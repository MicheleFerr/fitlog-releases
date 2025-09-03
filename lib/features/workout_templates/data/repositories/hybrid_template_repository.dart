/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data/repositories
 * 🎯 Feature: workout_templates
 * 🔧 Type: repository
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Hive (local storage)
 * - Firebase (cloud sync for premium)
 * - Domain entities
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// Hybrid repository for workout templates
/// - FREE users: Local storage only (unlimited local templates)
/// - PREMIUM users: Local + Cloud sync + Community access
class HybridTemplateRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  late Box<Map> _templatesBox;
  late Box<Map> _templateSyncBox;
  
  // Cache user profile
  UserProfile? _userProfile;
  
  HybridTemplateRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance {
    _initializeBoxes();
    _loadUserProfile();
  }
  
  /// Initialize Hive boxes
  Future<void> _initializeBoxes() async {
    _templatesBox = await Hive.openBox<Map>('templates');
    _templateSyncBox = await Hive.openBox<Map>('template_sync_queue');
  }
  
  /// Load user profile to check premium status
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
      print('Failed to load user profile: $e');
    }
  }
  
  /// Check if user is premium
  bool get _isPremiumUser {
    return _userProfile?.accountTier == AccountTier.premium ||
           _userProfile?.accountTier == AccountTier.pro;
  }
  
  /// Create a new template (LOCAL FIRST!)
  Future<String> createTemplate(WorkoutTemplate template) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    // Generate ID if not present
    final templateId = template.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    final newTemplate = template.copyWith(
      id: templateId,
      userId: userId,
      createdAt: template.createdAt ?? DateTime.now(),
      authorName: _auth.currentUser?.displayName,
      authorPhotoUrl: _auth.currentUser?.photoURL,
    );
    
    // 1. ALWAYS save locally first (instant!)
    await _saveTemplateLocally(newTemplate);
    
    // 2. If premium and template is public, sync to cloud
    if (_isPremiumUser && template.visibility == TemplateVisibility.public) {
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
        
        print('✅ Template synced to cloud: ${template.id}');
      } catch (e) {
        print('⚠️ Template cloud sync failed (will retry): $e');
        // Keep in sync queue for retry
      }
    });
  }
  
  /// Get user's templates (LOCAL + CLOUD if premium)
  Future<List<WorkoutTemplate>> getUserTemplates() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    
    // 1. Get local templates
    final localTemplates = await _getLocalTemplates(userId);
    
    // 2. If premium, merge with cloud templates
    if (_isPremiumUser) {
      try {
        final cloudTemplates = await _getCloudTemplates(userId);
        return _mergeTemplates(localTemplates, cloudTemplates);
      } catch (e) {
        print('Cloud fetch failed, using local only: $e');
      }
    }
    
    return localTemplates;
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
    TemplateCategory? category,
    String? searchQuery,
    List<String>? tags,
    String? difficultyLevel,
    int limit = 20,
  }) async {
    // Only premium users can access community templates
    if (!_isPremiumUser) {
      return [];
    }
    
    Query query = _firestore
        .collection('workout_templates')
        .where('visibility', isEqualTo: TemplateVisibility.public.name);
    
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
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
        print('Template cloud update failed: $e');
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
        print('Template cloud deletion failed: $e');
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
      merged[template.id!] = template;
    }
    
    // Merge cloud templates (cloud wins on conflict)
    for (final template in cloud) {
      final localVersion = merged[template.id];
      if (localVersion == null) {
        merged[template.id!] = template;
      } else {
        // Use most recently updated version
        final localUpdated = localVersion.updatedAt ?? localVersion.createdAt;
        final cloudUpdated = template.updatedAt ?? template.createdAt;
        
        if (cloudUpdated != null && localUpdated != null) {
          if (cloudUpdated.isAfter(localUpdated)) {
            merged[template.id!] = template;
          }
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
        print('Sync queue processing failed for $templateId: $e');
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
      'publicTemplates': templates.where((t) => t.visibility == TemplateVisibility.public).length,
      'privateTemplates': templates.where((t) => t.visibility == TemplateVisibility.private).length,
      'totalDownloads': templates.fold(0, (sum, t) => sum + (t.downloadCount ?? 0)),
      'averageRating': templates.where((t) => t.rating != null).fold(
        0.0, 
        (sum, t) => sum + (t.rating ?? 0),
      ) / templates.where((t) => t.rating != null).length,
    };
  }
  
  /// Clear local cache (for logout)
  Future<void> clearLocalCache() async {
    await _templatesBox.clear();
    await _templateSyncBox.clear();
  }
}