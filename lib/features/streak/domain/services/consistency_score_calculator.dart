/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/streak/domain/services
/// 🎯 Feature: streak
/// 🔧 Type: service
///
/// Consistency Score Calculator - Calculates workout adherence quality metrics
library;

import 'package:gymbro_flutter_new/features/streak/domain/entities/consistency_score.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/weekly_stats.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Service for calculating consistency scores from workout data
class ConsistencyScoreCalculator {
  /// Optimal workout frequency range (workouts per week)
  static const double _optimalFrequencyMin = 3.0;
  static const double _optimalFrequencyMax = 5.0;

  /// Optimal rest days range per week
  static const double _optimalRestDaysMin = 2.0;
  static const double _optimalRestDaysMax = 3.0;

  /// Minimum workouts for progression calculation
  static const int _minWorkoutsForProgression = 5;

  /// Calculate complete consistency score from workout history
  ///
  /// [workouts] - List of completed workouts (last 30 days recommended)
  /// [currentStreak] - Current consecutive workout days
  /// [longestStreak] - Longest consecutive workout days achieved
  ConsistencyScore calculateScore({
    required List<Workout> workouts,
    required int currentStreak,
    required int longestStreak,
  }) {
    if (workouts.isEmpty) {
      return ConsistencyScore.empty();
    }

    // Calculate weekly statistics
    final weeklyStats = _calculateWeeklyStats(workouts);

    // Calculate component scores
    final frequencyScore = _calculateFrequencyScore(weeklyStats.avgWorkoutsPerWeek);
    final restScore = _calculateRestScore(weeklyStats.avgRestDaysPerWeek);
    final volumeScore = _calculateVolumeScore(workouts);
    final progressionScore = _calculateProgressionScore(workouts);

    // Calculate overall score (weighted average)
    final overallScore = _calculateOverallScore(
      frequencyScore: frequencyScore,
      restScore: restScore,
      volumeScore: volumeScore,
      progressionScore: progressionScore,
    );

    // Determine score rating
    final scoreRating = _getScoreRating(overallScore);

    // Calculate overtraining risk
    final overtrainingRisk = _calculateOvertrainingRisk(
      avgWorkoutsPerWeek: weeklyStats.avgWorkoutsPerWeek,
      avgRestDaysPerWeek: weeklyStats.avgRestDaysPerWeek,
      volumeTrend: _getVolumeTrend(workouts),
    );

    return ConsistencyScore(
      overallScore: overallScore,
      scoreRating: scoreRating,
      rating: scoreRating, // Backward compatibility
      riskLevel: _getRiskLevelString(overtrainingRisk),
      overtrainingRisk: overtrainingRisk,
      frequencyScore: frequencyScore,
      restScore: restScore,
      volumeScore: volumeScore,
      progressionScore: progressionScore,
      weeklyStats: weeklyStats,
      workoutsCompleted: workouts.length,
      workoutsSkipped: 0, // TODO: Calculate from scheduled vs completed
      avgFrequency: weeklyStats.avgWorkoutsPerWeek,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate weekly statistics from workout history
  WeeklyStats _calculateWeeklyStats(List<Workout> workouts) {
    if (workouts.isEmpty) {
      return WeeklyStats.empty();
    }

    // Sort workouts by date (use endTime if available, else createdAt)
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) {
        final aDate = a.endTime ?? a.createdAt;
        final bDate = b.endTime ?? b.createdAt;
        return aDate.compareTo(bDate);
      });

    final oldestDate = sortedWorkouts.first.endTime ?? sortedWorkouts.first.createdAt;
    final newestDate = sortedWorkouts.last.endTime ?? sortedWorkouts.last.createdAt;
    final daysSpan = newestDate.difference(oldestDate).inDays + 1;
    final weeksSpan = daysSpan / 7.0;

    // Count active days (days with at least one workout)
    final activeDays = <DateTime>{};
    for (final workout in workouts) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      final dateOnly = DateTime(
        workoutDate.year,
        workoutDate.month,
        workoutDate.day,
      );
      activeDays.add(dateOnly);
    }

