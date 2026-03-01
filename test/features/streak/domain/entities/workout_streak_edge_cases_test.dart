import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';

void main() {
  group('WorkoutStreak - additional edge cases', () {
    group('direct constructor', () {
      test('creates instance with all required fields', () {
        final date = DateTime(2025, 3, 1);
        final streak = WorkoutStreak(
          currentStreak: 5,
          longestStreak: 12,
          isActive: true,
          lastWorkoutDate: date,
          totalWorkoutDays: 30,
        );

        expect(streak.currentStreak, 5);
        expect(streak.longestStreak, 12);
        expect(streak.isActive, true);
        expect(streak.lastWorkoutDate, date);
        expect(streak.totalWorkoutDays, 30);
      });

      test('copyWith creates new instance with updated fields', () {
        const original = WorkoutStreak(
          currentStreak: 3,
          longestStreak: 10,
          isActive: true,
          lastWorkoutDate: null,
          totalWorkoutDays: 20,
        );
        final updated = original.copyWith(currentStreak: 4, isActive: false);

        expect(updated.currentStreak, 4);
        expect(updated.isActive, false);
        expect(updated.longestStreak, 10); // unchanged
        expect(updated.totalWorkoutDays, 20); // unchanged
      });
    });

    group('fromWorkoutDates - streak continuation via yesterday', () {
      test('includes yesterday workout in current streak', () {
        final referenceDate = DateTime(2025, 6, 15);
        final workoutDates = [
          DateTime(2025, 6, 13),
          DateTime(2025, 6, 14), // yesterday
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        // Yesterday workout keeps streak alive (count from yesterday)
        expect(streak.currentStreak, 2);
        expect(streak.isActive, false); // not today but yesterday
      });

      test('streak of 1 when only today', () {
        final referenceDate = DateTime(2025, 6, 15);
        final workoutDates = [DateTime(2025, 6, 15)];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.currentStreak, 1);
        expect(streak.isActive, true);
        expect(streak.totalWorkoutDays, 1);
      });

      test('streak of 1 when only yesterday', () {
        final referenceDate = DateTime(2025, 6, 15);
        final workoutDates = [DateTime(2025, 6, 14)];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.currentStreak, 1);
      });
    });

    group('fromWorkoutDates - duplicate dates', () {
      test('deduplicates workouts on the same day', () {
        final referenceDate = DateTime(2025, 6, 15);
        // Two workouts on the same day (morning + evening)
        final workoutDates = [
          DateTime(2025, 6, 14, 8, 0),
          DateTime(2025, 6, 14, 18, 0),
          DateTime(2025, 6, 15, 9, 0),
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        // Should count as 2 unique days, not 3 workouts
        expect(streak.totalWorkoutDays, 2);
        expect(streak.currentStreak, 2);
      });
    });

    group('fromWorkoutDates - lastWorkoutDate', () {
      test('sets lastWorkoutDate to most recent workout date', () {
        final referenceDate = DateTime(2025, 6, 15);
        final workoutDates = [
          DateTime(2025, 6, 10),
          DateTime(2025, 6, 14),
          DateTime(2025, 6, 12),
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        // lastWorkoutDate should be Jun 14 (most recent, date-only)
        expect(streak.lastWorkoutDate, DateTime(2025, 6, 14));
      });
    });

    group('fromWorkoutDates - isActive', () {
      test('isActive is true when last workout was today', () {
        final referenceDate = DateTime(2025, 6, 15, 20, 0);
        final workoutDates = [
          DateTime(2025, 6, 13),
          DateTime(2025, 6, 14),
          DateTime(2025, 6, 15, 9, 0), // today
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.isActive, true);
      });

      test('isActive is false when last workout was 2+ days ago', () {
        final referenceDate = DateTime(2025, 6, 15);
        final workoutDates = [
          DateTime(2025, 6, 10),
          DateTime(2025, 6, 11),
          DateTime(2025, 6, 12),
          DateTime(2025, 6, 13), // 2 days ago
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.isActive, false);
        expect(streak.currentStreak, 0);
      });
    });

    group('fromWorkoutDates - longestStreak calculation', () {
      test('single workout has longestStreak of 1', () {
        final referenceDate = DateTime(2025, 6, 15);
        final workoutDates = [DateTime(2025, 6, 1)];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.longestStreak, 1);
      });

      test('correctly identifies longer gap streak as longest', () {
        final referenceDate = DateTime(2025, 6, 20);
        // First run: 2 days (Jun 10-11)
        // Second run: 5 days (Jun 14-18) - should be longest
        final workoutDates = [
          DateTime(2025, 6, 10),
          DateTime(2025, 6, 11),
          DateTime(2025, 6, 14),
          DateTime(2025, 6, 15),
          DateTime(2025, 6, 16),
          DateTime(2025, 6, 17),
          DateTime(2025, 6, 18),
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.longestStreak, 5);
      });

      test('non-consecutive workouts each have longestStreak of 1', () {
        final referenceDate = DateTime(2025, 6, 10);
        // All workouts with 2-day gaps
        final workoutDates = [
          DateTime(2025, 6, 1),
          DateTime(2025, 6, 3),
          DateTime(2025, 6, 5),
        ];

        final streak = WorkoutStreak.fromWorkoutDates(
          workoutDates,
          referenceDate,
        );

        expect(streak.longestStreak, 1);
      });
    });

    group('fromWorkoutDates - equality', () {
      test('two equal WorkoutStreak instances are equal', () {
        const a = WorkoutStreak(
          currentStreak: 5,
          longestStreak: 10,
          isActive: true,
          lastWorkoutDate: null,
          totalWorkoutDays: 20,
        );
        const b = WorkoutStreak(
          currentStreak: 5,
          longestStreak: 10,
          isActive: true,
          lastWorkoutDate: null,
          totalWorkoutDays: 20,
        );
        expect(a, equals(b));
      });
    });
  });
}
