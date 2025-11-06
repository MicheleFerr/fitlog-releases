/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/data/repositories
/// 🎯 Feature: smart_notifications
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// LOCAL NOTIFICATION REPOSITORY - flutter_local_notifications implementation
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';

/// Local implementation of NotificationRepository
/// TODO: Incomplete implementation - needs all abstract methods implemented
/// Commented out to avoid compilation errors until fully implemented
/*
// ignore: unused_element
class _LocalNotificationRepository implements NotificationRepository {

  _LocalNotificationRepository({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // TODO: onDidReceiveLocalNotification deprecated - use onDidReceiveNotificationResponse instead
      // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Low priority channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'gymbro_low_priority',
        'Low Priority Notifications',
        description: 'Non-urgent notifications and reminders',
        importance: Importance.low,
        playSound: false,
      ),
    );

    // Medium priority channel (default)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'gymbro_medium_priority',
        'Workout Reminders',
        description: 'Workout reminders and notifications',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
      ),
    );

    // High priority channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'gymbro_high_priority',
        'Important Alerts',
        description: 'Important workout and recovery alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ richiede permesso runtime
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
      return true; // Android < 13 non richiede permesso runtime
    }

    if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    }

    return false;
  }

  @override
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.areNotificationsEnabled();
        return granted ?? false;
      }
      return true;
    }

    if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.checkPermissions();
        // TODO: API changed in flutter_local_notifications - verify correct property names
        return (granted?.isEnabled ?? false);
      }
    }

    return false;
  }

  @override
  Future<String> scheduleNotification(UnifiedNotification notification) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(
      notification.scheduledTime,
      tz.local,
    );

    // Convert UnifiedNotification to WorkoutNotification for legacy code
    // TODO: Refactor to use UnifiedNotification directly
    final channelId = 'workout_channel';
    final channelName = 'Workout Notifications';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'GymBro workout notifications',
      importance: _getAndroidImportance(notification.priority),
      priority: _getAndroidPriority(notification.priority),
      icon: '@mipmap/ic_launcher',
      playSound: notification.priority != NotificationPriority.low,
      enableVibration: notification.priority == NotificationPriority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert String ID to int for flutter_local_notifications
    final intId = notification.id.hashCode;

    await _notificationsPlugin.zonedSchedule(
      intId,
      notification.title,
      notification.body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: notification.payload != null
          ? jsonEncode(notification.payload)
          : null,
    );

    return notification.id;
  }

  @override
  Future<List<String>> scheduleMultipleNotifications(
    List<UnifiedNotification> notifications,
  ) async {
    final ids = <String>[];
    for (final notification in notifications) {
      final id = await scheduleNotification(notification);
      ids.add(id);
    }
    return ids;
  }

  @override
  Future<bool> cancelNotification(String notificationId) async {
    try {
      await _ensureInitialized();
      final intId = notificationId.hashCode;
      await _notificationsPlugin.cancel(intId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> cancelMultipleNotifications(List<String> notificationIds) async {
    try {
      for (final id in notificationIds) {
        await cancelNotification(id);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notificationsPlugin.cancelAll();
  }

  @override
  Future<List<UnifiedNotification>> getPendingNotifications() async {
    await _ensureInitialized();

    final pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();

    // Note: flutter_local_notifications non fornisce tutti i dettagli delle notifiche pending
    // Quindi creiamo oggetti UnifiedNotification parziali
    return pendingNotifications.map((pending) {
      return UnifiedNotification(
        id: pending.id.toString(),
        type: NotificationType.workoutReminder, // Default, non possiamo sapere il tipo
        title: pending.title ?? '',
        body: pending.body ?? '',
        scheduledTime: DateTime.now(), // Non disponibile da pending
        priority: NotificationPriority.normal,
        payload: pending.payload != null
            ? jsonDecode(pending.payload!) as Map<String, dynamic>
            : null,
      );
    }).toList();
  }

  @override
  Future<List<UnifiedNotification>> getPendingNotificationsByType(
    NotificationType type,
  ) async {
    final allPending = await getPendingNotifications();
    // Non possiamo filtrare per tipo perché non è disponibile in pendingNotificationRequests
    // Dovremmo salvare le notifiche in un database locale per query più avanzate
    return allPending.where((n) => n.type == type).toList();
  }

  @override
  Future<List<UnifiedNotification>> getPendingNotificationsForRoutine(
    String routineId,
  ) async {
    final allPending = await getPendingNotifications();
    // Filtriamo per workoutId (assuming routine workouts use workoutId)
    return allPending.where((notification) {
      return notification.workoutId == routineId ||
             notification.payload?['routineId'] == routineId;
    }).toList();
  }

  @override
  Future<void> showImmediateNotification({
    required String id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'gymbro_medium_priority',
      'Workout Reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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

    final intId = id.hashCode;
    await _notificationsPlugin.show(
      intId,
      title,
      body,
      notificationDetails,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  // === HELPERS ===

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.critical:
        return Importance.max;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.critical:
        return Priority.max;
    }
  }

  // === CALLBACKS ===

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // iOS < 10 callback
    // Handle notification tap
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // Handle notification tap
    final payload = notificationResponse.payload;
    if (payload != null) {
      // Parse payload e naviga alla schermata appropriata
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        // TODO: Implementare navigazione basata sul payload
        // Es: se routineId presente, naviga a routine detail
      } catch (e) {
        // Invalid payload
      }
    }
  }

  // === MISSING ABSTRACT METHODS - STUB IMPLEMENTATIONS ===

  @override
  Future<bool> areNotificationsEnabled() async {
    // TODO: Implement actual check
    return true;
  }

  @override
  Future<void> cleanupOldNotifications({Duration? olderThan}) async {
    // TODO: Implement cleanup
  }

  @override
  Future<Map<String, NotificationDeliveryReceipt>> getMultipleDeliveryStatus(
    List<String> notificationIds,
  ) async {
    // TODO: Implement
    return {};
  }

  @override
  Future<NotificationDeliveryReceipt?> getDeliveryStatus(String notificationId) async {
    // TODO: Implement
    return null;
  }

  @override
  Future<NotificationMetrics> getMetrics({DateTime? since}) async {
    // TODO: Implement
    return NotificationMetrics(
      totalSent: 0,
      totalDelivered: 0,
      totalFailed: 0,
      totalRead: 0,
    );
  }

  @override
  Future<NotificationPreferences> getPreferences() async {
    // TODO: Implement
    return NotificationPreferences(
      enabledTypes: [],
      quietHours: [],
    );
  }

  @override
  Future<List<TimeRange>> getQuietHours() async {
    // TODO: Implement
    return [];
  }

  @override
  Future<List<NotificationError>> getRecentErrors({int limit = 10}) async {
    // TODO: Implement
    return [];
  }

  @override
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<bool> markAsFailed(String notificationId, String error) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<bool> markAsDelivered(
    String notificationId, {
    Map<String, dynamic>? platformData,
  }) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<bool> markMultipleAsRead(List<String> notificationIds) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<List<String>> scheduleMultipleNotifications(
    List<UnifiedNotification> notifications,
  ) async {
    // TODO: Implement
    return [];
  }

  @override
  Future<bool> cancelMultipleNotifications(List<String> notificationIds) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    // TODO: Implement
    return true;
  }

  @override
  Future<int> deleteExpiredNotifications({Duration? olderThan}) async {
    // TODO: Implement
    return 0;
  }

  @override
  Future<UnifiedNotification?> getNotification(String notificationId) async {
    // TODO: Implement
    return null;
  }

  @override
  Future<List<UnifiedNotification>> getAllNotifications({
    int? limit,
    DateTime? since,
  }) async {
    // TODO: Implement
    return [];
  }

  @override
  Future<bool> updateNotification(UnifiedNotification notification) async {
    // TODO: Implement
    return true;
  }
}
*/
