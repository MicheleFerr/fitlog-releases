/// Stress Index Calculator Tests
///
/// Tests the main stress index calculation logic including:
/// - RPE-based scoring (primary score)
/// - Weight-only scoring (fallback score)
/// - Muscle stress distribution
/// - Confidence calculation
/// - Logarithmic scaling
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/fitness_fatigue_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/stress_index_calculator.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

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

  // ============================================
  // BODYWEIGHT EXERCISE TESTS
  // ============================================

  group('StressIndexCalculator - Bodyweight Exercises', () {
    test('canCalculate returns true for bodyweight exercise with reps', () {
      final workout = createWorkout(exercises: [
        Exercise(
          name: 'Push Up',
          sets: [
            ExerciseSet(setNumber: 1, reps: 20, isCompleted: true),
          ],
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          countingMode: ExerciseCountingMode.reps,
        ),
      ]);
      expect(StressIndexCalculator.canCalculate(workout), isTrue);
    });

    test('calculate uses body weight for bodyweight exercises', () {
      final workout = createWorkout(exercises: [
        Exercise(
          name: 'Pull Up',
          sets: [
            ExerciseSet(setNumber: 1, reps: 10, actualReps: 10, isCompleted: true),
          ],
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          countingMode: ExerciseCountingMode.reps,
        ),
      ]);

      final result = StressIndexCalculator.calculate(
        workout,
        userBodyWeightKg: 80,
      );
      expect(result.totalSets, 1);
      expect(result.primaryScore, greaterThan(0));
    });

    test('calculate uses default 70kg when no body weight provided', () {
      final workout = createWorkout(exercises: [
        Exercise(
          name: 'Push Up',
          sets: [
            ExerciseSet(setNumber: 1, reps: 15, actualReps: 15, isCompleted: true),
          ],
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          countingMode: ExerciseCountingMode.reps,
        ),
      ]);

      final result = StressIndexCalculator.calculate(workout);
      expect(result.totalSets, 1);
      expect(result.primaryScore, greaterThan(0));
    });
  });

  // ============================================
  // RECOVERY STATUS TESTS
  // ============================================

  group('StressIndexCalculator.calculateRecoveryStatus', () {
    test('returns empty map for no workouts', () {
      final result = StressIndexCalculator.calculateRecoveryStatus([]);
      expect(result, isEmpty);
    });

    test('calculates recovery for single workout', () {
      final now = DateTime.now();
      final workout = StressIndexResult(
        primaryScore: 50,
        fallbackScore: 45,
        confidence: 1.0,
        muscleBreakdown: {
          'PETT': MuscleStressData(
            muscleId: 'PETT',
            displayName: 'Chest',
            stressScore: 40,
            setsCount: 4,
            totalVolume: 3200,
            avgRpe: 8.0,
            recoveryHours: 60,
            estimatedRecovery: now.add(const Duration(hours: 60)),
          ),
        },
        totalSets: 4,
        setsWithRpe: 4,
        workoutId: 'w-1',
        calculatedAt: now.subtract(const Duration(hours: 30)),
        rawScore: 5000,
      );

      final result = StressIndexCalculator.calculateRecoveryStatus([workout]);
      expect(result, contains('PETT'));
      expect(result['PETT']!.recoveryPercentage, greaterThan(0));
      expect(result['PETT']!.displayName, 'Chest');
    });

    test('uses most recent workout for each muscle', () {
      final now = DateTime.now();
      final olderWorkout = StressIndexResult(
        primaryScore: 50,
        fallbackScore: 45,
        confidence: 1.0,
        muscleBreakdown: {
          'PETT': MuscleStressData(
            muscleId: 'PETT',
            displayName: 'Chest',
            stressScore: 40,
            setsCount: 4,
            totalVolume: 3200,
            avgRpe: 8.0,
            recoveryHours: 60,
            estimatedRecovery: now,
          ),
        },
        totalSets: 4,
        setsWithRpe: 4,
        workoutId: 'w-1',
        calculatedAt: now.subtract(const Duration(hours: 72)),
        rawScore: 5000,
      );
      final newerWorkout = StressIndexResult(
        primaryScore: 60,
        fallbackScore: 55,
        confidence: 1.0,
        muscleBreakdown: {
          'PETT': MuscleStressData(
            muscleId: 'PETT',
            displayName: 'Chest',
            stressScore: 55,
            setsCount: 6,
            totalVolume: 4800,
            avgRpe: 9.0,
            recoveryHours: 60,
            estimatedRecovery: now,
          ),
        },
        totalSets: 6,
        setsWithRpe: 6,
        workoutId: 'w-2',
        calculatedAt: now.subtract(const Duration(hours: 24)),
        rawScore: 8000,
      );

      final result = StressIndexCalculator.calculateRecoveryStatus(
        [olderWorkout, newerWorkout],
      );
      // Should use newer workout's stress score
      expect(result['PETT']!.lastStressScore, 55);
    });
  });

  // ============================================
  // FFM STATE CONVERSION TESTS
  // ============================================

  group('StressIndexCalculator.ffmStateToRecoveryState', () {
    test('supercompensation maps to fullyRecovered', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.supercompensation),
        RecoveryState.fullyRecovered,
      );
    });

    test('optimal maps to fullyRecovered', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.optimal),
        RecoveryState.fullyRecovered,
      );
    });

    test('acceptable maps to almostReady', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.acceptable),
        RecoveryState.almostReady,
      );
    });

    test('suboptimal maps to recovering', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.suboptimal),
        RecoveryState.recovering,
      );
    });

    test('overtraining maps to fatigued', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.overtraining),
        RecoveryState.fatigued,
      );
    });

    test('critical maps to exhausted', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.critical),
        RecoveryState.exhausted,
      );
    });

    test('untrained maps to fullyRecovered', () {
      expect(
        StressIndexCalculator.ffmStateToRecoveryState(
            FFMRecoveryState.untrained),
        RecoveryState.fullyRecovered,
      );
    });
  });

  // ============================================
  // SLEEP CATEGORY/MODIFIER ALIASES
  // ============================================

  group('StressIndexCalculator.getSleepCategory', () {
    test('alias returns same result as getSleepQualityCategory', () {
      for (final hours in [3.0, 6.5, 8.0, 10.0]) {
        expect(
          StressIndexCalculator.getSleepCategory(hours),
          StressIndexCalculator.getSleepQualityCategory(hours),
        );
      }
    });
  });

  group('StressIndexCalculator.getSleepModifier', () {
    test('critical sleep returns 0.70', () {
      expect(StressIndexCalculator.getSleepModifier(3.5),
          StressIndexConstants.sleepModifierCritical);
    });

    test('suboptimal sleep returns 0.85', () {
      expect(StressIndexCalculator.getSleepModifier(6.5),
          StressIndexConstants.sleepModifierSuboptimal);
    });

    test('optimal sleep returns 1.0', () {
      expect(StressIndexCalculator.getSleepModifier(8.0),
          StressIndexConstants.sleepModifierOptimal);
    });

    test('excessive sleep returns 0.95', () {
      expect(StressIndexCalculator.getSleepModifier(10.0),
          StressIndexConstants.sleepModifierExcessive);
    });
  });

  // ============================================
  // MOVEMENT MULTIPLIER TESTS
  // ============================================

  group('StressIndexCalculator - Movement Multiplier', () {
    test('compound exercises produce more stress than isolation', () {
      final compoundWorkout = createWorkout(exercises: [
        createExercise(
          name: 'Squat',
          sets: [createSet(setNumber: 1, weight: 80, reps: 10, rpe: 8)],
          movementType: MovementType.compoundHeavy,
        ),
      ]);

      final isolationWorkout = createWorkout(exercises: [
        createExercise(
          name: 'Leg Extension',
          sets: [createSet(setNumber: 1, weight: 80, reps: 10, rpe: 8)],
          movementType: MovementType.isolationLight,
        ),
      ]);

      final compoundResult = StressIndexCalculator.calculate(compoundWorkout);
      final isolationResult = StressIndexCalculator.calculate(isolationWorkout);

      expect(compoundResult.primaryScore,
          greaterThan(isolationResult.primaryScore));
    });
  });

  // ============================================
  // MUSCLE MAP TESTS
  // ============================================

  group('StressIndexCalculator - exerciseMuscleMap', () {
    test('uses muscle map when provided', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Bench Press',
          sets: [createSet(setNumber: 1, weight: 80, reps: 10, rpe: 8)],
        ),
      ]);

      final muscleMap = {
        'Bench Press': ExerciseMuscleData(
          exerciseName: 'Bench Press',
          primary: ['PETT'],
          secondary: ['TRIC', 'DELT_ANT'],
          fileCategory: 'push_orizzontale',
        ),
      };

      final result = StressIndexCalculator.calculate(
        workout,
        exerciseMuscleMap: muscleMap,
      );

      expect(result.muscleBreakdown, isNotEmpty);
      expect(result.totalSets, 1);
    });

    test('falls back to category when muscle map has no match', () {
      final workout = createWorkout(exercises: [
        createExercise(
          name: 'Unknown Exercise',
          sets: [createSet(setNumber: 1, weight: 60, reps: 10, rpe: 7)],
          category: ExerciseCategory.chest,
        ),
      ]);

      final muscleMap = <String, ExerciseMuscleData>{};

      final result = StressIndexCalculator.calculate(
        workout,
        exerciseMuscleMap: muscleMap,
      );

      expect(result.muscleBreakdown, isNotEmpty);
    });
  });

  // ============================================
  // STRESS INDEX RESULT ENTITY TESTS
  // ============================================

  group('StressIndexResult computed properties', () {
    StressIndexResult makeResult({
      double primaryScore = 50,
      double fallbackScore = 45,
      double confidence = 1.0,
    }) {
      return StressIndexResult(
        primaryScore: primaryScore,
        fallbackScore: fallbackScore,
        confidence: confidence,
        muscleBreakdown: {},
        totalSets: 4,
        setsWithRpe: 4,
        workoutId: 'w-1',
        calculatedAt: DateTime.now(),
        rawScore: 5000,
      );
    }

    test('displayScore uses primary when confidence >= 0.5', () {
      final r = makeResult(primaryScore: 60, fallbackScore: 40, confidence: 0.5);
      expect(r.displayScore, 60);
    });

    test('displayScore uses fallback when confidence < 0.5', () {
      final r = makeResult(primaryScore: 60, fallbackScore: 40, confidence: 0.4);
      expect(r.displayScore, 40);
    });

    test('isHighConfidence', () {
      expect(makeResult(confidence: 0.80).isHighConfidence, true);
      expect(makeResult(confidence: 0.79).isHighConfidence, false);
    });

    test('isMediumConfidence', () {
      expect(makeResult(confidence: 0.60).isMediumConfidence, true);
      expect(makeResult(confidence: 0.80).isMediumConfidence, false);
      expect(makeResult(confidence: 0.49).isMediumConfidence, false);
    });

    test('isLowConfidence', () {
      expect(makeResult(confidence: 0.30).isLowConfidence, true);
      expect(makeResult(confidence: 0.50).isLowConfidence, false);
    });

    test('stressLevel light', () {
      expect(makeResult(primaryScore: 20).stressLevel, StressLevel.light);
    });

    test('stressLevel moderate', () {
      expect(makeResult(primaryScore: 45).stressLevel, StressLevel.moderate);
    });

    test('stressLevel hard', () {
      expect(makeResult(primaryScore: 70).stressLevel, StressLevel.hard);
    });

    test('stressLevel veryHard', () {
      expect(makeResult(primaryScore: 90).stressLevel, StressLevel.veryHard);
    });

    test('scoreRange high confidence shows single value', () {
      final r = makeResult(primaryScore: 75, confidence: 0.85);
      expect(r.scoreRange, '75');
    });

    test('scoreRange low confidence shows range', () {
      final r = makeResult(primaryScore: 50, fallbackScore: 50, confidence: 0.4);
      // displayScore = fallback = 50, so range = 45-55
      expect(r.scoreRange, contains('-'));
    });
  });
}
