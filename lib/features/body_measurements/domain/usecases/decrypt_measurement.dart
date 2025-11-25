import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/encrypted_measurement.dart';

/// DecryptMeasurement - Use case for decrypting measurement data
///
/// **Domain layer contract** (no implementation here).
/// Data layer implements this interface using AES-256-GCM decryption.
///
/// **GDPR Compliance**: Transparent decryption (Article 25)
/// - Data encrypted at rest, decrypted in memory for user access
/// - Decryption only with valid user key (data isolation)
/// - Failed decryption = access denied (key rotation, wrong user)
///
/// **Security Properties**:
/// - Confidentiality: Only correct key decrypts successfully
/// - Integrity: GCM tag verification prevents tampered data
/// - Authentication: Tag verification proves data from legitimate source
///
/// Example:
/// ```dart
/// final decryptMeasurement = DecryptMeasurementImpl(keyManager);
///
/// final encrypted = await datasource.read(measurementId);
/// final key = await keyManager.getKey(userId);
///
/// final result = await decryptMeasurement.call(encrypted, key);
/// result.fold(
///   (failure) => showError('Failed to decrypt: ${failure.message}'),
///   (measurement) => displayMeasurement(measurement),
/// );
/// ```
abstract class DecryptMeasurement {
  /// Decrypt an encrypted measurement using AES-256-GCM
  ///
  /// Parameters:
  /// - [encrypted]: Encrypted measurement (from storage)
  /// - [encryptionKey]: User's encryption key (from EncryptionKeyManager)
  ///
  /// Returns:
  /// - Right(Measurement): Successfully decrypted
  /// - Left(DecryptionFailure): Decryption failed (wrong key, tampered data)
  /// - Left(KeyRotationRequiredFailure): Key version mismatch (re-encrypt with new key)
  ///
  /// **Implementation Requirements**:
  /// 1. Base64 decode: encryptedData, IV, tag
  /// 2. Verify key length = 32 bytes (AES-256)
  /// 3. Decrypt with AES-256-GCM (key + IV)
  /// 4. Verify GCM tag (integrity check)
  /// 5. Deserialize JSON to Measurement
  /// 6. Return Measurement
  ///
  /// **Security Requirements**:
  /// - NEVER log encryption key or decrypted data
  /// - ALWAYS verify GCM tag (fail if tag invalid)
  /// - NEVER return partial data on tag verification failure
  /// - Clear decrypted data from memory after use
  ///
  /// **Failure Modes**:
  /// - Wrong key: Decryption produces garbage → JSON parse error
  /// - Tampered data: GCM tag verification fails → DecryptionFailure
  /// - Corrupted data: Base64 decode fails → DecryptionFailure
  /// - Key rotation: Key version mismatch → KeyRotationRequiredFailure
  ///
  /// Example:
  /// ```dart
  /// final decrypted = await decryptMeasurement.call(encrypted, key);
  /// decrypted.fold(
  ///   (failure) {
  ///     if (failure is KeyRotationRequiredFailure) {
  ///       // Trigger key rotation + re-encryption workflow
  ///       await keyManager.rotateKey(userId);
  ///     } else {
  ///       showError('Decryption failed');
  ///     }
  ///   },
  ///   (measurement) => print('Decrypted: ${measurement.value} ${measurement.unit}'),
  /// );
  /// ```
  Future<Either<DecryptionFailure, Measurement>> call(
    EncryptedMeasurement encrypted,
    String encryptionKey,
  );
}

/// DecryptionFailure - Error types for decryption operations
sealed class DecryptionFailure {
  const DecryptionFailure();
}

/// Invalid encryption key (wrong length, format)
class InvalidKeyFailure extends DecryptionFailure {
  final String message;
  const InvalidKeyFailure(this.message);
}

/// Decryption operation failed
class DecryptionOperationFailure extends DecryptionFailure {
  final String message;
  final Object? error;
  const DecryptionOperationFailure({required this.message, this.error});
}

/// GCM tag verification failed (data tampered)
class TagVerificationFailure extends DecryptionFailure {
  final String message;
  const TagVerificationFailure(this.message);
}

/// Key rotation required (version mismatch)
class KeyRotationRequiredFailure extends DecryptionFailure {
  final String message;
  const KeyRotationRequiredFailure(this.message);
}
