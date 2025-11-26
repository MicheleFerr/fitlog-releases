import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart' as health_pkg;
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';

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
  /// if (status.canSync(HealthDataType.workout)) {
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
}

/// Implementation of [IHealthRemoteDatasource] using the `health` package.
class HealthRemoteDatasourceImpl implements IHealthRemoteDatasource {
  final health_pkg.Health _health;
  bool _isConfigured = false;

  HealthRemoteDatasourceImpl({health_pkg.Health? health})
      : _health = health ?? health_pkg.Health();

  /// Ensures the health package is configured before use.
  ///
  /// **CRITICAL**: Must be called before any HealthKit/Health Connect operations.
  /// This enables the health package to communicate with the native platform.
  Future<void> _ensureConfigured() async {
    if (_isConfigured) {
      debugPrint('🏥 [HealthKit] Already configured');
      return;
    }

    debugPrint('🏥 [HealthKit] Configuring health package...');
    try {
      // Configure health package for HealthKit (iOS) / Health Connect (Android)
      // useHealthConnectIfAvailable: true enables Health Connect on Android 14+
      await _health.configure();
      _isConfigured = true;
      debugPrint('🏥 [HealthKit] ✅ Configuration successful');
    } catch (e, stack) {
      debugPrint('🏥 [HealthKit] ❌ Configuration failed: $e');
      debugPrint('🏥 [HealthKit] Stack: $stack');
      rethrow;
    }
  }

  /// Maps [HealthDataType] to `health` package's [HealthDataType].
  health_pkg.HealthDataType _mapToHealthPackageType(
    HealthDataType dataType,
  ) {
    switch (dataType) {
      case HealthDataType.workout:
        return health_pkg.HealthDataType.WORKOUT;
      case HealthDataType.bodyWeight:
        return health_pkg.HealthDataType.WEIGHT;
      case HealthDataType.bodyFat:
        return health_pkg.HealthDataType.BODY_FAT_PERCENTAGE;
      case HealthDataType.leanMass:
        return health_pkg.HealthDataType.BODY_MASS_INDEX; // Placeholder - health package limitation
      case HealthDataType.heartRate:
        return health_pkg.HealthDataType.HEART_RATE;
      case HealthDataType.sleep:
        return health_pkg.HealthDataType.SLEEP_ASLEEP; // Sleep in bed
      case HealthDataType.nutrition:
        return health_pkg.HealthDataType.NUTRITION; // Generic nutrition data
    }
  }

  // ============================================================
  // PERMISSION IMPLEMENTATION
  // ============================================================

  @override
  Future<HealthPermissionStatus> requestPermissions({
    required List<HealthDataType> dataTypes,
  }) async {
    debugPrint('🏥 [HealthKit] requestPermissions called for: $dataTypes');

    // Ensure health package is configured before requesting permissions
    await _ensureConfigured();

    // Map domain types to health package types
    final healthTypes = dataTypes
        .map((dt) => _mapToHealthPackageType(dt))
        .toList();

    debugPrint('🏥 [HealthKit] Mapped to health package types: $healthTypes');

    // Request read permissions only (MVP - no write to health platform yet)
    // Workout: Read-only (import from HealthKit/Health Connect)
    // Body weight: Read + Write (bidirectional sync)
    final permissions = dataTypes.map((dt) {
      if (dt == HealthDataType.bodyWeight) {
        return health_pkg.HealthDataAccess.READ_WRITE; // Bidirectional sync
      }
      return health_pkg.HealthDataAccess.READ; // Read-only for workouts
    }).toList();

    debugPrint('🏥 [HealthKit] Requesting permissions: $permissions');
    debugPrint('🏥 [HealthKit] Platform: ${Platform.isIOS ? "iOS" : "Android"}');

    // Request permissions via health package
    try {
      debugPrint('🏥 [HealthKit] Calling _health.requestAuthorization...');
      final result = await _health.requestAuthorization(
        healthTypes,
        permissions: permissions,
      );
      debugPrint('🏥 [HealthKit] requestAuthorization returned: $result');
    } catch (e, stack) {
      debugPrint('🏥 [HealthKit] ❌ requestAuthorization failed: $e');
      debugPrint('🏥 [HealthKit] Stack: $stack');
      rethrow;
    }

    // Check individual permission states
    final permissionStates = <HealthDataType, PermissionState>{};

    for (final dataType in dataTypes) {
      final healthType = _mapToHealthPackageType(dataType);
      final hasPermission = await _health.hasPermissions(
        [healthType],
        permissions: [health_pkg.HealthDataAccess.READ],
      );

      debugPrint('🏥 [HealthKit] hasPermissions for $dataType: $hasPermission');

      if (hasPermission == true) {
        permissionStates[dataType] = PermissionState.authorized;
      } else if (hasPermission == false) {
        permissionStates[dataType] = PermissionState.denied;
      } else {
        // iOS PRIVACY BEHAVIOR: hasPermissions returns null for READ access
        // because Apple doesn't disclose if user denied READ permissions.
        // After successful requestAuthorization, we assume authorized on iOS.
        // The only reliable way to check is to try reading data.
        if (Platform.isIOS) {
          debugPrint('🏥 [HealthKit] iOS: hasPermissions=null, assuming authorized after request');
          permissionStates[dataType] = PermissionState.authorized;
        } else {
          permissionStates[dataType] = PermissionState.notDetermined;
        }
      }
    }

    // Android-specific: Check if Health Connect is installed
    final healthConnectAvailable = Platform.isAndroid
        ? await _isHealthConnectAvailable()
        : false;

    return HealthPermissionStatus(
      permissions: permissionStates,
      healthConnectAvailable: healthConnectAvailable,
    );
  }

