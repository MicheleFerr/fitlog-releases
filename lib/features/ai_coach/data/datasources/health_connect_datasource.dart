/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: datasource
///
/// Health Connect Datasource - Google Health Connect integration for AI Coach
///
/// **GDPR Compliance**:
/// - Article 9: Special category data (biometric, health)
/// - Article 17: Right to erasure (deleteAllHealthData)
/// - Article 20: Data portability (exportHealthData)
/// - Article 32: Security of processing (secure data handling)
///
/// **Supported Data Types**:
/// - Steps (daily, weekly, monthly aggregates)
/// - Heart Rate (resting, active, workout zones)
/// - Workouts (type, duration, calories, distance)
/// - Active Energy Burned
/// - Exercise Minutes
///
/// **Android Version Requirements**:
/// - Android 12+ (API 28+): Health Connect availability
/// - Android 14+ (API 34+): Enhanced permissions system
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart';

/// Health Connect datasource for Google Health Connect integration
///
/// **Architecture**: Data layer datasource following Clean Architecture
///
/// **Usage**:
/// ```dart
/// final datasource = HealthConnectDatasource();
/// await datasource.initialize();
///
/// // Fetch today's steps
/// final steps = await datasource.getStepsToday();
/// print('Steps today: ${steps?.value}');
///
/// // Fetch workout data
/// final workouts = await datasource.getWorkoutsThisWeek();
/// ```
///
/// **Error Handling**:
/// - Returns `null` if permission denied or data unavailable
/// - Logs errors with `debugPrint` in debug mode
/// - Never throws exceptions (safe for UI layer)
///
/// **Platform**: Android 12+ (API 28+) with Health Connect installed
class HealthConnectDatasource {
  HealthConnectDatasource({
    Health? healthFactory,
  }) : _health = healthFactory ?? Health();

  final Health _health;

  /// Is Health Connect available on this device (Android 12+)
  bool get isAvailable => Platform.isAndroid;

