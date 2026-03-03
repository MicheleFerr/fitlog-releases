/// Stress Index Providers
///
/// Riverpod providers for stress index feature.
/// Provides access to stress index calculation, storage, and state management.
///
/// **Sleep-Aware Stress**: Integrates sleep data from HealthKit to provide
/// a complete picture of recovery (training fatigue + sleep quality).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/presentation/providers/recovery_insight_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/repositories/stress_index_repository.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_state.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/stress_index_calculator.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

// ====================
// REPOSITORY PROVIDER
// ====================

/// Provider for StressIndexRepository
final stressIndexRepositoryProvider = Provider<StressIndexRepository>((ref) {
  // FIX: keepAlive prevents provider recreation on each watch,
  // avoiding 2x StressIndexRepository initialization and duplicate Hive box opens
  ref.keepAlive();
  final repository = StressIndexRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

// ====================
// EXERCISE MUSCLE MAP PROVIDER
// ====================

/// Data class for exercise muscle targeting
///
/// Holds primary (focus), secondary muscles, and file category for an exercise.
/// The file category is used to infer movement pattern for EMG-based ratios.
class ExerciseMuscleData {
  const ExerciseMuscleData({
    required this.primary,
    required this.secondary,
    this.fileCategory = '',
    this.exerciseName = '',
  });

  /// Primary muscles (focus)
  final List<String> primary;

  /// Secondary muscles
  final List<String> secondary;

  /// File category (e.g., 'upper_push.json', 'lower.json')
  /// Used to infer MovementPattern for EMG-based ratio distribution
  final String fileCategory;

  /// Exercise name (used for pattern inference fallback)
  final String exerciseName;

  /// Check if exercise has any muscle data
  bool get hasData => primary.isNotEmpty || secondary.isNotEmpty;
}

/// Provider that builds a map of exercise name → muscle data (primary + secondary)
///
/// Used by the calculator for accurate muscle-level stress tracking.
/// Includes file category for EMG-based movement pattern inference.
///
/// **EXPANDED WITH ALIASES**: Maps both `nome` AND all `aliases` to muscle data
/// for better matching when workout stores different name variants.
/// Example: "Panca Piana con Bilanciere", "panca piana", "bp" all → same muscle data
final exerciseMuscleMapProvider =
    FutureProvider.autoDispose<Map<String, ExerciseMuscleData>>((ref) async {
      try {
        final repository = ref.watch(hybridExerciseRepositoryProvider);
        final exercises = await repository.getAllExercises();

        final muscleMap = <String, ExerciseMuscleData>{};
        for (final exercise in exercises) {
          if (exercise.focus.isNotEmpty ||
              exercise.muscoliSecondari.isNotEmpty) {
            final muscleData = ExerciseMuscleData(
              primary: exercise.focus,
              secondary: exercise.muscoliSecondari,
              // Use patternMovimento for movement pattern inference (replaces missing file field)
              fileCategory: exercise.patternMovimento,
              exerciseName: exercise.nome,
            );

            // Add main name (exact match)
            muscleMap[exercise.nome] = muscleData;

            // Add lowercase version for case-insensitive matching
            final nomeLower = exercise.nome.toLowerCase();
            if (!muscleMap.containsKey(nomeLower)) {
              muscleMap[nomeLower] = muscleData;
            }

            // Add all aliases for flexible matching
            // Example: "panca piana", "bp", "ppcb" all map to "Panca Piana con Bilanciere"
            for (final alias in exercise.aliases) {
              final aliasNormalized = alias.toLowerCase().trim();
              if (aliasNormalized.isNotEmpty &&
                  !muscleMap.containsKey(aliasNormalized)) {
                muscleMap[aliasNormalized] = muscleData;
              }
            }
          }
        }

        return muscleMap;
      } catch (e) {
        // Return empty map on error - calculator will use category fallback
        return {};
      }
    });

/// @deprecated Use [exerciseMuscleMapProvider] instead
/// Kept for backward compatibility
final exerciseFocusMapProvider =
    FutureProvider.autoDispose<Map<String, List<String>>>((ref) async {
      try {
        final muscleMap = await ref.watch(exerciseMuscleMapProvider.future);
        // Convert to old format (primary muscles only)
        return muscleMap.map((key, value) => MapEntry(key, value.primary));
      } catch (e) {
        return {};
      }
    });

// ====================
// RECENT RESULTS PROVIDER
// ====================

/// Provider for recent stress index results (last 7 days)
final recentStressIndexResultsProvider =
    FutureProvider.autoDispose<List<StressIndexResult>>((ref) async {
      final repository = ref.watch(stressIndexRepositoryProvider);
      return repository.getRecent(days: 7);
    });

/// Stream provider for watching recent results
final recentStressIndexStreamProvider =
    StreamProvider.autoDispose<List<StressIndexResult>>((ref) {
      final repository = ref.watch(stressIndexRepositoryProvider);
      return repository.watchRecent(days: 7);
    });

// ====================
// STATE NOTIFIER PROVIDER
// ====================

/// State notifier for stress index feature
///
/// Manages:
/// - Latest stress index result
/// - Muscle recovery status
/// - History of results
class StressIndexNotifier extends Notifier<AsyncValue<StressIndexState>> {
  @override
  AsyncValue<StressIndexState> build() {
    // Start async initialization
    _initialize();
    return const AsyncValue.loading();
  }

  Future<void> _initialize() async {
    try {
      final repository = ref.read(stressIndexRepositoryProvider);
      var recentResults = await repository.getRecent(days: 7);

      // Auto-backfill if no data exists
      if (recentResults.isEmpty) {
        if (kDebugMode) {
          debugPrint('[StressIndex] No data found, starting auto-backfill...');
        }
        final backfillCount = await _backfillSilently();
        if (backfillCount > 0) {
          // Re-fetch after backfill
          recentResults = await repository.getRecent(days: 7);
        }
      }

      final muscleRecovery = StressIndexCalculator.calculateRecoveryStatus(
        recentResults,
      );

      state = AsyncValue.data(
        StressIndexState(
          latestResult: recentResults.isNotEmpty ? recentResults.first : null,
          muscleRecovery: muscleRecovery,
          history: recentResults,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Internal backfill without updating state (used during init)
  Future<int> _backfillSilently() async {
    try {
      final historyAsync = await ref.read(workoutHistoryProvider.future);
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final recentWorkouts = historyAsync
          .where((w) => w.completedAt.isAfter(cutoff))
          .toList();

      if (recentWorkouts.isEmpty) return 0;

      final muscleMap = await ref
          .read(exerciseMuscleMapProvider.future)
          .catchError((_) => <String, ExerciseMuscleData>{});

      // 🏋️ Get user body weight for bodyweight exercise stress calculation
      final userBodyWeightKg = await _getUserBodyWeightKg();

      final repository = ref.read(stressIndexRepositoryProvider);
      int count = 0;

      for (final historyDetail in recentWorkouts) {
        final existing = await repository.getForWorkout(historyDetail.id);
        if (existing != null) continue;

        final workout = historyDetail.toWorkout();
        if (!StressIndexCalculator.canCalculate(workout)) continue;

        final result = StressIndexCalculator.calculate(
          workout,
          exerciseMuscleMap: muscleMap,
          userBodyWeightKg: userBodyWeightKg,
        );

        final adjustedResult = StressIndexResult(
          primaryScore: result.primaryScore,
          fallbackScore: result.fallbackScore,
          confidence: result.confidence,
          muscleBreakdown: result.muscleBreakdown,
          totalSets: result.totalSets,
          setsWithRpe: result.setsWithRpe,
          workoutId: result.workoutId,
          workoutName: result.workoutName,
          workoutDate: result.workoutDate,
          calculatedAt: historyDetail.completedAt,
          rawScore: result.rawScore,
        );

        await repository.save(adjustedResult);
        count++;
      }

      if (kDebugMode && count > 0) {
        debugPrint('[StressIndex] Auto-backfill: $count workouts');
      }
      return count;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndex] Auto-backfill failed: $e');
      }
      return 0;
    }
  }

  /// Calculate and save stress index for a completed workout
  Future<StressIndexResult?> calculateAndSave(Workout workout) async {
    try {
      // Get exercise muscle map for accurate muscle tracking (primary + secondary)
      final muscleMap = await ref
          .read(exerciseMuscleMapProvider.future)
          .catchError((_) => <String, ExerciseMuscleData>{});

      // 🏋️ Get user body weight for bodyweight exercise stress calculation
      final userBodyWeightKg = await _getUserBodyWeightKg();

      // Calculate stress index
      final result = StressIndexCalculator.calculate(
        workout,
        exerciseMuscleMap: muscleMap,
        userBodyWeightKg: userBodyWeightKg,
      );

      // Save to repository
      final repository = ref.read(stressIndexRepositoryProvider);
      await repository.save(result);

      // Update state
      final currentState = state.value ?? StressIndexState.empty();
      final updatedHistory = [result, ...currentState.history]
          .take(50) // Keep last 50 results
          .toList();

      final muscleRecovery = StressIndexCalculator.calculateRecoveryStatus(
        updatedHistory,
      );

      state = AsyncValue.data(
        StressIndexState(
          latestResult: result,
          muscleRecovery: muscleRecovery,
          history: updatedHistory,
        ),
      );

      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Refresh state from repository
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _initialize();
  }

  /// Clear all stress index data and recalculate from workout history
  ///
  /// Use this after modifying exercise focus values in the JSON database.
  /// This will:
  /// 1. Delete all existing stress index results (local + cloud)
  /// 2. Recalculate from workout history using updated exercise focus values
  ///
  /// Returns a tuple of (cleared count, recalculated count)
  Future<(int cleared, int recalculated)> clearAndRecalculate({
    int days = 30,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Step 1: Clear all existing data
      final repository = ref.read(stressIndexRepositoryProvider);
      final clearedCount = await repository.clearAll();

      if (kDebugMode) {
        debugPrint('[StressIndex] Cleared $clearedCount existing results');
      }

      // Step 2: Recalculate from history
      final recalculatedCount = await backfillFromHistory(days: days);

      if (kDebugMode) {
        debugPrint('[StressIndex] Recalculated $recalculatedCount workouts');
      }

      return (clearedCount, recalculatedCount);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return (0, 0);
    }
  }

  /// Get stress index for a specific workout
  Future<StressIndexResult?> getForWorkout(String workoutId) async {
    final repository = ref.read(stressIndexRepositoryProvider);
    return repository.getForWorkout(workoutId);
  }

  /// Backfill stress index from workout history
  ///
  /// Calculates and saves stress index for all past workouts that don't
  /// already have a stress index result. Limited to last [days] days.
  ///
  /// Returns the number of workouts processed.
  Future<int> backfillFromHistory({int days = 30}) async {
    try {
      // Get workout history
      final historyAsync = await ref.read(workoutHistoryProvider.future);

      // Filter to workouts within date range
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final recentWorkouts = historyAsync
          .where((w) => w.completedAt.isAfter(cutoff))
          .toList();

      if (recentWorkouts.isEmpty) {
        if (kDebugMode) {
          debugPrint('[StressIndex] No workouts found in last $days days');
        }
        return 0;
      }

      // Get exercise muscle map (primary + secondary)
      final muscleMap = await ref
          .read(exerciseMuscleMapProvider.future)
          .catchError((_) => <String, ExerciseMuscleData>{});

      // 🏋️ Get user body weight for bodyweight exercise stress calculation
      final userBodyWeightKg = await _getUserBodyWeightKg();

      final repository = ref.read(stressIndexRepositoryProvider);
      int processedCount = 0;

      for (final historyDetail in recentWorkouts) {
        // Skip if already has stress index
        final existing = await repository.getForWorkout(historyDetail.id);
        if (existing != null) {
          continue;
        }

        // Convert to Workout entity
        final workout = historyDetail.toWorkout();

        // Check if workout can be calculated
        if (!StressIndexCalculator.canCalculate(workout)) {
          continue;
        }

        // Calculate stress index
        final result = StressIndexCalculator.calculate(
          workout,
          exerciseMuscleMap: muscleMap,
          userBodyWeightKg: userBodyWeightKg,
        );

        // Override calculatedAt with the actual workout completion date
        final adjustedResult = StressIndexResult(
          primaryScore: result.primaryScore,
          fallbackScore: result.fallbackScore,
          confidence: result.confidence,
          muscleBreakdown: result.muscleBreakdown,
          totalSets: result.totalSets,
          setsWithRpe: result.setsWithRpe,
          workoutId: result.workoutId,
          workoutName: result.workoutName,
          workoutDate: result.workoutDate,
          calculatedAt: historyDetail.completedAt, // Use original workout date
          rawScore: result.rawScore,
        );

        // Save
        await repository.save(adjustedResult);
        processedCount++;

        if (kDebugMode) {
          debugPrint(
            '[StressIndex] Backfilled workout ${historyDetail.name} '
            '(${historyDetail.completedAt.toIso8601String()}): '
            'score=${adjustedResult.displayScore.toStringAsFixed(0)}',
          );
        }
      }

      // Refresh state after backfill
      if (processedCount > 0) {
        await refresh();
      }

      if (kDebugMode) {
        debugPrint(
          '[StressIndex] Backfill complete: $processedCount workouts processed',
        );
      }

      return processedCount;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[StressIndex] Backfill failed: $e\n$st');
      }
      return 0;
    }
  }

  /// Get user's body weight in kg from Body Measurements
  ///
  /// Returns null if not available. Used for bodyweight exercise
  /// stress calculations (push-ups, pull-ups, dips).
  /// Falls back to default 70kg in calculator if null.
  Future<double?> _getUserBodyWeightKg() async {
    try {
      final weightMeasurements = await ref.read(
        bodyMeasurementsProvider(HealthDataType.bodyWeight).future,
      );
      if (weightMeasurements.isNotEmpty) {
        final latestWeight = weightMeasurements.first;
        // Convert to kg if stored in pounds
        return latestWeight.unit == MeasurementUnit.pounds
            ? latestWeight.value * 0.453592
            : latestWeight.value;
      }
    } catch (_) {
      // Ignore - bodyweight exercises will use default fallback (70kg)
    }
    return null;
  }
}

/// Provider for StressIndexNotifier
final stressIndexNotifierProvider =
    NotifierProvider.autoDispose<
      StressIndexNotifier,
      AsyncValue<StressIndexState>
    >(StressIndexNotifier.new);

// ====================
// CONVENIENCE PROVIDERS
// ====================

/// Provider for latest stress index result
final latestStressIndexProvider = Provider.autoDispose<StressIndexResult?>((
  ref,
) {
  final state = ref.watch(stressIndexNotifierProvider);
  return state.value?.latestResult;
});

/// Provider for muscle recovery status map
final muscleRecoveryProvider = Provider.autoDispose<Map<String, dynamic>>((
  ref,
) {
  final state = ref.watch(stressIndexNotifierProvider);
  return state.value?.muscleRecovery ?? {};
});

/// Provider for checking if stress index data is available
final hasStressIndexDataProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(stressIndexNotifierProvider);
  return state.value?.hasData ?? false;
});

// ====================
// SLEEP-AWARE STRESS PROVIDERS
// ====================

/// Helper function to count consecutive bad nights (<6h sleep)
///
/// [sleepRecords] should be sorted by date descending (most recent first)
int _countConsecutiveBadNights(List<SleepRecord> sleepRecords) {
  if (sleepRecords.isEmpty) return 0;

  int consecutiveCount = 0;

  for (final record in sleepRecords) {
    if (record.asleepHours < StressIndexConstants.sleepCriticalThreshold) {
      consecutiveCount++;
    } else {
      // First good night breaks the streak
      break;
    }
  }

  return consecutiveCount;
}

/// Data class for sleep-aware stress index
///
/// Combines FFM-based stress calculation with sleep quality data
class SleepAwareStressData {
  const SleepAwareStressData({
    required this.rawReadiness,
    required this.adjustedReadiness,
    required this.sleepHours,
    required this.consecutiveBadNights,
    required this.sleepModifier,
    required this.sleepCategory,
    required this.hasSleepData,
  });

  /// Create default state when no data available
  factory SleepAwareStressData.noData() {
    return const SleepAwareStressData(
      rawReadiness: 100.0,
      adjustedReadiness: 100.0,
      sleepHours: StressIndexConstants.defaultSleepHours,
      consecutiveBadNights: 0,
      sleepModifier: 1.0,
      sleepCategory: SleepQualityCategory.optimal,
      hasSleepData: false,
    );
  }

  /// FFM-based readiness without sleep adjustment (0-100+)
  final double rawReadiness;

  /// Sleep-adjusted readiness (0-100+)
  final double adjustedReadiness;

  /// Last night's sleep hours
  final double sleepHours;

  /// Number of consecutive nights with <6h sleep
  final int consecutiveBadNights;

  /// Sleep modifier applied (0.7-1.0)
  final double sleepModifier;

  /// Sleep quality category
  final SleepQualityCategory sleepCategory;

  /// Whether sleep data is available
  final bool hasSleepData;

  /// Stress score derived from adjusted readiness (0-100)
  /// Higher = more stress, lower = more recovered
  double get stressScore => (100 - adjustedReadiness).clamp(0.0, 100.0);

  /// Impact of sleep on stress (positive = increased stress from poor sleep)
  double get sleepImpact => rawReadiness - adjustedReadiness;

  /// Whether sleep is significantly impacting recovery (>5% impact)
  bool get hasSleepImpact => sleepImpact.abs() > 5;
}

/// Provider for sleep-aware stress data
///
/// Combines:
/// - FFM-based readiness from workout history
/// - Sleep data from HealthKit
/// - Consecutive bad nights penalty
///
/// **Formula**: `AdjustedReadiness = FFM_Readiness × SleepModifier × ConsecutivePenalty`
final sleepAwareStressDataProvider = FutureProvider.autoDispose<SleepAwareStressData>((
  ref,
) async {
  // Get stress index history
  final stressState = ref.watch(stressIndexNotifierProvider);
  final history = stressState.value?.history ?? [];

  // Calculate raw FFM readiness
  final rawReadiness = StressIndexCalculator.getOverallReadinessFFM(history);

  // Get sleep records
  List<SleepRecord> sleepRecords;
  try {
    sleepRecords = await ref.watch(sleepRecordsProvider.future);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[SleepAwareStress] Failed to get sleep records: $e');
    }
    sleepRecords = [];
  }

  // If no sleep data, return raw readiness
  if (sleepRecords.isEmpty) {
    return SleepAwareStressData(
      rawReadiness: rawReadiness,
      adjustedReadiness: rawReadiness,
      sleepHours: StressIndexConstants.defaultSleepHours,
      consecutiveBadNights: 0,
      sleepModifier: 1.0,
      sleepCategory: SleepQualityCategory.optimal,
      hasSleepData: false,
    );
  }

  // Get last night's sleep
  final lastNightSleep = sleepRecords.first;
  final sleepHours = lastNightSleep.asleepHours;

  // Count consecutive bad nights
  final consecutiveBadNights = _countConsecutiveBadNights(sleepRecords);

  // Calculate sleep-adjusted readiness
  final adjustedReadiness = StressIndexCalculator.getOverallReadinessWithSleep(
    recentWorkouts: history,
    sleepHours: sleepHours,
    consecutiveBadNights: consecutiveBadNights,
  );

  // Get sleep modifier for display
  final sleepCategory = StressIndexCalculator.getSleepCategory(sleepHours);
  final sleepModifier = StressIndexCalculator.getSleepModifier(sleepHours);

  if (kDebugMode) {
    debugPrint(
      '[SleepAwareStress] Raw readiness: ${rawReadiness.toStringAsFixed(1)}%',
    );
    debugPrint(
      '[SleepAwareStress] Sleep: ${sleepHours.toStringAsFixed(1)}h ($sleepCategory)',
    );
    debugPrint(
      '[SleepAwareStress] Consecutive bad nights: $consecutiveBadNights',
    );
    debugPrint(
      '[SleepAwareStress] Adjusted readiness: ${adjustedReadiness.toStringAsFixed(1)}%',
    );
  }

  return SleepAwareStressData(
    rawReadiness: rawReadiness,
    adjustedReadiness: adjustedReadiness,
    sleepHours: sleepHours,
    consecutiveBadNights: consecutiveBadNights,
    sleepModifier: sleepModifier,
    sleepCategory: sleepCategory,
    hasSleepData: true,
  );
});

/// Provider for sleep-adjusted stress score
///
/// Convenience provider that returns just the stress score (0-100)
/// Higher = more stress, lower = more recovered
final sleepAwareStressScoreProvider = Provider.autoDispose<double>((ref) {
  final dataAsync = ref.watch(sleepAwareStressDataProvider);
  return dataAsync.value?.stressScore ?? 0.0;
});

/// Provider for checking if sleep is impacting recovery
final hasSleepImpactProvider = Provider.autoDispose<bool>((ref) {
  final dataAsync = ref.watch(sleepAwareStressDataProvider);
  return dataAsync.value?.hasSleepImpact ?? false;
});
