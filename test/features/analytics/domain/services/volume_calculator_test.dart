import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';

void main() {
  // Helper: Create ExerciseActivitySet
  ExerciseActivitySet createSet({
    int set = 1,
    String weight = '100',
    String reps = '10',
    bool done = true,
    bool isWarmup = false,
    int effort = 5,
    String? actualReps,
  }) {
    return ExerciseActivitySet(
      set: set,
      weight: weight,
      reps: reps,
      actualReps: actualReps,
      done: done,
      isWarmup: isWarmup,
      effort: effort,
    );
  }

  // Helper: Create ExerciseActivity
  ExerciseActivity createActivity({
    String id = 'activity-1',
    String email = 'test@example.com',
    String exerciseId = 'exercise-1',
    String exerciseName = 'Bench Press',
    String schedaName = 'Test Workout',
    required List<ExerciseActivitySet> sets,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return ExerciseActivity(
      id: id,
      email: email,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      schedaName: schedaName,
      sets: sets,
      createdAt: createdAt ?? DateTime.now(),
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  group('calculateTotalVolume', () {
    test('should calculate correct volume for working sets', () {
      final sets = [
        createSet(weight: '100', reps: '10'), // 1000
        createSet(weight: '120', reps: '8'),  // 960
        createSet(weight: '140', reps: '6'),  // 840
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 2800.0); // 1000 + 960 + 840
    });

    test('should count warmup sets at 50%', () {
      final sets = [
        createSet(weight: '60', reps: '10', isWarmup: true),  // 600 * 0.5 = 300
        createSet(weight: '100', reps: '10', isWarmup: false), // 1000
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 1300.0); // 300 + 1000
    });

    test('should skip incomplete sets', () {
      final sets = [
        createSet(weight: '100', reps: '10', done: true),  // 1000
        createSet(weight: '100', reps: '10', done: false), // Skipped
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 1000.0);
    });

    test('should handle empty sets list', () {
      final result = VolumeCalculator.calculateTotalVolume([]);
      expect(result, 0.0);
    });

    test('should handle invalid weight and reps', () {
      final sets = [
        createSet(weight: 'invalid', reps: '10'), // 0 * 10 = 0
        createSet(weight: '100', reps: 'invalid'), // 100 * 0 = 0
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 0.0);
    });

    test('should handle decimal weight values', () {
      final sets = [
        createSet(weight: '100.5', reps: '10'), // 1005
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 1005.0);
    });
  });

  group('calculateTonnage', () {
    test('should be alias for calculateTotalVolume', () {
      final sets = [
        createSet(weight: '100', reps: '10'),
      ];

      final volume = VolumeCalculator.calculateTotalVolume(sets);
      final tonnage = VolumeCalculator.calculateTonnage(sets);

      expect(tonnage, volume);
    });
  });

  group('calculateAverageIntensity', () {
    test('should calculate average weight for working sets', () {
      final sets = [
        createSet(weight: '100', reps: '10'),
        createSet(weight: '120', reps: '8'),
        createSet(weight: '140', reps: '6'),
      ];

      final result = VolumeCalculator.calculateAverageIntensity(sets);

      expect(result, 120.0); // (100 + 120 + 140) / 3
    });

    test('should exclude warmup sets', () {
      final sets = [
        createSet(weight: '60', reps: '10', isWarmup: true),  // Excluded
        createSet(weight: '100', reps: '10'),
        createSet(weight: '120', reps: '8'),
      ];

      final result = VolumeCalculator.calculateAverageIntensity(sets);

      expect(result, 110.0); // (100 + 120) / 2
    });

    test('should exclude incomplete sets', () {
      final sets = [
        createSet(weight: '100', reps: '10', done: false), // Excluded
        createSet(weight: '120', reps: '8', done: true),
      ];

      final result = VolumeCalculator.calculateAverageIntensity(sets);

      expect(result, 120.0);
    });

    test('should return 0 for empty sets', () {
      final result = VolumeCalculator.calculateAverageIntensity([]);
      expect(result, 0.0);
    });

    test('should return 0 when no working sets', () {
      final sets = [
        createSet(weight: '60', reps: '10', isWarmup: true),
        createSet(weight: '80', reps: '10', isWarmup: true),
      ];

      final result = VolumeCalculator.calculateAverageIntensity(sets);

      expect(result, 0.0);
    });
  });

  group('calculateVolumeByMuscleGroup', () {
    test('should categorize chest exercises', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '100', reps: '10')],
        ),
        createActivity(
          exerciseName: 'Chest Fly',
          sets: [createSet(weight: '50', reps: '12')],
        ),
      ];

      final result = VolumeCalculator.calculateVolumeByMuscleGroup(activities);

      expect(result['Chest'], 1600.0); // 1000 + 600
    });

    test('should categorize back exercises', () {
      final activities = [
        createActivity(
          exerciseName: 'Pull Up',
          sets: [createSet(weight: '0', reps: '10')],
        ),
        createActivity(
          exerciseName: 'Bent Over Row',
          sets: [createSet(weight: '100', reps: '8')],
        ),
      ];

      final result = VolumeCalculator.calculateVolumeByMuscleGroup(activities);

      expect(result['Back'], 800.0); // 0 + 800
    });

    test('should categorize multiple muscle groups', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '100', reps: '10')],
        ),
        createActivity(
          exerciseName: 'Squat',
          sets: [createSet(weight: '200', reps: '5')],
        ),
        createActivity(
          exerciseName: 'Shoulder Press',
          sets: [createSet(weight: '60', reps: '10')],
        ),
      ];

      final result = VolumeCalculator.calculateVolumeByMuscleGroup(activities);

      expect(result['Chest'], 1000.0);
      expect(result['Legs'], 1000.0);
      expect(result['Shoulders'], 600.0);
    });

    test('should handle unknown exercises as Other', () {
      final activities = [
        createActivity(
          exerciseName: 'Unknown Exercise',
          sets: [createSet(weight: '100', reps: '10')],
        ),
      ];

      final result = VolumeCalculator.calculateVolumeByMuscleGroup(activities);

      expect(result['Other'], 1000.0);
    });

    test('should handle empty activities', () {
      final result = VolumeCalculator.calculateVolumeByMuscleGroup([]);
      expect(result, isEmpty);
    });
  });

  group('calculateWeeklyVolume', () {
    test('should group activities by week', () {
      final now = DateTime.now();
      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: now.subtract(const Duration(days: 3)), // This week
        ),
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: now.subtract(const Duration(days: 10)), // 1 week ago
        ),
      ];

      final result = VolumeCalculator.calculateWeeklyVolume(activities);

      expect(result, isNotEmpty);
      expect(result.values.any((v) => v == 1000.0), true);
    });

    test('should exclude workouts older than 52 weeks', () {
      final now = DateTime.now();
      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: now.subtract(const Duration(days: 400)), // Too old
        ),
      ];

      final result = VolumeCalculator.calculateWeeklyVolume(activities);

      // Should be empty or not include the old workout
      final totalVolume = result.values.fold(0.0, (sum, v) => sum + v);
      expect(totalVolume, 0.0);
    });

    test('should handle empty activities', () {
      final result = VolumeCalculator.calculateWeeklyVolume([]);
      expect(result, isEmpty);
    });
  });

  group('calculateDailyVolume', () {
    test('should group activities by day', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: today,
        ),
        createActivity(
          sets: [createSet(weight: '120', reps: '8')],
          createdAt: yesterday,
        ),
      ];

      final result = VolumeCalculator.calculateDailyVolume(activities);

      expect(result, hasLength(2));
    });

    test('should exclude activities older than 30 days', () {
      final now = DateTime.now();
      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: now.subtract(const Duration(days: 35)), // Too old
        ),
      ];

      final result = VolumeCalculator.calculateDailyVolume(activities);

      expect(result, isEmpty);
    });

    test('should combine multiple activities on same day', () {
      final today = DateTime.now();

      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: today,
        ),
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: today.add(const Duration(hours: 2)),
        ),
      ];

      final result = VolumeCalculator.calculateDailyVolume(activities);

      // Should have one entry with combined volume
      expect(result, hasLength(1));
      expect(result.values.first, 2000.0);
    });

    test('should handle empty activities', () {
      final result = VolumeCalculator.calculateDailyVolume([]);
      expect(result, isEmpty);
    });
  });

  group('calculateProgression', () {
    test('should calculate weekly and monthly changes', () {
      final now = DateTime.now();
      final activities = [
        // This week - 1000
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        // Last week - 800
        createActivity(
          sets: [createSet(weight: '100', reps: '8')],
          createdAt: now.subtract(const Duration(days: 10)),
        ),
      ];

      final result = VolumeCalculator.calculateProgression(activities);

      expect(result, isA<VolumeProgression>());
      expect(result.currentWeekVolume, greaterThan(0));
    });

    test('should handle no activities', () {
      final result = VolumeCalculator.calculateProgression([]);

      expect(result.currentWeekVolume, 0.0);
      expect(result.currentMonthVolume, 0.0);
    });
  });

  group('calculateTrainingDensity', () {
    test('should calculate volume per minute', () {
      final sets = [
        createSet(weight: '100', reps: '10'), // 1000
      ];
      final duration = const Duration(minutes: 10);

      final result = VolumeCalculator.calculateTrainingDensity(sets, duration);

      expect(result, 100.0); // 1000 / 10
    });

    test('should return 0 for zero duration', () {
      final sets = [
        createSet(weight: '100', reps: '10'),
      ];
      final duration = Duration.zero;

      final result = VolumeCalculator.calculateTrainingDensity(sets, duration);

      expect(result, 0.0);
    });

    test('should handle high density workouts', () {
      final sets = [
        createSet(weight: '100', reps: '10'),
        createSet(weight: '100', reps: '10'),
        createSet(weight: '100', reps: '10'),
      ];
      final duration = const Duration(minutes: 5);

      final result = VolumeCalculator.calculateTrainingDensity(sets, duration);

      expect(result, 600.0); // 3000 / 5
    });
  });

  group('calculateEffectiveReps', () {
    test('should calculate effective reps with effort multiplier', () {
      final sets = [
        createSet(reps: '10', effort: 5), // 10 * 1.1 = 11 (effort 5 = 110%)
      ];

      final result = VolumeCalculator.calculateEffectiveReps(sets);

      expect(result, 11); // 10 * (0.6 + 5*0.1) = 11
    });

    test('should count warmup sets at 50%', () {
      final sets = [
        createSet(reps: '10', effort: 5, isWarmup: true), // 10 * 1.1 * 0.5 = 5.5 → 6
      ];

      final result = VolumeCalculator.calculateEffectiveReps(sets);

      expect(result, 6); // Rounded
    });

    test('should adjust for low effort', () {
      final sets = [
        createSet(reps: '10', effort: 1), // 10 * 0.7 = 7 (effort 1 = 70%)
      ];

      final result = VolumeCalculator.calculateEffectiveReps(sets);

      expect(result, 7); // 10 * (0.6 + 1*0.1) = 7
    });

    test('should skip incomplete sets', () {
      final sets = [
        createSet(reps: '10', effort: 5, done: false), // Skipped
        createSet(reps: '10', effort: 5, done: true),  // 11
      ];

      final result = VolumeCalculator.calculateEffectiveReps(sets);

      expect(result, 11);
    });

    test('should use actualReps when available', () {
      final sets = [
        createSet(reps: '10', actualReps: '8', effort: 5), // Use 8 not 10
      ];

      final result = VolumeCalculator.calculateEffectiveReps(sets);

      expect(result, 9); // 8 * (0.6 + 5*0.1) = 8.8 → 9
    });

    test('should handle empty sets', () {
      final result = VolumeCalculator.calculateEffectiveReps([]);
      expect(result, 0);
    });
  });

  group('calculateRelativeVolume', () {
    test('should calculate volume per body weight', () {
      final result = VolumeCalculator.calculateRelativeVolume(1000.0, 80.0);
      expect(result, 12.5); // 1000 / 80
    });

    test('should return 0 for zero body weight', () {
      final result = VolumeCalculator.calculateRelativeVolume(1000.0, 0.0);
      expect(result, 0.0);
    });

    test('should return 0 for negative body weight', () {
      final result = VolumeCalculator.calculateRelativeVolume(1000.0, -80.0);
      expect(result, 0.0);
    });

    test('should handle decimal values', () {
      final result = VolumeCalculator.calculateRelativeVolume(2500.0, 82.5);
      expect(result, closeTo(30.30, 0.01));
    });
  });

  group('getVolumeStats', () {
    test('should calculate complete statistics', () {
      final activities = [
        createActivity(sets: [createSet(weight: '100', reps: '10')]), // 1000
        createActivity(sets: [createSet(weight: '120', reps: '10')]), // 1200
        createActivity(sets: [createSet(weight: '140', reps: '10')]), // 1400
        createActivity(sets: [createSet(weight: '160', reps: '10')]), // 1600
        createActivity(sets: [createSet(weight: '180', reps: '10')]), // 1800
      ];

      final result = VolumeCalculator.getVolumeStats(activities);

      expect(result.total, 7000.0);
      expect(result.average, 1400.0);
      expect(result.median, 1400.0);
      expect(result.min, 1000.0);
      expect(result.max, 1800.0);
      expect(result.count, 5);
      expect(result.standardDeviation, greaterThan(0));
    });

    test('should calculate median for even count', () {
      final activities = [
        createActivity(sets: [createSet(weight: '100', reps: '10')]), // 1000
        createActivity(sets: [createSet(weight: '120', reps: '10')]), // 1200
        createActivity(sets: [createSet(weight: '140', reps: '10')]), // 1400
        createActivity(sets: [createSet(weight: '160', reps: '10')]), // 1600
      ];

      final result = VolumeCalculator.getVolumeStats(activities);

      expect(result.median, 1300.0); // (1200 + 1400) / 2
    });

    test('should return empty stats for no activities', () {
      final result = VolumeCalculator.getVolumeStats([]);

      expect(result.total, 0.0);
      expect(result.average, 0.0);
      expect(result.median, 0.0);
      expect(result.min, 0.0);
      expect(result.max, 0.0);
      expect(result.standardDeviation, 0.0);
      expect(result.count, 0);
    });

    test('should calculate coefficient of variation', () {
      final activities = [
        createActivity(sets: [createSet(weight: '100', reps: '10')]),
        createActivity(sets: [createSet(weight: '120', reps: '10')]),
      ];

      final result = VolumeCalculator.getVolumeStats(activities);

      expect(result.coefficientOfVariation, greaterThan(0));
    });
  });

  group('VolumeProgression', () {
    test('isImproving should be true when both changes positive', () {
      const progression = VolumeProgression(
        weeklyChange: 10.0,
        monthlyChange: 5.0,
        currentWeekVolume: 1000,
        currentMonthVolume: 4000,
      );

      expect(progression.isImproving, true);
    });

    test('isImproving should be false when either change negative', () {
      const progression = VolumeProgression(
        weeklyChange: -10.0,
        monthlyChange: 5.0,
        currentWeekVolume: 1000,
        currentMonthVolume: 4000,
      );

      expect(progression.isImproving, false);
    });

    test('isPlateau should be true when changes small', () {
      const progression = VolumeProgression(
        weeklyChange: 3.0,
        monthlyChange: -2.0,
        currentWeekVolume: 1000,
        currentMonthVolume: 4000,
      );

      expect(progression.isPlateau, true);
    });

    test('isPlateau should be false when changes large', () {
      const progression = VolumeProgression(
        weeklyChange: 10.0,
        monthlyChange: 15.0,
        currentWeekVolume: 1000,
        currentMonthVolume: 4000,
      );

      expect(progression.isPlateau, false);
    });
  });

  group('VolumeStats', () {
    test('coefficientOfVariation should calculate correctly', () {
      const stats = VolumeStats(
        total: 1000,
        average: 100.0,
        median: 100.0,
        min: 50.0,
        max: 150.0,
        standardDeviation: 20.0,
        count: 10,
      );

      expect(stats.coefficientOfVariation, 20.0); // (20 / 100) * 100
    });

    test('coefficientOfVariation should return 0 for zero average', () {
      const stats = VolumeStats(
        total: 0,
        average: 0.0,
        median: 0.0,
        min: 0.0,
        max: 0.0,
        standardDeviation: 0.0,
        count: 0,
      );

      expect(stats.coefficientOfVariation, 0.0);
    });

    test('empty factory should create zero stats', () {
      final stats = VolumeStats.empty();

      expect(stats.total, 0);
      expect(stats.average, 0);
      expect(stats.median, 0);
      expect(stats.min, 0);
      expect(stats.max, 0);
      expect(stats.standardDeviation, 0);
      expect(stats.count, 0);
    });
  });

  group('Integration Tests', () {
    test('should handle complete workout analysis workflow', () {
      final now = DateTime.now();
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [
            createSet(weight: '60', reps: '10', isWarmup: true),
            createSet(weight: '100', reps: '10'),
            createSet(weight: '100', reps: '8'),
            createSet(weight: '100', reps: '6'),
          ],
          createdAt: now,
        ),
        createActivity(
          exerciseName: 'Squat',
          sets: [
            createSet(weight: '140', reps: '10'),
            createSet(weight: '140', reps: '10'),
            createSet(weight: '140', reps: '8'),
          ],
          createdAt: now,
        ),
      ];

      // Test all calculations work together
      final volumeByGroup = VolumeCalculator.calculateVolumeByMuscleGroup(activities);
      final stats = VolumeCalculator.getVolumeStats(activities);
      final dailyVolume = VolumeCalculator.calculateDailyVolume(activities);

      expect(volumeByGroup, isNotEmpty);
      expect(stats.count, 2);
      expect(dailyVolume, hasLength(1));
    });
  });

  group('Edge Cases', () {
    test('should handle very large volumes', () {
      final sets = [
        createSet(weight: '999999', reps: '999'),
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, greaterThan(0));
    });

    test('should handle zero weight', () {
      final sets = [
        createSet(weight: '0', reps: '10'),
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 0.0);
    });

    test('should handle zero reps', () {
      final sets = [
        createSet(weight: '100', reps: '0'),
      ];

      final result = VolumeCalculator.calculateTotalVolume(sets);

      expect(result, 0.0);
    });
  });
}
