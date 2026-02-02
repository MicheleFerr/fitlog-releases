/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/services
/// Feature: analytics
/// Type: service
///
/// Analytics Calculation Service - Business logic for analytics calculations
///
/// **Purpose**: Extract heavy business logic from AnalyticsNotifier (THIN provider pattern)
///
/// **Responsibilities**:
/// - Volume calculations by period
/// - 1RM progression calculations
/// - Exercise trend analysis
/// - Frequency stats computation
/// - Streak calculations
/// - Personal records tracking
///
/// **Usage**:
/// ```dart
/// final service = AnalyticsCalculationService();
/// final volumeData = service.getVolumeByPeriod(activities, AnalysisPeriod.week);
/// final progression = service.get1RMProgression(activities, 'exercise123');
/// final stats = service.getFrequencyStats(activities);
/// ```
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

/// Service for analytics calculations (extracted from AnalyticsNotifier)
///
/// **Design**: Pure stateless service - all methods are static or instance methods without state
class AnalyticsCalculationService {
  /// Get volume data for specific period
  ///
  /// **Parameters**:
  /// - `activities`: List of exercise activities
  /// - `period`: Time period (week/month/quarter/year)
  ///
  /// **Returns**: Map of DateTime → volume (kg)
  ///
  /// **Example**:
  /// ```dart
  /// final service = AnalyticsCalculationService();
  /// final volumeData = service.getVolumeByPeriod(activities, AnalysisPeriod.week);
  /// // {2025-01-08: 1200.0, 2025-01-15: 1350.0, ...}
  /// ```
  Map<DateTime, double> getVolumeByPeriod(
    List<ExerciseActivity> activities,
    AnalysisPeriod period,
  ) {
    final volumeData = <DateTime, double>{};

    for (final activity in activities) {
      DateTime periodKey;

      switch (period) {
        case AnalysisPeriod.week:
          final weekStart = _getWeekStart(activity.createdAt);
          periodKey = weekStart;
        case AnalysisPeriod.month:
          periodKey = DateTime(
            activity.createdAt.year,
            activity.createdAt.month,
          );
        case AnalysisPeriod.quarter:
          final quarter = ((activity.createdAt.month - 1) ~/ 3) + 1;
          periodKey = DateTime(activity.createdAt.year, (quarter - 1) * 3 + 1);
        case AnalysisPeriod.year:
          periodKey = DateTime(activity.createdAt.year);
      }

      final volume = VolumeCalculator.calculateTotalVolume(activity.sets);
      volumeData[periodKey] = (volumeData[periodKey] ?? 0) + volume;
    }

    return volumeData;
  }

  /// Get 1RM progression for an exercise
  ///
  /// **Parameters**:
  /// - `activities`: All exercise activities
  /// - `exerciseId`: Exercise ID to filter
  ///
  /// **Returns**: Map of DateTime → estimated 1RM (kg)
  ///
  /// **Calculation**: Uses OneRMCalculator.calculateAverage (multi-formula average)
  ///
  /// **Example**:
  /// ```dart
  /// final progression = service.get1RMProgression(activities, 'bench-press-123');
  /// // {2025-01-01: 100.0, 2025-01-08: 102.5, 2025-01-15: 105.0}
  /// ```
  Map<DateTime, double> get1RMProgression(
    List<ExerciseActivity> activities,
    String exerciseId,
  ) {
    final progression = <DateTime, double>{};

    final exerciseActivities =
        activities.where((a) => a.exerciseId == exerciseId).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (final activity in exerciseActivities) {
      double max1RM = 0;

      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;

        if (weight > 0 && reps > 0) {
          final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
          if (estimated1RM > max1RM) {
            max1RM = estimated1RM;
          }
        }
      }

      if (max1RM > 0) {
        progression[activity.createdAt] = max1RM;
      }
    }

