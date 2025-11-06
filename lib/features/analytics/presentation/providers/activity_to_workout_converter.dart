import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:collection/collection.dart';

/// Helper to convert ExerciseActivity list to Workout list
/// Groups activities by workout name and date
class ActivityToWorkoutConverter {
  /// Convert activities to workouts by grouping them
  static List<Workout> convert(List<ExerciseActivity> activities) {
    if (activities.isEmpty) return [];

    // Group activities by workout name (schedaName) and date (day)
    final groupedActivities = groupBy<ExerciseActivity, String>(
      activities,
      (activity) => _getWorkoutKey(activity),
    );

    // Convert each group to a Workout
    return groupedActivities.entries.map((entry) {
      final workoutActivities = entry.value;
      return _createWorkoutFromActivities(workoutActivities);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Most recent first
  }

  /// Create unique key for workout grouping: "WorkoutName_YYYY-MM-DD"
  static String _getWorkoutKey(ExerciseActivity activity) {
    final date = activity.createdAt;
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${activity.schedaName}_$dateKey';
  }

  /// Create a Workout from a list of activities (same workout session)
  static Workout _createWorkoutFromActivities(List<ExerciseActivity> activities) {
    if (activities.isEmpty) {
      throw ArgumentError('Cannot create workout from empty activities list');
    }

    // Use first activity for workout metadata
    final firstActivity = activities.first;
    final workoutDate = firstActivity.createdAt;

    // Convert each activity to an Exercise
    final exercises = activities.map((activity) {
      return _convertActivityToExercise(activity);
    }).toList();

    // Calculate workout start/end times (approximate)
    final startTime = workoutDate;
    final endTime = activities.last.lastModified;

    return Workout(
      id: _getWorkoutKey(firstActivity), // Use workout key as ID
      name: firstActivity.schedaName,
      exercises: exercises,
      status: WorkoutStatus.completed, // All activities are completed
      startTime: startTime,
      endTime: endTime,
      createdAt: workoutDate,
      updatedAt: activities.last.lastModified,
    );
  }

  /// Convert single ExerciseActivity to Exercise
  static Exercise _convertActivityToExercise(ExerciseActivity activity) {
    // Convert activity sets to ExerciseSets
    final exerciseSets = activity.sets.map((activitySet) {
      return ExerciseSet(
        setNumber: activitySet.set,
        weight: double.tryParse(activitySet.weight),
        reps: int.tryParse(activitySet.reps),
        actualReps: activitySet.actualReps != null
            ? int.tryParse(activitySet.actualReps!)
            : null,
        rpe: activitySet.rpe,
        isCompleted: activitySet.done,
        isWarmup: activitySet.isWarmup,
      );
    }).toList();

    return Exercise(
      id: activity.exerciseId,
      name: activity.exerciseName,
      type: ExerciseType.single, // Default single set type
      category: _inferCategoryFromName(activity.exerciseName),
      sets: exerciseSets,
      createdAt: activity.createdAt,
      updatedAt: activity.lastModified,
    );
  }

  /// Infer exercise category from name (basic heuristic)
  static ExerciseCategory _inferCategoryFromName(String exerciseName) {
    final nameLower = exerciseName.toLowerCase();

    if (nameLower.contains('bench') ||
        nameLower.contains('chest') ||
        nameLower.contains('petto')) {
      return ExerciseCategory.chest;
    }

    if (nameLower.contains('squat') ||
        nameLower.contains('leg') ||
        nameLower.contains('gambe')) {
      return ExerciseCategory.legs;
    }

    if (nameLower.contains('pull') ||
        nameLower.contains('row') ||
        nameLower.contains('back') ||
        nameLower.contains('dorso')) {
      return ExerciseCategory.back;
    }

    if (nameLower.contains('shoulder') ||
        nameLower.contains('press') ||
        nameLower.contains('spall')) {
      return ExerciseCategory.shoulders;
    }

    if (nameLower.contains('curl') ||
        nameLower.contains('tricep') ||
        nameLower.contains('bracci')) {
      return ExerciseCategory.arms;
    }

    if (nameLower.contains('ab') ||
        nameLower.contains('crunch') ||
        nameLower.contains('plank')) {
      return ExerciseCategory.abs;
    }

    if (nameLower.contains('cardio') ||
        nameLower.contains('run') ||
        nameLower.contains('bike')) {
      return ExerciseCategory.cardio;
    }

    return ExerciseCategory.other;
  }
}
