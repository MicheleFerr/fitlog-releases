/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/data/datasources
/// Feature: Local Notifications System
/// Type: DataSource - flutter_local_notifications wrapper
///
/// Wraps flutter_local_notifications for scheduling and managing local notifications.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_config.dart';

/// Callback type for when a notification is tapped
typedef NotificationTapCallback = void Function(String? payload);

/// DataSource for scheduling and managing local notifications.
class LocalNotificationDatasource {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationTapCallback? _onNotificationTap;

  /// Initialize the notification plugin
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    _onNotificationTap = onNotificationTap;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions on iOS
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  /// Request notification permissions on iOS
  Future<bool> _requestIOSPermissions() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  /// Check if notifications are permitted
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      // iOS doesn't have a direct "are notifications enabled" check via this plugin
      // We assume yes if we've requested permissions
      return iosPlugin != null;
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  /// Schedule a notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationType type,
    String? payload,
  }) async {
    // Respect iOS 64 notification limit
    final pendingCount = await getPendingNotificationCount();
    if (pendingCount >= NotificationConfig.maxScheduledNotifications) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Cannot schedule notification: limit reached ($pendingCount/${NotificationConfig.maxScheduledNotifications})',
        );
      }
      // Cancel oldest notification to make room
      await _cancelOldestPendingNotification();
    }

    // Respect quiet hours - reschedule if necessary
    final effectiveTime = NotificationConfig.getNextAvailableTime(
      scheduledTime,
    );

    final androidDetails = AndroidNotificationDetails(
      type.channelId,
      type.channelName,
      channelDescription: type.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(effectiveTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    if (kDebugMode) {
      debugPrint(
        '📅 Scheduled notification #$id for $effectiveTime (${type.name})',
      );
    }
  }

  /// Show a notification immediately
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      type.channelId,
      type.channelName,
      channelDescription: type.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);

    if (kDebugMode) {
      debugPrint('🔔 Showed notification #$id: $title');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    if (kDebugMode) {
      debugPrint('❌ Canceled notification #$id');
    }
  }

  /// Cancel all notifications of a specific type
  Future<void> cancelNotificationsByType(NotificationType type) async {
    // flutter_local_notifications doesn't have a "cancel by channel" feature
    // We need to track IDs ourselves or cancel all and reschedule
    // For now, we'll use a simple approach: cancel by known ID ranges
    // Each type gets a range of 100 IDs
    final startId = _getIdRangeStart(type);
    for (var i = startId; i < startId + 100; i++) {
      await _plugin.cancel(i);
    }
    if (kDebugMode) {
      debugPrint('❌ Canceled all ${type.name} notifications');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    if (kDebugMode) {
      debugPrint('❌ Canceled all notifications');
    }
  }

  /// Get count of pending (scheduled) notifications
  Future<int> getPendingNotificationCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  /// Get all pending notification IDs
  Future<List<int>> getPendingNotificationIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((n) => n.id).toList();
  }

  /// Generate a unique notification ID for a type
  int generateNotificationId(NotificationType type) {
    final startId = _getIdRangeStart(type);
    final timestamp = DateTime.now().millisecondsSinceEpoch % 100;
    return startId + timestamp;
  }

  /// Get the ID range start for a notification type
  int _getIdRangeStart(NotificationType type) {
    switch (type) {
      case NotificationType.workoutForgotten:
        return 1000;
      case NotificationType.inactivity:
        return 2000;
      case NotificationType.insightPr:
        return 3000;
      case NotificationType.insightStreak:
        return 4000;
      case NotificationType.insightVolume:
        return 5000;
    }
  }

  /// Cancel the oldest pending notification to make room for new ones
  Future<void> _cancelOldestPendingNotification() async {
    final pending = await _plugin.pendingNotificationRequests();
    if (pending.isNotEmpty) {
      // Cancel the first one (oldest)
      await _plugin.cancel(pending.first.id);
      if (kDebugMode) {
        debugPrint(
          '🗑️ Canceled oldest notification #${pending.first.id} to make room',
        );
      }
    }
  }

  /// Handle notification tap response
  void _onNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('👆 Notification tapped: ${response.payload}');
    }
    _onNotificationTap?.call(response.payload);
  }
}
