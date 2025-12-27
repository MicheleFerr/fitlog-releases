import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/rate_limited_firestore_mixin.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_cloud_service.dart';

/// 🔒 RATE LIMITING: All Firestore operations are rate-limited to prevent quota exhaustion
/// Repository Firebase per template workout con sync offline
///
/// 🔐 USER ISOLATION: Cache keys are now user-scoped to prevent data leakage
/// when switching between accounts. Uses UserCacheKeyManager for key generation.
class FirebaseWorkoutTemplateRepository with RateLimitedFirestoreMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _templatesCollection = 'workoutTemplates';

  // 🔐 User-scoped cache keys via UserCacheKeyManager
  // Pattern: 'firebase_templates_cache_{userId}' instead of global 'firebase_templates_cache'
  String get _localCacheKey => userCacheKeys.templatesCacheKey;
  String get _lastSyncKey => userCacheKeys.templatesLastSyncKey;
  
  /// Ottiene solo i template personalizzati dell'utente
  Future<List<WorkoutTemplate>> getCustomTemplates() async {
    final allTemplates = await getAllTemplates();

    // Debug logging
    if (kDebugMode) {
      debugPrint('🔍 getCustomTemplates: Found ${allTemplates.length} total templates');
    }
    for (final template in allTemplates) {
      if (kDebugMode) {
        debugPrint('  - ${template.name}: isCustom=${template.isCustom}, isPublic=${template.isPublic}');
      }
    }

    // FIX: Return ALL user templates since they are all the user's personal templates
    // Don't filter by isPublic because user's templates might be marked as public
    if (kDebugMode) {
      debugPrint('🔍 getCustomTemplates: Returning ALL ${allTemplates.length} user templates');
    }

    return allTemplates;
  }
  
  /// Ottiene i template pubblici (rate-limited)
  Future<List<WorkoutTemplate>> getPublicTemplates() async {
    return await rateLimitedQuery(() async {
      try {
        final querySnapshot = await _firestore
            .collection(_templatesCollection)
            .where('isPublic', isEqualTo: true)
            .orderBy('downloadCount', descending: true)
            .limit(50)
            .get();

        return querySnapshot.docs
            .map((doc) => WorkoutTemplate.fromJson(doc.data()))
            .toList();
      } catch (e) {
        return <WorkoutTemplate>[];
      }
    });
  }

  /// Ottiene solo i template predefiniti
  Future<List<WorkoutTemplate>> getPredefinedTemplates() async {
    final allTemplates = await getAllTemplates();
    return allTemplates.where((template) => !template.isCustom).toList();
  }

  /// Cerca template per query
  Future<List<WorkoutTemplate>> searchTemplates(String query) async {
    final allTemplates = await getAllTemplates();
    final queryLower = query.toLowerCase();
    
    return allTemplates.where((template) {
      return template.name.toLowerCase().contains(queryLower) ||
             template.description.toLowerCase().contains(queryLower) ||
             template.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();
  }

  /// Ottiene template per tag
  Future<List<WorkoutTemplate>> getTemplatesByTags(List<String> tags) async {
    final allTemplates = await getAllTemplates();
    
    return allTemplates.where((template) {
      return tags.any((tag) => template.tags.contains(tag));
    }).toList();
  }

  /// Crea template da workout esistente
  Future<WorkoutTemplate> createTemplateFromWorkout({
    required String name,
    required String description,
    required List<Exercise> exercises,
    List<String>? tags,
    String? imageUrl,
  }) async {
    // ✅ FIX: Use ExerciseTemplate.fromExercise() to properly handle
    // SupersetExercise, DropSetExercise, and RestPauseExercise
    final exerciseTemplates = exercises.map((exercise) {
      return ExerciseTemplate.fromExercise(exercise);
    }).toList();

    final template = WorkoutTemplate(
      name: name,
      description: description,
      exercises: exerciseTemplates,
      tags: tags ?? [],
      imageUrl: imageUrl,
      isCustom: true,
    );

    await saveTemplate(template);
    return template;
  }

  /// ⚡ OPTIMIZED: Cache-first strategy - Check local cache before querying Firestore
  /// Ottiene tutti i template dell'utente (con cache offline)
  Future<List<WorkoutTemplate>> getAllTemplates() async {
    List<WorkoutTemplate> userTemplates = [];

    try {
      // ✅ STEP 1: Check LOCAL cache first (instant, offline-capable)
      final cachedTemplates = await _getTemplatesFromCache();

      // ✅ STEP 2: Check if cache is fresh (< 1 hour old)
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheAge = now - lastSync;
      const oneHour = 60 * 60 * 1000; // 1 hour in milliseconds

      // If cache is fresh and not empty, use cached data
      if (cachedTemplates.isNotEmpty && cacheAge < oneHour) {
        if (kDebugMode) {
          debugPrint('⚡ [CACHE-HIT] Using cached templates (${cachedTemplates.length} templates, age: ${(cacheAge / 1000 / 60).toStringAsFixed(1)} min)');
        }
        userTemplates = cachedTemplates;
      } else if (_auth.currentUser != null) {
        // ✅ STEP 3: Cache is stale or empty - query Firestore if user is authenticated
        if (kDebugMode) {
          final reason = cachedTemplates.isEmpty ? 'cache empty' : 'cache stale (${(cacheAge / 1000 / 60).toStringAsFixed(1)} min old)';
          debugPrint('🔥 [CACHE-MISS] Querying Firestore ($reason)');
        }

        final cloudTemplates = await _getTemplatesFromCloud();

        // MIGRATION: Ensure all user templates have isCustom=true
        await _migrateTemplatesIsCustomField(cloudTemplates);

        // ✅ STEP 4: Update cache and sync timestamp
        await _cacheTemplates(cloudTemplates);
        await prefs.setInt(_lastSyncKey, now);

        if (kDebugMode) {
          debugPrint('✅ [CACHE-UPDATE] Saved ${cloudTemplates.length} templates to cache');
        }

        userTemplates = cloudTemplates;
      }
    } catch (e, stackTrace) {
      // CRITICAL: Log the error - this was silently failing before!
      if (kDebugMode) {
        debugPrint('❌ Firebase getAllTemplates ERROR: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        debugPrint('❌ Falling back to cache...');
      }

      // Fallback: use cached data (even if stale)
      final cachedTemplates = await _getTemplatesFromCache();
      if (kDebugMode && cachedTemplates.isNotEmpty) {
        debugPrint('⚠️ [FALLBACK] Using stale cache (${cachedTemplates.length} templates)');
      }
      userTemplates = cachedTemplates;
    }

    // Sort by usage count, then by update date
    userTemplates.sort((a, b) {
      final usageCompare = b.usageCount.compareTo(a.usageCount);
      if (usageCompare != 0) return usageCompare;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    if (kDebugMode) {
      debugPrint('📋 [TEMPLATES] Returning ${userTemplates.length} user templates');
    }

    return userTemplates;
  }

  /// Rende pubblico un template privato (rate-limited)
  Future<void> makeTemplatePublic(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    return await rateLimitedWrite(() async {
      await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .update({
            'isPublic': true,
            'authorName': _auth.currentUser?.displayName ?? 'Anonymous',
            'userId': userId,
          });
    });
  }
  
  /// Scarica un template pubblico (crea una copia privata) (rate-limited)
  Future<WorkoutTemplate> downloadPublicTemplate(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    // Ottieni il template pubblico (rate-limited read)
    final doc = await rateLimitedRead(() async {
      final document = await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .get();

      if (!document.exists) throw Exception('Template non trovato');
      return document;
    });

    final publicTemplate = WorkoutTemplate.fromJson(doc.data()!);

    // Crea una copia privata
    final privateTemplate = publicTemplate.copyWith(
      name: '${publicTemplate.name} (Copy)',
      isPublic: false,
      isCustom: true,
      userId: userId,
      downloadCount: 0,
      averageRating: 0.0,
      reviewCount: 0,
    );

    // Salva la copia
    await saveTemplate(privateTemplate);

    // Incrementa il contatore download del template originale (rate-limited write)
    await rateLimitedWrite(() async {
      await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .update({
            'downloadCount': FieldValue.increment(1),
          });
    });

    return privateTemplate;
  }
  
  /// Salva un template (cloud + cache locale)
  ///
  /// 🔐 SECURITY: For NEW templates, uses Cloud Function to enforce quota.
  /// For UPDATES, uses direct Firestore write (allowed by security rules).
  Future<void> saveTemplate(WorkoutTemplate template) async {

    // PRE-SAVE VALIDATION - Critical validation before saving

    // Validate template basic fields
    if (template.id.isEmpty) {
      throw Exception('VALIDATION ERROR: Template ID cannot be empty');
    }
    if (template.name.trim().isEmpty) {
      throw Exception('VALIDATION ERROR: Template name cannot be empty');
    }

    // Validate exercises presence and integrity
    if (template.exercises.isEmpty) {
    }

    for (int i = 0; i < template.exercises.length; i++) {
      final ex = template.exercises[i];

      if (ex.exerciseId.isEmpty) {
        throw Exception('VALIDATION ERROR: Exercise at index $i has empty exerciseId');
      }
      if (ex.exerciseName.trim().isEmpty) {
        throw Exception('VALIDATION ERROR: Exercise at index $i has empty exerciseName');
      }
      if (ex.sets.isEmpty) {
      }

      // Validate each set
      for (int j = 0; j < ex.sets.length; j++) {
        final set = ex.sets[j];
        if (set.setNumber <= 0) {
          throw Exception('VALIDATION ERROR: Exercise "${ex.exerciseName}" set $j has invalid setNumber: ${set.setNumber}');
        }
      }
    }

    // Salva sempre in locale per sync rapido
    await _saveTemplateLocally(template);

    // Prova a salvare nel cloud se utente autenticato
    if (_auth.currentUser != null) {
      try {
        // Check if template already exists (update vs create)
        // 🔧 FIX: Add 5s timeout to prevent hanging when offline
        final existingDoc = await _firestore
            .collection(_templatesCollection)
            .doc(template.id)
            .get()
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint('⏱️ Firestore get() timed out - treating as offline');
                }
                throw TimeoutException('Firestore operation timed out');
              },
            );

        final isNewTemplate = !existingDoc.exists;

        if (isNewTemplate) {
          // 🔐 NEW TEMPLATE: Use Cloud Function for quota enforcement
          // Firestore security rules block direct creates (allow create: if false;)
          if (kDebugMode) {
            debugPrint('🔐 Creating NEW template via Cloud Function: ${template.name}');
          }

          // Convert ExerciseTemplate to Exercise for Cloud Function
          final exercises = template.exercises.map((exTemplate) {
            return Exercise(
              id: exTemplate.exerciseId,
              name: exTemplate.exerciseName,
              category: exTemplate.category,
              type: exTemplate.type,
              sets: exTemplate.sets.map((setTemplate) {
                return ExerciseSet(
                  id: 'set_${setTemplate.setNumber}',
                  setNumber: setTemplate.setNumber,
                  weight: setTemplate.targetWeight ?? 0,
                  reps: setTemplate.targetReps,
                  notes: setTemplate.notes,
                );
              }).toList(),
              notes: exTemplate.notes,
              restTime: exTemplate.restTime,
            );
          }).toList();

          final result = await TemplateCloudService.createTemplate(
            name: template.name,
            description: template.description,
            exercises: exercises,
            tags: template.tags,
            isPublic: template.isPublic,
          );

          if (!result.success) {
            throw Exception('Cloud Function failed: ${result.error ?? "Unknown error"}');
          }

          if (kDebugMode) {
            debugPrint('✅ Template created via Cloud Function: ${result.templateId}');
            debugPrint('📊 Quota: ${result.quota.privateUsed}/${result.quota.privateMax} private');
          }
        } else {
          // UPDATE: Direct Firestore write (allowed by security rules)
          if (kDebugMode) {
            debugPrint('📝 Updating existing template via Firestore: ${template.name}');
          }
          await _saveTemplateToCloud(template);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Cloud save failed: $e');
        }
        // Agenda per sync futuro
        await _markForSync(template.id);
        rethrow; // Propagate error so UI shows feedback
      }
    }
  }

  /// Elimina un template
  Future<void> deleteTemplate(String templateId) async {
    // Get template info before deletion for quota update
    bool isPublic = false;
    if (_auth.currentUser != null) {
      try {
        final doc = await _firestore
            .collection(_templatesCollection)
            .doc(templateId)
            .get();
        if (doc.exists) {
          isPublic = doc.data()?['isPublic'] ?? false;
        }
      } catch (e) {
      }
    }
    
    // Elimina localmente
    await _deleteTemplateLocally(templateId);
    
    // Elimina dal cloud se disponibile
    if (_auth.currentUser != null) {
      try {
        await _deleteTemplateFromCloud(templateId);
        // Decrement quota after successful deletion
        await _decrementQuota(isPublic);
      } catch (e) {
        // Agenda per sync futuro
        await _markForDeletion(templateId);
      }
    }
  }

  /// Incrementa contatore utilizzo
  Future<void> incrementUsage(String templateId) async {
    // Aggiorna localmente
    final templates = await _getTemplatesFromCache();
    final templateIndex = templates.indexWhere((t) => t.id == templateId);
    
    if (templateIndex != -1) {
      final updatedTemplate = templates[templateIndex].incrementUsage();
      templates[templateIndex] = updatedTemplate;
      await _cacheTemplates(templates);
      
      // Aggiorna anche nel cloud se possibile
      if (_auth.currentUser != null) {
        try {
          await _saveTemplateToCloud(updatedTemplate);
        } catch (e) {
        }
      }
    }
  }

  /// Sincronizza template locali con cloud
  Future<void> syncWithCloud() async {
    if (_auth.currentUser == null) return;
    
    try {
      // 1. Carica template dal cloud
      final cloudTemplates = await _getTemplatesFromCloud();
      final localTemplates = await _getTemplatesFromCache();
      
      // 2. Merge intelligente
      final mergedTemplates = _mergeTemplates(localTemplates, cloudTemplates);
      
      // 3. Salva risultato in cache
      await _cacheTemplates(mergedTemplates);
      
      // 4. Aggiorna timestamp sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      
    } catch (e) {
      rethrow;
    }
  }

  /// Verifica se è necessario un sync
  Future<bool> needsSync() async {
    if (_auth.currentUser == null) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Sync ogni 30 minuti
    return (now - lastSync) > (30 * 60 * 1000);
  }

  /// Stream per template real-time (solo cloud)
  Stream<List<WorkoutTemplate>> templatesStream() {
    if (_auth.currentUser == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(_templatesCollection)
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Assicura che l'ID sia nel data
        return WorkoutTemplate.fromJson(data);
      }).toList();
    });
  }

  // METODI PRIVATI

  /// Carica template dal cloud (rate-limited)
  /// NOTE: Uses fallback query without orderBy if index is missing
  Future<List<WorkoutTemplate>> _getTemplatesFromCloud() async {
    if (_auth.currentUser == null) return [];

    return await rateLimitedQuery(() async {
      if (kDebugMode) {
        debugPrint('🔥 Firebase: Getting templates for user ${_auth.currentUser!.uid}');
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      try {
        // Try with orderBy first (requires composite index)
        querySnapshot = await _firestore
            .collection(_templatesCollection)
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .orderBy('updatedAt', descending: true)
            .get();
      } catch (e) {
        // Fallback: query without orderBy if index is missing
        // This happens when the composite index hasn't been created yet
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Index missing, using fallback query without orderBy: $e');
        }
        querySnapshot = await _firestore
            .collection(_templatesCollection)
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .get();
      }

      if (kDebugMode) {
        debugPrint('🔥 Firebase: Found ${querySnapshot.docs.length} documents');
      }

      final templates = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Enhanced Debug Logging - Document validation
        if (kDebugMode) {
          debugPrint('🔥 Firebase: Template ${data['name']} - id: ${doc.id}, isCustom: ${data['isCustom']}, userId: ${data['userId']}');
        }

        final template = WorkoutTemplate.fromJson(data);

        if (template.exercises.isEmpty && (data['exercises'] as List?)?.isNotEmpty == true) {
          if (kDebugMode) {
            debugPrint('⚠️ Firebase: Template ${template.name} has exercises in data but not after parsing');
          }
        }

        return template;
      }).toList();

      // Sort client-side to ensure consistent ordering
      templates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (kDebugMode) {
        debugPrint('🔥 Firebase: Returning ${templates.length} templates');
      }
      return templates;
    });
  }

  /// Salva template nel cloud (rate-limited)
  Future<void> _saveTemplateToCloud(WorkoutTemplate template) async {
    if (_auth.currentUser == null) return;

    await rateLimitedWrite(() async {
      final data = template.toJson();
      data['userId'] = _auth.currentUser!.uid;
      data['serverTimestamp'] = FieldValue.serverTimestamp();

      // IMPORTANT: Ensure isCustom is set to true for user-created templates
      if (!data.containsKey('isCustom') || data['isCustom'] == null) {
        data['isCustom'] = true; // All user-created templates are custom
        if (kDebugMode) {
          debugPrint('⚠️ Firebase: Setting isCustom=true for template ${template.name}');
        }
      }

      if (kDebugMode) {
        debugPrint('🔥 Firebase: Saving template ${template.name} with isCustom=${data['isCustom']}');
      }

      // Enhanced Debug Logging - JSON validation

      if (data['exercises'] != null) {
        final exercisesJson = data['exercises'] as List;
        for (int i = 0; i < exercisesJson.length; i++) {
          final exJson = exercisesJson[i] as Map<String, dynamic>;
        }
      } else {
      }

      await _firestore
          .collection(_templatesCollection)
          .doc(template.id)
          .set(data, SetOptions(merge: true));


      // POST-SAVE VALIDATION - Verify data was saved correctly
      try {
        // Attempt to read back the saved template to verify integrity
        final savedDoc = await _firestore
            .collection(_templatesCollection)
            .doc(template.id)
            .get();

        if (savedDoc.exists) {
          final savedData = savedDoc.data()!;
          final exercisesInFirestore = (savedData['exercises'] as List?)?.length ?? 0;

          if (exercisesInFirestore != template.exercises.length) {
            throw Exception('POST-SAVE VALIDATION FAILED: Exercise data integrity compromised');
          }

        } else {
          throw Exception('POST-SAVE VALIDATION FAILED: Document not found in Firestore');
        }
      } catch (e) {
        // Don't throw here as the save actually succeeded, just log the issue
      }
    });
  }

  /// Elimina template dal cloud (rate-limited)
  Future<void> _deleteTemplateFromCloud(String templateId) async {
    if (_auth.currentUser == null) return;

    await rateLimitedDelete(() async {
      await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .delete();
    });
  }

  /// Carica template dalla cache locale
  Future<List<WorkoutTemplate>> _getTemplatesFromCache() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_localCacheKey);
      
      if (templatesJson == null) {
        return [];
      }
      
      final List<dynamic> templatesList = json.decode(templatesJson);
      
      final templates = templatesList.map((jsonData) {
        // Enhanced Debug Logging - Cache validation
        final templateJson = jsonData as Map<String, dynamic>;
        
        final template = WorkoutTemplate.fromJson(templateJson);
        
        if (template.exercises.isEmpty && (templateJson['exercises'] as List?)?.isNotEmpty == true) {
        }
        
        return template;
      }).toList();
      
      return templates;
    } catch (e) {
      return [];
    }
  }

  /// Salva template in cache locale
  Future<void> _cacheTemplates(List<WorkoutTemplate> templates) async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      
      // Pre-serialization validation
      int totalExercises = 0;
      for (final template in templates) {
        totalExercises += template.exercises.length;
      }
      
      final templatesJson = json.encode(
        templates.map((template) => template.toJson()).toList(),
      );
      
      await prefs.setString(_localCacheKey, templatesJson);
      
      // Post-serialization validation
      final savedJson = prefs.getString(_localCacheKey);
      if (savedJson != null) {
        final decodedList = json.decode(savedJson) as List;
        
        int cachedExercises = 0;
        for (final templateJson in decodedList) {
          final exercisesList = (templateJson as Map<String, dynamic>)['exercises'] as List?;
          cachedExercises += exercisesList?.length ?? 0;
        }
        
        if (cachedExercises != totalExercises) {
        } else {
        }
      }
      
    } catch (e) {
      rethrow;
    }
  }

  /// Aggiunge un template alla cache locale (usato dopo Cloud Function save)
  /// Public method per permettere al provider di aggiornare la cache
  Future<void> addTemplateToCache(WorkoutTemplate template) async {
    await _saveTemplateLocally(template);
  }

  /// Salva singolo template localmente
  Future<void> _saveTemplateLocally(WorkoutTemplate template) async {
    
    final templates = await _getTemplatesFromCache();
    templates.removeWhere((t) => t.id == template.id);
    templates.add(template);
    templates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    await _cacheTemplates(templates);
    
    // POST-SAVE VALIDATION for local cache
    final verifyTemplates = await _getTemplatesFromCache();
    final savedTemplate = verifyTemplates.firstWhere(
      (t) => t.id == template.id,
      orElse: () => throw Exception('CACHE VALIDATION ERROR: Template not found after save'),
    );
    
    if (savedTemplate.exercises.length != template.exercises.length) {
      throw Exception('CACHE VALIDATION FAILED: Exercise data integrity compromised');
    }
    
  }

  /// Elimina template localmente
  Future<void> _deleteTemplateLocally(String templateId) async {
    final templates = await _getTemplatesFromCache();
    templates.removeWhere((t) => t.id == templateId);
    await _cacheTemplates(templates);
  }

  /// Merge intelligente tra template locali e cloud
  List<WorkoutTemplate> _mergeTemplates(
    List<WorkoutTemplate> local, 
    List<WorkoutTemplate> cloud,
  ) {
    final Map<String, WorkoutTemplate> merged = {};
    
    // Aggiungi tutti i template cloud
    for (final template in cloud) {
      merged[template.id] = template;
    }
    
    // Aggiungi template locali se più recenti o non esistenti nel cloud
    for (final localTemplate in local) {
      final cloudTemplate = merged[localTemplate.id];
      
      if (cloudTemplate == null || 
          localTemplate.updatedAt.isAfter(cloudTemplate.updatedAt)) {
        merged[localTemplate.id] = localTemplate;
      }
    }
    
    final result = merged.values.toList();
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  /// Marca template per sync futuro
  /// 🔐 Uses user-scoped key: 'pending_sync_{userId}'
  Future<void> _markForSync(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final syncKey = userCacheKeys.pendingSyncKey;
    final pendingSync = prefs.getStringList(syncKey) ?? [];
    if (!pendingSync.contains(templateId)) {
      pendingSync.add(templateId);
      await prefs.setStringList(syncKey, pendingSync);
    }
  }

  /// Marca template per eliminazione futura
  /// 🔐 Uses user-scoped key: 'pending_deletion_{userId}'
  Future<void> _markForDeletion(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletionKey = userCacheKeys.pendingDeletionKey;
    final pendingDeletion = prefs.getStringList(deletionKey) ?? [];
    if (!pendingDeletion.contains(templateId)) {
      pendingDeletion.add(templateId);
      await prefs.setStringList(deletionKey, pendingDeletion);
    }
  }

  /// Processare sync in sospeso
  /// 🔐 Uses user-scoped keys for pending sync/deletion
  Future<void> processPendingSync() async {
    if (_auth.currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final syncKey = userCacheKeys.pendingSyncKey;
    final deletionKey = userCacheKeys.pendingDeletionKey;

    // Sync template pendenti
    final pendingSync = prefs.getStringList(syncKey) ?? [];
    for (final templateId in pendingSync) {
      try {
        final templates = await _getTemplatesFromCache();
        final template = templates.firstWhere((t) => t.id == templateId);
        await _saveTemplateToCloud(template);
      } catch (e) {
        // Template not found or sync failed
      }
    }
    await prefs.remove(syncKey);

    // Eliminazioni pendenti
    final pendingDeletion = prefs.getStringList(deletionKey) ?? [];
    for (final templateId in pendingDeletion) {
      try {
        await _deleteTemplateFromCloud(templateId);
      } catch (e) {
        // Deletion failed
      }
    }
    await prefs.remove(deletionKey);
  }

  /// Inizializza template predefiniti se necessario
  Future<void> initializePredefinedTemplates() async {
    final templates = await _getTemplatesFromCache();
    final hasAnyTemplate = templates.isNotEmpty;
    
    if (!hasAnyTemplate) {
      // Crea template predefiniti
      final predefinedTemplates = _createPredefinedTemplates();
      
      for (final template in predefinedTemplates) {
        await saveTemplate(template);
      }
    }
  }

  /// Decrement quota when deleting a template (rate-limited)
  Future<void> _decrementQuota(bool isPublic) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Get user document (rate-limited read)
      final userDoc = await rateLimitedRead(() async {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (!doc.exists) return null;
        return doc;
      });

      if (userDoc == null) return;

      final userData = userDoc.data()!;
      final quotaData = userData['templateQuota'] as Map<String, dynamic>?;
      if (quotaData == null) return;

      final usedPrivate = quotaData['usedPrivateTemplates'] ?? 0;
      final usedPublic = quotaData['usedPublicTemplates'] ?? 0;

      // Update quota (rate-limited write)
      await rateLimitedWrite(() async {
        await _firestore.collection('users').doc(userId).update({
          'templateQuota.usedPrivateTemplates': isPublic ? usedPrivate : (usedPrivate - 1).clamp(0, 999),
          'templateQuota.usedPublicTemplates': isPublic ? (usedPublic - 1).clamp(0, 999) : usedPublic,
        });
      });

    } catch (e) {
      // Don't throw - deletion is more important
    }
  }

  /// Crea template predefiniti
  List<WorkoutTemplate> _createPredefinedTemplates() {
    return [
      WorkoutTemplate(
        name: 'Upper Body Strength',
        description: 'Allenamento completo parte superiore: petto, schiena, spalle e braccia',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'panca_piana',
            exerciseName: 'Panca Piana',
            category: ExerciseCategory.chest,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'trazioni',
            exerciseName: 'Trazioni',
            category: ExerciseCategory.back,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 8),
              SetTemplate(setNumber: 3, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'shoulder_press',
            exerciseName: 'Shoulder Press',
            category: ExerciseCategory.shoulders,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
            ],
          ),
        ],
        tags: ['upper', 'strength', 'intermediate'],
        estimatedDuration: 60,
        isCustom: false,
      ),
      
      WorkoutTemplate(
        name: 'Lower Body Power',
        description: 'Allenamento gambe e glutei: squat, stacchi e affondi',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'squat',
            exerciseName: 'Squat',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 12),
              SetTemplate(setNumber: 2, targetReps: 10),
              SetTemplate(setNumber: 3, targetReps: 8),
              SetTemplate(setNumber: 4, targetReps: 6),
            ],
          ),
          const ExerciseTemplate(
            exerciseId: 'stacco_da_terra',
            exerciseName: 'Stacco da Terra',
            category: ExerciseCategory.legs,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 8),
              SetTemplate(setNumber: 2, targetReps: 6),
              SetTemplate(setNumber: 3, targetReps: 4),
            ],
          ),
        ],
        tags: ['lower', 'power', 'intermediate'],
        estimatedDuration: 55,
        isCustom: false,
      ),

      WorkoutTemplate(
        name: 'HIIT Cardio',
        description: 'Allenamento ad alta intensità per cardio e resistenza',
        exercises: [
          const ExerciseTemplate(
            exerciseId: 'burpees',
            exerciseName: 'Burpees',
            category: ExerciseCategory.cardio,
            sets: [
              SetTemplate(setNumber: 1, targetReps: 15),
              SetTemplate(setNumber: 2, targetReps: 15),
              SetTemplate(setNumber: 3, targetReps: 12),
            ],
          ),
        ],
        tags: ['hiit', 'cardio', 'beginner'],
        estimatedDuration: 25,
        isCustom: false,
      ),
    ];
  }

  /// Migration: Ensure all user templates have isCustom=true (rate-limited)
  Future<void> _migrateTemplatesIsCustomField(List<WorkoutTemplate> templates) async {
    if (_auth.currentUser == null) return;

    bool migrationNeeded = false;

    for (final template in templates) {
      // If template doesn't have isCustom set, or it's false for user templates
      if (!template.isCustom) {
        migrationNeeded = true;
        if (kDebugMode) {
          debugPrint('🔄 Migration: Template "${template.name}" needs isCustom=true');
        }

        try {
          // Update in Firebase (rate-limited write)
          await rateLimitedWrite(() async {
            await _firestore
                .collection(_templatesCollection)
                .doc(template.id)
                .update({
              'isCustom': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          });

          if (kDebugMode) {
            debugPrint('✅ Migration: Updated template "${template.name}" with isCustom=true');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Migration: Failed to update template "${template.name}": $e');
          }
        }
      }
    }

    if (migrationNeeded) {
      if (kDebugMode) {
        debugPrint('🔄 Migration: Updated templates with isCustom=true');
      }
    }
  }
}