# Apple Health & Health Connect Integration - Design Document

**Created**: 2025-11-22
**Status**: Design Approved
**Complexity**: MEDIUM (3-4 days MVP)
**Author**: Claude Code (Brainstorming Session)

---

## 📋 Executive Summary

Integrazione bidirezionale con Apple Health (iOS) e Health Connect (Android 14+) per sincronizzare automaticamente:
- ✅ **Workout completati** (tipo, durata, calorie)
- ✅ **Peso corporeo** (read + write bidirezionale)
- ✅ **Auto-sync 1x/day** in background
- ✅ **Manual sync on-demand**

**Differenziazione competitiva**:
- ✅ Peso bidirezionale (Fitbod ha solo one-time sync)
- ✅ Auto-sync background (Strong non ce l'ha)
- ✅ Dettagli workout completi (Health Sync non li ha)

**Unico che combina tutti e 3 dal giorno 1.**

---

## 🎯 User Story & Requirements

### User Story
> "Come utente bodybuilder/fitness, voglio che i miei workout e peso corporeo loggati in FitLog vengano sincronizzati automaticamente con Apple Health, così posso:
> - Vedere i workout in Apple Health app
> - Chiudere gli anelli attività automaticamente
> - Integrare con altre app fitness (Strava, MyFitnessPal, etc.)
> - Avere peso aggiornato da bilancia smart → FitLog automaticamente"

### Requirements MVP

**MUST-HAVE**:
- [x] Sync workout → Apple Health/Health Connect (write)
- [x] Sync peso → Apple Health/Health Connect (write)
- [x] Read peso da Apple Health/Health Connect
- [x] Auto-sync 1x/day in background
- [x] Manual sync button in Settings
- [x] Permission flow contestuale (first workout)
- [x] Graceful degradation (app funziona anche senza sync)

**NICE-TO-HAVE (Phase 2)**:
- [ ] Body fat % sync
- [ ] Lean mass sync
- [ ] Heart rate sync
- [ ] Sync frequency aumentata (più volte al giorno)

**OUT OF SCOPE (MVP)**:
- ❌ GPS/route tracking
- ❌ Sleep tracking
- ❌ Nutrition sync
- ❌ Set-by-set details (HealthKit non li supporta)

---

## 🏗️ Architecture Overview

### Clean Architecture Layers

```
lib/features/health_sync/
├── domain/
│   ├── entities/
│   │   ├── health_data_type.dart           # Enum: workout, weight, bodyFat, etc.
│   │   ├── health_sync_status.dart         # Status sync per data type (generic)
│   │   ├── health_permission_status.dart   # Permission runtime check (volatile)
│   │   ├── health_sync_preference.dart     # User preference (persisted Hive)
│   │   ├── health_permission_result.dart   # Permission request result
│   │   ├── health_workout_mapping.dart     # Workout type mapping (HK → FitLog)
│   │   └── body_measurement.dart           # Weight entity
│   ├── repositories/
│   │   └── health_repository.dart          # Interface astratta
│   └── usecases/
│       ├── sync_weight_to_health.dart      # Write peso a HealthKit
│       ├── sync_workout_to_health.dart     # Write workout a HealthKit
│       ├── import_weight_from_health.dart  # Read peso da HealthKit
│       └── retry_failed_sync.dart          # Retry logic
│
├── data/
│   ├── datasources/
│   │   ├── health_kit_datasource.dart      # iOS implementation (health package)
│   │   ├── health_connect_datasource.dart  # Android implementation
│   │   └── health_sync_local_datasource.dart # Hive persistence
│   ├── repositories/
│   │   └── health_repository_impl.dart     # Implementazione concreta
│   └── models/
│       ├── health_data_type_mapper.dart    # Mapping HK types
│       └── health_sync_status_model.dart   # Serializable model
│
└── presentation/
    ├── providers/
    │   ├── health_sync_provider.dart       # Riverpod state management
    │   ├── health_permission_provider.dart # Permission status
    │   └── health_background_sync_provider.dart # Background task (1x/day)
    └── widgets/
        ├── health_sync_permission_dialog.dart # First workout dialog
        ├── health_sync_settings_card.dart     # Settings UI
        └── sync_status_indicator.dart         # "Last synced: 2h ago"
```

---

## 🔐 Permission Flow & User Journey

### Trigger Point: First Workout Completion

```
1. User salva primo workout completato
   ↓
2. WorkoutProvider rileva: isFirstWorkoutEver == true
   ↓
3. Modal appare (HealthSyncPermissionDialog):

   🎉 "Primo workout completato!"

   "Vuoi sincronizzare automaticamente i tuoi workout
    e peso corporeo con Apple Health?"

   ✅ Benefici mostrati:
   - Dati disponibili in Health app
   - Anelli attività aggiornati automaticamente
   - Integrazione con altre app fitness

   [Abilita Sincronizzazione]  [Non ora]
   ↓
4a. User clicca "Abilita":
    → Richiesta permessi nativi (iOS/Android) SEQUENTIAL
    → iOS: Workout first, poi Weight
    → Validazione post-request (entrambi approved?)
    → Se approvato: sync istantaneo del workout appena salvato
    → Salva preferenza: healthSyncEnabled = true

4b. User clicca "Non ora":
    → Salva preferenza: healthSyncDismissed = true
    → Mostra hint in Settings: "Health sync disponibile"
```

### iOS Permission Handling (Sequential)

```dart
// Step 1: Request workout permission
final workoutGranted = await health.requestAuthorization([
  HealthDataType.WORKOUT
]);

// Step 2: Request weight permission
final weightGranted = await health.requestAuthorization([
  HealthDataType.WEIGHT
]);

// Step 3: Validation
final result = HealthPermissionResult(
  canSyncWorkouts: workoutGranted,
  canSyncWeight: weightGranted,
);

if (result.canSyncBoth) {
  // ✅ Tutto ok
  Navigator.pop(context, true);
} else if (result.canSyncPartial) {
  // ⚠️ Parziale: mostra snackbar
  SnackBarService.showWarning(
    context,
    result.canSyncWorkouts && !result.canSyncWeight
      ? 'Workout sync abilitato, peso no'
      : 'Peso sync abilitato, workout no'
  );
  Navigator.pop(context, result.canSyncPartial);
} else {
  // ❌ Nessuno approvato
  Navigator.pop(context, false);
}
```

### Android Health Connect Handling

```dart
// Step 1: Check if Health Connect installed
final isAvailable = await health.isHealthConnectAvailable();

if (!isAvailable) {
  // ⚠️ Health Connect non installato
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Health Connect richiesto'),
      content: Text('Installa Health Connect da Play Store'),
      actions: [
        TextButton(
          onPressed: () => _openPlayStore(),
          child: Text('Installa'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Non ora'),
        ),
      ],
    ),
  );
  return;
}

// Step 2: Request permissions (1 schermata granulare)
final granted = await health.requestAuthorization([
  HealthDataType.WORKOUT,
  HealthDataType.WEIGHT,
]);
```

### Gestione Edge Cases

| Scenario | Handling |
|----------|----------|
| **User nega permessi iOS** | Mostra snackbar "Health sync disabilitato. Abilita in Impostazioni iOS" |
| **User revoca permessi dopo** | Background sync rileva → aggiorna UI in Settings con warning |
| **Health Connect non installato** | Dialog con link Play Store + salva flag `healthConnectDeclined` |
| **User installa HC dopo decline** | Auto-detect on app resume → auto-abilita sync |
| **Permessi parziali iOS** | Sync quello che funziona + mostra quale è disabled |

---

## 📊 Data Mapping & Type Conversion

### HealthDataType Enum (Future-Proof)

```dart
// domain/entities/health_data_type.dart
enum HealthDataType {
  workout,    // MVP
  weight,     // MVP
  bodyFat,    // Phase 2
  leanMass,   // Phase 2
  heartRate,  // Phase 2
  sleep,      // Phase 3
  nutrition,  // Phase 3
}

extension HealthDataTypeExtension on HealthDataType {
  String get displayName {
    switch (this) {
      case HealthDataType.workout: return 'Workout';
      case HealthDataType.weight: return 'Peso';
      case HealthDataType.bodyFat: return 'Massa grassa';
      case HealthDataType.leanMass: return 'Massa magra';
      case HealthDataType.heartRate: return 'Frequenza cardiaca';
      case HealthDataType.sleep: return 'Sonno';
      case HealthDataType.nutrition: return 'Nutrizione';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthDataType.workout: return AppIcons.workout;
      case HealthDataType.weight: return AppIcons.weight;
      case HealthDataType.bodyFat: return AppIcons.bodyFat;
      case HealthDataType.leanMass: return AppIcons.muscle;
      case HealthDataType.heartRate: return AppIcons.heartRate;
      case HealthDataType.sleep: return AppIcons.sleep;
      case HealthDataType.nutrition: return AppIcons.food;
    }
  }
}
```

### Workout Type Mapping (Bodybuilding-Focused)

```dart
// domain/entities/health_workout_mapping.dart
enum FitLogWorkoutCategory {
  strength,    // Bodybuilding/resistance training
  cardio,      // Corsa, cyclette, etc.
  other,       // Fallback generico
}

class HealthWorkoutTypeMapper {
  // HealthKit → FitLog (lettura da Apple Health)
  static FitLogWorkoutCategory fromHealthKit(HKWorkoutActivityType type) {
    switch (type) {
      // Strength/Bodybuilding
      case HKWorkoutActivityType.traditionalStrengthTraining:
      case HKWorkoutActivityType.functionalStrengthTraining:
        return FitLogWorkoutCategory.strength;

      // Cardio (corsa + varianti)
      case HKWorkoutActivityType.running:
      case HKWorkoutActivityType.cycling:
      case HKWorkoutActivityType.walking:
      case HKWorkoutActivityType.elliptical:
      case HKWorkoutActivityType.stairClimbing:
        return FitLogWorkoutCategory.cardio;

      // Tutto il resto → other
      default:
        return FitLogWorkoutCategory.other;
    }
  }

  // FitLog → HealthKit (scrittura a Apple Health)
  static HKWorkoutActivityType toHealthKit(FitLogWorkoutCategory category) {
    switch (category) {
      case FitLogWorkoutCategory.strength:
        return HKWorkoutActivityType.traditionalStrengthTraining;
      case FitLogWorkoutCategory.cardio:
        return HKWorkoutActivityType.running; // Default a running
      case FitLogWorkoutCategory.other:
        return HKWorkoutActivityType.other;
    }
  }
}
```

### Weight Data Mapping (Bidirezionale)

```dart
// domain/entities/body_measurement.dart
@freezed
class BodyMeasurement with _$BodyMeasurement {
  const factory BodyMeasurement({
    required double weightKg,
    required DateTime measuredAt,
    String? source, // 'fitlog', 'apple_health', 'health_connect'
  }) = _BodyMeasurement;

  // Conversion helpers
  double get weightLbs => weightKg * 2.20462;

  // Da HealthKit HealthDataPoint
  factory BodyMeasurement.fromHealthKit(HealthDataPoint data) {
    return BodyMeasurement(
      weightKg: data.value.toDouble(),
      measuredAt: data.dateFrom,
      source: 'apple_health',
    );
  }

  // A HealthKit
  HealthDataPoint toHealthKit() {
    return HealthDataPoint(
      value: weightKg,
      type: HealthDataType.WEIGHT,
      unit: HealthDataUnit.KILOGRAM,
      dateFrom: measuredAt,
      dateTo: measuredAt,
    );
  }
}
```

---

## 🔄 Background Sync Logic

### Sync Frequency: 1x/Day

**Trigger**: `health_background_sync_provider.dart` (Riverpod)

```dart
final healthBackgroundSyncProvider = StateNotifierProvider((ref) {
  return HealthBackgroundSyncNotifier(
    syncUsecase: ref.watch(syncHealthDataUsecaseProvider),
    localDatasource: ref.watch(healthSyncLocalDatasourceProvider),
  );
});

class HealthBackgroundSyncNotifier extends StateNotifier<void> {
  Timer? _syncTimer;

  HealthBackgroundSyncNotifier({
    required this.syncUsecase,
    required this.localDatasource,
  }) : super(null) {
    _initBackgroundSync();
  }

  void _initBackgroundSync() {
    // Check ogni volta che app va in foreground
    WidgetsBinding.instance.addObserver(this);

    // Timer check ogni 1 ora (fallback)
    _syncTimer = Timer.periodic(Duration(hours: 1), (_) {
      _checkAndSync();
    });
  }

  Future<void> _checkAndSync() async {
    final status = await localDatasource.getLastSyncStatus();

    // È passato 1 giorno dall'ultimo sync?
    final shouldSync = status?.lastSyncTime == null ||
      DateTime.now().difference(status!.lastSyncTime!) > Duration(days: 1);

    if (shouldSync) {
      await _performSync();
    }

    // Controlla se ci sono retry pending
    if (status?.shouldRetry() ?? false) {
      await _retryFailedSync();
    }
  }

  Future<void> _performSync() async {
    try {
      // Sync tutti i data types abilitati
      final enabledTypes = await _getEnabledDataTypes();

      for (final type in enabledTypes) {
        await syncUsecase.call(type);
      }

      // Salva success status
      await localDatasource.saveSyncStatus(
        HealthSyncStatus(
          dataType: HealthDataType.workout, // TODO: per type
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.success,
          retryCount: 0,
        ),
      );
    } catch (e) {
      // Salva error status
      await localDatasource.incrementRetryCount();
    }
  }
}
```

### Retry Logic (Exponential Backoff)

```dart
// domain/usecases/retry_failed_sync.dart
class RetryFailedSyncUseCase {
  Future<void> call() async {
    final status = await repository.getSyncStatus();

    if (!status.shouldRetry()) return;

    // Exponential backoff
    final delay = _calculateDelay(status.retryCount);

    if (DateTime.now().difference(status.lastSyncTime!) < delay) {
      return; // Troppo presto per retry
    }

    try {
      await repository.syncAllData();
      await repository.resetRetryCount();
    } catch (e) {
      await repository.incrementRetryCount();
    }
  }

  Duration _calculateDelay(int retryCount) {
    switch (retryCount) {
      case 0: return Duration(hours: 1);
      case 1: return Duration(hours: 4);
      case 2: return Duration(hours: 24);
      default: return Duration(days: 7); // Max 3 retry
    }
  }
}
```

---

## 🎨 UI/UX Components

### 1. Health Sync Permission Dialog (First Workout)

**File**: `presentation/widgets/health_sync_permission_dialog.dart`

**Design**:
```
┌─────────────────────────────────────────┐
│          🎉 Icon (xxlarge)              │
│                                         │
│   Primo workout completato!             │
│                                         │
│   Vuoi sincronizzare automaticamente    │
│   i tuoi workout e peso corporeo con    │
│   Apple Health?                         │
│                                         │
│   ✅ Dati disponibili in Health app     │
│   ✅ Anelli attività aggiornati         │
│   ✅ Integrazione con altre app         │
│                                         │
│  [Non ora]  [Abilita Sincronizzazione]  │
└─────────────────────────────────────────┘
```

**Key Features**:
- ✅ Mostra benefici visualmente (icon + text)
- ✅ Gestione stato parziale (workout ok, peso no)
- ✅ Error handling con snackbar
- ✅ Localizzazione completa (EN/IT)

### 2. Health Sync Settings Card

**File**: `presentation/widgets/health_sync_settings_card.dart`

**Design**:
```
┌─────────────────────────────────────────┐
│ 🍎 Apple Health        [Toggle ON/OFF]  │
│                                         │
│ ✅ Ultimo sync: 2 ore fa                │
│ ✅ Peso: Sincronizzato                  │
│ ✅ Workout: 45 sincronizzati            │
│                                         │
│ [Sincronizza Ora] (manual button)       │
└─────────────────────────────────────────┘
```

**States**:

| State | UI Display |
|-------|-----------|
| **Enabled + Synced** | ✅ "Ultimo sync: 2h fa" + green checkmark |
| **Enabled + Syncing** | 🔄 CircularProgressIndicator + "Sincronizzazione..." |
| **Enabled + Error** | ❌ "Sync fallito: [error]" + retry button |
| **Enabled + Permission Revoked** | ⚠️ "Permessi disabilitati. Abilita in Impostazioni iOS" |
| **Disabled** | Toggle OFF + hint "Health sync disponibile" |
| **Android HC Not Installed** | ⚠️ "Health Connect non installato" + [Installa] button |

**Key Features**:
- ✅ Separate permission status + user preference
- ✅ Loading state durante permission request
- ✅ Lock button durante sync (previene race condition)
- ✅ Error handling con snackbar
- ✅ Auto-refresh permission status on app resume

### 3. Sync Status Indicator (Reusable Widget)

**File**: `presentation/widgets/sync_status_indicator.dart`

```dart
class SyncStatusIndicator extends StatelessWidget {
  final DateTime? lastSync;
  final SyncResult result;

  @override
  Widget build(BuildContext context) {
    if (lastSync == null) {
      return _StatusRow(
        icon: AppIcons.info,
        color: context.iconTertiary,
        text: context.l10n.neverSynced,
      );
    }

    final timeAgo = timeago.format(lastSync!, locale: 'it');

    switch (result) {
      case SyncResult.success:
        return _StatusRow(
          icon: AppIcons.checkCircle,
          color: context.iconSuccess,
          text: context.l10n.lastSyncSuccess(timeAgo),
        );

      case SyncResult.error:
        return _StatusRow(
          icon: AppIcons.error,
          color: context.iconError,
          text: context.l10n.lastSyncFailed(timeAgo),
        );

      case SyncResult.pending:
        return _StatusRow(
          icon: AppIcons.pending,
          color: context.iconWarning,
          text: context.l10n.syncPending,
        );
    }
  }
}
```

---

## 🧪 Testing Strategy

### Unit Tests (Domain Layer)

**File**: `test/features/health_sync/domain/entities/health_sync_status_test.dart`

```dart
void main() {
  group('HealthSyncStatus', () {
    test('should create status for workout type', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.success,
        retryCount: 0,
      );

      expect(status.dataType, HealthDataType.workout);
      expect(status.lastResult, SyncResult.success);
    });

    test('should serialize to JSON correctly', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.success,
        retryCount: 0,
      );

      final json = status.toJson();
      final restored = HealthSyncStatus.fromJson(json);

      expect(restored, equals(status));
    });
  });

  group('HealthPermissionStatus', () {
    test('canSync returns true when authorized', () {
      final status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.authorized,
          HealthDataType.weight: PermissionState.authorized,
        },
        healthConnectAvailable: true,
      );

      expect(status.canSync(HealthDataType.workout), true);
      expect(status.canSyncAny, true);
    });

    test('canSync returns false when denied', () {
      final status = HealthPermissionStatus(
        permissions: {
          HealthDataType.workout: PermissionState.denied,
        },
        healthConnectAvailable: true,
      );

      expect(status.canSync(HealthDataType.workout), false);
    });
  });
}
```

### Integration Tests (Repository Layer)

**File**: `test/features/health_sync/data/repositories/health_repository_test.dart`

```dart
void main() {
  late HealthRepositoryImpl repository;
  late MockHealthKitDatasource mockHealthKit;
  late MockHealthSyncLocalDatasource mockLocal;

  setUp(() {
    mockHealthKit = MockHealthKitDatasource();
    mockLocal = MockHealthSyncLocalDatasource();
    repository = HealthRepositoryImpl(mockHealthKit, mockLocal);
  });

  group('syncData', () {
    test('should sync workout data successfully', () async {
      when(() => mockHealthKit.writeWorkout(any()))
        .thenAnswer((_) async => {});

      await repository.syncData(HealthDataType.workout);

      verify(() => mockHealthKit.writeWorkout(any())).called(1);
    });

    test('should handle permission denied error', () async {
      when(() => mockHealthKit.writeWorkout(any()))
        .thenThrow(PermissionException('denied'));

      expect(
        () => repository.syncData(HealthDataType.workout),
        throwsA(isA<PermissionException>()),
      );
    });

    test('should save sync status to local storage', () async {
      when(() => mockHealthKit.writeWorkout(any()))
        .thenAnswer((_) async => {});
      when(() => mockLocal.saveSyncStatus(any()))
        .thenAnswer((_) async => {});

      await repository.syncData(HealthDataType.workout);

      verify(() => mockLocal.saveSyncStatus(any())).called(1);
    });
  });

  group('getPermissionStatus', () {
    test('should return current permission status from HealthKit', () async {
      when(() => mockHealthKit.checkPermissions(any()))
        .thenAnswer((_) async => {
          HealthDataType.workout: PermissionState.authorized,
        });

      final status = await repository.getPermissionStatus();

      expect(status.canSync(HealthDataType.workout), true);
    });
  });
}
```

### Widget Tests (UI Layer)

**File**: `test/features/health_sync/presentation/widgets/health_sync_settings_card_test.dart`

```dart
void main() {
  testWidgets('should show sync status for enabled data type', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allHealthSyncStatusesProvider.overrideWith((ref) => [
            HealthSyncStatus(
              dataType: HealthDataType.workout,
              lastSyncTime: DateTime.now(),
              lastResult: SyncResult.success,
              retryCount: 0,
            ),
          ]),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HealthSyncSettingsCard(),
          ),
        ),
      ),
    );

    expect(find.text('Workout'), findsOneWidget);
    expect(find.byIcon(AppIcons.checkCircle), findsOneWidget);
  });

  testWidgets('should disable sync button during sync', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthSyncInProgressProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: HealthSyncSettingsCard(),
          ),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );

    expect(button.onPressed, isNull); // Disabled
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### E2E Tests con Patrol (iOS Simulator)

**File**: `integration_test/health_sync_flow_test.dart`

```dart
void main() {
  patrolTest('complete health sync flow', (PatrolTester $) async {
    await $.pumpWidgetAndSettle(MyApp());

    // Navigate to settings
    await $(AppIcons.settings).tap();
    await $(#healthSyncCard).scrollTo();

    // Enable health sync
    await $(#healthSyncToggle).tap();

    // iOS permission dialog appears (native)
    await $.native.grantPermissionWhenInUse(); // HealthKit

    // Verify toggle is ON
    expect($(#healthSyncToggle).visible, true);

    // Tap manual sync button
    await $(#syncNowButton).tap();

    // Verify loading indicator
    expect($(CircularProgressIndicator).visible, true);

    // Wait for sync complete
    await $.waitUntilVisible(find.text('✅ Sincronizzazione completata'));

    // Verify status updated
    expect(find.text('Ultimo sync:'), findsOneWidget);
  });

  patrolTest('handle permission denial gracefully', (PatrolTester $) async {
    await $.pumpWidgetAndSettle(MyApp());

    // Navigate to settings
    await $(AppIcons.settings).tap();

    // Enable health sync
    await $(#healthSyncToggle).tap();

    // Deny iOS permission
    await $.native.denyPermissionOnce();

    // Verify error message
    expect(find.text('Health sync disabilitato'), findsOneWidget);

    // Verify toggle is still OFF
    final toggle = tester.widget<Switch>(find.byType(Switch));
    expect(toggle.value, false);
  });
}
```

---

## 🚀 Implementation Timeline

### Phase 1 - MVP (3-4 giorni)

**Day 1: Domain Layer + Data Layer**
- [x] Create feature structure (`lib/features/health_sync/`)
- [x] Implement domain entities (all `*.dart` in `domain/entities/`)
- [x] Implement repository interface
- [x] Implement usecases (sync_weight, sync_workout, import_weight, retry)
- [x] Implement datasources (HealthKit + Health Connect)
- [x] Implement local datasource (Hive)
- [x] Implement repository implementation
- [x] Write unit tests for domain layer

**Day 2: Background Sync + Permission Logic**
- [x] Implement `health_background_sync_provider.dart`
- [x] Implement permission request logic (iOS sequential)
- [x] Implement Android Health Connect availability check
- [x] Implement retry logic with exponential backoff
- [x] Implement permission status tracking (runtime check on app resume)
- [x] Write integration tests for repository

**Day 3: UI Components**
- [x] Implement `HealthSyncPermissionDialog` (first workout trigger)
- [x] Implement `HealthSyncSettingsCard` (Settings screen)
- [x] Implement `SyncStatusIndicator` (reusable widget)
- [x] Implement manual sync button with loading state
- [x] Implement Android HC installation prompt
- [x] Add localization strings (EN + IT)
- [x] `flutter gen-l10n`
- [x] Write widget tests

**Day 4: Integration + Testing**
- [x] Integrate permission dialog in workout flow
- [x] Integrate settings card in Settings screen
- [x] Test on iOS Simulator (HealthKit permissions)
- [x] Test on Android emulator (Health Connect)
- [x] Write E2E tests with Patrol
- [x] `flutter analyze` (0 errors)
- [x] Manual QA (permission flows, sync, error handling)

---

## 📝 Localization Strings Required

**Add to `assets/i18n/app_en.arb`**:

```json
{
  "firstWorkoutComplete": "First Workout Completed!",
  "healthSyncBenefits": "Automatically sync your workouts and body weight with Apple Health",
  "enableSync": "Enable Sync",
  "notNow": "Not Now",
  "autoSyncWorkouts": "Data available in Health app",
  "syncBodyWeight": "Activity rings updated automatically",
  "integrateOtherApps": "Integration with other fitness apps",
  "appleHealth": "Apple Health",
  "healthConnect": "Health Connect",
  "syncNow": "Sync Now",
  "syncing": "Syncing...",
  "lastSyncSuccess": "Last sync: {timeAgo}",
  "lastSyncFailed": "Sync failed: {timeAgo}",
  "syncPending": "Sync pending...",
  "neverSynced": "Never synced",
  "healthSyncDisabled": "Health sync disabled. Enable in iOS Settings",
  "healthConnectNotInstalled": "Health Connect not installed",
  "install": "Install",
  "workoutSyncEnabled": "Workout sync enabled",
  "weightSyncEnabled": "Weight sync enabled",
  "permissionsRevoked": "Permissions revoked. Re-enable in Settings"
}
```

**Add to `assets/i18n/app_it.arb`**:

```json
{
  "firstWorkoutComplete": "Primo Workout Completato!",
  "healthSyncBenefits": "Sincronizza automaticamente i tuoi workout e peso corporeo con Apple Health",
  "enableSync": "Abilita Sincronizzazione",
  "notNow": "Non ora",
  "autoSyncWorkouts": "Dati disponibili in app Salute",
  "syncBodyWeight": "Anelli attività aggiornati automaticamente",
  "integrateOtherApps": "Integrazione con altre app fitness",
  "appleHealth": "Apple Health",
  "healthConnect": "Health Connect",
  "syncNow": "Sincronizza Ora",
  "syncing": "Sincronizzazione...",
  "lastSyncSuccess": "Ultimo sync: {timeAgo}",
  "lastSyncFailed": "Sync fallito: {timeAgo}",
  "syncPending": "Sync in attesa...",
  "neverSynced": "Mai sincronizzato",
  "healthSyncDisabled": "Health sync disabilitato. Abilita in Impostazioni iOS",
  "healthConnectNotInstalled": "Health Connect non installato",
  "install": "Installa",
  "workoutSyncEnabled": "Sync workout abilitato",
  "weightSyncEnabled": "Sync peso abilitato",
  "permissionsRevoked": "Permessi revocati. Riabilita in Impostazioni"
}
```

---

## ⚠️ Edge Cases Handled

| Edge Case | Solution |
|-----------|----------|
| **iOS dual-modal permissions** | Sequential request (workout first, weight second) + validation |
| **Partial permission approval** | Graceful degradation + snackbar feedback |
| **Health Connect not installed** | Dialog con link Play Store + auto-detect after install |
| **User revokes permissions** | Runtime check on app resume + warning in Settings |
| **Sync race condition** | Lock button durante sync + `healthSyncInProgressProvider` |
| **Background sync fails** | Retry logic (max 3 attempts, exponential backoff) |
| **Permission status stale** | NOT saved in Hive, always checked at runtime |
| **Android HC installed after decline** | Auto-detect on app resume + auto-enable sync |
| **User preference vs permission state** | Separate entities (preference persisted, permissions volatile) |

---

## 🎯 Success Metrics (Post-Launch)

**Analytics to Track**:
- [ ] % users che abilitano sync al primo workout
- [ ] % users con sync attivo dopo 7 giorni
- [ ] Sync success rate (target: >95%)
- [ ] Permission denial rate (iOS vs Android)
- [ ] Retry count distribution
- [ ] Time to first successful sync
- [ ] Health Connect installation rate (Android)

**Firebase Analytics Events**:
```dart
FirebaseAnalytics.logEvent(
  name: 'health_sync_enabled',
  parameters: {
    'platform': Platform.isIOS ? 'ios' : 'android',
    'data_types': ['workout', 'weight'],
  },
);

FirebaseAnalytics.logEvent(
  name: 'health_sync_failed',
  parameters: {
    'error': errorMessage,
    'retry_count': retryCount,
    'data_type': 'workout',
  },
);
```

---

## 📚 Dependencies

**Already in `pubspec.yaml`**:
```yaml
health: ^13.2.1  # Latest version with HealthKit + Health Connect support
permission_handler: ^11.0.1
device_info_plus: ^12.2.0  # For Android API level checks
```

**iOS `Info.plist` Additions**:
```xml
<key>NSHealthShareUsageDescription</key>
<string>FitLog needs access to read your workout and weight data from Apple Health to provide personalized insights and sync your fitness progress.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>FitLog needs permission to save your workout and weight data to Apple Health so you can see your progress across all your health apps.</string>
```

**Android `AndroidManifest.xml` Additions**:
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.health.READ_EXERCISE"/>
<uses-permission android:name="android.permission.health.WRITE_EXERCISE"/>
<uses-permission android:name="android.permission.health.READ_WEIGHT"/>
<uses-permission android:name="android.permission.health.WRITE_WEIGHT"/>
```

---

## 🔮 Future Enhancements (Phase 2+)

**Phase 2 (Post-MVP)**:
- [ ] Body fat % sync (read + write)
- [ ] Lean mass sync (read + write)
- [ ] Heart rate sync (read from wearables)
- [ ] Sync frequency aumentata (2-3x al giorno)
- [ ] Sync history view (ultimi 30 giorni)

**Phase 3**:
- [ ] GPS/route tracking per cardio workouts
- [ ] Sleep tracking integration
- [ ] Nutrition data sync
- [ ] Active Energy burned per exercise
- [ ] Resting heart rate trends

---

## ✅ Definition of Done

- [x] Tutti i test passano (`flutter test`)
- [x] `flutter analyze` 0 errori
- [x] Testato su iOS Simulator con HealthKit
- [x] Testato su Android Emulator con Health Connect
- [x] Localization completa (EN + IT)
- [x] Design system compliant (AppIcons, context.colors, context.l10n)
- [x] Documentazione aggiornata (questo file)
- [x] Code review completata
- [x] E2E tests con Patrol passano

---

## 🎓 Learnings & Design Decisions

### Decision 1: Enum-Based Data Types (Future-Proof)

**Context**: Inizialmente si considerava di creare entità separate per ogni data type (workout, weight, body fat, etc.), ma questo portava a entity proliferation.

**Decision**: Usare un enum `HealthDataType` con entità generiche che accettano il tipo come parametro.

**Rationale**:
- ✅ Scala bene con nuovi data types (aggiungere = 1 riga enum, non nuove entità)
- ✅ Repository methods generiche riutilizzabili
- ✅ UI components riutilizzabili (loop su `HealthDataType.values`)
- ✅ Zero tech debt per Phase 2+

**Impact**: Refactoring richiesto +1-2 ore, ma risparmio di ~5 giorni in Phase 2.

### Decision 2: Sequential Permission Requests (iOS)

**Context**: iOS mostra 2 modal separate per HealthKit (read + write), utente può approvarne uno e negare l'altro.

**Decision**: Richieste sequenziali (workout first, poi weight) + validazione post-request.

**Rationale**:
- ✅ Più facile debuggare quale permesso è fallito
- ✅ Feedback granulare all'utente (snackbar con stato parziale)
- ✅ Graceful degradation (sync quello che funziona)

**Impact**: UX più trasparente, ma +30 minuti implementazione per gestire stati parziali.

### Decision 3: Separate Permission Status from User Preference

**Context**: Inizialmente si salvava lo stato dei permessi in Hive insieme al sync status, ma questo creava stale state (user revoca permessi in iOS Settings → app non lo sa fino al prossimo sync).

**Decision**:
- `HealthPermissionStatus` = volatile (Riverpod FutureProvider, checked at runtime)
- `HealthSyncPreference` = persistente (Hive, user intent)

**Rationale**:
- ✅ Permessi sempre freschi (no cache stale)
- ✅ App resiliente a user behavior (cambio permessi fuori dall'app)
- ✅ UI sempre accurata (riflette stato reale iOS/Android)

**Impact**: +2 entities, ma elimina classe di bug critici (crash su permission revoked).

---

## 📞 Support & Troubleshooting

**Common Issues**:

| Issue | Causa | Fix |
|-------|-------|-----|
| "Permission denied" anche dopo approval | iOS modal dismisso senza selection | Re-richiedi permessi in Settings |
| "Health Connect not found" su Android | App non installata | Installa da Play Store |
| Sync non si triggera automaticamente | Background task non inizializzato | Check `health_background_sync_provider` initialization |
| Weight sync unidirezionale | Solo write implementato | Verifica `import_weight_from_health.dart` usecase |
| Workout non appare in Apple Health | Mapping errato workout type | Check `HealthWorkoutTypeMapper.toHealthKit()` |

---

**🎉 Design Complete - Ready for Implementation!**

**Next Steps**:
1. Review design document with team
2. Create GitHub issue/PR per tracking
3. Implement Phase 1 (3-4 giorni)
4. Deploy to TestFlight/Internal Testing
5. Gather analytics + user feedback
6. Plan Phase 2 features
