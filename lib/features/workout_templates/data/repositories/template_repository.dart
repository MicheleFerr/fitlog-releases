/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data
/// 🎯 Feature: workout_templates
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Riverpod: Provider
/// - Firebase: Firestore
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/services/template_cloud_service.dart';

class TemplateRepository {
  TemplateRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collections
  // FIXED: Use same collection as FirebaseWorkoutTemplateRepository ('workoutTemplates')
  // to ensure Single Source of Truth for templates
  CollectionReference get _templatesCollection =>
      _firestore.collection('workoutTemplates');

  CollectionReference get _reviewsCollection =>
      _firestore.collection('template_reviews');

  CollectionReference get _commentsCollection =>
      _firestore.collection('template_comments');

  // CRUD Operations

  /// Crea un nuovo template
  ///
  /// 🔐 SECURITY FIX 2025-02-09: Uses Cloud Function to enforce server-side quota.
  /// Direct Firestore writes are BLOCKED by security rules (allow create: if false).
  ///
  /// [maxPrivateTemplates] - Max private templates (from tierEntitlementsProvider)
  /// [maxPublicTemplates] - Max public templates (from tierEntitlementsProvider)
  Future<String> createTemplate(
    WorkoutTemplate template, {
    required int maxPrivateTemplates,
    required int maxPublicTemplates,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Note: Quota is now enforced server-side by the Cloud Function.
    // We still do a client-side check for better UX (faster feedback).
    await _checkUserQuota(
      userId,
      template.visibility,
      maxPrivate: maxPrivateTemplates,
      maxPublic: maxPublicTemplates,
    );

    // GDPR: Anonymize author info if isAnonymous is true
    final authorName = template.isAnonymous
        ? 'Utente Anonimo'
        : _auth.currentUser?.displayName;

    if (kDebugMode) {
      debugPrint(
        '🔐 [TemplateRepository] Creating template via Cloud Function: "${template.name}"',
      );
    }

    // 🔐 SECURITY: Use Cloud Function for CREATE (direct writes are blocked)
    // Convert WorkoutTemplateExercise to JSON format for Cloud Function
    final exercisesJson = template.exercises.map((e) => e.toJson()).toList();

    final result = await TemplateCloudService.createTemplateFromJson(
      name: template.name,
      description: template.description ?? '',
      exercisesJson: exercisesJson,
      tags: template.tags,
      isPublic: template.visibility == TemplateVisibility.public,
    );

    if (!result.success) {
      throw Exception(result.error ?? 'Failed to create template via Cloud Function');
    }

    if (kDebugMode) {
      debugPrint(
        '✅ [TemplateRepository] Template created: ${result.templateId} '
        '(quota: ${result.quota.privateUsed}/${result.quota.privateMax})',
      );
    }

    // Update template with additional fields via direct UPDATE (allowed by rules)
    // This adds fields that the Cloud Function doesn't set
    if (result.templateId.isNotEmpty) {
      try {
        await _templatesCollection.doc(result.templateId).update({
          'authorName': authorName,
          'authorPhotoUrl': template.isAnonymous ? null : _auth.currentUser?.photoURL,
          'isAnonymous': template.isAnonymous,
          'visibility': template.visibility.name,
          'category': template.category.name,
          'difficultyLevel': template.difficultyLevel,
          'estimatedDurationMinutes': template.estimatedDurationMinutes,
          'forkedFromTemplateId': template.forkedFromTemplateId,
          'originalAuthorName': template.originalAuthorName,
        });
      } catch (e) {
        // Non-critical - template was created, just missing some metadata
        if (kDebugMode) {
          debugPrint('⚠️ [TemplateRepository] Failed to update metadata: $e');
        }
      }
    }

    return result.templateId;
  }

  /// Ottieni i template dell'utente corrente
  Future<List<WorkoutTemplate>> getUserTemplates() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _templatesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Ottieni template pubblici (con filtri)
  Future<List<WorkoutTemplate>> getPublicTemplates({
    TemplateCategory? category,
    String? searchQuery,
    List<String>? tags,
    String? difficultyLevel,
    int limit = 20,
  }) async {
    Query query = _templatesCollection.where(
      'visibility',
      isEqualTo: TemplateVisibility.public.name,
    );

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

    var templates = snapshot.docs
        .map(
          (doc) => WorkoutTemplate.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();

    // Filtra per searchQuery se presente (client-side)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      templates = templates
          .where(
            (t) =>
                t.name.toLowerCase().contains(lowerQuery) ||
                (t.description?.toLowerCase().contains(lowerQuery) ?? false) ||
                t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)),
          )
          .toList();
    }

