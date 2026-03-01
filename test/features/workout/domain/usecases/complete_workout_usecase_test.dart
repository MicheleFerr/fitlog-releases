import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/complete_workout_usecase.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class FakeWorkout extends Fake implements Workout {}

void main() {
  late CompleteWorkoutUseCase usecase;
  late MockWorkoutRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeWorkout());
  });

  setUp(() {
    mockRepository = MockWorkoutRepository();
    usecase = CompleteWorkoutUseCase(mockRepository);
  });

  // Helper to create a valid in-progress workout
  Workout _createValidWorkout({
    WorkoutStatus status = WorkoutStatus.inProgress,
    DateTime? startTime,
    List<Exercise>? exercises,
    int completedSetCount = 1,
  }) {
    final now = DateTime.now();
    final start = startTime ?? now.subtract(const Duration(minutes: 30));

    final defaultExercise = Exercise(
      name: 'Bench Press',
      type: ExerciseType.single,
      category: ExerciseCategory.chest,
      sets: [
        ExerciseSet(
          setNumber: 1,
          weight: 80.0,
          reps: 10,
          isCompleted: completedSetCount > 0,
          rpe: 7,
          restTime: 90,
        ),
        ExerciseSet(
          setNumber: 2,
          weight: 85.0,
          reps: 8,
          isCompleted: completedSetCount > 1,
        ),
      ],
    );

    return Workout(
      id: 'workout-1',
      name: 'Push Day',
      status: status,
      startTime: start,
      exercises: exercises ?? [defaultExercise],
      createdAt: now.subtract(const Duration(hours: 1)),
      updatedAt: now,
    );
  }

  group('CompleteWorkoutUseCase', () {
    group('validation', () {
      test('should fail when workout is not in progress', () async {
        final workout = _createValidWorkout(status: WorkoutStatus.planned);
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<ValidationFailure>());
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_workout_status'),
        );
        verifyNever(() => mockRepository.saveWorkout(any()));
      });

      test('should fail when workout is already completed', () async {
        final workout = _createValidWorkout(status: WorkoutStatus.completed);
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<ValidationFailure>());
      });

      test('should fail when workout has no startTime', () async {
        final now = DateTime.now();
        final workout = Workout(
          id: 'workout-1',
          name: 'Push Day',
          status: WorkoutStatus.inProgress,
          startTime: null,
          exercises: [
            Exercise(
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: true),
              ],
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('workout_not_started'),
        );
      });

      test('should fail when workout has no exercises', () async {
        final workout = _createValidWorkout(exercises: []);
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('no_exercises'),
        );
      });

      test('should fail when workout has no completed sets', () async {
        final workout = _createValidWorkout(completedSetCount: 0);
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('no_completed_sets'),
        );
      });

      test('should fail when workout duration is less than 30 seconds', () async {
        final now = DateTime.now();
        final workout = Workout(
          id: 'workout-1',
          name: 'Push Day',
          status: WorkoutStatus.inProgress,
          startTime: now.subtract(const Duration(seconds: 10)),
          endTime: now,
          exercises: [
            Exercise(
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [
                ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: true),
              ],
            ),
          ],
          createdAt: now,
          updatedAt: now,
        );
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('workout_too_short'),
        );
      });
    });

    group('successful completion', () {
      test('should complete workout and save without activities', () async {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
          saveAsActivities: false,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => const Right('workout-1'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        final completionResult = result.rightOrNull!;
        expect(completionResult.workoutId, equals('workout-1'));
        expect(
          completionResult.completedWorkout.status,
          equals(WorkoutStatus.completed),
        );
        expect(completionResult.completedWorkout.endTime, isNotNull);
        expect(completionResult.activityIds, isEmpty);
        expect(completionResult.stats, isNotNull);
        verify(() => mockRepository.saveWorkout(any())).called(1);
        verifyNever(
          () => mockRepository.saveCompletedWorkout(
            workout: any(named: 'workout'),
            userEmail: any(named: 'userEmail'),
          ),
        );
      });

      test('should complete workout and save with activities', () async {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
          saveAsActivities: true,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => const Right('workout-1'));
        when(
          () => mockRepository.saveCompletedWorkout(
            workout: any(named: 'workout'),
            userEmail: any(named: 'userEmail'),
          ),
        ).thenAnswer((_) async => const Right(['activity-1', 'activity-2']));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        final completionResult = result.rightOrNull!;
        expect(completionResult.activityIds, equals(['activity-1', 'activity-2']));
        verify(() => mockRepository.saveWorkout(any())).called(1);
        verify(
          () => mockRepository.saveCompletedWorkout(
            workout: any(named: 'workout'),
            userEmail: 'user@test.com',
          ),
        ).called(1);
      });
    });

    group('stats calculation', () {
      test('should calculate correct completion stats', () async {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
          saveAsActivities: false,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => const Right('workout-1'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        final stats = result.rightOrNull!.stats;
        expect(stats.completedSets, equals(1));
        expect(stats.totalVolume, equals(800.0)); // 80 * 10
        expect(stats.completionRate, equals(0.5)); // 1 of 2 sets
        expect(stats.averageRpe, equals(7.0)); // RPE 7 on the completed set
        expect(stats.averageRestTime, equals(const Duration(seconds: 90)));
        expect(
          stats.exercisesByCategory,
          equals({ExerciseCategory.chest: 1}),
        );
      });

      test('should handle workout with no RPE data', () async {
        final exercise = Exercise(
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [
            ExerciseSet(setNumber: 1, weight: 100, reps: 5, isCompleted: true),
          ],
        );
        final workout = _createValidWorkout(exercises: [exercise]);
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
          saveAsActivities: false,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => const Right('workout-1'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.stats.averageRpe, isNull);
      });
    });

    group('failure handling', () {
      test('should return failure when saveWorkout fails', () async {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        when(() => mockRepository.saveWorkout(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Save failed')),
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<ServerFailure>());
      });

      test('should return failure when saveCompletedWorkout fails', () async {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
          saveAsActivities: true,
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenAnswer((_) async => const Right('workout-1'));
        when(
          () => mockRepository.saveCompletedWorkout(
            workout: any(named: 'workout'),
            userEmail: any(named: 'userEmail'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Activities save failed')),
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<ServerFailure>());
      });

      test('should return UnexpectedFailure on exception', () async {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );

        when(() => mockRepository.saveWorkout(any()))
            .thenThrow(Exception('Unexpected'));

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<UnexpectedFailure>());
      });
    });

    group('CompleteWorkoutParams', () {
      test('should default saveAsActivities to true', () {
        final workout = _createValidWorkout();
        final params = CompleteWorkoutParams(
          workout: workout,
          userEmail: 'user@test.com',
        );
        expect(params.saveAsActivities, isTrue);
      });
    });
  });
}
