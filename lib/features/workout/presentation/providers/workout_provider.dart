import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/workout/data/repositories/exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/intelligent_notification_service.dart';
// MIGRATION: Using bridge provider for backward compatibility while migrating to unified system
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_provider_bridge.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/screen_wakelock_provider.dart';
// Auto-sync for cached progress stats
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';
// App config for default APRE settings
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
// APRE auto-regulation
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
// Routine auto-completion
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
// 🔒 Security: Input sanitization
import 'package:gymbro_flutter_new/shared/domain/services/input_sanitizer.dart';
// Haptic feedback
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';

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

// NOTE: WorkoutHistoryRepository removed - using unified HybridWorkoutRepository instead

// Current workout state provider
final currentWorkoutProvider = StateNotifierProvider<CurrentWorkoutNotifier, Workout?>((ref) {
  return CurrentWorkoutNotifier(ref);
});

class CurrentWorkoutNotifier extends StateNotifier<Workout?> {
  CurrentWorkoutNotifier(this.ref) : super(null);

  final Ref ref;

  // CRITICAL FIX: Track disposal state to prevent operations after dispose
  bool _isDisposed = false;

  // CRITICAL FIX: Atomic flag to prevent concurrent APRE calculations
  bool _apreCalculationInProgress = false;

  void createWorkout(String name) {
    state = Workout(name: name);
  }

  void startFromTemplate(wt.WorkoutTemplate workoutTemplate) {
    try {
      // Check if APRE is enabled globally
      final config = ref.read(appConfigProvider);
      final isApreEnabled = config.enableApre ?? false;

      if (kDebugMode) {
        debugPrint('[APRE] Starting workout from template: ${workoutTemplate.name}');
        debugPrint('[APRE] APRE system enabled: $isApreEnabled');
      }

      // Crea un nuovo workout dal template
      final workout = Workout(
        name: workoutTemplate.name,
        templateId: workoutTemplate.id, // ✅ CRITICAL FIX: Pass templateId for routine auto-detection
        exercises: workoutTemplate.exercises.map((templateExercise) {
          // Crea l'esercizio con i set predefiniti dal template
          var exercise = Exercise(
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

          // Apply APRE configuration if enabled globally
          if (isApreEnabled && exercise.type == ExerciseType.single && exercise.sets.isNotEmpty) {
            // Auto-select protocol based on target reps of first set
            final targetReps = exercise.sets.first.reps ?? 6;
            final protocol = APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);

            if (kDebugMode) {
              debugPrint('[APRE] Auto-selected protocol $protocol for ${exercise.name} (target reps: $targetReps)');
            }

            // Get appropriate rest time for protocol
            final restTime = APREAutoRegulationService.getRestTimeForProtocol(
              protocol,
              strengthRestTime: config.strengthRestTime,
              hypertrophyRestTime: config.hypertrophyRestTime,
              enduranceRestTime: config.enduranceRestTime,
              defaultRestTime: config.defaultRestTime,
            );

            exercise = exercise.copyWith(
              autoAdjustmentType: AutoAdjustmentType.apre,
              useAPRE: true,
              apreProtocol: protocol,
              restTime: restTime,
            );

            // Calculate base weight from history in background
            _calculateAndSetBaseWeight(exercise);
          }

          return exercise;
        }).toList(),
      );

      // Imposta il workout e lo avvia automaticamente
      state = workout.startWorkout();

      // Pre-calculate APRE weights for all exercises with APRE enabled
      if (isApreEnabled) {
        if (kDebugMode) {
          debugPrint('[APRE] Triggering pre-calculation of APRE weights for all exercises');
        }
        _preCalculateAllAPREWeights();
      }

      // Attiva wakelock se abilitato nelle impostazioni
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // Incrementa il contatore di utilizzo del template
      // Questo verrà gestito dal template provider
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error starting workout from template: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Ensure we don't leave the app in a bad state
      state = null;
      rethrow; // Allow UI to handle the error
    }
  }

