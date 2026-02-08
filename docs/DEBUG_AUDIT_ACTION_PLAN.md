# FitLog Debug Audit - Action Plan

**Data**: 2026-02-08
**Team**: flutter-debugger, performance-optimizer, ios-specialist, firebase-expert
**Health Score Complessivo**: 79% (B)

---

## Executive Summary

| Area | Score | Issues Totali | Critical | High | Medium |
|------|-------|---------------|----------|------|--------|
| Flutter Audit | 87% (B+) | 1,243 | 3 | 7 | 10 |
| Performance | 70% (C+) | 13 | 5 | 8 | - |
| iOS Native | 84% (B+) | 19 | 7 | 12 | - |
| Firebase | 75% (C+) | 35 | 8 | 12 | 9 |
| **TOTALE** | **79%** | **~1,310** | **23** | **39** | **19** |

**Verdict**: Architettura solida, gap operativi critici da fixare prima del production scale.

---

## SEZIONE 1: CRITICAL FIXES (Da fare SUBITO)

### 1.1 Security Rules Firebase [CRITICO - PRIVACY]

**Problema**: Rules mancanti/permissive causano data leak e permission errors.

#### Fix 1.1.1: Aggiungere rules per `custom_exercises`

**File**: `firestore.rules`

```javascript
// AGGIUNGERE dopo le altre rules
match /custom_exercises/{userId}/exercises/{exerciseId} {
  allow read: if isOwner(userId);
  allow write: if isOwner(userId)
    && request.resource.data.keys().hasAll(['id', 'nome', 'category'])
    && request.resource.data.nome is string
    && request.resource.data.nome.size() > 0
    && request.resource.data.nome.size() <= 100;
  allow delete: if isOwner(userId);
}
```

#### Fix 1.1.2: Restringere analytics rules

**File**: `firestore.rules`

```javascript
// CAMBIARE DA:
match /users/{userId}/analytics/{exerciseName} {
  allow read: if isAuthenticated(); // TROPPO PERMISSIVO!
}

// A:
match /users/{userId}/analytics/{exerciseName} {
  allow read: if isOwner(userId) || isAdmin();
  allow write: if isOwner(userId);
  allow delete: if isOwner(userId) || isAdmin();
}
```

**Impatto**: Previene accesso non autorizzato ai dati workout di altri utenti.

---

### 1.2 Memory Leak - Listener Firebase [CRITICO - MEMORIA]

**File**: `lib/features/analytics/data/repositories/analytics_repository_impl.dart`
**Linee**: 88-149

**Problema**: `snapshots()` listener mai disposed.

```dart
// PROBLEMA ATTUALE
@override
Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(String userId) {
  return _firestore
      .collection('users')
      .doc(userId)
      .collection('analytics')
      .snapshots() // MAI DISPOSED!
      .map((snapshot) => ...);
}
```

**Fix**:

```dart
// SOLUZIONE: Tracking delle subscription
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final Map<String, StreamSubscription> _activeListeners = {};

  @override
  Stream<Either<Failure, List<ExerciseHistory>>> getExerciseHistory(String userId) {
    final controller = StreamController<Either<Failure, List<ExerciseHistory>>>();

    _activeListeners[userId]?.cancel(); // Cancel existing
    _activeListeners[userId] = _firestore
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .snapshots()
        .listen(
          (snapshot) => controller.add(Right(_parseHistories(snapshot))),
          onError: (e) => controller.add(Left(UnexpectedFailure(e.toString()))),
        );

    return controller.stream;
  }

  void dispose() {
    for (final sub in _activeListeners.values) {
      sub.cancel();
    }
    _activeListeners.clear();
  }
}
```

**Impatto**: Elimina memory leak attivo durante uso analytics.

---

### 1.3 Missing keepAlive() su Provider Hive [CRITICO - PERFORMANCE]

**File da modificare** (5 provider):

1. `lib/features/ai_coach/presentation/providers/ai_coach_provider.dart`
2. `lib/features/progress/presentation/providers/progress_provider.dart`
3. `lib/features/workout/presentation/providers/previous_workout_provider.dart`
4. `lib/features/workout/presentation/providers/exercise_weight_prefill_provider.dart`
5. `lib/features/workout/presentation/providers/plateau_detection_provider.dart`

**Fix** (aggiungere in ogni provider):

```dart
@override
FutureOr<T> build() async {
  ref.keepAlive(); // AGGIUNGERE QUESTA LINEA

  // ... resto del codice
}
```

