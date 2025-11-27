/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/domain/entities
/// Feature: Local Notifications System
/// Type: Entity - Notification Record
///
/// Tracks sent notifications for anti-spam logic and analytics.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';

part 'notification_record.freezed.dart';
part 'notification_record.g.dart';

/// Record of a sent notification for tracking and anti-spam purposes.
@freezed
abstract class NotificationRecord with _$NotificationRecord {
  const factory NotificationRecord({
    /// Unique identifier
    required String id,

    /// Type of notification sent
    required NotificationType type,

    /// When the notification was scheduled/sent
    required DateTime sentAt,

    /// When the notification was opened (null if not opened)
    DateTime? openedAt,

    /// The message that was sent (for rotation tracking)
    required String messageKey,

    /// Additional context (e.g., exercise name for PR)
    String? context,

    /// For inactivity: which day in sequence (3, 7, or 14)
    int? inactivityDay,

    /// Whether this notification was canceled before delivery
    @Default(false) bool wasCanceled,
  }) = _NotificationRecord;

  const NotificationRecord._();

  factory NotificationRecord.fromJson(Map<String, dynamic> json) =>
      _$NotificationRecordFromJson(json);

  /// Whether the notification was opened by the user
  bool get wasOpened => openedAt != null;

  /// Whether the notification was ignored (sent but not opened)
  bool get wasIgnored => !wasCanceled && openedAt == null;
}

/// Statistics for a notification type
@freezed
abstract class NotificationStats with _$NotificationStats {
  const factory NotificationStats({
    /// Total notifications sent
    required int totalSent,

    /// How many were opened
    required int totalOpened,

    /// How many consecutive ignores (for stop-after-ignore logic)
    required int consecutiveIgnores,

    /// Last notification sent timestamp
    DateTime? lastSentAt,

    /// Last message key used (for rotation)
    String? lastMessageKey,
  }) = _NotificationStats;

  const NotificationStats._();

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsFromJson(json);

  /// Open rate as percentage (0.0 - 1.0)
  double get openRate {
    if (totalSent == 0) return 0.0;
    return totalOpened / totalSent;
  }

  /// Whether we should stop sending this type (too many ignores)
  bool shouldStopSending(int maxIgnores) => consecutiveIgnores >= maxIgnores;
}
