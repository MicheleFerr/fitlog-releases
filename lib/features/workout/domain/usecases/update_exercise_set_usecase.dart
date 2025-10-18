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
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

/// Use case for updating exercise sets with business logic
class UpdateExerciseSetUseCase {
  
  const UpdateExerciseSetUseCase(this._repository);
  final WorkoutRepository _repository;
  
  /// Update exercise set with validation and business rules
  Future<Either<Failure, void>> call(UpdateExerciseSetParams params) async {
    // Validate set data
    final validationResult = _validateExerciseSet(params.exerciseSet);
    if (validationResult != null) {
      return left(validationResult);
    }
    
    try {
      // Apply business logic transformations
      final processedSet = _processExerciseSet(params.exerciseSet, params.previousSet);
      
      // Delegate to repository
      return await _repository.updateExerciseSet(
        workoutId: params.workoutId,
        exerciseId: params.exerciseId,
        exerciseSet: processedSet,
      );
      
    } catch (e) {
      return left(UnexpectedFailure('Failed to update exercise set: $e'));
    }
  }
  
  /// Validate exercise set business rules
  ValidationFailure? _validateExerciseSet(ExerciseSet set) {
    // Weight validation
    if (set.weight < 0) {
      return const ValidationFailure(
        'Weight cannot be negative',
        code: 'negative_weight',
      );
    }
    
    if (set.weight > 10000) { // Reasonable maximum
      return const ValidationFailure(
        'Weight cannot exceed 10,000 kg',
        code: 'weight_too_high',
      );
    }
    
    // Reps validation
    if (set.reps <= 0) {
      return const ValidationFailure(
        'Reps must be greater than 0',
        code: 'invalid_reps',
      );
    }
    
    if (set.reps > 1000) { // Reasonable maximum
      return const ValidationFailure(
        'Reps cannot exceed 1000',
        code: 'reps_too_high',
      );
    }
    
    // RPE validation (if set)
    if (set.rpe != null && (set.rpe! < 1 || set.rpe! > 10)) {
      return const ValidationFailure(
        'RPE must be between 1 and 10',
        code: 'invalid_rpe',
      );
    }
    
    // Rest time validation (if set)
    if (set.restTime != null && set.restTime! < 0) {
      return const ValidationFailure(
        'Rest time cannot be negative',
        code: 'negative_rest_time',
      );
    }
    
    if (set.restTime != null && set.restTime! > 3600) { // 60 minutes = 3600 seconds
      return const ValidationFailure(
        'Rest time cannot exceed 60 minutes',
        code: 'rest_time_too_long',
      );
    }
    
    return null;
  }
  
  /// Process exercise set with business logic
  ExerciseSet _processExerciseSet(ExerciseSet currentSet, ExerciseSet? previousSet) {
    ExerciseSet result = currentSet;
    
    // Auto-calculate volume if not set
    final volume = result.weight * result.reps;
    result = result.copyWith(volume: volume);
    
    // Apply progressive overload suggestions
    if (previousSet != null) {
      result = _applyProgressiveOverloadLogic(result, previousSet);
    }
    
    // Set completion timestamp if marked complete
    if (result.isCompleted && result.completedAt == null) {
      result = result.copyWith(completedAt: DateTime.now());
    }
    
    // Clear completion timestamp if unmarked
    if (!result.isCompleted && result.completedAt != null) {
      result = result.copyWith(completedAt: null);
    }
    
    return result;
  }
  
  /// Apply progressive overload business logic
  ExerciseSet _applyProgressiveOverloadLogic(
    ExerciseSet currentSet,
    ExerciseSet previousSet,
  ) {
    // Calculate improvement metrics
    final weightImprovement = currentSet.weight - previousSet.weight;
    final repsImprovement = currentSet.reps - previousSet.reps;
    final volumeImprovement = currentSet.volume - previousSet.volume;
    
    // Add metadata about progression
    final Map<String, dynamic> progression = {
      'weightChange': weightImprovement,
      'repsChange': repsImprovement,
      'volumeChange': volumeImprovement,
      'isProgression': volumeImprovement > 0,
    };
    
    // Determine progression type
    if (weightImprovement > 0 && repsImprovement >= 0) {
      progression['progressionType'] = 'weight_increase';
    } else if (repsImprovement > 0 && weightImprovement >= 0) {
      progression['progressionType'] = 'reps_increase';
    } else if (volumeImprovement > 0) {
      progression['progressionType'] = 'volume_increase';
    } else if (volumeImprovement < 0) {
      progression['progressionType'] = 'deload';
    } else {
      progression['progressionType'] = 'maintenance';
    }
    
    return currentSet.copyWith(
      notes: _appendProgressionNote(currentSet.notes, progression),
    );
  }
  
  /// Append progression information to notes
  String? _appendProgressionNote(String? currentNotes, Map<String, dynamic> progression) {
    final progressionType = progression['progressionType'];
    final volumeChange = progression['volumeChange'] as double;
    
    String progressionNote = '';
    
    switch (progressionType) {
      case 'weight_increase':
        progressionNote = '⬆️ Weight increased (+${progression['weightChange']}kg)';
        break;
      case 'reps_increase':
        progressionNote = '⬆️ Reps increased (+${progression['repsChange']})';
        break;
      case 'volume_increase':
        progressionNote = '📈 Volume increased (+${volumeChange.toStringAsFixed(1)}kg)';
        break;
      case 'deload':
        progressionNote = '⬇️ Deload (-${(-volumeChange).toStringAsFixed(1)}kg volume)';
        break;
      case 'maintenance':
        progressionNote = '➡️ Same as last time';
        break;
    }
    
    if (progressionNote.isEmpty) return currentNotes;
    
    if (currentNotes == null || currentNotes.isEmpty) {
      return progressionNote;
    }
    
    // Check if progression note already exists
    if (currentNotes.contains('⬆️') || 
        currentNotes.contains('⬇️') || 
        currentNotes.contains('📈') || 
        currentNotes.contains('➡️')) {
      return currentNotes; // Don't add duplicate progression notes
    }
    
    return '$currentNotes\n$progressionNote';
  }
}

/// Parameters for UpdateExerciseSetUseCase
class UpdateExerciseSetParams { // For progression logic
  
  const UpdateExerciseSetParams({
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseSet,
    this.previousSet,
  });
  final String workoutId;
  final String exerciseId;
  final ExerciseSet exerciseSet;
  final ExerciseSet? previousSet;
}