import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as ExerciseDB;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_converter.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
    as WorkoutExercise;

void main() {
  group('SupersetConverter', () {
    ExerciseDB.Exercise createDbExercise({
      String id = 'db-ex-1',
      String nome = 'Bench Press',
      List<String> focus = const ['PETT'],
      ExerciseCountingMode countingMode = ExerciseCountingMode.weighted,
      String? tempoEsecuzione,
    }) {
      return ExerciseDB.Exercise(
        id: id,
        nome: nome,
        focus: focus,
        muscoliSecondari: const [],
        difficolta: 'Intermedio',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Barbell',
        patternMovimento: 'Push',
        rangeRipetizioni: '8-12',
        countingMode: countingMode,
        tempoEsecuzione: tempoEsecuzione,
      );
    }

    group('configurationToSupersetExercise', () {
      test('converts configuration with two exercises', () {
        final ex1 = createDbExercise(
          id: 'ex-1',
          nome: 'Bench Press',
          focus: ['PETT'],
        );
        final ex2 = createDbExercise(
          id: 'ex-2',
          nome: 'Barbell Row',
          focus: ['DORS'],
        );

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              targetWeight: 80.0,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
          name: 'Chest-Back',
          restAfterRound: 90,
          restBetweenExercises: 0,
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        expect(result, isA<WorkoutExercise.SupersetExercise>());
        expect(result.name, 'Chest-Back');
        expect(result.exercises.length, 2);
        expect(result.restTime, 90);
        expect(result.restAfterExercise, 0);
      });

      test('generates unique IDs for exercises', () {
        final ex1 = createDbExercise(id: 'ex-1', nome: 'Bench Press');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        final ids = result.exercises.map((e) => e.id).toList();
        // Each ID should be unique
        expect(ids.toSet().length, ids.length);
        // IDs should contain the original exercise ID
        expect(ids[0], contains('ex-1'));
        expect(ids[1], contains('ex-2'));
      });

      test('maps exercise names from database', () {
        final ex1 = createDbExercise(id: 'ex-1', nome: 'Panca Piana');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Rematore');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        expect(result.exercises[0].name, 'Panca Piana');
        expect(result.exercises[1].name, 'Rematore');
      });

      test('sets exercise type to single for each exercise', () {
        final ex1 = createDbExercise(id: 'ex-1');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        for (final exercise in result.exercises) {
          expect(exercise.type, WorkoutExercise.ExerciseType.single);
        }
      });

      test('preserves counting mode from database exercise', () {
        final ex1 = createDbExercise(
          id: 'ex-1',
          countingMode: ExerciseCountingMode.reps,
        );
        final ex2 = createDbExercise(
          id: 'ex-2',
          nome: 'Row',
          countingMode: ExerciseCountingMode.weighted,
        );

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        expect(result.exercises[0].countingMode, ExerciseCountingMode.reps);
        expect(result.exercises[1].countingMode, ExerciseCountingMode.weighted);
      });

      test('preserves TUT from database exercise', () {
        final ex1 = createDbExercise(
          id: 'ex-1',
          tempoEsecuzione: '3-1-2-0',
        );
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        expect(result.exercises[0].tut, '3-1-2-0');
        expect(result.exercises[1].tut, isNull);
      });

      test('creates correct number of superset sets from rounds', () {
        final ex1 = createDbExercise(id: 'ex-1');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
            SupersetRound.uniform(
              roundNumber: 2,
              targetReps: 8,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
            SupersetRound.uniform(
              roundNumber: 3,
              targetReps: 6,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        expect(result.supersetSets.length, 3);
        expect(result.supersetSets[0].setNumber, 1);
        expect(result.supersetSets[1].setNumber, 2);
        expect(result.supersetSets[2].setNumber, 3);
      });

      test('superset sets start as not completed', () {
        final ex1 = createDbExercise(id: 'ex-1');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        for (final set in result.supersetSets) {
          expect(set.isCompleted, false);
        }
      });

      test('exercise data in sets uses target weight and reps from config', () {
        final ex1 = createDbExercise(id: 'ex-1', nome: 'Bench Press');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Barbell Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound(
              roundNumber: 1,
              exerciseConfigs: {
                'ex-1': const SupersetExerciseConfig(
                  exerciseId: 'ex-1',
                  targetReps: 10,
                  targetWeight: 80.0,
                ),
                'ex-2': const SupersetExerciseConfig(
                  exerciseId: 'ex-2',
                  targetReps: 12,
                  targetWeight: 60.0,
                ),
              },
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        final setData = result.supersetSets[0].exerciseData;
        // Should have data for both exercises
        expect(setData.length, 2);

        // Find the data entries (keyed by generated workout exercise IDs)
        final dataValues = setData.values.toList();
        final benchData = dataValues.firstWhere(
          (d) => d.exerciseName == 'Bench Press',
        );
        final rowData = dataValues.firstWhere(
          (d) => d.exerciseName == 'Barbell Row',
        );

        expect(benchData.targetWeight, 80.0);
        expect(benchData.targetReps, 10);
        expect(benchData.isCompleted, false);
        expect(benchData.actualWeight, isNull);
        expect(benchData.actualReps, isNull);

        expect(rowData.targetWeight, 60.0);
        expect(rowData.targetReps, 12);
      });

      test('uses default weight when exercise config is missing', () {
        final ex1 = createDbExercise(id: 'ex-1', nome: 'Bench Press');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Barbell Row');

        // Create a round where ex-2 has no config
        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound(
              roundNumber: 1,
              exerciseConfigs: {
                'ex-1': const SupersetExerciseConfig(
                  exerciseId: 'ex-1',
                  targetReps: 10,
                  targetWeight: 80.0,
                ),
                // ex-2 deliberately missing
              },
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        final setData = result.supersetSets[0].exerciseData;
        final dataValues = setData.values.toList();
        final rowData = dataValues.firstWhere(
          (d) => d.exerciseName == 'Barbell Row',
        );

        // Should use default values when config is missing
        expect(rowData.targetWeight, 20.0);
        expect(rowData.targetReps, 12);
      });

      test('generates unique IDs for each superset set', () {
        final ex1 = createDbExercise(id: 'ex-1');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
            SupersetRound.uniform(
              roundNumber: 2,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        final ids = result.supersetSets.map((s) => s.id).toSet();
        expect(ids.length, 2);
      });

      test('maps exercise focus to correct category', () {
        final chestExercise = createDbExercise(
          id: 'ex-1',
          nome: 'Bench Press',
          focus: ['PETT'],
        );
        final backExercise = createDbExercise(
          id: 'ex-2',
          nome: 'Row',
          focus: ['LAT'],
        );

        final config = SupersetConfiguration(
          exercises: [chestExercise, backExercise],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        expect(
          result.exercises[0].category,
          WorkoutExercise.ExerciseCategory.chest,
        );
        expect(
          result.exercises[1].category,
          WorkoutExercise.ExerciseCategory.back,
        );
      });

      test('exercises in result have empty sets list', () {
        final ex1 = createDbExercise(id: 'ex-1');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        for (final exercise in result.exercises) {
          expect(exercise.sets, isEmpty);
        }
      });

      test('passes round notes to exercise data', () {
        final ex1 = createDbExercise(id: 'ex-1', nome: 'Bench');
        final ex2 = createDbExercise(id: 'ex-2', nome: 'Row');

        final config = SupersetConfiguration(
          exercises: [ex1, ex2],
          rounds: [
            SupersetRound(
              roundNumber: 1,
              exerciseConfigs: {
                'ex-1': const SupersetExerciseConfig(
                  exerciseId: 'ex-1',
                  targetReps: 10,
                ),
                'ex-2': const SupersetExerciseConfig(
                  exerciseId: 'ex-2',
                  targetReps: 10,
                ),
              },
              notes: 'Go heavy',
            ),
          ],
        );

        final result =
            SupersetConverter.configurationToSupersetExercise(config);

        for (final data in result.supersetSets[0].exerciseData.values) {
          expect(data.notes, 'Go heavy');
        }
      });
    });
  });
}
