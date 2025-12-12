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
  final analytics = await ref.watch(sleepAnalyticsProvider.future);

  if (analytics['available'] != true) {
    return [];
  }

  // For now, create records from the analytics summary
  // In a full implementation, we'd fetch individual night data
  final avgHours = (analytics['avg_sleep_hours'] as num?)?.toDouble() ?? 0;
  final nightsWithData = (analytics['nights_with_data'] as int?) ?? 0;

  if (nightsWithData == 0) {
    return [];
  }

  // Create synthetic records for demonstration
  // TODO: Fetch actual per-night data from HealthKit
  final records = <SleepRecord>[];
  final now = DateTime.now();

  for (int i = 0; i < nightsWithData; i++) {
    final date = now.subtract(Duration(days: i + 1));
    // Vary sleep around average for realism
    final variance = (i % 3 - 1) * 0.5; // -0.5, 0, +0.5 hours
    final sleepHours = (avgHours + variance).clamp(4.0, 12.0);

    records.add(SleepRecord.fromHealthData(
      date: date,
      asleepMinutes: sleepHours * 60,
      inBedMinutes: (sleepHours + 0.5) * 60, // Assume 30min awake time
      source: 'HealthKit',
    ));
  }

  return records;
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
  final isPro = ref.watch(isPremiumProvider);

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
  final isPro = ref.watch(isPremiumProvider);
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
