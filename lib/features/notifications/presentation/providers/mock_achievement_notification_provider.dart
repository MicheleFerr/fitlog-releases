/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/providers
/// 🎯 Feature: Mock Achievement Notification Provider (TEST DATA)
/// 🔧 Type: Riverpod Provider
///
/// Provides mock achievement data for testing notifications without analytics integration.
/// Use this during development to test UI and notification flow.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock achievement notification service provider
final mockAchievementNotificationServiceProvider =
    Provider<MockAchievementNotificationService>((ref) {
  return MockAchievementNotificationService();
});

/// Mock achievement types for testing
enum MockAchievementType {
  personalRecord,
  workoutStreak,
  goalCompletion,
  milestone,
}

/// Mock achievement data model
class MockAchievement {
  final MockAchievementType type;
  final String title;
  final String description;
  final String? emoji;

  const MockAchievement({
    required this.type,
    required this.title,
    required this.description,
    this.emoji,
  });
}

/// Mock achievement notification service with realistic test data
class MockAchievementNotificationService {
  /// Mock Personal Record achievements
  static const List<MockAchievement> mockPRs = [
    MockAchievement(
      type: MockAchievementType.personalRecord,
      title: 'New PR: Bench Press',
      description: '100kg (+5kg)',
      emoji: '💪',
    ),
    MockAchievement(
      type: MockAchievementType.personalRecord,
      title: 'New PR: Squat',
      description: '140kg (+10kg)',
      emoji: '🦵',
    ),
    MockAchievement(
      type: MockAchievementType.personalRecord,
      title: 'New PR: Deadlift',
      description: '180kg (+15kg)',
      emoji: '🏋️',
    ),
    MockAchievement(
      type: MockAchievementType.personalRecord,
      title: 'New PR: Overhead Press',
      description: '60kg (+2.5kg)',
      emoji: '💪',
    ),
  ];

  /// Mock Workout Streak achievements
  static const List<MockAchievement> mockStreaks = [
    MockAchievement(
      type: MockAchievementType.workoutStreak,
      title: '7-day Workout Streak!',
      description: "Keep it up! You're on fire 🔥",
      emoji: '🔥',
    ),
    MockAchievement(
      type: MockAchievementType.workoutStreak,
      title: '30-day Workout Streak!',
      description: 'Incredible consistency! 💯',
      emoji: '⭐',
    ),
    MockAchievement(
      type: MockAchievementType.workoutStreak,
      title: '100-day Workout Streak!',
      description: 'Legend status unlocked! 👑',
      emoji: '👑',
    ),
  ];

  /// Mock Goal Completion achievements
  static const List<MockAchievement> mockGoals = [
    MockAchievement(
      type: MockAchievementType.goalCompletion,
      title: 'Monthly Volume Goal Reached!',
      description: '50,000kg total volume 🎯',
      emoji: '🎯',
    ),
    MockAchievement(
      type: MockAchievementType.goalCompletion,
      title: 'Weekly Workout Goal Completed!',
      description: '5 workouts this week ✅',
      emoji: '✅',
    ),
    MockAchievement(
      type: MockAchievementType.goalCompletion,
      title: 'Squat 3-Plate Goal!',
      description: '140kg squat achieved 🏆',
      emoji: '🏆',
    ),
  ];

  /// Mock Milestone achievements
  static const List<MockAchievement> mockMilestones = [
    MockAchievement(
      type: MockAchievementType.milestone,
      title: '50 Workouts Completed!',
      description: "You're building a solid habit 💪",
      emoji: '🎉',
    ),
    MockAchievement(
      type: MockAchievementType.milestone,
      title: '100 Workouts Completed!',
      description: 'Century club member! 🎊',
      emoji: '💯',
    ),
    MockAchievement(
      type: MockAchievementType.milestone,
      title: '1,000,000kg Total Volume!',
      description: "You've moved 1 million kg! 🚀",
      emoji: '🚀',
    ),
  ];

