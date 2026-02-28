import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/aggregate_sets_by_session.dart';

void main() {
  // Helper to build ExerciseSetData
  ExerciseSetData buildSet({
    required DateTime date,
    double weight = 80.0,
    int reps = 10,
    int? rpe,
    double? volume,
    String workoutName = 'Test Workout',
  }) {
    return ExerciseSetData(
      date: date,
      weight: weight,
      reps: reps,
      rpe: rpe,
      volume: volume ?? weight * reps,
      workoutName: workoutName,
    );
  }

  group('aggregateSetsBySession - edge cases', () {
    test('returns empty list for empty input', () {
      final result = aggregateSetsBySession([]);
      expect(result, isEmpty);
    });

    test('returns single session for single set', () {
      final sets = [
        buildSet(date: DateTime(2025, 1, 15, 10, 30), weight: 80, reps: 8),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.length, equals(1));
      expect(result.first.maxWeight, equals(80.0));
      expect(result.first.setCount, equals(1));
    });
  });

  group('aggregateSetsBySession - grouping by day', () {
    test('groups multiple sets from same day into one session', () {
      // Three sets on same day at different times
      final sets = [
        buildSet(date: DateTime(2025, 1, 15, 9, 0), weight: 80, reps: 10),
        buildSet(date: DateTime(2025, 1, 15, 9, 5), weight: 85, reps: 8),
        buildSet(date: DateTime(2025, 1, 15, 9, 10), weight: 90, reps: 6),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.length, equals(1));
      expect(result.first.setCount, equals(3));
    });

    test('creates separate sessions for sets on different days', () {
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), weight: 80),
        buildSet(date: DateTime(2025, 1, 17), weight: 85),
        buildSet(date: DateTime(2025, 1, 19), weight: 90),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.length, equals(3));
    });

    test('mixes same-day and different-day sets correctly', () {
      // Day 1: 2 sets, Day 2: 1 set
      final sets = [
        buildSet(date: DateTime(2025, 1, 15, 9, 0), weight: 80),
        buildSet(date: DateTime(2025, 1, 15, 9, 5), weight: 85),
        buildSet(date: DateTime(2025, 1, 16, 10, 0), weight: 90),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.length, equals(2));
      final dayOneSession = result.firstWhere(
        (s) => s.date.day == 15,
      );
      expect(dayOneSession.setCount, equals(2));
    });
  });

  group('aggregateSetsBySession - aggregated values', () {
    test('calculates maxWeight correctly', () {
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), weight: 70),
        buildSet(date: DateTime(2025, 1, 15), weight: 80),
        buildSet(date: DateTime(2025, 1, 15), weight: 90),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.maxWeight, equals(90.0));
    });

    test('calculates avgWeight correctly', () {
      // (70 + 80 + 90) / 3 = 80.0
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), weight: 70),
        buildSet(date: DateTime(2025, 1, 15), weight: 80),
        buildSet(date: DateTime(2025, 1, 15), weight: 90),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.avgWeight, closeTo(80.0, 0.01));
    });

    test('calculates totalVolume correctly', () {
      // volume = weight * reps
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), weight: 80, reps: 10, volume: 800),
        buildSet(date: DateTime(2025, 1, 15), weight: 80, reps: 8, volume: 640),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.totalVolume, closeTo(1440.0, 0.01));
    });

    test('calculates maxReps correctly', () {
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), reps: 6),
        buildSet(date: DateTime(2025, 1, 15), reps: 8),
        buildSet(date: DateTime(2025, 1, 15), reps: 12),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.maxReps, equals(12));
    });

    test('calculates avgReps correctly', () {
      // (6 + 8 + 10) / 3 = 8.0
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), reps: 6),
        buildSet(date: DateTime(2025, 1, 15), reps: 8),
        buildSet(date: DateTime(2025, 1, 15), reps: 10),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.avgReps, closeTo(8.0, 0.01));
    });
  });

  group('aggregateSetsBySession - RPE handling', () {
    test('calculates avgRpe correctly for sets with RPE', () {
      // Average RPE: (7 + 8 + 9) / 3 = 8.0
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), rpe: 7),
        buildSet(date: DateTime(2025, 1, 15), rpe: 8),
        buildSet(date: DateTime(2025, 1, 15), rpe: 9),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.avgRpe, closeTo(8.0, 0.01));
    });

    test('avgRpe is null when no sets have RPE data', () {
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), rpe: null),
        buildSet(date: DateTime(2025, 1, 15), rpe: null),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.avgRpe, isNull);
    });

    test('ignores null RPE when computing average', () {
      // Only set1 has RPE=8, set2 has no RPE → avgRpe = 8.0
      final sets = [
        buildSet(date: DateTime(2025, 1, 15), rpe: 8),
        buildSet(date: DateTime(2025, 1, 15), rpe: null),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.avgRpe, closeTo(8.0, 0.01));
    });
  });

  group('aggregateSetsBySession - ordering', () {
    test('returns sessions sorted by date ascending (oldest first)', () {
      // Provide sets out of order
      final sets = [
        buildSet(date: DateTime(2025, 1, 20), weight: 90),
        buildSet(date: DateTime(2025, 1, 10), weight: 70),
        buildSet(date: DateTime(2025, 1, 15), weight: 80),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.length, equals(3));
      expect(result[0].date, equals(DateTime(2025, 1, 10)));
      expect(result[1].date, equals(DateTime(2025, 1, 15)));
      expect(result[2].date, equals(DateTime(2025, 1, 20)));
    });

    test('session date has no time component (midnight)', () {
      final sets = [
        buildSet(date: DateTime(2025, 3, 5, 14, 30, 45), weight: 80),
      ];

      final result = aggregateSetsBySession(sets);

      expect(result.first.date.hour, equals(0));
      expect(result.first.date.minute, equals(0));
      expect(result.first.date.second, equals(0));
      expect(result.first.date.year, equals(2025));
      expect(result.first.date.month, equals(3));
      expect(result.first.date.day, equals(5));
    });
  });
}
