/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/domain/entities
/// Feature: Local Notifications System
/// Type: Entity - Notification Type Enum
///
/// Defines all notification types for the retention system.
library;

/// Types of local notifications sent by the app.
///
/// Each type has specific trigger conditions, timing, and anti-spam rules.
enum NotificationType {
  /// Workout in progress but user left the app.
  /// Trigger: Timer active + app background >= 25 min + no set completed in 25 min
  /// Max: 1 per workout session
  workoutForgotten,

  /// User hasn't worked out in N days (3, 7, or 14).
  /// Trigger: Last completed workout >= N days ago
  /// Sequence: Day 3 -> Day 7 -> Day 14 -> STOP
  inactivity,

  /// New Personal Record detected.
  /// Trigger: PR detected by InsightsEngine after workout completion
  /// Delay: 15-30 min after workout (high value = faster)
  insightPr,

  /// Streak milestone reached (7, 14, 30 days).
  /// Trigger: Streak milestone reached
  /// Delay: Next morning 09:00 (low value = batched)
  insightStreak,

  /// Volume increase significant (>= 20% vs weekly average).
  /// Trigger: Volume +20% detected after workout
  /// Delay: Next morning 09:00 (low value = batched)
  insightVolume,
}

/// Extension methods for NotificationType
extension NotificationTypeX on NotificationType {
  /// Returns the notification channel ID for Android
  String get channelId {
    switch (this) {
      case NotificationType.workoutForgotten:
        return 'workout_reminder';
      case NotificationType.inactivity:
        return 'inactivity_reminder';
      case NotificationType.insightPr:
      case NotificationType.insightStreak:
      case NotificationType.insightVolume:
        return 'insights';
    }
  }

  /// Returns the notification channel name for Android
  String get channelName {
    switch (this) {
      case NotificationType.workoutForgotten:
        return 'Workout Reminders';
      case NotificationType.inactivity:
        return 'Inactivity Reminders';
      case NotificationType.insightPr:
      case NotificationType.insightStreak:
      case NotificationType.insightVolume:
        return 'Insights & Achievements';
    }
  }

  /// Returns the notification channel description for Android
  String get channelDescription {
    switch (this) {
      case NotificationType.workoutForgotten:
        return 'Reminders when you have an active workout in progress';
      case NotificationType.inactivity:
        return 'Gentle reminders when you haven\'t worked out in a while';
      case NotificationType.insightPr:
      case NotificationType.insightStreak:
      case NotificationType.insightVolume:
        return 'Notifications about your achievements and progress';
    }
  }

  /// Returns the deep link path for this notification type
  String get deepLinkPath {
    switch (this) {
      case NotificationType.workoutForgotten:
        return '/workout/active';
      case NotificationType.inactivity:
        return '/home';
      case NotificationType.insightPr:
      case NotificationType.insightStreak:
      case NotificationType.insightVolume:
        return '/analytics';
    }
  }

  /// Whether this is a high-value notification (should be sent faster)
  bool get isHighValue {
    switch (this) {
      case NotificationType.workoutForgotten:
      case NotificationType.insightPr:
        return true;
      case NotificationType.inactivity:
      case NotificationType.insightStreak:
      case NotificationType.insightVolume:
        return false;
    }
  }

  /// Max times this notification can be ignored before we stop sending
  int get maxIgnoreCount {
    switch (this) {
      case NotificationType.workoutForgotten:
        return 1; // Only 1 per session anyway
      case NotificationType.inactivity:
        return 3; // 3 -> 7 -> 14 -> stop
      case NotificationType.insightPr:
      case NotificationType.insightStreak:
      case NotificationType.insightVolume:
        return 5; // More tolerance for achievements
    }
  }
}
