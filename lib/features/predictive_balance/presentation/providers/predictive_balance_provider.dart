/// Predictive Balance Providers
///
/// Riverpod providers for the predictive balance feature.
/// Detects workout patterns and predicts missing workouts.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/pattern_prediction.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/weekly_pattern.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/services/pattern_detector_service.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/services/prediction_engine_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

// ====================
// WEEKLY PATTERN PROVIDER
// ====================

/// Provider for detected weekly workout pattern
///
/// Analyzes workout history to find repeating cycles.
/// Returns null if insufficient data or no pattern detected.
///
/// **Usage**:
/// ```dart
/// final patternAsync = ref.watch(weeklyPatternProvider);
/// patternAsync.when(
///   data: (pattern) {
///     if (pattern != null && pattern.isValid) {
///       // User has a consistent workout pattern
///     }
///   },
///   loading: () => ...,
///   error: (e, st) => ...,
/// );
/// ```
final weeklyPatternProvider = FutureProvider.autoDispose<WeeklyPattern?>((
  ref,
) async {
  try {
    // Get workout history
    final historyAsync = await ref.watch(workoutHistoryProvider.future);

    // Convert to Workout entities
    final history = historyAsync.map((detail) => detail.toWorkout()).toList();

    // Get muscle map
    final muscleMap = await ref.watch(exerciseMuscleMapProvider.future);

    if (history.isEmpty || muscleMap.isEmpty) {
      return null;
    }

    // Detect pattern
    final pattern = PatternDetectorService.detect(
      history: history,
      muscleMap: muscleMap,
    );

    if (kDebugMode && pattern != null) {
      debugPrint(
        '📊 [PredictiveBalance] Pattern detected: ${pattern.description}',
      );
      debugPrint(
        '   Confidence: ${(pattern.confidence * 100).toStringAsFixed(0)}%',
      );
    }

    return pattern;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('❌ [PredictiveBalance] Pattern detection error: $e');
      debugPrint('   $st');
    }
    return null;
  }
});

// ====================
// THIS WEEK WORKOUTS PROVIDER
// ====================

/// Provider for workouts completed this week (Monday-Sunday)
///
/// Filters workout history to only include workouts from the current ISO week.
final thisWeekWorkoutsProvider = FutureProvider.autoDispose<List<Workout>>((
  ref,
) async {
  final historyAsync = await ref.watch(workoutHistoryProvider.future);

  // Get start of current week (Monday)
  final now = DateTime.now();
  final daysFromMonday = now.weekday - 1;
  final weekStart = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: daysFromMonday));

  // Filter to this week's completed workouts
  return historyAsync
      .where((detail) {
        return detail.completedAt.isAfter(weekStart) ||
            detail.completedAt.isAtSameMomentAs(weekStart);
      })
      .map((detail) => detail.toWorkout())
      .toList();
});

// ====================
// MISSING WORKOUT PROVIDER
// ====================

/// Provider for predicted missing workout this week
///
/// Based on detected pattern, predicts which workout is missing
/// from the current week.
///
/// Returns null if:
/// - No valid pattern detected
/// - All expected workouts completed this week
///
/// **Usage**:
/// ```dart
/// final prediction = ref.watch(missingWorkoutProvider).value;
/// if (prediction != null) {
///   // Show "Complete ${prediction.displayName} to balance"
/// }
/// ```
final missingWorkoutProvider = FutureProvider.autoDispose<PatternPrediction?>((
  ref,
) async {
  try {
    // Get pattern
    final pattern = await ref.watch(weeklyPatternProvider.future);
    if (pattern == null || !pattern.isValid) return null;

    // Get this week's workouts
    final thisWeek = await ref.watch(thisWeekWorkoutsProvider.future);

    // Get muscle map
    final muscleMap = await ref.watch(exerciseMuscleMapProvider.future);

    // Get templates for suggestions
    List<dynamic>? templates;
    try {
      templates = await ref.watch(customWorkoutTemplatesProvider.future);
    } catch (_) {
      // Templates are optional
    }

    // Predict missing workout
    final prediction = PredictionEngineService.predict(
      pattern: pattern,
      thisWeekWorkouts: thisWeek,
      muscleMap: muscleMap,
      templates: templates?.cast(),
    );

    if (kDebugMode && prediction != null) {
      debugPrint('📊 [PredictiveBalance] Missing: ${prediction.displayName}');
      debugPrint('   Covers: ${prediction.musclesCovered.join(', ')}');
    }

    return prediction;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('❌ [PredictiveBalance] Prediction error: $e');
      debugPrint('   $st');
    }
    return null;
  }
});

// ====================
// ALL MISSING WORKOUTS PROVIDER
// ====================

