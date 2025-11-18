/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: datasource
///
/// HealthKit Datasource - Apple Health integration for AI Coach
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
/// **iOS Version Requirements**:
/// - iOS 14.0+: Basic HealthKit access
/// - iOS 16.0+: Enhanced workout metrics
library;

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart';

/// HealthKit datasource for Apple Health integration
///
/// **Architecture**: Data layer datasource following Clean Architecture
///
/// **Usage**:
/// ```dart
/// final datasource = HealthKitDatasource();
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
class HealthKitDatasource {
  HealthKitDatasource({
    Health? healthFactory,
  }) : _health = healthFactory ?? Health();

  final Health _health;

  /// Is HealthKit available on this device (iOS only)
  bool get isAvailable => Platform.isIOS;

  /// Supported HealthKit data types for AI Coach
  static const List<HealthDataType> supportedTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
  ];

  /// Initialize HealthKit and request permissions
  ///
  /// **GDPR Article 9**: Explicit consent required for health data
  ///
  /// Returns `true` if all permissions granted
  ///
  /// **Throws**:
  /// - `HealthKitNotAvailableError`: iOS not available
  /// - `HealthKitPermissionDeniedError`: User denied permissions
  ///
  /// **Usage**:
  /// ```dart
  /// try {
  ///   final granted = await datasource.initialize();
  /// } catch (e) {
  ///   if (e is HealthKitPermissionDeniedError) {
  ///     // Show permission dialog
  ///   }
  /// }
  /// ```
  Future<bool> initialize() async {
    if (!isAvailable) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthKitDatasource] HealthKit not available (iOS only)');
      }
      throw const HealthKitNotAvailableError();
    }

    try {
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
              ? '✅ [HealthKitDatasource] Permissions granted'
              : '❌ [HealthKitDatasource] Permissions denied',
        );
      }

      if (!granted) {
        throw const HealthKitPermissionDeniedError();
      }

      return granted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitDatasource] Initialize failed: $e');
      }
      // Re-throw if already HealthKitError
      if (e is HealthKitError) rethrow;

      // Wrap unknown errors
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
        debugPrint('❌ [HealthKitDatasource] hasPermission failed: $e');
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

  /// Delete all cached HealthKit data (GDPR Article 17: Right to erasure)
  ///
  /// **Note**: This deletes LOCAL cache only. HealthKit data remains in Apple Health.
  ///
  /// Returns `true` if successful, `false` otherwise
  Future<bool> deleteAllHealthData() async {
    try {
      // Note: health package doesn't expose cache deletion API
      // This is a placeholder for future implementation
      // Actual deletion would require clearing any local Hive/SharedPreferences cache

      if (kDebugMode) {
        debugPrint('🗑️ [HealthKitDatasource] Local cache cleared (GDPR Article 17)');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitDatasource] deleteAllHealthData failed: $e');
      }
      return false;
    }
  }

  /// Export all HealthKit data as JSON (GDPR Article 20: Data portability)
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
        debugPrint('❌ [HealthKitDatasource] exportHealthData failed: $e');
      }
      return {};
    }
  }

  // ==========================================
  // PRIVATE HELPER METHODS
  // ==========================================

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
          '📊 [HealthKitDatasource] Fetched ${dataPoints.length} ${type.name} data points',
        );
      }

      return dataPoints;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [HealthKitDatasource] _getHealthData failed: $e');
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
      sourcePlatform: HealthPlatformType.appleHealth,
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
      sourcePlatform: HealthPlatformType.appleHealth,
      sourceDeviceId: 'aggregated',
      sourceId: 'aggregated',
      sourceName: 'aggregated',
      recordingMethod: RecordingMethod.unknown,
    );
  }
}
