part of '../workout_provider.dart';

mixin WorkoutWatchCompoundMixin
    on
        Notifier<Workout?>,
        WorkoutCoreMixin,
        WorkoutHelpersMixin,
        WorkoutWatchNotifyMixin,
        WorkoutWatchTypeMixin {
  bool _isAutoRestTimerEnabled() {
    return ref.read(appConfigProvider).isAutoRestTimerEnabled;
  }

  // ============================================================
  // SUPERSET: Watch handlers
  // ============================================================

  /// Complete an entire superset round when triggered from Apple Watch
  /// - roundNumber: 1-indexed round that was completed
  /// - totalRounds: Total rounds in the superset
  /// - exercises: List of exercise names in the round
  /// - effort: Optional effort value (RPE 6-10 or RIR 0-4) for the entire round
  /// - effortScale: "rpe" or "rir" to indicate how to interpret the effort value
  void _completeSupersetRoundFromWatch({
    required int roundNumber,
    required int totalRounds,
    required List<String> exercises,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeSupersetRoundFromWatch called');
    debugPrint(
      '⌚🔥 [FLUTTER] Round $roundNumber/$totalRounds, exercises: $exercises',
    );
    if (effort != null) {
      debugPrint('⌚🔥 [FLUTTER] Effort: $effort (${effortScale ?? "rpe"})');
    }

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current superset exercise (first superset with incomplete rounds)
    SupersetExercise? currentSuperset;
    int supersetIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is SupersetExercise) {
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentSuperset = exercise;
          supersetIndex = i;
          break;
        }
      }
    }

    if (currentSuperset == null || supersetIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No superset with incomplete rounds found');
      return;
    }

    // Find the current round (first incomplete)
    final currentRoundIndex = currentSuperset.supersetSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentRoundIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No incomplete round found');
      return;
    }

    final currentRound = currentSuperset.supersetSets[currentRoundIndex];
    debugPrint(
      '⌚🔥 [FLUTTER] Found round ${currentRoundIndex + 1} to complete',
    );

    // DEDUPLICATION: Prevent duplicate processing from sendMessage + transferUserInfo
    final now = DateTime.now();
    final roundKey = '${currentSuperset.id}_round_$currentRoundIndex';
    if (_lastCompletedSetId == roundKey &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⚠️ Duplicate message ignored (round already completed)',
      );
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = roundKey;

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
      debugPrint('⌚🔥 [FLUTTER] Converted RIR $effort to RPE $rpeValue');
    }

    // Build completed exercise data for all exercises in the round
    final Map<String, SupersetExerciseData> completedExerciseData = {};
    for (final ex in currentSuperset.exercises) {
      final existingData = currentRound.exerciseData[ex.id];
      completedExerciseData[ex.id] = SupersetExerciseData(
        exerciseId: ex.id,
        exerciseName: ex.name,
        targetWeight: existingData?.targetWeight ?? 0.0,
        targetReps: existingData?.targetReps ?? 10,
        // Use actual values if already set, otherwise use target values
        actualWeight:
            existingData?.actualWeight ?? existingData?.targetWeight ?? 0.0,
        actualReps: existingData?.actualReps ?? existingData?.targetReps ?? 10,
        rpe: rpeValue, // Apply RPE to all exercises in the round
        isCompleted: true,
      );
    }

    // Create completed SupersetSet
    final completedSet = SupersetSet(
      id: currentRound.id,
      setNumber: currentRound.setNumber,
      exerciseData: completedExerciseData,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Created completed SupersetSet for round ${currentRound.setNumber}',
    );

    // Update the superset with the completed round
    final updatedSupersetSets = currentSuperset.supersetSets.map((set) {
      if (set.setNumber == completedSet.setNumber) {
        return completedSet;
      }
      return set;
    }).toList();

    final updatedSuperset = currentSuperset.copyWith(
      supersetSets: updatedSupersetSets,
    );
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[supersetIndex] = updatedSuperset;

    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint('⌚🔥 [FLUTTER] ✅ Updated workout state with completed round');

    // Check if this was the last round
    final remainingRounds = updatedSuperset.supersetSets
        .where((s) => !s.isCompleted)
        .length;
    final isLastRound = remainingRounds == 0;

    debugPrint(
      '⌚🔥 [FLUTTER] Remaining rounds: $remainingRounds, isLastRound: $isLastRound',
    );

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    final autoRestTimerEnabled = _isAutoRestTimerEnabled();

    // Start rest timer if not last round
    if (!isLastRound) {
      if (!autoRestTimerEnabled) {
        debugPrint(
          '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping rest timer after superset round',
        );
        return;
      }

      final restDuration = currentSuperset.restTime ?? 90;
      debugPrint('⌚🔥 [FLUTTER] ⏱️ Starting rest timer: ${restDuration}s');

      // Use tier1TimerActions to start rest timer (same as UI)
      final timerActions = ref.read(tier1TimerActionsProvider);
      timerActions.startExerciseRest(
        seconds: restDuration,
        exerciseName:
            '${currentSuperset.name} - Round ${currentRoundIndex + 2}',
        currentSet: currentRoundIndex + 2,
        totalSets: currentSuperset.supersetSets.length,
      );
    } else {
      debugPrint(
        '⌚🔥 [FLUTTER] 🏁 Superset completed! Checking for next exercise...',
      );

      // Start inter-exercise timer if there's a next exercise
      final nextExercise = _getNextIncompleteExercise(state!, currentSuperset);
      if (!autoRestTimerEnabled) {
        debugPrint(
          '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping inter-exercise timer after superset',
        );
      } else if (nextExercise != null) {
        final interExerciseRest = _resolveInterExerciseRest(currentSuperset);
        final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

        debugPrint(
          '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after superset: ${interExerciseRest}s before ${nextExercise.name}',
        );

        ref
            .read(unifiedTimerProvider.notifier)
            .startTimer(
              durationSeconds: interExerciseRest,
              type: TimerType.interExercise,
              exerciseName: nextExercise.name,
              currentSet: 1,
              totalSets: nextExerciseTotalSets,
              exerciseId: nextExercise.id,
            );

        // iOS: Transition Live Activity
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .transitionToRest(
                restDurationSeconds: interExerciseRest,
                nextExercise: nextExercise,
                nextSetIndex: 1,
              );
        }
      } else {
        debugPrint(
          '⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!',
        );
      }
    }
  }

  // ============================================================
  // DROPSET: Watch handlers
  // ============================================================

  /// Handle dropset stage completion from Watch
  void _completeDropsetStageFromWatch({
    required int stageIndex,
    required int totalStages,
    required int actualReps,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeDropsetStageFromWatch called');
    debugPrint(
      '⌚🔥 [FLUTTER] Stage ${stageIndex + 1}/$totalStages, reps: $actualReps',
    );

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current dropset exercise (first dropset with incomplete stages)
    DropSetExercise? currentDropset;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is DropSetExercise) {
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentDropset = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentDropset == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No dropset with incomplete stages found');
      return;
    }

    // Find the target stage (should match stageIndex or first incomplete)
    final targetStageIndex = currentDropset.stages.indexWhere(
      (s) => !s.isCompleted,
    );
    if (targetStageIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No incomplete stage found');
      return;
    }

    // DEDUPLICATION: Prevent duplicate processing
    final now = DateTime.now();
    final stageKey = '${currentDropset.id}_stage_$targetStageIndex';
    if (_lastCompletedSetId == stageKey &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint('⌚🔥 [FLUTTER] ⚠️ Duplicate message ignored');
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = stageKey;

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Update the stage
    final currentStage = currentDropset.stages[targetStageIndex];
    final updatedStages = List<DropSetStage>.from(currentDropset.stages);
    updatedStages[targetStageIndex] = currentStage.copyWith(
      actualReps: actualReps,
      rpe: rpeValue,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Create updated exercise
    final updatedExercise = DropSetExercise(
      id: currentDropset.id,
      name: currentDropset.name,
      category: currentDropset.category,
      stages: updatedStages,
      notes: currentDropset.notes,
      restTime: currentDropset.restTime,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Dropset stage ${targetStageIndex + 1} completed',
    );

    // Check if there are more stages
    final remainingStages = updatedExercise.stages
        .where((s) => !s.isCompleted)
        .length;
    final isLastStage = remainingStages == 0;

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // Dropset stages are typically done without rest between them
    // (the "drop" is immediate), but we check for inter-exercise timer after LAST stage
    if (isLastStage) {
      final autoRestTimerEnabled = _isAutoRestTimerEnabled();
      debugPrint(
        '⌚🔥 [FLUTTER] 🏁 Dropset completed! Checking for next exercise...',
      );

      // Start inter-exercise timer if there's a next exercise
      final nextExercise = _getNextIncompleteExercise(state!, currentDropset);
      if (!autoRestTimerEnabled) {
        debugPrint(
          '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping inter-exercise timer after dropset',
        );
      } else if (nextExercise != null) {
        final interExerciseRest = _resolveInterExerciseRest(currentDropset);
        final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

        debugPrint(
          '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after dropset: ${interExerciseRest}s before ${nextExercise.name}',
        );

        ref
            .read(unifiedTimerProvider.notifier)
            .startTimer(
              durationSeconds: interExerciseRest,
              type: TimerType.interExercise,
              exerciseName: nextExercise.name,
              currentSet: 1,
              totalSets: nextExerciseTotalSets,
              exerciseId: nextExercise.id,
            );

        // iOS: Transition Live Activity
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .transitionToRest(
                restDurationSeconds: interExerciseRest,
                nextExercise: nextExercise,
                nextSetIndex: 1,
              );
        }
      } else {
        debugPrint(
          '⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!',
        );
      }
    }
  }

  /// Handle entire dropset completion from Watch (all stages done at once)
  void _completeDropsetFromWatch({
    required int totalStages,
    int? actualReps,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeDropsetFromWatch called');
    debugPrint('⌚🔥 [FLUTTER] Total stages: $totalStages');

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current dropset exercise
    DropSetExercise? currentDropset;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is DropSetExercise) {
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentDropset = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentDropset == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No dropset with incomplete stages found');
      return;
    }

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Mark all remaining stages as completed
    // actualReps from Watch picker applies to the last remaining stage
    final incompleteStages = currentDropset.stages
        .where((s) => !s.isCompleted)
        .toList();
    final isLastStage = incompleteStages.length == 1;
    final updatedStages = currentDropset.stages.map((stage) {
      if (!stage.isCompleted) {
        return stage.copyWith(
          // Use actual reps from Watch picker for the last stage, else target reps
          actualReps: (isLastStage && actualReps != null)
              ? actualReps
              : stage.reps,
          rpe: rpeValue,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return stage;
    }).toList();

    // Create updated exercise using copyWith to preserve all fields
    final updatedExercise = currentDropset.copyWith(stages: updatedStages);

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint('⌚🔥 [FLUTTER] ✅ Entire dropset completed');

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    final autoRestTimerEnabled = _isAutoRestTimerEnabled();

    // Start inter-exercise timer if there's a next exercise
    final nextExercise = _getNextIncompleteExercise(state!, currentDropset);
    if (!autoRestTimerEnabled) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping inter-exercise timer after dropset',
      );
    } else if (nextExercise != null) {
      final interExerciseRest = _resolveInterExerciseRest(currentDropset);
      final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

      debugPrint(
        '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after dropset: ${interExerciseRest}s before ${nextExercise.name}',
      );

      ref
          .read(unifiedTimerProvider.notifier)
          .startTimer(
            durationSeconds: interExerciseRest,
            type: TimerType.interExercise,
            exerciseName: nextExercise.name,
            currentSet: 1,
            totalSets: nextExerciseTotalSets,
            exerciseId: nextExercise.id,
          );

      if (Platform.isIOS) {
        ref
            .read(workoutSessionLAProvider.notifier)
            .transitionToRest(
              restDurationSeconds: interExerciseRest,
              nextExercise: nextExercise,
              nextSetIndex: 1,
            );
      }
    } else {
      debugPrint(
        '⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!',
      );
    }
  }

  // ============================================================
  // REST-PAUSE: Watch handlers
  // ============================================================

  /// Handle rest-pause set completion from Watch
  void _completeRestPauseSetFromWatch({
    required int setIndex,
    required int totalSets,
    required int actualReps,
    required double weight,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeRestPauseSetFromWatch called');
    debugPrint(
      '⌚🔥 [FLUTTER] Set ${setIndex + 1}/$totalSets, reps: $actualReps, weight: $weight',
    );

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current rest-pause exercise (first with incomplete sets)
    RestPauseExercise? currentRestPause;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is RestPauseExercise) {
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
          currentRestPause = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentRestPause == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No rest-pause with incomplete sets found');
      return;
    }

    // Find the target set (should match setIndex or first incomplete)
    final targetSetIndex = currentRestPause.restPauseSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (targetSetIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No incomplete set found');
      return;
    }

    // DEDUPLICATION: Prevent duplicate processing
    final now = DateTime.now();
    final setKey = '${currentRestPause.id}_set_$targetSetIndex';
    if (_lastCompletedSetId == setKey &&
        _lastWatchSetCompletion != null &&
        now.difference(_lastWatchSetCompletion!).inSeconds < 3) {
      debugPrint('⌚🔥 [FLUTTER] ⚠️ Duplicate message ignored');
      return;
    }
    _lastWatchSetCompletion = now;
    _lastCompletedSetId = setKey;

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Update the set
    final currentSet = currentRestPause.restPauseSets[targetSetIndex];
    final updatedSets = List<RestPauseSet>.from(currentRestPause.restPauseSets);
    updatedSets[targetSetIndex] = currentSet.copyWith(
      actualReps: actualReps,
      rpe: rpeValue,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    // Create updated exercise using copyWith to preserve all fields
    final updatedExercise = currentRestPause.copyWith(
      restPauseSets: updatedSets,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint(
      '⌚🔥 [FLUTTER] ✅ Rest-Pause set ${targetSetIndex + 1} completed',
    );

    // Check if there are more sets
    final remainingSets = updatedExercise.restPauseSets
        .where((s) => !s.isCompleted)
        .length;
    final isLastSet = remainingSets == 0;

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    final autoRestTimerEnabled = _isAutoRestTimerEnabled();

    // Start short rest timer between rest-pause sets (not the full rest)
    if (!isLastSet) {
      if (!autoRestTimerEnabled) {
        debugPrint(
          '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping rest-pause timer',
        );
        return;
      }

      // Use the rest seconds from the NEXT set (if available)
      final nextSetIndex = targetSetIndex + 1;
      if (nextSetIndex < updatedExercise.restPauseSets.length) {
        final nextSet = updatedExercise.restPauseSets[nextSetIndex];
        final restSeconds = nextSet.restSeconds > 0
            ? nextSet.restSeconds
            : 15; // Default 15s

        final timerActions = ref.read(tier1TimerActionsProvider);
        timerActions.startExerciseRest(
          seconds: restSeconds,
          exerciseName: '${currentRestPause.name} - Set ${nextSetIndex + 1}',
          currentSet: nextSetIndex + 1,
          totalSets: updatedExercise.restPauseSets.length,
        );
      }
    } else {
      // Last set - move to next exercise using the same policy as other flows
      final nextExercise = _getNextIncompleteExercise(state!, currentRestPause);
      if (!autoRestTimerEnabled) {
        debugPrint(
          '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping inter-exercise timer after rest-pause',
        );
      } else if (nextExercise != null) {
        final interExerciseRest = _resolveInterExerciseRest(currentRestPause);
        final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

        debugPrint(
          '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after rest-pause: ${interExerciseRest}s before ${nextExercise.name}',
        );

        ref
            .read(unifiedTimerProvider.notifier)
            .startTimer(
              durationSeconds: interExerciseRest,
              type: TimerType.interExercise,
              exerciseName: nextExercise.name,
              currentSet: 1,
              totalSets: nextExerciseTotalSets,
              exerciseId: nextExercise.id,
            );

        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .transitionToRest(
                restDurationSeconds: interExerciseRest,
                nextExercise: nextExercise,
                nextSetIndex: 1,
              );
        }
      } else {
        debugPrint(
          '⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!',
        );
      }
    }
  }

  /// Handle entire rest-pause completion from Watch (all sets done at once)
  void _completeRestPauseFromWatch({
    required int totalSets,
    required double weight,
    int? actualReps,
    int? effort,
    String? effortScale,
  }) {
    debugPrint('⌚🔥 [FLUTTER] _completeRestPauseFromWatch called');
    debugPrint('⌚🔥 [FLUTTER] Total sets: $totalSets, weight: $weight');

    if (state == null) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No active workout');
      return;
    }

    final workout = state!;

    // Find current rest-pause exercise
    RestPauseExercise? currentRestPause;
    int exerciseIndex = -1;
    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      if (exercise is RestPauseExercise) {
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
          currentRestPause = exercise;
          exerciseIndex = i;
          break;
        }
      }
    }

    if (currentRestPause == null || exerciseIndex < 0) {
      debugPrint('⌚🔥 [FLUTTER] ❌ No rest-pause with incomplete sets found');
      return;
    }

    // Convert RIR to RPE if needed
    int? rpeValue = effort;
    if (effort != null && effortScale == 'rir') {
      rpeValue = (10 - effort).clamp(6, 10);
    }

    // Mark all remaining sets as completed
    // actualReps from Watch picker applies to the last remaining mini-set
    final incompleteSets = currentRestPause.restPauseSets
        .where((s) => !s.isCompleted)
        .toList();
    final isLastSet = incompleteSets.length == 1;
    final updatedSets = currentRestPause.restPauseSets.map((set) {
      if (!set.isCompleted) {
        return set.copyWith(
          // Use actual reps from Watch picker for the last set, else target reps
          actualReps: (isLastSet && actualReps != null) ? actualReps : set.reps,
          rpe: rpeValue,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return set;
    }).toList();

    // Create updated exercise using copyWith to preserve all fields
    final updatedExercise = currentRestPause.copyWith(
      restPauseSets: updatedSets,
    );

    // Update workout state
    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;
    state = workout.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );

    debugPrint('⌚🔥 [FLUTTER] ✅ Entire rest-pause completed');

    // Auto-save
    _autoSaveIfNeeded();

    // Update Watch with new state
    _notifyWatchWorkoutUpdate();

    // Sync Live Activity (iOS)
    _updateLiveActivityIfActive();

    // Start inter-exercise timer if there's a next exercise
    debugPrint(
      '⌚🔥 [FLUTTER] 🏁 Rest-Pause completed! Checking for next exercise...',
    );

    final autoRestTimerEnabled = _isAutoRestTimerEnabled();
    final nextExercise = _getNextIncompleteExercise(state!, currentRestPause);
    if (!autoRestTimerEnabled) {
      debugPrint(
        '⌚🔥 [FLUTTER] ⏸️ Auto rest timer disabled - skipping inter-exercise timer after rest-pause',
      );
    } else if (nextExercise != null) {
      final interExerciseRest = _resolveInterExerciseRest(currentRestPause);
      final nextExerciseTotalSets = _getExerciseTotalSets(nextExercise);

      debugPrint(
        '⏰ [TIMER] 🏋️ Starting INTER-EXERCISE timer after rest-pause: ${interExerciseRest}s before ${nextExercise.name}',
      );

      ref
          .read(unifiedTimerProvider.notifier)
          .startTimer(
            durationSeconds: interExerciseRest,
            type: TimerType.interExercise,
            exerciseName: nextExercise.name,
            currentSet: 1,
            totalSets: nextExerciseTotalSets,
            exerciseId: nextExercise.id,
          );

      // iOS: Transition Live Activity
      if (Platform.isIOS) {
        ref
            .read(workoutSessionLAProvider.notifier)
            .transitionToRest(
              restDurationSeconds: interExerciseRest,
              nextExercise: nextExercise,
              nextSetIndex: 1,
            );
      }
    } else {
      debugPrint(
        '⌚🔥 [FLUTTER] 🏁 Last exercise completed - workout finished!',
      );
    }
  }
}
