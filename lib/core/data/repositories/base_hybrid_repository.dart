/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: core/data/repositories
/// 🎯 Feature: core
/// 🔧 Type: base repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// CRITICAL: ALL new features MUST extend this base repository
/// to ensure automatic local storage and premium sync!
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile_consolidated.dart';

/// Base repository that ALL feature repositories MUST extend
/// Provides automatic local storage and premium sync
abstract class BaseHybridRepository<T> {
  
  BaseHybridRepository({
    required this.featureName,
    required this.collectionName,
    this.requiresPremiumForCloud = true,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance {
    _initialize();
  }
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
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
  final StreamController<SyncEvent> _syncEventController = StreamController.broadcast();
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;
  
  /// Initialize boxes and load user profile
  Future<void> _initialize() async {
    // Initialize Hive boxes for this feature
    _localBox = await Hive.openBox<Map>('${featureName}_data');
    _syncQueueBox = await Hive.openBox<Map>('${featureName}_sync_queue');
    
    // Load and monitor user profile
    await _loadUserProfile();
    _startProfileMonitoring();
    
    debugPrint('✅ BaseHybridRepository initialized for: $featureName');
  }
  
  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          _userProfile = UserProfile.fromFirestore(doc);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load user profile: $e');
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
    _syncEventController.add(SyncEvent(
      type: SyncEventType.saved,
      entityId: id,
      isLocal: true,
      willSync: canSyncToCloud,
    ));
    
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
    
    _syncEventController.add(SyncEvent(
      type: SyncEventType.updated,
      entityId: id,
      isLocal: true,
      willSync: canSyncToCloud,
    ));
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
    
    _syncEventController.add(SyncEvent(
      type: SyncEventType.deleted,
      entityId: id,
      isLocal: true,
      willSync: canSyncToCloud,
    ));
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
        final doc = await _firestore
            .collection(collectionName)
            .doc(id)
            .get();
        
        if (doc.exists) {
          final entity = fromJson(doc.data()!);
          // Cache locally for next time
          await _localBox.put(key, toJson(entity));
          return entity;
        }
      } catch (e) {
        debugPrint('⚠️ Cloud fetch failed for $id: $e');
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
    final localEntities = await _getLocalEntities(userId, limit: limit, since: since);
    
    // 2. If premium, merge with cloud
    if (canSyncToCloud) {
      try {
        final cloudEntities = await _getCloudEntities(userId, limit: limit, since: since);
        return _mergeEntities(localEntities, cloudEntities);
      } catch (e) {
        debugPrint('⚠️ Cloud fetch failed, using local only: $e');
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
    Query query = _firestore
        .collection(collectionName)
        .where('_userId', isEqualTo: userId);
    
    if (since != null) {
      query = query.where('_lastModified', isGreaterThan: Timestamp.fromDate(since));
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    final snapshot = await query.get();
    
    return snapshot.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
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
  Future<void> _queueForSync(String entityId, String operation, String userId) async {
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
        await _firestore
            .collection(collectionName)
            .doc(entityId)
            .delete();
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
    _syncEventController.add(SyncEvent(
      type: SyncEventType.syncRequested,
      entityId: null,
      isLocal: false,
      willSync: true,
    ));
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
    debugPrint('📊 [$featureName] $operation: $entityId - ${success ? '✅' : '❌'}');
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
  Future<void> clearLocalData() async {
    await _localBox.clear();
    await _syncQueueBox.clear();
  }
  
  /// Dispose resources
  void dispose() {
    _profileRefreshTimer?.cancel();
    _syncEventController.close();
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