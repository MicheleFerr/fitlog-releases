/// AnalyticsCalculationService tests - volume, 1RM, frequency, streaks.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/analytics_calculation_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  late AnalyticsCalculationService service;

  setUp(() {
    service = AnalyticsCalculationService();
  });

  ExerciseActivity _makeActivity({
    String exerciseId = 'bench_press',
    String name = 'Bench Press',
    required DateTime date,
    List<ExerciseActivitySet>? sets,
  }) {
    return ExerciseActivity(
      id: 'a_${date.millisecondsSinceEpoch}',
      email: 'test@test.com',
      exerciseId: exerciseId,
      exerciseName: name,
      schedaName: 'Test',
      sets: sets ??
          [
            ExerciseActivitySet(
              set: 1,
              weight: '100',
              reps: '10',
              done: true,
              effort: 3,
            ),
            ExerciseActivitySet(
              set: 2,
              weight: '100',
              reps: '10',
              done: true,
              effort: 3,
            ),
            ExerciseActivitySet(
              set: 3,
              weight: '100',
              reps: '10',
              done: true,
              effort: 3,
            ),
          ],
      createdAt: date,
      lastModified: date,
      category: ExerciseCategory.chest,
    );
  }

  group('getVolumeByPeriod', () {
    test('empty activities returns empty map', () {
      final result = service.getVolumeByPeriod([], AnalysisPeriod.week);
      expect(result, isEmpty);
    });

    test('weekly grouping aggregates by week start', () {
      final activities = [
        _makeActivity(date: DateTime(2025, 1, 6)), // Monday
        _makeActivity(date: DateTime(2025, 1, 7)), // Tuesday same week
        _makeActivity(date: DateTime(2025, 1, 13)), // Next Monday
      ];
      final result = service.getVolumeByPeriod(activities, AnalysisPeriod.week);
      expect(result.length, 2); // Two different weeks
    });

    test('monthly grouping', () {
      final activities = [
        _makeActivity(date: DateTime(2025, 1, 5)),
        _makeActivity(date: DateTime(2025, 1, 20)),
        _makeActivity(date: DateTime(2025, 2, 5)),
      ];
      final result = service.getVolumeByPeriod(activities, AnalysisPeriod.month);
      expect(result.length, 2); // Jan and Feb
    });

    test('quarterly grouping', () {
      final activities = [
        _makeActivity(date: DateTime(2025, 1, 15)),
        _makeActivity(date: DateTime(2025, 3, 15)),
        _makeActivity(date: DateTime(2025, 4, 15)),
      ];
      final result =
          service.getVolumeByPeriod(activities, AnalysisPeriod.quarter);
      expect(result.length, 2); // Q1 and Q2
    });

    test('yearly grouping', () {
      final activities = [
        _makeActivity(date: DateTime(2024, 6, 15)),
        _makeActivity(date: DateTime(2025, 3, 15)),
      ];
      final result = service.getVolumeByPeriod(activities, AnalysisPeriod.year);
      expect(result.length, 2); // 2024 and 2025
    });

    test('volume calculated correctly from sets', () {
      final activities = [
        _makeActivity(
          date: DateTime(2025, 1, 6),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '100',
              reps: '10',
              done: true,
              effort: 3,
            ),
          ],
        ),
      ];
      final result = service.getVolumeByPeriod(activities, AnalysisPeriod.week);
      // Volume = 100 * 10 = 1000
      expect(result.values.first, 1000.0);
    });
  });

  group('get1RMProgression', () {
    test('empty activities returns empty map', () {
      final result = service.get1RMProgression([], 'bench_press');
      expect(result, isEmpty);
    });

    test('filters by exerciseId', () {
      final activities = [
        _makeActivity(
          exerciseId: 'bench_press',
          date: DateTime(2025, 1, 1),
        ),
        _makeActivity(
          exerciseId: 'squat',
          date: DateTime(2025, 1, 2),
        ),
      ];
      final result = service.get1RMProgression(activities, 'bench_press');
      expect(result.length, 1);
    });

    test('skips warmup and undone sets', () {
      final activities = [
        _makeActivity(
          date: DateTime(2025, 1, 1),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '60',
              reps: '10',
              done: true,
              effort: 1,
              isWarmup: true,
            ),
            ExerciseActivitySet(
              set: 2,
              weight: '100',
              reps: '5',
              done: true,
              effort: 4,
            ),
            ExerciseActivitySet(
              set: 3,
              weight: '110',
              reps: '3',
              done: false, // not done
              effort: 5,
            ),
          ],
        ),
      ];
      final result = service.get1RMProgression(activities, 'bench_press');
      expect(result.length, 1);
      // Only set 2 counted (100kg x 5 reps)
      expect(result.values.first, greaterThan(100));
    });

    test('progression sorted by date', () {
      final activities = [
        _makeActivity(
          date: DateTime(2025, 1, 10),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '110',
              reps: '5',
              done: true,
              effort: 4,
            ),
          ],
        ),
        _makeActivity(
          date: DateTime(2025, 1, 1),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '100',
              reps: '5',
              done: true,
              effort: 4,
            ),
          ],
        ),
      ];
      final result = service.get1RMProgression(activities, 'bench_press');
      final dates = result.keys.toList();
      expect(dates.first.isBefore(dates.last), isTrue);
    });
  });

  group('calculateCurrentStreak', () {
    test('empty activities returns 0', () {
      expect(service.calculateCurrentStreak([]), 0);
    });

    test('workout today starts streak at 1', () {
      final activities = [
        _makeActivity(date: DateTime.now()),
      ];
      expect(service.calculateCurrentStreak(activities), 1);
    });

    test('workout yesterday counts', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final activities = [
        _makeActivity(date: yesterday),
      ];
      expect(service.calculateCurrentStreak(activities), 1);
    });

    test('consecutive days build streak', () {
      final now = DateTime.now();
      final activities = [
        _makeActivity(date: now),
        _makeActivity(date: now.subtract(const Duration(days: 1))),
        _makeActivity(date: now.subtract(const Duration(days: 2))),
      ];
      expect(service.calculateCurrentStreak(activities), 3);
    });

    test('gap in days breaks streak', () {
      final now = DateTime.now();
      final activities = [
        _makeActivity(date: now),
        _makeActivity(date: now.subtract(const Duration(days: 3))),
      ];
      expect(service.calculateCurrentStreak(activities), 1);
    });

    test('old workouts (>1 day ago) return 0 streak', () {
      final activities = [
        _makeActivity(
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      expect(service.calculateCurrentStreak(activities), 0);
    });
  });

  group('getFrequencyStats', () {
    test('empty activities returns zero stats', () {
      final stats = service.getFrequencyStats([]);
      expect(stats['daysInLast30'], 0);
      expect(stats['avgPerWeek'], 0);
      expect(stats['currentStreak'], 0);
    });

    test('counts unique workout days', () {
      final now = DateTime.now();
      final activities = [
        _makeActivity(date: now),
        _makeActivity(
          exerciseId: 'squat',
          date: now,
        ), // Same day, different exercise
        _makeActivity(
          date: now.subtract(const Duration(days: 1)),
        ),
      ];
      final stats = service.getFrequencyStats(activities);
      expect(stats['daysInLast30'], 2); // 2 unique days
    });

    test('dayDistribution tracks weekday counts', () {
      final now = DateTime.now();
      final activities = [
        _makeActivity(date: now),
      ];
      final stats = service.getFrequencyStats(activities);
      final dayDist = stats['dayDistribution'] as Map<int, int>;
      expect(dayDist[now.weekday], 1);
    });
  });

  group('getExerciseStats', () {
    test('empty activities returns empty map', () {
      final stats = service.getExerciseStats([], 'bench_press');
      expect(stats, isEmpty);
    });

    test('tracks max weight and reps', () {
      final activities = [
        _makeActivity(
          date: DateTime(2025, 1, 1),
          sets: [
            ExerciseActivitySet(
              set: 1,
              weight: '80',
              reps: '10',
              done: true,
              effort: 3,
            ),
            ExerciseActivitySet(
              set: 2,
              weight: '100',
              reps: '5',
              done: true,
              effort: 4,
            ),
          ],
        ),
      ];
      final stats = service.getExerciseStats(activities, 'bench_press');
      expect(stats['maxWeight'], 100.0);
      expect(stats['maxReps'], 10);
      expect(stats['estimated1RM'], greaterThan(0));
    });
  });

  group('calculateExerciseTrends', () {
    test('returns trends for top exercises', () async {
      final activities = [
        _makeActivity(
          exerciseId: 'bench',
          date: DateTime(2025, 1, 1),
        ),
        _makeActivity(
          exerciseId: 'bench',
          date: DateTime(2025, 1, 8),
        ),
        _makeActivity(
          exerciseId: 'squat',
          date: DateTime(2025, 1, 1),
        ),
      ];
      final trends = await service.calculateExerciseTrends(activities, limit: 2);
      expect(trends.length, 2);
      expect(trends.containsKey('bench'), isTrue);
    });

    test('respects limit parameter', () async {
      final activities = [
        _makeActivity(exerciseId: 'ex1', date: DateTime(2025, 1, 1)),
        _makeActivity(exerciseId: 'ex2', date: DateTime(2025, 1, 1)),
        _makeActivity(exerciseId: 'ex3', date: DateTime(2025, 1, 1)),
      ];
      final trends = await service.calculateExerciseTrends(activities, limit: 1);
      expect(trends.length, 1);
    });
  });
}
