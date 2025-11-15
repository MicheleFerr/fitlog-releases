import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/user_goal.dart';

void main() {
  group('UserGoal', () {
    test('should create UserGoal with valid values', () {
      // Arrange & Act
      const goal = UserGoal(
        goalType: GoalType.buildMuscle,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      // Assert
      expect(goal.goalType, GoalType.buildMuscle);
      expect(goal.weeklyWorkoutTarget, 4);
      expect(goal.experienceLevel, ExperienceLevel.intermediate);
    });

    test('should support all goal types', () {
      // Assert
      expect(GoalType.values.length, greaterThanOrEqualTo(3));
      expect(GoalType.values, contains(GoalType.buildMuscle));
      expect(GoalType.values, contains(GoalType.loseWeight));
      expect(GoalType.values, contains(GoalType.getStronger));
    });

    test('should support all experience levels', () {
      // Assert
      expect(ExperienceLevel.values.length, greaterThanOrEqualTo(3));
      expect(ExperienceLevel.values, contains(ExperienceLevel.beginner));
      expect(ExperienceLevel.values, contains(ExperienceLevel.intermediate));
      expect(ExperienceLevel.values, contains(ExperienceLevel.advanced));
    });

    test('should be immutable (Freezed)', () {
      // Arrange
      const goal = UserGoal(
        goalType: GoalType.buildMuscle,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      // Act - Try to create modified copy
      final modified = goal.copyWith(weeklyWorkoutTarget: 5);

      // Assert - Original unchanged, new instance created
      expect(goal.weeklyWorkoutTarget, 4);
      expect(modified.weeklyWorkoutTarget, 5);
      expect(modified.goalType, goal.goalType);
    });

    test('should support equality comparison', () {
      // Arrange
      const goal1 = UserGoal(
        goalType: GoalType.buildMuscle,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      const goal2 = UserGoal(
        goalType: GoalType.buildMuscle,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      const goal3 = UserGoal(
        goalType: GoalType.loseWeight,
        weeklyWorkoutTarget: 4,
        experienceLevel: ExperienceLevel.intermediate,
      );

      // Assert
      expect(goal1, equals(goal2)); // Same values
      expect(goal1, isNot(equals(goal3))); // Different goalType
    });
  });
}
