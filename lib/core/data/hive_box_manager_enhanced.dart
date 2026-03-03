import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/core/security/hive_encryption_manager.dart';

/// Custom exceptions for HiveBoxManagerEnhanced operations
class BoxOpenException implements Exception {
  BoxOpenException(this.boxName, this.message, [this.originalError]);

  final String boxName;
  final String message;
  final Object? originalError;

  @override
  String toString() =>
      'BoxOpenException($boxName): $message ${originalError != null ? '(caused by: $originalError)' : ''}';
}

class BoxCorruptedException implements Exception {
  BoxCorruptedException(this.boxName, this.originalError);

  final String boxName;
  final Object originalError;

  @override
  String toString() =>
      'BoxCorruptedException($boxName): Box corrupted, recovery attempted. Original error: $originalError';
}

/// Enhanced HiveBoxManagerEnhanced with error handling, concurrent access safety, and encryption support
///
/// ✅ IMPROVEMENTS:
/// - Error handling with retry logic and corruption recovery
/// - Thread-safe transactions with locks per box
/// - Encryption support for sensitive data
/// - LazyBox support for large datasets
/// - Batch operations (putAll, deleteAll)
/// - Automatic compaction
/// - Debug utilities
class HiveBoxManagerEnhanced {
  factory HiveBoxManagerEnhanced() => _instance;
  HiveBoxManagerEnhanced._internal();

  // Singleton pattern
  static final HiveBoxManagerEnhanced _instance =
      HiveBoxManagerEnhanced._internal();

  // Track all open boxes (regular + lazy)
  final Map<String, Box> _openBoxes = {};
  final Map<String, LazyBox> _openLazyBoxes = {};

  // ✅ CRITICAL: Locks for concurrent access safety
  final Map<String, Lock> _locks = {};

  bool _isDisposed = false;
  static bool _isHiveInitialized = false;

  /// 🔐 SECURITY: Boxes that require AES-256 encryption
  ///
  /// These boxes contain sensitive user data and MUST be encrypted:
  /// - GDPR-regulated data (consent history)
  /// - PII (email, displayName)
  /// - Privacy settings
  ///
  /// Encryption is applied AUTOMATICALLY when opening these boxes.
  ///
  /// NOTE: app_config was removed from this list (2024-12) because it only
  /// contains UI preferences (theme, language, font size) - NO PII or GDPR data.
  /// This reduces startup time by ~15s by avoiding encryption overhead during
  /// WebView initialization for GDPR consent.
  static const List<String> _sensitiveBoxes = [
    'user_consents', // GDPR consent history
    'privacy', // Privacy settings
    // 'app_config' removed - only UI preferences, no PII
    'user_profile_cache', // Cached user profile (email, displayName)
  ];

