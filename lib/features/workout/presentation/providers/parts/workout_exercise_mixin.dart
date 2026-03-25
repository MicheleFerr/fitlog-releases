part of '../workout_provider.dart';

mixin WorkoutExerciseMixin
    on
        Notifier<Workout?>,
        WorkoutCoreMixin,
        WorkoutWatchNotifyMixin,
        WorkoutWatchTypeMixin {
  void addExercise(Exercise exercise) {
    if (state == null) return;

    if (kDebugMode) {
      debugPrint(
        '🔍 [WorkoutProvider] addExercise RECEIVED: name=${exercise.name}, countingMode=${exercise.countingMode}',
      );
    }

    // SESSION: Record activity to prevent auto-logout during workout
    ref.read(sessionActivityRecorderProvider);

    try {
      state = state!.addExercise(exercise);

      if (kDebugMode) {
        debugPrint(
          '🔍 [WorkoutProvider] addExercise FINAL exercise.countingMode=${exercise.countingMode}',
        );
      }

      // Auto-save modifications
      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

      // Track exercise added
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseAdded(
        workoutId: state!.id,
        exerciseId: exercise.stableExerciseId,
        exerciseName: exercise.name,
        exerciseCategory: exercise.category.name,
        sets: exercise.sets.length,
        source: 'add_exercise_modal',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error adding exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Insert exercise at specific position (before another exercise)
  void insertExerciseAt(int index, Exercise exercise) {
    if (state == null) return;

    if (kDebugMode) {
      debugPrint(
        '🔍 [WorkoutProvider] insertExerciseAt index=$index, name=${exercise.name}',
      );
    }

    // Record session activity
    ref.read(sessionActivityRecorderProvider);

    try {
      state = state!.insertExerciseAt(index, exercise);

      // Auto-save
      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

      // Track analytics
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseAdded(
        workoutId: state!.id,
        exerciseId: exercise.stableExerciseId,
        exerciseName: exercise.name,
        exerciseCategory: exercise.category.name,
        sets: exercise.sets.length,
        source: 'warmup_suggestion',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error inserting exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
    }
  }

  void removeExercise(String exerciseId) {
    if (state != null) {
      // SESSION: Record activity to prevent auto-logout during workout
      ref.read(sessionActivityRecorderProvider);

      // Find exercise before removing for analytics
      final exercise = state!.exercises.firstWhere(
        (ex) => ex.id == exerciseId,
        orElse: () => Exercise(
          name: 'Unknown',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
          sets: [],
        ),
      );

      state = state!.removeExercise(exerciseId);

      // Auto-save modifications
      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

      // Track exercise removed
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseRemoved(
        workoutId: state!.id,
        exerciseId: exercise.stableExerciseId,
        exerciseName: exercise.name,
      );
    }
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (state == null) return;

    try {
      final exerciseCount = state!.exercises.length;

      // Validate indices
      if (oldIndex < 0 ||
          oldIndex >= exerciseCount ||
          newIndex < 0 ||
          newIndex > exerciseCount) {
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '⚠️ [WorkoutProvider] Invalid reorder indices: old=$oldIndex, new=$newIndex, exercises=$exerciseCount',
          );
        }
        return;
      }

      var targetIndex = newIndex;

      // Adjust newIndex if moving down
      if (oldIndex < targetIndex) {
        targetIndex -= 1;
      }

      // No-op reorder
      if (oldIndex == targetIndex) {
        return;
      }

      final exercises = List<Exercise>.from(state!.exercises);
      final exercise = exercises.removeAt(oldIndex);
      exercises.insert(targetIndex, exercise);

      state = state!.copyWith(exercises: exercises);

      // BUG FIX: Save after reordering
      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error reordering exercises: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExercise(String exerciseId, Exercise updatedExercise) {
    if (state == null) return;

    try {
      state = state!.updateExercise(exerciseId, updatedExercise);

      // Auto-save modifications
      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();

      // Track exercise customized
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseCustomized(
        workoutId: state!.id,
        exerciseId: updatedExercise.stableExerciseId,
        fieldChanged: 'exercise_data',
        oldValue: 'previous_state',
        newValue: 'updated_state',
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error updating exercise: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  /// Check if an exercise has completed sets.
  /// Returns number of completed sets.
  int getCompletedSetsCount(String exerciseId) {
    if (state == null) return 0;

    try {
      final exercise = state!.exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      return exercise.sets.where((set) => set.isCompleted).length;
    } catch (e) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error checking completed sets: $e',
        );
      }
      return 0;
    }
  }

  /// Change the counting mode of an exercise (weighted/reps/time).
  /// Used when user needs to fix template counting format during workout.
  void changeExerciseCountingMode(
    String exerciseId,
    ExerciseCountingMode newMode,
  ) {
    if (state == null) return;

    try {
      // Find exercise
      final exercise = state!.exercises.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => throw Exception('Exercise not found'),
      );

      // Create updated exercise with new counting mode
      final updatedExercise = exercise.copyWith(
        countingMode: newMode,
        updatedAt: DateTime.now(),
      );

      // Update exercise in state
      updateExercise(exerciseId, updatedExercise);

      // Track counting mode changed
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackExerciseCustomized(
        workoutId: state!.id,
        exerciseId: exerciseId,
        fieldChanged: 'counting_mode',
        oldValue: exercise.countingMode.name,
        newValue: newMode.name,
      );

      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '✅ [WorkoutProvider] Counting mode changed: ${exercise.name} → ${newMode.name}',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error changing counting mode: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }

  void updateExerciseOnly(Exercise updatedExercise) {
    if (state == null) return;

    try {
      final updatedExercises = state!.exercises.map((exercise) {
        if (exercise.id == updatedExercise.id) {
          return updatedExercise;
        }
        return exercise;
      }).toList();

      state = state!.copyWith(exercises: updatedExercises);

      // Auto-save modifications
      _autoSaveIfNeeded();

      // Sync to Watch
      _notifyWatchWorkoutUpdate();

      // Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error in updateExerciseOnly: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - silently fail to avoid disrupting user experience
    }
  }
}
