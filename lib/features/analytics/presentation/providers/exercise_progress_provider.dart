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
///
/// Tries multiple sources:
/// 1. First: from aggregated workout data (exerciseProgressMetricsProvider)
/// 2. Fallback: from Firebase analytics collection (exerciseHistoryByNameProvider)
final exerciseMetricsProvider = Provider.family<ExerciseProgressMetrics?, String>((ref, exerciseName) {
  final allMetrics = ref.watch(exerciseProgressMetricsProvider);

  // Try exact match first
  if (allMetrics.containsKey(exerciseName)) {
    return allMetrics[exerciseName];
  }

  // Try case-insensitive match
  final normalizedName = exerciseName.toLowerCase().trim();
  for (final entry in allMetrics.entries) {
    if (entry.key.toLowerCase().trim() == normalizedName) {
      return entry.value;
    }
  }

  return null;
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

/// Convert ExerciseHistory (from Firebase analytics) to ExerciseProgressMetrics
///
/// This allows ExerciseDetailScreen to use Firebase analytics data
/// when workout data is not available (e.g., name mismatch)
ExerciseProgressMetrics? convertHistoryToMetrics(
  dynamic history, // ExerciseHistory from analytics_providers.dart
) {
  if (history == null) return null;

  try {
    // Extract exerciseName from history object
    final String exerciseName = history.exerciseName;
    final sessions = history.sessions as List;

    if (sessions.isEmpty) return null;

    // Convert sessions to ExerciseSetData
    final List<ExerciseSetData> allSets = [];

    for (final session in sessions) {
      final sessionDate = session.date as DateTime;
      final sets = session.sets as List;

      for (final set in sets) {
        allSets.add(ExerciseSetData(
          date: set.date ?? sessionDate,
          weight: (set.weight as num).toDouble(),
          reps: set.reps as int,
          rpe: null, // AnalyticsSet doesn't have RPE
          volume: (set.weight as num).toDouble() * (set.reps as int),
          workoutName: session.exerciseName ?? exerciseName,
        ));
      }
    }

    if (allSets.isEmpty) return null;

    // Sort by date
    allSets.sort((a, b) => a.date.compareTo(b.date));

    // Calculate statistics
    final maxWeight =
        allSets.fold<double>(0, (max, set) => set.weight > max ? set.weight : max);
    final averageWeight =
        allSets.fold<double>(0, (sum, set) => sum + set.weight) / allSets.length;
    final averageReps =
        allSets.fold<double>(0, (sum, set) => sum + set.reps) / allSets.length;
    final totalVolume =
        allSets.fold<double>(0, (sum, set) => sum + set.volume);
    final uniqueDates = allSets.map((s) => _dateOnly(s.date)).toSet();
    final totalSessions = uniqueDates.length;
    final lastWorkoutDate = allSets.last.date;

    return ExerciseProgressMetrics(
      exerciseName: exerciseName,
      totalSessions: totalSessions,
      maxWeight: maxWeight,
      averageWeight: averageWeight,
      averageReps: averageReps,
      averageRPE: 0.0,
      totalVolume: totalVolume,
      lastWorkoutDate: lastWorkoutDate,
      weightTrend: allSets.calculateWeightTrend(),
      volumeTrend: allSets.calculateVolumeTrend(),
      allSets: allSets,
    );
  } catch (e) {
    return null;
  }
}
