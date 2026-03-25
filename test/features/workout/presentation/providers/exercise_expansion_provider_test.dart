import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_expansion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';

void main() {
  group('ExerciseExpansionProvider', () {
    test('completed exercises start collapsed when workout is restored', () {
      final completedExercise = Exercise(
        id: 'exercise-completed',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, reps: 8, weight: 80, isCompleted: true),
        ],
      );
      final activeWorkout = _buildWorkout([completedExercise]);

      final container = ProviderContainer(
        overrides: [
          currentWorkoutProvider.overrideWith(
            () => _TestCurrentWorkoutNotifier(activeWorkout),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(
        exerciseExpansionProvider(completedExercise.id),
      );

      expect(state.isExpanded, isFalse);
      expect(state.hasAutoCollapsed, isTrue);
    });

    test(
      'resetForIncomplete re-expands an exercise that becomes active again',
      () {
        final completedExercise = Exercise(
          id: 'exercise-reset',
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [
            ExerciseSet(setNumber: 1, reps: 5, weight: 100, isCompleted: true),
          ],
        );
        final activeWorkout = _buildWorkout([completedExercise]);

        final container = ProviderContainer(
          overrides: [
            currentWorkoutProvider.overrideWith(
              () => _TestCurrentWorkoutNotifier(activeWorkout),
            ),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(
          exerciseExpansionProvider(completedExercise.id).notifier,
        );

        notifier.resetForIncomplete();

        final state = container.read(
          exerciseExpansionProvider(completedExercise.id),
        );
        expect(state.isExpanded, isTrue);
        expect(state.hasAutoCollapsed, isFalse);
        expect(state.userManuallyExpanded, isFalse);
      },
    );
  });
}

Workout _buildWorkout(List<Exercise> exercises) {
  final now = DateTime(2026, 3, 11);
  return Workout(
    id: 'workout-1',
    name: 'Push Day',
    status: WorkoutStatus.inProgress,
    exercises: exercises,
    createdAt: now,
    updatedAt: now,
  );
}

class _TestCurrentWorkoutNotifier extends CurrentWorkoutNotifier {
  _TestCurrentWorkoutNotifier(this.workout);

  final Workout workout;

  @override
  Workout? build() => workout;
}
