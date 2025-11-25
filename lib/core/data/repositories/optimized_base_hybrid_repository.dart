/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/data/repositories
/// 🎯 Feature: core
/// 🔧 Type: base repository (OPTIMIZED VERSION)
///
/// ⚠️ IMPORTANT: This is a SPECIALIZED version of BaseHybridRepository
///
/// **When to use OptimizedBaseHybridRepository:**
/// - For SHARED data (e.g., exercise database) that doesn't need full sync
/// - When requiresPremiumForCloud = false (no premium checking needed)
/// - When you need 24h caching for premium status (reduces Firebase queries)
///
/// **When to use BaseHybridRepository instead:**
/// - For USER-SPECIFIC data (workouts, analytics, settings)
/// - When you need full sync operations (getAll, get, update, delete)
/// - When you need waitForDisposal() for safe cleanup
///
/// **Key differences:**
/// - Uses StreamSubscription for auth (vs Timer polling in Base)
/// - Has 24h cache for premium status (vs 5-min refresh in Base)
/// - Missing: getAll(), get(), update(), delete(), getSyncStats()
/// - Different UserProfile import (user_profile.dart vs consolidated)
///
/// @see BaseHybridRepository for full-featured repository base
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Optimized Base repository with smart premium detection
abstract class OptimizedBaseHybridRepository<T> {

