import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/services/encryption_key_manager.dart';

/// Provider for EncryptionKeyManager
///
/// Provides singleton instance of EncryptionKeyManager for AES-256-GCM encryption.
///
/// **Security Architecture**:
/// - Keys stored in Secure Enclave (iOS) / Keystore (Android)
/// - Per-user encryption keys (data isolation)
/// - Key rotation every 90 days (forward secrecy)
/// - GDPR Article 25 compliance (encryption by design)
///
/// **Lifecycle**:
/// - Initialized once on app startup (via app initialization)
/// - Closed on app shutdown (via app dispose)
///
/// **Usage in Data Layer**:
/// ```dart
/// final keyManager = ref.read(encryptionKeyManagerProvider);
///
/// // Get user's encryption key
/// final keyResult = await keyManager.getKey('user-123');
/// keyResult.fold(
///   (failure) => print('Failed to get key: ${failure.message}'),
///   (key) async {
///     // Encrypt measurement
///     final encryptResult = await keyManager.encrypt(plaintext, key);
///   },
/// );
/// ```
final encryptionKeyManagerProvider = Provider<EncryptionKeyManager>((ref) {
  return EncryptionKeyManager();
});
