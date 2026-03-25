part of '../workout_provider.dart';

mixin WorkoutLifecycleMixin
    on
        Notifier<Workout?>,
        WorkoutCoreMixin,
        WorkoutHelpersMixin,
        WorkoutWatchNotifyMixin,
        WorkoutSaveMixin {
  bool _isCurrentWorkoutGuidedTest() {
    final workout = state;
    if (workout == null) return false;
    return _isGuidedTestWorkout(workout);
  }

  bool _isGuidedTestWorkout(Workout workout) {
    final choiceService = ref.read(onboardingChoiceServiceProvider);
    if (choiceService == null) return false;
    return choiceService.isGuidedActiveTestWorkout(workout.id);
  }

  /// Creates workout from routine with pre-loaded exercises
  Future<void> createWorkoutFromRoutine({
    required String routineName,
    required List<Exercise> exercises,
    required String sessionId,
    String? templateId, // Accept templateId for auto-save
  }) async {
    // Store template ID for auto-save functionality
    _currentTemplateId = templateId;

    final workout = Workout(
      id: const Uuid().v4(),
      name: routineName,
      exercises: exercises,
      status: WorkoutStatus.planned,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPreloaded: true, // Flag to identify pre-loaded state
      preloadExpiry: DateTime.now().add(
        const Duration(minutes: 15),
      ), // 15-min timeout
      sessionId: sessionId, // Analytics tracking
      templateId: templateId, // Link workout to template
    );

    state = workout;
    _autoSaveIfNeeded();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_timerPaused) return; // Skip if paused

      final workout = state;
      if (workout?.isPreloaded == true && workout!.isExpired) {
        state = null; // Cleanup expired workout
        if (kDebugMode) debugPrint('🧹 Preloaded workout expired and removed');
      }
    });
  }

  void pauseCleanupTimer() {
    _timerPaused = true;
    if (kDebugMode) debugPrint('⏸️ Cleanup timer paused');
  }

  void resumeCleanupTimer() {
    _timerPaused = false;
    if (kDebugMode) debugPrint('▶️ Cleanup timer resumed');
  }

  Future<void> replaceExercisesFromTemplate(wt.WorkoutTemplate template) async {
    final workout = state;
    if (workout == null) return;

    // Use toWorkoutExercise() to properly handle superset/dropset types
    final exercises = template.exercises.map((templateExercise) {
      return templateExercise.toWorkoutExercise();
    }).toList();

    state = workout.copyWith(
      name: template.name,
      exercises: exercises,
      isPreloaded: false, // No longer pre-loaded
      exercisesModified: true, // Track modification
    );

    _autoSaveIfNeeded();
  }

  void createWorkout(String name, {String? templateId}) {
    state = Workout(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      templateId: templateId, // Pass templateId for duration tracking
    );
    _currentTemplateId =
        templateId; // Set template ID for auto-save (null for manual workouts)
  }

  Future<void> startFromTemplate(
    wt.WorkoutTemplate workoutTemplate, {
    String? sessionId,
  }) async {
    try {
      // Store template ID for auto-save
      _currentTemplateId = workoutTemplate.id;

      // Check if there's a cached version of this template
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      final cachedWorkout = await cacheService.getCachedWorkout(
        workoutTemplate.id,
      );

      Workout workout;

      if (cachedWorkout != null) {
        // Use cached version with modifications
        if (kDebugMode) {
          debugLog(
            LogCategory.workout,
            '💾 [WorkoutProvider] Loading cached workout for template: ${workoutTemplate.name}',
          );
        }
        workout = cachedWorkout;
      } else {
        // Create a new workout from the template
        // Use toWorkoutExercise() to properly handle superset/dropset types
        workout = Workout(
          id: const Uuid().v4(),
          name: workoutTemplate.name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          templateId: workoutTemplate
              .id, // CRITICAL FIX: Pass templateId for routine auto-detection
          exercises: workoutTemplate.exercises.map((templateExercise) {
            return templateExercise.toWorkoutExercise();
          }).toList(),
        );

        // LOCALIZATION FIX: Replace hardcoded English names with localized names from database
        final localizedExercises = <Exercise>[];
        for (final exercise in workout.exercises) {
          final localizedExercise = await _localizeExerciseName(exercise);
          localizedExercises.add(localizedExercise);
        }

        workout = workout.copyWith(exercises: localizedExercises);
      }

      workout = workout.copyWith(
        sessionId: sessionId ?? workout.sessionId,
        templateId: workoutTemplate.id,
      );

      // Auto-fill weights from the most recent completed workout for this template.
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        final previousWorkout = await _fetchPreviousTemplateWorkout(
          templateId: workoutTemplate.id,
          userId: userId,
        );
        workout = await ref
            .read(weightAutoFillServiceProvider)
            .fillFromTemplate(
              workout: workout,
              previousWorkout: previousWorkout,
            );
      }

      // Set the workout and start it automatically
      state = workout.startWorkout();

      // FIX: Start auto-save for template workouts (was missing, causing data loss on crash)
      ref.read(workoutAutoSaveProvider.notifier).startAutoSave(state!);

      // Track workout started from template
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      unawaited(
        tracker.trackWorkoutStarted(
          workoutId: workout.id,
          workoutType: 'strength', // Default type
          workoutName: workout.name,
          source: 'template',
          templateId: workoutTemplate.id,
        ),
      );

      // Activate wakelock if enabled in settings
      unawaited(ref.read(screenWakelockProvider.notifier).startWakelock());

      // Notify Apple Watch about workout start
      _notifyWatchWorkoutStarted();

      // Start iOS 17+ Workout Session Live Activity
      if (Platform.isIOS) {
        debugPrint(
          '[WorkoutProvider] 📱 Starting LA for template workout: ${state!.name}',
        );
        unawaited(
          ref.read(workoutSessionLAProvider.notifier).startLiveActivity(state!),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error starting workout from template: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Ensure we don't leave the app in a bad state
      state = null;
      rethrow; // Allow UI to handle the error
    }
  }

  /// Start a new workout session by repeating a workout from history.
  ///
  /// It copies exercise structure and target values, but resets completion
  /// state and timing metadata so the new session starts clean.
  Future<void> startFromHistory(WorkoutHistoryDetail historyWorkout) async {
    try {
      final now = DateTime.now();
      _currentTemplateId = historyWorkout.templateId;

      final exercises = historyWorkout.exercises.map((historyExercise) {
        final baseExercise = historyExercise.toExercise();

        final freshSets = historyExercise.sets.map((historySet) {
          return ExerciseSet(
            setNumber: historySet.setNumber,
            weight: historySet.weight,
            reps: historySet.reps,
            isWarmup: historySet.isWarmup,
            restTime: historySet.restSeconds,
          );
        }).toList();

        return baseExercise.copyWith(sets: freshSets, updatedAt: now);
      }).toList();

      final workout = Workout(
        id: const Uuid().v4(),
        name: historyWorkout.name,
        createdAt: now,
        updatedAt: now,
        exercises: exercises,
        templateId: historyWorkout.templateId,
      ).startWorkout();

      state = workout;

      // Start all runtime side-effects expected for active workouts.
      ref.read(workoutAutoSaveProvider.notifier).startAutoSave(workout);
      unawaited(ref.read(screenWakelockProvider.notifier).startWakelock());
      _notifyWatchWorkoutStarted();

      if (Platform.isIOS) {
        unawaited(
          ref
              .read(workoutSessionLAProvider.notifier)
              .startLiveActivity(workout),
        );
      }

      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);
      unawaited(
        tracker.trackWorkoutStarted(
          workoutId: workout.id,
          workoutType: 'strength',
          workoutName: workout.name,
          source: 'history_repeat',
          templateId: historyWorkout.templateId,
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error starting workout from history: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  Future<void> startWorkout() async {
    if (state != null) {
      final isGuidedTest = _isCurrentWorkoutGuidedTest();
      final templateId = state!.templateId;
      final isTemplateStart = templateId != null && templateId.isNotEmpty;

      if (!isGuidedTest) {
        // Track workout started only for real workouts.
        final analytics = ref.read(analyticsServiceProvider);
        final tracker = WorkoutEventTracker(analytics);
        unawaited(
          tracker.trackWorkoutStarted(
            workoutId: state!.id,
            workoutType: 'strength', // Default type
            workoutName: state!.name,
            templateId: isTemplateStart ? templateId : null,
            source: isTemplateStart ? 'template' : 'manual_start',
          ),
        );
      }

      // Auto-fill weights from history for free workouts (silent)
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (!isGuidedTest && userId != null && state!.templateId == null) {
        state = await ref
            .read(weightAutoFillServiceProvider)
            .fillFromHistory(workout: state!, userId: userId);
      }

      state = state!.startWorkout();

      // BUG FIX: Start auto-save when workout starts
      ref.read(workoutAutoSaveProvider.notifier).startAutoSave(state!);

      // Activate wakelock if enabled in settings
      unawaited(ref.read(screenWakelockProvider.notifier).startWakelock());

      // Notify Apple Watch about workout start
      _notifyWatchWorkoutStarted();

      // Start iOS 17+ Workout Session Live Activity
      if (Platform.isIOS) {
        unawaited(
          ref.read(workoutSessionLAProvider.notifier).startLiveActivity(state!),
        );
      }
    }
  }

  /// Restore workout from draft (after app killed by OS)
  ///
  /// Called when app resumes and finds a saved draft in local storage.
  /// This restores the full workout state including all exercises and sets.
  void restoreFromDraft(Workout workout) {
    if (kDebugMode) {
      debugPrint(
        '🔄 [WorkoutProvider] Restoring workout from draft: ${workout.name}',
      );
      debugPrint('   - Exercises: ${workout.exercises.length}');
      debugPrint('   - Status: ${workout.status}');
    }

    // Restore the workout state
    state = workout;

    // Start auto-save for the restored workout
    if (workout.isActive) {
      ref.read(workoutAutoSaveProvider.notifier).startAutoSave(workout);

      // Re-enable wakelock if workout is active
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // Notify Apple Watch about workout restore
      _notifyWatchWorkoutStarted();

      // Start iOS 17+ Workout Session Live Activity
      if (Platform.isIOS) {
        debugPrint(
          '[WorkoutProvider] 📱 Starting LA for restored workout: ${workout.name}',
        );
        ref.read(workoutSessionLAProvider.notifier).startLiveActivity(workout);
      }
    }

    // Track restoration event
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = WorkoutEventTracker(analytics);
    tracker.trackWorkoutStarted(
      workoutId: workout.id,
      workoutType: 'strength',
      workoutName: workout.name,
      source: 'draft_recovery',
    );
  }

  /// Update workout duration by setting a new endTime
  ///
  /// Use this when the user wants to adjust the recorded workout time,
  /// e.g., when actual time < total rest time.
  ///
  /// [newDuration] is the desired workout duration from startTime.
  void updateWorkoutDuration(Duration newDuration) {
    if (state == null || state!.startTime == null) return;

    final newEndTime = state!.startTime!.add(newDuration);
    state = state!.copyWith(endTime: newEndTime, updatedAt: DateTime.now());

    if (kDebugMode) {
      debugPrint(
        '⏱️ [WorkoutProvider] Duration updated to: ${newDuration.inMinutes}m',
      );
    }
  }

  /// Complete workout with optional UI feedback
  ///
  /// Pass [context] to show sync status toasts during save flow.
  /// If [context] is null, saves silently without UI feedback.
  Future<void> completeWorkout([BuildContext? context]) async {
    if (state != null) {
      if (_isCurrentWorkoutGuidedTest()) {
        await completeGuidedTestWorkout();
        return;
      }

      final workout = state!;

      // Track workout completed with full stats
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      // Calculate stats
      final totalExercises = workout.exercises.length;
      final totalSetsCount = workout.totalSets;
      final completedSets = workout.completedSets;
      final totalWeight = workout.completedVolume;

      unawaited(
        tracker.trackWorkoutCompleted(
          workoutId: workout.id,
          workoutType: 'strength',
          exerciseCount: totalExercises,
          totalSets: totalSetsCount,
          totalWeight: totalWeight,
          duration: workout.duration?.inSeconds ?? 0,
          completionRate: totalSetsCount > 0
              ? ((completedSets / totalSetsCount) * 100).round()
              : 0,
          sessionId: workout.sessionId,
        ),
      );

      // Track exercise usage for "Recent Exercises" in exercise picker
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        final usageTracker = ExerciseUsageTracker();
        for (final exercise in workout.exercises) {
          unawaited(
            usageTracker.incrementUsage(
              exerciseId: exercise.stableExerciseId,
              exerciseName: exercise.name,
              userId: currentUser.uid,
            ),
          );
        }
      }

      state = state!.completeWorkout();

      // Stop rest timer to prevent ticks after workout ends
      await ref.read(unifiedTimerProvider.notifier).stopTimer();

      // Haptic feedback for workout completion
      HapticFeedbackService.workoutCompletion(ref);

      // Keep orchestrator workout count in sync so post-first-workout
      // onboarding prompts (e.g. health integration) can unlock correctly.
      unawaited(
        ref
            .read(onboardingOrchestratorProvider.notifier)
            .incrementWorkoutCount(),
      );

      // Keep contextual tutorial workout count in sync for hint policy.
      unawaited(
        ref.read(tutorialStateProvider.notifier).incrementWorkoutCount(),
      );

      // Guided real mode completion: first real completion after guided test.
      final choiceService = ref.read(onboardingChoiceServiceProvider);
      if (choiceService != null &&
          choiceService.getChoice() == OnboardingChoice.guided &&
          choiceService.isGuidedTestCompleted() &&
          !choiceService.isGuidedRealCompleted()) {
        final analytics = ref.read(analyticsServiceProvider);
        unawaited(choiceService.completeGuidedRealMode());
        ref.invalidate(shouldShowGuidedSoftGateReminderProvider);
        unawaited(
          analytics.logEvent(
            name: AnalyticsEvents.guidedRealCompleted,
            parameters: {AnalyticsParameters.workoutId: workout.id},
          ),
        );
      }

      // Notify Apple Watch that workout ended
      await ref.read(watchConnectivityProvider.notifier).notifyWorkoutEnded();

      // End iOS 17+ Workout Session Live Activity (show completion for 5s)
      if (Platform.isIOS) {
        await ref
            .read(workoutSessionLAProvider.notifier)
            .endLiveActivity(dismissPolicy: 'after_5s');
      }

      // Clear cache after workout completion (start fresh next time)
      if (_currentTemplateId != null) {
        final cacheService = ref.read(workoutTemplateCacheServiceProvider);
        await cacheService.clearCache(_currentTemplateId!);
        _currentTemplateId = null;
      }

      // Stop auto-save timer, but keep the recovery draft until local save succeeds.
      ref
          .read(workoutAutoSaveProvider.notifier)
          .stopAutoSave(clearDraft: false);

      // Automatically save the completed workout to Firestore
      if (context != null && !context.mounted) {
        return;
      }
      await _saveCompletedWorkoutToFirestore(context);

      // Local save succeeded: the recovery draft is no longer needed.
      ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);

      // Deactivate wakelock when workout is completed
      await ref.read(screenWakelockProvider.notifier).stopWakelock();
    }
  }

  /// Complete a guided test workout without persisting any real workout data.
  ///
  /// This path intentionally avoids history/streak/xp/real workout analytics.
  Future<void> completeGuidedTestWorkout() async {
    final workout = state;
    if (workout == null) return;
    if (!_isGuidedTestWorkout(workout)) return;

    // Stop runtime systems tied to the active workout.
    await ref.read(unifiedTimerProvider.notifier).stopTimer();
    ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);
    await ref.read(screenWakelockProvider.notifier).stopWakelock();
    await ref.read(watchConnectivityProvider.notifier).notifyWorkoutEnded();

    if (Platform.isIOS) {
      await ref
          .read(workoutSessionLAProvider.notifier)
          .endLiveActivity(dismissPolicy: 'immediate');
    }

    // Clear template cache if present.
    if (_currentTemplateId != null) {
      final cacheService = ref.read(workoutTemplateCacheServiceProvider);
      await cacheService.clearCache(_currentTemplateId!);
      _currentTemplateId = null;
    }

    // Clear workout state immediately.
    state = null;

    final analytics = ref.read(analyticsServiceProvider);
    unawaited(
      analytics.logEvent(
        name: AnalyticsEvents.guidedTestCompleted,
        parameters: {AnalyticsParameters.workoutId: workout.id},
      ),
    );

    final choiceService = ref.read(onboardingChoiceServiceProvider);
    await choiceService?.completeGuidedTestMode();
    ref.invalidate(shouldShowGuidedSoftGateReminderProvider);
  }

  void pauseWorkout() {
    if (state != null) {
      final pausedAt = DateTime.now();
      final elapsedBeforePause = state!.startTime != null
          ? pausedAt.difference(state!.startTime!).inSeconds
          : 0;

      // Track workout paused
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutPaused(
        workoutId: state!.id,
        elapsedSeconds: elapsedBeforePause,
      );

      state = state!.pauseWorkout();

      // BUG FIX: Force save when pausing (user expects data saved)
      _autoSaveIfNeeded();
    }
  }

  void resumeWorkout() {
    if (state != null) {
      final pausedSeconds =
          state!.status == WorkoutStatus.paused && state!.endTime != null
          ? DateTime.now().difference(state!.endTime!).inSeconds
          : 0;

      // Track workout resumed
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutResumed(
        workoutId: state!.id,
        pausedSeconds: pausedSeconds,
      );

      state = state!.resumeWorkout();
    }
  }

  /// Undo workout completion - restore to "in progress" state
  ///
  /// Reverts a completed workout back to active state, allowing user to continue.
  /// Used for the undo pattern after workout completion.
  void undoCompletion() {
    if (state != null && state!.isCompleted) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '🔄 [WorkoutProvider] Undoing workout completion: ${state!.name}',
        );
      }

      // Restore workout to active state
      state = state!.copyWith(status: WorkoutStatus.inProgress, endTime: null);

      // Haptic feedback for undo action
      HapticFeedbackService.exerciseCompletion(ref);

      // Re-enable wakelock
      ref.read(screenWakelockProvider.notifier).startWakelock();

      // Track undo action
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = WorkoutEventTracker(analytics);

      tracker.trackWorkoutResumed(
        workoutId: state!.id,
        pausedSeconds: state!.duration?.inSeconds ?? 0,
      );
    }
  }

  void clearWorkout() {
    try {
      final workout = state;
      final isGuidedTestWorkout =
          workout != null && _isGuidedTestWorkout(workout);

      if (isGuidedTestWorkout) {
        // Guided test discard branch: no real workout analytics.
        final analytics = ref.read(analyticsServiceProvider);
        if (_currentTemplateId != null) {
          final cacheService = ref.read(workoutTemplateCacheServiceProvider);
          cacheService.clearCache(_currentTemplateId!);
          _currentTemplateId = null;
        }
        ref.read(unifiedTimerProvider.notifier).stopTimer();
        ref
            .read(workoutAutoSaveProvider.notifier)
            .stopAutoSave(clearDraft: true);
        ref.read(screenWakelockProvider.notifier).stopWakelock();
        ref.read(watchConnectivityProvider.notifier).notifyWorkoutEnded();
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .endLiveActivity(dismissPolicy: 'immediate');
        }
        state = null;
        final choiceService = ref.read(onboardingChoiceServiceProvider);
        unawaited(choiceService?.cancelGuidedTestMode());
        ref.invalidate(shouldShowGuidedSoftGateReminderProvider);
        unawaited(
          analytics.logEvent(
            name: AnalyticsEvents.guidedTestDiscarded,
            parameters: {AnalyticsParameters.workoutId: workout.id},
          ),
        );
        return;
      }

      // DEFENSIVE FIX: Force save any pending template modifications before clearing
      // This acts as a safety net in case clearWorkout is called directly
      if (_currentTemplateId != null && state != null) {
        final cacheService = ref.read(workoutTemplateCacheServiceProvider);
        cacheService.forceSave(); // Non-blocking, triggers immediate save
      }

      // Track workout cancelled only if NOT already completed
      // completeWorkout() already tracks workout_completed, notifies Watch, and ends LA
      if (state != null && !state!.isCompleted) {
        final analytics = ref.read(analyticsServiceProvider);
        final tracker = WorkoutEventTracker(analytics);

        tracker.trackWorkoutCancelled(
          workoutId: state!.id,
          elapsedSeconds: state!.duration?.inSeconds ?? 0,
          exerciseCount: state!.exercises.length,
        );

        // Notify Watch to discard HKWorkoutSession (only for cancelled)
        ref.read(watchConnectivityProvider.notifier).notifyWorkoutEnded();

        // End iOS 17+ Workout Session Live Activity (only for cancelled)
        if (Platform.isIOS) {
          ref
              .read(workoutSessionLAProvider.notifier)
              .endLiveActivity(dismissPolicy: 'immediate');
        }
      }

      state = null;

      // BUG FIX: Stop auto-save and clear draft when workout is cleared
      ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);

      // Deactivate wakelock (safe to call even if already stopped)
      ref.read(screenWakelockProvider.notifier).stopWakelock();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugLog(
          LogCategory.workout,
          '❌ [WorkoutProvider] Error clearing workout: $e',
        );
        debugLog(LogCategory.workout, '📍 Stack trace: $stackTrace');
      }
      // Ensure state is cleared even if wakelock fails
      state = null;
      // Still try to stop auto-save
      ref.read(workoutAutoSaveProvider.notifier).stopAutoSave(clearDraft: true);
    }
  }
}
