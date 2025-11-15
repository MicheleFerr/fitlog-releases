import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:uuid/uuid.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  late StreakRepository repository;
  late MockWorkoutRepository mockWorkoutRepository;

  setUp(() {
    mockWorkoutRepository = MockWorkoutRepository();
    repository = StreakRepositoryImpl(mockWorkoutRepository);
  });

  group('StreakRepository', () {
    test('should calculate streak from workout repository data', () async {
      final now = DateTime.now();
      final workouts = <Workout>[
        Workout(
          id: const Uuid().v4(),
          name: 'Workout 1',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
          exercises: const [],
          status: WorkoutStatus.completed,
          endTime: now.subtract(const Duration(days: 2)),
        ),
        Workout(
          id: const Uuid().v4(),
          name: 'Workout 2',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
          exercises: const [],
          status: WorkoutStatus.completed,
          endTime: now.subtract(const Duration(days: 1)),
        ),
        Workout(
          id: const Uuid().v4(),
          name: 'Workout 3',
          createdAt: now,
          updatedAt: now,
          exercises: const [],
          status: WorkoutStatus.completed,
          endTime: now,
        ),
      ];

      when(() => mockWorkoutRepository.getWorkouts())
          .thenAnswer((_) async => Right(workouts));

      final streak = await repository.getCurrentStreak();

      expect(streak.currentStreak, 3);
      expect(streak.totalWorkoutDays, 3);
    });

    test('should filter out incomplete workouts', () async {
      final now = DateTime.now();
      final workouts = <Workout>[
        Workout(
          id: const Uuid().v4(),
          name: 'Workout 1',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
          exercises: const [],
          status: WorkoutStatus.completed,
          endTime: now.subtract(const Duration(days: 1)),
        ),
        Workout(
          id: const Uuid().v4(),
          name: 'Workout 2',
          createdAt: now.subtract(const Duration(hours: 12)),
          updatedAt: now.subtract(const Duration(hours: 12)),
          exercises: const [],
          status: WorkoutStatus.inProgress, // Not completed
        ),
        Workout(
          id: const Uuid().v4(),
          name: 'Workout 3',
          createdAt: now,
          updatedAt: now,
          exercises: const [],
          status: WorkoutStatus.completed,
          endTime: now,
        ),
      ];

      when(() => mockWorkoutRepository.getWorkouts())
          .thenAnswer((_) async => Right(workouts));

      final streak = await repository.getCurrentStreak();

      expect(streak.totalWorkoutDays, 2); // Only 2 completed workouts
    });

    test('should handle empty workout list', () async {
      when(() => mockWorkoutRepository.getWorkouts())
          .thenAnswer((_) async => const Right([]));

      final streak = await repository.getCurrentStreak();

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.isActive, false);
    });
  });
}
