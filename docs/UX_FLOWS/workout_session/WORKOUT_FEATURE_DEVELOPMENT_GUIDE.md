# 🛠️ Workout Feature Development Guide
## Rules of Engagement (ROE) per Nuove Funzionalità

> Questa guida contiene le regole obbligatorie e le best practices per sviluppare nuove feature nel sistema workout di GymBro. Da leggere PRIMA di iniziare qualsiasi sviluppo.

---

## 📋 Indice

1. [Prima di Iniziare](#1-prima-di-iniziare)
2. [Architettura da Rispettare](#2-architettura-da-rispettare)
3. [State Management Rules](#3-state-management-rules)
4. [Data Persistence Rules](#4-data-persistence-rules)
5. [UI/UX Guidelines](#5-uiux-guidelines)
6. [iOS Integration Rules](#6-ios-integration-rules)
7. [Testing Requirements](#7-testing-requirements)
8. [Performance Requirements](#8-performance-requirements)
9. [Security & Validation](#9-security--validation)
10. [Checklist Pre-Commit](#10-checklist-pre-commit)

---

## 1. Prima di Iniziare

### ✅ Prerequisiti Obbligatori

Prima di scrivere anche solo una riga di codice, devi:

1. **Leggere la documentazione esistente**:
   ```
   ✓ CLAUDE.md (regole globali del progetto)
   ✓ WORKOUT_SYSTEM_OVERVIEW.md (overview funzionale)
   ✓ Questo documento (ROE specifiche workout)
   ```

2. **Analizzare l'esistente**:
   ```dart
   // Cerca implementazioni simili già presenti
   $ grep -r "feature_simile" lib/features/workout/

   // Analizza i provider esistenti
   $ ls lib/features/workout/presentation/providers/

   // Studia i test correlati
   $ ls test/features/workout/
   ```

3. **Verificare dependencies**:
   ```bash
   # Controlla provider dependencies nel grafo Riverpod
   flutter pub run riverpod_graph

   # Verifica che non ci siano circular dependencies
   ```

4. **Creare un design document** (anche informale):
   ```markdown
   ## Feature: [Nome Feature]

   ### Obiettivo
   Cosa vogliamo ottenere?

   ### Impatto
   - Quali file verranno modificati?
   - Quali provider coinvolti?
   - Nuove entità necessarie?

   ### Flusso Utente
   1. Step 1...
   2. Step 2...

   ### Rischi
   - Race conditions possibili?
   - Impatto performance?
   - Breaking changes?
   ```

---

## 2. Architettura da Rispettare

### 🏗️ Clean Architecture Layers

**REGOLA FERREA**: Rispetta SEMPRE la separazione dei layer.

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                          │
│ - Screens (UI)                                              │
│ - Widgets (Components)                                      │
│ - Providers (State Management)                              │
│                                                             │
│ ❌ NON può dipendere da: Data layer implementation         │
│ ✅ PUÒ dipendere da: Domain layer (entities, use cases)    │
└─────────────────────────────────────────────────────────────┘
                         ↓ usa ↓
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER                                                │
│ - Entities (Business Objects)                               │
│ - Use Cases (Business Logic)                                │
│ - Repository Interfaces                                     │
│ - Domain Services                                           │
│                                                             │
│ ❌ NON può dipendere da: Nessun altro layer                │
│ ✅ DEVE essere: Pure Dart (no Flutter, no Firebase)        │
└─────────────────────────────────────────────────────────────┘
                         ↑ implementa ↑
┌─────────────────────────────────────────────────────────────┐
│ DATA LAYER                                                  │
│ - Repository Implementations                                │
│ - Data Sources (Hive, Firebase)                             │
│ - Models (Serialization)                                    │
│ - Mappers (Entity ↔ Model)                                  │
│                                                             │
│ ❌ NON può dipendere da: Presentation layer                │
│ ✅ PUÒ dipendere da: Domain layer (solo interfaces)        │
└─────────────────────────────────────────────────────────────┘
```

### 📁 Struttura Directory Obbligatoria

Per aggiungere una feature `exercise_analytics`:

```
lib/features/workout/
├── domain/
│   ├── entities/
│   │   └── exercise_analytics.dart        # STEP 1: Entità business
│   ├── usecases/
│   │   └── calculate_analytics_usecase.dart  # STEP 2: Business logic
│   └── repositories/
│       └── analytics_repository.dart      # STEP 3: Interface
│
├── data/
│   ├── models/
│   │   └── exercise_analytics_model.dart  # STEP 4: Serialization
│   ├── repositories/
│   │   └── analytics_repository_impl.dart # STEP 5: Implementation
│   └── datasources/
│       └── analytics_datasource.dart      # STEP 6: Hive/Firebase
│
└── presentation/
    ├── providers/
    │   └── analytics_provider.dart        # STEP 7: State management
    ├── screens/
    │   └── analytics_screen.dart          # STEP 8: UI principale
    └── widgets/
        └── analytics_chart.dart           # STEP 9: Components
```

**❌ MAI creare file fuori da questa struttura!**

---

## 3. State Management Rules

### 🎯 Riverpod Provider Guidelines

#### REGOLA #1: Un Provider = Una Responsabilità

```dart
// ❌ SBAGLIATO - Provider che fa troppe cose
final megaWorkoutProvider = StateNotifierProvider<MegaNotifier, MegaState>((ref) {
  return MegaNotifier(); // Gestisce workout + analytics + export + ...
});

// ✅ CORRETTO - Responsabilità separate
final currentWorkoutProvider = StateNotifierProvider<CurrentWorkoutNotifier, Workout?>(...);
final workoutAnalyticsProvider = Provider<WorkoutAnalytics>(...);
final workoutExportProvider = Provider<WorkoutExportService>(...);
```

#### REGOLA #2: Usa .select() per Ottimizzare Rebuilds

```dart
// ❌ SBAGLIATO - Rebuild ogni volta che workout cambia
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(currentWorkoutProvider);
    return Text('Exercises: ${workout?.exercises.length ?? 0}');
  }
}

// ✅ CORRETTO - Rebuild solo quando exercises.length cambia
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseCount = ref.watch(
      currentWorkoutProvider.select((w) => w?.exercises.length ?? 0)
    );
    return Text('Exercises: $exerciseCount');
  }
}
```

#### REGOLA #3: Provider Dependencies

```dart
// ✅ CORRETTO - Dichiarare dependencies esplicitamente
final workoutStatsProvider = Provider<WorkoutStats>((ref) {
  final workout = ref.watch(currentWorkoutProvider);
  final history = ref.watch(workoutHistoryProvider);

  // Calcola stats basandosi su entrambi
  return WorkoutStats.calculate(workout, history);
});

// Provider dipende da altri provider:
// - currentWorkoutProvider
// - workoutHistoryProvider
```

**⚠️ ATTENZIONE**: Verifica sempre con `riverpod_graph` che non ci siano circular dependencies!

#### REGOLA #4: Atomic Operations

```dart
// ✅ CORRETTO - Atomic flags per operazioni critiche
class WorkoutNotifier extends StateNotifier<Workout?> {
  bool _saveInProgress = false;

  Future<void> saveWorkout() async {
    // Atomic check-and-set
    if (_saveInProgress) return;
    _saveInProgress = true;

    try {
      await _performSave();
    } finally {
      _saveInProgress = false; // Always release lock
    }
  }
}
```

#### REGOLA #5: Disposal Sicuro

```dart
// ✅ CORRETTO - Check disposal prima di async operations
class TimerNotifier extends StateNotifier<TimerState?> {
  bool _isDisposed = false;

  Future<void> startTimer() async {
    await _initializeComponents();

    // CRITICAL: Check after async boundary
    if (_isDisposed) return;

    state = TimerState.started();
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark first
    _cleanup();
    super.dispose();
  }
}
```

---

## 4. Data Persistence Rules

### 💾 Hybrid Storage Pattern

**REGOLA ASSOLUTA**: Sempre salvataggio locale PRIMA, poi cloud in background.

```dart
// ✅ TEMPLATE OBBLIGATORIO per save operations
Future<Either<Failure, String>> saveEntity(Entity entity) async {
  try {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return left(AuthenticationFailure('Not authenticated'));
    }

    // 1. SEMPRE salvare localmente PRIMA (instant response)
    final localId = await _localDataSource.save(entity, currentUser.uid);

    // 2. SE premium/admin, sync cloud in BACKGROUND (non-blocking)
    if (isPremiumUser || isAdminUser) {
      _syncToCloudInBackground(entity, currentUser.uid);
    }

    // 3. Ritorna SUBITO con ID locale (non aspetta cloud)
    return right(localId);

  } catch (e) {
    return left(UnexpectedFailure('Save failed: $e'));
  }
}

// Background sync (fire-and-forget)
void _syncToCloudInBackground(Entity entity, String userId) {
  Future(() async {
    try {
      if (await hasConnection) {
        await _remoteDataSource.save(entity, userId);
      }
    } catch (e) {
      // Log error ma NON bloccare l'utente
      debugPrint('Background sync failed: $e');
    }
  });
}
```

### 🔄 Conflict Resolution

```dart
// ✅ STRATEGIA OBBLIGATORIA per merge conflicts
List<EntityModel> _mergeEntities(
  List<EntityModel> local,
  List<EntityModel> remote,
) {
  final merged = <String, EntityModel>{};

  // 1. Aggiungi tutti i local
  for (final entity in local) {
    merged[entity.id] = entity;
  }

  // 2. Merge remote (remote vince in caso di conflitto)
  for (final entity in remote) {
    final localVersion = merged[entity.id];

    if (localVersion == null) {
      // Nuovo da cloud
      merged[entity.id] = entity;
    } else {
      // Conflitto: usa il più recente
      if (entity.updatedAt.isAfter(localVersion.updatedAt)) {
        merged[entity.id] = entity; // Remote wins
      }
      // else: local wins (già in merged)
    }
  }

  return merged.values.toList();
}
```

### 🗄️ Hive Best Practices

```dart
// ✅ CORRETTO - Lazy box opening
class EntityDataSource {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openLazyBox<Map>('entity_storage');
    return _box!;
  }

  Future<void> save(String key, Map data) async {
    final b = await box;
    await b.put(key, data);
  }
}

// ✅ CORRETTO - Validazione prima di salvare
Future<void> save(EntityModel entity) async {
  // Validation
  if (entity.id.isEmpty) {
    throw ValidationException('Entity ID cannot be empty');
  }

  if (entity.createdAt.isAfter(DateTime.now())) {
    throw ValidationException('createdAt cannot be in future');
  }

  // Save solo se valido
  await box.put(entity.id, entity.toJson());
}
```

---

## 5. UI/UX Guidelines

### 🎨 Localization (OBBLIGATORIO)

**REGOLA #1**: ZERO hardcoded strings.

```dart
// ❌ SBAGLIATO
Text('Workout Complete')
AppBar(title: Text('Settings'))

// ✅ CORRETTO
Text(context.l10n.workoutComplete)
AppBar(title: Text(context.l10n.settings))
```

**REGOLA #2**: Aggiungere traduzioni in ENTRAMBE le lingue.

```json
// assets/i18n/app_en.arb
{
  "myNewFeature": "My New Feature",
  "@myNewFeature": {
    "description": "Title for the new feature screen"
  }
}

// assets/i18n/app_it.arb
{
  "myNewFeature": "La Mia Nuova Feature"
}
```

**REGOLA #3**: Rigenerare sempre dopo modifiche.

```bash
flutter gen-l10n
```

### 🎨 Theme Support (OBBLIGATORIO)

**REGOLA #1**: ZERO hardcoded colors.

```dart
// ❌ SBAGLIATO
Container(color: Colors.blue)
Text(style: TextStyle(color: Colors.black))

// ✅ CORRETTO
Container(color: context.colors.primary)
Text(style: TextStyle(color: context.colors.onSurface))
```

**REGOLA #2**: Testare in ENTRAMBI i temi.

```dart
// Test con tema chiaro
testWidgets('should work in light mode', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: MyWidget(),
    ),
  );
  // assertions...
});

// Test con tema scuro
testWidgets('should work in dark mode', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: MyWidget(),
    ),
  );
  // assertions...
});
```

### 📱 Responsive Design

```dart
// ✅ CORRETTO - Usa MediaQuery tramite extensions
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final isTablet = screenWidth > 600;

    return Container(
      width: isTablet ? screenWidth * 0.6 : screenWidth * 0.9,
      child: ...,
    );
  }
}
```

### 🔄 Loading States

```dart
// ✅ CORRETTO - Usa LoadingIndicator unificato
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutProvider);

    return workout.when(
      data: (data) => WorkoutView(data),
      loading: () => LoadingIndicator(
        message: context.l10n.loadingWorkout,
      ),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

### 📢 User Feedback

```dart
// ✅ CORRETTO - Usa SnackBarService
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

Future<void> saveWorkout() async {
  final result = await repository.saveWorkout(workout);

  result.fold(
    (failure) => SnackBarService.showError(
      context,
      context.l10n.errorSavingWorkout,
    ),
    (id) => SnackBarService.showSuccess(
      context,
      context.l10n.workoutSavedSuccessfully,
    ),
  );
}
```

---

## 6. iOS Integration Rules

### 📱 Platform-Specific Code

**REGOLA #1**: Sempre check Platform PRIMA di chiamare iOS-specific code.

```dart
// ✅ CORRETTO
if (Platform.isIOS) {
  await _startLiveActivity();
}

// ❌ SBAGLIATO - Crash su Android!
await _startLiveActivity();
```

**REGOLA #2**: Usa il canale unificato per iOS.

```dart
// ✅ CORRETTO - Single source of truth
static const _unifiedChannel = MethodChannel('com.gymbro.timer/unified');

Future<void> startLiveActivity() async {
  if (!Platform.isIOS) return;

  try {
    await _unifiedChannel.invokeMethod('startLiveActivity', {
      'exerciseName': exercise,
      'totalSeconds': duration,
      // ...
    });
  } catch (e) {
    debugPrint('Live Activity failed: $e');
    // Fallback non-iOS behavior
  }
}
```

**REGOLA #3**: Fallback sempre disponibile.

```dart
// ✅ PATTERN OBBLIGATORIO
Future<void> playCompletionSound() async {
  if (Platform.isIOS) {
    try {
      // iOS native audio
      await _unifiedChannel.invokeMethod('playCompletionSound', {...});
    } catch (e) {
      // Fallback: notification
      await _sendNotificationAsFallback();
    }
  } else {
    // Android: Flutter AudioPlayer
    await _audioPlayer.play(AssetSource('sounds/sound.wav'));
  }
}
```

### 🔔 Notifications

**REGOLA #1**: iOS usa SOLO native notifications.

```dart
// ✅ CORRETTO
if (Platform.isIOS) {
  // iOS: ALWAYS use native bridge
  await _unifiedChannel.invokeMethod('sendNotification', {
    'title': context.l10n.timerComplete,
    'body': context.l10n.timerCompleteBody,
    'sound': 'sound',
  });
} else {
  // Android: Use flutter_local_notifications
  await _notifications.show(...);
}
```

**REGOLA #2**: Verificare delivery su iOS.

```dart
// ✅ CORRETTO - Verify delivery after 1s
final notificationId = await _unifiedChannel.invokeMethod('sendNotification', {...});

if (notificationId != null && notificationId is String) {
  await Future.delayed(const Duration(seconds: 1));

  final wasDelivered = await _unifiedChannel.invokeMethod<bool>(
    'wasNotificationDelivered',
    {'identifier': notificationId}
  );

  if (wasDelivered != true) {
    // Send fallback notification
    await _sendFallbackNotification();
  }
}
```

---

## 7. Testing Requirements

### ✅ Test Coverage Obbligatoria

Ogni nuova feature DEVE avere:

1. **Unit Tests** (domain & data layer)
2. **Widget Tests** (presentation layer)
3. **Integration Tests** (flussi end-to-end)

### 📝 Template Unit Test

```dart
// test/features/workout/domain/usecases/my_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements WorkoutRepository {}

void main() {
  late MyUseCase useCase;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    useCase = MyUseCase(repository: mockRepository);
  });

  group('MyUseCase', () {
    test('should return success when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.saveWorkout(any()))
          .thenAnswer((_) async => right('workout-id'));

      // Act
      final result = await useCase.call(workout);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.saveWorkout(any())).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.saveWorkout(any()))
          .thenAnswer((_) async => left(UnexpectedFailure('error')));

      // Act
      final result = await useCase.call(workout);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### 📝 Template Widget Test

```dart
// test/features/workout/presentation/widgets/my_widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('should display workout name', (tester) async {
    // Arrange
    final workout = Workout(name: 'Test Workout');

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentWorkoutProvider.overrideWith((ref) => workout),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MyWidget(),
        ),
      ),
    );

    // Assert
    expect(find.text('Test Workout'), findsOneWidget);
  });

  testWidgets('should show loading indicator when workout is null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentWorkoutProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MyWidget(),
        ),
      ),
    );

    expect(find.byType(LoadingIndicator), findsOneWidget);
  });
}
```

### 📝 Template Integration Test

```dart
// integration_test/tests/my_feature_e2e_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('should complete full workout flow', ($) async {
    // 1. Launch app
    await $.pumpWidgetAndSettle(MyApp());

    // 2. Navigate to workout screen
    await $(#workoutTab).tap();

    // 3. Start workout from template
    await $(#templateCard).tap();
    await $(#startWorkoutButton).tap();

    // 4. Complete first set
    await $(#completeSetButton).tap();
    await $(#weightInput).enterText('100');
    await $(#repsInput).enterText('10');
    await $(#saveSetButton).tap();

    // 5. Verify timer started
    expect($(#restTimer).exists, true);

    // 6. Complete workout
    await $(#completeWorkoutButton).tap();

    // 7. Verify navigation to summary
    expect($(#workoutSummaryScreen).exists, true);
  });
}
```

---

## 8. Performance Requirements

### ⚡ Requisiti Minimi

Ogni nuova feature DEVE rispettare:

| Metrica | Requisito | Come Misurare |
|---------|-----------|---------------|
| **UI Rebuild** | < 20 rebuilds/minuto | `debugPrintRebuildDirtyWidgets = true` |
| **State Write** | < 10 writes/minuto | Log in `_saveState()` |
| **Timer Accuracy** | ±100ms drift | Track `_accuracyErrorCount` |
| **Save Operation** | < 200ms | `Stopwatch` in repository |
| **Screen Transition** | < 100ms | Flutter DevTools Timeline |

### 🔧 Optimizations da Applicare

#### 1. UI Update Throttling

```dart
// ✅ OBBLIGATORIO per provider con update frequenti
DateTime? _lastUIUpdate;

void _updateState(NewState newState) {
  final now = DateTime.now();

  // Throttle updates to max 10 per second (100ms interval)
  if (_lastUIUpdate != null &&
      now.difference(_lastUIUpdate!).inMilliseconds < 100) {
    return; // Skip update
  }

  _lastUIUpdate = now;
  state = newState;
}
```

#### 2. Debounced Persistence

```dart
// ✅ OBBLIGATORIO per auto-save
Timer? _saveDebounceTimer;

void _scheduleAutoSave() {
  _saveDebounceTimer?.cancel();

  _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
    _performActualSave();
  });
}
```

#### 3. Selective Watching

```dart
// ✅ OBBLIGATORIO in widget builds
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SBAGLIATO: Watch entire workout
    // final workout = ref.watch(currentWorkoutProvider);

    // CORRETTO: Watch only what you need
    final exerciseCount = ref.watch(
      currentWorkoutProvider.select((w) => w?.exercises.length ?? 0)
    );

    return Text('Exercises: $exerciseCount');
  }
}
```

#### 4. Cached Computations

```dart
// ✅ OBBLIGATORIO per calcoli costosi
class WorkoutStatsProvider extends StateNotifier<WorkoutStats?> {
  DateTime? _lastCalculationTime;
  WorkoutStats? _cachedStats;

  WorkoutStats getStats() {
    final now = DateTime.now();

    // Cache valid for 5 minutes
    if (_cachedStats != null &&
        _lastCalculationTime != null &&
        now.difference(_lastCalculationTime!).inMinutes < 5) {
      return _cachedStats!;
    }

    // Recalculate
    _cachedStats = _calculateExpensiveStats();
    _lastCalculationTime = now;

    return _cachedStats!;
  }
}
```

---

## 9. Security & Validation

### 🔒 Input Sanitization (OBBLIGATORIO)

```dart
// ✅ SEMPRE sanitize user input prima di salvare
import 'package:gymbro_flutter_new/shared/domain/services/input_sanitizer.dart';

Future<void> saveWorkout(Workout workout) async {
  // 1. Sanitize ALL text fields
  final sanitizedName = InputSanitizer.sanitizeName(workout.name);
  final sanitizedNotes = InputSanitizer.sanitizeText(workout.notes ?? '');

  // 2. Validate
  final validation = InputSanitizer.validateWorkoutData(
    workoutName: sanitizedName,
    notes: sanitizedNotes,
    exerciseNames: workout.exercises.map((e) => e.name).toList(),
  );

  if (!validation.isValid) {
    throw ValidationException(validation.errors.join(', '));
  }

  // 3. Save with sanitized data
  final sanitizedWorkout = workout.copyWith(
    name: sanitizedName,
    notes: sanitizedNotes,
  );

  await repository.save(sanitizedWorkout);
}
```

### ✅ Validation Rules

```dart
// ✅ TEMPLATE OBBLIGATORIO per validazione entità
class EntityValidator {
  static ValidationResult validate(Entity entity) {
    final errors = <String>[];

    // Required fields
    if (entity.id.isEmpty) {
      errors.add('ID cannot be empty');
    }

    if (entity.name.isEmpty) {
      errors.add('Name cannot be empty');
    }

    // Length constraints
    if (entity.name.length > 100) {
      errors.add('Name too long (max 100 chars)');
    }

    // Range constraints
    if (entity.weight < 0 || entity.weight > 1000) {
      errors.add('Weight must be between 0-1000kg');
    }

    if (entity.reps < 1 || entity.reps > 100) {
      errors.add('Reps must be between 1-100');
    }

    // Date constraints
    if (entity.createdAt.isAfter(DateTime.now())) {
      errors.add('Created date cannot be in future');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

### 🛡️ Firestore Security Rules

Quando aggiungi una nuova collection Firestore, DEVI aggiungere security rules:

```javascript
// firestore.rules
match /my_new_collection/{docId} {
  // Rule 1: Only authenticated users
  allow read, write: if request.auth != null;

  // Rule 2: User can only access their own data
  allow read, write: if request.auth.uid == resource.data.userId;

  // Rule 3: Validate data structure
  allow write: if request.resource.data.keys().hasAll(['userId', 'name', 'createdAt'])
            && request.resource.data.name is string
            && request.resource.data.name.size() > 0
            && request.resource.data.name.size() <= 100;
}
```

---

## 10. Checklist Pre-Commit

### ✅ Prima di Committare, Verifica:

```markdown
## Code Quality

- [ ] NO hardcoded strings (tutti usano `context.l10n`)
- [ ] NO hardcoded colors (tutti usano `context.colors`)
- [ ] NO print() statements (usa `debugPrint` con `kDebugMode`)
- [ ] Import di `build_context_extensions.dart` aggiunto dove necessario
- [ ] Nessun warning da `flutter analyze`
- [ ] Nessun TODO lasciato senza issue tracker

## Localization

- [ ] Traduzioni aggiunte in app_en.arb
- [ ] Traduzioni aggiunte in app_it.arb
- [ ] `flutter gen-l10n` eseguito
- [ ] Tutte le stringhe UI sono localizzate

## Architecture

- [ ] Rispettato Clean Architecture (domain/data/presentation)
- [ ] Nessuna circular dependency (verificato con `riverpod_graph`)
- [ ] Repository pattern usato per data access
- [ ] Either<Failure, Success> usato per error handling

## State Management

- [ ] Provider naming convention rispettata (*Provider suffix)
- [ ] .select() usato per ottimizzare rebuilds
- [ ] Atomic flags per operazioni critiche
- [ ] Disposal sicuro implementato (_isDisposed check)

## Data Persistence

- [ ] Local save SEMPRE prima di cloud sync
- [ ] Background sync non blocca UI
- [ ] Conflict resolution implementata
- [ ] Validazione prima di save

## Performance

- [ ] UI rebuild < 20/minuto (verificato con debug)
- [ ] Debounced auto-save implementato
- [ ] Cached computations dove applicabile
- [ ] Nessun blocking operation su UI thread

## Testing

- [ ] Unit tests scritti (domain & data)
- [ ] Widget tests scritti (presentation)
- [ ] Integration test per flusso E2E
- [ ] Tutti i test passano: `flutter test`

## iOS Integration

- [ ] Platform.isIOS check prima di iOS-specific code
- [ ] Fallback Android implementato
- [ ] Live Activity tested su iPhone fisico
- [ ] Background timer tested con lockscreen

## Security

- [ ] Input sanitization applicata
- [ ] Validation rules implementate
- [ ] Firestore security rules aggiunte
- [ ] Nessun dato sensibile in log

## Documentation

- [ ] Commenti aggiunti per logica complessa
- [ ] TODO convertiti in GitHub issues
- [ ] README aggiornato se necessario
- [ ] CLAUDE.md aggiornato se nuove regole
```

### 🚀 Comandi da Eseguire Prima del Commit

```bash
# 1. Verifica hardcoded strings
./scripts/find_hardcoded_strings.sh

# 2. Rigenera localizzazioni
flutter gen-l10n

# 3. Analyze codice
flutter analyze

# 4. Format codice
flutter format lib/ test/ integration_test/

# 5. Run tutti i test
flutter test

# 6. (Opzionale) Run integration tests
flutter test integration_test/

# 7. Verifica build
flutter build apk --debug   # Android
flutter build ios --debug   # iOS

# 8. Se tutto passa, commit
git add .
git commit -m "feat: add feature X with proper architecture"
```

---

## 📚 Riferimenti Rapidi

### File Chiave da Consultare

```
Architettura:
  lib/features/workout/domain/entities/workout.dart
  lib/features/workout/data/repositories/hybrid_workout_repository_impl.dart
  lib/features/workout/presentation/providers/workout_provider.dart

Utilities:
  lib/shared/presentation/extensions/build_context_extensions.dart
  lib/shared/domain/services/input_sanitizer.dart
  lib/shared/presentation/widgets/loading_indicator.dart
  lib/shared/presentation/services/snackbar_service.dart
  lib/shared/presentation/services/modal_service.dart

iOS Integration:
  ios/Runner/Managers/UnifiedTimerCoordinator.swift
  ios/Runner/LiveActivityHandler.swift
  lib/features/timer/presentation/providers/unified_timer_provider.dart

Testing:
  test/features/workout/workout_provider_test.dart
  integration_test/tests/workout_flow_e2e_test.dart
```

### Provider Naming Conventions

```dart
// State management
final myFeatureProvider                        // Provider<T>
final myFeatureStateProvider                   // StateProvider<T>
final myFeatureNotifierProvider                // StateNotifierProvider<N, S>
final myFeatureFutureProvider                  // FutureProvider<T>
final myFeatureStreamProvider                  // StreamProvider<T>

// Dependency injection
final myFeatureRepositoryProvider              // Provider<Repository>
final myFeatureUseCaseProvider                 // Provider<UseCase>
final myFeatureServiceProvider                 // Provider<Service>
```

### Useful Snippets

```dart
// ConsumerWidget template
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.title)),
      body: state.when(
        data: (data) => MyDataView(data),
        loading: () => LoadingIndicator(),
        error: (err, stack) => ErrorView(err),
      ),
    );
  }
}

// StateNotifier template
class MyNotifier extends StateNotifier<MyState?> {
  MyNotifier(this.ref) : super(null);

  final Ref ref;
  bool _isDisposed = false;

  Future<void> performAction() async {
    if (_isDisposed) return;

    try {
      // Action logic
      state = newState;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
```

---

## 🆘 Troubleshooting

### Problemi Comuni e Soluzioni

#### Problema: "Provider threw an exception"

```dart
// CAUSA: Accessing provider before initialization
final value = ref.read(myProvider);

// SOLUZIONE: Use ref.watch or ref.listen in build
final value = ref.watch(myProvider);
```

#### Problema: "Circular dependency detected"

```dart
// CAUSA: Provider A dipende da B, B dipende da A
final providerA = Provider((ref) => ref.watch(providerB));
final providerB = Provider((ref) => ref.watch(providerA));

// SOLUZIONE: Refactor dependencies
final providerA = Provider((ref) => ServiceA());
final providerB = Provider((ref) => ServiceB(ref.watch(providerA)));
```

#### Problema: "setState called after dispose"

```dart
// CAUSA: Async operation continua dopo dispose
Future<void> loadData() async {
  await api.fetchData();
  state = newData; // ERROR se widget disposed
}

// SOLUZIONE: Check disposal flag
Future<void> loadData() async {
  await api.fetchData();
  if (_isDisposed) return;
  state = newData;
}
```

#### Problema: "Box already open"

```dart
// CAUSA: Trying to open Hive box multiple times
final box = await Hive.openBox('myBox');
final box2 = await Hive.openBox('myBox'); // ERROR

// SOLUZIONE: Reuse existing box
Box? _box;

Future<Box> get box async {
  _box ??= await Hive.openBox('myBox');
  return _box!;
}
```

---

## 📞 Supporto

Se hai dubbi o domande su queste ROE:

1. **Consulta la documentazione**:
   - CLAUDE.md (regole globali)
   - WORKOUT_SYSTEM_OVERVIEW.md (overview funzionale)
   - Questo documento (ROE workout)

2. **Analizza codice esistente**:
   - Cerca implementazioni simili nel codebase
   - Leggi i test per capire behavior atteso

3. **Chiedi review**:
   - Apri PR anche per work-in-progress
   - Chiedi feedback early per evitare refactor massicci

4. **Testing locale**:
   - Testa sempre su device fisico (non solo simulator)
   - Testa offline scenarios
   - Testa background behavior

---

**Ultima revisione**: Gennaio 2025
**Versione documento**: 1.0
**Autore**: Michele Cozzolino
**Per**: Sviluppatori che lavorano sul sistema workout di GymBro
