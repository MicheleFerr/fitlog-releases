import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/encrypted_measurement.dart';

/// EncryptMeasurement - Use case for encrypting measurement data
///
/// **Domain layer contract** (no implementation here).
/// Data layer implements this interface using AES-256-GCM encryption.
///
/// **GDPR Compliance**: Encryption by design (Article 25)
/// - All sensitive PII encrypted before storage
/// - Per-user encryption keys (data isolated)
/// - Keys managed by EncryptionKeyManager (Secure Enclave/Keystore)
///
/// **Security Properties**:
/// - Confidentiality: Only user with encryption key can decrypt
/// - Integrity: GCM authentication prevents tampering
/// - Forward secrecy: Key rotation every 90 days
///
/// Example:
/// ```dart
/// final encryptMeasurement = EncryptMeasurementImpl(keyManager);
///
/// final measurement = Measurement(...);
/// final key = await keyManager.getKey(userId);
///
/// final result = await encryptMeasurement.call(measurement, key);
/// result.fold(
///   (failure) => print('Encryption failed: ${failure.message}'),
///   (encrypted) => await datasource.save(encrypted),
/// );
/// ```
abstract class EncryptMeasurement {
  /// Encrypt a measurement using AES-256-GCM
  ///
  /// Parameters:
  /// - [measurement]: Measurement to encrypt (plaintext)
  /// - [encryptionKey]: User's encryption key (from EncryptionKeyManager)
  ///
  /// Returns:
  /// - Right(EncryptedMeasurement): Successfully encrypted
  /// - Left(EncryptionFailure): Encryption failed (invalid key, crypto error)
  ///
  /// **Implementation Requirements**:
  /// 1. Generate random IV (12 bytes) for AES-GCM
  /// 2. Serialize measurement to JSON
  /// 3. Encrypt JSON with AES-256-GCM (key + IV)
  /// 4. Base64 encode: encryptedData, IV, tag
  /// 5. Return EncryptedMeasurement with all fields
  ///
  /// **Security Requirements**:
  /// - NEVER reuse IV with same key (generates new IV each time)
  /// - NEVER log encryption key or plaintext data
  /// - Verify key length = 32 bytes (AES-256)
  /// - Use secure random for IV generation
  ///
  /// Example:
  /// ```dart
  /// final encrypted = await encryptMeasurement.call(measurement, key);
  /// ```
  Future<Either<EncryptionFailure, EncryptedMeasurement>> call(
    Measurement measurement,
    String encryptionKey,
  );
}

/// EncryptionFailure - Error types for encryption operations
sealed class EncryptionFailure {
  const EncryptionFailure();
}

/// Invalid encryption key (wrong length, format)
class InvalidKeyFailure extends EncryptionFailure {
  final String message;
  const InvalidKeyFailure(this.message);
}

/// Encryption operation failed
class EncryptionOperationFailure extends EncryptionFailure {
  final String message;
  final Object? error;
  const EncryptionOperationFailure({required this.message, this.error});
}

/// IV generation failed
class IVGenerationFailure extends EncryptionFailure {
  final String message;
  const IVGenerationFailure(this.message);
}
