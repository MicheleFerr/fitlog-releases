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
import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/quiet_hours.dart';

part 'workout_notification.freezed.dart';
part 'workout_notification.g.dart';

/// Notification type
enum NotificationType {
  workoutReminder,   // Reminder per workout del giorno
  recoveryAlert,     // Alert per giorni da recuperare
  streakMotivation,  // Motivazione per streak attiva
  restDayReminder,   // Reminder giorno di riposo
  supplementReminder, // Reminder per assunzione integratori
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
      case NotificationType.supplementReminder:
        return '💊';
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

/// Notification settings entity v2.0
///
/// **Version History**:
/// - v1.0: Initial implementation (11 fields)
/// - v2.0: Added GDPR compliance, per-category controls, frequency caps (22 fields total)
///
/// **Migration**: v1.0 → v2.0 handled by `MigrateNotificationSettings` use case
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    // === v1.0 Fields (Backward Compatible) ===
    @Default(true) bool enableWorkoutReminders,
    @Default(true) bool enableRecoveryAlerts,
    @Default(false) bool enableStreakMotivation,
    @Default(false) bool enableRestDayReminders,
    @Default(false) bool enableSupplementReminders,
    // Achievement notifications (v2.0 - Priority 2)
    @Default(false) bool enablePRNotifications,
    @Default(false) bool enableStreakAchievements,
    @Default(false) bool enableGoalCompletions,
    @Default(false) bool enableMilestones,
    @Default(NotificationTimePreference.morning)
    NotificationTimePreference preferredTime,
    DateTime? customTime,
    @Default(true) bool enableSmartScheduling,
    @Default(false) bool doNotDisturbEnabled,
    DateTime? doNotDisturbStart,
    DateTime? doNotDisturbEnd,
    @Default(60) int reminderMinutesBefore,

    // === v2.0 New Fields ===

    /// Custom time per notification type (e.g., workout reminders at 09:00, recovery at 18:00)
    /// Key: NotificationType.name (string), Value: DateTime (time component only)
    @Default({}) Map<String, DateTime> customTimePerType,

    /// Per-category quiet hours (e.g., workout reminders quiet 22:00-08:00)
    /// Key: NotificationType.name (string), Value: QuietHours configuration
    @Default({}) Map<String, QuietHours> categoryQuietHours,

    /// Global frequency cap preferences (research-backed: 3/day, 5/week)
    FrequencyCap? frequencyCapPreferences,

    /// Per-category frequency caps (override global)
    /// Key: NotificationType.name (string), Value: FrequencyCap configuration
    @Default({}) Map<String, FrequencyCap> categoryFrequencyCaps,

    /// GDPR Article 7.1: Timestamp when user gave explicit consent
    /// NULL = grandfathered user (assumed implicit consent)
    DateTime? consentTimestamp,

    /// Version of consent agreement user agreed to (e.g., '1.0', '1.1', '2.0')
    /// Increment when consent terms change (requires re-consent)
    @Default('1.0') String consentVersion,

    /// User opted in to analytics data collection
    /// Default: false (GDPR requires opt-in, not opt-out)
    @Default(false) bool enableAnalytics,

    /// GDPR Article 5.1.e: Data retention period (in days)
    /// Default: 90 days (industry standard for notification history)
    /// Options: 30, 60, 90, 180, 365, or 9999 ('forever')
    @Default(90) int dataRetentionDays,

    /// Cross-device sync: Last synced timestamp (Firestore server timestamp)
    /// NULL = never synced
    DateTime? lastSyncedAt,

    /// Cross-device sync: Device ID that last modified settings
    /// Format: '{platform}_{uuid}' (e.g., 'ios_abc123', 'android_def456')
    String? deviceId,

    /// Schema version for migrations (1 = v1.0, 2 = v2.0)
    /// Used to detect when migration is needed
    @Default(2) int settingsVersion,

    /// Migration metadata: Source system ('v1_sharedprefs', 'firestore', 'default')
    /// NULL = fresh v2.0 install
    String? migrationSource,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  /// Factory: Create default v2.0 settings
  factory NotificationSettings.defaults() => NotificationSettings(
        enableWorkoutReminders: true,
        enableRecoveryAlerts: true,
        enableStreakMotivation: false,
        enableRestDayReminders: false,
        enableSupplementReminders: false,
        preferredTime: NotificationTimePreference.morning,
        enableSmartScheduling: true,
        doNotDisturbEnabled: false,
        reminderMinutesBefore: 60,
        frequencyCapPreferences: const FrequencyCap(
          maxPerDay: 3,
          maxPerWeek: 5, // Research-backed optimal
          minIntervalHours: 2,
        ),
        consentTimestamp: null, // NULL = grandfathered
        consentVersion: '1.0',
        enableAnalytics: false,
        dataRetentionDays: 90,
        settingsVersion: 2,
        migrationSource: 'default',
      );
}

