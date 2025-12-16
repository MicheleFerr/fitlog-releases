# Apple Health & Health Connect Integration - Implementation Plan

**Generated**: 2025-11-22 10:05
**Source**: task-master.dev (WebFetch API)
**Design Document**: [HEALTH_SYNC_INTEGRATION_DESIGN.md](../UX_FLOWS/health_sync/HEALTH_SYNC_INTEGRATION_DESIGN.md)
**Complexity Score**: HIGH
**Reason**: New feature + Multi-platform integration + 18 granular tasks
**Total Tasks**: 18
**Estimated Time**: ~24-32 hours (3-4 days)
**Plan Version**: 1.0

**Context Snapshot**:
- Flutter Version: 3.16.0
- Key Packages: riverpod ^2.4.9, health ^13.2.1, hive_flutter ^1.1.0
- Target Platforms: iOS 14+, Android 14+
- Related PRs/Issues: None
- Parent Milestone: None

---

## 📋 Original Request

> Implementa Apple Health (iOS HealthKit) e Google Health Connect (Android 14+) integration per FitLog Pro con sync bidirezionale di workout data + body weight. Auto-sync 1x/giorno + manual on-demand. Zero tech debt. Bodybuilding & cardio focus.

---

## 🎯 Task Breakdown

### PHASE 1: MUST DO FIRST - Domain Foundation (6 tasks, ~2.5h)

**Blocking tasks** - Tutto il resto dipende da questi. Priorità assoluta.

---

#### Task 1.1: Define HealthDataType Enum

**Layer**: Domain
**Files**: `lib/features/health_sync/domain/entities/health_data_type.dart`
**Dependencies**: None
**Est. Time**: 20 min
**Blocking**: Yes (blocks Tasks 1.2-1.6, 2.1-2.4, 3.1-3.5)
**Verification**:
- Enum compiles with values: `workout`, `bodyWeight`, `bodyFat`, `leanMass`, `heartRate`, `sleep`, `nutrition`
- Extension method `displayName` returns localized key (NOT hardcoded string - use placeholder)
- Freezed annotation presente per future JSON serialization

**Code Prompt**:
```dart
// Create enum-based health data type with future extensibility
enum HealthDataType {
  workout,     // MVP
  bodyWeight,  // MVP
  bodyFat,     // Phase 2
  leanMass,    // Phase 2
  heartRate,   // Phase 2
  sleep,       // Phase 3
  nutrition,   // Phase 3
}

extension HealthDataTypeExtension on HealthDataType {
  String get displayNameKey {
    // Return localization key (NOT hardcoded text)
    // Example: 'healthDataTypeWorkout' for Task 6.1 to use
  }
}
```

**Notes**: Questa è la base per tutto il sistema. Zero tech debt = enum scalabile dal giorno 1.

---

#### Task 1.2: Create HealthSyncStatus Entity

**Layer**: Domain
**Files**: `lib/features/health_sync/domain/entities/health_sync_status.dart`
**Dependencies**: Task 1.1
**Est. Time**: 25 min
**Blocking**: Yes (blocks Task 2.1, 2.4, 3.2)
**Verification**:
- Freezed class `HealthSyncStatus` with fields: `HealthDataType dataType`, `DateTime? lastSyncTime`, `SyncResult lastResult`, `int retryCount`, `String? errorMessage`
- Enum `SyncResult` with values: `idle`, `syncing`, `success`, `error`
- Method `shouldRetry()` returns `true` if `lastResult == error && retryCount < 3`
- Freezed code generation passes (`flutter pub run build_runner build`)

**Code Prompt**:
```dart
@freezed
class HealthSyncStatus with _$HealthSyncStatus {
  const factory HealthSyncStatus({
    required HealthDataType dataType,
    required DateTime? lastSyncTime,
    required SyncResult lastResult,
    required int retryCount,
    String? errorMessage,
  }) = _HealthSyncStatus;

  factory HealthSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthSyncStatusFromJson(json);
}

enum SyncResult { idle, syncing, success, error }

extension HealthSyncStatusExtension on HealthSyncStatus {
  bool shouldRetry() => lastResult == SyncResult.error && retryCount < 3;
}
```

**Notes**: Questa entity rappresenta lo stato sync per OGNI tipo di dato (workout, peso, etc.). Generic = zero tech debt.

---

#### Task 1.3: Create HealthPermissionStatus Entity

**Layer**: Domain
**Files**: `lib/features/health_sync/domain/entities/health_permission_status.dart`
**Dependencies**: Task 1.1
**Est. Time**: 20 min
**Blocking**: Yes (blocks Task 3.1)
**Verification**:
- Freezed class `HealthPermissionStatus` con `Map<HealthDataType, PermissionState> permissions`
- Enum `PermissionState`: `notDetermined`, `authorized`, `denied`, `healthConnectNotInstalled` (Android-specific)
- Method `canSync(HealthDataType type)` returns `permissions[type] == PermissionState.authorized`
- Field `bool healthConnectAvailable` (Android-only flag)

**Code Prompt**:
```dart
@freezed
class HealthPermissionStatus with _$HealthPermissionStatus {
  const factory HealthPermissionStatus({
    required Map<HealthDataType, PermissionState> permissions,
    required bool healthConnectAvailable, // Android only
  }) = _HealthPermissionStatus;

  // NO fromJson - questo è volatile (mai persisted in Hive)
}

enum PermissionState {
  notDetermined,
  authorized,
  denied,
  healthConnectNotInstalled, // Android-specific
}

extension HealthPermissionStatusExtension on HealthPermissionStatus {
  bool canSync(HealthDataType type) =>
    permissions[type] == PermissionState.authorized;

  bool get hasPartialPermissions =>
    permissions.values.any((p) => p == PermissionState.authorized) &&
    permissions.values.any((p) => p != PermissionState.authorized);
}
```

**Notes**: VOLATILE = no Hive persistence (contro stale state). Runtime check sempre prima di sync.

---

#### Task 1.4: Create BodyMeasurement Entity

**Layer**: Domain
**Files**: `lib/features/health_sync/domain/entities/body_measurement.dart`
**Dependencies**: Task 1.1
**Est. Time**: 25 min
**Blocking**: Yes (blocks Task 2.2, 2.3)
**Verification**:
- Freezed class `BodyMeasurement` con fields: `double value`, `MeasurementUnit unit`, `DateTime recordedAt`, `HealthDataType dataType`, `String? source`
- Enum `MeasurementUnit`: `kilograms`, `pounds`, `percent` (for body fat %), etc.
- Freezed + JSON serialization
- Method `toKilograms()` for unit conversion

