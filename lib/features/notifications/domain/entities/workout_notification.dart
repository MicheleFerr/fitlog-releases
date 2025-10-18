/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/entities
/// 🎯 Feature: smart_notifications
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// WORKOUT NOTIFICATION ENTITY - Smart notifications for workouts
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_notification.freezed.dart';
part 'workout_notification.g.dart';

/// Notification type
enum NotificationType {
  workoutReminder,   // Reminder per workout del giorno
  recoveryAlert,     // Alert per giorni da recuperare
  streakMotivation,  // Motivazione per streak attiva
  restDayReminder,   // Reminder giorno di riposo
}

/// Notification priority
enum NotificationPriority {
  low,      // Non urgente, può essere ritardata
  medium,   // Normale priorità
  high,     // Alta priorità, da mostrare subito
}

/// Notification delivery time preference
enum NotificationTimePreference {
  morning,      // 7:00 - 9:00
  midday,       // 12:00 - 13:00
  afternoon,    // 15:00 - 17:00
  evening,      // 18:00 - 20:00
  custom,       // Orario personalizzato
}

/// Smart workout notification
@freezed
class WorkoutNotification with _$WorkoutNotification {
  const factory WorkoutNotification({
    required int id,
    required NotificationType type,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationPriority priority,
    String? routineId,
    String? workoutName,
    int? daysToRecover,
    bool? isDelivered,
    DateTime? deliveredAt,
    Map<String, dynamic>? payload,
  }) = _WorkoutNotification;

  factory WorkoutNotification.fromJson(Map<String, dynamic> json) =>
      _$WorkoutNotificationFromJson(json);
}

/// Extension for notification operations
extension WorkoutNotificationExtensions on WorkoutNotification {
  /// Check if notification is in the past
  bool get isPast => scheduledTime.isBefore(DateTime.now());

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledTime.year == now.year &&
        scheduledTime.month == now.month &&
        scheduledTime.day == now.day;
  }

  /// Check if notification should be shown now
  bool get shouldShowNow {
    final now = DateTime.now();
    final diff = scheduledTime.difference(now).inMinutes;
    return diff >= -5 && diff <= 5; // 5 minuti di tolleranza
  }

  /// Get channel ID based on priority
  String get channelId {
    switch (priority) {
      case NotificationPriority.low:
        return 'gymbro_low_priority';
      case NotificationPriority.medium:
        return 'gymbro_medium_priority';
      case NotificationPriority.high:
        return 'gymbro_high_priority';
    }
  }

  /// Get channel name based on priority
  String get channelName {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low Priority Notifications';
      case NotificationPriority.medium:
        return 'Workout Reminders';
      case NotificationPriority.high:
        return 'Important Alerts';
    }
  }

  /// Get icon for notification type
  String get icon {
    switch (type) {
      case NotificationType.workoutReminder:
        return '💪';
      case NotificationType.recoveryAlert:
        return '🔄';
      case NotificationType.streakMotivation:
        return '🔥';
      case NotificationType.restDayReminder:
        return '😴';
    }
  }

  /// Mark as delivered
  WorkoutNotification markAsDelivered() {
    return copyWith(
      isDelivered: true,
      deliveredAt: DateTime.now(),
    );
  }
}

/// Factory for creating notifications
class WorkoutNotificationFactory {
  /// Create workout reminder notification
  static WorkoutNotification createWorkoutReminder({
    required int id,
    required String workoutName,
    required DateTime scheduledTime,
    String? routineId,
  }) {
    return WorkoutNotification(
      id: id,
      type: NotificationType.workoutReminder,
      title: 'Workout Reminder',
      body: 'Time for your $workoutName workout! 💪',
      scheduledTime: scheduledTime,
      priority: NotificationPriority.medium,
      routineId: routineId,
      workoutName: workoutName,
      isDelivered: false,
    );
  }

