import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Provider that aggregates exercise data from all completed workouts
final exerciseProgressMetricsProvider = Provider<Map<String, ExerciseProgressMetrics>>((ref) {
  final workoutsAsync = ref.watch(historicalWorkoutsProvider);

  return workoutsAsync.when(
    data: (workouts) => _aggregateExerciseData(workouts),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider for a specific exercise's metrics
final exerciseMetricsProvider = Provider.family<ExerciseProgressMetrics?, String>((ref, exerciseName) {
  final allMetrics = ref.watch(exerciseProgressMetricsProvider);
  return allMetrics[exerciseName];
});

/// Aggregate exercise data from all workouts
Map<String, ExerciseProgressMetrics> _aggregateExerciseData(
  List<Workout> workouts,
) {
  // Map to store all sets grouped by exercise name
  final Map<String, List<ExerciseSetData>> exerciseSets = {};
  final Map<String, DateTime> lastWorkoutDates = {};

  // Extract all completed sets from all workouts
  for (final workout in workouts) {
    if (workout.status != WorkoutStatus.completed) continue;

    final workoutDate = workout.endTime ?? workout.createdAt;

    for (final exercise in workout.exercises) {
      // Only include exercises with completed sets
      final completedSets = exercise.sets.where((s) => s.isCompleted).toList();
      if (completedSets.isEmpty) continue;

      final exerciseName = exercise.name;

      // Initialize list if not exists
      if (!exerciseSets.containsKey(exerciseName)) {
        exerciseSets[exerciseName] = [];
        lastWorkoutDates[exerciseName] = workoutDate;
      }

      // Update last workout date if this is more recent
      if (workoutDate.isAfter(lastWorkoutDates[exerciseName]!)) {
        lastWorkoutDates[exerciseName] = workoutDate;
      }

      // Add all completed sets
      for (final set in completedSets) {
        exerciseSets[exerciseName]!.add(
          ExerciseSetData(
            date: set.completedAt ?? workoutDate,
            weight: set.weight ?? 0.0,
            reps: set.actualReps ?? set.reps ?? 0,
            rpe: set.rpe,
            volume: (set.weight ?? 0.0) * (set.actualReps ?? set.reps ?? 0),
            workoutName: workout.name,
          ),
        );
      }
    }
  }

  // Calculate metrics for each exercise
  final Map<String, ExerciseProgressMetrics> metrics = {};

  for (final entry in exerciseSets.entries) {
    final exerciseName = entry.key;
    final sets = entry.value;

    if (sets.isEmpty) continue;

    // Sort sets by date (oldest first) for trend calculation
    sets.sort((a, b) => a.date.compareTo(b.date));

    // Calculate statistics
    final maxWeight = sets.fold<double>(
      0,
      (max, set) => set.weight > max ? set.weight : max,
    );

    final averageWeight = sets.fold<double>(
      0,
      (sum, set) => sum + set.weight,
    ) / sets.length;

    final averageReps = sets.fold<double>(
      0,
      (sum, set) => sum + set.reps,
    ) / sets.length;

    final setsWithRPE = sets.where((s) => s.rpe != null).toList();
    final averageRPE = setsWithRPE.isNotEmpty
        ? setsWithRPE.fold<double>(
            0,
            (sum, set) => sum + (set.rpe ?? 0),
          ) / setsWithRPE.length
        : 0.0;

    final totalVolume = sets.fold<double>(
      0,
      (sum, set) => sum + set.volume,
    );

    // Count unique workout sessions
    final uniqueDates = sets.map((s) => _dateOnly(s.date)).toSet();
    final totalSessions = uniqueDates.length;

    // Calculate trends
    final weightTrend = sets.calculateWeightTrend();
    final volumeTrend = sets.calculateVolumeTrend();

    metrics[exerciseName] = ExerciseProgressMetrics(
      exerciseName: exerciseName,
      totalSessions: totalSessions,
      maxWeight: maxWeight,
      averageWeight: averageWeight,
      averageReps: averageReps,
      averageRPE: averageRPE,
      totalVolume: totalVolume,
      lastWorkoutDate: lastWorkoutDates[exerciseName]!,
      weightTrend: weightTrend,
      volumeTrend: volumeTrend,
      allSets: sets,
    );
  }

  return metrics;
}

/// Helper to get date without time
DateTime _dateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}