**Code Prompt**:
```dart
@freezed
class BodyMeasurement with _$BodyMeasurement {
  const factory BodyMeasurement({
    required double value,
    required MeasurementUnit unit,
    required DateTime recordedAt,
    required HealthDataType dataType, // bodyWeight, bodyFat, etc.
    String? source, // 'FitLog', 'HealthKit', 'Health Connect'
  }) = _BodyMeasurement;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementFromJson(json);
}

enum MeasurementUnit {
  kilograms,
  pounds,
  percent, // for body fat %
}

extension BodyMeasurementExtension on BodyMeasurement {
  double toKilograms() {
    if (unit == MeasurementUnit.pounds) return value * 0.453592;
    return value; // already kg
  }
}
```

**Notes**: Generic entity per peso, body fat %, lean mass (Phase 2). Future-proof.

---

#### Task 1.5: Create HealthWorkoutMapping Entity

**Layer**: Domain
**Files**: `lib/features/health_sync/domain/entities/health_workout_mapping.dart`
**Dependencies**: Task 1.1
**Est. Time**: 20 min
**Blocking**: Yes (blocks Task 2.2)
**Verification**:
- Class `HealthWorkoutTypeMapper` con static methods: `fromHealthKit()`, `toHealthKit()`, `fromHealthConnect()`, `toHealthConnect()`
- Enum `FitLogWorkoutCategory`: `strength`, `cardio`, `other`
- Mapping bidirectional per iOS + Android

**Code Prompt**:
```dart
enum FitLogWorkoutCategory {
  strength,  // Bodybuilding/resistance training
  cardio,    // Running, cycling, etc.
  other,     // Fallback generico
}

class HealthWorkoutTypeMapper {
  // iOS HealthKit → FitLog
  static FitLogWorkoutCategory fromHealthKit(HKWorkoutActivityType type) {
    switch (type) {
      case HKWorkoutActivityType.traditionalStrengthTraining:
      case HKWorkoutActivityType.functionalStrengthTraining:
        return FitLogWorkoutCategory.strength;

      case HKWorkoutActivityType.running:
      case HKWorkoutActivityType.cycling:
        return FitLogWorkoutCategory.cardio;

      default:
        return FitLogWorkoutCategory.other;
    }
  }

  // FitLog → iOS HealthKit (reverse)
  static HKWorkoutActivityType toHealthKit(FitLogWorkoutCategory category) {
    switch (category) {
      case FitLogWorkoutCategory.strength:
        return HKWorkoutActivityType.traditionalStrengthTraining;
      case FitLogWorkoutCategory.cardio:
        return HKWorkoutActivityType.running;
      case FitLogWorkoutCategory.other:
        return HKWorkoutActivityType.other;
    }
  }

  // Android Health Connect mappings (similar structure)
  // ...
}
```

**Notes**: Bodybuilding-focused (3 categorie). Non serve yoga, HIIT, sports per MVP.

---

#### Task 1.6: Define IHealthRepository Interface

**Layer**: Domain
**Files**: `lib/features/health_sync/domain/repositories/health_repository.dart`
**Dependencies**: Tasks 1.1, 1.2, 1.3, 1.4, 1.5
**Est. Time**: 30 min
**Blocking**: Yes (blocks ALL data + presentation layers)
**Verification**:
- Abstract class `IHealthRepository` con 6+ methods
- Returns `Future<Either<Failure, T>>` (fpdart)
- Methods: `requestPermissions()`, `syncWorkouts()`, `syncBodyWeight()`, `getLastSyncStatus()`, `retryFailedSync()`, `clearSyncCache()`

**Code Prompt**:
```dart
abstract class IHealthRepository {
  // Permission management
  Future<Either<Failure, HealthPermissionStatus>> requestPermissions({
    required List<HealthDataType> dataTypes,
  });

  Future<Either<Failure, HealthPermissionStatus>> checkPermissionStatus();

  // Sync operations
  Future<Either<Failure, void>> syncWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, void>> syncBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Sync status
  Future<Either<Failure, HealthSyncStatus>> getLastSyncStatus(
    HealthDataType dataType,
  );

  Future<Either<Failure, void>> retryFailedSync(HealthDataType dataType);

  Future<Either<Failure, void>> clearSyncCache();
}
```

**Notes**: Contract per data layer. Usa fpdart Either per error handling (già in pubspec.yaml).

---

### PHASE 2: THEN - Data + Presentation Layers (8 tasks, ~7.5h)

**Parallel workable** dopo Phase 1 completata. Task 2.1-2.4 possono andare in parallelo con 3.1-3.5.

---

#### Task 2.1: Create Freezed Models with JSON Serialization

**Layer**: Data
**Files**:
- `lib/features/health_sync/data/models/body_measurement_model.dart`
- `lib/features/health_sync/data/models/health_sync_status_model.dart`
- `lib/features/health_sync/data/models/health_workout_mapping_model.dart` (if needed)

**Dependencies**: Tasks 1.1-1.5
**Est. Time**: 45 min
**Blocking**: No (parallel con Task 3.1)
**Verification**:
- `flutter pub run build_runner build` compiles senza errori
- `*.freezed.dart` e `*.g.dart` generati
- JSON round-trip test passa: `model.toJson() → fromJson() → equals(model)`

**Code Prompt**:
```dart
// body_measurement_model.dart
@freezed
class BodyMeasurementModel with _$BodyMeasurementModel {
  const factory BodyMeasurementModel({
    required double value,
    required MeasurementUnit unit,
    required DateTime recordedAt,
    required HealthDataType dataType,
    String? source,
  }) = _BodyMeasurementModel;

  factory BodyMeasurementModel.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementModelFromJson(json);

  // Mapper to domain entity
  factory BodyMeasurementModel.fromDomain(BodyMeasurement entity) =>
      BodyMeasurementModel(
        value: entity.value,
        unit: entity.unit,
        recordedAt: entity.recordedAt,
        dataType: entity.dataType,
        source: entity.source,
      );

  BodyMeasurement toDomain() => BodyMeasurement(
    value: value,
    unit: unit,
    recordedAt: recordedAt,
    dataType: dataType,
    source: source,
  );
}

// Ripeti per HealthSyncStatusModel, etc.
```

**Notes**: Separazione data models (JSON) da domain entities (business logic). Clean Architecture.

---

#### Task 2.2: Implement HealthLocalDatasource (Hive)

