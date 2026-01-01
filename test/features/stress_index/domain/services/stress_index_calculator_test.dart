/// Stress Index Calculator Tests
///
/// Tests the main stress index calculation logic including:
/// - RPE-based scoring (primary score)
/// - Weight-only scoring (fallback score)
/// - Muscle stress distribution
/// - Confidence calculation
/// - Logarithmic scaling
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/stress_index_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

void main() {
  // ============================================
  // HELPER FUNCTIONS
  // ============================================

  /// Create a simple ExerciseSet for testing
  ExerciseSet createSet({
    int setNumber = 1,
    double? weight,
    int? reps,
    int? rpe,
    bool isCompleted = true,
    bool isWarmup = false,
  }) {
    return ExerciseSet(
      setNumber: setNumber,
      reps: reps ?? 10,
      actualReps: reps ?? 10,
      weight: weight,
      rpe: rpe,
      isCompleted: isCompleted,
      isWarmup: isWarmup,
    );
  }

  /// Create an Exercise for testing
  Exercise createExercise({
    required String name,
    required List<ExerciseSet> sets,
    ExerciseCategory category = ExerciseCategory.chest,
    ExerciseType type = ExerciseType.single,
    MovementType? movementType,
  }) {
    return Exercise(
      name: name,
      sets: sets,
      category: category,
      type: type,
      movementType: movementType,
    );
  }

  /// Create a Workout for testing
  Workout createWorkout({
    required List<Exercise> exercises,
    String? id,
  }) {
    final now = DateTime.now();
    return Workout(
      id: id ?? 'w-${now.millisecondsSinceEpoch}',
      name: 'Test Workout',
      exercises: exercises,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ============================================
  // canCalculate TESTS
  // ============================================

  group('StressIndexCalculator.canCalculate', () {
    test('returns false for empty workout', () {
      final workout = createWorkout(exercises: []);
      expect(StressIndexCalculator.canCalculate(workout), isFalse);
    });

    test('returns false for workout with only incomplete sets', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Bench Press',
          sets: [
            createSet(setNumber: 1, weight: 60, reps: 10, isCompleted: false),
            createSet(setNumber: 2, weight: 60, reps: 10, isCompleted: false),
          ],
        ),
      ]);
      expect(StressIndexCalculator.canCalculate(workout), isFalse);
    });

    test('returns false for workout with only warmup sets', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Squat',
          sets: [
            createSet(setNumber: 1, weight: 20, reps: 10, isWarmup: true),
            createSet(setNumber: 2, weight: 40, reps: 8, isWarmup: true),
          ],
        ),
      ]);
      expect(StressIndexCalculator.canCalculate(workout), isFalse);
    });

    test('returns true for workout with completed working sets', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Deadlift',
          sets: [
            createSet(setNumber: 1, weight: 100, reps: 5, isCompleted: true),
          ],
        ),
      ]);
      expect(StressIndexCalculator.canCalculate(workout), isTrue);
    });
  });

  // ============================================
  // calculate BASIC TESTS
  // ============================================

  group('StressIndexCalculator.calculate - Basic', () {
    test('calculates score for simple workout', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Bench Press',
          sets: [
            createSet(setNumber: 1, weight: 60, reps: 10),
            createSet(setNumber: 2, weight: 60, reps: 10),
            createSet(setNumber: 3, weight: 60, reps: 10),
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      // Should have valid scores
      expect(result.primaryScore, greaterThan(0));
      expect(result.fallbackScore, greaterThan(0));
      expect(result.primaryScore, lessThanOrEqualTo(100));
      expect(result.totalSets, equals(3));
    });

    test('returns zero confidence without RPE', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Squat',
          sets: [
            createSet(setNumber: 1, weight: 80, reps: 8), // No RPE
            createSet(setNumber: 2, weight: 80, reps: 8),
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      expect(result.confidence, equals(0.0));
      expect(result.setsWithRpe, equals(0));
    });

    test('calculates correct confidence with mixed RPE', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Lat Pulldown',
          sets: [
            createSet(setNumber: 1, weight: 50, reps: 12, rpe: 7), // Has RPE
            createSet(setNumber: 2, weight: 50, reps: 12),         // No RPE
            createSet(setNumber: 3, weight: 50, reps: 12, rpe: 8), // Has RPE
            createSet(setNumber: 4, weight: 50, reps: 10),         // No RPE
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      // 2 out of 4 sets have RPE = 50% confidence
      expect(result.confidence, equals(0.5));
      expect(result.setsWithRpe, equals(2));
      expect(result.totalSets, equals(4));
    });

    test('calculates 100% confidence when all sets have RPE', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Row',
          sets: [
            createSet(setNumber: 1, weight: 40, reps: 12, rpe: 6),
            createSet(setNumber: 2, weight: 45, reps: 10, rpe: 7),
            createSet(setNumber: 3, weight: 45, reps: 8, rpe: 8),
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      expect(result.confidence, equals(1.0));
      expect(result.setsWithRpe, equals(3));
    });
  });

  // ============================================
  // RPE INTENSITY TESTS
  // ============================================

  group('StressIndexCalculator.calculate - RPE Intensity', () {
    test('higher RPE results in higher stress', () {
      // Workout with RPE 6
      final workoutLowRpe = createWorkout(exercises: [
        createExercise(
          name: 'Bench Press',
          sets: [
            createSet(setNumber: 1, weight: 60, reps: 10, rpe: 6),
          ],
        ),
      ]);

      // Same workout with RPE 9
      final workoutHighRpe = createWorkout(exercises: [
        createExercise(
          name: 'Bench Press',
          sets: [
            createSet(setNumber: 1, weight: 60, reps: 10, rpe: 9),
          ],
        ),
      ]);

      final resultLow = StressIndexCalculator.calculate(workoutLowRpe);
      final resultHigh = StressIndexCalculator.calculate(workoutHighRpe);

      // Higher RPE should result in higher stress
      expect(resultHigh.primaryScore, greaterThan(resultLow.primaryScore));
    });

    test('RPE 10 gives maximum intensity multiplier', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Deadlift',
          sets: [createSet(setNumber: 1, weight: 100, reps: 5, rpe: 10)],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      // RPE 10 should produce the highest stress for given weight/reps
      expect(result.primaryScore, greaterThan(0));
      expect(result.confidence, equals(1.0));
    });
  });

  // ============================================
  // VOLUME TESTS
  // ============================================

  group('StressIndexCalculator.calculate - Volume', () {
    test('more volume results in higher stress', () {
      // 3 sets
      final workout3Sets = createWorkout(exercises: [
        createExercise(
          name: 'Squat',
          sets: [
            createSet(setNumber: 1, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 2, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 3, weight: 80, reps: 10, rpe: 7),
          ],
        ),
      ]);

      // 6 sets (double volume)
      final workout6Sets = createWorkout(exercises: [
        createExercise(
          name: 'Squat',
          sets: [
            createSet(setNumber: 1, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 2, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 3, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 4, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 5, weight: 80, reps: 10, rpe: 7),
            createSet(setNumber: 6, weight: 80, reps: 10, rpe: 7),
          ],
        ),
      ]);

      final result3 = StressIndexCalculator.calculate(workout3Sets);
      final result6 = StressIndexCalculator.calculate(workout6Sets);

      // More volume should result in higher stress
      expect(result6.primaryScore, greaterThan(result3.primaryScore));
      expect(result6.totalSets, equals(6));
      expect(result3.totalSets, equals(3));
    });

    test('heavier weight results in higher stress', () {
      // Light weight
      final workoutLight = createWorkout(exercises: [
        createExercise(
          name: 'Bench',
          sets: [createSet(setNumber: 1, weight: 40, reps: 10, rpe: 7)],
        ),
      ]);

      // Heavy weight
      final workoutHeavy = createWorkout(exercises: [
        createExercise(
          name: 'Bench',
          sets: [createSet(setNumber: 1, weight: 100, reps: 10, rpe: 7)],
        ),
      ]);

      final resultLight = StressIndexCalculator.calculate(workoutLight);
      final resultHeavy = StressIndexCalculator.calculate(workoutHeavy);

      expect(resultHeavy.primaryScore, greaterThan(resultLight.primaryScore));
    });
  });

  // ============================================
  // EDGE CASES
  // ============================================

  group('StressIndexCalculator.calculate - Edge Cases', () {
    test('skips sets with zero weight', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Test',
          sets: [
            createSet(setNumber: 1, weight: 0, reps: 10), // Should be skipped
            createSet(setNumber: 2, weight: 50, reps: 10, rpe: 7), // Valid
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      // Only 1 valid set
      expect(result.totalSets, equals(1));
    });

    test('skips sets with zero reps', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Test',
          sets: [
            createSet(setNumber: 1, weight: 50, reps: 0), // Should be skipped
            createSet(setNumber: 2, weight: 50, reps: 10, rpe: 7), // Valid
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      expect(result.totalSets, equals(1));
    });

    test('handles very high volume workout', () {
      final sets = List.generate(
        30, // 30 sets
        (i) => createSet(setNumber: i + 1, weight: 100, reps: 10, rpe: 8),
      );

      final workout = createWorkout(exercises: [
        createExercise(name: 'Heavy Workout', sets: sets),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      // Should still produce valid score (capped at 100)
      expect(result.primaryScore, lessThanOrEqualTo(100));
      expect(result.primaryScore, greaterThan(0));
      expect(result.totalSets, equals(30));
    });

    test('includes workout ID in result', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 'specific-workout-id-123',
        name: 'Test',
        exercises: [
          createExercise(
            name: 'Exercise',
            sets: [createSet(setNumber: 1, weight: 50, reps: 10)],
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final result = StressIndexCalculator.calculate(workout);

      expect(result.workoutId, equals('specific-workout-id-123'));
    });
  });

  // ============================================
  // getStressLevelDescription TESTS
  // ============================================

  group('StressIndexCalculator.getStressLevelDescription', () {
    test('returns correct descriptions for all levels', () {
      // Test all StressLevel values have descriptions
      for (final level in StressLevel.values) {
        final description = StressIndexCalculator.getStressLevelDescription(level);
        expect(description, isNotEmpty);
      }
    });
  });

  // ============================================
  // MUSCLE BREAKDOWN TESTS
  // ============================================

  group('StressIndexCalculator.calculate - Muscle Breakdown', () {
    test('produces muscle breakdown', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Bench Press',
          sets: [
            createSet(setNumber: 1, weight: 60, reps: 10, rpe: 7),
            createSet(setNumber: 2, weight: 60, reps: 10, rpe: 7),
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      // Should have at least one muscle in breakdown
      expect(result.muscleBreakdown, isNotEmpty);
    });

    test('muscle data contains required fields', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Squat',
          sets: [
            createSet(setNumber: 1, weight: 100, reps: 8, rpe: 8),
          ],
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);

      for (final entry in result.muscleBreakdown.entries) {
        final muscleData = entry.value;
        expect(muscleData.muscleId, isNotEmpty);
        expect(muscleData.stressScore, greaterThanOrEqualTo(0));
        expect(muscleData.setsCount, greaterThan(0));
        expect(muscleData.recoveryHours, greaterThan(0));
        expect(muscleData.estimatedRecovery, isNotNull);
      }
    });
  });

  // ============================================
  // LOGARITHMIC SCALE TESTS
  // ============================================

  group('StressIndexCalculator - Logarithmic Scale', () {
    test('score is bounded between 0 and 100', () {
      // Very light workout
      final lightWorkout = createWorkout(exercises: [
        createExercise(
          name: 'Light',
          sets: [createSet(setNumber: 1, weight: 10, reps: 5)],
        ),
      ]);

      // Very heavy workout
      final heavySets = List.generate(
        20,
        (i) => createSet(setNumber: i + 1, weight: 200, reps: 10, rpe: 10),
      );
      final heavyWorkout = createWorkout(exercises: [
        createExercise(name: 'Heavy', sets: heavySets),
      ]);

      final lightResult = StressIndexCalculator.calculate(lightWorkout);
      final heavyResult = StressIndexCalculator.calculate(heavyWorkout);

      // Both should be in valid range
      expect(lightResult.primaryScore, greaterThanOrEqualTo(0));
      expect(lightResult.primaryScore, lessThanOrEqualTo(100));
      expect(heavyResult.primaryScore, greaterThanOrEqualTo(0));
      expect(heavyResult.primaryScore, lessThanOrEqualTo(100));
    });
  });

  // ============================================
  // SLEEP-AWARE STRESS INDEX TESTS
  // ============================================

  group('StressIndexCalculator.applySleepModifier', () {
    test('critical sleep (<6h) amplifies fatigue', () {
      // FFM performance at 89% (fatigued, -11 from baseline)
      const ffmPerformance = 89.0;
      const criticalSleep = 3.5; // Critical sleep

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: criticalSleep,
        consecutiveBadNights: 0,
      );

      // With poor sleep, fatigue should be amplified
      // Deviation: -11, sleep mod: 0.70 → adjusted deviation: -11/0.70 ≈ -15.7
      // Adjusted: 100 + (-15.7) ≈ 84.3
      expect(adjusted, lessThan(ffmPerformance));
      expect(adjusted, closeTo(84.3, 1.0));
    });

    test('suboptimal sleep (6-7h) moderately impacts performance', () {
      const ffmPerformance = 89.0;
      const suboptimalSleep = 6.5;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: suboptimalSleep,
        consecutiveBadNights: 0,
      );

      // With suboptimal sleep (0.85 modifier), fatigue is moderately amplified
      expect(adjusted, lessThan(ffmPerformance));
      expect(adjusted, greaterThan(84.0)); // Less impact than critical sleep
    });

    test('optimal sleep (7-9h) has no impact', () {
      const ffmPerformance = 89.0;
      const optimalSleep = 8.0;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: optimalSleep,
        consecutiveBadNights: 0,
      );

      // Optimal sleep (1.0 modifier) should not change the score
      expect(adjusted, equals(ffmPerformance));
    });

    test('excessive sleep (>9h) has minor impact', () {
      const ffmPerformance = 89.0;
      const excessiveSleep = 10.5;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: excessiveSleep,
        consecutiveBadNights: 0,
      );

      // Excessive sleep (0.95 modifier) has slight negative impact
      expect(adjusted, lessThan(ffmPerformance));
      expect(adjusted, greaterThan(87.0)); // Very minor impact
    });

    test('supercompensation with poor sleep reduces gains', () {
      // FFM performance at 105% (supercompensating, +5 from baseline)
      const ffmPerformance = 105.0;
      const criticalSleep = 4.0;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: criticalSleep,
        consecutiveBadNights: 0,
      );

      // When supercompensating, poor sleep reduces the gains
      // Deviation: +5, sleep mod: 0.70 → adjusted: 5 * 0.70 = 3.5
      // Adjusted: 100 + 3.5 = 103.5
      expect(adjusted, lessThan(ffmPerformance));
      expect(adjusted, greaterThan(100.0)); // Still above baseline
      expect(adjusted, closeTo(103.5, 0.5));
    });

    test('supercompensation with optimal sleep is unchanged', () {
      const ffmPerformance = 105.0;
      const optimalSleep = 8.0;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: optimalSleep,
        consecutiveBadNights: 0,
      );

      expect(adjusted, equals(ffmPerformance));
    });
  });

  group('StressIndexCalculator.applySleepModifier - Consecutive Bad Nights', () {
    test('2 consecutive bad nights adds 5% penalty', () {
      const ffmPerformance = 89.0;
      const criticalSleep = 4.0;

      final adjustedWith0 = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: criticalSleep,
        consecutiveBadNights: 0,
      );

      final adjustedWith2 = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: criticalSleep,
        consecutiveBadNights: 2,
      );

      // 2 consecutive bad nights should result in worse performance
      expect(adjustedWith2, lessThan(adjustedWith0));
    });

    test('3+ consecutive bad nights adds 10% penalty', () {
      const ffmPerformance = 89.0;
      const criticalSleep = 4.0;

      final adjustedWith2 = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: criticalSleep,
        consecutiveBadNights: 2,
      );

      final adjustedWith3 = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: criticalSleep,
        consecutiveBadNights: 3,
      );

      // 3 consecutive bad nights should be worse than 2
      expect(adjustedWith3, lessThan(adjustedWith2));
    });

    test('consecutive bad nights with optimal sleep still has penalty', () {
      const ffmPerformance = 89.0;
      const optimalSleep = 8.0; // Last night was good

      final adjustedWith0 = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: optimalSleep,
        consecutiveBadNights: 0,
      );

      final adjustedWith3 = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmPerformance,
        sleepHours: optimalSleep,
        consecutiveBadNights: 3, // But had 3 bad nights before
      );

      // Even with good sleep last night, cumulative penalty applies
      expect(adjustedWith3, lessThan(adjustedWith0));
    });
  });

  group('StressIndexCalculator.getSleepQualityCategory', () {
    test('returns critical for sleep < 6h', () {
      expect(
        StressIndexCalculator.getSleepQualityCategory(3.5),
        equals(SleepQualityCategory.critical),
      );
      expect(
        StressIndexCalculator.getSleepQualityCategory(5.9),
        equals(SleepQualityCategory.critical),
      );
    });

    test('returns suboptimal for sleep 6-7h', () {
      expect(
        StressIndexCalculator.getSleepQualityCategory(6.0),
        equals(SleepQualityCategory.suboptimal),
      );
      expect(
        StressIndexCalculator.getSleepQualityCategory(6.9),
        equals(SleepQualityCategory.suboptimal),
      );
    });

    test('returns optimal for sleep 7-9h', () {
      expect(
        StressIndexCalculator.getSleepQualityCategory(7.0),
        equals(SleepQualityCategory.optimal),
      );
      expect(
        StressIndexCalculator.getSleepQualityCategory(8.0),
        equals(SleepQualityCategory.optimal),
      );
      expect(
        StressIndexCalculator.getSleepQualityCategory(9.0),
        equals(SleepQualityCategory.optimal),
      );
    });

    test('returns excessive for sleep > 9h', () {
      expect(
        StressIndexCalculator.getSleepQualityCategory(9.5),
        equals(SleepQualityCategory.excessive),
      );
      expect(
        StressIndexCalculator.getSleepQualityCategory(11.0),
        equals(SleepQualityCategory.excessive),
      );
    });
  });

  group('StressIndexCalculator - Real World Scenarios', () {
    test('heavy workout + critical sleep = severely reduced readiness', () {
      // Simulate scenario: FFM at 89% (after heavy workout) + 3.5h sleep
      const ffmAfterWorkout = 89.0;
      const criticalSleep = 3.5;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmAfterWorkout,
        sleepHours: criticalSleep,
        consecutiveBadNights: 0,
      );

      // Should drop significantly below 89%
      expect(adjusted, lessThan(85.0));
      // Should show as "fatigued" territory
      expect(adjusted, lessThan(StressIndexConstants.acceptableTrainingMin));
    });

    test('rest day + optimal sleep = full recovery', () {
      // Simulate scenario: FFM at baseline (100%) + 8h sleep
      const ffmBaseline = 100.0;
      const optimalSleep = 8.0;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmBaseline,
        sleepHours: optimalSleep,
        consecutiveBadNights: 0,
      );

      // Should remain at baseline
      expect(adjusted, equals(ffmBaseline));
    });

    test('supercompensation window + poor sleep = reduced peak', () {
      // Simulate scenario: FFM supercompensating (105%) but poor sleep
      const ffmSupercompensating = 105.0;
      const poorSleep = 5.0;

      final adjusted = StressIndexCalculator.applySleepModifier(
        ffmPerformance: ffmSupercompensating,
        sleepHours: poorSleep,
        consecutiveBadNights: 1,
      );

      // Gains should be reduced but still above baseline
      expect(adjusted, lessThan(ffmSupercompensating));
      expect(adjusted, greaterThan(100.0));
    });
  });
}
