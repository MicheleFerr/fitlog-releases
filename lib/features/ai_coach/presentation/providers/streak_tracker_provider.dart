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

/// Streak Tracker State Notifier
///
/// Manages:
/// - Current streak calculation from workout history
/// - Longest streak tracking
/// - Milestone detection and celebration
/// - Streak status (active/at-risk/broken)
/// - Progress to next milestone
class StreakTrackerNotifier extends StateNotifier<AsyncValue<StreakData>> {
  StreakTrackerNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  final StreakRepository _repository;

  /// Initialize streak data
  ///
  /// In production, this would:
  /// 1. Fetch workout history from WorkoutRepository
  /// 2. Calculate streak from history
  /// 3. Load previous streak data from local storage
  Future<void> _initialize() async {
    try {
      // TODO: Replace with actual workout history from WorkoutRepository
      // final workoutDates = await _workoutRepository.getWorkoutDates();

      // For now, use mock data for demonstration
      final mockWorkoutDates = _getMockWorkoutDates();

      final streakData = _repository.calculateStreak(
        workoutDates: mockWorkoutDates,
        previousStreakData: null, // TODO: Load from storage
      );

      state = AsyncValue.data(streakData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Record new workout completion
  ///
  /// Updates streak calculation when user completes a workout
  Future<void> recordWorkoutCompleted(DateTime workoutDate) async {
    final currentData = state.value;
    if (currentData == null) return;

    try {
      // TODO: Fetch updated workout history from WorkoutRepository
      final mockWorkoutDates = [
        ..._getMockWorkoutDates(),
        workoutDate,
      ];

      final updatedStreak = _repository.calculateStreak(
        workoutDates: mockWorkoutDates,
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
    state = const AsyncValue.loading();
    await _initialize();
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

  /// Mock workout dates for demonstration
  ///
  /// TODO: Replace with actual workout history from WorkoutRepository
  List<DateTime> _getMockWorkoutDates() {
    final now = DateTime.now();

    // Simulate 5-day streak
    return [
      now, // Today
      now.subtract(const Duration(days: 1)), // Yesterday
      now.subtract(const Duration(days: 2)), // 2 days ago
      now.subtract(const Duration(days: 3)), // 3 days ago
      now.subtract(const Duration(days: 4)), // 4 days ago
    ];
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
    StateNotifierProvider<StreakTrackerNotifier, AsyncValue<StreakData>>((ref) {
  final repository = ref.watch(streakRepositoryProvider);
  return StreakTrackerNotifier(repository);
});

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
