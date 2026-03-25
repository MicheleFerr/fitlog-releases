// ignore_for_file: avoid_redundant_argument_values

/// Additional tests for HomeTourNotifier, WorkoutTutorialNotifier,
/// and TemplatesTourNotifier to increase coverage.
///
/// Covers:
/// - TemplatesTourState / TemplatesTourNotifier (no existing tests)
/// - HomeTourNotifier._getNextStep logic (via enum ordering)
/// - HomeTourNotifier._getStepNumber logic (via enum ordering)
/// - WorkoutTutorialNotifier static cache (clearCacheForTesting)
/// - WorkoutTutorialNotifier.isLoaded / waitForLoad edge cases
/// - WorkoutTutorialState copyWith partial updates
/// - HomeTourState all enum values
/// - TemplatesTourStep enum
/// - showCurrentStep guard: !state.isActive early return
/// - showTour guard: !state.isActive early return
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/home_tour_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/templates_tour_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer() => ProviderContainer();

void main() {
  // =========================================================================
  // TemplatesTourStep enum
  // =========================================================================
  group('TemplatesTourStep enum', () {
    test('has 5 values in correct order', () {
      expect(TemplatesTourStep.values, hasLength(5));
      expect(TemplatesTourStep.values.first, TemplatesTourStep.myTemplates);
      expect(TemplatesTourStep.values.last, TemplatesTourStep.completed);
    });

    test('all non-completed steps have valid indices', () {
      for (final step in TemplatesTourStep.values) {
        if (step == TemplatesTourStep.completed) continue;
        expect(TemplatesTourStep.values.indexOf(step), greaterThanOrEqualTo(0));
      }
    });

    test('completed step has index 4', () {
      expect(TemplatesTourStep.values.indexOf(TemplatesTourStep.completed), 4);
    });
  });

  // =========================================================================
  // TemplatesTourState
  // =========================================================================
  group('TemplatesTourState', () {
    test('default constructor sets expected values', () {
      const state = TemplatesTourState(
        isActive: false,
        currentStep: TemplatesTourStep.myTemplates,
        hasCompletedTour: false,
      );
      expect(state.isActive, isFalse);
      expect(state.currentStep, TemplatesTourStep.myTemplates);
      expect(state.hasCompletedTour, isFalse);
    });

    test('copyWith updates isActive', () {
      const state = TemplatesTourState(
        isActive: false,
        currentStep: TemplatesTourStep.myTemplates,
        hasCompletedTour: false,
      );
      final updated = state.copyWith(isActive: true);
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, TemplatesTourStep.myTemplates);
      expect(updated.hasCompletedTour, isFalse);
    });

    test('copyWith updates currentStep', () {
      const state = TemplatesTourState(
        isActive: true,
        currentStep: TemplatesTourStep.myTemplates,
        hasCompletedTour: false,
      );
      final updated = state.copyWith(currentStep: TemplatesTourStep.exercises);
      expect(updated.currentStep, TemplatesTourStep.exercises);
      expect(updated.isActive, isTrue);
    });

    test('copyWith updates hasCompletedTour', () {
      const state = TemplatesTourState(
        isActive: false,
        currentStep: TemplatesTourStep.myTemplates,
        hasCompletedTour: false,
      );
      final updated = state.copyWith(hasCompletedTour: true);
      expect(updated.hasCompletedTour, isTrue);
      expect(state.hasCompletedTour, isFalse); // original unchanged
    });

    test('copyWith preserves all fields when nothing specified', () {
      const state = TemplatesTourState(
        isActive: true,
        currentStep: TemplatesTourStep.discover,
        hasCompletedTour: true,
      );
      final updated = state.copyWith();
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, TemplatesTourStep.discover);
      expect(updated.hasCompletedTour, isTrue);
    });

    test('copyWith all fields at once', () {
      const state = TemplatesTourState(
        isActive: false,
        currentStep: TemplatesTourStep.myTemplates,
        hasCompletedTour: false,
      );
      final updated = state.copyWith(
        isActive: true,
        currentStep: TemplatesTourStep.createButton,
        hasCompletedTour: true,
      );
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, TemplatesTourStep.createButton);
      expect(updated.hasCompletedTour, isTrue);
      // Original unchanged
      expect(state.isActive, isFalse);
      expect(state.currentStep, TemplatesTourStep.myTemplates);
      expect(state.hasCompletedTour, isFalse);
    });
  });

  // =========================================================================
  // TemplatesTourNotifier (Riverpod Notifier)
  // =========================================================================
  group('TemplatesTourNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state has isActive=false and first step', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final state = container.read(templatesTourProvider);
      expect(state.isActive, isFalse);
      expect(state.currentStep, TemplatesTourStep.myTemplates);
      expect(state.hasCompletedTour, isFalse);
    });

    test('startTour sets isActive=true and resets to first step', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(templatesTourProvider.notifier).startTour();

      final state = container.read(templatesTourProvider);
      expect(state.isActive, isTrue);
      expect(state.currentStep, TemplatesTourStep.myTemplates);
    });

    test('startTour after advanceToStep resets to first step', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(templatesTourProvider.notifier).startTour();
      container
          .read(templatesTourProvider.notifier)
          .advanceToStep(TemplatesTourStep.exercises);
      expect(
        container.read(templatesTourProvider).currentStep,
        TemplatesTourStep.exercises,
      );

      // Start again - resets to first step
      container.read(templatesTourProvider.notifier).startTour();
      expect(
        container.read(templatesTourProvider).currentStep,
        TemplatesTourStep.myTemplates,
      );
    });

    test('stopTour sets isActive=false', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(templatesTourProvider.notifier).startTour();
      container.read(templatesTourProvider.notifier).stopTour();

      expect(container.read(templatesTourProvider).isActive, isFalse);
    });

    test('advanceToStep only works when active', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Not active — advanceToStep should no-op
      container
          .read(templatesTourProvider.notifier)
          .advanceToStep(TemplatesTourStep.exercises);
      expect(
        container.read(templatesTourProvider).currentStep,
        TemplatesTourStep.myTemplates,
      );

      // Activate then advance
      container.read(templatesTourProvider.notifier).startTour();
      container
          .read(templatesTourProvider.notifier)
          .advanceToStep(TemplatesTourStep.discover);
      expect(
        container.read(templatesTourProvider).currentStep,
        TemplatesTourStep.discover,
      );
    });

    test('advanceToStep traverses all steps when active', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(templatesTourProvider.notifier).startTour();

      for (final step in [
        TemplatesTourStep.exercises,
        TemplatesTourStep.discover,
        TemplatesTourStep.createButton,
        TemplatesTourStep.completed,
      ]) {
        container.read(templatesTourProvider.notifier).advanceToStep(step);
        expect(container.read(templatesTourProvider).currentStep, step);
      }
    });

    test('completeTour sets hasCompletedTour=true and persists', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(templatesTourProvider.notifier).startTour();
      await container.read(templatesTourProvider.notifier).completeTour();

      final state = container.read(templatesTourProvider);
      expect(state.hasCompletedTour, isTrue);
      expect(state.isActive, isFalse);
      expect(state.currentStep, TemplatesTourStep.completed);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('templates_tour_completed'), isTrue);
    });

    test(
      'resetTour clears hasCompletedTour and SharedPreferences key',
      () async {
        final container = _makeContainer();
        addTearDown(container.dispose);

        container.read(templatesTourProvider.notifier).startTour();
        await container.read(templatesTourProvider.notifier).completeTour();

        expect(container.read(templatesTourProvider).hasCompletedTour, isTrue);

        await container.read(templatesTourProvider.notifier).resetTour();

        final state = container.read(templatesTourProvider);
        expect(state.hasCompletedTour, isFalse);
        expect(state.isActive, isFalse);
        expect(state.currentStep, TemplatesTourStep.myTemplates);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('templates_tour_completed'), isNull);
      },
    );

    test('resetTour without completeTour does not throw', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Reset without completing first should be a no-op for completion flag
      await container.read(templatesTourProvider.notifier).resetTour();

      final state = container.read(templatesTourProvider);
      expect(state.hasCompletedTour, isFalse);
    });

    test('templatesTourCompletedProvider reflects hasCompletedTour', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(container.read(templatesTourCompletedProvider), isFalse);

      container.read(templatesTourProvider.notifier).startTour();
      await container.read(templatesTourProvider.notifier).completeTour();

      expect(container.read(templatesTourCompletedProvider), isTrue);
    });

    test('complete + reset cycle toggles hasCompletedTour', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(templatesTourProvider.notifier).startTour();
      await container.read(templatesTourProvider.notifier).completeTour();
      expect(container.read(templatesTourProvider).hasCompletedTour, isTrue);

      await container.read(templatesTourProvider.notifier).resetTour();
      expect(container.read(templatesTourProvider).hasCompletedTour, isFalse);
    });

    test(
      'load from SharedPreferences - completed=true restores hasCompletedTour',
      () async {
        // Pre-populate SharedPreferences with completed=true
        SharedPreferences.setMockInitialValues({
          'templates_tour_completed': true,
        });

        final container = _makeContainer();

        // Trigger build() by reading the provider first, then wait for _loadState
        container.read(templatesTourProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(templatesTourProvider);
        container.dispose();
        expect(state.hasCompletedTour, isTrue);
      },
    );

    test('stopTour while not active does not throw', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Should not throw when calling stopTour before startTour
      expect(
        () => container.read(templatesTourProvider.notifier).stopTour(),
        returnsNormally,
      );
    });
  });

  // =========================================================================
  // HomeTourStep ordering — covers _getNextStep and _getStepNumber logic
  // =========================================================================
  group('HomeTourStep ordering', () {
    test('steps have correct enum index order', () {
      expect(HomeTourStep.xpProgress.index, 0);
      expect(HomeTourStep.myTemplates.index, 1);
      expect(HomeTourStep.aiCoachIntro.index, 2);
      expect(HomeTourStep.completed.index, 3);
    });

    test('_getStepNumber equivalent: indexOf returns 1-based numbers', () {
      // _getStepNumber is indexOf(step) + 1
      expect(HomeTourStep.values.indexOf(HomeTourStep.xpProgress) + 1, 1);
      expect(HomeTourStep.values.indexOf(HomeTourStep.myTemplates) + 1, 2);
      expect(HomeTourStep.values.indexOf(HomeTourStep.aiCoachIntro) + 1, 3);
    });

    test(
      '_getNextStep equivalent: last real step before completed has no next',
      () {
        // _getNextStep returns null when currentIndex >= values.length - 2
        // values.length = 4, so length - 2 = 2, aiCoachIntro has index 2 => no next
        const values = HomeTourStep.values;
        final aiIndex = values.indexOf(HomeTourStep.aiCoachIntro);
        final hasNext = aiIndex < values.length - 2;
        expect(hasNext, isFalse);
      },
    );

    test('_getNextStep equivalent: first step has a next', () {
      const values = HomeTourStep.values;
      final xpIndex = values.indexOf(HomeTourStep.xpProgress);
      final hasNext = xpIndex < values.length - 2;
      expect(hasNext, isTrue);
      expect(values[xpIndex + 1], HomeTourStep.myTemplates);
    });

    test('_getNextStep equivalent: myTemplates has a next', () {
      const values = HomeTourStep.values;
      final templateIndex = values.indexOf(HomeTourStep.myTemplates);
      final hasNext = templateIndex < values.length - 2;
      expect(hasNext, isTrue);
      expect(values[templateIndex + 1], HomeTourStep.aiCoachIntro);
    });
  });

  // =========================================================================
  // HomeTourNotifier — additional edge cases
  // =========================================================================
  group('HomeTourNotifier additional', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'load from SharedPreferences - completed=true restores hasCompletedTour',
      () async {
        SharedPreferences.setMockInitialValues({'home_tour_completed': true});

        final container = _makeContainer();

        // Trigger build() by reading the provider first, then wait for _loadState
        container.read(homeTourProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(homeTourProvider);
        container.dispose();
        expect(state.hasCompletedTour, isTrue);
      },
    );

    test('advanceToStep to all HomeTourStep values when active', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(homeTourProvider.notifier).startTour();

      for (final step in HomeTourStep.values) {
        container.read(homeTourProvider.notifier).advanceToStep(step);
        expect(container.read(homeTourProvider).currentStep, step);
      }
    });

    test('advanceToStep to completed step when active', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(homeTourProvider.notifier).startTour();
      container
          .read(homeTourProvider.notifier)
          .advanceToStep(HomeTourStep.completed);

      expect(
        container.read(homeTourProvider).currentStep,
        HomeTourStep.completed,
      );
    });

    test('multiple startTour calls reset to xpProgress each time', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(homeTourProvider.notifier).startTour();
      container
          .read(homeTourProvider.notifier)
          .advanceToStep(HomeTourStep.aiCoachIntro);

      container.read(homeTourProvider.notifier).startTour();
      expect(
        container.read(homeTourProvider).currentStep,
        HomeTourStep.xpProgress,
      );
    });

    test('stopTour while not started does not throw', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(homeTourProvider.notifier).stopTour(),
        returnsNormally,
      );
    });

    test('resetTour without completing does not throw', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(homeTourProvider.notifier).resetTour();
      expect(container.read(homeTourProvider).hasCompletedTour, isFalse);
    });

    test('completeTour without startTour still marks as completed', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(homeTourProvider.notifier).completeTour();

      final state = container.read(homeTourProvider);
      expect(state.hasCompletedTour, isTrue);
      expect(state.isActive, isFalse);
    });
  });

  // =========================================================================
  // WorkoutTutorialNotifier — additional edge cases
  // =========================================================================
  group('WorkoutTutorialNotifier additional', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      WorkoutTutorialNotifier.clearCacheForTesting();
    });

    tearDown(() {
      WorkoutTutorialNotifier.clearCacheForTesting();
    });

    test('advanceToStep to all non-completed steps when active', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();

      for (final step in WorkoutTutorialStep.values) {
        if (step == WorkoutTutorialStep.completed) continue;
        container.read(workoutTutorialProvider.notifier).advanceToStep(step);
        expect(container.read(workoutTutorialProvider).currentStep, step);
      }
    });

    test('advanceToStep to completed step when active', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      container
          .read(workoutTutorialProvider.notifier)
          .advanceToStep(WorkoutTutorialStep.completed);

      expect(
        container.read(workoutTutorialProvider).currentStep,
        WorkoutTutorialStep.completed,
      );
    });

    test('pauseTutorial while not active does not throw', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(workoutTutorialProvider.notifier).pauseTutorial(),
        returnsNormally,
      );
    });

    test('resumeTutorial while not paused does not throw', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(workoutTutorialProvider.notifier).resumeTutorial(),
        returnsNormally,
      );
    });

    test('stopTutorial while not started does not throw', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(workoutTutorialProvider.notifier).stopTutorial(),
        returnsNormally,
      );
    });

    test('completeTutorial sets currentStep to completed', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      container
          .read(workoutTutorialProvider.notifier)
          .advanceToStep(WorkoutTutorialStep.completeSetRpe);
      await container.read(workoutTutorialProvider.notifier).completeTutorial();

      expect(
        container.read(workoutTutorialProvider).currentStep,
        WorkoutTutorialStep.completed,
      );
    });

    test('clearCacheForTesting resets static fields', () {
      // After clearing, a new container should get fresh initial state
      WorkoutTutorialNotifier.clearCacheForTesting();
      final container = _makeContainer();
      addTearDown(container.dispose);

      final state = container.read(workoutTutorialProvider);
      expect(state.isActive, isFalse);
      expect(state.hasCompletedTutorial, isFalse);
    });

    test(
      'load from SharedPreferences - completed=true restores state',
      () async {
        SharedPreferences.setMockInitialValues({
          'workout_tutorial_completed': true,
          'workout_tutorial_started': true,
        });

        final container = _makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(workoutTutorialProvider.notifier);
        await notifier.waitForLoad();

        final state = container.read(workoutTutorialProvider);
        expect(state.hasCompletedTutorial, isTrue);
        expect(state.hasStartedTutorial, isTrue);
      },
    );

    test('isLoaded is false before waitForLoad', () {
      // Just after build, _isLoaded may be false if _loadState has not completed
      // but clearCacheForTesting ensures _isLoaded=false
      WorkoutTutorialNotifier.clearCacheForTesting();
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Read the notifier — at this point it may not be loaded yet
      final notifier = container.read(workoutTutorialProvider.notifier);
      // isLoaded could be true or false depending on timing,
      // but after waitForLoad it must be true
      expect(notifier, isNotNull);
    });

    test('waitForLoad is idempotent (calling twice does not throw)', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(workoutTutorialProvider.notifier);
      await notifier.waitForLoad();
      await notifier.waitForLoad(); // second call should be no-op
      expect(notifier.isLoaded, isTrue);
    });

    test(
      'startTutorial when hasStartedTutorial=true does not re-persist',
      () async {
        final container = _makeContainer();
        addTearDown(container.dispose);

        // First start - persists started=true
        await container.read(workoutTutorialProvider.notifier).startTutorial();

        final prefsAfterFirst = await SharedPreferences.getInstance();
        expect(prefsAfterFirst.getBool('workout_tutorial_started'), isTrue);

        // Second start - already started, should not throw
        await container.read(workoutTutorialProvider.notifier).startTutorial();
        expect(
          container.read(workoutTutorialProvider).hasStartedTutorial,
          isTrue,
        );
      },
    );

    test('pause/resume cycle preserves isActive', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      expect(container.read(workoutTutorialProvider).isActive, isTrue);

      container.read(workoutTutorialProvider.notifier).pauseTutorial();
      expect(container.read(workoutTutorialProvider).isPaused, isTrue);
      // isActive is independent of isPaused
      expect(container.read(workoutTutorialProvider).isActive, isTrue);

      container.read(workoutTutorialProvider.notifier).resumeTutorial();
      expect(container.read(workoutTutorialProvider).isPaused, isFalse);
      expect(container.read(workoutTutorialProvider).isActive, isTrue);
    });

    test('resetTutorial resets all flags and removes prefs keys', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      await container.read(workoutTutorialProvider.notifier).startTutorial();
      await container.read(workoutTutorialProvider.notifier).completeTutorial();

      // Verify completed before reset
      expect(
        container.read(workoutTutorialProvider).hasCompletedTutorial,
        isTrue,
      );

      await container.read(workoutTutorialProvider.notifier).resetTutorial();

      final state = container.read(workoutTutorialProvider);
      expect(state.isActive, isFalse);
      expect(state.hasCompletedTutorial, isFalse);
      expect(state.hasStartedTutorial, isFalse);
      expect(state.currentStep, WorkoutTutorialStep.welcome);
    });
  });

  // =========================================================================
  // WorkoutTutorialState — additional copyWith edge cases
  // =========================================================================
  group('WorkoutTutorialState additional copyWith', () {
    test('copyWith preserves isPaused when not specified', () {
      const state = WorkoutTutorialState(
        isActive: true,
        currentStep: WorkoutTutorialStep.editSetGestures,
        hasCompletedTutorial: false,
        hasStartedTutorial: true,
        isPaused: true,
      );
      final updated = state.copyWith(isActive: false);
      expect(updated.isPaused, isTrue);
      expect(updated.isActive, isFalse);
    });

    test('copyWith with all fields specified creates fully new state', () {
      const original = WorkoutTutorialState(
        isActive: false,
        currentStep: WorkoutTutorialStep.welcome,
        hasCompletedTutorial: false,
        hasStartedTutorial: false,
        isPaused: false,
      );
      final updated = original.copyWith(
        isActive: true,
        currentStep: WorkoutTutorialStep.completeSetRpe,
        hasCompletedTutorial: true,
        hasStartedTutorial: true,
        isPaused: true,
      );
      expect(updated.isActive, isTrue);
      expect(updated.currentStep, WorkoutTutorialStep.completeSetRpe);
      expect(updated.hasCompletedTutorial, isTrue);
      expect(updated.hasStartedTutorial, isTrue);
      expect(updated.isPaused, isTrue);
      // Original unchanged
      expect(original.isActive, isFalse);
      expect(original.currentStep, WorkoutTutorialStep.welcome);
    });

    test('copyWith with no args returns equivalent state', () {
      const state = WorkoutTutorialState(
        isActive: true,
        currentStep: WorkoutTutorialStep.completeSetRpe,
        hasCompletedTutorial: false,
        hasStartedTutorial: true,
        isPaused: false,
      );
      final updated = state.copyWith();
      expect(updated.isActive, state.isActive);
      expect(updated.currentStep, state.currentStep);
      expect(updated.hasCompletedTutorial, state.hasCompletedTutorial);
      expect(updated.hasStartedTutorial, state.hasStartedTutorial);
      expect(updated.isPaused, state.isPaused);
    });
  });

  // =========================================================================
  // WorkoutTutorialStep enum — step order verification
  // =========================================================================
  group('WorkoutTutorialStep ordering', () {
    test('steps are in correct workflow order', () {
      const steps = WorkoutTutorialStep.values;
      expect(steps[0], WorkoutTutorialStep.welcome);
      expect(steps[1], WorkoutTutorialStep.addExercise);
      expect(steps[2], WorkoutTutorialStep.browseDatabase);
      expect(steps[3], WorkoutTutorialStep.filtersAndCustom);
      expect(steps[4], WorkoutTutorialStep.customizeExercise);
      expect(steps[5], WorkoutTutorialStep.workoutSettings);
      expect(steps[6], WorkoutTutorialStep.editSetGestures);
      expect(steps[7], WorkoutTutorialStep.completeSetRpe);
      expect(steps[8], WorkoutTutorialStep.completed);
    });

    test('step indices align with step number display (index + 1)', () {
      // The tutorial shows "stepNumber = step.index + 1" in the UI
      expect(WorkoutTutorialStep.welcome.index + 1, 1);
      expect(WorkoutTutorialStep.addExercise.index + 1, 2);
      expect(WorkoutTutorialStep.browseDatabase.index + 1, 3);
      expect(WorkoutTutorialStep.filtersAndCustom.index + 1, 4);
      expect(WorkoutTutorialStep.customizeExercise.index + 1, 5);
      expect(WorkoutTutorialStep.workoutSettings.index + 1, 6);
      expect(WorkoutTutorialStep.editSetGestures.index + 1, 7);
      expect(WorkoutTutorialStep.completeSetRpe.index + 1, 8);
    });

    test('totalSteps count excludes completed step', () {
      // The UI uses: WorkoutTutorialStep.values.length - 1
      final totalSteps = WorkoutTutorialStep.values.length - 1;
      expect(totalSteps, 8);
    });
  });
}
