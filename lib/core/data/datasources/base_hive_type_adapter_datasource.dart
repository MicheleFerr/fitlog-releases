/// Base Hive Type Adapter Datasource
///
/// Generic base class for Hive datasources using TypeAdapter pattern.
/// Uses `Box<T>` instead of `Box<Map<String, dynamic>>` for type-safe storage.
///
/// ## Usage
/// ```dart
/// class ExerciseUsageDatasource extends BaseHiveTypeAdapterDatasource<ExerciseUsageModel> {
///   ExerciseUsageDatasource() : super(boxName: 'exercise_usage');
///
///   @override
///   String getKey(ExerciseUsageModel item) => item.exerciseId;
/// }
/// ```
///
/// ## Differences from BaseHiveLocalDatasource
/// - Uses `Box<T>` instead of `Box<Map<String, dynamic>>`
/// - No need for toJson/fromJson conversions
/// - Works with models that extend HiveObject and use @HiveType annotation
/// - Leverages Hive's built-in TypeAdapter for serialization
library;

import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
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

/// Abstract base class for Hive datasources using TypeAdapter pattern
///
/// Generic constraint: `T` must extend HiveObject to enable auto-save and key management
abstract class BaseHiveTypeAdapterDatasource<T extends HiveObject> {
  BaseHiveTypeAdapterDatasource({
    required this.boxName,
    this.useLazyBox = false,
  });

  /// Name of the Hive box
  final String boxName;

  /// Whether to use LazyBox (for on-demand loading)
  /// Note: Regular Box<T> is often preferred for TypeAdapter models
  /// as they're typically smaller and benefit from being in memory
  final bool useLazyBox;

  /// Regular box (default for TypeAdapter models)
  Box<T>? _box;

  /// Lazy box (for large datasets)
  LazyBox<T>? _lazyBox;

  /// Check if datasource is initialized
  bool get isInitialized {
    if (useLazyBox) {
      return _lazyBox != null && _lazyBox!.isOpen;
    }
    return _box != null && _box!.isOpen;
  }

  // ============ ABSTRACT METHODS ============

  /// Get unique key for an item (used as Hive box key)
  /// Supports any key type (String, int, etc.)
  dynamic getKey(T item);

  /// Optional: Filter to determine if item is "active"
  /// Override to implement soft-delete filtering
  bool isActive(T item) => true;

  // ============ INITIALIZATION ============

