/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/providers
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION HISTORY PROVIDER V2.0 - Riverpod providers for history & search
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/repositories/notification_history_repository_impl.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_settings_provider_v2.dart';

// === Repository Provider ===

/// Provider for NotificationHistoryRepository (v2.0)
final notificationHistoryRepositoryV2Provider =
    Provider<NotificationHistoryRepository>((ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);

  return NotificationHistoryRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// === State Providers ===

/// Provider for notification history (default: last 50, newest first)
///
/// **Parameters**:
/// - limit: Max notifications to return (default: 50)
/// - since: Only notifications after this date
/// - until: Only notifications before this date
/// - types: Filter by notification types
/// - unreadOnly: Only unread notifications
///
/// **Example**:
/// ```dart
/// final history = ref.watch(notificationHistoryProvider(
///   limit: 100,
///   unreadOnly: true,
/// ));
/// ```
final notificationHistoryProvider = FutureProvider.family<
    List<UnifiedNotification>,
    NotificationHistoryParams>((ref, params) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);

  return await repository.getHistory(
    limit: params.limit,
    since: params.since,
    until: params.until,
    types: params.types,
    unreadOnly: params.unreadOnly,
  );
});

/// Parameters for notification history queries
class NotificationHistoryParams {

  const NotificationHistoryParams({
    this.limit = 50,
    this.since,
    this.until,
    this.types,
    this.unreadOnly = false,
  });
  final int limit;
  final DateTime? since;
  final DateTime? until;
  final List<NotificationType>? types;
  final bool unreadOnly;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationHistoryParams &&
        other.limit == limit &&
        other.since == since &&
        other.until == until &&
        _listEquals(other.types, types) &&
        other.unreadOnly == unreadOnly;
  }

  @override
  int get hashCode {
    return Object.hash(
      limit,
      since,
      until,
      types,
      unreadOnly,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Provider for single notification by ID
final notificationByIdProvider =
    FutureProvider.family<UnifiedNotification?, String>((ref, id) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return await repository.getNotificationById(id);
});

/// Provider for unread count
final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return await repository.getUnreadCount();
});

/// Stream provider for unread count (real-time updates)
final unreadCountStreamProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return repository.watchUnreadCount();
});

/// Stream provider for new notifications (real-time)
final newNotificationsStreamProvider =
    StreamProvider<UnifiedNotification>((ref) {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return repository.watchNewNotifications();
});

// === Actions ===

/// Mark notification as read (use case: user taps notification)
final markAsReadProvider = Provider<Future<void> Function(String)>((ref) {
  return (String notificationId) async {
    final repository = ref.read(notificationHistoryRepositoryV2Provider);
    await repository.markAsRead(notificationId);

    // Refresh history
    ref.invalidate(notificationHistoryProvider);
    ref.invalidate(unreadCountProvider);
  };
});

/// Mark all notifications as read (use case: "Mark all as read" button)
final markAllAsReadProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(notificationHistoryRepositoryV2Provider);
    await repository.markAllAsRead();

    // Refresh history
    ref.invalidate(notificationHistoryProvider);
    ref.invalidate(unreadCountProvider);
  };
});

/// Delete notification (use case: swipe to delete)
final deleteNotificationProvider = Provider<Future<void> Function(String)>((ref) {
  return (String notificationId) async {
    final repository = ref.read(notificationHistoryRepositoryV2Provider);
    await repository.deleteNotification(notificationId);

    // Refresh history
    ref.invalidate(notificationHistoryProvider);
    ref.invalidate(unreadCountProvider);
  };
});

// === Search ===

/// Search notifications by text (title/body)
///
/// **Example**:
/// ```dart
/// final results = ref.watch(searchNotificationsProvider('workout'));
/// ```
final searchNotificationsProvider =
    FutureProvider.family<List<UnifiedNotification>, String>((ref, query) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return await repository.searchNotifications(query);
});

// === Cleanup ===

/// Cleanup expired notifications (90-day TTL)
///
/// **Use case**: Manual cleanup button or background Cloud Function
final cleanupExpiredNotificationsProvider =
    FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return await repository.cleanupExpiredNotifications();
});

/// Get storage size estimate (bytes)
final storageSizeBytesProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);
  return await repository.getStorageSizeBytes();
});

// === Convenience Providers (UI Helpers) ===

/// Provider for "today's notifications" (last 24h)
final todaysNotificationsProvider =
    FutureProvider<List<UnifiedNotification>>((ref) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);

  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(hours: 24));

  return await repository.getHistory(
    since: yesterday,
    limit: 100,
  );
});

/// Provider for "this week's notifications"
final thisWeeksNotificationsProvider =
    FutureProvider<List<UnifiedNotification>>((ref) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);

  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));

  return await repository.getHistory(
    since: weekAgo,
    limit: 200,
  );
});

/// Provider for unread notifications only
final unreadNotificationsProvider =
    FutureProvider<List<UnifiedNotification>>((ref) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);

  return await repository.getHistory(
    unreadOnly: true,
    limit: 100,
  );
});

/// Provider for notifications by type
final notificationsByTypeProvider = FutureProvider.family<
    List<UnifiedNotification>, NotificationType>((ref, type) async {
  final repository = ref.watch(notificationHistoryRepositoryV2Provider);

  return await repository.getHistory(
    types: [type],
    limit: 50,
  );
});
