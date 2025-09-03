import '../entities/unified_notification.dart';
import '../entities/unified_notification_state.dart';

/// Abstract repository interface for notification management
/// Follows Clean Architecture principles - domain layer defines the contract
abstract class NotificationRepository {
  
  // CRUD Operations
  Future<String> scheduleNotification(UnifiedNotification notification);
  Future<bool> cancelNotification(String notificationId);
  Future<UnifiedNotification?> getNotification(String notificationId);
  Future<List<UnifiedNotification>> getAllNotifications({
    int? limit,
    DateTime? since,
    List<NotificationType>? types,
  });
  Future<bool> updateNotification(UnifiedNotification notification);
  Future<bool> deleteNotification(String notificationId);
  
  // Batch Operations
  Future<List<String>> scheduleMultipleNotifications(List<UnifiedNotification> notifications);
  Future<bool> cancelMultipleNotifications(List<String> notificationIds);
  Future<bool> markMultipleAsRead(List<String> notificationIds);
  Future<int> deleteExpiredNotifications({Duration? olderThan});
  
  // Status and Tracking
  Future<NotificationDeliveryReceipt?> getDeliveryStatus(String notificationId);
  Future<Map<String, NotificationDeliveryReceipt>> getMultipleDeliveryStatus(List<String> notificationIds);
  Future<bool> markAsDelivered(String notificationId, {Map<String, dynamic>? platformData});
  Future<bool> markAsFailed(String notificationId, String error);
  Future<bool> markAsRead(String notificationId);
  
  // User Preferences
  Future<NotificationPreferences> getPreferences();
  Future<bool> updatePreferences(NotificationPreferences preferences);
  Future<bool> isNotificationTypeEnabled(NotificationType type);
  Future<List<TimeRange>> getQuietHours();
  
  // Metrics and Analytics
  Future<NotificationMetrics> getMetrics({DateTime? since});
  Future<List<NotificationError>> getRecentErrors({int limit = 10});
  Future<Map<NotificationType, int>> getDeliveryStatsByType({DateTime? since});
  Future<double> getDeliveryRate({DateTime? since});
  
  // Real-time Streams
  Stream<UnifiedNotification> get notificationStream;
  Stream<NotificationDeliveryReceipt> get deliveryReceiptStream;
  Stream<NotificationMetrics> get metricsStream;
  
  // Platform-specific
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  Future<List<String>> getPendingNotificationIds();
  Future<bool> areNotificationsEnabled();
  
  // Synchronization
  Future<bool> syncWithCloud();
  Future<DateTime?> getLastSyncTime();
  Future<bool> syncPreferencesWithCloud();
  
  // System Health
  Future<bool> isSystemHealthy();
  Future<Map<String, dynamic>> getSystemStatus();
  Future<bool> performHealthCheck();
  
  // Cleanup and Maintenance
  Future<int> cleanupOldNotifications();
  Future<bool> optimizeStorage();
  Future<Map<String, int>> getStorageStats();
}