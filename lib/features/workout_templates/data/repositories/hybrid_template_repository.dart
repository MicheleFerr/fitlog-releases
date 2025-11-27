/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/repositories
/// 🎯 Feature: workout_templates
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Hive (local storage)
/// - Firebase (cloud sync for premium)
/// - Domain entities
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// Debug logger for hybrid template repository (TEMPORARY FOR DEBUGGING)
class _HybridTemplateLogger {
  static const bool _enableDebugLogs = kDebugMode; // Only in debug mode

  static void log(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔄 HYBRID_REPO [$timestamp] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('❌ HYBRID_REPO_ERROR [$timestamp] $message${error != null ? ' - $error' : ''}');
    }
  }

  static void step(String step, String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('📍 HYBRID_STEP [$timestamp] $step: $message');
    }
  }

  static void hive(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('📦 HIVE [$timestamp] $message');
    }
  }

  static void firebase(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔥 FIREBASE [$timestamp] $message');
    }
  }
}

/// Hybrid repository for workout templates
/// - FREE users: Local storage only (unlimited local templates)
/// - PREMIUM users: Local + Cloud sync + Community access
class HybridTemplateRepository {

  HybridTemplateRepository({
    required HiveBoxManagerEnhanced boxManager,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Ref? ref,
  })  : _boxManager = boxManager,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _ref = ref {
    _HybridTemplateLogger.log('🚀 HybridTemplateRepository constructor called');
    _HybridTemplateLogger.log('  - Firestore: ${_firestore.runtimeType}');
    _HybridTemplateLogger.log('  - Auth: ${_auth.runtimeType}');
    _HybridTemplateLogger.log('  - Current user: ${_auth.currentUser?.email ?? 'null'}');

    _HybridTemplateLogger.log('Starting initialization sequence...');
    // Store the initialization future to await it later
    _initializationFuture = _initializeBoxes();
  }
  final HiveBoxManagerEnhanced _boxManager;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Ref? _ref; // Optional ref for accessing user profile provider
  late Box<Map> _templatesBox;
  late Box<Map> _templateSyncBox;

  // Initialization state tracking
  Future<void>? _initializationFuture;

  // 🚀 FIRESTORE OPTIMIZATION: Cache public templates to reduce redundant queries
  // Users frequently browse popular templates (same default query)
  // Cache only default queries (no filters) - most common use case
  // Savings: ~90,000 ops/day with 1000 users (~$18/day)
  static const Duration _publicTemplatesCacheDuration = Duration(hours: 24);
  static const String _publicTemplatesCacheKey = 'public_templates_cache';
  static const String _publicTemplatesTimestampKey = 'public_templates_timestamp';

  List<WorkoutTemplate>? _cachedPublicTemplates;
  DateTime? _publicTemplatesCacheTimestamp;

  /// Initialize Hive boxes
  Future<void> _initializeBoxes() async {
    _HybridTemplateLogger.step('HIVE_INIT', 'Starting Hive box initialization...');
    try {
      _HybridTemplateLogger.hive('Opening templates box...');
      _templatesBox = await _boxManager.openBox<Map>('templates');
      _HybridTemplateLogger.hive('✅ Templates box opened: ${_templatesBox.keys.length} existing entries');

      _HybridTemplateLogger.hive('Opening template sync queue box...');
      _templateSyncBox = await _boxManager.openBox<Map>('template_sync_queue');
      _HybridTemplateLogger.hive('✅ Template sync box opened: ${_templateSyncBox.keys.length} pending syncs');

      _HybridTemplateLogger.step('HIVE_INIT', '✅ Hive initialization completed successfully');
    } catch (e, stackTrace) {
      _HybridTemplateLogger.error('❌ Error initializing Hive boxes', e);
      _HybridTemplateLogger.error('Stack trace: $stackTrace');
      // Re-throw to prevent silent failures
      rethrow;
    }
  }

