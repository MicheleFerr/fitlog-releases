import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/models/user_fitness_profile.dart';

/// Advanced Muscle Efficiency Calculator
/// Calculates a sensitive, real-time efficiency score based on multiple factors
class MuscleEfficiencyCalculator {
  
  /// Calculate comprehensive muscle efficiency score (0-100)
  static MuscleEfficiencyScore calculate({
    required List<ExerciseActivity> recentActivities,
    required DateTime currentDate,
    UserFitnessProfile? userProfile,
  }) {
    if (recentActivities.isEmpty) {
      return MuscleEfficiencyScore.empty();
    }

    // Get activities from last 30 days
    final thirtyDaysAgo = currentDate.subtract(const Duration(days: 30));
    final relevantActivities = recentActivities
        .where((a) => a.createdAt.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (relevantActivities.isEmpty) {
      return MuscleEfficiencyScore.empty();
    }

    // 1. Volume Progression (30% weight)
    final volumeScore = _calculateVolumeProgression(relevantActivities);
    
    // 2. Recovery Efficiency (25% weight)
    final recoveryScore = _calculateRecoveryEfficiency(relevantActivities);
    
    // 3. Intensity Management (20% weight)
    final intensityScore = _calculateIntensityManagement(relevantActivities);
    
    // 4. Consistency Score (15% weight)
    final consistencyScore = _calculateConsistency(relevantActivities, currentDate);
    
    // 5. Progressive Overload (10% weight)
    final overloadScore = _calculateProgressiveOverload(relevantActivities);

    // Weighted average
    final totalScore = (volumeScore * 0.30) +
                      (recoveryScore * 0.25) +
                      (intensityScore * 0.20) +
                      (consistencyScore * 0.15) +
                      (overloadScore * 0.10);

    // Determine trend
    final trend = _calculateTrend(relevantActivities);
    
    // Get insights
    final insights = _generateInsights(
      volumeScore: volumeScore,
      recoveryScore: recoveryScore,
      intensityScore: intensityScore,
      consistencyScore: consistencyScore,
      overloadScore: overloadScore,
    );

    return MuscleEfficiencyScore(
      score: totalScore.round(),
      components: {
        'volume': volumeScore,
        'recovery': recoveryScore,
        'intensity': intensityScore,
        'consistency': consistencyScore,
        'overload': overloadScore,
      },
      trend: trend,
      insights: insights,
      lastCalculated: currentDate,
    );
  }

  /// Calculate volume progression efficiency
  static double _calculateVolumeProgression(List<ExerciseActivity> activities) {
    if (activities.length < 2) return 50.0;

    final volumes = <DateTime, double>{};
    
    for (final activity in activities) {
      final date = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );
      
      double volume = 0;
      for (final set in activity.sets) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;
        volume += weight * reps;
      }
      
      volumes[date] = (volumes[date] ?? 0) + volume;
    }

    if (volumes.length < 2) return 50.0;

    // Calculate week-over-week progression
    final weeks = _groupByWeek(volumes);
    if (weeks.length < 2) return 50.0;

    double progressionScore = 50.0;
    final weeksList = weeks.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    
    for (int i = 1; i < weeksList.length; i++) {
      final prevWeek = weeksList[i - 1].value;
      final currWeek = weeksList[i].value;
      
      if (prevWeek > 0) {
        final change = (currWeek - prevWeek) / prevWeek;
        
        // Optimal progression is 2-5% per week
        if (change >= 0.02 && change <= 0.05) {
          progressionScore += 10;
        } else if (change > 0 && change < 0.02) {
          progressionScore += 5; // Too slow
        } else if (change > 0.05 && change <= 0.10) {
          progressionScore += 7; // A bit too fast
        } else if (change > 0.10) {
          progressionScore -= 5; // Too fast, risk of injury
        } else if (change < 0) {
          progressionScore -= 10; // Regression
        }
      }
    }

