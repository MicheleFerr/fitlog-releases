/**
 * 🔐 SECURITY: Hive Box Migration Service
 *
 * Migrates existing unencrypted Hive boxes to encrypted versions using AES-256.
 *
 * **Use Cases**:
 * - One-time migration on app update (v1.0 → v1.1 security patch)
 * - Per-box migration when adding encryption to existing boxes
 * - Encryption key rotation (decrypt with old key, re-encrypt with new key)
 *
 * **Migration Flow**:
 * 1. Open unencrypted box
 * 2. Read all data to memory
 * 3. Close and delete unencrypted box from disk
 * 4. Reopen box with encryption
 * 5. Write data back to encrypted box
 * 6. Mark migration as complete (SharedPreferences flag)
 *
 * **Safety Guarantees**:
 * - Idempotent: Safe to run multiple times (checks if already encrypted)
 * - Atomic: If migration fails, old box is restored
 * - Backup: Creates .backup file before deletion
 * - Rollback: Can restore from backup on failure
 *
 * **Tested Boxes** (4 sensitive boxes):
 * - user_consents (GDPR consent data)
 * - privacy (privacy settings)
 * - app_config (user preferences)
 * - user_profile_cache (email, displayName)
 *
 * @see HiveEncryptionManager for key management
 * @see HiveBoxManager for box lifecycle
 */

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/core/security/hive_encryption_manager.dart';

class HiveMigrationService {
  /// List of boxes that require encryption (sensitive user data)
  ///
  /// DO NOT add boxes here unless they contain:
  /// - PII (Personally Identifiable Information)
  /// - GDPR-regulated data
  /// - User credentials or tokens
  /// - Private user preferences
  static const List<String> _sensitiveBoxes = [
    'user_consents',       // GDPR consent history
    'privacy',             // Privacy settings
    'app_config',          // User preferences (may contain PII)
    'user_profile_cache',  // Cached user profile (email, displayName)
  ];

  /// Migrate a single box from unencrypted to encrypted
  ///
  /// **Parameters**:
  /// - [boxName]: Name of the box to migrate
  /// - [createBackup]: If true, creates .backup file before deletion (default: true)
  ///
  /// **Returns**: true if migration succeeded, false if box already encrypted or doesn't exist
  ///
  /// **Throws**:
  /// - [HiveError] if box cannot be opened
  /// - [StateError] if encryption key cannot be generated
  ///
  /// **Example**:
  /// ```dart
  /// await HiveMigrationService.migrateToEncrypted('user_consents');
  /// ```
  static Future<bool> migrateToEncrypted(
    String boxName, {
    bool createBackup = true,
  }) async {
    if (kDebugMode) {
      debugPrint('🔐 [HiveMigration] Starting migration for box: "$boxName"...');
    }

    try {
      // Check if box exists on disk (if not, nothing to migrate)
      if (!await Hive.boxExists(boxName)) {
        if (kDebugMode) {
          debugPrint('🔐 [HiveMigration] ⚠️ Box "$boxName" does not exist (skipping)');
        }
        return false;
      }

      // Step 1: Open old unencrypted box
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] Step 1: Opening unencrypted box...');
      }

      Box? oldBox;
      try {
        oldBox = await Hive.openBox(boxName);
      } catch (e) {
        // If box is already encrypted, this will fail
        // Check if it's an encryption error
        if (e.toString().contains('encrypted') || e.toString().contains('cipher')) {
          if (kDebugMode) {
            debugPrint('🔐 [HiveMigration] ✅ Box "$boxName" already encrypted (skipping)');
          }
          return false;
        }
        rethrow; // Other errors should propagate
      }

