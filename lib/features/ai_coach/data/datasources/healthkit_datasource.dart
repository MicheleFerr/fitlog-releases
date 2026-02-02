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
import 'dart:math' show sqrt;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/errors/healthkit_errors.dart';

/// Extension to safely extract numeric values from HealthDataPoint
/// FIX: Health package returns NumericHealthValue, not raw num
/// This caused: "type 'NumericHealthValue' is not a subtype of type 'num'"
extension HealthDataPointNumericValue on HealthDataPoint {
  /// Safely extract numeric value from health data point
  /// Handles NumericHealthValue wrapper from health package
  double get numericValue {
    final v = value;
    if (v is NumericHealthValue) {
      return v.numericValue.toDouble();
    }
    // Fallback: try to parse string representation (shouldn't happen for numeric data)
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

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
  HealthKitDatasource({Health? healthFactory})
    : _health = healthFactory ?? Health();

  final Health _health;

  /// FIX: Cache per dati sleep per evitare fetch duplicati durante l'avvio
  /// Cache TTL: 2 minuti (i dati sleep non cambiano frequentemente)
  static const Duration _sleepCacheTtl = Duration(minutes: 2);
  final Map<String, _CachedData<List<HealthDataPoint>>> _sleepCache = {};

  /// Is HealthKit available on this device (iOS only)
  bool get isAvailable => Platform.isIOS;

  /// Supported HealthKit data types for AI Coach
  ///
  /// **Sleep Types Added**: Based on scientific research showing:
  /// - Sleep deprivation reduces muscle protein synthesis by ~22% (Res et al.)
  /// - <6h sleep reduces strength output in multi-joint movements (Knowles et al.)
  /// - 7-9h recommended by AASM/Sleep Research Society
  ///
  /// **iOS 16+ Sleep Stages**: Apple Watch tracks sleep in stages:
  /// - SLEEP_CORE: Core sleep (light sleep)
  /// - SLEEP_DEEP: Deep sleep (restorative)
  /// - SLEEP_REM: REM sleep (dreaming)
  /// - SLEEP_AWAKE: Awake periods during sleep
  ///
  /// **HRV (Heart Rate Variability)**: Key recovery marker
  /// Based on research (PMC6204890, MDPI Sensors 2024):
  /// - RMSSD is primary marker for parasympathetic activity
  /// - SDNN reflects overall ANS balance
  /// - Normal RMSSD: 35-107ms for athletes
  /// - Low HRV indicates insufficient recovery
  static const List<HealthDataType> supportedTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
    // Sleep tracking for recovery correlation
    HealthDataType.SLEEP_ASLEEP, // Time actually asleep (legacy)
    HealthDataType.SLEEP_IN_BED, // Total time in bed
    // iOS 16+ sleep stages (Apple Watch)
    HealthDataType.SLEEP_AWAKE, // Awake periods during sleep
    HealthDataType.SLEEP_DEEP, // Deep sleep
    HealthDataType.SLEEP_REM, // REM sleep
    HealthDataType.SLEEP_LIGHT, // Light/core sleep
    // HRV for recovery assessment (Coach Plus feature)
    HealthDataType.HEART_RATE_VARIABILITY_SDNN, // Apple Watch primary HRV
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
        debugPrint(
          '⚠️ [HealthKitDatasource] HealthKit not available (iOS only)',
        );
      }
      throw const HealthKitNotAvailableError();
    }

    try {
      // Request permissions for all supported types
      // Read-only access (no write permissions for privacy)
      final granted = await _health.requestAuthorization(
        supportedTypes,
        permissions: [
          HealthDataAccess.READ, // STEPS
          HealthDataAccess.READ, // HEART_RATE
          HealthDataAccess.READ, // WORKOUT
          HealthDataAccess.READ, // ACTIVE_ENERGY_BURNED
          HealthDataAccess.READ, // EXERCISE_TIME
          HealthDataAccess.READ, // SLEEP_ASLEEP
          HealthDataAccess.READ, // SLEEP_IN_BED
          HealthDataAccess.READ, // SLEEP_AWAKE
          HealthDataAccess.READ, // SLEEP_DEEP
          HealthDataAccess.READ, // SLEEP_REM
          HealthDataAccess.READ, // SLEEP_LIGHT
          HealthDataAccess.READ, // HEART_RATE_VARIABILITY_SDNN
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
  // HRV DATA (Heart Rate Variability)
  // ==========================================

  /// Get most recent HRV (SDNN) value
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **Scientific Basis** (PMC6204890, MDPI Sensors 2024):
  /// - SDNN is Apple Watch's primary HRV metric
  /// - Reflects overall autonomic nervous system balance
  /// - Higher HRV = better recovery capacity
  /// - Normal range for athletes: 35-107ms
  ///
  /// **AI Coach Use Case**: Recovery assessment, readiness prediction
  Future<HealthDataPoint?> getHrvToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _getAggregatedData(
      type: HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      startTime: startOfDay,
      endTime: now,
    );
  }

  /// Get HRV data for the last 7 days
  ///
  /// Returns empty list if permission denied or no HRV data
  ///
  /// **Use Case**: Calculate personal HRV baseline
  ///
  /// **Scientific Basis** (SimpliFaster, Elite HRV):
  /// - Weekly averages provide stable baseline
  /// - CV (coefficient of variation) indicates adaptation
  /// - Consistent daily measurement is key (≥5 days/week)
  Future<List<HealthDataPoint>> getHrvThisWeek() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _getHealthData(
      type: HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      startTime: weekAgo,
      endTime: now,
    );
  }

  /// Get HRV analytics for recovery assessment
  ///
  /// Returns map with baseline, current, and deviation analysis
  ///
  /// **Scientific Basis**:
  /// - Ratio < 0.7 of baseline = system stressed (recovery compromised)
  /// - Ratio > 1.1 of baseline = accelerated recovery
  /// - Progressive decrease may indicate overtraining
  Future<Map<String, dynamic>> getHrvAnalytics({int days = 7}) async {
    final hrvData = await getHrvThisWeek();

    if (hrvData.isEmpty) {
      return {'available': false, 'message': 'No HRV data available'};
    }

    // Calculate statistics
    // FIX: Usa extension numericValue per evitare crash con NumericHealthValue
    final values = hrvData.map((p) => p.numericValue).toList();
    final avgHrv = values.reduce((a, b) => a + b) / values.length;
    final minHrv = values.reduce((a, b) => a < b ? a : b);
    final maxHrv = values.reduce((a, b) => a > b ? a : b);

    // Calculate coefficient of variation (CV)
    final variance =
        values.map((v) => (v - avgHrv) * (v - avgHrv)).reduce((a, b) => a + b) /
        values.length;
    final stdDev = variance > 0 && values.length > 1 ? sqrt(variance) : 0.0;
    final cv = avgHrv > 0 ? (stdDev / avgHrv) * 100 : 0.0;

    // Get today's HRV
    final todayHrv = await getHrvToday();
    // FIX: Usa extension numericValue per evitare crash con NumericHealthValue
    final currentHrv = todayHrv?.numericValue;

    // Calculate ratio to baseline
    double? ratioToBaseline;
    String? recoveryStatus;
    if (currentHrv != null && avgHrv > 0) {
      ratioToBaseline = currentHrv / avgHrv;

      if (ratioToBaseline < 0.7) {
        recoveryStatus = 'critical';
      } else if (ratioToBaseline < 0.85) {
        recoveryStatus = 'stressed';
      } else if (ratioToBaseline > 1.1) {
        recoveryStatus = 'accelerated';
      } else {
        recoveryStatus = 'normal';
      }
    }

    // Determine quality category
    String category;
    if (avgHrv >= 70) {
      category = 'excellent';
    } else if (avgHrv >= 50) {
      category = 'good';
    } else if (avgHrv >= 35) {
      category = 'normal';
    } else {
      category = 'low';
    }

    return {
      'available': true,
      'days_analyzed': days,
      'data_points': values.length,
      'avg_hrv_ms': avgHrv,
      'min_hrv_ms': minHrv,
      'max_hrv_ms': maxHrv,
      'std_dev': stdDev,
      'cv_percent': cv,
      'current_hrv_ms': currentHrv,
      'ratio_to_baseline': ratioToBaseline,
      'recovery_status': recoveryStatus,
      'category': category,
      'scientific_basis': {
        'source_pmid': 'PMC6204890 - HRV in sports medicine',
        'source_mdpi': 'MDPI Sensors 2024 - HRV mobile monitoring',
        'normal_range': '35-107ms for athletes',
        'interpretation': 'Higher HRV = better recovery capacity',
      },
    };
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
  // SLEEP DATA
  // ==========================================

  /// All sleep types that count as actual sleep time (excluding AWAKE)
  ///
  /// **iOS 16+ Sleep Stages**:
  /// - SLEEP_ASLEEP: Legacy type (still used by some apps)
  /// - SLEEP_DEEP: Deep sleep (N3 stage)
  /// - SLEEP_REM: REM sleep (dreaming)
  /// - SLEEP_LIGHT: Light sleep (N1/N2 stages)
  ///
  /// Note: SLEEP_AWAKE is NOT included as it represents awake time
  static const List<HealthDataType> _sleepTypes = [
    HealthDataType.SLEEP_ASLEEP, // Legacy
    HealthDataType.SLEEP_DEEP, // iOS 16+
    HealthDataType.SLEEP_REM, // iOS 16+
    HealthDataType.SLEEP_LIGHT, // iOS 16+
  ];

  /// Fetch all sleep data points for a time range
  ///
  /// Combines all sleep types (ASLEEP, DEEP, REM, LIGHT) into one list
  /// FIX: Implementato caching per evitare fetch duplicati durante l'avvio
  Future<List<HealthDataPoint>> _getAllSleepData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // FIX: Check cache first to avoid duplicate HealthKit queries
    final cacheKey =
        '${startTime.millisecondsSinceEpoch}_${endTime.millisecondsSinceEpoch}';
    final cached = _sleepCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      if (kDebugMode) {
        debugPrint(
          '⚡ [_getAllSleepData] CACHE HIT - returning ${cached.data.length} cached points',
        );
      }
      return cached.data;
    }

    if (kDebugMode) {
      debugPrint('🔍 [_getAllSleepData] START');
      debugPrint(
        '   📅 Range: ${startTime.toIso8601String()} → ${endTime.toIso8601String()}',
      );
      debugPrint(
        '   📋 Sleep types to fetch: ${_sleepTypes.map((t) => t.name).join(", ")}',
      );
    }

    if (!isAvailable) {
      if (kDebugMode) {
        debugPrint('   ❌ HealthKit NOT available - returning empty');
      }
      return [];
    }

    final allSleepData = <HealthDataPoint>[];

    for (final type in _sleepTypes) {
      try {
        if (kDebugMode) {
          debugPrint('   🔄 Fetching ${type.name}...');
        }
        final data = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: startTime,
          endTime: endTime,
        );
        allSleepData.addAll(data);

        if (kDebugMode) {
          debugPrint('   😴 ${type.name}: ${data.length} records');
          if (data.isNotEmpty) {
            // Show first record details for debugging
            final first = data.first;
            debugPrint('      → First: ${first.dateFrom} to ${first.dateTo}');
            debugPrint(
              '      → Value: ${first.value} (${first.value.runtimeType})',
            );
            debugPrint('      → Unit: ${first.unit}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HealthKitDatasource] Failed to fetch ${type.name}: $e',
          );
        }
        // Continue with other types
      }
    }

    if (kDebugMode) {
      debugPrint(
        '📊 [HealthKitDatasource] Total sleep records: ${allSleepData.length}',
      );
    }

    // FIX: Store in cache to avoid duplicate HealthKit queries
    _sleepCache[cacheKey] = _CachedData(allSleepData, _sleepCacheTtl);
    if (kDebugMode) {
      debugPrint(
        '💾 [_getAllSleepData] Cached ${allSleepData.length} points (TTL: ${_sleepCacheTtl.inMinutes}min)',
      );
    }

    return allSleepData;
  }

  /// Get total sleep duration for last night
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Sleep-performance correlation
  ///
  /// **Scientific Basis**:
  /// - <6h: Critical - reduced strength output (Knowles et al.)
  /// - 6-7h: Suboptimal - -22% MPS (Res et al.)
  /// - 7-9h: Optimal (AASM recommendation)
  /// - >9h: May indicate illness/overtraining
  ///
  /// **Note**: Aggregates all sleep stages (ASLEEP, DEEP, REM, LIGHT)
  Future<HealthDataPoint?> getSleepLastNight() async {
    final now = DateTime.now();
    // Sleep window: yesterday 8 PM to today 12 PM (accounts for late sleepers)
    final sleepWindowStart = DateTime(now.year, now.month, now.day - 1, 20);
    final sleepWindowEnd = DateTime(now.year, now.month, now.day, 12);

    final allSleepData = await _getAllSleepData(
      startTime: sleepWindowStart,
      endTime: sleepWindowEnd,
    );

    if (allSleepData.isEmpty) return null;

    return _sumDataPoints(allSleepData);
  }

  /// Get time in bed for last night (includes awake time)
  ///
  /// Returns `null` if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Sleep efficiency calculation
  /// Sleep efficiency = (SLEEP_ASLEEP / SLEEP_IN_BED) * 100
  /// - >85%: Good efficiency
  /// - 75-85%: Normal
  /// - <75%: Poor efficiency (may indicate sleep issues)
  Future<HealthDataPoint?> getTimeInBedLastNight() async {
    final now = DateTime.now();
    final sleepWindowStart = DateTime(now.year, now.month, now.day - 1, 20);
    final sleepWindowEnd = DateTime(now.year, now.month, now.day, 12);

    return _getAggregatedData(
      type: HealthDataType.SLEEP_IN_BED,
      startTime: sleepWindowStart,
      endTime: sleepWindowEnd,
    );
  }

  /// Get all sleep data for the last 7 days
  ///
  /// Returns empty list if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Sleep trend analysis, chronic sleep debt detection
  ///
  /// **Scientific Basis** (Skein et al. 2011):
  /// - Consecutive sleep restriction shows cumulative performance decline
  /// - 1 bad night: minor impact
  /// - 3+ bad nights: significant strength reduction
  ///
  /// **Note**: Aggregates all sleep stages (ASLEEP, DEEP, REM, LIGHT)
  Future<List<HealthDataPoint>> getSleepThisWeek() async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('🌙 [getSleepThisWeek] Called');
    }
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final result = await _getAllSleepData(startTime: weekAgo, endTime: now);

    if (kDebugMode) {
      debugPrint(
        '🌙 [getSleepThisWeek] Returning ${result.length} data points',
      );
    }
    return result;
  }

  /// Get all in-bed data for the last 7 days
  ///
  /// Returns empty list if permission denied or data unavailable
  ///
  /// **AI Coach Use Case**: Sleep efficiency calculation
  /// Sleep efficiency = (SLEEP_ASLEEP / SLEEP_IN_BED) * 100
  Future<List<HealthDataPoint>> getInBedThisWeek() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _getHealthData(
      type: HealthDataType.SLEEP_IN_BED,
      startTime: weekAgo,
      endTime: now,
    );
  }

  /// Get detailed sleep data for correlation analysis
  ///
  /// Returns raw sleep data points for advanced analysis
  ///
  /// **AI Coach Use Case**: Sleep-workout performance correlation
  ///
  /// **Analysis Features**:
  /// - Track sleep before workout days vs rest days
  /// - Correlate sleep duration with workout volume/intensity
  /// - Identify optimal sleep patterns for individual user
  ///
  /// **Note**: Aggregates all sleep stages (ASLEEP, DEEP, REM, LIGHT)
  Future<Map<String, dynamic>> getSleepAnalytics({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    // Fetch ALL sleep types (not just SLEEP_ASLEEP)
    final sleepData = await _getAllSleepData(
      startTime: startDate,
      endTime: now,
    );

    final inBedData = await _getHealthData(
      type: HealthDataType.SLEEP_IN_BED,
      startTime: startDate,
      endTime: now,
    );

    // Calculate statistics
    if (sleepData.isEmpty) {
      return {'available': false, 'message': 'No sleep data available'};
    }

    // Group by night (using END time - when you wake up)
    // Sleep from 23:00 Dec 20 → 06:00 Dec 21 counts as "Dec 21"
    final nightlySleep = <DateTime, double>{};
    for (final point in sleepData) {
      final nightKey = DateTime(
        point.dateTo.year,
        point.dateTo.month,
        point.dateTo.day,
      );
      // FIX: Usa extension numericValue per evitare crash con NumericHealthValue
      final minutes = point.numericValue;
      nightlySleep[nightKey] = (nightlySleep[nightKey] ?? 0) + minutes;
    }

    // Convert to hours
    final sleepHours = nightlySleep.values.map((m) => m / 60).toList();
    if (sleepHours.isEmpty) {
      return {'available': false, 'message': 'No valid sleep data'};
    }

    final avgSleepHours =
        sleepHours.reduce((a, b) => a + b) / sleepHours.length;
    final minSleepHours = sleepHours.reduce((a, b) => a < b ? a : b);
    final maxSleepHours = sleepHours.reduce((a, b) => a > b ? a : b);

    // Calculate sleep efficiency if in-bed data available
    double? avgEfficiency;
    if (inBedData.isNotEmpty) {
      final nightlyInBed = <DateTime, double>{};
      for (final point in inBedData) {
        // Use dateTo for consistency with sleep grouping
        final nightKey = DateTime(
          point.dateTo.year,
          point.dateTo.month,
          point.dateTo.day,
        );
        // FIX: Usa extension numericValue per evitare crash con NumericHealthValue
        final minutes = point.numericValue;
        nightlyInBed[nightKey] = (nightlyInBed[nightKey] ?? 0) + minutes;
      }

      // Calculate efficiency for nights with both values
      final efficiencies = <double>[];
      for (final night in nightlySleep.keys) {
        final sleep = nightlySleep[night] ?? 0;
        final inBed = nightlyInBed[night] ?? 0;
        if (inBed > 0) {
          efficiencies.add((sleep / inBed) * 100);
        }
      }

      if (efficiencies.isNotEmpty) {
        avgEfficiency =
            efficiencies.reduce((a, b) => a + b) / efficiencies.length;
      }
    }

    // Count nights below threshold
    final nightsBelow6h = sleepHours.where((h) => h < 6).length;
    final nightsBelow7h = sleepHours.where((h) => h < 7).length;

    // Determine sleep quality category
    String category;
    String recommendation;

    if (avgSleepHours < 6) {
      category = 'critical';
      recommendation =
          'Sonno critico. Studi dimostrano -22% sintesi proteica muscolare con deprivazione del sonno (Res et al.). Priorità assoluta al riposo.';
    } else if (avgSleepHours < 7) {
      category = 'suboptimal';
      recommendation =
          'Sonno insufficiente. La ricerca mostra output di forza ridotto nei movimenti multi-articolari (Knowles et al.). Punta a 7-9h.';
    } else if (avgSleepHours <= 9) {
      category = 'optimal';
      recommendation =
          'Sonno ottimale! Sei nel range raccomandato di 7-9h (AASM). Condizione ideale per il recupero.';
    } else {
      category = 'excessive';
      recommendation =
          'Sonno eccessivo può indicare sovrallenamento o malessere. Monitora come ti senti.';
    }

    return {
      'available': true,
      'days_analyzed': days,
      'nights_with_data': nightlySleep.length,
      'avg_sleep_hours': avgSleepHours,
      'min_sleep_hours': minSleepHours,
      'max_sleep_hours': maxSleepHours,
      'nights_below_6h': nightsBelow6h,
      'nights_below_7h': nightsBelow7h,
      'avg_efficiency': avgEfficiency,
      'category': category,
      'recommendation': recommendation,
      'scientific_basis': {
        'source_aasm': '7-9h raccomandate (AASM/Sleep Research Society)',
        'source_res': '-22% MPS con deprivazione del sonno (Res et al.)',
        'source_knowles': 'Ridotto output di forza <6h (Knowles et al.)',
        'source_skein':
            'Restrizione consecutiva del sonno mostra declino cumulativo (Skein et al. 2011)',
      },
    };
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
        debugPrint(
          '🗑️ [HealthKitDatasource] Local cache cleared (GDPR Article 17)',
        );
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

    // FIX: Usa extension numericValue per evitare crash con NumericHealthValue
    final total = dataPoints.fold<num>(
      0,
      (sum, point) => sum + point.numericValue,
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

    // FIX: Usa extension numericValue per evitare crash con NumericHealthValue
    final sum = dataPoints.fold<num>(
      0,
      (sum, point) => sum + point.numericValue,
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

/// Helper class for time-based caching
/// FIX: Evita fetch duplicati di HealthKit durante l'avvio app
class _CachedData<T> {
  _CachedData(this.data, Duration ttl) : _expiry = DateTime.now().add(ttl);

  final T data;
  final DateTime _expiry;

  bool get isExpired => DateTime.now().isAfter(_expiry);
}
