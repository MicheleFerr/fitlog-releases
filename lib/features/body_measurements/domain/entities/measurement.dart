import 'package:freezed_annotation/freezed_annotation.dart';
import 'metric_type.dart';

part 'measurement.freezed.dart';
part 'measurement.g.dart';

/// Measurement - Domain entity for body measurement data
///
/// Represents a single body measurement (weight, circumference, etc.)
/// with full GDPR compliance metadata.
///
/// Features:
/// - Immutable with freezed
/// - JSON serialization for Firestore sync
/// - Encryption support (value stored encrypted in data layer)
/// - Audit trail tracking (source, timestamp)
/// - Validation via MetricType.validRange
///
/// Example:
/// ```dart
/// final measurement = Measurement(
///   id: 'uuid-123',
///   userId: 'user-456',
///   metricType: MetricType.weight,
///   value: 75.5,
///   unit: 'kg',
///   timestamp: DateTime.now(),
///   source: MeasurementSource.manual,
///   notes: 'Morning weight after workout',
/// );
/// ```
@freezed
abstract class Measurement with _$Measurement {
  const factory Measurement({
    /// Unique identifier (UUID v4)
    required String id,

    /// User ID (Firebase Auth UID)
    /// GDPR: Required for data isolation and deletion
    required String userId,

    /// Type of measurement (weight, body fat, circumference, etc.)
    required MetricType metricType,

    /// Numeric value of the measurement
    /// NOTE: Stored encrypted in data layer (AES-256-GCM)
    required double value,

    /// Unit of measurement (kg, cm, %, etc.)
    /// Defaults to MetricType.defaultUnit
    required String unit,

    /// When the measurement was taken (user's local time)
    /// NOTE: NOT when it was synced to Firestore
    required DateTime timestamp,

    /// Where the data came from (manual, HealthKit, calculated, etc.)
    required MeasurementSource source,

    /// Optional user notes (encrypted in data layer)
    /// Max length: 500 characters
    String? notes,

    /// When this measurement was created in the app
    /// Used for sync conflict resolution (latest wins)
    DateTime? createdAt,

    /// When this measurement was last modified
    /// Used for sync conflict resolution
    DateTime? updatedAt,

    /// Whether this measurement is marked for deletion
    /// GDPR: Soft-delete with 30-day retention before permanent deletion
    @Default(false) bool isDeleted,

    /// When this measurement was soft-deleted (if isDeleted = true)
    /// After 30 days from this timestamp, data is permanently deleted
    DateTime? deletedAt,
  }) = _Measurement;

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);
}

/// MeasurementMetadata - Additional context for measurements
///
/// Used for audit logging and analytics (GDPR compliant)
@freezed
abstract class MeasurementMetadata with _$MeasurementMetadata {
  const factory MeasurementMetadata({
    /// Device info (anonymized)
    /// Example: "iOS 17.2, iPhone 14 Pro"
    String? deviceInfo,

    /// App version when measurement was created
    /// Example: "1.0.0+49"
    String? appVersion,

    /// Sync status (pending, synced, conflict)
    @Default(SyncStatus.pending) SyncStatus syncStatus,

    /// Last sync attempt timestamp
    DateTime? lastSyncAttempt,

    /// Sync error message (if sync failed)
    String? syncError,

    /// Whether this measurement was validated
    @Default(false) bool isValidated,

    /// Validation errors (if any)
    List<String>? validationErrors,
  }) = _MeasurementMetadata;

  factory MeasurementMetadata.fromJson(Map<String, dynamic> json) =>
      _$MeasurementMetadataFromJson(json);
}

/// SyncStatus - Tracks synchronization state with Firestore
enum SyncStatus {
  /// Not yet synced to Firestore
  pending,

  /// Successfully synced to Firestore
  synced,

  /// Sync conflict detected (device vs cloud)
  conflict,

  /// Sync failed (network error, permission denied, etc.)
  failed;
}
