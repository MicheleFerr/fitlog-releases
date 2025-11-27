import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/consistency_score.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/streak/domain/services/consistency_score_calculator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';

/// Provider for StreakRepository
///
/// Creates StreakRepositoryImpl with WorkoutRepository dependency
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  return StreakRepositoryImpl(workoutRepository);
});

/// Provider for current workout streak
///
/// Fetches current streak data from repository
/// Auto-invalidates when dependencies change
final currentStreakProvider = FutureProvider.autoDispose<WorkoutStreak>((ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  return repository.getCurrentStreak();
});

/// Provider for consistency score calculator
final consistencyScoreCalculatorProvider = Provider<ConsistencyScoreCalculator>((ref) {
  return ConsistencyScoreCalculator();
});

/// Provider for consistency score
///
/// Calculates workout adherence quality from last 30 days of workout data
/// Updates automatically when workouts or streak changes
final consistencyScoreProvider = FutureProvider.autoDispose<ConsistencyScore>((ref) async {
  // Get dependencies
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  final calculator = ref.watch(consistencyScoreCalculatorProvider);

  // Get streak data
  final streak = await ref.watch(currentStreakProvider.future);

  // Get last 30 days of completed workouts
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final workoutsEither = await workoutRepository.getWorkouts();

  return workoutsEither.fold(
    (failure) {
      // If failed to get workouts, return empty score
      return ConsistencyScore.empty();
    },
    (allWorkouts) {
      // Filter to last 30 days of completed workouts
      final recentWorkouts = allWorkouts
          .where((w) => w.isCompleted)
          .where((w) {
            final workoutDate = w.endTime ?? w.createdAt;
            return workoutDate.isAfter(thirtyDaysAgo);
          })
          .toList();

      // If no workouts in last 30 days, return empty
      if (recentWorkouts.isEmpty) {
        return ConsistencyScore.empty();
      }

      // Calculate score using calculator service
      return calculator.calculateScore(
        workouts: recentWorkouts,
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
      );
    },
  );
});
