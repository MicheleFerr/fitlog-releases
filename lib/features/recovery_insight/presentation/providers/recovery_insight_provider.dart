/// Recovery Insight Provider
///
/// Riverpod providers for the Recovery Insight feature.
///
/// **Provides**:
/// - Sleep data from HealthKit/Health Connect
/// - Recovery score calculation
/// - Sleep-workout correlation (Pro)
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart' show NumericHealthValue;
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/healthkit_datasource.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/services/sleep_workout_correlation_service.dart';

// ==========================================
// SERVICE PROVIDERS
// ==========================================

/// Provider for HealthKitDatasource
/// FIX: keepAlive() previene ricreazione che causava fetch duplicati di sleep data
final healthKitDatasourceProvider = Provider<HealthKitDatasource>((ref) {
  ref.keepAlive(); // Previene ricreazione e mantiene cache interna
  return HealthKitDatasource();
});

/// Provider for SleepWorkoutCorrelationService
final sleepWorkoutCorrelationServiceProvider =
    Provider<SleepWorkoutCorrelationService>((ref) {
      return SleepWorkoutCorrelationService();
    });

// ==========================================
// DATA PROVIDERS
// ==========================================

/// Provider for sleep analytics data from HealthKit
///
/// Returns raw sleep analytics including:
/// - Average sleep hours
/// - Sleep efficiency
/// - Nights below thresholds
/// - Recommendations
final sleepAnalyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async {
    final datasource = ref.watch(healthKitDatasourceProvider);

    // Check if HealthKit is available (iOS only)
    if (!datasource.isAvailable) {
      return {
        'available': false,
        'message': 'HealthKit non disponibile su questo dispositivo',
      };
    }

    try {
      // Initialize HealthKit (request permissions if needed)
      await datasource.initialize();

      // Get sleep analytics for last 7 days
      final analytics = await datasource.getSleepAnalytics(days: 7);

      if (kDebugMode) {
        debugPrint('[SleepAnalytics] Fetched: $analytics');
      }

      return analytics;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SleepAnalytics] Error: $e');
      }
      return {
        'available': false,
        'message': 'Errore nel recupero dati sonno: $e',
      };
    }
  },
);

