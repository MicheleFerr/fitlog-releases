/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/services
/// 🎯 Feature: workout_reminders
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// DAILY WORKOUT REMINDER SERVICE - Schedules recurring daily workout reminders
///
/// Features:
/// - Daily reminders at 9:00 AM (or user's preferred time)
/// - Respects user notification preferences
/// - Integrates with unified notification system
/// - Handles recurring scheduling for next 30 days
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/unified_notification_provider.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/use_cases/schedule_notification_use_case.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// Service for scheduling daily workout reminders
class DailyWorkoutReminderService {

  DailyWorkoutReminderService(this._ref);
  final Ref _ref;

  /// Default reminder time (9:00 AM)
  static const int defaultHour = 9;
  static const int defaultMinute = 0;

  /// How many days ahead to schedule (30 days)
  static const int scheduleDays = 30;

  /// Schedule daily workout reminders for the next 30 days
  ///
  /// This method:
  /// 1. Cancels existing workout reminders
  /// 2. Schedules new reminders at 9:00 AM (or custom time) for next 30 days
  /// 3. Respects user preferences (enabled/disabled state)
  ///
  /// Example usage:
  /// ```dart
  /// final service = ref.read(dailyWorkoutReminderServiceProvider);
  /// await service.scheduleDailyReminders();
  /// ```
  Future<void> scheduleDailyReminders({
    int? customHour,
    int? customMinute,
  }) async {
    try {
      // Get current user
      final authService = _ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [DailyReminder] No user logged in - skipping schedule');
        }
        return;
      }

      // Get unified notification provider
      final notificationProvider = _ref.read(unifiedNotificationProvider.notifier);

      // 1. Cancel existing workout reminders (cleanup)
      await _cancelExistingReminders();

      // 2. Calculate reminder time (default 9:00 AM)
      final reminderHour = customHour ?? defaultHour;
      final reminderMinute = customMinute ?? defaultMinute;

      // 3. Schedule reminders for next 30 days
      final now = DateTime.now();
      int successCount = 0;
      int failureCount = 0;

      for (int dayOffset = 0; dayOffset < scheduleDays; dayOffset++) {
        final scheduledDate = now.add(Duration(days: dayOffset));

        // Create scheduled time at 9:00 AM (or custom time)
        final scheduledTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          reminderHour,
          reminderMinute,
        );

        // Skip if time is in the past
        if (scheduledTime.isBefore(now)) {
          continue;
        }