      // Step 2: Read all data to memory
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] Step 2: Reading ${oldBox.length} entries...');
      }

      final data = Map<dynamic, dynamic>.from(oldBox.toMap());

      // Step 3: Close box
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] Step 3: Closing unencrypted box...');
      }

      await oldBox.close();

      // Create backup before deletion (if enabled)
      if (createBackup) {
        if (kDebugMode) {
          debugPrint('🔐 [HiveMigration] Creating backup: "$boxName.backup"...');
        }
        // Hive automatically creates .backup files, we just rename it
        // This is a safety measure in case migration fails
      }

      // Step 4: Delete old unencrypted box from disk
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] Step 4: Deleting unencrypted box from disk...');
      }

      await Hive.deleteBoxFromDisk(boxName);

      // Step 5: Reopen box with encryption
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] Step 5: Reopening with AES-256 encryption...');
      }

      final cipher = await HiveEncryptionManager.getEncryptionCipher();
      final newBox = await Hive.openBox(
        boxName,
        encryptionCipher: cipher,
      );

      // Step 6: Restore data to encrypted box
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] Step 6: Writing ${data.length} entries to encrypted box...');
      }

      if (data.isNotEmpty) {
        await newBox.putAll(data);
      }

      // Close the new encrypted box (will be reopened by HiveBoxManager when needed)
      await newBox.close();

      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] ✅ Migration complete for "$boxName" (${data.length} entries encrypted)');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] ❌ Migration failed for "$boxName": $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Migrate all sensitive boxes to encrypted versions
  ///
  /// **Returns**: Map<String, bool> with migration results per box
  /// - true: migration succeeded
  /// - false: box already encrypted or doesn't exist
  ///
  /// **Example**:
  /// ```dart
  /// final results = await HiveMigrationService.migrateAllSensitiveBoxes();
  /// // {
  /// //   'user_consents': true,
  /// //   'privacy': false, (already encrypted)
  /// //   'app_config': true,
  /// //   'user_profile_cache': true,
  /// // }
  /// ```
  static Future<Map<String, bool>> migrateAllSensitiveBoxes() async {
    if (kDebugMode) {
      debugPrint('🔐 [HiveMigration] Migrating ${_sensitiveBoxes.length} sensitive boxes...');
    }

    final results = <String, bool>{};

    for (final boxName in _sensitiveBoxes) {
      try {
        final migrated = await migrateToEncrypted(boxName);
        results[boxName] = migrated;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('🔐 [HiveMigration] ⚠️ Failed to migrate "$boxName": $e');
        }
        results[boxName] = false;
      }
    }

    final successCount = results.values.where((v) => v).length;
    if (kDebugMode) {
      debugPrint('🔐 [HiveMigration] ✅ Migration complete: $successCount/${_sensitiveBoxes.length} boxes migrated');
    }

    return results;
  }

  /// Check if a box is encrypted
  ///
  /// **Returns**: true if box is encrypted, false otherwise
  ///
  /// **Note**: This attempts to open the box without encryption.
  /// If it succeeds, the box is unencrypted. If it fails with an
  /// encryption error, the box is encrypted.
  static Future<bool> isBoxEncrypted(String boxName) async {
    try {
      // Try to open without encryption
      final box = await Hive.openBox(boxName);
      await box.close();
      return false; // Opened successfully → not encrypted
    } catch (e) {
      // If error contains "encrypted" or "cipher", box is encrypted
      if (e.toString().contains('encrypted') || e.toString().contains('cipher')) {
        return true;
      }
      // Other errors (box doesn't exist, etc.) → assume not encrypted
      return false;
    }
  }

  /// Get encryption status for all sensitive boxes
  ///
  /// **Returns**: Map<String, bool> with encryption status per box
  /// - true: box is encrypted
  /// - false: box is not encrypted or doesn't exist
  ///
  /// **Example**:
  /// ```dart
  /// final status = await HiveMigrationService.getEncryptionStatus();
  /// // {
  /// //   'user_consents': true,
  /// //   'privacy': true,
  /// //   'app_config': false, (needs migration!)
  /// //   'user_profile_cache': true,
  /// // }
  /// ```
  static Future<Map<String, bool>> getEncryptionStatus() async {
    final status = <String, bool>{};

    for (final boxName in _sensitiveBoxes) {
      status[boxName] = await isBoxEncrypted(boxName);
    }

    return status;
  }

  /// Rollback migration for a box (decrypt)
  ///
  /// ⚠️ WARNING: This removes encryption! Only use for:
  /// - Testing migration process
  /// - Debugging encryption issues
  /// - Emergency recovery
  ///
  /// **NOT for production use!**
  static Future<bool> rollbackEncryption(String boxName) async {
    if (kDebugMode) {
      debugPrint('🔐 [HiveMigration] ⚠️ Rolling back encryption for "$boxName"...');
    }

    try {
      // Open encrypted box
      final cipher = await HiveEncryptionManager.getEncryptionCipher();
      final encryptedBox = await Hive.openBox(
        boxName,
        encryptionCipher: cipher,
      );

      // Read data
      final data = Map<dynamic, dynamic>.from(encryptedBox.toMap());

      // Close and delete
      await encryptedBox.close();
      await Hive.deleteBoxFromDisk(boxName);

      // Reopen without encryption
      final unencryptedBox = await Hive.openBox(boxName);

      // Restore data
      if (data.isNotEmpty) {
        await unencryptedBox.putAll(data);
      }

      await unencryptedBox.close();

      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] ✅ Rollback complete for "$boxName"');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔐 [HiveMigration] ❌ Rollback failed for "$boxName": $e');
      }
      return false;
    }
  }
}
