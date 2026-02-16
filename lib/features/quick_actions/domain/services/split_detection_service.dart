/// Split Detection Service
///
/// Pure Dart service for workout split pattern detection.
/// Analyzes workout history to suggest the next muscle group to train.
///
/// All methods are static for easy testing and no dependencies.
library;

import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

/// Result of split detection analysis
class SplitDetectionResult {
  const SplitDetectionResult({
    required this.type,
    this.suggestedCategory,
    this.detectedCycle,
    this.daysSinceLastForCategory,
    this.isImbalanceDetected = false,
  });

  /// Type of detection result
  final SplitDetectionType type;

  /// Suggested next category to train
  final ExerciseCategory? suggestedCategory;

  /// Detected cycle pattern (e.g. [chest, legs, back, shoulders])
  final List<ExerciseCategory>? detectedCycle;

  /// Days since last training for the suggested category
  final int? daysSinceLastForCategory;

  /// Whether a muscle imbalance was detected
  final bool isImbalanceDetected;
}

/// Type of split detection outcome
enum SplitDetectionType {
  /// A repeating cycle pattern was detected
  patternDetected,

  /// No pattern, suggestion based on most rested muscle group
  recoveryBased,

  /// A muscle group has been neglected (>7 days, active user)
  imbalanceDetected,

  /// New user with <4 workouts
  newUser,
}

/// Pure service for detecting workout split patterns
class SplitDetectionService {
  const SplitDetectionService._();

  /// Categories to exclude from split detection (not muscle groups)
  static const _excludedCategories = {
    ExerciseCategory.cardio,
    ExerciseCategory.other,
  };

  /// Analyze workout history and detect split pattern
  ///
  /// [workouts] should be the last 21 days of completed workouts,
  /// sorted by completedAt descending (newest first).
  /// [recoveryData] optional map of category -> hours since last workout
  static SplitDetectionResult detect({
    required List<WorkoutHistoryDetail> workouts,
    Map<ExerciseCategory, int>? recoveryHoursPerCategory,
  }) {
    // New user: <4 workouts
    if (workouts.length < 4) {
      return const SplitDetectionResult(type: SplitDetectionType.newUser);
    }

    // Step 1: Get dominant category per workout (chronological order)
    final dominantCategories = _getDominantCategories(workouts);

    if (dominantCategories.isEmpty) {
      return const SplitDetectionResult(type: SplitDetectionType.newUser);
    }

    // Step 2: Try pattern detection
    final cycle = _detectCycle(dominantCategories);

    // Step 3: Calculate days since last for each category
    final daysSinceLastMap = _daysSinceLastPerCategory(workouts);

    if (cycle != null) {
      // Pattern found - determine next in rotation
      final lastCategory = dominantCategories.last;
      final lastIndex = cycle.indexOf(lastCategory);
      final nextCategory = cycle[(lastIndex + 1) % cycle.length];
      final daysSinceLast = daysSinceLastMap[nextCategory];

      return SplitDetectionResult(
        type: SplitDetectionType.patternDetected,
        suggestedCategory: nextCategory,
        detectedCycle: cycle,
        daysSinceLastForCategory: daysSinceLast,
      );
    }

    // Step 4: Check for imbalance (category >7 days, user active 2+ in 7 days)
    final recentWorkouts = workouts.where((w) {
      final daysDiff = DateTime.now().difference(w.completedAt).inDays;
      return daysDiff <= 7;
    }).length;

    if (recentWorkouts >= 2) {
      // Find most neglected muscle group
      for (final entry in daysSinceLastMap.entries) {
        if (entry.value > 7) {
          return SplitDetectionResult(
            type: SplitDetectionType.imbalanceDetected,
            suggestedCategory: entry.key,
            daysSinceLastForCategory: entry.value,
            isImbalanceDetected: true,
          );
        }
      }
    }

    // Step 5: Fallback recovery-based - suggest most rested category
    final mostRested = _getMostRestedCategory(
      daysSinceLastMap,
      recoveryHoursPerCategory,
    );

    return SplitDetectionResult(
      type: SplitDetectionType.recoveryBased,
      suggestedCategory: mostRested,
      daysSinceLastForCategory: daysSinceLastMap[mostRested],
    );
  }

