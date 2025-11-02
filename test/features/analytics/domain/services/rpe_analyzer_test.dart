import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/rpe_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';

void main() {
  // Helper: Create workout with RPE sets
  Workout createWorkoutWithRPE({
    required Map<int, int> rpeCounts, // RPE value → count
    DateTime? createdAt,
    ExerciseCategory category = ExerciseCategory.chest,
    bool includeWarmup = false,
  }) {
    final sets = <ExerciseSet>[];
    int setNumber = 1;

    // Add warmup set if requested
    if (includeWarmup) {
      sets.add(ExerciseSet(
        setNumber: setNumber++,
        weight: 50,
        reps: 10,
        isCompleted: true,
        isWarmup: true,
        rpe: 5,
      ));
    }

    // Add working sets with specified RPE
    for (final entry in rpeCounts.entries) {
      for (int i = 0; i < entry.value; i++) {
        sets.add(ExerciseSet(
          setNumber: setNumber++,
          weight: 100,
          reps: 10,
          isCompleted: true,
          isWarmup: false,
          rpe: entry.key,
        ));
      }
    }

    return Workout(
      id: 'workout-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Test Workout',
      createdAt: createdAt ?? DateTime.now(),
      exercises: [
        Exercise(
          name: 'Bench Press',
          category: category,
          type: ExerciseType.single,
          sets: sets,
        ),
      ],
    );
  }

  group('analyzeRPEDistribution', () {
    test('should correctly categorize RPE zones', () {
      final workouts = [
        createWorkoutWithRPE(rpeCounts: {
          5: 2,  // Recovery
          6: 2,  // Recovery
          7: 3,  // Moderate
          8: 4,  // Hard
          9: 3,  // Very Hard
          10: 2, // Maximal
        }),
      ];

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts);

      expect(result.recoverySets, 4);      // 5-6
      expect(result.moderateSets, 3);      // 7
      expect(result.hardSets, 4);          // 8
      expect(result.veryHardSets, 3);      // 9
      expect(result.maximalSets, 2);       // 10
      expect(result.totalSetsWithRPE, 16);
    });

    test('should calculate correct percentages', () {
      final workouts = [
        createWorkoutWithRPE(rpeCounts: {
          7: 5,  // 50% moderate
          8: 5,  // 50% hard
        }),
      ];

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts);

      expect(result.moderatePercentage, 50.0);
      expect(result.hardPercentage, 50.0);
      expect(result.recoveryPercentage, 0.0);
      expect(result.veryHardPercentage, 0.0);
      expect(result.maximalPercentage, 0.0);
      expect(result.totalSetsWithRPE, 10);
    });

    test('should skip warmup sets', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {8: 5},
          includeWarmup: true, // Should be ignored
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts);

      // Only working sets counted
      expect(result.totalSetsWithRPE, 5);
      expect(result.hardSets, 5);
    });

    test('should skip incomplete sets', () {
      final workout = Workout(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        exercises: [
          Exercise(
            name: 'Exercise',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 100,
                reps: 10,
                isCompleted: false, // Not completed
                isWarmup: false,
                rpe: 8,
              ),
              ExerciseSet(
                setNumber: 2,
                weight: 100,
                reps: 10,
                isCompleted: true,
                isWarmup: false,
                rpe: 8,
              ),
            ],
          ),
        ],
      );

      final result = RPEAnalyzer.analyzeRPEDistribution([workout]);

      expect(result.totalSetsWithRPE, 1); // Only completed set
      expect(result.hardSets, 1);
    });

    test('should skip sets without RPE', () {
      final workout = Workout(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        exercises: [
          Exercise(
            name: 'Exercise',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 100,
                reps: 10,
                isCompleted: true,
                isWarmup: false,
                rpe: null, // No RPE
              ),
              ExerciseSet(
                setNumber: 2,
                weight: 100,
                reps: 10,
                isCompleted: true,
                isWarmup: false,
                rpe: 8,
              ),
            ],
          ),
        ],
      );

      final result = RPEAnalyzer.analyzeRPEDistribution([workout]);

      expect(result.totalSetsWithRPE, 1); // Only set with RPE
      expect(result.hardSets, 1);
    });

    test('should handle empty workout list', () {
      final result = RPEAnalyzer.analyzeRPEDistribution([]);

      expect(result.totalSetsWithRPE, 0);
      expect(result.recoverySets, 0);
      expect(result.moderateSets, 0);
      expect(result.hardSets, 0);
      expect(result.veryHardSets, 0);
      expect(result.maximalSets, 0);
      expect(result.recoveryPercentage, 0.0);
      expect(result.moderatePercentage, 0.0);
      expect(result.hardPercentage, 0.0);
      expect(result.veryHardPercentage, 0.0);
      expect(result.maximalPercentage, 0.0);
    });

    test('should handle workout with no RPE sets', () {
      final workout = Workout(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        exercises: [
          Exercise(
            name: 'Exercise',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 100,
                reps: 10,
                isCompleted: true,
                isWarmup: false,
                rpe: null,
              ),
            ],
          ),
        ],
      );

      final result = RPEAnalyzer.analyzeRPEDistribution([workout]);

      expect(result.totalSetsWithRPE, 0);
      expect(result.recoveryPercentage, 0.0);
    });

    test('should filter workouts by days parameter', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {8: 5},
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        createWorkoutWithRPE(
          rpeCounts: {8: 5},
          createdAt: DateTime.now().subtract(const Duration(days: 10)), // Too old
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts, days: 7);

      // Only first workout counted (within 7 days)
      expect(result.totalSetsWithRPE, 5);
      expect(result.hardSets, 5);
    });

    test('should handle RPE above 10', () {
      final workout = Workout(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
        exercises: [
          Exercise(
            name: 'Exercise',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 100,
                reps: 10,
                isCompleted: true,
                isWarmup: false,
                rpe: 11, // Edge case: RPE > 10
              ),
            ],
          ),
        ],
      );

      final result = RPEAnalyzer.analyzeRPEDistribution([workout]);

      // Should be counted as maximal (>= 10)
      expect(result.maximalSets, 1);
      expect(result.totalSetsWithRPE, 1);
    });
  });

  group('analyzeRPEPerMuscleGroup', () {
    test('should calculate average RPE per muscle group', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {8: 5, 9: 5},
          category: ExerciseCategory.chest,
        ),
        createWorkoutWithRPE(
          rpeCounts: {7: 5, 8: 5},
          category: ExerciseCategory.back,
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts);

      // Chest: (8*5 + 9*5) / 10 = 85 / 10 = 8.5
      expect(result[MuscleGroup.chest]!.averageRPE, 8.5);
      expect(result[MuscleGroup.chest]!.totalSets, 10);

      // Back: (7*5 + 8*5) / 10 = 75 / 10 = 7.5
      expect(result[MuscleGroup.back]!.averageRPE, 7.5);
      expect(result[MuscleGroup.back]!.totalSets, 10);
    });

    test('should calculate min and max RPE correctly', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {6: 2, 9: 3, 10: 1},
          category: ExerciseCategory.chest,
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts);

      expect(result[MuscleGroup.chest]!.minRPE, 6);
      expect(result[MuscleGroup.chest]!.maxRPE, 10);
      expect(result[MuscleGroup.chest]!.totalSets, 6);
    });

    test('should return zero stats for muscle groups with no data', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {8: 5},
          category: ExerciseCategory.chest,
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts);

      // Chest has data
      expect(result[MuscleGroup.chest]!.totalSets, 5);

      // Back has no data - should be zeros
      expect(result[MuscleGroup.back]!.averageRPE, 0);
      expect(result[MuscleGroup.back]!.minRPE, 0);
      expect(result[MuscleGroup.back]!.maxRPE, 0);
      expect(result[MuscleGroup.back]!.totalSets, 0);
    });

    test('should skip warmup sets', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {8: 5},
          category: ExerciseCategory.chest,
          includeWarmup: true,
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts);

      // Only working sets counted
      expect(result[MuscleGroup.chest]!.totalSets, 5);
      expect(result[MuscleGroup.chest]!.averageRPE, 8.0);
    });

    test('should filter workouts by days parameter', () {
      final workouts = [
        createWorkoutWithRPE(
          rpeCounts: {8: 5},
          category: ExerciseCategory.chest,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        createWorkoutWithRPE(
          rpeCounts: {9: 5},
          category: ExerciseCategory.chest,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      final result = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts, days: 7);

      // Only first workout (within 7 days)
      expect(result[MuscleGroup.chest]!.totalSets, 5);
      expect(result[MuscleGroup.chest]!.averageRPE, 8.0);
    });

    test('should handle multiple exercises for same muscle group', () {
      final workout = Workout(
        id: 'test',
        name: 'Test',
        createdAt: DateTime.now(),
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
                rpe: 8,
              ),
            ],
          ),
          Exercise(
            name: 'Incline Press',
            category: ExerciseCategory.chest,
            type: ExerciseType.single,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 80,
                reps: 12,
                isCompleted: true,
                isWarmup: false,
                rpe: 7,
              ),
            ],
          ),
        ],
      );

      final result = RPEAnalyzer.analyzeRPEPerMuscleGroup([workout]);

      // Both exercises for chest: (8 + 7) / 2 = 7.5
      expect(result[MuscleGroup.chest]!.averageRPE, 7.5);
      expect(result[MuscleGroup.chest]!.totalSets, 2);
    });
  });

  group('getIntensityZone', () {
    test('should return tooEasy when >50% recovery sets', () {
      final distribution = RPEDistributionData(
        recoverySets: 60,      // 60% recovery
        moderateSets: 20,
        hardSets: 10,
        veryHardSets: 10,
        maximalSets: 0,
        totalSetsWithRPE: 100,
        recoveryPercentage: 60.0,
        moderatePercentage: 20.0,
        hardPercentage: 10.0,
        veryHardPercentage: 10.0,
        maximalPercentage: 0.0,
      );

      final zone = RPEAnalyzer.getIntensityZone(distribution);

      expect(zone, IntensityZone.tooEasy);
    });

    test('should return optimalHypertrophy when 60-80% productive sets', () {
      final distribution = RPEDistributionData(
        recoverySets: 30,
        moderateSets: 30,      // RPE 7
        hardSets: 30,          // RPE 8
        veryHardSets: 10,      // RPE 9
        maximalSets: 0,
        totalSetsWithRPE: 100,
        recoveryPercentage: 30.0,
        moderatePercentage: 30.0,
        hardPercentage: 30.0,
        veryHardPercentage: 10.0,
        maximalPercentage: 0.0,
      );

      // Productive = 30 + 30 + 10 = 70%
      final zone = RPEAnalyzer.getIntensityZone(distribution);

      expect(zone, IntensityZone.optimalHypertrophy);
    });

    test('should return optimalStrength when 50-70% very hard sets', () {
      final distribution = RPEDistributionData(
        recoverySets: 30,
        moderateSets: 5,       // Reduced to avoid hypertrophy range
        hardSets: 20,          // RPE 8
        veryHardSets: 20,      // RPE 9
        maximalSets: 25,       // RPE 10 - increased
        totalSetsWithRPE: 100,
        recoveryPercentage: 30.0,
        moderatePercentage: 5.0,
        hardPercentage: 20.0,
        veryHardPercentage: 20.0,
        maximalPercentage: 25.0,
      );

      // Productive = 5 + 20 + 20 = 45% (< 60, NOT hypertrophy)
      // Very hard = 20 + 20 + 25 = 65% (50-70, optimalStrength ✅)
      final zone = RPEAnalyzer.getIntensityZone(distribution);

      expect(zone, IntensityZone.optimalStrength);
    });

    test('should return tooHard when >30% maximal sets', () {
      final distribution = RPEDistributionData(
        recoverySets: 10,
        moderateSets: 5,       // Reduced to avoid hypertrophy range
        hardSets: 10,          // Reduced
        veryHardSets: 15,      // Moderate
        maximalSets: 60,       // 60% maximal - way too much!
        totalSetsWithRPE: 100,
        recoveryPercentage: 10.0,
        moderatePercentage: 5.0,
        hardPercentage: 10.0,
        veryHardPercentage: 15.0,
        maximalPercentage: 60.0,
      );

      // Productive = 5 + 10 + 15 = 30% (< 60, NOT hypertrophy)
      // Maximal = 60% (> 30, tooHard ✅)
      final zone = RPEAnalyzer.getIntensityZone(distribution);

      expect(zone, IntensityZone.tooHard);
    });

    test('should return balanced when no specific criteria match', () {
      final distribution = RPEDistributionData(
        recoverySets: 20,      // Not >50%
        moderateSets: 40,
        hardSets: 20,
        veryHardSets: 10,
        maximalSets: 10,       // Not >30%
        totalSetsWithRPE: 100,
        recoveryPercentage: 20.0,
        moderatePercentage: 40.0,
        hardPercentage: 20.0,
        veryHardPercentage: 10.0,
        maximalPercentage: 10.0,
      );

      // Productive = 40 + 20 + 10 = 70% (optimalHypertrophy range)
      // Very hard = 20 + 10 + 10 = 40% (not in optimalStrength range 50-70%)
      final zone = RPEAnalyzer.getIntensityZone(distribution);

      expect(zone, IntensityZone.optimalHypertrophy);
    });

    test('should handle edge case at exactly 50% recovery', () {
      final distribution = RPEDistributionData(
        recoverySets: 50,      // Exactly 50%
        moderateSets: 30,
        hardSets: 20,
        veryHardSets: 0,
        maximalSets: 0,
        totalSetsWithRPE: 100,
        recoveryPercentage: 50.0,
        moderatePercentage: 30.0,
        hardPercentage: 20.0,
        veryHardPercentage: 0.0,
        maximalPercentage: 0.0,
      );

      final zone = RPEAnalyzer.getIntensityZone(distribution);

      // Should NOT be tooEasy (needs >50%)
      expect(zone, isNot(IntensityZone.tooEasy));
    });

    test('should prioritize tooEasy over other zones', () {
      final distribution = RPEDistributionData(
        recoverySets: 60,      // >50% recovery - triggers tooEasy
        moderateSets: 10,
        hardSets: 10,
        veryHardSets: 10,
        maximalSets: 10,
        totalSetsWithRPE: 100,
        recoveryPercentage: 60.0,
        moderatePercentage: 10.0,
        hardPercentage: 10.0,
        veryHardPercentage: 10.0,
        maximalPercentage: 10.0,
      );

      final zone = RPEAnalyzer.getIntensityZone(distribution);

      expect(zone, IntensityZone.tooEasy);
    });

    test('should handle edge case at exactly 30% maximal', () {
      final distribution = RPEDistributionData(
        recoverySets: 20,
        moderateSets: 20,
        hardSets: 20,
        veryHardSets: 10,
        maximalSets: 30,       // Exactly 30%
        totalSetsWithRPE: 100,
        recoveryPercentage: 20.0,
        moderatePercentage: 20.0,
        hardPercentage: 20.0,
        veryHardPercentage: 10.0,
        maximalPercentage: 30.0,
      );

      final zone = RPEAnalyzer.getIntensityZone(distribution);

      // Should NOT be tooHard (needs >30%)
      expect(zone, isNot(IntensityZone.tooHard));
    });
  });

  group('RPEDistributionData', () {
    test('should create instance with all fields', () {
      final distribution = RPEDistributionData(
        recoverySets: 10,
        moderateSets: 20,
        hardSets: 30,
        veryHardSets: 25,
        maximalSets: 15,
        totalSetsWithRPE: 100,
        recoveryPercentage: 10.0,
        moderatePercentage: 20.0,
        hardPercentage: 30.0,
        veryHardPercentage: 25.0,
        maximalPercentage: 15.0,
      );

      expect(distribution.recoverySets, 10);
      expect(distribution.moderateSets, 20);
      expect(distribution.hardSets, 30);
      expect(distribution.veryHardSets, 25);
      expect(distribution.maximalSets, 15);
      expect(distribution.totalSetsWithRPE, 100);
      expect(distribution.recoveryPercentage, 10.0);
      expect(distribution.moderatePercentage, 20.0);
      expect(distribution.hardPercentage, 30.0);
      expect(distribution.veryHardPercentage, 25.0);
      expect(distribution.maximalPercentage, 15.0);
    });
  });

  group('RPEStats', () {
    test('should create instance with all fields', () {
      final stats = RPEStats(
        averageRPE: 8.5,
        minRPE: 7,
        maxRPE: 10,
        totalSets: 20,
      );

      expect(stats.averageRPE, 8.5);
      expect(stats.minRPE, 7);
      expect(stats.maxRPE, 10);
      expect(stats.totalSets, 20);
    });
  });

  group('IntensityZone Enum', () {
    test('should have all expected values', () {
      expect(IntensityZone.values.length, 5);
      expect(IntensityZone.values, contains(IntensityZone.tooEasy));
      expect(IntensityZone.values, contains(IntensityZone.optimalHypertrophy));
      expect(IntensityZone.values, contains(IntensityZone.optimalStrength));
      expect(IntensityZone.values, contains(IntensityZone.balanced));
      expect(IntensityZone.values, contains(IntensityZone.tooHard));
    });
  });

  group('Integration Tests', () {
    test('should handle complete workout analysis workflow', () {
      // Create realistic training week
      final workouts = [
        // Day 1: Heavy strength (RPE 8-10)
        createWorkoutWithRPE(
          rpeCounts: {8: 4, 9: 4, 10: 2},
          category: ExerciseCategory.chest,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        // Day 2: Moderate hypertrophy (RPE 7-8)
        createWorkoutWithRPE(
          rpeCounts: {7: 6, 8: 4},
          category: ExerciseCategory.back,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        // Day 3: Light recovery (RPE 5-6)
        createWorkoutWithRPE(
          rpeCounts: {5: 5, 6: 5},
          category: ExerciseCategory.legs,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      // Test distribution
      final distribution = RPEAnalyzer.analyzeRPEDistribution(workouts);
      expect(distribution.totalSetsWithRPE, 30);
      expect(distribution.recoverySets, 10);
      expect(distribution.moderateSets, 6);
      expect(distribution.hardSets, 8);
      expect(distribution.veryHardSets, 4);
      expect(distribution.maximalSets, 2);

      // Test per muscle group
      final perMuscle = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts);
      expect(perMuscle[MuscleGroup.chest]!.totalSets, 10);
      expect(perMuscle[MuscleGroup.back]!.totalSets, 10);
      expect(perMuscle[MuscleGroup.legs]!.totalSets, 10);

      // Test intensity zone
      final zone = RPEAnalyzer.getIntensityZone(distribution);
      expect(zone, isA<IntensityZone>());
    });

    test('should provide consistent results across multiple analyses', () {
      final workouts = [
        createWorkoutWithRPE(rpeCounts: {8: 5, 9: 5}),
      ];

      final result1 = RPEAnalyzer.analyzeRPEDistribution(workouts);
      final result2 = RPEAnalyzer.analyzeRPEDistribution(workouts);

      expect(result1.totalSetsWithRPE, result2.totalSetsWithRPE);
      expect(result1.hardPercentage, result2.hardPercentage);
      expect(result1.veryHardPercentage, result2.veryHardPercentage);
    });
  });

  group('Edge Cases', () {
    test('should handle workout with only one RPE value', () {
      final workouts = [
        createWorkoutWithRPE(rpeCounts: {8: 10}),
      ];

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts);

      expect(result.totalSetsWithRPE, 10);
      expect(result.hardSets, 10);
      expect(result.hardPercentage, 100.0);
    });

    test('should handle very large workout count', () {
      final workouts = List.generate(
        100,
        (i) => createWorkoutWithRPE(
          rpeCounts: {8: 5},
          createdAt: DateTime.now().subtract(Duration(days: i % 7)),
        ),
      );

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts);

      expect(result.totalSetsWithRPE, greaterThan(0));
      expect(result.hardPercentage, 100.0);
    });

    test('should handle fractional percentages correctly', () {
      final workouts = [
        createWorkoutWithRPE(rpeCounts: {7: 1, 8: 1, 9: 1}),
      ];

      final result = RPEAnalyzer.analyzeRPEDistribution(workouts);

      expect(result.moderatePercentage, closeTo(33.33, 0.1));
      expect(result.hardPercentage, closeTo(33.33, 0.1));
      expect(result.veryHardPercentage, closeTo(33.33, 0.1));
    });
  });
}
