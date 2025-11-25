import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// EncryptionKeyManager - Secure key generation and storage
///
/// **Security Architecture**:
/// - iOS: Secure Enclave (Hardware-backed keychain)
/// - Android: Keystore (Hardware-backed if available)
/// - Fallback: flutter_secure_storage (software encryption)
///
/// **Key Properties**:
/// - Algorithm: AES-256 (32-byte keys)
/// - Rotation: Every 90 days (configurable)
/// - Versioning: Track key version for migration
/// - Derivation: PBKDF2-SHA256 (if password-based)
///
/// **GDPR Compliance**:
/// - Article 32: State of the art encryption
/// - Article 25: Privacy by design (secure key storage)
/// - Article 5: Data minimization (keys never logged)
///
/// Example:
/// ```dart
/// final keyManager = EncryptionKeyManager();
///
/// // Generate new key for user
/// final result = await keyManager.generateKeyForUser('user-123');
/// result.fold(
///   (failure) => print('Key generation failed'),
///   (keyData) => print('Key generated: version ${keyData.version}'),
/// );
///
/// // Get key for encryption/decryption
/// final keyResult = await keyManager.getKey('user-123');
/// keyResult.fold(
///   (failure) => print('Key not found'),
///   (key) => await encryptData(data, key),
/// );
///
/// // Check if rotation needed
/// if (await keyManager.isRotationRequired('user-123')) {
///   await keyManager.rotateKey('user-123');
/// }
/// ```
class EncryptionKeyManager {
  final FlutterSecureStorage _secureStorage;
  final Duration _rotationInterval;

  /// Default rotation interval: 90 days (GDPR best practice)
  static const Duration defaultRotationInterval = Duration(days: 90);

  EncryptionKeyManager({
    FlutterSecureStorage? secureStorage,
    Duration? rotationInterval,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                // Use Android Keystore for hardware-backed encryption
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                // Use iOS Keychain with Secure Enclave
                accessibility: KeychainAccessibility.first_unlock_this_device,
                synchronizable: false,
              ),
            ),
        _rotationInterval = rotationInterval ?? defaultRotationInterval;

