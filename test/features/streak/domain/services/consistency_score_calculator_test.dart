import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/services/consistency_score_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  late ConsistencyScoreCalculator calculator;

  setUp(() {
    calculator = ConsistencyScoreCalculator();
  });

  group('Binary Indicators', () {
    group('isFrequencyOptimal', () {
      test('returns true for 3.0 workouts/week', () {
        // Frequency: 3.0 (minimum optimal)
        // Source: Schoenfeld 2019 - range 3-5 validated
        expect(calculator.isFrequencyOptimal(3.0), true);
      });

      test('returns true for 4.2 workouts/week', () {
        expect(calculator.isFrequencyOptimal(4.2), true);
      });

      test('returns true for 5.0 workouts/week', () {
        // Frequency: 5.0 (maximum optimal)
        expect(calculator.isFrequencyOptimal(5.0), true);
      });

      test('returns false for 2.9 workouts/week', () {
        // Below optimal range
        expect(calculator.isFrequencyOptimal(2.9), false);
      });

      test('returns false for 5.1 workouts/week', () {
        // Above optimal range (overtraining risk)
        expect(calculator.isFrequencyOptimal(5.1), false);
      });
    });

    group('isRestOptimal', () {
      test('returns true for 2.0 rest days/week', () {
        // Rest: 2.0 (minimum safe)
        // Source: UCLA Health - <2 days = 5.2x injury risk
        expect(calculator.isRestOptimal(2.0), true);
      });

      test('returns true for 2.5 rest days/week', () {
        expect(calculator.isRestOptimal(2.5), true);
      });

      test('returns true for 3.0 rest days/week', () {
        // Rest: 3.0 (maximum optimal)
        expect(calculator.isRestOptimal(3.0), true);
      });

      test('returns false for 1.9 rest days/week', () {
        // Insufficient rest (injury risk)
        expect(calculator.isRestOptimal(1.9), false);
      });

      test('returns false for 3.1 rest days/week', () {
        // Too much rest (undertraining)
        expect(calculator.isRestOptimal(3.1), false);
      });
    });

    group('isProgressionPositive', () {
      test('returns true for >5% improvement', () {
        final workouts = _createWorkoutsWithImprovement(0.10); // 10% improvement
        // Source: NASM - progressive overload +5-10%/week optimal
        expect(calculator.isProgressionPositive(workouts), true);
      });

      test('returns true for exactly 5% improvement', () {
        final workouts = _createWorkoutsWithImprovement(0.05);
        expect(calculator.isProgressionPositive(workouts), true);
      });

      test('returns false for 3% improvement (maintaining)', () {
        final workouts = _createWorkoutsWithImprovement(0.03);
        expect(calculator.isProgressionPositive(workouts), false);
      });

      test('returns false for negative trend', () {
        final workouts = _createWorkoutsWithImprovement(-0.05);
        expect(calculator.isProgressionPositive(workouts), false);
      });

      test('returns false for less than 5 workouts', () {
        final workouts = _createWorkoutsWithImprovement(0.10, count: 4);
        // Not enough data
        expect(calculator.isProgressionPositive(workouts), false);
      });
    });
  });
}

/// Helper: Create workouts with specific improvement trend
List<Workout> _createWorkoutsWithImprovement(double ratio, {int count = 10}) {
  const baseWeight = 50.0;
  final midPoint = count ~/ 2;

  return List.generate(count, (i) {
    final isRecentHalf = i >= midPoint;
    final weight = isRecentHalf
        ? baseWeight * (1 + ratio) // Recent half has improvement
        : baseWeight;                // Older half baseline

    final workoutDate = DateTime.now().subtract(Duration(days: count - i));

    return Workout(
      id: 'workout_$i',
      name: 'Test Workout $i',
      createdAt: workoutDate,
      updatedAt: workoutDate,
      status: WorkoutStatus.completed,
      exercises: [
        Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: weight,
              reps: 10,
              isCompleted: true,
            ),
            ExerciseSet(
              setNumber: 2,
              weight: weight,
              reps: 10,
              isCompleted: true,
            ),
            ExerciseSet(
              setNumber: 3,
              weight: weight,
              reps: 10,
              isCompleted: true,
            ),
          ],
        ),
      ],
      endTime: workoutDate,
    );
  });
}
