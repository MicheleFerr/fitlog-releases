/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/widgets
/// 🎯 Feature: notification_services
/// 🔧 Type: widget (initializer)
/// 🌍 Localization: N/A (no UI)
/// 🎨 Theme: N/A (no UI)
/// 📱 Platform: Universal
///
/// NOTIFICATION SERVICES INITIALIZER - Initializes notification services at app startup
///
/// This widget:
/// 1. Schedules daily workout reminders (9:00 AM, 30 days)
/// 2. Enables auto-check for streak achievements
/// 3. Runs once when app starts (after ProviderScope is ready)
///
/// Usage:
/// Wrap MaterialApp with NotificationServicesInitializer in app.dart
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/daily_workout_reminder_service.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/streak_achievement_notification_service.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_settings_provider_v2.dart';

/// Initializer widget for notification services
///
/// This widget initializes notification services once at app startup.
/// It wraps the child widget and performs initialization in initState.
///
/// Example:
/// ```dart
/// NotificationServicesInitializer(
///   child: MaterialApp(...),
/// )
/// ```
class NotificationServicesInitializer extends ConsumerStatefulWidget {
  const NotificationServicesInitializer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<NotificationServicesInitializer> createState() =>
      _NotificationServicesInitializerState();
}

class _NotificationServicesInitializerState
    extends ConsumerState<NotificationServicesInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize services after first frame (when ProviderScope is ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  /// Initialize all notification services
  Future<void> _initializeServices() async {
    if (_initialized) return;

    _initialized = true;

    try {
      if (kDebugMode) {
        debugPrint('🔔 [NotificationServices] Initializing...');
      }

      // 1. Activate auto-scheduling listener (watches v2 settings changes)
      _activateAutoScheduleListener();

      // 2. Schedule daily workout reminders (using v2 settings)
      await _scheduleDailyReminders();

      // 3. Enable auto-check for streak achievements
      _enableStreakAutoCheck();

      if (kDebugMode) {
        debugPrint('✅ [NotificationServices] Initialization complete');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [NotificationServices] Initialization failed: $e');
      }
      // Don't throw - app should continue even if notifications fail
    }
  }

  /// Activate auto-scheduling listener for settings v2.0
  ///
  /// This listener watches `notificationSettingsV2Provider` and automatically
  /// schedules/cancels reminders when settings change.
  void _activateAutoScheduleListener() {
    try {
      // Reading this provider activates the ref.listen() inside it
      ref.read(autoScheduleNotificationsV2Provider);

      if (kDebugMode) {
        debugPrint('✅ [AutoSchedule] Listener activated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AutoSchedule] Failed to activate: $e');
      }
    }
  }

  /// Schedule daily workout reminders for next 30 days
  ///
  /// Uses v2 settings for:
  /// - Enabled/disabled state
  /// - Custom reminder time
  Future<void> _scheduleDailyReminders() async {
    try {
      final reminderService = ref.read(dailyWorkoutReminderServiceProvider);

      // Get v2 settings (if available)
      final settingsAsync = ref.read(notificationSettingsV2Provider);
      final settings = settingsAsync.valueOrNull;

      // Check if workout reminders are enabled
      final isEnabled = settings?.enableWorkoutReminders ?? true;

      if (!isEnabled) {
        if (kDebugMode) {
          debugPrint('🔕 [DailyReminders] Disabled in settings - skipping');
        }
        return;
      }

      // Use custom time from settings (or default 9:00 AM)
      // v2.0: Check customTimePerType['workoutReminder'] first, then fallback to global customTime
      final customTime = settings?.customTimePerType['workoutReminder'] ??
          settings?.customTime;

      await reminderService.scheduleDailyReminders(
        customHour: customTime?.hour,
        customMinute: customTime?.minute,
      );

      if (kDebugMode) {
        final count = reminderService.getPendingReminderCount();
        final hour = customTime?.hour ?? 9;
        final minute = customTime?.minute ?? 0;
        debugPrint(
          '✅ [DailyReminders] Scheduled $count reminders at $hour:${minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [DailyReminders] Failed to schedule: $e');
      }
    }
  }

  /// Enable auto-check for streak achievements
  ///
  /// This watches the autoCheckStreakAchievementsProvider which automatically
  /// checks for streak milestones whenever currentStreak changes.
  void _enableStreakAutoCheck() {
    try {
      // Read provider to activate auto-check listener
      ref.read(autoCheckStreakAchievementsProvider);

      if (kDebugMode) {
        debugPrint('✅ [StreakAchievements] Auto-check enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [StreakAchievements] Failed to enable auto-check: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Just pass through to child - no UI
    return widget.child;
  }
}
