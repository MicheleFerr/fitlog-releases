import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralized manager for all Hive box lifecycle in the app.
///
/// Ensures:
/// - 1 box = 1 open = 1 close (no duplicate opens)
/// - Automatic tracking of all open boxes
/// - Centralized disposal on app termination
/// - Debug visibility of box lifecycle
///
/// Usage:
/// ```dart
/// final manager = HiveBoxManager();
/// final box = await manager.openBox<Map>('workouts');
/// // ... use box
/// await manager.closeAll(); // On app termination
/// ```
class HiveBoxManager {
  factory HiveBoxManager() => _instance;
  HiveBoxManager._internal();
  // Singleton pattern
  static final HiveBoxManager _instance = HiveBoxManager._internal();

  // Track all open boxes (regular + lazy)
  final Map<String, Box> _openBoxes = {};
  final Map<String, LazyBox> _openLazyBoxes = {};
  bool _isDisposed = false;

  // ✅ CRITICAL FIX: Track if Hive has been initialized
  static bool _isHiveInitialized = false;

  /// Initialize HiveBoxManager and pre-open critical boxes
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
        debugPrint('📦 [HiveBoxManager] Already initialized (skipping)');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] 🚀 Initializing with critical boxes...');
    }

    // ✅ CRITICAL FIX: Set flag BEFORE opening boxes to avoid chicken-and-egg
    // The openBox() method checks this flag, so it must be true first
    _isHiveInitialized = true;

    // Pre-open critical boxes that are truly Box<dynamic> (no specific type)
    // Note: app_config is NOT pre-opened because it's typed as Box<AppConfig>
    // and will be opened on-demand by AppConfigNotifier with the correct type
    await Future.wait([
      _instance.openBox<dynamic>('user_consents'),  // Privacy/GDPR
      _instance.openBox<dynamic>('privacy'),         // Privacy Manager
    ]);

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] ✅ Initialized with ${_instance._openBoxes.length} critical boxes');
    }
  }

  /// Opens a regular box if not already open, otherwise returns existing one.
  ///
  /// Parameters:
  /// - [name]: Unique box name (use HiveBoxNames constants)
  /// - [encryptionCipher]: Optional encryption for sensitive data
  ///
  /// Throws:
  /// - [StateError] if HiveBoxManager is already disposed or not initialized
  /// - [HiveError] if box cannot be opened
  Future<Box<E>> openBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
  }) async {
    if (_isDisposed) {
      throw StateError('HiveBoxManager is disposed');
    }

    // ✅ CRITICAL FIX: Prevent opening boxes before Hive is initialized
    if (!_isHiveInitialized) {
      throw StateError(
        '❌ HiveBoxManager not initialized. '
        'Call HiveBoxManager.initialize() in main.dart after Hive.initFlutter()',
      );
    }

    // Return existing box if already open
    if (_openBoxes.containsKey(name)) {
      if (kDebugMode) {
        debugPrint('📦 [HiveBoxManager] Box "$name" already open (reusing)');
      }
      return _openBoxes[name] as Box<E>;
    }

    // Open new box and track it
    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] Opening box: "$name"...');
    }

    final box = await Hive.openBox<E>(
      name,
      encryptionCipher: encryptionCipher,
    );

    _openBoxes[name] = box;

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManager] ✅ Opened box: "$name" '
        '(total boxes: ${_openBoxes.length + _openLazyBoxes.length})',
      );
    }

    return box;
  }

  /// Opens a lazy box if not already open, otherwise returns existing one.
  ///
  /// Lazy boxes load data on-demand, improving startup time for large datasets.
  ///
  /// Use for boxes with:
  /// - >100 entries
  /// - Large entries (>10KB each)
  ///
  /// Parameters:
  /// - [name]: Unique box name (use HiveBoxNames constants)
  /// - [encryptionCipher]: Optional encryption for sensitive data
  ///
  /// Throws:
  /// - [StateError] if HiveBoxManager is already disposed or not initialized
  /// - [HiveError] if box cannot be opened
  Future<LazyBox<E>> openLazyBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
  }) async {
    if (_isDisposed) {
      throw StateError('HiveBoxManager is disposed');
    }

    // ✅ CRITICAL FIX: Prevent opening boxes before Hive is initialized
    if (!_isHiveInitialized) {
      throw StateError(
        '❌ HiveBoxManager not initialized. '
        'Call HiveBoxManager.initialize() in main.dart after Hive.initFlutter()',
      );
    }

    // Return existing lazy box if already open
    if (_openLazyBoxes.containsKey(name)) {
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManager] Lazy box "$name" already open (reusing)',
        );
      }
      return _openLazyBoxes[name] as LazyBox<E>;
    }

    // Open new lazy box and track it
    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] Opening lazy box: "$name"...');
    }

    final box = await Hive.openLazyBox<E>(
      name,
      encryptionCipher: encryptionCipher,
    );

    _openLazyBoxes[name] = box;

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManager] ✅ Opened lazy box: "$name" '
        '(total boxes: ${_openBoxes.length + _openLazyBoxes.length})',
      );
    }

    return box;
  }

  /// Closes a specific regular box.
  ///
  /// Safe to call even if box is not open.
  Future<void> closeBox(String name) async {
    if (!_openBoxes.containsKey(name)) {
      if (kDebugMode) {
        debugPrint('📦 [HiveBoxManager] ⚠️ Box "$name" not open (skipping)');
      }
      return;
    }

    final box = _openBoxes[name]!;
    await box.close();
    _openBoxes.remove(name);

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManager] ❌ Closed box: "$name" '
        '(remaining: ${_openBoxes.length + _openLazyBoxes.length})',
      );
    }
  }

  /// Closes a specific lazy box.
  ///
  /// Safe to call even if box is not open.
  Future<void> closeLazyBox(String name) async {
    if (!_openLazyBoxes.containsKey(name)) {
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManager] ⚠️ Lazy box "$name" not open (skipping)',
        );
      }
      return;
    }

    final box = _openLazyBoxes[name]!;
    await box.close();
    _openLazyBoxes.remove(name);

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManager] ❌ Closed lazy box: "$name" '
        '(remaining: ${_openBoxes.length + _openLazyBoxes.length})',
      );
    }
  }

  /// Compacts a box to reclaim disk space from deleted entries.
  ///
  /// Should be called:
  /// - Weekly (via background task)
  /// - After bulk delete operations (>100 deletes)
  ///
  /// Returns false if box is not open.
  Future<bool> compactBox(String name) async {
    final box = _openBoxes[name];
    if (box == null) {
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManager] ⚠️ Cannot compact "$name" (not open)',
        );
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] 🗜️ Compacting box: "$name"...');
    }

    await box.compact();

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] ✅ Compacted box: "$name"');
    }

    return true;
  }

  /// Compacts all open boxes.
  ///
  /// Should be run:
  /// - Weekly (via background task)
  /// - Before app backup
  Future<void> compactAll() async {
    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManager] 🗜️ Compacting all boxes '
        '(${_openBoxes.length} regular)...',
      );
    }

    for (final name in _openBoxes.keys.toList()) {
      await compactBox(name);
    }

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] ✅ All boxes compacted');
    }
  }

  /// Closes ALL boxes (regular + lazy).
  ///
  /// Called on app termination or logout.
  ///
  /// Safe to call multiple times - subsequent calls are no-op.
  Future<void> closeAll() async {
    if (_isDisposed) {
      if (kDebugMode) {
        debugPrint(
          '📦 [HiveBoxManager] ⚠️ Already disposed (skipping closeAll)',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '📦 [HiveBoxManager] ❌ Closing all boxes '
        '(${_openBoxes.length} regular, ${_openLazyBoxes.length} lazy)...',
      );
    }

    // Close all regular boxes
    for (final box in _openBoxes.values) {
      try {
        await box.close();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('📦 [HiveBoxManager] ⚠️ Error closing box: $e');
        }
      }
    }

    // Close all lazy boxes
    for (final box in _openLazyBoxes.values) {
      try {
        await box.close();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('📦 [HiveBoxManager] ⚠️ Error closing lazy box: $e');
        }
      }
    }

    _openBoxes.clear();
    _openLazyBoxes.clear();
    _isDisposed = true;

    if (kDebugMode) {
      debugPrint('📦 [HiveBoxManager] ✅ All boxes closed (disposed)');
    }
  }

  /// Debug: Get list of all open box names (regular + lazy).
  List<String> get openBoxNames => [
        ..._openBoxes.keys,
        ..._openLazyBoxes.keys.map((name) => '$name (lazy)'),
      ];

  /// Debug: Get total count of open boxes (regular + lazy).
  int get openBoxCount => _openBoxes.length + _openLazyBoxes.length;

  /// Debug: Check if a specific box is open.
  bool isBoxOpen(String name) =>
      _openBoxes.containsKey(name) || _openLazyBoxes.containsKey(name);

  /// Debug: Check if manager is disposed.
  bool get isDisposed => _isDisposed;
}
