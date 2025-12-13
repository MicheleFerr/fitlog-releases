/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/providers
/// Feature: analytics
/// Type: provider
///
/// Weekly Analytics Provider - encapsulates all calculations for the simplified
/// analytics dashboard.
///
/// Architecture:
/// - FutureProvider for async data loading
/// - Depends on historicalWorkoutsProvider and appConfigProvider
/// - Calculates weekly metrics, top exercises, and recent workouts
/// - Auto-disposes when not needed (memory optimization)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/top_exercises_section.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/dashboard/recent_activity_section.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Data model for weekly analytics
class WeeklyAnalyticsData {
  const WeeklyAnalyticsData({
    required this.weeklyWorkoutCount,
    required this.previousWeekWorkoutCount,
    this.weeklyGoal,
    required this.weeklyVolume,
    required this.currentStreak,
    required this.weeklyPRCount,
    required this.measurementUnit,
    required this.muscleVolumePercentages,
    required this.topExercises,
    required this.recentWorkouts,
  });

  final int weeklyWorkoutCount;
  final int previousWeekWorkoutCount;
  final int? weeklyGoal;
  final double weeklyVolume;
  final int currentStreak;
  final int weeklyPRCount;
  final String measurementUnit;
  final Map<String, double> muscleVolumePercentages;
  final List<TopExerciseData> topExercises;
  final List<RecentWorkoutData> recentWorkouts;
}

/// Provider for weekly analytics dashboard data
///
/// Auto-disposes when not in use to free memory.
/// Depends on:
/// - historicalWorkoutsProvider for workout data
/// - appConfigProvider for measurement unit
final weeklyAnalyticsProvider = FutureProvider.autoDispose<WeeklyAnalyticsData>((ref) async {
  final workouts = await ref.watch(historicalWorkoutsProvider.future);
  final appConfig = ref.watch(appConfigProvider);
  final measurementUnit = appConfig.measurementUnit;

  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));

  // Filter workouts by week (nullable startTime check)
  final thisWeekWorkouts = workouts.where((w) {
    final date = w.startTime;
    return date != null && date.isAfter(startOfWeek);
  }).toList();

  final previousWeekWorkouts = workouts.where((w) {
    final date = w.startTime;
    return date != null &&
           date.isAfter(startOfPreviousWeek) &&
           date.isBefore(startOfWeek);
  }).toList();

  // Calculate weekly volume
  double weeklyVolume = 0;
  for (final workout in thisWeekWorkouts) {
    for (final ex in workout.exercises) {
      for (final set in ex.sets) {
        if (set.isCompleted) {
          weeklyVolume += (set.weight ?? 0) * (set.reps ?? 0);
        }
      }
    }
  }

  // Calculate muscle/category volumes for heatmap
  final categoryVolumes = <String, double>{};
  double maxVolume = 0;
  for (final workout in thisWeekWorkouts) {
    for (final ex in workout.exercises) {
      final volume = ex.sets
          .where((s) => s.isCompleted)
          .fold<double>(0, (sum, s) => sum + (s.weight ?? 0) * (s.reps ?? 0));
      final categoryKey = ex.category.name;
      categoryVolumes[categoryKey] = (categoryVolumes[categoryKey] ?? 0) + volume;
      if (categoryVolumes[categoryKey]! > maxVolume) {
        maxVolume = categoryVolumes[categoryKey]!;
      }
    }
  }

  // Normalize to percentages (0-100)
  final muscleVolumePercentages = <String, double>{};
  if (maxVolume > 0) {
    for (final entry in categoryVolumes.entries) {
      muscleVolumePercentages[entry.key] =
          (entry.value / maxVolume * 100).clamp(0.0, 100.0);
    }
  }

  // Build top exercises with weight tracking
  final exerciseCounts = <String, int>{};
  final exerciseLastSets = <String, (double, int)>{};
  final exerciseWeightDeltas = <String, double>{};

  // Collect this week's data
  for (final workout in thisWeekWorkouts) {
    for (final ex in workout.exercises) {
      exerciseCounts[ex.name] = (exerciseCounts[ex.name] ?? 0) + 1;
      final completedSets = ex.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isNotEmpty) {
        final lastSet = completedSets.last;
        exerciseLastSets[ex.name] = (lastSet.weight ?? 0, lastSet.reps ?? 0);
      }
    }
  }

  // Calculate weight deltas from previous week
  final previousWeekExerciseWeights = <String, double>{};
  for (final workout in previousWeekWorkouts) {
    for (final ex in workout.exercises) {
      final completedSets = ex.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isNotEmpty) {
        final avgWeight = completedSets
            .map((s) => s.weight ?? 0)
            .reduce((a, b) => a + b) / completedSets.length;
        previousWeekExerciseWeights[ex.name] = avgWeight;
      }
    }
  }

  for (final exerciseName in exerciseCounts.keys) {
    final currentWeight = exerciseLastSets[exerciseName]?.$1 ?? 0;
    final previousWeight = previousWeekExerciseWeights[exerciseName] ?? 0;
    exerciseWeightDeltas[exerciseName] = previousWeight > 0
        ? currentWeight - previousWeight
        : 0;
  }

  final topExercises = exerciseCounts.entries
      .where((e) => exerciseLastSets.containsKey(e.key))
      .map((e) => TopExerciseData(
            name: e.key,
            sessionCount: e.value,
            lastWeight: exerciseLastSets[e.key]!.$1,
            lastReps: exerciseLastSets[e.key]!.$2,
            weightDelta: exerciseWeightDeltas[e.key]!,
            measurementUnit: measurementUnit,
          ))
      .toList()
    ..sort((a, b) => b.sessionCount.compareTo(a.sessionCount));

  // Build recent workouts (sorted by date)
  final sortedWorkouts = [...thisWeekWorkouts]
    ..sort((a, b) => (b.startTime ?? DateTime(2000))
        .compareTo(a.startTime ?? DateTime(2000)));

  final recentWorkouts = sortedWorkouts.take(5).map((w) {
    double vol = 0;
    final categories = <String>{};
    for (final ex in w.exercises) {
      categories.add(ex.category.name);
      for (final set in ex.sets) {
        if (set.isCompleted) {
          vol += (set.weight ?? 0) * (set.reps ?? 0);
        }
      }
    }
    return RecentWorkoutData(
      id: w.id,
      name: w.name,
      date: w.startTime ?? DateTime.now(),
      durationMinutes: w.duration?.inMinutes ?? 0,
      exerciseCount: w.exercises.length,
      totalVolume: vol,
      muscleGroups: categories.toList(),
    );
  }).toList();

  return WeeklyAnalyticsData(
    weeklyWorkoutCount: thisWeekWorkouts.length,
    previousWeekWorkoutCount: previousWeekWorkouts.length,
    weeklyGoal: null, // TODO: Add to AppConfig or separate settings
    weeklyVolume: weeklyVolume,
    currentStreak: 0, // TODO: Get from streak provider
    weeklyPRCount: 0, // TODO: Get from PR provider
    measurementUnit: measurementUnit,
    muscleVolumePercentages: muscleVolumePercentages,
    topExercises: topExercises.take(10).toList(),
    recentWorkouts: recentWorkouts,
  );
});