  OptimizedBaseHybridRepository({
    required this.featureName,
    required this.collectionName,
    required HiveBoxManagerEnhanced boxManager,
    this.requiresPremiumForCloud = true,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _boxManager = boxManager {
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
  
  // OPTIMIZED: Cache user profile locally with expiry
  UserProfile? _cachedUserProfile;
  DateTime? _profileCacheTime;
  static const Duration _cacheValidity = Duration(hours: 24); // Cache for 24 hours!
  
  // OPTIMIZED: Listen to auth state changes instead of polling
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _profileChangeSubscription;
  
  // Sync configuration
  final StreamController<SyncEvent> _syncEventController = StreamController.broadcast();
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  /// Protected getter for Firestore instance
  @protected
  FirebaseFirestore get firestore => _firestore;

  /// Protected getter for FirebaseAuth instance
  @protected
  FirebaseAuth get auth => _auth;

  /// Initialize with optimized profile loading
  Future<void> _initialize() async {
    // Initialize Hive boxes
    _localBox = await _boxManager.openBox<Map>('${featureName}_data');
    _syncQueueBox = await _boxManager.openBox<Map>('${featureName}_sync_queue');
    
    // OPTIMIZED: Load cached profile first
    await _loadCachedProfile();
    
    // OPTIMIZED: Listen to auth changes instead of polling
    _setupAuthListener();
    
    // OPTIMIZED: Setup Firestore listener for profile changes
    _setupProfileListener();
    
    debugPrint('✅ OptimizedBaseHybridRepository initialized for: $featureName');
  }
  
  /// OPTIMIZED: Load profile from local cache first
  Future<void> _loadCachedProfile() async {
    try {
      // Check local cache first
      final cacheBox = await _boxManager.openBox<Map>('user_profile_cache');
      final cachedData = cacheBox.get('profile');

      if (cachedData != null) {
        final cacheTime = DateTime.parse(cachedData['cacheTime'] ?? '');
        final now = DateTime.now();

        // Use cache if still valid (24 hours)
        if (now.difference(cacheTime) < _cacheValidity) {
          // Deep cast: convert nested Map<dynamic, dynamic> to Map<String, dynamic>
          final profileData = _deepCastMap(cachedData['profile']);
          _cachedUserProfile = UserProfile.fromJson(profileData);
          _profileCacheTime = cacheTime;
          debugPrint('📱 Using cached profile (saved ${now.difference(cacheTime).inHours}h ago)');
          return;
        }
      }

      // Cache expired or doesn't exist, load from Firestore
      await _refreshProfileFromFirestore();

    } catch (e) {
      debugPrint('⚠️ Failed to load cached profile: $e');
      // Clear corrupted cache and retry from Firestore
      try {
        final cacheBox = await _boxManager.openBox<Map>('user_profile_cache');
        await cacheBox.delete('profile');
        debugPrint('🗑️ Cleared corrupted cache');
      } catch (_) {}
      await _refreshProfileFromFirestore();
    }
  }

  /// Deep cast Map<dynamic, dynamic> to Map<String, dynamic> recursively
  Map<String, dynamic> _deepCastMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final stringKey = key.toString();
        final castedValue = _deepCastValue(value);
        return MapEntry(stringKey, castedValue);
      });
    }
    throw ArgumentError('Expected Map but got ${data.runtimeType}');
  }

  /// Deep cast any value, handling nested structures and Firestore Timestamp
  dynamic _deepCastValue(dynamic value) {
    if (value is Map) {
      return _deepCastMap(value);
    } else if (value is List) {
      return value.map((item) => _deepCastValue(item)).toList();
    } else if (value is Timestamp) {
      // ✅ FIX: Convert Firestore Timestamp to ISO8601 string for JSON serialization
      return value.toDate().toIso8601String();
    }
    return value;
  }
  
  /// OPTIMIZED: Only refresh from Firestore when necessary
  Future<void> _refreshProfileFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Check if we really need to refresh
      if (_profileCacheTime != null) {
        final timeSinceLastRefresh = DateTime.now().difference(_profileCacheTime!);
        if (timeSinceLastRefresh < const Duration(minutes: 30)) {
          debugPrint('⏭️ Skipping profile refresh (last refresh ${timeSinceLastRefresh.inMinutes} min ago)');
          return;
        }
      }
      
      debugPrint('🔄 Refreshing profile from Firestore...');
      
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        _cachedUserProfile = UserProfile.fromFirestore(doc);
        _profileCacheTime = DateTime.now();
        
        // Save to local cache
        await _saveProfileToCache();
        
        debugPrint('✅ Profile refreshed and cached');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to refresh profile from Firestore: $e');
      // Continue with cached profile if available
    }
  }
  
  /// OPTIMIZED: Save profile to local cache
  Future<void> _saveProfileToCache() async {
    if (_cachedUserProfile == null) return;

    try {
      final cacheBox = await _boxManager.openBox<Map>('user_profile_cache');

      // ✅ FIX: Convert Timestamp objects to strings BEFORE caching
      // This prevents type cast errors when reading from Hive
      final profileMap = _cachedUserProfile!.toFirestore();
      final serializedProfile = _deepCastMap(profileMap);

      await cacheBox.put('profile', {
        'profile': serializedProfile,
        'cacheTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('⚠️ Failed to cache profile: $e');
    }
  }
  
  /// OPTIMIZED: Listen to auth state changes
  void _setupAuthListener() {
    _authStateSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null) {
        // User logged in or changed
        debugPrint('🔑 Auth state changed, refreshing profile...');
        await _refreshProfileFromFirestore();
      } else {
        // User logged out
        _cachedUserProfile = null;
        _profileCacheTime = null;
      }
    });
  }
  
  /// OPTIMIZED: Real-time listener for profile changes (only for premium path)
  void _setupProfileListener() {
    final user = _auth.currentUser;
    if (user == null) return;
    
    // IMPORTANT: Only setup listener if user might be premium
    // This reduces listeners for free users
    if (_cachedUserProfile?.accountTier == AccountTier.free) {
      debugPrint('💡 Skipping profile listener for free user');
      return;
    }
    
    _profileChangeSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final newProfile = UserProfile.fromFirestore(snapshot);
            
            // Only update if tier changed
            if (newProfile.accountTier != _cachedUserProfile?.accountTier) {
              debugPrint('🔄 Account tier changed: ${_cachedUserProfile?.accountTier} → ${newProfile.accountTier}');
              _cachedUserProfile = newProfile;
              _profileCacheTime = DateTime.now();
              _saveProfileToCache();
              
              // Trigger sync if upgraded to premium
              if (isPremiumUser) {
                _scheduleBackgroundSync();
              }
            }
          }
        });
  }
  
  /// Check if user is premium (uses cached data)
  bool get isPremiumUser {
    // Use cached profile, no Firebase query!
    return _cachedUserProfile?.accountTier == AccountTier.premium ||
           _cachedUserProfile?.accountTier == AccountTier.pro;
  }
  
  /// Check if user can sync to cloud
  bool get canSyncToCloud {
    if (!requiresPremiumForCloud) return true;
    return isPremiumUser;
  }
  
  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// OPTIMIZED: Force refresh only when explicitly needed
  Future<void> forceProfileRefresh() async {
    debugPrint('🔄 Force refreshing profile...');
    await _refreshProfileFromFirestore();
  }
  
  /// OPTIMIZED: Check premium status with minimal queries
  Future<bool> verifyPremiumStatus() async {
    // First check cache
    if (_cachedUserProfile != null && _profileCacheTime != null) {
      final cacheAge = DateTime.now().difference(_profileCacheTime!);
      
      // If cache is recent (< 1 hour), trust it
      if (cacheAge < const Duration(hours: 1)) {
        debugPrint('✅ Using cached premium status (${cacheAge.inMinutes} min old)');
        return isPremiumUser;
      }
    }
    
    // Cache is old, refresh
    await _refreshProfileFromFirestore();
    return isPremiumUser;
  }
  
  // ============================================================
  // REST OF THE IMPLEMENTATION (same as before)
  // ============================================================
  
  /// Convert entity to JSON for storage
  Map<String, dynamic> toJson(T entity);
  
  /// Convert JSON to entity
  T fromJson(Map<String, dynamic> json);
  
  /// Get unique ID for entity
  String getId(T entity);
  
  /// Validate entity before saving
  bool validate(T entity);
  
  /// Save entity (ALWAYS local, cloud if premium)
  Future<String> save(T entity) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');
    
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
    
    // 1. ALWAYS save locally first
    await _localBox.put(key, json);
    _logOperation('SAVE_LOCAL', id, true);
    
    // 2. Queue for cloud sync if allowed (uses cached premium status)
    if (canSyncToCloud) {
      await _queueForSync(id, 'create', userId);
      _scheduleBackgroundSync();
    }
    
    _syncEventController.add(SyncEvent(
      type: SyncEventType.saved,
      entityId: id,
      isLocal: true,
      willSync: canSyncToCloud,
    ));
    
    return id;
  }
  
  // ... (rest of the methods remain the same)
  
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
  
  /// Schedule background sync
  void _scheduleBackgroundSync() {
    // This will be handled by PremiumSyncManager
    _syncEventController.add(SyncEvent(
      type: SyncEventType.syncRequested,
      entityId: null,
      isLocal: false,
      willSync: true,
    ));
  }
  
  /// Get local storage key
  String _getLocalKey(String entityId, String userId) {
    return '${userId}_$entityId';
  }
  
  /// Log operation for debugging
  void _logOperation(String operation, String entityId, bool success) {
    debugPrint('📊 [$featureName] $operation: $entityId - ${success ? '✅' : '❌'}');
  }
  
  /// Dispose resources
  void dispose() {
    _authStateSubscription?.cancel();
    _profileChangeSubscription?.cancel();
    _syncEventController.close();
  }
}

// Extension for UserProfile JSON conversion
extension UserProfileJson on UserProfile {
  Map<String, dynamic> toJson() {
    return toFirestore();
  }
  
  static UserProfile fromJson(Map<String, dynamic> json) {
    // Helper to parse DateTime from various formats (Timestamp or String)
    DateTime parseDateTime(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return fallback;
    }

    // Create a mock DocumentSnapshot for parsing
    return UserProfile(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      accountTier: AccountTier.values.firstWhere(
        (t) => t.name == json['accountTier'],
        orElse: () => AccountTier.free,
      ),
      templateQuota: TemplateQuota.fromJson(json['templateQuota'] ?? {}),
      createdAt: parseDateTime(json['createdAt'], DateTime.now()),
      lastLoginAt: parseDateTime(json['lastLoginAt'], DateTime.now()),
      preferences: json['preferences'] ?? {},
      stats: json['stats'] ?? {},
      isGuest: json['isGuest'] ?? false,
    );
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