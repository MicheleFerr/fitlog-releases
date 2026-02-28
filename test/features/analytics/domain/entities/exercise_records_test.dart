import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_records.dart';

void main() {
  group('ExerciseRecords - construction and basic properties', () {
    final firstDate = DateTime(2025, 1, 1);
    final lastDate = DateTime(2025, 4, 1); // 90 days later

    ExerciseRecords buildRecords({
      String exerciseName = 'Bench Press',
      double maxWeightRecord = 100.0,
      double estimated1RM = 115.0,
      double totalVolumeRecord = 5000.0,
      int totalSetsRecord = 5,
      DateTime? lastWorkoutDate,
      double weeklyFrequency = 2.5,
      DateTime? firstWorkoutDate,
      int totalWorkouts = 30,
    }) {
      return ExerciseRecords(
        exerciseName: exerciseName,
        maxWeightRecord: maxWeightRecord,
        estimated1RM: estimated1RM,
        totalVolumeRecord: totalVolumeRecord,
        totalSetsRecord: totalSetsRecord,
        lastWorkoutDate: lastWorkoutDate ?? lastDate,
        weeklyFrequency: weeklyFrequency,
        firstWorkoutDate: firstWorkoutDate ?? firstDate,
        totalWorkouts: totalWorkouts,
      );
    }

    test('creates record with all required fields', () {
      final record = buildRecords();

      expect(record.exerciseName, equals('Bench Press'));
      expect(record.maxWeightRecord, equals(100.0));
      expect(record.estimated1RM, equals(115.0));
      expect(record.totalVolumeRecord, equals(5000.0));
      expect(record.totalSetsRecord, equals(5));
      expect(record.weeklyFrequency, equals(2.5));
      expect(record.totalWorkouts, equals(30));
    });

    test('two records with same data are equal (freezed equality)', () {
      final r1 = buildRecords();
      final r2 = buildRecords();

      expect(r1, equals(r2));
    });

    test('two records with different exercise names are not equal', () {
      final r1 = buildRecords(exerciseName: 'Bench Press');
      final r2 = buildRecords(exerciseName: 'Squat');

      expect(r1, isNot(equals(r2)));
    });
  });

  group('ExerciseRecordsX - extension calculations', () {
    test('daysSinceLastWorkout returns correct number of days', () {
      // Use a fixed date in the past
      final lastWorkoutDate = DateTime.now().subtract(const Duration(days: 5));
      final record = ExerciseRecords(
        exerciseName: 'Squat',
        maxWeightRecord: 120.0,
        estimated1RM: 135.0,
        totalVolumeRecord: 8000.0,
        totalSetsRecord: 4,
        lastWorkoutDate: lastWorkoutDate,
        weeklyFrequency: 2.0,
        firstWorkoutDate: lastWorkoutDate.subtract(const Duration(days: 90)),
        totalWorkouts: 25,
      );

      expect(record.daysSinceLastWorkout, equals(5));
    });

    test('totalTrainingDays calculates difference between first and last workout', () {
      final first = DateTime(2025, 1, 1);
      final last = DateTime(2025, 4, 11); // 99 days later (Jan: 30 days remaining, Feb: 28, Mar: 31, Apr 1-10: 10 = 99)
      final record = ExerciseRecords(
        exerciseName: 'Deadlift',
        maxWeightRecord: 160.0,
        estimated1RM: 180.0,
        totalVolumeRecord: 10000.0,
        totalSetsRecord: 5,
        lastWorkoutDate: last,
        weeklyFrequency: 1.5,
        firstWorkoutDate: first,
        totalWorkouts: 20,
      );

      // last.difference(first).inDays = (Jan 1 → Apr 11) = 30 + 28 + 31 + 10 = 99 days
      expect(record.totalTrainingDays, equals(99));
    });

    test('overallFrequency calculates workouts per week over entire history', () {
      // Jan 1 → Mar 2 = 60 days exactly (Jan: 31, Feb: 28, +1 = 60)
      // 30 workouts over 60 days = 30 / (60/7) = 30 / 8.571 ≈ 3.5 workouts/week
      final first = DateTime(2025, 1, 1);
      final last = DateTime(2025, 3, 2); // 60 days later
      final record = ExerciseRecords(
        exerciseName: 'Bench Press',
        maxWeightRecord: 100.0,
        estimated1RM: 110.0,
        totalVolumeRecord: 5000.0,
        totalSetsRecord: 4,
        lastWorkoutDate: last,
        weeklyFrequency: 3.5,
        firstWorkoutDate: first,
        totalWorkouts: 30,
      );

      // 30 / (60/7) = 30 / 8.571... ≈ 3.5
      expect(record.overallFrequency, closeTo(3.5, 0.01));
    });

    test('overallFrequency returns 0 when first and last workout are same day', () {
      final sameDate = DateTime(2025, 1, 1);
      final record = ExerciseRecords(
        exerciseName: 'Push Up',
        maxWeightRecord: 0.0,
        estimated1RM: 0.0,
        totalVolumeRecord: 0.0,
        totalSetsRecord: 1,
        lastWorkoutDate: sameDate,
        weeklyFrequency: 0.0,
        firstWorkoutDate: sameDate,
        totalWorkouts: 1,
      );

      expect(record.overallFrequency, equals(0.0));
    });

    test('totalTrainingDays is 0 when first and last workout are same day', () {
      final sameDate = DateTime(2025, 6, 1);
      final record = ExerciseRecords(
        exerciseName: 'Chin Up',
        maxWeightRecord: 0.0,
        estimated1RM: 0.0,
        totalVolumeRecord: 0.0,
        totalSetsRecord: 1,
        lastWorkoutDate: sameDate,
        weeklyFrequency: 0.0,
        firstWorkoutDate: sameDate,
        totalWorkouts: 1,
      );

      expect(record.totalTrainingDays, equals(0));
    });
  });
}
