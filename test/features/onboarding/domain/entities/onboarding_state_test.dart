import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/user_goal.dart';

void main() {
  group('OnboardingState', () {
    test('should create initial state', () {
      // Arrange & Act
      final state = OnboardingState.initial();

      // Assert
      expect(state.currentStep, OnboardingStep.welcome);
      expect(state.isCompleted, false);
      expect(state.userGoal, isNull);
    });

    test('should create completed state with user goal', () {
      // Arrange
      const goal = UserGoal(
        goalType: GoalType.buildMuscle,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      // Act
      const state = OnboardingState(
        currentStep: OnboardingStep.completed,
        isCompleted: true,
        userGoal: goal,
      );

      // Assert
      expect(state.currentStep, OnboardingStep.completed);
      expect(state.isCompleted, true);
      expect(state.userGoal, goal);
    });

    test('should support all onboarding steps', () {
      // Assert
      expect(OnboardingStep.values.length, greaterThanOrEqualTo(4));
      expect(OnboardingStep.values, contains(OnboardingStep.welcome));
      expect(OnboardingStep.values, contains(OnboardingStep.goalSelection));
      expect(OnboardingStep.values, contains(OnboardingStep.weeklyGoal));
      expect(OnboardingStep.values, contains(OnboardingStep.completed));
    });

    test('should be immutable (Freezed)', () {
      // Arrange
      final state = OnboardingState.initial();

      // Act
      final modified = state.copyWith(
        currentStep: OnboardingStep.goalSelection,
      );

      // Assert
      expect(state.currentStep, OnboardingStep.welcome);
      expect(modified.currentStep, OnboardingStep.goalSelection);
    });

    test('should support equality comparison', () {
      // Arrange
      final state1 = OnboardingState.initial();
      final state2 = OnboardingState.initial();

      const state3 = OnboardingState(
        currentStep: OnboardingStep.goalSelection,
        isCompleted: false,
        userGoal: null,
      );

      // Assert
      expect(state1, equals(state2)); // Same initial state
      expect(state1, isNot(equals(state3))); // Different step
    });

    test('should track completion progress', () {
      // Arrange
      const goal = UserGoal(
        goalType: GoalType.buildMuscle,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      // Act
      const incomplete = OnboardingState(
        currentStep: OnboardingStep.goalSelection,
        isCompleted: false,
        userGoal: null,
      );

      const complete = OnboardingState(
        currentStep: OnboardingStep.completed,
        isCompleted: true,
        userGoal: goal,
      );

      // Assert
      expect(incomplete.isCompleted, false);
      expect(incomplete.userGoal, isNull);
      expect(complete.isCompleted, true);
      expect(complete.userGoal, isNotNull);
    });
  });
}
