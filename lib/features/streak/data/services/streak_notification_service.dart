import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for managing streak reminder notifications
///
/// Handles:
/// - Daily streak reminder notifications
/// - Permission requests (iOS/Android)
/// - Notification scheduling with timezone support
class StreakNotificationService {
  StreakNotificationService(this._notificationsPlugin);

  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  static const int _streakReminderId = 1;
  static const String _channelId = 'streak_reminders';
  static const String _channelName = 'Streak Reminders';
  static const String _channelDescription = 'Daily reminders to maintain your workout streak';

  /// Request notification permissions from user (iOS/Android 13+)
  Future<bool> requestPermissions() async {
    // iOS permissions
    final iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Android 13+ permissions
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    return true; // Older Android versions don't need runtime permission
  }

  /// Check if notifications are currently enabled (Android only in v19.5.0)
  ///
  /// Note: iOS notification status check removed in v19.5.0
  /// For iOS, permissions must be requested first, then rely on system settings
  Future<bool> areNotificationsEnabled() async {
    // Android check (v19.5.0+)
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      return granted ?? false;
    }

    // iOS: Always return true (rely on requestPermissions result)
    // System will handle showing permission dialog when needed
    return true;
  }

  /// Schedule daily streak reminder at specific time
  ///
  /// [hour] - Hour in 24-hour format (0-23)
  /// [minute] - Minute (0-59)
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      _streakReminderId,
      'Don\'t break your streak! 🔥',
      'Time for your daily workout to keep the streak going!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the daily streak reminder
  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(_streakReminderId);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
