import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/workout_tutorial_service.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/timer_tour_service.dart';

void main() {
  group('Onboarding System Smoke Tests', () {
    test('WorkoutTutorialState value object behavior', () {
      // Test state construction and copyWith
      const initialState = WorkoutTutorialState(
        isActive: false,
        currentStep: WorkoutTutorialStep.addExercise,
        hasCompletedTutorial: false,
        hasStartedTutorial: false,
        isPaused: false,
      );

      expect(initialState.isActive, isFalse);
      expect(initialState.currentStep, equals(WorkoutTutorialStep.addExercise));
      expect(initialState.isPaused, isFalse);
    });

    test('WorkoutTutorialState copyWith functionality', () {
      const state = WorkoutTutorialState(
        isActive: false,
        currentStep: WorkoutTutorialStep.addExercise,
        hasCompletedTutorial: false,
        hasStartedTutorial: false,
        isPaused: false,
      );

      // Test state transitions via copyWith
      final activeState = state.copyWith(isActive: true, hasStartedTutorial: true);
      expect(activeState.isActive, isTrue);
      expect(activeState.hasStartedTutorial, isTrue);

      // Test pause state
      final pausedState = activeState.copyWith(isPaused: true);
      expect(pausedState.isPaused, isTrue);
      expect(pausedState.isActive, isTrue);

      // Test resume state
      final resumedState = pausedState.copyWith(isPaused: false);
      expect(resumedState.isPaused, isFalse);
      expect(resumedState.isActive, isTrue);
    });

    test('WorkoutTutorialState step transitions', () {
      const state = WorkoutTutorialState(
        isActive: true,
        currentStep: WorkoutTutorialStep.addExercise,
        hasCompletedTutorial: false,
        hasStartedTutorial: true,
        isPaused: false,
      );

      // Advance to next step
      final nextState = state.copyWith(
        currentStep: WorkoutTutorialStep.tapSet,
      );

      expect(nextState.currentStep, equals(WorkoutTutorialStep.tapSet));
      expect(nextState.isActive, isTrue);
    });

    test('WorkoutTutorialStep enum values exist', () {
      // Verify all expected steps exist
      expect(WorkoutTutorialStep.addExercise, isNotNull);
      expect(WorkoutTutorialStep.tapSet, isNotNull);
      expect(WorkoutTutorialStep.exerciseMenu, isNotNull);
      expect(WorkoutTutorialStep.reorder, isNotNull);
      expect(WorkoutTutorialStep.settings, isNotNull);
      expect(WorkoutTutorialStep.finish, isNotNull);
      expect(WorkoutTutorialStep.completed, isNotNull);
    });

    test('Riverpod providers compile without errors', () {
      // This test verifies that all provider definitions are syntactically valid
      // We access them via the provider reference to ensure they compile
      expect(workoutTutorialProvider, isNotNull);
      expect(workoutTutorialCompletedProvider, isNotNull);
    });
  });
}
