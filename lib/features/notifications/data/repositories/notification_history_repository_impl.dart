/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/data/repositories
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION HISTORY REPOSITORY IMPLEMENTATION
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_remote_datasource.dart';

/// Implementation of NotificationHistoryRepository
///
/// **Data Flow**:
/// ```
/// Notification delivered
///       ↓
/// saveNotification() called
///       ↓
/// 1. Save to Firestore (source of truth)
/// 2. Cache to SharedPreferences (last 100)
///       ↓
/// User views history
///       ↓
/// getHistory() called
///       ↓
/// 1. Try local cache first (offline support)
/// 2. Fallback to Firestore if not cached
/// ```
class NotificationHistoryRepositoryImpl
    implements NotificationHistoryRepository {

  NotificationHistoryRepositoryImpl({
    required NotificationLocalDataSource localDataSource,
    required NotificationRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;
  final NotificationLocalDataSource _localDataSource;
  final NotificationRemoteDataSource _remoteDataSource;

  // === CRUD Operations ===

  @override
  Future<List<UnifiedNotification>> getHistory({
    int limit = 50,
    DateTime? since,
    DateTime? until,
    List<NotificationType>? types,
    bool unreadOnly = false,
  }) async {
    // Try Firestore first (source of truth)
    final remoteHistory = await _remoteDataSource.getNotificationHistory(
      limit: limit,
      since: since,
      until: until,
      types: types,
      unreadOnly: unreadOnly,
    );

    if (remoteHistory.isNotEmpty) {
      // Update local cache (last 100)
      await _localDataSource.cacheNotificationHistory(remoteHistory);
      return remoteHistory;
    }

    // Fallback to local cache (offline mode)
    final localHistory = await _localDataSource.getCachedNotificationHistory();

    // Apply filters manually (local cache doesn't support complex queries)
    var filtered = localHistory;

    if (since != null) {
      filtered = filtered
          .where((n) => n.scheduledTime.isAfter(since))
          .toList();
    }

    if (until != null) {
      filtered = filtered
          .where((n) => n.scheduledTime.isBefore(until))
          .toList();
    }

    if (types != null && types.isNotEmpty) {
      filtered = filtered.where((n) => types.contains(n.type)).toList();
    }

    if (unreadOnly) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    // Sort by scheduled time (newest first)
    filtered.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

    // Apply limit
    return filtered.take(limit).toList();
  }

  @override
  Future<UnifiedNotification?> getNotificationById(String id) async {
    // Try Firestore first
    final remote = await _remoteDataSource.getNotificationById(id);

    if (remote != null) {
      return remote;
    }

    // Fallback to local cache
    final localHistory = await _localDataSource.getCachedNotificationHistory();
    return localHistory.firstWhere(
      (n) => n.id == id,
      orElse: () => throw Exception('Notification not found'),
    );
  }

  @override
  Future<void> saveNotification(UnifiedNotification notification) async {
    // Save to Firestore (source of truth)
    await _remoteDataSource.saveNotificationHistory(notification);

    // Update local cache
    final currentHistory =
        await _localDataSource.getCachedNotificationHistory();
    final updatedHistory = [notification, ...currentHistory];
    await _localDataSource.cacheNotificationHistory(updatedHistory);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Update Firestore
    await _remoteDataSource.markAsRead(notificationId);

    // Update local cache
    final localHistory = await _localDataSource.getCachedNotificationHistory();
    final updatedHistory = localHistory.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(readAt: DateTime.now()); // isRead is computed from readAt
      }
      return n;
    }).toList();

    await _localDataSource.cacheNotificationHistory(updatedHistory);
  }

  @override
  Future<void> markAllAsRead() async {
    // Update Firestore (batch)
    await _remoteDataSource.markAllAsRead();

    // Update local cache
    final localHistory = await _localDataSource.getCachedNotificationHistory();
    final updatedHistory = localHistory.map((n) {
      return n.copyWith(readAt: DateTime.now()); // isRead is computed from readAt
    }).toList();

    await _localDataSource.cacheNotificationHistory(updatedHistory);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    // Delete from Firestore
    await _remoteDataSource.deleteNotification(notificationId);

    // Remove from local cache
    final localHistory = await _localDataSource.getCachedNotificationHistory();
    final updatedHistory =
        localHistory.where((n) => n.id != notificationId).toList();

    await _localDataSource.cacheNotificationHistory(updatedHistory);
  }

  // === Search & Filter ===

  @override
  Future<List<UnifiedNotification>> searchNotifications(String query) async {
    // Use Firestore search (gets last 200 and filters in-memory)
    return await _remoteDataSource.searchNotifications(query);
  }

  @override
  Future<int> getUnreadCount() async {
    // Try Firestore first (accurate count)
    try {
      return await _remoteDataSource.getUnreadCount();
    } catch (e) {
      // Fallback to local cache (offline mode)
      final localHistory =
          await _localDataSource.getCachedNotificationHistory();
      return localHistory.where((n) => !n.isRead).length;
    }
  }

  // === Cleanup ===

  @override
  Future<int> cleanupExpiredNotifications() async {
    // Cleanup from Firestore (90-day TTL)
    final deletedCount = await _remoteDataSource.cleanupExpiredNotifications();

    // Refresh local cache
    final remoteHistory = await _remoteDataSource.getNotificationHistory(
      limit: 100,
    );
    await _localDataSource.cacheNotificationHistory(remoteHistory);

    return deletedCount;
  }

  @override
  Future<int> getStorageSizeBytes() async {
    // Estimate: 600 bytes per notification (avg)
    final count = await _remoteDataSource.getUnreadCount();
    return count * 600;
  }

  // === Real-Time Streams ===

  @override
  Stream<UnifiedNotification> watchNewNotifications() {
    return _remoteDataSource.watchNewNotifications();
  }

  @override
  Stream<int> watchUnreadCount() {
    return _remoteDataSource.watchUnreadCount();
  }
}
