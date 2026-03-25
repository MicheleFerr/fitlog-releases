import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/utils/exercise_replacement_utils.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('buildReplacementExercise', () {
    test('keeps workout programming while swapping exercise metadata', () {
      final currentExercise = Exercise(
        id: 'exercise-slot-1',
        databaseExerciseId: 'bench_press',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            id: 'set-1',
            setNumber: 1,
            weight: 80,
            reps: 8,
            actualReps: 8,
            isCompleted: true,
          ),
          ExerciseSet(id: 'set-2', setNumber: 2, weight: 85, reps: 6),
        ],
        notes: 'Keep elbows tucked',
        restTime: null,
        restAfterExercise: 75,
        tut: '3-1-1-0',
        autoAdjustmentType: AutoAdjustmentType.rpe,
        targetRPEMin: 7.5,
        targetRPEMax: 9.0,
        targetRIR: 1,
        countingMode: ExerciseCountingMode.weighted,
      );

      final replacementExercise = Exercise(
        id: 'new-exercise-id',
        databaseExerciseId: 'incline_dumbbell_press',
        name: 'Incline Dumbbell Press',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
        sets: [ExerciseSet(setNumber: 1, reps: 12)],
        notes: 'Replacement notes',
        restTime: 120,
        restAfterExercise: 30,
        tut: '1-0-1-0',
        countingMode: ExerciseCountingMode.reps,
        movementType: MovementType.compoundMedium,
      );

      final result = buildReplacementExercise(
        currentExercise: currentExercise,
        replacementExercise: replacementExercise,
      );

      expect(result.id, currentExercise.id);
      expect(result.databaseExerciseId, replacementExercise.stableExerciseId);
      expect(result.stableExerciseId, replacementExercise.stableExerciseId);
      expect(result.name, replacementExercise.name);
      expect(result.category, replacementExercise.category);
      expect(result.movementType, replacementExercise.movementType);

      expect(result.sets, isNot(same(currentExercise.sets)));
      expect(result.sets.length, 2);
      expect(result.sets.first.id, 'set-1');
      expect(result.sets.first.weight, 80);
      expect(result.sets.first.reps, 8);
      expect(result.sets.first.actualReps, 8);
      expect(result.sets.first.isCompleted, isTrue);

      expect(result.notes, currentExercise.notes);
      expect(result.restTime, isNull);
      expect(result.restAfterExercise, currentExercise.restAfterExercise);
      expect(result.tut, currentExercise.tut);
      expect(result.autoAdjustmentType, currentExercise.autoAdjustmentType);
      expect(result.targetRPEMin, currentExercise.targetRPEMin);
      expect(result.targetRPEMax, currentExercise.targetRPEMax);
      expect(result.targetRIR, currentExercise.targetRIR);
      expect(result.countingMode, currentExercise.countingMode);
    });
  });
}
