part of '../workout_provider.dart';

mixin WorkoutWatchNotifyMixin on Notifier<Workout?> {
  int _latestWatchSyncToken = 0;

  // ─── Abstract requirements ───────────────────────────────────────────────
  // These are implemented by other mixins or the main class.
  // Declaring them here avoids circular `on` constraints while still
  // allowing WorkoutWatchNotifyMixin to call them on `this`.

  /// Implemented in CurrentWorkoutNotifier (main class) — registers all
  /// Apple Watch callbacks without introducing circular mixin dependencies.
  void _setupWatchCallbacks();

  /// Implemented in WorkoutWatchTypeMixin.
  void _handleSupersetWatchStartup({
    required SupersetExercise superset,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  });

  /// Implemented in WorkoutWatchTypeMixin.
  void _handleSupersetWatchUpdate({
    required SupersetExercise superset,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  });

  /// Implemented in WorkoutWatchTypeMixin.
  void _handleDropSetWatchUpdate({
    required DropSetExercise dropset,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  });

  /// Implemented in WorkoutWatchTypeMixin.
  void _handleRestPauseWatchUpdate({
    required RestPauseExercise restPause,
    required int completedSets,
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
  });

  // ─────────────────────────────────────────────────────────────────────────

  /// ⌚ Notify Apple Watch that workout has started
  void _notifyWatchWorkoutStarted() {
    debugPrint('⌚ [FLUTTER DEBUG] _notifyWatchWorkoutStarted called');

    if (state == null) {
      debugPrint('⌚ [FLUTTER DEBUG] ❌ state is null, returning');
      return;
    }

    final workout = state!;
    final firstExercise = workout.exercises.isNotEmpty
        ? workout.exercises.first
        : null;

    debugPrint('⌚ [FLUTTER DEBUG] Workout: ${workout.name}');
    debugPrint(
      '⌚ [FLUTTER DEBUG] First exercise: ${firstExercise?.name ?? "none"}',
    );
    debugPrint('⌚ [FLUTTER DEBUG] Exercise count: ${workout.exercises.length}');

    // ⌚ Setup callbacks for Watch → iPhone communication
    // Callback registration is done in _setupWatchCallbacks() which is
    // implemented in the main CurrentWorkoutNotifier class, where all
    // mixin methods are available without circular on-constraints.
    _setupWatchCallbacks();
    debugPrint('⌚ [FLUTTER DEBUG] ✅ Watch callbacks registered');

    // Get RPE tracking settings from app config
    final appConfig = ref.read(appConfigProvider);
    final rpeTrackingEnabled = appConfig.rpeTracking ?? false;
    final effortScale = appConfig.effortScale;
    // Get locale for Watch UI strings
    final locale = ref.read(localeProvider).languageCode;
    debugPrint(
      '⌚ [FLUTTER DEBUG] RPE Settings: enabled=$rpeTrackingEnabled, scale=$effortScale, locale=$locale',
    );

    if (firstExercise != null) {
      // 🔥 SUPERSET HANDLING at workout start
      if (firstExercise is SupersetExercise) {
        _handleSupersetWatchStartup(
          superset: firstExercise,
          rpeTrackingEnabled: rpeTrackingEnabled,
          effortScale: effortScale,
          locale: locale,
        );
      } else {
        // 📝 Get Form Cues for the exercise (async, fire and forget)
        // ⌚ Use actual TUT or generate default (same logic as UI)
        final effectiveTut = firstExercise.tut ?? _getDefaultTut(firstExercise);

        // ✅ FIX: Build allSets list for Watch navigation (include actualReps for edit mode)
        final allSets = firstExercise.sets
            .map(
              (s) => {
                'weight': s.weight?.toDouble() ?? 0.0,
                'reps': s.reps ?? 0,
                'seconds': s.seconds ?? 0,
                'actualReps':
                    s.actualReps, // ✅ Reps effettive (null se non completato)
                'isCompleted': s.isCompleted, // ✅ Stato completamento
                'isWarmup': s.isWarmup, // ⌚ Warmup flag (mancava in startup)
                'minReps': s.minReps, // ⌚ Rep range support
                'maxReps': s.maxReps, // ⌚ Rep range support
              },
            )
            .toList();

        // Usa il primo set non completato (non necessariamente il primo in assoluto)
        // per evitare di inviare dati 0x0 se il primo set è già completato o è warmup
        final firstSet =
            firstExercise.sets.where((s) => !s.isCompleted).firstOrNull ??
            (firstExercise.sets.isNotEmpty ? firstExercise.sets.first : null);

        _getFormCuesAndNotifyWatch(
          workoutId: workout.id,
          exerciseName: firstExercise.name,
          exerciseId: firstExercise.id,
          currentSet: 1,
          totalSets: firstExercise.sets.length,
          countingMode: firstExercise.countingMode.name,
          targetWeight: firstSet?.weight,
          targetReps: firstSet?.reps ?? firstSet?.minReps,
          targetSeconds: firstSet?.seconds,
          minReps: firstSet?.minReps, // ⌚ Rep range support
          maxReps: firstSet?.maxReps, // ⌚ Rep range support
          setsCompleted: 0,
          rpeTrackingEnabled: rpeTrackingEnabled,
          effortScale: effortScale,
          locale: locale,
          tut: effectiveTut, // ⌚ TUT with fallback to default
          isStartup: true,
          allSets: allSets, // ✅ FIX: All sets for Watch navigation
        );
      }
    } else {
      debugPrint('⌚ [FLUTTER DEBUG] No first exercise, using workout name');
      final watchNotifier = ref.read(watchConnectivityProvider.notifier);
      watchNotifier.notifyWorkoutStarted(
        workoutId: workout.id,
        exerciseName: workout.name,
        currentSet: 1,
        totalSets: 1,
        setsCompleted: 0,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
    }
  }

  /// ⌚ Get default TUT based on exercise type (same logic as UI)
  String _getDefaultTut(Exercise exercise) {
    switch (exercise.type) {
      case ExerciseType.single:
        return exercise.category == ExerciseCategory.legs
            ? '3-0-1-0'
            : '2-1-2-0';
      case ExerciseType.superset:
        return '2-0-1-0';
      case ExerciseType.dropset:
        return '2-1-2-0';
      case ExerciseType.restPause:
        return '2-1-2-1';
    }
  }

  /// Helper to get Form Cues and notify Watch
  Future<void> _getFormCuesAndNotifyWatch({
    required String workoutId,
    required String exerciseName,
    String? exerciseId,
    required int currentSet,
    required int totalSets,
    String countingMode = 'weighted',
    double? targetWeight,
    int? targetReps,
    int? targetSeconds,
    int? minReps, // ⌚ Rep range support
    int? maxReps, // ⌚ Rep range support
    required int setsCompleted,
    int?
    setsCompletedInExercise, // ✅ Sets completed in current exercise (for edit UI)
    int? lastCompletedReps, // ✅ Actual reps of last completed set (for edit UI)
    required bool rpeTrackingEnabled,
    required String effortScale,
    required String locale,
    String? tut, // ⌚ BUG FIX #3: Time Under Tension (e.g., "3-1-2-0")
    bool isStartup = false,
    List<Map<String, dynamic>>? allSets, // ✅ FIX: All sets for Watch navigation
    // 🔄 Exercise navigation support
    List<String>? exerciseNames, // All exercise names in workout
    int currentExerciseIndex = 0, // 0-indexed current exercise position
    // ✅ FIX: Rest time for Watch optimistic timer
    int? restTime, // Rest time in seconds for current exercise
    // 🔥 SUPERSET SUPPORT
    bool isSuperset = false,
    String? supersetName,
    List<String>? supersetExercises,
    int currentExerciseInSuperset = 0,
    int totalExercisesInSuperset = 0,
    int supersetRound = 0,
    int totalSupersetRounds = 0,
    // 🔥 DROPSET SUPPORT
    bool isDropset = false,
    List<Map<String, dynamic>>? dropsetStages,
    int currentDropsetStage = 0,
    int totalDropsetStages = 0,
    // 🔥 REST-PAUSE SUPPORT
    bool isRestPause = false,
    double? restPauseWeight,
    int? restPauseTargetReps,
    List<Map<String, dynamic>>? restPauseSets,
    int currentRestPauseSet = 0,
    int totalRestPauseSets = 0,
  }) async {
    final requestToken = ++_latestWatchSyncToken;
    final watchNotifier = ref.read(watchConnectivityProvider.notifier);
    final prefsRepo = ref.read(userExercisePreferencesRepositoryProvider);

    // Fetch Form Cues asynchronously
    String? formCues;
    try {
      formCues = await prefsRepo.getFormCues(exerciseId, exerciseName);
    } catch (e) {
      debugPrint('⌚ [FLUTTER DEBUG] ⚠️ Failed to fetch Form Cues: $e');
    }

    // 📚 Look up real TUT and noteTecniche from exercise database
    String? effectiveTut = tut;
    String? effectiveFormCues = formCues;
    try {
      final exercises = await ref.read(allExercisesProvider.future);
      // Find by name (case-insensitive)
      final normalizedName = exerciseName.toLowerCase().trim();
      final dbExercise = exercises.cast<dynamic>().firstWhere(
        (e) => (e.nome as String?)?.toLowerCase().trim() == normalizedName,
        orElse: () => null,
      );
      if (dbExercise != null) {
        // 📚 TUT from database (tempoEsecuzione)
        if (dbExercise.tempoEsecuzione != null) {
          effectiveTut = dbExercise.tempoEsecuzione as String;
          debugPrint(
            '⌚ [FLUTTER DEBUG] 📚 Found real TUT from database: $effectiveTut',
          );
        } else {
          // 📚 Smart fallback based on exercise type and movement pattern
          effectiveTut =
              _inferTutFromExercise(
                tipoEsercizio: dbExercise.tipoEsercizio as String?,
                patternMovimento: dbExercise.patternMovimento as String?,
                defaultTut: tut,
              ) ??
              tut;
          debugPrint(
            '⌚ [FLUTTER DEBUG] 📚 No DB TUT → inferred: $effectiveTut '
            '(tipo: ${dbExercise.tipoEsercizio}, pattern: ${dbExercise.patternMovimento})',
          );
        }
        // 📝 Form Cues fallback from database (noteTecniche)
        if (effectiveFormCues == null && dbExercise.noteTecniche != null) {
          final noteTecniche = dbExercise.noteTecniche as String;
          // Truncate for Watch display (max 500 chars, preserve first steps)
          if (noteTecniche.length > 500) {
            effectiveFormCues = '${noteTecniche.substring(0, 497)}...';
          } else {
            effectiveFormCues = noteTecniche;
          }
          debugPrint(
            '⌚ [FLUTTER DEBUG] 📝 Using noteTecniche as Form Cues fallback',
          );
        }
      } else {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 📚 Exercise not found in database: $exerciseName',
        );
      }
    } catch (e) {
      debugPrint('⌚ [FLUTTER DEBUG] ⚠️ Failed to fetch from database: $e');
    }

    debugPrint(
      '⌚ [FLUTTER DEBUG] Form Cues for $exerciseName: ${effectiveFormCues != null ? "${effectiveFormCues.length} chars (from db: ${effectiveFormCues != formCues})" : "none"}',
    );

    if (requestToken != _latestWatchSyncToken) {
      debugPrint(
        '⌚ [FLUTTER DEBUG] Skipping stale Watch sync for $exerciseName set $currentSet',
      );
      return;
    }

    if (isStartup) {
      debugPrint('⌚ [FLUTTER DEBUG] Calling notifyWorkoutStarted with:');
      debugPrint('   - exerciseName: $exerciseName');
      debugPrint('   - currentSet: $currentSet');
      debugPrint('   - totalSets: $totalSets');
      debugPrint(
        '   - formCues: ${effectiveFormCues != null ? "${effectiveFormCues.length} chars" : "none"}',
      );
      debugPrint(
        '   - tut: ${effectiveTut ?? "none"} (from db: ${effectiveTut != tut})',
      );
      debugPrint('   - allSets: ${allSets?.length ?? 0} sets');
      if (isSuperset) {
        debugPrint(
          '   - 🔥 SUPERSET: $supersetName, Ex $currentExerciseInSuperset/$totalExercisesInSuperset, Round $supersetRound/$totalSupersetRounds',
        );
      }
      unawaited(
        watchNotifier.notifyWorkoutStarted(
          workoutId: workoutId,
          exerciseName: exerciseName,
          currentSet: currentSet,
          totalSets: totalSets,
          countingMode: countingMode,
          targetWeight: targetWeight,
          targetReps: targetReps,
          targetSeconds: targetSeconds,
          minReps: minReps, // ⌚ Rep range support
          maxReps: maxReps, // ⌚ Rep range support
          setsCompleted: setsCompleted,
          setsCompletedInExercise: setsCompletedInExercise ?? 0, // ✅ NEW
          lastCompletedReps: lastCompletedReps, // ✅ NEW
          rpeTrackingEnabled: rpeTrackingEnabled,
          effortScale: effortScale,
          locale: locale,
          formCues: effectiveFormCues, // 📝 User saved or noteTecniche fallback
          tut: effectiveTut, // ⌚ Real TUT from database or fallback
          allSets: allSets, // ✅ FIX: All sets for Watch navigation
          // 🔄 Exercise navigation support
          exerciseNames: exerciseNames,
          currentExerciseIndex: currentExerciseIndex,
          // 🔥 SUPERSET SUPPORT
          isSuperset: isSuperset,
          supersetName: supersetName,
          supersetExercises: supersetExercises,
          currentExerciseInSuperset: currentExerciseInSuperset,
          totalExercisesInSuperset: totalExercisesInSuperset,
          supersetRound: supersetRound,
          totalSupersetRounds: totalSupersetRounds,
          // 🔥 DROPSET SUPPORT
          isDropset: isDropset,
          dropsetStages: dropsetStages,
          currentDropsetStage: currentDropsetStage,
          totalDropsetStages: totalDropsetStages,
          // 🔥 REST-PAUSE SUPPORT
          isRestPause: isRestPause,
          restPauseWeight: restPauseWeight,
          restPauseTargetReps: restPauseTargetReps,
          restPauseSets: restPauseSets,
          currentRestPauseSet: currentRestPauseSet,
          totalRestPauseSets: totalRestPauseSets,
        ),
      );
      debugPrint(
        '⌚ [FLUTTER DEBUG] ✅ notifyWorkoutStarted called successfully',
      );
    } else {
      if (isSuperset) {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 🔥 SUPERSET Update: $supersetName, Ex $currentExerciseInSuperset/$totalExercisesInSuperset, Round $supersetRound/$totalSupersetRounds',
        );
      } else if (isDropset) {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 🔥 DROPSET Update: $exerciseName, Stage $currentDropsetStage/$totalDropsetStages',
        );
      } else if (isRestPause) {
        debugPrint(
          '⌚ [FLUTTER DEBUG] 🔥 REST-PAUSE Update: $exerciseName, Set $currentRestPauseSet/$totalRestPauseSets',
        );
      }
      unawaited(
        watchNotifier.sendWorkoutUpdate(
          workoutId: workoutId,
          exerciseName: exerciseName,
          currentSet: currentSet,
          totalSets: totalSets,
          countingMode: countingMode,
          targetWeight: targetWeight,
          targetReps: targetReps,
          targetSeconds: targetSeconds,
          minReps: minReps, // ⌚ Rep range support
          maxReps: maxReps, // ⌚ Rep range support
          setsCompleted: setsCompleted,
          setsCompletedInExercise: setsCompletedInExercise ?? 0, // ✅ NEW
          lastCompletedReps: lastCompletedReps, // ✅ NEW
          rpeTrackingEnabled: rpeTrackingEnabled,
          effortScale: effortScale,
          locale: locale,
          formCues: effectiveFormCues, // 📝 User saved or noteTecniche fallback
          tut: effectiveTut, // ⌚ Real TUT from database or fallback
          allSets: allSets, // ✅ FIX: All sets for Watch navigation
          // 🔄 Exercise navigation support
          exerciseNames: exerciseNames,
          currentExerciseIndex: currentExerciseIndex,
          // ✅ FIX: Rest time for Watch optimistic timer
          restTime: restTime,
          // 🔥 SUPERSET SUPPORT
          isSuperset: isSuperset,
          supersetName: supersetName,
          supersetExercises: supersetExercises,
          currentExerciseInSuperset: currentExerciseInSuperset,
          totalExercisesInSuperset: totalExercisesInSuperset,
          supersetRound: supersetRound,
          totalSupersetRounds: totalSupersetRounds,
          // 🔥 DROPSET SUPPORT
          isDropset: isDropset,
          dropsetStages: dropsetStages,
          currentDropsetStage: currentDropsetStage,
          totalDropsetStages: totalDropsetStages,
          // 🔥 REST-PAUSE SUPPORT
          isRestPause: isRestPause,
          restPauseWeight: restPauseWeight,
          restPauseTargetReps: restPauseTargetReps,
          restPauseSets: restPauseSets,
          currentRestPauseSet: currentRestPauseSet,
          totalRestPauseSets: totalRestPauseSets,
        ),
      );
    }
  }

  /// ⌚ Notify Apple Watch about workout update (exercise/set change)
  void _notifyWatchWorkoutUpdate() {
    if (state == null) return;

    final workout = state!;

    // Get RPE tracking settings from app config
    final appConfig = ref.read(appConfigProvider);
    final rpeTrackingEnabled = appConfig.rpeTracking ?? false;
    final effortScale = appConfig.effortScale;
    // Get locale for Watch UI strings
    final locale = ref.read(localeProvider).languageCode;

    // 🔥 Find current exercise - handle all exercise types (regular, superset, dropset, rest-pause)
    Exercise? currentExercise;
    for (final exercise in workout.exercises) {
      if (exercise is SupersetExercise) {
        // For superset: check if any round is incomplete
        if (exercise.supersetSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else if (exercise is DropSetExercise) {
        // 🔥 FIX: For dropset: check if any STAGE is incomplete (not sets!)
        if (exercise.stages.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else if (exercise is RestPauseExercise) {
        // 🔥 FIX: For rest-pause: check if any REST-PAUSE SET is incomplete
        if (exercise.restPauseSets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      } else {
        // For regular exercise: check if any set is incomplete
        if (exercise.sets.any((s) => !s.isCompleted)) {
          currentExercise = exercise;
          break;
        }
      }
    }

    // Calculate total completed sets (including superset rounds, dropset stages, rest-pause sets)
    final completedSets = workout.exercises.fold<int>(0, (total, e) {
      if (e is SupersetExercise) {
        return total + e.supersetSets.where((s) => s.isCompleted).length;
      } else if (e is DropSetExercise) {
        // 🔥 FIX: Count completed STAGES for dropset
        return total + e.stages.where((s) => s.isCompleted).length;
      } else if (e is RestPauseExercise) {
        // 🔥 FIX: Count completed REST-PAUSE SETS
        return total + e.restPauseSets.where((s) => s.isCompleted).length;
      }
      return total + e.sets.where((s) => s.isCompleted).length;
    });

    if (currentExercise == null) return;

    // 🔥 SUPERSET HANDLING
    if (currentExercise is SupersetExercise) {
      _handleSupersetWatchUpdate(
        superset: currentExercise,
        completedSets: completedSets,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
      return;
    }

    // 🔥 DROPSET HANDLING
    if (currentExercise is DropSetExercise) {
      _handleDropSetWatchUpdate(
        dropset: currentExercise,
        completedSets: completedSets,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
      return;
    }

    // 🔥 REST-PAUSE HANDLING
    if (currentExercise is RestPauseExercise) {
      _handleRestPauseWatchUpdate(
        restPause: currentExercise,
        completedSets: completedSets,
        rpeTrackingEnabled: rpeTrackingEnabled,
        effortScale: effortScale,
        locale: locale,
      );
      return;
    }

    // Regular exercise handling
    final currentSetIndex = currentExercise.sets.indexWhere(
      (s) => !s.isCompleted,
    );
    final currentSet = currentSetIndex >= 0
        ? currentExercise.sets[currentSetIndex]
        : null;
    // ⌚ Use actual TUT or generate default (same logic as UI)
    final effectiveTut = currentExercise.tut ?? _getDefaultTut(currentExercise);

    // ✅ FIX: Calculate sets completed IN CURRENT EXERCISE (not total workout)
    final setsCompletedInExercise = currentExercise.sets
        .where((s) => s.isCompleted)
        .length;

    // ✅ FIX: Get actualReps of last completed set in current exercise
    int? lastCompletedReps;
    for (int i = currentExercise.sets.length - 1; i >= 0; i--) {
      if (currentExercise.sets[i].isCompleted) {
        lastCompletedReps =
            currentExercise.sets[i].actualReps ?? currentExercise.sets[i].reps;
        break;
      }
    }

    // ✅ FIX: Build allSets list for Watch navigation (include actualReps for edit mode)
    final allSets = currentExercise.sets
        .map(
          (s) => {
            'weight': s.weight?.toDouble() ?? 0.0,
            'reps': s.reps ?? 0,
            'seconds': s.seconds ?? 0,
            'actualReps':
                s.actualReps, // ✅ Reps effettive (null se non completato)
            'isCompleted': s.isCompleted, // ✅ Stato completamento
            'isWarmup': s.isWarmup, // ✅ Warmup flag per Watch
            'minReps': s.minReps, // ⌚ Rep range support
            'maxReps': s.maxReps, // ⌚ Rep range support
          },
        )
        .toList();

    // 🔄 Build exercise names list and find current index for Watch navigation
    final exerciseNames = workout.exercises.map((e) => e.name).toList();
    final currentExerciseIdx = workout.exercises.indexWhere(
      (e) => e.id == currentExercise!.id,
    );

    // 📝 Use async helper to fetch Form Cues and send update
    _getFormCuesAndNotifyWatch(
      workoutId: workout.id,
      exerciseName: currentExercise.name,
      exerciseId: currentExercise.id,
      currentSet: currentSetIndex >= 0
          ? currentSetIndex + 1
          : currentExercise.sets.length,
      totalSets: currentExercise.sets.length,
      countingMode: currentExercise.countingMode.name,
      targetWeight: currentSet?.weight,
      targetReps:
          currentSet?.reps ??
          currentSet?.minReps, // ⌚ Fallback to minReps for rep range
      targetSeconds: currentSet?.seconds,
      minReps: currentSet?.minReps, // ⌚ Rep range support
      maxReps: currentSet?.maxReps, // ⌚ Rep range support
      setsCompleted: completedSets,
      setsCompletedInExercise: setsCompletedInExercise, // ✅ NEW
      lastCompletedReps: lastCompletedReps, // ✅ NEW
      rpeTrackingEnabled: rpeTrackingEnabled,
      effortScale: effortScale,
      locale: locale,
      tut: effectiveTut, // ⌚ TUT with fallback to default
      isStartup: false,
      allSets: allSets, // ✅ FIX: All sets for Watch navigation
      // 🔄 Exercise navigation support
      exerciseNames: exerciseNames,
      currentExerciseIndex: currentExerciseIdx >= 0 ? currentExerciseIdx : 0,
      // ✅ FIX: Rest time for Watch optimistic timer
      restTime: currentExercise.restTime,
    );
  }
}
