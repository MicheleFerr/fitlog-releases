import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';

/// Provider that aggregates all exercise activities into a list of ExerciseHistory.
/// Each ExerciseHistory object represents the complete history for a single exercise.
final allExerciseHistoriesProvider = Provider<List<ExerciseHistory>>((ref) {
  final analyticsState = ref.watch(analyticsProvider);
  final List<ExerciseActivity> allActivities = analyticsState.activities;

  if (allActivities.isEmpty) {
    return [];
  }

  // Group activities by exercise name
  final Map<String, List<ExerciseActivity>> activitiesByExercise = {};
  for (final activity in allActivities) {
    activitiesByExercise.putIfAbsent(activity.exerciseName, () => []).add(activity);
  }

  final List<ExerciseHistory> exerciseHistories = [];

  activitiesByExercise.forEach((exerciseName, activities) {
    // For each exercise, group its activities into sessions (an activity is a session)
    final List<ExerciseSession> sessions = activities.map((activity) {
      final List<AnalyticsSet> analyticsSets = [];
      for (final ExerciseActivitySet setData in activity.sets) {
        if (setData.done) { // Only consider completed sets
          final double? weight = double.tryParse(setData.weight ?? '0.0');
          final int? reps = int.tryParse(setData.actualReps ?? setData.reps ?? '0');

          if (weight != null && weight > 0 && reps != null && reps > 0) {
            analyticsSets.add(AnalyticsSet(
              weight: weight,
              reps: reps,
              date: activity.createdAt, // Use the activity creation date for the set date
            ));
          }
        }
      }

      // Ensure that there are valid sets for the session
      if (analyticsSets.isNotEmpty) {
        // Sort sets by date ascending to ensure proper session calculation if needed
        analyticsSets.sort((a, b) => a.date.compareTo(b.date));

        return ExerciseSession(
          exerciseName: activity.exerciseName,
          muscleGroup: activity.category.name, // Use category enum name as muscle group
          sets: analyticsSets,
          date: activity.createdAt, // Use the activity creation date for the session date
        );
      }
      return null;
    }).whereType<ExerciseSession>().toList(); // Filter out nulls

    // Ensure sessions are sorted by date for ExerciseHistory
    sessions.sort((a, b) => a.date.compareTo(b.date));

    // Create ExerciseHistory for the exercise
    if (sessions.isNotEmpty) {
      exerciseHistories.add(ExerciseHistory(
        exerciseName: exerciseName,
        muscleGroup: sessions.first.muscleGroup, // Take muscleGroup from the first session
        sessions: sessions,
      ));
    }
  });

  // Sort histories by exercise name or another relevant metric if desired
  exerciseHistories.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));

  return exerciseHistories;
});