/// Provider for all missing workouts this week
///
/// Returns a list of all predicted missing workouts (not just the first one).
final allMissingWorkoutsProvider =
    FutureProvider.autoDispose<List<PatternPrediction>>((ref) async {
      try {
        // Get pattern
        final pattern = await ref.watch(weeklyPatternProvider.future);
        if (pattern == null || !pattern.isValid) return [];

        // Get this week's workouts
        final thisWeek = await ref.watch(thisWeekWorkoutsProvider.future);

        // Get muscle map
        final muscleMap = await ref.watch(exerciseMuscleMapProvider.future);

        // Get templates for suggestions
        List<dynamic>? templates;
        try {
          templates = await ref.watch(customWorkoutTemplatesProvider.future);
        } catch (_) {
          // Templates are optional
        }

        // Predict all missing workouts
        return PredictionEngineService.predictAll(
          pattern: pattern,
          thisWeekWorkouts: thisWeek,
          muscleMap: muscleMap,
          templates: templates?.cast(),
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [PredictiveBalance] Prediction error: $e');
        }
        return [];
      }
    });

// ====================
// MUSCLE RESOLUTION PROVIDER
// ====================

/// Provider to check if a specific muscle would be resolved by completing the pattern
///
/// **Usage**:
/// ```dart
/// // In a neglected muscle card
/// final wouldResolve = ref.watch(muscleWouldBeResolvedProvider('quadriceps'));
/// if (wouldResolve.value == true) {
///   // Show "Complete Leg Day to resolve ✓"
/// }
/// ```
final muscleWouldBeResolvedProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, muscleName) async {
      try {
        // Get pattern
        final pattern = await ref.watch(weeklyPatternProvider.future);
        if (pattern == null || !pattern.isValid) return false;

        // Get this week's workouts
        final thisWeek = await ref.watch(thisWeekWorkoutsProvider.future);

        // Get muscle map
        final muscleMap = await ref.watch(exerciseMuscleMapProvider.future);

        return PredictionEngineService.wouldResolveMuscle(
          pattern: pattern,
          thisWeekWorkouts: thisWeek,
          muscleMap: muscleMap,
          muscleName: muscleName,
        );
      } catch (_) {
        return false;
      }
    });

// ====================
// PATTERN SUMMARY PROVIDER
// ====================

/// Provider for a human-readable pattern summary
///
/// Returns a string like "Push → Pull → Legs (3 workouts/week)"
/// or null if no pattern detected.
final patternSummaryProvider = Provider.autoDispose<String?>((ref) {
  final pattern = ref.watch(weeklyPatternProvider).value;
  if (pattern == null || !pattern.isValid) return null;

  return pattern.description;
});

// ====================
// WEEK COMPLETION STATUS PROVIDER
// ====================

/// Provider for week completion status
///
/// Returns a tuple-like class with completion info.
final weekCompletionStatusProvider =
    FutureProvider.autoDispose<WeekCompletionStatus>((ref) async {
      final pattern = await ref.watch(weeklyPatternProvider.future);
      final thisWeek = await ref.watch(thisWeekWorkoutsProvider.future);
      final missing = await ref.watch(allMissingWorkoutsProvider.future);

      if (pattern == null || !pattern.isValid) {
        return WeekCompletionStatus(
          hasPattern: false,
          expectedWorkouts: 0,
          completedWorkouts: thisWeek.length,
          missingWorkouts: 0,
          isComplete: false,
        );
      }

      final completed = pattern.cycle.length - missing.length;

      return WeekCompletionStatus(
        hasPattern: true,
        expectedWorkouts: pattern.cycle.length,
        completedWorkouts: completed,
        missingWorkouts: missing.length,
        isComplete: missing.isEmpty,
      );
    });

/// Week completion status data class
class WeekCompletionStatus {
  const WeekCompletionStatus({
    required this.hasPattern,
    required this.expectedWorkouts,
    required this.completedWorkouts,
    required this.missingWorkouts,
    required this.isComplete,
  });

  /// Whether a valid pattern was detected
  final bool hasPattern;

  /// Number of workouts expected per week based on pattern
  final int expectedWorkouts;

  /// Number of workouts completed this week
  final int completedWorkouts;

  /// Number of workouts still missing
  final int missingWorkouts;

  /// Whether all expected workouts are complete
  final bool isComplete;

  /// Progress percentage (0.0 - 1.0)
  double get progressPercentage {
    if (expectedWorkouts == 0) return 0.0;
    return completedWorkouts / expectedWorkouts;
  }

  /// Display string like "2/3 workouts"
  String get displayString => '$completedWorkouts/$expectedWorkouts';
}
