/// Sleep-Workout Correlation Service
///
/// Calculates recovery scores and correlations between sleep patterns
/// and workout performance.
///
/// **Scientific Basis**:
/// - Res et al.: -22% MPS with sleep deprivation
/// - Knowles et al.: Reduced strength output with <6h sleep
/// - AASM: 7-9h recommended for adults
/// - Skein et al. 2011: Cumulative decline with consecutive sleep restriction
library;


import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Service for calculating sleep-workout correlations and recovery insights
class SleepWorkoutCorrelationService {
  /// Calculate recovery insight from sleep and workout data
  ///
  /// **Formula**:
  /// ```
  /// FinalScore = BaseScore × SleepModifier × ConsecutivePenalty
  /// ```
  ///
  /// **Base Score** (from workout history):
  /// - Days since last workout: optimal 1-3 days
  /// - Weekly frequency adherence
  /// - Training consistency streak
  ///
  /// **Sleep Modifier**:
  /// - <6h average: ×0.70 (critical)
  /// - 6-7h average: ×0.85 (suboptimal)
  /// - 7-9h average: ×1.00 (optimal)
  /// - >9h average: ×0.95 (excessive)
  ///
  /// **Consecutive Bad Nights Penalty**:
  /// - 2 consecutive <6h: -5%
  /// - 3+ consecutive <6h: -10%
  RecoveryInsight calculateRecovery({
    required List<SleepRecord> sleepHistory,
    required List<Workout> workoutHistory,
    SleepWorkoutCorrelation? correlation,
  }) {
    // Handle no sleep data case
    if (sleepHistory.isEmpty) {
      return RecoveryInsight.noData();
    }

    // Calculate base metrics
    final lastNightSleep = sleepHistory.isNotEmpty
        ? sleepHistory.first.asleepDuration
        : Duration.zero;

    final weeklyAverageHours = _calculateWeeklyAverage(sleepHistory);
    final consecutiveBadNights = _countConsecutiveBadNights(sleepHistory);
    final streakDays = _countGoodSleepStreak(sleepHistory);

    // Calculate base score from workout history
    final baseScore = _calculateBaseScore(workoutHistory);

    // Apply sleep modifier
    final sleepModifier = _getSleepModifier(weeklyAverageHours);

    // Apply consecutive bad nights penalty
    final consecutivePenalty = _getConsecutivePenalty(consecutiveBadNights);

    // Calculate final score
    final rawScore = baseScore * sleepModifier * consecutivePenalty;
    final finalScore = rawScore.round().clamp(0, 100);

    // Determine category and recommendation
    final category = RecoveryCategoryExtension.fromScore(finalScore);
    final recommendation = _getRecommendation(
      category,
      weeklyAverageHours,
      consecutiveBadNights,
    );

    if (kDebugMode) {
      debugPrint('[RecoveryInsight] Base: $baseScore, '
          'SleepMod: $sleepModifier, '
          'ConsecPenalty: $consecutivePenalty, '
          'Final: $finalScore');
    }

    return RecoveryInsight(
      score: finalScore,
      category: category,
      recommendation: recommendation,
      lastNightSleep: lastNightSleep,
      weeklyAverageHours: weeklyAverageHours,
      consecutiveBadNights: consecutiveBadNights,
      streakDays: streakDays,
      correlation: correlation,
      calculatedAt: DateTime.now(),
      hasSleepData: true,
      baseScore: baseScore,
      sleepModifier: sleepModifier,
      consecutivePenalty: consecutivePenalty,
    );
  }

