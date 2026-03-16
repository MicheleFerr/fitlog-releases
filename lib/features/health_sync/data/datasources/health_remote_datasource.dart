import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart' as health_pkg;
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remote datasource for health data from HealthKit (iOS) and Health Connect (Android).
///
/// Wraps the `health` package (https://pub.dev/packages/health) which provides
/// unified API for both iOS HealthKit and Android Health Connect.
///
/// **Platform Support**:
/// - iOS 14+: Uses HealthKit (native framework)
/// - Android 14+: Uses Health Connect (installable app)
///
/// **Permission Model**:
/// - iOS: Sequential permission requests (workout → weight)
/// - Android: Batch permission request + Health Connect availability check
abstract class IHealthRemoteDatasource {
  // ============================================================
  // PERMISSION MANAGEMENT
  // ============================================================

  /// Requests permission to access specified health data types.
  ///
  /// iOS: Shows native HealthKit permission dialog for each data type.
  /// Android: Shows Health Connect permission dialog (batch).
  ///
  /// Returns [HealthPermissionStatus] with granular permission state per type.
  ///
  /// Example:
  /// ```dart
  /// final status = await datasource.requestPermissions(
  ///   dataTypes: [HealthDataType.workout, HealthDataType.bodyWeight],
  /// );
  ///
  /// if (status.canAttemptSync(HealthDataType.workout)) {
  ///   // Authorized to sync workouts
  /// }
  /// ```
  Future<HealthPermissionStatus> requestPermissions({
    required List<HealthDataType> dataTypes,
  });

  /// Checks current permission status without requesting (runtime check only).
  ///
  /// **IMPORTANT**: Always returns fresh runtime status (no cached state).
  ///
  /// Example:
  /// ```dart
  /// final status = await datasource.checkPermissionStatus();
  /// if (status.hasPartialPermissions) {
  ///   // Show UI: "Some permissions granted, some denied"
  /// }
  /// ```
  Future<HealthPermissionStatus> checkPermissionStatus();

  // ============================================================
  // WORKOUT SYNC
  // ============================================================

  /// Fetches workouts from health platform within date range.
  ///
  /// iOS: Queries HealthKit for HKWorkoutActivityType samples.
  /// Android: Queries Health Connect for ExerciseSessionRecord.
  ///
  /// Returns list of workout data as maps:
  /// ```dart
  /// {
  ///   'type': 'TRADITIONAL_STRENGTH_TRAINING', // HealthKit type
  ///   'startTime': '2025-01-15T10:00:00',
  ///   'endTime': '2025-01-15T11:00:00',
  ///   'duration': 60, // minutes
  ///   'calories': 300, // optional
  ///   'source': 'HealthKit', // or 'Health Connect'
  /// }
  /// ```
  ///
  /// Example:
  /// ```dart
  /// final workouts = await datasource.fetchWorkouts(
  ///   startDate: DateTime.now().subtract(Duration(days: 30)),
  ///   endDate: DateTime.now(),
  /// );
  ///
  /// for (final workout in workouts) {
  ///   final category = HealthWorkoutTypeMapper.fromHealthKit(workout['type']);
  ///   // Save to FitLog based on category
  /// }
  /// ```
  Future<List<Map<String, dynamic>>> fetchWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================================
  // BODY WEIGHT SYNC
  // ============================================================

