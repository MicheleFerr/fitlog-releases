import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_template.dart' as wt;
import '../../data/repositories/exercise_activity_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/domain/services/intelligent_notification_service.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

// Exercise Activity Repository provider
final exerciseActivityRepositoryProvider = Provider<ExerciseActivityRepository>((ref) {
  return ExerciseActivityRepository();
});

// Current workout state provider
final currentWorkoutProvider = StateNotifierProvider<CurrentWorkoutNotifier, Workout?>((ref) {
  return CurrentWorkoutNotifier(ref);
});

class CurrentWorkoutNotifier extends StateNotifier<Workout?> {
  CurrentWorkoutNotifier(this.ref) : super(null);
  
  final Ref ref;

  void createWorkout(String name) {
    state = Workout(name: name);
  }

  void startFromTemplate(wt.WorkoutTemplate workoutTemplate) {
    // Crea un nuovo workout dal template
    final workout = Workout(
      name: workoutTemplate.name,
      exercises: workoutTemplate.exercises.map((templateExercise) {
        // Crea l'esercizio con i set predefiniti dal template
        return Exercise(
          name: templateExercise.exerciseName,
          type: templateExercise.type,
          category: templateExercise.category,
          sets: templateExercise.sets.map((templateSet) {
            return ExerciseSet(
              setNumber: templateSet.setNumber,
              weight: templateSet.targetWeight,
              reps: templateSet.targetReps,
            );
          }).toList(),
        );
      }).toList(),
    );
    
    // Imposta il workout e lo avvia automaticamente
    state = workout.startWorkout();
    
    // Incrementa il contatore di utilizzo del template
    // Questo verrà gestito dal template provider
  }

  void startWorkout() {
    if (state != null) {
      state = state!.startWorkout();
    }
  }

  void completeWorkout() {
    if (state != null) {
      state = state!.completeWorkout();
      // Salva automaticamente il workout completato in Firestore
      _saveCompletedWorkoutToFirestore();
    }
  }

  /// Salva il workout completato in Firestore come exerciseActivities
  Future<void> _saveCompletedWorkoutToFirestore() async {
    
    final workout = state;
    
    if (workout == null || !workout.isCompleted) {
      return;
    }


    try {
      // Ottieni email utente corrente
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      
      if (currentUser?.email == null) {
        return;
      }


      // Normalizza email per consistency
      final normalizedEmail = currentUser!.email!.toLowerCase().trim();
      
      // Salva il workout usando il repository
      final repository = ref.read(exerciseActivityRepositoryProvider);
      final savedIds = await repository.saveCompletedWorkout(
        workout: workout,
        userEmail: normalizedEmail,
      );

      // Genera notifiche intelligenti basate sul workout completato
      final intelligentService = ref.read(intelligentNotificationServiceProvider);
      final notifications = await intelligentService.analyzeWorkoutCompletion(workout);
      
      // Aggiungi le notifiche generate
      final notificationNotifier = ref.read(notificationProvider.notifier);
      for (final notification in notifications) {
        await notificationNotifier.addNotification(notification);
      }
      
      // Genera anche un suggerimento giornaliero se appropriato
      final dailySuggestion = await intelligentService.generateDailySuggestion();
      if (dailySuggestion != null) {
        await notificationNotifier.addNotification(dailySuggestion);
      }
      
    } catch (e, stackTrace) {
      // Non blocchiamo l'UI per errori di salvataggio
      // L'utente può sempre tentare di nuovo in seguito
      print('Errore nel salvataggio workout: $e');
    }
  }

  void pauseWorkout() {
    if (state != null) {
      state = state!.pauseWorkout();
    }
  }

  void resumeWorkout() {
    if (state != null) {
      state = state!.resumeWorkout();
    }
  }

  void addExercise(Exercise exercise) {
    if (state != null) {
      state = state!.addExercise(exercise);
    }
  }

  void removeExercise(String exerciseId) {
    if (state != null) {
      state = state!.removeExercise(exerciseId);
    }
  }

  void updateExercise(String exerciseId, Exercise updatedExercise) {
    if (state != null) {
      state = state!.updateExercise(exerciseId, updatedExercise);
    }
  }

