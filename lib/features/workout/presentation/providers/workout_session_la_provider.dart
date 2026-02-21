import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/timer/presentation/providers/unified_timer_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider for the WorkoutSessionLAService singleton
final workoutSessionLAServiceProvider = Provider<WorkoutSessionLAService>((
  ref,
) {
  final service = WorkoutSessionLAService();
  // Initialize service and handle errors
  service.initialize().catchError((e, stack) {
    print('[WorkoutSessionLA] Failed to initialize service: $e\n$stack');
  });
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

  const WorkoutSessionLAState({
    this.isActive = false,
    this.activityId,
    this.mode = WorkoutSessionMode.exercise,
    this.currentExerciseName,
    this.currentExerciseId,
    this.currentSetIndex = 1,
    this.totalSets = 1,
  });
  final bool isActive;
  final String? activityId;
  final WorkoutSessionMode mode;
  final String? currentExerciseName;
  final String? currentExerciseId;
  final int currentSetIndex;
  final int totalSets;

  WorkoutSessionLAState copyWith({
    bool? isActive,
    String? activityId,
    WorkoutSessionMode? mode,
    String? currentExerciseName,
    String? currentExerciseId,
    int? currentSetIndex,
    int? totalSets,
  }) {
    return WorkoutSessionLAState(
      isActive: isActive ?? this.isActive,
      activityId: activityId ?? this.activityId,
      mode: mode ?? this.mode,
      currentExerciseName: currentExerciseName ?? this.currentExerciseName,
      currentExerciseId: currentExerciseId ?? this.currentExerciseId,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      totalSets: totalSets ?? this.totalSets,
    );
  }
}

/// Notifier that manages the Live Activity lifecycle
class WorkoutSessionLANotifier extends Notifier<WorkoutSessionLAState> {
  StreamSubscription<WorkoutSessionEvent>? _eventSubscription;

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
    // FIX BUG-8: Use .select() to only fire when isCompleted changes,
    // instead of every tick (60 callbacks/min wasted on early returns).
    print('[WorkoutSessionLA] 📡 Setting up timer state listener');
    ref.listen(
      unifiedTimerProvider.select(
        (state) => (
          isActive: state?.isActive ?? false,
          isCompleted: state?.isCompleted ?? false,
        ),
      ),
      (previous, next) {
        final wasActive = previous?.isActive ?? false;
        final isNowCompleted = next.isCompleted;

        if (wasActive && isNowCompleted) {
          _onTimerCompleted();
        }
      },
    );
    print('[WorkoutSessionLA] ✅ Timer state listener set up');

    // Cleanup on dispose
    ref.onDispose(() {
      print(
        '[WorkoutSessionLA] 🗑️ Provider being disposed - cleaning up',
      );
      _eventSubscription?.cancel();
      _transitionDebounceTimer?.cancel();
    });

    return const WorkoutSessionLAState();
  }

  /// Called by the .select() listener when timer transitions from active to completed.
  /// Only fires on actual completion — not on every tick (FIX BUG-8).
  void _onTimerCompleted() {
    print(
      '[WorkoutSessionLA] 🔄 Timer COMPLETED detected: mode=${state.mode}, isTransitioning=$_isTransitioningToExercise',
    );

    if (state.mode != WorkoutSessionMode.rest) return;

    // GUARD: Prevent double transition due to rapid state changes
    if (_isTransitioningToExercise) {
      print(
        '[WorkoutSessionLA] ⚠️ Already transitioning - skipping duplicate',
      );
      return;
    }
    _isTransitioningToExercise = true;

    // Cancel any pending transition to prevent race condition
    _transitionDebounceTimer?.cancel();

    // 500ms delay to let iOS complete the transitionToRest first
    print(
      '[WorkoutSessionLA] ⏰ Timer completed - scheduling EXERCISE transition with 500ms delay',
    );
    _transitionDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      print(
        '[WorkoutSessionLA] ⏰ Debounce complete - now transitioning LA to EXERCISE mode',
      );
      _transitionToExerciseAfterRest();
    });
  }

  /// Transition Live Activity back to exercise mode after rest timer ends
  void _transitionToExerciseAfterRest() {
    print('[WorkoutSessionLA] 🔄 _transitionToExerciseAfterRest called');

    final workout = ref.read(currentWorkoutProvider);
    if (workout == null) {
      print('[WorkoutSessionLA] ❌ No workout found, cannot transition');
      return;
    }

    print(
      '[WorkoutSessionLA] 📋 Looking for next incomplete set (currentExerciseId=${state.currentExerciseId})',
    );

    // FIX: Use currentExerciseId to find the right exercise first
    // instead of blindly picking the first exercise with incomplete sets
    Exercise? targetExercise;
    int targetSetIndex = -1;

    if (state.currentExerciseId != null) {
      try {
        final currentExercise = workout.exercises.firstWhere(
          (e) => e.id == state.currentExerciseId,
        );
        final incompleteIdx = currentExercise.sets.indexWhere(
          (set) => !set.isCompleted,
        );
        if (incompleteIdx != -1) {
          targetExercise = currentExercise;
          targetSetIndex = incompleteIdx;
          print(
            '[WorkoutSessionLA] ✅ Current exercise still has incomplete sets: ${currentExercise.name} set #${incompleteIdx + 1}',
          );
        }
      } catch (_) {
        // Exercise not found by ID - fall through to scan
      }
    }

    // Fallback: scan all exercises for first incomplete set
    if (targetExercise == null) {
      for (final exercise in workout.exercises) {
        final incompleteSetIndex = exercise.sets.indexWhere(
          (set) => !set.isCompleted,
        );
        if (incompleteSetIndex != -1) {
          targetExercise = exercise;
          targetSetIndex = incompleteSetIndex;
          print(
            '[WorkoutSessionLA] 🔍 Fallback: found ${exercise.name} set #${incompleteSetIndex + 1}',
          );
          break;
        }
      }
    }

    if (targetExercise != null && targetSetIndex != -1) {
      final completedExercises = workout.exercises
          .where((e) => e.sets.every((s) => s.isCompleted))
          .length;

      transitionToExercise(
        exercise: targetExercise,
        setIndex: targetSetIndex + 1,
        completedExercises: completedExercises,
        totalExercises: workout.exercises.length,
      );
    } else {
      print(
        '[WorkoutSessionLA] ⚠️ No incomplete sets found - workout may be complete',
      );
    }
  }

  WorkoutSessionLAService get _service =>
      ref.read(workoutSessionLAServiceProvider);

  /// Start the Live Activity when a workout begins
  Future<void> startLiveActivity(Workout workout) async {
    if (!Platform.isIOS) return;

    print(
      '[WorkoutSessionLA] 🚀 Starting Live Activity for workout: ${workout.name}',
    );

    final firstExercise = workout.exercises.isNotEmpty
        ? workout.exercises.first
        : null;

    if (firstExercise == null) {
      print('[WorkoutSessionLA] ❌ No exercises in workout');
      return;
    }

    // Get RPE setting from app config
    final appConfig = ref.read(appConfigProvider);
    final rpeEnabled = appConfig.rpeTracking ?? false;

    // Find first incomplete set
    final firstIncompleteSetIndex = firstExercise.sets.indexWhere(
      (set) => !set.isCompleted,
    );
    final currentSetIndex = firstIncompleteSetIndex == -1
        ? firstExercise.sets.length
        : firstIncompleteSetIndex + 1;

    final firstSet = firstExercise.sets.isNotEmpty
        ? firstExercise.sets[firstIncompleteSetIndex == -1
              ? 0
              : firstIncompleteSetIndex]
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
      print(
        '[WorkoutSessionLA] ✅ Live Activity started with ID: $activityId',
      );
      state = state.copyWith(
        isActive: true,
        activityId: activityId,
        mode: WorkoutSessionMode.exercise,
        currentExerciseName: firstExercise.name,
        currentExerciseId: firstExercise.id,
        currentSetIndex: currentSetIndex,
        totalSets: firstExercise.sets.length,
      );

      // Store the current exercise's rest time in UserDefaults for AppIntent access
      final restDuration = firstExercise.restTime ?? 90;
      await _service.setCurrentRestDuration(restDuration);

      // Store RPE tracking setting so AppIntent knows whether to show RPE mode
      await _service.setRpeTrackingEnabled(rpeEnabled);

      // Precompute next exercise info for AppIntent
      await _computeAndStoreNextInfo(firstExercise, currentSetIndex, workout);
    } else {
      print(
        '[WorkoutSessionLA] ❌ Failed to start Live Activity (null activityId)',
      );
    }
  }

  /// Update the Live Activity with new exercise info
  Future<void> updateExercise(
    Exercise exercise,
    int completedExercises,
    int totalExercises,
  ) async {
    if (!state.isActive) return;

    // Find first incomplete set
    final firstIncompleteSetIndex = exercise.sets.indexWhere(
      (set) => !set.isCompleted,
    );
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
      currentExerciseId: exercise.id,
      currentSetIndex: currentSetIndex,
      totalSets: exercise.sets.length,
    );

    // Update the rest duration for this exercise in UserDefaults
    final restDuration = exercise.restTime ?? 90;
    await _service.setCurrentRestDuration(restDuration);

    // Precompute next exercise info for AppIntent
    final workout = ref.read(currentWorkoutProvider);
    if (workout != null) {
      await _computeAndStoreNextInfo(exercise, currentSetIndex, workout);
    }
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
    print(
      '[WorkoutSessionLA] 🔄 transitionToRest called - isActive: ${state.isActive}, activityId: ${state.activityId}',
    );

    // Reset transition guard flag when entering REST mode
    // This allows the next timer completion to trigger a new transition
    _isTransitioningToExercise = false;

    if (!state.isActive) {
      print(
        '[WorkoutSessionLA] ⚠️ LA not active, cannot transition to rest',
      );
      return;
    }

    final nextSet =
        nextExercise.sets.isNotEmpty && nextSetIndex <= nextExercise.sets.length
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
      currentExerciseId: nextExercise.id,
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
    try {
      if (!state.isActive) {
        print(
          '[WorkoutSessionLA] ⚠️ LA not active, cannot transition to exercise',
        );
        return;
      }

      final set = exercise.sets.isNotEmpty && setIndex <= exercise.sets.length
          ? exercise.sets[setIndex - 1]
          : (exercise.sets.isNotEmpty ? exercise.sets.first : null);

      print(
        '[WorkoutSessionLA] 📤 Calling iOS transitionToExercise: ${exercise.name} set $setIndex',
      );
      await _service.transitionToExercise(
        exerciseName: exercise.name,
        currentSet: setIndex,
        totalSets: exercise.sets.length,
        weight: set?.weight ?? 0,
        targetReps: set?.reps ?? 0,
        completedExercises: completedExercises,
      );
      print('[WorkoutSessionLA] ✅ iOS transitionToExercise completed');

      state = state.copyWith(
        mode: WorkoutSessionMode.exercise,
        currentExerciseName: exercise.name,
        currentExerciseId: exercise.id,
        currentSetIndex: setIndex,
        totalSets: exercise.sets.length,
      );

      // Update the rest duration for this exercise in UserDefaults
      final restDuration = exercise.restTime ?? 90;
      await _service.setCurrentRestDuration(restDuration);

      // Precompute next exercise info for AppIntent
      final workout = ref.read(currentWorkoutProvider);
      if (workout != null) {
        await _computeAndStoreNextInfo(exercise, setIndex, workout);
      }

      print(
        '[WorkoutSessionLA] ✅ Transition to EXERCISE complete, rest duration set to ${restDuration}s',
      );
    } finally {
      _isTransitioningToExercise = false;
    }
  }

  /// Precompute and store next exercise/set info in UserDefaults for AppIntent access
  ///
  /// When the AppIntent completes a set and transitions to REST, it needs to know
  /// what exercise/set to display next. This method precomputes that info.
  Future<void> _computeAndStoreNextInfo(
    Exercise exercise,
    int currentSetIndex,
    Workout workout,
  ) async {
    final isLastSet = currentSetIndex >= exercise.sets.length;

    if (!isLastSet) {
      // Not the last set of this exercise → next is the same exercise, next set
      final nextSetIdx = currentSetIndex; // 0-based index of next set
      final nextSet = nextSetIdx < exercise.sets.length
          ? exercise.sets[nextSetIdx]
          : null;

      await _service.setNextExerciseInfo(
        exerciseName: exercise.name,
        currentSet: currentSetIndex + 1,
        totalSets: exercise.sets.length,
        weight: nextSet?.weight ?? 0,
        targetReps: nextSet?.reps ?? 0,
        restDuration: exercise.restTime ?? 90,
        isLastSetOfExercise: (currentSetIndex + 1) >= exercise.sets.length,
      );
    } else {
      // Last set of this exercise → find the next exercise in the workout
      final exerciseIndex = workout.exercises.indexWhere(
        (e) => e.id == exercise.id,
      );
      Exercise? nextExercise;

      // Look for the next exercise with incomplete sets
      if (exerciseIndex != -1) {
        for (var i = exerciseIndex + 1; i < workout.exercises.length; i++) {
          final candidate = workout.exercises[i];
          if (candidate.sets.any((s) => !s.isCompleted)) {
            nextExercise = candidate;
            break;
          }
        }
      }

      if (nextExercise != null) {
        final firstIncomplete = nextExercise.sets.indexWhere(
          (s) => !s.isCompleted,
        );
        final nextSetIdx = firstIncomplete == -1 ? 0 : firstIncomplete;
        final nextSet = nextExercise.sets.isNotEmpty
            ? nextExercise.sets[nextSetIdx]
            : null;

        // Use the inter-exercise rest (restAfterExercise) if available
        final interExerciseRest = exercise.restAfterExercise ?? exercise.restTime ?? 90;

        await _service.setNextExerciseInfo(
          exerciseName: nextExercise.name,
          currentSet: nextSetIdx + 1,
          totalSets: nextExercise.sets.length,
          weight: nextSet?.weight ?? 0,
          targetReps: nextSet?.reps ?? 0,
          restDuration: interExerciseRest,
          isLastSetOfExercise: false,
        );
      } else {
        // No more exercises — store current info as fallback
        await _service.setNextExerciseInfo(
          exerciseName: exercise.name,
          currentSet: exercise.sets.length,
          totalSets: exercise.sets.length,
          weight: 0,
          targetReps: 0,
          restDuration: exercise.restTime ?? 90,
          isLastSetOfExercise: true,
        );
      }
    }
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
  /// This catches events (like +15s) that were sent while app was suspended.
  ///
  /// ARCH-3 FIX: The native checkPendingEvents now returns event data directly
  /// instead of invoking MethodChannel (avoids double-processing). We process
  /// the returned data explicitly via _handleLiveActivityEvent.
  Future<void> checkPendingEventsOnResume() async {
    if (!Platform.isIOS) return;

    print(
      '[WorkoutSessionLA] 🔍 Checking for pending events on app resume...',
    );

    final pendingEvent = await _service.checkPendingEvents();
    if (pendingEvent != null) {
      print(
        '[WorkoutSessionLA] 📬 Processing pending event: ${pendingEvent['eventType']}',
      );
      final event = WorkoutSessionEvent.fromMap(pendingEvent);
      _handleLiveActivityEvent(event);
    }
  }

  /// Handle events from Live Activity button taps
  void _handleLiveActivityEvent(WorkoutSessionEvent event) {
    print('[WorkoutSessionLA] 📥 Event received: ${event.eventType}');

    // Forward events to WorkoutProvider for handling
    final workoutNotifier = ref.read(currentWorkoutProvider.notifier);

    if (event.isCompleteSet) {
      // User tapped "Fatto" on Live Activity
      // This triggers set completion in the main app
      print('[WorkoutSessionLA] 🎯 Processing complete_set event');
      workoutNotifier.completeCurrentSetFromLiveActivity(
        selectedRPE: event.data['selectedRPE'] as int?,
      );
    } else if (event.isSkipRest) {
      // User tapped "Salta" - skip rest timer
      workoutNotifier.skipRestTimerFromLiveActivity();
    } else if (event.isAddTime) {
      // User tapped "+15s" - extend rest timer
      final addedSeconds = event.addedSeconds ?? 15;
      print(
        '[WorkoutSessionLA] 📨 Received add_time event: +$addedSeconds seconds',
      );
      print('[WorkoutSessionLA] 📨 Event data: ${event.data}');
      print(
        '[WorkoutSessionLA] 📤 Calling extendRestTimerFromLiveActivity($addedSeconds)...',
      );
      // FIX BUG-6: extendRestTimerFromLiveActivity returns Future<void>.
      // Stream.listen callbacks can't await, so use unawaited + catchError
      // to prevent silently swallowed errors.
      unawaited(
        workoutNotifier.extendRestTimerFromLiveActivity(addedSeconds).catchError((Object e) {
          print('[WorkoutSessionLA] Error extending rest timer: $e');
        }),
      );
    } else if (event.isSelectRPE) {
      // User selected an RPE value - update Live Activity UI to show selection
      final selectedRPE = event.selectedRPE;
      if (selectedRPE != null) {
        print(
          '[WorkoutSessionLA] 🎯 RPE selected: $selectedRPE - updating Live Activity',
        );
        // Update the Live Activity to show the selected RPE (highlights the button)
        _service.updateSelectedRPE(selectedRPE);
      }
    } else if (event.isConfirmRPE) {
      // User confirmed RPE selection
      final confirmedRPE = event.confirmedRPE;
      if (confirmedRPE != null) {
        workoutNotifier.confirmRPEFromLiveActivity(confirmedRPE);
      }
    } else if (event.isPauseResume) {
      // User tapped pause/resume on Live Activity lock screen
      print('[WorkoutSessionLA] ⏯️ Processing pause_resume event');
      final timerNotifier = ref.read(unifiedTimerProvider.notifier);
      final timerState = ref.read(unifiedTimerProvider);
      if (timerState != null && timerState.isActive) {
        if (timerState.isPaused) {
          timerNotifier.resumeTimer();
        } else {
          timerNotifier.pauseTimer();
        }
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
    print(
      '[WorkoutSessionLA] 🚀 completeCurrentSetFromLiveActivity called, selectedRPE: $selectedRPE',
    );

    final workout = state;
    if (workout == null) {
      print('[WorkoutSessionLA] ❌ No active workout - state is null');
      return;
    }

    print(
      '[WorkoutSessionLA] 📋 Workout: ${workout.name}, exercises: ${workout.exercises.length}',
    );

    // FIX: Use currentExerciseId from LA state to find the right exercise
    final laState = ref.read(workoutSessionLAProvider);
    final currentExerciseId = laState.currentExerciseId;
    print(
      '[WorkoutSessionLA] 🔍 LA currentExerciseId: $currentExerciseId',
    );

    Exercise? targetExercise;
    ExerciseSet? targetSet;

    // Try to find the exercise tracked by the LA first
    if (currentExerciseId != null) {
      try {
        final currentExercise = workout.exercises.firstWhere(
          (e) => e.id == currentExerciseId,
        );
        final incompleteSets = currentExercise.sets.where((set) => !set.isCompleted);
        if (incompleteSets.isNotEmpty) {
          targetExercise = currentExercise;
          targetSet = incompleteSets.first;
          print(
            '[WorkoutSessionLA] ✅ Using LA-tracked exercise: ${currentExercise.name}',
          );
        }
      } catch (_) {
        // Exercise not found by ID - fall through
      }
    }

    // Fallback: find the first exercise with incomplete sets
    if (targetExercise == null || targetSet == null) {
      for (final exercise in workout.exercises) {
        final incompleteSets = exercise.sets.where((set) => !set.isCompleted);
        if (incompleteSets.isNotEmpty) {
          targetExercise = exercise;
          targetSet = incompleteSets.first;
          print(
            '[WorkoutSessionLA] 🔍 Fallback: ${exercise.name} set #${targetSet!.setNumber}',
          );
          break;
        }
      }
    }

    if (targetExercise == null || targetSet == null) {
      print(
        '[WorkoutSessionLA] ⚠️ No incomplete sets found in any exercise',
      );
      return;
    }

    print(
      '[WorkoutSessionLA] 🎯 Target: ${targetExercise.name} set #${targetSet.setNumber}',
    );

    // Check if RPE tracking is enabled
    final appConfig = ref.read(appConfigProvider);
    final rpeEnabled = appConfig.rpeTracking ?? false;
    print('[WorkoutSessionLA] ⚙️ RPE enabled: $rpeEnabled');

    if (rpeEnabled && selectedRPE == null) {
      // RPE is enabled and no RPE provided yet - show RPE selection screen
      print(
        '[WorkoutSessionLA] 🎯 RPE enabled but no RPE provided - transitioning to RPE mode',
      );
      ref.read(workoutSessionLAProvider.notifier).transitionToRPE();
      return;
    }

    print(
      '[WorkoutSessionLA] ✅ Completing set ${targetSet.setNumber} of ${targetExercise.name}',
    );

    // If RPE was provided, update the set first
    if (selectedRPE != null) {
      final updatedSet = targetSet.copyWith(rpe: selectedRPE);
      updateExerciseSet(targetExercise.id, updatedSet);
    }

    // Complete the set (this will start rest timer automatically)
    print(
      '[WorkoutSessionLA] 📤 Calling completeSet(${targetExercise.id}, ${targetSet.id})',
    );
    completeSet(targetExercise.id, targetSet.id);
    print('[WorkoutSessionLA] ✅ completeSet called successfully');
  }

  /// Skip rest timer triggered from Live Activity
  ///
  /// Cancels the current rest timer immediately without playing audio.
  void skipRestTimerFromLiveActivity() {
    print(
      '[WorkoutSessionLA] ⏭️ Skipping rest timer from Live Activity',
    );

    // Skip the unified timer
    ref.read(unifiedTimerProvider.notifier).skipTimer();

    // Transition Live Activity back to exercise mode
    _transitionLAToExerciseMode();
  }

  /// Extend rest timer triggered from Live Activity
  ///
  /// Adds additional seconds to the current rest timer.
  /// NOTE: The Live Activity is ALREADY updated directly by WorkoutExtendRestIntent
  /// for immediate UI feedback. We pass fromLiveActivity: true to addTime() so it
  /// skips the LA update but still notifies the Watch.
  Future<void> extendRestTimerFromLiveActivity(int additionalSeconds) async {
    print(
      '[WorkoutSessionLA] ⏰ extendRestTimerFromLiveActivity called: +$additionalSeconds seconds',
    );

    // Check current timer state before
    final timerStateBefore = ref.read(unifiedTimerProvider);
    print(
      '[WorkoutSessionLA] 📊 Timer state BEFORE: isActive=${timerStateBefore?.isActive}, remaining=${timerStateBefore?.remainingSeconds}s',
    );

    // Update Flutter timer state and notify Watch
    // fromLiveActivity: true tells addTime() to skip LA update (already done by AppIntent)
    // but still notify the Watch
    print(
      '[WorkoutSessionLA] 📤 Calling addTime($additionalSeconds, fromLiveActivity: true)...',
    );
    await ref
        .read(unifiedTimerProvider.notifier)
        .addTime(additionalSeconds, fromLiveActivity: true);

    // Check timer state after
    final timerStateAfter = ref.read(unifiedTimerProvider);
    final newDuration = timerStateAfter?.totalDurationSeconds ?? 0;
    final newRemaining = timerStateAfter?.remainingSeconds ?? 0;
    print(
      '[WorkoutSessionLA] ✅ Timer state AFTER: remaining=${newRemaining}s, total=${newDuration}s',
    );
    print(
      '[WorkoutSessionLA] ✅ +${additionalSeconds}s synced: Flutter ✓ Watch ✓ (LA already updated by AppIntent)',
    );
  }

  /// Confirm RPE from Live Activity
  ///
  /// Completes the current set with the selected RPE, then starts rest timer.
  /// This is called after user confirms RPE selection on the Live Activity.
  void confirmRPEFromLiveActivity(int rpe) {
    final workout = state;
    if (workout == null) {
      print(
        '[WorkoutSessionLA] ❌ No active workout for RPE confirmation',
      );
      return;
    }

    print('[WorkoutSessionLA] 💪 Confirming RPE: $rpe');

    // FIX: Use currentExerciseId from LA state to find the right exercise
    final laState = ref.read(workoutSessionLAProvider);
    final currentExerciseId = laState.currentExerciseId;

    Exercise? targetExercise;
    ExerciseSet? targetSet;

    // Try LA-tracked exercise first
    if (currentExerciseId != null) {
      try {
        final currentExercise = workout.exercises.firstWhere(
          (e) => e.id == currentExerciseId,
        );
        final incompleteSets = currentExercise.sets.where((set) => !set.isCompleted);
        if (incompleteSets.isNotEmpty) {
          targetExercise = currentExercise;
          targetSet = incompleteSets.first;
        }
      } catch (_) {
        // Exercise not found by ID - fall through
      }
    }

    // Fallback: find first incomplete
    if (targetExercise == null || targetSet == null) {
      for (final exercise in workout.exercises) {
        final incompleteSets = exercise.sets.where((set) => !set.isCompleted);
        if (incompleteSets.isNotEmpty) {
          targetExercise = exercise;
          targetSet = incompleteSets.first;
          break;
        }
      }
    }

    if (targetExercise == null || targetSet == null) {
      print(
        '[WorkoutSessionLA] ⚠️ No incomplete set found for RPE confirmation',
      );
      return;
    }

    print(
      '[WorkoutSessionLA] ✅ Completing set ${targetSet.setNumber} of ${targetExercise.name} with RPE $rpe',
    );

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

    // FIX: Use currentExerciseId from LA state to find the right exercise
    final laState = ref.read(workoutSessionLAProvider);
    final currentExerciseId = laState.currentExerciseId;
    Exercise? targetExercise;
    int targetSetIndex = -1;

    // Try LA-tracked exercise first
    if (currentExerciseId != null) {
      try {
        final currentExercise = workout.exercises.firstWhere(
          (e) => e.id == currentExerciseId,
        );
        final incompleteIdx = currentExercise.sets.indexWhere(
          (set) => !set.isCompleted,
        );
        if (incompleteIdx != -1) {
          targetExercise = currentExercise;
          targetSetIndex = incompleteIdx;
        }
      } catch (_) {
        // Exercise not found by ID
      }
    }

    // Fallback: scan all exercises
    if (targetExercise == null) {
      for (final exercise in workout.exercises) {
        final incompleteIdx = exercise.sets.indexWhere(
          (set) => !set.isCompleted,
        );
        if (incompleteIdx != -1) {
          targetExercise = exercise;
          targetSetIndex = incompleteIdx;
          break;
        }
      }
    }

    if (targetExercise != null && targetSetIndex != -1) {
      final completedExercises = workout.exercises
          .where((e) => e.sets.every((s) => s.isCompleted))
          .length;

      ref
          .read(workoutSessionLAProvider.notifier)
          .transitionToExercise(
            exercise: targetExercise,
            setIndex: targetSetIndex + 1,
            completedExercises: completedExercises,
            totalExercises: workout.exercises.length,
          );
    }
  }
}