  /// Get all mock achievements
  List<MockAchievement> getAllMockAchievements() {
    return [
      ...mockPRs,
      ...mockStreaks,
      ...mockGoals,
      ...mockMilestones,
    ];
  }

  /// Get mock achievements by type
  List<MockAchievement> getMockAchievementsByType(MockAchievementType type) {
    switch (type) {
      case MockAchievementType.personalRecord:
        return mockPRs;
      case MockAchievementType.workoutStreak:
        return mockStreaks;
      case MockAchievementType.goalCompletion:
        return mockGoals;
      case MockAchievementType.milestone:
        return mockMilestones;
    }
  }

  /// Get random mock achievement for testing
  MockAchievement getRandomMockAchievement() {
    final allAchievements = getAllMockAchievements();
    return allAchievements[DateTime.now().millisecond % allAchievements.length];
  }

  /// Show achievement notification (mock implementation)
  Future<void> showAchievement({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    // Mock implementation - in real version this would trigger actual notification
    await Future.delayed(const Duration(milliseconds: 100));
    // TODO: Integrate with actual notification service
  }

  /// Notify PR achievement (mock)
  Future<void> notifyPRAchievement(String exerciseName, String newPR) async {
    await showAchievement(
      title: 'New PR: $exerciseName',
      description: newPR,
    );
  }

  /// Notify streak achievement (mock)
  Future<void> notifyStreakAchievement(int days) async {
    String title;
    String description;

    if (days == 7) {
      title = '7-day Workout Streak!';
      description = "Keep it up! You're on fire 🔥";
    } else if (days == 30) {
      title = '30-day Workout Streak!';
      description = 'Incredible consistency! 💯';
    } else if (days == 100) {
      title = '100-day Workout Streak!';
      description = 'Legend status unlocked! 👑';
    } else {
      title = '$days-day Workout Streak!';
      description = 'Keep the momentum going! 💪';
    }

    await showAchievement(
      title: title,
      description: description,
    );
  }

  /// Notify goal completion (mock)
  Future<void> notifyGoalCompletion(String goalName, String details) async {
    await showAchievement(
      title: goalName,
      description: details,
    );
  }

  /// Notify milestone achievement (mock)
  Future<void> notifyMilestone(int workoutCount) async {
    String title;
    String description;

    if (workoutCount == 50) {
      title = '50 Workouts Completed!';
      description = "You're building a solid habit 💪";
    } else if (workoutCount == 100) {
      title = '100 Workouts Completed!';
      description = 'Century club member! 🎊';
    } else if (workoutCount == 500) {
      title = '500 Workouts Completed!';
      description = 'Absolute dedication! 🌟';
    } else {
      title = '$workoutCount Workouts Completed!';
      description = 'Keep crushing it! 💪';
    }

    await showAchievement(
      title: title,
      description: description,
    );
  }

  /// Check for unlocked achievements (mock - returns random achievement)
  Future<MockAchievement?> checkAchievements() async {
    await Future.delayed(const Duration(milliseconds: 100));

    // 50% chance of returning a mock achievement
    if (DateTime.now().second % 2 == 0) {
      return getRandomMockAchievement();
    }

    return null;
  }

  /// Notify multiple PRs with batching (mock)
  Future<int> notifyMultiplePRs(
    List<String> exerciseNames, {
    required String workoutId,
  }) async {
    // Mock implementation - notify each PR
    for (final exercise in exerciseNames) {
      await notifyPRAchievement(
        exercise,
        'New record! Check workout details',
      );
    }

    return exerciseNames.length;
  }

  /// Queue streak achievement notification (mock)
  Future<void> queueStreakAchievement(
    int streakDays, {
    required String workoutId,
  }) async {
    await notifyStreakAchievement(streakDays);
  }

  /// Queue volume achievement notification (mock)
  Future<void> queueVolumeAchievement(
    double totalVolume, {
    required String workoutId,
  }) async {
    await notifyGoalCompletion(
      'Monthly Volume Goal Reached!',
      '${totalVolume.toStringAsFixed(0)}kg total volume 🎯',
    );
  }
}