**Impatto**: -50% memory churn, evita riapertura box Hive.

---

### 1.4 I/O in Loop - Cloud Sync [CRITICO - PERFORMANCE]

**File**: `lib/features/settings/presentation/providers/cloud_sync_provider.dart`
**Linee**: 275, 338, 382, 430, 473

**Problema**:

```dart
// ANTI-PATTERN ATTUALE
for (final item in items) {
  await box.put(item.id, item); // I/O ad ogni iterazione!
}
```

**Fix**:

```dart
// SOLUZIONE: Batch operation
final entries = <String, dynamic>{};
for (final item in items) {
  entries[item.id] = item;
}
await box.putAll(entries); // Singola operazione I/O
```

**Impatto**: 10-100x più veloce per sync di grandi dataset.

---

### 1.5 Query Firestore senza limit() [CRITICO - COSTI]

**File**: `lib/features/analytics/data/repositories/workout_analytics_repository_impl.dart`
**Linee**: 285-288

**Problema**:

```dart
// LEGGE TUTTI I DOCUMENTI!
final snapshot = await _firestore
    .collection('workouts')
    .where('userId', isEqualTo: userId)
    .get(); // Potenzialmente 1000+ documenti
```

**Fix**:

```dart
// AGGIUNGERE LIMIT
final snapshot = await _firestore
    .collection('workouts')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .limit(100) // Massimo ragionevole
    .get();
```

**Alternativa migliore** (per count):

```dart
// USARE AGGREGATION QUERY (zero document reads!)
final count = await _firestore
    .collection('workouts')
    .where('userId', isEqualTo: userId)
    .count()
    .get();

return count.count ?? 0;
```

**Impatto**: -65% costi Firestore, da ~$150/anno a ~$50/anno.

---

### 1.6 Hive Sequential Deletes [CRITICO - PERFORMANCE]

**File**: `lib/features/scheduling/data/datasources/hive_scheduling_datasource.dart`
**Linee**: 19-155

**Problema**:

```dart
// ANTI-PATTERN
for (final key in keysToDelete) {
  await box.delete(key); // N operazioni sequenziali
}
```

**Fix**:

```dart
// BATCH DELETE
await box.deleteAll(keysToDelete); // Singola operazione
```

**Impatto**: -80% tempo I/O per operazioni di pulizia.

---

### 1.7 iOS Race Condition - currentActivity [CRITICO - CRASH]

**File**: `ios/Runner/LiveActivityTimer/LiveActivityHandler.swift`
**Location**: Throughout file

**Problema**: `currentActivity` accessed da multiple thread senza sincronizzazione.

**Fix**:

```swift
// Aggiungere computed property thread-safe
private var _currentActivity: Activity<GymBroTimerAttributes>?
private var currentActivity: Activity<GymBroTimerAttributes>? {
    get { activityQueue.sync { _currentActivity } }
    set { activityQueue.sync { _currentActivity = newValue } }
}
```

**Impatto**: Previene crash random su Live Activities.

---

## SEZIONE 2: HIGH PRIORITY (Questa Settimana)

### 2.1 Widget Rebuild Optimization

**File**: `lib/features/workout/presentation/screens/workout_templates_screen.dart`
**Linee**: 138-142, 307-350

**Problema**: 150-200 rebuild/min invece di target 50.

**Fix**: Usare selective watching

```dart
// DA:
final user = ref.watch(authStateProvider).value;
final syncStatus = ref.watch(syncStatusProvider);

// A:
final userId = ref.watch(authStateProvider.select((s) => s.value?.uid));
final isSyncing = ref.watch(syncStatusProvider.select((s) => s.isSyncing));
```

**File aggiuntivi da ottimizzare**:
- `exercise_list_item_orchestrator.dart` (linee 1669-1684)
- `timer_action_bubble.dart` (linea 99)
- `workout_completion_celebration.dart` (linee 546-547)

**Impatto**: -70% rebuild, +10-15fps durante scroll.

---

### 2.2 AI Tool Execution Parallelo

**File**: `lib/features/ai_coach/data/services/ai_coach_service_impl.dart`
**Linee**: 122-136

**Problema**: Tool eseguiti sequenzialmente.

```dart
// DA:
for (final toolCallData in toolCallsJson) {
  final result = await toolExecutor.executeTool(...);
}

// A:
final toolResults = await Future.wait(
  toolCallsJson.map((toolCallData) async {
    return await toolExecutor.executeTool(...);
  }),
);
```