**Layer**: Data
**Files**: `lib/features/health_sync/data/datasources/health_local_datasource.dart`
**Dependencies**: Task 2.1
**Est. Time**: 50 min
**Blocking**: No (parallel con Task 2.3)
**Verification**:
- Hive box `healthSyncBox` creato
- CRUD methods: `saveBodyMeasurement()`, `getLastSyncStatus()`, `updateRetryCount()`, `clearCache()`
- Type-safe con `BodyMeasurementModel`, `HealthSyncStatusModel`
- Hive adapters registrati in `main.dart`

**Code Prompt**:
```dart
class HealthLocalDatasource {
  static const String _boxName = 'healthSyncBox';
  static const String _measurementsKey = 'measurements';
  static const String _syncStatusKey = 'syncStatus';

  Future<Box> _openBox() async => await Hive.openBox(_boxName);

  // Save body measurement
  Future<void> saveBodyMeasurement(BodyMeasurementModel measurement) async {
    final box = await _openBox();
    final measurements = box.get(_measurementsKey, defaultValue: <Map>[]) as List;
    measurements.add(measurement.toJson());
    await box.put(_measurementsKey, measurements);
  }

  // Get last sync status for data type
  Future<HealthSyncStatusModel?> getLastSyncStatus(HealthDataType type) async {
    final box = await _openBox();
    final statusMap = box.get(_syncStatusKey, defaultValue: {}) as Map;
    if (!statusMap.containsKey(type.name)) return null;
    return HealthSyncStatusModel.fromJson(statusMap[type.name]);
  }

  // Update retry count (exponential backoff)
  Future<void> updateRetryCount(HealthDataType type, int count) async {
    final box = await _openBox();
    final status = await getLastSyncStatus(type);
    if (status == null) return;

    final updated = status.copyWith(retryCount: count);
    final statusMap = box.get(_syncStatusKey, defaultValue: {}) as Map;
    statusMap[type.name] = updated.toJson();
    await box.put(_syncStatusKey, statusMap);
  }

  Future<void> clearCache() async {
    final box = await _openBox();
    await box.clear();
  }
}
```

**Notes**: Usa Hive (già in pubspec.yaml). NO shared_preferences (troppo semplice per complex data).

---

#### Task 2.3: Implement HealthRemoteDatasource (HealthKit/Health Connect)

**Layer**: Data
**Files**: `lib/features/health_sync/data/datasources/health_remote_datasource.dart`
**Dependencies**: Tasks 1.1, 1.4, 1.5
**Est. Time**: 1h 15 min
**Blocking**: No (parallel con Task 2.2)
**Verification**:
- Wrapper around `health` package v13.2.1
- iOS: Sequential permission requests (`requestAuthorization` per workout, poi per weight)
- Android: `HealthConnectClient.isAvailable()` check + fallback dialog
- Platform channel errors mapped to domain `Failure` types
- Methods: `requestPermissions()`, `fetchWorkouts()`, `fetchBodyWeight()`, `writeBodyWeight()`

**Code Prompt**:
```dart
import 'package:health/health.dart';
import 'dart:io' show Platform;

class HealthRemoteDatasource {
  final Health _health = Health();

  // iOS: Sequential permission requests
  Future<HealthPermissionStatus> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    if (Platform.isIOS) {
      return await _requestIOSPermissions(dataTypes);
    } else if (Platform.isAndroid) {
      return await _requestAndroidPermissions(dataTypes);
    }
    throw UnsupportedError('Platform not supported');
  }

  Future<HealthPermissionStatus> _requestIOSPermissions(
    List<HealthDataType> types,
  ) async {
    final Map<HealthDataType, PermissionState> permissions = {};

    // Step 1: Request workout permission
    if (types.contains(HealthDataType.workout)) {
      final granted = await _health.requestAuthorization([
        HealthDataType.WORKOUT,
      ]);
      permissions[HealthDataType.workout] = granted
          ? PermissionState.authorized
          : PermissionState.denied;
    }

    // Step 2: Request weight permission (sequential!)
    if (types.contains(HealthDataType.bodyWeight)) {
      final granted = await _health.requestAuthorization([
        HealthDataType.WEIGHT,
      ]);
      permissions[HealthDataType.bodyWeight] = granted
          ? PermissionState.authorized
          : PermissionState.denied;
    }

    return HealthPermissionStatus(
      permissions: permissions,
      healthConnectAvailable: false, // iOS doesn't use Health Connect
    );
  }

  Future<HealthPermissionStatus> _requestAndroidPermissions(
    List<HealthDataType> types,
  ) async {
    // Check Health Connect availability
    final bool available = await _health.isHealthConnectAvailable();
    if (!available) {
      return HealthPermissionStatus(
        permissions: {
          for (var type in types)
            type: PermissionState.healthConnectNotInstalled,
        },
        healthConnectAvailable: false,
      );
    }

    // Request permissions (NOT sequential on Android)
    final androidTypes = types.map(_mapToHealthDataType).toList();
    final granted = await _health.requestAuthorization(androidTypes);

    return HealthPermissionStatus(
      permissions: {
        for (var type in types)
          type: granted ? PermissionState.authorized : PermissionState.denied,
      },
      healthConnectAvailable: true,
    );
  }

  // Fetch workouts
  Future<List<BodyMeasurementModel>> fetchWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final workouts = await _health.getHealthDataFromTypes(
      startDate,
      endDate,
      [HealthDataType.WORKOUT],
    );

    // Map to BodyMeasurementModel (workout duration as "measurement")
    return workouts.map((w) => BodyMeasurementModel(
      value: w.value.toDouble(), // workout duration in minutes
      unit: MeasurementUnit.minutes, // new enum value
      recordedAt: w.dateFrom,
      dataType: HealthDataType.workout,
      source: Platform.isIOS ? 'HealthKit' : 'Health Connect',
    )).toList();
  }

  // Fetch body weight
  Future<List<BodyMeasurementModel>> fetchBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final weights = await _health.getHealthDataFromTypes(
      startDate,
      endDate,
      [HealthDataType.WEIGHT],
    );

    return weights.map((w) => BodyMeasurementModel(
      value: w.value.toDouble(),
      unit: MeasurementUnit.kilograms,
      recordedAt: w.dateFrom,
      dataType: HealthDataType.bodyWeight,
      source: Platform.isIOS ? 'HealthKit' : 'Health Connect',
    )).toList();
  }

  // Write body weight (instant sync)
  Future<void> writeBodyWeight(BodyMeasurementModel measurement) async {
    await _health.writeHealthData(
      measurement.value,
      HealthDataType.WEIGHT,
      measurement.recordedAt,
      measurement.recordedAt,
    );
  }

  HealthDataType _mapToHealthDataType(HealthDataType appType) {
    switch (appType) {
      case HealthDataType.workout:
        return HealthDataType.WORKOUT;
      case HealthDataType.bodyWeight:
        return HealthDataType.WEIGHT;
      default:
        throw UnimplementedError('Type $appType not implemented');
    }
  }
}
```