  void updateExerciseOnly(Exercise updatedExercise) {
    print('🔄 updateExerciseOnly called with exercise: ${updatedExercise.name}');
    
    if (state == null) {
      print('⚠️ State is null, cannot update exercise');
      return;
    }
    
    try {
      print('🔄 Current exercises count: ${state!.exercises.length}');
      
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == updatedExercise.id) {
          print('✅ Found matching exercise to update: ${exercise.name} -> ${updatedExercise.name}');
          return updatedExercise;
        }
        return exercise;
      }).toList();

      print('🔄 Updated exercises count: ${updatedExercises.length}');
      state = state!.copyWith(exercises: updatedExercises);
      print('✅ State updated successfully');
    } catch (e, stackTrace) {
      print('❌ Error updating exercise: $e');
      print('Stack: $stackTrace');
    }
  }

  void completeSet(String exerciseId, String setId) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((exercise) {
      if (exercise.id == exerciseId) {
        final updatedSets = exercise.sets.map((set) {
          if (set.id == setId) {
            return set.copyWith(isCompleted: true);
          }
          return set;
        }).toList();
        return exercise.copyWith(sets: updatedSets);
      }
      return exercise;
    }).toList();

    state = state!.copyWith(exercises: updatedExercises);
  }

  void updateExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((exercise) {
      if (exercise.id == exerciseId) {
        final updatedSets = exercise.sets.map((set) {
          if (set.id == updatedSet.id) {
            return updatedSet;
          }
          return set;
        }).toList();
        return exercise.copyWith(sets: updatedSets);
      }
      return exercise;
    }).toList();

    state = state!.copyWith(exercises: updatedExercises);
  }

  void addSetToExercise(String exerciseId) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((exercise) {
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

    state = state!.copyWith(exercises: updatedExercises);
  }

  void removeSetFromExercise(String exerciseId, String setId) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((exercise) {
      if (exercise.id == exerciseId) {
        final updatedSets = exercise.sets.where((set) => set.id != setId).toList();
        
        // Renumber sets
        for (int i = 0; i < updatedSets.length; i++) {
          updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
        }
        
        return exercise.copyWith(sets: updatedSets);
      }
      return exercise;
    }).toList();

    state = state!.copyWith(exercises: updatedExercises);
  }

  void clearWorkout() {
    state = null;
  }
}

// Workout history provider (for future implementation)
final workoutHistoryProvider = StateNotifierProvider<WorkoutHistoryNotifier, List<Workout>>((ref) {
  return WorkoutHistoryNotifier();
});

class WorkoutHistoryNotifier extends StateNotifier<List<Workout>> {
  WorkoutHistoryNotifier() : super([]);

  void addCompletedWorkout(Workout workout) {
    if (workout.isCompleted) {
      state = [workout, ...state];
    }
  }

  void removeWorkout(String workoutId) {
    state = state.where((w) => w.id != workoutId).toList();
  }

  List<Workout> getWorkoutsByDateRange(DateTime start, DateTime end) {
    return state.where((workout) {
      if (workout.startTime == null) return false;
      return workout.startTime!.isAfter(start) && workout.startTime!.isBefore(end);
    }).toList();
  }
}

// Exercise templates provider
final exerciseTemplatesProvider = Provider<Map<ExerciseCategory, List<String>>>((ref) {
  return WorkoutTemplate.exerciseDatabase;
});

// Exercise search provider
final exerciseSearchProvider = StateProvider<String>((ref) => '');

final filteredExercisesProvider = Provider<List<String>>((ref) {
  final searchQuery = ref.watch(exerciseSearchProvider);
  
  if (searchQuery.isEmpty) {
    return [];
  }
  
  return WorkoutTemplate.searchExercises(searchQuery);
});

// Selected exercise category for modal
final selectedExerciseCategoryProvider = StateProvider<ExerciseCategory>((ref) {
  return ExerciseCategory.chest;
});

// Selected exercise type for modal
final selectedExerciseTypeProvider = StateProvider<ExerciseType>((ref) {
  return ExerciseType.single;
});