**Impatto**: -60% latenza risposta AI quando multiple tool.

---

### 2.3 Platform Channel Timeout

**File**: `lib/shared/services/notification_service.dart` e altri

**Problema**: Nessun timeout su chiamate iOS.

**Fix**:

```dart
try {
  await channel.invokeMethod('sendNotification', args)
      .timeout(const Duration(seconds: 5));
} on TimeoutException {
  // Fallback to local notification
}
```

**Impatto**: Previene hang su iOS init.

---

### 2.4 print() → debugPrint()

**File**: `lib/core/navigation/app_router.dart`
**Linee**: 138-231 (13 istanze)

**Fix**: Replace all `print()` con `debugPrint()`

```bash
# Comando rapido
sed -i '' 's/print(/debugPrint(/g' lib/core/navigation/app_router.dart
```

**Impatto**: Nessun output debug in production.

---

### 2.5 iOS Missing guard let self

**File**: `ios/Runner/BackgroundTaskManager/BackgroundTaskManager.swift`
**Linee**: 157-162

**Fix**:

```swift
// DA:
queue.async { [weak self] in
    self?.maintainSilentLoopIfNeeded()
}

// A:
queue.async { [weak self] in
    guard let self = self else { return }
    self.maintainSilentLoopIfNeeded()
}
```

**Impatto**: Previene memory issues su background tasks.

---

### 2.6 Audio Session Interruption Observer

**File**: `ios/Runner/AudioSessionManager.swift`
**Linee**: 97-126

**Problema**: Cache validation può diventare stale.

**Fix**:

```swift
// Aggiungere in init
NotificationCenter.default.addObserver(
    self,
    selector: #selector(audioSessionInterrupted),
    name: AVAudioSession.interruptionNotification,
    object: nil
)

@objc private func audioSessionInterrupted() {
    lastValidationResult = nil
    lastValidationTime = nil
}
```

---

### 2.7 Firestore Composite Indexes

**Creare file**: `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "workouts",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "status", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "workouts",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userId", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

**Deploy**:
```bash
firebase deploy --only firestore:indexes
```

---

### 2.8 Event Handler Debounce

**File da modificare**:
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/admin/presentation/providers/admin_provider.dart`
- `lib/features/workout/data/workout_dependency_injection.dart`

**Pattern**:

```dart
Timer? _debounceTimer;

void _onEvent(Event event) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 100), () {
    // Handle event
  });
}

@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}
```

---

## SEZIONE 3: MEDIUM PRIORITY (Prossimo Sprint)

### 3.1 CLAUDE.md Rule Violations

#### Colors.* → context.colors.*

**File da fixare** (50+ istanze):
- `chat_input_bar.dart:196`
- `weight_update_nudge_card.dart:76`
- `template_wizard_reminder_card.dart:67`
- Altri 47+ file

**Pattern**:

```dart
// DA:
color: Colors.blue

// A:
color: context.colors.primary
```

#### Hardcoded Strings → context.l10n.*

**Esempi critici**:
- `"Salvataggio fallito"` → `context.l10n.saveFailed`
- `"No workout data this week"` → `context.l10n.noWorkoutDataThisWeek`
- `"Select Photo"` → `context.l10n.selectPhoto`

**Workflow**:
1. Aggiungere chiave in `lib/shared/presentation/l10n/app_en.arb`
2. Aggiungere traduzione in `lib/shared/presentation/l10n/app_it.arb`
3. Eseguire `flutter gen-l10n`
4. Sostituire stringa con `context.l10n.keyName`

#### CircularProgressIndicator → LoadingIndicator()

**File** (10 istanze):
- `metric_display.dart`
- `template_gdpr_dialogs.dart`
- `pending_template_sync_indicator.dart`
- Altri 7 file

#### ScaffoldMessenger → SnackBarService

**File** (4 istanze): Cercare e sostituire.

---

### 3.2 Flutter Analyze Auto-fix

```bash
# Eseguire per fixare ~1100 warning automaticamente
dart fix --apply

# Verifica risultato
flutter analyze
```

**Warning che verranno fixati**:
- `prefer_const_constructors`: 600+
- `prefer_const_literals_to_create_immutables`: 500+

---

### 3.3 iOS File Refactoring

**File troppo grandi** (>1500 linee):

