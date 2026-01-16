/// Base Hive Local Datasource
///
/// Generic base class for Hive local datasources.
/// Provides common CRUD operations and initialization patterns.
///
/// ## Usage
/// ```dart
/// class MeasurementDatasource extends BaseHiveLocalDatasource<EncryptedMeasurement> {
///   MeasurementDatasource() : super(boxName: 'measurements');
///
///   @override
///   String getKey(EncryptedMeasurement item) => item.id;
///
///   @override
///   Map<String, dynamic> toJson(EncryptedMeasurement item) => item.toJson();
///
///   @override
///   EncryptedMeasurement fromJson(Map<String, dynamic> json) =>
///       EncryptedMeasurement.fromJson(json);
/// }
/// ```
library;

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Failure type for local storage operations
class LocalStorageFailure extends Failure {
  const LocalStorageFailure(super.message, {super.code, this.error});
  final Object? error;
}

/// Hive-specific failure
class HiveFailure extends LocalStorageFailure {
  const HiveFailure({required String message, Object? error})
      : super(message, code: 'HIVE_ERROR', error: error);
}

/// Abstract base class for Hive local datasources
abstract class BaseHiveLocalDatasource<T> {
  BaseHiveLocalDatasource({required this.boxName, this.useLazyBox = true});

  /// Name of the Hive box
  final String boxName;

  /// Whether to use LazyBox (recommended for large datasets)
  final bool useLazyBox;

  /// Regular box (if not using lazy box)
  Box<Map<String, dynamic>>? _box;

  /// Lazy box (for on-demand loading)
  LazyBox<Map<String, dynamic>>? _lazyBox;

  /// Check if datasource is initialized
  bool get isInitialized {
    if (useLazyBox) {
      return _lazyBox != null && _lazyBox!.isOpen;
    }
    return _box != null && _box!.isOpen;
  }

  // ============ ABSTRACT METHODS ============

  /// Get unique key for an item (used as Hive box key)
  String getKey(T item);

  /// Convert item to JSON for storage
  Map<String, dynamic> toJson(T item);

  /// Convert JSON back to item
  T fromJson(Map<String, dynamic> json);

  /// Optional: Filter to determine if item is "active"
  /// Override to implement soft-delete filtering
  bool isActive(T item) => true;

  // ============ INITIALIZATION ============