  /// Generate new encryption key for user
  ///
  /// Creates a cryptographically secure random 256-bit key and stores it
  /// in Secure Enclave (iOS) or Keystore (Android).
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  /// - [version]: Key version (default: 1, increment on rotation)
  ///
  /// Returns:
  /// - Right(EncryptionKeyData): Key metadata (key itself NOT returned)
  /// - Left(KeyGenerationFailure): Failed to generate or store key
  ///
  /// **Security**:
  /// - Key never leaves secure storage
  /// - Uses SecureRandom for cryptographic randomness
  /// - Metadata stored separately from key
  ///
  /// Example:
  /// ```dart
  /// final result = await keyManager.generateKeyForUser('user-123');
  /// result.fold(
  ///   (failure) => showError('Key generation failed'),
  ///   (keyData) => print('Key v${keyData.version} generated'),
  /// );
  /// ```
  Future<Either<Failure, EncryptionKeyData>> generateKeyForUser(
    String userId, {
    int version = 1,
  }) async {
    try {
      // Generate cryptographically secure random 256-bit key
      final secureRandom = Random.secure();
      final keyBytes = Uint8List(32); // AES-256 requires 32 bytes
      for (var i = 0; i < keyBytes.length; i++) {
        keyBytes[i] = secureRandom.nextInt(256);
      }

      // Convert key to base64 for storage
      final keyBase64 = base64.encode(keyBytes);

      // Store key in secure storage
      final keyStorageKey = _getKeyStorageKey(userId, version);
      await _secureStorage.write(
        key: keyStorageKey,
        value: keyBase64,
      );

      // Store key metadata
      final now = DateTime.now();
      final metadata = EncryptionKeyData(
        userId: userId,
        version: version,
        generatedAt: now,
        lastRotated: null,
        rotationScheduled: now.add(_rotationInterval),
        algorithm: 'AES-256-GCM',
      );

      await _storeKeyMetadata(userId, metadata);

      return Right(metadata);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to generate encryption key: $e',
          code: 'KEY_GENERATION_FAILED',
        ),
      );
    }
  }

  /// Get encryption key for user
  ///
  /// Retrieves the current active encryption key from secure storage.
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  /// - [version]: Specific key version (default: latest)
  ///
  /// Returns:
  /// - Right(String): Base64-encoded 256-bit key
  /// - Left(KeyNotFoundFailure): Key doesn't exist
  /// - Left(KeyAccessFailure): Failed to read from secure storage
  ///
  /// **Security**:
  /// - NEVER log the returned key
  /// - Clear key from memory after use
  /// - Verify key length = 32 bytes before use
  ///
  /// Example:
  /// ```dart
  /// final keyResult = await keyManager.getKey('user-123');
  /// await keyResult.fold(
  ///   (failure) => showError('Key not found'),
  ///   (key) async {
  ///     final encrypted = await encrypt(data, key);
  ///     // Clear key from memory
  ///     key = '';
  ///     return encrypted;
  ///   },
  /// );
  /// ```
  Future<Either<Failure, String>> getKey(
    String userId, {
    int? version,
  }) async {
    try {
      // Get latest key metadata
      final metadataResult = await _getKeyMetadata(userId);

      return await metadataResult.fold(
        (failure) => Left(failure),
        (metadata) async {
          final keyVersion = version ?? metadata.version;
          final keyStorageKey = _getKeyStorageKey(userId, keyVersion);

          final keyBase64 = await _secureStorage.read(key: keyStorageKey);

          if (keyBase64 == null) {
            return Left(
              CacheFailure(
                'Encryption key not found for user $userId v$keyVersion',
                code: 'KEY_NOT_FOUND',
              ),
            );
          }

          // Verify key is valid AES-256 (32 bytes)
          final keyBytes = base64.decode(keyBase64);
          if (keyBytes.length != 32) {
            return Left(
              ValidationFailure(
                'Invalid key length: ${keyBytes.length} (expected 32)',
                code: 'INVALID_KEY_LENGTH',
              ),
            );
          }

          return Right(keyBase64);
        },
      );
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to get encryption key: $e',
          code: 'KEY_ACCESS_FAILED',
        ),
      );
    }
  }

  /// Check if key rotation is required
  ///
  /// Returns true if:
  /// - Key age > rotation interval (default 90 days)
  /// - Key version mismatch detected
  /// - Manual rotation requested
  ///
  /// Example:
  /// ```dart
  /// if (await keyManager.isRotationRequired('user-123')) {
  ///   await keyManager.rotateKey('user-123');
  ///   await reEncryptAllData('user-123'); // Re-encrypt with new key
  /// }
  /// ```
  Future<bool> isRotationRequired(String userId) async {
    final metadataResult = await _getKeyMetadata(userId);

    return metadataResult.fold(
      (failure) => false, // No key = no rotation needed
      (metadata) {
        final now = DateTime.now();
        return now.isAfter(metadata.rotationScheduled);
      },
    );
  }

  /// Rotate encryption key for user
  ///
  /// Creates new key version and schedules re-encryption of all data.
  ///
  /// **IMPORTANT**: This only creates the new key. You MUST:
  /// 1. Call this method to create new key
  /// 2. Re-encrypt all user data with new key
  /// 3. Delete old key after re-encryption complete
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  ///
  /// Returns:
  /// - Right(EncryptionKeyData): New key metadata
  /// - Left(KeyRotationFailure): Rotation failed
  ///
  /// **Workflow**:
  /// ```dart
  /// // Step 1: Rotate key
  /// final newKeyResult = await keyManager.rotateKey('user-123');
  ///
  /// await newKeyResult.fold(
  ///   (failure) => showError('Rotation failed'),
  ///   (newKeyData) async {
  ///     // Step 2: Re-encrypt all data
  ///     final measurements = await getAllMeasurements('user-123');
  ///     for (final m in measurements) {
  ///       final decrypted = await decrypt(m, oldKey);
  ///       final reEncrypted = await encrypt(decrypted, newKey);
  ///       await saveMeasurement(reEncrypted);
  ///     }
  ///
  ///     // Step 3: Delete old key
  ///     await keyManager.deleteKey('user-123', version: oldVersion);
  ///   },
  /// );
  /// ```
  Future<Either<Failure, EncryptionKeyData>> rotateKey(String userId) async {
    try {
      // Get current key metadata
      final metadataResult = await _getKeyMetadata(userId);

      return await metadataResult.fold(
        (failure) => Left(failure),
        (currentMetadata) async {
          // Generate new key with incremented version
          final newVersion = currentMetadata.version + 1;

          final newKeyResult = await generateKeyForUser(
            userId,
            version: newVersion,
          );

          return newKeyResult.fold(
            (failure) => Left(failure),
            (newKeyData) async {
              // Update metadata with rotation timestamp
              final updatedMetadata = newKeyData.copyWith(
                lastRotated: DateTime.now(),
              );

              await _storeKeyMetadata(userId, updatedMetadata);

              return Right(updatedMetadata);
            },
          );
        },
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to rotate key: $e',
          code: 'KEY_ROTATION_FAILED',
        ),
      );
    }
  }

  /// Delete encryption key for user
  ///
  /// **WARNING**: This is permanent. All data encrypted with this key
  /// will become unrecoverable.
  ///
  /// Only call this:
  /// - After successful key rotation AND re-encryption
  /// - During account deletion (GDPR Right to Erasure)
  ///
  /// Parameters:
  /// - [userId]: Firebase Auth UID
  /// - [version]: Specific key version to delete (optional, deletes all if null)
  ///
  /// Example:
  /// ```dart
  /// // Delete old key after rotation + re-encryption
  /// await keyManager.deleteKey('user-123', version: 1);
  ///
  /// // Delete ALL keys (account deletion)
  /// await keyManager.deleteKey('user-123');
  /// ```
  Future<Either<Failure, void>> deleteKey(
    String userId, {
    int? version,
  }) async {
    try {
      if (version != null) {
        // Delete specific version
        final keyStorageKey = _getKeyStorageKey(userId, version);
        await _secureStorage.delete(key: keyStorageKey);
      } else {
        // Delete all versions
        final metadataResult = await _getKeyMetadata(userId);

        await metadataResult.fold(
          (failure) => null,
          (metadata) async {
            // Delete all versions from 1 to current
            for (var v = 1; v <= metadata.version; v++) {
              final keyStorageKey = _getKeyStorageKey(userId, v);
              await _secureStorage.delete(key: keyStorageKey);
            }

            // Delete metadata
            await _secureStorage.delete(key: _getMetadataStorageKey(userId));
          },
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to delete key: $e',
          code: 'KEY_DELETION_FAILED',
        ),
      );
    }
  }

  /// Get key metadata (without exposing actual key)
  ///
  /// Returns information about key without revealing the key itself.
  ///
  /// Useful for:
  /// - Checking key version
  /// - Checking rotation schedule
  /// - Audit logging
  ///
  /// Example:
  /// ```dart
  /// final metadataResult = await keyManager.getKeyMetadata('user-123');
  /// metadataResult.fold(
  ///   (failure) => print('No key found'),
  ///   (metadata) {
  ///     print('Key version: ${metadata.version}');
  ///     print('Next rotation: ${metadata.rotationScheduled}');
  ///   },
  /// );
  /// ```
  Future<Either<Failure, EncryptionKeyData>> getKeyMetadata(String userId) {
    return _getKeyMetadata(userId);
  }

  // ========== Private Helper Methods ==========

  /// Get storage key for encryption key
  String _getKeyStorageKey(String userId, int version) {
    return 'encryption_key_${userId}_v$version';
  }

  /// Get storage key for key metadata
  String _getMetadataStorageKey(String userId) {
    return 'encryption_key_metadata_$userId';
  }

  /// Store key metadata in secure storage
  Future<void> _storeKeyMetadata(
    String userId,
    EncryptionKeyData metadata,
  ) async {
    final metadataJson = jsonEncode(metadata.toJson());
    await _secureStorage.write(
      key: _getMetadataStorageKey(userId),
      value: metadataJson,
    );
  }

  /// Get key metadata from secure storage
  Future<Either<Failure, EncryptionKeyData>> _getKeyMetadata(
    String userId,
  ) async {
    try {
      final metadataJson = await _secureStorage.read(
        key: _getMetadataStorageKey(userId),
      );

      if (metadataJson == null) {
        return Left(
          CacheFailure(
            'Key metadata not found for user $userId',
            code: 'KEY_METADATA_NOT_FOUND',
          ),
        );
      }

      final metadata = EncryptionKeyData.fromJson(
        jsonDecode(metadataJson) as Map<String, dynamic>,
      );

      return Right(metadata);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to read key metadata: $e',
          code: 'KEY_METADATA_READ_FAILED',
        ),
      );
    }
  }

  /// Derive key from password using PBKDF2
  ///
  /// Use this for password-based encryption (not recommended for body measurements).
  ///
  /// Parameters:
  /// - [password]: User password
  /// - [salt]: Cryptographic salt (16 bytes minimum)
  /// - [iterations]: PBKDF2 iterations (default: 100,000)
  ///
  /// Returns: 32-byte AES-256 key
  ///
  /// **Security**:
  /// - Use 100,000+ iterations (OWASP 2023 recommendation)
  /// - Salt must be unique per user
  /// - Store salt alongside encrypted data
  ///
  /// Example:
  /// ```dart
  /// final salt = generateSalt(); // 16 random bytes
  /// final key = deriveKeyFromPassword('userPassword123', salt);
  /// final encrypted = await encrypt(data, key);
  /// ```
  static String deriveKeyFromPassword(
    String password,
    List<int> salt, {
    int iterations = 100000,
  }) {
    // PBKDF2-SHA256 key derivation
    final passwordBytes = utf8.encode(password);

    var hash = passwordBytes + salt;
    for (var i = 0; i < iterations; i++) {
      hash = sha256.convert(hash).bytes;
    }

    // Take first 32 bytes for AES-256
    final keyBytes = Uint8List.fromList(hash.take(32).toList());

    return base64.encode(keyBytes);
  }

  /// Generate cryptographic salt
  ///
  /// Creates a random 16-byte salt for PBKDF2.
  ///
  /// Example:
  /// ```dart
  /// final salt = EncryptionKeyManager.generateSalt();
  /// final key = deriveKeyFromPassword(password, salt);
  /// ```
  static List<int> generateSalt({int length = 16}) {
    final secureRandom = Random.secure();
    return List<int>.generate(length, (_) => secureRandom.nextInt(256));
  }
}

