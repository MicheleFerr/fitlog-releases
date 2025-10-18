/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/repositories
/// 🎯 Feature: smart_notifications
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION REPOSITORY INTERFACE - Contract for notification operations
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification_state.dart';

/// Abstract repository interface for notification operations
abstract class NotificationRepository {
  // === INITIALIZATION ===

  /// Initialize notification system
  Future<void> initialize() async {
    // Default implementation - can be overridden
  }

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Check if permissions are granted
  Future<bool> hasPermissions();

  // === SCHEDULING ===

  /// Schedule a notification
  Future<String> scheduleNotification(UnifiedNotification notification);

  /// Schedule multiple notifications
  Future<List<String>> scheduleMultipleNotifications(
    List<UnifiedNotification> notifications,
  );

  /// Cancel a scheduled notification by ID
  Future<bool> cancelNotification(String notificationId);

  /// Cancel multiple notifications by IDs
  Future<bool> cancelMultipleNotifications(List<String> notificationIds);

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    final pendingIds = await getPendingNotificationIds();
    await cancelMultipleNotifications(pendingIds);
  }

  // === QUERIES ===

  /// Get all pending scheduled notifications
  Future<List<UnifiedNotification>> getPendingNotifications() async {
    return getAllNotifications();
  }

  /// Get pending notifications by type
  Future<List<UnifiedNotification>> getPendingNotificationsByType(
    NotificationType type,
  ) async {
    return getAllNotifications(types: [type]);
  }

  /// Get pending notifications for a specific routine/workout
  Future<List<UnifiedNotification>> getPendingNotificationsForRoutine(
    String routineId,
  ) async {
    final all = await getAllNotifications();
    return all.where((n) => n.workoutId == routineId).toList();
  }

  /// Get notification by ID
  Future<UnifiedNotification?> getNotification(String notificationId);

  /// Get all notifications with optional filters
  Future<List<UnifiedNotification>> getAllNotifications({
    int? limit,
    DateTime? since,
    List<NotificationType>? types,
  });

  /// Get pending notification IDs
  Future<List<String>> getPendingNotificationIds();

  // === CRUD OPERATIONS ===

  /// Update an existing notification
  Future<bool> updateNotification(UnifiedNotification notification);

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId);

  /// Delete expired notifications
  Future<int> deleteExpiredNotifications({Duration? olderThan});

  // === BATCH OPERATIONS ===

  /// Mark multiple notifications as read
  Future<bool> markMultipleAsRead(List<String> notificationIds);

  // === STATUS AND TRACKING ===

  /// Get delivery status for a notification
  Future<NotificationDeliveryReceipt?> getDeliveryStatus(String notificationId);

  /// Get delivery status for multiple notifications
  Future<Map<String, NotificationDeliveryReceipt>> getMultipleDeliveryStatus(
    List<String> notificationIds,
  );

  /// Mark notification as delivered
  Future<bool> markAsDelivered(
    String notificationId, {
    Map<String, dynamic>? platformData,
  });

  /// Mark notification as failed
  Future<bool> markAsFailed(String notificationId, String error);

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId);

  // === USER PREFERENCES ===

  /// Get user notification preferences
  Future<NotificationPreferences> getPreferences();

  /// Update user notification preferences
  Future<bool> updatePreferences(NotificationPreferences preferences);

  /// Check if notification type is enabled
  Future<bool> isNotificationTypeEnabled(NotificationType type);

  /// Get quiet hours configuration
  Future<List<TimeRange>> getQuietHours();

  // === METRICS AND ANALYTICS ===

  /// Get notification metrics
  Future<NotificationMetrics> getMetrics({DateTime? since});

  /// Get recent errors
  Future<List<NotificationError>> getRecentErrors({int limit = 10});

  /// Get delivery stats by type
  Future<Map<NotificationType, int>> getDeliveryStatsByType({DateTime? since});

  /// Get overall delivery rate
  Future<double> getDeliveryRate({DateTime? since});

  // === REAL-TIME STREAMS ===

  /// Stream of new notifications
  Stream<UnifiedNotification> get notificationStream;

  /// Stream of delivery receipts
  Stream<NotificationDeliveryReceipt> get deliveryReceiptStream;

  /// Stream of metrics updates
  Stream<NotificationMetrics> get metricsStream;

  // === PLATFORM-SPECIFIC ===

  /// Check if notifications are enabled at system level
  Future<bool> areNotificationsEnabled();

  // === SYNCHRONIZATION ===

  /// Sync notifications with cloud
  Future<bool> syncWithCloud();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();

  /// Sync preferences with cloud
  Future<bool> syncPreferencesWithCloud();

  // === SYSTEM HEALTH ===

  /// Check if system is healthy
  Future<bool> isSystemHealthy();

  /// Get detailed system status
  Future<Map<String, dynamic>> getSystemStatus();

  /// Perform health check
  Future<bool> performHealthCheck();

  // === CLEANUP AND MAINTENANCE ===

  /// Clean up old notifications
  Future<int> cleanupOldNotifications();

  /// Optimize storage
  Future<bool> optimizeStorage();

  /// Get storage statistics
  Future<Map<String, int>> getStorageStats();

  // === TESTING ===

  /// Show notification immediately (for testing)
  Future<void> showImmediateNotification({
    required String id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    // Create immediate notification
    final notification = UnifiedNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.systemUpdate,
      scheduledTime: DateTime.now(),
      payload: payload ?? {},
    );
    await scheduleNotification(notification);
  }
}
