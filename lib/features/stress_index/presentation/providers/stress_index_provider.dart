/// Stress Index Providers
///
/// Riverpod providers for stress index feature.
/// Provides access to stress index calculation, storage, and state management.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/repositories/stress_index_repository.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_state.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/stress_index_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

// ====================
// REPOSITORY PROVIDER
// ====================

/// Provider for StressIndexRepository
final stressIndexRepositoryProvider = Provider<StressIndexRepository>((ref) {
  final repository = StressIndexRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

// ====================
// EXERCISE FOCUS MAP PROVIDER
// ====================

/// Provider that builds a map of exercise name → focus muscles
///
/// Used by the calculator for accurate muscle-level stress tracking.
final exerciseFocusMapProvider =
    FutureProvider.autoDispose<Map<String, List<String>>>((ref) async {
  try {
    final repository = ref.watch(hybridExerciseRepositoryProvider);
    final exercises = await repository.getAllExercises();

    final focusMap = <String, List<String>>{};
    for (final exercise in exercises) {
      if (exercise.focus.isNotEmpty) {
        focusMap[exercise.nome] = exercise.focus;
      }
    }

    return focusMap;
  } catch (e) {
    // Return empty map on error - calculator will use category fallback
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
class StressIndexNotifier extends StateNotifier<AsyncValue<StressIndexState>> {
  StressIndexNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref _ref;

  Future<void> _initialize() async {
    try {
      final repository = _ref.read(stressIndexRepositoryProvider);
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

      final muscleRecovery =
          StressIndexCalculator.calculateRecoveryStatus(recentResults);

      state = AsyncValue.data(StressIndexState(
        latestResult: recentResults.isNotEmpty ? recentResults.first : null,
        muscleRecovery: muscleRecovery,
        history: recentResults,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Internal backfill without updating state (used during init)
  Future<int> _backfillSilently() async {
    try {
      final historyAsync = await _ref.read(workoutHistoryProvider.future);
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final recentWorkouts = historyAsync
          .where((w) => w.completedAt.isAfter(cutoff))
          .toList();

      if (recentWorkouts.isEmpty) return 0;

      final focusMap = await _ref
          .read(exerciseFocusMapProvider.future)
          .catchError((_) => <String, List<String>>{});

      final repository = _ref.read(stressIndexRepositoryProvider);
      int count = 0;

      for (final historyDetail in recentWorkouts) {
        final existing = await repository.getForWorkout(historyDetail.id);
        if (existing != null) continue;

        final workout = historyDetail.toWorkout();
        if (!StressIndexCalculator.canCalculate(workout)) continue;

        final result = StressIndexCalculator.calculate(
          workout,
          exerciseFocusMap: focusMap,
        );

        final adjustedResult = StressIndexResult(
          primaryScore: result.primaryScore,
          fallbackScore: result.fallbackScore,
          confidence: result.confidence,
          muscleBreakdown: result.muscleBreakdown,
          totalSets: result.totalSets,
          setsWithRpe: result.setsWithRpe,
          workoutId: result.workoutId,
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
      // Get exercise focus map for accurate muscle tracking
      final focusMap =
          await _ref.read(exerciseFocusMapProvider.future).catchError((_) => <String, List<String>>{});

      // Calculate stress index
      final result = StressIndexCalculator.calculate(
        workout,
        exerciseFocusMap: focusMap,
      );

      // Save to repository
      final repository = _ref.read(stressIndexRepositoryProvider);
      await repository.save(result);

      // Update state
      final currentState = state.valueOrNull ?? StressIndexState.empty();
      final updatedHistory = [result, ...currentState.history]
          .take(50) // Keep last 50 results
          .toList();

      final muscleRecovery =
          StressIndexCalculator.calculateRecoveryStatus(updatedHistory);

      state = AsyncValue.data(StressIndexState(
        latestResult: result,
        muscleRecovery: muscleRecovery,
        history: updatedHistory,
      ));

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

  /// Get stress index for a specific workout
  Future<StressIndexResult?> getForWorkout(String workoutId) async {
    final repository = _ref.read(stressIndexRepositoryProvider);
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
      final historyAsync = await _ref.read(workoutHistoryProvider.future);

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

      // Get exercise focus map
      final focusMap = await _ref
          .read(exerciseFocusMapProvider.future)
          .catchError((_) => <String, List<String>>{});

      final repository = _ref.read(stressIndexRepositoryProvider);
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
          exerciseFocusMap: focusMap,
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
        debugPrint('[StressIndex] Backfill complete: $processedCount workouts processed');
      }

      return processedCount;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[StressIndex] Backfill failed: $e\n$st');
      }
      return 0;
    }
  }
}

/// Provider for StressIndexNotifier
final stressIndexNotifierProvider =
    StateNotifierProvider.autoDispose<StressIndexNotifier, AsyncValue<StressIndexState>>(
  (ref) => StressIndexNotifier(ref),
);

// ====================
// CONVENIENCE PROVIDERS
// ====================

/// Provider for latest stress index result
final latestStressIndexProvider =
    Provider.autoDispose<StressIndexResult?>((ref) {
  final state = ref.watch(stressIndexNotifierProvider);
  return state.valueOrNull?.latestResult;
});

/// Provider for muscle recovery status map
final muscleRecoveryProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  final state = ref.watch(stressIndexNotifierProvider);
  return state.valueOrNull?.muscleRecovery ?? {};
});

/// Provider for checking if stress index data is available
final hasStressIndexDataProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(stressIndexNotifierProvider);
  return state.valueOrNull?.hasData ?? false;
});
