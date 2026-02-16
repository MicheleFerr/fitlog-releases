import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('🎯 Exercise Uncovered Methods Tests', () {
    group('ExerciseSet Methods', () {
      test('completeWithRPE updates set correctly', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 100,
          reps: 10,
          isCompleted: false,
        );

        final completed = set.completeWithRPE(
          actualReps: 8,
          rpe: 9,
          notes: 'Tough set',
        );

        expect(completed.actualReps, 8);
        expect(completed.rpe, 9);
        expect(completed.isCompleted, true);
        expect(completed.completedAt, isNotNull);
        expect(completed.notes, 'Tough set');
      });

      test('hasValidRPE validates RPE range', () {
        // Valid RPE (5-10)
        final validSet1 = ExerciseSet(setNumber: 1, rpe: 5);
        expect(validSet1.hasValidRPE, true);

        final validSet2 = ExerciseSet(setNumber: 1, rpe: 10);
        expect(validSet2.hasValidRPE, true);

        final validSet3 = ExerciseSet(setNumber: 1, rpe: 7);
        expect(validSet3.hasValidRPE, true);

        // Invalid RPE
        final invalidSet1 = ExerciseSet(setNumber: 1, rpe: 4);
        expect(invalidSet1.hasValidRPE, false);

        final invalidSet2 = ExerciseSet(setNumber: 1, rpe: 11);
        expect(invalidSet2.hasValidRPE, false);

        final invalidSet3 = ExerciseSet(setNumber: 1, rpe: null);
        expect(invalidSet3.hasValidRPE, false);
      });

      test('rpeText formats RPE correctly', () {
        final setWithRpe = ExerciseSet(setNumber: 1, rpe: 8);
        expect(setWithRpe.rpeText, 'RPE: 8/10');

        final setWithoutRpe = ExerciseSet(setNumber: 1);
        expect(setWithoutRpe.rpeText, '');
      });

      test('repsText formats reps correctly', () {
        // Both actualReps and target reps
        final set1 = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 8,
        );
        expect(set1.repsText, '8/10 reps');

        // Only actualReps (defaults reps=0)
        final set2 = ExerciseSet(
          setNumber: 1,
          actualReps: 12,
        );
        expect(set2.repsText, '12 reps'); // Should show just actualReps when no target

        // Only target reps
        final set3 = ExerciseSet(
          setNumber: 1,
          reps: 15,
        );
        expect(set3.repsText, '15 reps (target)');

        // Neither
        final set4 = ExerciseSet(setNumber: 1);
        expect(set4.repsText, '');
      });

      test('isFullyCompleted checks completion status', () {
        // Fully completed (actualReps >= target)
        final fullSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 10,
          isCompleted: true,
        );
        expect(fullSet.isFullyCompleted, true);

        // Over-completed
        final overSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 12,
          isCompleted: true,
        );
        expect(overSet.isFullyCompleted, true);

        // Partially completed
        final partialSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 8,
          isCompleted: true,
        );
        expect(partialSet.isFullyCompleted, false);

        // Not completed
        final notCompleted = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 10,
          isCompleted: false,
        );
        expect(notCompleted.isFullyCompleted, false);

        // No actualReps
        final noActual = ExerciseSet(
          setNumber: 1,
          reps: 10,
          isCompleted: true,
        );
        expect(noActual.isFullyCompleted, false);
      });

      test('isPartiallyCompleted checks partial completion', () {
        // Partially completed (actualReps < target)
        final partialSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 8,
          isCompleted: true,
        );
        expect(partialSet.isPartiallyCompleted, true);

        // Fully completed
        final fullSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 10,
          isCompleted: true,
        );
        expect(fullSet.isPartiallyCompleted, false);

        // Over-completed
        final overSet = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 12,
          isCompleted: true,
        );
        expect(overSet.isPartiallyCompleted, false);

        // Not completed
        final notCompleted = ExerciseSet(
          setNumber: 1,
          reps: 10,
          actualReps: 8,
          isCompleted: false,
        );
        expect(notCompleted.isPartiallyCompleted, false);

        // No actual reps
        final noActual = ExerciseSet(
          setNumber: 1,
          reps: 10,
          isCompleted: true,
        );
        expect(noActual.isPartiallyCompleted, false);
      });
    });

    group('SupersetExercise', () {
      test('creates superset with multiple exercises', () {
        final exercise1 = Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 80, reps: 10),
          ],
        );

        final exercise2 = Exercise(
          id: 'ex-2',
          name: 'Bent-Over Row',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [
            ExerciseSet(setNumber: 1, weight: 60, reps: 10),
          ],
        );

        final superset = SupersetExercise(
          id: 'superset-1',
          name: 'Chest & Back Superset',
          exercises: [exercise1, exercise2],
          notes: 'Antagonist superset',
        );

        expect(superset.type, ExerciseType.superset);
        expect(superset.exercises.length, 2);
        expect(superset.exercises[0].name, 'Bench Press');
        expect(superset.exercises[1].name, 'Bent-Over Row');
        expect(superset.category, ExerciseCategory.chest); // Takes first exercise category
        expect(superset.notes, 'Antagonist superset');
      });

      test('superset with empty exercises defaults to other category', () {
        final superset = SupersetExercise(
          name: 'Empty Superset',
          exercises: [],
        );

        expect(superset.category, ExerciseCategory.other);
      });
    });

    group('DropSetExercise', () {
      test('creates dropset with stages', () {
        final dropset = DropSetExercise(
          id: 'dropset-1',
          name: 'Bicep Curls Dropset',
          category: ExerciseCategory.arms,
          stages: [
            DropSetStage(weight: 20, reps: 8),
            DropSetStage(weight: 15, reps: 10),
            DropSetStage(weight: 10, reps: 12),
          ],
          notes: 'Go to failure each stage',
        );

        expect(dropset.type, ExerciseType.dropset);
        expect(dropset.category, ExerciseCategory.arms);
        expect(dropset.stages.length, 3);
        expect(dropset.stages[0].weight, 20);
        expect(dropset.stages[1].weight, 15);
        expect(dropset.stages[2].weight, 10);
        expect(dropset.notes, 'Go to failure each stage');
      });

      test('DropSetStage copyWith', () {
        final stage = DropSetStage(
          weight: 20,
          reps: 10,
          isCompleted: false,
        );

        final updated = stage.copyWith(
          isCompleted: true,
        );

        expect(updated.weight, 20);
        expect(updated.reps, 10);
        expect(updated.isCompleted, true);
        expect(stage.isCompleted, false); // Original unchanged
      });
    });

    group('RestPauseExercise', () {
      test('creates rest-pause exercise', () {
        final restPause = RestPauseExercise(
          id: 'rp-1',
          name: 'Shoulder Press Rest-Pause',
          category: ExerciseCategory.shoulders,
          weight: 30,
          targetReps: 20,
          restPauseSets: [
            RestPauseSet(reps: 12, restSeconds: 15, isCompleted: true),
            RestPauseSet(reps: 5, restSeconds: 15, isCompleted: true),
            RestPauseSet(reps: 3, restSeconds: 15, isCompleted: true),
          ],
          notes: '15 seconds rest between mini-sets',
        );

        expect(restPause.type, ExerciseType.restPause);
        expect(restPause.category, ExerciseCategory.shoulders);
        expect(restPause.weight, 30);
        expect(restPause.targetReps, 20);
        expect(restPause.restPauseSets.length, 3);
        expect(restPause.restPauseSets[0].reps, 12);
        expect(restPause.restPauseSets[0].restSeconds, 15);
      });

      test('RestPauseSet copyWith', () {
        final set = RestPauseSet(
          reps: 10,
          restSeconds: 20,
          isCompleted: false,
        );

        final updated = set.copyWith(
          isCompleted: true,
        );

        expect(updated.reps, 10);
        expect(updated.restSeconds, 20);
        expect(updated.isCompleted, true);
        expect(set.isCompleted, false); // Original unchanged
      });

      test('RestPauseExercise with incomplete sets', () {
        final restPause = RestPauseExercise(
          name: 'Test',
          category: ExerciseCategory.arms,
          weight: 20,
          targetReps: 15,
          restPauseSets: [
            RestPauseSet(reps: 8, restSeconds: 15, isCompleted: true),
            RestPauseSet(reps: 4, restSeconds: 15, isCompleted: true),
            RestPauseSet(reps: 2, restSeconds: 15, isCompleted: false), // Not completed
          ],
        );

        expect(restPause.restPauseSets.where((s) => s.isCompleted).length, 2);
        final totalReps = restPause.restPauseSets
            .where((s) => s.isCompleted)
            .fold(0, (sum, s) => sum + s.reps);
        expect(totalReps, 12); // Only completed sets: 8 + 4
      });

      test('RestPauseExercise properties', () {
        final restPause = RestPauseExercise(
          id: 'rp-1',
          name: 'Test Exercise',
          category: ExerciseCategory.chest,
          weight: 50,
          targetReps: 20,
          restPauseSets: [
            RestPauseSet(reps: 10, restSeconds: 15),
            RestPauseSet(reps: 6, restSeconds: 15),
            RestPauseSet(reps: 4, restSeconds: 15),
          ],
        );

        expect(restPause.name, 'Test Exercise');
        expect(restPause.weight, 50);
        expect(restPause.targetReps, 20);
        expect(restPause.category, ExerciseCategory.chest);
        expect(restPause.restPauseSets.length, 3);
      });
    });

    group('ExerciseType enum', () {
      test('enum values exist', () {
        expect(ExerciseType.values, contains(ExerciseType.single));
        expect(ExerciseType.values, contains(ExerciseType.superset));
        expect(ExerciseType.values, contains(ExerciseType.dropset));
        expect(ExerciseType.values, contains(ExerciseType.restPause));
      });

      test('enum name property', () {
        expect(ExerciseType.single.name, 'single');
        expect(ExerciseType.superset.name, 'superset');
        expect(ExerciseType.dropset.name, 'dropset');
        expect(ExerciseType.restPause.name, 'restPause');
      });
    });

    group('ExerciseCategory enum', () {
      test('enum values exist', () {
        expect(ExerciseCategory.values, contains(ExerciseCategory.chest));
        expect(ExerciseCategory.values, contains(ExerciseCategory.back));
        expect(ExerciseCategory.values, contains(ExerciseCategory.shoulders));
        expect(ExerciseCategory.values, contains(ExerciseCategory.arms));
        expect(ExerciseCategory.values, contains(ExerciseCategory.legs));
        expect(ExerciseCategory.values, contains(ExerciseCategory.abs));
        expect(ExerciseCategory.values, contains(ExerciseCategory.cardio));
        expect(ExerciseCategory.values, contains(ExerciseCategory.other));
      });

      test('enum name property', () {
        expect(ExerciseCategory.chest.name, 'chest');
        expect(ExerciseCategory.back.name, 'back');
        expect(ExerciseCategory.shoulders.name, 'shoulders');
        expect(ExerciseCategory.arms.name, 'arms');
        expect(ExerciseCategory.legs.name, 'legs');
        expect(ExerciseCategory.abs.name, 'abs');
        expect(ExerciseCategory.cardio.name, 'cardio');
        expect(ExerciseCategory.other.name, 'other');
      });
    });
  });
}