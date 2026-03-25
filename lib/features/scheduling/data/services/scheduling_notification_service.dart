import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:gymbro_flutter_new/shared/data/services/local_notifications_bootstrap.dart';
import 'package:gymbro_flutter_new/shared/data/services/local_timezone_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for scheduling workout reminder notifications
class SchedulingNotificationService {
  SchedulingNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  Future<void>? _initializeFuture;

  /// Notification channel ID for scheduled workout reminders
  static const String channelId = 'scheduled_workout_reminders';

  /// Notification channel name
  static const String channelName = 'Scheduled Workout Reminders';

  /// Notification channel description
  static const String channelDescription =
      'Reminders for your scheduled workout sessions';

  /// Base notification ID for scheduled workouts (using high range to avoid conflicts)
  static const int _baseNotificationId = 100000;

  /// Initialize the notification channel (call on app startup)
  Future<void> initialize() {
    return _initializeFuture ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    await LocalTimezoneService.ensureInitialized();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await LocalNotificationsBootstrap.ensureInitialized(
      plugin: _notificationsPlugin,
      settings: initSettings,
    );

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

    if (kDebugMode) {
      debugPrint('[SchedulingNotification] Service initialized successfully');
    }
  }

  /// Ensure notification scheduling is available before attempting to create reminders.
  Future<void> ensureReadyForScheduling() async {
    await initialize();

    if (Platform.isIOS) {
      final granted = await _requestIOSPermissions();
      if (!granted) {
        throw const SchedulingNotificationException(
          SchedulingNotificationExceptionType.notificationsDisabled,
        );
      }
      return;
    }

    if (!Platform.isAndroid) {
      return;
    }

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) {
      return;
    }

    var notificationsEnabled =
        await androidPlugin.areNotificationsEnabled() ?? false;

    if (!notificationsEnabled) {
      final permissionGranted =
          await androidPlugin.requestNotificationsPermission() ?? false;
      notificationsEnabled =
          permissionGranted ||
          (await androidPlugin.areNotificationsEnabled() ?? false);
    }

    if (!notificationsEnabled) {
      throw const SchedulingNotificationException(
        SchedulingNotificationExceptionType.notificationsDisabled,
      );
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
    AndroidScheduleMode? androidScheduleMode,
  }) async {
    await initialize();

    final notificationId = _generateNotificationId(workout.id);
    final scheduledDateTime = workout.reminderDateTime;

    // Prevent false-positive scheduling success for past reminders.
    if (scheduledDateTime.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint(
          '[SchedulingNotification] Skipping past reminder: ${workout.templateName} at $scheduledDateTime',
        );
      }
      throw const SchedulingNotificationException(
        SchedulingNotificationExceptionType.reminderTimeInPast,
      );
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
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode:
            androidScheduleMode ?? await _resolveAndroidScheduleMode(),
        payload: buildReminderPayload(workout),
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
    await ensureReadyForScheduling();

    final results = <String, int>{};
    final androidScheduleMode = await _resolveAndroidScheduleMode();

    try {
      for (final workout in workouts) {
        final notificationId = await scheduleWorkoutReminder(
          workout: workout,
          title: titleBuilder(workout),
          body: bodyBuilder(workout),
          androidScheduleMode: androidScheduleMode,
        );
        results[workout.id] = notificationId;
      }
    } catch (e) {
      for (final workoutId in results.keys) {
        await cancelReminder(workoutId);
      }
      rethrow;
    }

    return results;
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(String workoutId) async {
    await initialize();
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
    await initialize();
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

  @visibleForTesting
  String buildReminderPayload(ScheduledWorkout workout) {
    final deepLink = Uri(
      path: AppRoutes.templateDetailPath,
      queryParameters: {
        'id': workout.templateId,
        'scheduledWorkoutId': workout.id,
        'scheduledDate': workout.scheduledDate.toIso8601String(),
        'reminderHour': workout.reminderHour.toString(),
        'reminderMinute': workout.reminderMinute.toString(),
        'source': 'notification',
      },
    ).toString();

    return 'scheduled_workout:${workout.id}:$deepLink';
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final canScheduleExact =
        await androidPlugin?.canScheduleExactNotifications() ?? true;

    if (!canScheduleExact && kDebugMode) {
      debugPrint(
        '[SchedulingNotification] Exact alarms unavailable, falling back to inexact scheduling',
      );
    }

    return canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}

enum SchedulingNotificationExceptionType {
  notificationsDisabled,
  reminderTimeInPast,
}

class SchedulingNotificationException implements Exception {
  const SchedulingNotificationException(this.type);

  final SchedulingNotificationExceptionType type;

  @override
  String toString() {
    switch (type) {
      case SchedulingNotificationExceptionType.notificationsDisabled:
        return 'Notification permissions not granted';
      case SchedulingNotificationExceptionType.reminderTimeInPast:
        return 'Reminder time is already in the past';
    }
  }
}