  void startWorkout() {
    if (state != null) {
      state = state!.startWorkout();

      // Pre-calculate APRE weights for all exercises with APRE enabled
      _preCalculateAllAPREWeights();

      // Attiva wakelock se abilitato nelle impostazioni
      ref.read(screenWakelockProvider.notifier).startWakelock();
    }
  }

  void completeWorkout() {
    if (state != null) {
      state = state!.completeWorkout();

      // Haptic feedback for workout completion
      HapticFeedbackService.workoutCompletion(ref);

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
      // 🔒 SECURITY: Sanitize user input to prevent XSS/injection attacks
      final sanitizedWorkoutName = InputSanitizer.sanitizeName(workout.name);
      final sanitizedWorkoutNotes = InputSanitizer.sanitizeText(workout.notes ?? '');

      // Validate workout data before save
      final validation = InputSanitizer.validateWorkoutData(
        workoutName: sanitizedWorkoutName,
        notes: sanitizedWorkoutNotes,
        exerciseNames: workout.exercises.map((e) => e.name).toList(),
      );

      if (!validation.isValid) {
        debugPrint('❌ [WorkoutProvider] Validation failed: ${validation.errors.join(', ')}');
        // Don't throw - log error but continue with sanitized data
      }

      // 1. Convert Workout to WorkoutHistoryDetail (with sanitized data)
      final exercisesHistory = workout.exercises.map((exercise) {
        // 🔒 Sanitize exercise data
        final sanitizedExerciseName = InputSanitizer.sanitizeName(exercise.name);
        final sanitizedExerciseNotes = InputSanitizer.sanitizeText(exercise.notes ?? '', maxLength: 500);

        final setsHistory = exercise.sets.map((set) {
          // 🔒 Sanitize set notes
          final sanitizedSetNotes = set.notes != null
              ? InputSanitizer.sanitizeText(set.notes!, maxLength: 200)
              : null;

          return SetHistoryDetail(
            setNumber: set.setNumber,
            weight: double.tryParse(set.weight.toString()) ?? 0.0,
            reps: int.tryParse(set.reps.toString()) ?? 0,
            rpe: set.rpe ?? 0,
            notes: sanitizedSetNotes,
            isWarmup: set.isWarmup,
            // ✅ TUT & Advanced Tracking Fields
            setDurationMillis: set.setDurationMillis,
            setStartedAt: set.setStartedAt,
            completedAt: set.completedAt,
            actualReps: set.actualReps,
          );
        }).toList();

        return ExerciseHistoryDetail(
          id: exercise.id,
          name: sanitizedExerciseName,
          category: exercise.category.name ?? 'Other',
          notes: sanitizedExerciseNotes,
          sets: setsHistory,
          exerciseData: {},
        );
      }).toList();

      final workoutHistoryDetail = WorkoutHistoryDetail(
        id: workout.id,
        userId: currentUser.uid,
        name: sanitizedWorkoutName,
        description: sanitizedWorkoutNotes,
        createdAt: workout.createdAt,
        startedAt: workout.startTime ?? workout.createdAt,
        completedAt: workout.endTime ?? DateTime.now(),
        updatedAt: workout.updatedAt,
        duration: workout.duration ?? Duration.zero,
        exercises: exercisesHistory,
        metadata: {'source': 'app_completion'},
        templateId: workout.templateId, // ✅ CRITICAL FIX: Pass templateId for routine auto-detection
      );

      // 2. Save to 'workouts' collection in Firestore
      await FirebaseFirestore.instance
          .collection('workouts')
          .doc(workoutHistoryDetail.id)
          .set(workoutHistoryDetail.toFirestoreMap());

      // CRITICAL FIX: Check disposal after Firestore write
      if (_isDisposed) {
        debugPrint('⚠️ [WorkoutProvider] Provider disposed after Firestore save - aborting remaining operations');
        return;
      }

      // 3. Save workout using HiveWorkoutDataSource directly (unified approach)
      try {
        final hiveDataSource = ref.read(hiveWorkoutDataSourceProvider);
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final workoutModel = WorkoutModel.fromDomain(workout);
          await hiveDataSource.saveWorkout(workoutModel, userId);
          debugPrint('✅ [WorkoutProvider] Workout saved to unified Hive storage successfully');
        }
      } catch (saveError, stackTrace) {
        debugPrint('❌ [WorkoutProvider] CRITICAL: Failed to save workout: $saveError');
        debugPrint('📍 [WorkoutProvider] Stack trace: $stackTrace');
        // Continue execution - don't fail the entire completion process
      }

      // 4. Update user stats with transaction to prevent lost updates
      try {
        final firestore = FirebaseFirestore.instance;
        final userRef = firestore.collection('users').doc(currentUser.uid);

        // CRITICAL FIX: Use transaction to prevent lost updates from concurrent workouts
        await firestore.runTransaction((transaction) async {
          final userDoc = await transaction.get(userRef);

          // Initialize stats if document doesn't exist
          if (!userDoc.exists) {
            transaction.set(userRef, {
              'stats': {
                'totalWorkouts': 1,
                'lastWorkoutDate': FieldValue.serverTimestamp(),
                'totalVolume': workoutHistoryDetail.totalVolume,
                'monthlyWorkouts': 1,
              }
            }, SetOptions(merge: true));
            return;
          }

          // Get current stats or initialize
          final data = userDoc.data();
          final stats = data?['stats'] as Map<String, dynamic>? ?? {};
          final currentTotalWorkouts = stats['totalWorkouts'] as int? ?? 0;
          final currentTotalVolume = stats['totalVolume'] as num? ?? 0;
          final currentMonthlyWorkouts = stats['monthlyWorkouts'] as int? ?? 0;

          // Update with transactional safety
          transaction.update(userRef, {
            'stats.totalWorkouts': currentTotalWorkouts + 1,
            'stats.lastWorkoutDate': FieldValue.serverTimestamp(),
            'stats.totalVolume': currentTotalVolume + workoutHistoryDetail.totalVolume,
            'stats.monthlyWorkouts': currentMonthlyWorkouts + 1,
          });
        });
        debugPrint('✅ [WorkoutProvider] User stats updated atomically');
      } catch (statsError) {
        debugPrint('⚠️ [WorkoutProvider] Failed to update stats: $statsError');
        // Non-critical - workout is already saved
      }

      // CRITICAL FIX: Check disposal after stats update
      if (_isDisposed) {
        debugPrint('⚠️ [WorkoutProvider] Provider disposed after stats update - aborting remaining operations');
        return;
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

        // CRITICAL FIX: Check disposal after notification generation
        if (_isDisposed) {
          debugPrint('⚠️ [WorkoutProvider] Provider disposed after notification generation - skipping notification addition');
          return;
        }

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

      // 7. Auto-complete routine day if applicable
      try {
        final didAutoComplete = await _autoCompleteRoutineDay(workout);
        if (didAutoComplete) {
          debugPrint('✅ [Routine] Auto-completed routine day');
        }
      } catch (routineError) {
        debugPrint('⚠️ [Routine] Failed to auto-complete day: $routineError');
        // Non-critical - workout is already saved
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Critical error saving workout: $e');
      debugPrint('Stack: $stackTrace');
    }
  }

  /// Auto-complete routine day if workout matches scheduled template
  ///
  /// Returns true if a routine day was auto-completed, false otherwise.
  Future<bool> _autoCompleteRoutineDay(Workout workout) async {
    // 1. Check if workout has templateId
    if (workout.templateId == null || workout.templateId!.isEmpty) {
      debugPrint('[Routine] Workout has no templateId - skipping auto-completion');
      return false;
    }

    // 2. Get active routine
    final activeRoutineAsync = ref.read(activeFlexibleRoutineProvider);
    final activeRoutine = activeRoutineAsync.value;

    if (activeRoutine == null) {
      debugPrint('[Routine] No active routine - skipping auto-completion');
      return false;
    }

    debugPrint('[Routine] Checking workout template ${workout.templateId} against routine ${activeRoutine.name}');

    // 3. Find matching day in schedule
    // Priority: today > yesterday > last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = workout.startTime ?? now;
    final workoutDay = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);

    // Check dates in order of priority: workout day, today, yesterday, then last 7 days
    final datesToCheck = <DateTime>[
      workoutDay, // Day when workout was done
      today, // Today
      today.subtract(const Duration(days: 1)), // Yesterday
      today.subtract(const Duration(days: 2)),
      today.subtract(const Duration(days: 3)),
      today.subtract(const Duration(days: 4)),
      today.subtract(const Duration(days: 5)),
      today.subtract(const Duration(days: 6)),
      today.subtract(const Duration(days: 7)),
    ];

    // Remove duplicates while preserving order
    final uniqueDates = <DateTime>[];
    for (final date in datesToCheck) {
      if (!uniqueDates.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day)) {
        uniqueDates.add(date);
      }
    }

