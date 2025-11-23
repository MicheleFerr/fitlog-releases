import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';

part 'health_sync_status.freezed.dart';
part 'health_sync_status.g.dart';

/// Represents the synchronization status for a specific [HealthDataType].
///
/// This entity tracks:
/// - Last sync timestamp
/// - Current sync result (idle/syncing/success/error)
/// - Retry count for exponential backoff
/// - Error message if sync failed
///
/// Generic design allows single entity to handle all health data types
/// (workout, weight, body fat, etc.) without code duplication.
@freezed
class HealthSyncStatus with _$HealthSyncStatus {
  const factory HealthSyncStatus({
    /// The type of health data this status represents
    required HealthDataType dataType,

    /// Timestamp of the last sync attempt (null if never synced)
    required DateTime? lastSyncTime,

    /// Result of the last sync operation
    required SyncResult lastResult,

    /// Number of retry attempts (0-3, exponential backoff)
    /// - 0: No retries
    /// - 1: First retry (1h delay)
    /// - 2: Second retry (4h delay)
    /// - 3: Third retry (24h delay)
    @Default(0) int retryCount,

    /// Error message from last failed sync (null if no error)
    String? errorMessage,
  }) = _HealthSyncStatus;

  factory HealthSyncStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthSyncStatusFromJson(json);
}

/// Enum representing the possible states of a sync operation
enum SyncResult {
  /// No sync in progress, waiting for trigger
  idle,

  /// Sync currently in progress
  syncing,

  /// Last sync completed successfully
  success,

  /// Last sync failed with error
  error,
}

/// Extension methods for [HealthSyncStatus]
extension HealthSyncStatusExtension on HealthSyncStatus {
  /// Returns true if sync should be retried based on error state and retry count.
  ///
  /// Retry logic:
  /// - Only retry if last result was error
  /// - Max 3 retries (retryCount < 3)
  /// - Exponential backoff delays handled by provider
  bool shouldRetry() => lastResult == SyncResult.error && retryCount < 3;

  /// Returns true if enough time has passed since last sync (24h for daily sync)
  bool shouldAutoSync() {
    if (lastSyncTime == null) return true; // Never synced
    final hoursSinceSync = DateTime.now().difference(lastSyncTime!).inHours;
    return hoursSinceSync >= 24; // Daily sync = 24h interval
  }

  /// Returns a user-friendly status message key for localization
  String get statusMessageKey {
    switch (lastResult) {
      case SyncResult.idle:
        return lastSyncTime == null
            ? 'healthSyncStatusNeverSynced'
            : 'healthSyncStatusIdle';
      case SyncResult.syncing:
        return 'healthSyncStatusSyncing';
      case SyncResult.success:
        return 'healthSyncStatusSuccess';
      case SyncResult.error:
        return 'healthSyncStatusError';
    }
  }
}
