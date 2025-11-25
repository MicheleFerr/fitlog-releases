/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/repositories
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION HISTORY REPOSITORY - Notification history & search
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';

/// Repository interface for notification history operations
///
/// **Responsibilities**:
/// - CRUD for notification history (past 90 days)
/// - Search & filtering
/// - Auto-cleanup (GDPR data retention)
/// - Unread count tracking
///
/// **Storage**:
/// - Local cache: Last 100 notifications (SharedPreferences)
/// - Remote persistence: Full 90-day history (Firestore)
abstract class NotificationHistoryRepository {
  // === CRUD Operations ===

  /// Get notification history with filters
  ///
  /// **Default**: Last 50 notifications, newest first
  ///
  /// **Filters**:
  /// - limit: Max notifications to return (default: 50)
  /// - since: Only notifications after this date
  /// - until: Only notifications before this date
  /// - types: Filter by notification types (e.g., [workoutReminder, recoveryAlert])
  /// - unreadOnly: Only unread notifications
  ///
  /// **Data source**: Firestore (cached locally for last 100)
  Future<List<UnifiedNotification>> getHistory({
    int limit = 50,
    DateTime? since,
    DateTime? until,
    List<NotificationType>? types,
    bool unreadOnly = false,
  });

  /// Get single notification by ID
  ///
  /// **Returns**: UnifiedNotification or null if not found
  Future<UnifiedNotification?> getNotificationById(String id);

  /// Save notification to history (after delivery)
  ///
  /// **Called by**: SmartNotificationService after notification delivered
  ///
  /// **Effect**:
  /// - Save to Firestore (with expiresAt = now + retentionDays)
  /// - Update local cache (if within last 100)
  Future<void> saveNotification(UnifiedNotification notification);

  /// Mark notification as read
  ///
  /// **Effect**:
  /// - Update Firestore document (isRead = true, readAt = now)
  /// - Update local cache
  /// - Decrement unread count
  Future<void> markAsRead(String notificationId);

  /// Mark all as read
  ///
  /// **Effect**:
  /// - Batch update Firestore (all unread → read)
  /// - Clear local unread cache
  /// - Reset unread count to 0
  Future<void> markAllAsRead();

  /// Delete notification
  ///
  /// **Effect**:
  /// - Delete from Firestore
  /// - Remove from local cache
  /// - Decrement unread count if was unread
  Future<void> deleteNotification(String notificationId);

  // === Search & Filter ===

  /// Search notifications by text (title/body)
  ///
  /// **Strategy**: Firestore query (case-insensitive substring match)
  ///
  /// **Example**: query='workout' matches 'Workout Reminder', 'Start your workout!'
  Future<List<UnifiedNotification>> searchNotifications(String query);

  /// Get unread count
  ///
  /// **Returns**: Number of unread notifications
  ///
  /// **Cached**: Value stored in SharedPreferences for instant access
  Future<int> getUnreadCount();

  // === Cleanup ===

  /// Delete notifications older than retention period
  ///
  /// **Strategy**:
  /// - Read dataRetentionDays from NotificationSettings (default: 90)
  /// - Find notifications with scheduledTime < (now - retentionDays)
  /// - Batch delete from Firestore (max 500 per batch)
  ///
  /// **Returns**: Number of notifications deleted
  ///
  /// **Called by**: Background Cloud Function (daily) + manual cleanup button
  Future<int> cleanupExpiredNotifications();

  /// Get storage size estimate
  ///
  /// **Returns**: Approximate bytes used by notification history
  ///
  /// **Calculation**: notificationCount * avgNotificationSize (600 bytes)
  Future<int> getStorageSizeBytes();

  // === Real-Time Streams ===

  /// Stream of new notifications (Firestore real-time)
  ///
  /// **Use case**: Show toast/banner when new notification delivered
  ///
  /// **Emits**: UnifiedNotification when new document added to Firestore
  Stream<UnifiedNotification> watchNewNotifications();

  /// Stream of unread count changes
  ///
  /// **Use case**: Update badge icon in navigation
  ///
  /// **Emits**: int (new unread count) when notifications marked read/delivered
  Stream<int> watchUnreadCount();
}
