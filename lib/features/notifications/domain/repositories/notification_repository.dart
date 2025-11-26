/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/domain/repositories
/// Feature: Local Notifications System
/// Type: Repository Interface
///
/// Abstract repository for notification operations.
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';

/// Repository interface for notification operations.
abstract class NotificationRepository {
  /// Initialize the repository
  Future<void> initialize();

  /// Schedule a notification
  ///
  /// Returns the record ID if scheduled, null if blocked by anti-spam
  Future<String?> scheduleNotification({
    required NotificationType type,
    required NotificationMessage message,
    required DateTime scheduledTime,
    String? context,
    int? inactivityDay,
  });

  /// Show a notification immediately
  ///
  /// Returns the record ID if shown, null if blocked by anti-spam
  Future<String?> showNotificationNow({
    required NotificationType type,
    required NotificationMessage message,
    String? context,
  });

  /// Cancel a scheduled notification by record ID
  Future<void> cancelNotification(String recordId);

  /// Cancel all notifications of a specific type
  Future<void> cancelNotificationsByType(NotificationType type);

  /// Mark a notification as opened (called when user taps)
  Future<void> markNotificationOpened(String recordId);

  /// Check if we can send a notification (respects anti-spam rules)
  Future<bool> canSendNotification(NotificationType type);

  /// Get stats for a notification type
  Future<NotificationStats> getNotificationStats(NotificationType type);

  /// Get the last message key used for a type (for rotation)
  Future<String?> getLastMessageKey(NotificationType type);

  /// Get count of notifications sent this week
  Future<int> getWeeklyNotificationCount();

  /// Clean up old records
  Future<void> cleanupOldRecords();

  /// Reset consecutive ignores (when user actively uses the app)
  Future<void> resetIgnoreCount(NotificationType type);

  /// Close and release resources
  Future<void> close();
}
