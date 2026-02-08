import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/encrypted_measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';

/// MeasurementLocalDatasource - Abstract interface for local storage
///
/// **Data Layer Responsibility**:
/// - Persist encrypted measurements locally (Hive database)
/// - Fast read access for offline mode
/// - CRUD operations on encrypted measurement data
/// - Backup before Firestore sync
///
/// **Encryption**:
/// - All measurements stored encrypted (AES-256-GCM)
/// - Encryption handled by EncryptionKeyManager
/// - Hive stores only encrypted data (no plaintext on disk)
///
/// **Usage**:
/// ```dart
/// final datasource = HiveMeasurementDatasource();
///
/// // Save encrypted measurement
/// await datasource.saveMeasurement(encryptedMeasurement);
///
/// // Get all measurements for a user
/// final measurements = await datasource.getAllMeasurements('user-123');
/// ```
abstract class MeasurementLocalDatasource {
  /// Save encrypted measurement to local storage
  ///
  /// **Storage Strategy**: Hive box with user-specific keys
  ///
  /// Key format: `{userId}_{measurementId}`
  /// Example: `user-123_measurement-456`
  ///
  /// Parameters:
  /// - measurement: EncryptedMeasurement with AES-256-GCM encrypted data
  ///
  /// Returns:
  /// - Right(void): Measurement saved successfully
  /// - Left(LocalStorageFailure): Hive write error
  Future<Either<LocalStorageFailure, void>> saveMeasurement(
    EncryptedMeasurement measurement,
  );

  /// Get encrypted measurement by ID
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - measurementId: UUID of measurement
  ///
  /// Returns:
  /// - Right(EncryptedMeasurement): Measurement found
  /// - Left(MeasurementNotFoundFailure): Measurement doesn't exist locally
  /// - Left(LocalStorageFailure): Hive read error
  Future<Either<LocalStorageFailure, EncryptedMeasurement>> getMeasurement({
    required String userId,
    required String measurementId,
  });

  /// Get all measurements for a user
  ///
  /// **Performance**: Returns all measurements (use filtering if needed)
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(List<EncryptedMeasurement>): List of encrypted measurements
  /// - Left(LocalStorageFailure): Hive read error
  ///
  /// **Note**: Returns empty list if no measurements found (not an error)
  Future<Either<LocalStorageFailure, List<EncryptedMeasurement>>>
  getAllMeasurements(String userId);

  /// Get measurements filtered by metric type
  ///
  /// **Use Case**: Display only weight measurements, or only circumferences
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - metricType: MetricType to filter by
  ///
  /// Returns:
  /// - Right(List<EncryptedMeasurement>): Filtered measurements
  /// - Left(LocalStorageFailure): Hive read error
  Future<Either<LocalStorageFailure, List<EncryptedMeasurement>>>
  getMeasurementsByMetric({
    required String userId,
    required MetricType metricType,
  });

  /// Get measurements within date range
  ///
  /// **Use Case**: Display measurements for last 30 days, or specific month
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - startDate: Range start (inclusive)
  /// - endDate: Range end (inclusive)
  ///
  /// Returns:
  /// - Right(List<EncryptedMeasurement>): Measurements in date range
  /// - Left(LocalStorageFailure): Hive read error
  Future<Either<LocalStorageFailure, List<EncryptedMeasurement>>>
  getMeasurementsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update existing measurement
  ///
  /// **Use Case**: User edits measurement value
  ///
  /// Parameters:
  /// - measurement: Updated EncryptedMeasurement
  ///
  /// Returns:
  /// - Right(void): Measurement updated successfully
  /// - Left(MeasurementNotFoundFailure): Measurement doesn't exist
  /// - Left(LocalStorageFailure): Hive write error
  Future<Either<LocalStorageFailure, void>> updateMeasurement(
    EncryptedMeasurement measurement,
  );

  /// Delete measurement by ID
  ///
  /// **GDPR Right to Erasure**: User can delete measurements
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - measurementId: UUID of measurement to delete
  ///
  /// Returns:
  /// - Right(void): Measurement deleted successfully
  /// - Left(MeasurementNotFoundFailure): Measurement doesn't exist
  /// - Left(LocalStorageFailure): Hive delete error
  Future<Either<LocalStorageFailure, void>> deleteMeasurement({
    required String userId,
    required String measurementId,
  });

  /// Delete all measurements for a user
  ///
  /// **GDPR Right to Erasure**: User deletes account
  ///
  /// **Use Case**: Account deletion, or consent revocation
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(int): Number of measurements deleted
  /// - Left(LocalStorageFailure): Hive delete error
  Future<Either<LocalStorageFailure, int>> deleteAllMeasurements(String userId);

  /// Delete measurements for a specific metric type
  ///
  /// **GDPR**: User revokes consent for a metric group
  ///
  /// **Use Case**: User revokes consent for "Vitals" group → delete all
  /// bodyTemperature, waterMass, boneMass measurements
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  /// - metricType: MetricType to delete
  ///
  /// Returns:
  /// - Right(int): Number of measurements deleted
  /// - Left(LocalStorageFailure): Hive delete error
  Future<Either<LocalStorageFailure, int>> deleteMeasurementsByMetric({
    required String userId,
    required MetricType metricType,
  });

  /// Get count of measurements for a user
  ///
  /// **Use Case**: Display "You have 150 measurements" in UI
  ///
  /// Parameters:
  /// - userId: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(int): Number of measurements
  /// - Left(LocalStorageFailure): Hive read error
  Future<Either<LocalStorageFailure, int>> getMeasurementCount(String userId);

  /// Clear all data (for testing or debug)
  ///
  /// **WARNING**: Deletes EVERYTHING. Use with extreme caution.
  ///
  /// Returns:
  /// - Right(void): All data cleared
  /// - Left(LocalStorageFailure): Hive clear error
  Future<Either<LocalStorageFailure, void>> clearAllData();

  /// Initialize Hive box and setup
  ///
  /// **Lifecycle**: Called once on app startup
  ///
  /// Returns:
  /// - Right(void): Initialization successful
  /// - Left(LocalStorageFailure): Hive initialization error
  Future<Either<LocalStorageFailure, void>> initialize();

  /// Close Hive box (cleanup)
  ///
  /// **Lifecycle**: Called on app shutdown or dispose
  ///
  /// Returns:
  /// - Right(void): Closed successfully
  /// - Left(LocalStorageFailure): Hive close error
  Future<Either<LocalStorageFailure, void>> close();
}

/// LocalStorageFailure - Error types for local storage operations
sealed class LocalStorageFailure {
  const LocalStorageFailure();
}

/// Measurement not found in local storage
class MeasurementNotFoundFailure extends LocalStorageFailure {

  const MeasurementNotFoundFailure(this.measurementId);
  final String measurementId;
}

/// Hive database operation failed
class HiveFailure extends LocalStorageFailure {

  const HiveFailure({required this.message, this.error});
  final String message;
  final Object? error;
}

/// Hive box not initialized (call initialize() first)
class HiveNotInitializedFailure extends LocalStorageFailure {
  const HiveNotInitializedFailure();
}

/// Encryption/decryption failed during storage operation
class EncryptionStorageFailure extends LocalStorageFailure {

  const EncryptionStorageFailure(this.message);
  final String message;
}
