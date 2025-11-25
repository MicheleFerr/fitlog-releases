import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Use case to get recently used exercises for quick selection
///
/// Retrieves unique exercise names from recent workouts (newest first)
/// Limited by the provided limit parameter (default 10)
class GetRecentExercises {

  GetRecentExercises(this._repository);
  final WorkoutRepository _repository;

  /// Get list of recently used exercise names
  ///
  /// Returns exercise names in reverse chronological order (most recent first)
  /// Only unique exercise names are returned
  /// [limit] - Maximum number of exercises to return (default 10)
  Future<List<String>> execute({int limit = 10}) async {
    final result = await _repository.getWorkouts();

    return result.fold(
      // If error, return empty list
      (failure) => [],
      // If success, extract unique exercise names
      (workouts) {
        final seenExercises = <String>{};
        final orderedNames = <String>[];

        // Process workouts in reverse order (newest first)
        // Process exercises in reverse order within each workout
        for (final workout in workouts.reversed) {
          for (final exercise in workout.exercises.reversed) {
            if (!seenExercises.contains(exercise.name)) {
              seenExercises.add(exercise.name);
              orderedNames.add(exercise.name);

              // Stop when we reach the limit
              if (orderedNames.length >= limit) {
                return orderedNames;
              }
            }
          }
        }

        return orderedNames;
      },
    );
  }
}