  /// Initialize the datasource (open Hive box)
  Future<fpdart.Either<LocalStorageFailure, void>> initialize() async {
    try {
      if (isInitialized) {
        return const fpdart.Right(null);
      }

      if (useLazyBox) {
        _lazyBox = await Hive.openLazyBox<T>(boxName);
      } else {
        _box = await Hive.openBox<T>(boxName);
      }

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to initialize Hive box: $boxName',
        error: e,
      ));
    }
  }

  /// Close the datasource
  Future<fpdart.Either<LocalStorageFailure, void>> close() async {
    try {
      if (useLazyBox && _lazyBox != null && _lazyBox!.isOpen) {
        await _lazyBox!.close();
        _lazyBox = null;
      } else if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
      }
      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to close Hive box: $boxName',
        error: e,
      ));
    }
  }

  // ============ CRUD OPERATIONS ============

  /// Save an item
  /// Note: HiveObject.save() could also be used, but this provides error handling
  Future<fpdart.Either<LocalStorageFailure, void>> save(T item) async {
    try {
      _ensureInitialized();
      final key = getKey(item);

      if (useLazyBox) {
        await _lazyBox!.put(key, item);
      } else {
        await _box!.put(key, item);
      }

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to save item',
        error: e,
      ));
    }
  }

  /// Save multiple items in batch
  Future<fpdart.Either<LocalStorageFailure, void>> saveAll(List<T> items) async {
    try {
      _ensureInitialized();
      final entries = <dynamic, T>{};

      for (final item in items) {
        entries[getKey(item)] = item;
      }

      if (useLazyBox) {
        await _lazyBox!.putAll(entries);
      } else {
        await _box!.putAll(entries);
      }

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to save ${items.length} items',
        error: e,
      ));
    }
  }

  /// Get an item by key
  Future<fpdart.Either<LocalStorageFailure, T?>> get(dynamic key) async {
    try {
      _ensureInitialized();
      T? item;

      if (useLazyBox) {
        item = await _lazyBox!.get(key);
      } else {
        item = _box!.get(key);
      }

      if (item == null) return const fpdart.Right(null);

      return fpdart.Right(isActive(item) ? item : null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to get item with key: $key',
        error: e,
      ));
    }
  }

  /// Get all items (optionally filtered by a predicate)
  Future<fpdart.Either<LocalStorageFailure, List<T>>> getAll({
    bool Function(T)? filter,
  }) async {
    try {
      _ensureInitialized();
      final items = <T>[];
      final keys = useLazyBox ? _lazyBox!.keys : _box!.keys;

      for (final key in keys) {
        T? item;

        if (useLazyBox) {
          item = await _lazyBox!.get(key);
        } else {
          item = _box!.get(key);
        }

        if (item == null) continue;

        if (!isActive(item)) continue;
        if (filter != null && !filter(item)) continue;

        items.add(item);
      }

      return fpdart.Right(items);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to get all items',
        error: e,
      ));
    }
  }

  /// Delete an item by key
  Future<fpdart.Either<LocalStorageFailure, void>> delete(dynamic key) async {
    try {
      _ensureInitialized();

      if (useLazyBox) {
        await _lazyBox!.delete(key);
      } else {
        await _box!.delete(key);
      }

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to delete item with key: $key',
        error: e,
      ));
    }
  }

  /// Delete all items matching a filter
  Future<fpdart.Either<LocalStorageFailure, int>> deleteWhere(
    bool Function(T) filter,
  ) async {
    try {
      _ensureInitialized();
      final keysToDelete = <dynamic>[];
      final keys = useLazyBox ? _lazyBox!.keys : _box!.keys;

      for (final key in keys) {
        T? item;

        if (useLazyBox) {
          item = await _lazyBox!.get(key);
        } else {
          item = _box!.get(key);
        }

        if (item == null) continue;

        if (filter(item)) {
          keysToDelete.add(key);
        }
      }

      if (useLazyBox) {
        await _lazyBox!.deleteAll(keysToDelete);
      } else {
        await _box!.deleteAll(keysToDelete);
      }

      return fpdart.Right(keysToDelete.length);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to delete items',
        error: e,
      ));
    }
  }

  /// Clear all items from the box
  Future<fpdart.Either<LocalStorageFailure, void>> clear() async {
    try {
      _ensureInitialized();

      if (useLazyBox) {
        await _lazyBox!.clear();
      } else {
        await _box!.clear();
      }

      return const fpdart.Right(null);
    } catch (e) {
      return fpdart.Left(HiveFailure(
        message: 'Failed to clear all items',
        error: e,
      ));
    }
  }

  /// Count items (optionally filtered)
  Future<fpdart.Either<LocalStorageFailure, int>> count({
    bool Function(T)? filter,
  }) async {
    if (filter == null) {
      try {
        _ensureInitialized();
        return fpdart.Right(useLazyBox ? _lazyBox!.length : _box!.length);
      } catch (e) {
        return fpdart.Left(HiveFailure(
          message: 'Failed to count items',
          error: e,
        ));
      }
    }

    final result = await getAll(filter: filter);
    return result.map((items) => items.length);
  }

  /// Check if an item exists
  Future<fpdart.Either<LocalStorageFailure, bool>> exists(dynamic key) async {
    try {
      _ensureInitialized();
      final contains = useLazyBox
          ? _lazyBox!.containsKey(key)
          : _box!.containsKey(key);
      return fpdart.Right(contains);
    } catch (e) {
      return fpdart.Left(HiveFailure(
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
