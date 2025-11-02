import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/chart_data_service.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/chart_data.dart';
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
  }) {
    return ExerciseActivitySet(
      set: set,
      weight: weight,
      reps: reps,
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
    required DateTime createdAt,
    DateTime? lastModified,
  }) {
    return ExerciseActivity(
      id: id,
      email: email,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      schedaName: schedaName,
      sets: sets,
      createdAt: createdAt,
      lastModified: lastModified ?? createdAt,
    );
  }

  group('generateWeeklyVolumeChart', () {
    test('should group activities by week and calculate volume', () {
      final baseDate = DateTime(2024, 1, 1); // Monday
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '100', reps: '10')], // 1000
          createdAt: baseDate,
        ),
        createActivity(
          exerciseName: 'Squat',
          sets: [createSet(weight: '120', reps: '8')], // 960
          createdAt: baseDate.add(const Duration(days: 2)),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.name, 'Volume Settimanale');
      expect(result.dataPoints.length, 1); // Same week
      expect(result.dataPoints.first.value, 1960.0); // 1000 + 960
      expect(result.color, Colors.blue);
      expect(result.showTrendline, true);
    });

    test('should create separate data points for different weeks', () {
      final week1 = DateTime(2024, 1, 1);
      final week2 = DateTime(2024, 1, 8);
      final week3 = DateTime(2024, 1, 15);

      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: week1,
        ),
        createActivity(
          sets: [createSet(weight: '120', reps: '8')],
          createdAt: week2,
        ),
        createActivity(
          sets: [createSet(weight: '140', reps: '6')],
          createdAt: week3,
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.length, 3);
      expect(result.dataPoints[0].value, 1000.0); // Week 1
      expect(result.dataPoints[1].value, 960.0);  // Week 2
      expect(result.dataPoints[2].value, 840.0);  // Week 3
    });

    test('should aggregate multiple activities in same week', () {
      final monday = DateTime(2024, 1, 1);
      final wednesday = DateTime(2024, 1, 3);
      final friday = DateTime(2024, 1, 5);

      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: monday,
        ),
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: wednesday,
        ),
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: friday,
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.length, 1);
      expect(result.dataPoints.first.value, 3000.0); // 3 × 1000
    });

    test('should sort data points by date', () {
      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 15),
        ),
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 1),
        ),
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 8),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.length, 3);
      expect(result.dataPoints[0].date.isBefore(result.dataPoints[1].date), true);
      expect(result.dataPoints[1].date.isBefore(result.dataPoints[2].date), true);
    });

    test('should handle empty activities list', () {
      final result = ChartDataService.generateWeeklyVolumeChart([]);

      expect(result.dataPoints, isEmpty);
    });

    test('should skip incomplete sets (done=false)', () {
      final activities = [
        createActivity(
          sets: [
            createSet(weight: '100', reps: '10', done: true),  // 1000
            createSet(weight: '120', reps: '8', done: false),  // Skip
            createSet(weight: '140', reps: '6', done: true),   // 840
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.length, 1);
      expect(result.dataPoints.first.value, 1840.0); // 1000 + 840 only
    });

    test('should handle string and numeric weight values', () {
      final activities = [
        createActivity(
          sets: [
            createSet(weight: '100', reps: '10'),  // String
            createSet(weight: '50.5', reps: '8'),  // Decimal string
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.first.value, 1404.0); // 1000 + 404
    });
  });

  group('generateWeightProgressionChart', () {
    test('should filter activities by exercise name', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 1),
        ),
        createActivity(
          exerciseName: 'Squat',
          sets: [createSet(weight: '120', reps: '8')],
          createdAt: DateTime(2024, 1, 2),
        ),
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '105', reps: '10')],
          createdAt: DateTime(2024, 1, 3),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(result.name, 'Bench Press');
      expect(result.dataPoints.length, 2); // Only Bench Press
      expect(result.color, Colors.green);
      expect(result.showTrendline, true);
    });

    test('should be case insensitive when filtering', () {
      final activities = [
        createActivity(
          exerciseName: 'BENCH PRESS',
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 1),
        ),
        createActivity(
          exerciseName: 'bench press',
          sets: [createSet(weight: '105', reps: '10')],
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(result.dataPoints.length, 2);
    });

    test('should extract max weight from sets', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [
            createSet(weight: '100', reps: '10'),
            createSet(weight: '120', reps: '8'),  // Max
            createSet(weight: '110', reps: '9'),
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(result.dataPoints.first.value, 120.0);
    });

    test('should include metadata with sets and reps', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [
            createSet(weight: '100', reps: '10'),
            createSet(weight: '105', reps: '8'),
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      final metadata = result.dataPoints.first.metadata;
      expect(metadata, isNotNull);
      expect(metadata!['sets'], 2);
      expect(metadata['reps'], '10'); // First set reps
    });

    test('should sort data points by date', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '110', reps: '10')],
          createdAt: DateTime(2024, 1, 10),
        ),
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 1),
        ),
        createActivity(
          exerciseName: 'Bench Press',
          sets: [createSet(weight: '105', reps: '10')],
          createdAt: DateTime(2024, 1, 5),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(result.dataPoints[0].value, 100.0);
      expect(result.dataPoints[1].value, 105.0);
      expect(result.dataPoints[2].value, 110.0);
    });

    test('should return empty data points when no matching exercise', () {
      final activities = [
        createActivity(
          exerciseName: 'Squat',
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(result.dataPoints, isEmpty);
    });

    test('should handle empty activities list', () {
      final result = ChartDataService.generateWeightProgressionChart(
        [],
        'Bench Press',
      );

      expect(result.dataPoints, isEmpty);
    });

    test('should skip incomplete sets when finding max weight', () {
      final activities = [
        createActivity(
          exerciseName: 'Bench Press',
          sets: [
            createSet(weight: '100', reps: '10', done: true),
            createSet(weight: '150', reps: '8', done: false), // Skip
            createSet(weight: '110', reps: '9', done: true),
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(result.dataPoints.first.value, 110.0); // Max from completed only
    });
  });

  group('generateFrequencyHeatmap', () {
    test('should generate heatmap data for date range', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 8);
      final activities = [
        createActivity(
          sets: [createSet()],
          createdAt: DateTime(2024, 1, 3),
        ),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        startDate,
        endDate,
      );

      expect(result.length, 7); // 7 days in range
      expect(result.every((d) => d.date.isAfter(startDate.subtract(const Duration(days: 1)))), true);
      expect(result.every((d) => d.date.isBefore(endDate)), true);
    });

    test('should count multiple workouts on same day', () {
      final date = DateTime(2024, 1, 5);
      final activities = [
        createActivity(sets: [createSet()], createdAt: date),
        createActivity(sets: [createSet()], createdAt: date),
        createActivity(sets: [createSet()], createdAt: date),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 8),
      );

      final targetDay = result.firstWhere((d) =>
        d.date.year == date.year &&
        d.date.month == date.month &&
        d.date.day == date.day
      );

      expect(targetDay.workoutCount, 3);
    });

    test('should normalize intensity values', () {
      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')], // 1000
          createdAt: DateTime(2024, 1, 1),
        ),
        createActivity(
          sets: [createSet(weight: '50', reps: '10')], // 500
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 3),
      );

      final day1 = result.firstWhere((d) => d.date.day == 1);
      final day2 = result.firstWhere((d) => d.date.day == 2);

      expect(day1.intensity, 1.0); // Max intensity
      expect(day2.intensity, 0.5); // Half intensity
    });

    test('should set intensity to 0 for days with no workouts', () {
      final activities = [
        createActivity(
          sets: [createSet(weight: '100', reps: '10')],
          createdAt: DateTime(2024, 1, 3),
        ),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 6),
      );

      final emptyDay = result.firstWhere((d) => d.date.day == 1);

      expect(emptyDay.workoutCount, 0);
      expect(emptyDay.intensity, 0.0);
    });

    test('should handle empty activities list', () {
      final result = ChartDataService.generateFrequencyHeatmap(
        [],
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 8),
      );

      expect(result.length, 7);
      expect(result.every((d) => d.workoutCount == 0), true);
      expect(result.every((d) => d.intensity == 0.0), true);
    });

    test('should ignore time component of activity dates', () {
      final date = DateTime(2024, 1, 5);
      final activities = [
        createActivity(
          sets: [createSet()],
          createdAt: DateTime(2024, 1, 5, 8, 30), // Morning
        ),
        createActivity(
          sets: [createSet()],
          createdAt: DateTime(2024, 1, 5, 20, 45), // Evening
        ),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 8),
      );

      final targetDay = result.firstWhere((d) => d.date.day == 5);

      expect(targetDay.workoutCount, 2); // Both counted on same day
    });

    test('should calculate intensity based on total volume', () {
      final activities = [
        createActivity(
          sets: [
            createSet(weight: '100', reps: '10'), // 1000
            createSet(weight: '120', reps: '8'),  // 960
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
        createActivity(
          sets: [
            createSet(weight: '50', reps: '10'), // 500
          ],
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 3),
      );

      final day1 = result.firstWhere((d) => d.date.day == 1);
      final day2 = result.firstWhere((d) => d.date.day == 2);

      // Day1 volume = 1960, Day2 volume = 500
      expect(day1.intensity, 1.0); // Max
      expect(day2.intensity, closeTo(500 / 1960, 0.01)); // Normalized
    });

    test('should handle activities outside date range', () {
      final activities = [
        createActivity(
          sets: [createSet()],
          createdAt: DateTime(2023, 12, 25), // Before range
        ),
        createActivity(
          sets: [createSet()],
          createdAt: DateTime(2024, 1, 3), // In range
        ),
        createActivity(
          sets: [createSet()],
          createdAt: DateTime(2024, 2, 1), // After range
        ),
      ];

      final result = ChartDataService.generateFrequencyHeatmap(
        activities,
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 8),
      );

      final workoutDays = result.where((d) => d.workoutCount > 0).toList();
      expect(workoutDays.length, 1); // Only Jan 3
      expect(workoutDays.first.date.day, 3);
    });
  });

  group('Edge Cases', () {
    test('should handle invalid weight values', () {
      final activities = [
        createActivity(
          sets: [
            createSet(weight: 'invalid', reps: '10'),
            createSet(weight: '100', reps: '10'),
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.first.value, 1000.0); // Only valid weight
    });

    test('should handle invalid reps values', () {
      final activities = [
        createActivity(
          sets: [
            createSet(weight: '100', reps: 'invalid'),
            createSet(weight: '100', reps: '10'),
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.first.value, 1000.0); // Only valid reps
    });

    test('should handle activities with no completed sets', () {
      final activities = [
        createActivity(
          sets: [
            createSet(weight: '100', reps: '10', done: false),
            createSet(weight: '120', reps: '8', done: false),
          ],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final result = ChartDataService.generateWeeklyVolumeChart(activities);

      expect(result.dataPoints.first.value, 0.0);
    });

    test('should handle activities with empty sets list', () {
      final activities = [
        createActivity(
          sets: [],
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final weeklyResult = ChartDataService.generateWeeklyVolumeChart(activities);
      final progressionResult = ChartDataService.generateWeightProgressionChart(
        activities,
        'Bench Press',
      );

      expect(weeklyResult.dataPoints.first.value, 0.0);
      expect(progressionResult.dataPoints.first.value, 0.0);
    });
  });
}