  /// Check if user is premium (reads from provider to avoid duplicate fetch)
  bool get _isPremiumUser {
    if (_ref == null) return false;

    final profileAsync = _ref.read(userProfileProvider);
    return profileAsync.when(
      data: (profile) => profile?.accountTier == AccountTier.premium ||
                         profile?.accountTier == AccountTier.pro,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Check template quota (5 for free users, unlimited for premium)
  Future<void> _checkQuota() async {
    // Premium users have unlimited templates
    if (_isPremiumUser) {
      _HybridTemplateLogger.log('Quota check: PREMIUM user - unlimited templates');
      return;
    }

    // Count custom templates for free users
    final customTemplates = await getUserTemplates();
    final customCount = customTemplates.where((t) => t.isCustom).length;

    const maxFreeTemplates = 5;
    _HybridTemplateLogger.log('Quota check: FREE user - $customCount/$maxFreeTemplates templates used');

    if (customCount >= maxFreeTemplates) {
      _HybridTemplateLogger.error('Quota exceeded: $customCount >= $maxFreeTemplates');
      throw Exception(
        'Template quota exceeded. Free users can save up to $maxFreeTemplates custom templates. '
        'Upgrade to Premium for unlimited templates.'
      );
    }
  }

  /// Create a new template (LOCAL FIRST!)
  Future<String> createTemplate(WorkoutTemplate template) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Check quota before creating (5 for free, unlimited for premium)
    await _checkQuota();

    // Generate ID if not present
    final templateId = template.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    final newTemplate = template.copyWith(
      userId: userId,
      authorName: _auth.currentUser?.displayName,
    );
    
    // 1. ALWAYS save locally first (instant!)
    await _saveTemplateLocally(newTemplate);
    
    // 2. If premium and template is public, sync to cloud
    if (_isPremiumUser && template.isPublic) {
      _syncTemplateToCloud(newTemplate);
    }
    
    return templateId;
  }
  
  /// Save template locally
  Future<void> _saveTemplateLocally(WorkoutTemplate template) async {
    final key = 'template_${template.id}';
    await _templatesBox.put(key, template.toJson());
  }
  
  /// Sync template to cloud (background)
  void _syncTemplateToCloud(WorkoutTemplate template) {
    Future(() async {
      try {
        // Add to sync queue first
        await _templateSyncBox.put(template.id, {
          'templateId': template.id,
          'operation': 'create',
          'timestamp': DateTime.now().toIso8601String(),
          'retryCount': 0,
        });
        
        // Try to sync immediately
        await _firestore
            .collection('workout_templates')
            .doc(template.id)
            .set(template.toJson());
        
        // Remove from sync queue on success
        await _templateSyncBox.delete(template.id);
        
        // print('✅ Template synced to cloud: ${template.id}');
      } catch (e) {
        // print('⚠️ Template cloud sync failed (will retry): $e');
        // Keep in sync queue for retry
      }
    });
  }
  
  /// Get user's templates (LOCAL + CLOUD if premium)
  Future<List<WorkoutTemplate>> getUserTemplates() async {
    _HybridTemplateLogger.log('📥 getUserTemplates() called');

    // Ensure initialization is complete before proceeding
    if (_initializationFuture != null) {
      _HybridTemplateLogger.step('INIT_WAIT', 'Waiting for initialization to complete...');
      await _initializationFuture;
      _HybridTemplateLogger.step('INIT_WAIT', '✅ Initialization completed');
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _HybridTemplateLogger.error('❌ No authenticated user');
        return [];
      }

      _HybridTemplateLogger.log('✅ Authenticated user: $userId');
      _HybridTemplateLogger.log('Premium status: ${_isPremiumUser ? 'PREMIUM' : 'FREE'}');

      // 1. Get local templates
      _HybridTemplateLogger.step('LOCAL', 'Fetching local templates...');
      final localTemplates = await _getLocalTemplates(userId);
      _HybridTemplateLogger.step('LOCAL', 'Found ${localTemplates.length} local templates');

      // 2. If premium, merge with cloud templates
      if (_isPremiumUser) {
        _HybridTemplateLogger.step('CLOUD', 'User is premium, fetching cloud templates...');
        try {
          final cloudTemplates = await _getCloudTemplates(userId);
          _HybridTemplateLogger.step('CLOUD', 'Found ${cloudTemplates.length} cloud templates');

          final merged = _mergeTemplates(localTemplates, cloudTemplates);
          _HybridTemplateLogger.log('✅ Merged ${merged.length} total templates (local + cloud)');
          return merged;
        } catch (e, stackTrace) {
          _HybridTemplateLogger.error('Cloud fetch failed, using local only', e);
          _HybridTemplateLogger.error('Stack trace: $stackTrace');
        }
      } else {
        _HybridTemplateLogger.step('CLOUD', 'User is free, skipping cloud templates');
      }

      _HybridTemplateLogger.log('✅ Returning ${localTemplates.length} local templates');
      return localTemplates;
    } catch (e, stackTrace) {
      _HybridTemplateLogger.error('Fatal error in getUserTemplates()', e);
      _HybridTemplateLogger.error('Stack trace: $stackTrace');
      return []; // Return empty list instead of throwing
    }
  }
  