**Notes**: Platform-agnostic wrapper. iOS = sequential, Android = batch + Health Connect check.

---

#### Task 2.4: Implement HealthRepositoryImpl

**Layer**: Data
**Files**: `lib/features/health_sync/data/repositories/health_repository_impl.dart`
**Dependencies**: Tasks 1.6, 2.2, 2.3
**Est. Time**: 55 min
**Blocking**: No (parallel con Task 3.1)
**Verification**:
- Implements `IHealthRepository` interface
- Integrates `HealthLocalDatasource` + `HealthRemoteDatasource`
- Error handling: `try-catch` → `Either<Failure, T>`
- Sync logic: fetch remote → save local → update status
- Conflict resolution: remote wins (timestamp-based)

**Code Prompt**:
```dart
class HealthRepositoryImpl implements IHealthRepository {
  final HealthLocalDatasource _localDatasource;
  final HealthRemoteDatasource _remoteDatasource;

  HealthRepositoryImpl({
    required HealthLocalDatasource localDatasource,
    required HealthRemoteDatasource remoteDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, HealthPermissionStatus>> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    try {
      final status = await _remoteDatasource.requestPermissions(
        dataTypes: dataTypes,
      );
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Update status to "syncing"
      await _localDatasource.updateSyncStatus(
        HealthDataType.bodyWeight,
        HealthSyncStatusModel(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.syncing,
          retryCount: 0,
        ),
      );

      // Fetch from HealthKit/Health Connect
      final measurements = await _remoteDatasource.fetchBodyWeight(
        startDate: startDate,
        endDate: endDate,
      );

      // Save to local Hive
      for (var measurement in measurements) {
        await _localDatasource.saveBodyMeasurement(measurement);
      }

      // Update status to "success"
      await _localDatasource.updateSyncStatus(
        HealthDataType.bodyWeight,
        HealthSyncStatusModel(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.success,
          retryCount: 0,
        ),
      );

      return const Right(null);
    } catch (e) {
      // Update status to "error"
      await _localDatasource.updateSyncStatus(
        HealthDataType.bodyWeight,
        HealthSyncStatusModel(
          dataType: HealthDataType.bodyWeight,
          lastSyncTime: DateTime.now(),
          lastResult: SyncResult.error,
          retryCount: 1, // First retry
          errorMessage: e.toString(),
        ),
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Implement syncWorkouts(), getLastSyncStatus(), retryFailedSync(), etc.
  // Similar pattern to syncBodyWeight()
}
```

**Notes**: Core sync orchestration. Gestisce local + remote coordination.

---

#### Task 3.1: Create HealthPermissionProvider

**Layer**: Presentation
**Files**: `lib/features/health_sync/presentation/providers/health_permission_provider.dart`
**Dependencies**: Tasks 1.3, 1.6
**Est. Time**: 35 min
**Blocking**: No (parallel con Task 2.1)
**Verification**:
- `StateNotifierProvider<HealthPermissionNotifier, AsyncValue<HealthPermissionStatus>>`
- Method `requestPermissions(List<HealthDataType>)` triggers repository call
- iOS sequential flow observable via state stream
- Android Health Connect not installed → auto-shows installation dialog

**Code Prompt**:
```dart
final healthPermissionProvider =
    StateNotifierProvider<HealthPermissionNotifier, AsyncValue<HealthPermissionStatus>>(
  (ref) => HealthPermissionNotifier(
    repository: ref.watch(healthRepositoryProvider),
  ),
);

class HealthPermissionNotifier extends StateNotifier<AsyncValue<HealthPermissionStatus>> {
  final IHealthRepository _repository;

  HealthPermissionNotifier({required IHealthRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading());

  Future<void> requestPermissions(List<HealthDataType> dataTypes) async {
    state = const AsyncValue.loading();

    final result = await _repository.requestPermissions(dataTypes: dataTypes);

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (status) {
        state = AsyncValue.data(status);

        // Android: Check Health Connect availability
        if (!status.healthConnectAvailable) {
          // Trigger installation dialog (via UI callback)
          // TODO: Implement in Task 3.5 (UI integration)
        }
      },
    );
  }

  Future<void> checkPermissionStatus() async {
    final result = await _repository.checkPermissionStatus();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (status) => state = AsyncValue.data(status),
    );
  }
}
```

**Notes**: Riverpod StateNotifier per permission flow. Observable per UI.

---

#### Task 3.2: Create HealthSyncProvider

**Layer**: Presentation
**Files**: `lib/features/health_sync/presentation/providers/health_sync_provider.dart`
**Dependencies**: Tasks 1.2, 1.6, 2.4
**Est. Time**: 40 min
**Blocking**: No (parallel con Task 3.1)
**Verification**:
- `StateNotifierProvider<HealthSyncNotifier, AsyncValue<HealthSyncStatus>>`
- Method `manualSync(HealthDataType)` triggers on-demand sync
- Retry logic: exponential backoff (1h → 4h → 24h delays)
- Loading/error/success states exposed to UI

**Code Prompt**:
```dart
final healthSyncProvider =
    StateNotifierProvider.family<HealthSyncNotifier, AsyncValue<HealthSyncStatus>, HealthDataType>(
  (ref, dataType) => HealthSyncNotifier(
    repository: ref.watch(healthRepositoryProvider),
    dataType: dataType,
  ),
);

class HealthSyncNotifier extends StateNotifier<AsyncValue<HealthSyncStatus>> {
  final IHealthRepository _repository;
  final HealthDataType _dataType;

  HealthSyncNotifier({
    required IHealthRepository repository,
    required HealthDataType dataType,
  })  : _repository = repository,
        _dataType = dataType,
        super(const AsyncValue.loading()) {
    _loadLastSyncStatus();
  }

  Future<void> _loadLastSyncStatus() async {
    final result = await _repository.getLastSyncStatus(_dataType);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (status) => state = AsyncValue.data(status),
    );
  }

  Future<void> manualSync() async {
    state = const AsyncValue.loading();

    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30)); // Last 30 days

    final result = _dataType == HealthDataType.bodyWeight
        ? await _repository.syncBodyWeight(startDate: startDate, endDate: now)
        : await _repository.syncWorkouts(startDate: startDate, endDate: now);

    result.fold(
      (failure) {
        // Increment retry count
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) => _loadLastSyncStatus(), // Reload status after success
    );
  }

  Future<void> retryFailedSync() async {
    final currentStatus = state.value;
    if (currentStatus == null || !currentStatus.shouldRetry()) return;

    // Exponential backoff delays
    final delays = [
      const Duration(hours: 1),
      const Duration(hours: 4),
      const Duration(hours: 24),
    ];

    final retryCount = currentStatus.retryCount;
    if (retryCount >= delays.length) return; // Max retries exceeded

    await Future.delayed(delays[retryCount]);
    await manualSync();
  }
}
```

