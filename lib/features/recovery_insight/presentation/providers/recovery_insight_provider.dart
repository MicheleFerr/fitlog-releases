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
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/services/sleep_workout_correlation_service.dart';

// ==========================================
// SERVICE PROVIDERS
// ==========================================

/// Provider for HealthKitDatasource
final healthKitDatasourceProvider = Provider<HealthKitDatasource>((ref) {
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
final sleepAnalyticsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
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
});

/// Provider for sleep records (last 7 days)
///
/// Converts raw HealthKit data to SleepRecord entities
final sleepRecordsProvider =
    FutureProvider.autoDispose<List<SleepRecord>>((ref) async {
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
      debugPrint('🔄 [SleepRecords] Step 2: Calling datasource.initialize()...');
    }
    await datasource.initialize();
    if (kDebugMode) {
      debugPrint('✅ [SleepRecords] Step 2: Initialize completed');
    }

    // Fetch raw sleep data for last 7 days
    if (kDebugMode) {
      debugPrint('🔄 [SleepRecords] Step 3: Calling datasource.getSleepThisWeek()...');
    }
    final sleepData = await datasource.getSleepThisWeek();
    if (kDebugMode) {
      debugPrint('📊 [SleepRecords] Step 3: getSleepThisWeek() returned ${sleepData.length} data points');
      if (sleepData.isNotEmpty) {
        debugPrint('   First point: ${sleepData.first.dateFrom} - ${sleepData.first.value} (${sleepData.first.type.name})');
        debugPrint('   Last point: ${sleepData.last.dateFrom} - ${sleepData.last.value} (${sleepData.last.type.name})');
      }
    }

    if (sleepData.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [SleepRecords] NO SLEEP DATA - returning empty list');
        debugPrint('╚══════════════════════════════════════════════════════════╝');
      }
      return [];
    }

    // Group sleep data by night (date only, no time)
    final nightlySleep = <DateTime, double>{};
    for (final point in sleepData) {
      final nightKey = DateTime(
        point.dateFrom.year,
        point.dateFrom.month,
        point.dateFrom.day,
      );
      // Extract numeric value from NumericHealthValue wrapper
      final numericValue = point.value as NumericHealthValue;
      final minutes = numericValue.numericValue.toDouble();
      nightlySleep[nightKey] = (nightlySleep[nightKey] ?? 0) + minutes;
    }

    // Fetch in-bed data for efficiency calculation (using datasource's initialized Health instance)
    final inBedRawData = await datasource.getInBedThisWeek();

    final nightlyInBed = <DateTime, double>{};
    for (final point in inBedRawData) {
      final nightKey = DateTime(
        point.dateFrom.year,
        point.dateFrom.month,
        point.dateFrom.day,
      );
      // Extract numeric value from NumericHealthValue wrapper
      final numericValue = point.value as NumericHealthValue;
      final minutes = numericValue.numericValue.toDouble();
      nightlyInBed[nightKey] = (nightlyInBed[nightKey] ?? 0) + minutes;
    }

    // Create SleepRecord for each night
    final records = <SleepRecord>[];
    for (final entry in nightlySleep.entries) {
      final date = entry.key;
      final asleepMinutes = entry.value;
      final inBedMinutes = nightlyInBed[date] ?? asleepMinutes + 30; // Default to +30min if not available

      records.add(SleepRecord.fromHealthData(
        date: date,
        asleepMinutes: asleepMinutes,
        inBedMinutes: inBedMinutes,
        source: 'HealthKit',
      ));
    }

    // Sort by date descending (most recent first)
    records.sort((a, b) => b.date.compareTo(a.date));

    if (kDebugMode) {
      debugPrint('');
      debugPrint('✅ [SleepRecords] FINAL RESULT: ${records.length} sleep records');
      for (final record in records) {
        debugPrint('   📅 ${record.date.toIso8601String().split('T')[0]}: ${record.formattedDuration}');
      }
      debugPrint('╚══════════════════════════════════════════════════════════╝');
    }

    return records;
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('❌ [SleepRecords] EXCEPTION: $e');
      debugPrint('   Stack: $stackTrace');
      debugPrint('╚══════════════════════════════════════════════════════════╝');
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
final recoveryInsightProvider =
    FutureProvider.autoDispose<RecoveryInsight>((ref) async {
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
  return insightAsync.valueOrNull?.score ?? 75;
});

/// Provider for recovery category
final recoveryCategoryProvider = Provider.autoDispose<RecoveryCategory>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.valueOrNull?.category ?? RecoveryCategory.good;
});

/// Provider for last night's sleep duration (formatted)
final lastNightSleepProvider = Provider.autoDispose<String>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.valueOrNull?.formattedLastNight ?? '--';
});

/// Provider for weekly average sleep (formatted)
final weeklyAverageSleepProvider = Provider.autoDispose<String>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.valueOrNull?.formattedWeeklyAverage ?? '--';
});

/// Provider to check if sleep data is available
final hasSleepDataProvider = Provider.autoDispose<bool>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.valueOrNull?.hasSleepData ?? false;
});

/// Provider for good sleep streak days
final sleepStreakProvider = Provider.autoDispose<int>((ref) {
  final insightAsync = ref.watch(recoveryInsightProvider);
  return insightAsync.valueOrNull?.streakDays ?? 0;
});
