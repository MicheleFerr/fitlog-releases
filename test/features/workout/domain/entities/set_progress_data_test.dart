import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/set_progress_data.dart';

void main() {
  final lastDate = DateTime(2026, 2, 20);

  SetProgressData makeData({
    double currentWeight = 100.0,
    double lastWeight = 100.0,
    int currentReps = 10,
    int lastReps = 10,
  }) {
    return SetProgressData(
      currentWeight: currentWeight,
      lastWeight: lastWeight,
      currentReps: currentReps,
      lastReps: lastReps,
      lastWorkoutDate: lastDate,
      setNumber: 1,
      exerciseName: 'Bench Press',
    );
  }

  group('SetProgressData', () {
    group('constructor', () {
      test('creates instance with all required fields', () {
        final data = makeData();

        expect(data.currentWeight, 100.0);
        expect(data.lastWeight, 100.0);
        expect(data.currentReps, 10);
        expect(data.lastReps, 10);
        expect(data.lastWorkoutDate, lastDate);
        expect(data.setNumber, 1);
        expect(data.exerciseName, 'Bench Press');
      });
    });

    group('weightDelta', () {
      test('returns positive when weight increased', () {
        final data = makeData(currentWeight: 110, lastWeight: 100);
        expect(data.weightDelta, 10.0);
      });

      test('returns negative when weight decreased', () {
        final data = makeData(currentWeight: 90, lastWeight: 100);
        expect(data.weightDelta, -10.0);
      });

      test('returns zero when weight unchanged', () {
        final data = makeData(currentWeight: 100, lastWeight: 100);
        expect(data.weightDelta, 0.0);
      });

      test('handles decimal weights', () {
        final data = makeData(currentWeight: 102.5, lastWeight: 100.0);
        expect(data.weightDelta, closeTo(2.5, 0.001));
      });
    });

    group('repsDelta', () {
      test('returns positive when reps increased', () {
        final data = makeData(currentReps: 12, lastReps: 10);
        expect(data.repsDelta, 2);
      });

      test('returns negative when reps decreased', () {
        final data = makeData(currentReps: 8, lastReps: 10);
        expect(data.repsDelta, -2);
      });

      test('returns zero when reps unchanged', () {
        final data = makeData(currentReps: 10, lastReps: 10);
        expect(data.repsDelta, 0);
      });
    });

    group('hasWeightImproved', () {
      test('true when current > last', () {
        expect(makeData(currentWeight: 110, lastWeight: 100).hasWeightImproved, isTrue);
      });

      test('false when current == last', () {
        expect(makeData(currentWeight: 100, lastWeight: 100).hasWeightImproved, isFalse);
      });

      test('false when current < last', () {
        expect(makeData(currentWeight: 90, lastWeight: 100).hasWeightImproved, isFalse);
      });
    });

    group('hasWeightDecreased', () {
      test('true when current < last', () {
        expect(makeData(currentWeight: 90, lastWeight: 100).hasWeightDecreased, isTrue);
      });

      test('false when current == last', () {
        expect(makeData(currentWeight: 100, lastWeight: 100).hasWeightDecreased, isFalse);
      });

      test('false when current > last', () {
        expect(makeData(currentWeight: 110, lastWeight: 100).hasWeightDecreased, isFalse);
      });
    });

    group('hasRepsImproved', () {
      test('true when current > last', () {
        expect(makeData(currentReps: 12, lastReps: 10).hasRepsImproved, isTrue);
      });

      test('false when current == last', () {
        expect(makeData(currentReps: 10, lastReps: 10).hasRepsImproved, isFalse);
      });

      test('false when current < last', () {
        expect(makeData(currentReps: 8, lastReps: 10).hasRepsImproved, isFalse);
      });
    });

    group('hasRepsDecreased', () {
      test('true when current < last', () {
        expect(makeData(currentReps: 8, lastReps: 10).hasRepsDecreased, isTrue);
      });

      test('false when current == last', () {
        expect(makeData(currentReps: 10, lastReps: 10).hasRepsDecreased, isFalse);
      });

      test('false when current > last', () {
        expect(makeData(currentReps: 12, lastReps: 10).hasRepsDecreased, isFalse);
      });
    });

    group('overallStatus', () {
      test('majorImprovement when both weight and reps up', () {
        final data = makeData(
          currentWeight: 110, lastWeight: 100,
          currentReps: 12, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.majorImprovement);
      });

      test('improvement when weight up, reps same', () {
        final data = makeData(
          currentWeight: 110, lastWeight: 100,
          currentReps: 10, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.improvement);
      });

      test('improvement when reps up, weight same', () {
        final data = makeData(
          currentWeight: 100, lastWeight: 100,
          currentReps: 12, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.improvement);
      });

      test('mixed when weight up, reps down', () {
        final data = makeData(
          currentWeight: 110, lastWeight: 100,
          currentReps: 8, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.mixed);
      });

      test('mixed when reps up, weight down', () {
        final data = makeData(
          currentWeight: 90, lastWeight: 100,
          currentReps: 12, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.mixed);
      });

      test('unchanged when both same', () {
        final data = makeData(
          currentWeight: 100, lastWeight: 100,
          currentReps: 10, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.unchanged);
      });

      test('regression when weight down, reps same', () {
        final data = makeData(
          currentWeight: 90, lastWeight: 100,
          currentReps: 10, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.regression);
      });

      test('regression when reps down, weight same', () {
        final data = makeData(
          currentWeight: 100, lastWeight: 100,
          currentReps: 8, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.regression);
      });

      test('majorRegression when both weight and reps down', () {
        final data = makeData(
          currentWeight: 90, lastWeight: 100,
          currentReps: 8, lastReps: 10,
        );
        expect(data.overallStatus, ProgressStatus.majorRegression);
      });
    });

    group('weightPercentageChange', () {
      test('positive percentage for weight increase', () {
        final data = makeData(currentWeight: 110, lastWeight: 100);
        expect(data.weightPercentageChange, closeTo(10.0, 0.001));
      });

      test('negative percentage for weight decrease', () {
        final data = makeData(currentWeight: 90, lastWeight: 100);
        expect(data.weightPercentageChange, closeTo(-10.0, 0.001));
      });

      test('zero percentage when unchanged', () {
        final data = makeData(currentWeight: 100, lastWeight: 100);
        expect(data.weightPercentageChange, 0.0);
      });

      test('returns 100 when last weight was 0 and current > 0', () {
        final data = makeData(currentWeight: 50, lastWeight: 0);
        expect(data.weightPercentageChange, 100.0);
      });

      test('returns 0 when both are 0', () {
        final data = makeData(currentWeight: 0, lastWeight: 0);
        expect(data.weightPercentageChange, 0.0);
      });

      test('handles large percentage changes', () {
        final data = makeData(currentWeight: 200, lastWeight: 50);
        expect(data.weightPercentageChange, closeTo(300.0, 0.001));
      });

      test('handles small decimal changes', () {
        final data = makeData(currentWeight: 100.5, lastWeight: 100.0);
        expect(data.weightPercentageChange, closeTo(0.5, 0.001));
      });
    });

    group('repsPercentageChange', () {
      test('positive percentage for reps increase', () {
        final data = makeData(currentReps: 12, lastReps: 10);
        expect(data.repsPercentageChange, closeTo(20.0, 0.001));
      });

      test('negative percentage for reps decrease', () {
        final data = makeData(currentReps: 8, lastReps: 10);
        expect(data.repsPercentageChange, closeTo(-20.0, 0.001));
      });

      test('zero percentage when unchanged', () {
        final data = makeData(currentReps: 10, lastReps: 10);
        expect(data.repsPercentageChange, 0.0);
      });

      test('returns 100 when last reps was 0 and current > 0', () {
        final data = makeData(currentReps: 5, lastReps: 0);
        expect(data.repsPercentageChange, 100.0);
      });

      test('returns 0 when both are 0', () {
        final data = makeData(currentReps: 0, lastReps: 0);
        expect(data.repsPercentageChange, 0.0);
      });

      test('handles 100% increase (doubled)', () {
        final data = makeData(currentReps: 20, lastReps: 10);
        expect(data.repsPercentageChange, closeTo(100.0, 0.001));
      });

      test('handles 50% decrease', () {
        final data = makeData(currentReps: 5, lastReps: 10);
        expect(data.repsPercentageChange, closeTo(-50.0, 0.001));
      });
    });

    group('ProgressStatus enum', () {
      test('has all expected values', () {
        expect(ProgressStatus.values, hasLength(6));
        expect(ProgressStatus.values, contains(ProgressStatus.majorImprovement));
        expect(ProgressStatus.values, contains(ProgressStatus.improvement));
        expect(ProgressStatus.values, contains(ProgressStatus.mixed));
        expect(ProgressStatus.values, contains(ProgressStatus.unchanged));
        expect(ProgressStatus.values, contains(ProgressStatus.regression));
        expect(ProgressStatus.values, contains(ProgressStatus.majorRegression));
      });
    });

    group('SetProgressParams', () {
      test('creates instance with required fields', () {
        const params = SetProgressParams(
          exerciseName: 'Squat',
          setNumber: 2,
          currentWeight: 140.0,
          currentReps: 5,
        );

        expect(params.exerciseName, 'Squat');
        expect(params.setNumber, 2);
        expect(params.currentWeight, 140.0);
        expect(params.currentReps, 5);
      });

      test('freezed equality works', () {
        const a = SetProgressParams(
          exerciseName: 'Squat',
          setNumber: 2,
          currentWeight: 140.0,
          currentReps: 5,
        );
        const b = SetProgressParams(
          exerciseName: 'Squat',
          setNumber: 2,
          currentWeight: 140.0,
          currentReps: 5,
        );

        expect(a, equals(b));
      });

      test('different fields means not equal', () {
        const a = SetProgressParams(
          exerciseName: 'Squat',
          setNumber: 2,
          currentWeight: 140.0,
          currentReps: 5,
        );
        const b = SetProgressParams(
          exerciseName: 'Deadlift',
          setNumber: 2,
          currentWeight: 140.0,
          currentReps: 5,
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('freezed equality', () {
      test('same fields are equal', () {
        final a = makeData(currentWeight: 110, lastWeight: 100, currentReps: 12, lastReps: 10);
        final b = SetProgressData(
          currentWeight: 110,
          lastWeight: 100,
          currentReps: 12,
          lastReps: 10,
          lastWorkoutDate: lastDate,
          setNumber: 1,
          exerciseName: 'Bench Press',
        );
        expect(a, equals(b));
      });

      test('different fields are not equal', () {
        final a = makeData(currentWeight: 110);
        final b = makeData(currentWeight: 120);
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new weight', () {
        final original = makeData(currentWeight: 100);
        final copied = original.copyWith(currentWeight: 120);

        expect(copied.currentWeight, 120);
        expect(copied.lastWeight, original.lastWeight);
        expect(copied.exerciseName, original.exerciseName);
      });

      test('copies with new reps', () {
        final original = makeData(currentReps: 10);
        final copied = original.copyWith(currentReps: 15);

        expect(copied.currentReps, 15);
        expect(copied.currentWeight, original.currentWeight);
      });
    });
  });
}
