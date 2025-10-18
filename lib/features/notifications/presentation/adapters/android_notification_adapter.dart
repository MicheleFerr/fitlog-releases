import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as TZ;
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification_state.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/adapters/notification_platform_adapter.dart';
import 'package:flutter/foundation.dart';

/// Android-specific implementation of the notification platform adapter
/// Integrates with Android notification system, channels, and FCM
class AndroidNotificationAdapter implements NotificationPlatformAdapter {
  static const MethodChannel _channel = MethodChannel('com.gymbro.notifications.android');
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  late AndroidFlutterLocalNotificationsPlugin _androidPlugin;
  
  // Android-specific notification channels
  static const Map<NotificationType, AndroidNotificationChannel> _notificationChannels = {
    NotificationType.timerComplete: AndroidNotificationChannel(
      'timer_complete',
      'Timer Complete',
      description: 'Notifications when workout timers complete',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('timer_complete'),
    ),
    NotificationType.workoutReminder: AndroidNotificationChannel(
      'workout_reminder',
      'Workout Reminders',
      description: 'Reminders to start or continue workouts',
      importance: Importance.defaultImportance,
      sound: RawResourceAndroidNotificationSound('workout_reminder'),
    ),
    NotificationType.achievementUnlocked: AndroidNotificationChannel(
      'achievements',
      'Achievements',
      description: 'Workout achievements and milestones',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('achievement_unlocked'),
      enableVibration: true,
    ),
    NotificationType.progressMilestone: AndroidNotificationChannel(
      'progress',
      'Progress Updates',
      description: 'Updates on your fitness progress and improvements',
      importance: Importance.defaultImportance,
    ),
    NotificationType.restReminder: AndroidNotificationChannel(
      'rest_timer',
      'Rest Timer',
      description: 'Rest period notifications during workouts',
      importance: Importance.defaultImportance,
      sound: RawResourceAndroidNotificationSound('rest_timer_complete'),
    ),
    NotificationType.workoutSummary: AndroidNotificationChannel(
      'workout_summary',
      'Workout Summary',
      description: 'Summary of completed workouts',
      importance: Importance.low,
    ),
    NotificationType.streakReminder: AndroidNotificationChannel(
      'streak_reminder',
      'Streak Reminders',
      description: 'Reminders to maintain workout streaks',
      importance: Importance.defaultImportance,
    ),
    NotificationType.friendActivity: AndroidNotificationChannel(
      'social',
      'Friend Activity',
      description: 'Updates from friends and social features',
      importance: Importance.low,
    ),
    NotificationType.coachMessage: AndroidNotificationChannel(
      'coaching',
      'Coach Messages',
      description: 'Messages and tips from your virtual coach',
      importance: Importance.defaultImportance,
    ),
    NotificationType.systemUpdate: AndroidNotificationChannel(
      'system',
      'System Updates',
      description: 'App updates and system notifications',
      importance: Importance.defaultImportance,
    ),
    NotificationType.promotional: AndroidNotificationChannel(
      'promotional',
      'Promotions',
      description: 'Special offers and promotional content',
      importance: Importance.low,
    ),
    NotificationType.emergency: AndroidNotificationChannel(
      'emergency',
      'Emergency',
      description: 'Critical emergency notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
  };

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get Android-specific plugin
      _androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!;
      
      // Initialize local notifications with Android settings
      const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
      const initSettings = InitializationSettings(android: androidSettings);
      
      await _localNotifications.initialize(initSettings);

      // Create notification channels
      await createNotificationChannels();

      // Setup platform channel
      _channel.setMethodCallHandler(_handleMethodCall);

      // Initialize native Android components
      await _channel.invokeMethod('initialize', {
        'channels': _notificationChannels.map((type, channel) => 
          MapEntry(type.name, _channelToMap(channel))),
      });

      _isInitialized = true;
    } catch (error) {
      throw Exception('Failed to initialize Android notification adapter: $error');
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
        debugPrint('Error disposing Android notification adapter: $error');
      }
    }
  }

  // === PERMISSION MANAGEMENT ===

  @override
  Future<bool> hasPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> hasCriticalAlertPermissions() async {
    // Android doesn't have separate critical alert permissions
    return await hasPermissions();
  }

  @override
  Future<bool> requestCriticalAlertPermissions() async {
    // Android doesn't require separate critical alert permissions
    return await hasPermissions();
  }

  // === NOTIFICATION DELIVERY ===

  @override
  Future<String> scheduleLocalNotification(UnifiedNotification notification) async {
    try {
      final channel = _notificationChannels[notification.type]!;
      
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: _getPriorityForNotification(notification.priority),
        sound: notification.soundName != null 
            ? RawResourceAndroidNotificationSound(notification.soundName!)
            : channel.sound,
        // largeIcon requires file-based icons, skip for now
        largeIcon: null,
        color: notification.androidConfig?.color != null 
            ? Color(notification.androidConfig!.color!)
            : null,
        autoCancel: notification.androidConfig?.autoCancel ?? true,
        ongoing: notification.androidConfig?.ongoing ?? false,
        groupKey: notification.androidConfig?.group,
        setAsGroupSummary: notification.androidConfig?.groupSummary ?? false,
        actions: notification.actions?.map((action) => AndroidNotificationAction(
          action.id,
          action.title,
          // Skip icon for now - requires drawable resources
        )).toList(),
        styleInformation: _getStyleInformation(notification),
      );

      final details = NotificationDetails(android: androidDetails);

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
      throw Exception('Failed to schedule Android notification: $error');
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
      await _localNotifications.cancelAll();
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
      // Return null for now - FCM integration removed
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

  // === NOTIFICATION CHANNELS ===

  @override
  Future<bool> createNotificationChannels() async {
    try {
      for (final channel in _notificationChannels.values) {
        await _androidPlugin.createNotificationChannel(channel);
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error creating notification channels: $error');
      }
      return false;
    }
  }

  @override
  Future<bool> updateNotificationChannel(NotificationType type, Map<String, dynamic> settings) async {
    try {
      final channel = _notificationChannels[type];
      if (channel == null) return false;

      final updatedChannel = AndroidNotificationChannel(
        channel.id,
        settings['name'] ?? channel.name,
        description: settings['description'] ?? channel.description,
        importance: _parseImportance(settings['importance']) ?? channel.importance,
        sound: settings['sound'] != null 
            ? RawResourceAndroidNotificationSound(settings['sound'])
            : channel.sound,
        enableVibration: settings['enableVibration'] ?? channel.enableVibration,
        enableLights: settings['enableLights'] ?? channel.enableLights,
        playSound: settings['playSound'] ?? channel.playSound,
      );

      await _androidPlugin.createNotificationChannel(updatedChannel);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> deleteNotificationChannel(NotificationType type) async {
    try {
      final channel = _notificationChannels[type];
      if (channel == null) return false;

      await _androidPlugin.deleteNotificationChannel(channel.id);
      return true;
    } catch (error) {
      return false;
    }
  }

  // === ADVANCED FEATURES ===

  @override
  Future<String?> showAdvancedNotification(UnifiedNotification notification) async {
    try {
      // For Android, advanced notifications use BigPictureStyle, InboxStyle, etc.
      return await scheduleLocalNotification(notification);
    } catch (error) {
      return null;
    }
  }

  @override
  Future<bool> showHeadsUpNotification(UnifiedNotification notification) async {
    try {
      // Create a high priority notification for heads-up display
      final channel = _notificationChannels[notification.type]!;
      
      final androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      final details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        details,
        payload: json.encode({
          'notificationId': notification.id,
          'type': notification.type.name,
          'payload': notification.payload,
        }),
      );

      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> groupNotifications(List<String> notificationIds, String groupKey) async {
    try {
      // Android uses groupKey for notification grouping
      for (final id in notificationIds) {
        await _channel.invokeMethod('updateNotificationGroup', {
          'notificationId': id,
          'groupKey': groupKey,
        });
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> setGroupSummary(String notificationId, String groupKey) async {
    try {
      await _channel.invokeMethod('setGroupSummary', {
        'notificationId': notificationId,
        'groupKey': groupKey,
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> clearNotificationGroup(String groupKey) async {
    try {
      await _channel.invokeMethod('clearNotificationGroup', {'groupKey': groupKey});
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
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getPlatformSettings');
      return Map<String, dynamic>.from(result ?? {});
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
      final channel = _notificationChannels[type];
      if (channel == null) return false;

      await updateNotificationChannel(type, {
        'sound': soundName,
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
      // Android doesn't have a universal badge system, but we can use shortcuts
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
      final result = await _channel.invokeMethod<String>('getSystemImportanceLevel');
      return result ?? 'unknown';
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
        latencyByPlatform: {'android': Duration(milliseconds: metricsData['androidLatency'] ?? 0)},
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
        issues.add('Android adapter not initialized');
      }
      
      if (!await hasPermissions()) {
        issues.add('Notification permissions not granted');
      }
      
      if (!await areSystemNotificationsEnabled()) {
        issues.add('System notifications disabled');
      }
      
      // Check notification channels
      for (final entry in _notificationChannels.entries) {
        try {
          await _androidPlugin.createNotificationChannel(entry.value);
        } catch (error) {
          issues.add('Failed to create channel for ${entry.key.name}: $error');
        }
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
          debugPrint('Unhandled Android method call: ${call.method}');
        }
    }
  }

  Priority _getPriorityForNotification(NotificationPriority priority) {
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

  Importance? _parseImportance(dynamic importance) {
    if (importance == null) return null;
    
    switch (importance.toString().toLowerCase()) {
      case 'min':
        return Importance.min;
      case 'low':
        return Importance.low;
      case 'default':
        return Importance.defaultImportance;
      case 'high':
        return Importance.high;
      case 'max':
        return Importance.max;
      default:
        return null;
    }
  }

  StyleInformation? _getStyleInformation(UnifiedNotification notification) {
    // Determine style based on notification content and type
    if (notification.payload?['messages'] != null) {
      final messages = notification.payload!['messages'] as List<String>;
      return InboxStyleInformation(
        messages,
        contentTitle: notification.title,
        summaryText: '${messages.length} messages',
      );
    }

    if (notification.body.length > 100) {
      return BigTextStyleInformation(
        notification.body,
        contentTitle: notification.title,
      );
    }

    return null;
  }

  Map<String, dynamic> _channelToMap(AndroidNotificationChannel channel) {
    return {
      'id': channel.id,
      'name': channel.name,
      'description': channel.description,
      'importance': channel.importance.name,
      'sound': channel.sound?.sound,
      'enableVibration': channel.enableVibration,
      'enableLights': channel.enableLights,
      'playSound': channel.playSound,
    };
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
          android: AndroidNotificationDetails(
            'system',
            'System Updates',
            channelDescription: 'Test channel',
          ),
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
  Future<bool> updateLiveActivity(String activityId, Map<String, dynamic> data) async {
    // Android doesn't have Live Activities, but could implement similar with persistent notifications
    return false;
  }

  @override
  Future<bool> cancelLiveActivity(String activityId) async {
    // Android doesn't have Live Activities
    return false;
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