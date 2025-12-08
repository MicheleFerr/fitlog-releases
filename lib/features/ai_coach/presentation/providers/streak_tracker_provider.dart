/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Streak Tracker Provider - Manages workout consistency streaks
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/streak_calculator.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/streak_data.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';

/// Streak Tracker State Notifier
///
/// Manages:
/// - Current streak calculation from workout history
/// - Longest streak tracking
/// - Milestone detection and celebration
/// - Streak status (active/at-risk/broken)
/// - Progress to next milestone
class StreakTrackerNotifier extends AsyncNotifier<StreakData> {
  late final StreakRepository _repository;

  @override
  Future<StreakData> build() async {
    _repository = ref.read(streakRepositoryProvider);
    return await _initialize();
  }

  /// Initialize streak data
  ///
  /// Fetches real workout history from WorkoutRepository
  /// and calculates streak based on actual completed workouts
  Future<StreakData> _initialize() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      // No user authenticated, return empty streak
      return const StreakData(
        currentStreak: 0,
        longestStreak: 0,
        lastWorkoutDate: null,
        workedOutToday: false,
        milestonesAchieved: [],
        totalWorkouts: 0,
      );
    }

    // Fetch real workout dates from repository
    final workoutDates = await _getWorkoutDates(userId);

    final streakData = _repository.calculateStreak(
      workoutDates: workoutDates,
      previousStreakData: null, // TODO: Load from storage
    );

    return streakData;
  }

  /// Fetch workout dates from WorkoutRepository
  Future<List<DateTime>> _getWorkoutDates(String userId) async {
    try {
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final workoutsResult = await workoutRepository.getWorkouts();

      return workoutsResult.fold(
        (failure) {
          // On error, return empty list (will result in 0 streak)
          return <DateTime>[];
        },
        (workouts) {
          // Extract dates from completed workouts
          return workouts
              .where((workout) => workout.endTime != null) // Only completed workouts
              .map((workout) => workout.endTime!)
              .toList()
            ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
        },
      );
    } catch (e) {
      // On error, return empty list
      return <DateTime>[];
    }
  }

  /// Record new workout completion
  ///
  /// Updates streak calculation when user completes a workout
  Future<void> recordWorkoutCompleted(DateTime workoutDate) async {
    final currentData = state.value;
    if (currentData == null) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      // Fetch updated workout history from WorkoutRepository
      final workoutDates = await _getWorkoutDates(userId);

      final updatedStreak = _repository.calculateStreak(
        workoutDates: workoutDates,
        previousStreakData: currentData,
      );

      // Check if new milestone achieved
      final newMilestoneAchieved = _repository.checkNewMilestoneAchieved(
        currentStreak: updatedStreak,
        previousStreak: currentData,
      );

      if (newMilestoneAchieved) {
        // TODO: Trigger celebration animation/notification
        // TODO: Save achievement to AchievementRepository
      }

      state = AsyncValue.data(updatedStreak);

      // TODO: Save to local storage for persistence
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh streak data (e.g., on app open)
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Get motivational message for current streak
  String getMotivationalMessage() {
    final streakData = state.value;
    if (streakData == null) return 'streakMessageNone';

    return _repository.getStreakMessage(streakData);
  }

  /// Get progress to next milestone (0.0 - 1.0)
  double getProgressToNextMilestone() {
    final streakData = state.value;
    if (streakData == null) return 0.0;

    return _repository.calculateProgressToNextMilestone(streakData);
  }
}

/// Provider: Streak Repository
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository();
});

/// Provider: Streak Tracker
///
/// Manages workout consistency streak state
final streakTrackerProvider =
    AsyncNotifierProvider<StreakTrackerNotifier, StreakData>(
  StreakTrackerNotifier.new,
);

/// Provider: Current Streak Count
///
/// Convenience provider for accessing just the current streak number
final currentStreakProvider = Provider<int>((ref) {
  final streakAsync = ref.watch(streakTrackerProvider);
  return streakAsync.value?.currentStreak ?? 0;
});

/// Provider: Streak Status
///
/// Convenience provider for accessing streak status
final streakStatusProvider = Provider<StreakStatus>((ref) {
  final streakAsync = ref.watch(streakTrackerProvider);
  return streakAsync.value?.status ?? StreakStatus.none;
});

/// Provider: Is Personal Record
///
/// Convenience provider for checking if current streak is a PR
final isPersonalRecordProvider = Provider<bool>((ref) {
  final streakAsync = ref.watch(streakTrackerProvider);
  return streakAsync.value?.isPersonalRecord ?? false;
});
