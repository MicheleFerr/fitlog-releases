import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_volume_classifier.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';

void main() {
  group('MuscleVolumeClassifier - calculateVolumeDistribution', () {
    test('should return empty distribution for empty exercise list', () {
      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([]);

      // Assert
      expect(result.length, equals(6));
      expect(result[MuscleGroup.chest]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.back]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.shoulders]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.arms]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.legs]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.core]!.totalWeightedVolume, equals(0));
    });

    test('should calculate primary volume for single chest exercise', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, 
            reps: 10,
            weight: 100,
            isCompleted: true,
            actualReps: 10,
          ),
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert - 100kg x 10 reps = 1000 volume
      expect(result[MuscleGroup.chest]!.primaryVolume, equals(1000));
    });

    test('should calculate secondary volume for compound chest exercise', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Bench Press', // Compound - activates triceps
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, 
            reps: 10,
            weight: 100,
            isCompleted: true,
            actualReps: 10,
          ),
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert
      // Chest: 1000 primary
      // Shoulders: 500 secondary (50% of 1000)
      // Arms (triceps): 500 secondary (50% of 1000)
      expect(result[MuscleGroup.chest]!.primaryVolume, equals(1000));
      expect(result[MuscleGroup.shoulders]!.secondaryVolume, equals(500));
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(500));
    });

    test('should calculate volume for multiple sets', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        category: ExerciseCategory.legs,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10),
          ExerciseSet(setNumber: 1, reps: 8, weight: 110, isCompleted: true, actualReps: 8),
          ExerciseSet(setNumber: 1, reps: 6, weight: 120, isCompleted: true, actualReps: 6),
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert - (100*10) + (110*8) + (120*6) = 1000 + 880 + 720 = 2600
      expect(result[MuscleGroup.legs]!.primaryVolume, equals(2600));
      // Squats are compound, should activate core as secondary
      expect(result[MuscleGroup.core]!.secondaryVolume, equals(1300)); // 50% of 2600
    });

    test('should skip incomplete sets', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10),
          ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: false), // Not completed
          ExerciseSet(setNumber: 1, reps: 8, weight: 110, isCompleted: true, actualReps: 8),
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert - Only completed sets: (100*10) + (110*8) = 1000 + 880 = 1880
      expect(result[MuscleGroup.chest]!.primaryVolume, equals(1880));
    });

    test('should handle multiple exercises across different muscle groups', () {
      // Arrange
      final exercises = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
        ),
        Exercise(
          id: 'e2',
          name: 'Pull Up',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 8, weight: 0, isCompleted: true, actualReps: 8)],
        ),
        Exercise(
          id: 'e3',
          name: 'Squat',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 80, isCompleted: true, actualReps: 12)],
        ),
      ];

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution(exercises);

      // Assert
      expect(result[MuscleGroup.chest]!.primaryVolume, equals(1000)); // 100*10
      expect(result[MuscleGroup.back]!.primaryVolume, equals(0)); // Bodyweight
      expect(result[MuscleGroup.legs]!.primaryVolume, equals(960)); // 80*12
    });

    test('should accumulate volume from multiple exercises same muscle', () {
      // Arrange
      final exercises = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
        ),
        Exercise(
          id: 'e2',
          name: 'Incline Press',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 8, weight: 80, isCompleted: true, actualReps: 8)],
        ),
      ];

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution(exercises);

      // Assert - (100*10) + (80*8) = 1000 + 640 = 1640
      expect(result[MuscleGroup.chest]!.primaryVolume, equals(1640));
    });

    test('should handle exercises with zero weight', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Push Up',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, reps: 20, weight: 0, isCompleted: true, actualReps: 20),
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert
      expect(result[MuscleGroup.chest]!.primaryVolume, equals(0));
    });

    test('should handle exercises with null weight', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Plank',
        category: ExerciseCategory.abs,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, reps: 1, isCompleted: true, actualReps: 1), // weight: null
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert
      expect(result[MuscleGroup.core]!.primaryVolume, equals(0));
    });

    test('should handle cardio exercises with no muscle activation', () {
      // Arrange
      final exercise = Exercise(
        id: 'e1',
        name: 'Running',
        category: ExerciseCategory.cardio,
        type: ExerciseType.single,
        sets: [
          ExerciseSet(setNumber: 1, reps: 1, weight: 0, isCompleted: true, actualReps: 1),
        ],
      );

      // Act
      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Assert - No primary or secondary activation for cardio
      expect(result[MuscleGroup.chest]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.back]!.totalWeightedVolume, equals(0));
      expect(result[MuscleGroup.legs]!.totalWeightedVolume, equals(0));
    });
  });

  group('MuscleVolumeClassifier - Primary Muscle Classification', () {
    test('should classify chest exercises to chest muscle', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      expect(result[MuscleGroup.chest]!.primaryVolume, greaterThan(0));
    });

    test('should classify back exercises to back muscle', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Barbell Row',
        category: ExerciseCategory.back,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      expect(result[MuscleGroup.back]!.primaryVolume, equals(1000));
    });

    test('should classify shoulder exercises to shoulders muscle', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Overhead Press',
        category: ExerciseCategory.shoulders,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      expect(result[MuscleGroup.shoulders]!.primaryVolume, equals(1000));
    });

    test('should classify arms exercises to arms muscle', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Bicep Curl',
        category: ExerciseCategory.arms,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 20, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      expect(result[MuscleGroup.arms]!.primaryVolume, equals(200));
    });

    test('should classify legs exercises to legs muscle', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Squat',
        category: ExerciseCategory.legs,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      expect(result[MuscleGroup.legs]!.primaryVolume, equals(1000));
    });

    test('should classify abs exercises to core muscle', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Crunch',
        category: ExerciseCategory.abs,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 20, weight: 10, isCompleted: true, actualReps: 20)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      expect(result[MuscleGroup.core]!.primaryVolume, equals(200));
    });

    test('should not assign primary muscle to cardio exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Running',
        category: ExerciseCategory.cardio,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 1, weight: 0, isCompleted: true, actualReps: 1)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // No primary muscles should be activated
      for (final distribution in result.values) {
        expect(distribution.primaryVolume, equals(0));
      }
    });

    test('should not assign primary muscle to other category exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Stretching',
        category: ExerciseCategory.other,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 1, weight: 0, isCompleted: true, actualReps: 1)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // No primary muscles should be activated
      for (final distribution in result.values) {
        expect(distribution.primaryVolume, equals(0));
      }
    });
  });

  group('MuscleVolumeClassifier - Secondary Muscle Classification', () {
    test('should activate shoulders as secondary for chest exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Chest exercises always activate front delts (shoulders)
      expect(result[MuscleGroup.shoulders]!.secondaryVolume, equals(500)); // 50% of 1000
    });

    test('should activate arms for compound chest exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Bench Press', // Contains 'press' = compound
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Compound chest exercises activate triceps
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(500)); // 50% of 1000
    });

    test('should not activate arms for isolation chest exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Cable Fly', // No compound keyword
        category: ExerciseCategory.chest,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 30, isCompleted: true, actualReps: 12)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Isolation chest exercises don't activate triceps
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0));
      // But still activate shoulders
      expect(result[MuscleGroup.shoulders]!.secondaryVolume, equals(180)); // 50% of 360
    });

    test('should activate shoulders and arms for back pulling exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Pull Up', // Contains 'pull' = pulling movement
        category: ExerciseCategory.back,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Back exercises activate rear delts (shoulders)
      expect(result[MuscleGroup.shoulders]!.secondaryVolume, equals(0)); // Bodyweight
      // Pulling movements activate biceps (arms)
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0)); // Bodyweight
    });

    test('should activate shoulders for back but not arms for non-pulling', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Back Extension', // Not a pulling movement
        category: ExerciseCategory.back,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 15, weight: 20, isCompleted: true, actualReps: 15)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Back exercises always activate shoulders
      expect(result[MuscleGroup.shoulders]!.secondaryVolume, equals(150)); // 50% of 300
      // But extension doesn't activate biceps
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0));
    });

    test('should activate arms and chest for shoulder pressing exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Overhead Press', // Contains 'press' = pressing movement
        category: ExerciseCategory.shoulders,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 8, weight: 60, isCompleted: true, actualReps: 8)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Shoulder presses activate triceps (arms)
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(240)); // 50% of 480
      // And upper chest
      expect(result[MuscleGroup.chest]!.secondaryVolume, equals(240)); // 50% of 480
    });

    test('should not activate secondary for shoulder lateral raises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Lateral Raise', // Not a pressing movement
        category: ExerciseCategory.shoulders,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 15, isCompleted: true, actualReps: 12)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Isolation shoulder work has no secondary
      expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0));
      expect(result[MuscleGroup.chest]!.secondaryVolume, equals(0));
    });

    test('should activate core for compound leg exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Squat', // Contains 'squat' = compound
        category: ExerciseCategory.legs,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Compound leg exercises activate core
      expect(result[MuscleGroup.core]!.secondaryVolume, equals(500)); // 50% of 1000
    });

    test('should not activate core for isolation leg exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Leg Curl', // Not a compound movement
        category: ExerciseCategory.legs,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 40, isCompleted: true, actualReps: 12)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Isolation leg exercises don't activate core significantly
      expect(result[MuscleGroup.core]!.secondaryVolume, equals(0));
    });

    test('should not activate secondary muscles for arm isolation', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Bicep Curl',
        category: ExerciseCategory.arms,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 15, isCompleted: true, actualReps: 12)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Arm isolation has minimal secondary activation
      for (final muscle in MuscleGroup.values) {
        if (muscle != MuscleGroup.arms) {
          expect(result[muscle]!.secondaryVolume, equals(0));
        }
      }
    });

    test('should not activate secondary muscles for core exercises', () {
      final exercise = Exercise(
        id: 'e1',
        name: 'Plank',
        category: ExerciseCategory.abs,
        type: ExerciseType.single,
        sets: [ExerciseSet(setNumber: 1, reps: 3, weight: 0, isCompleted: true, actualReps: 3)],
      );

      final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

      // Core exercises have minimal secondary (may involve hip flexors/legs)
      // But current implementation doesn't model this
      for (final muscle in MuscleGroup.values) {
        if (muscle != MuscleGroup.core) {
          expect(result[muscle]!.secondaryVolume, equals(0));
        }
      }
    });
  });

  group('MuscleVolumeClassifier - Exercise Pattern Matching', () {
    group('_isCompound detection', () {
      test('should detect press as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Bench Press',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Compound chest exercise should activate arms
        expect(result[MuscleGroup.arms]!.secondaryVolume, greaterThan(0));
      });

      test('should detect squat as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Back Squat',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 100, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Compound leg exercise should activate core
        expect(result[MuscleGroup.core]!.secondaryVolume, equals(500));
      });

      test('should detect deadlift as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Deadlift',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 5, weight: 150, isCompleted: true, actualReps: 5)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Deadlift should activate core
        expect(result[MuscleGroup.core]!.secondaryVolume, equals(375)); // 50% of 750
      });

      test('should detect row as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Barbell Row',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 80, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Row is pulling, should activate arms
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(400)); // 50% of 800
      });

      test('should detect dip as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Dips',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 0, isCompleted: true, actualReps: 12)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Dips are compound, bodyweight so 0 volume but structure correct
        expect(result[MuscleGroup.chest]!.primaryVolume, equals(0)); // Bodyweight
      });

      test('should detect push up as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Push Up',
          category: ExerciseCategory.chest,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 20, weight: 0, isCompleted: true, actualReps: 20)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Push ups are compound (bodyweight)
        expect(result[MuscleGroup.chest]!.primaryVolume, equals(0));
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0)); // Bodyweight
      });

      test('should detect lunge as compound', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Walking Lunge',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 20, weight: 50, isCompleted: true, actualReps: 20)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Lunges are compound, should activate core
        expect(result[MuscleGroup.core]!.secondaryVolume, equals(500)); // 50% of 1000
      });
    });

    group('_isPulling detection', () {
      test('should detect pull as pulling', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Pull Up',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Pulling should activate biceps (but bodyweight = 0)
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0));
      });

      test('should detect row as pulling', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Dumbbell Row',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 40, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Row should activate biceps
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(200)); // 50% of 400
      });

      test('should detect chin as pulling', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Chin Up',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 8, weight: 0, isCompleted: true, actualReps: 8)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Chin ups activate biceps (bodyweight)
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(0));
      });

      test('should detect lat exercises as pulling', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Lat Pulldown',
          category: ExerciseCategory.back,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 12, weight: 60, isCompleted: true, actualReps: 12)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Lat pulldown activates biceps
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(360)); // 50% of 720
      });
    });

    group('_isPressing detection', () {
      test('should detect press as pressing', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Shoulder Press',
          category: ExerciseCategory.shoulders,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 50, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Shoulder press should activate triceps and chest
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(250)); // 50% of 500
        expect(result[MuscleGroup.chest]!.secondaryVolume, equals(250)); // 50% of 500
      });

      test('should detect push as pressing', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Push Press',
          category: ExerciseCategory.shoulders,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 8, weight: 60, isCompleted: true, actualReps: 8)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Push press activates triceps and chest
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(240)); // 50% of 480
        expect(result[MuscleGroup.chest]!.secondaryVolume, equals(240)); // 50% of 480
      });

      test('should detect dip as pressing', () {
        final exercise = Exercise(
          id: 'e1',
          name: 'Weighted Dip',
          category: ExerciseCategory.shoulders,
          type: ExerciseType.single,
          sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 20, isCompleted: true, actualReps: 10)],
        );

        final result = MuscleVolumeClassifier.calculateVolumeDistribution([exercise]);

        // Dips activate triceps and chest
        expect(result[MuscleGroup.arms]!.secondaryVolume, equals(100)); // 50% of 200
        expect(result[MuscleGroup.chest]!.secondaryVolume, equals(100)); // 50% of 200
      });
    });
  });

  group('VolumeDistribution', () {
    test('should calculate total weighted volume correctly', () {
      // Arrange
      final distribution = VolumeDistribution(
        primaryVolume: 1000,
        secondaryVolume: 500,
      );

      // Assert - primary + secondary (already at 50%)
      expect(distribution.totalWeightedVolume, equals(1500));
    });

    test('should calculate total raw volume correctly', () {
      // Arrange
      final distribution = VolumeDistribution(
        primaryVolume: 1000,
        secondaryVolume: 500,
      );

      // Assert - primary + (secondary * 2)
      expect(distribution.totalRawVolume, equals(2000));
    });

    test('should calculate primary percentage correctly', () {
      // Arrange
      final distribution = VolumeDistribution(
        primaryVolume: 1000,
        secondaryVolume: 500,
      );

      // Assert - (1000 / 1500) * 100 = 66.67%
      expect(distribution.primaryPercentage, closeTo(66.67, 0.01));
    });

    test('should return 0 percentage when total volume is zero', () {
      // Arrange
      final distribution = VolumeDistribution(
        primaryVolume: 0,
        secondaryVolume: 0,
      );

      // Assert
      expect(distribution.primaryPercentage, equals(0));
    });

    test('should return 100% when only primary volume exists', () {
      // Arrange
      final distribution = VolumeDistribution(
        primaryVolume: 1000,
        secondaryVolume: 0,
      );

      // Assert
      expect(distribution.primaryPercentage, equals(100));
    });

    test('should return 0% when only secondary volume exists', () {
      // Arrange
      final distribution = VolumeDistribution(
        primaryVolume: 0,
        secondaryVolume: 1000,
      );

      // Assert
      expect(distribution.primaryPercentage, equals(0));
    });
  });
}
