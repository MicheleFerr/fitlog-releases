import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider for the WorkoutSessionLAService singleton
final workoutSessionLAServiceProvider = Provider<WorkoutSessionLAService>((ref) {
  final service = WorkoutSessionLAService();
  service.initialize();
  return service;
});

/// Provider that manages the Workout Session Live Activity
///
/// This provider listens to workout state changes and automatically
/// updates the Live Activity accordingly. It acts as a bridge between
/// the WorkoutProvider and the native iOS Live Activity.
final workoutSessionLAProvider =
    NotifierProvider<WorkoutSessionLANotifier, WorkoutSessionLAState>(
  WorkoutSessionLANotifier.new,
);

/// State class for the Live Activity
class WorkoutSessionLAState {
  final bool isActive;
  final String? activityId;
  final WorkoutSessionMode mode;
  final String? currentExerciseName;
  final int currentSetIndex;
  final int totalSets;

  const WorkoutSessionLAState({
    this.isActive = false,
    this.activityId,
    this.mode = WorkoutSessionMode.exercise,
    this.currentExerciseName,
    this.currentSetIndex = 1,
    this.totalSets = 1,
  });

  WorkoutSessionLAState copyWith({
    bool? isActive,
    String? activityId,
    WorkoutSessionMode? mode,
    String? currentExerciseName,
    int? currentSetIndex,
    int? totalSets,
  }) {
    return WorkoutSessionLAState(
      isActive: isActive ?? this.isActive,
      activityId: activityId ?? this.activityId,
      mode: mode ?? this.mode,
      currentExerciseName: currentExerciseName ?? this.currentExerciseName,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      totalSets: totalSets ?? this.totalSets,
    );
  }
}

/// Notifier that manages the Live Activity lifecycle
class WorkoutSessionLANotifier extends Notifier<WorkoutSessionLAState> {
  StreamSubscription<WorkoutSessionEvent>? _eventSubscription;
  bool _wasInRestMode = false;

  /// Guard flag to prevent double transition when timer completes
  /// This prevents race condition where timer state changes fire twice
  bool _isTransitioningToExercise = false;

  /// ✅ FIX: Debounce timer to prevent race condition with REST→EXERCISE transition
  /// Gives iOS native side time to complete the transitionToRest before we call transitionToExercise
  Timer? _transitionDebounceTimer;

  @override
  WorkoutSessionLAState build() {
    // Only setup on iOS
    if (!Platform.isIOS) {
      return const WorkoutSessionLAState();
    }

    // Listen to Live Activity events (button taps from lock screen)
    final service = ref.read(workoutSessionLAServiceProvider);
    _eventSubscription?.cancel();
    _eventSubscription = service.events.listen(_handleLiveActivityEvent);

    // Listen to timer state for rest → exercise transitions
    debugPrint('[WorkoutSessionLA] 📡 Setting up timer state listener');
    ref.listen(unifiedTimerProvider, (previous, next) {
      _handleTimerStateChange(previous, next);
    });
    debugPrint('[WorkoutSessionLA] ✅ Timer state listener set up');

    // Cleanup on dispose
    ref.onDispose(() {
      debugPrint('[WorkoutSessionLA] 🗑️ Provider being disposed - cleaning up');
      _eventSubscription?.cancel();
      _transitionDebounceTimer?.cancel();
    });

    return const WorkoutSessionLAState();
  }

