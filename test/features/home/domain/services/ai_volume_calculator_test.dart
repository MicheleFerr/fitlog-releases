import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_volume_calculator.dart';

void main() {
  group('MuscleGroupVolume', () {
    test('should classify below MEV for less than 10 sets', () {
      // Arrange
      const volume = MuscleGroupVolume(
        muscleGroup: 'Chest',
        totalSets: 8,
        totalVolume: 1000,
        exercises: ['Bench Press'],
      );

      // Act
      final classification = volume.classify();

      // Assert
      expect(classification, equals(VolumeClassification.belowMEV));
      expect(volume.isTooLow, isTrue);
      expect(volume.isOptimal, isFalse);
    });

    test('should classify as MEV for 10-14 sets', () {
      // Arrange
      const volume = MuscleGroupVolume(
        muscleGroup: 'Chest',
        totalSets: 12,
        totalVolume: 1500,
        exercises: ['Bench Press'],
      );

      // Act
      final classification = volume.classify();

      // Assert
      expect(classification, equals(VolumeClassification.mev));
      expect(volume.isTooLow, isFalse);
      expect(volume.isOptimal, isFalse);
    });

    test('should classify as MAV (optimal) for 15-20 sets', () {
      // Arrange
      const volume = MuscleGroupVolume(
        muscleGroup: 'Chest',
        totalSets: 18,
        totalVolume: 2000,
        exercises: ['Bench Press'],
      );

      // Act
      final classification = volume.classify();

      // Assert
      expect(classification, equals(VolumeClassification.mav));
      expect(volume.isOptimal, isTrue);
      expect(volume.isTooLow, isFalse);
      expect(volume.isTooHigh, isFalse);
    });

    test('should classify as approaching MRV for 21-25 sets', () {
      // Arrange
      const volume = MuscleGroupVolume(
        muscleGroup: 'Chest',
        totalSets: 23,
        totalVolume: 3000,
        exercises: ['Bench Press'],
      );

      // Act
      final classification = volume.classify();

      // Assert
      expect(classification, equals(VolumeClassification.approaching_mrv));
      expect(volume.isOptimal, isFalse);
      expect(volume.isTooHigh, isFalse);
    });

    test('should classify as above MRV for more than 25 sets', () {
      // Arrange
      const volume = MuscleGroupVolume(
        muscleGroup: 'Chest',
        totalSets: 28,
        totalVolume: 4000,
        exercises: ['Bench Press'],
      );

      // Act
      final classification = volume.classify();

      // Assert
      expect(classification, equals(VolumeClassification.above_mrv));
      expect(volume.isTooHigh, isTrue);
      expect(volume.isOptimal, isFalse);
    });

    test('should handle boundary cases correctly', () {
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 9, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.belowMEV),
      );
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 10, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.mev),
      );
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 15, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.mav),
      );
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 20, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.mav),
      );
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 21, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.approaching_mrv),
      );
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 25, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.approaching_mrv),
      );
      expect(
        const MuscleGroupVolume(muscleGroup: '', totalSets: 26, totalVolume: 0, exercises: [])
            .classify(),
        equals(VolumeClassification.above_mrv),
      );
    });
  });

  group('AIVolumeCalculator', () {
    // Helper to create test Exercise
    Exercise createExercise({
      required String nome,
      required List<String> focus,
      List<String> muscoliSecondari = const [],
    }) {
      return Exercise(
        id: 'ex_${nome.toLowerCase()}',
        nome: nome,
        focus: focus,
        muscoliSecondari: muscoliSecondari,
        difficolta: 'Intermedio',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Bilanciere',
        patternMovimento: 'Push',
        rangeRipetizioni: '8-12',
      );
    }

    // Helper to create test ExerciseActivity
    ExerciseActivity createActivity({
      required String exerciseName,
      required List<ExerciseActivitySet> sets,
      ExerciseCategory category = ExerciseCategory.chest,
    }) {
      return ExerciseActivity(
        id: 'activity_${exerciseName.toLowerCase()}',
        email: 'test@example.com',
        exerciseId: 'ex_${exerciseName.toLowerCase()}',
        exerciseName: exerciseName,
        schedaName: 'Test Scheda',
        category: category,
        sets: sets,
        createdAt: DateTime(2024, 1, 10),
        lastModified: DateTime(2024, 1, 10),
      );
    }

    // Helper to create test ExerciseActivitySet
    ExerciseActivitySet createSet({
      required String weight,
      required String reps,
      bool done = true,
    }) {
      return ExerciseActivitySet(
        set: 1,
        weight: weight,
        reps: reps,
        done: done,
        effort: 3,
      );
    }

    group('calculateWeeklyVolumeByMuscleGroup', () {
      test('should return empty map for empty activities', () {
        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          [],
          {},
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should calculate volume for single muscle group', () {
        // Arrange
        final exercises = {
          'Bench Press': createExercise(
            nome: 'Bench Press',
            focus: ['Petto'],
          ),
        };

        final activities = [
          createActivity(
            exerciseName: 'Bench Press',
            sets: [
              createSet(weight: '100', reps: '10'), // 1000
              createSet(weight: '100', reps: '8'), // 800
              createSet(weight: '100', reps: '6'), // 600
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result['Petto'], isNotNull);
        expect(result['Petto']!.totalSets, equals(3));
        expect(result['Petto']!.totalVolume, equals(2400)); // 1000+800+600
        expect(result['Petto']!.exercises, contains('Bench Press'));
      });

      test('should handle secondary muscles with half volume', () {
        // Arrange
        final exercises = {
          'Bench Press': createExercise(
            nome: 'Bench Press',
            focus: ['Petto'],
            muscoliSecondari: ['Spalle', 'Tricipiti'],
          ),
        };

        final activities = [
          createActivity(
            exerciseName: 'Bench Press',
            sets: [
              createSet(weight: '100', reps: '10'), // 1000
              createSet(weight: '100', reps: '10'), // 1000
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result, hasLength(3));
        // Primary muscle
        expect(result['Petto']!.totalSets, equals(2));
        expect(result['Petto']!.totalVolume, equals(2000));
        // Secondary muscles (half volume)
        expect(result['Spalle']!.totalSets, equals(1)); // 2 * 0.5 = 1
        expect(result['Spalle']!.totalVolume, equals(1000)); // 2000 * 0.5 = 1000
        expect(result['Tricipiti']!.totalSets, equals(1));
        expect(result['Tricipiti']!.totalVolume, equals(1000));
      });

      test('should accumulate volume from multiple activities', () {
        // Arrange
        final exercises = {
          'Bench Press': createExercise(
            nome: 'Bench Press',
            focus: ['Petto'],
          ),
          'Incline Press': createExercise(
            nome: 'Incline Press',
            focus: ['Petto'],
          ),
        };

        final activities = [
          createActivity(
            exerciseName: 'Bench Press',
            sets: [
              createSet(weight: '100', reps: '10'),
              createSet(weight: '100', reps: '10'),
            ],
          ),
          createActivity(
            exerciseName: 'Incline Press',
            sets: [
              createSet(weight: '80', reps: '10'),
              createSet(weight: '80', reps: '10'),
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result['Petto']!.totalSets, equals(4)); // 2 + 2
        expect(result['Petto']!.totalVolume, equals(3600)); // 2000 + 1600
        expect(result['Petto']!.exercises, containsAll(['Bench Press', 'Incline Press']));
      });

      test('should skip incomplete sets', () {
        // Arrange
        final exercises = {
          'Bench Press': createExercise(
            nome: 'Bench Press',
            focus: ['Petto'],
          ),
        };

        final activities = [
          createActivity(
            exerciseName: 'Bench Press',
            sets: [
              createSet(weight: '100', reps: '10', done: true),
              createSet(weight: '100', reps: '10', done: false), // Skip
              createSet(weight: '100', reps: '10', done: true),
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result['Petto']!.totalSets, equals(2)); // Only completed sets
        expect(result['Petto']!.totalVolume, equals(2000));
      });

      test('should use fallback categorization when exercise not in database', () {
        // Arrange - Empty exercise database
        final exercises = <String, Exercise>{};

        final activities = [
          createActivity(
            exerciseName: 'Bench Press', // Contains 'bench'
            sets: [
              createSet(weight: '100', reps: '10'),
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result['PETT'], isNotNull); // Fallback categorization
        expect(result['PETT']!.totalSets, equals(1));
      });

      test('should handle exercises with multiple primary muscles', () {
        // Arrange
        final exercises = {
          'Deadlift': createExercise(
            nome: 'Deadlift',
            focus: ['Dorso', 'Gambe', 'Core'],
          ),
        };

        final activities = [
          createActivity(
            exerciseName: 'Deadlift',
            sets: [
              createSet(weight: '200', reps: '5'),
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result, hasLength(3));
        expect(result['Dorso']!.totalSets, equals(1));
        expect(result['Gambe']!.totalSets, equals(1));
        expect(result['Core']!.totalSets, equals(1));
        // Each muscle gets full volume (not split)
        expect(result['Dorso']!.totalVolume, equals(1000));
        expect(result['Gambe']!.totalVolume, equals(1000));
        expect(result['Core']!.totalVolume, equals(1000));
      });

      test('should handle zero weight sets (bodyweight)', () {
        // Arrange
        final exercises = {
          'Pull Up': createExercise(
            nome: 'Pull Up',
            focus: ['Dorso'],
          ),
        };

        final activities = [
          createActivity(
            exerciseName: 'Pull Up',
            sets: [
              createSet(weight: '0', reps: '12'),
            ],
          ),
        ];

        // Act
        final result = AIVolumeCalculator.calculateWeeklyVolumeByMuscleGroup(
          activities,
          exercises,
        );

        // Assert
        expect(result['Dorso']!.totalSets, equals(1));
        expect(result['Dorso']!.totalVolume, equals(0)); // 0 weight
      });
    });

    group('findImbalancedMuscles', () {
      test('should return empty list when all muscles are balanced', () {
        // Arrange
        final volumeMap = {
          'Chest': const MuscleGroupVolume(
            muscleGroup: 'Chest',
            totalSets: 15,
            totalVolume: 2000,
            exercises: [],
          ),
          'Back': const MuscleGroupVolume(
            muscleGroup: 'Back',
            totalSets: 18,
            totalVolume: 2500,
            exercises: [],
          ),
        };

        // Act
        final result = AIVolumeCalculator.findImbalancedMuscles(volumeMap);

        // Assert
        expect(result, isEmpty);
      });

      test('should identify muscles with too low volume (<10 sets)', () {
        // Arrange
        final volumeMap = {
          'Chest': const MuscleGroupVolume(
            muscleGroup: 'Chest',
            totalSets: 8, // Too low
            totalVolume: 1000,
            exercises: [],
          ),
          'Back': const MuscleGroupVolume(
            muscleGroup: 'Back',
            totalSets: 15, // OK
            totalVolume: 2000,
            exercises: [],
          ),
        };

        // Act
        final result = AIVolumeCalculator.findImbalancedMuscles(volumeMap);

        // Assert
        expect(result, hasLength(1));
        expect(result, contains('Chest'));
      });

      test('should identify all imbalanced muscles', () {
        // Arrange
        final volumeMap = {
          'Chest': const MuscleGroupVolume(
            muscleGroup: 'Chest',
            totalSets: 5,
            totalVolume: 500,
            exercises: [],
          ),
          'Back': const MuscleGroupVolume(
            muscleGroup: 'Back',
            totalSets: 8,
            totalVolume: 800,
            exercises: [],
          ),
          'Legs': const MuscleGroupVolume(
            muscleGroup: 'Legs',
            totalSets: 15, // OK
            totalVolume: 2000,
            exercises: [],
          ),
        };

        // Act
        final result = AIVolumeCalculator.findImbalancedMuscles(volumeMap);

        // Assert
        expect(result, hasLength(2));
        expect(result, containsAll(['Chest', 'Back']));
      });
    });

    group('findOvertrainedMuscles', () {
      test('should return empty list when no muscles are overtrained', () {
        // Arrange
        final volumeMap = {
          'Chest': const MuscleGroupVolume(
            muscleGroup: 'Chest',
            totalSets: 15,
            totalVolume: 2000,
            exercises: [],
          ),
          'Back': const MuscleGroupVolume(
            muscleGroup: 'Back',
            totalSets: 20,
            totalVolume: 2500,
            exercises: [],
          ),
        };

        // Act
        final result = AIVolumeCalculator.findOvertrainedMuscles(volumeMap);

        // Assert
        expect(result, isEmpty);
      });

      test('should identify muscles with too high volume (>25 sets)', () {
        // Arrange
        final volumeMap = {
          'Chest': const MuscleGroupVolume(
            muscleGroup: 'Chest',
            totalSets: 28, // Too high
            totalVolume: 4000,
            exercises: [],
          ),
          'Back': const MuscleGroupVolume(
            muscleGroup: 'Back',
            totalSets: 15, // OK
            totalVolume: 2000,
            exercises: [],
          ),
        };

        // Act
        final result = AIVolumeCalculator.findOvertrainedMuscles(volumeMap);

        // Assert
        expect(result, hasLength(1));
        expect(result, contains('Chest'));
      });

      test('should identify all overtrained muscles', () {
        // Arrange
        final volumeMap = {
          'Chest': const MuscleGroupVolume(
            muscleGroup: 'Chest',
            totalSets: 30,
            totalVolume: 5000,
            exercises: [],
          ),
          'Back': const MuscleGroupVolume(
            muscleGroup: 'Back',
            totalSets: 26,
            totalVolume: 4000,
            exercises: [],
          ),
          'Legs': const MuscleGroupVolume(
            muscleGroup: 'Legs',
            totalSets: 15, // OK
            totalVolume: 2000,
            exercises: [],
          ),
        };

        // Act
        final result = AIVolumeCalculator.findOvertrainedMuscles(volumeMap);

        // Assert
        expect(result, hasLength(2));
        expect(result, containsAll(['Chest', 'Back']));
      });
    });
  });
}