    return progression;
  }

  /// Get workout frequency stats
  ///
  /// **Returns**:
  /// ```dart
  /// {
  ///   'daysInLast30': 12,
  ///   'avgPerWeek': 3,
  ///   'dayDistribution': {1: 2, 2: 3, 3: 2, 5: 3, 6: 2}, // Monday to Saturday
  ///   'currentStreak': 5
  /// }
  /// ```
  ///
  /// **Use Case**: Dashboard stats, frequency heatmaps
  Map<String, dynamic> getFrequencyStats(List<ExerciseActivity> activities) {
    final stats = <String, dynamic>{};

    // Last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentActivities = activities
        .where((a) => a.createdAt.isAfter(thirtyDaysAgo))
        .toList();

    // Unique workout days
    final workoutDays = recentActivities
        .map(
          (a) => DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day),
        )
        .toSet();

    stats['daysInLast30'] = workoutDays.length;
    stats['avgPerWeek'] = (workoutDays.length / 4.3).round();

    // Day distribution
    final dayDistribution = <int, int>{};
    for (final activity in recentActivities) {
      final dayOfWeek = activity.createdAt.weekday;
      dayDistribution[dayOfWeek] = (dayDistribution[dayOfWeek] ?? 0) + 1;
    }
    stats['dayDistribution'] = dayDistribution;

    // Current streak
    stats['currentStreak'] = calculateCurrentStreak(activities);

    return stats;
  }

  /// Get exercise-specific stats
  ///
  /// **Parameters**:
  /// - `activities`: All activities
  /// - `exerciseId`: Exercise to analyze
  ///
  /// **Returns**:
  /// ```dart
  /// {
  ///   'volumeStats': {...},
  ///   'maxWeight': 120.0,
  ///   'maxReps': 12,
  ///   'estimated1RM': 140.0,
  ///   'trend': TrendAnalysis(...),
  ///   'plateau': PlateauStatus(...)
  /// }
  /// ```
  Map<String, dynamic> getExerciseStats(
    List<ExerciseActivity> activities,
    String exerciseId,
  ) {
    final exerciseActivities = activities
        .where((a) => a.exerciseId == exerciseId)
        .toList();

    if (exerciseActivities.isEmpty) {
      return {};
    }

    final stats = <String, dynamic>{};

    // Volume stats
    final volumeStats = VolumeCalculator.getVolumeStats(exerciseActivities);
    stats['volumeStats'] = volumeStats;

    // Best performance
    double maxWeight = 0;
    int maxReps = 0;
    double max1RM = 0;

    for (final activity in exerciseActivities) {
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;

        if (weight > maxWeight) maxWeight = weight;
        if (reps > maxReps) maxReps = reps;

        if (weight > 0 && reps > 0) {
          final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
          if (estimated1RM > max1RM) max1RM = estimated1RM;
        }
      }
    }

    stats['maxWeight'] = maxWeight;
    stats['maxReps'] = maxReps;
    stats['estimated1RM'] = max1RM;

    // Trend
    final trend = TrendAnalyzer.analyzeStrengthTrend(activities, exerciseId);
    stats['trend'] = trend;

    // Plateau detection
    final plateau = TrendAnalyzer.detectPlateau(activities, exerciseId);
    stats['plateau'] = plateau;

    return stats;
  }

  /// Calculate exercise trends for top N exercises
  ///
  /// **Parameters**:
  /// - `activities`: All activities
  /// - `limit`: Number of top exercises (default 5)
  ///
  /// **Returns**: Map of exerciseId → TrendAnalysis
  ///
  /// **Logic**: Sorts by frequency, takes top N, analyzes strength trend
  Future<Map<String, TrendAnalysis>> calculateExerciseTrends(
    List<ExerciseActivity> activities, {
    int limit = 5,
  }) async {
    final trends = <String, TrendAnalysis>{};

    // Get top N exercises by frequency
    final exerciseCounts = <String, int>{};
    for (final activity in activities) {
      exerciseCounts[activity.exerciseId] =
          (exerciseCounts[activity.exerciseId] ?? 0) + 1;
    }

    final topExercises = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final exercise in topExercises.take(limit)) {
      trends[exercise.key] = TrendAnalyzer.analyzeStrengthTrend(
        activities,
        exercise.key,
      );
    }

    return trends;
  }

  /// Calculate current workout streak
  ///
  /// **Logic**:
  /// - Must have workout today OR yesterday to continue streak
  /// - Counts consecutive days with at least 1 workout
  /// - Breaks on first day without workout
  ///
  /// **Returns**: Number of consecutive days (0 if streak broken)
  int calculateCurrentStreak(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return 0;

    final sortedActivities = activities.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final uniqueDates =
        sortedActivities
            .map(
              (a) => DateTime(
                a.createdAt.year,
                a.createdAt.month,
                a.createdAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    // Check if last workout was today or yesterday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (uniqueDates.first != today && uniqueDates.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i - 1].difference(uniqueDates[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Get start of week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }
}