**Notes**: Manual sync on-demand + retry logic. Family provider per data type.

---

#### Task 3.3: Create HealthBackgroundSyncProvider

**Layer**: Presentation
**Files**: `lib/features/health_sync/presentation/providers/health_background_sync_provider.dart`
**Dependencies**: Tasks 1.6, 2.4, 3.2
**Est. Time**: 45 min
**Blocking**: No (parallel con Task 3.1, 3.2)
**Verification**:
- Uses `workmanager` package (add to pubspec.yaml se mancante)
- Registers daily background task (24h interval)
- Checks `lastSyncTime` → syncs if >24h elapsed
- Platform-specific: iOS background fetch, Android WorkManager

**Code Prompt**:
```dart
import 'package:workmanager/workmanager.dart';

final healthBackgroundSyncProvider = Provider<HealthBackgroundSyncService>(
  (ref) => HealthBackgroundSyncService(
    repository: ref.watch(healthRepositoryProvider),
  ),
);

class HealthBackgroundSyncService {
  static const String _syncTaskName = 'healthDailySync';
  final IHealthRepository _repository;

  HealthBackgroundSyncService({required IHealthRepository repository})
      : _repository = repository;

  Future<void> registerDailySync() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    await Workmanager().registerPeriodicTask(
      _syncTaskName,
      _syncTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.connected, // Require internet
        requiresBatteryNotLow: true,
      ),
    );
  }

  Future<void> cancelDailySync() async {
    await Workmanager().cancelByUniqueName(_syncTaskName);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == HealthBackgroundSyncService._syncTaskName) {
      // Check last sync time
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 1));

      // TODO: Inject repository (workaround for background isolate)
      // For now, use direct datasource access

      debugPrint('🔄 Background sync triggered at $now');
      return Future.value(true);
    }
    return Future.value(false);
  });
}
```

**Notes**: 1x/day background sync. Usa WorkManager (cross-platform). Aggiungere `workmanager: ^0.5.2` a pubspec.yaml.

---

#### Task 3.4: Create HealthSyncStatusWidget

**Layer**: Presentation
**Files**: `lib/features/health_sync/presentation/widgets/health_sync_status_widget.dart`
**Dependencies**: Task 3.2
**Est. Time**: 30 min
**Blocking**: No (parallel con Task 3.5)
**Verification**:
- `ConsumerWidget` che mostra `HealthSyncStatus` per un `HealthDataType`
- Stati visualizzati: idle (grey), syncing (blue + spinner), success (green + checkmark), error (red + retry button)
- Last sync time formattato: "2 hours ago" (usa `timeago` package già in pubspec.yaml)
- Localized strings (usa placeholder keys per ora, Task 6.1 popola)

**Code Prompt**:
```dart
class HealthSyncStatusWidget extends ConsumerWidget {
  final HealthDataType dataType;

  const HealthSyncStatusWidget({
    super.key,
    required this.dataType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(healthSyncProvider(dataType));

    return syncStatus.when(
      data: (status) => _buildStatusCard(context, status),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => _buildErrorCard(context, error),
    );
  }

  Widget _buildStatusCard(BuildContext context, HealthSyncStatus status) {
    return Card(
      child: ListTile(
        leading: _getStatusIcon(status.lastResult),
        title: Text(
          // TODO: Replace with context.l10n.healthSyncStatusTitle in Task 6.1
          'healthSyncStatusTitle_${status.dataType.name}',
        ),
        subtitle: status.lastSyncTime != null
            ? Text(
                // TODO: Replace with timeago localization in Task 6.1
                timeago.format(status.lastSyncTime!),
              )
            : const Text('Never synced'),
        trailing: status.lastResult == SyncResult.error
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(healthSyncProvider(dataType).notifier).retryFailedSync();
                },
              )
            : null,
      ),
    );
  }

  Widget _getStatusIcon(SyncResult result) {
    switch (result) {
      case SyncResult.idle:
        return const Icon(Icons.cloud_outlined, color: Colors.grey);
      case SyncResult.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncResult.success:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case SyncResult.error:
        return const Icon(Icons.cloud_off, color: Colors.red);
    }
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return Card(
      color: context.colors.error.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(Icons.error, color: context.colors.error),
        title: const Text('Sync Error'),
        subtitle: Text(error.toString()),
      ),
    );
  }
}
```

**Notes**: Reusable widget per ogni HealthDataType. Theme-aware colors.

---

#### Task 3.5: Build HealthSyncSettingsScreen

**Layer**: Presentation
**Files**: `lib/features/health_sync/presentation/screens/health_sync_settings_screen.dart`
**Dependencies**: Tasks 3.1, 3.2, 3.3, 3.4
**Est. Time**: 50 min
**Blocking**: No (final presentation task)
**Verification**:
- Screen accessibile da Settings → "Health Sync"
- iOS: Sequential permission cards (workout, weight) con granular feedback
- Android: Health Connect availability check + install button se missing
- Manual sync button per workout + weight
- `HealthSyncStatusWidget` per ogni data type
- Last sync timestamp displayed
- Error messaging con retry button

