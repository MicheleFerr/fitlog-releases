import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification_state.dart';

/// Abstract platform adapter for notification functionality
/// Provides a consistent interface for iOS and Android implementations
abstract class NotificationPlatformAdapter {
  
  // === PERMISSION MANAGEMENT ===
  
  /// Check if the app has notification permissions
  Future<bool> hasPermissions();
  
  /// Request notification permissions from the user
  Future<bool> requestPermissions();
  
  /// Check if critical alert permissions are available (iOS only)
  Future<bool> hasCriticalAlertPermissions();
  
  /// Request critical alert permissions (iOS only)
  Future<bool> requestCriticalAlertPermissions();
  
  // === NOTIFICATION DELIVERY ===
  
  /// Schedule a local notification
  Future<String> scheduleLocalNotification(UnifiedNotification notification);
  
  /// Schedule multiple local notifications in batch
  Future<List<String>> scheduleMultipleLocalNotifications(List<UnifiedNotification> notifications);
  
  /// Cancel a scheduled notification
  Future<bool> cancelLocalNotification(String notificationId);
  
  /// Cancel multiple notifications in batch
  Future<bool> cancelMultipleLocalNotifications(List<String> notificationIds);
  
  /// Get all pending notification IDs
  Future<List<String>> getPendingNotificationIds();
  
  /// Clear all delivered notifications from the notification tray
  Future<bool> clearAllDeliveredNotifications();
  
  // === PUSH NOTIFICATIONS ===
  
  /// Get the FCM/APN token for push notifications
  Future<String?> getPushToken();
  
  /// Handle incoming push notification
  Future<void> handlePushNotification(Map<String, dynamic> payload);
  
  /// Register for push notifications with server
  Future<bool> registerForPushNotifications(String token);
  
  /// Unregister from push notifications
  Future<bool> unregisterFromPushNotifications();
  
  // === PREFERENCE MANAGEMENT ===
  
  /// Update platform-specific notification preferences
  Future<bool> updatePreferences(NotificationPreferences preferences);
  
  /// Get current platform notification settings
  Future<Map<String, dynamic>> getPlatformSettings();
  
  /// Apply quiet hours settings to platform
  Future<bool> applyQuietHours(List<TimeRange> quietHours);
  
  /// Set notification sound for different types
  Future<bool> setNotificationSound(NotificationType type, String soundName);
  
  // === BADGE MANAGEMENT ===
  
  /// Set application badge count
  Future<bool> setBadgeCount(int count);
  
  /// Get current badge count
  Future<int> getBadgeCount();
  
  /// Clear application badge
  Future<bool> clearBadge();
  
  // === NOTIFICATION CHANNELS (Android) ===
  
  /// Create notification channels for different types
  Future<bool> createNotificationChannels();
  
  /// Update notification channel settings
  Future<bool> updateNotificationChannel(NotificationType type, Map<String, dynamic> settings);
  
  /// Delete notification channel
  Future<bool> deleteNotificationChannel(NotificationType type);
  
  // === SYSTEM INTEGRATION ===
  
  /// Check system notification settings
  Future<bool> areSystemNotificationsEnabled();
  
  /// Open system notification settings
  Future<bool> openSystemSettings();
  
  /// Get system notification importance level
  Future<String> getSystemImportanceLevel();
  
  // === ANALYTICS AND TRACKING ===
  
  /// Track notification delivery
  Future<void> trackNotificationDelivered(String notificationId, Map<String, dynamic> metadata);
  
  /// Track notification interaction
  Future<void> trackNotificationInteraction(String notificationId, String interactionType);
  
  /// Get delivery statistics
  Future<Map<String, dynamic>> getDeliveryStats();
  
  // === PERFORMANCE MONITORING ===
  
  /// Get notification system performance metrics
  Future<NotificationPerformanceMetrics> getPerformanceMetrics();
  
  /// Perform platform-specific health check
  Future<bool> performHealthCheck();
  
  /// Get system resource usage
  Future<Map<String, dynamic>> getResourceUsage();
  
  // === ADVANCED FEATURES ===
  
  /// Show notification with custom UI (iOS Live Activities, Android Custom Layout)
  Future<String?> showAdvancedNotification(UnifiedNotification notification);
  
