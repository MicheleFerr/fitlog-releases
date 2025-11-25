/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/providers
/// 🎯 Feature: smart_notifications
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION PROVIDERS - Riverpod providers for notification system
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ FIXED: Hide NotificationType from workout_notification to avoid ambiguity with unified_notification
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart' hide NotificationType;
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/repositories/local_notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/smart_notification_service.dart';
// 🔔 WARM-START: Import for GoRouter navigation
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/app/app.dart' show routerProvider;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:flutter/foundation.dart';

/// Provider for NotificationRepository instance
/// ✅ FIXED: Now uses LocalNotificationRepository (real implementation)
/// 🔔 WARM-START: Includes navigation callback for notification taps
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  // 🔔 WARM-START: Get GoRouter for navigation
  final router = ref.read(routerProvider);

  return LocalNotificationRepository(
    ref: ref, // 🔔 FIX: Pass ref to read NotificationSettings v2.0
    onNotificationTapped: (payload) {
      // 🔔 WARM-START: Handle notification tap when app is already running
      _handleNotificationTap(router, payload);
    },
  );
});

/// Handle notification tap (warm-start)
/// Navigates to appropriate screen based on notification type
void _handleNotificationTap(GoRouter router, Map<String, dynamic> payload) {
  try {
    final typeString = payload['type'] as String?;
    if (typeString == null) return;

    // Parse notification type
    final type = NotificationType.values.firstWhere(
      (t) => t.toString() == typeString,
      orElse: () => NotificationType.workoutReminder,
    );

    // 🔔 WARM-START: Route mapping (same as cold-start in main.dart)
    final routeMap = {
      NotificationType.workoutReminder: '/workout',
      NotificationType.achievementUnlocked: '/analytics',
      NotificationType.progressMilestone: '/analytics',
      NotificationType.restReminder: '/routine',
      NotificationType.workoutSummary: '/analytics',
      NotificationType.streakReminder: '/analytics',
      NotificationType.timerComplete: '/workout',
    };

    final route = routeMap[type] ?? '/';

    // ✅ PRODUCTION-READY: Use go() instead of pushNamed() to avoid stack issues
    // go() replaces current route, preventing navigation stack bloat
    router.go(route);

    if (kDebugMode) {
      debugPrint('🔔 [Warm-start] Navigated to: $route (type: $type)');
    }

    // TODO: Add Firebase Analytics event (notification_tapped)
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ [Warm-start] Navigation error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
    }
  }
}

/// Provider for NotificationSettings (from SharedPreferences)
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

