/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/domain/entities
/// Feature: Local Notifications System
/// Type: Entity - Notification Configuration
///
/// Constants and configuration for the notification system.
/// Based on validated research from industry best practices.
library;

import 'package:flutter/material.dart';

/// Configuration constants for the notification system.
///
/// These values are based on research from:
/// - Duolingo notification strategy
/// - Fitness app retention best practices
/// - iOS local notification limitations
abstract final class NotificationConfig {
  // ============================================
  // GLOBAL ANTI-SPAM RULES
  // ============================================

  /// Minimum time between any two notifications (any type)
  /// Source: Best practice to avoid notification fatigue
  static const Duration globalCooldown = Duration(hours: 24);

  /// Maximum notifications per week (all types combined)
  /// Source: MobileLoud research - 2-5/week optimal
  static const int maxNotificationsPerWeek = 3;

  /// Quiet hours start (no notifications after this time)
  static const TimeOfDay quietHoursStart = TimeOfDay(hour: 22, minute: 0);

  /// Quiet hours end (notifications resume after this time)
  static const TimeOfDay quietHoursEnd = TimeOfDay(hour: 8, minute: 0);

  /// Default time to schedule notifications during quiet hours
  static const TimeOfDay defaultScheduleTime = TimeOfDay(hour: 9, minute: 0);

  // ============================================
  // iOS LIMITATIONS
  // ============================================

  /// Maximum scheduled notifications on iOS (actual limit is 64)
  /// We use 10 to be safe and refresh on app open
  /// Source: flutter_local_notifications GitHub Issue #200
  static const int maxScheduledNotifications = 10;

  // ============================================
  // WORKOUT FORGOTTEN
  // ============================================

  /// Time after app goes to background to send workout reminder
  /// Source: Abandoned cart research - 30-60 min optimal, we use 25
  static const Duration workoutForgottenDelay = Duration(minutes: 25);

  /// Minimum time since last set completion to consider workout "forgotten"
  static const Duration noSetActivityThreshold = Duration(minutes: 25);

  // ============================================
  // INACTIVITY SEQUENCE
  // ============================================

  /// Days for first inactivity reminder
  static const int inactivityDay1 = 3;

  /// Days for second inactivity reminder (if first ignored)
  static const int inactivityDay2 = 7;

  /// Days for third/final inactivity reminder (if second ignored)
  static const int inactivityDay3 = 14;

  /// All inactivity reminder days in sequence
  static const List<int> inactivitySequence = [
    inactivityDay1,
    inactivityDay2,
    inactivityDay3,
  ];

  // ============================================
  // INSIGHT NOTIFICATIONS
  // ============================================

  /// Delay for PR notification (high value = faster)
  /// Source: Trophy gamification research - immediate feedback better
  static const Duration prNotificationDelay = Duration(minutes: 20);

  /// Delay for streak/volume notifications (low value = batched to morning)
  /// These are scheduled for next day at defaultScheduleTime
  static const bool batchLowValueInsights = true;

  /// Streak milestones that trigger notifications
  static const List<int> streakMilestones = [7, 14, 30, 60, 90, 180, 365];

  /// Minimum volume increase percentage to trigger notification
  static const double volumeIncreaseThreshold = 0.20; // 20%

  // ============================================
  // MESSAGE ROTATION
  // ============================================

  /// Minimum time before showing the same message again
  /// Source: Duolingo - uses "forgetting curve" for message repetition
  static const Duration messageRotationCooldown = Duration(days: 7);

  // ============================================
  // STOP-AFTER-IGNORE
  // ============================================

  /// Stop sending after N consecutive ignores (per type)
  /// Source: Duolingo - protects the push channel
  static const int defaultMaxIgnores = 3;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Check if current time is within quiet hours
  static bool isQuietHours(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final currentMinutes = hour * 60 + minute;

    final startMinutes =
        quietHoursStart.hour * 60 + quietHoursStart.minute; // 22:00 = 1320
    final endMinutes =
        quietHoursEnd.hour * 60 + quietHoursEnd.minute; // 08:00 = 480

    // Quiet hours span midnight (22:00 - 08:00)
    // So we're in quiet hours if:
    // - After 22:00 (currentMinutes >= 1320) OR
    // - Before 08:00 (currentMinutes < 480)
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  /// Get the next available notification time (respecting quiet hours)
  static DateTime getNextAvailableTime(DateTime from) {
    if (!isQuietHours(from)) {
      return from;
    }

    // If we're in quiet hours, schedule for tomorrow at defaultScheduleTime
    // Unless we're already past midnight, then schedule for today at defaultScheduleTime
    final hour = from.hour;

    if (hour >= quietHoursStart.hour) {
      // After 22:00 - schedule for tomorrow 09:00
      return DateTime(
        from.year,
        from.month,
        from.day + 1,
        defaultScheduleTime.hour,
        defaultScheduleTime.minute,
      );
    } else {
      // Before 08:00 - schedule for today 09:00
      return DateTime(
        from.year,
        from.month,
        from.day,
        defaultScheduleTime.hour,
        defaultScheduleTime.minute,
      );
    }
  }

  /// Get next inactivity day in sequence, or null if sequence exhausted
  static int? getNextInactivityDay(int? currentDay) {
    if (currentDay == null) return inactivityDay1;

    final currentIndex = inactivitySequence.indexOf(currentDay);
    if (currentIndex == -1 || currentIndex >= inactivitySequence.length - 1) {
      return null; // Sequence exhausted
    }

    return inactivitySequence[currentIndex + 1];
  }

  /// Check if a streak count is a milestone
  static bool isStreakMilestone(int streakDays) {
    return streakMilestones.contains(streakDays);
  }
}