    // Find first matching scheduled day
    for (final date in uniqueDates) {
      final dateKey = _dateToString(date);
      final scheduledDay = activeRoutine.schedule[dateKey];

      if (scheduledDay == null) continue;

      // Check if templateId matches and day is not already completed
      if (scheduledDay.templateId == workout.templateId &&
          scheduledDay.status != DayStatus.completed) {
        debugPrint('[Routine] Found matching day: $dateKey (${scheduledDay.status})');

        // 4. Complete the day
        try {
          final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
          final success = await notifier.completeDayWorkout(
            routineId: activeRoutine.id,
            date: date,
            workoutId: workout.id,
          );

          if (success) {
            debugPrint('✅ [Routine] Auto-completed routine day $dateKey');

            // Refresh routine data
            ref.invalidate(activeFlexibleRoutineProvider);
            ref.invalidate(userFlexibleRoutinesProvider);

            return true;
          }
        } catch (e) {
          debugPrint('❌ [Routine] Error auto-completing day: $e');
          return false;
        }
      }
    }

    debugPrint('[Routine] No matching scheduled day found for template ${workout.templateId}');
    return false;
  }

  /// Convert DateTime to string key for schedule map (YYYY-MM-DD)
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    if (state == null) return;

    try {
      // Check if APRE is enabled globally and exercise doesn't have APRE configured yet
      final config = ref.read(appConfigProvider);
      final isApreEnabled = config.enableApre ?? false;

      Exercise exerciseToAdd = exercise;

      // Apply default APRE settings if enabled and exercise doesn't already have auto-adjustment
      if (isApreEnabled && exercise.autoAdjustmentType == null && exercise.type == ExerciseType.single) {
        // Auto-select protocol based on target reps
        final targetReps = exercise.sets.isNotEmpty ? (exercise.sets.first.reps ?? 6) : 6;
        final protocol = APREAutoRegulationService.selectProtocolFromTargetReps(targetReps);

        if (kDebugMode) {
          debugPrint('[APRE] Auto-selected protocol $protocol for ${exercise.name} (target reps: $targetReps)');
        }

        // Get appropriate rest time for protocol
        final restTime = APREAutoRegulationService.getRestTimeForProtocol(
          protocol,
          strengthRestTime: config.strengthRestTime,
          hypertrophyRestTime: config.hypertrophyRestTime,
          enduranceRestTime: config.enduranceRestTime,
          defaultRestTime: config.defaultRestTime,
        );

        exerciseToAdd = exercise.copyWith(
          autoAdjustmentType: AutoAdjustmentType.apre,
          useAPRE: true,
          apreProtocol: protocol,
          restTime: restTime,
        );

        // Calculate base weight from history in background
        _calculateAndSetBaseWeight(exerciseToAdd);
      }

      state = state!.addExercise(exerciseToAdd);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error adding exercise: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void removeExercise(String exerciseId) {
    if (state != null) {
      state = state!.removeExercise(exerciseId);
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (state == null) return;

    try {
      // Validate indices
      if (oldIndex < 0 || oldIndex >= state!.exercises.length ||
          newIndex < 0 || newIndex >= state!.exercises.length) {
        if (kDebugMode) {
          debugPrint('⚠️ [WorkoutProvider] Invalid reorder indices: old=$oldIndex, new=$newIndex, exercises=${state!.exercises.length}');
        }
        return;
      }

      // Adjust newIndex if moving down
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final exercises = List<Exercise>.from(state!.exercises);
      final exercise = exercises.removeAt(oldIndex);
      exercises.insert(newIndex, exercise);

      state = state!.copyWith(exercises: exercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error reordering exercises: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExercise(String exerciseId, Exercise updatedExercise) {
    if (state == null) return;

    try {
      state = state!.updateExercise(exerciseId, updatedExercise);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error updating exercise: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
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
    } catch (e) {
      // print('❌ Error updating exercise: $e');
      // print('Stack: $stackTrace');
    }
  }

  void completeSet(String exerciseId, String setId) {
    if (state == null) return;

    try {
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error completing set: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExerciseSet(String exerciseId, ExerciseSet updatedSet) {
    if (state == null) return;

    try {
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error updating exercise set: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateSupersetSet(String exerciseId, SupersetSet updatedSupersetSet) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId && exercise is SupersetExercise) {
          final updatedSupersetSets = exercise.supersetSets.map((set) {
            // ✅ FIX: Usa setNumber invece di id per identificare il round
            // Tutti i round creati insieme hanno lo stesso ID (timestamp),
            // ma setNumber è univoco (1, 2, 3, etc.)
            if (set.setNumber == updatedSupersetSet.setNumber) {
              return updatedSupersetSet;
            }
            return set;
          }).toList();
          return exercise.copyWith(supersetSets: updatedSupersetSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error updating superset set: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void addSetToExercise(String exerciseId) {
    if (state == null) return;

    try {
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error adding set to exercise: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void removeSetFromExercise(String exerciseId, String setId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == exerciseId) {
          final updatedSets = exercise.sets.where((set) => set.id != setId).toList();

          // Prevent removing last set
          if (updatedSets.isEmpty) {
            if (kDebugMode) {
              debugPrint('⚠️ [WorkoutProvider] Cannot remove last set from exercise');
            }
            return exercise;
          }

          // Renumber sets
          for (int i = 0; i < updatedSets.length; i++) {
            updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
          }

          return exercise.copyWith(sets: updatedSets);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error removing set from exercise: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Aggiunge un nuovo round a un superset
  void addRoundToSuperset(String supersetId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == supersetId && exercise is SupersetExercise) {
          final newRoundNumber = exercise.supersetSets.length + 1;
          final lastRound = exercise.supersetSets.isNotEmpty
              ? exercise.supersetSets.last
              : null;

          // Crea exerciseData per tutti gli esercizi del superset
          final Map<String, SupersetExerciseData> exerciseData = {};

          for (final ex in exercise.exercises) {
            // Usa i dati dell'ultimo round come template, o valori di default
            final lastData = lastRound?.exerciseData[ex.id];
            exerciseData[ex.id] = SupersetExerciseData(
              exerciseId: ex.id,
              exerciseName: ex.name,
              targetWeight: lastData?.targetWeight ?? lastData?.actualWeight ?? 0.0,
              targetReps: lastData?.targetReps ?? lastData?.actualReps ?? 10,
              actualWeight: null,
              actualReps: null,
              rpe: null,
              isCompleted: false,
              notes: null,
            );
          }

          // ✅ FIX: Genera ID univoco per il nuovo round
          final newRound = SupersetSet(
            id: 'superset_round_${DateTime.now().millisecondsSinceEpoch}_$newRoundNumber',
            setNumber: newRoundNumber,
            exerciseData: exerciseData,
            isCompleted: false,
          );

          return exercise.copyWith(
            supersetSets: [...exercise.supersetSets, newRound]
          );
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error adding round to superset: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Rimuove un round da un superset
  void removeRoundFromSuperset(String supersetId, String roundId) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == supersetId && exercise is SupersetExercise) {
          final updatedRounds = exercise.supersetSets
              .where((round) => round.id != roundId)
              .toList();

          // Prevent removing last round
          if (updatedRounds.isEmpty) {
            if (kDebugMode) {
              debugPrint('⚠️ [WorkoutProvider] Cannot remove last round from superset');
            }
            return exercise;
          }

          // Renumber rounds
          for (int i = 0; i < updatedRounds.length; i++) {
            updatedRounds[i] = updatedRounds[i].copyWith(setNumber: i + 1);
          }

          return exercise.copyWith(supersetSets: updatedRounds);
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error removing round from superset: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void clearWorkout() {
    try {
      state = null;

      // Disattiva wakelock quando si cancella il workout
      ref.read(screenWakelockProvider.notifier).stopWakelock();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [WorkoutProvider] Error clearing workout: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Ensure state is cleared even if wakelock fails
      state = null;
    }
  }

  /// Pre-calculate APRE weights for all exercises when starting workout
  Future<void> _preCalculateAllAPREWeights() async {
    if (state == null) return;

    // CRITICAL FIX: Prevent concurrent APRE calculations
    if (_apreCalculationInProgress) {
      debugPrint('[APRE] ⚠️ Calculation already in progress - skipping duplicate request');
      return;
    }

    _apreCalculationInProgress = true;
    debugPrint('[APRE] 🔒 Calculation started - locking concurrent access');

    try {
      await _preCalculateAllAPREWeightsInternal();
    } finally {
      _apreCalculationInProgress = false;
      debugPrint('[APRE] 🔓 Calculation complete - unlocking');
    }
  }

  /// Internal method for APRE calculation (called with lock held)
  Future<void> _preCalculateAllAPREWeightsInternal() async {
    debugPrint('[APRE] Pre-calculating weights for all APRE exercises...');

    // Get all exercises with APRE enabled that need calculation
    final apreExercises = state!.exercises
        .where((ex) => ex.useAPRE && ex.type == ExerciseType.single)
        .toList();

    if (apreExercises.isEmpty) {
      debugPrint('[APRE] No APRE exercises to calculate');
      return;
    }

    debugPrint('[APRE] Found ${apreExercises.length} APRE exercises to process');
    for (final ex in apreExercises) {
      debugPrint('[APRE]   - ${ex.name}: protocol=${ex.apreProtocol}, cached1RM=${ex.calculated1RM?.toStringAsFixed(1)}');
    }

    // Calculate weights for each exercise in parallel
    final futures = apreExercises.map((exercise) async {
      // Skip if calculations are recent AND values exist
      if (exercise.calculated1RM != null &&
          !APREAutoRegulationService.shouldRecalculate(exercise)) {
        debugPrint('[APRE] Skipping ${exercise.name} - calculations are recent and exist');
        debugPrint('[APRE]   Existing 1RM: ${exercise.calculated1RM?.toStringAsFixed(1)}kg');
        return null;
      }

      try {
        // Get exercise history
        final historyData = await ref.read(exerciseHistoryFromWorkoutsProvider(exercise.name).future);

        if (historyData.isEmpty) {
          debugPrint('[APRE] No history for ${exercise.name}');
          return null;
        }

        // Calculate APRE weights
        final calculations = APREAutoRegulationService.calculateAPREWeights(
          historicalSets: historyData,
          protocol: exercise.apreProtocol ?? 6,
          useMetricSystem: true,
        );

        if (calculations.isEmpty) {
          debugPrint('[APRE] No calculations returned for ${exercise.name}');
          return null;
        }

        debugPrint('[APRE] Calculations for ${exercise.name}:');
        debugPrint('[APRE]   1RM: ${calculations['calculated1RM']?.toStringAsFixed(1)}kg');
        debugPrint('[APRE]   3RM: ${calculations['calculated3RM']?.toStringAsFixed(1)}kg');
        debugPrint('[APRE]   6RM: ${calculations['calculated6RM']?.toStringAsFixed(1)}kg');
        debugPrint('[APRE]   10RM: ${calculations['calculated10RM']?.toStringAsFixed(1)}kg');

        // Return updated exercise
        return exercise.copyWith(
          apreBaseWeight: calculations['baseWeight']?.toDouble(),
          calculated1RM: calculations['calculated1RM']?.toDouble(),
          calculated3RM: calculations['calculated3RM']?.toDouble(),
          calculated6RM: calculations['calculated6RM']?.toDouble(),
          calculated10RM: calculations['calculated10RM']?.toDouble(),
          lastCalculationDate: DateTime.now(),
          calculationMetadata: calculations['metadata'],
        );
      } catch (e) {
        debugPrint('[APRE] Error calculating for ${exercise.name}: $e');
        return null;
      }
    });

    // Wait for all calculations to complete
    final results = await Future.wait(futures);

    // CRITICAL FIX: Check disposal state before updating state
    if (_isDisposed) {
      debugPrint('[APRE] ⚠️ Provider disposed during calculations - aborting state update');
      return;
    }

    // Update state with calculated exercises
    if (state != null) {
      final updatedExercises = state!.exercises.map((exercise) {
        // Find if this exercise was updated
        final updatedExercise = results.firstWhere(
          (result) => result != null && result.id == exercise.id,
          orElse: () => null,
        );
        return updatedExercise ?? exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);
      debugPrint('[APRE] Pre-calculation complete for ${results.where((r) => r != null).length} exercises');
    }
  }

  /// Calculate and set base weight for APRE from exercise history
  Future<void> _calculateAndSetBaseWeight(Exercise exercise) async {
    try {
      // Skip if calculations are recent AND values exist
      if (exercise.calculated1RM != null &&
          !APREAutoRegulationService.shouldRecalculate(exercise)) {
        debugPrint('[APRE] Using cached calculations for ${exercise.name}');
        debugPrint('[APRE]   Cached 1RM: ${exercise.calculated1RM?.toStringAsFixed(1)}kg');
        return;
      }

      // Get exercise history from Firebase
      final historyData = await ref.read(exerciseHistoryFromWorkoutsProvider(exercise.name).future);

      if (historyData.isEmpty) {
        debugPrint('⚠️ [APRE] No history for ${exercise.name}, skipping base weight calculation');
        return;
      }

      // Calculate APRE weights using the service
      final calculations = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: historyData,
        protocol: exercise.apreProtocol ?? 6,
        useMetricSystem: true, // TODO: Get from user settings
      );

      if (calculations.isEmpty) {
        debugPrint('⚠️ [APRE] Could not calculate weights for ${exercise.name}');
        return;
      }

      // CRITICAL FIX: Check disposal state before updating state
      if (_isDisposed) {
        debugPrint('[APRE] ⚠️ Provider disposed during calculation - aborting state update');
        return;
      }

      // Update exercise with calculated values
      if (state != null) {
        final updatedExercises = state!.exercises.map((ex) {
          if (ex.id == exercise.id) {
            return ex.copyWith(
              apreBaseWeight: calculations['baseWeight']?.toDouble(),
              calculated1RM: calculations['calculated1RM']?.toDouble(),
              calculated3RM: calculations['calculated3RM']?.toDouble(),
              calculated6RM: calculations['calculated6RM']?.toDouble(),
              calculated10RM: calculations['calculated10RM']?.toDouble(),
              lastCalculationDate: DateTime.now(),
              calculationMetadata: calculations['metadata'],
            );
          }
          return ex;
        }).toList();

        state = state!.copyWith(exercises: updatedExercises);
      }
    } catch (e) {
      debugPrint('❌ [APRE] Error calculating base weight for ${exercise.name}: $e');
    }
  }

  @override
  void dispose() {
    // CRITICAL FIX: Mark as disposed to prevent async operations from modifying state
    _isDisposed = true;
    debugPrint('🔒 [WorkoutProvider] Provider disposed - blocking future async operations');
    super.dispose();
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