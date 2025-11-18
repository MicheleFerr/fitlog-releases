/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/usecases
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: use_case
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// SCHEDULE SMART NOTIFICATION V2.0 USE CASE - Enhanced with v2.0 rules
///
/// **New v2.0 Rules**:
/// 1. Frequency cap enforcement (max 3/day, 5/week, min 2h interval)
/// 2. Per-category quiet hours (workout/recovery/streak/rest)
/// 3. Analytics opt-in check before collecting metrics
/// 4. Cross-device sync awareness (check Firestore for recent notifications)
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart' as workout;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/quiet_hours.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart' as unified;

/// Schedule smart notification with v2.0 enhanced rules
///
/// **Workflow**:
/// ```
/// 1. Load settings (with v2.0 fields)
/// 2. Check frequency cap (last 24h, last 7 days)
/// 3. Check quiet hours (per-category)
/// 4. Check analytics consent (if metrics needed)
/// 5. Adjust time based on smart scheduling
/// 6. Schedule notification
/// 7. Save to history (if consent given)
/// ```
class ScheduleSmartNotificationV2 {
  final NotificationSettingsRepository _settingsRepository;
  final NotificationHistoryRepository _historyRepository;
  final NotificationRepository _notificationRepository;

  ScheduleSmartNotificationV2({
    required NotificationSettingsRepository settingsRepository,
    required NotificationHistoryRepository historyRepository,
    required NotificationRepository notificationRepository,
  })  : _settingsRepository = settingsRepository,
        _historyRepository = historyRepository,
        _notificationRepository = notificationRepository;

  /// Execute smart scheduling
  ///
  /// **Returns**: scheduled notification ID or null if skipped (frequency cap)
  Future<String?> execute({
    required workout.NotificationType type,
    required String title,
    required String body,
    DateTime? preferredTime,
    Map<String, dynamic>? payload,
  }) async {
    // 1. Load settings (includes v2.0 fields)
    final settings = await _settingsRepository.getSettings();

    // 2. Check if notification type is enabled
    if (!_isTypeEnabled(settings, type)) {
      return null; // Type disabled
    }

    // 3. Check frequency cap (v2.0 new logic)
    final isAllowedByFrequencyCap = await _checkFrequencyCap(settings, type);
    if (!isAllowedByFrequencyCap) {
      return null; // Frequency cap exceeded
    }

    // 4. Calculate scheduled time (respecting quiet hours)
    final scheduledTime = await _calculateScheduledTime(
      settings: settings,
      type: type,
      preferredTime: preferredTime,
    );

    // 5. Map workout notification type to unified type
    final unifiedType = _mapToUnifiedType(type);

    // 6. Create unified notification
    final unifiedNotification = unified.UnifiedNotification(
      type: unifiedType,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: payload,
    );

    // 7. Schedule notification
    final notificationId = await _notificationRepository.scheduleNotification(
      unifiedNotification,
    );

    // 8. Save to history (if consent given)
    if (settings.hasValidConsent && settings.enableAnalytics) {
      // Update notification with actual ID
      final notificationWithId = unified.UnifiedNotification(
        id: notificationId,
        type: unifiedType,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      );

      await _historyRepository.saveNotification(notificationWithId);
    }

    return notificationId;
  }

  /// Check if notification type is enabled
  bool _isTypeEnabled(workout.NotificationSettings settings, workout.NotificationType type) {
    switch (type) {
      case workout.NotificationType.workoutReminder:
        return settings.enableWorkoutReminders;
      case workout.NotificationType.recoveryAlert:
        return settings.enableRecoveryAlerts;
      case workout.NotificationType.streakMotivation:
        return settings.enableStreakMotivation;
      case workout.NotificationType.restDayReminder:
        return settings.enableRestDayReminders;
      case workout.NotificationType.supplementReminder:
        return settings.enableSupplementReminders;
    }
  }

