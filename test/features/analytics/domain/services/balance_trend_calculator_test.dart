/// BalanceTrendCalculator tests - trends, periods, filtering.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/balance_trend_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';

void main() {
  late BalanceTrendCalculator calculator;

  setUp(() {
    calculator = BalanceTrendCalculator();
  });

  ExerciseHistory _makeHistory({
    required String name,
    required String muscle,
    required double weight,
    required int reps,
    int sets = 3,
    DateTime? date,
  }) {
    final d = date ?? DateTime.now().subtract(const Duration(days: 5));
    final analyticsSets = List.generate(
      sets,
      (i) => AnalyticsSet(weight: weight, reps: reps, date: d),
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
          date: d,
        ),
      ],
    );
  }

  MuscleBalanceMetrics _metricsWithScore(double score) {
    return MuscleBalanceMetrics(
      pushPullRatio: 1.0,
      upperLowerRatio: 1.0,
      pushPullWarning: false,
      upperLowerWarning: false,
      neglectedMuscles: const [],
      topMuscles: const [],
      balanceScore: score,
      muscleVolumePercentages: const {},
    );
  }

  group('TimePeriod', () {
    test('has 5 values', () {
      expect(TimePeriod.values.length, 5);
    });
  });

  group('TrendDirection', () {
    test('has 3 values', () {
      expect(TrendDirection.values.length, 3);
    });
  });

  group('BalanceTrendData', () {
    test('currentRating based on score', () {
      final data = BalanceTrendData(
        currentMetrics: _metricsWithScore(9.5),
        previousMetrics: null,
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        period: TimePeriod.last30Days,
      );
      expect(data.currentRating, 'Excellent');
    });

    test('previousRating null when no previous', () {
      final data = BalanceTrendData(
        currentMetrics: _metricsWithScore(8.0),
        previousMetrics: null,
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        period: TimePeriod.last30Days,
      );
      expect(data.previousRating, isNull);
    });

    test('previousRating returns value when previous exists', () {
      final data = BalanceTrendData(
        currentMetrics: _metricsWithScore(8.0),
        previousMetrics: _metricsWithScore(6.0),
        trendDirection: TrendDirection.improving,
        percentageChange: 33.3,
        period: TimePeriod.last30Days,
      );
      expect(data.previousRating, 'Fair');
    });

    test('rating tiers', () {
      for (final entry in {
        9.5: 'Excellent',
        8.0: 'Good',
        6.5: 'Fair',
        4.5: 'Needs Improvement',
        3.0: 'Poor',
      }.entries) {
        final data = BalanceTrendData(
          currentMetrics: _metricsWithScore(entry.key),
          previousMetrics: null,
          trendDirection: TrendDirection.stable,
          percentageChange: 0.0,
          period: TimePeriod.last30Days,
        );
        expect(data.currentRating, entry.value,
            reason: 'Score ${entry.key} should be ${entry.value}');
      }
    });

    test('rating boundary: exactly 9.0 is Excellent', () {
      final data = BalanceTrendData(
        currentMetrics: _metricsWithScore(9.0),
        previousMetrics: null,
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        period: TimePeriod.last30Days,
      );
      expect(data.currentRating, 'Excellent');
    });

    test('rating boundary: exactly 7.5 is Good', () {
      final data = BalanceTrendData(
        currentMetrics: _metricsWithScore(7.5),
        previousMetrics: null,
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        period: TimePeriod.last30Days,
      );
      expect(data.currentRating, 'Good');
    });

    test('rating boundary: exactly 4.0 is Needs Improvement', () {
      final data = BalanceTrendData(
        currentMetrics: _metricsWithScore(4.0),
        previousMetrics: null,
        trendDirection: TrendDirection.stable,
        percentageChange: 0.0,
        period: TimePeriod.last30Days,
      );
      expect(data.currentRating, 'Needs Improvement');
    });
  });

  group('BalanceTrendCalculator.calculateTrend', () {
    test('empty histories returns stable trend', () {
      final result = calculator.calculateTrend(
        exerciseHistories: [],
        period: TimePeriod.last30Days,
      );
      expect(result.trendDirection, TrendDirection.stable);
      expect(result.percentageChange, 0.0);
    });

    test('recent data returns current metrics', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        _makeHistory(
          name: 'Barbell Row',
          muscle: 'back',
          weight: 100,
          reps: 10,
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      final result = calculator.calculateTrend(
        exerciseHistories: histories,
        period: TimePeriod.last7Days,
      );
      expect(result.currentMetrics.balanceScore, isNotNull);
    });

    test('all time period includes everything', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          date: DateTime(2020, 1, 1),
        ),
      ];
      final result = calculator.calculateTrend(
        exerciseHistories: histories,
        period: TimePeriod.allTime,
      );
      expect(result.period, TimePeriod.allTime);
    });

    test('no previous data returns null previousMetrics', () {
      final histories = [
        _makeHistory(
          name: 'Bench Press',
          muscle: 'chest',
          weight: 100,
          reps: 10,
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      final result = calculator.calculateTrend(
        exerciseHistories: histories,
        period: TimePeriod.last7Days,
      );
      // Only data in current period, nothing in previous
      expect(result.previousMetrics, isNull);
    });
  });

  group('BalanceTrendCalculator.getPeriodDurationInDays', () {
    test('returns correct durations', () {
      expect(calculator.getPeriodDurationInDays(TimePeriod.last7Days), 7);
      expect(calculator.getPeriodDurationInDays(TimePeriod.last30Days), 30);
      expect(calculator.getPeriodDurationInDays(TimePeriod.last3Months), 90);
      expect(calculator.getPeriodDurationInDays(TimePeriod.lastYear), 365);
      expect(calculator.getPeriodDurationInDays(TimePeriod.allTime), 9999);
    });
  });
}
