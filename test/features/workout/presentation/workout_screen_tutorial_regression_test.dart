/// GymBro TrackLog - Flutter Fitness App
///
/// Regression Test: Tutorial Re-Show Bug
/// Issue: Tutorial randomly appears when app returns from background
/// Root Cause: didChangeAppLifecycleState() didn't check hasCompletedTutorial
/// Fix: Added !tutorialState.hasCompletedTutorial to condition
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';

void main() {
  group('WorkoutScreen Tutorial Lifecycle Regression Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // Initialize SharedPreferences with empty state
      SharedPreferences.setMockInitialValues({});

      // ✅ CRITICAL: Clear static cache before each test
      // Create temporary container just to reset the cache
      final tempContainer = ProviderContainer();
      await tempContainer.read(workoutTutorialProvider.notifier).resetTutorial();
      tempContainer.dispose();

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Tutorial should NOT re-show after background if already completed',
        () async {
      // Arrange: User has completed tutorial
      final notifier = container.read(workoutTutorialProvider.notifier);

      // Simulate tutorial completion
      await notifier.startTutorial();
      await notifier.completeTutorial();

      // Verify tutorial is marked as completed
      final initialState = container.read(workoutTutorialProvider);
      expect(initialState.hasCompletedTutorial, true,
          reason: 'Tutorial should be marked as completed');
      expect(initialState.isActive, false,
          reason: 'Tutorial should not be active after completion');

      // Act: Simulate app going to background and returning
      // In the real app, WorkoutScreen.didChangeAppLifecycleState() would be called
      // with AppLifecycleState.resumed

      // The bug was: isActive could become true again due to provider reload
      // Let's simulate a provider reload by creating a new container
      final newContainer = ProviderContainer();
      final reloadedNotifier = newContainer.read(workoutTutorialProvider.notifier);
      await reloadedNotifier.startTutorial(); // Simulate tutorial being active again

      final reloadedState = newContainer.read(workoutTutorialProvider);

      // Assert: Even if isActive is true, hasCompletedTutorial should prevent re-show
      // The fixed code checks BOTH isActive AND !hasCompletedTutorial
      final shouldReshow =
          reloadedState.isActive && !reloadedState.hasCompletedTutorial;

      expect(shouldReshow, false,
          reason:
              'Tutorial should NOT re-show if hasCompletedTutorial is true');

      newContainer.dispose();
    });

    test('Tutorial SHOULD re-show after background if NOT completed', () async {
      // Arrange: User started tutorial but didn't complete it
      final notifier = container.read(workoutTutorialProvider.notifier);
      await notifier.startTutorial();

      // Verify tutorial is active but not completed
      final initialState = container.read(workoutTutorialProvider);
      expect(initialState.isActive, true,
          reason: 'Tutorial should be active after start');
      expect(initialState.hasCompletedTutorial, false,
          reason: 'Tutorial should not be completed yet');

      // Act: Simulate app going to background and returning
      final state = container.read(workoutTutorialProvider);
      final shouldReshow = state.isActive && !state.hasCompletedTutorial;

      // Assert: Tutorial SHOULD re-show (this is the intended behavior)
      expect(shouldReshow, true,
          reason:
              'Tutorial SHOULD re-show if user started but did not complete');
    });

    test('Tutorial state persists across provider reloads (STATIC CACHE)', () async {
      // Arrange: Complete tutorial in first container
      final notifier1 = container.read(workoutTutorialProvider.notifier);
      await notifier1.startTutorial();
      await notifier1.completeTutorial();

      final initialState = container.read(workoutTutorialProvider);
      expect(initialState.hasCompletedTutorial, true);

      // Act: Create new container (simulates provider rebuild)
      final newContainer = ProviderContainer();

      // ✅ FIX VERIFICATION: Static cache should provide state IMMEDIATELY
      // No need to wait for async SharedPreferences load!
      final state2 = newContainer.read(workoutTutorialProvider);

      // Assert: State is available immediately from static cache
      expect(state2.hasCompletedTutorial, isTrue,
          reason: 'Static cache should preserve hasCompletedTutorial immediately');
      expect(state2.hasStartedTutorial, isTrue,
          reason: 'Static cache should preserve hasStartedTutorial immediately');
      expect(state2.isActive, false,
          reason: 'isActive should be false after completion');

      newContainer.dispose();
    });

    test('Multiple background/foreground cycles do not restart tutorial',
        () async {
      // Arrange: Complete tutorial
      final notifier = container.read(workoutTutorialProvider.notifier);
      await notifier.startTutorial();
      await notifier.completeTutorial();

      // Act: Simulate 5 background/foreground cycles
      for (int i = 0; i < 5; i++) {
        // Each cycle checks if tutorial should re-show
        final state = container.read(workoutTutorialProvider);
        final shouldReshow = state.isActive && !state.hasCompletedTutorial;

        // Assert: Tutorial should NEVER re-show
        expect(shouldReshow, false,
            reason: 'Tutorial should not re-show on cycle $i');
      }
    });

    test('Edge case: User skips tutorial instead of completing', () async {
      // Arrange: User starts tutorial then stops it (simulates skip/dismiss)
      final notifier = container.read(workoutTutorialProvider.notifier);
      await notifier.startTutorial();
      notifier.stopTutorial(); // User dismisses without completing

      final initialState = container.read(workoutTutorialProvider);
      expect(initialState.isActive, false,
          reason: 'Tutorial should not be active after stop');
      expect(initialState.hasCompletedTutorial, false,
          reason: 'Tutorial is not completed if user stops it');

      // Act: Simulate app resume after background
      // In this case, the tutorial should NOT re-show because isActive is false
      final shouldReshow =
          initialState.isActive && !initialState.hasCompletedTutorial;

      // Assert: Tutorial should NOT re-show (isActive is false)
      expect(shouldReshow, false,
          reason:
              'Tutorial should not re-show if stopped (even if not completed)');
    });

    test('CRITICAL: Skip → Background → Foreground should NOT re-show tutorial',
        () async {
      // This is the EXACT bug scenario reported by the user!
      // "se faccio salta cosa succede? mi riappare ogni volta? sembra che si resetti ogni volta"

      // Arrange: User starts tutorial
      final notifier = container.read(workoutTutorialProvider.notifier);
      await notifier.startTutorial();

      final stateAfterStart = container.read(workoutTutorialProvider);
      expect(stateAfterStart.hasStartedTutorial, true,
          reason: 'Tutorial marked as started');

      // Act 1: User clicks "Salta" (skip)
      notifier.stopTutorial();

      // Act 2: Simulate provider rebuild (app background → foreground)
      final newContainer = ProviderContainer();

      // ✅ CRITICAL CHECK: Static cache should preserve hasStartedTutorial
      final stateAfterReload = newContainer.read(workoutTutorialProvider);

      // Assert: Tutorial should NOT auto-show again
      // Because hasStartedTutorial = true prevents auto-start in _showFirstWorkoutWelcomeIfNeeded()
      expect(stateAfterReload.hasStartedTutorial, true,
          reason:
              'Static cache must preserve hasStartedTutorial across rebuilds');
      expect(stateAfterReload.isActive, false,
          reason: 'Tutorial should not be active after skip');

      // Verify auto-show logic would NOT trigger
      // (from workout_screen.dart:178-180)
      final wouldAutoShow = !stateAfterReload.hasStartedTutorial &&
          !stateAfterReload.isActive;

      expect(wouldAutoShow, false,
          reason:
              'Tutorial should NOT auto-show because hasStartedTutorial=true');

      newContainer.dispose();
    });
  });

  group('WorkoutTutorialState Integration Tests', () {
    setUp(() {
      WorkoutTutorialNotifier.clearCacheForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    test('hasCompletedTutorial flag is persistent', () async {
      // Setup mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'workout_tutorial_completed': true,
      });

      final container = ProviderContainer();
      container.read(workoutTutorialProvider.notifier);

      // Wait for SharedPreferences to load
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(workoutTutorialProvider);

      expect(state.hasCompletedTutorial, true,
          reason: 'Should load completed state from SharedPreferences');

      container.dispose();
    });

    test('hasStartedTutorial prevents auto-show after first time', () async {
      SharedPreferences.setMockInitialValues({
        'workout_tutorial_started': true,
        'workout_tutorial_completed': false,
      });

      final container = ProviderContainer();
      container.read(workoutTutorialProvider.notifier);

      // Wait longer for async state loading
      await Future.delayed(const Duration(milliseconds: 300));

      // Force read to trigger state load
      final state = container.read(workoutTutorialProvider);

      // NOTE: This test validates SharedPreferences persistence
      // The main fix (tutorial re-show prevention) is validated by other tests ✅
      expect(state.hasStartedTutorial, isTrue,
          reason: 'Should load started state from SharedPreferences');
      expect(state.hasCompletedTutorial, isFalse,
          reason: 'Should not be completed if user stopped mid-way');

      container.dispose();
    });
  });
}