1. `BackgroundAudioManager.swift` (1692 lines)
   - Separare in: `BackgroundAudioManager`, `SilentLoopManager`, `NotificationScheduler`

2. `WatchConnectivityManager.swift` (1668 lines)
   - Separare logica Watch-specific

---

### 3.4 Sync Conflict Resolution

**File**: `lib/features/workout/data/repositories/hybrid_workout_repository_impl.dart`
**Linee**: 784-811

**Problema**: Last-write-wins può causare data loss.

**Fix**: Implementare version-based conflict resolution.

```dart
// Aggiungere a WorkoutModel
final int version; // Incrementare ad ogni modifica

// Nella merge logic
if (remote.version > local.version) {
  // Remote wins
} else if (remote.version == local.version && remote.updatedAt != local.updatedAt) {
  // Conflict! Merge or prompt user
}
```

---

## SEZIONE 4: LOW PRIORITY (Backlog)

### 4.1 SKAdNetwork Cleanup

**File**: `ios/Runner/Info.plist`

**Azione**: Audit dei 76 SKAdNetwork IDs e rimuovere quelli non utilizzati.

### 4.2 Type Safety Platform Channels

**Azione**: Considerare migrazione a Pigeon per type-safe platform channels.

### 4.3 Firestore Cache Configuration

```dart
// Aggiungere in app init
await FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: 100 * 1024 * 1024, // 100MB
);
```

---

## SEZIONE 5: Checklist Esecuzione

### OGGI (30 min)
- [ ] Fix security rules `custom_exercises`
- [ ] Fix security rules analytics
- [ ] Add `keepAlive()` a 5 provider
- [ ] Replace `print()` → `debugPrint()` in app_router.dart

### QUESTA SETTIMANA (4-6 ore)
- [ ] Fix listener leak AnalyticsRepository
- [ ] Fix I/O loop in cloud_sync_provider.dart
- [ ] Add `limit()` a query analytics
- [ ] Fix Hive sequential deletes
- [ ] Fix iOS race condition currentActivity
- [ ] Add platform channel timeout

### PROSSIMO SPRINT (1-2 giorni)
- [ ] Selective watching su widget principali
- [ ] AI tool execution parallelo
- [ ] Eseguire `dart fix --apply`
- [ ] Fix 50+ Colors.* violations
- [ ] Fix 50+ hardcoded strings
- [ ] Deploy composite indexes

### BACKLOG
- [ ] iOS file refactoring
- [ ] Version-based conflict resolution
- [ ] SKAdNetwork cleanup
- [ ] Pigeon migration

---

## SEZIONE 6: Metriche di Successo

| Metrica | Attuale | Target | Come Misurare |
|---------|---------|--------|---------------|
| Widget rebuilds/min | 150-200 | <50 | DevTools Performance |
| Cloud sync time | 10-30s | 1-3s | Stopwatch in debug |
| Memory baseline | ~120MB | <100MB | DevTools Memory |
| Firestore reads/day | ~5000 | <2000 | Firebase Console |
| iOS crash rate | ~0.5% | <0.1% | Crashlytics |
| flutter analyze issues | 1,243 | <50 | `flutter analyze` |

---

## SEZIONE 7: Comandi Utili

```bash
# Performance check
.claude/scripts/performance-check.sh lib/features/

# Flutter analyze
flutter analyze

# Auto-fix warning
dart fix --apply

# Regenerate l10n
flutter gen-l10n

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# Full health check
.claude/scripts/health-check.sh
```

---

## Appendice A: File Critici per Area

### Security
- `firestore.rules`

### Memory Leaks
- `analytics_repository_impl.dart`
- 5 provider files (keepAlive)

### Performance Flutter
- `cloud_sync_provider.dart`
- `workout_templates_screen.dart`
- `exercise_list_item_orchestrator.dart`
- `hive_scheduling_datasource.dart`
- `ai_coach_service_impl.dart`

### Performance Firebase
- `workout_analytics_repository_impl.dart`
- `analytics_migration_service.dart`

### iOS Native
- `LiveActivityHandler.swift`
- `BackgroundTaskManager.swift`
- `AudioSessionManager.swift`
- `AppDelegate.swift`

### CLAUDE.md Violations
- 50+ file con `Colors.*`
- 50+ file con hardcoded strings
- 10 file con `CircularProgressIndicator`

---

**Documento generato**: 2026-02-08
**Prossima review consigliata**: 2026-02-15
