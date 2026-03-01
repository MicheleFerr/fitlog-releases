import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';

void main() {
  // ---------------------------------------------------------------------------
  // calculateWeeklySets
  // ---------------------------------------------------------------------------
  group('calculateWeeklySets', () {
    test('calculates weekly sets per muscle group correctly', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Squat', ExerciseCategory.legs, sets: 5),
          ],
        ),
        _createWorkout(
          daysAgo: 4,
          exercises: [
            _createExercise('Pull-ups', ExerciseCategory.back, sets: 3),
            _createExercise('Overhead Press', ExerciseCategory.shoulders, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.chest], 4);
      expect(result[MuscleGroup.legs], 5);
      expect(result[MuscleGroup.back], 3);
      expect(result[MuscleGroup.shoulders], 4);
      expect(result[MuscleGroup.arms], 0);
      expect(result[MuscleGroup.core], 0);
    });

    test('only counts workouts from last 7 days', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 4)],
        ),
        _createWorkout(
          daysAgo: 10, // older than 7 days — should not count
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.chest], 4);
    });

    test('returns zeroes for empty workouts list', () {
      final result = VolumeAnalyzer.calculateWeeklySets([]);

      for (final group in MuscleGroup.values) {
        expect(result[group], 0);
      }
    });

    test('skips cardio and uncategorized exercises', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Running', ExerciseCategory.cardio, sets: 1),
            _createExercise('Unknown', ExerciseCategory.other, sets: 2),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.chest], 4);
      // All other groups must be 0
      expect(result[MuscleGroup.back], 0);
      expect(result[MuscleGroup.shoulders], 0);
      expect(result[MuscleGroup.arms], 0);
      expect(result[MuscleGroup.legs], 0);
      expect(result[MuscleGroup.core], 0);
    });

    test('accumulates sets from multiple workouts within the week', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Incline Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 5,
          exercises: [_createExercise('Flyes', ExerciseCategory.chest, sets: 2)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.chest], 8); // 3 + 3 + 2
    });

    test('maps abs category to core muscle group', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Plank', ExerciseCategory.abs, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.core], 3);
    });

    test('maps arms category to arms muscle group', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Curl', ExerciseCategory.arms, sets: 4)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySets(workouts);

      expect(result[MuscleGroup.arms], 4);
    });
  });

  // ---------------------------------------------------------------------------
  // calculateWeeklySetsWeighted — no muscle map (category fallback)
  // ---------------------------------------------------------------------------
  group('calculateWeeklySetsWeighted — category fallback', () {
    test('returns correct weighted sets using category when no muscle map', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Squat', ExerciseCategory.legs, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(workouts);

      expect(result[MuscleGroup.chest], 4.0);
      expect(result[MuscleGroup.legs], 3.0);
    });

    test('returns zeroes for empty workouts', () {
      final result = VolumeAnalyzer.calculateWeeklySetsWeighted([]);

      for (final group in MuscleGroup.values) {
        expect(result[group], 0.0);
      }
    });

    test('skips exercises with no sets', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExerciseNoSets('Bench Press', ExerciseCategory.chest),
            _createExercise('Squat', ExerciseCategory.legs, sets: 2),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(workouts);

      expect(result[MuscleGroup.chest], 0.0);
      expect(result[MuscleGroup.legs], 2.0);
    });

    test('ignores workouts older than 7 days', () {
      final workouts = [
        _createWorkout(
          daysAgo: 8,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 5)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 2)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(workouts);

      expect(result[MuscleGroup.chest], 2.0);
    });

    test('skips cardio/other exercises without muscle map', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Running', ExerciseCategory.cardio, sets: 5),
            _createExercise('Misc', ExerciseCategory.other, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(workouts);

      for (final group in MuscleGroup.values) {
        expect(result[group], 0.0);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // calculateWeeklySetsWeighted — with muscle map (EMG distribution)
  // ---------------------------------------------------------------------------
  group('calculateWeeklySetsWeighted — with muscle map', () {
    test('distributes sets with primary and secondary muscle data', () {
      // Bench Press: primary PETT (chest), secondary DELT_ANT (shoulders), TRIC (arms)
      final muscleMap = {
        'Bench Press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: ['DELT_ANT', 'TRIC'],
          fileCategory: 'Push Pattern',
          exerciseName: 'Bench Press',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 4)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // Primary (chest) should receive 60% of 4 sets = 2.4 (pushHorizontal)
      expect(result[MuscleGroup.chest], greaterThan(0.0));
      // Shoulders should receive some synergist volume
      expect(result[MuscleGroup.shoulders], greaterThan(0.0));
      // Arms (triceps) should receive some volume
      expect(result[MuscleGroup.arms], greaterThan(0.0));
      // Total distributed volume must not exceed total sets (EMG ratios sum to 1)
      final total = result.values.fold(0.0, (a, b) => a + b);
      expect(total, closeTo(4.0, 0.01));
    });

    test('falls back to category when exercise not in map', () {
      final muscleMap = <String, ExerciseMuscleData>{};

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Pull-ups', ExerciseCategory.back, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      expect(result[MuscleGroup.back], 3.0);
    });

    test('uses case-insensitive lookup for exercise names', () {
      final muscleMap = {
        'bench press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: [],
          fileCategory: 'Push Pattern',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          // Stored with original casing — lookup should find lowercase key
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // With only primary muscle and no secondary, 100% goes to chest
      expect(result[MuscleGroup.chest], closeTo(3.0, 0.01));
    });

    test('handles exercise with only secondary muscles (no primary)', () {
      // Rare edge case: no primary, only secondary
      final muscleMap = {
        'Mystery Exercise': ExerciseMuscleData(
          primary: [],
          secondary: ['DELT_ANT', 'TRIC'],
          fileCategory: 'Push Pattern',
          exerciseName: 'Mystery Exercise',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Mystery Exercise', ExerciseCategory.shoulders, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // All volume should go to secondary muscles — total ≈ 4
      final total = result.values.fold(0.0, (a, b) => a + b);
      expect(total, greaterThan(0.0));
    });

    test('handles exercise with no recognized muscles gracefully', () {
      final muscleMap = {
        'Unknown Muscle Exercise': ExerciseMuscleData(
          primary: [],
          secondary: [],
          fileCategory: '',
          exerciseName: 'Unknown Muscle Exercise',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise(
              'Unknown Muscle Exercise',
              ExerciseCategory.other,
              sets: 3,
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // No distribution when both primary and secondary are empty
      for (final group in MuscleGroup.values) {
        expect(result[group], 0.0);
      }
    });

    test('distributes only to primary when no secondary exists', () {
      final muscleMap = {
        'Isolation Curl': ExerciseMuscleData(
          primary: ['BICI'],
          secondary: [],
          fileCategory: 'Isolation',
          exerciseName: 'Isolation Curl',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Isolation Curl', ExerciseCategory.arms, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // 100% to arms (BICI maps to arms, no secondary so full 3.0 sets)
      expect(result[MuscleGroup.arms], closeTo(3.0, 0.01));
    });

    test('handles multiple primary muscle groups splitting sets', () {
      // Exercise targets back AND legs as primary
      final muscleMap = {
        'Deadlift': ExerciseMuscleData(
          primary: ['LOMB', 'GLUT'],
          secondary: ['QUAD'],
          fileCategory: 'Hinge Pattern',
          exerciseName: 'Deadlift',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Deadlift', ExerciseCategory.back, sets: 4)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // Both back (LOMB) and legs (GLUT, QUAD) should get some volume
      expect(result[MuscleGroup.back], greaterThan(0.0));
      expect(result[MuscleGroup.legs], greaterThan(0.0));
    });

    test('handles empty fileCategory by using inferPattern fallback', () {
      // Empty fileCategory causes EmgMovementRatios.inferPattern to be called
      final muscleMap = {
        'Pull-up': ExerciseMuscleData(
          primary: ['LAT'],
          secondary: ['BRAC'],
          fileCategory: '', // empty → triggers inferPattern
          exerciseName: 'Pull-up',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Pull-up', ExerciseCategory.back, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      expect(result[MuscleGroup.back], greaterThan(0.0));
    });

    test('accumulates volume across multiple workouts with muscle map', () {
      final muscleMap = {
        'Bench Press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: [],
          fileCategory: 'Push Pattern',
          exerciseName: 'Bench Press',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 2)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // 5 total sets all to chest (no secondary)
      expect(result[MuscleGroup.chest], closeTo(5.0, 0.01));
    });

    test('tiered synergist: first secondary gets more volume than remaining', () {
      // Bench press: primary chest, secondary [shoulders (high synergist), arms (moderate)]
      final muscleMap = {
        'Bench Press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: ['DELT_ANT', 'TRIC'],
          fileCategory: 'Push Pattern',
          exerciseName: 'Bench Press',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 10)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // Shoulders (first synergist) should get more than arms (second/moderate synergist)
      expect(
        result[MuscleGroup.shoulders]!,
        greaterThan(result[MuscleGroup.arms]!),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // calculateWeeklySetsWithExercisesWeighted
  // ---------------------------------------------------------------------------
  group('calculateWeeklySetsWithExercisesWeighted', () {
    test('returns empty result for empty workout list', () {
      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted([]);

      for (final group in MuscleGroup.values) {
        expect(result.categorized[group], isEmpty);
        expect(result.totalWeightedSets[group], 0.0);
      }
      expect(result.uncategorized, isEmpty);
    });

    test('categorizes chest exercises using category fallback', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      final contribution = result.categorized[MuscleGroup.chest]!.first;
      expect(contribution.exerciseName, 'Bench Press');
      expect(contribution.rawSets, 4);
      expect(contribution.weightedSets, 4.0);
      expect(contribution.isPrimary, true);
      expect(result.totalWeightedSets[MuscleGroup.chest], 4.0);
    });

    test('places cardio and other exercises in uncategorized', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 3),
            _createExercise('Running', ExerciseCategory.cardio, sets: 1),
            _createExercise('Yoga', ExerciseCategory.other, sets: 2),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.uncategorized.length, 2);
      expect(
        result.uncategorized.any((e) => e.exerciseName == 'Running'),
        isTrue,
      );
      expect(
        result.uncategorized.any((e) => e.exerciseName == 'Yoga'),
        isTrue,
      );
    });

    test('combines same exercise across multiple workouts', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Squat', ExerciseCategory.legs, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 4,
          exercises: [_createExercise('Squat', ExerciseCategory.legs, sets: 2)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.categorized[MuscleGroup.legs]!.length, 1);
      expect(result.categorized[MuscleGroup.legs]!.first.rawSets, 5);
    });

    test('combines same uncategorized exercise across multiple workouts', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Running', ExerciseCategory.cardio, sets: 2)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Running', ExerciseCategory.cardio, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.uncategorized.length, 1);
      expect(result.uncategorized.first.rawSets, 5);
    });

    test('sorts categorized exercises by weighted sets descending', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 2),
            _createExercise('Incline Press', ExerciseCategory.chest, sets: 5),
            _createExercise('Flyes', ExerciseCategory.chest, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      final chestExercises = result.categorized[MuscleGroup.chest]!;
      expect(chestExercises[0].exerciseName, 'Incline Press'); // 5 sets
      expect(chestExercises[1].exerciseName, 'Flyes'); // 3 sets
      expect(chestExercises[2].exerciseName, 'Bench Press'); // 2 sets
    });

    test('sorts uncategorized exercises by weighted sets descending', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Running', ExerciseCategory.cardio, sets: 1),
            _createExercise('Swimming', ExerciseCategory.cardio, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.uncategorized[0].exerciseName, 'Swimming');
      expect(result.uncategorized[1].exerciseName, 'Running');
    });

    test('skips exercises with zero sets', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExerciseNoSets('Bench Press', ExerciseCategory.chest),
            _createExercise('Squat', ExerciseCategory.legs, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.categorized[MuscleGroup.chest], isEmpty);
      expect(result.categorized[MuscleGroup.legs]!.length, 1);
    });

    test('uses muscle map for EMG-based distribution', () {
      final muscleMap = {
        'Bench Press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: ['DELT_ANT'],
          fileCategory: 'Push Pattern',
          exerciseName: 'Bench Press',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // Chest should have primary contribution
      expect(result.categorized[MuscleGroup.chest]!.isNotEmpty, isTrue);
      expect(result.categorized[MuscleGroup.chest]!.first.isPrimary, isTrue);

      // Shoulders should have secondary contribution
      expect(result.categorized[MuscleGroup.shoulders]!.isNotEmpty, isTrue);
    });

    test('combines same exercise via muscle map across multiple workouts', () {
      final muscleMap = {
        'Bench Press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: [],
          fileCategory: 'Push Pattern',
          exerciseName: 'Bench Press',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 2)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // Should merge into one entry with combined rawSets
      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.categorized[MuscleGroup.chest]!.first.rawSets, 5);
    });

    test('uses case-insensitive lookup from muscle map', () {
      final muscleMap = {
        'bench press': ExerciseMuscleData(
          primary: ['PETT'],
          secondary: [],
          fileCategory: 'Push Pattern',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      expect(result.categorized[MuscleGroup.chest]!.isNotEmpty, isTrue);
    });

    test('handles exercise with only secondary muscles in weighted breakdown', () {
      final muscleMap = {
        'Mystery Exercise': ExerciseMuscleData(
          primary: [],
          secondary: ['DELT_ANT', 'TRIC'],
          fileCategory: 'Push Pattern',
          exerciseName: 'Mystery Exercise',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Mystery Exercise', ExerciseCategory.shoulders, sets: 4),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // Volume should be distributed to secondary groups
      final allGroups = MuscleGroup.values
          .map((g) => result.totalWeightedSets[g]!)
          .fold(0.0, (a, b) => a + b);
      expect(allGroups, greaterThan(0.0));
    });

    test('falls back to category when muscle data has empty primary and secondary', () {
      // hasData is false when both lists are empty, so category fallback is used
      final muscleMap = {
        'Undefined Exercise': ExerciseMuscleData(
          primary: [],
          secondary: [],
          fileCategory: 'Push Pattern',
          exerciseName: 'Undefined Exercise',
        ),
      };

      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Undefined Exercise', ExerciseCategory.chest, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(
        workouts,
        exerciseMuscleMap: muscleMap,
      );

      // hasData == false → category fallback → chest gets all 3 sets
      expect(result.totalWeightedSets[MuscleGroup.chest], 3.0);
    });

    test('excludes workouts older than 7 days', () {
      final workouts = [
        _createWorkout(
          daysAgo: 10,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 5)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercisesWeighted(workouts);

      expect(result.categorized[MuscleGroup.chest], isEmpty);
      expect(result.totalWeightedSets[MuscleGroup.chest], 0.0);
    });
  });

  // ---------------------------------------------------------------------------
  // calculateWeeklySetsWithExercises (non-weighted)
  // ---------------------------------------------------------------------------
  group('calculateWeeklySetsWithExercises', () {
    test('returns exercises grouped by muscle with set counts', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Squat', ExerciseCategory.legs, sets: 5),
            _createExercise('Pull-ups', ExerciseCategory.back, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.categorized[MuscleGroup.chest]!.first.exerciseName, 'Bench Press');
      expect(result.categorized[MuscleGroup.chest]!.first.sets, 4);
      expect(result.categorized[MuscleGroup.legs]!.first.sets, 5);
      expect(result.categorized[MuscleGroup.back]!.first.sets, 3);
    });

    test('combines sets for same exercise across workouts', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 3)],
        ),
        _createWorkout(
          daysAgo: 4,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 4)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.categorized[MuscleGroup.chest]!.first.sets, 7); // 3 + 4
    });

    test('handles uncategorized exercises separately', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 4),
            _createExercise('Running', ExerciseCategory.cardio, sets: 1),
            _createExercise('Yoga', ExerciseCategory.other, sets: 1),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest]!.length, 1);
      expect(result.uncategorized.length, 2);
      expect(result.uncategorized.any((e) => e.exerciseName == 'Running'), isTrue);
      expect(result.uncategorized.any((e) => e.exerciseName == 'Yoga'), isTrue);
    });

    test('sorts exercises by sets descending', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise('Bench Press', ExerciseCategory.chest, sets: 2),
            _createExercise('Incline Press', ExerciseCategory.chest, sets: 5),
            _createExercise('Flyes', ExerciseCategory.chest, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      final chestExercises = result.categorized[MuscleGroup.chest]!;
      expect(chestExercises[0].exerciseName, 'Incline Press');
      expect(chestExercises[1].exerciseName, 'Flyes');
      expect(chestExercises[2].exerciseName, 'Bench Press');
    });

    test('handles empty workouts gracefully', () {
      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises([]);

      for (final group in MuscleGroup.values) {
        expect(result.categorized[group], isEmpty);
      }
      expect(result.uncategorized, isEmpty);
    });

    test('combines same uncategorized exercise across workouts', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [_createExercise('Running', ExerciseCategory.cardio, sets: 2)],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [_createExercise('Running', ExerciseCategory.cardio, sets: 3)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.uncategorized.length, 1);
      expect(result.uncategorized.first.exerciseName, 'Running');
      expect(result.uncategorized.first.sets, 5);
    });

    test('sorts uncategorized exercises by sets descending', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise('Running', ExerciseCategory.cardio, sets: 1),
            _createExercise('Swimming', ExerciseCategory.cardio, sets: 5),
            _createExercise('Cycling', ExerciseCategory.cardio, sets: 3),
          ],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.uncategorized[0].exerciseName, 'Swimming');
      expect(result.uncategorized[1].exerciseName, 'Cycling');
      expect(result.uncategorized[2].exerciseName, 'Running');
    });

    test('respects 7-day window for exercises', () {
      final workouts = [
        _createWorkout(
          daysAgo: 9,
          exercises: [_createExercise('Bench Press', ExerciseCategory.chest, sets: 4)],
        ),
      ];

      final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);

      expect(result.categorized[MuscleGroup.chest], isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // analyzeRepContinuum
  // ---------------------------------------------------------------------------
  group('analyzeRepContinuum', () {
    test('classifies strength sets correctly (1-5 reps)', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise(
              'Bench Press',
              ExerciseCategory.chest,
              sets: 3,
              repsPerSet: [3, 4, 5],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 3);
      expect(result.hypertrophySets, 0);
      expect(result.enduranceSets, 0);
      expect(result.totalSets, 3);
      expect(result.strengthPercentage, 100.0);
    });

    test('classifies hypertrophy sets correctly (6-15 reps)', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise(
              'Bench Press',
              ExerciseCategory.chest,
              sets: 4,
              repsPerSet: [8, 10, 12, 15],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 0);
      expect(result.hypertrophySets, 4);
      expect(result.enduranceSets, 0);
      expect(result.hypertrophyPercentage, 100.0);
    });

    test('classifies endurance sets correctly (16+ reps)', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise(
              'Leg Press',
              ExerciseCategory.legs,
              sets: 3,
              repsPerSet: [16, 20, 25],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 0);
      expect(result.hypertrophySets, 0);
      expect(result.enduranceSets, 3);
      expect(result.endurancePercentage, 100.0);
    });

    test('handles mixed rep ranges', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise(
              'Squat',
              ExerciseCategory.legs,
              sets: 5,
              repsPerSet: [3, 5, 10, 12, 20],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 2); // 3, 5 reps
      expect(result.hypertrophySets, 2); // 10, 12 reps
      expect(result.enduranceSets, 1); // 20 reps
      expect(result.totalSets, 5);
      expect(result.strengthPercentage, 40.0);
      expect(result.hypertrophyPercentage, 40.0);
      expect(result.endurancePercentage, 20.0);
    });

    test('skips sets without rep data', () {
      final workouts = [
        _createWorkout(
          daysAgo: 2,
          exercises: [
            _createExercise(
              'Bench Press',
              ExerciseCategory.chest,
              sets: 3,
              repsPerSet: [10, null, 12],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.totalSets, 2); // null rep set excluded
      expect(result.hypertrophySets, 2);
    });

    test('returns zeroes for empty workouts', () {
      final result = VolumeAnalyzer.analyzeRepContinuum([]);

      expect(result.totalSets, 0);
      expect(result.strengthPercentage, 0.0);
      expect(result.hypertrophyPercentage, 0.0);
      expect(result.endurancePercentage, 0.0);
    });

    test('boundary: 5 reps is strength, 6 reps is hypertrophy', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise(
              'Squat',
              ExerciseCategory.legs,
              sets: 2,
              repsPerSet: [5, 6],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 1); // 5
      expect(result.hypertrophySets, 1); // 6
    });

    test('boundary: 15 reps is hypertrophy, 16 reps is endurance', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise(
              'Leg Extension',
              ExerciseCategory.legs,
              sets: 2,
              repsPerSet: [15, 16],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.hypertrophySets, 1); // 15
      expect(result.enduranceSets, 1); // 16
    });

    test('counts all reps across multiple exercises and workouts', () {
      final workouts = [
        _createWorkout(
          daysAgo: 1,
          exercises: [
            _createExercise(
              'Squat',
              ExerciseCategory.legs,
              sets: 2,
              repsPerSet: [5, 10],
            ),
            _createExercise(
              'Curl',
              ExerciseCategory.arms,
              sets: 1,
              repsPerSet: [20],
            ),
          ],
        ),
        _createWorkout(
          daysAgo: 3,
          exercises: [
            _createExercise(
              'Bench Press',
              ExerciseCategory.chest,
              sets: 1,
              repsPerSet: [8],
            ),
          ],
        ),
      ];

      final result = VolumeAnalyzer.analyzeRepContinuum(workouts);

      expect(result.strengthSets, 1); // 5
      expect(result.hypertrophySets, 2); // 10, 8
      expect(result.enduranceSets, 1); // 20
      expect(result.totalSets, 4);
    });
  });

  // ---------------------------------------------------------------------------
  // getVolumeZone
  // ---------------------------------------------------------------------------
  group('getVolumeZone', () {
    test('below maintenance when sets less than MV', () {
      // Chest MV = 6
      expect(VolumeAnalyzer.getVolumeZone(0, MuscleGroup.chest), VolumeZone.belowMaintenance);
      expect(VolumeAnalyzer.getVolumeZone(5, MuscleGroup.chest), VolumeZone.belowMaintenance);
    });

    test('maintenance zone: MV to MEV-1', () {
      // Chest MV=6, MEV=10
      expect(VolumeAnalyzer.getVolumeZone(6, MuscleGroup.chest), VolumeZone.maintenance);
      expect(VolumeAnalyzer.getVolumeZone(9, MuscleGroup.chest), VolumeZone.maintenance);
    });

    test('effective zone: MEV to MAV-1', () {
      // Chest MEV=10, MAV=18
      expect(VolumeAnalyzer.getVolumeZone(10, MuscleGroup.chest), VolumeZone.effective);
      expect(VolumeAnalyzer.getVolumeZone(17, MuscleGroup.chest), VolumeZone.effective);
    });

    test('optimal zone: MAV to MRV-1', () {
      // Chest MAV=18, MRV=22
      expect(VolumeAnalyzer.getVolumeZone(18, MuscleGroup.chest), VolumeZone.optimal);
      expect(VolumeAnalyzer.getVolumeZone(21, MuscleGroup.chest), VolumeZone.optimal);
    });

    test('excessive zone: MRV and above', () {
      // Chest MRV=22
      expect(VolumeAnalyzer.getVolumeZone(22, MuscleGroup.chest), VolumeZone.excessive);
      expect(VolumeAnalyzer.getVolumeZone(30, MuscleGroup.chest), VolumeZone.excessive);
    });

    test('back muscle group uses correct landmarks', () {
      // Back MV=8, MEV=12, MAV=20, MRV=25
      expect(VolumeAnalyzer.getVolumeZone(7, MuscleGroup.back), VolumeZone.belowMaintenance);
      expect(VolumeAnalyzer.getVolumeZone(8, MuscleGroup.back), VolumeZone.maintenance);
      expect(VolumeAnalyzer.getVolumeZone(12, MuscleGroup.back), VolumeZone.effective);
      expect(VolumeAnalyzer.getVolumeZone(20, MuscleGroup.back), VolumeZone.optimal);
      expect(VolumeAnalyzer.getVolumeZone(25, MuscleGroup.back), VolumeZone.excessive);
    });

    test('shoulders muscle group uses correct landmarks', () {
      // Shoulders MV=6, MEV=8, MAV=16, MRV=20
      expect(VolumeAnalyzer.getVolumeZone(5, MuscleGroup.shoulders), VolumeZone.belowMaintenance);
      expect(VolumeAnalyzer.getVolumeZone(6, MuscleGroup.shoulders), VolumeZone.maintenance);
      expect(VolumeAnalyzer.getVolumeZone(8, MuscleGroup.shoulders), VolumeZone.effective);
      expect(VolumeAnalyzer.getVolumeZone(16, MuscleGroup.shoulders), VolumeZone.optimal);
      expect(VolumeAnalyzer.getVolumeZone(20, MuscleGroup.shoulders), VolumeZone.excessive);
    });

    test('arms muscle group uses correct landmarks', () {
      // Arms MV=6, MEV=8, MAV=14, MRV=18
      expect(VolumeAnalyzer.getVolumeZone(5, MuscleGroup.arms), VolumeZone.belowMaintenance);
      expect(VolumeAnalyzer.getVolumeZone(6, MuscleGroup.arms), VolumeZone.maintenance);
      expect(VolumeAnalyzer.getVolumeZone(8, MuscleGroup.arms), VolumeZone.effective);
      expect(VolumeAnalyzer.getVolumeZone(14, MuscleGroup.arms), VolumeZone.optimal);
      expect(VolumeAnalyzer.getVolumeZone(18, MuscleGroup.arms), VolumeZone.excessive);
    });

    test('legs muscle group uses correct landmarks', () {
      // Legs MV=8, MEV=10, MAV=18, MRV=22
      expect(VolumeAnalyzer.getVolumeZone(7, MuscleGroup.legs), VolumeZone.belowMaintenance);
      expect(VolumeAnalyzer.getVolumeZone(8, MuscleGroup.legs), VolumeZone.maintenance);
      expect(VolumeAnalyzer.getVolumeZone(10, MuscleGroup.legs), VolumeZone.effective);
      expect(VolumeAnalyzer.getVolumeZone(18, MuscleGroup.legs), VolumeZone.optimal);
      expect(VolumeAnalyzer.getVolumeZone(22, MuscleGroup.legs), VolumeZone.excessive);
    });

    test('core muscle group uses correct landmarks', () {
      // Core MV=6, MEV=8, MAV=15, MRV=20
      expect(VolumeAnalyzer.getVolumeZone(5, MuscleGroup.core), VolumeZone.belowMaintenance);
      expect(VolumeAnalyzer.getVolumeZone(6, MuscleGroup.core), VolumeZone.maintenance);
      expect(VolumeAnalyzer.getVolumeZone(8, MuscleGroup.core), VolumeZone.effective);
      expect(VolumeAnalyzer.getVolumeZone(15, MuscleGroup.core), VolumeZone.optimal);
      expect(VolumeAnalyzer.getVolumeZone(20, MuscleGroup.core), VolumeZone.excessive);
    });
  });

  // ---------------------------------------------------------------------------
  // Data classes
  // ---------------------------------------------------------------------------
  group('VolumeLandmarks', () {
    test('stores all landmark values', () {
      const landmarks = VolumeLandmarks(mv: 6, mev: 10, mav: 18, mrv: 22);

      expect(landmarks.mv, 6);
      expect(landmarks.mev, 10);
      expect(landmarks.mav, 18);
      expect(landmarks.mrv, 22);
    });
  });

  group('RepContinuumData', () {
    test('stores all rep data', () {
      final data = RepContinuumData(
        strengthPercentage: 25.0,
        hypertrophyPercentage: 50.0,
        endurancePercentage: 25.0,
        strengthSets: 5,
        hypertrophySets: 10,
        enduranceSets: 5,
        totalSets: 20,
      );

      expect(data.strengthPercentage, 25.0);
      expect(data.hypertrophyPercentage, 50.0);
      expect(data.endurancePercentage, 25.0);
      expect(data.strengthSets, 5);
      expect(data.hypertrophySets, 10);
      expect(data.enduranceSets, 5);
      expect(data.totalSets, 20);
    });
  });

  group('ExerciseContribution', () {
    test('stores exercise details', () {
      final contribution = ExerciseContribution(
        exerciseName: 'Bench Press',
        sets: 4,
        workoutDate: DateTime(2024, 1, 1),
        category: ExerciseCategory.chest,
      );

      expect(contribution.exerciseName, 'Bench Press');
      expect(contribution.sets, 4);
      expect(contribution.workoutDate, DateTime(2024, 1, 1));
      expect(contribution.category, ExerciseCategory.chest);
    });

    test('supports null category', () {
      final contribution = ExerciseContribution(
        exerciseName: 'Unknown',
        sets: 2,
        workoutDate: DateTime(2024, 6, 1),
      );

      expect(contribution.category, isNull);
    });
  });

  group('ExerciseContributionWeighted', () {
    test('stores all weighted contribution fields', () {
      final contribution = ExerciseContributionWeighted(
        exerciseName: 'Bench Press',
        rawSets: 4,
        weightedSets: 2.8,
        workoutDate: DateTime(2024, 1, 1),
        isPrimary: true,
        category: ExerciseCategory.chest,
      );

      expect(contribution.exerciseName, 'Bench Press');
      expect(contribution.rawSets, 4);
      expect(contribution.weightedSets, 2.8);
      expect(contribution.workoutDate, DateTime(2024, 1, 1));
      expect(contribution.isPrimary, isTrue);
      expect(contribution.category, ExerciseCategory.chest);
    });

    test('displaySets shows raw sets when equal to weightedSets rounded', () {
      final contribution = ExerciseContributionWeighted(
        exerciseName: 'Curl',
        rawSets: 3,
        weightedSets: 3.0,
        workoutDate: DateTime.now(),
        isPrimary: true,
      );

      expect(contribution.displaySets, '3 sets');
    });

    test('displaySets shows weighted and raw when they differ', () {
      final contribution = ExerciseContributionWeighted(
        exerciseName: 'Bench Press',
        rawSets: 4,
        weightedSets: 2.8,
        workoutDate: DateTime.now(),
        isPrimary: true,
      );

      expect(contribution.displaySets, '2.8 sets (4 raw)');
    });

    test('supports null category', () {
      final contribution = ExerciseContributionWeighted(
        exerciseName: 'Mystery',
        rawSets: 2,
        weightedSets: 1.4,
        workoutDate: DateTime.now(),
        isPrimary: false,
      );

      expect(contribution.category, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Static constants
  // ---------------------------------------------------------------------------
  group('Static constants', () {
    test('defaultLandmarks contains entries for all MuscleGroups', () {
      for (final group in MuscleGroup.values) {
        expect(
          VolumeAnalyzer.defaultLandmarks.containsKey(group),
          isTrue,
          reason: '$group should have default landmarks',
        );
      }
    });

    test('primaryMuscleWeight is 0.7', () {
      expect(VolumeAnalyzer.primaryMuscleWeight, 0.7);
    });

    test('secondaryMuscleWeight is 0.3', () {
      expect(VolumeAnalyzer.secondaryMuscleWeight, 0.3);
    });

    test('rep range thresholds are consistent', () {
      expect(VolumeAnalyzer.strengthMaxReps, 5);
      expect(VolumeAnalyzer.hypertrophyMinReps, 6);
      expect(VolumeAnalyzer.hypertrophyMaxReps, 15);
      expect(VolumeAnalyzer.enduranceMinReps, 16);

      // Validate no gap between ranges
      expect(VolumeAnalyzer.hypertrophyMinReps, VolumeAnalyzer.strengthMaxReps + 1);
      expect(VolumeAnalyzer.enduranceMinReps, VolumeAnalyzer.hypertrophyMaxReps + 1);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper constructors
// ---------------------------------------------------------------------------

Workout _createWorkout({
  required int daysAgo,
  required List<Exercise> exercises,
}) {
  final date = DateTime.now().subtract(Duration(days: daysAgo));
  return Workout(
    id: 'workout-$daysAgo-${exercises.length}',
    name: 'Test Workout',
    exercises: exercises,
    createdAt: date,
    updatedAt: date,
  );
}

Exercise _createExercise(
  String name,
  ExerciseCategory category, {
  required int sets,
  List<int?>? repsPerSet,
}) {
  final setsList = List.generate(sets, (i) {
    final reps = repsPerSet != null && i < repsPerSet.length
        ? repsPerSet[i]
        : 10; // default

    return ExerciseSet(
      id: 'set-$i',
      setNumber: i + 1,
      reps: reps,
      weight: 100.0,
      isCompleted: true,
    );
  });

  return Exercise(
    id: 'exercise-${name.hashCode}-$sets',
    name: name,
    type: ExerciseType.single,
    category: category,
    sets: setsList,
  );
}

/// Creates an exercise with no sets (for edge-case testing)
Exercise _createExerciseNoSets(String name, ExerciseCategory category) {
  return Exercise(
    id: 'exercise-${name.hashCode}-nosets',
    name: name,
    type: ExerciseType.single,
    category: category,
    sets: [],
  );
}
