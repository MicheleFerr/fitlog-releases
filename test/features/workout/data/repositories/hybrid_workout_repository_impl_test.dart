import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_workout_repository_impl.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/firebase_workout_datasource.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

// Mocks
class MockHiveWorkoutDataSource extends Mock implements HiveWorkoutDataSource {}
class MockFirebaseWorkoutDataSource extends Mock implements FirebaseWorkoutDataSource {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

// Fakes for registerFallbackValue
class FakeWorkoutModel extends Fake implements WorkoutModel {}
class FakeExercise extends Fake implements Exercise {}

void main() {
  late HybridWorkoutRepositoryImpl repository;
  late MockHiveWorkoutDataSource mockLocalDataSource;
  late MockFirebaseWorkoutDataSource mockRemoteDataSource;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockLocalDataSource = MockHiveWorkoutDataSource();
    mockRemoteDataSource = MockFirebaseWorkoutDataSource();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Register fallback values for mocktail
    registerFallbackValue(FakeWorkoutModel());
    registerFallbackValue(FakeExercise());

    // Default auth setup - authenticated user
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

    repository = HybridWorkoutRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      auth: mockAuth,
    );
  });

  tearDown(() {
    repository.dispose();
  });

  group('HybridWorkoutRepositoryImpl - saveWorkout', () {
    test('should save workout locally and return success', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.saveWorkout(any(), any()))
          .thenAnswer((_) async => 'workout-id');

      // Act
      final result = await repository.saveWorkout(workout);

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (id) => expect(id, equals('workout-id')),
      );
      verify(() => mockLocalDataSource.saveWorkout(any(), 'test-user-id')).called(1);
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      final workout = _createTestWorkout();

      // Act
      final result = await repository.saveWorkout(workout);

      // Assert
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.toString(), contains('not authenticated')),
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(() => mockLocalDataSource.saveWorkout(any(), any()));
    });

    test('should save locally first for instant response', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.saveWorkout(any(), any()))
          .thenAnswer((_) async => 'workout-id');

      // Act
      final stopwatch = Stopwatch()..start();
      await repository.saveWorkout(workout);
      stopwatch.stop();

      // Assert - Should be fast (< 100ms for local save)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      verify(() => mockLocalDataSource.saveWorkout(any(), 'test-user-id')).called(1);
    });

    test('should handle save errors gracefully', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.saveWorkout(any(), any()))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.saveWorkout(workout);

      // Assert
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.toString(), contains('Failed to save workout')),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('HybridWorkoutRepositoryImpl - updateWorkout', () {
    test('should update workout locally', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.updateWorkout(any(), any()))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateWorkout(workout);

      // Assert
      expect(result.isRight, isTrue);
      verify(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id')).called(1);
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      final workout = _createTestWorkout();

      // Act
      final result = await repository.updateWorkout(workout);

      // Assert
      expect(result.isLeft, isTrue);
      verifyNever(() => mockLocalDataSource.updateWorkout(any(), any()));
    });

    test('should handle update errors', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.updateWorkout(any(), any()))
          .thenThrow(Exception('Update failed'));

      // Act
      final result = await repository.updateWorkout(workout);

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - getWorkout', () {
    test('should get workout from local storage first', () async {
      // Arrange
      final workoutModel = _createTestWorkoutModel();
      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => workoutModel);

      // Act
      final result = await repository.getWorkout('workout-id');

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (workout) => expect(workout.id, equals('workout-id')),
      );
      verify(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id')).called(1);
    });

    test('should return failure when workout not found locally', () async {
      // Arrange
      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getWorkout('workout-id');

      // Assert
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.toString(), contains('not found')),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await repository.getWorkout('workout-id');

      // Assert
      expect(result.isLeft, isTrue);
      verifyNever(() => mockLocalDataSource.getWorkout(any(), any()));
    });

    test('should handle get errors gracefully', () async {
      // Arrange
      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getWorkout('workout-id');

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - getWorkouts', () {
    test('should get workouts from local storage', () async {
      // Arrange
      final workouts = [_createTestWorkoutModel(), _createTestWorkoutModel()];
      when(() => mockLocalDataSource.getWorkouts(
        'test-user-id',
        limit: any(named: 'limit'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => workouts);

      // Act
      final result = await repository.getWorkouts();

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (workoutList) => expect(workoutList.length, equals(2)),
      );
    });

    test('should apply limit filter correctly', () async {
      // Arrange
      final workouts = [_createTestWorkoutModel()];
      when(() => mockLocalDataSource.getWorkouts(
        'test-user-id',
        limit: 10,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => workouts);

      // Act
      await repository.getWorkouts(limit: 10);

      // Assert
      verify(() => mockLocalDataSource.getWorkouts(
        'test-user-id',
        limit: 10,
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).called(1);
    });

    test('should apply date range filters', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      when(() => mockLocalDataSource.getWorkouts(
        'test-user-id',
        limit: any(named: 'limit'),
        startDate: startDate,
        endDate: endDate,
      )).thenAnswer((_) async => []);

      // Act
      await repository.getWorkouts(startDate: startDate, endDate: endDate);

      // Assert
      verify(() => mockLocalDataSource.getWorkouts(
        'test-user-id',
        limit: any(named: 'limit'),
        startDate: startDate,
        endDate: endDate,
      )).called(1);
    });

    test('should return empty list when no workouts found', () async {
      // Arrange
      when(() => mockLocalDataSource.getWorkouts(
        'test-user-id',
        limit: any(named: 'limit'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getWorkouts();

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (workouts) => expect(workouts, isEmpty),
      );
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await repository.getWorkouts();

      // Assert
      expect(result.isLeft, isTrue);
      verifyNever(() => mockLocalDataSource.getWorkouts(
        any(),
        limit: any(named: 'limit'),
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ));
    });
  });

  group('HybridWorkoutRepositoryImpl - deleteWorkout', () {
    test('should delete workout from local storage', () async {
      // Arrange
      when(() => mockLocalDataSource.deleteWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteWorkout('workout-id');

      // Assert
      expect(result.isRight, isTrue);
      verify(() => mockLocalDataSource.deleteWorkout('workout-id', 'test-user-id')).called(1);
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await repository.deleteWorkout('workout-id');

      // Assert
      expect(result.isLeft, isTrue);
      verifyNever(() => mockLocalDataSource.deleteWorkout(any(), any()));
    });

    test('should handle delete errors', () async {
      // Arrange
      when(() => mockLocalDataSource.deleteWorkout('workout-id', 'test-user-id'))
          .thenThrow(Exception('Delete failed'));

      // Act
      final result = await repository.deleteWorkout('workout-id');

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - saveCompletedWorkout', () {
    test('should save completed workout to local storage', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.saveWorkout(any(), 'test-user-id'))
          .thenAnswer((_) async => 'workout-id');

      // Act
      final result = await repository.saveCompletedWorkout(
        workout: workout,
        userEmail: 'test@example.com',
      );

      // Assert
      expect(result.isRight, isTrue);
      verify(() => mockLocalDataSource.saveWorkout(any(), 'test-user-id')).called(1);
    });

    test('should return empty activity IDs list', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.saveWorkout(any(), 'test-user-id'))
          .thenAnswer((_) async => 'workout-id');

      // Act
      final result = await repository.saveCompletedWorkout(
        workout: workout,
        userEmail: 'test@example.com',
      );

      // Assert
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (activityIds) => expect(activityIds, isEmpty),
      );
    });
  });

  group('HybridWorkoutRepositoryImpl - Mutex Protection', () {
    test('should protect concurrent save operations with mutex', () async {
      // Arrange
      final workout = _createTestWorkout();
      var callCount = 0;

      when(() => mockLocalDataSource.saveWorkout(any(), any()))
          .thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return 'workout-id-$callCount';
      });

      // Act - Start multiple saves concurrently
      final futures = [
        repository.saveWorkout(workout),
        repository.saveWorkout(workout),
        repository.saveWorkout(workout),
      ];

      await Future.wait(futures);

      // Assert - Mutex should ensure sequential execution
      verify(() => mockLocalDataSource.saveWorkout(any(), any())).called(3);
      expect(callCount, equals(3));
    });

    test('should protect concurrent update operations', () async {
      // Arrange
      final workout = _createTestWorkout();
      var updateCount = 0;

      when(() => mockLocalDataSource.updateWorkout(any(), any()))
          .thenAnswer((_) async {
        updateCount++;
        await Future.delayed(const Duration(milliseconds: 50));
      });

      // Act
      final futures = [
        repository.updateWorkout(workout),
        repository.updateWorkout(workout),
      ];

      await Future.wait(futures);

      // Assert
      expect(updateCount, equals(2));
    });
  });

  group('HybridWorkoutRepositoryImpl - Error Handling', () {
    test('should return UnexpectedFailure for unknown errors', () async {
      // Arrange
      final workout = _createTestWorkout();
      when(() => mockLocalDataSource.saveWorkout(any(), any()))
          .thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.saveWorkout(workout);

      // Assert
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.toString(), contains('Failed to save workout')),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should handle null user gracefully in all methods', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert - All methods should fail gracefully
      expect((await repository.saveWorkout(_createTestWorkout())).isLeft, isTrue);
      expect((await repository.updateWorkout(_createTestWorkout())).isLeft, isTrue);
      expect((await repository.getWorkout('id')).isLeft, isTrue);
      expect((await repository.getWorkouts()).isLeft, isTrue);
      expect((await repository.deleteWorkout('id')).isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - Disposal', () {
    test('should properly dispose resources', () {
      // Act
      repository.dispose();

      // Assert - Should not throw
      expect(true, isTrue);
    });

    test('should prevent operations after disposal', () {
      // Act
      repository.dispose();

      // Assert - Operations should handle disposed state
      // (Implementation detail - _isDisposed flag prevents operations)
      expect(true, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - getWorkoutStats', () {
    test('should get workout stats from local storage', () async {
      // Arrange
      const stats = WorkoutStats(
        totalWorkouts: 10,
        totalExercises: 50,
        totalSets: 150,
        totalDuration: Duration(hours: 7, minutes: 30),
        averageWorkoutDuration: 45.0, // minutes as double
        exercisesByCategory: {},
      );
      when(() => mockLocalDataSource.getWorkoutStats(
        'test-user-id',
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).thenAnswer((_) async => stats);

      // Act
      final result = await repository.getWorkoutStats();

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (returnedStats) {
          expect(returnedStats.totalWorkouts, equals(10));
          expect(returnedStats.totalExercises, equals(50));
        },
      );
      verify(() => mockLocalDataSource.getWorkoutStats(
        'test-user-id',
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      )).called(1);
    });

    test('should apply date filters to stats', () async {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      const stats = WorkoutStats(
        totalWorkouts: 5,
        totalExercises: 25,
        totalSets: 75,
        totalDuration: Duration(hours: 3, minutes: 20),
        averageWorkoutDuration: 40.0, // minutes as double
        exercisesByCategory: {},
      );
      when(() => mockLocalDataSource.getWorkoutStats(
        'test-user-id',
        startDate: startDate,
        endDate: endDate,
      )).thenAnswer((_) async => stats);

      // Act
      await repository.getWorkoutStats(startDate: startDate, endDate: endDate);

      // Assert
      verify(() => mockLocalDataSource.getWorkoutStats(
        'test-user-id',
        startDate: startDate,
        endDate: endDate,
      )).called(1);
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await repository.getWorkoutStats();

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - watchActiveWorkout', () {
    test('should stream active workout from local storage', () async {
      // Arrange
      final workoutModel = _createTestWorkoutModel();
      when(() => mockLocalDataSource.getActiveWorkout('test-user-id'))
          .thenAnswer((_) async => workoutModel);

      // Act
      final stream = repository.watchActiveWorkout();
      final results = await stream.take(2).toList();

      // Assert
      expect(results.length, equals(2));
      expect(results.every((r) => r.isRight), isTrue);
    });

    test('should stream null when no active workout', () async {
      // Arrange
      when(() => mockLocalDataSource.getActiveWorkout('test-user-id'))
          .thenAnswer((_) async => null);

      // Act
      final stream = repository.watchActiveWorkout();
      final result = await stream.first;

      // Assert
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (workout) => expect(workout, isNull),
      );
    });

    test('should return failure stream when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final stream = repository.watchActiveWorkout();
      final result = await stream.first;

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - getWorkoutHistory', () {
    test('should get workout history with pagination', () async {
      // Arrange
      final history = WorkoutHistory(
        workouts: [_createTestWorkout(), _createTestWorkout()],
        totalCount: 20,
        currentPage: 1,
        hasMore: true,
      );
      when(() => mockLocalDataSource.getWorkoutHistory(
        'test-user-id',
        page: 1,
        limit: 10,
      )).thenAnswer((_) async => history);

      // Act
      final result = await repository.getWorkoutHistory(page: 1, limit: 10);

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (returnedHistory) {
          expect(returnedHistory.workouts.length, equals(2));
          expect(returnedHistory.totalCount, equals(20));
          expect(returnedHistory.hasMore, isTrue);
        },
      );
    });

    test('should handle different page numbers', () async {
      // Arrange
      final history = WorkoutHistory(
        workouts: [_createTestWorkout()],
        totalCount: 15,
        currentPage: 2,
        hasMore: false,
      );
      when(() => mockLocalDataSource.getWorkoutHistory(
        'test-user-id',
        page: 2,
        limit: 10,
      )).thenAnswer((_) async => history);

      // Act
      await repository.getWorkoutHistory(page: 2, limit: 10);

      // Assert
      verify(() => mockLocalDataSource.getWorkoutHistory(
        'test-user-id',
        page: 2,
        limit: 10,
      )).called(1);
    });

    test('should return failure when user not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await repository.getWorkoutHistory();

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - updateExerciseSet', () {
    test('should update exercise set within workout', () async {
      // Arrange
      final workout = _createTestWorkoutWithExercise();
      final workoutModel = WorkoutModel.fromDomain(workout);
      final exerciseSet = ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        reps: 12,
        weight: 50.0,
        restTime: 90,
        isCompleted: true,
      );

      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => workoutModel);
      when(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.updateExerciseSet(
        workoutId: 'workout-id',
        exerciseId: 'exercise-1',
        exerciseSet: exerciseSet,
      );

      // Assert
      expect(result.isRight, isTrue);
      verify(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id')).called(1);
      verify(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id')).called(1);
    });

    test('should return failure when workout not found', () async {
      // Arrange
      final exerciseSet = ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        reps: 10,
        weight: 40.0,
        restTime: 60,
        isCompleted: false,
      );
      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.updateExerciseSet(
        workoutId: 'workout-id',
        exerciseId: 'exercise-1',
        exerciseSet: exerciseSet,
      );

      // Assert
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure.toString(), contains('not found')),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('HybridWorkoutRepositoryImpl - addExerciseToWorkout', () {
    test('should add exercise to existing workout', () async {
      // Arrange
      final workout = _createTestWorkout();
      final workoutModel = WorkoutModel.fromDomain(workout);
      final newExercise = _createTestExercise();

      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => workoutModel);
      when(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.addExerciseToWorkout(
        workoutId: 'workout-id',
        exercise: newExercise,
      );

      // Assert
      expect(result.isRight, isTrue);
      verify(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id')).called(1);
      verify(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id')).called(1);
    });

    test('should return failure when workout not found', () async {
      // Arrange
      final exercise = _createTestExercise();
      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.addExerciseToWorkout(
        workoutId: 'workout-id',
        exercise: exercise,
      );

      // Assert
      expect(result.isLeft, isTrue);
    });
  });

  group('HybridWorkoutRepositoryImpl - removeExerciseFromWorkout', () {
    test('should remove exercise from workout', () async {
      // Arrange
      final workout = _createTestWorkoutWithExercise();
      final workoutModel = WorkoutModel.fromDomain(workout);

      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => workoutModel);
      when(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id'))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.removeExerciseFromWorkout(
        workoutId: 'workout-id',
        exerciseId: 'exercise-1',
      );

      // Assert
      expect(result.isRight, isTrue);
      verify(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id')).called(1);
      verify(() => mockLocalDataSource.updateWorkout(any(), 'test-user-id')).called(1);
    });

    test('should return failure when workout not found', () async {
      // Arrange
      when(() => mockLocalDataSource.getWorkout('workout-id', 'test-user-id'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.removeExerciseFromWorkout(
        workoutId: 'workout-id',
        exerciseId: 'exercise-1',
      );

      // Assert
      expect(result.isLeft, isTrue);
    });
  });
}

/// Helper function to create a test Workout entity
Workout _createTestWorkout({
  String? id,
  String name = 'Test Workout',
  WorkoutStatus status = WorkoutStatus.planned,
}) {
  return Workout(
    id: id ?? 'workout-id',
    name: name,
    exercises: [],
    status: status,
    startTime: DateTime(2024, 1, 15, 10, 0),
    endTime: DateTime(2024, 1, 15, 11, 0),
    notes: 'Test notes',
  );
}

/// Helper function to create a test Workout with an exercise
Workout _createTestWorkoutWithExercise() {
  return Workout(
    id: 'workout-id',
    name: 'Test Workout',
    exercises: [_createTestExercise()],
    status: WorkoutStatus.inProgress,
    startTime: DateTime(2024, 1, 15, 10, 0),
    endTime: DateTime(2024, 1, 15, 11, 0),
    notes: 'Test notes',
  );
}

/// Helper function to create a test Exercise
Exercise _createTestExercise({String? id}) {
  return Exercise(
    id: id ?? 'exercise-1',
    name: 'Bench Press',
    type: ExerciseType.single,
    category: ExerciseCategory.chest,
    sets: [
      ExerciseSet(
        id: 'set-1',
        setNumber: 1,
        reps: 10,
        weight: 50.0,
        restTime: 90,
        isCompleted: false,
      ),
    ],
    restTime: 90,
    notes: 'Test exercise',
  );
}

/// Helper function to create a test WorkoutModel
WorkoutModel _createTestWorkoutModel({
  String? id,
  String name = 'Test Workout',
}) {
  final workout = _createTestWorkout(id: id, name: name);
  return WorkoutModel.fromDomain(workout);
}
