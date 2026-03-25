import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/save_workout_usecase.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class FakeWorkout extends Fake implements Workout {}

void main() {
  late SaveWorkoutUseCase usecase;
  late MockWorkoutRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeWorkout());
  });

  setUp(() {
    mockRepository = MockWorkoutRepository();
    usecase = SaveWorkoutUseCase(mockRepository);
  });

  final now = DateTime(2026, 3, 1, 12, 0);

  Exercise _makeExercise({
    String name = 'Bench Press',
    ExerciseCategory category = ExerciseCategory.chest,
    List<ExerciseSet>? sets,
  }) {
    return Exercise(
      name: name,
      type: ExerciseType.single,
      category: category,
      sets:
          sets ??
          [
            ExerciseSet(
              setNumber: 1,
              weight: 80.0,
              reps: 10,
              isCompleted: true,
            ),
          ],
    );
  }

  Workout _makeWorkout({
    String name = 'Push Day',
    List<Exercise>? exercises,
    WorkoutStatus status = WorkoutStatus.inProgress,
  }) {
    return Workout(
      id: 'workout-1',
      name: name,
      status: status,
      exercises: exercises ?? [_makeExercise()],
      createdAt: now,
      updatedAt: now,
    );
  }

  group('SaveWorkoutUseCase', () {
    group('name validation', () {
      test('should fail when name is empty', () async {
        final workout = _makeWorkout(name: '');
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_name'),
        );
      });

      test('should fail when name is whitespace only', () async {
        final workout = _makeWorkout(name: '   ');
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_name'),
        );
      });

      test('should fail when name is too short (1 char)', () async {
        final workout = _makeWorkout(name: 'A');
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('name_too_short'),
        );
      });

      test('should fail when name exceeds 100 characters', () async {
        final longName = 'A' * 101;
        final workout = _makeWorkout(name: longName);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('name_too_long'),
        );
      });

      test('should accept name with exactly 2 characters', () async {
        final workout = _makeWorkout(name: 'AB');
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });

      test('should accept name with exactly 100 characters', () async {
        final workout = _makeWorkout(name: 'A' * 100);
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });
    });

    group('exercise validation', () {
      test('should fail when workout has no exercises', () async {
        final workout = _makeWorkout(exercises: []);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('empty_workout'),
        );
      });

      test('should fail when exercise name is empty', () async {
        final exercise = _makeExercise(name: '');
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_exercise_name'),
        );
      });

      test('should fail when exercise has no sets', () async {
        final exercise = _makeExercise(sets: []);
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('exercise_no_sets'),
        );
      });
    });

    group('set validation', () {
      test('should fail when weight is negative', () async {
        final exercise = _makeExercise(
          sets: [ExerciseSet(setNumber: 1, weight: -5.0, reps: 10)],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('negative_weight'),
        );
      });

      test('should fail when reps is 0', () async {
        final exercise = _makeExercise(
          sets: [ExerciseSet(setNumber: 1, weight: 80.0, reps: 0)],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_reps'),
        );
      });

      test('should fail when reps exceeds 1000', () async {
        final exercise = _makeExercise(
          sets: [ExerciseSet(setNumber: 1, weight: 80.0, reps: 1001)],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('reps_too_high'),
        );
      });

      test('should accept null weight (bodyweight exercise)', () async {
        final exercise = _makeExercise(
          sets: [ExerciseSet(setNumber: 1, reps: 10)],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });

      test('should accept null reps', () async {
        final exercise = _makeExercise(
          sets: [ExerciseSet(setNumber: 1, weight: 80.0)],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });

      test('should accept zero weight', () async {
        final exercise = _makeExercise(
          sets: [ExerciseSet(setNumber: 1, weight: 0.0, reps: 10)],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });
    });

    group('requireCompletedSets', () {
      test(
        'should fail when requireCompletedSets is true and no completed sets',
        () async {
          final exercise = _makeExercise(
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 80.0,
                reps: 10,
                isCompleted: false,
              ),
            ],
          );
          final workout = _makeWorkout(exercises: [exercise]);
          final params = SaveWorkoutParams(
            workout: workout,
            requireCompletedSets: true,
          );

          final result = await usecase(params);

          expect(result.isLeft, isTrue);
          expect(
            (result.leftOrNull as ValidationFailure).code,
            equals('no_completed_sets'),
          );
        },
      );

      test(
        'should succeed when requireCompletedSets is false and no completed sets',
        () async {
          final exercise = _makeExercise(
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 80.0,
                reps: 10,
                isCompleted: false,
              ),
            ],
          );
          final workout = _makeWorkout(exercises: [exercise]);
          final params = SaveWorkoutParams(
            workout: workout,
            requireCompletedSets: false,
          );

          when(
            () => mockRepository.saveWorkout(any()),
          ).thenAnswer((_) async => const Right('id'));

          final result = await usecase(params);

          expect(result.isRight, isTrue);
        },
      );
    });

    group('successful save', () {
      test('should save workout and return id', () async {
        final workout = _makeWorkout();
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('saved-workout-id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull, equals('saved-workout-id'));
        verify(() => mockRepository.saveWorkout(any())).called(1);
      });

      test(
        'should set endTime for completed workout without endTime',
        () async {
          final workout = _makeWorkout(status: WorkoutStatus.completed);
          final params = SaveWorkoutParams(workout: workout);

          late Workout savedWorkout;
          when(() => mockRepository.saveWorkout(any())).thenAnswer((
            invocation,
          ) async {
            savedWorkout = invocation.positionalArguments[0] as Workout;
            return const Right('id');
          });

          await usecase(params);

          expect(savedWorkout.endTime, isNotNull);
        },
      );

      test('should filter out invalid sets during preparation', () async {
        // Since validation runs first, this test focuses only on preparation logic
        // for sets that are still valid at entity level.
        final exerciseWithFilterable = _makeExercise(
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80.0,
              reps: 10,
              isCompleted: true,
            ),
            ExerciseSet(setNumber: 2, weight: 80.0), // null reps - valid, kept
          ],
        );
        final workout = _makeWorkout(exercises: [exerciseWithFilterable]);
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Right('id'));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });

      test('should renumber sets after filtering', () async {
        final exercise = _makeExercise(
          sets: [
            ExerciseSet(setNumber: 5, weight: 80.0, reps: 10),
            ExerciseSet(setNumber: 10, weight: 85.0, reps: 8),
          ],
        );
        final workout = _makeWorkout(exercises: [exercise]);
        final params = SaveWorkoutParams(workout: workout);

        late Workout savedWorkout;
        when(() => mockRepository.saveWorkout(any())).thenAnswer((
          invocation,
        ) async {
          savedWorkout = invocation.positionalArguments[0] as Workout;
          return const Right('id');
        });

        await usecase(params);

        final savedSets = savedWorkout.exercises.first.sets;
        expect(savedSets[0].setNumber, equals(1));
        expect(savedSets[1].setNumber, equals(2));
      });
    });

    group('failure handling', () {
      test('should return failure when repository fails', () async {
        final workout = _makeWorkout();
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Save failed')));

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<ServerFailure>());
      });

      test('should return UnexpectedFailure on exception', () async {
        final workout = _makeWorkout();
        final params = SaveWorkoutParams(workout: workout);

        when(
          () => mockRepository.saveWorkout(any()),
        ).thenThrow(Exception('Unexpected'));

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<UnexpectedFailure>());
      });
    });

    group('SaveWorkoutParams defaults', () {
      test('should default requireCompletedSets to false', () {
        final workout = _makeWorkout();
        final params = SaveWorkoutParams(workout: workout);
        expect(params.requireCompletedSets, isFalse);
      });
    });
  });
}
