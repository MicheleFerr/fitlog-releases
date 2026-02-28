part of '../workout_provider.dart';

mixin WorkoutWatchCommandsMixin on Notifier<Workout?>, WorkoutCoreMixin, WorkoutWatchNotifyMixin, WorkoutWatchTypeMixin, WorkoutWatchCompoundMixin {
  // ─── Abstract requirements ───────────────────────────────────────────────
  // Implemented in WorkoutSetMixin / WorkoutLifecycleMixin.
  // Declared here to avoid circular `on` constraints.

  /// Implemented in WorkoutSetMixin.
  void completeSet(String exerciseId, String setId);

  /// Implemented in WorkoutLifecycleMixin.
  void completeWorkout([BuildContext? context]);

  /// Implemented in WorkoutLifecycleMixin.
  void clearWorkout();

  // ─────────────────────────────────────────────────────────────────────────

  /// ⌚ Complete current set when triggered from Apple Watch
  /// - effort: Optional effort value (RPE 6-10 or RIR 0-4)
  /// - effortScale: "rpe" or "rir" to indicate how to interpret the effort value
  void completeCurrentSetFromWatch({int? effort, String? effortScale, int? actualReps}) {
    debugPrint('⌚ [FLUTTER] completeCurrentSetFromWatch called');
    if (effort != null) {
      debugPrint(
        '⌚ [FLUTTER] Effort from Watch: $effort (${effortScale ?? "rpe"})',
      );
    }
    if (actualReps != null) {
      debugPrint('⌚ [FLUTTER] Actual reps from Watch: $actualReps');
    }

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // ✅ FIX Bug 3: Find current exercise handling ALL exercise types
    // SupersetExercise has sets=[] so we must check supersetSets
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else if (exercise is DropSetExercise) {
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else if (exercise is RestPauseExercise) {
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
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

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ❌ No exercise with incomplete sets');
      return;
    }
    // Final binding for null-safety promotion in closures
    final activeExercise = currentExercise;

    // ✅ FIX Bug 3: If current exercise is a superset, delegate to superset handler
    if (currentExercise is SupersetExercise) {
      final superset = currentExercise;
      final currentRoundIndex = superset.supersetSets.indexWhere((s) => !s.isCompleted);
      debugPrint('⌚ [FLUTTER] 🔥 Current exercise is superset, delegating to _completeSupersetRoundFromWatch');
      _completeSupersetRoundFromWatch(
        roundNumber: currentRoundIndex >= 0 ? currentRoundIndex + 1 : 1,
        totalRounds: superset.supersetSets.length,
        exercises: superset.exercises.map((e) => e.name).toList(),
        effort: effort,
        effortScale: effortScale,
      );
      return;
    }

    // ✅ FIX: If current exercise is a dropset, delegate to dropset handler
    if (currentExercise is DropSetExercise) {
      debugPrint('⌚ [FLUTTER] 🔥 Current exercise is dropset, delegating to _completeDropsetFromWatch');
      _completeDropsetFromWatch(
        totalStages: currentExercise.stages.length,
        actualReps: actualReps,
        effort: effort,
        effortScale: effortScale,
      );
      return;
    }

    // ✅ FIX: If current exercise is a rest-pause, delegate to rest-pause handler
    if (currentExercise is RestPauseExercise) {
      debugPrint('⌚ [FLUTTER] 🔥 Current exercise is rest-pause, delegating to _completeRestPauseFromWatch');
      _completeRestPauseFromWatch(
        totalSets: currentExercise.restPauseSets.length,
        weight: currentExercise.weight,
        actualReps: actualReps,
        effort: effort,
        effortScale: effortScale,
      );
      return;
    }

    // Find first incomplete set
    final currentSet = activeExercise.sets.cast<ExerciseSet?>().firstWhere(
      (s) => s != null && !s.isCompleted,
      orElse: () => null,
    );

    if (currentSet == null) {
      debugPrint('⌚ [FLUTTER] ❌ No incomplete set found');
      return;
    }

    // ✅ DEDUPLICATION: Prevent duplicate processing from sendMessage + transferUserInfo
    // Both are sent for reliability, but we only want to process once
    final now = DateTime.now();
    if (_lastCompletedSetId == currentSet.id &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Duplicate message ignored (set ${currentSet.id} already completed)',
      );
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = currentSet.id;

    debugPrint(
      '⌚ [FLUTTER] ✅ Completing set ${currentSet.setNumber} of ${activeExercise.name}',
    );
    debugPrint(
      '⌚ [FLUTTER] Exercise ID: ${activeExercise.id}, Set ID: ${currentSet.id}',
    );

    // Convert RIR to RPE if needed (RIR 0-4 → RPE 10-6)
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
      debugPrint('⌚ [FLUTTER] Converted RIR $effort to RPE $rpeValue');
    }

    // If we have an effort value, update the set with RPE before completing
    if (rpeValue != null) {
      // Update set with RPE value
      final updatedSet = currentSet.copyWith(rpe: rpeValue);
      final setIndex = activeExercise.sets.indexWhere(
        (s) => s.id == currentSet.id,
      );
      if (setIndex >= 0) {
        final updatedSets = List<ExerciseSet>.from(activeExercise.sets);
        updatedSets[setIndex] = updatedSet;
        final updatedExercise = activeExercise.copyWith(sets: updatedSets);
        final exerciseIndex = workout.exercises.indexWhere(
          (e) => e.id == activeExercise.id,
        );
        if (exerciseIndex >= 0) {
          final updatedExercises = List<Exercise>.from(workout.exercises);
          updatedExercises[exerciseIndex] = updatedExercise;
          state = workout.copyWith(exercises: updatedExercises);
          debugPrint('⌚ [FLUTTER] ✅ Updated set with RPE $rpeValue');
        }
      }
    }

    // ⌚ If Watch sent actualReps (from rep range picker), set it on the set before completing
    if (actualReps != null) {
      // Re-read state in case RPE update modified it
      final currentWorkout = state!;
      final currentEx = currentWorkout.exercises.cast<Exercise?>().firstWhere(
        (e) => e != null && e.id == activeExercise.id,
        orElse: () => null,
      );
      if (currentEx != null) {
        final setIdx = currentEx.sets.indexWhere((s) => s.id == currentSet.id);
        if (setIdx >= 0) {
          final updatedSet2 = currentEx.sets[setIdx].copyWith(actualReps: actualReps);
          final updatedSets2 = List<ExerciseSet>.from(currentEx.sets);
          updatedSets2[setIdx] = updatedSet2;
          final updatedEx2 = currentEx.copyWith(sets: updatedSets2);
          final exIdx = currentWorkout.exercises.indexWhere((e) => e.id == currentEx.id);
          if (exIdx >= 0) {
            final updatedExercises2 = List<Exercise>.from(currentWorkout.exercises);
            updatedExercises2[exIdx] = updatedEx2;
            state = currentWorkout.copyWith(exercises: updatedExercises2);
            debugPrint('⌚ [FLUTTER] ✅ Updated set with actualReps $actualReps from Watch');
          }
        }
      }
    }

    // Use existing completeSet method
    debugPrint('⌚ [FLUTTER] 🎯 Calling completeSet...');
    completeSet(activeExercise.id, currentSet.id);
    debugPrint('⌚ [FLUTTER] ✅ completeSet finished');

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();
  }

  /// ⌚ Skip rest timer when triggered from Apple Watch
  void _skipRestFromWatch() {
    debugPrint('⌚ [FLUTTER] ⏭️ Skipping rest timer from Watch');

    // Skip the timer using the unified timer provider
    ref.read(unifiedTimerProvider.notifier).skipTimer();

    if (kDebugMode) {
      debugPrint('⌚ [FLUTTER] ✅ Rest timer skipped via Watch');
    }
  }

  /// ⌚ Handle health metrics from Apple Watch (HR, calories)
  void _handleHealthMetricsFromWatch(
    double heartRate,
    double calories,
    double elapsedTime,
  ) {
    debugPrint(
      '⌚ [FLUTTER] Health metrics from Watch: HR=${heartRate.toInt()}, Cal=${calories.toInt()}, Time=${elapsedTime.toInt()}s',
    );
    // TODO: Store/display these metrics in the workout UI
  }

  /// ⌚ End workout when triggered from Apple Watch
  /// [save] - if true, save the workout; if false, discard it
  void _endWorkoutFromWatch({bool save = true}) {
    debugPrint('⌚ [FLUTTER] 🏁 Ending workout from Watch (save: $save)');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout to end');
      return;
    }

    if (save) {
      // Complete the workout (saves and clears state)
      completeWorkout();
      if (kDebugMode) {
        debugPrint('⌚ [FLUTTER] ✅ Workout saved via Watch');
      }
    } else {
      // Discard the workout without saving
      clearWorkout();
      if (kDebugMode) {
        debugPrint('⌚ [FLUTTER] 🗑️ Workout discarded via Watch');
      }
    }
  }

  /// ⌚ Edit a SPECIFIC completed set's reps when triggered from Apple Watch
  /// - setIndex: 0-indexed position within completed sets of current exercise
  ///   (0 = first completed set, 1 = second completed set, etc.)
  /// - newReps: The new reps value to set
  void _editCompletedSetRepsFromWatch(int setIndex, int newReps) {
    debugPrint(
      '⌚ [FLUTTER] ✏️ Editing completed set at index $setIndex to: $newReps reps',
    );

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets, or last exercise if all complete)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      final hasIncompleteSets = exercise.sets.any((s) => !s.isCompleted);
      if (hasIncompleteSets) {
        currentExercise = exercise;
        break;
      }
    }

    // If all exercises are complete, use the last exercise
    currentExercise ??= workout.exercises.isNotEmpty
        ? workout.exercises.last
        : null;

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Build list of completed sets with their original indices
    final completedSets = <({ExerciseSet set, int originalIndex})>[];
    for (int i = 0; i < currentExercise.sets.length; i++) {
      if (currentExercise.sets[i].isCompleted) {
        completedSets.add((set: currentExercise.sets[i], originalIndex: i));
      }
    }

    // Validate setIndex
    if (setIndex < 0 || setIndex >= completedSets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid setIndex $setIndex (have ${completedSets.length} completed sets)',
      );
      return;
    }

    // Get the target set
    final target = completedSets[setIndex];
    final targetSet = target.set;
    final originalIndex = target.originalIndex;

    debugPrint(
      '⌚ [FLUTTER] Found target set: #${targetSet.setNumber} at index $originalIndex (actualReps: ${targetSet.actualReps} → $newReps)',
    );

    // Update the set with new actualReps
    final updatedSet = targetSet.copyWith(actualReps: newReps);
    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[originalIndex] = updatedSet;
    final updatedExercise = currentExercise.copyWith(sets: updatedSets);

    // Find and update exercise in workout
    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );
    if (exerciseIndex >= 0) {
      final updatedExercises = List<Exercise>.from(workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      state = workout.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      debugPrint(
        '⌚ [FLUTTER] ✅ Updated set ${targetSet.setNumber} actualReps to $newReps',
      );

      // Trigger auto-save
      _autoSaveIfNeeded();

      // Update Watch with new state
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    }
  }

  /// ⌚ Uncomplete (undo) a completed set from Watch
  /// - Parameter setIndex: 0-indexed position in completed sets list
  void _uncompleteSetFromWatch(int setIndex) {
    debugPrint('⌚ [FLUTTER] ↩️ Uncompleting set at index $setIndex');

    if (state == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No active workout');
      return;
    }

    final workout = state!;

    // Find the current exercise (first with incomplete sets, or last exercise if all complete)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      final hasIncompleteSets = exercise.sets.any((s) => !s.isCompleted);
      if (hasIncompleteSets) {
        currentExercise = exercise;
        break;
      }
    }

    // If all exercises are complete, use the last exercise
    currentExercise ??= workout.exercises.isNotEmpty
        ? workout.exercises.last
        : null;

    if (currentExercise == null) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise found');
      return;
    }

    // Build list of completed sets with their original indices
    final completedSets = <({ExerciseSet set, int originalIndex})>[];
    for (int i = 0; i < currentExercise.sets.length; i++) {
      if (currentExercise.sets[i].isCompleted) {
        completedSets.add((set: currentExercise.sets[i], originalIndex: i));
      }
    }

    // Validate setIndex
    if (setIndex < 0 || setIndex >= completedSets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid setIndex $setIndex (have ${completedSets.length} completed sets)',
      );
      return;
    }

    // Get the target set
    final target = completedSets[setIndex];
    final targetSet = target.set;
    final originalIndex = target.originalIndex;

    debugPrint(
      '⌚ [FLUTTER] Found target set: #${targetSet.setNumber} at index $originalIndex - marking as incomplete',
    );

    // ✅ FIX: Create new set directly instead of copyWith (copyWith can't set null values)
    final updatedSet = ExerciseSet(
      id: targetSet.id,
      setNumber: targetSet.setNumber,
      weight: targetSet.weight,
      reps: targetSet.reps,
      actualReps: null, // ✅ Reset to null
      rpe: null, // ✅ Reset to null
      restTime: targetSet.restTime,
      seconds: targetSet.seconds,
      distance: targetSet.distance,
      isCompleted: false, // ✅ Mark as incomplete
      notes: targetSet.notes,
      completedAt: null, // ✅ Reset to null
      setDurationMillis: null, // ✅ Reset to null
      setStartedAt: null, // ✅ Reset to null
      isWarmup: targetSet.isWarmup,
    );
    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[originalIndex] = updatedSet;
    final updatedExercise = currentExercise.copyWith(sets: updatedSets);

    // Find and update exercise in workout
    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );
    if (exerciseIndex >= 0) {
      final updatedExercises = List<Exercise>.from(workout.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      state = workout.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      debugPrint('⌚ [FLUTTER] ✅ Uncompleted set ${targetSet.setNumber}');

      // Trigger auto-save
      _autoSaveIfNeeded();

      // Update Watch with new state
      _notifyWatchWorkoutUpdate();

      // 📱 Sync Live Activity (iOS)
      _updateLiveActivityIfActive();
    }
  }

  /// ⌚ Update current set target (weight/reps) from Watch
  /// Called when user edits the target using Digital Crown before completing
  /// [setNumber] - 1-indexed set number being modified
  /// [isSuperset] - true if editing a superset exercise
  /// [exerciseIndexInSuperset] - 0-indexed position of exercise within superset
  void _updateCurrentSetTargetFromWatch(
    double weight,
    int reps, {
    required int setNumber,
    bool isSuperset = false,
    int? exerciseIndexInSuperset,
  }) {
    debugPrint(
      '⌚ [FLUTTER] ✏️ Updating set #$setNumber target: ${weight}kg × $reps reps (superset: $isSuperset, exerciseIndex: $exerciseIndexInSuperset)',
    );

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
      // For superset, check supersetSets; for others, check sets
      final hasIncompleteSets = exercise is SupersetExercise
          ? exercise.supersetSets.any((s) => !s.isCompleted)
          : exercise.sets.any((s) => !s.isCompleted);
      if (hasIncompleteSets) {
        currentExercise = exercise;
        exerciseIndex = i;
        break;
      }
    }

    if (currentExercise == null || exerciseIndex < 0) {
      debugPrint('⌚ [FLUTTER] ⚠️ No exercise with incomplete sets found');
      return;
    }

    // 🔥 SUPERSET: Handle superset set modification
    if (isSuperset &&
        currentExercise is SupersetExercise &&
        exerciseIndexInSuperset != null) {
      _updateSupersetTargetFromWatch(
        workout: workout,
        superset: currentExercise,
        exerciseIndex: exerciseIndex,
        exerciseIndexInSuperset: exerciseIndexInSuperset,
        weight: weight,
        reps: reps,
      );
      return;
    }

    // ✅ FIX: Use setNumber from Watch instead of finding first incomplete set
    // setNumber is 1-indexed, convert to 0-indexed
    final currentSetIndex = setNumber - 1;

    // Validate index bounds
    if (currentSetIndex < 0 || currentSetIndex >= currentExercise.sets.length) {
      debugPrint(
        '⌚ [FLUTTER] ⚠️ Invalid set index: $currentSetIndex (setNumber: $setNumber, total sets: ${currentExercise.sets.length})',
      );
      return;
    }

    final currentSet = currentExercise.sets[currentSetIndex];
    debugPrint(
      '⌚ [FLUTTER] ✅ Targeting set #$setNumber at index $currentSetIndex',
    );

    // Update the set with new weight and reps
    final updatedSet = currentSet.copyWith(weight: weight, reps: reps);

    final updatedSets = List<ExerciseSet>.from(currentExercise.sets);
    updatedSets[currentSetIndex] = updatedSet;
    final updatedExercise = currentExercise.copyWith(sets: updatedSets);

    // Update exercise in workout
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚ [FLUTTER] ✅ Updated set ${currentSet.setNumber} target to ${weight}kg × $reps reps',
    );

    // ✅ DEBUG: Verify the state was updated correctly
    final verifyExercise = state!.exercises[exerciseIndex];
    final verifySet = verifyExercise.sets[currentSetIndex];
    debugPrint(
      '⌚ [FLUTTER] 🔍 VERIFY: Exercise "${verifyExercise.name}" Set #${verifySet.setNumber}',
    );
    debugPrint(
      '⌚ [FLUTTER] 🔍 VERIFY: weight=${verifySet.weight}, reps=${verifySet.reps}',
    );

    // Trigger auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state (confirms the change)
    _notifyWatchWorkoutUpdate();
  }

  /// 🔥 SUPERSET: Update target weight/reps for a specific exercise within a superset
  void _updateSupersetTargetFromWatch({
    required Workout workout,
    required SupersetExercise superset,
    required int exerciseIndex,
    required int exerciseIndexInSuperset,
    required double weight,
    required int reps,
  }) {
    debugPrint(
      '⌚🔥 [FLUTTER] Updating superset target: exerciseIndex=$exerciseIndexInSuperset, weight=$weight, reps=$reps',
    );

    // Find the current round (first incomplete SupersetSet)
    int currentRoundIndex = -1;
    for (int i = 0; i < superset.supersetSets.length; i++) {
      if (!superset.supersetSets[i].isCompleted) {
        currentRoundIndex = i;
        break;
      }
    }

    if (currentRoundIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ⚠️ No incomplete superset round found');
      return;
    }

    // Validate exercise index
    if (exerciseIndexInSuperset < 0 ||
        exerciseIndexInSuperset >= superset.exercises.length) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⚠️ Invalid exercise index: $exerciseIndexInSuperset (max: ${superset.exercises.length - 1})',
      );
      return;
    }

    // Get the exercise ID from the exercises list
    final targetExerciseId = superset.exercises[exerciseIndexInSuperset].id;
    final targetExerciseName = superset.exercises[exerciseIndexInSuperset].name;
    debugPrint(
      '⌚🔥 [FLUTTER] Target exercise: "$targetExerciseName" (id: $targetExerciseId)',
    );

    // Get current round and update the exercise data
    final currentRound = superset.supersetSets[currentRoundIndex];
    final existingData = currentRound.exerciseData[targetExerciseId];

    if (existingData == null) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⚠️ No exercise data found for id: $targetExerciseId',
      );
      return;
    }

    // Update target weight and reps
    final updatedExerciseData = existingData.copyWith(
      targetWeight: weight,
      targetReps: reps,
    );

    // Create updated exerciseData map
    final updatedDataMap = Map<String, SupersetExerciseData>.from(
      currentRound.exerciseData,
    );
    updatedDataMap[targetExerciseId] = updatedExerciseData;

    // Create updated round
    final updatedRound = currentRound.copyWith(exerciseData: updatedDataMap);

    // Create updated supersetSets list
    final updatedSupersetSets = List<SupersetSet>.from(superset.supersetSets);
    updatedSupersetSets[currentRoundIndex] = updatedRound;

    // Create updated superset
    final updatedSuperset = superset.copyWith(
      supersetSets: updatedSupersetSets,
    );

    // Update exercise in workout
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedSuperset;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Updated superset exercise "$targetExerciseName" target to ${weight}kg × $reps reps',
    );

    // Trigger auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state (confirms the change)
    _notifyWatchWorkoutUpdate();
  }

  /// 🧪 TEST ONLY: Public wrapper for testing superset target updates
  /// DO NOT use in production code - use the Watch callback system instead
  @visibleForTesting
  void updateSupersetTargetFromWatchTest({
    required int exerciseIndexInSuperset,
    required double weight,
    required int reps,
  }) {
    _updateCurrentSetTargetFromWatch(
      weight,
      reps,
      setNumber:
          1, // Not used for superset (uses exerciseIndexInSuperset instead)
      isSuperset: true,
      exerciseIndexInSuperset: exerciseIndexInSuperset,
    );
  }

}
