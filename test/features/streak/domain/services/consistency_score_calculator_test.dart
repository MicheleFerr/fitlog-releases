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

  group('calculateScore', () {
    test('returns score with binary indicators set correctly', () {
      // Create 10 workouts with:
      // - 4 workouts/week (optimal frequency)
      // - 3 rest days/week (optimal rest)
      // - 10% improvement (positive progression)
      final workouts = _createOptimalWorkouts();

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 12,
      );

      // Binary indicators should all be true
      expect(score.frequencyOptimal, true);
      expect(score.restOptimal, true);
      expect(score.progressionPositive, true);

      // Detailed scores should be present
      expect(score.frequencyScore, greaterThan(70));
      expect(score.restScore, greaterThan(70));
      expect(score.progressionScore, greaterThan(70));

      // Deprecated fields should be null
      expect(score.overallScore, isNull);
      expect(score.scoreRating, isNull);
      expect(score.overtrainingRisk, isNull);
      expect(score.volumeScore, isNull);
    });

    test('returns empty score for no workouts', () {
      final score = calculator.calculateScore(
        workouts: [],
        currentStreak: 0,
        longestStreak: 0,
      );

      expect(score.frequencyOptimal, false);
      expect(score.restOptimal, false);
      expect(score.progressionPositive, false);
    });
  });
}

/// Helper: Create workouts with optimal patterns
List<Workout> _createOptimalWorkouts() {
  // 10 workouts over 17 days = ~4.1 workouts/week (optimal)
  // 17 - 10 = 7 rest days over 17 days = ~2.9 rest days/week (optimal)
  // 10% improvement in weight (positive progression)
  return _createWorkoutsWithImprovement(0.10, count: 10);
}

/// Helper: Create workouts with specific improvement trend
List<Workout> _createWorkoutsWithImprovement(double ratio, {int count = 10}) {
  const baseWeight = 50.0;
  final midPoint = count ~/ 2;

  // Spread workouts over ~17 days for optimal frequency
  // 10 workouts / 17 days ≈ 4.1 workouts/week
  final workoutDays = [0, 2, 4, 5, 7, 9, 11, 13, 15, 16];

  return List.generate(count, (i) {
    final isRecentHalf = i >= midPoint;
    final weight = isRecentHalf
        ? baseWeight * (1 + ratio) // Recent half has improvement
        : baseWeight;                // Older half baseline

    final daysBack = workoutDays[i];
    final workoutDate = DateTime.now().subtract(Duration(days: daysBack));

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