  /// Fetches body weight measurements from health platform.
  ///
  /// iOS: Queries HealthKit for HKQuantityTypeIdentifierBodyMass samples.
  /// Android: Queries Health Connect for WeightRecord.
  ///
  /// Returns list of [BodyMeasurement] with:
  /// - Value in kilograms (always kg from health package)
  /// - Timestamp (recordedAt)
  /// - Source ('HealthKit' or 'Health Connect')
  ///
  /// Example:
  /// ```dart
  /// final weights = await datasource.fetchBodyWeight(
  ///   startDate: DateTime.now().subtract(Duration(days: 90)),
  ///   endDate: DateTime.now(),
  /// );
  ///
  /// // weights[0] = BodyMeasurement(value: 75.5, unit: kg, recordedAt: ...)
  /// ```
  Future<List<BodyMeasurement>> fetchBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Writes a single body weight measurement to health platform.
  ///
  /// iOS: Creates HKQuantitySample for BodyMass.
  /// Android: Creates WeightRecord in Health Connect.
  ///
  /// Instant sync: Called when user manually enters weight in FitLog.
  /// Writes immediately to platform without waiting for daily background sync.
  ///
  /// Example:
  /// ```dart
  /// final measurement = BodyMeasurement(
  ///   value: 75.5,
  ///   unit: MeasurementUnit.kilograms,
  ///   recordedAt: DateTime.now(),
  ///   dataType: HealthDataType.bodyWeight,
  ///   source: 'FitLog',
  /// );
  ///
  /// await datasource.writeBodyWeight(measurement);
  /// // Now visible in Apple Health or Health Connect
  /// ```
  Future<void> writeBodyWeight(BodyMeasurement measurement);

  // ============================================================
  // HEIGHT SYNC
  // ============================================================

  /// Fetches height measurements from health platform.
  ///
  /// iOS: Queries HealthKit for HKQuantityTypeIdentifierHeight samples.
  /// Android: Queries Health Connect for HeightRecord.
  ///
  /// Returns list of [BodyMeasurement] with:
  /// - Value in meters (from health package)
  /// - Timestamp (recordedAt)
  /// - Source ('HealthKit' or 'Health Connect')
  ///
  /// Example:
  /// ```dart
  /// final heights = await datasource.fetchHeight(
  ///   startDate: DateTime.now().subtract(Duration(days: 365)),
  ///   endDate: DateTime.now(),
  /// );
  ///
  /// // heights[0] = BodyMeasurement(value: 1.75, unit: meters, recordedAt: ...)
  /// // Convert to cm: 1.75 * 100 = 175 cm
  /// ```
  Future<List<BodyMeasurement>> fetchHeight({
    required DateTime startDate,
    required DateTime endDate,
  });

  // ============================================================
  // WORKOUT WRITE
  // ============================================================

  /// Writes a completed workout to health platform.
  ///
  /// iOS: Creates HKWorkout with activity type TRADITIONAL_STRENGTH_TRAINING.
  /// Android: Creates ExerciseSessionRecord in Health Connect.
  ///
  /// This enables workouts to appear in Apple Fitness and count toward
  /// Activity rings (Exercise ring).
  ///
  /// **Parameters**:
  /// - [startTime]: When the workout started
  /// - [endTime]: When the workout ended
  /// - [totalCalories]: Optional calories burned during workout
  /// - [workoutName]: Optional name for logging purposes
  ///
  /// Example:
  /// ```dart
  /// await datasource.writeWorkout(
  ///   startTime: workout.startTime,
  ///   endTime: workout.endTime,
  ///   totalCalories: 300,
  /// );
  /// // Now visible in Apple Fitness and counts toward Exercise ring
  /// ```
  Future<bool> writeWorkout({
    required DateTime startTime,
    required DateTime endTime,
    int? totalCalories,
    String? workoutName,
  });

  // ============================================================
  // HEALTH CONNECT (ANDROID) - AVAILABILITY & INSTALLATION
  // ============================================================

  /// Android-specific: Opens Play Store to install Health Connect.
  ///
  /// Call this when Health Connect is not available on the device.
  /// iOS: No-op (uses native HealthKit).
  ///
  /// Example:
  /// ```dart
  /// final status = await datasource.checkPermissionStatus();
  /// if (!status.healthConnectAvailable && Platform.isAndroid) {
  ///   await datasource.installHealthConnect();
  ///   // Show dialog: "Please install Health Connect and return to the app"
  /// }
  /// ```
  Future<void> installHealthConnect();
}

/// Implementation of [IHealthRemoteDatasource] using the `health` package.
class HealthRemoteDatasourceImpl implements IHealthRemoteDatasource {
  HealthRemoteDatasourceImpl({
    health_pkg.Health? health,
    Future<SharedPreferences> Function()? sharedPreferencesFactory,
    bool? isIOSOverride,
    bool? isAndroidOverride,
  }) : _health = health ?? health_pkg.Health(),
       _sharedPreferencesFactory =
           sharedPreferencesFactory ?? SharedPreferences.getInstance,
       _isIOS = isIOSOverride ?? Platform.isIOS,
       _isAndroid = isAndroidOverride ?? Platform.isAndroid;

