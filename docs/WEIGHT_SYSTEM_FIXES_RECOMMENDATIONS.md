# Raccomandazioni di Fix - Sistema Pesi GymBro

## Priorità e Timeline

| Priorità | Bug | Effort | Impact |
|----------|-----|--------|--------|
| 🔴 CRITICAL | Cloud→Local sync fallace | 4h | Multi-device users |
| 🟡 MEDIUM | Case-sensitive matching | 2h | 30% users |
| 🟡 MEDIUM | Memory leak ExerciseHistory | 1h | RAM usage |
| 🟢 LOW | Weak error handling | 1h | UX only |
| 🟢 LOW | Fuzzy matching | 3h | Optional enhancement |

---

## FIX #1: Cloud to Local Sync (CRITICAL)

### Problema
Premium users con workout cloud non vedono history su local device.

### Soluzione A: Aggressive Sync (Simple)

```dart
// File: lib/features/workout/presentation/providers/exercise_history_provider.dart

// Nuovo provider per trigger sync
final exerciseHistorySyncProvider = 
  FutureProvider.autoDispose.family<void, String>((ref, userId) async {
    // Recupera workouts da Firebase
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('users/$userId/workouts')
        .orderBy('endTime', descending: true)
        .limit(10)
        .get();
    
    // Sincronizza in Hive
    final boxManager = ref.watch(hiveBoxManagerProvider);
    final box = await boxManager.openBox<Map>('workouts');
    
    for (final doc in snapshot.docs) {
      final key = '${userId}_${doc.id}';
      final data = doc.data();
      await box.put(key, data);
    }
  });

// Chiama questo provider dopo salvataggio
@override
Future<Either<Failure, String>> saveWorkout(Workout workout) async {
  // ... existing code ...
  
  // ✅ NEW: Trigger sync dopo save
  if (isPremiumUser || await isAdminUser) {
    _syncToCloudInBackground(
      workoutModel: workoutModel,
      userId: currentUser.uid,
      operation: 'save',
    );
    
    // ✅ NEW: Invalidate cache per next query
    ref.invalidate(exerciseHistorySyncProvider(currentUser.uid));
  }
  
  return right(localResult);
}
```

### Soluzione B: Event-Driven Sync (Better)

```dart
// File: lib/shared/domain/services/sync_event_service.dart

class SyncEventService {
  static final _instance = SyncEventService._();
  factory SyncEventService() => _instance;
  SyncEventService._();
  
  final _syncController = StreamController<SyncEvent>.broadcast();
  Stream<SyncEvent> get syncEvents => _syncController.stream;
  
  void notifyWorkoutSaved(String userId, String workoutId) {
    _syncController.add(SyncEvent(
      type: SyncEventType.workoutSaved,
      userId: userId,
      workoutId: workoutId,
      timestamp: DateTime.now(),
    ));
  }
  
  void dispose() {
    _syncController.close();
  }
}

// Usar in repository
Future<Either<Failure, String>> saveWorkout(Workout workout) async {
  // ... existing code ...
  
  // ✅ Notify subscribers
  SyncEventService().notifyWorkoutSaved(userId, localResult);
  
  return right(localResult);
}

// Listen in service
final syncListenerProvider = StreamProvider.autoDispose((ref) {
  return SyncEventService().syncEvents;
});

final exerciseHistoryServiceProvider = Provider((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  final service = ExerciseHistoryService(boxManager: boxManager);
  
  // Listen to sync events
  ref.listen(syncListenerProvider, (prev, next) {
    next.whenData((event) {
      if (event.type == SyncEventType.workoutSaved) {
        // Invalidate cache
        ref.invalidate(recentWeightsProvider);
      }
    });
  });
  
  return service;
});
```

### Implementation Steps

1. **Scegli approccio**: A (simple) o B (robust)
2. **Aggiungi invalidation logic** a HybridWorkoutRepository
3. **Test cross-device**: Device A save → Device B load
4. **Monitor**: Aggiungi logging per verify sync