  /// Calculate correlation between sleep and workout performance
  ///
  /// Analyzes how sleep duration affects workout volume.
  ///
  /// **Returns**:
  /// - volumeChangeAbove7h: % change in volume with >7h sleep
  /// - volumeChangeBelow6h: % change in volume with <6h sleep
  SleepWorkoutCorrelation calculateCorrelation({
    required List<SleepRecord> sleepHistory,
    required List<Workout> workoutHistory,
    int periodDays = 30,
  }) {
    if (sleepHistory.isEmpty || workoutHistory.isEmpty) {
      return SleepWorkoutCorrelation.noData();
    }

    // Build data points by matching workout dates with previous night's sleep
    final dataPoints = <SleepWorkoutDataPoint>[];

    for (final workout in workoutHistory) {
      // Skip incomplete workouts
      if (workout.exercises.isEmpty) continue;

      // Find previous night's sleep
      final workoutDate = workout.completedAt;
      if (workoutDate == null) continue; // Skip workouts without completion date
      final previousNight = _findPreviousNightSleep(sleepHistory, workoutDate);

      if (previousNight != null) {
        final volume = _calculateWorkoutVolume(workout);

        dataPoints.add(SleepWorkoutDataPoint(
          workoutDate: workoutDate,
          sleepHours: previousNight.asleepHours,
          workoutVolume: volume,
          workoutDurationMinutes: workout.duration?.inMinutes ?? 0,
          exerciseCount: workout.exercises.length,
        ));
      }
    }

    if (dataPoints.isEmpty) {
      return SleepWorkoutCorrelation.noData();
    }

    // Separate into good sleep (>7h) and poor sleep (<6h) groups
    final goodSleepWorkouts =
        dataPoints.where((dp) => dp.sleepHours >= 7).toList();
    final poorSleepWorkouts =
        dataPoints.where((dp) => dp.sleepHours < 6).toList();
    final allWorkouts = dataPoints;

    // Calculate average volumes
    final overallAvgVolume = _averageVolume(allWorkouts);
    final goodSleepAvgVolume = goodSleepWorkouts.isNotEmpty
        ? _averageVolume(goodSleepWorkouts)
        : overallAvgVolume;
    final poorSleepAvgVolume = poorSleepWorkouts.isNotEmpty
        ? _averageVolume(poorSleepWorkouts)
        : overallAvgVolume;

    // Calculate percentage changes
    final volumeChangeAbove7h = overallAvgVolume > 0
        ? ((goodSleepAvgVolume - overallAvgVolume) / overallAvgVolume) * 100
        : 0.0;
    final volumeChangeBelow6h = overallAvgVolume > 0
        ? ((poorSleepAvgVolume - overallAvgVolume) / overallAvgVolume) * 100
        : 0.0;

    // Determine significance (need at least 3 data points in each category)
    final isSignificant =
        goodSleepWorkouts.length >= 3 && poorSleepWorkouts.length >= 3;

    // Detect sleep pattern
    final sleepPattern = _detectSleepPattern(
      goodSleepWorkouts.length,
      poorSleepWorkouts.length,
      dataPoints.length,
    );

    // Calculate overall averages
    final avgSleepHours = dataPoints.isNotEmpty
        ? dataPoints.fold<double>(0, (sum, dp) => sum + dp.sleepHours) /
            dataPoints.length
        : 0.0;

    if (kDebugMode) {
      debugPrint('[Correlation] Good sleep workouts: ${goodSleepWorkouts.length}, '
          'Poor sleep workouts: ${poorSleepWorkouts.length}, '
          'Pattern: ${sleepPattern.name}');
      debugPrint('[Correlation] Volume change >7h: ${volumeChangeAbove7h.toStringAsFixed(1)}%, '
          '<6h: ${volumeChangeBelow6h.toStringAsFixed(1)}%');
    }

    return SleepWorkoutCorrelation(
      volumeChangeAbove7h: volumeChangeAbove7h,
      volumeChangeBelow6h: volumeChangeBelow6h,
      workoutSampleSize: dataPoints.length,
      sleepSampleSize: sleepHistory.length,
      isSignificant: isSignificant,
      periodDays: periodDays,
      workoutsWithGoodSleep: goodSleepWorkouts.length,
      workoutsWithPoorSleep: poorSleepWorkouts.length,
      sleepPattern: sleepPattern,
      averageSleepHours: avgSleepHours,
      averageVolume: overallAvgVolume,
    );
  }

