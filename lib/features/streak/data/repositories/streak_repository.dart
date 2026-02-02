import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/streak_milestone.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';

abstract class StreakRepository {
  Future<WorkoutStreak> getCurrentStreak();
  Future<void> checkAndNotifyMilestone(int newStreak);
}

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._workoutRepository);
  final WorkoutRepository _workoutRepository;

  @override
  Future<WorkoutStreak> getCurrentStreak() async {
    final workoutsEither = await _workoutRepository.getWorkouts();

    return workoutsEither.fold(
      (failure) {
        // If failed to get workouts, return empty streak
        return const WorkoutStreak(
          currentStreak: 0,
          longestStreak: 0,
          isActive: false,
          lastWorkoutDate: null,
          totalWorkoutDays: 0,
        );
      },
      (workouts) {
        final workoutDates = workouts
            .where((w) => w.isCompleted)
            .map((w) => w.endTime ?? w.createdAt)
            .toList();

        return WorkoutStreak.fromWorkoutDates(workoutDates, DateTime.now());
      },
    );
  }

  @override
  Future<void> checkAndNotifyMilestone(int newStreak) async {
    final milestone = StreakMilestone.getCurrentMilestone(newStreak);
    if (milestone != null) {
      // Notification logic will be added in Task 5
      // For now, just a stub
    }
  }
}
