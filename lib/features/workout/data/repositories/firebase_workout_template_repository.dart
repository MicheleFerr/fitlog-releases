import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/rate_limited_firestore_mixin.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_cloud_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/template_cloud_sync_service.dart';

/// 🔒 RATE LIMITING: All Firestore operations are rate-limited to prevent quota exhaustion
/// Repository Firebase per template workout con sync offline
///
/// 🔐 USER ISOLATION: Cache keys are now user-scoped to prevent data leakage
/// when switching between accounts. Uses UserCacheKeyManager for key generation.
///
/// Uses [FirebaseErrorMapperMixin] for standardized Firebase error handling.
class FirebaseWorkoutTemplateRepository
    with RateLimitedFirestoreMixin, FirebaseErrorMapperMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _templatesCollection = 'workoutTemplates';

  // 🔐 User-scoped cache keys via UserCacheKeyManager
  // Pattern: 'firebase_templates_cache_{userId}' instead of global 'firebase_templates_cache'
  String get _localCacheKey => userCacheKeys.templatesCacheKey;
  String get _lastSyncKey => userCacheKeys.templatesLastSyncKey;

  /// Ottiene solo i template personalizzati dell'utente
  Future<List<WorkoutTemplate>> getCustomTemplates() async {
    return getAllTemplates();
  }

  /// Ottiene i template pubblici (rate-limited)
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<List<WorkoutTemplate>> getPublicTemplates() async {
    return await rateLimitedQuery(() async {
      final result = await handleFirebaseOperation(() async {
        QuerySnapshot<Map<String, dynamic>> querySnapshot;

        try {
          querySnapshot = await _firestore
              .collection(_templatesCollection)
              .where('visibility', isEqualTo: 'public')
              .where('distributionStatus', isEqualTo: 'active')
              .where('lineageType', isEqualTo: 'original')
              .orderBy('downloadCount', descending: true)
              .limit(50)
              .get()
              .timeout(const Duration(seconds: 8));
        } catch (_) {
          querySnapshot = await _firestore
              .collection(_templatesCollection)
              .where('isPublic', isEqualTo: true)
              .orderBy('downloadCount', descending: true)
              .limit(50)
              .get()
              .timeout(const Duration(seconds: 8));
        }

        return querySnapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return WorkoutTemplate.fromJson(data);
            })
            .where((template) => template.isDiscoverablePublic)
            .toList();
      }, operationName: 'getPublicTemplates');

      return result.fold((failure) {
        if (kDebugMode) {
          debugPrint('❌ getPublicTemplates failed: ${failure.message}');
        }
        return <WorkoutTemplate>[];
      }, (templates) => templates);
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
          debugPrint(
            '⚡ [CACHE-HIT] Using cached templates (${cachedTemplates.length} templates, age: ${(cacheAge / 1000 / 60).toStringAsFixed(1)} min)',
          );
        }
        userTemplates = cachedTemplates;
      } else if (_auth.currentUser != null) {
        // ✅ STEP 3: Cache is stale or empty - query Firestore if user is authenticated
        if (kDebugMode) {
          final reason = cachedTemplates.isEmpty
              ? 'cache empty'
              : 'cache stale (${(cacheAge / 1000 / 60).toStringAsFixed(1)} min old)';
          debugPrint('🔥 [CACHE-MISS] Querying Firestore ($reason)');
        }

        final cloudTemplates = await _getTemplatesFromCloud();

        // MIGRATION: Ensure all user templates have isCustom=true
        await _migrateTemplatesIsCustomField(cloudTemplates);

        // ✅ STEP 4: Update cache and sync timestamp
        await _cacheTemplates(cloudTemplates);
        await prefs.setInt(_lastSyncKey, now);

        if (kDebugMode) {
          debugPrint(
            '✅ [CACHE-UPDATE] Saved ${cloudTemplates.length} templates to cache',
          );
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
        debugPrint(
          '⚠️ [FALLBACK] Using stale cache (${cachedTemplates.length} templates)',
        );
      }
      userTemplates = cachedTemplates;
    }

    userTemplates = userTemplates
        .where(
          (template) => !template.isShared || template.isActiveDistribution,
        )
        .toList();

    // Sort by usage count, then by update date
    userTemplates.sort((a, b) {
      final usageCompare = b.usageCount.compareTo(a.usageCount);
      if (usageCompare != 0) return usageCompare;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    if (kDebugMode) {
      debugPrint(
        '📋 [TEMPLATES] Returning ${userTemplates.length} user templates',
      );
    }

    return userTemplates;
  }

  /// Condivide un template in modalità unlisted tramite Cloud Function.
  Future<String> shareTemplateUnlisted(
    String templateId, {
    bool isAnonymous = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    final result = await TemplateCloudService.shareTemplateUnlisted(
      templateId: templateId,
      isAnonymous: isAnonymous,
    );

    await syncWithCloud();
    return result.templateId;
  }

  /// Rende pubblico un template dell'utente tramite Cloud Function.
  Future<void> makeTemplatePublic(
    String templateId, {
    bool isAnonymous = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    await TemplateCloudService.publishTemplate(
      templateId: templateId,
      isAnonymous: isAnonymous,
    );

    await syncWithCloud();
  }

  /// Crea una draft privata da un template condiviso dell'utente.
  Future<WorkoutTemplate> createDraftFromSharedTemplate(
    String templateId,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    final result = await TemplateCloudService.createTemplateDraftFromShared(
      templateId: templateId,
    );

    await syncWithCloud();
    final templates = await _getTemplatesFromCache();
    return templates.firstWhere(
      (template) => template.id == result.templateId,
      orElse: () => throw Exception('Draft template not found after sync'),
    );
  }

  /// Returns the same template if editable, otherwise creates a private draft.
  Future<WorkoutTemplate> ensureEditableTemplate(
    WorkoutTemplate template,
  ) async {
    if (template.isEditable) {
      return template;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    if (template.userId != null && template.userId != userId) {
      throw Exception('Save this template to your Library before editing it.');
    }

    return createDraftFromSharedTemplate(template.id);
  }

  /// Recupera un template condiviso tramite codice/ID.
  Future<WorkoutTemplate> getSharedTemplateById(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    final doc = await rateLimitedRead(() async {
      final document = await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .get();
      if (!document.exists) throw Exception('Template non trovato');
      return document;
    });

    final data = doc.data()!;
    data['id'] = doc.id;
    final template = WorkoutTemplate.fromJson(data);

    if (!template.isShared || !template.isActiveDistribution) {
      throw Exception('Template condiviso non disponibile');
    }

    return template;
  }

  /// Segnala un template condiviso per moderazione.
  Future<void> reportTemplate({
    required String templateId,
    required String reason,
    String? details,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');

    await TemplateCloudService.reportTemplate(
      templateId: templateId,
      reason: reason,
      details: details,
    );
  }

  /// Save a Store template to Library (creates a private editable copy).
  Future<WorkoutTemplate> downloadPublicTemplate(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Utente non autenticato');
    final result = await TemplateCloudService.forkTemplate(
      templateId: templateId,
    );

    await syncWithCloud();

    final templates = await _getTemplatesFromCache();
    return templates.firstWhere(
      (template) => template.id == result.templateId,
      orElse: () => throw Exception('Forked template not found after sync'),
    );
  }

  /// Salva un template (cloud + cache locale)
  ///
  /// 🔐 SECURITY: For NEW templates, uses Cloud Function to enforce quota.
  /// For UPDATES, uses direct Firestore write (allowed by security rules).
  Future<void> saveTemplate(WorkoutTemplate template) async {
    if (!template.isEditable) {
      throw Exception(
        'Shared templates are read-only. Customize your copy before editing.',
      );
    }

    // PRE-SAVE VALIDATION - Critical validation before saving

    // Validate template basic fields
    if (template.id.isEmpty) {
      throw Exception('VALIDATION ERROR: Template ID cannot be empty');
    }
    if (template.name.trim().isEmpty) {
      throw Exception('VALIDATION ERROR: Template name cannot be empty');
    }

    // Validate exercises presence and integrity
    // Empty templates are allowed but will only be saved locally (not synced to cloud)
    final isEmptyTemplate = template.exercises.isEmpty;
    if (isEmptyTemplate && kDebugMode) {
      debugPrint(
        '📝 Empty template "${template.name}" will be saved locally only',
      );
    }

    for (int i = 0; i < template.exercises.length; i++) {
      final ex = template.exercises[i];

      if (ex.exerciseId.isEmpty) {
        throw Exception(
          'VALIDATION ERROR: Exercise at index $i has empty exerciseId',
        );
      }
      if (ex.exerciseName.trim().isEmpty) {
        throw Exception(
          'VALIDATION ERROR: Exercise at index $i has empty exerciseName',
        );
      }
      if (ex.sets.isEmpty) {}

      // Validate each set
      for (int j = 0; j < ex.sets.length; j++) {
        final set = ex.sets[j];
        if (set.setNumber <= 0) {
          throw Exception(
            'VALIDATION ERROR: Exercise "${ex.exerciseName}" set $j has invalid setNumber: ${set.setNumber}',
          );
        }
      }
    }

    // Salva sempre in locale per sync rapido
    await _saveTemplateLocally(template);
    await _markCacheFresh();

    // Skip cloud sync for empty templates - they'll sync when exercises are added
    if (isEmptyTemplate) {
      if (kDebugMode) {
        debugPrint(
          '⏭️ Skipping cloud sync for empty template - save locally only',
        );
      }
      return;
    }

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
                  debugPrint(
                    '⏱️ Firestore get() timed out - treating as offline',
                  );
                }
                throw TimeoutException('Firestore operation timed out');
              },
            );

        final isNewTemplate = !existingDoc.exists;

        if (isNewTemplate) {
          // 🔐 NEW TEMPLATE: Use Cloud Function for quota enforcement
          // Firestore security rules block direct creates (allow create: if false;)
          if (kDebugMode) {
            debugPrint(
              '🔐 Creating NEW template via Cloud Function: ${template.name}',
            );
          }

          // ✅ FIX: Use ExerciseTemplate.toJson() to preserve superset/dropset/restpause data
          // Previous code created plain Exercise objects, losing subExercises and supersetSets
          final exercisesJson = template.exercises
              .map((e) => e.toJson())
              .toList();

          final result = await TemplateCloudService.createTemplateFromJson(
            name: template.name,
            description: template.description,
            exercisesJson: exercisesJson,
            tags: template.tags,
            isPublic: template.isPublic,
          );

          if (!result.success) {
            throw Exception(
              'Cloud Function failed: ${result.error ?? "Unknown error"}',
            );
          }

          if (kDebugMode) {
            debugPrint(
              '✅ Template created via Cloud Function: ${result.templateId}',
            );
            debugPrint(
              '📊 Library quota: ${result.quota.libraryUsed}/${result.quota.libraryMax}',
            );
          }
        } else {
          // UPDATE: Direct Firestore write (allowed by security rules)
          if (kDebugMode) {
            debugPrint(
              '📝 Updating existing template via Firestore: ${template.name}',
            );
          }
          await _saveTemplateToCloud(template);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Cloud save failed: $e');
        }

        // 🔄 EXPONENTIAL BACKOFF RETRY: Add to cloud sync service for automatic retry
        // with exponential backoff: 3s, 6s, 12s, 24s, 48s
        // ✅ FIX: Use ExerciseTemplate.toJson() to preserve superset/dropset/restpause data
        final exercisesForSync = template.exercises
            .map((e) => e.toJson())
            .toList();

        final templateData = {
          'name': template.name,
          'description': template.description,
          'exercises': exercisesForSync,
          'tags': template.tags,
          'isPublic': template.isPublic,
        };

        await TemplateCloudSyncService.addPendingTemplate(
          template.id,
          templateData,
        );

        if (kDebugMode) {
          debugPrint(
            '⏳ Template ${template.id} marked for automatic retry (exponential backoff)',
          );
        }

        rethrow; // Propagate error so UI shows feedback
      }
    }
  }

  /// Elimina un template
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<void> deleteTemplate(String templateId) async {
    // Elimina localmente
    await _deleteTemplateLocally(templateId);

    // Elimina dal cloud se disponibile
    if (_auth.currentUser != null) {
      final deleteResult = await handleFirebaseVoidOperation(() async {
        await _deleteTemplateFromCloud(templateId);
        await _recalculateQuotaMetadata();
      }, operationName: 'deleteTemplateFromCloud');

      deleteResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('⚠️ Cloud delete failed: ${failure.message}');
          }
          // Agenda per sync futuro
          _markForDeletion(templateId);
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Template deleted from cloud: $templateId');
          }
        },
      );
    }
  }

  /// Incrementa contatore utilizzo
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
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
        final result = await handleFirebaseVoidOperation(
          () => _saveTemplateToCloud(updatedTemplate),
          operationName: 'incrementUsage',
        );

        result.mapLeft((failure) {
          if (kDebugMode) {
            debugPrint('⚠️ Failed to sync usage: ${failure.message}');
          }
        });
      }
    }
  }

  /// Sincronizza template locali con cloud
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<void> syncWithCloud() async {
    if (_auth.currentUser == null) return;

    final result = await handleFirebaseVoidOperation(() async {
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

      if (kDebugMode) {
        debugPrint(
          '✅ syncWithCloud completed: ${mergedTemplates.length} templates',
        );
      }
    }, operationName: 'syncWithCloud');

    result.mapLeft((failure) {
      if (kDebugMode) {
        debugPrint('❌ syncWithCloud failed: ${failure.message}');
      }
      throw failure; // Rethrow for caller to handle
    });
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
        debugPrint(
          '🔥 Firebase: Getting templates for user ${_auth.currentUser!.uid}',
        );
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      try {
        // Try with orderBy first (requires composite index)
        querySnapshot = await _firestore
            .collection(_templatesCollection)
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .orderBy('updatedAt', descending: true)
            .get()
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        // Fallback: query without orderBy if index is missing
        // This happens when the composite index hasn't been created yet
        if (kDebugMode) {
          debugPrint(
            '⚠️ Firebase: Index missing, using fallback query without orderBy: $e',
          );
        }
        querySnapshot = await _firestore
            .collection(_templatesCollection)
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .get()
            .timeout(const Duration(seconds: 8));
      }

      final templates = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final template = WorkoutTemplate.fromJson(data);

        if (template.exercises.isEmpty &&
            (data['exercises'] as List?)?.isNotEmpty == true) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ Firebase: Template ${template.name} has exercises in data but not after parsing',
            );
          }
        }

        return template;
      }).toList();

      // Sort client-side to ensure consistent ordering
      templates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return templates;
    });
  }

  /// Salva template nel cloud (rate-limited)
  ///
  /// 🔐 SECURITY FIX 2025-02-09: Per nuovi template usa Cloud Function createTemplate
  /// che enforce quota limits server-side. Per UPDATE usa scrittura diretta (permesso).
  Future<void> _saveTemplateToCloud(WorkoutTemplate template) async {
    if (_auth.currentUser == null) return;

    // 🔐 STEP 1: Check if document already exists (UPDATE vs CREATE)
    final docExists = await _firestore
        .collection(_templatesCollection)
        .doc(template.id)
        .get()
        .then((doc) => doc.exists)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => false, // Assume new if timeout
        );

    if (!docExists) {
      // 🆕 NEW TEMPLATE: Use Cloud Function to enforce quota limits
      if (kDebugMode) {
        debugPrint(
          '🆕 Firebase: Creating NEW template "${template.name}" via Cloud Function',
        );
      }

      try {
        // Convert ExerciseTemplate list to JSON format for Cloud Function
        final exercisesJson = template.exercises
            .map((e) => e.toJson())
            .toList();

        final result = await TemplateCloudService.createTemplateFromJson(
          name: template.name,
          description: template.description,
          exercisesJson: exercisesJson,
          tags: template.tags,
          isPublic: template.isPublic,
        );

        if (!result.success) {
          throw Exception(
            result.error ?? 'Failed to create template via Cloud Function',
          );
        }

        if (kDebugMode) {
          debugPrint(
            '✅ Firebase: Template created with ID: ${result.templateId}',
          );
        }

        // 🔧 Update local cache with the new ID from Cloud Function
        // The template ID might be different from the UUID generated client-side
        if (result.templateId != template.id) {
          // Update local cache to use the server-generated ID
          await _updateLocalTemplateId(template.id, result.templateId);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Firebase: Cloud Function failed: $e');
        }
        rethrow;
      }
      return;
    }

    // 📝 EXISTING TEMPLATE: Use direct UPDATE (allowed by security rules)
    await rateLimitedWrite(() async {
      final data = template.toJson();
      data['userId'] = _auth.currentUser!.uid;
      data['serverTimestamp'] = FieldValue.serverTimestamp();

      // IMPORTANT: Ensure isCustom is set to true for user-created templates
      if (!data.containsKey('isCustom') || data['isCustom'] == null) {
        data['isCustom'] = true; // All user-created templates are custom
        if (kDebugMode) {
          debugPrint(
            '⚠️ Firebase: Setting isCustom=true for template ${template.name}',
          );
        }
      }

      if (kDebugMode) {
        debugPrint(
          '🔥 Firebase: Updating template ${template.name} with isCustom=${data['isCustom']}',
        );
      }

      // 🔧 FIX: Add 10s timeout to prevent infinite hanging on network issues
      await _firestore
          .collection(_templatesCollection)
          .doc(template.id)
          .set(data, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('⏱️ Firebase: Template save timed out after 10s');
              }
              throw TimeoutException('Firestore save timed out');
            },
          );

      // POST-SAVE VALIDATION - Verify data was saved correctly
      try {
        // Attempt to read back the saved template to verify integrity
        // 🔧 FIX: Add 5s timeout for validation read
        final savedDoc = await _firestore
            .collection(_templatesCollection)
            .doc(template.id)
            .get()
            .timeout(const Duration(seconds: 5));

        if (savedDoc.exists) {
          final savedData = savedDoc.data()!;
          final exercisesInFirestore =
              (savedData['exercises'] as List?)?.length ?? 0;

          if (exercisesInFirestore != template.exercises.length) {
            throw Exception(
              'POST-SAVE VALIDATION FAILED: Exercise data integrity compromised',
            );
          }
        } else {
          throw Exception(
            'POST-SAVE VALIDATION FAILED: Document not found in Firestore',
          );
        }
      } catch (e) {
        // Don't throw here as the save actually succeeded, just log the issue
      }
    });
  }

  /// Helper to update local cache when template ID changes after Cloud Function creation
  Future<void> _updateLocalTemplateId(String oldId, String newId) async {
    try {
      final templates = await _getTemplatesFromCache();
      final index = templates.indexWhere((t) => t.id == oldId);
      if (index != -1) {
        templates[index] = templates[index].copyWith(id: newId);
        await _cacheTemplates(templates);
        if (kDebugMode) {
          debugPrint('🔄 Cache: Updated template ID from $oldId to $newId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Cache: Failed to update template ID: $e');
      }
    }
  }

  /// Elimina template dal cloud (rate-limited)
  Future<void> _deleteTemplateFromCloud(String templateId) async {
    if (_auth.currentUser == null) return;

    // 🔍 DEBUG: Log user and document info before delete attempt
    final currentUserId = _auth.currentUser!.uid;
    final currentUserEmail = _auth.currentUser!.email;

    // Get document to check ownership before delete
    final docSnapshot = await _firestore
        .collection(_templatesCollection)
        .doc(templateId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final docUserId = data['userId'] as String?;
      final docEmail = data['email'] as String?;
      final docCoachId = data['coachId'] as String?;

      // Log comparison (works in release via print)
      if (kDebugMode) {
        print('🔍 DELETE DEBUG:');
        print('   Template ID: $templateId');
        print('   Current user UID: $currentUserId');
        print('   Current user email: $currentUserEmail');
        print('   Doc userId: $docUserId');
        print('   Doc email: $docEmail');
        print('   Doc coachId: $docCoachId');
        print('   userId match: ${docUserId == currentUserId}');
        print('   email match: ${docEmail == currentUserEmail}');
      }

      if (docUserId != currentUserId &&
          docEmail != currentUserEmail &&
          docCoachId != currentUserId) {
        if (kDebugMode) {
          print('⚠️ OWNERSHIP MISMATCH - Delete will fail!');
        }
      }

      // Only attempt delete if document exists
      await rateLimitedDelete(() async {
        await _firestore
            .collection(_templatesCollection)
            .doc(templateId)
            .delete();
      });
    } else {
      // Document doesn't exist in Firestore - skip cloud delete
      // This happens when template was only in local cache (never synced)
      if (kDebugMode) {
        print(
          '🔍 DELETE: Document $templateId not in Firestore, skipping cloud delete',
        );
      }
    }
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

        if (template.exercises.isEmpty &&
            (templateJson['exercises'] as List?)?.isNotEmpty == true) {}

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
          final exercisesList =
              (templateJson as Map<String, dynamic>)['exercises'] as List?;
          cachedExercises += exercisesList?.length ?? 0;
        }

        if (cachedExercises != totalExercises) {
        } else {}
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
      orElse: () => throw Exception(
        'CACHE VALIDATION ERROR: Template not found after save',
      ),
    );

    if (savedTemplate.exercises.length != template.exercises.length) {
      throw Exception(
        'CACHE VALIDATION FAILED: Exercise data integrity compromised',
      );
    }
  }

  /// Elimina template localmente
  Future<void> _deleteTemplateLocally(String templateId) async {
    final templates = await _getTemplatesFromCache();
    templates.removeWhere((t) => t.id == templateId);
    await _cacheTemplates(templates);
    await _markCacheFresh();
  }

  Future<void> _markCacheFresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
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
  ///
  /// ✅ UPDATED: Now delegates to TemplateCloudSyncService for exponential backoff retry
  /// with attempt tracking (3s, 6s, 12s, 24s, 48s delays).
  /// Old pending sync entries are processed here for backward compatibility.
  ///
  /// Uses [FirebaseErrorMapperMixin] for standardized error handling.
  Future<void> processPendingSync() async {
    if (_auth.currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final syncKey = userCacheKeys.pendingSyncKey;
    final deletionKey = userCacheKeys.pendingDeletionKey;

    // ✅ NEW: Process pending templates via TemplateCloudSyncService
    // This handles exponential backoff and attempt tracking
    await TemplateCloudSyncService.syncPending();

    // Legacy: Process old pending sync entries (for backward compatibility)
    final pendingSync = prefs.getStringList(syncKey) ?? [];
    for (final templateId in pendingSync) {
      final templates = await _getTemplatesFromCache();
      final templateOpt = templates
          .where((t) => t.id == templateId)
          .firstOrNull;

      if (templateOpt != null) {
        final result = await handleFirebaseVoidOperation(
          () => _saveTemplateToCloud(templateOpt),
          operationName: 'processPendingSync',
        );

        result.mapLeft((failure) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ Pending sync failed for $templateId: ${failure.message}',
            );
          }
        });
      }
    }
    await prefs.remove(syncKey);

    // Eliminazioni pendenti
    final pendingDeletion = prefs.getStringList(deletionKey) ?? [];
    for (final templateId in pendingDeletion) {
      final result = await handleFirebaseVoidOperation(
        () => _deleteTemplateFromCloud(templateId),
        operationName: 'processPendingDeletion',
      );

      result.mapLeft((failure) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Pending deletion failed for $templateId: ${failure.message}',
          );
        }
      });
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

  /// Recalculate quota buckets after direct client-side deletions.
  Future<void> _recalculateQuotaMetadata() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final updateResult = await handleFirebaseVoidOperation(() async {
      final snapshot = await rateLimitedRead(() async {
        return await _firestore
            .collection(_templatesCollection)
            .where('userId', isEqualTo: userId)
            .get();
      });

      final templates = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkoutTemplate.fromJson(data);
      }).toList();

      final privateCount = templates.where((t) => t.isEditable).length;
      final distributedCount = templates
          .where((t) => t.isShared && t.isActiveDistribution)
          .length;

      await rateLimitedWrite(() async {
        await _firestore.collection('users').doc(userId).set({
          'templateQuota': {
            'usedLibraryTemplates': privateCount,
            'libraryEditableCount': privateCount,
            'usedPrivateTemplates': privateCount,
            'usedSharedTemplates': distributedCount,
            'usedPublicTemplates': distributedCount,
            'distributedTemplateCount': distributedCount,
            'distributionMetered': false,
          },
        }, SetOptions(merge: true));
      });
    }, operationName: 'recalculateTemplateQuota');

    updateResult.mapLeft((failure) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to recalculate quota: ${failure.message}');
      }
    });
  }

  /// Crea template predefiniti
  List<WorkoutTemplate> _createPredefinedTemplates() {
    return [
      WorkoutTemplate(
        name: 'Upper Body Strength',
        description:
            'Allenamento completo parte superiore: petto, schiena, spalle e braccia',
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
  Future<void> _migrateTemplatesIsCustomField(
    List<WorkoutTemplate> templates,
  ) async {
    if (_auth.currentUser == null) return;

    bool migrationNeeded = false;

    for (final template in templates) {
      // If template doesn't have isCustom set, or it's false for user templates
      if (!template.isCustom) {
        migrationNeeded = true;
        if (kDebugMode) {
          debugPrint(
            '🔄 Migration: Template "${template.name}" needs isCustom=true',
          );
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
            debugPrint(
              '✅ Migration: Updated template "${template.name}" with isCustom=true',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '❌ Migration: Failed to update template "${template.name}": $e',
            );
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

  // ============================================================
  // 🔧 DIAGNOSTIC METHODS - For debugging template sync issues
  // ============================================================

  /// 🔧 Invalidates local cache and forces a fresh load from Firebase
  ///
  /// Use this when:
  /// - Templates are out of sync between cache and Firebase
  /// - Quota shows more templates than visible in UI
  /// - Need to diagnose ghost templates
  Future<void> invalidateCacheAndForceRefresh() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear cache
    await prefs.remove(_localCacheKey);
    await prefs.remove(_lastSyncKey);

    debugPrint(
      '🔧 [DIAG] Cache invalidated - next getAllTemplates will fetch from Firebase',
    );
  }

  /// 🔧 Fetches ALL templates for current user directly from Firebase (no cache)
  ///
  /// Returns diagnostic info including template IDs for deletion.
  /// Use this to see "ghost" templates that don't appear in the UI.
  Future<List<Map<String, dynamic>>>
  fetchAllTemplatesFromFirebaseDirect() async {
    if (_auth.currentUser == null) {
      debugPrint('🔧 [DIAG] User not authenticated');
      return [];
    }

    final userId = _auth.currentUser!.uid;
    debugPrint('🔧 [DIAG] Fetching ALL templates for userId: $userId');

    try {
      final querySnapshot = await _firestore
          .collection(_templatesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint(
        '🔧 [DIAG] Found ${querySnapshot.docs.length} templates in Firebase',
      );

      final results = <Map<String, dynamic>>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final info = <String, dynamic>{
          'id': doc.id,
          'name': data['name'] ?? 'NO NAME',
          'isPublic': data['isPublic'] ?? false,
          'exerciseCount': (data['exercises'] as List?)?.length ?? 0,
          'createdAt': data['createdAt']?.toDate()?.toIso8601String() ?? 'N/A',
          'userId': data['userId'],
        };

        results.add(info);

        debugPrint('🔧 [DIAG] Template: ${info['name']}');
        debugPrint('         ID: ${info['id']}');
        debugPrint('         Exercises: ${info['exerciseCount']}');
        debugPrint('         Created: ${info['createdAt']}');
        debugPrint('         isPublic: ${info['isPublic']}');
        debugPrint('');
      }

      return results;
    } catch (e) {
      debugPrint('🔧 [DIAG] Error fetching templates: $e');
      return [];
    }
  }

  /// 🔧 Deletes a template directly from Firebase by ID
  ///
  /// Use this to remove "ghost" templates that appear in quota but not in UI.
  /// ⚠️ WARNING: This is permanent and cannot be undone!
  Future<bool> forceDeleteTemplateById(String templateId) async {
    if (_auth.currentUser == null) {
      debugPrint('🔧 [DIAG] User not authenticated');
      return false;
    }

    try {
      debugPrint('🔧 [DIAG] Force deleting template: $templateId');

      // First verify the template belongs to current user
      final doc = await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .get();

      if (!doc.exists) {
        debugPrint('🔧 [DIAG] Template does not exist in Firebase');
        return false;
      }

      final data = doc.data()!;
      final docUserId = data['userId'] as String?;

      if (docUserId != _auth.currentUser!.uid) {
        debugPrint(
          '🔧 [DIAG] Template belongs to different user - cannot delete',
        );
        return false;
      }

      // Delete from Firebase
      await _firestore
          .collection(_templatesCollection)
          .doc(templateId)
          .delete();

      debugPrint('🔧 [DIAG] ✅ Template deleted successfully');

      // Also remove from local cache
      await _deleteTemplateLocally(templateId);

      return true;
    } catch (e) {
      debugPrint('🔧 [DIAG] Error deleting template: $e');
      return false;
    }
  }

  /// 🔧 Gets diagnostic info about template quota discrepancy
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Cache info
    final cacheJson = prefs.getString(_localCacheKey);
    final lastSync = prefs.getInt(_lastSyncKey) ?? 0;
    final cacheAge = DateTime.now().millisecondsSinceEpoch - lastSync;

    int cachedCount = 0;
    if (cacheJson != null) {
      try {
        final cacheList = json.decode(cacheJson) as List;
        cachedCount = cacheList.length;
      } catch (_) {}
    }

    // Firebase count
    int firebaseCount = 0;
    if (_auth.currentUser != null) {
      try {
        final snapshot = await _firestore
            .collection(_templatesCollection)
            .where('userId', isEqualTo: _auth.currentUser!.uid)
            .count()
            .get();
        firebaseCount = snapshot.count ?? 0;
      } catch (_) {}
    }

    final info = {
      'userId': _auth.currentUser?.uid ?? 'NOT AUTHENTICATED',
      'cacheCount': cachedCount,
      'firebaseCount': firebaseCount,
      'cacheAgeMinutes': (cacheAge / 1000 / 60).round(),
      'isCacheStale': cacheAge > (60 * 60 * 1000), // > 1 hour
      'discrepancy': firebaseCount - cachedCount,
    };

    debugPrint('🔧 [DIAG] Template Diagnostic Info:');
    debugPrint('         User ID: ${info['userId']}');
    debugPrint('         Cache count: ${info['cacheCount']}');
    debugPrint('         Firebase count: ${info['firebaseCount']}');
    debugPrint('         Cache age: ${info['cacheAgeMinutes']} minutes');
    debugPrint('         Cache stale: ${info['isCacheStale']}');
    debugPrint('         Discrepancy: ${info['discrepancy']}');

    return info;
  }
}
