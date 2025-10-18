import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as TZ;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification_state.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/adapters/notification_platform_adapter.dart';
import 'package:flutter/foundation.dart';

/// iOS-specific implementation of the notification platform adapter
/// Integrates with iOS native notifications, Live Activities, and APNs
class IOSNotificationAdapter implements NotificationPlatformAdapter {
  static const MethodChannel _channel = MethodChannel('com.gymbro.notifications.ios');
  static const MethodChannel _liveActivityChannel = MethodChannel('com.gymbro.live_activities');
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  late IOSFlutterLocalNotificationsPlugin _iosPlugin;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get iOS-specific plugin
      _iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!;
      
      // Initialize local notifications with iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false, // We'll request this separately if needed
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const initSettings = InitializationSettings(iOS: iosSettings);
      await _localNotifications.initialize(initSettings);

      // Setup platform channels
      _channel.setMethodCallHandler(_handleMethodCall);
      _liveActivityChannel.setMethodCallHandler(_handleLiveActivityCall);

      // Initialize native iOS components
      await _channel.invokeMethod('initialize', {
        'sounds': _getAvailableSounds(),
        'categories': _getNotificationCategories(),
      });

      _isInitialized = true;
    } catch (error) {
      throw Exception('Failed to initialize iOS notification adapter: $error');
    }
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    try {
      await _channel.invokeMethod('dispose');
      _isInitialized = false;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error disposing iOS notification adapter: $error');
      }
    }
  }

  // === PERMISSION MANAGEMENT ===

  @override
  Future<bool> hasPermissions() async {
    try {
      // Use iOS plugin to check notification permissions
      final result = await _iosPlugin.checkPermissions();
      return result?.isEnabled ?? false;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // Request local notification permissions only
      final result = await _iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: false,
      );

      return result ?? false;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> hasCriticalAlertPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasCriticalAlertPermissions');
      return result ?? false;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> requestCriticalAlertPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestCriticalAlertPermissions');
      return result ?? false;
    } catch (error) {
      return false;
    }
  }

  // === NOTIFICATION DELIVERY ===

  @override
  Future<String> scheduleLocalNotification(UnifiedNotification notification) async {
    try {
      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: notification.soundName,
        badgeNumber: null, // Will be set by badge management
        threadIdentifier: notification.iosConfig?.threadId,
        categoryIdentifier: _getCategoryForType(notification.type),
        interruptionLevel: _getInterruptionLevel(notification.priority),
        subtitle: notification.iosConfig?.categoryId,
      );

      final details = NotificationDetails(iOS: iosDetails);

      await _localNotifications.zonedSchedule(
        notification.id.hashCode,
        notification.title,
        notification.body,
        TZ.TZDateTime.from(notification.scheduledTime, TZ.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: json.encode({
          'notificationId': notification.id,
          'type': notification.type.name,
          'payload': notification.payload,
        }),
      );

      return notification.id;
    } catch (error) {
      throw Exception('Failed to schedule iOS notification: $error');
    }
  }

  @override
  Future<List<String>> scheduleMultipleLocalNotifications(List<UnifiedNotification> notifications) async {
    final results = <String>[];
    
    for (final notification in notifications) {
      try {
        final id = await scheduleLocalNotification(notification);
        results.add(id);
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Failed to schedule notification ${notification.id}: $error');
        }
        // Continue with other notifications
      }
    }
    
    return results;
  }

  @override
  Future<bool> cancelLocalNotification(String notificationId) async {
    try {
      await _localNotifications.cancel(notificationId.hashCode);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> cancelMultipleLocalNotifications(List<String> notificationIds) async {
    try {
      for (final id in notificationIds) {
        await _localNotifications.cancel(id.hashCode);
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<List<String>> getPendingNotificationIds() async {
    try {
      final pending = await _localNotifications.pendingNotificationRequests();
      return pending.map((request) => request.id.toString()).toList();
    } catch (error) {
      return [];
    }
  }

  @override
  Future<bool> clearAllDeliveredNotifications() async {
    try {
      await _channel.invokeMethod('clearAllDeliveredNotifications');
      return true;
    } catch (error) {
      return false;
    }
  }

  // === PUSH NOTIFICATIONS ===

  @override
  Future<String?> getPushToken() async {
    try {
      // No FCM token available - return null
      return null;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> handlePushNotification(Map<String, dynamic> payload) async {
    try {
      await _channel.invokeMethod('handlePushNotification', payload);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error handling push notification: $error');
      }
    }
  }

  @override
  Future<bool> registerForPushNotifications(String token) async {
    try {
      final result = await _channel.invokeMethod<bool>('registerForPushNotifications', {
        'token': token,
      });
      return result ?? false;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> unregisterFromPushNotifications() async {
    try {
      // No FCM token to delete
      return true;
    } catch (error) {
      return false;
    }
  }

  // === PREFERENCE MANAGEMENT ===

  @override
  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    try {
      await _channel.invokeMethod('updatePreferences', {
        'enabled': preferences.enabled,
        'typePreferences': preferences.typePreferences.map((k, v) => MapEntry(k.name, v)),
        'soundPreferences': preferences.soundPreferences.toJson(),
        'vibrationEnabled': preferences.vibrationEnabled,
        'quietHours': preferences.quietHours.map((q) => q.toJson()).toList(),
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getPlatformSettings() async {
    try {
      // Use iOS plugin to get notification settings
      final permissions = await _iosPlugin.checkPermissions();
      return {
        'authorizationStatus': (permissions?.isEnabled ?? false) ? 'authorized' : 'denied',
        'alert': 'enabled', // Simplified since we can't access individual permissions
        'badge': 'enabled',
        'sound': 'enabled',
      };
    } catch (error) {
      return {};
    }
  }

  @override
  Future<bool> applyQuietHours(List<TimeRange> quietHours) async {
    try {
      await _channel.invokeMethod('applyQuietHours', {
        'quietHours': quietHours.map((q) => q.toJson()).toList(),
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> setNotificationSound(NotificationType type, String soundName) async {
    try {
      await _channel.invokeMethod('setNotificationSound', {
        'type': type.name,
        'soundName': soundName,
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  // === BADGE MANAGEMENT ===

  @override
  Future<bool> setBadgeCount(int count) async {
    try {
      await _iosPlugin.requestPermissions(badge: true);
      await _channel.invokeMethod('setBadgeCount', {'count': count});
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<int> getBadgeCount() async {
    try {
      final result = await _channel.invokeMethod<int>('getBadgeCount');
      return result ?? 0;
    } catch (error) {
      return 0;
    }
  }

  @override
  Future<bool> clearBadge() async {
    return await setBadgeCount(0);
  }

  // === LIVE ACTIVITIES (iOS-specific) ===

  @override
  Future<String?> showAdvancedNotification(UnifiedNotification notification) async {
    try {
      // For iOS, advanced notifications are Live Activities
      if (notification.type == NotificationType.timerComplete || 
          notification.workoutId != null) {
        return await _startLiveActivity(notification);
      }
      
      // Fall back to regular notification
      return await scheduleLocalNotification(notification);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error showing advanced notification: $error');
      }
      return null;
    }
  }

  @override
  Future<bool> updateLiveActivity(String activityId, Map<String, dynamic> data) async {
    try {
      await _liveActivityChannel.invokeMethod('updateLiveActivity', {
        'activityId': activityId,
        'data': data,
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> cancelLiveActivity(String activityId) async {
    try {
      await _liveActivityChannel.invokeMethod('cancelLiveActivity', {
        'activityId': activityId,
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<String?> _startLiveActivity(UnifiedNotification notification) async {
    try {
      final activityId = await _liveActivityChannel.invokeMethod<String>('startLiveActivity', {
        'type': notification.type.name,
        'title': notification.title,
        'body': notification.body,
        'workoutId': notification.workoutId,
        'exerciseId': notification.exerciseId,
        'scheduledTime': notification.scheduledTime.millisecondsSinceEpoch,
        'payload': notification.payload,
      });
      
      return activityId;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error starting Live Activity: $error');
      }
      return null;
    }
  }

  // === SYSTEM INTEGRATION ===

  @override
  Future<bool> areSystemNotificationsEnabled() async {
    return await hasPermissions();
  }

  @override
  Future<bool> openSystemSettings() async {
    try {
      await _channel.invokeMethod('openSystemSettings');
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<String> getSystemImportanceLevel() async {
    try {
      final permissions = await _iosPlugin.checkPermissions();
      return (permissions?.isEnabled ?? false) ? 'authorized' : 'denied';
    } catch (error) {
      return 'unknown';
    }
  }

  // === PERFORMANCE MONITORING ===

  @override
  Future<NotificationPerformanceMetrics> getPerformanceMetrics() async {
    try {
      final metricsData = await _channel.invokeMethod<Map<dynamic, dynamic>>('getPerformanceMetrics');
      
      if (metricsData == null) {
        return NotificationPerformanceMetrics.empty();
      }

      return NotificationPerformanceMetrics(
        averageDeliveryLatency: Duration(milliseconds: metricsData['averageDeliveryLatency'] ?? 0),
        averageSchedulingLatency: Duration(milliseconds: metricsData['averageSchedulingLatency'] ?? 0),
        totalNotificationsScheduled: metricsData['totalNotificationsScheduled'] ?? 0,
        totalNotificationsDelivered: metricsData['totalNotificationsDelivered'] ?? 0,
        totalNotificationsFailed: metricsData['totalNotificationsFailed'] ?? 0,
        memoryUsageMB: (metricsData['memoryUsageMB'] ?? 0.0).toDouble(),
        cpuUsagePercent: (metricsData['cpuUsagePercent'] ?? 0.0).toDouble(),
        lastMetricsUpdate: DateTime.now(),
        deliveryCountByType: {},
        latencyByPlatform: {'ios': Duration(milliseconds: metricsData['iosLatency'] ?? 0)},
      );
    } catch (error) {
      return NotificationPerformanceMetrics.empty();
    }
  }

  @override
  Future<bool> performHealthCheck() async {
    try {
      final hasPerms = await hasPermissions();
      final canSchedule = await _testNotificationScheduling();
      final systemEnabled = await areSystemNotificationsEnabled();
      
      return hasPerms && canSchedule && systemEnabled;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getResourceUsage() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getResourceUsage');
      return Map<String, dynamic>.from(result ?? {});
    } catch (error) {
      return {};
    }
  }

  // === TESTING AND DEBUGGING ===

  @override
  Future<bool> sendTestNotification(String title, String body) async {
    try {
      final testNotification = UnifiedNotification(
        type: NotificationType.systemUpdate,
        title: title,
        body: body,
        scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      );
      
      await scheduleLocalNotification(testNotification);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<List<String>> validateConfiguration() async {
    final issues = <String>[];
    
    try {
      if (!_isInitialized) {
        issues.add('iOS adapter not initialized');
      }
      
      if (!await hasPermissions()) {
        issues.add('Notification permissions not granted');
      }
      
      if (!await areSystemNotificationsEnabled()) {
        issues.add('System notifications disabled');
      }
      
      final sounds = _getAvailableSounds();
      if (sounds.isEmpty) {
        issues.add('No notification sounds available');
      }
      
    } catch (error) {
      issues.add('Configuration validation failed: $error');
    }
    
    return issues;
  }

  @override
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final info = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDebugInfo');
      return Map<String, dynamic>.from(info ?? {});
    } catch (error) {
      return {'error': error.toString()};
    }
  }

  // === HELPER METHODS ===

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationDelivered':
        await trackNotificationDelivered(
          call.arguments['notificationId'],
          Map<String, dynamic>.from(call.arguments['metadata'] ?? {}),
        );
        break;
      case 'onNotificationInteraction':
        await trackNotificationInteraction(
          call.arguments['notificationId'],
          call.arguments['interactionType'],
        );
        break;
      default:
        if (kDebugMode) {
          debugPrint('Unhandled iOS method call: ${call.method}');
        }
    }
  }

  Future<void> _handleLiveActivityCall(MethodCall call) async {
    switch (call.method) {
      case 'onLiveActivityInteraction':
        await trackNotificationInteraction(
          call.arguments['activityId'],
          'live_activity_${call.arguments['interactionType']}',
        );
        break;
      default:
        if (kDebugMode) {
          debugPrint('Unhandled Live Activity method call: ${call.method}');
        }
    }
  }

  List<String> _getAvailableSounds() {
    return [
      'timer_complete.caf',
      'achievement_unlocked.caf',
      'workout_reminder.caf',
      'progress_milestone.caf',
      'rest_timer_complete.caf',
    ];
  }

  List<Map<String, dynamic>> _getNotificationCategories() {
    return [
      {
        'identifier': 'TIMER_COMPLETE',
        'actions': [
          {'identifier': 'STOP_TIMER', 'title': 'Stop', 'options': ['destructive']},
          {'identifier': 'START_REST', 'title': 'Start Rest', 'options': []},
        ],
      },
      {
        'identifier': 'WORKOUT_REMINDER', 
        'actions': [
          {'identifier': 'START_WORKOUT', 'title': 'Start Now', 'options': []},
          {'identifier': 'SNOOZE_REMINDER', 'title': 'Remind Later', 'options': []},
        ],
      },
      {
        'identifier': 'ACHIEVEMENT',
        'actions': [
          {'identifier': 'VIEW_ACHIEVEMENT', 'title': 'View', 'options': []},
          {'identifier': 'SHARE_ACHIEVEMENT', 'title': 'Share', 'options': []},
        ],
      },
    ];
  }

  String _getCategoryForType(NotificationType type) {
    switch (type) {
      case NotificationType.timerComplete:
        return 'TIMER_COMPLETE';
      case NotificationType.workoutReminder:
        return 'WORKOUT_REMINDER';
      case NotificationType.achievementUnlocked:
        return 'ACHIEVEMENT';
      default:
        return 'DEFAULT';
    }
  }

  InterruptionLevel _getInterruptionLevel(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return InterruptionLevel.passive;
      case NotificationPriority.normal:
        return InterruptionLevel.active;
      case NotificationPriority.high:
        return InterruptionLevel.timeSensitive;
      case NotificationPriority.critical:
        return InterruptionLevel.critical;
    }
  }

  Future<bool> _testNotificationScheduling() async {
    try {
      final testId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      await _localNotifications.zonedSchedule(
        testId.hashCode,
        'Test',
        'Test notification',
        TZ.TZDateTime.from(DateTime.now().add(const Duration(days: 365)), TZ.local), // Far future
        const NotificationDetails(
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      // Cancel immediately
      await _localNotifications.cancel(testId.hashCode);
      return true;
    } catch (error) {
      return false;
    }
  }

  // === ABSTRACT METHOD IMPLEMENTATIONS ===

  @override
  Future<bool> createNotificationChannels() async {
    // iOS doesn't use channels, but we return true for compatibility
    return true;
  }

  @override
  Future<bool> updateNotificationChannel(NotificationType type, Map<String, dynamic> settings) async {
    // iOS doesn't use channels, but we can update category settings
    return true;
  }

  @override
  Future<bool> deleteNotificationChannel(NotificationType type) async {
    // iOS doesn't use channels
    return true;
  }

  @override
  Future<bool> showHeadsUpNotification(UnifiedNotification notification) async {
    // iOS doesn't have heads-up notifications, use regular notification with high priority
    return await scheduleLocalNotification(notification) != null;
  }

  @override
  Future<bool> groupNotifications(List<String> notificationIds, String groupKey) async {
    // iOS uses thread identifier for grouping
    return true;
  }

  @override
  Future<bool> setGroupSummary(String notificationId, String groupKey) async {
    // iOS doesn't need explicit group summaries
    return true;
  }

  @override
  Future<bool> clearNotificationGroup(String groupKey) async {
    // Clear all notifications with the same thread identifier
    try {
      await _channel.invokeMethod('clearNotificationGroup', {'groupKey': groupKey});
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<void> trackNotificationDelivered(String notificationId, Map<String, dynamic> metadata) async {
    try {
      await _channel.invokeMethod('trackNotificationDelivered', {
        'notificationId': notificationId,
        'metadata': metadata,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error tracking notification delivery: $error');
      }
    }
  }

  @override
  Future<void> trackNotificationInteraction(String notificationId, String interactionType) async {
    try {
      await _channel.invokeMethod('trackNotificationInteraction', {
        'notificationId': notificationId,
        'interactionType': interactionType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error tracking notification interaction: $error');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getDeliveryStats() async {
    try {
      final stats = await _channel.invokeMethod<Map<dynamic, dynamic>>('getDeliveryStats');
      return Map<String, dynamic>.from(stats ?? {});
    } catch (error) {
      return {};
    }
  }

  @override
  Future<void> handleAppStateChange(String state) async {
    try {
      await _channel.invokeMethod('handleAppStateChange', {'state': state});
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error handling app state change: $error');
      }
    }
  }
}