import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';

void main() {
  // Helper to create ExerciseSetData
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

  group('TrendDirection enum', () {
    test('has three values: improving, declining, stable', () {
      expect(TrendDirection.values.length, equals(3));
      expect(TrendDirection.values, contains(TrendDirection.improving));
      expect(TrendDirection.values, contains(TrendDirection.declining));
      expect(TrendDirection.values, contains(TrendDirection.stable));
    });
  });

  group('TimePeriod enum', () {
    test('has five values', () {
      expect(TimePeriod.values.length, equals(5));
    });
  });

  group('TrendCalculation extension - calculateWeightTrend', () {
    test('returns stable for empty list', () {
      final sets = <ExerciseSetData>[];
      expect(sets.calculateWeightTrend(), equals(TrendDirection.stable));
    });

    test('returns stable for single set', () {
      final sets = [buildSet(date: DateTime(2025, 1, 1))];
      expect(sets.calculateWeightTrend(), equals(TrendDirection.stable));
    });

    test('detects improving trend when second half weight is higher', () {
      // First half avg: (60+60) / 2 = 60
      // Second half avg: (90+90) / 2 = 90
      // Change: 50% > 5% threshold → improving
      final sets = [
        buildSet(date: DateTime(2025, 1, 1), weight: 60),
        buildSet(date: DateTime(2025, 1, 8), weight: 60),
        buildSet(date: DateTime(2025, 1, 15), weight: 90),
        buildSet(date: DateTime(2025, 1, 22), weight: 90),
      ];

      expect(sets.calculateWeightTrend(), equals(TrendDirection.improving));
    });

    test('detects declining trend when second half weight is lower', () {
      // First half avg: (100+100) / 2 = 100
      // Second half avg: (60+60) / 2 = 60
      // Change: -40% < -5% threshold → declining
      final sets = [
        buildSet(date: DateTime(2025, 1, 1), weight: 100),
        buildSet(date: DateTime(2025, 1, 8), weight: 100),
        buildSet(date: DateTime(2025, 1, 15), weight: 60),
        buildSet(date: DateTime(2025, 1, 22), weight: 60),
      ];

      expect(sets.calculateWeightTrend(), equals(TrendDirection.declining));
    });

    test('returns stable when change is within ±5%', () {
      // First half avg: (80+80) / 2 = 80
      // Second half avg: (82+82) / 2 = 82
      // Change: 2.5% within ±5% → stable
      final sets = [
        buildSet(date: DateTime(2025, 1, 1), weight: 80),
        buildSet(date: DateTime(2025, 1, 8), weight: 80),
        buildSet(date: DateTime(2025, 1, 15), weight: 82),
        buildSet(date: DateTime(2025, 1, 22), weight: 82),
      ];

      expect(sets.calculateWeightTrend(), equals(TrendDirection.stable));
    });
  });

  group('TrendCalculation extension - calculateVolumeTrend', () {
    test('returns stable for empty list', () {
      final sets = <ExerciseSetData>[];
      expect(sets.calculateVolumeTrend(), equals(TrendDirection.stable));
    });

    test('detects improving volume trend', () {
      // First half volume avg: 400, second half: 800 → +100% → improving
      final sets = [
        buildSet(date: DateTime(2025, 1, 1), weight: 40, reps: 10, volume: 400),
        buildSet(date: DateTime(2025, 1, 8), weight: 40, reps: 10, volume: 400),
        buildSet(
          date: DateTime(2025, 1, 15),
          weight: 80,
          reps: 10,
          volume: 800,
        ),
        buildSet(
          date: DateTime(2025, 1, 22),
          weight: 80,
          reps: 10,
          volume: 800,
        ),
      ];

      expect(sets.calculateVolumeTrend(), equals(TrendDirection.improving));
    });

    test('detects declining volume trend', () {
      // First half volume avg: 800, second half: 400 → -50% → declining
      final sets = [
        buildSet(date: DateTime(2025, 1, 1), weight: 80, reps: 10, volume: 800),
        buildSet(date: DateTime(2025, 1, 8), weight: 80, reps: 10, volume: 800),
        buildSet(
          date: DateTime(2025, 1, 15),
          weight: 40,
          reps: 10,
          volume: 400,
        ),
        buildSet(
          date: DateTime(2025, 1, 22),
          weight: 40,
          reps: 10,
          volume: 400,
        ),
      ];

      expect(sets.calculateVolumeTrend(), equals(TrendDirection.declining));
    });
  });

  group('ExerciseProgressMetrics - getSetsInPeriod', () {
    late List<ExerciseSetData> allSets;
    late ExerciseProgressMetrics metrics;

    setUp(() {
      final now = DateTime.now();
      allSets = [
        // Within 1 week
        buildSet(date: now.subtract(const Duration(days: 3)), weight: 80),
        // Within 1 month (but not 1 week)
        buildSet(date: now.subtract(const Duration(days: 15)), weight: 75),
        // Within 3 months (but not 1 month)
        buildSet(date: now.subtract(const Duration(days: 60)), weight: 70),
        // Within 1 year (but not 3 months)
        buildSet(date: now.subtract(const Duration(days: 200)), weight: 65),
        // Very old (more than 1 year)
        buildSet(date: now.subtract(const Duration(days: 400)), weight: 60),
      ];

      metrics = ExerciseProgressMetrics(
        exerciseName: 'Squat',
        totalSessions: 5,
        maxWeight: 80.0,
        averageWeight: 70.0,
        averageReps: 8.0,
        averageRPE: 7.0,
        totalVolume: 5000.0,
        lastWorkoutDate: now.subtract(const Duration(days: 3)),
        weightTrend: TrendDirection.improving,
        volumeTrend: TrendDirection.stable,
        allSets: allSets,
      );
    });

    test('TimePeriod.all returns all sets', () {
      final result = metrics.getSetsInPeriod(TimePeriod.all);
      expect(result.length, equals(5));
    });

    test('TimePeriod.week returns sets within 7 days', () {
      final result = metrics.getSetsInPeriod(TimePeriod.week);
      expect(result.length, equals(1));
    });

    test('TimePeriod.month returns sets within 30 days', () {
      final result = metrics.getSetsInPeriod(TimePeriod.month);
      expect(result.length, equals(2));
    });

    test('TimePeriod.threeMonths returns sets within 90 days', () {
      final result = metrics.getSetsInPeriod(TimePeriod.threeMonths);
      expect(result.length, equals(3));
    });

    test('TimePeriod.year returns sets within 365 days', () {
      final result = metrics.getSetsInPeriod(TimePeriod.year);
      expect(result.length, equals(4));
    });

    test('getSetsInPeriod.week returns empty when no recent sets', () {
      final oldSets = [
        buildSet(date: DateTime.now().subtract(const Duration(days: 30))),
      ];
      final m = ExerciseProgressMetrics(
        exerciseName: 'Pull Up',
        totalSessions: 1,
        maxWeight: 0.0,
        averageWeight: 0.0,
        averageReps: 10.0,
        averageRPE: 6.0,
        totalVolume: 0.0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 30)),
        weightTrend: TrendDirection.stable,
        volumeTrend: TrendDirection.stable,
        allSets: oldSets,
      );

      expect(m.getSetsInPeriod(TimePeriod.week), isEmpty);
    });

    test('TimePeriod.week includes a set exactly 6 days ago', () {
      final now = DateTime.now();
      final boundaryDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));

      final m = ExerciseProgressMetrics(
        exerciseName: 'Pull Up',
        totalSessions: 1,
        maxWeight: 0.0,
        averageWeight: 0.0,
        averageReps: 10.0,
        averageRPE: 6.0,
        totalVolume: 0.0,
        lastWorkoutDate: boundaryDate,
        weightTrend: TrendDirection.stable,
        volumeTrend: TrendDirection.stable,
        allSets: [buildSet(date: boundaryDate)],
      );

      expect(m.getSetsInPeriod(TimePeriod.week), hasLength(1));
    });
  });
}