  /// Get the dominant ExerciseCategory for each workout
  ///
  /// Returns categories in chronological order (oldest first).
  /// Excludes cardio and other.
  static List<ExerciseCategory> _getDominantCategories(
    List<WorkoutHistoryDetail> workouts,
  ) {
    final result = <ExerciseCategory>[];

    // Sort oldest first for pattern detection
    final sorted = List<WorkoutHistoryDetail>.from(workouts)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    for (final workout in sorted) {
      final categoryCounts = <ExerciseCategory, int>{};

      for (final exercise in workout.exercises) {
        final category = ExerciseCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == exercise.category.toLowerCase(),
          orElse: () => ExerciseCategory.other,
        );

        if (_excludedCategories.contains(category)) continue;

        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      if (categoryCounts.isNotEmpty) {
        // Find category with most exercises
        final dominant = categoryCounts.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );
        result.add(dominant.key);
      }
    }

    return result;
  }

  /// Detect a repeating cycle pattern in the category sequence
  ///
  /// Tries cycle lengths 2..7, requires at least 2 full repetitions.
  /// Allows 1 mismatch per cycle (tolerance for occasional off-pattern).
  static List<ExerciseCategory>? _detectCycle(
    List<ExerciseCategory> sequence,
  ) {
    if (sequence.length < 4) return null;

    for (var cycleLen = 2; cycleLen <= 7; cycleLen++) {
      // Need at least 2 full repetitions
      if (sequence.length < cycleLen * 2) continue;

      final candidate = sequence.sublist(0, cycleLen);
      var totalMismatches = 0;
      var fullCycles = 0;

      for (var i = cycleLen; i + cycleLen <= sequence.length; i += cycleLen) {
        var cycleMismatches = 0;
        for (var j = 0; j < cycleLen; j++) {
          if (sequence[i + j] != candidate[j]) {
            cycleMismatches++;
          }
        }
        // Allow 1 mismatch per cycle
        if (cycleMismatches <= 1) {
          totalMismatches += cycleMismatches;
          fullCycles++;
        } else {
          break;
        }
      }

      // At least 1 additional full cycle found (= 2 total repetitions)
      if (fullCycles >= 1 && totalMismatches <= fullCycles) {
        return candidate;
      }
    }

    return null;
  }

  /// Calculate days since last workout for each trained category
  ///
  /// Returns map sorted by days descending (most rested first).
  static Map<ExerciseCategory, int> _daysSinceLastPerCategory(
    List<WorkoutHistoryDetail> workouts,
  ) {
    final lastTrainedMap = <ExerciseCategory, DateTime>{};
    final now = DateTime.now();

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        final category = ExerciseCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == exercise.category.toLowerCase(),
          orElse: () => ExerciseCategory.other,
        );

        if (_excludedCategories.contains(category)) continue;

        final existing = lastTrainedMap[category];
        if (existing == null || workout.completedAt.isAfter(existing)) {
          lastTrainedMap[category] = workout.completedAt;
        }
      }
    }

    // Convert to days since last
    final daysSinceMap = <ExerciseCategory, int>{};
    for (final entry in lastTrainedMap.entries) {
      daysSinceMap[entry.key] = now.difference(entry.value).inDays;
    }

    // Sort by days descending (most rested first)
    final sortedEntries = daysSinceMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  /// Get the most rested category (highest days since last workout)
  static ExerciseCategory? _getMostRestedCategory(
    Map<ExerciseCategory, int> daysSinceLastMap,
    Map<ExerciseCategory, int>? recoveryHoursPerCategory,
  ) {
    if (daysSinceLastMap.isEmpty) return null;

    // If we have recovery data, use it to weight the suggestion
    if (recoveryHoursPerCategory != null &&
        recoveryHoursPerCategory.isNotEmpty) {
      // Score = days since last / (recovery hours needed / 24)
      // Higher score = more rested relative to needs
      double bestScore = -1;
      ExerciseCategory? bestCategory;

      for (final entry in daysSinceLastMap.entries) {
        final recoveryDays =
            (recoveryHoursPerCategory[entry.key] ?? 72) / 24.0;
        final score = entry.value / recoveryDays;
        if (score > bestScore) {
          bestScore = score;
          bestCategory = entry.key;
        }
      }

      return bestCategory;
    }

    // Simple fallback: most days since last
    return daysSinceLastMap.entries.first.key;
  }
}
