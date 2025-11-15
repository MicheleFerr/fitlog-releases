import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/workout_streak.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
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
final currentStreakProvider = FutureProvider<WorkoutStreak>((ref) async {
  final repository = ref.watch(streakRepositoryProvider);
  return repository.getCurrentStreak();
});