**Code Prompt**:
```dart
class HealthSyncSettingsScreen extends ConsumerWidget {
  const HealthSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatus = ref.watch(healthPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Sync'), // TODO: Localize in Task 6.1
      ),
      body: permissionStatus.when(
        data: (status) => _buildContent(context, ref, status),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'), // TODO: Localize
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HealthPermissionStatus permissionStatus,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Android: Health Connect check
        if (Platform.isAndroid && !permissionStatus.healthConnectAvailable)
          _buildHealthConnectInstallCard(context),

        // Permission cards
        _buildPermissionCard(
          context,
          ref,
          dataType: HealthDataType.workout,
          permission: permissionStatus.permissions[HealthDataType.workout],
        ),
        const SizedBox(height: 16),
        _buildPermissionCard(
          context,
          ref,
          dataType: HealthDataType.bodyWeight,
          permission: permissionStatus.permissions[HealthDataType.bodyWeight],
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),

        // Sync status widgets
        const Text(
          'Sync Status', // TODO: Localize
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        HealthSyncStatusWidget(dataType: HealthDataType.workout),
        const SizedBox(height: 8),
        HealthSyncStatusWidget(dataType: HealthDataType.bodyWeight),

        const SizedBox(height: 32),

        // Manual sync button
        ElevatedButton.icon(
          onPressed: () => _manualSyncAll(ref),
          icon: const Icon(Icons.sync),
          label: const Text('Sync Now'), // TODO: Localize
        ),
      ],
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    WidgetRef ref, {
    required HealthDataType dataType,
    PermissionState? permission,
  }) {
    final isGranted = permission == PermissionState.authorized;

    return Card(
      child: ListTile(
        leading: Icon(
          isGranted ? Icons.check_circle : Icons.cancel,
          color: isGranted ? Colors.green : Colors.grey,
        ),
        title: Text(
          dataType == HealthDataType.workout ? 'Workout Sync' : 'Weight Sync',
          // TODO: Localize
        ),
        subtitle: Text(
          isGranted ? 'Authorized' : 'Not authorized',
          // TODO: Localize
        ),
        trailing: !isGranted
            ? TextButton(
                onPressed: () {
                  ref.read(healthPermissionProvider.notifier).requestPermissions([dataType]);
                },
                child: const Text('Enable'), // TODO: Localize
              )
            : null,
      ),
    );
  }

  Widget _buildHealthConnectInstallCard(BuildContext context) {
    return Card(
      color: context.colors.warning.withValues(alpha: 0.1),
      child: ListTile(
        leading: const Icon(Icons.warning),
        title: const Text('Health Connect Not Installed'), // TODO: Localize
        subtitle: const Text('Install from Play Store to enable sync'),
        trailing: ElevatedButton(
          onPressed: () {
            // Open Play Store
            // TODO: Use url_launcher (già in pubspec.yaml)
          },
          child: const Text('Install'),
        ),
      ),
    );
  }

  void _manualSyncAll(WidgetRef ref) {
    ref.read(healthSyncProvider(HealthDataType.workout).notifier).manualSync();
    ref.read(healthSyncProvider(HealthDataType.bodyWeight).notifier).manualSync();

    SnackBarService.showSuccess(
      // context unavailable in method - TODO: pass context
      'Syncing...', // TODO: Localize
    );
  }
}
```

**Notes**: Complete settings screen. iOS/Android platform-specific UI. Integra tutti i provider.

---

### PHASE 3: FINALLY - Testing + Localization (4 tasks, ~4h)

**Eseguire dopo Phase 1 + Phase 2 completate.** Testing richiede codice funzionante.

---

#### Task 4.1: Unit Tests (Entities + Mappers)

**Layer**: Testing
**Files**:
- `test/features/health_sync/domain/entities/health_data_type_test.dart`
- `test/features/health_sync/domain/entities/health_sync_status_test.dart`
- `test/features/health_sync/domain/entities/body_measurement_test.dart`
- `test/features/health_sync/data/models/body_measurement_model_test.dart`

**Dependencies**: Tasks 1.1-1.5, 2.1
**Est. Time**: 50 min
**Blocking**: No (parallel con Task 4.2)
**Verification**:
- `flutter test` passa (0 failures)
- Coverage >90% per entities + models
- JSON serialization round-trips testati
- Freezed equality tests

**Code Prompt**:
```dart
// health_sync_status_test.dart
void main() {
  group('HealthSyncStatus', () {
    test('should create instance with required fields', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.success,
        retryCount: 0,
      );

      expect(status.dataType, HealthDataType.workout);
      expect(status.lastResult, SyncResult.success);
    });

    test('shouldRetry returns true when error and retryCount < 3', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.error,
        retryCount: 2,
      );

      expect(status.shouldRetry(), true);
    });

    test('shouldRetry returns false when retryCount >= 3', () {
      final status = HealthSyncStatus(
        dataType: HealthDataType.workout,
        lastSyncTime: DateTime.now(),
        lastResult: SyncResult.error,
        retryCount: 3,
      );

      expect(status.shouldRetry(), false);
    });
  });
}

// body_measurement_model_test.dart
void main() {
  group('BodyMeasurementModel', () {
    test('JSON round-trip serialization', () {
      final model = BodyMeasurementModel(
        value: 75.5,
        unit: MeasurementUnit.kilograms,
        recordedAt: DateTime.now(),
        dataType: HealthDataType.bodyWeight,
        source: 'HealthKit',
      );

      final json = model.toJson();
      final restored = BodyMeasurementModel.fromJson(json);

      expect(restored, model); // Freezed equality
    });

    test('toKilograms converts pounds correctly', () {
      final model = BodyMeasurementModel(
        value: 165.0, // 165 lbs
        unit: MeasurementUnit.pounds,
        recordedAt: DateTime.now(),
        dataType: HealthDataType.bodyWeight,
      );

      final kg = model.toKilograms();
      expect(kg, closeTo(74.84, 0.01)); // 165 lbs ≈ 74.84 kg
    });
  });
}
```

**Notes**: Focus su entity logic + JSON serialization. Usa `mocktail` (già in pubspec.yaml).

---

#### Task 4.2: Integration Tests (HealthRepository)

**Layer**: Testing
**Files**: `test/features/health_sync/data/repositories/health_repository_impl_test.dart`
**Dependencies**: Tasks 2.2, 2.3, 2.4
**Est. Time**: 1h
**Blocking**: No (parallel con Task 4.1)
**Verification**:
- Mock `HealthLocalDatasource` e `HealthRemoteDatasource`
- Testa sync flow: fetch remote → save local → update status
- Testa error handling: remote failure → error status + retry count increment
- Testa conflict resolution: timestamp comparison