    return templates;
  }

  /// Download/Copia template pubblico
  ///
  /// [maxPrivateTemplates] - Max private templates (from tierEntitlementsProvider)
  /// [maxPublicTemplates] - Max public templates (from tierEntitlementsProvider)
  Future<void> downloadTemplate(
    String templateId, {
    required int maxPrivateTemplates,
    required int maxPublicTemplates,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Ottieni il template
    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) throw Exception('Template not found');

    final template = WorkoutTemplate.fromJson(
      templateDoc.data() as Map<String, dynamic>,
    );

    // Crea una copia privata con fork attribution
    final userCopy = template.copyWith(
      id: '', // Verrà generato nuovo ID
      userId: userId,
      visibility: TemplateVisibility.private,
      name: template.name, // Senza "(Copy)" — l'utente personalizza
      createdAt: DateTime.now(),
      downloadCount: 0,
      likeCount: 0,
      reviewCount: 0,
      averageRating: 0.0,
      isAnonymous: false,
      // Fork attribution
      forkedFromTemplateId: template.id,
      originalAuthorName: template.authorName ?? 'Sconosciuto',
    );

    await createTemplate(
      userCopy,
      maxPrivateTemplates: maxPrivateTemplates,
      maxPublicTemplates: maxPublicTemplates,
    );

    // Incrementa download count del template originale
    await _templatesCollection.doc(templateId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  /// Aggiungi review
  Future<void> addReview(TemplateReview review) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Controlla se l'utente ha già recensito
    final existing = await _reviewsCollection
        .where('templateId', isEqualTo: review.templateId)
        .where('userId', isEqualTo: userId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already reviewed this template');
    }

    final doc = _reviewsCollection.doc();
    final newReview = review.copyWith(
      id: doc.id,
      userId: userId,
      userName: _auth.currentUser?.displayName ?? 'Anonymous',
      userPhotoUrl: _auth.currentUser?.photoURL,
      createdAt: DateTime.now(),
    );

    await doc.set(newReview.toJson());

    // Aggiorna statistiche template
    await _updateTemplateRating(review.templateId);
  }

  /// Aggiungi commento
  Future<void> addComment(TemplateComment comment) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = _commentsCollection.doc();
    final newComment = comment.copyWith(
      id: doc.id,
      userId: userId,
      userName: _auth.currentUser?.displayName ?? 'Anonymous',
      userPhotoUrl: _auth.currentUser?.photoURL,
      createdAt: DateTime.now(),
    );

    await doc.set(newComment.toJson());
  }

  /// Like/Unlike template
  Future<void> toggleTemplateLike(String templateId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final templateRef = _templatesCollection.doc(templateId);

    await _firestore.runTransaction((transaction) async {
      final templateDoc = await transaction.get(templateRef);
      if (!templateDoc.exists) throw Exception('Template not found');

      final data = templateDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        transaction.update(templateRef, {
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(userId);
        transaction.update(templateRef, {
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(1),
        });
      }
    });
  }

  // Helper methods

  /// Check user template quota
  ///
  /// Uses consolidated limits from tierEntitlementsProvider (passed by caller)
  /// Pattern: Takes MAX of UserTier (XP) + AccountTier (Premium)
  Future<void> _checkUserQuota(
    String userId,
    TemplateVisibility visibility, {
    required int maxPrivate,
    required int maxPublic,
  }) async {
    final userTemplates = await _templatesCollection
        .where('userId', isEqualTo: userId)
        .where('visibility', isEqualTo: visibility.name)
        .get();

    final count = userTemplates.docs.length;

    // ✅ FIXED: Use consolidated limits (UserTier + AccountTier)
    // Limits passed from caller with tierEntitlementsProvider access
    final limit = visibility == TemplateVisibility.private
        ? maxPrivate
        : maxPublic;

    if (count >= limit) {
      throw Exception(
        'Template limit reached: $count/$limit ${visibility.name} templates. '
        'Delete existing templates or upgrade tier for more slots.',
      );
    }
  }

  Future<void> _updateTemplateRating(String templateId) async {
    final reviews = await _reviewsCollection
        .where('templateId', isEqualTo: templateId)
        .get();

    if (reviews.docs.isEmpty) return;

    double totalRating = 0;
    for (var doc in reviews.docs) {
      final review = TemplateReview.fromJson(
        doc.data() as Map<String, dynamic>,
      );
      totalRating += review.rating;
    }

    final averageRating = totalRating / reviews.docs.length;

    await _templatesCollection.doc(templateId).update({
      'reviewCount': reviews.docs.length,
      'averageRating': averageRating,
    });
  }

  /// Replace an exercise in multiple templates
  /// CRITICAL FIX: Uses batch write for atomic updates
  Future<void> replaceExerciseInTemplates({
    required List<String> templateIds,
    required String oldExerciseName,
    required String newExerciseName,
    String weightOption = 'keep', // 'keep', 'reset', 'manual'
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // CRITICAL FIX: Use batch write for atomic updates
    final batch = _firestore.batch();
    int updatedCount = 0;

    // First, fetch and validate all templates
    for (final templateId in templateIds) {
      final templateDoc = await _templatesCollection.doc(templateId).get();
      if (!templateDoc.exists) continue;

      final template = WorkoutTemplate.fromJson(
        templateDoc.data() as Map<String, dynamic>,
      );

      // Verify user owns this template
      if (template.userId != userId) {
        throw Exception('Cannot modify template owned by another user');
      }

      // Find and replace exercise
      final updatedExercises = template.exercises.map((exercise) {
        if (exercise.name.toLowerCase() == oldExerciseName.toLowerCase()) {
          // Create new exercise with replacement name
          var newExercise = exercise.copyWith(name: newExerciseName);

          // Handle weight based on option
          if (weightOption == 'reset') {
            // Reset all sets to have no weight
            final resetSets = newExercise.sets
                .map((set) => set.copyWith(weight: 0.0))
                .toList();
            newExercise = newExercise.copyWith(sets: resetSets);
          } else if (weightOption == 'manual') {
            // Clear weight for manual input later
            final manualSets = newExercise.sets
                .map((set) => set.copyWith(weight: null))
                .toList();
            newExercise = newExercise.copyWith(sets: manualSets);
          }
          // 'keep' option: keep current weights as-is

          return newExercise;
        }
        return exercise;
      }).toList();

      // Update template with new exercises
      final updatedTemplate = template.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );

      // Add to batch
      batch.update(
        _templatesCollection.doc(templateId),
        updatedTemplate.toJson(),
      );
      updatedCount++;
    }

    // CRITICAL FIX: Commit all updates atomically
    if (updatedCount > 0) {
      await batch.commit();
    }
  }
}

// Provider
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});
