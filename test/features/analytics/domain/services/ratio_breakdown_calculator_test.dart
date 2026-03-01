/// RatioBreakdownCalculator tests - push/pull/upper/lower breakdown.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/ratio_breakdown.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/ratio_breakdown_calculator.dart';

void main() {
  late RatioBreakdownCalculator calculator;

  setUp(() {
    calculator = RatioBreakdownCalculator();
  });

  ExerciseHistory _makeHistory({
    required String name,
    required String muscle,
    required double weight,
    required int reps,
    int sets = 3,
  }) {
    final analyticsSets = List.generate(
      sets,
      (i) => AnalyticsSet(
        weight: weight,
        reps: reps,
        date: DateTime(2025, 1, 1),
      ),
    );
    return ExerciseHistory(
      exerciseId: name.toLowerCase().replaceAll(' ', '_'),
      exerciseName: name,
      muscleGroup: muscle,
      sessions: [
        ExerciseSession(
          exerciseName: name,
          muscleGroup: muscle,
          sets: analyticsSets,
          date: DateTime(2025, 1, 1),
        ),
      ],
    );
  }

  group('calculateBreakdown', () {
    test('empty histories returns empty breakdown', () {
      final breakdown = calculator.calculateBreakdown([]);
      expect(breakdown.pushBreakdown.totalVolume, 0);
      expect(breakdown.pullBreakdown.totalVolume, 0);
      expect(breakdown.upperBreakdown.totalVolume, 0);
      expect(breakdown.lowerBreakdown.totalVolume, 0);
      expect(breakdown.hasData, isFalse);
    });

    test('chest exercise classified as push and upper', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pushBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.upperBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.pullBreakdown.totalVolume, 0);
      expect(breakdown.lowerBreakdown.totalVolume, 0);
    });

    test('back exercise classified as pull and upper', () {
      final histories = [
        _makeHistory(
          name: 'Barbell Row',
          muscle: 'back',
          weight: 80,
          reps: 10,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pullBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.upperBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.pushBreakdown.totalVolume, 0);
    });

    test('quads exercise classified as push and lower', () {
      final histories = [
        _makeHistory(
          name: 'Squat',
          muscle: 'quads',
          weight: 120,
          reps: 8,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pushBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.lowerBreakdown.totalVolume, greaterThan(0));
    });

    test('hamstrings exercise classified as pull and lower', () {
      final histories = [
        _makeHistory(
          name: 'Leg Curl',
          muscle: 'hamstrings',
          weight: 50,
          reps: 12,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pullBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.lowerBreakdown.totalVolume, greaterThan(0));
    });

    test('deltoid specific portions: delt_ant is push', () {
      final histories = [
        _makeHistory(
          name: 'Front Raise',
          muscle: 'delt_ant',
          weight: 10,
          reps: 12,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pushBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.pullBreakdown.totalVolume, 0);
    });

    test('deltoid specific portions: delt_post is pull', () {
      final histories = [
        _makeHistory(
          name: 'Face Pull',
          muscle: 'delt_post',
          weight: 15,
          reps: 15,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pullBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.pushBreakdown.totalVolume, 0);
    });

    test('deltoid specific portions: delt_lat is neutral', () {
      final histories = [
        _makeHistory(
          name: 'Lateral Raise',
          muscle: 'delt_lat',
          weight: 8,
          reps: 15,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      // delt_lat should be neither push nor pull
      expect(breakdown.pushBreakdown.totalVolume, 0);
      expect(breakdown.pullBreakdown.totalVolume, 0);
      // But should be upper
      expect(breakdown.upperBreakdown.totalVolume, greaterThan(0));
    });

    test('exercise name inference: bench press as push', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'generic', // wrong stored value
          weight: 100,
          reps: 10,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pushBreakdown.totalVolume, greaterThan(0));
    });

    test('exercise name inference: pull up as pull', () {
      final histories = [
        _makeHistory(
          name: 'Pull Up',
          muscle: 'generic',
          weight: 80,
          reps: 8,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.pullBreakdown.totalVolume, greaterThan(0));
    });

    test('exercise contributions have percentages', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 3,
        ),
        _makeHistory(
          name: 'Dumbbell Fly',
          muscle: 'chest',
          weight: 20,
          reps: 12,
          sets: 3,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      final allPush = breakdown.pushBreakdown.allExercises;
      expect(allPush.isNotEmpty, isTrue);

      // Sum of percentages in push category should be ~100%
      final totalPct = allPush.fold<double>(0, (s, e) => s + e.percentage);
      expect(totalPct, closeTo(100.0, 1.0));
    });

    test('multiple exercises in same muscle group aggregated', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 3,
        ),
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 3,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      // Same exercise name -> aggregated into one entry
      expect(breakdown.pushBreakdown.totalVolume, 6000.0); // 100*10*3*2
    });

    test('hasData is true when data exists', () {
      final histories = [
        _makeHistory(
          name: 'Bench',
          muscle: 'chest',
          weight: 50,
          reps: 10,
        ),
      ];
      final breakdown = calculator.calculateBreakdown(histories);
      expect(breakdown.hasData, isTrue);
    });
  });

  group('calculateCorrectedBreakdown', () {
    test('empty returns empty', () {
      final breakdown = calculator.calculateCorrectedBreakdown([]);
      expect(breakdown.hasData, isFalse);
    });

    test('corrects squat from legs to quads (push)', () {
      final histories = [
        _makeHistory(
          name: 'Squat',
          muscle: 'legs', // generic
          weight: 100,
          reps: 10,
        ),
      ];
      final breakdown = calculator.calculateCorrectedBreakdown(histories);
      expect(breakdown.pushBreakdown.totalVolume, greaterThan(0));
      expect(breakdown.lowerBreakdown.totalVolume, greaterThan(0));
    });

    test('corrects deadlift from legs to back (pull)', () {
      final histories = [
        _makeHistory(
          name: 'Deadlift',
          muscle: 'legs',
          weight: 150,
          reps: 5,
        ),
      ];
      final breakdown = calculator.calculateCorrectedBreakdown(histories);
      expect(breakdown.pullBreakdown.totalVolume, greaterThan(0));
    });
  });

  group('CategoryBreakdown', () {
    test('topExercises returns limited list', () {
      const breakdown = CategoryBreakdown(
        categoryName: 'Push',
        totalVolume: 3000,
        exercisesByMuscle: {
          'chest': [
            ExerciseContribution(
              exerciseName: 'Bench',
              muscleGroup: 'chest',
              volume: 2000,
              percentage: 66.7,
            ),
            ExerciseContribution(
              exerciseName: 'Fly',
              muscleGroup: 'chest',
              volume: 500,
              percentage: 16.7,
            ),
          ],
          'triceps': [
            ExerciseContribution(
              exerciseName: 'Pushdown',
              muscleGroup: 'triceps',
              volume: 500,
              percentage: 16.7,
            ),
          ],
        },
      );
      expect(breakdown.topExercises(2).length, 2);
      // Sorted by volume desc
      expect(breakdown.topExercises(1).first.exerciseName, 'Bench');
    });

    test('hasData false when no volume', () {
      const breakdown = CategoryBreakdown(
        categoryName: 'Push',
        totalVolume: 0,
        exercisesByMuscle: {},
      );
      expect(breakdown.hasData, isFalse);
    });
  });

  group('RatioBreakdown', () {
    test('empty factory', () {
      final empty = RatioBreakdown.empty();
      expect(empty.hasData, isFalse);
      expect(empty.pushBreakdown.categoryName, 'Push');
      expect(empty.pullBreakdown.categoryName, 'Pull');
      expect(empty.upperBreakdown.categoryName, 'Upper');
      expect(empty.lowerBreakdown.categoryName, 'Lower');
    });

    test('pushPullPair returns correct pair', () {
      final empty = RatioBreakdown.empty();
      final (push, pull) = empty.pushPullPair;
      expect(push.categoryName, 'Push');
      expect(pull.categoryName, 'Pull');
    });

    test('upperLowerPair returns correct pair', () {
      final empty = RatioBreakdown.empty();
      final (upper, lower) = empty.upperLowerPair;
      expect(upper.categoryName, 'Upper');
      expect(lower.categoryName, 'Lower');
    });
  });
}