  /// Handle timer state changes to transition LA between rest and exercise modes
  void _handleTimerStateChange(UnifiedTimerState? previous, UnifiedTimerState? next) {
    // Check if timer just completed (was active, now completed or null)
    final wasActive = previous?.isActive == true;
    final isNowInactive = next == null || next.isCompleted;

    // Only log when there's an actual transition (not every tick)
    if (wasActive && isNowInactive) {
      debugPrint('[WorkoutSessionLA] 🔄 Timer TRANSITION detected: wasActive=$wasActive, isNowInactive=$isNowInactive, mode=${state.mode}, isTransitioning=$_isTransitioningToExercise');
    }

    if (wasActive && isNowInactive && state.mode == WorkoutSessionMode.rest) {
      // GUARD: Prevent double transition due to rapid state changes
      if (_isTransitioningToExercise) {
        debugPrint('[WorkoutSessionLA] ⚠️ Already transitioning - skipping duplicate');
        return;
      }
      _isTransitioningToExercise = true;

      // ✅ FIX: Cancel any pending transition to prevent race condition
      _transitionDebounceTimer?.cancel();

      // ✅ FIX: Add 500ms delay to let iOS complete the transitionToRest first
      // This prevents "MODE STILL rest - UPDATE FAILED!" error caused by
      // transitionToExercise being called before iOS has processed transitionToRest
      debugPrint('[WorkoutSessionLA] ⏰ Timer completed - scheduling EXERCISE transition with 500ms delay');
      _transitionDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        debugPrint('[WorkoutSessionLA] ⏰ Debounce complete - now transitioning LA to EXERCISE mode');
        _transitionToExerciseAfterRest();
      });
    }

    // Track if we're entering rest mode
    _wasInRestMode = state.mode == WorkoutSessionMode.rest;
  }

  /// Transition Live Activity back to exercise mode after rest timer ends
  void _transitionToExerciseAfterRest() {
    debugPrint('[WorkoutSessionLA] 🔄 _transitionToExerciseAfterRest called');

    final workout = ref.read(currentWorkoutProvider);
    if (workout == null) {
      debugPrint('[WorkoutSessionLA] ❌ No workout found, cannot transition');
      return;
    }

    debugPrint('[WorkoutSessionLA] 📋 Looking for next incomplete set in ${workout.exercises.length} exercises');

    // Find the current exercise and set
    for (final exercise in workout.exercises) {
      final incompleteSetIndex = exercise.sets.indexWhere((set) => !set.isCompleted);

      if (incompleteSetIndex != -1) {
        final completedExercises = workout.exercises
            .where((e) => e.sets.every((s) => s.isCompleted))
            .length;

        debugPrint('[WorkoutSessionLA] ✅ Found next set: ${exercise.name} set #${incompleteSetIndex + 1}');

        transitionToExercise(
          exercise: exercise,
          setIndex: incompleteSetIndex + 1,
          completedExercises: completedExercises,
          totalExercises: workout.exercises.length,
        );
        return;
      }
    }

    debugPrint('[WorkoutSessionLA] ⚠️ No incomplete sets found - workout may be complete');
  }

  WorkoutSessionLAService get _service => ref.read(workoutSessionLAServiceProvider);

  /// Start the Live Activity when a workout begins
  Future<void> startLiveActivity(Workout workout) async {
    if (!Platform.isIOS) return;

    debugPrint('[WorkoutSessionLA] 🚀 Starting Live Activity for workout: ${workout.name}');

    final firstExercise = workout.exercises.isNotEmpty
        ? workout.exercises.first
        : null;

    if (firstExercise == null) {
      debugPrint('[WorkoutSessionLA] ❌ No exercises in workout');
      return;
    }

    // Get RPE setting from app config
    final appConfig = ref.read(appConfigProvider);
    final rpeEnabled = appConfig.rpeTracking ?? false;

    // Find first incomplete set
    final firstIncompleteSetIndex = firstExercise.sets
        .indexWhere((set) => !set.isCompleted);
    final currentSetIndex = firstIncompleteSetIndex == -1
        ? firstExercise.sets.length
        : firstIncompleteSetIndex + 1;

    final firstSet = firstExercise.sets.isNotEmpty
        ? firstExercise.sets[firstIncompleteSetIndex == -1 ? 0 : firstIncompleteSetIndex]
        : null;

    // Count completed exercises
    final completedExercises = workout.exercises
        .where((e) => e.sets.every((s) => s.isCompleted))
        .length;

    final activityId = await _service.startSession(
      workoutId: workout.id,
      workoutName: workout.name,
      exerciseName: firstExercise.name,
      currentSet: currentSetIndex,
      totalSets: firstExercise.sets.length,
      weight: firstSet?.weight ?? 0,
      targetReps: firstSet?.reps ?? 0,
      completedExercises: completedExercises,
      totalExercises: workout.exercises.length,
      rpeEnabled: rpeEnabled,
    );

    if (activityId != null) {
      debugPrint('[WorkoutSessionLA] ✅ Live Activity started with ID: $activityId');
      state = state.copyWith(
        isActive: true,
        activityId: activityId,
        mode: WorkoutSessionMode.exercise,
        currentExerciseName: firstExercise.name,
        currentSetIndex: currentSetIndex,
        totalSets: firstExercise.sets.length,
      );

      // Store the current exercise's rest time in UserDefaults for AppIntent access
      final restDuration = firstExercise.restTime ?? 90;
      await _service.setCurrentRestDuration(restDuration);

      // Store RPE tracking setting so AppIntent knows whether to show RPE mode
      await _service.setRpeTrackingEnabled(rpeEnabled);
    } else {
      debugPrint('[WorkoutSessionLA] ❌ Failed to start Live Activity (null activityId)');
    }
  }

  /// Update the Live Activity with new exercise info
  Future<void> updateExercise(Exercise exercise, int completedExercises, int totalExercises) async {
    if (!state.isActive) return;

    // Find first incomplete set
    final firstIncompleteSetIndex = exercise.sets
        .indexWhere((set) => !set.isCompleted);
    final currentSetIndex = firstIncompleteSetIndex == -1
        ? exercise.sets.length
        : firstIncompleteSetIndex + 1;

    final currentSet = exercise.sets.isNotEmpty && firstIncompleteSetIndex != -1
        ? exercise.sets[firstIncompleteSetIndex]
        : (exercise.sets.isNotEmpty ? exercise.sets.last : null);

    await _service.transitionToExercise(
      exerciseName: exercise.name,
      currentSet: currentSetIndex,
      totalSets: exercise.sets.length,
      weight: currentSet?.weight ?? 0,
      targetReps: currentSet?.reps ?? 0,
      completedExercises: completedExercises,
    );

    state = state.copyWith(
      mode: WorkoutSessionMode.exercise,
      currentExerciseName: exercise.name,
      currentSetIndex: currentSetIndex,
      totalSets: exercise.sets.length,
    );

    // Update the rest duration for this exercise in UserDefaults
    final restDuration = exercise.restTime ?? 90;
    await _service.setCurrentRestDuration(restDuration);
  }

  /// Transition to rest mode after completing a set
  ///
  /// [restDurationSeconds] - Rest time in seconds
  /// [nextExercise] - The exercise for the next set (could be same or different)
  /// [nextSetIndex] - The set number to show as "Next"
  Future<void> transitionToRest({
    required int restDurationSeconds,
    required Exercise nextExercise,
    required int nextSetIndex,
  }) async {
    debugPrint('[WorkoutSessionLA] 🔄 transitionToRest called - isActive: ${state.isActive}, activityId: ${state.activityId}');

    // Reset transition guard flag when entering REST mode
    // This allows the next timer completion to trigger a new transition
    _isTransitioningToExercise = false;

    if (!state.isActive) {
      debugPrint('[WorkoutSessionLA] ⚠️ LA not active, cannot transition to rest');
      return;
    }

    final nextSet = nextExercise.sets.isNotEmpty && nextSetIndex <= nextExercise.sets.length
        ? nextExercise.sets[nextSetIndex - 1]
        : (nextExercise.sets.isNotEmpty ? nextExercise.sets.first : null);

    await _service.transitionToRest(
      restDuration: restDurationSeconds,
      nextExerciseName: nextExercise.name,
      nextSet: nextSetIndex,
      totalSets: nextExercise.sets.length,
      weight: nextSet?.weight ?? 0,
      targetReps: nextSet?.reps ?? 0,
    );

    state = state.copyWith(
      mode: WorkoutSessionMode.rest,
      currentExerciseName: nextExercise.name,
      currentSetIndex: nextSetIndex,
      totalSets: nextExercise.sets.length,
    );
  }

  /// Transition to RPE selection mode
  Future<void> transitionToRPE() async {
    if (!state.isActive) return;

    await _service.transitionToRPE();

    state = state.copyWith(mode: WorkoutSessionMode.rpe);
  }

  /// Transition back to exercise mode after rest timer ends
  Future<void> transitionToExercise({
    required Exercise exercise,
    required int setIndex,
    required int completedExercises,
    required int totalExercises,
  }) async {
    if (!state.isActive) {
      debugPrint('[WorkoutSessionLA] ⚠️ LA not active, cannot transition to exercise');
      _isTransitioningToExercise = false;
      return;
    }

    final set = exercise.sets.isNotEmpty && setIndex <= exercise.sets.length
        ? exercise.sets[setIndex - 1]
        : (exercise.sets.isNotEmpty ? exercise.sets.first : null);

    debugPrint('[WorkoutSessionLA] 📤 Calling iOS transitionToExercise: ${exercise.name} set $setIndex');
    await _service.transitionToExercise(
      exerciseName: exercise.name,
      currentSet: setIndex,
      totalSets: exercise.sets.length,
      weight: set?.weight ?? 0,
      targetReps: set?.reps ?? 0,
      completedExercises: completedExercises,
    );
    debugPrint('[WorkoutSessionLA] ✅ iOS transitionToExercise completed');

    state = state.copyWith(
      mode: WorkoutSessionMode.exercise,
      currentExerciseName: exercise.name,
      currentSetIndex: setIndex,
      totalSets: exercise.sets.length,
    );

    // Update the rest duration for this exercise in UserDefaults
    final restDuration = exercise.restTime ?? 90;
    await _service.setCurrentRestDuration(restDuration);
    debugPrint('[WorkoutSessionLA] ✅ Transition to EXERCISE complete, rest duration set to ${restDuration}s');

    // Reset transition guard flag
    _isTransitioningToExercise = false;
  }

  /// End the Live Activity when workout ends
  Future<void> endLiveActivity({String dismissPolicy = 'after_5s'}) async {
    if (!state.isActive) return;

    await _service.endSession(dismissPolicy: dismissPolicy);

    state = const WorkoutSessionLAState();
  }

  /// Check for pending Live Activity events on app resume
  ///
  /// Called by AppLifecycleManager when app resumes from background.
  /// This catches events (like +30s) that were sent while app was suspended.
  Future<void> checkPendingEventsOnResume() async {
    if (!Platform.isIOS) return;

    debugPrint('[WorkoutSessionLA] 🔍 Checking for pending events on app resume...');

    // The service's checkPendingEvents will:
    // 1. Read UserDefaults for any pending event
    // 2. Forward it via MethodChannel (which triggers _handleLiveActivityEvent)
    // 3. Clear the event from UserDefaults
    await _service.checkPendingEvents();
  }

  /// Handle events from Live Activity button taps
  void _handleLiveActivityEvent(WorkoutSessionEvent event) {
    debugPrint('[WorkoutSessionLA] 📥 Event received: ${event.eventType}');

    // Forward events to WorkoutProvider for handling
    final workoutNotifier = ref.read(currentWorkoutProvider.notifier);

    if (event.isCompleteSet) {
      // User tapped "Fatto" on Live Activity
      // This triggers set completion in the main app
      debugPrint('[WorkoutSessionLA] 🎯 Processing complete_set event');
      workoutNotifier.completeCurrentSetFromLiveActivity(
        selectedRPE: event.data['selectedRPE'] as int?,
      );
    } else if (event.isSkipRest) {
      // User tapped "Salta" - skip rest timer
      workoutNotifier.skipRestTimerFromLiveActivity();
    } else if (event.isAddTime) {
      // User tapped "+30s" - extend rest timer
      final addedSeconds = event.addedSeconds ?? 30;
      debugPrint('[WorkoutSessionLA] 📨 Received add_time event: +$addedSeconds seconds');
      debugPrint('[WorkoutSessionLA] 📨 Event data: ${event.data}');
      debugPrint('[WorkoutSessionLA] 📤 Calling extendRestTimerFromLiveActivity($addedSeconds)...');
      workoutNotifier.extendRestTimerFromLiveActivity(addedSeconds);
      debugPrint('[WorkoutSessionLA] ✅ extendRestTimerFromLiveActivity completed');
    } else if (event.isSelectRPE) {
      // User selected an RPE value - update Live Activity UI to show selection
      final selectedRPE = event.selectedRPE;
      if (selectedRPE != null) {
        if (kDebugMode) {
          debugPrint('[WorkoutSessionLA] 🎯 RPE selected: $selectedRPE - updating Live Activity');
        }
        // Update the Live Activity to show the selected RPE (highlights the button)
        _service.updateSelectedRPE(selectedRPE);
      }
    } else if (event.isConfirmRPE) {
      // User confirmed RPE selection
      final confirmedRPE = event.confirmedRPE;
      if (confirmedRPE != null) {
        workoutNotifier.confirmRPEFromLiveActivity(confirmedRPE);
      }
    }
  }
}

