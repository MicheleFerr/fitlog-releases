/// Stress Index Repository
///
/// Handles persistence of stress index results.
/// Uses local-first storage with optional cloud sync.
///
/// Uses [FirebaseErrorMapperMixin] for standardized error handling.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';

/// Repository interface for stress index data
abstract class StressIndexRepositoryInterface {
  /// Save a stress index result
  Future<void> save(StressIndexResult result);

  /// Get stress index result for a specific workout
  Future<StressIndexResult?> getForWorkout(String workoutId);

  /// Get recent stress index results (last N days)
  Future<List<StressIndexResult>> getRecent({int days = 7});

  /// Watch recent stress index results
  Stream<List<StressIndexResult>> watchRecent({int days = 7});

  /// Delete stress index result for a workout
  Future<void> delete(String workoutId);

  /// Clear all stress index data (for recalculation after exercise focus changes)
  Future<int> clearAll();

  /// Dispose resources
  Future<void> dispose();
}

/// Implementation of stress index repository
///
/// Uses Hive for local storage with optional Firestore sync.
/// Uses [FirebaseErrorMapperMixin] for standardized error handling.
class StressIndexRepository
    with FirebaseErrorMapperMixin
    implements StressIndexRepositoryInterface {
  StressIndexRepository({
    HiveBoxManagerEnhanced? boxManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _boxManager = boxManager ?? HiveBoxManagerEnhanced(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance {
    _initialize();
  }

  final HiveBoxManagerEnhanced _boxManager;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _boxName = HiveBoxNames.stressIndexData;
  static const String _collectionName = 'stress_index';

  Box<Map>? _localBox;
  bool _isInitialized = false;
  bool _isDisposed = false;

  final StreamController<List<StressIndexResult>> _recentController =
      StreamController<List<StressIndexResult>>.broadcast();

  /// Deep convert a dynamic map to proper typed Map.
  ///
  /// Hive returns nested maps as `_Map<dynamic, dynamic>` which causes
  /// type cast errors with freezed models. This recursively converts all
  /// nested maps to the correct type.
  static Map<String, dynamic> _deepConvertMap(dynamic data) {
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(
          key.toString(),
          value is Map ? _deepConvertMap(value) : value,
        ),
      );
    }
    throw ArgumentError('Expected Map, got ${data.runtimeType}');
  }

  /// Initialize the repository
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      _localBox = await _boxManager.openBox<Map>(_boxName);
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Failed to initialize: $e');
      }
    }
  }

  /// Ensure repository is initialized before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  @override
  Future<void> save(StressIndexResult result) async {
    if (_isDisposed) return;
    await _ensureInitialized();

    try {
      // Save locally
      final json = result.toJson();
      await _localBox?.put(result.workoutId, json);

      // Emit update
      _emitRecentUpdate();

      // Sync to cloud if user is logged in
      await _syncToCloud(result);

      if (kDebugMode) {
        debugPrint(
          '[StressIndexRepository] Saved stress index for workout: ${result.workoutId}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Failed to save: $e');
      }
    }
  }

  @override
  Future<StressIndexResult?> getForWorkout(String workoutId) async {
    if (_isDisposed) return null;
    await _ensureInitialized();

    try {
      final json = _localBox?.get(workoutId);
      if (json == null) return null;

      return StressIndexResult.fromJson(_deepConvertMap(json));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Failed to get for workout: $e');
      }
      return null;
    }
  }

  @override
  Future<List<StressIndexResult>> getRecent({int days = 7}) async {
    if (_isDisposed) return [];
    await _ensureInitialized();

    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final results = <StressIndexResult>[];

      for (final key in _localBox?.keys ?? []) {
        final json = _localBox?.get(key);
        if (json == null) continue;

        try {
          final result = StressIndexResult.fromJson(_deepConvertMap(json));
          if (result.calculatedAt.isAfter(cutoff)) {
            results.add(result);
          }
        } catch (e) {
          // Skip invalid entries
          if (kDebugMode) {
            debugPrint('[StressIndexRepository] Skipping invalid entry: $e');
          }
        }
      }

      // Sort by date descending (most recent first)
      results.sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));

      return results;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Failed to get recent: $e');
      }
      return [];
    }
  }

  @override
  Stream<List<StressIndexResult>> watchRecent({int days = 7}) {
    // Emit initial value
    getRecent(days: days).then((results) {
      if (!_isDisposed) {
        _recentController.add(results);
      }
    });

    return _recentController.stream;
  }

  @override
  Future<void> delete(String workoutId) async {
    if (_isDisposed) return;
    await _ensureInitialized();

    try {
      await _localBox?.delete(workoutId);
      _emitRecentUpdate();

      // Delete from cloud if user is logged in
      await _deleteFromCloud(workoutId);

      if (kDebugMode) {
        debugPrint(
          '[StressIndexRepository] Deleted stress index for workout: $workoutId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Failed to delete: $e');
      }
    }
  }

  @override
  Future<int> clearAll() async {
    if (_isDisposed) return 0;
    await _ensureInitialized();

    try {
      final count = _localBox?.length ?? 0;

      // Clear local Hive box
      await _localBox?.clear();

      // Clear cloud data if user is logged in
      await _clearCloudData();

      // Emit update
      _emitRecentUpdate();

      if (kDebugMode) {
        debugPrint(
          '[StressIndexRepository] Cleared all stress index data ($count entries)',
        );
      }

      return count;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[StressIndexRepository] Failed to clear all: $e');
      }
      return 0;
    }
  }

  /// Clear all stress index data from Firestore
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<void> _clearCloudData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final clearResult = await handleFirebaseVoidOperation(() async {
      final collection = _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName);

      // Get all documents and delete them
      final snapshot = await collection.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        debugPrint(
          '[StressIndexRepository] Cleared ${snapshot.docs.length} entries from cloud',
        );
      }
    }, operationName: 'clearCloudData');

    // Log failure but don't throw (local clear succeeded)
    clearResult.mapLeft((failure) {
      if (kDebugMode) {
        debugPrint(
          '[StressIndexRepository] Cloud clear failed: ${failure.message}',
        );
      }
    });
  }

  /// Emit update to recent stream
  void _emitRecentUpdate() {
    if (_isDisposed) return;
    getRecent().then((results) {
      if (!_isDisposed) {
        _recentController.add(results);
      }
    });
  }

  /// Sync result to Firestore
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<void> _syncToCloud(StressIndexResult result) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final syncResult = await handleFirebaseVoidOperation(() async {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .doc(result.workoutId)
          .set(result.toJson());
    }, operationName: 'syncToCloud');

    syncResult.fold(
      (failure) {
        // Don't throw - local save succeeded
        if (kDebugMode) {
          debugPrint('[StressIndexRepository] Sync failed: ${failure.message}');
        }
      },
      (_) {
        if (kDebugMode) {
          debugPrint(
            '[StressIndexRepository] Synced to cloud: ${result.workoutId}',
          );
        }
      },
    );
  }

  /// Delete from Firestore
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<void> _deleteFromCloud(String workoutId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final deleteResult = await handleFirebaseVoidOperation(() async {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionName)
          .doc(workoutId)
          .delete();
    }, operationName: 'deleteFromCloud');

    // Log failure but don't throw (local delete succeeded)
    deleteResult.mapLeft((failure) {
      if (kDebugMode) {
        debugPrint(
          '[StressIndexRepository] Cloud delete failed: ${failure.message}',
        );
      }
    });
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _recentController.close();
    // Box is managed by HiveBoxManagerEnhanced
    if (kDebugMode) {
      debugPrint('[StressIndexRepository] Disposed');
    }
  }
}
