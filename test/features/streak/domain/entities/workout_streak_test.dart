import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';

void main() {
  group('WorkoutStreak', () {
    test('should calculate current streak correctly for consecutive days', () {
      final workoutDates = [
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 11),
        DateTime(2025, 1, 12),
        DateTime(2025, 1, 13),
        DateTime(2025, 1, 14),
      ];

      final streak = WorkoutStreak.fromWorkoutDates(workoutDates, DateTime(2025, 1, 14));

      expect(streak.currentStreak, 5);
      expect(streak.isActive, true);
    });

    test('should return 0 streak when no recent workouts', () {
      final workoutDates = [DateTime(2025, 1, 1)];

      final streak = WorkoutStreak.fromWorkoutDates(workoutDates, DateTime(2025, 1, 14));

      expect(streak.currentStreak, 0);
      expect(streak.isActive, false);
    });

    test('should calculate longest streak correctly', () {
      final workoutDates = [
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 2),
        DateTime(2025, 1, 3),
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 11),
        DateTime(2025, 1, 12),
        DateTime(2025, 1, 13),
        DateTime(2025, 1, 14),
      ];

      final streak = WorkoutStreak.fromWorkoutDates(workoutDates, DateTime(2025, 1, 14));

      expect(streak.longestStreak, 5);
    });

    test('should handle empty workout list', () {
      final streak = WorkoutStreak.fromWorkoutDates([], DateTime(2025, 1, 14));

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.isActive, false);
      expect(streak.totalWorkoutDays, 0);
    });

    test('should mark streak as inactive if last workout was not today or yesterday', () {
      final workoutDates = [
        DateTime(2025, 1, 10),
        DateTime(2025, 1, 11),
        DateTime(2025, 1, 12),
      ];

      final streak = WorkoutStreak.fromWorkoutDates(workoutDates, DateTime(2025, 1, 15));

      expect(streak.currentStreak, 0);
      expect(streak.isActive, false);
    });
  });
}
