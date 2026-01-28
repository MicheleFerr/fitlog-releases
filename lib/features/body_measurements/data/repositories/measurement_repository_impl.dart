import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/encrypted_measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/datasources/measurement_local_datasource.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/encryption_key_manager.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart' as shared;

/// MeasurementRepositoryImpl - Firestore + Hive implementation of MeasurementRepository
///
/// **Data Layer Responsibility**:
/// - Encrypt/decrypt measurements using AES-256-GCM
/// - Enforce consent checks via ConsentRepository
/// - Store encrypted data locally (Hive) + cloud (Firestore)
/// - Sync between local and cloud with conflict resolution
/// - GDPR-compliant data operations
///
/// **Architecture**:
/// ```
/// [UI] → [MeasurementRepositoryImpl]
///        ├─ ConsentRepository (consent enforcement)
///        ├─ EncryptionKeyManager (AES-256-GCM key management)
///        ├─ MeasurementLocalDatasource (Hive storage)
///        └─ Firestore (cloud storage)
/// ```
///
/// **Data Flow - Add Measurement**:
/// 1. Check consent (hasConsentFor)
/// 2. Validate measurement (domain validator)
/// 3. Get encryption key (EncryptionKeyManager)
/// 4. Encrypt measurement (AES-256-GCM)
/// 5. Save to Hive (local backup)
/// 6. Save to Firestore (cloud sync)
///
/// **Firestore Schema**:
/// ```
/// /bodyMeasurements/{userId}/measurements/{measurementId}
/// {
///   id: string (UUID v4)
///   userId: string (Firebase Auth UID)
///   metricType: string (weight, bodyFatPercentage, etc.)
///   encryptedData: string (Base64 AES-256-GCM ciphertext)
///   iv: string (Base64 initialization vector - 12 bytes)
///   tag: string (Base64 authentication tag - 16 bytes)
///   timestamp: timestamp
///   createdAt: timestamp
///   updatedAt: timestamp
/// }
/// ```
///
/// **GDPR Compliance**:
/// - Consent enforcement before ALL operations
/// - Encryption at rest (local + cloud)
/// - Audit logging integration (TODO: Task 2.9)
/// - Right to Erasure support (soft-delete + permanent delete)
///
/// **Encryption Implementation**:
/// - Algorithm: AES-256-GCM (authenticated encryption)
/// - Key: 256-bit (32 bytes) from EncryptionKeyManager
/// - IV: 96-bit (12 bytes) random per encryption
/// - Tag: 128-bit (16 bytes) authentication tag
/// - TODO: Full AES-GCM implementation requires `pointycastle` package
///
/// **Usage**:
/// ```dart
/// final measurementRepo = MeasurementRepositoryImpl(
///   firestore: FirebaseFirestore.instance,
///   consentRepo: ref.read(consentRepositoryProvider),
///   localDatasource: ref.read(measurementLocalDatasourceProvider),
///   keyManager: ref.read(encryptionKeyManagerProvider),
/// );
///
/// // Add measurement (with consent check)
/// final result = await measurementRepo.addMeasurement(
///   measurement,
///   hasConsent: true,
/// );
/// ```
class MeasurementRepositoryImpl with FirebaseErrorMapperMixin implements MeasurementRepository {
  final FirebaseFirestore _firestore;
  final ConsentRepository _consentRepo;
  final MeasurementLocalDatasource _localDatasource;
  final EncryptionKeyManager _keyManager;
  final Uuid _uuid;

  /// Collection name in Firestore
  static const String _collectionName = 'bodyMeasurements';

  /// Subcollection for measurements
  static const String _measurementsSubcollection = 'measurements';

  MeasurementRepositoryImpl({
    required FirebaseFirestore firestore,
    required ConsentRepository consentRepo,
    required MeasurementLocalDatasource localDatasource,
    required EncryptionKeyManager keyManager,
    Uuid? uuid,
  })  : _firestore = firestore,
        _consentRepo = consentRepo,
        _localDatasource = localDatasource,
        _keyManager = keyManager,
        _uuid = uuid ?? const Uuid();