// Extension to add Live Activity support methods to CurrentWorkoutNotifier
extension WorkoutProviderLAExtension on CurrentWorkoutNotifier {
  /// Complete current set triggered from Live Activity "Fatto" button
  ///
  /// If RPE tracking is enabled, transitions to RPE mode first.
  /// Otherwise, directly completes the set and starts rest timer.
  void completeCurrentSetFromLiveActivity({int? selectedRPE}) {
    debugPrint('[WorkoutSessionLA] 🚀 completeCurrentSetFromLiveActivity called, selectedRPE: $selectedRPE');

    final workout = state;
    if (workout == null) {
      debugPrint('[WorkoutSessionLA] ❌ No active workout - state is null');
      return;
    }

    debugPrint('[WorkoutSessionLA] 📋 Workout: ${workout.name}, exercises: ${workout.exercises.length}');

    // Find the first exercise with incomplete sets
    Exercise? targetExercise;
    ExerciseSet? targetSet;

    for (final exercise in workout.exercises) {
      final incompleteSets = exercise.sets.where((set) => !set.isCompleted);
      debugPrint('[WorkoutSessionLA] 📊 Exercise ${exercise.name}: ${incompleteSets.length} incomplete sets');
      if (incompleteSets.isNotEmpty) {
        targetExercise = exercise;
        targetSet = incompleteSets.first;
        break;
      }
    }

    if (targetExercise == null || targetSet == null) {
      debugPrint('[WorkoutSessionLA] ⚠️ No incomplete sets found in any exercise');
      return;
    }

    debugPrint('[WorkoutSessionLA] 🎯 Target: ${targetExercise.name} set #${targetSet.setNumber}');

    // Check if RPE tracking is enabled
    final appConfig = ref.read(appConfigProvider);
    final rpeEnabled = appConfig.rpeTracking ?? false;
    debugPrint('[WorkoutSessionLA] ⚙️ RPE enabled: $rpeEnabled');

    if (rpeEnabled && selectedRPE == null) {
      // RPE is enabled and no RPE provided yet - show RPE selection screen
      debugPrint('[WorkoutSessionLA] 🎯 RPE enabled but no RPE provided - transitioning to RPE mode');
      ref.read(workoutSessionLAProvider.notifier).transitionToRPE();
      return;
    }

    debugPrint('[WorkoutSessionLA] ✅ Completing set ${targetSet.setNumber} of ${targetExercise.name}');

    // If RPE was provided, update the set first
    if (selectedRPE != null) {
      final updatedSet = targetSet.copyWith(rpe: selectedRPE);
      updateExerciseSet(targetExercise.id, updatedSet);
    }

    // Complete the set (this will start rest timer automatically)
    debugPrint('[WorkoutSessionLA] 📤 Calling completeSet(${targetExercise.id}, ${targetSet.id})');
    completeSet(targetExercise.id, targetSet.id);
    debugPrint('[WorkoutSessionLA] ✅ completeSet called successfully');
  }

