import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/user_goals_provider.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // UserGoals Data Class
  // ═══════════════════════════════════════════════════════════════
  group('UserGoals', () {
    test('default constructor uses correct defaults', () {
      const goals = UserGoals();

      expect(goals.workoutsPerWeek, 2);
      expect(goals.weeklyVolumeTargetKg, isNull);
      expect(goals.streakWeeksGoal, 4);
    });

    test('empty static constant matches default constructor', () {
      expect(UserGoals.empty.workoutsPerWeek, 2);
      expect(UserGoals.empty.weeklyVolumeTargetKg, isNull);
      expect(UserGoals.empty.streakWeeksGoal, 4);
    });

    test('constructor with custom values', () {
      const goals = UserGoals(
        workoutsPerWeek: 5,
        weeklyVolumeTargetKg: 10000.0,
        streakWeeksGoal: 12,
      );

      expect(goals.workoutsPerWeek, 5);
      expect(goals.weeklyVolumeTargetKg, 10000.0);
      expect(goals.streakWeeksGoal, 12);
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        const original = UserGoals(
          workoutsPerWeek: 3,
          weeklyVolumeTargetKg: 5000.0,
          streakWeeksGoal: 8,
        );

        final copy = original.copyWith(
          workoutsPerWeek: 5,
          weeklyVolumeTargetKg: 8000.0,
          streakWeeksGoal: 16,
        );

        expect(copy.workoutsPerWeek, 5);
        expect(copy.weeklyVolumeTargetKg, 8000.0);
        expect(copy.streakWeeksGoal, 16);
      });

      test('preserves original values when no fields specified', () {
        const original = UserGoals(
          workoutsPerWeek: 4,
          weeklyVolumeTargetKg: 7500.0,
          streakWeeksGoal: 10,
        );

        final copy = original.copyWith();

        expect(copy.workoutsPerWeek, 4);
        expect(copy.weeklyVolumeTargetKg, 7500.0);
        expect(copy.streakWeeksGoal, 10);
      });

      test('updates only workoutsPerWeek', () {
        const original = UserGoals(
          workoutsPerWeek: 3,
          weeklyVolumeTargetKg: 5000.0,
          streakWeeksGoal: 8,
        );

        final copy = original.copyWith(workoutsPerWeek: 6);

        expect(copy.workoutsPerWeek, 6);
        expect(copy.weeklyVolumeTargetKg, 5000.0);
        expect(copy.streakWeeksGoal, 8);
      });

      test('updates only weeklyVolumeTargetKg', () {
        const original = UserGoals(workoutsPerWeek: 3, streakWeeksGoal: 8);

        final copy = original.copyWith(weeklyVolumeTargetKg: 12000.0);

        expect(copy.workoutsPerWeek, 3);
        expect(copy.weeklyVolumeTargetKg, 12000.0);
        expect(copy.streakWeeksGoal, 8);
      });

      test('updates only streakWeeksGoal', () {
        const original = UserGoals(
          workoutsPerWeek: 3,
          weeklyVolumeTargetKg: 5000.0,
          streakWeeksGoal: 8,
        );

        final copy = original.copyWith(streakWeeksGoal: 20);

        expect(copy.workoutsPerWeek, 3);
        expect(copy.weeklyVolumeTargetKg, 5000.0);
        expect(copy.streakWeeksGoal, 20);
      });

      test('clearVolumeTarget sets weeklyVolumeTargetKg to null', () {
        const original = UserGoals(
          workoutsPerWeek: 3,
          weeklyVolumeTargetKg: 5000.0,
          streakWeeksGoal: 8,
        );

        final copy = original.copyWith(clearVolumeTarget: true);

        expect(copy.workoutsPerWeek, 3);
        expect(copy.weeklyVolumeTargetKg, isNull);
        expect(copy.streakWeeksGoal, 8);
      });

      test('clearVolumeTarget takes precedence over weeklyVolumeTargetKg', () {
        const original = UserGoals(weeklyVolumeTargetKg: 5000.0);

        final copy = original.copyWith(
          clearVolumeTarget: true,
          weeklyVolumeTargetKg: 9999.0,
        );

        expect(copy.weeklyVolumeTargetKg, isNull);
      });

      test('clearVolumeTarget false preserves existing value', () {
        const original = UserGoals(weeklyVolumeTargetKg: 5000.0);

        final copy = original.copyWith(clearVolumeTarget: false);

        expect(copy.weeklyVolumeTargetKg, 5000.0);
      });

      test('does not mutate original', () {
        const original = UserGoals(
          workoutsPerWeek: 3,
          weeklyVolumeTargetKg: 5000.0,
          streakWeeksGoal: 8,
        );

        original.copyWith(
          workoutsPerWeek: 7,
          weeklyVolumeTargetKg: 20000.0,
          streakWeeksGoal: 52,
        );

        expect(original.workoutsPerWeek, 3);
        expect(original.weeklyVolumeTargetKg, 5000.0);
        expect(original.streakWeeksGoal, 8);
      });

      test('can set volume target on goals that had none', () {
        const original = UserGoals();

        final copy = original.copyWith(weeklyVolumeTargetKg: 3000.0);

        expect(copy.weeklyVolumeTargetKg, 3000.0);
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // WeeklyWorkoutProgress Data Class
  // ═══════════════════════════════════════════════════════════════
  group('WeeklyWorkoutProgress', () {
    test('stores all fields correctly', () {
      const progress = WeeklyWorkoutProgress(
        current: 3,
        goal: 5,
        percentage: 0.6,
        isComplete: false,
      );

      expect(progress.current, 3);
      expect(progress.goal, 5);
      expect(progress.percentage, 0.6);
      expect(progress.isComplete, false);
    });

    test('complete state', () {
      const progress = WeeklyWorkoutProgress(
        current: 5,
        goal: 5,
        percentage: 1.0,
        isComplete: true,
      );

      expect(progress.isComplete, true);
      expect(progress.percentage, 1.0);
    });

    test('zero progress', () {
      const progress = WeeklyWorkoutProgress(
        current: 0,
        goal: 4,
        percentage: 0.0,
        isComplete: false,
      );

      expect(progress.current, 0);
      expect(progress.percentage, 0.0);
      expect(progress.isComplete, false);
    });

    test('over-achieved state', () {
      const progress = WeeklyWorkoutProgress(
        current: 7,
        goal: 5,
        percentage: 1.0,
        isComplete: true,
      );

      expect(progress.current, 7);
      expect(progress.goal, 5);
      expect(progress.isComplete, true);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // WeeklyVolumeProgress Data Class
  // ═══════════════════════════════════════════════════════════════
  group('WeeklyVolumeProgress', () {
    test('stores all fields correctly', () {
      const progress = WeeklyVolumeProgress(
        currentKg: 3500.0,
        goalKg: 5000.0,
        percentage: 0.7,
        isComplete: false,
      );

      expect(progress.currentKg, 3500.0);
      expect(progress.goalKg, 5000.0);
      expect(progress.percentage, 0.7);
      expect(progress.isComplete, false);
    });

    test('null goal', () {
      const progress = WeeklyVolumeProgress(
        currentKg: 1500.0,
        goalKg: null,
        percentage: 0.0,
        isComplete: false,
      );

      expect(progress.goalKg, isNull);
      expect(progress.percentage, 0.0);
      expect(progress.isComplete, false);
    });

    test('complete state', () {
      const progress = WeeklyVolumeProgress(
        currentKg: 6000.0,
        goalKg: 5000.0,
        percentage: 1.0,
        isComplete: true,
      );

      expect(progress.isComplete, true);
    });

    test('zero volume', () {
      const progress = WeeklyVolumeProgress(
        currentKg: 0.0,
        goalKg: 10000.0,
        percentage: 0.0,
        isComplete: false,
      );

      expect(progress.currentKg, 0.0);
      expect(progress.percentage, 0.0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // StreakWeeksProgress Data Class
  // ═══════════════════════════════════════════════════════════════
  group('StreakWeeksProgress', () {
    test('stores all fields correctly', () {
      const progress = StreakWeeksProgress(
        current: 6,
        goal: 12,
        percentage: 0.5,
        isComplete: false,
      );

      expect(progress.current, 6);
      expect(progress.goal, 12);
      expect(progress.percentage, 0.5);
      expect(progress.isComplete, false);
    });

    test('complete state', () {
      const progress = StreakWeeksProgress(
        current: 12,
        goal: 12,
        percentage: 1.0,
        isComplete: true,
      );

      expect(progress.isComplete, true);
      expect(progress.percentage, 1.0);
    });

    test('zero streak', () {
      const progress = StreakWeeksProgress(
        current: 0,
        goal: 4,
        percentage: 0.0,
        isComplete: false,
      );

      expect(progress.current, 0);
      expect(progress.percentage, 0.0);
    });

    test('exceeded goal', () {
      const progress = StreakWeeksProgress(
        current: 20,
        goal: 12,
        percentage: 1.0,
        isComplete: true,
      );

      expect(progress.current, 20);
      expect(progress.goal, 12);
      expect(progress.isComplete, true);
    });
  });
}