  bool _isRecoverableSchemaError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('not a subtype of') ||
        message.contains('type cast') ||
        message.contains('casterror') ||
        message.contains('expected type');
  }

  Future<void> _deleteAndRecreateBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
    _openBoxes.remove(name);
    _openLazyBoxes.remove(name);
    await Hive.deleteBoxFromDisk(name);
  }

  /// Initialize HiveBoxManagerEnhanced and pre-open critical boxes
  ///
  /// MUST be called in main.dart AFTER Hive.initFlutter()
  /// and BEFORE any service that uses Hive boxes
  ///
  /// Pre-opens essential boxes for:
  /// - Privacy/Consent (GDPR compliance)
  /// - Analytics (performance tracking)
  /// - User settings (app configuration)
  static Future<void> initialize() async {
    if (_isHiveInitialized) {
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManagerEnhanced] Already initialized (skipping)',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManagerEnhanced] 🚀 Initializing with critical boxes...',
      );
    }

    // ✅ CRITICAL FIX: Set flag BEFORE opening boxes to avoid chicken-and-egg
    // The openBox() method checks this flag, so it must be true first
    _isHiveInitialized = true;

    // Pre-open critical boxes that are truly Box<dynamic> (no specific type)
    // Note: app_config is NOT pre-opened because it's typed as Box<AppConfig>
    // and will be opened on-demand by AppConfigNotifier with the correct type

    // ✅ FIX: Open boxes individually with error handling instead of Future.wait
    // This ensures that if one box fails, others still open successfully
    final List<String> failedBoxes = [];

    try {
      await _instance.openBox<dynamic>('privacy'); // Privacy Manager
    } catch (e) {
      failedBoxes.add('privacy: $e');
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManagerEnhanced] ❌ Failed to open box "privacy": $e',
        );
      }
    }

    try {
      await _instance.openBox<dynamic>('user_consents'); // Privacy/GDPR
    } catch (e) {
      failedBoxes.add('user_consents: $e');
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManagerEnhanced] ❌ Failed to open box "user_consents": $e',
        );
      }
    }

    try {
      // ✅ FIX: Open analytics_cache with the correct generic type for the provider
      await _instance.openBox<Map<dynamic, dynamic>>(
        'analytics_cache',
      ); // Analytics cache for AI coach
    } catch (e) {
      failedBoxes.add('analytics_cache: $e');
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManagerEnhanced] ❌ Failed to open box "analytics_cache": $e',
        );
      }
    }

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManagerEnhanced] ✅ Initialized with ${_instance._openBoxes.length} critical boxes',
      );
      if (failedBoxes.isNotEmpty) {
        debugPrint(
          '📦 [HiveBoxManagerEnhanced] ⚠️ Failed boxes: ${failedBoxes.join(', ')}',
        );
      }
    }
  }

  /// ⚠️ CRITICAL: Opens a box with error handling and corruption recovery
  ///
  /// Handles:
  /// - Box corruption (deletes and recreates)
  /// - I/O errors (retries with exponential backoff)
  /// - Concurrent access (reuses existing box)
  ///
  /// Throws:
  /// - [BoxOpenException] if cannot open after retries
  /// - [BoxCorruptedException] if corruption was detected and recovered
  Future<Box<E>> openBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    int maxRetries = 3,
  }) async {
    if (_isDisposed) {
      throw StateError('HiveBoxManagerEnhanced is disposed');
    }

    if (!_isHiveInitialized) {
      throw StateError(
        '❌ HiveBoxManagerEnhanced not initialized. '
        'Call HiveBoxManagerEnhanced.initialize() in main.dart after Hive.initFlutter()',
      );
    }

    // Return existing box if already open (no logging - too verbose in loops)
    if (_openBoxes.containsKey(name)) {
      return _openBoxes[name] as Box<E>;
    }

    // 🔐 SECURITY: Auto-encrypt sensitive boxes if no cipher provided
    HiveCipher? cipher = encryptionCipher;
    if (_sensitiveBoxes.contains(name) && cipher == null) {
      if (kDebugMode) {
        debugPrint(
          '🔐 [HiveBoxManagerEnhanced] Box "$name" is sensitive → auto-encrypting with AES-256...',
        );
      }
      cipher = await HiveEncryptionManager.getEncryptionCipher();
    }

    // Try opening with retry logic
    Box<E>? box;
    int attempt = 0;
    Object? lastError;

    while (attempt < maxRetries) {
      try {
        if (kDebugMode && attempt > 0) {
          debugPrint(
            '📦 [HiveBoxManagerEnhanced] Retry $attempt/$maxRetries for box: "$name"',
          );
        }

        box = await Hive.openBox<E>(
          name,
          encryptionCipher:
              cipher, // 🔐 Uses auto-encryption cipher for sensitive boxes
        );

        _openBoxes[name] = box;
        return box;
      } on HiveError catch (e) {
        lastError = e;

        // Box corrupted - try recovery
        if (e.toString().contains('corrupted') ||
            e.toString().contains('invalid') ||
            e.toString().contains('format')) {
          if (kDebugMode) {
            debugPrint(
              '📦 [HiveBoxManagerEnhanced] ⚠️ Box "$name" corrupted, attempting recovery...',
            );
          }

          try {
            // Delete corrupted box
            await Hive.deleteBoxFromDisk(name);

            if (kDebugMode) {
              debugPrint(
                '📦 [HiveBoxManagerEnhanced] 🗑️ Deleted corrupted box "$name"',
              );
            }

            // Retry opening (will create new box)
            attempt++;
            continue;
          } catch (deleteError) {
            if (kDebugMode) {
              debugPrint(
                '📦 [HiveBoxManagerEnhanced] ❌ Failed to delete corrupted box: $deleteError',
              );
            }
            throw BoxCorruptedException(name, e);
          }
        }

        // Other HiveError - retry
        attempt++;
        await Future.delayed(
          Duration(milliseconds: 100 * attempt),
        ); // Exponential backoff
      } on FileSystemException catch (e) {
        lastError = e;

        if (kDebugMode) {
          debugPrint(
            '📦 [HiveBoxManagerEnhanced] ❌ I/O error for box "$name": $e',
          );
        }

        // I/O error - retry with backoff
        attempt++;
        await Future.delayed(Duration(milliseconds: 100 * attempt));
      } catch (e) {
        lastError = e;

        if (_isRecoverableSchemaError(e)) {
          if (kDebugMode) {
            debugPrint(
              '📦 [HiveBoxManagerEnhanced] ⚠️ Schema/type mismatch in box "$name", attempting recovery...',
            );
          }

          try {
            await _deleteAndRecreateBox(name);
            if (kDebugMode) {
              debugPrint(
                '📦 [HiveBoxManagerEnhanced] 🗑️ Recreated box "$name" after schema mismatch',
              );
            }
            attempt++;
            continue;
          } catch (deleteError) {
            if (kDebugMode) {
              debugPrint(
                '📦 [HiveBoxManagerEnhanced] ❌ Failed to recover schema-mismatched box: $deleteError',
              );
            }
            throw BoxCorruptedException(name, e);
          }
        }

        if (kDebugMode) {
          debugPrint(
            '📦 [HiveBoxManagerEnhanced] ❌ Unexpected error opening box "$name": $e',
          );
        }

        throw BoxOpenException(name, 'Unexpected error opening box', e);
      }
    }

    // Failed after all retries
    throw BoxOpenException(
      name,
      'Failed to open box after $maxRetries attempts',
      lastError,
    );
  }

  /// Opens a lazy box with error handling
  Future<LazyBox<E>> openLazyBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    int maxRetries = 3,
  }) async {
    if (_isDisposed) {
      throw StateError('HiveBoxManagerEnhanced is disposed');
    }

    if (!_isHiveInitialized) {
      throw StateError(
        '❌ HiveBoxManagerEnhanced not initialized. '
        'Call HiveBoxManagerEnhanced.initialize() in main.dart after Hive.initFlutter()',
      );
    }

    // Return existing lazy box if already open (no logging - too verbose in loops)
    if (_openLazyBoxes.containsKey(name)) {
      return _openLazyBoxes[name] as LazyBox<E>;
    }

    // 🔐 SECURITY: Auto-encrypt sensitive boxes if no cipher provided
    HiveCipher? cipher = encryptionCipher;
    if (_sensitiveBoxes.contains(name) && cipher == null) {
      if (kDebugMode) {
        debugPrint(
          '🔐 [HiveBoxManagerEnhanced] Lazy box "$name" is sensitive → auto-encrypting with AES-256...',
        );
      }
      cipher = await HiveEncryptionManager.getEncryptionCipher();
    }

    // Try opening with retry logic (similar to openBox)
    LazyBox<E>? box;
    int attempt = 0;
    Object? lastError;

    while (attempt < maxRetries) {
      try {
        box = await Hive.openLazyBox<E>(
          name,
          encryptionCipher:
              cipher, // 🔐 Uses auto-encryption cipher for sensitive boxes
        );

        _openLazyBoxes[name] = box;
        return box;
      } on HiveError catch (e) {
        lastError = e;

        // Handle corruption same as regular box
        if (e.toString().contains('corrupted') ||
            e.toString().contains('invalid')) {
          try {
            await Hive.deleteBoxFromDisk(name);
            attempt++;
            continue;
          } catch (_) {
            throw BoxCorruptedException(name, e);
          }
        }

        attempt++;
        await Future.delayed(Duration(milliseconds: 100 * attempt));
      } catch (e) {
        lastError = e;
        attempt++;
        await Future.delayed(Duration(milliseconds: 100 * attempt));
      }
    }

    throw BoxOpenException(
      name,
      'Failed to open lazy box after $maxRetries attempts',
      lastError,
    );
  }

  /// 🔒 CRITICAL: Thread-safe transaction
  ///
  /// Executes operations atomically with lock protection
  ///
  /// Example:
  /// ```dart
  /// await boxManager.transaction<Workout>('workouts', (box) async {
  ///   final workout = box.get('key');
  ///   workout.reps += 1;
  ///   await box.put('key', workout);
  /// });
  /// ```
  Future<void> transaction<T>(
    String boxName,
    Future<void> Function(Box<T>) operation,
  ) async {
    final lock = _locks.putIfAbsent(boxName, () => Lock());

    await lock.synchronized(() async {
      final box = await openBox<T>(boxName);
      await operation(box);
    });
  }

  /// Opens a box with encryption for sensitive data
  ///
  /// Use for:
  /// - PII (personally identifiable information)
  /// - Authentication tokens
  /// - Payment credentials
  /// - Health data
  ///
  /// Encryption key should be stored in flutter_secure_storage
  Future<Box<T>> openSecureBox<T>(
    String name, {
    required List<int> encryptionKey,
  }) async {
    if (encryptionKey.length != 32) {
      throw ArgumentError('Encryption key must be exactly 32 bytes');
    }

    final cipher = HiveAesCipher(encryptionKey);
    return await openBox<T>(name, encryptionCipher: cipher);
  }

  /// Batch put operation (70% faster than loop with put())
  Future<void> putAll<T>(String boxName, Map<dynamic, T> entries) async {
    final box = await openBox<T>(boxName);
    await box.putAll(entries);

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManagerEnhanced] ✅ Batch put ${entries.length} entries to "$boxName"',
      );
    }
  }

  /// Batch delete operation
  Future<void> deleteAll(String boxName, List<dynamic> keys) async {
    final box = await openBox(boxName);
    await box.deleteAll(keys);

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManagerEnhanced] ✅ Batch deleted ${keys.length} entries from "$boxName"',
      );
    }
  }

  /// Closes a specific regular box
  Future<void> closeBox(String name) async {
    if (!_openBoxes.containsKey(name)) {
      return;
    }

    final box = _openBoxes[name]!;
    await box.close();
    _openBoxes.remove(name);
    _locks.remove(name); // Remove lock too

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] ❌ Closed box: "$name"');
    }
  }

  /// Closes a specific lazy box
  Future<void> closeLazyBox(String name) async {
    if (!_openLazyBoxes.containsKey(name)) {
      return;
    }

    final box = _openLazyBoxes[name]!;
    await box.close();
    _openLazyBoxes.remove(name);

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] ❌ Closed lazy box: "$name"');
    }
  }

  /// Compacts a box to reclaim disk space
  Future<bool> compactBox(String name) async {
    final box = _openBoxes[name];
    if (box == null) return false;

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] 🗜️ Compacting box: "$name"...');
    }

    await box.compact();

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] ✅ Compacted box: "$name"');
    }

    return true;
  }

  /// Compacts all open boxes
  Future<void> compactAll() async {
    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] 🗜️ Compacting all boxes...');
    }

    for (final name in _openBoxes.keys.toList()) {
      await compactBox(name);
    }

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] ✅ All boxes compacted');
    }
  }

  /// Closes ALL boxes
  Future<void> closeAll() async {
    if (_isDisposed) return;

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] ❌ Closing all boxes...');
    }

    // Close all regular boxes
    for (final box in _openBoxes.values) {
      try {
        await box.close();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('📦 [HiveBoxManagerEnhanced] ⚠️ Error closing box: $e');
        }
      }
    }

    // Close all lazy boxes
    for (final box in _openLazyBoxes.values) {
      try {
        await box.close();
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '📦 [HiveBoxManagerEnhanced] ⚠️ Error closing lazy box: $e',
          );
        }
      }
    }

    _openBoxes.clear();
    _openLazyBoxes.clear();
    _locks.clear();
    _isDisposed = true;

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] ✅ All boxes closed');
    }
  }

  /// 🔐 SECURITY: Clear all user-specific data from ALL Hive boxes
  ///
  /// MUST be called on logout/account switch to prevent data leakage
  /// between different user accounts sharing the same device.
  ///
  /// This clears the CONTENTS of all boxes (not the boxes themselves),
  /// so they can be repopulated with the new user's data.
  ///
  /// FIX: Now also opens and clears boxes that weren't opened yet in this
  /// session, preventing stale data from leaking to the next user.
  Future<void> clearAllUserData() async {
    if (kDebugMode) {
      debugPrint('🔐 [HiveBoxManagerEnhanced] Clearing all user data...');
      debugPrint(
        '🔐 [HiveBoxManagerEnhanced] Currently open boxes: ${_openBoxes.length}, lazy: ${_openLazyBoxes.length}',
      );
    }

    // Boxes that contain device-level (not user-specific) data
    const systemBoxes = <String>{
      'privacy', // GDPR consent - device level, not user level
      'user_consents', // GDPR consent history - device level
      'app_config', // App settings + onboarding completion guard
    };

    int clearedCount = 0;
    int failedCount = 0;

    // 1. Clear all currently open boxes
    for (final entry in _openBoxes.entries.toList()) {
      if (systemBoxes.contains(entry.key)) continue;

      try {
        await entry.value.clear();
        clearedCount++;
        if (kDebugMode) {
          debugPrint(
            '🗑️ [HiveBoxManagerEnhanced] Cleared box: "${entry.key}"',
          );
        }
      } catch (e) {
        failedCount++;
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HiveBoxManagerEnhanced] Failed to clear box "${entry.key}": $e',
          );
        }
      }
    }

    // 2. Clear all currently open lazy boxes
    for (final entry in _openLazyBoxes.entries.toList()) {
      if (systemBoxes.contains(entry.key)) continue;

      try {
        await entry.value.clear();
        clearedCount++;
        if (kDebugMode) {
          debugPrint(
            '🗑️ [HiveBoxManagerEnhanced] Cleared lazy box: "${entry.key}"',
          );
        }
      } catch (e) {
        failedCount++;
        if (kDebugMode) {
          debugPrint(
            '⚠️ [HiveBoxManagerEnhanced] Failed to clear lazy box "${entry.key}": $e',
          );
        }
      }
    }

    // 3. 🔐 CRITICAL FIX: Open and clear ALL known boxes that weren't opened yet
    // This prevents stale data from surviving logout in unopened boxes
    final openBoxNames = {..._openBoxes.keys, ..._openLazyBoxes.keys};
    for (final boxName in HiveBoxNames.allBoxNames) {
      if (systemBoxes.contains(boxName)) continue;
      if (openBoxNames.contains(boxName)) continue; // Already cleared above

      try {
        // Try to open the box - if it doesn't exist on disk, Hive creates an empty one
        // which is harmless. If it exists with stale data, we clear it.
        final box = await Hive.openBox<dynamic>(boxName);
        if (box.isNotEmpty) {
          await box.clear();
          clearedCount++;
          if (kDebugMode) {
            debugPrint(
              '🗑️ [HiveBoxManagerEnhanced] Opened and cleared unopened box: "$boxName"',
            );
          }
        }
        await box.close();
      } catch (e) {
        // Box might be corrupted or have type mismatch - delete the file
        try {
          await Hive.deleteBoxFromDisk(boxName);
          clearedCount++;
          if (kDebugMode) {
            debugPrint(
              '🗑️ [HiveBoxManagerEnhanced] Deleted corrupted box from disk: "$boxName"',
            );
          }
        } catch (deleteError) {
          failedCount++;
          if (kDebugMode) {
            debugPrint(
              '⚠️ [HiveBoxManagerEnhanced] Failed to clear/delete box "$boxName": $e / $deleteError',
            );
          }
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        '🔐 [HiveBoxManagerEnhanced] ✅ User data cleared: $clearedCount boxes, $failedCount failed',
      );
    }
  }

  /// Debug utilities
  List<String> get openBoxNames => [
    ..._openBoxes.keys,
    ..._openLazyBoxes.keys.map((name) => '$name (lazy)'),
  ];

  int get openBoxCount => _openBoxes.length + _openLazyBoxes.length;

  bool isBoxOpen(String name) =>
      _openBoxes.containsKey(name) || _openLazyBoxes.containsKey(name);

  bool get isDisposed => _isDisposed;

  /// Reset manager state for testing purposes
  ///
  /// Resets the dispose state and clears all tracked boxes/locks,
  /// but KEEPS the initialization flag (since Hive itself remains initialized).
  ///
  /// IMPORTANT: Call this AFTER Hive.deleteFromDisk() to ensure
  /// internal maps are cleared after boxes are closed.
  ///
  /// NOTE: Does NOT reset _isHiveInitialized because:
  /// - It's a static flag shared across all tests
  /// - Once Hive is initialized in setUpAll(), it stays initialized
  /// - Only instance state (boxes, locks) needs to be cleared between tests
  @visibleForTesting
  void resetForTesting() {
    _isDisposed = false;
    _openBoxes.clear(); // ✅ CRITICAL: Clear box tracking maps
    _openLazyBoxes.clear();
    _locks.clear(); // ✅ CRITICAL: Clear lock maps
    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManagerEnhanced] 🔄 Reset for testing');
    }
  }

  /// Reset initialization flag for testing (ONLY for initialization tests)
  ///
  /// Use this ONLY in tests that specifically test the initialize() method.
  /// Regular tests should NOT call this.
  @visibleForTesting
  static void resetInitializationForTesting() {
    _isHiveInitialized = false;
    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManagerEnhanced] 🔄 Reset initialization flag for testing',
      );
    }
  }
}
