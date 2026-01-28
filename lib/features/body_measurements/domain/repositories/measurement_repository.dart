import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';

/// MeasurementRepository - Domain repository interface
///
/// Abstract contract for measurement data operations.
/// Enforces GDPR consent checks and encryption requirements.
///
/// **GDPR Compliance**:
/// - All operations require user consent verification
/// - Data must be encrypted before storage
/// - Audit logging required for all data access
///
/// **Implementation**:
/// - Data layer implements this interface
/// - Uses Either<Failure, T> for error handling (fpdart pattern)
/// - Supports local + cloud sync with conflict resolution
abstract class MeasurementRepository {
  /// Add a new measurement
  ///
  /// **GDPR CRITICAL**: Requires explicit consent for the metric type.
  /// Operation blocked if user hasn't consented to track this metric.
  ///
  /// Parameters:
  /// - [measurement]: The measurement to add
  /// - [hasConsent]: Whether user has consented to this metric type
  ///
  /// Returns:
  /// - Right(void): Measurement saved successfully
  /// - Left(ConsentRequiredFailure): Consent not granted for metric
  /// - Left(ValidationFailure): Measurement value invalid (out of range)
  /// - Left(StorageFailure): Local/cloud storage error
  ///
  /// Example:
  /// ```dart
  /// final hasConsent = await consentRepo.hasConsentFor(userId, MetricType.weight);
  /// final result = await measurementRepo.addMeasurement(
  ///   measurement,
  ///   hasConsent: hasConsent,
  /// );
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (_) => print('Measurement saved'),
  /// );
  /// ```
  Future<Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  });

  /// Get measurements for a user, optionally filtered by metric type
  ///
  /// **GDPR**: Only returns measurements user has consented to.
  /// Non-consented metrics are filtered out automatically.
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  /// - [filterByType]: Optional metric filter (e.g., MetricType.weight)
  /// - [dateFrom]: Optional start date filter
  /// - [dateTo]: Optional end date filter
  ///
  /// Returns:
  /// - Right(List<Measurement>): List of measurements (may be empty)
  /// - Left(StorageFailure): Error fetching data
  /// - Left(NetworkFailure): Cloud sync failed (offline mode)
  ///
  /// Example:
  /// ```dart
  /// // Get all weight measurements from last 30 days
  /// final result = await measurementRepo.getMeasurements(
  ///   userId,
  ///   filterByType: MetricType.weight,
  ///   dateFrom: DateTime.now().subtract(Duration(days: 30)),
  /// );
  /// ```
  Future<Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  /// Update an existing measurement
  ///
  /// **GDPR**: Logs modification to audit trail.
  /// Cannot change userId or metricType (immutable fields).
  ///
  /// Parameters:
  /// - [measurement]: Updated measurement (must have same id as existing)
  ///
  /// Returns:
  /// - Right(void): Update successful
  /// - Left(NotFoundFailure): Measurement id not found
  /// - Left(ValidationFailure): Invalid update (userId/metricType changed)
  /// - Left(StorageFailure): Storage error
  ///
  /// Example:
  /// ```dart
  /// final updated = existingMeasurement.copyWith(
  ///   value: 76.0,
  ///   notes: 'After lunch',
  /// );
  /// final result = await measurementRepo.updateMeasurement(updated);
  /// ```
  Future<Either<MeasurementFailure, void>> updateMeasurement(Measurement measurement);

  /// Delete a measurement (soft-delete with 30-day retention)
  ///
  /// **GDPR CRITICAL**: Right to erasure implementation.
  /// Marks measurement as deleted, schedules permanent deletion after retention period.
  ///
  /// Parameters:
  /// - [measurementId]: UUID of measurement to delete
  /// - [userId]: User requesting deletion (verification)
  ///
  /// Returns:
  /// - Right(void): Soft-delete successful (30-day retention starts)
  /// - Left(NotFoundFailure): Measurement id not found
  /// - Left(PermissionDeniedFailure): userId doesn't match measurement owner
  ///
  /// Example:
  /// ```dart
  /// final result = await measurementRepo.deleteMeasurement(
  ///   measurementId: '123e4567-e89b-12d3-a456-426614174000',
  ///   userId: currentUser.uid,
  /// );
  /// // User can cancel deletion within 30 days via privacy settings
  /// ```
  Future<Either<MeasurementFailure, void>> deleteMeasurement({
    required String measurementId,
    required String userId,
  });

  /// Permanently delete a measurement (irreversible)
  ///
  /// **Internal use only**: Called automatically after 30-day retention period.
  /// Not exposed to UI layer directly.
  ///
  /// Parameters:
  /// - [measurementId]: UUID of measurement to permanently delete
  ///
  /// Returns:
  /// - Right(void): Permanent deletion successful
  /// - Left(StorageFailure): Deletion failed (retry required)
  Future<Either<MeasurementFailure, void>> permanentlyDeleteMeasurement(
    String measurementId,
  );

  /// Sync measurements with health platform (HealthKit or Health Connect)
  ///
  /// **GDPR CRITICAL**: Only syncs metrics user has consented to.
  /// Bi-directional: reads from health platform AND writes measurements back.
  ///
  /// Parameters:
  /// - [userId]: User to sync for
  /// - [consentedMetrics]: List of metrics user has consented to sync
  /// - [direction]: Sync direction (read, write, or both)
  ///
  /// Returns:
  /// - Right(SyncResult): Sync completed (includes counts: read, written, conflicts)
  /// - Left(PermissionDeniedFailure): Health platform permissions not granted
  /// - Left(PlatformNotAvailableFailure): HealthKit/Health Connect not available
  /// - Left(SyncFailure): Sync error (partial sync may have occurred)
  ///
  /// Example:
  /// ```dart
  /// final consent = await consentRepo.getConsent(userId);
  /// final result = await measurementRepo.syncWithHealthPlatform(
  ///   userId: userId,
  ///   consentedMetrics: consent.consentedMetrics,
  ///   direction: SyncDirection.both,
  /// );
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (syncResult) => print('Synced: ${syncResult.readCount} read, ${syncResult.writeCount} written'),
  /// );
  /// ```
  Future<Either<MeasurementFailure, SyncResult>> syncWithHealthPlatform({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
  });

  /// Get the latest measurement for each metric type
  ///
  /// Returns a map of MetricType -> latest Measurement for efficient dashboard display.
  /// Only returns metrics user has consented to.
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(Map<MetricType, Measurement>): Latest measurement per metric type
  /// - Left(StorageFailure): Error fetching data
  Future<Either<MeasurementFailure, Map<MetricType, Measurement>>> getLatestMeasurementsByType(
    String userId,
  );

  /// Get sync conflicts (measurements with different values on device vs cloud)
  ///
  /// Conflicts occur when:
  /// - User modifies measurement offline
  /// - Same measurement modified on different device
  /// - Cloud sync overwrites local changes
  ///
  /// Parameters:
  /// - [userId]: User to check conflicts for
  ///
  /// Returns:
  /// - Right(List<SyncConflict>): List of conflicts (may be empty)
  /// - Left(StorageFailure): Error fetching data
  ///
  /// Example:
  /// ```dart
  /// final result = await measurementRepo.getSyncConflicts(userId);
  /// result.fold(
  ///   (failure) => showError(failure.message),
  ///   (conflicts) {
  ///     if (conflicts.isNotEmpty) {
  ///       navigateTo(SyncConflictScreen(conflicts: conflicts));
  ///     }
  ///   },
  /// );
  /// ```
  Future<Either<MeasurementFailure, List<SyncConflict>>> getSyncConflicts(String userId);

  /// Resolve a sync conflict by choosing device or cloud version
  ///
  /// Parameters:
  /// - [conflictId]: ID of conflict to resolve
  /// - [resolution]: Which version to keep (device, cloud, or both)
  ///
  /// Returns:
  /// - Right(void): Conflict resolved
  /// - Left(NotFoundFailure): Conflict id not found
  /// - Left(StorageFailure): Resolution failed
  ///
  /// Example:
  /// ```dart
  /// // User chose to keep device version
  /// final result = await measurementRepo.resolveConflict(
  ///   conflictId: conflict.id,
  ///   resolution: ConflictResolution.keepDevice,
  /// );
  /// ```
  Future<Either<MeasurementFailure, void>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  });

  /// Get last sync timestamp for health platform
  ///
  /// Returns:
  /// - Right(DateTime?): Last successful sync time (null if never synced)
  /// - Left(StorageFailure): Error reading sync metadata
  Future<Either<MeasurementFailure, DateTime?>> getLastSyncTimestamp(String userId);
}