  /// Get local templates
  Future<List<WorkoutTemplate>> _getLocalTemplates(String userId) async {
    final templates = <WorkoutTemplate>[];
    
    for (final key in _templatesBox.keys) {
      if (key.toString().startsWith('template_')) {
        final data = _templatesBox.get(key);
        if (data != null) {
          final template = WorkoutTemplate.fromJson(Map<String, dynamic>.from(data));
          if (template.userId == userId) {
            templates.add(template);
          }
        }
      }
    }
    
    // Sort by creation date
    templates.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));
    
    return templates;
  }
  
  /// Get cloud templates
  Future<List<WorkoutTemplate>> _getCloudTemplates(String userId) async {
    final snapshot = await _firestore
        .collection('workout_templates')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => WorkoutTemplate.fromJson(doc.data()))
        .toList();
  }
  
  /// Get public/community templates (PREMIUM ONLY)
  Future<List<WorkoutTemplate>> getPublicTemplates({
    String? category,  // Changed from UnifiedTemplateCategory to String (cleanup fix)
    String? searchQuery,
    List<String>? tags,
    String? difficultyLevel,
    int limit = 20,
  }) async {
    // Only premium users can access community templates
    if (!_isPremiumUser) {
      return [];
    }

    // 🚀 SMART CACHING: Only cache default queries (most common use case)
    // Default query = no filters, limit=20 → cache it
    // Filtered queries → fetch directly (less common, more specific)
    final isDefaultQuery = category == null &&
                          searchQuery == null &&
                          (tags == null || tags.isEmpty) &&
                          difficultyLevel == null &&
                          limit == 20;

    if (isDefaultQuery) {
      // 🚀 TIER 1: Check memory cache first (fastest)
      if (_cachedPublicTemplates != null && _publicTemplatesCacheTimestamp != null) {
        final cacheAge = DateTime.now().difference(_publicTemplatesCacheTimestamp!);
        if (cacheAge < _publicTemplatesCacheDuration) {
          return _cachedPublicTemplates!; // ✅ Memory cache hit
        }
      }

      // 🚀 TIER 2: Check SharedPreferences persistent cache
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_publicTemplatesCacheKey);
      final cachedTimestamp = prefs.getInt(_publicTemplatesTimestampKey);

      if (cachedJson != null && cachedTimestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
        final cacheAge = DateTime.now().difference(cacheTime);

        if (cacheAge < _publicTemplatesCacheDuration) {
          // ✅ SharedPreferences cache hit - restore to memory cache
          final List<dynamic> jsonList = json.decode(cachedJson) as List<dynamic>;
          final templates = jsonList
              .map((item) => WorkoutTemplate.fromJson(item as Map<String, dynamic>))
              .toList();

          _cachedPublicTemplates = templates;
          _publicTemplatesCacheTimestamp = cacheTime;
          return templates;
        }
      }
    }

    // ❌ Cache miss OR filtered query - fetch from Firestore
    Query query = _firestore
        .collection('workout_templates')
        .where('isPublic', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);  // category is now String
    }

    if (difficultyLevel != null) {
      query = query.where('difficultyLevel', isEqualTo: difficultyLevel);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    query = query.orderBy('downloadCount', descending: true).limit(limit);

    final snapshot = await query.get();

    final templates = snapshot.docs
        .map((doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    // Cache popular templates locally for offline access
    for (final template in templates.take(5)) {
      await _saveTemplateLocally(template);
    }

    // 💾 Save to cache ONLY if default query
    if (isDefaultQuery) {
      _cachedPublicTemplates = templates;
      _publicTemplatesCacheTimestamp = DateTime.now();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _publicTemplatesCacheKey,
        json.encode(templates.map((t) => t.toJson()).toList()),
      );
      await prefs.setInt(
        _publicTemplatesTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    return templates;
  }
  
  /// Update template
  Future<void> updateTemplate(WorkoutTemplate template) async {
    // Update locally first
    await _saveTemplateLocally(template);
    
    // Sync to cloud if premium
    if (_isPremiumUser) {
      _updateTemplateInCloud(template);
    }
  }
  
  /// Update template in cloud (background)
  void _updateTemplateInCloud(WorkoutTemplate template) {
    Future(() async {
      try {
        await _firestore
            .collection('workout_templates')
            .doc(template.id)
            .update(template.toJson());
      } catch (e) {
        // print('Template cloud update failed: $e');
      }
    });
  }
  
  /// Delete template
  Future<void> deleteTemplate(String templateId) async {
    // Delete locally
    await _templatesBox.delete('template_$templateId');
    
    // Delete from cloud if premium
    if (_isPremiumUser) {
      _deleteTemplateFromCloud(templateId);
    }
  }
  
  /// Delete template from cloud (background)
  void _deleteTemplateFromCloud(String templateId) {
    Future(() async {
      try {
        await _firestore
            .collection('workout_templates')
            .doc(templateId)
            .delete();
      } catch (e) {
        // print('Template cloud deletion failed: $e');
      }
    });
  }
  
  /// Merge local and cloud templates
  List<WorkoutTemplate> _mergeTemplates(
    List<WorkoutTemplate> local,
    List<WorkoutTemplate> cloud,
  ) {
    final merged = <String, WorkoutTemplate>{};
    
    // Add local templates
    for (final template in local) {
      merged[template.id] = template;
    }
    
    // Merge cloud templates (cloud wins on conflict)
    for (final template in cloud) {
      final localVersion = merged[template.id];
      if (localVersion == null) {
        merged[template.id] = template;
      } else {
        // Use most recently updated version
        final localUpdated = localVersion.updatedAt ?? localVersion.createdAt;
        final cloudUpdated = template.updatedAt ?? template.createdAt;
        
        if (cloudUpdated.isAfter(localUpdated)) {
          merged[template.id] = template;
        }
            }
    }
    
    final result = merged.values.toList();
    result.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));
    
    return result;
  }
  
  /// Process sync queue (for premium users)
  Future<void> processSyncQueue() async {
    if (!_isPremiumUser) return;
    
    final pendingItems = _templateSyncBox.values.toList();
    
    for (final item in pendingItems) {
      final templateId = item['templateId'];
      final operation = item['operation'];
      
      try {
        if (operation == 'create' || operation == 'update') {
          final localData = _templatesBox.get('template_$templateId');
          if (localData != null) {
            final template = WorkoutTemplate.fromJson(Map<String, dynamic>.from(localData));
            await _firestore
                .collection('workout_templates')
                .doc(templateId)
                .set(template.toJson());
          }
        } else if (operation == 'delete') {
          await _firestore
              .collection('workout_templates')
              .doc(templateId)
              .delete();
        }
        
        // Remove from sync queue on success
        await _templateSyncBox.delete(templateId);
      } catch (e) {
        // print('Sync queue processing failed for $templateId: $e');
        // Increment retry count
        item['retryCount'] = (item['retryCount'] ?? 0) + 1;
        await _templateSyncBox.put(templateId, item);
      }
    }
  }
  
  /// Get template statistics
  Future<Map<String, dynamic>> getTemplateStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};
    
    final templates = await getUserTemplates();
    
    return {
      'totalTemplates': templates.length,
      'publicTemplates': templates.where((t) => t.isPublic).length,
      'privateTemplates': templates.where((t) => !t.isPublic).length,
      'totalDownloads': templates.fold(0, (sum, t) => sum + t.downloadCount),
      'averageRating': templates.where((t) => t.averageRating > 0).isNotEmpty
        ? templates.where((t) => t.averageRating > 0).fold(
            0.0,
            (sum, t) => sum + t.averageRating,
          ) / templates.where((t) => t.averageRating > 0).length
        : 0.0,
    };
  }
  
  /// Clear local cache (for logout)
  Future<void> clearLocalCache() async {
    await _templatesBox.clear();
    await _templateSyncBox.clear();
  }
}