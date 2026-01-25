/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/data/repositories
/// 🎯 Feature: core
/// 🔧 Type: base repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ✅ SINGLE SOURCE OF TRUTH for hybrid (local + cloud) repositories
///
/// CRITICAL: ALL new features MUST extend this base repository
/// to ensure automatic local storage and premium sync!
///
/// **Features:**
/// - Automatic local-first storage (instant saves)
/// - Premium sync to Firestore (queued background sync)
/// - Full CRUD operations (save, get, getAll, update, delete)
/// - Sync queue management with retry logic
/// - Memory-safe disposal pattern (waitForDisposal)
///
/// **For SHARED data (exercise database, etc.):**
/// @see OptimizedBaseHybridRepository - specialized version with 24h caching
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/shared/data/mixins/firestore_cache_first_mixin.dart';

/// Base repository that ALL feature repositories MUST extend
/// Provides automatic local storage and premium sync
abstract class BaseHybridRepository<T> with FirestoreCacheFirstMixin {
  BaseHybridRepository({
    required this.featureName,
    required this.collectionName,
    this.requiresPremiumForCloud = true,
    HiveBoxManagerEnhanced? boxManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _boxManager = boxManager ?? HiveBoxManagerEnhanced() {
    _initialize();
  }
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final HiveBoxManagerEnhanced _boxManager;
  late Box<Map> _localBox;
  late Box<Map> _syncQueueBox;

  // Feature configuration
  final String featureName;
  final String collectionName;
  final bool requiresPremiumForCloud;

  // User profile cache
  UserProfile? _userProfile;
  Timer? _profileRefreshTimer;

  // Sync configuration
  final StreamController<SyncEvent> _syncEventController =
      StreamController.broadcast();
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  // MEMORY LEAK FIX: Disposal flag to prevent operations after dispose
  bool _isDisposed = false;
  Future<void>? _disposeFuture;

  /// Initialize boxes and load user profile
  Future<void> _initialize() async {
    // ✅ FIX: Use HiveBoxManagerEnhanced instead of Hive.openBox() directly
    // This ensures proper lifecycle management and prevents memory leaks
    final dataBoxName = HiveBoxNames.getDataBoxName(featureName);
    final syncBoxName = HiveBoxNames.getSyncQueueName(featureName);

    _localBox = await _boxManager.openBox<Map>(dataBoxName);
    _syncQueueBox = await _boxManager.openBox<Map>(syncBoxName);

    // Load and monitor user profile
    await _loadUserProfile();
    _startProfileMonitoring();

    if (kDebugMode) {
      debugPrint('✅ BaseHybridRepository initialized for: $featureName');
      debugPrint('   - Data box: $dataBoxName');
      debugPrint('   - Sync box: $syncBoxName');
    }
  }

  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await getCacheFirst(docRef);

        if (doc != null && doc.exists) {
          _userProfile = UserProfile.fromFirestore(doc);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to load user profile: $e');
      }
    }
  }

