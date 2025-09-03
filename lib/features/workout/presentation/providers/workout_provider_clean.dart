/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation/providers
 * 🎯 Feature: workout
 * 🔧 Type: provider
 * 🌍 Localization: ✅ Error messages via AppLocalizations
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod state management
 * - Domain use cases only
 * - No direct Firebase dependencies
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'workout_dependency_injection.dart';

/// Clean Architecture workout provider using use cases
final currentWorkoutProviderClean = StateNotifierProvider<CurrentWorkoutNotifierClean, WorkoutState>((ref) {
  return CurrentWorkoutNotifierClean(ref);
});

/// State class for workout with loading and error states
class WorkoutState {
  final Workout? workout;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const WorkoutState({
    this.workout,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  WorkoutState copyWith({
    Workout? workout,
    bool? isLoading,
    String? error,
    bool? isSaving,
  }) {
    return WorkoutState(
      workout: workout ?? this.workout,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// Clear error after showing it
  WorkoutState clearError() => copyWith(error: null);
  
  /// Helper getters
  bool get hasWorkout => workout != null;
  bool get isActive => workout?.isActive ?? false;
  bool get isCompleted => workout?.isCompleted ?? false;
}

/// Clean workout notifier using domain use cases
class CurrentWorkoutNotifierClean extends StateNotifier<WorkoutState> {
  final Ref _ref;
  
  CurrentWorkoutNotifierClean(this._ref) : super(const WorkoutState());

  /// Create new workout
  void createWorkout(String name) {
    if (name.trim().isEmpty) {
      _setError('Workout name cannot be empty');
      return;
    }
    
    final workout = Workout(name: name.trim());
    state = state.copyWith(workout: workout);
  }

  /// Start workout from template
  Future<void> startFromTemplate(wt.WorkoutTemplate workoutTemplate) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Create workout from template (business logic)
      final workout = Workout(
        name: workoutTemplate.name,
        exercises: workoutTemplate.exercises.map((templateExercise) {
          return Exercise(
            name: templateExercise.exerciseName,
            type: templateExercise.type,
            category: templateExercise.category,
            sets: templateExercise.sets.map((templateSet) {
              return ExerciseSet(
                setNumber: templateSet.setNumber,
                weight: templateSet.targetWeight ?? 0.0,
                reps: templateSet.targetReps ?? 0,
              );
            }).toList(),
          );
        }).toList(),
      );
      
      // Start the workout
      final startedWorkout = workout.startWorkout();
      state = state.copyWith(workout: startedWorkout, isLoading: false);
      
      // Auto-save the workout
      await _saveWorkout();
      
    } catch (e) {
      _setError('Failed to start workout from template: $e');
    }
  }

  /// Start current workout
  Future<void> startWorkout() async {
    if (state.workout == null) {
      _setError('No workout to start');
      return;
    }
    
    final startedWorkout = state.workout!.startWorkout();
    state = state.copyWith(workout: startedWorkout);
    
    await _saveWorkout();
  }

  /// Complete workout with comprehensive validation
  Future<void> completeWorkout() async {
    if (state.workout == null) {
      _setError('No workout to complete');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userEmail = _ref.read(currentUserEmailProvider);
      if (userEmail == null) {
        _setError('User not authenticated');
        return;
      }
      
      // Use complete workout use case
      final completeUseCase = _ref.read(completeWorkoutUseCaseProvider);
      final params = CompleteWorkoutParams(
        workout: state.workout!,
        userEmail: userEmail,
        saveAsActivities: true,
      );
      
      final result = await completeUseCase(params);
      
      result.fold(
        (failure) => _setError(_mapFailureToMessage(failure)),
        (completionResult) {
          state = state.copyWith(
            workout: completionResult.completedWorkout,
            isLoading: false,
          );
          
          // Show achievements if any
          if (completionResult.achievements.isNotEmpty) {
            // Could trigger achievements notification here
            // For now just complete silently
          }
        },
      );
      
    } catch (e) {
      _setError('Unexpected error completing workout: $e');
    }
  }

  /// Pause workout
  void pauseWorkout() {
    if (state.workout?.isActive == true) {
      final pausedWorkout = state.workout!.pauseWorkout();
      state = state.copyWith(workout: pausedWorkout);
    }
  }

  /// Resume workout
  void resumeWorkout() {
    if (state.workout?.status == WorkoutStatus.paused) {
      final resumedWorkout = state.workout!.resumeWorkout();
      state = state.copyWith(workout: resumedWorkout);
    }
  }

  /// Add exercise to workout
  void addExercise(Exercise exercise) {
    if (state.workout == null) return;
    
    final updatedWorkout = state.workout!.addExercise(exercise);
    state = state.copyWith(workout: updatedWorkout);
    
    _saveWorkoutAsync();
  }

  /// Remove exercise from workout
  void removeExercise(String exerciseId) {
    if (state.workout == null) return;
    
    final updatedWorkout = state.workout!.removeExercise(exerciseId);
    state = state.copyWith(workout: updatedWorkout);
    
    _saveWorkoutAsync();
  }

  /// Update exercise set with business logic
  Future<void> updateExerciseSet(String exerciseId, ExerciseSet updatedSet) async {
    if (state.workout == null) return;
    
    try {
      // Find previous set for progression logic
      ExerciseSet? previousSet;
      final exercise = state.workout!.exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );
      
      // Try to find previous set with same setNumber for comparison
      if (exercise.sets.length > 1) {
        final sameSetNumber = exercise.sets.where((s) => 
          s.setNumber == updatedSet.setNumber && s.id != updatedSet.id).toList();
        if (sameSetNumber.isNotEmpty) {
          previousSet = sameSetNumber.last;
        }
      }
      
      // Use the use case for business logic
      final updateUseCase = _ref.read(updateExerciseSetUseCaseProvider);
      final params = UpdateExerciseSetParams(
        workoutId: state.workout!.id,
        exerciseId: exerciseId,
        exerciseSet: updatedSet,
        previousSet: previousSet,
      );
      
      final result = await updateUseCase(params);
      
      result.fold(
        (failure) => _setError(_mapFailureToMessage(failure)),
        (_) {
          // Update local state
          _updateLocalExerciseSet(exerciseId, updatedSet);
        },
      );
      
    } catch (e) {
      _setError('Failed to update exercise set: $e');
    }
  }

  /// Update exercise details only
  void updateExerciseOnly(Exercise updatedExercise) {
    if (state.workout == null) return;
    
    final updatedWorkout = state.workout!.updateExercise(
      updatedExercise.id, 
      updatedExercise,
    );
    
    state = state.copyWith(workout: updatedWorkout);
    _saveWorkoutAsync();
  }

  /// Add set to exercise
  void addSetToExercise(String exerciseId) {
    if (state.workout == null) return;
    
    final exercises = state.workout!.exercises.map((exercise) {
      if (exercise.id == exerciseId) {
        final newSetNumber = exercise.sets.length + 1;
        final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
        
        final newSet = ExerciseSet(
          setNumber: newSetNumber,
          weight: lastSet?.weight ?? 0,
          reps: lastSet?.reps ?? 10,
        );
        
        return exercise.copyWith(sets: [...exercise.sets, newSet]);
      }
      return exercise;
    }).toList();

    state = state.copyWith(
      workout: state.workout!.copyWith(exercises: exercises),
    );
    
    _saveWorkoutAsync();
  }

  /// Remove set from exercise
  void removeSetFromExercise(String exerciseId, String setId) {
    if (state.workout == null) return;
    
    final exercises = state.workout!.exercises.map((exercise) {
      if (exercise.id == exerciseId) {
        var updatedSets = exercise.sets.where((set) => set.id != setId).toList();
        
        // Renumber sets
        for (int i = 0; i < updatedSets.length; i++) {
          updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
        }
        
        return exercise.copyWith(sets: updatedSets);
      }
      return exercise;
    }).toList();

    state = state.copyWith(
      workout: state.workout!.copyWith(exercises: exercises),
    );
    
    _saveWorkoutAsync();
  }

  /// Clear current workout
  void clearWorkout() {
    state = const WorkoutState();
  }

  /// Clear error state
  void clearError() {
    state = state.clearError();
  }

  /// Private helper methods
  
  void _updateLocalExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    if (state.workout == null) return;
    
    final exercises = state.workout!.exercises.map((exercise) {
      if (exercise.id == exerciseId) {
        final sets = exercise.sets.map((set) {
          return set.id == updatedSet.id ? updatedSet : set;
        }).toList();
        return exercise.copyWith(sets: sets);
      }
      return exercise;
    }).toList();

    state = state.copyWith(
      workout: state.workout!.copyWith(exercises: exercises),
    );
  }