/// SyncResult - Result of health platform synchronization
class SyncResult {
  /// Number of measurements read from health platform
  final int readCount;

  /// Number of measurements written to health platform
  final int writeCount;

  /// Number of sync conflicts detected
  final int conflictCount;

  /// Timestamp when sync completed
  final DateTime syncedAt;

  /// Measurements imported from health platform (for persistence by caller)
  final List<Measurement> importedMeasurements;

  const SyncResult({
    required this.readCount,
    required this.writeCount,
    required this.conflictCount,
    required this.syncedAt,
    this.importedMeasurements = const [],
  });
}

/// SyncDirection - Direction of health platform synchronization
enum SyncDirection {
  /// Read measurements from health platform into app
  read,

  /// Write measurements from app to health platform
  write,

  /// Bi-directional sync (read + write)
  both;
}

/// SyncConflict - Represents a conflict between device and cloud data
class SyncConflict {
  /// Unique conflict ID
  final String id;

  /// Measurement on device (local version)
  final Measurement deviceVersion;

  /// Measurement on cloud (Firestore version)
  final Measurement cloudVersion;

  /// When conflict was detected
  final DateTime detectedAt;

  const SyncConflict({
    required this.id,
    required this.deviceVersion,
    required this.cloudVersion,
    required this.detectedAt,
  });
}

/// ConflictResolution - How to resolve a sync conflict
enum ConflictResolution {
  /// Keep device version, discard cloud version
  keepDevice,

  /// Keep cloud version, discard device version
  keepCloud,

  /// Keep both versions (save as separate measurements)
  keepBoth;
}

/// MeasurementFailure - Error types for measurement operations
sealed class MeasurementFailure {
  const MeasurementFailure();
}

/// User hasn't consented to track this metric type
class ConsentRequiredFailure extends MeasurementFailure {
  final MetricType metricType;
  const ConsentRequiredFailure(this.metricType);
}

/// Measurement value outside valid range
class ValidationFailure extends MeasurementFailure {
  final String message;
  const ValidationFailure(this.message);
}

/// Local or cloud storage error
class StorageFailure extends MeasurementFailure {
  final String message;
  final Object? error;
  const StorageFailure({required this.message, this.error});
}

/// Measurement not found
class MeasurementNotFoundFailure extends MeasurementFailure {
  final String measurementId;
  const MeasurementNotFoundFailure(this.measurementId);
}

/// Sync conflict between device and cloud
class SyncConflictFailure extends MeasurementFailure {
  final String message;
  const SyncConflictFailure(this.message);
}

/// Health platform (HealthKit/Health Connect) error
class HealthPlatformFailure extends MeasurementFailure {
  final String message;
  final Object? error;
  const HealthPlatformFailure({required this.message, this.error});
}
