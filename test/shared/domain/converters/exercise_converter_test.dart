import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as database_exercise;
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';

void main() {
  group('ExerciseConverter', () {
    test(
      'creates unique workout instance ids while preserving database exercise id',
      () {
        final dbExercise = database_exercise.ExerciseDefinition(
          id: 'bench_press',
          nome: 'Bench Press',
          focus: const ['PETT'],
          muscoliSecondari: const ['TRIC'],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bilanciere',
          patternMovimento: 'Horizontal Push',
          rangeRipetizioni: '6-10',
        );

        final first = ExerciseConverter.fromDatabaseExercise(dbExercise);
        final second = ExerciseConverter.fromDatabaseExercise(dbExercise);

        expect(first.id, isNot(dbExercise.id));
        expect(second.id, isNot(dbExercise.id));
        expect(first.id, isNot(second.id));
        expect(first.databaseExerciseId, dbExercise.id);
        expect(second.databaseExerciseId, dbExercise.id);
        expect(first.stableExerciseId, dbExercise.id);
        expect(second.stableExerciseId, dbExercise.id);
      },
    );

    test(
      'supports overriding the initial set count for free workout quick add',
      () {
        final dbExercise = database_exercise.ExerciseDefinition(
          id: 'pull_up',
          nome: 'Pull Up',
          focus: const ['DORS'],
          muscoliSecondari: const ['BIC'],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Corpo libero',
          patternMovimento: 'Vertical Pull',
          rangeRipetizioni: '6-12',
        );

        final workoutExercise = ExerciseConverter.fromDatabaseExercise(
          dbExercise,
          initialSetCount: 1,
        );

        expect(workoutExercise.sets, hasLength(1));
        expect(workoutExercise.sets.single.setNumber, 1);
        expect(workoutExercise.databaseExerciseId, dbExercise.id);
      },
    );
  });
}
