import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('Exercise copyWith tests', () {
    test('SupersetExercise copyWith preserves type', () {
      final superset = SupersetExercise(
        name: 'Test Superset',
        exercises: [
          Exercise(
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
          ),
          Exercise(
            name: 'Flyes',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
          ),
        ],
      );

      final updated = superset.copyWith(
        name: 'Updated Superset',
      );

      expect(updated, isA<SupersetExercise>());
      expect(updated.name, 'Updated Superset');
      expect(updated.exercises.length, 2);
      expect(updated.type, ExerciseType.superset);
    });

    test('DropSetExercise copyWith preserves type', () {
      final dropset = DropSetExercise(
        name: 'Test Dropset',
        category: ExerciseCategory.chest,
        stages: [
          DropSetStage(weight: 100, reps: 8),
          DropSetStage(weight: 80, reps: 10),
          DropSetStage(weight: 60, reps: 12),
        ],
      );

      final updated = dropset.copyWith(
        name: 'Updated Dropset',
      );

      expect(updated, isA<DropSetExercise>());
      expect(updated.name, 'Updated Dropset');
      expect(updated.stages.length, 3);
      expect(updated.type, ExerciseType.dropset);
    });

    test('RestPauseExercise copyWith preserves type', () {
      final restPause = RestPauseExercise(
        name: 'Test Rest-Pause',
        category: ExerciseCategory.chest,
        weight: 100,
        targetReps: 10,
        restPauseSets: [
          RestPauseSet(reps: 10, restSeconds: 15),
          RestPauseSet(reps: 5, restSeconds: 15),
          RestPauseSet(reps: 3, restSeconds: 15),
        ],
      );

      final updated = restPause.copyWith(
        name: 'Updated Rest-Pause',
      );

      expect(updated, isA<RestPauseExercise>());
      expect(updated.name, 'Updated Rest-Pause');
      expect(updated.restPauseSets.length, 3);
      expect(updated.type, ExerciseType.restPause);
      expect(updated.weight, 100);
    });
  });
}