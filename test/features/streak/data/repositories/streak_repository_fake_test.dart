import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/streak_milestone.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/either/either.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/paginated_result.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Manual fake - no mocktail/mockito
// ---------------------------------------------------------------------------
class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({
    required this.workoutsResult,
  });

  final Either<Failure, List<Workout>> workoutsResult;

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      workoutsResult;

  // ---- Unimplemented stubs (not called by StreakRepositoryImpl) ----
  @override
  Future<Either<Failure, String>> saveWorkout(Workout workout) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateWorkout(Workout workout) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Workout>> getWorkout(String workoutId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteWorkout(String workoutId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<String>>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateExerciseSet({
    required String workoutId,
    required String exerciseId,
    required ExerciseSet exerciseSet,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, WorkoutStats>> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      throw UnimplementedError();

  @override
  Stream<Either<Failure, Workout?>> watchActiveWorkout() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, WorkoutHistory>> getWorkoutHistory({
    int page = 1,
    int limit = 10,
  }) =>
      throw UnimplementedError();

  @override
  Future<Workout?> getLastCompletedWorkout(String userId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, PaginatedResult<Workout>>> getWorkoutsPaginated({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
  }) =>
      throw UnimplementedError();
}

class _TestNetworkFailure extends Failure {
  const _TestNetworkFailure() : super('network error');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Workout _completedWorkout({required DateTime date, String? id}) => Workout(
      id: id ?? const Uuid().v4(),
      name: 'Test Workout',
      createdAt: date,
      updatedAt: date,
      exercises: const [],
      status: WorkoutStatus.completed,
      endTime: date,
    );

Workout _inProgressWorkout({required DateTime date, String? id}) => Workout(
      id: id ?? const Uuid().v4(),
      name: 'In Progress Workout',
      createdAt: date,
      updatedAt: date,
      exercises: const [],
      status: WorkoutStatus.inProgress,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('StreakRepositoryImpl (manual fakes)', () {
    group('getCurrentStreak', () {
      test('calculates 3-day consecutive streak from completed workouts', () async {
        final now = DateTime.now();
        final workouts = [
          _completedWorkout(date: now.subtract(const Duration(days: 2))),
          _completedWorkout(date: now.subtract(const Duration(days: 1))),
          _completedWorkout(date: now),
        ];

        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: Right(workouts)),
        );

        final streak = await repo.getCurrentStreak();

        expect(streak.currentStreak, 3);
        expect(streak.totalWorkoutDays, 3);
      });

      test('filters out incomplete workouts', () async {
        final now = DateTime.now();
        final workouts = [
          _completedWorkout(date: now.subtract(const Duration(days: 1))),
          _inProgressWorkout(date: now.subtract(const Duration(hours: 12))),
          _completedWorkout(date: now),
        ];

        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: Right(workouts)),
        );

        final streak = await repo.getCurrentStreak();

        // Only 2 completed workouts
        expect(streak.totalWorkoutDays, 2);
      });

      test('returns empty streak on empty workout list', () async {
        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: const Right([])),
        );

        final streak = await repo.getCurrentStreak();

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.isActive, false);
        expect(streak.lastWorkoutDate, isNull);
        expect(streak.totalWorkoutDays, 0);
      });

      test('returns empty streak when repository returns a failure', () async {
        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(
            workoutsResult: const Left(_TestNetworkFailure()),
          ),
        );

        final streak = await repo.getCurrentStreak();

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.isActive, false);
        expect(streak.totalWorkoutDays, 0);
      });

      test('uses endTime when available for date calculation', () async {
        final now = DateTime.now();
        // Workout has endTime different from createdAt
        final workout = Workout(
          id: const Uuid().v4(),
          name: 'Workout with endTime',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now,
          exercises: const [],
          status: WorkoutStatus.completed,
          endTime: now, // endTime is today
        );

        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: Right([workout])),
        );

        final streak = await repo.getCurrentStreak();

        // Should use endTime (today) → currentStreak = 1
        expect(streak.currentStreak, 1);
        expect(streak.isActive, true);
      });

      test('uses createdAt when endTime is null for date calculation', () async {
        final now = DateTime.now();
        // Completed workout without endTime (legacy data)
        final workout = Workout(
          id: const Uuid().v4(),
          name: 'Legacy Workout',
          createdAt: now,
          updatedAt: now,
          exercises: const [],
          status: WorkoutStatus.completed,
          // endTime is null
        );

        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: Right([workout])),
        );

        final streak = await repo.getCurrentStreak();

        // createdAt = today → currentStreak = 1
        expect(streak.currentStreak, 1);
      });

      test('handles only one completed workout correctly', () async {
        final now = DateTime.now();
        final workouts = [_completedWorkout(date: now)];

        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: Right(workouts)),
        );

        final streak = await repo.getCurrentStreak();

        expect(streak.currentStreak, 1);
        expect(streak.longestStreak, 1);
        expect(streak.isActive, true);
        expect(streak.totalWorkoutDays, 1);
      });
    });

    group('checkAndNotifyMilestone', () {
      test('completes without error for a milestone streak', () async {
        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: const Right([])),
        );

        // Should not throw even when milestone is reached
        await expectLater(
          repo.checkAndNotifyMilestone(7),
          completes,
        );
      });

      test('completes without error for a non-milestone streak', () async {
        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: const Right([])),
        );

        await expectLater(
          repo.checkAndNotifyMilestone(3),
          completes,
        );
      });

      test('completes without error for streak below first milestone', () async {
        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: const Right([])),
        );

        await expectLater(
          repo.checkAndNotifyMilestone(0),
          completes,
        );
      });

      test('completes without error at legendary streak threshold', () async {
        final repo = StreakRepositoryImpl(
          FakeWorkoutRepository(workoutsResult: const Right([])),
        );

        await expectLater(
          repo.checkAndNotifyMilestone(100),
          completes,
        );
      });
    });
  });

  group('StreakMilestone integration with StreakRepositoryImpl', () {
    test('getCurrentMilestone returns null for 0 streak', () {
      expect(StreakMilestone.getCurrentMilestone(0), isNull);
    });

    test('getCurrentMilestone returns weekWarrior at 7', () {
      expect(
        StreakMilestone.getCurrentMilestone(7),
        StreakMilestone.weekWarrior,
      );
    });

    test('getCurrentMilestone returns legendary at 100', () {
      expect(
        StreakMilestone.getCurrentMilestone(100),
        StreakMilestone.legendary,
      );
    });
  });
}
