/// MuscleBalanceCalculator tests - push/pull, upper/lower ratios, balance score.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';

void main() {
  late MuscleBalanceCalculator calculator;

  setUp(() {
    calculator = MuscleBalanceCalculator();
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

  group('MuscleBalanceCalculator', () {
    test('empty histories returns empty metrics', () {
      final metrics = calculator.calculateBalance([]);
      expect(metrics.pushPullRatio, 1.0);
      expect(metrics.upperLowerRatio, 1.0);
      expect(metrics.balanceScore, 10.0);
      expect(metrics.pushPullWarning, isFalse);
      expect(metrics.upperLowerWarning, isFalse);
      expect(metrics.neglectedMuscles, isEmpty);
    });

    test('balanced push/pull gives ratio ~1.0', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
        ),
        _makeHistory(
          name: 'Barbell Row',
          muscle: 'back',
          weight: 100,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.pushPullRatio, closeTo(1.0, 0.01));
      expect(metrics.pushPullWarning, isFalse);
    });

    test('push-dominant triggers warning', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 6,
        ),
        _makeHistory(
          name: 'Barbell Row',
          muscle: 'back',
          weight: 50,
          reps: 10,
          sets: 3,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.pushPullRatio, greaterThan(1.5));
      expect(metrics.pushPullWarning, isTrue);
    });

    test('upper-dominant triggers warning', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 5,
        ),
        _makeHistory(
          name: 'Barbell Row',
          muscle: 'back',
          weight: 100,
          reps: 10,
          sets: 5,
        ),
        _makeHistory(
          name: 'Squat',
          muscle: 'quads',
          weight: 50,
          reps: 5,
          sets: 2,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.upperLowerRatio, greaterThan(1.5));
      expect(metrics.upperLowerWarning, isTrue);
    });

    test('balance score decreases with imbalances', () {
      final imbalanced = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(imbalanced);
      expect(metrics.balanceScore, lessThan(10.0));
    });

    test('neglected muscles detected under 5%', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 10,
        ),
        _makeHistory(
          name: 'Squat',
          muscle: 'quads',
          weight: 100,
          reps: 10,
          sets: 10,
        ),
        _makeHistory(
          name: 'Lateral Raise',
          muscle: 'shoulders',
          weight: 5,
          reps: 10,
          sets: 1,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      // shoulders volume (50) vs total (~6050), <5%
      expect(metrics.neglectedMuscles, contains('shoulders'));
    });

    test('top muscles detected over 15%', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          sets: 5,
        ),
        _makeHistory(
          name: 'Curl',
          muscle: 'biceps',
          weight: 10,
          reps: 10,
          sets: 1,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.topMuscles, contains('chest'));
    });

    test('name inference: squat classified as quads (push/lower)', () {
      final histories = [
        _makeHistory(
          name: 'Squat',
          muscle: 'legs', // generic stored value
          weight: 100,
          reps: 10,
        ),
        _makeHistory(
          name: 'Lat Pulldown',
          muscle: 'back',
          weight: 100,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      // Squat inferred as quads (push + lower)
      expect(metrics.muscleVolumePercentages.containsKey('quads'), isTrue);
    });

    test('name inference: bench press classified as chest (push/upper)', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'generic',
          weight: 100,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.muscleVolumePercentages.containsKey('chest'), isTrue);
    });

    test('name inference: barbell row classified as back (pull/upper)', () {
      final histories = [
        _makeHistory(
          name: 'Barbell Row',
          muscle: 'generic',
          weight: 100,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.muscleVolumePercentages.containsKey('back'), isTrue);
    });

    test('name inference: leg curl classified as hamstrings (pull/lower)', () {
      final histories = [
        _makeHistory(
          name: 'Leg Curl',
          muscle: 'generic',
          weight: 50,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(
        metrics.muscleVolumePercentages.containsKey('hamstrings'),
        isTrue,
      );
    });

    test('name inference: bicep curl classified as biceps (pull)', () {
      final histories = [
        _makeHistory(
          name: 'Bicep Curl',
          muscle: 'generic',
          weight: 20,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.muscleVolumePercentages.containsKey('biceps'), isTrue);
    });

    test('name inference: tricep pushdown classified as triceps (push)', () {
      final histories = [
        _makeHistory(
          name: 'Tricep Pushdown',
          muscle: 'generic',
          weight: 30,
          reps: 10,
        ),
      ];
      final metrics = calculator.calculateBalance(histories);
      expect(metrics.muscleVolumePercentages.containsKey('triceps'), isTrue);
    });
  });

  group('MuscleBalanceMetrics', () {
    test('empty factory', () {
      final empty = MuscleBalanceMetrics.empty();
      expect(empty.pushPullRatio, 1.0);
      expect(empty.upperLowerRatio, 1.0);
      expect(empty.balanceScore, 10.0);
      expect(empty.hasWarnings, isFalse);
      expect(empty.balanceRating, 'Excellent');
    });

    test('hasWarnings when push/pull warning', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 2.0,
        upperLowerRatio: 1.0,
        pushPullWarning: true,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 8.0,
        muscleVolumePercentages: {},
      );
      expect(metrics.hasWarnings, isTrue);
    });

    test('hasWarnings when neglected muscles present', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: ['calves'],
        topMuscles: [],
        balanceScore: 9.0,
        muscleVolumePercentages: {},
      );
      expect(metrics.hasWarnings, isTrue);
    });

    test('balanceRating tiers', () {
      expect(
        const MuscleBalanceMetrics(
          pushPullRatio: 1.0,
          upperLowerRatio: 1.0,
          pushPullWarning: false,
          upperLowerWarning: false,
          neglectedMuscles: [],
          topMuscles: [],
          balanceScore: 9.5,
          muscleVolumePercentages: {},
        ).balanceRating,
        'Excellent',
      );
      expect(
        const MuscleBalanceMetrics(
          pushPullRatio: 1.0,
          upperLowerRatio: 1.0,
          pushPullWarning: false,
          upperLowerWarning: false,
          neglectedMuscles: [],
          topMuscles: [],
          balanceScore: 8.0,
          muscleVolumePercentages: {},
        ).balanceRating,
        'Good',
      );
      expect(
        const MuscleBalanceMetrics(
          pushPullRatio: 1.0,
          upperLowerRatio: 1.0,
          pushPullWarning: false,
          upperLowerWarning: false,
          neglectedMuscles: [],
          topMuscles: [],
          balanceScore: 6.5,
          muscleVolumePercentages: {},
        ).balanceRating,
        'Fair',
      );
      expect(
        const MuscleBalanceMetrics(
          pushPullRatio: 1.0,
          upperLowerRatio: 1.0,
          pushPullWarning: false,
          upperLowerWarning: false,
          neglectedMuscles: [],
          topMuscles: [],
          balanceScore: 5.0,
          muscleVolumePercentages: {},
        ).balanceRating,
        'Needs Improvement',
      );
      expect(
        const MuscleBalanceMetrics(
          pushPullRatio: 1.0,
          upperLowerRatio: 1.0,
          pushPullWarning: false,
          upperLowerWarning: false,
          neglectedMuscles: [],
          topMuscles: [],
          balanceScore: 3.0,
          muscleVolumePercentages: {},
        ).balanceRating,
        'Poor',
      );
    });

    test('nextWorkoutSuggestion when no warnings', () {
      final metrics = MuscleBalanceMetrics.empty();
      expect(metrics.nextWorkoutSuggestion, isNull);
    });

    test('nextWorkoutSuggestion for upper push/pull imbalance', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 8.0,
        muscleVolumePercentages: {},
        upperPushPullRatio: 2.0,
        upperPushPullWarning: true,
      );
      expect(metrics.nextWorkoutSuggestion, contains('pull'));
    });

    test('nextWorkoutSuggestion for lower push/pull imbalance', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 8.0,
        muscleVolumePercentages: {},
        lowerPushPullRatio: 2.0,
        lowerPushPullWarning: true,
      );
      expect(metrics.nextWorkoutSuggestion, contains('hamstrings'));
    });

    test('nextWorkoutSuggestion for upper/lower imbalance', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 2.0,
        pushPullWarning: false,
        upperLowerWarning: true,
        neglectedMuscles: [],
        topMuscles: [],
        balanceScore: 8.0,
        muscleVolumePercentages: {},
      );
      expect(metrics.nextWorkoutSuggestion, contains('leg'));
    });

    test('nextWorkoutSuggestion for neglected muscles', () {
      const metrics = MuscleBalanceMetrics(
        pushPullRatio: 1.0,
        upperLowerRatio: 1.0,
        pushPullWarning: false,
        upperLowerWarning: false,
        neglectedMuscles: ['calves'],
        topMuscles: [],
        balanceScore: 9.0,
        muscleVolumePercentages: {},
      );
      expect(metrics.nextWorkoutSuggestion, contains('calves'));
    });
  });
}