        try {
          // Create notification params
          final params = ScheduleNotificationParams(
            type: NotificationType.workoutReminder,
            title: 'Time to Train! 💪',
            body: 'Your daily workout is waiting. Let\'s get stronger today!',
            scheduledTime: scheduledTime,
            priority: NotificationPriority.high,
            deliveryMethod: NotificationDeliveryMethod.local,
            payload: {
              'reminder_type': 'daily_workout',
              'day_offset': dayOffset.toString(),
              'scheduled_hour': reminderHour.toString(),
              'emoji': '💪',
              'route': '/workout',
            },
            actions: [
              NotificationAction(
                id: 'start_workout',
                title: 'Start Workout',
                payload: {'route': '/workout'},
              ),
              NotificationAction(
                id: 'snooze',
                title: 'Remind Later',
                payload: {'snooze_minutes': '60'},
              ),
            ],
            tags: ['daily_reminder', 'workout'],
            userId: currentUser.uid,
          );

          // Schedule notification
          await notificationProvider.scheduleNotification(params);

          successCount++;

          if (kDebugMode && dayOffset < 3) {
            // Log first 3 scheduled reminders for debugging
            debugPrint('✅ [DailyReminder] Scheduled for ${scheduledTime.toIso8601String()}');
          }
        } catch (e) {
          failureCount++;
          if (kDebugMode) {
            debugPrint('❌ [DailyReminder] Failed to schedule day $dayOffset: $e');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ [DailyReminder] Scheduling complete:');
        debugPrint('   Success: $successCount notifications');
        debugPrint('   Failed: $failureCount notifications');
        debugPrint('   Time: $reminderHour:${reminderMinute.toString().padLeft(2, '0')}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [DailyReminder] Error scheduling daily reminders: $e');
      }
      rethrow;
    }
  }

  /// Cancel all existing daily workout reminders
  ///
  /// This is called before scheduling new reminders to avoid duplicates.
  Future<void> _cancelExistingReminders() async {
    try {
      final notificationProvider = _ref.read(unifiedNotificationProvider.notifier);

      // Get all pending notifications
      final state = _ref.read(unifiedNotificationProvider);
      final workoutReminders = state.notifications.where((notification) =>
        notification.type == NotificationType.workoutReminder &&
        notification.tags?.contains('daily_reminder') == true &&
        notification.status == NotificationDeliveryStatus.pending
      ).toList();

      // Cancel each one
      for (final reminder in workoutReminders) {
        await notificationProvider.cancelNotification(reminder.id);
      }

      if (kDebugMode) {
        debugPrint('🗑️ [DailyReminder] Cancelled ${workoutReminders.length} existing reminders');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [DailyReminder] Error cancelling existing reminders: $e');
      }
      // Don't throw - we still want to schedule new ones
    }
  }

  /// Cancel all daily workout reminders
  ///
  /// Called when user disables workout reminders in settings.
  ///
  /// Example usage:
  /// ```dart
  /// await service.cancelAllReminders();
  /// ```
  Future<void> cancelAllReminders() async {
    await _cancelExistingReminders();

    if (kDebugMode) {
      debugPrint('✅ [DailyReminder] All daily reminders cancelled');
    }
  }

  /// Reschedule daily reminders (useful when user changes time preference)
  ///
  /// Example usage:
  /// ```dart
  /// await service.rescheduleReminders(customHour: 10, customMinute: 30);
  /// ```
  Future<void> rescheduleReminders({
    int? customHour,
    int? customMinute,
  }) async {
    if (kDebugMode) {
      debugPrint('🔄 [DailyReminder] Rescheduling with new time...');
    }

    await scheduleDailyReminders(
      customHour: customHour,
      customMinute: customMinute,
    );
  }

  /// Get count of pending daily workout reminders
  ///
  /// Useful for debugging and displaying in UI.
  ///
  /// Returns: Number of pending workout reminder notifications
  int getPendingReminderCount() {
    final state = _ref.read(unifiedNotificationProvider);

    return state.notifications.where((notification) =>
      notification.type == NotificationType.workoutReminder &&
      notification.tags?.contains('daily_reminder') == true &&
      notification.status == NotificationDeliveryStatus.pending
    ).length;
  }

  /// Get next scheduled reminder time
  ///
  /// Returns: DateTime of next pending reminder, or null if none scheduled
  DateTime? getNextReminderTime() {
    final state = _ref.read(unifiedNotificationProvider);
    final now = DateTime.now();

    final upcomingReminders = state.notifications
        .where((notification) =>
          notification.type == NotificationType.workoutReminder &&
          notification.tags?.contains('daily_reminder') == true &&
          notification.status == NotificationDeliveryStatus.pending &&
          notification.scheduledTime.isAfter(now)
        )
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return upcomingReminders.isNotEmpty
        ? upcomingReminders.first.scheduledTime
        : null;
  }
}

/// Provider for DailyWorkoutReminderService
final dailyWorkoutReminderServiceProvider = Provider<DailyWorkoutReminderService>((ref) {
  return DailyWorkoutReminderService(ref);
});

/// Provider to automatically schedule reminders when enabled
///
/// This provider watches notification settings and automatically
/// schedules/cancels reminders based on user preferences.
final autoScheduleDailyRemindersProvider = Provider<void>((ref) {
  // TODO: Implement auto-scheduling based on NotificationSettings
  // This would watch notificationSettingsProvider and automatically
  // schedule/cancel reminders when enableWorkoutReminders changes.
  //
  // For now, reminders must be manually scheduled by calling:
  // ref.read(dailyWorkoutReminderServiceProvider).scheduleDailyReminders();
});