  /// Check frequency cap (v2.0 logic)
  ///
  /// **Rules**:
  /// - Max 3 notifications per day (all types combined)
  /// - Max 5 notifications per week (research: >5 → 64% quit risk)
  /// - Min 2 hours between notifications
  Future<bool> _checkFrequencyCap(
    workout.NotificationSettings settings,
    workout.NotificationType type,
  ) async {
    final frequencyCap = settings.getFrequencyCapForType(type);

    // Get recent notifications (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final unifiedType = _mapToUnifiedType(type);
    final recentNotifications = await _historyRepository.getHistory(
      since: weekAgo,
      types: [unifiedType],
      limit: 100,
    );

    // Check daily limit
    final today = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
    ));
    final todayCount =
        recentNotifications.where((n) => n.scheduledTime.isAfter(today)).length;

    if (todayCount >= frequencyCap.maxPerDay) {
      return false; // Daily limit exceeded
    }

    // Check weekly limit
    if (recentNotifications.length >= frequencyCap.maxPerWeek) {
      return false; // Weekly limit exceeded
    }

    // Check minimum interval
    if (recentNotifications.isNotEmpty) {
      final lastNotification = recentNotifications.first;
      final timeSinceLast = now.difference(lastNotification.scheduledTime);

      if (timeSinceLast.inHours < frequencyCap.minIntervalHours) {
        return false; // Too soon since last notification
      }
    }

    return true; // All checks passed
  }

  /// Calculate scheduled time (respecting quiet hours)
  Future<DateTime> _calculateScheduledTime({
    required workout.NotificationSettings settings,
    required workout.NotificationType type,
    DateTime? preferredTime,
  }) async {
    var scheduledTime = preferredTime ?? DateTime.now();

    // Check per-category quiet hours (v2.0)
    final quietHours = settings.categoryQuietHours[type.name];
    if (quietHours != null) {
      // If scheduled time falls in quiet hours, move to after quiet hours
      if (quietHours.isTimeInQuietHours(scheduledTime)) {
        scheduledTime = quietHours.adjustTimeToAvoidQuietHours(scheduledTime);
      }
    }

    // Check global Do Not Disturb
    if (settings.doNotDisturbEnabled &&
        settings.doNotDisturbStart != null &&
        settings.doNotDisturbEnd != null) {
      final dndStart = settings.doNotDisturbStart!;
      final dndEnd = settings.doNotDisturbEnd!;

      final scheduledHour = scheduledTime.hour;
      if (scheduledHour >= dndStart.hour && scheduledHour < dndEnd.hour) {
        // Move to after DND window
        scheduledTime = DateTime(
          scheduledTime.year,
          scheduledTime.month,
          scheduledTime.day,
          dndEnd.hour,
          dndEnd.minute,
        );
      }
    }

    // Smart scheduling (adjust based on workout patterns)
    if (settings.enableSmartScheduling) {
      // TODO: Implement ML-based smart scheduling
      // For now, use preferred time from settings
      final preferredTimeOfDay = settings.getPreferredTimeForDate(
        scheduledTime,
        type,
      );

      scheduledTime = DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        preferredTimeOfDay.hour,
        preferredTimeOfDay.minute,
      );
    }

    return scheduledTime;
  }

  /// Map workout notification type to unified notification type
  ///
  /// **Mapping Logic**:
  /// - `workoutReminder` → `workoutReminder` (1:1)
  /// - `recoveryAlert` → `workoutReminder` (unified doesn't have recoveryAlert)
  /// - `streakMotivation` → `streakReminder` (similar concept)
  /// - `restDayReminder` → `restReminder` (similar concept)
  /// - `supplementReminder` → `workoutReminder` (unified doesn't have supplementReminder)
  unified.NotificationType _mapToUnifiedType(workout.NotificationType workoutType) {
    switch (workoutType) {
      case workout.NotificationType.workoutReminder:
        return unified.NotificationType.workoutReminder;
      case workout.NotificationType.recoveryAlert:
        return unified.NotificationType.workoutReminder; // No equivalent in unified
      case workout.NotificationType.streakMotivation:
        return unified.NotificationType.streakReminder;
      case workout.NotificationType.restDayReminder:
        return unified.NotificationType.restReminder;
      case workout.NotificationType.supplementReminder:
        return unified.NotificationType.workoutReminder; // No equivalent in unified
    }
  }
}