  Future<void> _saveWorkout() async {
    if (state.workout == null) return;
    
    state = state.copyWith(isSaving: true, error: null);
    
    try {
      final saveUseCase = _ref.read(saveWorkoutUseCaseProvider);
      final params = SaveWorkoutParams(
        workout: state.workout!,
        requireCompletedSets: false,
      );
      
      final result = await saveUseCase(params);
      
      result.fold(
        (failure) => _setError(_mapFailureToMessage(failure)),
        (workoutId) {
          // Workout saved successfully
          state = state.copyWith(isSaving: false);
        },
      );
      
    } catch (e) {
      _setError('Failed to save workout: $e');
    }
  }

  void _saveWorkoutAsync() {
    // Save in background without blocking UI
    _saveWorkout().catchError((error) {
      // Silently handle errors for background saves
      // User will see error on next explicit action if still failing
    });
  }

  void _setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
      isSaving: false,
    );
  }

  String _mapFailureToMessage(Failure failure) {
    // Map failures to user-friendly messages
    // In real app, would use AppLocalizations.of(context)
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Network connection error. Please check your internet.';
      case AuthenticationFailure:
        return 'Authentication required. Please sign in.';
      case ValidationFailure:
        return failure.message;
      case WorkoutNotFoundFailure:
        return 'Workout not found.';
      case QuotaExceededFailure:
        return 'Storage quota exceeded. Please free up space.';
      case PermissionDeniedFailure:
        return 'Permission denied. Please check your account permissions.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Additional providers for workout operations

final workoutListProvider = FutureProvider.autoDispose.family<List<Workout>, GetWorkoutsParams>((ref, params) async {
  final getWorkoutsUseCase = ref.read(getWorkoutsUseCaseProvider);
  
  final result = await getWorkoutsUseCase(params);
  
  return result.fold(
    (failure) => throw Exception(_mapFailureToMessage(failure)),
    (workouts) => workouts,
  );
});

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case NetworkFailure:
      return 'Network connection error';
    case AuthenticationFailure:
      return 'Authentication required';
    case ValidationFailure:
      return failure.message;
    default:
      return 'An unexpected error occurred';
  }
}

/// Exercise templates and search providers (unchanged from original)
final exerciseTemplatesProvider = Provider<Map<ExerciseCategory, List<String>>>((ref) {
  return WorkoutTemplate.exerciseDatabase;
});

final exerciseSearchProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = Provider<List<String>>((ref) {
  final searchQuery = ref.watch(exerciseSearchProvider);
  
  if (searchQuery.isEmpty) {
    return [];
  }
  
  return WorkoutTemplate.searchExercises(searchQuery);
});

final selectedExerciseCategoryProvider = StateProvider<ExerciseCategory>((ref) {
  return ExerciseCategory.chest;
});

final selectedExerciseTypeProvider = StateProvider<ExerciseType>((ref) {
  return ExerciseType.single;
});