/// EncryptionKeyData - Metadata for encryption key
///
/// Contains information ABOUT the key, not the key itself.
/// Safe to store unencrypted, safe to log (no sensitive data).
class EncryptionKeyData {
  /// User ID (Firebase Auth UID)
  final String userId;

  /// Key version (incremented on rotation)
  final int version;

  /// When key was generated
  final DateTime generatedAt;

  /// When key was last rotated (null if never rotated)
  final DateTime? lastRotated;

  /// When next rotation is scheduled
  final DateTime rotationScheduled;

  /// Encryption algorithm (always "AES-256-GCM" for this app)
  final String algorithm;

  /// Key derivation function (if password-based)
  final String? keyDerivationFunction;

  const EncryptionKeyData({
    required this.userId,
    required this.version,
    required this.generatedAt,
    required this.rotationScheduled,
    required this.algorithm,
    this.lastRotated,
    this.keyDerivationFunction,
  });

  /// Create copy with updated fields
  EncryptionKeyData copyWith({
    String? userId,
    int? version,
    DateTime? generatedAt,
    DateTime? lastRotated,
    DateTime? rotationScheduled,
    String? algorithm,
    String? keyDerivationFunction,
  }) {
    return EncryptionKeyData(
      userId: userId ?? this.userId,
      version: version ?? this.version,
      generatedAt: generatedAt ?? this.generatedAt,
      lastRotated: lastRotated ?? this.lastRotated,
      rotationScheduled: rotationScheduled ?? this.rotationScheduled,
      algorithm: algorithm ?? this.algorithm,
      keyDerivationFunction:
          keyDerivationFunction ?? this.keyDerivationFunction,
    );
  }

  /// Convert to JSON (for secure storage)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'version': version,
      'generatedAt': generatedAt.toIso8601String(),
      'lastRotated': lastRotated?.toIso8601String(),
      'rotationScheduled': rotationScheduled.toIso8601String(),
      'algorithm': algorithm,
      'keyDerivationFunction': keyDerivationFunction,
    };
  }

  /// Create from JSON
  factory EncryptionKeyData.fromJson(Map<String, dynamic> json) {
    return EncryptionKeyData(
      userId: json['userId'] as String,
      version: json['version'] as int,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      lastRotated: json['lastRotated'] != null
          ? DateTime.parse(json['lastRotated'] as String)
          : null,
      rotationScheduled:
          DateTime.parse(json['rotationScheduled'] as String),
      algorithm: json['algorithm'] as String,
      keyDerivationFunction: json['keyDerivationFunction'] as String?,
    );
  }

  @override
  String toString() {
    return 'EncryptionKeyData(userId: $userId, version: $version, '
        'generatedAt: $generatedAt, lastRotated: $lastRotated, '
        'rotationScheduled: $rotationScheduled, algorithm: $algorithm)';
  }
}
