import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/usecases/get_workouts_usecase.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late GetWorkoutsUseCase usecase;
  late MockWorkoutRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkoutRepository();
    usecase = GetWorkoutsUseCase(mockRepository);
  });

  final now = DateTime(2026, 3, 1, 12, 0);

  Workout _makeWorkout({
    required String id,
    required String name,
    WorkoutStatus status = WorkoutStatus.completed,
    DateTime? startTime,
    DateTime? endTime,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id,
      name: name,
      status: status,
      startTime: startTime ?? now.subtract(const Duration(hours: 2)),
      endTime: endTime ?? now.subtract(const Duration(hours: 1)),
      exercises: exercises ?? [],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now,
    );
  }

  group('GetWorkoutsUseCase', () {
    group('parameter validation', () {
      test('should fail when limit is 0', () async {
        final params = GetWorkoutsParams(limit: 0);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_limit'),
        );
        verifyNever(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        );
      });

      test('should fail when limit is negative', () async {
        final params = GetWorkoutsParams(limit: -1);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_limit'),
        );
      });

      test('should fail when limit exceeds 1000', () async {
        final params = GetWorkoutsParams(limit: 1001);

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('limit_too_high'),
        );
      });

      test('should fail when startDate is after endDate', () async {
        final params = GetWorkoutsParams(
          startDate: DateTime(2026, 3, 10),
          endDate: DateTime(2026, 3, 1),
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(
          (result.leftOrNull as ValidationFailure).code,
          equals('invalid_date_range'),
        );
      });

      test('should accept valid limit', () async {
        const params = GetWorkoutsParams(limit: 50);

        when(() => mockRepository.getWorkouts(
              limit: any(named: 'limit'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right<Failure, List<Workout>>([]));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });

      test('should accept null limit', () async {
        const params = GetWorkoutsParams();

        when(() => mockRepository.getWorkouts(
              limit: any(named: 'limit'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => Right<Failure, List<Workout>>([]));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
      });
    });

    group('successful retrieval', () {
      test('should return workouts from repository', () async {
        final workouts = [
          _makeWorkout(id: '1', name: 'Push Day'),
          _makeWorkout(id: '2', name: 'Pull Day'),
        ];
        const params = GetWorkoutsParams();

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.length, equals(2));
      });

      test('should pass limit and dates to repository', () async {
        final startDate = DateTime(2026, 1, 1);
        final endDate = DateTime(2026, 2, 1);
        final params = GetWorkoutsParams(
          limit: 10,
          startDate: startDate,
          endDate: endDate,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right<Failure, List<Workout>>([]));

        await usecase(params);

        verify(
          () => mockRepository.getWorkouts(
            limit: 10,
            startDate: startDate,
            endDate: endDate,
          ),
        ).called(1);
      });
    });

    group('status filtering', () {
      test('should filter by status', () async {
        final workouts = [
          _makeWorkout(id: '1', name: 'Completed', status: WorkoutStatus.completed),
          _makeWorkout(id: '2', name: 'In Progress', status: WorkoutStatus.inProgress),
          _makeWorkout(id: '3', name: 'Planned', status: WorkoutStatus.planned),
        ];
        final params = GetWorkoutsParams(
          statusFilter: WorkoutStatus.completed,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.length, equals(1));
        expect(result.rightOrNull!.first.name, equals('Completed'));
      });
    });

    group('minimum duration filtering', () {
      test('should filter workouts by minimum duration', () async {
        final workouts = [
          _makeWorkout(
            id: '1',
            name: 'Long',
            startTime: now.subtract(const Duration(hours: 2)),
            endTime: now,
          ),
          _makeWorkout(
            id: '2',
            name: 'Short',
            startTime: now.subtract(const Duration(minutes: 10)),
            endTime: now,
          ),
        ];
        final params = GetWorkoutsParams(
          minDuration: const Duration(hours: 1),
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.length, equals(1));
        expect(result.rightOrNull!.first.name, equals('Long'));
      });
    });

    group('minimum exercises filtering', () {
      test('should filter workouts by minimum exercise count', () async {
        final exerciseA = Exercise(
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [ExerciseSet(setNumber: 1, weight: 80, reps: 10)],
        );
        final exerciseB = Exercise(
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [ExerciseSet(setNumber: 1, weight: 100, reps: 5)],
        );

        final workouts = [
          _makeWorkout(id: '1', name: 'Full', exercises: [exerciseA, exerciseB]),
          _makeWorkout(id: '2', name: 'Minimal', exercises: [exerciseA]),
        ];
        final params = GetWorkoutsParams(minExercises: 2);

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.length, equals(1));
        expect(result.rightOrNull!.first.name, equals('Full'));
      });
    });

    group('sorting', () {
      test('should sort by date descending (default)', () async {
        final workouts = [
          _makeWorkout(
            id: '1',
            name: 'Older',
            startTime: now.subtract(const Duration(days: 3)),
          ),
          _makeWorkout(
            id: '2',
            name: 'Newer',
            startTime: now.subtract(const Duration(days: 1)),
          ),
        ];
        const params = GetWorkoutsParams(
          sortBy: WorkoutSortBy.date,
          sortDescending: true,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.first.name, equals('Newer'));
        expect(result.rightOrNull!.last.name, equals('Older'));
      });

      test('should sort by date ascending', () async {
        final workouts = [
          _makeWorkout(
            id: '1',
            name: 'Newer',
            startTime: now.subtract(const Duration(days: 1)),
          ),
          _makeWorkout(
            id: '2',
            name: 'Older',
            startTime: now.subtract(const Duration(days: 3)),
          ),
        ];
        const params = GetWorkoutsParams(
          sortBy: WorkoutSortBy.date,
          sortDescending: false,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.first.name, equals('Older'));
      });

      test('should sort by name descending', () async {
        final workouts = [
          _makeWorkout(id: '1', name: 'Alpha'),
          _makeWorkout(id: '2', name: 'Zeta'),
        ];
        const params = GetWorkoutsParams(
          sortBy: WorkoutSortBy.name,
          sortDescending: true,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.first.name, equals('Zeta'));
      });

      test('should sort by duration', () async {
        final workouts = [
          _makeWorkout(
            id: '1',
            name: 'Long',
            startTime: now.subtract(const Duration(hours: 2)),
            endTime: now,
          ),
          _makeWorkout(
            id: '2',
            name: 'Short',
            startTime: now.subtract(const Duration(minutes: 30)),
            endTime: now,
          ),
        ];
        const params = GetWorkoutsParams(
          sortBy: WorkoutSortBy.duration,
          sortDescending: true,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.first.name, equals('Long'));
      });

      test('should sort by exercise count', () async {
        final exercise = Exercise(
          name: 'Bench',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [ExerciseSet(setNumber: 1)],
        );
        final workouts = [
          _makeWorkout(id: '1', name: 'Few', exercises: [exercise]),
          _makeWorkout(id: '2', name: 'Many', exercises: [exercise, exercise, exercise]),
        ];
        const params = GetWorkoutsParams(
          sortBy: WorkoutSortBy.exerciseCount,
          sortDescending: true,
        );

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => Right(workouts));

        final result = await usecase(params);

        expect(result.isRight, isTrue);
        expect(result.rightOrNull!.first.name, equals('Many'));
      });
    });

    group('failure handling', () {
      test('should return failure when repository fails', () async {
        const params = GetWorkoutsParams();

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('Server error')),
        );

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<ServerFailure>());
      });

      test('should return UnexpectedFailure on exception', () async {
        const params = GetWorkoutsParams();

        when(
          () => mockRepository.getWorkouts(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(Exception('Unexpected'));

        final result = await usecase(params);

        expect(result.isLeft, isTrue);
        expect(result.leftOrNull, isA<UnexpectedFailure>());
      });
    });

    group('GetWorkoutsParams defaults', () {
      test('should have correct defaults', () {
        const params = GetWorkoutsParams();
        expect(params.limit, isNull);
        expect(params.startDate, isNull);
        expect(params.endDate, isNull);
        expect(params.statusFilter, isNull);
        expect(params.minDuration, isNull);
        expect(params.minExercises, isNull);
        expect(params.sortBy, equals(WorkoutSortBy.date));
        expect(params.sortDescending, isTrue);
      });
    });
  });
}
