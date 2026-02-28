part of '../workout_provider.dart';

mixin WorkoutWatchTypeMixin on Notifier<Workout?>, WorkoutWatchNotifyMixin {
  /// Handle superset-specific Watch update
  void _handleSupersetWatchUpdate({
    required SupersetExercise superset,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    // Find current round (first incomplete)
    final currentRoundIndex = superset.supersetSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentRoundIndex < 0) return;

    final currentRound = superset.supersetSets[currentRoundIndex];
    final totalRounds = superset.supersetSets.length;

    // Find current exercise within the round (first without actualReps)
    int currentExerciseIndex = 0;
    String currentExerciseName = superset.exercises.isNotEmpty
        ? superset.exercises.first.name
        : superset.name;
    String? currentExerciseId;
    double? targetWeight;
    int? targetReps;

    for (int i = 0; i < superset.exercises.length; i++) {
      final ex = superset.exercises[i];
      final data = currentRound.exerciseData[ex.id];
      if (data != null && data.actualReps == null) {
        // This exercise hasn't been completed yet in this round
        currentExerciseIndex = i;
        currentExerciseName = ex.name;
        currentExerciseId = ex.id;
        targetWeight = data.targetWeight;
        targetReps = data.targetReps;
        break;
      }
    }

    // Build exercise names list for Watch display
    final supersetExerciseNames = superset.exercises
        .map((e) => e.name)
        .toList();

    // Rounds completed in this superset
    final roundsCompletedInSuperset = superset.supersetSets
        .where((s) => s.isCompleted)
        .length;

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 SUPERSET Watch Update:');
    debugPrint('   - Superset: ${superset.name}');
    debugPrint('   - Exercises: ${supersetExerciseNames.join(", ")}');
    debugPrint(
      '   - Current Exercise: $currentExerciseName (${currentExerciseIndex + 1}/${superset.exercises.length})',
    );
    debugPrint('   - Round: ${currentRoundIndex + 1}/$totalRounds');

    // Send update with superset info
    _getFormCuesAndNotifyWatch(
      exerciseName: currentExerciseName, // Current sub-exercise name
      exerciseId: currentExerciseId,
      currentSet: currentRoundIndex + 1, // Use round as "set" for Watch display
      totalSets: totalRounds,
      targetWeight: targetWeight,
      targetReps: targetReps,
      setsCompleted: completedSets,
      setsCompletedInExercise: roundsCompletedInSuperset,
      lastCompletedReps: null, // Could calculate if needed
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: superset.tut ?? '2-0-1-0', // Superset default TUT
      isStartup: false,
      allSets: [], // Superset doesn't use allSets navigation
      // SUPERSET SUPPORT
      isSuperset: true,
      supersetName: superset.name,
      supersetExercises: supersetExerciseNames,
      currentExerciseInSuperset:
          currentExerciseIndex + 1, // 1-indexed for display
      totalExercisesInSuperset: superset.exercises.length,
      supersetRound: currentRoundIndex + 1, // 1-indexed for display
      totalSupersetRounds: totalRounds,
    );
  }

  /// Handle superset-specific Watch startup notification
  void _handleSupersetWatchStartup({
    required SupersetExercise superset,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    if (superset.supersetSets.isEmpty) {
      debugPrint(
        '⌚ [FLUTTER DEBUG] ⚠️ Superset has no rounds, skipping Watch notification',
      );
      return;
    }

    // Use first round for startup
    final firstRound = superset.supersetSets.first;
    final totalRounds = superset.supersetSets.length;

    // Use first exercise for initial display
    final firstExerciseName = superset.exercises.isNotEmpty
        ? superset.exercises.first.name
        : superset.name;
    final firstExerciseId = superset.exercises.isNotEmpty
        ? superset.exercises.first.id
        : null;

    // Get target from first exercise in first round
    double? targetWeight;
    int? targetReps;
    if (superset.exercises.isNotEmpty) {
      final firstEx = superset.exercises.first;
      final data = firstRound.exerciseData[firstEx.id];
      if (data != null) {
        targetWeight = data.targetWeight;
        targetReps = data.targetReps;
      }
    }

    // Build exercise names list for Watch display
    final supersetExerciseNames = superset.exercises
        .map((e) => e.name)
        .toList();

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 SUPERSET Watch Startup:');
    debugPrint('   - Superset: ${superset.name}');
    debugPrint('   - Exercises: ${supersetExerciseNames.join(", ")}');
    debugPrint('   - First Exercise: $firstExerciseName');
    debugPrint('   - Total Rounds: $totalRounds');

    // Send startup notification with superset info
    _getFormCuesAndNotifyWatch(
      exerciseName: firstExerciseName, // First sub-exercise name
      exerciseId: firstExerciseId,
      currentSet: 1, // First round
      totalSets: totalRounds,
      targetWeight: targetWeight,
      targetReps: targetReps,
      setsCompleted: 0,
      setsCompletedInExercise: 0,
      lastCompletedReps: null,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: superset.tut ?? '2-0-1-0', // Superset default TUT
      isStartup: true, // This is startup, not update
      allSets: [], // Superset doesn't use allSets navigation
      // SUPERSET SUPPORT
      isSuperset: true,
      supersetName: superset.name,
      supersetExercises: supersetExerciseNames,
      currentExerciseInSuperset: 1, // Start at first exercise
      totalExercisesInSuperset: superset.exercises.length,
      supersetRound: 1, // Start at first round
      totalSupersetRounds: totalRounds,
    );
  }

  /// Handle dropset-specific Watch update
  void _handleDropSetWatchUpdate({
    required DropSetExercise dropset,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    // Find current stage (first incomplete)
    final currentStageIndex = dropset.stages.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentStageIndex < 0) return;

    final currentStage = dropset.stages[currentStageIndex];
    final totalStages = dropset.stages.length;

    // Stages completed in this dropset
    final stagesCompletedInDropset = dropset.stages
        .where((s) => s.isCompleted)
        .length;

    // Build stages data for Watch
    final dropsetStagesData = dropset.stages.asMap().entries.map((entry) {
      final stage = entry.value;
      return {
        'weight': stage.weight,
        'reps': stage.reps,
        'actualReps': stage.actualReps,
        'isCompleted': stage.isCompleted,
      };
    }).toList();

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 DROPSET Watch Update:');
    debugPrint('   - Dropset: ${dropset.name}');
    debugPrint('   - Current Stage: ${currentStageIndex + 1}/$totalStages');
    debugPrint('   - Stage Weight: ${currentStage.weight}kg × ${currentStage.reps} reps');

    // Send update with dropset info
    _getFormCuesAndNotifyWatch(
      exerciseName: dropset.name,
      exerciseId: dropset.id,
      currentSet: currentStageIndex + 1, // Use stage as "set" for Watch display
      totalSets: totalStages,
      targetWeight: currentStage.weight,
      targetReps: currentStage.reps,
      setsCompleted: completedSets,
      setsCompletedInExercise: stagesCompletedInDropset,
      lastCompletedReps: currentStageIndex > 0
          ? dropset.stages[currentStageIndex - 1].actualReps
          : null,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: dropset.tut ?? '2-1-2-0', // Dropset default TUT
      isStartup: false,
      allSets: [], // Dropset uses stages, not allSets
      restTime: dropset.restTime,
      // DROPSET SUPPORT
      isDropset: true,
      dropsetStages: dropsetStagesData,
      currentDropsetStage: currentStageIndex + 1, // 1-indexed for display
      totalDropsetStages: totalStages,
    );
  }

  /// Handle rest-pause-specific Watch update
  void _handleRestPauseWatchUpdate({
    required RestPauseExercise restPause,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  }) {
    // Find current mini-set (first incomplete)
    final currentSetIndex = restPause.restPauseSets.indexWhere(
      (s) => !s.isCompleted,
    );
    if (currentSetIndex < 0) return;

    final currentSet = restPause.restPauseSets[currentSetIndex];
    final totalSets = restPause.restPauseSets.length;

    // Sets completed in this rest-pause
    final setsCompletedInRestPause = restPause.restPauseSets
        .where((s) => s.isCompleted)
        .length;

    // Build sets data for Watch
    final restPauseSetsData = restPause.restPauseSets.asMap().entries.map((entry) {
      final set = entry.value;
      return {
        'reps': set.reps,
        'actualReps': set.actualReps,
        'restSeconds': set.restSeconds,
        'isCompleted': set.isCompleted,
      };
    }).toList();

    debugPrint('⌚ [FLUTTER DEBUG] 🔥 REST-PAUSE Watch Update:');
    debugPrint('   - Rest-Pause: ${restPause.name}');
    debugPrint('   - Current Set: ${currentSetIndex + 1}/$totalSets');
    debugPrint('   - Weight: ${restPause.weight}kg, Target Reps: ${restPause.targetReps}');

    // Send update with rest-pause info
    _getFormCuesAndNotifyWatch(
      exerciseName: restPause.name,
      exerciseId: restPause.id,
      currentSet: currentSetIndex + 1, // Use mini-set as "set" for Watch display
      totalSets: totalSets,
      targetWeight: restPause.weight,
      targetReps: currentSet.reps,
      setsCompleted: completedSets,
      setsCompletedInExercise: setsCompletedInRestPause,
      lastCompletedReps: currentSetIndex > 0
          ? restPause.restPauseSets[currentSetIndex - 1].actualReps
          : null,
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: restPause.tut ?? '2-1-2-1', // Rest-pause default TUT
      isStartup: false,
      allSets: [], // Rest-pause uses restPauseSets, not allSets
      restTime: restPause.restTime,
      // REST-PAUSE SUPPORT
      isRestPause: true,
      restPauseWeight: restPause.weight,
      restPauseTargetReps: restPause.targetReps,
      restPauseSets: restPauseSetsData,
      currentRestPauseSet: currentSetIndex + 1, // 1-indexed for display
      totalRestPauseSets: totalSets,
    );
  }

  /// Update Live Activity if active (iOS only).
  /// Called when workout structure changes (exercises/sets added/removed).
  void _updateLiveActivityIfActive() {
    if (!Platform.isIOS) return;
    if (state == null) return;

    final laState = ref.read(workoutSessionLAProvider);
    if (!laState.isActive) return;

    // FIX: Don't call transitionToExercise during RPE or REST mode
    if (laState.mode == WorkoutSessionMode.rpe ||
        laState.mode == WorkoutSessionMode.rest) {
      debugPrint(
        '[WorkoutProvider] 📱 Skipping LA update - mode is ${laState.mode} (will transition after)',
      );
      return;
    }

    final workout = state!;

    // Find current exercise (first with incomplete sets)
    final currentExercise = workout.exercises.cast<Exercise?>().firstWhere(
      (e) => e != null && e.sets.any((s) => !s.isCompleted),
      orElse: () => null,
    );

    if (currentExercise != null) {
      final completedExercises = workout.exercises
          .where((e) => e.sets.every((s) => s.isCompleted))
          .length;

      ref
          .read(workoutSessionLAProvider.notifier)
          .updateExercise(
            currentExercise,
            completedExercises,
            workout.exercises.length,
          );
    }
  }
}