  @override
  Future<HealthPermissionStatus> checkPermissionStatus() async {
    debugPrint('🏥 [HealthKit] checkPermissionStatus called');

    // Ensure health package is configured before checking permissions
    await _ensureConfigured();

    // Check all possible data types (7 total)
    const allTypes = HealthDataType.values;
    debugPrint('🏥 [HealthKit] Checking permissions for: $allTypes');

    final permissionStates = <HealthDataType, PermissionState>{};

    for (final dataType in allTypes) {
      final healthType = _mapToHealthPackageType(dataType);
      final hasPermission = await _health.hasPermissions(
        [healthType],
        permissions: [health_pkg.HealthDataAccess.READ],
      );

      debugPrint('🏥 [HealthKit] checkPermissionStatus for $dataType: $hasPermission');

      if (hasPermission == true) {
        permissionStates[dataType] = PermissionState.authorized;
      } else if (hasPermission == false) {
        permissionStates[dataType] = PermissionState.denied;
      } else {
        // iOS PRIVACY BEHAVIOR: hasPermissions returns null for READ access
        // because Apple doesn't disclose if user denied READ permissions.
        // On iOS, we assume authorized and let the actual data fetch determine
        // if permissions were granted. This matches iOS privacy design where
        // the only reliable way to check is to try reading data.
        if (Platform.isIOS) {
          debugPrint('🏥 [HealthKit] iOS: hasPermissions=null for $dataType, assuming authorized');
          permissionStates[dataType] = PermissionState.authorized;
        } else {
          permissionStates[dataType] = PermissionState.notDetermined;
        }
      }
    }

    final healthConnectAvailable = Platform.isAndroid
        ? await _isHealthConnectAvailable()
        : false;

    return HealthPermissionStatus(
      permissions: permissionStates,
      healthConnectAvailable: healthConnectAvailable,
    );
  }

  /// Android-specific: Checks if Health Connect app is installed.
  ///
  /// iOS always returns false (uses native HealthKit).
  Future<bool> _isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return false;

    // The health package automatically checks Health Connect availability
    // when requesting permissions. We can infer availability by checking
    // if any permission can be granted.
    //
    // Alternative: Use a platform channel to check package manager.
    // For MVP, we assume Health Connect is available if on Android 14+.
    return true; // Placeholder - health package handles this internally
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

    // Map HealthDataPoint to workout maps
    final workouts = workoutData.map((dataPoint) {
      // TODO: Extract actual workout type from HealthDataPoint when integrating
      // with workout system. For MVP, use generic type.
      const workoutType = 'GENERIC_WORKOUT';

      // Extract calories if available
      // health package v13+ returns NumericHealthValue, not raw num
      final healthValue = dataPoint.value;
      final calories = healthValue is health_pkg.NumericHealthValue
          ? healthValue.numericValue.toInt()
          : null;

      return {
        'type': workoutType,
        'startTime': dataPoint.dateFrom.toIso8601String(),
        'endTime': dataPoint.dateTo.toIso8601String(),
        'duration': dataPoint.dateTo.difference(dataPoint.dateFrom).inMinutes,
        'calories': calories, // May be null
        'source': Platform.isIOS ? 'HealthKit' : 'Health Connect',
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
        source: Platform.isIOS ? 'HealthKit' : 'Health Connect',
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
}