  static const String _iosRequestedPermissionsKey =
      'health_sync_ios_requested_permissions';

  final health_pkg.Health _health;
  final Future<SharedPreferences> Function() _sharedPreferencesFactory;
  final bool _isIOS;
  final bool _isAndroid;
  bool _isConfigured = false;

  /// Ensures the health package is configured before use.
  ///
  /// **CRITICAL**: Must be called before any HealthKit/Health Connect operations.
  /// This enables the health package to communicate with the native platform.
  Future<void> _ensureConfigured() async {
    if (_isConfigured) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] Already configured');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] Configuring health package...');
    }
    try {
      // Configure health package for HealthKit (iOS) / Health Connect (Android)
      // useHealthConnectIfAvailable: true enables Health Connect on Android 14+
      await _health.configure();
      _isConfigured = true;
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] ✅ Configuration successful');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] ❌ Configuration failed: $e');
      }
      debugPrint('🏥 [HealthKit] Stack: $stack');
      rethrow;
    }
  }

  /// Maps [HealthDataType] to `health` package's [HealthDataType].
  health_pkg.HealthDataType _mapToHealthPackageType(HealthDataType dataType) {
    switch (dataType) {
      case HealthDataType.workout:
        return health_pkg.HealthDataType.WORKOUT;
      case HealthDataType.bodyWeight:
        return health_pkg.HealthDataType.WEIGHT;
      case HealthDataType.height:
        return health_pkg.HealthDataType.HEIGHT;
      case HealthDataType.bodyFat:
        return health_pkg.HealthDataType.BODY_FAT_PERCENTAGE;
      case HealthDataType.leanMass:
        return health_pkg.HealthDataType.LEAN_BODY_MASS;
      case HealthDataType.heartRate:
        return health_pkg.HealthDataType.HEART_RATE;
      case HealthDataType.sleep:
        return health_pkg.HealthDataType.SLEEP_ASLEEP; // Sleep in bed
      case HealthDataType.nutrition:
        return health_pkg.HealthDataType.NUTRITION; // Generic nutrition data
    }
  }

  health_pkg.HealthDataAccess _requiredAccessForType(HealthDataType dataType) {
    if (dataType == HealthDataType.bodyWeight ||
        dataType == HealthDataType.workout) {
      return health_pkg.HealthDataAccess.READ_WRITE;
    }

    return health_pkg.HealthDataAccess.READ;
  }

  Future<void> _markIosPermissionsRequested(
    Iterable<HealthDataType> dataTypes,
  ) async {
    if (!_isIOS) {
      return;
    }

    final prefs = await _sharedPreferencesFactory();
    final requested =
        prefs.getStringList(_iosRequestedPermissionsKey)?.toSet() ?? <String>{};
    requested.addAll(dataTypes.map((type) => type.name));
    await prefs.setStringList(
      _iosRequestedPermissionsKey,
      requested.toList()..sort(),
    );
  }

  Future<bool> _wasIosPermissionRequested(HealthDataType dataType) async {
    if (!_isIOS) {
      return false;
    }

    final prefs = await _sharedPreferencesFactory();
    final requested = prefs.getStringList(_iosRequestedPermissionsKey);
    return requested?.contains(dataType.name) ?? false;
  }

  Future<PermissionState> _resolvePermissionState(
    HealthDataType dataType,
  ) async {
    final healthType = _mapToHealthPackageType(dataType);
    final requiredAccess = _requiredAccessForType(dataType);
    final hasPermission = await _health.hasPermissions(
      [healthType],
      permissions: [requiredAccess],
    );

    if (kDebugMode) {
      debugPrint(
        '🏥 [HealthKit] permission check for $dataType ($requiredAccess): $hasPermission',
      );
    }

    if (hasPermission == true) {
      return PermissionState.authorized;
    }

    if (hasPermission == false) {
      return PermissionState.denied;
    }

    if (!_isIOS) {
      return PermissionState.notDetermined;
    }

    final hasWritePermission =
        requiredAccess == health_pkg.HealthDataAccess.READ
        ? null
        : await _health.hasPermissions(
            [healthType],
            permissions: [health_pkg.HealthDataAccess.WRITE],
          );

    if (kDebugMode) {
      debugPrint(
        '🏥 [HealthKit] iOS write permission probe for $dataType: $hasWritePermission',
      );
    }

    if (hasWritePermission == true ||
        await _wasIosPermissionRequested(dataType)) {
      return PermissionState.unverified;
    }

    return PermissionState.notDetermined;
  }

  // ============================================================
  // PERMISSION IMPLEMENTATION
  // ============================================================

  @override
  Future<HealthPermissionStatus> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] requestPermissions called for: $dataTypes');
    }

    // Ensure health package is configured before requesting permissions
    await _ensureConfigured();

    // Map domain types to health package types
    final healthTypes = dataTypes
        .map((dt) => _mapToHealthPackageType(dt))
        .toList();

    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] Mapped to health package types: $healthTypes');
    }

    // Bidirectional sync: Request read + write permissions
    // Workout: Read + Write (export to Apple Fitness / Activity rings)
    // Body weight: Read + Write (bidirectional sync)
    // Height: Read only (import for onboarding)
    final permissions = dataTypes.map(_requiredAccessForType).toList();

    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] Requesting permissions: $permissions');
    }
    debugPrint('🏥 [HealthKit] Platform: ${_isIOS ? "iOS" : "Android"}');

    // Request permissions via health package
    try {
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] Calling _health.requestAuthorization...');
      }
      final result = await _health.requestAuthorization(
        healthTypes,
        permissions: permissions,
      );
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] requestAuthorization returned: $result');
      }

      if (result) {
        await _markIosPermissionsRequested(dataTypes);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] ❌ requestAuthorization failed: $e');
      }
      debugPrint('🏥 [HealthKit] Stack: $stack');
      rethrow;
    }

    final permissionStates = <HealthDataType, PermissionState>{};

    for (final dataType in dataTypes) {
      permissionStates[dataType] = await _resolvePermissionState(dataType);
    }

    // Android-specific: Check if Health Connect is installed
    final healthConnectAvailable = _isAndroid
        ? await _isHealthConnectAvailable()
        : false;

    return HealthPermissionStatus(
      permissions: permissionStates,
      healthConnectAvailable: healthConnectAvailable,
    );
  }

  @override
  Future<HealthPermissionStatus> checkPermissionStatus() async {
    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] checkPermissionStatus called');
    }

    // Ensure health package is configured before checking permissions
    await _ensureConfigured();

    // Check all possible data types (7 total)
    const allTypes = HealthDataType.values;
    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] Checking permissions for: $allTypes');
    }

    final permissionStates = <HealthDataType, PermissionState>{};

    for (final dataType in allTypes) {
      permissionStates[dataType] = await _resolvePermissionState(dataType);
    }

    final healthConnectAvailable = _isAndroid
        ? await _isHealthConnectAvailable()
        : false;

    return HealthPermissionStatus(
      permissions: permissionStates,
      healthConnectAvailable: healthConnectAvailable,
    );
  }

  /// Android-specific: Checks if Health Connect app is installed and SDK status.
  ///
  /// iOS always returns false (uses native HealthKit).
  ///
  /// **Health Connect SDK Status**:
  /// - `sdkAvailable`: Health Connect is installed and ready
  /// - `sdkUnavailable`: Health Connect not available (old Android version)
  /// - `sdkUnavailableProviderUpdateRequired`: Health Connect needs update
  ///
  /// Example:
  /// ```dart
  /// final available = await _isHealthConnectAvailable();
  /// if (!available) {
  ///   // Show dialog to install Health Connect
  /// }
  /// ```
  Future<bool> _isHealthConnectAvailable() async {
    if (!_isAndroid) return false;

    try {
      final status = await _health.getHealthConnectSdkStatus();
      if (kDebugMode) {
        debugPrint('🏥 [HealthConnect] SDK Status: $status');
      }

      // sdkAvailable means Health Connect is installed and ready
      return status == health_pkg.HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthConnect] Error checking SDK status: $e');
      }
      return false;
    }
  }

  /// Android-specific: Opens Play Store to install Health Connect.
  ///
  /// Call this when [_isHealthConnectAvailable] returns false.
  ///
  /// Example:
  /// ```dart
  /// if (!await _isHealthConnectAvailable()) {
  ///   await installHealthConnect();
  /// }
  /// ```
  @override
  Future<void> installHealthConnect() async {
    if (!_isAndroid) return;

    try {
      await _health.installHealthConnect();
      if (kDebugMode) {
        debugPrint('🏥 [HealthConnect] Opened Play Store for installation');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthConnect] Error opening Play Store: $e');
      }
      rethrow;
    }
  }

  /// Android-specific: Gets detailed Health Connect SDK status.
  ///
  /// Returns one of:
  /// - `sdkAvailable`: Ready to use
  /// - `sdkUnavailable`: Not supported on this device
  /// - `sdkUnavailableProviderUpdateRequired`: Needs update
  ///
  /// iOS returns null.
  Future<health_pkg.HealthConnectSdkStatus?> getHealthConnectStatus() async {
    if (!_isAndroid) return null;

    try {
      return await _health.getHealthConnectSdkStatus();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthConnect] Error getting status: $e');
      }
      return null;
    }
  }

  // ============================================================
  // WORKOUT SYNC IMPLEMENTATION
  // ============================================================

  @override
  Future<List<Map<String, dynamic>>> fetchWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Ensure health package is configured before fetching data
    await _ensureConfigured();

    // Fetch workout data from health platform
    const healthType = health_pkg.HealthDataType.WORKOUT;

    final workoutData = await _health.getHealthDataFromTypes(
      types: [healthType],
      startTime: startDate,
      endTime: endDate,
    );

    // Map HealthDataPoint to workout maps, excluding workouts written by this
    // app to avoid re-importing what GymBro already saved (feedback loop).
    const ownBundleId = 'com.michele.gymbro.flutter';
    final workouts = workoutData
        .where((dataPoint) => !dataPoint.sourceId.startsWith(ownBundleId))
        .map((dataPoint) {
      final healthValue = dataPoint.value;
      final workoutValue = healthValue is health_pkg.WorkoutHealthValue
          ? healthValue
          : null;
      final workoutType =
          workoutValue?.workoutActivityType.name ??
          dataPoint.workoutSummary?.workoutType ??
          'OTHER';
      final calories =
          workoutValue?.totalEnergyBurned ??
          dataPoint.workoutSummary?.totalEnergyBurned;
      final distance =
          workoutValue?.totalDistance ??
          dataPoint.workoutSummary?.totalDistance;
      final steps =
          workoutValue?.totalSteps ?? dataPoint.workoutSummary?.totalSteps;

      return {
        'uuid': dataPoint.uuid,
        'type': workoutType,
        'startTime': dataPoint.dateFrom.toIso8601String(),
        'endTime': dataPoint.dateTo.toIso8601String(),
        'duration': dataPoint.dateTo.difference(dataPoint.dateFrom).inMinutes,
        'calories': calories, // May be null
        'distance': distance,
        'steps': steps,
        'source': _isIOS ? 'HealthKit' : 'Health Connect',
        'sourceId': dataPoint.sourceId,
        'sourceName': dataPoint.sourceName,
        'recordingMethod': dataPoint.recordingMethod.name,
      };
    }).toList();

    return workouts;
  }

  // ============================================================
  // BODY WEIGHT SYNC IMPLEMENTATION
  // ============================================================

  @override
  Future<List<BodyMeasurement>> fetchBodyWeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Ensure health package is configured before fetching data
    await _ensureConfigured();

    const healthType = health_pkg.HealthDataType.WEIGHT;

    final weightData = await _health.getHealthDataFromTypes(
      types: [healthType],
      startTime: startDate,
      endTime: endDate,
    );

    // Map HealthDataPoint to BodyMeasurement
    // health package v13+ returns NumericHealthValue, not raw num
    final measurements = weightData.map((dataPoint) {
      final healthValue = dataPoint.value;
      final weightValue = healthValue is health_pkg.NumericHealthValue
          ? healthValue.numericValue.toDouble()
          : 0.0;

      return BodyMeasurement(
        value: weightValue, // kg from health package
        unit: MeasurementUnit.kilograms,
        recordedAt: dataPoint.dateFrom,
        dataType: HealthDataType.bodyWeight,
        source: _isIOS ? 'HealthKit' : 'Health Connect',
      );
    }).toList();

    return measurements;
  }

  @override
  Future<void> writeBodyWeight(BodyMeasurement measurement) async {
    // Ensure health package is configured before writing data
    await _ensureConfigured();

    // Convert to kilograms if needed (health package expects kg)
    final valueInKg = measurement.unit == MeasurementUnit.kilograms
        ? measurement.value
        : measurement.toKilograms();

    const healthType = health_pkg.HealthDataType.WEIGHT;

    final success = await _health.writeHealthData(
      value: valueInKg,
      type: healthType,
      startTime: measurement.recordedAt,
      endTime: measurement.recordedAt, // Weight is point-in-time
    );

    if (!success) {
      throw Exception('Failed to write body weight to health platform');
    }
  }

  // ============================================================
  // HEIGHT SYNC IMPLEMENTATION
  // ============================================================

  @override
  Future<List<BodyMeasurement>> fetchHeight({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Ensure health package is configured before fetching data
    await _ensureConfigured();

    const healthType = health_pkg.HealthDataType.HEIGHT;

    final heightData = await _health.getHealthDataFromTypes(
      types: [healthType],
      startTime: startDate,
      endTime: endDate,
    );

    // Map HealthDataPoint to BodyMeasurement
    // health package v13+ returns NumericHealthValue, not raw num
    // Height is returned in meters from HealthKit
    final measurements = heightData.map((dataPoint) {
      final healthValue = dataPoint.value;
      final heightValue = healthValue is health_pkg.NumericHealthValue
          ? healthValue.numericValue.toDouble()
          : 0.0;

      return BodyMeasurement(
        value: heightValue, // meters from health package
        unit: MeasurementUnit.meters,
        recordedAt: dataPoint.dateFrom,
        dataType: HealthDataType.height,
        source: _isIOS ? 'HealthKit' : 'Health Connect',
      );
    }).toList();

    return measurements;
  }

  // ============================================================
  // WORKOUT WRITE IMPLEMENTATION
  // ============================================================

  @override
  Future<bool> writeWorkout({
    required DateTime startTime,
    required DateTime endTime,
    int? totalCalories,
    String? workoutName,
  }) async {
    if (kDebugMode) {
      debugPrint('🏥 [HealthKit] writeWorkout called');
      debugPrint('🏥 [HealthKit] Start: $startTime, End: $endTime');
      debugPrint('🏥 [HealthKit] Calories: $totalCalories, Name: $workoutName');
    }

    // Ensure health package is configured before writing data
    await _ensureConfigured();

    try {
      // Write workout to HealthKit/Health Connect
      // Using TRADITIONAL_STRENGTH_TRAINING as the workout type
      // This is the appropriate type for weight training/bodybuilding
      final success = await _health.writeWorkoutData(
        activityType:
            health_pkg.HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
        start: startTime,
        end: endTime,
        totalEnergyBurned: totalCalories,
        totalEnergyBurnedUnit: health_pkg.HealthDataUnit.KILOCALORIE,
      );

      if (kDebugMode) {
        if (success) {
          debugPrint('🏥 [HealthKit] ✅ Workout written successfully');
          debugPrint(
            '🏥 [HealthKit] Workout should now appear in Apple Fitness',
          );
          debugPrint(
            '🏥 [HealthKit] Exercise ring should update with workout duration',
          );
        } else {
          debugPrint('🏥 [HealthKit] ❌ Failed to write workout');
        }
      }

      return success;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('🏥 [HealthKit] ❌ Error writing workout: $e');
        debugPrint('🏥 [HealthKit] Stack: $stack');
      }
      return false;
    }
  }
}