  /// Update Live Activity (iOS only)
  Future<bool> updateLiveActivity(String activityId, Map<String, dynamic> data);
  
  /// Cancel Live Activity (iOS only)
  Future<bool> cancelLiveActivity(String activityId);
  
  /// Show heads-up notification (Android only)
  Future<bool> showHeadsUpNotification(UnifiedNotification notification);
  
  // === GROUPING AND BUNDLING ===
  
  /// Group notifications by type or conversation
  Future<bool> groupNotifications(List<String> notificationIds, String groupKey);
  
  /// Set notification as group summary
  Future<bool> setGroupSummary(String notificationId, String groupKey);
  
  /// Clear notification group
  Future<bool> clearNotificationGroup(String groupKey);
  
  // === TESTING AND DEBUGGING ===
  
  /// Send test notification for debugging
  Future<bool> sendTestNotification(String title, String body);
  
  /// Validate notification configuration
  Future<List<String>> validateConfiguration();
  
  /// Get debug information
  Future<Map<String, dynamic>> getDebugInfo();
  
  // === LIFECYCLE MANAGEMENT ===
  
  /// Initialize platform-specific components
  Future<void> initialize();
  
  /// Clean up resources
  Future<void> dispose();
  
  /// Handle app state changes
  Future<void> handleAppStateChange(String state);
}

/// Performance metrics for notification system
class NotificationPerformanceMetrics {

  const NotificationPerformanceMetrics({
    required this.averageDeliveryLatency,
    required this.averageSchedulingLatency,
    required this.totalNotificationsScheduled,
    required this.totalNotificationsDelivered,
    required this.totalNotificationsFailed,
    required this.memoryUsageMB,
    required this.cpuUsagePercent,
    required this.lastMetricsUpdate,
    required this.deliveryCountByType,
    required this.latencyByPlatform,
  });

  factory NotificationPerformanceMetrics.empty() {
    return NotificationPerformanceMetrics(
      averageDeliveryLatency: Duration.zero,
      averageSchedulingLatency: Duration.zero,
      totalNotificationsScheduled: 0,
      totalNotificationsDelivered: 0,
      totalNotificationsFailed: 0,
      memoryUsageMB: 0.0,
      cpuUsagePercent: 0.0,
      lastMetricsUpdate: DateTime.now(),
      deliveryCountByType: {},
      latencyByPlatform: {},
    );
  }
  final Duration averageDeliveryLatency;
  final Duration averageSchedulingLatency;
  final int totalNotificationsScheduled;
  final int totalNotificationsDelivered;
  final int totalNotificationsFailed;
  final double memoryUsageMB;
  final double cpuUsagePercent;
  final DateTime lastMetricsUpdate;
  final Map<NotificationType, int> deliveryCountByType;
  final Map<String, Duration> latencyByPlatform;

  // Performance indicators
  double get deliveryRate => totalNotificationsScheduled > 0 
      ? totalNotificationsDelivered / totalNotificationsScheduled 
      : 0.0;
      
  double get failureRate => totalNotificationsScheduled > 0 
      ? totalNotificationsFailed / totalNotificationsScheduled 
      : 0.0;
      
  bool get isHealthy => deliveryRate > 0.95 && failureRate < 0.05 && memoryUsageMB < 50.0;

  Map<String, dynamic> toJson() {
    return {
      'averageDeliveryLatency': averageDeliveryLatency.inMilliseconds,
      'averageSchedulingLatency': averageSchedulingLatency.inMilliseconds,
      'totalNotificationsScheduled': totalNotificationsScheduled,
      'totalNotificationsDelivered': totalNotificationsDelivered,
      'totalNotificationsFailed': totalNotificationsFailed,
      'memoryUsageMB': memoryUsageMB,
      'cpuUsagePercent': cpuUsagePercent,
      'lastMetricsUpdate': lastMetricsUpdate.toIso8601String(),
      'deliveryCountByType': deliveryCountByType.map((k, v) => MapEntry(k.name, v)),
      'latencyByPlatform': latencyByPlatform.map((k, v) => MapEntry(k, v.inMilliseconds)),
      'derivedMetrics': {
        'deliveryRate': deliveryRate,
        'failureRate': failureRate,
        'isHealthy': isHealthy,
      },
    };
  }
}