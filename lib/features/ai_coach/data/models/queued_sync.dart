/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/models
/// 🎯 Feature: ai_coach
/// 🔧 Type: model
///
/// Queued Sync Model - Failed sync stored for retry
///
/// **Persistence**: Stored in Hive for offline resilience
/// **Retry Logic**: Exponential backoff (30s → 1m → 2m → 5m → 10m)
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'queued_sync.freezed.dart';
part 'queued_sync.g.dart';

/// Queued sync entry (for offline retry)
///
/// **Usage**:
/// ```dart
/// final queuedSync = QueuedSync(
///   id: 'sync-123',
///   timestamp: DateTime.now(),
///   healthMetrics: {'steps_today': 8500, ...},
///   error: 'Network error',
///   retryCount: 0,
///   retryable: true,
/// );
///
/// // Save to Hive
/// await queueBox.put(queuedSync.id, queuedSync);
/// ```
@freezed
@HiveType(typeId: 10) // AI Coach feature = 10-19 range
class QueuedSync with _$QueuedSync {
  const factory QueuedSync({
    /// Unique ID for this sync attempt
    @HiveField(0) required String id,

    /// Timestamp when sync failed
    @HiveField(1) required DateTime timestamp,

    /// Health metrics that failed to sync
    @HiveField(2) required Map<String, dynamic> healthMetrics,

    /// Error message (for logging)
    @HiveField(3) required String error,

    /// Number of retry attempts (0 = first attempt)
    @HiveField(4) @Default(0) int retryCount,

    /// Is this sync retryable (false for rate limit, quota errors)
    @HiveField(5) @Default(true) bool retryable,

    /// Next retry time (calculated with exponential backoff)
    @HiveField(6) DateTime? nextRetryAt,
  }) = _QueuedSync;

  factory QueuedSync.fromJson(Map<String, dynamic> json) =>
      _$QueuedSyncFromJson(json);
}

/// Extension for QueuedSync convenience methods
extension QueuedSyncX on QueuedSync {
  /// Is this sync ready for retry (past nextRetryAt time)
  bool get isReadyForRetry {
    if (nextRetryAt == null) return true;
    return DateTime.now().isAfter(nextRetryAt!);
  }

  /// Get exponential backoff delay based on retry count
  ///
  /// **Backoff Strategy**:
  /// - 0 retries: 30s
  /// - 1 retry: 1m
  /// - 2 retries: 2m
  /// - 3 retries: 5m
  /// - 4+ retries: 10m (max)
  Duration get backoffDelay {
    switch (retryCount) {
      case 0:
        return const Duration(seconds: 30);
      case 1:
        return const Duration(minutes: 1);
      case 2:
        return const Duration(minutes: 2);
      case 3:
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 10); // Max backoff
    }
  }

  /// Create copy with incremented retry count and next retry time
  QueuedSync incrementRetry() {
    final nextRetry = DateTime.now().add(backoffDelay);
    return copyWith(
      retryCount: retryCount + 1,
      nextRetryAt: nextRetry,
    );
  }

  /// Has exceeded max retry attempts (5 attempts = 0-4 retryCount)
  bool get hasExceededMaxRetries => retryCount >= 5;

  /// Time until next retry (null if ready now)
  Duration? get timeUntilNextRetry {
    if (nextRetryAt == null) return null;
    final remaining = nextRetryAt!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}