/// Provider for sleep records (last 7 days)
///
/// Converts raw HealthKit data to SleepRecord entities
final sleepRecordsProvider = FutureProvider.autoDispose<List<SleepRecord>>((
  ref,
) async {
  if (kDebugMode) {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint('║  🔍 SLEEP RECORDS PROVIDER - DEBUG TRACE                 ║');
    debugPrint('╚══════════════════════════════════════════════════════════╝');
  }

  final datasource = ref.watch(healthKitDatasourceProvider);

  // Check if HealthKit is available (iOS only)
  if (!datasource.isAvailable) {
    if (kDebugMode) {
      debugPrint('❌ [SleepRecords] HealthKit NOT available - STOPPING');
    }
    return [];
  }
  if (kDebugMode) {
    debugPrint('✅ [SleepRecords] Step 1: HealthKit is available');
  }

  try {
    // Initialize HealthKit (request permissions if needed)
    if (kDebugMode) {
      debugPrint(
        '🔄 [SleepRecords] Step 2: Calling datasource.initialize()...',
      );
    }
    await datasource.initialize();
    if (kDebugMode) {
      debugPrint('✅ [SleepRecords] Step 2: Initialize completed');
    }

    // Fetch raw sleep data for last 7 days
    if (kDebugMode) {
      debugPrint(
        '🔄 [SleepRecords] Step 3: Calling datasource.getSleepThisWeek()...',
      );
    }
    final sleepData = await datasource.getSleepThisWeek();
    if (kDebugMode) {
      debugPrint(
        '📊 [SleepRecords] Step 3: getSleepThisWeek() returned ${sleepData.length} data points',
      );
      if (sleepData.isNotEmpty) {
        debugPrint(
          '   First point: ${sleepData.first.dateFrom} - ${sleepData.first.value} (${sleepData.first.type.name})',
        );
        debugPrint(
          '   Last point: ${sleepData.last.dateFrom} - ${sleepData.last.value} (${sleepData.last.type.name})',
        );
      }
    }

    if (sleepData.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [SleepRecords] NO SLEEP DATA - returning empty list');
        debugPrint(
          '╚══════════════════════════════════════════════════════════╝',
        );
      }
      return [];
    }

    // ============================================================
    // EDGE CASE HANDLING FOR SLEEP DATA
    // ============================================================
    //
    // 1. Use END time (wake up) for grouping - not start time
    // 2. Filter out short naps (<2h) - only count real night sleep
    // 3. Deduplicate overlapping records from multiple sources
    // 4. Handle "still sleeping" edge case
    //
    // Group sleep data by night (using END time - when you wake up)
    // This ensures sleep from 23:00 Dec 20 → 06:00 Dec 21 counts as "Dec 21"
    // which matches "last night" when viewing on Dec 21
    final nightlySleep = <DateTime, double>{};

    // Track sleep sessions to avoid double-counting overlapping records
    final processedSessions = <String>{}; // "startTime-endTime" keys

    for (final point in sleepData) {
      // Extract numeric value from NumericHealthValue wrapper
      final numericValue = point.value as NumericHealthValue;
      final minutes = numericValue.numericValue.toDouble();

      // EDGE CASE 1: Skip very short sleep segments (<5 min)
      // These are often noise from movement during sleep
      if (minutes < 5) continue;

      // EDGE CASE 2: Deduplication - skip if we've seen this exact time range
      // Different sources (Watch, iPhone) may report same sleep
      final sessionKey =
          '${point.dateFrom.millisecondsSinceEpoch}-${point.dateTo.millisecondsSinceEpoch}';
      if (processedSessions.contains(sessionKey)) continue;
      processedSessions.add(sessionKey);

      // Use dateTo (wake time) for grouping, not dateFrom (sleep start)
      final nightKey = DateTime(
        point.dateTo.year,
        point.dateTo.month,
        point.dateTo.day,
      );

      nightlySleep[nightKey] = (nightlySleep[nightKey] ?? 0) + minutes;
    }

    // EDGE CASE 3: Filter out "nap days" - nights with <2h total sleep
    // These are likely naps, not actual night sleep
    // We keep track but filter in the final records
    final validNights = <DateTime, double>{};
    const minNightSleepMinutes = 120.0; // 2 hours minimum for "night sleep"

    for (final entry in nightlySleep.entries) {
      if (entry.value >= minNightSleepMinutes) {
        validNights[entry.key] = entry.value;
      } else if (kDebugMode) {
        debugPrint(
          '   ⚠️ Filtered out ${entry.key}: ${entry.value.round()}min (<2h, likely nap)',
        );
      }
    }

    // Fetch in-bed data for efficiency calculation (using datasource's initialized Health instance)
    final inBedRawData = await datasource.getInBedThisWeek();

    final nightlyInBed = <DateTime, double>{};
    for (final point in inBedRawData) {
      // Use dateTo (wake time) for grouping, consistent with sleep grouping
      final nightKey = DateTime(
        point.dateTo.year,
        point.dateTo.month,
        point.dateTo.day,
      );
      // Extract numeric value from NumericHealthValue wrapper
      final numericValue = point.value as NumericHealthValue;
      final minutes = numericValue.numericValue.toDouble();
      nightlyInBed[nightKey] = (nightlyInBed[nightKey] ?? 0) + minutes;
    }

    // Create SleepRecord for each VALID night (filtered out naps)
    final records = <SleepRecord>[];
    for (final entry in validNights.entries) {
      final date = entry.key;
      final asleepMinutes = entry.value;

      // EDGE CASE 4: Ensure inBedMinutes >= asleepMinutes
      // This prevents efficiency > 100% from data inconsistencies
      var inBedMinutes = nightlyInBed[date] ?? asleepMinutes + 30;
      if (inBedMinutes < asleepMinutes) {
        // If in-bed is less than asleep (data error), use asleep + small buffer
        inBedMinutes = asleepMinutes + 15;
        if (kDebugMode) {
          debugPrint(
            '   ⚠️ Corrected inBed for $date: was ${nightlyInBed[date]?.round()}min, now ${inBedMinutes.round()}min',
          );
        }
      }

      records.add(
        SleepRecord.fromHealthData(
          date: date,
          asleepMinutes: asleepMinutes,
          inBedMinutes: inBedMinutes,
          source: 'HealthKit',
        ),
      );
    }

    // Sort by date descending (most recent first)
    records.sort((a, b) => b.date.compareTo(a.date));

    // EDGE CASE 5: Handle "today's sleep might be incomplete"
    // If user opens app before 10 AM and today has very little sleep data,
    // it might be because they're still sleeping or watch hasn't synced yet
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isEarlyMorning = now.hour < 10; // Before 10 AM

    if (isEarlyMorning && records.isNotEmpty && records.first.date == today) {
      // Today's record exists but might be incomplete
      final todayRecord = records.first;
      if (todayRecord.asleepDuration.inMinutes < 180) {
        // Less than 3 hours - likely incomplete data
        // Remove "today" from the list, use yesterday as "last night"
        if (kDebugMode) {
          debugPrint(
            '   ⚠️ Removed incomplete today record: ${todayRecord.formattedDuration} (before 10 AM)',
          );
        }
        records.removeAt(0);
      }
    }

    if (kDebugMode) {
      debugPrint('');
      debugPrint(
        '✅ [SleepRecords] FINAL RESULT: ${records.length} sleep records',
      );
      for (final record in records) {
        debugPrint(
          '   📅 ${record.date.toIso8601String().split('T')[0]}: ${record.formattedDuration}',
        );
      }
      debugPrint(
        '╚══════════════════════════════════════════════════════════╝',
      );
    }

    return records;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('❌ [SleepRecords] EXCEPTION: $e');
      debugPrint('   Stack: $stackTrace');
      debugPrint(
        '╚══════════════════════════════════════════════════════════╝',
      );
    }
    return [];
  }
});

