import 'package:freezed_annotation/freezed_annotation.dart';

part 'encrypted_measurement.freezed.dart';
part 'encrypted_measurement.g.dart';

/// EncryptedMeasurement - Value object for encrypted measurement data
///
/// Represents measurement data encrypted with AES-256-GCM.
/// Used for storage (Hive + Firestore) to ensure data-at-rest encryption.
///
/// **GDPR Compliance**: Encryption by design (Article 25, Article 32)
/// - All sensitive PII (measurement values, notes) encrypted
/// - AES-256-GCM authenticated encryption (prevents tampering)
/// - Per-user encryption keys (data isolated even if database breached)
/// - Keys stored in Secure Enclave (iOS) / Keystore (Android)
///
/// **Encryption Scheme**: AES-256-GCM
/// - Algorithm: AES (Advanced Encryption Standard)
/// - Key size: 256 bits (32 bytes)
/// - Mode: GCM (Galois/Counter Mode) - authenticated encryption
/// - IV: 96 bits (12 bytes) - randomly generated per encryption
/// - Tag: 128 bits (16 bytes) - authentication tag
///
/// Example:
/// ```dart
/// // Encrypt measurement (data layer implementation)
/// final encrypted = EncryptedMeasurement(
///   id: measurement.id,
///   userId: measurement.userId,
///   metricType: measurement.metricType.name,
///   encryptedData: 'base64EncodedCiphertext',
///   iv: 'base64EncodedIV',
///   tag: 'base64EncodedTag',
///   timestamp: measurement.timestamp,
/// );
///
/// // Save to Firestore/Hive (encrypted)
/// await datasource.save(encrypted);
///
/// // Decrypt when reading (data layer implementation)
/// final decrypted = await decryptMeasurement.call(encrypted, key);
/// ```
@freezed
class EncryptedMeasurement with _$EncryptedMeasurement {
  const factory EncryptedMeasurement({
    /// Measurement ID (same as original Measurement.id)
    required String id,

    /// User ID (Firebase Auth UID)
    required String userId,

    /// Metric type (stored unencrypted for querying)
    ///
    /// **Note**: MetricType is NOT sensitive PII, safe to store unencrypted.
    /// Allows efficient Firestore queries: "Get all weight measurements"
    required String metricType,

    /// Encrypted measurement data (base64 encoded)
    ///
    /// **Contains**: Measurement JSON serialized → encrypted → base64
    /// ```json
    /// {
    ///   "value": 75.5,
    ///   "unit": "kg",
    ///   "notes": "Morning weight after workout",
    ///   "source": "manual"
    /// }
    /// ```
    required String encryptedData,

    /// Initialization Vector (base64 encoded)
    ///
    /// **IV**: Randomly generated 12 bytes for AES-GCM.
    /// Must be unique per encryption operation (never reuse with same key).
    required String iv,

    /// Authentication tag (base64 encoded)
    ///
    /// **Tag**: 16-byte GCM tag for data integrity verification.
    /// Prevents tampering (decryption fails if data modified).
    required String tag,

    /// Timestamp (stored unencrypted for sorting/filtering)
    ///
    /// **Note**: Timestamp is NOT sensitive PII, safe to store unencrypted.
    /// Allows efficient queries: "Get measurements from last 30 days"
    required DateTime timestamp,

    /// When this encrypted measurement was created
    DateTime? createdAt,

    /// When this encrypted measurement was last updated
    DateTime? updatedAt,
  }) = _EncryptedMeasurement;

  factory EncryptedMeasurement.fromJson(Map<String, dynamic> json) =>
      _$EncryptedMeasurementFromJson(json);
}

/// EncryptionMetadata - Additional metadata for encryption operations
///
/// Used for key rotation and audit logging
@freezed
class EncryptionMetadata with _$EncryptionMetadata {
  const factory EncryptionMetadata({
    /// Encryption key version (incremented on key rotation)
    ///
    /// **Key Rotation**: Every 90 days or on-demand.
    /// Old encrypted data is re-encrypted with new key.
    required int keyVersion,

    /// When encryption key was generated
    required DateTime keyGeneratedAt,

    /// When encryption key was last rotated
    DateTime? keyLastRotated,

    /// Next scheduled key rotation date
    DateTime? keyRotationScheduled,

    /// Encryption algorithm used
    /// Default: "AES-256-GCM"
    @Default('AES-256-GCM') String algorithm,

    /// Key derivation function (if applicable)
    /// Example: "PBKDF2-SHA256" for password-derived keys
    String? keyDerivationFunction,
  }) = _EncryptionMetadata;

  factory EncryptionMetadata.fromJson(Map<String, dynamic> json) =>
      _$EncryptionMetadataFromJson(json);
}
