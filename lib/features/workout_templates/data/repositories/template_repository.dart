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