  /// Detect user's sleep pattern based on workout distribution
  ///
  /// - **Variable**: Has at least 2 workouts in both good and poor sleep categories
  /// - **Consistently good**: 80%+ workouts with ≥7h sleep
  /// - **Consistently poor**: 80%+ workouts with <6h sleep
  /// - **Unknown**: Not enough data or mixed pattern
  SleepPattern _detectSleepPattern(
    int goodSleepCount,
    int poorSleepCount,
    int totalCount,
  ) {
    if (totalCount < 5) {
      return SleepPattern.unknown;
    }

    final goodRatio = goodSleepCount / totalCount;
    final poorRatio = poorSleepCount / totalCount;

    // Variable: has significant data in both categories
    if (goodSleepCount >= 2 && poorSleepCount >= 2) {
      return SleepPattern.variable;
    }

    // Consistently good: 80%+ good sleep
    if (goodRatio >= 0.8) {
      return SleepPattern.consistentlyGood;
    }

    // Consistently poor: 80%+ poor sleep
    if (poorRatio >= 0.8) {
      return SleepPattern.consistentlyPoor;
    }

    // Mixed pattern (moderate sleep 6-7h mostly) - treat as variable
    return SleepPattern.variable;
  }

  // ==========================================
  // PRIVATE HELPER METHODS
  // ==========================================

  /// Calculate base score from workout history (0-100)
  double _calculateBaseScore(List<Workout> workoutHistory) {
    if (workoutHistory.isEmpty) {
      return 75; // Default "good" when no workout data
    }

    // Filter to only workouts with completion dates and sort by date descending
    final completedWorkouts = workoutHistory
        .where((w) => w.completedAt != null)
        .toList();

    if (completedWorkouts.isEmpty) {
      return 75; // Default "good" when no completed workouts
    }

    final sorted = completedWorkouts
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    // Days since last workout (optimal: 1-3 days)
    final lastWorkout = sorted.first;
    final daysSinceLastWorkout =
        DateTime.now().difference(lastWorkout.completedAt!).inDays;

    double daysScore;
    if (daysSinceLastWorkout <= 1) {
      daysScore = 90; // Just worked out
    } else if (daysSinceLastWorkout <= 3) {
      daysScore = 100; // Optimal recovery window
    } else if (daysSinceLastWorkout <= 5) {
      daysScore = 80; // Could use a workout
    } else {
      daysScore = 60; // Been too long
    }

    // Weekly frequency (last 7 days)
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final workoutsThisWeek =
        sorted.where((w) => w.completedAt!.isAfter(weekAgo)).length;

    double frequencyScore;
    if (workoutsThisWeek >= 4) {
      frequencyScore = 100; // Active week
    } else if (workoutsThisWeek >= 2) {
      frequencyScore = 85; // Moderate week
    } else if (workoutsThisWeek >= 1) {
      frequencyScore = 70; // Light week
    } else {
      frequencyScore = 50; // No workouts
    }

    // Consistency (workouts in last 14 days)
    final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
    final workoutsLastTwoWeeks =
        sorted.where((w) => w.completedAt!.isAfter(twoWeeksAgo)).length;

    double consistencyScore;
    if (workoutsLastTwoWeeks >= 6) {
      consistencyScore = 100; // Very consistent
    } else if (workoutsLastTwoWeeks >= 4) {
      consistencyScore = 85; // Consistent
    } else if (workoutsLastTwoWeeks >= 2) {
      consistencyScore = 70; // Somewhat consistent
    } else {
      consistencyScore = 50; // Inconsistent
    }

    // Weighted average
    return (daysScore * 0.4) + (frequencyScore * 0.3) + (consistencyScore * 0.3);
  }