  /// Start monitoring user profile changes
  void _startProfileMonitoring() {
    _profileRefreshTimer?.cancel();
    _profileRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadUserProfile();
    });
  }

  /// Check if user can sync to cloud
  bool get canSyncToCloud {
    if (!requiresPremiumForCloud) return true;
    return isPremiumUser;
  }

  /// Check if user is premium
  bool get isPremiumUser {
    return _userProfile?.accountTier == AccountTier.premium ||
        _userProfile?.accountTier == AccountTier.pro;
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // ABSTRACT METHODS - Must be implemented by each feature
  // ============================================================

  /// Convert entity to JSON for storage
  Map<String, dynamic> toJson(T entity);

  /// Convert JSON to entity
  T fromJson(Map<String, dynamic> json);

  /// Get unique ID for entity
  String getId(T entity);

  /// Validate entity before saving
  bool validate(T entity);

  // ============================================================
  // AUTOMATIC LOCAL + CLOUD OPERATIONS
  // ============================================================

  /// Save entity (ALWAYS local, cloud if premium)
  Future<String> save(T entity) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Validate entity
    if (!validate(entity)) {
      throw Exception('Entity validation failed');
    }

    final id = getId(entity);
    final key = _getLocalKey(id, userId);
    final json = toJson(entity);

    // Add metadata
    json['_localLastModified'] = DateTime.now().toIso8601String();
    json['_userId'] = userId;
    json['_syncStatus'] = 'pending';

    // 1. ALWAYS save locally first (instant!)
    await _localBox.put(key, json);
    _logOperation('SAVE_LOCAL', id, true);

    // 2. Queue for cloud sync if allowed
    if (canSyncToCloud) {
      await _queueForSync(id, 'create', userId);
      _scheduleBackgroundSync();
    }

    // Emit sync event
    _syncEventController.add(
      SyncEvent(
        type: SyncEventType.saved,
        entityId: id,
        isLocal: true,
        willSync: canSyncToCloud,
      ),
    );

    return id;
  }

  /// Update entity
  Future<void> update(T entity) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    if (!validate(entity)) {
      throw Exception('Entity validation failed');
    }

    final id = getId(entity);
    final key = _getLocalKey(id, userId);
    final json = toJson(entity);

    json['_localLastModified'] = DateTime.now().toIso8601String();
    json['_userId'] = userId;
    json['_syncStatus'] = 'pending';

    // Update locally
    await _localBox.put(key, json);
    _logOperation('UPDATE_LOCAL', id, true);

    // Queue for sync
    if (canSyncToCloud) {
      await _queueForSync(id, 'update', userId);
      _scheduleBackgroundSync();
    }

    _syncEventController.add(
      SyncEvent(
        type: SyncEventType.updated,
        entityId: id,
        isLocal: true,
        willSync: canSyncToCloud,
      ),
    );
  }

  /// Delete entity
  Future<void> delete(String id) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final key = _getLocalKey(id, userId);

    // Delete locally
    await _localBox.delete(key);
    _logOperation('DELETE_LOCAL', id, true);

    // Queue for sync
    if (canSyncToCloud) {
      await _queueForSync(id, 'delete', userId);
      _scheduleBackgroundSync();
    }

    _syncEventController.add(
      SyncEvent(
        type: SyncEventType.deleted,
        entityId: id,
        isLocal: true,
        willSync: canSyncToCloud,
      ),
    );
  }

  /// Get single entity
  Future<T?> get(String id) async {
    final userId = currentUserId;
    if (userId == null) return null;

    // 1. Try local first (fastest)
    final key = _getLocalKey(id, userId);
    final localData = _localBox.get(key);

    if (localData != null) {
      final entity = fromJson(Map<String, dynamic>.from(localData));
      return entity;
    }

    // 2. If premium and not found locally, try cloud
    if (canSyncToCloud) {
      try {
        final docRef = _firestore.collection(collectionName).doc(id);
        final doc = await getCacheFirst(docRef);

        if (doc != null && doc.exists) {
          final entity = fromJson(doc.data()!);
          // Cache locally for next time
          await _localBox.put(key, toJson(entity));
          return entity;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Cloud fetch failed for $id: $e');
        }
      }
    }

    return null;
  }

  /// Get all entities for current user
  Future<List<T>> getAll({
    int? limit,
    DateTime? since,
    Map<String, dynamic>? filters,
  }) async {
    final userId = currentUserId;
    if (userId == null) return [];

    // 1. Get local entities
    final localEntities = await _getLocalEntities(
      userId,
      limit: limit,
      since: since,
    );

    // 2. If premium, merge with cloud
    if (canSyncToCloud) {
      try {
        final cloudEntities = await _getCloudEntities(
          userId,
          limit: limit,
          since: since,
        );
        return _mergeEntities(localEntities, cloudEntities);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Cloud fetch failed, using local only: $e');
        }
      }
    }

    return localEntities;
  }

  /// Get local entities
  Future<List<T>> _getLocalEntities(
    String userId, {
    int? limit,
    DateTime? since,
  }) async {
    final entities = <T>[];
    final prefix = '${userId}_';

    for (final key in _localBox.keys) {
      if (key.toString().startsWith(prefix)) {
        final data = _localBox.get(key);
        if (data != null) {
          final json = Map<String, dynamic>.from(data);

          // Apply date filter
          if (since != null && json['_localLastModified'] != null) {
            final modified = DateTime.parse(json['_localLastModified']);
            if (modified.isBefore(since)) continue;
          }

          entities.add(fromJson(json));
        }
      }
    }

    // Apply limit
    if (limit != null && entities.length > limit) {
      return entities.take(limit).toList();
    }

    return entities;
  }

  /// Get cloud entities
  Future<List<T>> _getCloudEntities(
    String userId, {
    int? limit,
    DateTime? since,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(collectionName)
        .where('_userId', isEqualTo: userId);

    if (since != null) {
      query = query.where(
        '_lastModified',
        isGreaterThan: Timestamp.fromDate(since),
      );
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await queryCacheFirst(query);

    return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
  }

  /// Merge local and cloud entities
  List<T> _mergeEntities(List<T> local, List<T> cloud) {
    final merged = <String, T>{};

    // Add local entities
    for (final entity in local) {
      merged[getId(entity)] = entity;
    }

    // Merge cloud (cloud wins on conflict)
    for (final entity in cloud) {
      merged[getId(entity)] = entity;
    }

    return merged.values.toList();
  }

  // ============================================================
  // SYNC QUEUE MANAGEMENT
  // ============================================================

  /// Queue entity for sync
  Future<void> _queueForSync(
    String entityId,
    String operation,
    String userId,
  ) async {
    final queueId = '${entityId}_${DateTime.now().millisecondsSinceEpoch}';

    await _syncQueueBox.put(queueId, {
      'entityId': entityId,
      'operation': operation,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
      'status': 'pending',
    });
  }

  /// Process sync queue
  Future<SyncResult> processSyncQueue() async {
    if (!canSyncToCloud) {
      final result = SyncResult();
      result.success = false;
      result.message = 'Cloud sync not available';
      return result;
    }

    final result = SyncResult();
    final pendingItems = _syncQueueBox.values
        .where((item) => item['status'] == 'pending')
        .toList();

    for (final item in pendingItems) {
      try {
        await _processSyncItem(item);
        result.syncedItems++;
      } catch (e) {
        result.failedItems++;
        result.errors.add('Failed to sync ${item['entityId']}: $e');
      }
    }

    result.success = result.failedItems == 0;
    result.message = 'Synced ${result.syncedItems} items';

    return result;
  }

  /// Process single sync item
  Future<void> _processSyncItem(Map item) async {
    final entityId = item['entityId'];
    final operation = item['operation'];
    final userId = item['userId'];

    switch (operation) {
      case 'create':
      case 'update':
        final key = _getLocalKey(entityId, userId);
        final localData = _localBox.get(key);

        if (localData != null) {
          await _firestore
              .collection(collectionName)
              .doc(entityId)
              .set(Map<String, dynamic>.from(localData));
        }
        break;

      case 'delete':
        await _firestore.collection(collectionName).doc(entityId).delete();
        break;
    }

    // Mark as synced
    item['status'] = 'completed';
    item['completedAt'] = DateTime.now().toIso8601String();
  }

  /// Schedule background sync
  void _scheduleBackgroundSync() {
    // This will be handled by PremiumSyncManager
    // Just emit event here
    _syncEventController.add(
      SyncEvent(
        type: SyncEventType.syncRequested,
        entityId: null,
        isLocal: false,
        willSync: true,
      ),
    );
  }

  // ============================================================
  // UTILITIES
  // ============================================================

  /// Get local storage key
  String _getLocalKey(String entityId, String userId) {
    return '${userId}_$entityId';
  }

  /// Log operation for debugging
  void _logOperation(String operation, String entityId, bool success) {
    if (kDebugMode) {
      debugPrint(
        '📊 [$featureName] $operation: $entityId - ${success ? '✅' : '❌'}',
      );
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final pending = _syncQueueBox.values
        .where((item) => item['status'] == 'pending')
        .length;

    final completed = _syncQueueBox.values
        .where((item) => item['status'] == 'completed')
        .length;

    final localCount = _localBox.length;

    return {
      'feature': featureName,
      'localEntities': localCount,
      'pendingSync': pending,
      'completedSync': completed,
      'isPremium': isPremiumUser,
      'canSync': canSyncToCloud,
    };
  }

  /// Clear all local data
  ///
  /// ⚡ OPTIMIZED: Parallel clear operations with Future.wait()
  Future<void> clearLocalData() async {
    await Future.wait([
      _localBox.clear(),
      _syncQueueBox.clear(),
    ]);
  }

  /// Dispose resources (synchronous entry point)
  ///
  /// ✅ FIX: Async disposal pattern to prevent race conditions.
  ///
  /// This method is synchronous for compatibility with Riverpod's `ref.onDispose()`,
  /// but internally starts async disposal without blocking.
  ///
  /// For tests or critical shutdown, use [waitForDisposal] to ensure
  /// all async cleanup completes.
  void dispose() {
    if (_isDisposed) return;

    // Start async disposal but don't await
    // (ref.onDispose() in Riverpod is sync)
    _disposeFuture = _disposeAsync();
  }

  /// Internal async disposal implementation
  ///
  /// ✅ FIX: Properly awaits all async cleanup operations
  Future<void> _disposeAsync() async {
    if (_isDisposed) return;
    _isDisposed = true;

    if (kDebugMode) {
      debugPrint('🗑️ BaseHybridRepository disposing for: $featureName...');
    }

    try {
      // 1. Cancel timer
      _profileRefreshTimer?.cancel();
      _profileRefreshTimer = null;

      // 2. Close stream controller (async)
      await _syncEventController.close();

      // 3. ✅ CRITICAL FIX: DO NOT close boxes manually!
      //    HiveBoxManagerEnhanced owns box lifecycle and will close them centrally.
      //    Closing here causes race conditions with other repositories.
      //
      //    OLD (WRONG):
      //    await _localBox.close();      // ❌ Race condition!
      //    await _syncQueueBox.close();  // ❌ Race condition!
      //
      //    NEW (CORRECT):
      //    Boxes are managed by HiveBoxManagerEnhanced and closed via:
      //    - ref.onDispose() in hiveBoxManagerProvider
      //    - Or manually: await manager.closeAll()

      // 4. Clear user profile cache
      _userProfile = null;

      if (kDebugMode) {
        debugPrint('✅ BaseHybridRepository disposed for: $featureName');
        debugPrint('   - Timer cancelled');
        debugPrint('   - Stream closed');
        debugPrint(
          '   - Boxes managed by HiveBoxManagerEnhanced (not closed here)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error during disposal of $featureName: $e');
      }
      rethrow;
    }
  }

  /// Wait for disposal to complete (for tests and critical shutdown)
  ///
  /// Example:
  /// ```dart
  /// repository.dispose();
  /// await repository.waitForDisposal(); // Ensures cleanup is done
  /// ```
  Future<void> waitForDisposal() async {
    if (_disposeFuture != null) {
      await _disposeFuture;
    }
  }
}

/// Sync event for monitoring
class SyncEvent {
  SyncEvent({
    required this.type,
    required this.entityId,
    required this.isLocal,
    required this.willSync,
  }) : timestamp = DateTime.now();
  final SyncEventType type;
  final String? entityId;
  final bool isLocal;
  final bool willSync;
  final DateTime timestamp;
}

enum SyncEventType {
  saved,
  updated,
  deleted,
  synced,
  syncFailed,
  syncRequested,
}

/// Sync result
class SyncResult {
  bool success = false;
  String message = '';
  int syncedItems = 0;
  int failedItems = 0;
  List<String> errors = [];

  void merge(SyncResult other) {
    success = success && other.success;
    syncedItems += other.syncedItems;
    failedItems += other.failedItems;
    errors.addAll(other.errors);
  }
}