    return progressionScore.clamp(0, 100);
  }

  /// Calculate recovery efficiency based on workout spacing
  static double _calculateRecoveryEfficiency(List<ExerciseActivity> activities) {
    if (activities.length < 2) return 50.0;

    // Group by muscle groups
    final muscleGroupWorkouts = <String, List<DateTime>>{};
    
    for (final activity in activities) {
      final muscle = _getMuscleGroup(activity.exerciseName);
      muscleGroupWorkouts[muscle] ??= [];
      muscleGroupWorkouts[muscle]!.add(activity.createdAt);
    }

    double totalScore = 0;
    int groupCount = 0;

    for (final entry in muscleGroupWorkouts.entries) {
      final workouts = entry.value..sort();
      if (workouts.length < 2) continue;

      double groupScore = 100.0;
      
      for (int i = 1; i < workouts.length; i++) {
        final daysBetween = workouts[i].difference(workouts[i - 1]).inDays;
        
        // Optimal recovery is 2-4 days for same muscle group
        if (daysBetween >= 2 && daysBetween <= 4) {
          // Perfect recovery
        } else if (daysBetween == 1) {
          groupScore -= 15; // Too soon
        } else if (daysBetween == 5 || daysBetween == 6) {
          groupScore -= 5; // Slightly long
        } else if (daysBetween >= 7) {
          groupScore -= 10; // Too long, losing adaptation
        } else if (daysBetween == 0) {
          groupScore -= 25; // Same day - poor recovery
        }
      }
      
      totalScore += groupScore.clamp(0, 100);
      groupCount++;
    }

    return groupCount > 0 ? totalScore / groupCount : 50.0;
  }

  /// Calculate intensity management (effort distribution)
  static double _calculateIntensityManagement(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return 50.0;

    final efforts = <int>[];
    
    for (final activity in activities) {
      for (final set in activity.sets) {
        if (set.effort != null) {
          efforts.add(set.effort!);
        }
      }
    }

    if (efforts.isEmpty) return 50.0;

    // Calculate distribution
    final avgEffort = efforts.reduce((a, b) => a + b) / efforts.length;
    
    // Count high intensity (8-10), medium (5-7), low (1-4)
    int high = efforts.where((e) => e >= 8).length;
    int medium = efforts.where((e) => e >= 5 && e < 8).length;
    int low = efforts.where((e) => e < 5).length;
    
    final total = efforts.length;
    final highPercent = high / total;
    final mediumPercent = medium / total;
    final lowPercent = low / total;

    // Optimal distribution: 20% high, 60% medium, 20% low
    double score = 100.0;
    
    // Penalize too much high intensity
    if (highPercent > 0.30) {
      score -= (highPercent - 0.30) * 100;
    }
    
    // Reward balanced approach
    if (mediumPercent >= 0.50 && mediumPercent <= 0.70) {
      score += 10;
    }
    
    // Ensure some easy work for recovery
    if (lowPercent < 0.10) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  /// Calculate workout consistency
  static double _calculateConsistency(List<ExerciseActivity> activities, DateTime currentDate) {
    if (activities.isEmpty) return 0.0;

    // Get unique workout days
    final workoutDays = <DateTime>{};
    for (final activity in activities) {
      workoutDays.add(DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      ));
    }

    // Calculate weeks
    final weeks = <int>{};
    for (final day in workoutDays) {
      weeks.add(_getWeekNumber(day));
    }

    // Score based on consistency
    final avgWorkoutsPerWeek = workoutDays.length / 4; // Last 30 days ≈ 4 weeks
    
    double score = 0;
    if (avgWorkoutsPerWeek >= 3 && avgWorkoutsPerWeek <= 5) {
      score = 100; // Optimal frequency
    } else if (avgWorkoutsPerWeek >= 2 && avgWorkoutsPerWeek < 3) {
      score = 70;
    } else if (avgWorkoutsPerWeek > 5 && avgWorkoutsPerWeek <= 6) {
      score = 80; // Good but watch recovery
    } else if (avgWorkoutsPerWeek > 6) {
      score = 60; // Too much, risk of overtraining
    } else {
      score = avgWorkoutsPerWeek * 35; // Linear scale for low frequency
    }

    // Bonus for streak
    final streak = _calculateStreak(workoutDays, currentDate);
    if (streak >= 7) score += 10;
    if (streak >= 14) score += 5;
    if (streak >= 21) score += 5;

    return score.clamp(0, 100);
  }

  /// Calculate progressive overload quality
  static double _calculateProgressiveOverload(List<ExerciseActivity> activities) {
    if (activities.length < 4) return 50.0;

    // Track max weights per exercise
    final exerciseProgress = <String, List<double>>{};
    
    for (final activity in activities) {
      exerciseProgress[activity.exerciseName] ??= [];
      
      double maxWeight = 0;
      for (final set in activity.sets) {
        final weight = double.tryParse(set.weight) ?? 0;
        if (weight > maxWeight) maxWeight = weight;
      }
      
      if (maxWeight > 0) {
        exerciseProgress[activity.exerciseName]!.add(maxWeight);
      }
    }

    double totalScore = 0;
    int validExercises = 0;

    for (final weights in exerciseProgress.values) {
      if (weights.length < 2) continue;
      
      // Check for progression
      bool hasProgression = false;
      for (int i = 1; i < weights.length; i++) {
        if (weights[i] > weights[i - 1]) {
          hasProgression = true;
          break;
        }
      }
      
      if (hasProgression) {
        totalScore += 100;
      } else {
        totalScore += 50; // Maintenance is okay
      }
      validExercises++;
    }

    return validExercises > 0 ? totalScore / validExercises : 50.0;
  }

  /// Calculate trend over time
  static EfficiencyTrend _calculateTrend(List<ExerciseActivity> activities) {
    if (activities.length < 7) return EfficiencyTrend.stable;

    // Compare last week to previous week
    final oneWeekAgo = activities.last.createdAt.subtract(const Duration(days: 7));
    final twoWeeksAgo = activities.last.createdAt.subtract(const Duration(days: 14));
    
    final lastWeek = activities.where((a) => a.createdAt.isAfter(oneWeekAgo)).toList();
    final prevWeek = activities.where((a) => 
      a.createdAt.isAfter(twoWeeksAgo) && a.createdAt.isBefore(oneWeekAgo)
    ).toList();

    if (lastWeek.isEmpty || prevWeek.isEmpty) return EfficiencyTrend.stable;

    final lastWeekVolume = _calculateTotalVolume(lastWeek);
    final prevWeekVolume = _calculateTotalVolume(prevWeek);

    final change = (lastWeekVolume - prevWeekVolume) / prevWeekVolume;

    if (change > 0.05) return EfficiencyTrend.improving;
    if (change < -0.05) return EfficiencyTrend.declining;
    return EfficiencyTrend.stable;
  }

  /// Generate actionable insights
  static List<String> _generateInsights({
    required double volumeScore,
    required double recoveryScore,
    required double intensityScore,
    required double consistencyScore,
    required double overloadScore,
  }) {
    final insights = <String>[];

    // Volume insights
    if (volumeScore < 50) {
      insights.add('Consider gradually increasing training volume by 2-5% weekly');
    } else if (volumeScore > 90) {
      insights.add('Excellent volume progression! Maintain current approach');
    }

    // Recovery insights
    if (recoveryScore < 60) {
      insights.add('Allow 2-3 days between training same muscle groups');
    } else if (recoveryScore > 85) {
      insights.add('Recovery timing is optimal');
    }

    // Intensity insights
    if (intensityScore < 50) {
      insights.add('Balance high and moderate intensity work better');
    }

    // Consistency insights
    if (consistencyScore < 60) {
      insights.add('Aim for 3-4 workouts per week for optimal results');
    }

    // Progressive overload insights
    if (overloadScore < 50) {
      insights.add('Focus on gradually increasing weights or reps');
    }

    return insights;
  }

  // Helper methods
  static String _getMuscleGroup(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('chest') || lower.contains('bench')) return 'chest';
    if (lower.contains('back') || lower.contains('row') || lower.contains('pull')) return 'back';
    if (lower.contains('shoulder') || lower.contains('press')) return 'shoulders';
    if (lower.contains('bicep') || lower.contains('tricep') || lower.contains('curl')) return 'arms';
    if (lower.contains('squat') || lower.contains('leg')) return 'legs';
    if (lower.contains('core') || lower.contains('ab')) return 'core';
    return 'other';
  }

  static Map<DateTime, double> _groupByWeek(Map<DateTime, double> daily) {
    final weekly = <DateTime, double>{};
    
    for (final entry in daily.entries) {
      final weekStart = _getWeekStart(entry.key);
      weekly[weekStart] = (weekly[weekStart] ?? 0) + entry.value;
    }
    
    return weekly;
  }

  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirst = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirst / 7).floor();
  }

  static int _calculateStreak(Set<DateTime> workoutDays, DateTime currentDate) {
    if (workoutDays.isEmpty) return 0;
    
    final sortedDays = workoutDays.toList()..sort();
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    int streak = 0;
    DateTime checkDate = today;
    
    while (sortedDays.contains(checkDate) || 
           sortedDays.contains(checkDate.subtract(const Duration(days: 1)))) {
      if (sortedDays.contains(checkDate)) streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (checkDate.isBefore(sortedDays.first)) break;
    }
    
    return streak;
  }

  static double _calculateTotalVolume(List<ExerciseActivity> activities) {
    double total = 0;
    for (final activity in activities) {
      for (final set in activity.sets) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;
        total += weight * reps;
      }
    }
    return total;
  }
}

/// Muscle Efficiency Score model
class MuscleEfficiencyScore {
  final int score;
  final Map<String, double> components;
  final EfficiencyTrend trend;
  final List<String> insights;
  final DateTime lastCalculated;

  MuscleEfficiencyScore({
    required this.score,
    required this.components,
    required this.trend,
    required this.insights,
    required this.lastCalculated,
  });

  factory MuscleEfficiencyScore.empty() {
    return MuscleEfficiencyScore(
      score: 0,
      components: {},
      trend: EfficiencyTrend.stable,
      insights: ['Start tracking workouts to see your efficiency score'],
      lastCalculated: DateTime.now(),
    );
  }

  Color get color {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  String get label {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 50) return 'Needs Work';
    return 'Poor';
  }
}

enum EfficiencyTrend {
  improving,
  stable,
  declining,
}