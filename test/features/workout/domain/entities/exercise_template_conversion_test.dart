import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';

void main() {
  group('ExerciseTemplate.toWorkoutExercise()', () {
    group('DropSet conversion', () {
      test('should convert ExerciseTemplate with dropset type to DropSetExercise', () {
        // Arrange: Create a template with dropset type and stages as SetTemplates
        const template = ExerciseTemplate(
          exerciseId: 'dropset_1',
          exerciseName: 'Bicep Curl - Drop Set',
          category: ExerciseCategory.arms,
          type: ExerciseType.dropset,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 20, targetReps: 8),
            SetTemplate(setNumber: 2, targetWeight: 15, targetReps: 10),
            SetTemplate(setNumber: 3, targetWeight: 10, targetReps: 12),
          ],
          notes: 'Test dropset',
          restTime: 90,
        );

        // Act: Convert to workout exercise
        final exercise = template.toWorkoutExercise();

        // Assert: Should be a DropSetExercise
        expect(exercise, isA<DropSetExercise>());

        final dropset = exercise as DropSetExercise;
        expect(dropset.name, 'Bicep Curl - Drop Set');
        expect(dropset.category, ExerciseCategory.arms);
        expect(dropset.type, ExerciseType.dropset);
        expect(dropset.stages.length, 3);

        // Verify stages have correct data
        expect(dropset.stages[0].weight, 20);
        expect(dropset.stages[0].reps, 8);
        expect(dropset.stages[0].isCompleted, false);

        expect(dropset.stages[1].weight, 15);
        expect(dropset.stages[1].reps, 10);

        expect(dropset.stages[2].weight, 10);
        expect(dropset.stages[2].reps, 12);
      });

      test('should handle dropset with null weights using defaults', () {
        const template = ExerciseTemplate(
          exerciseId: 'dropset_2',
          exerciseName: 'Test Dropset',
          category: ExerciseCategory.chest,
          type: ExerciseType.dropset,
          sets: [
            SetTemplate(setNumber: 1, targetReps: 10), // No weight
            SetTemplate(setNumber: 2, targetReps: 12),
          ],
        );

        final exercise = template.toWorkoutExercise();

        expect(exercise, isA<DropSetExercise>());
        final dropset = exercise as DropSetExercise;
        expect(dropset.stages[0].weight, 0); // Default
        expect(dropset.stages[1].weight, 0);
      });
    });

    group('RestPause conversion', () {
      test('should convert ExerciseTemplate with restPause type to RestPauseExercise', () {
        // Arrange
        const template = ExerciseTemplate(
          exerciseId: 'restpause_1',
          exerciseName: 'Bench Press - Rest-Pause',
          category: ExerciseCategory.chest,
          type: ExerciseType.restPause,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 80, targetReps: 8, restSeconds: 20),
            SetTemplate(setNumber: 2, targetWeight: 80, targetReps: 5, restSeconds: 20),
            SetTemplate(setNumber: 3, targetWeight: 80, targetReps: 3, restSeconds: 20),
          ],
          notes: 'Heavy rest-pause',
          restTime: 180,
        );

        // Act
        final exercise = template.toWorkoutExercise();

        // Assert
        expect(exercise, isA<RestPauseExercise>());

        final restPause = exercise as RestPauseExercise;
        expect(restPause.name, 'Bench Press - Rest-Pause');
        expect(restPause.category, ExerciseCategory.chest);
        expect(restPause.type, ExerciseType.restPause);
        expect(restPause.weight, 80);
        expect(restPause.targetReps, 8);
        expect(restPause.restPauseSets.length, 3);

        // Verify restSeconds is preserved
        expect(restPause.restPauseSets[0].restSeconds, 20);
        expect(restPause.restPauseSets[1].restSeconds, 20);
        expect(restPause.restPauseSets[2].restSeconds, 20);
      });

      test('should use default restSeconds when not provided', () {
        const template = ExerciseTemplate(
          exerciseId: 'restpause_2',
          exerciseName: 'Test Rest-Pause',
          category: ExerciseCategory.back,
          type: ExerciseType.restPause,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 50, targetReps: 10),
            SetTemplate(setNumber: 2, targetReps: 6),
          ],
        );

        final exercise = template.toWorkoutExercise();

        expect(exercise, isA<RestPauseExercise>());
        final restPause = exercise as RestPauseExercise;
        // Default restSeconds should be 15
        expect(restPause.restPauseSets[0].restSeconds, 15);
        expect(restPause.restPauseSets[1].restSeconds, 15);
      });
    });

    group('Roundtrip conversion', () {
      test('DropSetExercise -> ExerciseTemplate -> DropSetExercise preserves data', () {
        // Create original DropSetExercise
        final original = DropSetExercise(
          name: 'Lateral Raise Drop Set',
          category: ExerciseCategory.shoulders,
          stages: [
            DropSetStage(weight: 12, reps: 10, isCompleted: false),
            DropSetStage(weight: 8, reps: 12, isCompleted: false),
            DropSetStage(weight: 5, reps: 15, isCompleted: false),
          ],
          notes: 'Keep strict form',
          restTime: 60,
        );

        // Convert to template
        final template = ExerciseTemplate.fromExercise(original);

        // Convert back to exercise
        final converted = template.toWorkoutExercise();

        // Verify it's still a DropSetExercise with same data
        expect(converted, isA<DropSetExercise>());
        final dropset = converted as DropSetExercise;

        expect(dropset.name, original.name);
        expect(dropset.category, original.category);
        expect(dropset.stages.length, original.stages.length);
        expect(dropset.stages[0].weight, original.stages[0].weight);
        expect(dropset.stages[0].reps, original.stages[0].reps);
        expect(dropset.stages[1].weight, original.stages[1].weight);
        expect(dropset.stages[2].weight, original.stages[2].weight);
        expect(dropset.notes, original.notes);
        expect(dropset.restTime, original.restTime);
      });

      test('RestPauseExercise -> ExerciseTemplate -> RestPauseExercise preserves data', () {
        // Create original RestPauseExercise
        final original = RestPauseExercise(
          name: 'Leg Press Rest-Pause',
          category: ExerciseCategory.legs,
          weight: 200,
          targetReps: 15,
          restPauseSets: [
            RestPauseSet(reps: 15, restSeconds: 25, isCompleted: false),
            RestPauseSet(reps: 8, restSeconds: 25, isCompleted: false),
            RestPauseSet(reps: 5, restSeconds: 25, isCompleted: false),
          ],
          notes: 'Go deep',
          restTime: 120,
        );

        // Convert to template
        final template = ExerciseTemplate.fromExercise(original);

        // Convert back to exercise
        final converted = template.toWorkoutExercise();

        // Verify it's still a RestPauseExercise with same data
        expect(converted, isA<RestPauseExercise>());
        final restPause = converted as RestPauseExercise;

        expect(restPause.name, original.name);
        expect(restPause.category, original.category);
        expect(restPause.weight, original.weight);
        expect(restPause.targetReps, original.targetReps);
        expect(restPause.restPauseSets.length, original.restPauseSets.length);
        // Verify restSeconds is preserved through roundtrip
        expect(restPause.restPauseSets[0].restSeconds, 25);
        expect(restPause.restPauseSets[1].restSeconds, 25);
        expect(restPause.notes, original.notes);
        expect(restPause.restTime, original.restTime);
      });
    });

    group('Normal exercise conversion (regression)', () {
      test('should still convert normal exercises correctly', () {
        const template = ExerciseTemplate(
          exerciseId: 'normal_1',
          exerciseName: 'Squat',
          category: ExerciseCategory.legs,
          type: ExerciseType.single,
          sets: [
            SetTemplate(setNumber: 1, targetWeight: 100, targetReps: 5),
            SetTemplate(setNumber: 2, targetWeight: 100, targetReps: 5),
            SetTemplate(setNumber: 3, targetWeight: 100, targetReps: 5),
          ],
        );

        final exercise = template.toWorkoutExercise();

        expect(exercise, isA<Exercise>());
        expect(exercise, isNot(isA<DropSetExercise>()));
        expect(exercise, isNot(isA<RestPauseExercise>()));
        expect(exercise.type, ExerciseType.single);
        expect(exercise.sets.length, 3);
      });
    });
  });
}
