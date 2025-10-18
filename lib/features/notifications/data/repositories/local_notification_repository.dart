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
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';

/// Local implementation of NotificationRepository
class LocalNotificationRepository implements NotificationRepository {

  LocalNotificationRepository({
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
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
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
        return granted.alert == true &&
            granted.badge == true &&
            granted.sound == true;
      }
    }

    return false;
  }

  @override
  Future<void> scheduleNotification(WorkoutNotification notification) async {
    await _ensureInitialized();

    final scheduledDate = tz.TZDateTime.from(
      notification.scheduledTime,
      tz.local,
    );

    final androidDetails = AndroidNotificationDetails(
      notification.channelId,
      notification.channelName,
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

    await _notificationsPlugin.zonedSchedule(
      notification.id,
      '${notification.icon} ${notification.title}',
      notification.body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notification.payload != null
          ? jsonEncode(notification.payload)
          : null,
    );
  }

  @override
  Future<void> scheduleMultipleNotifications(
    List<WorkoutNotification> notifications,
  ) async {
    for (final notification in notifications) {
      await scheduleNotification(notification);
    }
  }

  @override
  Future<void> cancelNotification(int notificationId) async {
    await _ensureInitialized();
    await _notificationsPlugin.cancel(notificationId);
  }

  @override
  Future<void> cancelMultipleNotifications(List<int> notificationIds) async {
    for (final id in notificationIds) {
      await cancelNotification(id);
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notificationsPlugin.cancelAll();
  }

  @override
  Future<List<WorkoutNotification>> getPendingNotifications() async {
    await _ensureInitialized();

    final pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();

    // Note: flutter_local_notifications non fornisce tutti i dettagli delle notifiche pending
    // Quindi creiamo oggetti WorkoutNotification parziali
    return pendingNotifications.map((pending) {
      return WorkoutNotification(
        id: pending.id,
        type: NotificationType.workoutReminder, // Default, non possiamo sapere il tipo
        title: pending.title ?? '',
        body: pending.body ?? '',
        scheduledTime: DateTime.now(), // Non disponibile da pending
        priority: NotificationPriority.medium,
        isDelivered: false,
        payload: pending.payload != null
            ? jsonDecode(pending.payload!) as Map<String, dynamic>
            : null,
      );
    }).toList();
  }

  @override
  Future<List<WorkoutNotification>> getPendingNotificationsByType(
    NotificationType type,
  ) async {
    final allPending = await getPendingNotifications();
    // Non possiamo filtrare per tipo perché non è disponibile in pendingNotificationRequests
    // Dovremmo salvare le notifiche in un database locale per query più avanzate
    return allPending;
  }

  @override
  Future<List<WorkoutNotification>> getPendingNotificationsForRoutine(
    String routineId,
  ) async {
    final allPending = await getPendingNotifications();
    // Filtriamo per routineId se presente nel payload
    return allPending.where((notification) {
      return notification.payload?['routineId'] == routineId;
    }).toList();
  }

  @override
  Future<void> showImmediateNotification({
    required int id,
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

    await _notificationsPlugin.show(
      id,
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
      case NotificationPriority.medium:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.medium:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
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
}
