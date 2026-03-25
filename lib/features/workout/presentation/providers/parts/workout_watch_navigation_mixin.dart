part of '../workout_provider.dart';

mixin WorkoutWatchNavigationMixin
    on Notifier<Workout?>, WorkoutCoreMixin, WorkoutWatchNotifyMixin {
  /// ⌚ Jump to a specific exercise when triggered from Apple Watch
  /// - exerciseIndex: 0-indexed position in the exercises list
  void _jumpToExerciseFromWatch(int exerciseIndex) {
    debugPrint('⌚ [FLUTTER] ↔️ Jumping to exercise at index $exerciseIndex');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Validate index
    if (exerciseIndex < 0 || exerciseIndex >= workout.exercises.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid exerciseIndex $exerciseIndex (have ${workout.exercises.length} exercises)',
      );
      return;
    }

    final targetExercise = workout.exercises[exerciseIndex];
    debugPrint('⌚ [FLUTTER] 🎯 Target exercise: ${targetExercise.name}');

    // Update Watch with the new exercise state
    _notifyWatchWorkoutUpdate();

    debugPrint(
      '⌚ [FLUTTER] ✅ Jumped to exercise ${exerciseIndex + 1}: ${targetExercise.name}',
    );
  }

  /// ⌚ Jump to a specific set when triggered from Apple Watch
  /// - setNumber: 1-indexed set number to navigate to
  void _jumpToSetFromWatch(int setNumber) {
    debugPrint('⌚ [FLUTTER] ↕️ Jumping to set $setNumber');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else {
        if (exercise.sets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      }
    }

    // Fallback to last exercise
    currentExercise ??= workout.exercises.isNotEmpty
        ? workout.exercises.last
        : null;

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Validate setNumber (1-indexed)
    final setIndex = setNumber - 1;
    if (setIndex < 0 || setIndex >= currentExercise.sets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid setNumber $setNumber (have ${currentExercise.sets.length} sets)',
      );
      return;
    }

    final targetSet = currentExercise.sets[setIndex];
    final appConfig = ref.read(appConfigProvider);
    final rpeTrackingEnabled = appConfig.rpeTracking ?? false;
    final effortScale = appConfig.effortScale;
    final locale = ref.read(localeProvider).languageCode;
    final effectiveTut = currentExercise.tut ?? _getDefaultTut(currentExercise);

    // Keep progress counters consistent with regular watch updates.
    final completedSets = workout.exercises.fold<int>(0, (total, e) {
      if (e is SupersetExercise) {
        return total + e.supersetSets.where((s) => s.isCompleted).length;
      } else if (e is DropSetExercise) {
        return total + e.stages.where((s) => s.isCompleted).length;
      } else if (e is RestPauseExercise) {
        return total + e.restPauseSets.where((s) => s.isCompleted).length;
      }
      return total + e.sets.where((s) => s.isCompleted).length;
    });
    final setsCompletedInExercise = currentExercise.sets
        .where((s) => s.isCompleted)
        .length;

    int? lastCompletedReps;
    for (int i = currentExercise.sets.length - 1; i >= 0; i--) {
      if (currentExercise.sets[i].isCompleted) {
        lastCompletedReps =
            currentExercise.sets[i].actualReps ?? currentExercise.sets[i].reps;
        break;
      }
    }

    final allSets = currentExercise.sets
        .map(
          (s) => {
            'weight': s.weight?.toDouble() ?? 0.0,
            'reps': s.reps ?? 0,
            'actualReps': s.actualReps,
            'isCompleted': s.isCompleted,
            'isWarmup': s.isWarmup,
            'minReps': s.minReps,
            'maxReps': s.maxReps,
          },
        )
        .toList();
    final exerciseNames = workout.exercises.map((e) => e.name).toList();
    final currentExerciseIdx = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );

    debugPrint(
      '⌚ [FLUTTER] 🎯 Target set: $setNumber of ${currentExercise.name}',
    );

    // Send a targeted update so Watch actually shows the selected set.
    _getFormCuesAndNotifyWatch(
      workoutId: workout.id,
      exerciseName: currentExercise.name,
      exerciseId: currentExercise.id,
      currentSet: setNumber,
      totalSets: currentExercise.sets.length,
      targetWeight: targetSet.weight,
      targetReps: targetSet.reps ?? targetSet.minReps,
      minReps: targetSet.minReps,
      maxReps: targetSet.maxReps,
      setsCompleted: completedSets,
      setsCompletedInExercise: setsCompletedInExercise,
      lastCompletedReps: lastCompletedReps,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: effectiveTut,
      isStartup: false,
      allSets: allSets,
      exerciseNames: exerciseNames,
      currentExerciseIndex: currentExerciseIdx >= 0 ? currentExerciseIdx : 0,
      restTime: currentExercise.restTime,
    );

    debugPrint(
      '⌚ [FLUTTER] ✅ Jumped to set $setNumber '
      '(${targetSet.weight?.toStringAsFixed(1) ?? "0.0"}kg × ${targetSet.reps ?? targetSet.minReps ?? 0})',
    );
  }

  /// ⌚ Copy weight and reps to all sets when triggered from Apple Watch
  /// - weight: Weight value to apply
  /// - reps: Reps value to apply
  void _copyToAllSetsFromWatch(double weight, int reps) {
    debugPrint('⌚ [FLUTTER] 📄 Copying to all sets: ${weight}kg × $reps');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          exerciseIndex = i;
          break;
        }
      } else {
        if (exercise.sets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    // Fallback to last exercise
    if (currentExercise == null && workout.exercises.isNotEmpty) {
      currentExercise = workout.exercises.last;
      exerciseIndex = workout.exercises.length - 1;
    }

    if (currentExercise == null || exerciseIndex < 0) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Update ALL sets with the new weight and reps (for non-superset exercises)
    if (currentExercise is! SupersetExercise) {
      final updatedSets = currentExercise.sets.map((set) {
        return set.copyWithExactTarget(weight: weight, reps: reps);
      }).toList();

      final updatedExercise = currentExercise.copyWith(sets: updatedSets);
      final updatedExercises = List<Exercise>.from(workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;

      state = workout.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      debugPrint(
        '⌚ [FLUTTER] ✅ Copied ${weight}kg × $reps to all ${updatedSets.length} sets of ${currentExercise.name}',
      );

      // Auto-save
      _autoSaveIfNeeded();

      // Update Watch with new state
      _notifyWatchWorkoutUpdate();
    } else {
      debugPrint('⌚ [FLUTTER] ⚠️ Copy to all sets not supported for supersets');
    }
  }

  /// ⌚ Copy from previous set when triggered from Apple Watch
  void _copyFromPreviousSetFromWatch() {
    debugPrint('⌚ [FLUTTER] 📋 Copying from previous set');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets)
    Exercise? currentExercise;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is! SupersetExercise &&
          exercise.sets.any((s) => !s.isCompleted)) {
        currentExercise = exercise;
        exerciseIndex = i;
        break;
      }
    }

    if (currentExercise == null || exerciseIndex < 0) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise with incomplete sets found');
      return;
    }

    // Find the first incomplete set
    final firstIncompleteIndex = currentExercise.sets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (firstIncompleteIndex <= 0) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ No previous set to copy from (current is first set)',
      );
      return;
    }

    // Get previous completed set
    final previousSet = currentExercise.sets[firstIncompleteIndex - 1];
    final currentSet = currentExercise.sets[firstIncompleteIndex];

    // Copy the full rep target from the previous set so exact reps and ranges
    // stay consistent on both iPhone and Watch.
    final updatedSet = currentSet.copyWeightAndRepTargetFrom(previousSet);

    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[firstIncompleteIndex] = updatedSet;

    final updatedExercise = currentExercise.copyWith(sets: updatedSets);
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚ [FLUTTER] ✅ Copied ${previousSet.weight}kg × ${previousSet.repsDisplay} from set $firstIncompleteIndex to set ${firstIncompleteIndex + 1}',
    );

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();
  }

  /// ⌚ Start a new timer with specific duration when triggered from Apple Watch
  /// - duration: Timer duration in seconds
  void _startNewTimerFromWatch(int duration) {
    debugPrint('⌚ [FLUTTER] ⏱️ Starting new timer: ${duration}s');

    // Use the unified timer provider to start a new rest timer
    final timerActions = ref.read(tier1TimerActionsProvider);

    // Get current exercise name for context
    String exerciseName = 'Rest';
    if (state != null) {
      for (final exercise in state!.exercises) {
        if (exercise is SupersetExercise) {
          if (exercise.supersetSets.any((s) => !s.isCompleted)) {
            exerciseName = exercise.name;
            break;
          }
        } else {
          if (exercise.sets.any((s) => !s.isCompleted)) {
            exerciseName = exercise.name;
            break;
          }
        }
      }
    }

    timerActions.startExerciseRest(
      seconds: duration,
      exerciseName: exerciseName,
      currentSet: 1,
      totalSets: 1,
    );

    debugPrint('⌚ [FLUTTER] ✅ Timer started: ${duration}s for $exerciseName');
  }
}