**Code Prompt**:
```dart
import 'package:mocktail/mocktail.dart';

class MockHealthLocalDatasource extends Mock implements HealthLocalDatasource {}
class MockHealthRemoteDatasource extends Mock implements HealthRemoteDatasource {}

void main() {
  late HealthRepositoryImpl repository;
  late MockHealthLocalDatasource mockLocal;
  late MockHealthRemoteDatasource mockRemote;

  setUp(() {
    mockLocal = MockHealthLocalDatasource();
    mockRemote = MockHealthRemoteDatasource();
    repository = HealthRepositoryImpl(
      localDatasource: mockLocal,
      remoteDatasource: mockRemote,
    );
  });

  group('syncBodyWeight', () {
    test('should fetch from remote and save to local on success', () async {
      // Arrange
      final measurements = [
        BodyMeasurementModel(
          value: 75.5,
          unit: MeasurementUnit.kilograms,
          recordedAt: DateTime.now(),
          dataType: HealthDataType.bodyWeight,
          source: 'HealthKit',
        ),
      ];

      when(() => mockRemote.fetchBodyWeight(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => measurements);

      when(() => mockLocal.saveBodyMeasurement(any()))
          .thenAnswer((_) async => {});

      when(() => mockLocal.updateSyncStatus(any(), any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.syncBodyWeight(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRemote.fetchBodyWeight(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).called(1);
      verify(() => mockLocal.saveBodyMeasurement(measurements[0])).called(1);
      verify(() => mockLocal.updateSyncStatus(
        HealthDataType.bodyWeight,
        any(that: isA<HealthSyncStatusModel>()
            .having((s) => s.lastResult, 'lastResult', SyncResult.success)),
      )).called(1);
    });

    test('should update error status on remote failure', () async {
      // Arrange
      when(() => mockRemote.fetchBodyWeight(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenThrow(Exception('Network error'));

      when(() => mockLocal.updateSyncStatus(any(), any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.syncBodyWeight(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      // Assert
      expect(result.isLeft(), true);
      verify(() => mockLocal.updateSyncStatus(
        HealthDataType.bodyWeight,
        any(that: isA<HealthSyncStatusModel>()
            .having((s) => s.lastResult, 'lastResult', SyncResult.error)
            .having((s) => s.retryCount, 'retryCount', 1)),
      )).called(1);
    });
  });
}
```

**Notes**: Integration testing senza UI. Verifica data layer coordination.

---

#### Task 4.3: E2E Tests (Patrol - Permission Dialogs)

**Layer**: Testing
**Files**: `integration_test/health_sync_e2e_test.dart`
**Dependencies**: Tasks 3.1, 3.5
**Est. Time**: 1h 15 min
**Blocking**: No (può andare in parallelo con Task 4.1, 4.2)
**Verification**:
- Patrol test runner configurato
- Test iOS: apri settings → tap "Enable" → sistema iOS permission dialog appare → tap "Allow" → verifica authorized state
- Test Android: apri settings → tap "Enable" → Health Connect dialog → tap "Allow" → verifica authorized
- Mock HealthKit/Health Connect responses (Patrol native mocking)

**Code Prompt**:
```dart
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'iOS: Sequential permission flow workout → weight',
    ($) async {
      // Navigate to Health Sync settings
      await $.pumpWidgetAndSettle(const MyApp());
      await $.tap(find.text('Settings'));
      await $.tap(find.text('Health Sync'));

      // Verify initial state: both permissions not authorized
      expect($(find.text('Not authorized')), findsNWidgets(2));

      // Step 1: Request workout permission
      await $.tap($(find.text('Enable')).first); // First "Enable" button

      // Patrol handles iOS native permission dialog
      await $.native.grantPermissionWhenInUse(); // HealthKit workout permission

      // Verify workout authorized, weight still not
      await $.waitUntilVisible(find.text('Authorized'));
      expect($(find.text('Authorized')), findsOneWidget);
      expect($(find.text('Not authorized')), findsOneWidget);

      // Step 2: Request weight permission
      await $.tap($(find.text('Enable')).at(1)); // Second "Enable" button

      await $.native.grantPermissionWhenInUse(); // HealthKit weight permission

      // Verify both authorized
      await $.waitUntilVisible($(find.text('Authorized')).at(1));
      expect($(find.text('Authorized')), findsNWidgets(2));
    },
  );

  patrolTest(
    'Android: Health Connect not installed flow',
    ($) async {
      // Navigate to Health Sync settings
      await $.pumpWidgetAndSettle(const MyApp());
      await $.tap(find.text('Settings'));
      await $.tap(find.text('Health Sync'));

      // Verify Health Connect install card visible
      expect($(find.text('Health Connect Not Installed')), findsOneWidget);

      // Tap install button
      await $.tap(find.text('Install'));

      // Patrol handles Play Store navigation
      await $.native.openAppSwitcher();
      await $.native.selectAppByPackageName('com.android.vending'); // Play Store

      // (In real test, user would install Health Connect)
      // For test, mock Health Connect becoming available

      // Return to app
      await $.native.openAppByPackageName('com.example.fitlog');

      // Verify install card no longer visible
      expect($(find.text('Health Connect Not Installed')), findsNothing);
    },
  );
}
```

**Notes**: E2E con Patrol. Testa native permission dialogs iOS/Android. Richiede device fisico o emulator.

---

#### Task 4.4: Localization Strings + Setup

**Layer**: Localization
**Files**: `assets/i18n/app_en.arb`, `assets/i18n/app_it.arb`
**Dependencies**: Task 3.5 (copy finalized)
**Est. Time**: 40 min
**Blocking**: No (can start after Task 3.5 UI complete)
**Verification**:
- ~20 new strings added to both EN + IT
- `flutter gen-l10n` compiles senza errori
- `AppLocalizations.of(context)` resolve tutte le nuove stringhe
- Replace tutti i placeholder in Task 3.4 e 3.5 con `context.l10n.*`

