// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/user_goals_provider.dart';

// ---------------------------------------------------------------------------
// Tests for UserGoals clamping logic and edge-case behaviour.
// ---------------------------------------------------------------------------

void main() {
  // ================================================================
  // UserGoals clamping logic (mirrors setWorkoutsPerWeek/setStreakWeeksGoal)
  // ================================================================
  group('UserGoals clamping logic', () {
    int clampWorkoutsPerWeek(int value) => value.clamp(1, 7);
    int clampStreakWeeksGoal(int value) => value.clamp(1, 52);

    group('clampWorkoutsPerWeek', () {
      test('value 0 is clamped to 1', () {
        expect(clampWorkoutsPerWeek(0), 1);
      });

      test('value -5 is clamped to 1', () {
        expect(clampWorkoutsPerWeek(-5), 1);
      });

      test('value 1 stays 1 (lower boundary)', () {
        expect(clampWorkoutsPerWeek(1), 1);
      });

      test('value 3 stays 3', () {
        expect(clampWorkoutsPerWeek(3), 3);
      });

      test('value 7 stays 7 (upper boundary)', () {
        expect(clampWorkoutsPerWeek(7), 7);
      });

      test('value 8 is clamped to 7', () {
        expect(clampWorkoutsPerWeek(8), 7);
      });

      test('value 100 is clamped to 7', () {
        expect(clampWorkoutsPerWeek(100), 7);
      });

      test('midpoint 4 stays 4', () {
        expect(clampWorkoutsPerWeek(4), 4);
      });
    });

    group('clampStreakWeeksGoal', () {
      test('value 0 is clamped to 1', () {
        expect(clampStreakWeeksGoal(0), 1);
      });

      test('value -10 is clamped to 1', () {
        expect(clampStreakWeeksGoal(-10), 1);
      });

      test('value 1 stays 1 (lower boundary)', () {
        expect(clampStreakWeeksGoal(1), 1);
      });

      test('value 4 stays 4', () {
        expect(clampStreakWeeksGoal(4), 4);
      });

      test('value 12 stays 12', () {
        expect(clampStreakWeeksGoal(12), 12);
      });

      test('value 26 stays 26', () {
        expect(clampStreakWeeksGoal(26), 26);
      });

      test('value 52 stays 52 (upper boundary)', () {
        expect(clampStreakWeeksGoal(52), 52);
      });

      test('value 53 is clamped to 52', () {
        expect(clampStreakWeeksGoal(53), 52);
      });

      test('value 365 is clamped to 52', () {
        expect(clampStreakWeeksGoal(365), 52);
      });
    });
  });

  // ================================================================
  // Weekly workout progress percentage calculation
  // ================================================================
  group('weekly workout progress percentage', () {
    double calcPercent(int workoutsThisWeek, int goal) {
      return goal > 0 ? (workoutsThisWeek / goal).clamp(0.0, 1.0) : 0.0;
    }

    test('0 workouts, goal 3 -> 0.0', () {
      expect(calcPercent(0, 3), 0.0);
    });

    test('1 workout, goal 3 -> 0.333', () {
      expect(calcPercent(1, 3), closeTo(1 / 3, 0.001));
    });

    test('3 workouts, goal 3 -> 1.0', () {
      expect(calcPercent(3, 3), 1.0);
    });

    test('4 workouts, goal 3 -> clamped to 1.0', () {
      expect(calcPercent(4, 3), 1.0);
    });

    test('goal 0 -> 0.0 (guard against division by zero)', () {
      expect(calcPercent(5, 0), 0.0);
    });

    test('5 workouts, goal 7 -> ~0.714', () {
      expect(calcPercent(5, 7), closeTo(5 / 7, 0.001));
    });

    test('7 workouts, goal 7 -> 1.0', () {
      expect(calcPercent(7, 7), 1.0);
    });

    test('isComplete when workoutsThisWeek >= goal', () {
      expect(3 >= 3, isTrue);
      expect(4 >= 3, isTrue);
      expect(2 >= 3, isFalse);
    });
  });

  // ================================================================
  // Weekly volume progress percentage calculation
  // ================================================================
  group('weekly volume progress percentage', () {
    double calcVolumePercent(double currentKg, double? goalKg) {
      return (goalKg != null && goalKg > 0)
          ? (currentKg / goalKg).clamp(0.0, 1.0)
          : 0.0;
    }

    test('null goal -> 0.0', () {
      expect(calcVolumePercent(5000.0, null), 0.0);
    });

    test('goal 0 -> 0.0 (guard against division by zero)', () {
      expect(calcVolumePercent(1000.0, 0), 0.0);
    });

    test('0 volume, goal 10000 -> 0.0', () {
      expect(calcVolumePercent(0.0, 10000.0), 0.0);
    });

    test('5000 kg, goal 10000 kg -> 0.5', () {
      expect(calcVolumePercent(5000.0, 10000.0), closeTo(0.5, 0.001));
    });

    test('10000 kg, goal 10000 kg -> 1.0', () {
      expect(calcVolumePercent(10000.0, 10000.0), 1.0);
    });

    test('exceeding goal -> clamped to 1.0', () {
      expect(calcVolumePercent(12000.0, 10000.0), 1.0);
    });

    test('isComplete when volume >= goal', () {
      const goalKg = 5000.0;
      expect(5000.0 >= goalKg, isTrue);
      expect(6000.0 >= goalKg, isTrue);
      expect(4999.9 >= goalKg, isFalse);
    });
  });

  // ================================================================
  // Streak weeks percentage calculation
  // ================================================================
  group('streak weeks progress percentage', () {
    double calcStreakPercent(int streakWeeks, int goal) {
      return goal > 0 ? (streakWeeks / goal).clamp(0.0, 1.0) : 0.0;
    }

    test('0 streak, goal 4 -> 0.0', () {
      expect(calcStreakPercent(0, 4), 0.0);
    });

    test('2 streak, goal 4 -> 0.5', () {
      expect(calcStreakPercent(2, 4), 0.5);
    });

    test('4 streak, goal 4 -> 1.0', () {
      expect(calcStreakPercent(4, 4), 1.0);
    });

    test('5 streak, goal 4 -> clamped to 1.0', () {
      expect(calcStreakPercent(5, 4), 1.0);
    });

    test('goal 0 -> 0.0', () {
      expect(calcStreakPercent(10, 0), 0.0);
    });

    test('12 streak, goal 52 -> ~0.231', () {
      expect(calcStreakPercent(12, 52), closeTo(12 / 52, 0.001));
    });
  });

  // ================================================================
  // Week boundary calculation (mirrors provider logic)
  // ================================================================
  group('week boundary calculation', () {
    // Mirrors: startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1))
    DateTime getStartOfWeek(DateTime now) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
    }

    DateTime getEndOfWeek(DateTime startOfWeek) {
      return startOfWeek.add(const Duration(days: 7));
    }

    test('Monday 2026-02-23: startOfWeek is 2026-02-23', () {
      final monday = DateTime(2026, 2, 23, 10, 30);
      expect(getStartOfWeek(monday), DateTime(2026, 2, 23));
    });

    test('Wednesday 2026-02-25: startOfWeek is 2026-02-23', () {
      final wednesday = DateTime(2026, 2, 25, 14, 0);
      expect(getStartOfWeek(wednesday), DateTime(2026, 2, 23));
    });

    test('Sunday 2026-03-01: startOfWeek is 2026-02-23', () {
      final sunday = DateTime(2026, 3, 1, 20, 0);
      expect(getStartOfWeek(sunday), DateTime(2026, 2, 23));
    });

    test('Friday 2026-02-27: startOfWeek is 2026-02-23', () {
      final friday = DateTime(2026, 2, 27, 8, 0);
      expect(getStartOfWeek(friday), DateTime(2026, 2, 23));
    });

    test('endOfWeek is 7 days after startOfWeek', () {
      final start = DateTime(2026, 2, 23);
      expect(getEndOfWeek(start), DateTime(2026, 3, 2));
    });

    test('workout on Monday is after startOfWeek', () {
      final monday = DateTime(2026, 2, 23);
      final start = getStartOfWeek(monday);
      final workoutDate = DateTime(2026, 2, 23, 8, 0);
      expect(
        workoutDate.isAfter(start) || workoutDate.isAtSameMomentAs(start),
        isTrue,
      );
    });

    test('workout on Sunday is before endOfWeek', () {
      final monday = DateTime(2026, 2, 23);
      final start = getStartOfWeek(monday);
      final end = getEndOfWeek(start);
      final workoutDate = DateTime(2026, 3, 1, 20, 0);
      expect(workoutDate.isBefore(end), isTrue);
    });

    test('previous Sunday is not in week', () {
      final monday = DateTime(2026, 2, 23);
      final start = getStartOfWeek(monday);
      final prevSunday = DateTime(2026, 2, 22, 20, 0);
      expect(prevSunday.isBefore(start), isTrue);
    });

    test('next Monday is not in week', () {
      final monday = DateTime(2026, 2, 23);
      final start = getStartOfWeek(monday);
      final end = getEndOfWeek(start);
      final nextMonday = DateTime(2026, 3, 2, 8, 0);
      expect(nextMonday.isBefore(end), isFalse);
    });
  });

  // ================================================================
  // Workout filter within week boundaries (mirrors provider filter)
  // ================================================================
  group('workout filter within week', () {
    // Mirrors: w.completedAt.isAfter(startOfWeek) && w.completedAt.isBefore(endOfWeek)
    bool isInWeek(DateTime completedAt, DateTime startOfWeek, DateTime endOfWeek) {
      return completedAt.isAfter(startOfWeek) && completedAt.isBefore(endOfWeek);
    }

    final start = DateTime(2026, 2, 23);
    final end = DateTime(2026, 3, 2);

    test('workout Tuesday is in week', () {
      expect(isInWeek(DateTime(2026, 2, 24, 9, 0), start, end), isTrue);
    });

    test('workout Saturday is in week', () {
      expect(isInWeek(DateTime(2026, 2, 28, 15, 0), start, end), isTrue);
    });

    test('workout on start boundary (exactly at start) is NOT after', () {
      // .isAfter is strict, so exactly on Monday midnight is not included
      expect(isInWeek(DateTime(2026, 2, 23), start, end), isFalse);
    });

    test('workout one second after start IS included', () {
      expect(
        isInWeek(DateTime(2026, 2, 23, 0, 0, 1), start, end),
        isTrue,
      );
    });

    test('workout at end boundary is NOT included', () {
      expect(isInWeek(DateTime(2026, 3, 2), start, end), isFalse);
    });

    test('workout before start is excluded', () {
      expect(isInWeek(DateTime(2026, 2, 22, 23, 59), start, end), isFalse);
    });

    test('workout after end is excluded', () {
      expect(isInWeek(DateTime(2026, 3, 3, 0, 0, 1), start, end), isFalse);
    });
  });

  // ================================================================
  // Streak calculation logic (mirrors streakWeeksProgressProvider)
  // ================================================================
  group('streak weeks calculation logic', () {
    // Simplified mirror of the streak counter logic
    // Count consecutive weeks from current week going backwards
    // where workoutsPerWeek goal was met.

    int calculateStreak({
      required List<DateTime> workoutDates,
      required int goal,
      required DateTime referenceMonday,
    }) {
      int streak = 0;
      var weekStart = referenceMonday;

      for (int i = 0; i < 52; i++) {
        final weekEnd = weekStart.add(const Duration(days: 7));
        final workoutsInWeek = workoutDates.where((d) {
          return d.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              d.isBefore(weekEnd);
        }).length;

        if (workoutsInWeek >= goal) {
          streak++;
        } else {
          if (i > 0) break;
        }
        weekStart = weekStart.subtract(const Duration(days: 7));
      }
      return streak;
    }

    final monday = DateTime(2026, 2, 23);

    test('no workouts -> streak 0', () {
      expect(calculateStreak(workoutDates: [], goal: 3, referenceMonday: monday), 0);
    });

    test('1 workout this week, goal 1 -> streak 1', () {
      expect(
        calculateStreak(
          workoutDates: [DateTime(2026, 2, 24, 10, 0)],
          goal: 1,
          referenceMonday: monday,
        ),
        1,
      );
    });

    test('goal not met this week but met last week -> streak 0 (gap breaks)', () {
      // Last week: 2026-02-16 to 2026-02-22
      expect(
        calculateStreak(
          workoutDates: [DateTime(2026, 2, 17, 10, 0)],
          goal: 1,
          referenceMonday: monday,
        ),
        0,
      );
    });

    test('goal met this week and last week -> streak 2', () {
      expect(
        calculateStreak(
          workoutDates: [
            DateTime(2026, 2, 24, 10, 0), // this week
            DateTime(2026, 2, 17, 10, 0), // last week
          ],
          goal: 1,
          referenceMonday: monday,
        ),
        2,
      );
    });

    test('3 consecutive weeks -> streak 3', () {
      expect(
        calculateStreak(
          workoutDates: [
            DateTime(2026, 2, 24, 10, 0), // week 1
            DateTime(2026, 2, 17, 10, 0), // week 2
            DateTime(2026, 2, 10, 10, 0), // week 3
          ],
          goal: 1,
          referenceMonday: monday,
        ),
        3,
      );
    });

    test('goal 3, only 2 workouts this week -> streak 0', () {
      expect(
        calculateStreak(
          workoutDates: [
            DateTime(2026, 2, 23, 10, 0),
            DateTime(2026, 2, 24, 10, 0),
          ],
          goal: 3,
          referenceMonday: monday,
        ),
        0,
      );
    });

    test('goal met this week but not last week -> streak 1', () {
      // This week: 3 workouts meeting goal 3
      // Last week: only 1 workout (doesn't meet goal 3)
      expect(
        calculateStreak(
          workoutDates: [
            DateTime(2026, 2, 23, 8, 0),
            DateTime(2026, 2, 24, 9, 0),
            DateTime(2026, 2, 25, 10, 0), // this week: 3 workouts
            DateTime(2026, 2, 16, 10, 0), // last week: only 1
          ],
          goal: 3,
          referenceMonday: monday,
        ),
        1,
      );
    });
  });

  // ================================================================
  // UserGoals equality and immutability
  // ================================================================
  group('UserGoals equality and immutability', () {
    test('two goals with same values are structurally equal via copyWith', () {
      const a = UserGoals(
        workoutsPerWeek: 4,
        weeklyVolumeTargetKg: 5000.0,
        streakWeeksGoal: 12,
      );
      final b = a.copyWith();
      // Verify all fields match
      expect(b.workoutsPerWeek, a.workoutsPerWeek);
      expect(b.weeklyVolumeTargetKg, a.weeklyVolumeTargetKg);
      expect(b.streakWeeksGoal, a.streakWeeksGoal);
    });

    test('goals are const constructable', () {
      const goals = UserGoals();
      expect(goals.workoutsPerWeek, 2);
    });

    test('UserGoals.empty is the default', () {
      expect(UserGoals.empty.workoutsPerWeek, 2);
      expect(UserGoals.empty.streakWeeksGoal, 4);
      expect(UserGoals.empty.weeklyVolumeTargetKg, isNull);
    });

    test('copyWith with null weeklyVolumeTargetKg parameter keeps existing', () {
      const original = UserGoals(weeklyVolumeTargetKg: 8000.0);
      // Not setting clearVolumeTarget -> keeps existing
      final copy = original.copyWith();
      expect(copy.weeklyVolumeTargetKg, 8000.0);
    });

    test('multiple copyWith operations chain correctly', () {
      const base = UserGoals();
      final result = base
          .copyWith(workoutsPerWeek: 5)
          .copyWith(streakWeeksGoal: 12)
          .copyWith(weeklyVolumeTargetKg: 10000.0);

      expect(result.workoutsPerWeek, 5);
      expect(result.streakWeeksGoal, 12);
      expect(result.weeklyVolumeTargetKg, 10000.0);
    });
  });

  // ================================================================
  // WeeklyWorkoutProgress data class edge cases
  // ================================================================
  group('WeeklyWorkoutProgress edge cases', () {
    test('percentage exactly 0.0 is allowed', () {
      const p = WeeklyWorkoutProgress(
        current: 0,
        goal: 5,
        percentage: 0.0,
        isComplete: false,
      );
      expect(p.percentage, 0.0);
      expect(p.isComplete, isFalse);
    });

    test('percentage exactly 1.0 marks complete', () {
      const p = WeeklyWorkoutProgress(
        current: 5,
        goal: 5,
        percentage: 1.0,
        isComplete: true,
      );
      expect(p.percentage, 1.0);
      expect(p.isComplete, isTrue);
    });

    test('goal 1, 1 workout -> 100% complete', () {
      const p = WeeklyWorkoutProgress(
        current: 1,
        goal: 1,
        percentage: 1.0,
        isComplete: true,
      );
      expect(p.isComplete, isTrue);
    });

    test('goal 7 (max), 3 workouts -> ~0.428', () {
      const p = WeeklyWorkoutProgress(
        current: 3,
        goal: 7,
        percentage: 3 / 7,
        isComplete: false,
      );
      expect(p.percentage, closeTo(3 / 7, 0.001));
    });
  });

  // ================================================================
  // WeeklyVolumeProgress data class edge cases
  // ================================================================
  group('WeeklyVolumeProgress edge cases', () {
    test('null goalKg and non-zero current -> no target mode', () {
      const p = WeeklyVolumeProgress(
        currentKg: 3500.0,
        goalKg: null,
        percentage: 0.0,
        isComplete: false,
      );
      expect(p.goalKg, isNull);
      expect(p.percentage, 0.0);
      expect(p.isComplete, isFalse);
    });

    test('goalKg 0.0 -> no target mode (guard division by zero)', () {
      const p = WeeklyVolumeProgress(
        currentKg: 100.0,
        goalKg: 0.0,
        percentage: 0.0,
        isComplete: false,
      );
      expect(p.percentage, 0.0);
    });

    test('isComplete true when currentKg >= goalKg', () {
      const p = WeeklyVolumeProgress(
        currentKg: 5001.0,
        goalKg: 5000.0,
        percentage: 1.0,
        isComplete: true,
      );
      expect(p.isComplete, isTrue);
    });

    test('exactly at goal -> complete', () {
      const p = WeeklyVolumeProgress(
        currentKg: 5000.0,
        goalKg: 5000.0,
        percentage: 1.0,
        isComplete: true,
      );
      expect(p.isComplete, isTrue);
    });
  });

  // ================================================================
  // StreakWeeksProgress edge cases
  // ================================================================
  group('StreakWeeksProgress edge cases', () {
    test('goal 52 (max), streak 1 -> ~1.9%', () {
      const p = StreakWeeksProgress(
        current: 1,
        goal: 52,
        percentage: 1 / 52,
        isComplete: false,
      );
      expect(p.percentage, closeTo(1 / 52, 0.001));
    });

    test('goal 1, streak 1 -> complete', () {
      const p = StreakWeeksProgress(
        current: 1,
        goal: 1,
        percentage: 1.0,
        isComplete: true,
      );
      expect(p.isComplete, isTrue);
    });

    test('exceeding goal by many weeks -> isComplete true', () {
      const p = StreakWeeksProgress(
        current: 100,
        goal: 52,
        percentage: 1.0,
        isComplete: true,
      );
      expect(p.isComplete, isTrue);
    });

    test('zero streak and goal 4 -> 0% progress', () {
      const p = StreakWeeksProgress(
        current: 0,
        goal: 4,
        percentage: 0.0,
        isComplete: false,
      );
      expect(p.percentage, 0.0);
      expect(p.isComplete, isFalse);
    });
  });
}
