/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/application/services
/// 🎯 Feature: routine
/// 🔧 Type: service
///
/// Service for sending routine-related notifications
/// Integrates with flutter_local_notifications for skip reminders and recovery prompts
///
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification IDs for routine notifications
class RoutineNotificationIds {
  static const int skippedDayReminder = 7000;
  static const int routineDayCompleted = 7001;
  static const int recoveryOpportunity = 7002;
}

/// Service for routine skip notifications
class RoutineNotificationService {
  RoutineNotificationService() {
    _initialize();
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ [RoutineNotificationService] Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineNotificationService] Initialization error: $e');
      }
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint(
        '🔔 [RoutineNotificationService] Notification tapped: ${response.payload}',
      );
    }
    // TODO: Navigate to skip recovery screen or routine details
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      // Request Android 13+ permissions
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // Request iOS permissions
      final iosPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true; // Assume granted for other platforms
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineNotificationService] Permission error: $e');
      }
      return false;
    }
  }

  /// Send notification when day is skipped
  ///
  /// Called after marking past days as skipped to remind user they can recover
  Future<void> sendSkippedDayReminder({
    required String routineName,
    required int skippedCount,
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'routine_skips',
        'Routine Skipped Days',
        channelDescription: 'Notifications about skipped routine days',
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

      final title = skippedCount == 1
          ? '📅 1 day skipped in $routineName'
          : '📅 $skippedCount days skipped in $routineName';

      const body = 'Tap to view recovery options and get back on track!';

      await _notifications.show(
        RoutineNotificationIds.skippedDayReminder,
        title,
        body,
        notificationDetails,
        payload: 'routine_skips:$skippedCount',
      );

      if (kDebugMode) {
        debugPrint(
          '🔔 [RoutineNotificationService] Sent skip reminder: $skippedCount days',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineNotificationService] Error sending skip reminder: $e');
      }
    }
  }

  /// Send notification when routine day is completed
  Future<void> sendRoutineDayCompletedNotification({
    required String routineName,
    required String workoutName,
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'routine_completion',
        'Routine Progress',
        channelDescription: 'Notifications about routine day completion',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
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

      await _notifications.show(
        RoutineNotificationIds.routineDayCompleted,
        '✅ $routineName day completed!',
        'Great job completing $workoutName!',
        notificationDetails,
        payload: 'routine_completed',
      );

      if (kDebugMode) {
        debugPrint(
          '🔔 [RoutineNotificationService] Sent completion notification',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineNotificationService] Error sending completion: $e');
      }
    }
  }

  /// Send notification about recovery opportunity
  Future<void> sendRecoveryOpportunityNotification({
    required String routineName,
    required int recoverableDays,
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'routine_recovery',
        'Routine Recovery',
        channelDescription: 'Notifications about recovery opportunities',
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

      final title = recoverableDays == 1
          ? '💪 1 skipped day can be recovered'
          : '💪 $recoverableDays skipped days can be recovered';

      await _notifications.show(
        RoutineNotificationIds.recoveryOpportunity,
        title,
        'Tap to schedule recovery workouts in $routineName',
        notificationDetails,
        payload: 'recovery_opportunity:$recoverableDays',
      );

      if (kDebugMode) {
        debugPrint(
          '🔔 [RoutineNotificationService] Sent recovery opportunity: $recoverableDays days',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineNotificationService] Error sending recovery: $e');
      }
    }
  }

  /// Cancel all routine notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      await _notifications.cancel(RoutineNotificationIds.skippedDayReminder);
      await _notifications.cancel(RoutineNotificationIds.routineDayCompleted);
      await _notifications.cancel(RoutineNotificationIds.recoveryOpportunity);

      if (kDebugMode) {
        debugPrint('🔕 [RoutineNotificationService] Cancelled all notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [RoutineNotificationService] Error cancelling: $e');
      }
    }
  }

  /// Dispose service
  void dispose() {
    _isInitialized = false;
  }
}