/// Notifier for NotificationSettings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      state = NotificationSettings(
        enableWorkoutReminders: prefs.getBool('notif_workout_reminders') ?? true,
        enableRecoveryAlerts: prefs.getBool('notif_recovery_alerts') ?? true,
        enableStreakMotivation:
            prefs.getBool('notif_streak_motivation') ?? false,
        enableRestDayReminders:
            prefs.getBool('notif_rest_day_reminders') ?? false,
        preferredTime: NotificationTimePreference.values[
            prefs.getInt('notif_preferred_time') ?? 0],
        enableSmartScheduling:
            prefs.getBool('notif_smart_scheduling') ?? true,
        doNotDisturbEnabled: prefs.getBool('notif_dnd_enabled') ?? false,
        reminderMinutesBefore: prefs.getInt('notif_reminder_minutes') ?? 60,
      );

      // Load custom time if set
      final customHour = prefs.getInt('notif_custom_hour');
      final customMinute = prefs.getInt('notif_custom_minute');
      if (customHour != null && customMinute != null) {
        state = state.copyWith(
          customTime: DateTime(2000, 1, 1, customHour, customMinute),
        );
      }

      // Load DND window if enabled
      final dndStartHour = prefs.getInt('notif_dnd_start_hour');
      final dndStartMinute = prefs.getInt('notif_dnd_start_minute');
      final dndEndHour = prefs.getInt('notif_dnd_end_hour');
      final dndEndMinute = prefs.getInt('notif_dnd_end_minute');

      if (dndStartHour != null &&
          dndStartMinute != null &&
          dndEndHour != null &&
          dndEndMinute != null) {
        state = state.copyWith(
          doNotDisturbStart:
              DateTime(2000, 1, 1, dndStartHour, dndStartMinute),
          doNotDisturbEnd: DateTime(2000, 1, 1, dndEndHour, dndEndMinute),
        );
      }
    } catch (e) {
      // Use defaults if loading fails
    }
  }

  /// Update settings and persist
  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = newSettings;

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'notif_workout_reminders',
        newSettings.enableWorkoutReminders,
      );
      await prefs.setBool(
        'notif_recovery_alerts',
        newSettings.enableRecoveryAlerts,
      );
      await prefs.setBool(
        'notif_streak_motivation',
        newSettings.enableStreakMotivation,
      );
      await prefs.setBool(
        'notif_rest_day_reminders',
        newSettings.enableRestDayReminders,
      );
      await prefs.setInt(
        'notif_preferred_time',
        newSettings.preferredTime.index,
      );
      await prefs.setBool(
        'notif_smart_scheduling',
        newSettings.enableSmartScheduling,
      );
      await prefs.setBool(
        'notif_dnd_enabled',
        newSettings.doNotDisturbEnabled,
      );
      await prefs.setInt(
        'notif_reminder_minutes',
        newSettings.reminderMinutesBefore,
      );

      // Save custom time
      if (newSettings.customTime != null) {
        await prefs.setInt('notif_custom_hour', newSettings.customTime!.hour);
        await prefs.setInt(
          'notif_custom_minute',
          newSettings.customTime!.minute,
        );
      }

      // Save DND window
      if (newSettings.doNotDisturbStart != null) {
        await prefs.setInt(
          'notif_dnd_start_hour',
          newSettings.doNotDisturbStart!.hour,
        );
        await prefs.setInt(
          'notif_dnd_start_minute',
          newSettings.doNotDisturbStart!.minute,
        );
      }

      if (newSettings.doNotDisturbEnd != null) {
        await prefs.setInt(
          'notif_dnd_end_hour',
          newSettings.doNotDisturbEnd!.hour,
        );
        await prefs.setInt(
          'notif_dnd_end_minute',
          newSettings.doNotDisturbEnd!.minute,
        );
      }
    } catch (e) {
      // Ignore persistence errors
    }
  }

  /// Toggle workout reminders
  ///
  /// When enabled, schedules daily reminders (handled by DailyWorkoutReminderService).
  /// When disabled, cancels all scheduled reminders.
  Future<void> toggleWorkoutReminders(bool enabled) async {
    await updateSettings(state.copyWith(enableWorkoutReminders: enabled));
    // NOTE: Actual scheduling/canceling is handled by DailyWorkoutReminderService
    // via the notification settings screen
  }

  /// Toggle recovery alerts
  Future<void> toggleRecoveryAlerts(bool enabled) async {
    await updateSettings(state.copyWith(enableRecoveryAlerts: enabled));
  }

  /// Update preferred time
  Future<void> updatePreferredTime(
    NotificationTimePreference preference,
  ) async {
    await updateSettings(state.copyWith(preferredTime: preference));
  }
}

/// Provider for SmartNotificationService
final smartNotificationServiceProvider =
    Provider<SmartNotificationService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final settings = ref.watch(notificationSettingsProvider);

  return SmartNotificationService(
    repository: repository,
    settings: settings,
  );
});

/// Future provider for notification initialization
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final notificationInitializationProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(smartNotificationServiceProvider);
  return await service.initialize();
});

/// Future provider for pending notifications
final pendingNotificationsProvider =
    FutureProvider<List<WorkoutNotification>>((ref) async {
  final service = ref.watch(smartNotificationServiceProvider);
  return await service.getPendingNotifications();
});

/// Provider for notification permission status
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final notificationPermissionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(smartNotificationServiceProvider);
  return await service.areNotificationsEnabled();
});
