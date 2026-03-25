import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';
import 'package:gymbro_flutter_new/shared/data/services/local_notifications_bootstrap.dart';
import 'package:gymbro_flutter_new/shared/data/services/local_timezone_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for scheduling progress photo reminder notifications
///
/// Best practices applied (from competitor research):
/// - Gentle, motivational tone (not pushy)
/// - Message rotation to avoid repetition
/// - Anti-spam: auto-disable after consecutive ignores
/// - Recommended frequency: 4-5 weeks (Hevy research)
class PhotoReminderNotificationService {
  PhotoReminderNotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
           notificationsPlugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  Future<void>? _initializeFuture;

  /// Notification channel ID for photo reminders
  static const String channelId = 'progress_photo_reminders';

  /// Notification channel name
  static const String channelName = 'Progress Photo Reminders';

  /// Notification channel description
  static const String channelDescription =
      'Gentle reminders to capture your fitness progress';

  /// Base notification ID for photo reminders
  static const int _baseNotificationId = 200000;

  /// Motivational message variations for rotation
  /// Keeps notifications fresh and engaging
  static const List<Map<String, String>> _messageVariations = [
    {
      'title': '📸 Time for a Progress Check!',
      'body':
          'Your fitness journey deserves to be documented. Take a moment to capture your progress.',
    },
    {
      'title': '💪 How\'s Your Transformation Going?',
      'body':
          'A quick photo can reveal changes you might not notice day-to-day.',
    },
    {
      'title': '🎯 Progress Photo Reminder',
      'body':
          'Small changes add up! Capture today\'s you and compare with your journey.',
    },
    {
      'title': '✨ Document Your Journey',
      'body':
          'Future you will thank present you for these photos. Take one now!',
    },
    {
      'title': '📊 Track Your Visual Progress',
      'body':
          'Numbers tell one story, photos tell another. Which story are you writing today?',
    },
  ];

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
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
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
          importance: Importance.defaultImportance,
        ),
      );
    }

    // Request iOS permissions
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    if (kDebugMode) {
      debugPrint('[PhotoReminder] Notification service initialized');
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
        debugPrint('[PhotoReminder] iOS permissions granted: $result');
      }

      return result ?? false;
    }

    return false;
  }

  /// Schedule a photo reminder notification
  ///
  /// Returns the notification ID for later cancellation
  Future<int> schedulePhotoReminder({
    required PhotoReminderSettings settings,
    int? messageVariation,
  }) async {
    await initialize();

    if (!settings.isEnabled) {
      if (kDebugMode) {
        debugPrint('[PhotoReminder] Reminders disabled, skipping schedule');
      }
      return -1;
    }

    final nextReminder =
        settings.nextReminderScheduled ??
        settings.calculateNextReminder(DateTime.now());

    // Don't schedule if time is in the past
    if (nextReminder.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('[PhotoReminder] Skipping past reminder: $nextReminder');
      }
      return -1;
    }

    // Select message variation (rotate through messages)
    final variation =
        messageVariation ??
        DateTime.now().millisecond % _messageVariations.length;
    final message = _messageVariations[variation];

    final notificationId = _baseNotificationId + variation;
    final tzScheduledDateTime = tz.TZDateTime.from(nextReminder, tz.local);

    if (kDebugMode) {
      debugPrint('[PhotoReminder] Scheduling notification...');
      debugPrint('[PhotoReminder] - Title: ${message['title']}');
      debugPrint('[PhotoReminder] - Scheduled for: $tzScheduledDateTime');
      debugPrint('[PhotoReminder] - Notification ID: $notificationId');
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        message['title']!,
        message['body']!,
        tzScheduledDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'progress_photo_reminder:$variation',
      );

      if (kDebugMode) {
        debugPrint(
          '[PhotoReminder] ✅ Scheduled reminder at $tzScheduledDateTime (ID: $notificationId)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PhotoReminder] ❌ Error scheduling notification: $e');
      }
      rethrow;
    }

    return notificationId;
  }

  /// Cancel any scheduled photo reminder
  Future<void> cancelReminder() async {
    await initialize();

    // Cancel all possible variations
    for (var i = 0; i < _messageVariations.length; i++) {
      await _notificationsPlugin.cancel(_baseNotificationId + i);
    }

    if (kDebugMode) {
      debugPrint('[PhotoReminder] Cancelled all photo reminders');
    }
  }

  /// Get message for a specific variation (for preview)
  Map<String, String> getMessagePreview(int variation) {
    return _messageVariations[variation % _messageVariations.length];
  }

  /// Total number of message variations
  int get messageVariationCount => _messageVariations.length;
}