### Test Cases

```dart
test('Premium user: Cloud workout syncs to local', () async {
  // 1. Save workout on device A
  // 2. Switch to device B
  // 3. Trigger sync
  // 4. Assert: getExerciseHistory returns data
});

test('Multi-set sync maintains order', () async {
  // 1. Save workout with 20 sets
  // 2. Sync
  // 3. Assert: All sets present and in order
});

test('Sync preserves all metadata (RPE, TUT, duration)', () async {
  // 1. Save workout with metadata
  // 2. Sync
  // 3. Assert: All fields preserved
});
```

---

## FIX #2: Robust Exercise Name Matching

### Problema
"Bench Press" vs "bench press" vs "Bench  Press" non sempre match.

### Soluzione: Normalization Layer

```dart
// File: lib/shared/utils/exercise_name_normalizer.dart

class ExerciseNameNormalizer {
  
  /// Normalizza nome esercizio per matching robusto
  static String normalize(String name) {
    return name
        .toLowerCase()
        .trim()
        // Normalizza spazi multipli
        .replaceAll(RegExp(r'\s+'), ' ')
        // Rimuovi accenti
        .replaceAll(RegExp(r'[àáâäå]'), 'a')
        .replaceAll(RegExp(r'[èéêëē]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôöø]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        // Rimuovi punteggiatura
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }
  
  /// Calcola similarità tra due nomi (0.0 = diverso, 1.0 = identico)
  static double calculateSimilarity(String name1, String name2) {
    final n1 = normalize(name1);
    final n2 = normalize(name2);
    
    // Exact match
    if (n1 == n2) return 1.0;
    
    // Substring match (parziale)
    if (n1.contains(n2) || n2.contains(n1)) return 0.8;
    
    // Levenshtein distance
    return _levenshteinSimilarity(n1, n2);
  }
  
  /// Levenshtein distance: misura minimo edit per trasformare a→b
  static double _levenshteinSimilarity(String a, String b) {
    final aLen = a.length;
    final bLen = b.length;
    
    if (aLen == 0) return bLen == 0 ? 1.0 : 0.0;
    if (bLen == 0) return 0.0;
    
    // Matrice di distanze
    final dp = List.generate(aLen + 1, (_) => List.filled(bLen + 1, 0));
    
    for (int i = 0; i <= aLen; i++) dp[i][0] = i;
    for (int j = 0; j <= bLen; j++) dp[0][j] = j;
    
    for (int i = 1; i <= aLen; i++) {
      for (int j = 1; j <= bLen; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,      // Cancella
          dp[i][j - 1] + 1,      // Inserisci
          dp[i - 1][j - 1] + cost // Replace
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    final distance = dp[aLen][bLen];
    final maxLen = (aLen > bLen ? aLen : bLen).toDouble();
    return 1.0 - (distance / maxLen);
  }
  
  /// Mapping esercizio → variazioni note
  static final _exerciseVariations = {
    'panca piana': [
      'bench press', 'flat bench', 'panca', 'distensioni panca',
      'horizontal bench', 'barbell bench'
    ],
    'squat': [
      'back squat', 'front squat', 'goblet squat', 'smith squat',
      'accosciata', 'accosciate'
    ],
    'stacco': [
      'deadlift', 'stacco da terra', 'stacchi', 'sumo deadlift',
      'romanian deadlift', 'trap bar deadlift'
    ],
    'rematore': [
      'barbell row', 'dumbbell row', 'pendlay row', 'bent over row',
      'machine row', 'cable row', 'rowing'
    ],
    'military press': [
      'overhead press', 'standing press', 'spinte militari',
      'lento avanti', 'shoulder press', 'pike press'
    ],
    'curl': [
      'bicep curl', 'curl bicipiti', 'dumbbell curl', 'barbell curl',
      'machine curl', 'cable curl'
    ],
  };
  
  /// Ottieni tutte le variazioni note per un esercizio
  static Set<String> getVariations(String exerciseName) {
    final normalized = normalize(exerciseName);
    final variations = <String>{normalized};
    
    // Cerca nel mapping
    for (final entry in _exerciseVariations.entries) {
      if (normalize(entry.key) == normalized) {
        variations.addAll(
          entry.value.map((v) => normalize(v))
        );
        break;
      }
    }
    
    return variations;
  }
}

// TEST CASES
void main() {
  expect(ExerciseNameNormalizer.normalize('Bench Press'), 'bench press');
  expect(ExerciseNameNormalizer.normalize('bench  press'), 'bench press');
  expect(ExerciseNameNormalizer.normalize('BENCH PRESS'), 'bench press');
  expect(ExerciseNameNormalizer.normalize('Panca Piana'), 'panca piana');
  
  expect(
    ExerciseNameNormalizer.calculateSimilarity('Bench Press', 'bench press'),
    1.0
  );
  expect(
    ExerciseNameNormalizer.calculateSimilarity('Bench Press', 'Barbell Bench'),
    greaterThan(0.7)
  );
}
```