**Code Prompt**:
```json
// app_en.arb
{
  "healthSyncTitle": "Health Sync",
  "healthSyncBenefits": "Sync your workouts and weight with Apple Health or Health Connect",

  "healthDataTypeWorkout": "Workout",
  "healthDataTypeBodyWeight": "Body Weight",

  "healthSyncStatusSyncing": "Syncing...",
  "healthSyncStatusSuccess": "Last synced {timeAgo}",
  "healthSyncStatusError": "Sync failed: {error}",
  "healthSyncStatusNeverSynced": "Never synced",

  "healthPermissionAuthorized": "Authorized",
  "healthPermissionNotAuthorized": "Not authorized",
  "healthPermissionEnable": "Enable",

  "healthSyncManualSyncButton": "Sync Now",
  "healthSyncManualSyncInProgress": "Syncing...",
  "healthSyncManualSyncSuccess": "Sync completed successfully",

  "healthConnectNotInstalled": "Health Connect Not Installed",
  "healthConnectInstallPrompt": "Install from Play Store to enable sync",
  "healthConnectInstallButton": "Install",

  "healthSyncErrorNetwork": "Network error. Check connection.",
  "healthSyncErrorPermission": "Permission denied. Enable in settings.",
  "healthSyncErrorRetry": "Retry",

  "healthSyncFirstWorkoutComplete": "Great job! Enable health sync to track your progress in Apple Health.",
  "healthSyncFirstWorkoutCompleteButton": "Enable Sync"
}

// app_it.arb (traduzioni italiane)
{
  "healthSyncTitle": "Sincronizzazione Salute",
  "healthSyncBenefits": "Sincronizza allenamenti e peso con Apple Health o Health Connect",

  "healthDataTypeWorkout": "Allenamento",
  "healthDataTypeBodyWeight": "Peso Corporeo",

  "healthSyncStatusSyncing": "Sincronizzazione...",
  "healthSyncStatusSuccess": "Ultima sincronizzazione {timeAgo}",
  "healthSyncStatusError": "Sincronizzazione fallita: {error}",
  "healthSyncStatusNeverSynced": "Mai sincronizzato",

  "healthPermissionAuthorized": "Autorizzato",
  "healthPermissionNotAuthorized": "Non autorizzato",
  "healthPermissionEnable": "Abilita",

  "healthSyncManualSyncButton": "Sincronizza Ora",
  "healthSyncManualSyncInProgress": "Sincronizzazione...",
  "healthSyncManualSyncSuccess": "Sincronizzazione completata",

  "healthConnectNotInstalled": "Health Connect Non Installato",
  "healthConnectInstallPrompt": "Installa dal Play Store per abilitare la sincronizzazione",
  "healthConnectInstallButton": "Installa",

  "healthSyncErrorNetwork": "Errore di rete. Controlla la connessione.",
  "healthSyncErrorPermission": "Permesso negato. Abilita nelle impostazioni.",
  "healthSyncErrorRetry": "Riprova",

  "healthSyncFirstWorkoutComplete": "Ottimo lavoro! Abilita la sincronizzazione per tracciare i progressi in Apple Health.",
  "healthSyncFirstWorkoutCompleteButton": "Abilita Sincronizzazione"
}
```

**Post-Task**:
- Run `flutter gen-l10n`
- Replace all hardcoded strings in Task 3.4 + 3.5 with `context.l10n.*`
- Commit: `feat(localization): add health sync strings (EN + IT)`

**Notes**: ~20 stringhe EN + IT. Segue convenzione esistente app (fitness-focused copy).

---

## 📊 Implementation Order

### Critical Path (Must Complete Sequentially):

```
Tasks 1.1-1.6 (Domain Foundation) → ~2.5h
         ↓
Task 2.1 (Models) → ~45 min
         ↓
Tasks 2.2-2.4 (Data Layer) → ~3h
         ↓
Tasks 3.1-3.3 (Providers) → ~2h
         ↓
Task 3.5 (Settings Screen) → ~50 min
         ↓
Task 4.4 (Localization) → ~40 min
```

**Total Critical Path**: ~10h (Day 1-2)

### Parallel Workable:

**After Task 1.6 completes**, these can run concurrently:

- **Track A** (Data): Tasks 2.1 → 2.2 → 2.3 → 2.4
- **Track B** (Presentation): Tasks 3.1 → 3.2 → 3.3 → 3.4 → 3.5
- **Track C** (Testing): Tasks 4.1 → 4.2 → 4.3 (after Track A + B complete)

**Estimated Timeline**:

- **Day 1**: Tasks 1.1-1.6 (domain) + Task 2.1 (models) → ~3.5h
- **Day 2**: Tasks 2.2-2.4 (data) + Tasks 3.1-3.3 (providers) → ~6h
- **Day 3**: Tasks 3.4-3.5 (UI) + Task 4.4 (localization) → ~2h
- **Day 4**: Tasks 4.1-4.3 (testing) + polish → ~3h

**Total**: ~14.5h actual work → 3-4 days accounting for breaks, debugging, testing

---

## 🎯 Success Criteria

**MVP is complete when**:

- [ ] ✅ All 18 tasks marked complete
- [ ] ✅ `flutter analyze` passes (0 errors, 0 warnings)
- [ ] ✅ `flutter test` passes (>90% coverage for health_sync feature)
- [ ] ✅ Manual testing on iPhone: permission flow works, sync succeeds
- [ ] ✅ Localization complete (EN + IT, no hardcoded strings)
- [ ] ✅ Settings screen accessible and functional
- [ ] ✅ Background sync registered (1x/day)
- [ ] ✅ Graceful degradation tested (partial permissions, offline, Health Connect missing)

**Known Limitations (Documented)**:

- ❌ Android testing: Only emulator available (no physical device)
- ❌ HealthKit set-by-set data: Not supported by HealthKit API (workout summaries only)
- ❌ Background sync iOS: Requires background fetch capability enabled

---

## 📝 Notes & Decisions

**2025-11-22 10:05**: Plan generated via task-master.dev API

**Key Architectural Decisions**:

1. **Enum-based `HealthDataType`** (Task 1.1): Future-proof for Phase 2+ (body fat, heart rate, sleep). Zero tech debt principle.
2. **Volatile permission status** (Task 1.3): NO Hive persistence → runtime checks prevent stale state bugs.
3. **Sequential iOS permissions** (Task 2.3): iOS HIG compliance + granular user feedback.
4. **WorkManager for background** (Task 3.3): Cross-platform 1x/day sync vs platform-specific solutions.
5. **Graceful degradation** (Task 3.5): Partial permission approval OK (workout-only or weight-only sync).

**Dependencies Added to pubspec.yaml**:

- `workmanager: ^0.5.2` (background sync) - TODO: Add in Task 3.3
- All other packages already present (`health ^13.2.1`, `riverpod`, `hive_flutter`, etc.)

---

## 🔗 Related Documentation

- [HEALTH_SYNC_INTEGRATION_DESIGN.md](../UX_FLOWS/health_sync/HEALTH_SYNC_INTEGRATION_DESIGN.md) - Complete architecture design (60KB)
- [CLAUDE.md](../../CLAUDE.md) - Project rules + REGOLA #14 (taskmaster integration)
- [pubspec.yaml](../../pubspec.yaml) - Dependencies reference
- [docs/NAVIGATION/INDEX.md](../NAVIGATION/INDEX.md) - Documentation index

---

## 📈 Version History

### v1.0 - 2025-11-22 10:05

**Initial plan generation** via task-master.dev API

**Total Tasks**: 18
**Estimated Time**: ~14.5h (3-4 days)
**Complexity**: HIGH (new feature + multi-platform + zero tech debt)

---

*✅ Piano pronto per implementazione. Seguire task order per evitare blockers.*