  /// Get sleep modifier based on average hours
  double _getSleepModifier(double averageHours) {
    if (averageHours < 6) {
      return 0.70; // Critical: -30%
    } else if (averageHours < 7) {
      return 0.85; // Suboptimal: -15%
    } else if (averageHours <= 9) {
      return 1.00; // Optimal: no change
    } else {
      return 0.95; // Excessive: -5%
    }
  }

  /// Get penalty for consecutive bad nights
  double _getConsecutivePenalty(int consecutiveBadNights) {
    if (consecutiveBadNights >= 3) {
      return 0.90; // -10% for 3+ consecutive bad nights
    } else if (consecutiveBadNights >= 2) {
      return 0.95; // -5% for 2 consecutive bad nights
    } else {
      return 1.00; // No penalty
    }
  }

  /// Calculate weekly average sleep hours
  double _calculateWeeklyAverage(List<SleepRecord> sleepHistory) {
    if (sleepHistory.isEmpty) return 0;

    // Only consider last 7 days
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentSleep =
        sleepHistory.where((s) => s.date.isAfter(weekAgo)).toList();

    if (recentSleep.isEmpty) return 0;

    final totalHours =
        recentSleep.fold<double>(0, (sum, s) => sum + s.asleepHours);
    return totalHours / recentSleep.length;
  }

  /// Count consecutive nights with <6h sleep (starting from most recent)
  int _countConsecutiveBadNights(List<SleepRecord> sleepHistory) {
    if (sleepHistory.isEmpty) return 0;

    // Sort by date descending (most recent first)
    final sorted = List<SleepRecord>.from(sleepHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int count = 0;
    for (final record in sorted) {
      if (record.isBadNight) {
        count++;
      } else {
        break; // Stop counting at first non-bad night
      }
    }

    return count;
  }

  /// Count consecutive nights meeting sleep goal (7h+)
  int _countGoodSleepStreak(List<SleepRecord> sleepHistory) {
    if (sleepHistory.isEmpty) return 0;

    // Sort by date descending
    final sorted = List<SleepRecord>.from(sleepHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int count = 0;
    for (final record in sorted) {
      if (record.meetsRecommendation) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }

  /// Find sleep record for the night before a workout
  SleepRecord? _findPreviousNightSleep(
    List<SleepRecord> sleepHistory,
    DateTime workoutDate,
  ) {
    final previousNightDate = DateTime(
      workoutDate.year,
      workoutDate.month,
      workoutDate.day - 1,
    );

    try {
      return sleepHistory.firstWhere(
        (s) =>
            s.date.year == previousNightDate.year &&
            s.date.month == previousNightDate.month &&
            s.date.day == previousNightDate.day,
      );
    } catch (_) {
      return null;
    }
  }

  /// Calculate total workout volume (simplified)
  double _calculateWorkoutVolume(Workout workout) {
    double totalVolume = 0;

    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          // Volume = weight × reps
          final weight = set.weight ?? 0;
          final reps = set.reps ?? 0;
          totalVolume += weight * reps;
        }
      }
    }

    return totalVolume;
  }

  /// Calculate average volume from data points
  double _averageVolume(List<SleepWorkoutDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.fold<double>(0, (sum, dp) => sum + dp.workoutVolume) /
        dataPoints.length;
  }

  /// Get recommendation KEY based on recovery state
  ///
  /// Returns a key string that should be localized in presentation layer.
  /// Keys: 'consecutive_bad_3', 'consecutive_bad_2', 'optimal', 'good',
  ///       'moderate', 'low', 'critical'
  String _getRecommendation(
    RecoveryCategory category,
    double avgSleepHours,
    int consecutiveBadNights,
  ) {
    // Prioritize consecutive bad nights warning
    if (consecutiveBadNights >= 3) {
      return 'consecutive_bad_3:$consecutiveBadNights';
    }

    if (consecutiveBadNights >= 2) {
      return 'consecutive_bad_2';
    }

    // Then use category-based recommendations
    return category.name;
  }
}