  /// Get reference to user's measurements collection
  CollectionReference<Map<String, dynamic>> _getMeasurementsCollection(
    String userId,
  ) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .collection(_measurementsSubcollection);
  }

  @override
  Future<Either<MeasurementFailure, void>> addMeasurement(
    Measurement measurement, {
    required bool hasConsent,
  }) async {
    // GDPR: Enforce consent
    if (!hasConsent) {
      return left(ConsentRequiredFailure(measurement.metricType));
    }

    // Get encryption key
    final keyResult = await _keyManager.getKey(measurement.userId);
    if (keyResult.isLeft()) {
      return left(const StorageFailure(
        message: 'Failed to get encryption key',
      ));
    }

    final encryptionKey = keyResult.getOrElse((_) => '');

    // Encrypt measurement
    final encryptedMeasurement = await _encryptMeasurement(
      measurement,
      encryptionKey,
    );

    // Save to local storage (Hive) - offline backup
    final localResult = await _localDatasource.saveMeasurement(
      encryptedMeasurement,
    );
    if (localResult.isLeft()) {
      // Log error but don't fail (local storage is backup)
      // TODO: Add audit log entry (Task 2.9)
    }

    // Save to Firestore (cloud) using mixin
    final result = await handleFirebaseVoidOperation(
      () async {
        await _getMeasurementsCollection(measurement.userId)
            .doc(measurement.id)
            .set(encryptedMeasurement.toJson());
      },
      operationName: 'addMeasurement',
    );

    // TODO: Create audit log entry (Task 2.9)
    // await _auditLogger.log(
    //   userId: measurement.userId,
    //   action: AuditAction.measurementAdded,
    //   metricType: measurement.metricType,
    //   timestamp: DateTime.now(),
    // );

    return result.mapLeft(_mapToMeasurementFailure);
  }

  @override
  Future<Either<MeasurementFailure, List<Measurement>>> getMeasurements(
    String userId, {
    MetricType? filterByType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    // Build query based on filters
    if (filterByType == null && dateFrom == null && dateTo == null) {
      // No filters - get all from local storage first (faster)
      final localResult = await _localDatasource.getAllMeasurements(userId);

      List<EncryptedMeasurement> encryptedMeasurements;
      if (localResult.isRight()) {
        encryptedMeasurements = localResult.getOrElse((_) => []);
      } else {
        // Fallback to Firestore using mixin
        final firestoreResult = await handleFirebaseOperation<List<EncryptedMeasurement>>(
          () async {
            final snapshot = await _getMeasurementsCollection(userId)
                .orderBy('timestamp', descending: true)
                .get();

            return snapshot.docs
                .map((doc) => EncryptedMeasurement.fromJson(doc.data()))
                .toList();
          },
          operationName: 'getMeasurements_noFilters',
        );

        // Handle error case
        final mappedResult = firestoreResult.mapLeft(_mapToMeasurementFailure);
        if (mappedResult.isLeft()) {
          return mappedResult.map((_) => <Measurement>[]);
        }
        encryptedMeasurements = firestoreResult.getOrElse((_) => []);
      }

      // Decrypt measurements
      final measurements = await _decryptMeasurements(
        encryptedMeasurements,
        userId,
      );

      // Filter by consent (GDPR: only return consented metrics)
      final consentedMeasurements = await _filterByConsent(userId, measurements);

      return right(consentedMeasurements);
    } else {
      // Has filters - query Firestore directly using mixin
      final result = await handleFirebaseOperation<List<EncryptedMeasurement>>(
        () async {
          Query<Map<String, dynamic>> query =
              _getMeasurementsCollection(userId);

          if (filterByType != null) {
            query = query.where('metricType', isEqualTo: filterByType.name);
          }

          if (dateFrom != null) {
            query = query.where('timestamp', isGreaterThanOrEqualTo: dateFrom);
          }

          if (dateTo != null) {
            query = query.where('timestamp', isLessThanOrEqualTo: dateTo);
          }

          final snapshot = await query.orderBy('timestamp', descending: true).get();

          return snapshot.docs
              .map((doc) => EncryptedMeasurement.fromJson(doc.data()))
              .toList();
        },
        operationName: 'getMeasurements_withFilters',
      );

      // Handle error case
      final mappedResult = result.mapLeft(_mapToMeasurementFailure);
      if (mappedResult.isLeft()) {
        return mappedResult.map((_) => <Measurement>[]);
      }

      final encryptedMeasurements = result.getOrElse((_) => []);

      // Decrypt measurements
      final measurements = await _decryptMeasurements(
        encryptedMeasurements,
        userId,
      );

      // Filter by consent (GDPR: only return consented metrics)
      final consentedMeasurements = await _filterByConsent(userId, measurements);

      return right(consentedMeasurements);
    }
  }

  @override
  Future<Either<MeasurementFailure, Map<MetricType, Measurement>>> getLatestMeasurementsByType(
    String userId,
  ) async {
    // Get all measurements then group by type and pick latest
    final result = await getMeasurements(userId);

    return result.map((measurements) {
      final latestByType = <MetricType, Measurement>{};
      for (final m in measurements) {
        final existing = latestByType[m.metricType];
        if (existing == null || m.timestamp.isAfter(existing.timestamp)) {
          latestByType[m.metricType] = m;
        }
      }
      return latestByType;
    });
  }

  @override
  Future<Either<MeasurementFailure, void>> updateMeasurement(
    Measurement measurement,
  ) async {
    // Check consent
    final consentResult = await _consentRepo.hasConsentFor(
      measurement.userId,
      measurement.metricType,
    );

    if (consentResult.isLeft() || !(consentResult.getOrElse((_) => false))) {
      return left(ConsentRequiredFailure(measurement.metricType));
    }

    // Get encryption key
    final keyResult = await _keyManager.getKey(measurement.userId);
    if (keyResult.isLeft()) {
      return left(const StorageFailure(
        message: 'Failed to get encryption key',
      ));
    }

    final encryptionKey = keyResult.getOrElse((_) => '');

    // Encrypt measurement
    final encryptedMeasurement = await _encryptMeasurement(
      measurement,
      encryptionKey,
    );

    // Update local storage
    await _localDatasource.updateMeasurement(encryptedMeasurement);

    // Update Firestore using mixin
    final result = await handleFirebaseVoidOperation(
      () async {
        await _getMeasurementsCollection(measurement.userId)
            .doc(measurement.id)
            .update(encryptedMeasurement.toJson());
      },
      operationName: 'updateMeasurement',
    );

    // TODO: Create audit log entry (Task 2.9)

    return result.mapLeft(_mapToMeasurementFailure);
  }

  @override
  Future<Either<MeasurementFailure, void>> deleteMeasurement({
    required String measurementId,
    required String userId,
  }) async {
    // Soft-delete: Mark as deleted with 30-day retention
    // TODO: Implement soft-delete with scheduledDeletion field (Task 2.8)

    // For now, hard delete (TODO: Change to soft-delete in Task 2.8)
    // Delete from local storage
    await _localDatasource.deleteMeasurement(
      userId: userId,
      measurementId: measurementId,
    );

    // Delete from Firestore using mixin
    final result = await handleFirebaseVoidOperation(
      () async {
        await _getMeasurementsCollection(userId).doc(measurementId).delete();
      },
      operationName: 'deleteMeasurement',
    );

    // TODO: Create audit log entry (Task 2.9)

    return result.mapLeft(_mapToMeasurementFailure);
  }

  @override
  Future<Either<MeasurementFailure, void>> permanentlyDeleteMeasurement(
    String measurementId,
  ) async {
    try {
      // GDPR: Permanent deletion (called after 30-day retention period)
      // Note: userId not needed as this is internal cleanup

      // For now, simple implementation (TODO: Add retention period check in Task 2.8)
      // We need to find the measurement first to get userId
      // This is a simplified implementation - proper version should track deletions

      // TODO: Implement proper permanent deletion with retention period tracking (Task 2.8)
      // For now, return success (actual deletion happens in deleteMeasurement)

      return right(null);
    } catch (e) {
      return left(StorageFailure(
        message: 'Unexpected error permanently deleting measurement: $e',
        error: e,
      ));
    }
  }

  @override
  Future<Either<MeasurementFailure, SyncResult>> syncWithHealthPlatform({
    required String userId,
    required List<MetricType> consentedMetrics,
    required SyncDirection direction,
  }) async {
    // TODO: Implement HealthKit/Health Connect sync (Tasks 2.4, 2.5)
    // Requires:
    // - HealthKit integration (iOS) - Task 2.4
    // - Health Connect adapter (Android) - Task 2.5
    // - Consent-driven filtering (only sync consented metrics)

    // For now, return empty sync result
    return right(SyncResult(
      readCount: 0,
      writeCount: 0,
      conflictCount: 0,
      syncedAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<MeasurementFailure, List<SyncConflict>>> getSyncConflicts(
    String userId,
  ) async {
    // TODO: Implement conflict detection
    // Strategy:
    // 1. Compare local (Hive) vs cloud (Firestore) timestamps
    // 2. If same measurement ID has different updatedAt timestamps, it's a conflict
    // 3. Return SyncConflict objects with both versions

    // For now, return empty list (no conflicts)
    return right([]);
  }

  @override
  Future<Either<MeasurementFailure, void>> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    // TODO: Implement conflict resolution
    // Strategy:
    // - keepDevice: Overwrite cloud with device version
    // - keepCloud: Overwrite device with cloud version
    // - keepBoth: Create new measurement ID for one version

    // For now, return success (no conflicts exist yet)
    return right(null);
  }

  @override
  Future<Either<MeasurementFailure, DateTime?>> getLastSyncTimestamp(
    String userId,
  ) async {
    // TODO: Implement sync timestamp tracking
    // Store last successful sync time in Hive or Firestore metadata

    // For now, return null (never synced)
    return right(null);
  }

  // ========== Private Helper Methods ==========

  /// Map shared Failure to MeasurementFailure
  MeasurementFailure _mapToMeasurementFailure(shared.Failure failure) {
    if (failure is shared.NotFoundFailure) {
      // Extract measurement ID from message if possible, otherwise use generic message
      return StorageFailure(message: failure.message, error: failure);
    } else if (failure is shared.ValidationFailure) {
      return ValidationFailure(failure.message);
    } else {
      // Map all other failures to StorageFailure
      return StorageFailure(
        message: failure.message,
        error: failure,
      );
    }
  }

  /// Encrypt measurement using AES-256-GCM
  ///
  /// **Current Implementation**: Simplified using crypto package
  /// **TODO**: Full AES-256-GCM requires `pointycastle` or `encrypt` package
  ///
  /// **Encryption Process**:
  /// 1. Serialize measurement to JSON
  /// 2. Generate random 12-byte IV
  /// 3. Encrypt JSON with AES-256-GCM (key + IV)
  /// 4. Extract 16-byte authentication tag
  /// 5. Base64 encode all components
  /// 6. Return EncryptedMeasurement
  Future<EncryptedMeasurement> _encryptMeasurement(
    Measurement measurement,
    String base64Key,
  ) async {
    try {
      // Decode base64 key to bytes
      final keyBytes = base64.decode(base64Key);

      // Verify key length = 32 bytes (AES-256)
      if (keyBytes.length != 32) {
        throw Exception('Invalid encryption key length: ${keyBytes.length} (expected 32)');
      }

      // Convert measurement to JSON string
      final measurementJson = jsonEncode(measurement.toJson());
      final plaintextBytes = utf8.encode(measurementJson);

      // Generate random 12-byte IV for AES-GCM
      final random = Random.secure();
      final iv = Uint8List(12); // AES-GCM standard IV size
      for (var i = 0; i < iv.length; i++) {
        iv[i] = random.nextInt(256);
      }

      // TODO: Implement full AES-256-GCM encryption
      // For now, use simplified approach with XOR (TEMPORARY - NOT PRODUCTION READY)
      // This is a placeholder until pointycastle package is added

      // TEMPORARY IMPLEMENTATION (NOT SECURE - FOR DEVELOPMENT ONLY):
      // XOR plaintext with key (repeated) and IV
      final ciphertext = Uint8List(plaintextBytes.length);
      for (var i = 0; i < plaintextBytes.length; i++) {
        ciphertext[i] = plaintextBytes[i] ^ keyBytes[i % keyBytes.length] ^ iv[i % iv.length];
      }

      // Generate mock authentication tag (16 bytes)
      // TODO: Replace with real GCM tag
      final tag = Uint8List(16);
      for (var i = 0; i < tag.length; i++) {
        tag[i] = random.nextInt(256);
      }

      // Base64 encode components
      final base64Ciphertext = base64.encode(ciphertext);
      final base64Iv = base64.encode(iv);
      final base64Tag = base64.encode(tag);

      // Create EncryptedMeasurement
      return EncryptedMeasurement(
        id: measurement.id,
        userId: measurement.userId,
        metricType: measurement.metricType.name,
        encryptedData: base64Ciphertext,
        iv: base64Iv,
        tag: base64Tag,
        timestamp: measurement.timestamp,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt list of encrypted measurements
  ///
  /// **Current Implementation**: Simplified using crypto package
  /// **TODO**: Full AES-256-GCM requires `pointycastle` or `encrypt` package
  ///
  /// **Decryption Process**:
  /// 1. Get encryption key once for all measurements
  /// 2. For each encrypted measurement:
  ///    a. Base64 decode ciphertext, IV, tag
  ///    b. Decrypt with AES-256-GCM
  ///    c. Verify authentication tag
  ///    d. Parse JSON to Measurement
  /// 3. Return list of decrypted measurements
  Future<List<Measurement>> _decryptMeasurements(
    List<EncryptedMeasurement> encryptedMeasurements,
    String userId,
  ) async {
    final measurements = <Measurement>[];

    // Get encryption key once for all measurements
    final keyResult = await _keyManager.getKey(userId);
    if (keyResult.isLeft()) {
      // Can't decrypt without key, return empty list
      return [];
    }

    final base64Key = keyResult.getOrElse((_) => '');
    final keyBytes = base64.decode(base64Key);

    for (final encrypted in encryptedMeasurements) {
      try {
        // Base64 decode components
        final ciphertext = base64.decode(encrypted.encryptedData);
        final iv = base64.decode(encrypted.iv);
        final tag = base64.decode(encrypted.tag);

        // TODO: Implement full AES-256-GCM decryption with tag verification
        // For now, use simplified approach (matches encryption)

        // TEMPORARY IMPLEMENTATION (NOT SECURE - FOR DEVELOPMENT ONLY):
        // XOR ciphertext with key (repeated) and IV to get plaintext
        final plaintext = Uint8List(ciphertext.length);
        for (var i = 0; i < ciphertext.length; i++) {
          plaintext[i] = ciphertext[i] ^ keyBytes[i % keyBytes.length] ^ iv[i % iv.length];
        }

        // Convert bytes to JSON string
        final plaintextJson = utf8.decode(plaintext);

        // Parse JSON to Measurement
        final measurementJson = jsonDecode(plaintextJson) as Map<String, dynamic>;
        final measurement = Measurement.fromJson(measurementJson);

        measurements.add(measurement);
      } catch (e) {
        // Skip measurements that fail to decrypt (corrupted, wrong key, etc.)
        // TODO: Add audit log entry for decryption failures (Task 2.9)
        continue;
      }
    }

    return measurements;
  }

  /// Filter measurements by user consent (GDPR compliance)
  ///
  /// Only returns measurements for metrics user has explicitly consented to track.
  /// Non-consented metrics are filtered out automatically.
  ///
  /// **GDPR Article 6**: Legal basis for processing (consent required)
  /// **GDPR Article 7**: Conditions for consent (explicit, informed, freely given)
  Future<List<Measurement>> _filterByConsent(
    String userId,
    List<Measurement> measurements,
  ) async {
    final consentedMeasurements = <Measurement>[];

    for (final measurement in measurements) {
      final hasConsentResult = await _consentRepo.hasConsentFor(
        userId,
        measurement.metricType,
      );

      if (hasConsentResult.isRight() &&
          hasConsentResult.getOrElse((_) => false)) {
        consentedMeasurements.add(measurement);
      }
    }

    return consentedMeasurements;
  }
}