### Usare in ExerciseHistoryService

```dart
// File: lib/features/workout/data/services/exercise_history_service.dart

// OLD:
if (exerciseNameLower == searchNameLower) {
  isMatch = true;
} else if (...) {
  // hardcoded variations
}

// NEW:
final similarity = ExerciseNameNormalizer.calculateSimilarity(
  exercise.name,
  exerciseName,
);

if (similarity >= 0.8) {  // 80% match threshold
  isMatch = true;
}
```

### Migration Steps

1. Crea `exercise_name_normalizer.dart`
2. Aggiungi unit tests
3. Aggiorna `exercise_history_service.dart`
4. Test cross-platform matching
5. Deploy & monitor

---

## FIX #3: Memory Leak - Close Hive Boxes

### Problema
ExerciseHistoryService apre boxes senza chiuderli.

### Soluzione: Using Statement Pattern

```dart
// OLD (linea 124-125)
final box = await _boxManager.openBox<Map>(_workoutsBoxName);
// ... query ...
return result;  // ❌ Box rimane aperto

// NEW
Future<List<ExerciseHistoryData>> _getExerciseHistory(...) async {
  try {
    final box = await _boxManager.openBox<Map>(_workoutsBoxName);
    // ... query logic ...
    return result;
  } finally {
    // ✅ Sempre chiudi
    if (Hive.isBoxOpen(_workoutsBoxName)) {
      await Hive.box<Map>(_workoutsBoxName).close();
    }
  }
}
```

### Alternative: Box Manager Wrapper

```dart
// File: lib/core/data/hive_box_context.dart

class HiveBoxContext {
  HiveBoxContext(this._boxManager, this._boxName);
  
  final HiveBoxManagerEnhanced _boxManager;
  final String _boxName;
  
  late Box<Map> _box;
  
  Future<void> open() async {
    _box = await _boxManager.openBox<Map>(_boxName);
  }
  
  Future<T> query<T>(Future<T> Function(Box<Map>) fn) async {
    try {
      return await fn(_box);
    } finally {
      await _box.close();
    }
  }
  
  Future<void> close() async {
    await _box.close();
  }
}

// USAGE
final context = HiveBoxContext(boxManager, 'workouts');
await context.open();

final result = await context.query((box) async {
  // Query logic
  return data;
});
```

### Implementation (Quick Fix)

```dart
// Minimal change - aggiungi finally block
Future<List<ExerciseHistoryData>> _getExerciseHistory(
  String exerciseName, 
  String userId, 
  {int limit = 10}
) async {
  try {
    final box = await _boxManager.openBox<Map>(_workoutsBoxName);
    final historyData = <ExerciseHistoryData>[];
    
    // ... existing query logic ...
    
    return historyData.take(limit).toList();
  } finally {
    // ✅ CRITICAL: Close box sempre
    try {
      if (Hive.isBoxOpen(_workoutsBoxName)) {
        await Hive.box<Map>(_workoutsBoxName).close();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error closing Hive box: $e');
      }
    }
  }
}
```