  /// Skip rest timer triggered from Live Activity
  ///
  /// Cancels the current rest timer immediately without playing audio.
  void skipRestTimerFromLiveActivity() {
    if (kDebugMode) {
      debugPrint('[WorkoutSessionLA] ⏭️ Skipping rest timer from Live Activity');
    }

    // Skip the unified timer
    ref.read(unifiedTimerProvider.notifier).skipTimer();

    // Transition Live Activity back to exercise mode
    _transitionLAToExerciseMode();
  }

  /// Extend rest timer triggered from Live Activity
  ///
  /// Adds additional seconds to the current rest timer.
  /// NOTE: The Live Activity is ALREADY updated directly by WorkoutAddTimeIntent
  /// for immediate UI feedback. We pass fromLiveActivity: true to addTime() so it
  /// skips the LA update but still notifies the Watch.
  Future<void> extendRestTimerFromLiveActivity(int additionalSeconds) async {
    debugPrint('[WorkoutSessionLA] ⏰ extendRestTimerFromLiveActivity called: +$additionalSeconds seconds');

    // Check current timer state before
    final timerStateBefore = ref.read(unifiedTimerProvider);
    debugPrint('[WorkoutSessionLA] 📊 Timer state BEFORE: isActive=${timerStateBefore?.isActive}, remaining=${timerStateBefore?.remainingSeconds}s');

    // Update Flutter timer state and notify Watch
    // fromLiveActivity: true tells addTime() to skip LA update (already done by AppIntent)
    // but still notify the Watch
    debugPrint('[WorkoutSessionLA] 📤 Calling addTime($additionalSeconds, fromLiveActivity: true)...');
    await ref.read(unifiedTimerProvider.notifier).addTime(
      additionalSeconds,
      fromLiveActivity: true,
    );

    // Check timer state after
    final timerStateAfter = ref.read(unifiedTimerProvider);
    final newDuration = timerStateAfter?.totalDurationSeconds ?? 0;
    final newRemaining = timerStateAfter?.remainingSeconds ?? 0;
    debugPrint('[WorkoutSessionLA] ✅ Timer state AFTER: remaining=${newRemaining}s, total=${newDuration}s');
    debugPrint('[WorkoutSessionLA] ✅ +${additionalSeconds}s synced: Flutter ✓ Watch ✓ (LA already updated by AppIntent)');
  }