// ==========================================
// RECOVERY INSIGHT PROVIDERS
// ==========================================

/// Main provider for recovery insight
///
/// Combines sleep data with workout history to calculate recovery score.
///
/// **Free users**: Basic score and recommendation
/// **Pro users**: Full correlation analysis
///
/// **Bodyweight Exercise Volume**:
/// Automatically uses user's body weight from Body Measurements for
/// bodyweight exercises (push-ups, pull-ups, etc.) to calculate accurate volume.
final recoveryInsightProvider = FutureProvider.autoDispose<RecoveryInsight>((
  ref,
) async {
  final service = ref.watch(sleepWorkoutCorrelationServiceProvider);
  final sleepRecords = await ref.watch(sleepRecordsProvider.future);
  final isPro = ref.watch(isPremiumUserProvider);

  // Get workout history
  List workoutHistory;
  try {
    final historyDetails = await ref.watch(workoutHistoryProvider.future);
    workoutHistory = historyDetails.map((h) => h.toWorkout()).toList();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[RecoveryInsight] Error fetching workout history: $e');
    }
    workoutHistory = [];
  }

  // Get user's body weight for bodyweight exercise volume calculation
  double? userBodyWeightKg;
  try {
    final weightMeasurements = await ref.watch(
      bodyMeasurementsProvider(HealthDataType.bodyWeight).future,
    );
    if (weightMeasurements.isNotEmpty) {
      // Get most recent measurement
      final latestWeight = weightMeasurements.first;
      // Convert to kg if needed
      userBodyWeightKg = latestWeight.unit == MeasurementUnit.pounds
          ? latestWeight.value *
                0.453592 // lbs to kg
          : latestWeight.value;

      if (kDebugMode) {
        debugPrint(
          '[RecoveryInsight] User body weight: ${userBodyWeightKg.toStringAsFixed(1)}kg',
        );
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[RecoveryInsight] Could not fetch body weight: $e');
    }
    // Continue without body weight - bodyweight exercises will have volume = 0
  }

  // Handle no sleep data
  if (sleepRecords.isEmpty) {
    return RecoveryInsight.noData();
  }

  // Calculate correlation for Pro users
  SleepWorkoutCorrelation? correlation;
  if (isPro && workoutHistory.isNotEmpty) {
    correlation = service.calculateCorrelation(
      sleepHistory: sleepRecords,
      workoutHistory: workoutHistory.cast(),
      periodDays: 30,
      userBodyWeightKg: userBodyWeightKg,
    );
  }

  // Calculate recovery insight
  return service.calculateRecovery(
    sleepHistory: sleepRecords,
    workoutHistory: workoutHistory.cast(),
    correlation: correlation,
  );
});

/// Provider for sleep-workout correlation (Pro only)
///
/// Returns null for free users
final sleepCorrelationProvider =
    FutureProvider.autoDispose<SleepWorkoutCorrelation?>((ref) async {
      final isPro = ref.watch(isPremiumUserProvider);
      if (!isPro) return null;

      final insight = await ref.watch(recoveryInsightProvider.future);
      return insight.correlation;
    });

// ==========================================
// CONVENIENCE PROVIDERS
// ==========================================

/// Provider for recovery score only
final recoveryScoreProvider = Provider.autoDispose<int>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.value?.score ?? 75;
});

/// Provider for recovery category
final recoveryCategoryProvider = Provider.autoDispose<RecoveryCategory>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.value?.category ?? RecoveryCategory.good;
});

/// Provider for last night's sleep duration (formatted)
final lastNightSleepProvider = Provider.autoDispose<String>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.value?.formattedLastNight ?? '--';
});

/// Provider for weekly average sleep (formatted)
final weeklyAverageSleepProvider = Provider.autoDispose<String>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.value?.formattedWeeklyAverage ?? '--';
});

/// Provider to check if sleep data is available
final hasSleepDataProvider = Provider.autoDispose<bool>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.value?.hasSleepData ?? false;
});

/// Provider for good sleep streak days
final sleepStreakProvider = Provider.autoDispose<int>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.value?.streakDays ?? 0;
});
