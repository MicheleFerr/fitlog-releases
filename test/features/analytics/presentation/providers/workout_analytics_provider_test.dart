import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

void main() {
  // Test data factories
  WorkoutMetrics createTestMetrics({
    String workoutId = 'workout-1',
    double totalVolume = 1000.0,
    double completionPercentage = 0.5,  // Changed to decimal (0.0-1.0)
    double averageRPE = 8.0,
    int completedSets = 2,
    int totalSets = 4,
  }) {
    return WorkoutMetrics(
      workoutId: workoutId,
      calculatedAt: DateTime.now(),
      totalVolume: totalVolume,
      workingSetsVolume: 900,
      warmupVolume: 100,
      volumeByMuscleGroup: {ExerciseCategory.chest: 1000},
      totalSets: totalSets,
      completedSets: completedSets,
      workingSets: 2,
      warmupSets: 0,
      averageWeight: 100,
      averageRPE: averageRPE,
      averageIntensity: 80,
      peakIntensity: 1000,
      totalDuration: const Duration(minutes: 30),
      workingTime: const Duration(minutes: 10),
      restTime: const Duration(minutes: 20),
      trainingDensity: 33.3,
      completionPercentage: completionPercentage,
      exercisesCompleted: 1,
      totalExercises: 2,
    );
  }

  PersonalRecordAchieved createTestPR({
    String exerciseId = 'exercise-1',
    PRType type = PRType.weight,
    double newValue = 150.0,
    double? previousValue = 140.0,
  }) {
    return PersonalRecordAchieved(
      exerciseId: exerciseId,
      exerciseName: 'Bench Press',
      type: type,
      newValue: newValue,
      previousValue: previousValue,
      achievedAt: DateTime.now(),
    );
  }

  WorkoutComparison createTestComparison({
    double improvementScore = 10.0,
  }) {
    return WorkoutComparison(
      comparisonId: 'comparison-1',
      comparisonDate: DateTime.now().subtract(const Duration(days: 7)),
      comparisonName: 'Previous Workout',
      volumeChange: 100,
      volumeChangePercentage: 10,
      intensityChange: 0.5,
      intensityChangePercentage: 5,
      durationChange: const Duration(minutes: -5),
      densityChange: 2.0,
      improvementScore: improvementScore,
    );
  }

  group('WorkoutAnalyticsState', () {
    test('should create state with required fields', () {
      final state = WorkoutAnalyticsState(
        lastUpdated: DateTime.now(),
      );

      expect(state.currentMetrics, isNull);
      expect(state.currentPRs, isEmpty);
      expect(state.comparison, isNull);
      expect(state.prPredictions, isEmpty);
      expect(state.isCalculating, false);
      expect(state.error, isNull);
      expect(state.lastUpdated, isA<DateTime>());
    });

    test('copyWith should update only specified fields', () {
      final state = WorkoutAnalyticsState(
        lastUpdated: DateTime.now(),
      );

      final metrics = createTestMetrics();
      final updatedState = state.copyWith(
        currentMetrics: metrics,
        isCalculating: true,
      );

      expect(updatedState.currentMetrics, equals(metrics));
      expect(updatedState.isCalculating, true);
      expect(updatedState.currentPRs, isEmpty); // Unchanged
    });

    test('hasNewPRs should return true when PRs exist', () {
      final pr = createTestPR();
      final state = WorkoutAnalyticsState(
        currentPRs: [pr],
        lastUpdated: DateTime.now(),
      );

      expect(state.hasNewPRs, true);
    });

    test('hasNewPRs should return false when no PRs', () {
      final state = WorkoutAnalyticsState(
        lastUpdated: DateTime.now(),
      );

      expect(state.hasNewPRs, false);
    });

    test('totalPRs should return correct count', () {
      final prs = [
        createTestPR(exerciseId: 'ex-1'),
        createTestPR(exerciseId: 'ex-2'),
        createTestPR(exerciseId: 'ex-3'),
      ];

      final state = WorkoutAnalyticsState(
        currentPRs: prs,
        lastUpdated: DateTime.now(),
      );

      expect(state.totalPRs, 3);
    });

    test('significantPRs should filter PRs with >2.5% improvement', () {
      final prs = [
        createTestPR(newValue: 150, previousValue: 140), // 7.1% - significant
        createTestPR(newValue: 101, previousValue: 100), // 1% - not significant
        createTestPR(newValue: 200, previousValue: 190), // 5.3% - significant
      ];

      final state = WorkoutAnalyticsState(
        currentPRs: prs,
        lastUpdated: DateTime.now(),
      );

      expect(state.significantPRs.length, 2);
    });

    test('showsImprovement should be true when has PRs', () {
      final pr = createTestPR();
      final state = WorkoutAnalyticsState(
        currentPRs: [pr],
        lastUpdated: DateTime.now(),
      );

      expect(state.showsImprovement, true);
    });

    test('showsImprovement should be true when comparison shows improvement', () {
      final comparison = createTestComparison(improvementScore: 10);
      final state = WorkoutAnalyticsState(
        comparison: comparison,
        lastUpdated: DateTime.now(),
      );

      expect(state.showsImprovement, true);
    });

    test('qualityRating should return A+ for score >= 90', () {
      // Target score ~95: Volume(40) + Intensity(24) + Completion(20) + Consistency(10) = 94
      final metrics = createTestMetrics(
        totalVolume: 2000,
        averageRPE: 9.0,
        completionPercentage: 1.0,
        completedSets: 20,
        totalSets: 20,
      );
      final state = WorkoutAnalyticsState(
        currentMetrics: metrics,
        lastUpdated: DateTime.now(),
      );

      expect(state.qualityRating, 'A+');
    });

    test('qualityRating should return A for score >= 85', () {
      // Target score ~87: Volume(38) + Intensity(21) + Completion(19) + Consistency(9) = 87
      final metrics = createTestMetrics(
        totalVolume: 1900,
        averageRPE: 8.5,
        completionPercentage: 0.95,
        completedSets: 18,
        totalSets: 20,
      );
      final state = WorkoutAnalyticsState(
        currentMetrics: metrics,
        lastUpdated: DateTime.now(),
      );

      expect(state.qualityRating, 'A');
    });

    test('qualityRating should return B+ for score >= 80', () {
      // Target score ~80: Volume(36) + Intensity(18) + Completion(18) + Consistency(8) = 80
      final metrics = createTestMetrics(
        totalVolume: 1800,
        averageRPE: 8.0,
        completionPercentage: 0.90,
        completedSets: 16,
        totalSets: 20,
      );
      final state = WorkoutAnalyticsState(
        currentMetrics: metrics,
        lastUpdated: DateTime.now(),
      );

      expect(state.qualityRating, 'B+');
    });

    test('qualityRating should return F for score < 60', () {
      // Target score ~53: Volume(24) + Intensity(12) + Completion(12) + Consistency(5) = 53
      final metrics = createTestMetrics(
        totalVolume: 1200,
        averageRPE: 7.0,
        completionPercentage: 0.60,
        completedSets: 10,
        totalSets: 20,
      );
      final state = WorkoutAnalyticsState(
        currentMetrics: metrics,
        lastUpdated: DateTime.now(),
      );

      expect(state.qualityRating, 'F');
    });

    test('should handle null error in copyWith', () {
      final state = WorkoutAnalyticsState(
        error: 'Test error',
        lastUpdated: DateTime.now(),
      );

      final updatedState = state.copyWith(error: null);

      expect(updatedState.error, isNull);
    });
  });

  group('WorkoutComparison', () {
    test('isImprovement should be true when score > 5', () {
      final comparison = createTestComparison(improvementScore: 10);
      expect(comparison.isImprovement, true);
    });

    test('isSimilar should be true when score within ±5', () {
      final comparison = createTestComparison(improvementScore: 3);
      expect(comparison.isSimilar, true);
    });

    test('isRegression should be true when score < -5', () {
      final comparison = createTestComparison(improvementScore: -10);
      expect(comparison.isRegression, true);
    });

    test('formattedVolumeChange should include sign and percentage', () {
      final comparison = createTestComparison();
      expect(comparison.formattedVolumeChange, contains('+'));
      expect(comparison.formattedVolumeChange, contains('%'));
    });

    test('formattedDurationChange should format correctly', () {
      final comparison = createTestComparison();
      expect(comparison.formattedDurationChange, matches(r'[+-]\d+m'));
    });
  });

  group('PersonalRecordAchieved', () {
    test('improvementPercentage should calculate correctly', () {
      final pr = createTestPR(newValue: 150, previousValue: 100);
      expect(pr.improvementPercentage, 50.0);
    });

    test('improvementPercentage should return 100% when previousValue is null', () {
      final pr = createTestPR(newValue: 150, previousValue: null);
      expect(pr.improvementPercentage, 100.0);
    });

    test('isSignificant should be true for >2.5% improvement', () {
      final pr = createTestPR(newValue: 150, previousValue: 140);
      expect(pr.isSignificant, true);
    });

    test('isSignificant should be false for <=2.5% improvement', () {
      final pr = createTestPR(newValue: 101, previousValue: 100);
      expect(pr.isSignificant, false);
    });

    test('typeDescription should return correct descriptions', () {
      expect(
        createTestPR(type: PRType.weight).typeDescription,
        'Max Weight',
      );
      expect(
        createTestPR(type: PRType.reps).typeDescription,
        'Max Reps',
      );
      expect(
        createTestPR(type: PRType.volume).typeDescription,
        'Volume PR',
      );
      expect(
        createTestPR(type: PRType.oneRM).typeDescription,
        '1RM Est.',
      );
    });
  });

  group('WorkoutMetrics', () {
    test('empty factory should create metrics with zero values', () {
      final metrics = WorkoutMetrics.empty('workout-1');

      expect(metrics.workoutId, 'workout-1');
      expect(metrics.totalVolume, 0);
      expect(metrics.completedSets, 0);
      expect(metrics.totalDuration, Duration.zero);
    });

    test('fromWorkout should calculate metrics correctly', () {
      final workout = Workout(
        id: 'test-workout',
        name: 'Test Workout',
        createdAt: DateTime.now(),
        updatedAt: DateTime(2024, 1, 1),
        exercises: [
          Exercise(
            name: 'Bench Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 100,
                reps: 10,
                isCompleted: true,
                isWarmup: false,
              ),
            ],
          ),
        ],
      );

      final metrics = WorkoutMetrics.fromWorkout(workout);

      expect(metrics.workoutId, workout.id);
      expect(metrics.totalVolume, greaterThan(0));
      expect(metrics.completedSets, greaterThan(0));
    });

    test('formattedVolume should include kg unit', () {
      final metrics = createTestMetrics(totalVolume: 1234.56);
      expect(metrics.formattedVolume, contains('kg'));
      expect(metrics.formattedVolume, contains('1235'));
    });

    test('formattedDuration should format hours and minutes correctly', () {
      final metrics = WorkoutMetrics(
        workoutId: 'workout-1',
        calculatedAt: DateTime.now(),
        totalVolume: 1000,
        workingSetsVolume: 900,
        warmupVolume: 100,
        volumeByMuscleGroup: {},
        totalSets: 4,
        completedSets: 2,
        workingSets: 2,
        warmupSets: 0,
        averageWeight: 100,
        averageRPE: 8,
        averageIntensity: 80,
        peakIntensity: 1000,
        totalDuration: const Duration(hours: 1, minutes: 30),
        workingTime: const Duration(minutes: 45),
        restTime: const Duration(minutes: 45),
        trainingDensity: 11.1,
        completionPercentage: 50,
        exercisesCompleted: 1,
        totalExercises: 2,
      );

      expect(metrics.formattedDuration, '1h 30m');
    });

    test('isStrongWorkout should be true for high metrics', () {
      // isStrongWorkout checks: totalVolume > 1000, averageRPE >= 7.5, trainingDensity > 15
      final metrics = createTestMetrics(
        totalVolume: 2000,
        averageRPE: 8.5,
        completionPercentage: 0.90,
      );

      expect(metrics.isStrongWorkout, true);
    });

    test('qualityScore should be clamped between 0 and 100', () {
      final metrics = createTestMetrics(
        totalVolume: 2000,
        averageRPE: 9.0,
        completionPercentage: 0.95,
      );
      expect(metrics.qualityScore, lessThanOrEqualTo(100));
      expect(metrics.qualityScore, greaterThanOrEqualTo(0));
    });

    test('copyWith should update specified fields only', () {
      final metrics = createTestMetrics();
      final updated = metrics.copyWith(totalVolume: 2000);

      expect(updated.totalVolume, 2000);
      expect(updated.workoutId, metrics.workoutId); // Unchanged
    });
  });

  group('Edge Cases', () {
    test('should handle empty workout correctly', () {
      final emptyWorkout = Workout(
        id: 'empty',
        name: 'Empty Workout',
        createdAt: DateTime.now(),
        updatedAt: DateTime(2024, 1, 1),
        exercises: [],
      );

      final metrics = WorkoutMetrics.fromWorkout(emptyWorkout);

      expect(metrics.totalVolume, 0);
      expect(metrics.completedSets, 0);
      expect(metrics.totalExercises, 0);
    });

    test('should handle workout with only warmup sets', () {
      final workout = Workout(
        id: 'warmup-only',
        name: 'Warmup Only',
        createdAt: DateTime.now(),
        updatedAt: DateTime(2024, 1, 1),
        exercises: [
          Exercise(
            name: 'Bench Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 60,
                reps: 10,
                isCompleted: true,
                isWarmup: true,
              ),
            ],
          ),
        ],
      );

      final metrics = WorkoutMetrics.fromWorkout(workout);

      expect(metrics.warmupSets, 1);
      expect(metrics.workingSets, 0);
      expect(metrics.warmupVolume, greaterThan(0));
    });

    test('should handle very long duration correctly', () {
      final metrics = createTestMetrics();
      final updated = metrics.copyWith(
        totalDuration: const Duration(hours: 5, minutes: 30),
      );

      expect(updated.formattedDuration, '5h 30m');
    });
  });
}