  /// Confirm RPE from Live Activity
  ///
  /// Completes the current set with the selected RPE, then starts rest timer.
  /// This is called after user confirms RPE selection on the Live Activity.
  void confirmRPEFromLiveActivity(int rpe) {
    final workout = state;
    if (workout == null) {
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] ❌ No active workout for RPE confirmation');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[WorkoutSessionLA] 💪 Confirming RPE: $rpe');
    }

    // Find the first INCOMPLETE set (the one we're about to complete)
    Exercise? targetExercise;
    ExerciseSet? targetSet;

    for (final exercise in workout.exercises) {
      final incompleteSets = exercise.sets.where((set) => !set.isCompleted);
      if (incompleteSets.isNotEmpty) {
        targetExercise = exercise;
        targetSet = incompleteSets.first;
        break;
      }
    }

    if (targetExercise == null || targetSet == null) {
      if (kDebugMode) {
        debugPrint('[WorkoutSessionLA] ⚠️ No incomplete set found for RPE confirmation');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[WorkoutSessionLA] ✅ Completing set ${targetSet.setNumber} of ${targetExercise.name} with RPE $rpe');
    }

    // Update the set with RPE value
    final updatedSet = targetSet.copyWith(rpe: rpe);
    updateExerciseSet(targetExercise.id, updatedSet);

    // Complete the set - this will automatically:
    // 1. Mark set as completed
    // 2. Start rest timer (if not last set)
    // 3. Transition Live Activity to REST mode
    completeSet(targetExercise.id, targetSet.id);
  }

  /// Helper to transition Live Activity back to exercise mode
  void _transitionLAToExerciseMode() {
    final workout = state;
    if (workout == null) return;

    // Find current exercise and set
    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      final incompleteSetIndex = exercise.sets.indexWhere((set) => !set.isCompleted);

      if (incompleteSetIndex != -1) {
        final completedExercises = workout.exercises
            .where((e) => e.sets.every((s) => s.isCompleted))
            .length;

        ref.read(workoutSessionLAProvider.notifier).transitionToExercise(
          exercise: exercise,
          setIndex: incompleteSetIndex + 1,
          completedExercises: completedExercises,
          totalExercises: workout.exercises.length,
        );
        break;
      }
    }
  }
}