  /// Initialize the datasource (open Hive box)
  Future<Either<LocalStorageFailure, void>> initialize() async {
    try {
      if (isInitialized) {
        return right(null);
      }

      if (useLazyBox) {
        _lazyBox = await Hive.openLazyBox<Map<String, dynamic>>(boxName);
      } else {
        _box = await Hive.openBox<Map<String, dynamic>>(boxName);
      }

      return right(null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to initialize Hive box: $boxName',
        error: e,
      ));
    }
  }

  /// Close the datasource
  Future<Either<LocalStorageFailure, void>> close() async {
    try {
      if (useLazyBox && _lazyBox != null && _lazyBox!.isOpen) {
        await _lazyBox!.close();
        _lazyBox = null;
      } else if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
      }
      return right(null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to close Hive box: $boxName',
        error: e,
      ));
    }
  }

  // ============ CRUD OPERATIONS ============

  /// Save an item
  Future<Either<LocalStorageFailure, void>> save(T item) async {
    try {
      _ensureInitialized();
      final key = getKey(item);
      final json = toJson(item);

      if (useLazyBox) {
        await _lazyBox!.put(key, json);
      } else {
        await _box!.put(key, json);
      }

      return right(null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to save item',
        error: e,
      ));
    }
  }

  /// Save multiple items in batch
  Future<Either<LocalStorageFailure, void>> saveAll(List<T> items) async {
    try {
      _ensureInitialized();
      final entries = <String, Map<String, dynamic>>{};

      for (final item in items) {
        entries[getKey(item)] = toJson(item);
      }

      if (useLazyBox) {
        await _lazyBox!.putAll(entries);
      } else {
        await _box!.putAll(entries);
      }

      return right(null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to save ${items.length} items',
        error: e,
      ));
    }
  }

  /// Get an item by key
  Future<Either<LocalStorageFailure, T?>> get(String key) async {
    try {
      _ensureInitialized();
      Map<String, dynamic>? json;

      if (useLazyBox) {
        json = await _lazyBox!.get(key);
      } else {
        json = _box!.get(key);
      }

      if (json == null) return right(null);

      final item = fromJson(json);
      return right(isActive(item) ? item : null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to get item with key: $key',
        error: e,
      ));
    }
  }

  /// Get all items (optionally filtered by a predicate)
  Future<Either<LocalStorageFailure, List<T>>> getAll({
    bool Function(T)? filter,
  }) async {
    try {
      _ensureInitialized();
      final items = <T>[];
      final keys = useLazyBox ? _lazyBox!.keys : _box!.keys;

      for (final key in keys) {
        Map<String, dynamic>? json;

        if (useLazyBox) {
          json = await _lazyBox!.get(key);
        } else {
          json = _box!.get(key);
        }

        if (json == null) continue;

        final item = fromJson(json);
        if (!isActive(item)) continue;
        if (filter != null && !filter(item)) continue;

        items.add(item);
      }

      return right(items);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to get all items',
        error: e,
      ));
    }
  }

  /// Delete an item by key
  Future<Either<LocalStorageFailure, void>> delete(String key) async {
    try {
      _ensureInitialized();

      if (useLazyBox) {
        await _lazyBox!.delete(key);
      } else {
        await _box!.delete(key);
      }

      return right(null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to delete item with key: $key',
        error: e,
      ));
    }
  }

  /// Delete all items matching a filter
  Future<Either<LocalStorageFailure, int>> deleteWhere(
    bool Function(T) filter,
  ) async {
    try {
      _ensureInitialized();
      final keysToDelete = <dynamic>[];
      final keys = useLazyBox ? _lazyBox!.keys : _box!.keys;

      for (final key in keys) {
        Map<String, dynamic>? json;

        if (useLazyBox) {
          json = await _lazyBox!.get(key);
        } else {
          json = _box!.get(key);
        }

        if (json == null) continue;

        final item = fromJson(json);
        if (filter(item)) {
          keysToDelete.add(key);
        }
      }

      if (useLazyBox) {
        await _lazyBox!.deleteAll(keysToDelete);
      } else {
        await _box!.deleteAll(keysToDelete);
      }

      return right(keysToDelete.length);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to delete items',
        error: e,
      ));
    }
  }

  /// Clear all items from the box
  Future<Either<LocalStorageFailure, void>> clear() async {
    try {
      _ensureInitialized();

      if (useLazyBox) {
        await _lazyBox!.clear();
      } else {
        await _box!.clear();
      }

      return right(null);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to clear all items',
        error: e,
      ));
    }
  }

  /// Count items (optionally filtered)
  Future<Either<LocalStorageFailure, int>> count({
    bool Function(T)? filter,
  }) async {
    if (filter == null) {
      try {
        _ensureInitialized();
        return right(useLazyBox ? _lazyBox!.length : _box!.length);
      } catch (e) {
        return left(HiveFailure(
          message: 'Failed to count items',
          error: e,
        ));
      }
    }

    final result = await getAll(filter: filter);
    return result.map((items) => items.length);
  }

  /// Check if an item exists
  Future<Either<LocalStorageFailure, bool>> exists(String key) async {
    try {
      _ensureInitialized();
      final contains = useLazyBox
          ? _lazyBox!.containsKey(key)
          : _box!.containsKey(key);
      return right(contains);
    } catch (e) {
      return left(HiveFailure(
        message: 'Failed to check if item exists',
        error: e,
      ));
    }
  }

  // ============ HELPERS ============

  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError('Datasource not initialized. Call initialize() first.');
    }
  }
}
