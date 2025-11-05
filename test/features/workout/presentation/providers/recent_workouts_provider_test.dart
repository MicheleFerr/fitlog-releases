import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

// Mock classes
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  group('recentWorkoutsProvider', () {
    late MockWorkoutRepository mockRepository;

    setUp(() {
      mockRepository = MockWorkoutRepository();
    });

    test('returns workouts from last N days', () async {
      final container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Setup: Mock repository with 5 workouts
      final now = DateTime.now();
      final workouts = [
        createMockWorkout(id: '1', name: 'Workout 1', startTime: now),
        createMockWorkout(id: '2', name: 'Workout 2', startTime: now.subtract(const Duration(days: 2))),
        createMockWorkout(id: '3', name: 'Workout 3', startTime: now.subtract(const Duration(days: 5))),
        createMockWorkout(id: '4', name: 'Workout 4', startTime: now.subtract(const Duration(days: 8))), // Outside 7 days
        createMockWorkout(id: '5', name: 'Workout 5', startTime: now.subtract(const Duration(days: 10))), // Outside 7 days
      ];

      when(() => mockRepository.getWorkouts(limit: 50))
          .thenAnswer((_) async => Right(workouts));

      // Act: Fetch last 7 days
      final result = await container.read(recentWorkoutsProvider(7).future);

      // Assert: Only workouts within 7 days
      expect(result.length, 3);
      expect(result[0].id, '1');
      expect(result[1].id, '2');
      expect(result[2].id, '3');
    });

    test('filters out workouts without startTime', () async {
      final container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final now = DateTime.now();
      final workouts = [
        createMockWorkout(id: '1', name: 'With time', startTime: now),
        createMockWorkout(id: '2', name: 'Without time', startTime: null),
      ];

      when(() => mockRepository.getWorkouts(limit: 50))
          .thenAnswer((_) async => Right(workouts));

      final result = await container.read(recentWorkoutsProvider(7).future);

      expect(result.length, 1);
      expect(result[0].id, '1');
    });

    test('throws exception on repository failure', () async {
      final container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      when(() => mockRepository.getWorkouts(limit: 50))
          .thenAnswer((_) async => Left(ServerFailure('Network error')));

      expect(
        () => container.read(recentWorkoutsProvider(7).future),
        throwsA(isA<Exception>()),
      );
    });
  });
}

// Helper function
Workout createMockWorkout({
  required String id,
  required String name,
  DateTime? startTime,
}) {
  return Workout(
    id: id,
    name: name,
    startTime: startTime,
    endTime: startTime?.add(const Duration(minutes: 45)),
    exercises: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    templateId: null,
  );
}
