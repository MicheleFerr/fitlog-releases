import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/services/consistency_score_calculator.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a Workout with a single exercise and a specific weight-per-set.
Workout _workoutWithWeight({
  required String id,
  required DateTime date,
  required double weight,
  int sets = 3,
  int reps = 10,
}) =>
    Workout(
      id: id,
      name: 'Workout $id',
      createdAt: date,
      updatedAt: date,
      status: WorkoutStatus.completed,
      endTime: date,
      exercises: [
        Exercise(
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: List.generate(
            sets,
            (i) => ExerciseSet(
              setNumber: i + 1,
              weight: weight,
              reps: reps,
              isCompleted: true,
            ),
          ),
        ),
      ],
    );

/// Creates a Workout with NO exercises (zero volume).
Workout _emptyWorkout({required String id, required DateTime date}) => Workout(
      id: id,
      name: 'Empty Workout $id',
      createdAt: date,
      updatedAt: date,
      status: WorkoutStatus.completed,
      endTime: date,
      exercises: const [],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  late ConsistencyScoreCalculator calculator;

  setUp(() {
    calculator = ConsistencyScoreCalculator();
  });

  // -------------------------------------------------------------------------
  // Frequency score (tested through calculateScore)
  // -------------------------------------------------------------------------
  group('calculateScore - frequency score branches', () {
    test('frequencyScore is 100 for optimal range (3-5 workouts/week)', () {
      // 4 workouts over 8 days = 3.5/week (optimal)
      final workouts = List.generate(4, (i) {
        final daysBack = i * 2; // every 2 days
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: daysBack)),
          weight: 50.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 1,
      );

      expect(score.frequencyScore, 100);
    });

    test('frequencyScore < 100 when frequency is below optimal (1/week)', () {
      // 3 workouts over 3 weeks = 1/week (below optimal)
      final workouts = [
        _workoutWithWeight(
          id: 'w0',
          date: DateTime.now().subtract(const Duration(days: 14)),
          weight: 50.0,
        ),
        _workoutWithWeight(
          id: 'w1',
          date: DateTime.now().subtract(const Duration(days: 7)),
          weight: 50.0,
        ),
        _workoutWithWeight(
          id: 'w2',
          date: DateTime.now(),
          weight: 50.0,
        ),
      ];

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 1,
      );

      expect(score.frequencyScore, lessThan(100));
      expect(score.frequencyScore, greaterThanOrEqualTo(0));
    });

    test('frequencyScore < 100 when frequency is above optimal (7/week)', () {
      // 7 workouts in 1 week = 7/week (overtraining range)
      final workouts = List.generate(7, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i)),
          weight: 50.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 7,
        longestStreak: 7,
      );

      expect(score.frequencyScore, lessThan(100));
    });
  });

  // -------------------------------------------------------------------------
  // Rest score (tested through calculateScore)
  // -------------------------------------------------------------------------
  group('calculateScore - rest score branches', () {
    test('restScore is 100 when rest days in optimal range (2-3/week)', () {
      // 4 workouts over 7 days: 3 rest days/week (optimal)
      // Days: 0, 2, 4, 6 → 4 active, 3 rest (in 7 days)
      final workouts = [
        _workoutWithWeight(
          id: 'w0',
          date: DateTime.now(),
          weight: 50.0,
        ),
        _workoutWithWeight(
          id: 'w1',
          date: DateTime.now().subtract(const Duration(days: 2)),
          weight: 50.0,
        ),
        _workoutWithWeight(
          id: 'w2',
          date: DateTime.now().subtract(const Duration(days: 4)),
          weight: 50.0,
        ),
        _workoutWithWeight(
          id: 'w3',
          date: DateTime.now().subtract(const Duration(days: 6)),
          weight: 50.0,
        ),
      ];

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 1,
      );

      expect(score.restScore, 100);
    });

    test('restScore < 100 when too many rest days (almost all rest)', () {
      // 2 workouts over 15 days → ~6 rest days/week (too many)
      final workouts = [
        _workoutWithWeight(
          id: 'w0',
          date: DateTime.now().subtract(const Duration(days: 14)),
          weight: 50.0,
        ),
        _workoutWithWeight(
          id: 'w1',
          date: DateTime.now(),
          weight: 50.0,
        ),
      ];

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 1,
      );

      expect(score.restScore, lessThan(100));
    });
  });

  // -------------------------------------------------------------------------
  // Progression score (tested through calculateScore)
  // -------------------------------------------------------------------------
  group('calculateScore - progression score branches', () {
    test('progressionScore is 50 when fewer than 5 workouts', () {
      final workouts = List.generate(4, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i * 2)),
          weight: 60.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 2,
        longestStreak: 2,
      );

      expect(score.progressionScore, 50);
    });

    test('progressionScore is 100 for >15% improvement', () {
      // Older half: weight=50, Recent half: weight=60 → 20% improvement
      final workouts = List.generate(10, (i) {
        final isRecent = i >= 5;
        final weight = isRecent ? 60.0 : 50.0;
        final daysBack = (9 - i) * 2;
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: daysBack)),
          weight: weight,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 5,
      );

      expect(score.progressionScore, 100);
    });

    test('progressionScore is 85 for 5-15% improvement', () {
      // Older half: weight=50, Recent half: weight=55 → 10% improvement
      final workouts = List.generate(10, (i) {
        final isRecent = i >= 5;
        final weight = isRecent ? 55.0 : 50.0;
        final daysBack = (9 - i) * 2;
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: daysBack)),
          weight: weight,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 5,
      );

      expect(score.progressionScore, 85);
    });

    test('progressionScore is 70 for ±5% (maintaining)', () {
      // Same weight throughout → 0% change
      final workouts = List.generate(10, (i) {
        final daysBack = (9 - i) * 2;
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: daysBack)),
          weight: 50.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 5,
      );

      expect(score.progressionScore, 70);
    });

    test('progressionScore is 50 for regression (>5% worse)', () {
      // Recent half lighter than older half → regression
      final workouts = List.generate(10, (i) {
        final isRecent = i >= 5;
        final weight = isRecent ? 40.0 : 50.0; // -20%
        final daysBack = (9 - i) * 2;
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: daysBack)),
          weight: weight,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 5,
      );

      expect(score.progressionScore, 50);
    });

    test('progressionScore is 50 when older average is zero (empty exercises)', () {
      // Workouts with no sets → totalSets=0 → avgWeight=0 → olderAvg=0
      final workouts = List.generate(10, (i) {
        final daysBack = (9 - i) * 2;
        return _emptyWorkout(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: daysBack)),
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 5,
      );

      expect(score.progressionScore, 50);
    });
  });

  // -------------------------------------------------------------------------
  // Weekly stats calculation
  // -------------------------------------------------------------------------
  group('calculateScore - weeklyStats', () {
    test('weeklyStats reflects correct totals', () {
      // 5 workouts on separate days over 10-day span
      final base = DateTime.now();
      final workouts = [
        _workoutWithWeight(id: 'w0', date: base.subtract(const Duration(days: 8)), weight: 50),
        _workoutWithWeight(id: 'w1', date: base.subtract(const Duration(days: 6)), weight: 50),
        _workoutWithWeight(id: 'w2', date: base.subtract(const Duration(days: 4)), weight: 50),
        _workoutWithWeight(id: 'w3', date: base.subtract(const Duration(days: 2)), weight: 50),
        _workoutWithWeight(id: 'w4', date: base, weight: 50),
      ];

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 2,
      );

      expect(score.weeklyStats.totalWorkouts, 5);
      expect(score.weeklyStats.totalActiveDays, 5);
      // 9 day span, 5 active → 4 rest days
      expect(score.weeklyStats.totalRestDays, 4);
    });

    test('workoutsCompleted and avgFrequency are populated', () {
      final workouts = List.generate(6, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i * 2)),
          weight: 50.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 3,
        longestStreak: 3,
      );

      expect(score.workoutsCompleted, 6);
      expect(score.avgFrequency, greaterThan(0.0));
    });

    test('currentStreak and longestStreak are stored correctly', () {
      final workouts = List.generate(5, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i)),
          weight: 50.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 5,
        longestStreak: 20,
      );

      expect(score.currentStreak, 5);
      expect(score.longestStreak, 20);
    });

    test('calculatedAt is set', () {
      final workouts = List.generate(5, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i * 2)),
          weight: 50.0,
        );
      });

      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 1,
      );
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(score.calculatedAt, isNotNull);
      expect(score.calculatedAt!.isAfter(before), isTrue);
      expect(score.calculatedAt!.isBefore(after), isTrue);
    });

    test('deprecated fields are all null', () {
      final workouts = List.generate(5, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i * 2)),
          weight: 50.0,
        );
      });

      final score = calculator.calculateScore(
        workouts: workouts,
        currentStreak: 1,
        longestStreak: 1,
      );

      // ignore: deprecated_member_use
      expect(score.overallScore, isNull);
      // ignore: deprecated_member_use
      expect(score.scoreRating, isNull);
      // ignore: deprecated_member_use
      expect(score.rating, isNull);
      // ignore: deprecated_member_use
      expect(score.riskLevel, isNull);
      // ignore: deprecated_member_use
      expect(score.overtrainingRisk, isNull);
      // ignore: deprecated_member_use
      expect(score.volumeScore, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // isProgressionPositive - edge cases
  // -------------------------------------------------------------------------
  group('isProgressionPositive - edge cases', () {
    test('returns false for exactly 4 workouts (below minimum)', () {
      final workouts = List.generate(4, (i) {
        return _workoutWithWeight(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i)),
          weight: 80.0,
        );
      });

      expect(calculator.isProgressionPositive(workouts), false);
    });

    test('returns false for empty workout list', () {
      expect(calculator.isProgressionPositive([]), false);
    });

    test('returns false when older average is zero (no sets in early workouts)', () {
      // 5 empty workouts → avgWeight = 0 → olderAvg = 0 → returns false
      final workouts = List.generate(5, (i) {
        return _emptyWorkout(
          id: 'w$i',
          date: DateTime.now().subtract(Duration(days: i * 2)),
        );
      });

      expect(calculator.isProgressionPositive(workouts), false);
    });
  });

  // -------------------------------------------------------------------------
  // isFrequencyOptimal - boundary values
  // -------------------------------------------------------------------------
  group('isFrequencyOptimal - boundary values', () {
    test('exactly 3.0 is optimal', () {
      expect(calculator.isFrequencyOptimal(3.0), true);
    });

    test('exactly 5.0 is optimal', () {
      expect(calculator.isFrequencyOptimal(5.0), true);
    });

    test('2.999 is not optimal', () {
      expect(calculator.isFrequencyOptimal(2.999), false);
    });

    test('5.001 is not optimal', () {
      expect(calculator.isFrequencyOptimal(5.001), false);
    });

    test('0.0 is not optimal', () {
      expect(calculator.isFrequencyOptimal(0.0), false);
    });
  });

  // -------------------------------------------------------------------------
  // isRestOptimal - boundary values
  // -------------------------------------------------------------------------
  group('isRestOptimal - boundary values', () {
    test('exactly 2.0 is optimal', () {
      expect(calculator.isRestOptimal(2.0), true);
    });

    test('exactly 3.0 is optimal', () {
      expect(calculator.isRestOptimal(3.0), true);
    });

    test('1.999 is not optimal', () {
      expect(calculator.isRestOptimal(1.999), false);
    });

    test('3.001 is not optimal', () {
      expect(calculator.isRestOptimal(3.001), false);
    });

    test('0.0 is not optimal', () {
      expect(calculator.isRestOptimal(0.0), false);
    });

    test('7.0 is not optimal', () {
      expect(calculator.isRestOptimal(7.0), false);
    });
  });
}
