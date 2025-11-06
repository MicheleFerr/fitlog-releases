/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain/usecases
/// 🎯 Feature: workout
/// 🔧 Type: usecase
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Domain entities
/// - Repository interface
/// - Shared failures
library;

import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Use case for saving workouts with business logic validation
class SaveWorkoutUseCase {
  
  const SaveWorkoutUseCase(this._repository);
  final WorkoutRepository _repository;
  
  /// Save workout with validation
  Future<Either<Failure, String>> call(SaveWorkoutParams params) async {
    // Business logic validation
    final validationResult = _validateWorkout(params.workout);
    if (validationResult != null) {
      return left(validationResult);
    }
    
    // Additional business rules
    if (params.workout.exercises.isEmpty) {
      return left(const ValidationFailure(
        'Workout must have at least one exercise',
        code: 'empty_workout',
      ));
    }
    
    // Check if workout has any completed sets before saving
    if (params.requireCompletedSets && params.workout.completedSets == 0) {
      return left(const ValidationFailure(
        'Cannot save workout without any completed sets',
        code: 'no_completed_sets',
      ));
    }
    
    try {
      // Apply business logic transformations
      final workoutToSave = _prepareWorkoutForSave(params.workout);
      
      // Delegate to repository
      return await _repository.saveWorkout(workoutToSave);
      
    } catch (e) {
      return left(UnexpectedFailure('Failed to save workout: $e'));
    }
  }
  
  /// Validate workout business rules
  ValidationFailure? _validateWorkout(Workout workout) {
    // Name validation
    if (workout.name.trim().isEmpty) {
      return const ValidationFailure(
        'Workout name cannot be empty',
        code: 'invalid_name',
      );
    }
    
    if (workout.name.trim().length < 2) {
      return const ValidationFailure(
        'Workout name must be at least 2 characters',
        code: 'name_too_short',
      );
    }
    
    if (workout.name.trim().length > 100) {
      return const ValidationFailure(
        'Workout name cannot exceed 100 characters',
        code: 'name_too_long',
      );
    }
    
    // Exercise validation
    for (final exercise in workout.exercises) {
      final exerciseValidation = _validateExercise(exercise);
      if (exerciseValidation != null) {
        return exerciseValidation;
      }
    }
    
    return null;
  }
  
  /// Validate individual exercise
  ValidationFailure? _validateExercise(Exercise exercise) {
    if (exercise.name.trim().isEmpty) {
      return const ValidationFailure(
        'Exercise name cannot be empty',
        code: 'invalid_exercise_name',
      );
    }
    
    if (exercise.sets.isEmpty) {
      return const ValidationFailure(
        'Exercise must have at least one set',
        code: 'exercise_no_sets',
      );
    }
    
    // Validate sets
    for (final set in exercise.sets) {
      // ✅ Null-safe: weight and reps are nullable
      if (set.weight != null && set.weight! < 0) {
        return const ValidationFailure(
          'Weight cannot be negative',
          code: 'negative_weight',
        );
      }

      if (set.reps != null && set.reps! <= 0) {
        return const ValidationFailure(
          'Reps must be greater than 0',
          code: 'invalid_reps',
        );
      }

      if (set.reps != null && set.reps! > 1000) {
        return const ValidationFailure(
          'Reps cannot exceed 1000',
          code: 'reps_too_high',
        );
      }
    }
    
    return null;
  }
  
  /// Apply business logic transformations before saving
  Workout _prepareWorkoutForSave(Workout workout) {
    // Ensure proper timestamps
    Workout result = workout;
    
    if (workout.status == WorkoutStatus.completed && workout.endTime == null) {
      result = result.copyWith(endTime: DateTime.now());
    }
    
    // Clean up exercise data
    final cleanedExercises = workout.exercises.map((exercise) {
      // Remove empty sets or sets with invalid data
      // ✅ Null-safe: weight and reps are nullable
      final validSets = exercise.sets
          .where((set) =>
              (set.weight == null || set.weight! >= 0) &&
              (set.reps == null || set.reps! > 0))
          .toList();
      
      // Renumber sets
      final renumberedSets = validSets.asMap().entries.map((entry) {
        return entry.value.copyWith(setNumber: entry.key + 1);
      }).toList();
      
      return exercise.copyWith(sets: renumberedSets);
    }).where((exercise) => exercise.sets.isNotEmpty).toList();
    
    return result.copyWith(
      exercises: cleanedExercises,
      updatedAt: DateTime.now(),
    );
  }
}

/// Parameters for SaveWorkoutUseCase
class SaveWorkoutParams {
  
  const SaveWorkoutParams({
    required this.workout,
    this.requireCompletedSets = false,
  });
  final Workout workout;
  final bool requireCompletedSets;
}