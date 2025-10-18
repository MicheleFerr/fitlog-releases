import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout_template.dart' as wt;
import '../../data/repositories/exercise_activity_repository.dart';
import '../../data/repositories/hybrid_exercise_activity_repository.dart';
import '../../data/datasources/hive_workout_datasource.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/domain/services/intelligent_notification_service.dart';
// MIGRATION: Using bridge provider for backward compatibility while migrating to unified system
import '../../../notifications/presentation/providers/notification_provider_bridge.dart';
import '../../../history/domain/entities/workout_history_detail.dart';
import 'intelligent_workout_suggestion_provider.dart';
import 'screen_wakelock_provider.dart';
// Auto-sync for cached progress stats
import '../../../progress/presentation/providers/cached_progress_provider.dart';

// Hive datasource provider
final hiveWorkoutDataSourceProvider = Provider<HiveWorkoutDataSource>((ref) {
  return HiveWorkoutDataSource();
});

// Hybrid Exercise Activity Repository provider
final hybridExerciseActivityRepositoryProvider = Provider<HybridExerciseActivityRepository>((ref) {
  final localDataSource = ref.watch(hiveWorkoutDataSourceProvider);
  return HybridExerciseActivityRepository(localDataSource: localDataSource);
});

// Exercise Activity Repository provider (kept for backward compatibility)
final exerciseActivityRepositoryProvider = Provider<ExerciseActivityRepository>((ref) {
  return ExerciseActivityRepository();
});

// Workout History Repository provider (import from intelligent_workout_suggestion_provider)
// This is already defined there, so we can import it

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

    // Attiva wakelock se abilitato nelle impostazioni
    ref.read(screenWakelockProvider.notifier).startWakelock();

    // Incrementa il contatore di utilizzo del template
    // Questo verrà gestito dal template provider
  }

  void startWorkout() {
    if (state != null) {
      state = state!.startWorkout();

      // Attiva wakelock se abilitato nelle impostazioni
      ref.read(screenWakelockProvider.notifier).startWakelock();
    }
  }

  void completeWorkout() {
    if (state != null) {
      state = state!.completeWorkout();
      // Salva automaticamente il workout completato in Firestore
      _saveCompletedWorkoutToFirestore();

      // Disattiva wakelock quando il workout è completato
      ref.read(screenWakelockProvider.notifier).stopWakelock();
    }
  }

  /// Salva il workout completato localmente e in Firestore
  Future<void> _saveCompletedWorkoutToFirestore() async {
    final workout = state;
    if (workout == null || !workout.isCompleted) {
      return;
    }

    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      return;
    }

    try {
      // 1. Convert Workout to WorkoutHistoryDetail
      final exercisesHistory = workout.exercises.map((exercise) {
        final setsHistory = exercise.sets.map((set) {
          return SetHistoryDetail(
            setNumber: set.setNumber,
            weight: double.tryParse(set.weight.toString()) ?? 0.0,
            reps: int.tryParse(set.reps.toString()) ?? 0,
            rpe: set.rpe ?? 0,
            notes: set.notes,
            isWarmup: set.isWarmup,
          );
        }).toList();

        return ExerciseHistoryDetail(
          id: exercise.id,
          name: exercise.name,
          category: exercise.category?.name ?? 'Other',
          notes: exercise.notes,
          sets: setsHistory,
          exerciseData: {},
        );
      }).toList();

      final workoutHistoryDetail = WorkoutHistoryDetail(
        id: workout.id,
        userId: currentUser.uid,
        name: workout.name,
        description: workout.notes ?? '',
        createdAt: workout.createdAt,
        startedAt: workout.startTime ?? workout.createdAt,
        completedAt: workout.endTime ?? DateTime.now(),
        updatedAt: workout.updatedAt,
        duration: workout.duration ?? Duration.zero,
        exercises: exercisesHistory,
        metadata: {'source': 'app_completion'},
      );

      // 2. Save to 'workouts' collection in Firestore
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workoutHistoryDetail.id)
          .set(workoutHistoryDetail.toFirestoreMap());

      // 3. Save locally with explicit error handling
      try {
        final historyRepository = ref.read(workoutHistoryRepositoryProvider);
        await historyRepository.saveWorkoutLocally(workout);
        debugPrint('✅ [WorkoutProvider] Workout saved locally successfully');
      } catch (localError, stackTrace) {
        debugPrint('❌ [WorkoutProvider] CRITICAL: Failed to save workout locally: $localError');
        debugPrint('📍 [WorkoutProvider] Stack trace: $stackTrace');
        // Continue execution - don't fail the entire completion process
      }

      // 4. Update user stats
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(currentUser.uid).update({
          'stats.totalWorkouts': FieldValue.increment(1),
          'stats.lastWorkoutDate': FieldValue.serverTimestamp(),
          'stats.totalVolume': FieldValue.increment(workoutHistoryDetail.totalVolume),
          'stats.monthlyWorkouts': FieldValue.increment(1),
        });
      } catch (statsError) {
        // Non-critical
      }

      // 5. Update cached progress stats
      try {
        final cacheRepo = ref.read(progressCacheRepositoryProvider);
        final workoutDate = workout.startTime ?? DateTime.now();
        final dateKey =
            '${workoutDate.year}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}';
        await cacheRepo.incrementWorkout(dateKey);
        ref.invalidate(cachedProgressProvider);
      } catch (cacheError) {
        ref.invalidate(cachedProgressProvider);
      }

      // 6. Generate intelligent notifications
      try {
        final intelligentService = ref.read(intelligentNotificationServiceProvider);
        final notifications = await intelligentService.analyzeWorkoutCompletion(workout);
        final notificationNotifier = ref.read(notificationProvider.notifier);
        for (final notification in notifications) {
          await notificationNotifier.addNotification(notification);
        }
        final dailySuggestion = await intelligentService.generateDailySuggestion();
        if (dailySuggestion != null) {
          await notificationNotifier.addNotification(dailySuggestion);
        }
      } catch (notificationError) {
        // Non-critical
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Critical error saving workout: $e');
      debugPrint('Stack: $stackTrace');
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
    // print('🔄 updateExerciseOnly called with exercise: ${updatedExercise.name}');
    
    if (state == null) {
      // print('⚠️ State is null, cannot update exercise');
      return;
    }
    
    try {
      // print('🔄 Current exercises count: ${state!.exercises.length}');
      
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == updatedExercise.id) {
          // print('✅ Found matching exercise to update: ${exercise.name} -> ${updatedExercise.name}');
          return updatedExercise;
        }
        return exercise;
      }).toList();

      // print('🔄 Updated exercises count: ${updatedExercises.length}');
      state = state!.copyWith(exercises: updatedExercises);
      // print('✅ State updated successfully');
    } catch (e, stackTrace) {
      // print('❌ Error updating exercise: $e');
      // print('Stack: $stackTrace');
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

  void updateSupersetSet(String exerciseId, SupersetSet updatedSupersetSet) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((exercise) {
      if (exercise.id == exerciseId && exercise is SupersetExercise) {
        final updatedSupersetSets = exercise.supersetSets.map((set) {
          if (set.id == updatedSupersetSet.id) {
            return updatedSupersetSet;
          }
          return set;
        }).toList();
        return exercise.copyWith(supersetSets: updatedSupersetSets);
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

    // Disattiva wakelock quando si cancella il workout
    ref.read(screenWakelockProvider.notifier).stopWakelock();
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