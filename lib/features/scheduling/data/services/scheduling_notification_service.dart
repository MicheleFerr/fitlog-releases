import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for scheduling workout reminder notifications
class SchedulingNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  /// Notification channel ID for scheduled workout reminders
  static const String channelId = 'scheduled_workout_reminders';

  /// Notification channel name
  static const String channelName = 'Scheduled Workout Reminders';

  /// Notification channel description
  static const String channelDescription =
      'Reminders for your scheduled workout sessions';

  /// Base notification ID for scheduled workouts (using high range to avoid conflicts)
  static const int _baseNotificationId = 100000;

  SchedulingNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initialize the notification channel (call on app startup)
  Future<void> initialize() async {
    // Initialize timezone data (required for zonedSchedule)
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Create Android notification channel
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
        ),
      );
    }

    // Request iOS permissions explicitly
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    if (kDebugMode) {
      debugPrint('[SchedulingNotification] Service initialized successfully');
    }
  }

  /// Request notification permissions on iOS
  Future<bool> _requestIOSPermissions() async {
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final result = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        debugPrint('[SchedulingNotification] iOS permissions granted: $result');
      }

      return result ?? false;
    }

    return false;
  }

  /// Schedule a workout reminder notification
  ///
  /// Returns the notification ID for later cancellation
  Future<int> scheduleWorkoutReminder({
    required ScheduledWorkout workout,
    required String title,
    required String body,
  }) async {
    final notificationId = _generateNotificationId(workout.id);
    final scheduledDateTime = workout.reminderDateTime;

    // Don't schedule if time is in the past
    if (scheduledDateTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint(
          '[SchedulingNotification] Skipping past reminder: ${workout.templateName} at $scheduledDateTime',
        );
      }
      return notificationId;
    }

    final tzScheduledDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    if (kDebugMode) {
      debugPrint('[SchedulingNotification] Scheduling notification...');
      debugPrint('[SchedulingNotification] - Title: $title');
      debugPrint('[SchedulingNotification] - Body: $body');
      debugPrint(
        '[SchedulingNotification] - Scheduled for: $tzScheduledDateTime',
      );
      debugPrint('[SchedulingNotification] - Notification ID: $notificationId');
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduledDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'scheduled_workout:${workout.id}',
      );

      if (kDebugMode) {
        debugPrint(
          '[SchedulingNotification] ✅ Scheduled reminder for "${workout.templateName}" at $tzScheduledDateTime (ID: $notificationId)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[SchedulingNotification] ❌ Error scheduling notification: $e',
        );
      }
      rethrow;
    }

    return notificationId;
  }

  /// Schedule reminders for multiple workouts
  Future<Map<String, int>> scheduleMultipleReminders({
    required List<ScheduledWorkout> workouts,
    required String Function(ScheduledWorkout workout) titleBuilder,
    required String Function(ScheduledWorkout workout) bodyBuilder,
  }) async {
    final results = <String, int>{};

    for (final workout in workouts) {
      final notificationId = await scheduleWorkoutReminder(
        workout: workout,
        title: titleBuilder(workout),
        body: bodyBuilder(workout),
      );
      results[workout.id] = notificationId;
    }

    return results;
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(String workoutId) async {
    final notificationId = _generateNotificationId(workoutId);
    await _notificationsPlugin.cancel(notificationId);

    if (kDebugMode) {
      debugPrint(
        '[SchedulingNotification] Cancelled reminder for workout: $workoutId',
      );
    }
  }

  /// Cancel all scheduled workout reminders
  Future<void> cancelAllReminders() async {
    // Get all pending notifications and cancel those with our payload prefix
    final pending = await _notificationsPlugin.pendingNotificationRequests();

    for (final notification in pending) {
      if (notification.payload?.startsWith('scheduled_workout:') == true) {
        await _notificationsPlugin.cancel(notification.id);
      }
    }

    if (kDebugMode) {
      debugPrint('[SchedulingNotification] Cancelled all workout reminders');
    }
  }

  /// Generate a unique notification ID from workout ID
  int _generateNotificationId(String workoutId) {
    // Use hashCode and ensure positive number in valid range
    return _baseNotificationId + (workoutId.hashCode.abs() % 100000);
  }
}
