import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_recent_exercises.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late GetRecentExercises usecase;
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
    usecase = GetRecentExercises(mockRepository);
  });

  group('GetRecentExercises', () {
    test('should return last 10 unique exercises from workout history', () async {
      // Mock workout data with various exercises
      final workouts = [
        Workout(
          id: '1',
          name: 'Workout 1',
          exercises: [
            Exercise(
              name: 'Squat',
              type: ExerciseType.single,
              category: ExerciseCategory.legs,
            ),
            Exercise(
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Workout(
          id: '2',
          name: 'Workout 2',
          exercises: [
            Exercise(
              name: 'Squat',
              type: ExerciseType.single,
              category: ExerciseCategory.legs,
            ),
            Exercise(
              name: 'Deadlift',
              type: ExerciseType.single,
              category: ExerciseCategory.legs,
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      when(() => mockRepository.getWorkouts())
          .thenAnswer((_) async => Right(workouts));

      final result = await usecase.execute(limit: 10);

      expect(result, ['Deadlift', 'Squat', 'Bench Press']);
      verify(() => mockRepository.getWorkouts()).called(1);
    });

    test('should respect the limit parameter', () async {
      final workouts = [
        Workout(
          id: '1',
          name: 'Workout 1',
          exercises: [
            Exercise(
              name: 'Squat',
              type: ExerciseType.single,
              category: ExerciseCategory.legs,
            ),
            Exercise(
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
            ),
            Exercise(
              name: 'Deadlift',
              type: ExerciseType.single,
              category: ExerciseCategory.legs,
            ),
            Exercise(
              name: 'Overhead Press',
              type: ExerciseType.single,
              category: ExerciseCategory.shoulders,
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getWorkouts())
          .thenAnswer((_) async => Right(workouts));

      final result = await usecase.execute(limit: 2);

      expect(result.length, 2);
      expect(result, ['Overhead Press', 'Deadlift']);
    });

    test('should return empty list when no workouts exist', () async {
      when(() => mockRepository.getWorkouts())
          .thenAnswer((_) async => const Right([]));

      final result = await usecase.execute(limit: 10);

      expect(result, []);
    });
  });
}