/// Extension for NotificationSettings v2.0
extension NotificationSettingsExtensions on NotificationSettings {
  // === v1.0 Methods (Kept for Backward Compatibility) ===

  /// Get preferred notification time for a specific date
  /// v2.0: Now checks customTimePerType first
  DateTime getPreferredTimeForDate(DateTime date, [NotificationType? type]) {
    // v2.0: Check if custom time set for specific type
    if (type != null && customTimePerType.containsKey(type.name)) {
      final customTimeForType = customTimePerType[type.name]!;
      return DateTime(
        date.year,
        date.month,
        date.day,
        customTimeForType.hour,
        customTimeForType.minute,
      );
    }

    // v1.0 fallback: Use global preferredTime
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
  /// v2.0: Now checks categoryQuietHours first
  bool isInDoNotDisturbWindow(DateTime time, [NotificationType? type]) {
    // v2.0: Check category-specific quiet hours first
    if (type != null && categoryQuietHours.containsKey(type.name)) {
      final categoryQuiet = categoryQuietHours[type.name]!;
      return categoryQuiet.isTimeInQuietHours(time);
    }

    // v1.0 fallback: Use global DND
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
  /// v2.0: Now uses categoryQuietHours first
  DateTime adjustForDoNotDisturb(DateTime scheduledTime, [NotificationType? type]) {
    // v2.0: Check category-specific quiet hours first
    if (type != null && categoryQuietHours.containsKey(type.name)) {
      final categoryQuiet = categoryQuietHours[type.name]!;
      return categoryQuiet.adjustTimeToAvoidQuietHours(scheduledTime);
    }

    // v1.0 fallback: Use global DND
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

  // === v2.0 New Methods ===

  /// Check if user has given valid GDPR consent
  bool get hasValidConsent => consentTimestamp != null;

  /// Check if settings are out of sync (local vs remote)
  bool isOutOfSync(DateTime? remoteLastSyncedAt) {
    if (lastSyncedAt == null || remoteLastSyncedAt == null) {
      return true; // Need initial sync
    }
    return lastSyncedAt!.isBefore(remoteLastSyncedAt);
  }

  /// Get frequency cap for notification type (category-specific or global)
  FrequencyCap getFrequencyCapForType(NotificationType type) {
    // Check category-specific cap first
    if (categoryFrequencyCaps.containsKey(type.name)) {
      return categoryFrequencyCaps[type.name]!;
    }

    // Fallback to global cap or default
    return frequencyCapPreferences ?? const FrequencyCap();
  }

  /// Check if notification type is enabled (backward compatible)
  bool isNotificationTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
        return enableWorkoutReminders;
      case NotificationType.recoveryAlert:
        return enableRecoveryAlerts;
      case NotificationType.streakMotivation:
        return enableStreakMotivation;
      case NotificationType.restDayReminder:
        return enableRestDayReminders;
      case NotificationType.supplementReminder:
        return enableSupplementReminders;
    }
  }

  /// Check if analytics collection is enabled (GDPR-compliant)
  bool get canCollectAnalytics => hasValidConsent && enableAnalytics;

  /// Get data retention cutoff date (notifications older than this should be deleted)
  DateTime getDataRetentionCutoffDate() {
    final now = DateTime.now();
    if (dataRetentionDays == 9999) {
      // 'Forever' = keep 10 years worth
      return now.subtract(const Duration(days: 365 * 10));
    }
    return now.subtract(Duration(days: dataRetentionDays));
  }

  /// Check if migration from v1.0 is needed
  bool get needsMigration => settingsVersion < 2;

  /// Check if frequency cap exceeds research-backed limit (>5/week)
  bool get exceedsResearchLimit {
    final globalCap = frequencyCapPreferences;
    if (globalCap != null && globalCap.exceedsResearchLimit) {
      return true;
    }

    // Check category-specific caps
    return categoryFrequencyCaps.values.any((cap) => cap.exceedsResearchLimit);
  }
}