    final totalActiveDays = activeDays.length;
    final totalWorkouts = workouts.length;
    final totalRestDays = daysSpan - totalActiveDays;

    // Calculate averages per week
    final avgWorkoutsPerWeek = weeksSpan > 0 ? totalWorkouts / weeksSpan : 0.0;
    final avgRestDaysPerWeek = weeksSpan > 0 ? totalRestDays / weeksSpan : 7.0;

    return WeeklyStats(
      avgWorkoutsPerWeek: avgWorkoutsPerWeek,
      avgRestDaysPerWeek: avgRestDaysPerWeek,
      totalWorkouts: totalWorkouts,
      totalRestDays: totalRestDays,
      totalActiveDays: totalActiveDays,
      weekStartDate: oldestDate,
      weekEndDate: newestDate,
    );
  }

  /// Calculate frequency score (0-100)
  ///
  /// Optimal range: 3-5 workouts per week
  /// Score = 100 when in optimal range
  /// Score decreases as frequency moves away from optimal
  int _calculateFrequencyScore(double avgWorkoutsPerWeek) {
    if (avgWorkoutsPerWeek >= _optimalFrequencyMin &&
        avgWorkoutsPerWeek <= _optimalFrequencyMax) {
      return 100; // Perfect frequency
    }

    // Too few workouts
    if (avgWorkoutsPerWeek < _optimalFrequencyMin) {
      final score = (avgWorkoutsPerWeek / _optimalFrequencyMin) * 100;
      return score.round().clamp(0, 100);
    }

    // Too many workouts (overtraining risk)
    final excessRatio = (avgWorkoutsPerWeek - _optimalFrequencyMax) / _optimalFrequencyMax;
    final penalty = (excessRatio * 50).round(); // 50% penalty for 2x excess
    return (100 - penalty).clamp(0, 100);
  }

  /// Calculate rest score (0-100)
  ///
  /// Optimal range: 2-3 rest days per week
  /// Score = 100 when in optimal range
  int _calculateRestScore(double avgRestDaysPerWeek) {
    if (avgRestDaysPerWeek >= _optimalRestDaysMin &&
        avgRestDaysPerWeek <= _optimalRestDaysMax) {
      return 100; // Perfect rest
    }

    // Too few rest days (overtraining risk)
    if (avgRestDaysPerWeek < _optimalRestDaysMin) {
      final score = (avgRestDaysPerWeek / _optimalRestDaysMin) * 100;
      return score.round().clamp(0, 100);
    }

    // Too many rest days (undertraining)
    final excessRatio = (avgRestDaysPerWeek - _optimalRestDaysMax) / 7.0;
    final penalty = (excessRatio * 100).round();
    return (100 - penalty).clamp(0, 100);
  }

  /// Calculate volume score (0-100)
  ///
  /// Based on total volume trend over time
  /// Increasing or stable volume = higher score
  int _calculateVolumeScore(List<Workout> workouts) {
    if (workouts.length < 3) {
      return 50; // Not enough data, neutral score
    }

    final volumeTrend = _getVolumeTrend(workouts);

    if (volumeTrend > 0.1) {
      return 100; // Increasing volume (good progression)
    } else if (volumeTrend >= -0.1) {
      return 80; // Stable volume (maintaining)
    } else if (volumeTrend >= -0.3) {
      return 60; // Slightly decreasing (warning)
    } else {
      return 40; // Significantly decreasing (concern)
    }
  }

  /// Calculate progression score (0-100)
  ///
  /// Based on weight/rep improvements over time
  int _calculateProgressionScore(List<Workout> workouts) {
    if (workouts.length < _minWorkoutsForProgression) {
      return 50; // Not enough data, neutral score
    }

    // Calculate average weight per workout
    final avgWeights = workouts.map((workout) {
      final totalWeight = workout.exercises.fold<double>(
        0.0,
        (sum, exercise) => sum + exercise.sets.fold<double>(
          0.0,
          (setSum, set) => setSum + ((set.weight ?? 0.0) * (set.reps ?? 0)),
        ),
      );
      final totalSets = workout.exercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.sets.length,
      );
      return totalSets > 0 ? totalWeight / totalSets : 0.0;
    }).toList();

    if (avgWeights.length < 2) {
      return 50;
    }

    // Compare recent half vs older half
    final midPoint = avgWeights.length ~/ 2;
    final olderHalf = avgWeights.sublist(0, midPoint);
    final recentHalf = avgWeights.sublist(midPoint);

    final olderAvg = olderHalf.reduce((a, b) => a + b) / olderHalf.length;
    final recentAvg = recentHalf.reduce((a, b) => a + b) / recentHalf.length;

    if (olderAvg == 0) {
      return 50;
    }

    final improvement = (recentAvg - olderAvg) / olderAvg;

    if (improvement > 0.15) {
      return 100; // Excellent progression (>15% improvement)
    } else if (improvement > 0.05) {
      return 85; // Good progression (5-15% improvement)
    } else if (improvement >= -0.05) {
      return 70; // Maintaining (±5%)
    } else {
      return 50; // Regressing
    }
  }

  /// Calculate overall score as weighted average
  int _calculateOverallScore({
    required int frequencyScore,
    required int restScore,
    required int volumeScore,
    required int progressionScore,
  }) {
    // Weights for each component
    const frequencyWeight = 0.30; // 30% - most important
    const restWeight = 0.25; // 25% - recovery crucial
    const volumeWeight = 0.25; // 25% - workload important
    const progressionWeight = 0.20; // 20% - long-term indicator

    final weighted = (frequencyScore * frequencyWeight) +
        (restScore * restWeight) +
        (volumeScore * volumeWeight) +
        (progressionScore * progressionWeight);

    return weighted.round().clamp(0, 100);
  }

  /// Calculate volume trend from workout history
  ///
  /// Returns positive value for increasing trend, negative for decreasing
  double _getVolumeTrend(List<Workout> workouts) {
    if (workouts.length < 3) {
      return 0.0;
    }

    // Calculate total volume per workout (sum of all sets)
    final volumes = workouts.map((workout) {
      return workout.exercises.fold<double>(
        0.0,
        (sum, exercise) => sum + exercise.sets.fold<double>(
          0.0,
          (setSum, set) => setSum + ((set.weight ?? 0.0) * (set.reps ?? 0)),
        ),
      );
    }).toList();

    // Compare recent half vs older half
    final midPoint = volumes.length ~/ 2;
    final olderHalf = volumes.sublist(0, midPoint);
    final recentHalf = volumes.sublist(midPoint);

    final olderAvg = olderHalf.reduce((a, b) => a + b) / olderHalf.length;
    final recentAvg = recentHalf.reduce((a, b) => a + b) / recentHalf.length;

    if (olderAvg == 0) {
      return 0.0;
    }

    return (recentAvg - olderAvg) / olderAvg; // Return ratio of change
  }

  /// Check if frequency is in optimal range (3-5 workouts/week)
  ///
  /// Evidence: Schoenfeld et al. 2019 (PMID: 30558493)
  /// - 2x/week vs 3x/week: identical results if volume equated
  /// - Range 3-5 validated for general population hypertrophy
  /// - Ralston et al. 2018 (PMID: 30076500): ES 0.03, p=0.78 (no difference)
  bool isFrequencyOptimal(double avgWorkoutsPerWeek) {
    return avgWorkoutsPerWeek >= _optimalFrequencyMin &&
        avgWorkoutsPerWeek <= _optimalFrequencyMax;
  }

  /// Check if rest is in optimal range (2-3 rest days/week)
  ///
  /// Evidence: UCLA Health 2024
  /// - <2 rest days = 5.2x injury risk increase
  /// - ACE Guidelines: 2-3 days optimal for general population
  /// - UCHealth: 1-2 days for advanced, 2-3 for beginners
  bool isRestOptimal(double avgRestDaysPerWeek) {
    return avgRestDaysPerWeek >= _optimalRestDaysMin &&
        avgRestDaysPerWeek <= _optimalRestDaysMax;
  }

  /// Check if progression is positive (>5% improvement)
  ///
  /// Evidence: NASM 2023 - Progressive Overload Guidelines
  /// - Optimal increment: +5-10% per week
  /// - Threshold: >5% improvement indicates positive progression
  /// - Maintaining ±5% acceptable, >5% is active progress
  bool isProgressionPositive(List<Workout> workouts) {
    if (workouts.length < _minWorkoutsForProgression) {
      return false; // Not enough data to determine progression
    }

    final improvement = _calculateProgressionRatio(workouts);
    return improvement >= 0.05; // >5% improvement threshold
  }

  /// Calculate progression ratio (recent vs older average)
  ///
  /// Returns positive value for improvement, negative for regression
  double _calculateProgressionRatio(List<Workout> workouts) {
    if (workouts.length < 2) return 0.0;

    // Calculate average weight per set for each workout
    final avgWeights = workouts.map((workout) {
      final totalWeight = workout.exercises.fold<double>(
        0.0,
        (sum, exercise) => sum + exercise.sets.fold<double>(
          0.0,
          (setSum, set) => setSum + ((set.weight ?? 0.0) * (set.reps ?? 0)),
        ),
      );
      final totalSets = workout.exercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.sets.length,
      );
      return totalSets > 0 ? totalWeight / totalSets : 0.0;
    }).toList();

    // Compare recent 50% vs older 50%
    final midPoint = avgWeights.length ~/ 2;
    final olderHalf = avgWeights.sublist(0, midPoint);
    final recentHalf = avgWeights.sublist(midPoint);

    final olderAvg = olderHalf.reduce((a, b) => a + b) / olderHalf.length;
    final recentAvg = recentHalf.reduce((a, b) => a + b) / recentHalf.length;

    if (olderAvg == 0) return 0.0;

    return (recentAvg - olderAvg) / olderAvg; // Return ratio of change
  }

  /// Calculate overtraining risk level
  OvertrainingRisk _calculateOvertrainingRisk({
    required double avgWorkoutsPerWeek,
    required double avgRestDaysPerWeek,
    required double volumeTrend,
  }) {
    // Risk factors
    final tooManyWorkouts = avgWorkoutsPerWeek > 6.0;
    final tooFewRestDays = avgRestDaysPerWeek < 1.0;
    final rapidVolumeIncrease = volumeTrend > 0.5; // >50% increase

    final riskFactors = [
      if (tooManyWorkouts) 1,
      if (tooFewRestDays) 1,
      if (rapidVolumeIncrease) 1,
    ].fold(0, (sum, factor) => sum + factor);

    if (riskFactors >= 2) {
      return OvertrainingRisk.high;
    } else if (riskFactors == 1) {
      return OvertrainingRisk.medium;
    } else {
      return OvertrainingRisk.low;
    }
  }

  /// Get score rating text
  String _getScoreRating(int score) {
    if (score >= 85) {
      return 'Excellent';
    } else if (score >= 70) {
      return 'Good';
    } else if (score >= 50) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  /// Get risk level string from enum
  String _getRiskLevelString(OvertrainingRisk risk) {
    switch (risk) {
      case OvertrainingRisk.low:
        return 'Low';
      case OvertrainingRisk.medium:
        return 'Medium';
      case OvertrainingRisk.high:
        return 'High';
    }
  }
}