  /// Create recovery alert notification
  static WorkoutNotification createRecoveryAlert({
    required int id,
    required int daysToRecover,
    required DateTime scheduledTime,
    String? routineId,
  }) {
    return WorkoutNotification(
      id: id,
      type: NotificationType.recoveryAlert,
      title: 'Recovery Needed',
      body: 'You have $daysToRecover skipped ${daysToRecover == 1 ? 'day' : 'days'} to recover! 🔄',
      scheduledTime: scheduledTime,
      priority: NotificationPriority.high,
      routineId: routineId,
      daysToRecover: daysToRecover,
      isDelivered: false,
    );
  }

  /// Create streak motivation notification
  static WorkoutNotification createStreakMotivation({
    required int id,
    required int currentStreak,
    required DateTime scheduledTime,
    String? routineId,
  }) {
    return WorkoutNotification(
      id: id,
      type: NotificationType.streakMotivation,
      title: 'Keep Your Streak Going!',
      body: '$currentStreak days streak! Don\'t break it now! 🔥',
      scheduledTime: scheduledTime,
      priority: NotificationPriority.low,
      routineId: routineId,
      isDelivered: false,
      payload: {'currentStreak': currentStreak.toString()},
    );
  }

  /// Create rest day reminder
  static WorkoutNotification createRestDayReminder({
    required int id,
    required DateTime scheduledTime,
    String? routineId,
  }) {
    return WorkoutNotification(
      id: id,
      type: NotificationType.restDayReminder,
      title: 'Rest Day',
      body: 'Today is your rest day. Recovery is just as important! 😴',
      scheduledTime: scheduledTime,
      priority: NotificationPriority.low,
      routineId: routineId,
      isDelivered: false,
    );
  }
}

/// Notification settings entity
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool enableWorkoutReminders,
    @Default(true) bool enableRecoveryAlerts,
    @Default(false) bool enableStreakMotivation,
    @Default(false) bool enableRestDayReminders,
    @Default(NotificationTimePreference.morning) NotificationTimePreference preferredTime,
    DateTime? customTime,
    @Default(true) bool enableSmartScheduling,
    @Default(false) bool doNotDisturbEnabled,
    DateTime? doNotDisturbStart,
    DateTime? doNotDisturbEnd,
    @Default(60) int reminderMinutesBefore,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}

/// Extension for NotificationSettings
extension NotificationSettingsExtensions on NotificationSettings {
  /// Get preferred notification time
  DateTime getPreferredTimeForDate(DateTime date) {
    switch (preferredTime) {
      case NotificationTimePreference.morning:
        return DateTime(date.year, date.month, date.day, 8, 0); // 8:00
      case NotificationTimePreference.midday:
        return DateTime(date.year, date.month, date.day, 12, 30); // 12:30
      case NotificationTimePreference.afternoon:
        return DateTime(date.year, date.month, date.day, 16, 0); // 16:00
      case NotificationTimePreference.evening:
        return DateTime(date.year, date.month, date.day, 19, 0); // 19:00
      case NotificationTimePreference.custom:
        if (customTime != null) {
          return DateTime(
            date.year,
            date.month,
            date.day,
            customTime!.hour,
            customTime!.minute,
          );
        }
        return DateTime(date.year, date.month, date.day, 8, 0); // Default
    }
  }

  /// Check if time is in Do Not Disturb window
  bool isInDoNotDisturbWindow(DateTime time) {
    if (!doNotDisturbEnabled ||
        doNotDisturbStart == null ||
        doNotDisturbEnd == null) {
      return false;
    }

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = doNotDisturbStart!.hour * 60 + doNotDisturbStart!.minute;
    final endMinutes = doNotDisturbEnd!.hour * 60 + doNotDisturbEnd!.minute;

    // Handle overnight DND (e.g., 22:00 - 7:00)
    if (startMinutes > endMinutes) {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  /// Adjust time to avoid Do Not Disturb
  DateTime adjustForDoNotDisturb(DateTime scheduledTime) {
    if (!isInDoNotDisturbWindow(scheduledTime)) {
      return scheduledTime;
    }

    // Se è in DND, sposta all'orario di fine DND
    if (doNotDisturbEnd != null) {
      return DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        doNotDisturbEnd!.hour,
        doNotDisturbEnd!.minute,
      );
    }

    return scheduledTime;
  }
}