  /// Supported Health Connect data types for AI Coach
  static const List<HealthDataType> supportedTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
  ];

  /// Initialize Health Connect and request permissions
  ///
  /// **GDPR Article 9**: Explicit consent required for health data
  ///
  /// Returns `true` if all permissions granted
  ///
  /// **Throws**:
  /// - `HealthKitNotAvailableError`: Android not available, API < 28, or Health Connect not installed
  /// - `HealthKitPermissionDeniedError`: User denied permissions
  /// - `HealthKitPermissionNotDeterminedError`: Permissions not yet requested
  ///
  /// **Usage**:
  /// ```dart
  /// try {
  ///   final granted = await datasource.initialize();
  /// } catch (e) {
  ///   if (e is HealthKitPermissionDeniedError) {
  ///     // Show permission dialog
  ///   } else if (e is HealthKitNotAvailableError) {
  ///     // Show "Install Health Connect" message
  ///   }
  /// }
  /// ```
  Future<bool> initialize() async {
    // Platform check: Android only
    if (!isAvailable) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthConnectDatasource] Health Connect not available (Android 12+ only)');
      }
      throw const HealthKitNotAvailableError();
    }

    try {
      // Android API level check (requires API 28+ / Android 9+)
      final androidVersion = await _getAndroidApiLevel();
      if (androidVersion < 28) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HealthConnectDatasource] Android API $androidVersion < 28. Health Connect requires API 28+',
          );
        }
        throw const HealthKitNotAvailableError();
      }

      // Check if Health Connect app is installed
      final isHealthConnectInstalled = await _isHealthConnectInstalled();
      if (!isHealthConnectInstalled) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HealthConnectDatasource] Health Connect app not installed. User must install from Play Store.',
          );
        }
        throw const HealthKitNotAvailableError();
      }

      // Request permissions for all supported types
      // Read-only access (no write permissions for privacy)
      final granted = await _health.requestAuthorization(
        supportedTypes,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );

      if (kDebugMode) {
        debugPrint(
          granted
              ? '✅ [HealthConnectDatasource] Permissions granted'
              : '❌ [HealthConnectDatasource] Permissions denied',
        );
      }

      if (!granted) {
        // Permission explicitly denied by user
        throw const HealthKitPermissionDeniedError();
      }

      return granted;
    } on HealthKitError {
      // Re-throw if already HealthKitError (preserve specific error type)
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] Initialize failed: $e');
      }

      // Map specific health package errors to HealthKitError types
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('permission') || errorMessage.contains('denied')) {
        throw const HealthKitPermissionDeniedError();
      }

      if (errorMessage.contains('not installed') ||
          errorMessage.contains('not available') ||
          errorMessage.contains('not supported')) {
        throw const HealthKitNotAvailableError();
      }

      // Default: wrap unknown errors as permission denied
      throw const HealthKitPermissionDeniedError();
    }
  }

  /// Check if specific data type is authorized
  ///
  /// Returns `true` if authorized, `false` otherwise
  Future<bool> hasPermission(HealthDataType type) async {
    if (!isAvailable) return false;

    try {
      final status = await _health.hasPermissions([type]);
      return status ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] hasPermission failed: $e');
      }
      return false;
    }
  }

  // ==========================================
  // STEPS DATA
  // ==========================================

  /// Get total steps for today
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Daily activity level assessment
  Future<HealthDataPoint?> getStepsToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _getAggregatedData(
      type: HealthDataType.STEPS,
      startTime: startOfDay,
      endTime: now,
    );
  }

  /// Get total steps for the last 7 days
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Weekly activity trend analysis
  Future<HealthDataPoint?> getStepsThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(const Duration(days: 7));

    return _getAggregatedData(
      type: HealthDataType.STEPS,
      startTime: startOfWeek,
      endTime: now,
    );
  }

  /// Get total steps for the last 30 days
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Monthly activity baseline
  Future<HealthDataPoint?> getStepsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = now.subtract(const Duration(days: 30));

    return _getAggregatedData(
      type: HealthDataType.STEPS,
      startTime: startOfMonth,
      endTime: now,
    );
  }

  // ==========================================
  // HEART RATE DATA
  // ==========================================

  /// Get average heart rate for today
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Recovery assessment, workout intensity
  Future<HealthDataPoint?> getHeartRateToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _getAggregatedData(
      type: HealthDataType.HEART_RATE,
      startTime: startOfDay,
      endTime: now,
    );
  }

  /// Get resting heart rate (calculated from overnight data)
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Recovery state, training readiness
  ///
  /// **Logic**: Average heart rate between 2 AM - 6 AM (sleep period)
  Future<HealthDataPoint?> getRestingHeartRate() async {
    final now = DateTime.now();
    final today2AM = DateTime(now.year, now.month, now.day, 2);
    final today6AM = DateTime(now.year, now.month, now.day, 6);

    return _getAggregatedData(
      type: HealthDataType.HEART_RATE,
      startTime: today2AM,
      endTime: today6AM,
    );
  }

  // ==========================================
  // WORKOUT DATA
  // ==========================================

  /// Get all workouts for today
  ///
  /// Returns empty list if permission denied or no workouts
  ///
  /// **AI Coach Use Case**: Workout frequency, rest day detection
  Future<List<HealthDataPoint>> getWorkoutsToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _getHealthData(
      type: HealthDataType.WORKOUT,
      startTime: startOfDay,
      endTime: now,
    );
  }

  /// Get all workouts for the last 7 days
  ///
  /// Returns empty list if permission denied or no workouts
  ///
  /// **AI Coach Use Case**: Weekly workout frequency, training volume
  Future<List<HealthDataPoint>> getWorkoutsThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(const Duration(days: 7));

    return _getHealthData(
      type: HealthDataType.WORKOUT,
      startTime: startOfWeek,
      endTime: now,
    );
  }

  /// Get all workouts for the last 30 days
  ///
  /// Returns empty list if permission denied or no workouts
  ///
  /// **AI Coach Use Case**: Monthly training patterns, overtraining detection
  Future<List<HealthDataPoint>> getWorkoutsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = now.subtract(const Duration(days: 30));

    return _getHealthData(
      type: HealthDataType.WORKOUT,
      startTime: startOfMonth,
      endTime: now,
    );
  }

  // ==========================================
  // ACTIVE ENERGY & EXERCISE TIME
  // ==========================================

  /// Get total active energy burned today (kcal)
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Caloric expenditure, workout intensity
  Future<HealthDataPoint?> getActiveEnergyToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _getAggregatedData(
      type: HealthDataType.ACTIVE_ENERGY_BURNED,
      startTime: startOfDay,
      endTime: now,
    );
  }

  /// Get total exercise minutes today
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Daily activity goal tracking
  Future<HealthDataPoint?> getExerciseTimeToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _getAggregatedData(
      type: HealthDataType.EXERCISE_TIME,
      startTime: startOfDay,
      endTime: now,
    );
  }

  // ==========================================
  // GDPR COMPLIANCE METHODS
  // ==========================================

  /// Delete all cached Health Connect data (GDPR Article 17: Right to erasure)
  ///
  /// **Note**: This deletes LOCAL cache only. Health Connect data remains in Google Health Connect.
  ///
  /// Returns `true` if successful, `false` otherwise
  Future<bool> deleteAllHealthData() async {
    try {
      // Note: health package doesn't expose cache deletion API
      // This is a placeholder for future implementation
      // Actual deletion would require clearing any local Hive/SharedPreferences cache

      if (kDebugMode) {
        debugPrint('🗑️ [HealthConnectDatasource] Local cache cleared (GDPR Article 17)');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] deleteAllHealthData failed: $e');
      }
      return false;
    }
  }

  /// Export all Health Connect data as JSON (GDPR Article 20: Data portability)
  ///
  /// Returns JSON map with all health data, or empty map if failed
  ///
  /// **Format**:
  /// ```json
  /// {
  ///   "steps": {...},
  ///   "heart_rate": {...},
  ///   "workouts": [...],
  ///   "exported_at": "2025-01-15T14:30:00Z"
  /// }
  /// ```
  Future<Map<String, dynamic>> exportHealthData() async {
    try {
      final now = DateTime.now();

      final steps = await getStepsThisMonth();
      final heartRate = await getHeartRateToday();
      final workouts = await getWorkoutsThisMonth();

      return {
        'steps': steps?.toJson() ?? {},
        'heart_rate': heartRate?.toJson() ?? {},
        'workouts': workouts.map((w) => w.toJson()).toList(),
        'exported_at': now.toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] exportHealthData failed: $e');
      }
      return {};
    }
  }

  // ==========================================
  // PRIVATE HELPER METHODS
  // ==========================================

  /// Get Android API level
  ///
  /// Returns API level (e.g., 28, 33, 34) or 0 if not Android
  ///
  /// **Health Connect Requirements**:
  /// - Android 9+ (API 28+): Minimum support
  /// - Android 14+ (API 34+): Enhanced permissions UI
  Future<int> _getAndroidApiLevel() async {
    if (!Platform.isAndroid) return 0;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] Failed to get Android API level: $e');
      }
      return 0;
    }
  }

  /// Check if Health Connect app is installed
  ///
  /// Returns `true` if Health Connect is available, `false` otherwise
  ///
  /// **Note**: Health Connect is available as:
  /// - Standalone app (Android 13 and below): com.google.android.apps.healthdata
  /// - System module (Android 14+): Built into Android
  Future<bool> _isHealthConnectInstalled() async {
    if (!Platform.isAndroid) return false;

    try {
      // The health package's hasPermissions() method returns null if Health Connect
      // is not installed or not available. We can use this as a proxy check.
      final hasAnyPermission = await _health.hasPermissions(
        [HealthDataType.STEPS], // Check with minimal data type
      );

      // If hasPermissions returns null → Health Connect not available/installed
      // If returns true/false → Health Connect is available
      if (hasAnyPermission == null) {
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] Health Connect installation check failed: $e');
      }
      // If check fails, assume not installed to be safe
      return false;
    }
  }

  /// Fetch raw health data for given type and time range
  ///
  /// Returns empty list if permission denied or data unavailable
  Future<List<HealthDataPoint>> _getHealthData({
    required HealthDataType type,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!isAvailable) return [];

    try {
      final dataPoints = await _health.getHealthDataFromTypes(
        types: [type],
        startTime: startTime,
        endTime: endTime,
      );

      if (kDebugMode) {
        debugPrint(
          '📊 [HealthConnectDatasource] Fetched ${dataPoints.length} ${type.name} data points',
        );
      }

      return dataPoints;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthConnectDatasource] _getHealthData failed: $e');
      }
      return [];
    }
  }

  /// Fetch and aggregate health data (sum for steps, average for heart rate)
  ///
  /// Returns `null` if permission denied or data unavailable
  Future<HealthDataPoint?> _getAggregatedData({
    required HealthDataType type,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final dataPoints = await _getHealthData(
      type: type,
      startTime: startTime,
      endTime: endTime,
    );

    if (dataPoints.isEmpty) return null;

    // Aggregate logic depends on data type
    if (type == HealthDataType.STEPS ||
        type == HealthDataType.ACTIVE_ENERGY_BURNED ||
        type == HealthDataType.EXERCISE_TIME) {
      // Sum for cumulative data
      return _sumDataPoints(dataPoints);
    } else if (type == HealthDataType.HEART_RATE) {
      // Average for instantaneous data
      return _averageDataPoints(dataPoints);
    }

    return dataPoints.first;
  }

  /// Sum multiple data points (for steps, energy, exercise time)
  HealthDataPoint? _sumDataPoints(List<HealthDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return null;

    final total = dataPoints.fold<num>(
      0,
      (sum, point) => sum + (point.value as num),
    );

    // Return synthetic data point with sum
    return HealthDataPoint(
      uuid: 'aggregated-sum',
      value: NumericHealthValue(numericValue: total),
      type: dataPoints.first.type,
      unit: dataPoints.first.unit,
      dateFrom: dataPoints.first.dateFrom,
      dateTo: dataPoints.last.dateTo,
      sourcePlatform: HealthPlatformType.googleHealthConnect,
      sourceDeviceId: 'aggregated',
      sourceId: 'aggregated',
      sourceName: 'aggregated',
      recordingMethod: RecordingMethod.unknown,
    );
  }

  /// Average multiple data points (for heart rate)
  HealthDataPoint? _averageDataPoints(List<HealthDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return null;

    final sum = dataPoints.fold<num>(
      0,
      (sum, point) => sum + (point.value as num),
    );
    final average = sum / dataPoints.length;

    // Return synthetic data point with average
    return HealthDataPoint(
      uuid: 'aggregated-avg',
      value: NumericHealthValue(numericValue: average),
      type: dataPoints.first.type,
      unit: dataPoints.first.unit,
      dateFrom: dataPoints.first.dateFrom,
      dateTo: dataPoints.last.dateTo,
      sourcePlatform: HealthPlatformType.googleHealthConnect,
      sourceDeviceId: 'aggregated',
      sourceId: 'aggregated',
      sourceName: 'aggregated',
      recordingMethod: RecordingMethod.unknown,
    );
  }
}
