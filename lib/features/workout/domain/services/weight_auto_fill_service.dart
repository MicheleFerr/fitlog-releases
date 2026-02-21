import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/weight_recovery_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

/// Domain service — silently pre-fills exercise sets with weights/reps
/// from the user's previous session. Never throws; always returns a valid Workout.
class WeightAutoFillService {
  WeightAutoFillService({required ExerciseHistoryService historyService})
      : _historyService = historyService;

  final ExerciseHistoryService _historyService;

  /// Template path: apply all weights from a previous completed workout via
  /// WeightRecoveryService. Falls back to fillFromHistory if no previous workout
  /// is provided.
  Future<Workout> fillFromTemplate({
    required Workout workout,
    required Workout? previousWorkout,
  }) async {
    try {
      if (previousWorkout == null) return workout;
      return WeightRecoveryService.applyPreviousWeights(
        currentWorkout: workout,
        previousWorkout: previousWorkout,
        multiplier: 1.0,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[WeightAutoFill] fillFromTemplate error: $e');
      return workout;
    }
  }

  /// Free-workout path: look up last weight per exercise from Hive history.
  Future<Workout> fillFromHistory({
    required Workout workout,
    required String userId,
  }) async {
    try {
      final updatedExercises = <Exercise>[];

      for (final exercise in workout.exercises) {
        final lastData = await _historyService.getLastExerciseData(
          exercise.name,
          userId,
        );

        if (lastData.weight == null) {
          updatedExercises.add(exercise);
          continue;
        }

        final updatedSets = exercise.sets.map((set) {
          return set.copyWith(weight: lastData.weight);
        }).toList();

        updatedExercises.add(exercise.copyWith(sets: updatedSets));
      }

      return workout.copyWith(exercises: updatedExercises);
    } catch (e) {
      if (kDebugMode) debugPrint('[WeightAutoFill] fillFromHistory error: $e');
      return workout;
    }
  }
}