### Verification

```bash
# Monitor memory usage prima/dopo
1. Open DevTools Memory profiler
2. Add exercise che trigga history load
3. Ripeti 10 volte
4. PRIMA (bug): Memory increases 10-15MB
5. DOPO (fix): Memory stays stable ±500KB
```

---

## FIX #4: Error Handling - User Feedback

### Problema
Se load pesi fallisce, user non sa.

### Soluzione

```dart
// File: lib/features/workout/presentation/widgets/enhanced_add_exercise_modal.dart

Future<void> _loadPreviousWeights(String exerciseName) async {
  try {
    final workouts = ref.read(workoutHistoryProvider);
    
    // ... existing logic ...
    
    // Se arriva qui, significa success
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.previousWeightsLoaded),
          backgroundColor: context.colors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } on TimeoutException catch (e) {
    // ✅ NEW: Timeout feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.loadWeightsTimeout),
          backgroundColor: context.colors.warning,
        ),
      );
    }
    debugPrint('⏱️ Timeout loading weights: $e');
  } catch (e) {
    // ✅ NEW: Generic error feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.loadWeightsFailed),
          backgroundColor: context.colors.error,
          action: SnackBarAction(
            label: context.l10n.retry,
            onPressed: () => _loadPreviousWeights(exerciseName),
          ),
        ),
      );
    }
    debugPrint('❌ Error loading previous weights: $e');
  }
}
```

### Add to Localization

```yaml
# assets/i18n/app_en.arb
"previousWeightsLoaded": "Previous weights loaded successfully",
"loadWeightsTimeout": "Loading took too long, using defaults",
"loadWeightsFailed": "Could not load previous weights",
"retry": "Retry"

# assets/i18n/app_it.arb
"previousWeightsLoaded": "Pesi precedenti caricati",
"loadWeightsTimeout": "Caricamento troppo lento, usando default",
"loadWeightsFailed": "Impossibile caricare pesi",
"retry": "Riprova"
```

---

## FIX #5: Timeout Protection

### Problema
Se Hive è corrotto, openBox() freezes indefinitamente.

### Soluzione

```dart
// File: lib/features/workout/data/services/exercise_history_service.dart

Future<List<ExerciseHistoryData>> _getExerciseHistory(...) async {
  try {
    // ✅ Aggiungi timeout
    final box = await _boxManager.openBox<Map>(_workoutsBoxName)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException(
              'Hive box "$_workoutsBoxName" timeout after 5s'
            );
          },
        );
    
    // ... rest of logic ...
    
  } on TimeoutException catch (e) {
    if (enableDebugLogging && kDebugMode) {
      debugPrint('⏱️ [HISTORY] Timeout: $e');
      debugPrint('📍 This usually means Hive box is corrupted');
    }
    return [];  // Return empty instead of freezing
    
  } catch (e) {
    // ... existing error handling ...
  }
}
```

---

## Implementation Priority

### Week 1 (Critical)
- [ ] Fix #1: Cloud→Local sync
- [ ] Testing & validation

### Week 2 (High Impact)
- [ ] Fix #2: Exercise name matching
- [ ] Fix #3: Memory leak

### Week 3 (Quality)
- [ ] Fix #4: Error handling
- [ ] Fix #5: Timeout protection

---

## Testing Checklist

```dart
// Test suite da aggiungere
test_suite:
  - exercise_name_normalizer_test.dart
  - weight_recovery_sync_test.dart
  - exercise_history_memory_test.dart
  - weight_loading_error_handling_test.dart
```

### CI/CD Integration

```yaml
# .github/workflows/tests.yml
- name: Weight System Tests
  run: |
    flutter test test/features/workout/weight_*.dart --coverage
    
- name: Memory Profiling
  run: |
    dart run test --concurrency=1 test/memory_leak_test.dart
```

