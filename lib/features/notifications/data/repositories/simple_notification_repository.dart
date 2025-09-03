import 'dart:async';
import '../../domain/entities/unified_notification.dart';
import '../../domain/entities/unified_notification_state.dart';
import '../../domain/repositories/notification_repository.dart';

/// Simple in-memory implementation of NotificationRepository
/// Used for basic functionality until full Firebase implementation is needed
class SimpleNotificationRepository implements NotificationRepository {
  final List<UnifiedNotification> _notifications = [];
  final NotificationPreferences _preferences = NotificationPreferences.defaults();
  
  final StreamController<UnifiedNotification> _notificationStreamController = StreamController.broadcast();
  final StreamController<NotificationDeliveryReceipt> _deliveryReceiptStreamController = StreamController.broadcast();
  final StreamController<NotificationMetrics> _metricsStreamController = StreamController.broadcast();

  // === CRUD Operations ===
  
  @override
  Future<String> scheduleNotification(UnifiedNotification notification) async {
    _notifications.add(notification);
    _notificationStreamController.add(notification);
    
    // Simulate delivery receipt after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      final receipt = NotificationDeliveryReceipt(
        notificationId: notification.id,
        status: NotificationDeliveryStatus.delivered,
        timestamp: DateTime.now(),
      );
      _deliveryReceiptStreamController.add(receipt);
    });
    
    return notification.id;
  }

  @override
  Future<bool> cancelNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);
      return true;
    }
    return false;
  }

  @override
  Future<UnifiedNotification?> getNotification(String notificationId) async {
    try {
      return _notifications.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<UnifiedNotification>> getAllNotifications({
    int? limit,
    DateTime? since,
    List<NotificationType>? types,
  }) async {
    var filtered = _notifications.where((n) {
      if (since != null && n.createdAt.isBefore(since)) return false;
      if (types != null && !types.contains(n.type)) return false;
      return true;
    }).toList();
    
    // Sort by creation time (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }
    
    return filtered;
  }

  @override
  Future<bool> updateNotification(UnifiedNotification notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _notifications[index] = notification;
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    return await cancelNotification(notificationId);
  }

  // === Batch Operations ===
  
  @override
  Future<List<String>> scheduleMultipleNotifications(List<UnifiedNotification> notifications) async {
    final results = <String>[];
    for (final notification in notifications) {
      final id = await scheduleNotification(notification);
      results.add(id);
    }
    return results;
  }

  @override
  Future<bool> cancelMultipleNotifications(List<String> notificationIds) async {
    bool allSuccess = true;
    for (final id in notificationIds) {
      final success = await cancelNotification(id);
      if (!success) allSuccess = false;
    }
    return allSuccess;
  }

  @override
  Future<bool> markMultipleAsRead(List<String> notificationIds) async {
    for (final id in notificationIds) {
      await markAsRead(id);
    }
    return true;
  }

  @override
  Future<int> deleteExpiredNotifications({Duration? olderThan}) async {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(days: 30));
    final toRemove = _notifications.where((n) => n.createdAt.isBefore(cutoff)).toList();
    
    for (final notification in toRemove) {
      _notifications.remove(notification);
    }
    
    return toRemove.length;
  }

  // === Status and Tracking ===
  
  @override
  Future<NotificationDeliveryReceipt?> getDeliveryStatus(String notificationId) async {
    // Simple implementation - assume delivered if notification exists
    final notification = await getNotification(notificationId);
    if (notification != null) {
      return NotificationDeliveryReceipt(
        notificationId: notificationId,
        status: NotificationDeliveryStatus.delivered,
        timestamp: notification.deliveredAt ?? DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<Map<String, NotificationDeliveryReceipt>> getMultipleDeliveryStatus(List<String> notificationIds) async {
    final results = <String, NotificationDeliveryReceipt>{};
    for (final id in notificationIds) {
      final receipt = await getDeliveryStatus(id);
      if (receipt != null) {
        results[id] = receipt;
      }
    }
    return results;
  }

  @override
  Future<bool> markAsDelivered(String notificationId, {Map<String, dynamic>? platformData}) async {
    final notification = await getNotification(notificationId);
    if (notification != null) {
      final updated = notification.markAsDelivered();
      await updateNotification(updated);
      return true;
    }
    return false;
  }

  @override
  Future<bool> markAsFailed(String notificationId, String error) async {
    final notification = await getNotification(notificationId);
    if (notification != null) {
      final updated = notification.markAsFailed(error);
      await updateNotification(updated);
      return true;
    }
    return false;
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    final notification = await getNotification(notificationId);
    if (notification != null) {
      final updated = notification.markAsRead();
      await updateNotification(updated);
      return true;
    }
    return false;
  }

  // === User Preferences ===
  
  @override
  Future<NotificationPreferences> getPreferences() async {
    return _preferences;
  }

  @override
  Future<bool> updatePreferences(NotificationPreferences preferences) async {
    // In a real implementation, this would save to storage
    return true;
  }

  @override
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    final prefs = await getPreferences();
    return prefs.typePreferences[type] ?? true;
  }

  @override
  Future<List<TimeRange>> getQuietHours() async {
    final prefs = await getPreferences();
    return prefs.quietHours;
  }

  // === Metrics and Analytics ===
  
  @override
  Future<NotificationMetrics> getMetrics({DateTime? since}) async {
    final cutoff = since ?? DateTime.now().subtract(const Duration(days: 7));
    final recentNotifications = _notifications.where((n) => n.createdAt.isAfter(cutoff)).toList();
    
    final totalScheduled = recentNotifications.length;
    final totalDelivered = recentNotifications.where((n) => n.isDelivered).length;
    final totalFailed = recentNotifications.where((n) => n.isFailed).length;
    final totalRead = recentNotifications.where((n) => n.isRead).length;
    
    final deliveryByType = <NotificationType, int>{};
    for (final notification in recentNotifications.where((n) => n.isDelivered)) {
      deliveryByType[notification.type] = (deliveryByType[notification.type] ?? 0) + 1;
    }
    
    return NotificationMetrics(
      totalScheduled: totalScheduled,
      totalDelivered: totalDelivered,
      totalFailed: totalFailed,
      totalRead: totalRead,
      duplicatesPrevented: 0,
      deliveryByType: deliveryByType,
      recentErrors: [],
      averageSchedulingLatency: const Duration(milliseconds: 100),
      averageDeliveryLatency: const Duration(seconds: 1),
      batteryImpact: 0.5,
    );
  }

  @override
  Future<List<NotificationError>> getRecentErrors({int limit = 10}) async {
    return []; // No errors in simple implementation
  }

  @override
  Future<Map<NotificationType, int>> getDeliveryStatsByType({DateTime? since}) async {
    final metrics = await getMetrics(since: since);
    return metrics.deliveryByType;
  }

  @override
  Future<double> getDeliveryRate({DateTime? since}) async {
    final metrics = await getMetrics(since: since);
    return metrics.deliveryRate;
  }

  // === Real-time Streams ===
  
  @override
  Stream<UnifiedNotification> get notificationStream => _notificationStreamController.stream;

  @override
  Stream<NotificationDeliveryReceipt> get deliveryReceiptStream => _deliveryReceiptStreamController.stream;

  @override
  Stream<NotificationMetrics> get metricsStream => _metricsStreamController.stream;

  // === Platform-specific ===
  
  @override
  Future<bool> requestPermissions() async {
    return true; // Assume permissions granted in simple implementation
  }

  @override
  Future<bool> hasPermissions() async {
    return true;
  }

  @override
  Future<List<String>> getPendingNotificationIds() async {
    return _notifications.where((n) => n.isPending).map((n) => n.id).toList();
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return true;
  }

  // === Synchronization ===
  
  @override
  Future<bool> syncWithCloud() async {
    return true; // No cloud sync in simple implementation
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return DateTime.now();
  }

  @override
  Future<bool> syncPreferencesWithCloud() async {
    return true;
  }

  // === System Health ===
  
  @override
  Future<bool> isSystemHealthy() async {
    return true;
  }

  @override
  Future<Map<String, dynamic>> getSystemStatus() async {
    return {
      'status': 'healthy',
      'notificationCount': _notifications.length,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<bool> performHealthCheck() async {
    return true;
  }

  // === Cleanup and Maintenance ===
  
  @override
  Future<int> cleanupOldNotifications() async {
    return await deleteExpiredNotifications();
  }

  @override
  Future<bool> optimizeStorage() async {
    return true; // No storage optimization needed for in-memory
  }

  @override
  Future<Map<String, int>> getStorageStats() async {
    return {
      'totalNotifications': _notifications.length,
      'memoryUsageBytes': _notifications.length * 1000, // Rough estimate
    };
  }
}