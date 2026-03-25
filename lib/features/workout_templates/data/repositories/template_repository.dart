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
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

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
  /// [maxLibraryTemplates] - Max editable templates allowed in Library
  Future<String> createTemplate(
    WorkoutTemplate template, {
    required int maxLibraryTemplates,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    if (template.visibility == TemplateVisibility.private) {
      // Note: Quota is enforced server-side by the Cloud Function.
      // We keep a lightweight client-side Library check for faster UX feedback.
      await _checkUserQuota(userId, maxLibrary: maxLibraryTemplates);
    }

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
      throw Exception(
        result.error ?? 'Failed to create template via Cloud Function',
      );
    }

    if (kDebugMode) {
      debugPrint(
        '✅ [TemplateRepository] Template created: ${result.templateId} '
        '(library: ${result.quota.libraryUsed}/${result.quota.libraryMax})',
      );
    }

    // Update template with additional fields via direct UPDATE (allowed by rules)
    // This adds fields that the Cloud Function doesn't set
    if (result.templateId.isNotEmpty) {
      try {
        await _templatesCollection.doc(result.templateId).update({
          'authorName': authorName,
          'authorPhotoUrl': template.isAnonymous
              ? null
              : _auth.currentUser?.photoURL,
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

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return WorkoutTemplate.fromJson(_normalizeFirestoreData(data));
    }).toList();
  }

  /// Converte i Timestamp di Firestore in stringhe ISO 8601 per il parser JSON
  Map<String, dynamic> _normalizeFirestoreData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    for (final key in ['createdAt', 'updatedAt']) {
      final value = result[key];
      if (value is Timestamp) {
        result[key] = value.toDate().toIso8601String();
      }
    }
    return result;
  }

  // Helper methods

  /// Check user template quota
  ///
  /// Uses consolidated Library limits from tierEntitlementsProvider.
  Future<void> _checkUserQuota(String userId, {required int maxLibrary}) async {
    final userTemplates = await _templatesCollection
        .where('userId', isEqualTo: userId)
        .where('visibility', isEqualTo: TemplateVisibility.private.name)
        .get();

    final count = userTemplates.docs.length;

    if (count >= maxLibrary) {
      throw Exception(
        'Library limit reached: $count/$maxLibrary editable templates. '
        'Delete existing Library templates or upgrade tier for more slots.',
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

  /// Add an exercise to a user template.
  ///
  /// Throws if:
  /// - user is not authenticated
  /// - template does not exist
  /// - template belongs to another user
  /// - exercise already exists and [allowDuplicate] is false
  Future<CommunityWorkoutTemplate> addExerciseToTemplate({
    required String templateId,
    required Exercise exercise,
    bool allowDuplicate = false,
    int? insertAt,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) {
      throw Exception('Template not found');
    }

    final templateData = templateDoc.data() as Map<String, dynamic>;
    final ownerId = templateData['userId']?.toString();
    if (ownerId != null && ownerId.isNotEmpty && ownerId != userId) {
      throw Exception('Cannot modify template owned by another user');
    }

    final template = CommunityWorkoutTemplate.fromJson(
      _normalizeFirestoreData(templateData),
    );

    final normalizedNewName = exercise.name.trim().toLowerCase();
    final alreadyExists = template.exercises.any(
      (existing) => existing.name.trim().toLowerCase() == normalizedNewName,
    );

    if (alreadyExists && !allowDuplicate) {
      throw Exception('Exercise "${exercise.name}" already exists in template');
    }

    final updatedExercises = [...template.exercises];
    var safeInsertAt = insertAt ?? updatedExercises.length;
    if (safeInsertAt < 0) safeInsertAt = 0;
    if (safeInsertAt > updatedExercises.length) {
      safeInsertAt = updatedExercises.length;
    }
    updatedExercises.insert(safeInsertAt, exercise);

    final now = DateTime.now();
    await _templatesCollection.doc(templateId).update({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
      'updatedAt': now.toIso8601String(),
    });

    return template.copyWith(exercises: updatedExercises, updatedAt: now);
  }

  /// Remove an exercise from a user template by name.
  ///
  /// If [removeAllMatches] is false, removes only the first match.
  Future<CommunityWorkoutTemplate> removeExerciseFromTemplate({
    required String templateId,
    required String exerciseName,
    bool removeAllMatches = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) throw Exception('Template not found');

    final templateData = templateDoc.data() as Map<String, dynamic>;
    final ownerId = templateData['userId']?.toString();
    if (ownerId != null && ownerId.isNotEmpty && ownerId != userId) {
      throw Exception('Cannot modify template owned by another user');
    }

    final template = CommunityWorkoutTemplate.fromJson(
      _normalizeFirestoreData(templateData),
    );

    final normalizedTarget = exerciseName.trim().toLowerCase();
    final indexed = template.exercises.asMap().entries.toList();
    final exactMatches = indexed
        .where(
          (entry) => entry.value.name.trim().toLowerCase() == normalizedTarget,
        )
        .toList();
    final containsMatches = exactMatches.isNotEmpty
        ? exactMatches
        : indexed
              .where(
                (entry) => entry.value.name.trim().toLowerCase().contains(
                  normalizedTarget,
                ),
              )
              .toList();

    if (containsMatches.isEmpty) {
      throw Exception('Exercise "$exerciseName" not found in template');
    }

    final updatedExercises = <Exercise>[];
    final indexesToRemove = removeAllMatches
        ? containsMatches.map((e) => e.key).toSet()
        : {containsMatches.first.key};

    for (final entry in indexed) {
      if (!indexesToRemove.contains(entry.key)) {
        updatedExercises.add(entry.value);
      }
    }

    final now = DateTime.now();
    await _templatesCollection.doc(templateId).update({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
      'updatedAt': now.toIso8601String(),
    });

    return template.copyWith(exercises: updatedExercises, updatedAt: now);
  }

  /// Replace an existing exercise inside a user template.
  ///
  /// If [replaceAllMatches] is false, replaces only the first match.
  Future<CommunityWorkoutTemplate> replaceExerciseInTemplate({
    required String templateId,
    required String oldExerciseName,
    required Exercise newExercise,
    bool replaceAllMatches = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) throw Exception('Template not found');

    final templateData = templateDoc.data() as Map<String, dynamic>;
    final ownerId = templateData['userId']?.toString();
    if (ownerId != null && ownerId.isNotEmpty && ownerId != userId) {
      throw Exception('Cannot modify template owned by another user');
    }

    final template = CommunityWorkoutTemplate.fromJson(
      _normalizeFirestoreData(templateData),
    );

    final normalizedTarget = oldExerciseName.trim().toLowerCase();
    final indexed = template.exercises.asMap().entries.toList();
    final exactMatches = indexed
        .where(
          (entry) => entry.value.name.trim().toLowerCase() == normalizedTarget,
        )
        .toList();
    final matches = exactMatches.isNotEmpty
        ? exactMatches
        : indexed
              .where(
                (entry) => entry.value.name.trim().toLowerCase().contains(
                  normalizedTarget,
                ),
              )
              .toList();

    if (matches.isEmpty) {
      throw Exception('Exercise "$oldExerciseName" not found in template');
    }

    final indexesToReplace = replaceAllMatches
        ? matches.map((e) => e.key).toSet()
        : {matches.first.key};

    final updatedExercises = <Exercise>[];
    for (final entry in indexed) {
      if (indexesToReplace.contains(entry.key)) {
        updatedExercises.add(newExercise);
      } else {
        updatedExercises.add(entry.value);
      }
    }

    final now = DateTime.now();
    await _templatesCollection.doc(templateId).update({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
      'updatedAt': now.toIso8601String(),
    });

    return template.copyWith(exercises: updatedExercises, updatedAt: now);
  }

  /// Update rest time for one exercise (or all exercises) inside a template.
  ///
  /// If [applyToAllExercises] is true, updates every exercise in the template.
  /// If [updateAllMatches] is false, updates only the first matching exercise.
  Future<CommunityWorkoutTemplate> updateExerciseRestTimeInTemplate({
    required String templateId,
    String? exerciseName,
    required int restSeconds,
    bool updateAllMatches = false,
    bool applyToAllExercises = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) throw Exception('Template not found');

    final templateData = templateDoc.data() as Map<String, dynamic>;
    final ownerId = templateData['userId']?.toString();
    if (ownerId != null && ownerId.isNotEmpty && ownerId != userId) {
      throw Exception('Cannot modify template owned by another user');
    }

    final template = CommunityWorkoutTemplate.fromJson(
      _normalizeFirestoreData(templateData),
    );

    final safeRestSeconds = restSeconds.clamp(20, 300);
    final indexed = template.exercises.asMap().entries.toList();
    late final Set<int> indexesToUpdate;

    if (applyToAllExercises) {
      indexesToUpdate = indexed.map((entry) => entry.key).toSet();
    } else {
      final target = exerciseName?.trim();
      if (target == null || target.isEmpty) {
        throw Exception(
          'Exercise name is required when applyToAllExercises is false',
        );
      }

      final normalizedTarget = target.toLowerCase();
      final exactMatches = indexed
          .where(
            (entry) =>
                entry.value.name.trim().toLowerCase() == normalizedTarget,
          )
          .toList();
      final matches = exactMatches.isNotEmpty
          ? exactMatches
          : indexed
                .where(
                  (entry) => entry.value.name.trim().toLowerCase().contains(
                    normalizedTarget,
                  ),
                )
                .toList();

      if (matches.isEmpty) {
        throw Exception('Exercise "$target" not found in template');
      }

      indexesToUpdate = updateAllMatches
          ? matches.map((entry) => entry.key).toSet()
          : {matches.first.key};
    }

    final updatedExercises = <Exercise>[];
    for (final entry in indexed) {
      if (!indexesToUpdate.contains(entry.key)) {
        updatedExercises.add(entry.value);
        continue;
      }

      final updatedSets = entry.value.sets
          .map((set) => set.copyWith(restTime: safeRestSeconds))
          .toList();
      updatedExercises.add(
        entry.value.copyWith(restTime: safeRestSeconds, sets: updatedSets),
      );
    }

    final now = DateTime.now();
    await _templatesCollection.doc(templateId).update({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
      'updatedAt': now.toIso8601String(),
    });

    return template.copyWith(exercises: updatedExercises, updatedAt: now);
  }

  /// Update sets and reps configuration for one exercise (or all exercises)
  /// inside a template.
  ///
  /// If [applyToAllExercises] is true, updates every exercise in the template.
  /// If [updateAllMatches] is false, updates only the first matching exercise.
  /// If [sets]/[reps]/[minReps]/[maxReps] are null, keeps existing values.
  Future<CommunityWorkoutTemplate> updateExerciseSetRepsInTemplate({
    required String templateId,
    String? exerciseName,
    int? sets,
    int? reps,
    int? minReps,
    int? maxReps,
    bool updateAllMatches = false,
    bool applyToAllExercises = false,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final templateDoc = await _templatesCollection.doc(templateId).get();
    if (!templateDoc.exists) throw Exception('Template not found');

    final templateData = templateDoc.data() as Map<String, dynamic>;
    final ownerId = templateData['userId']?.toString();
    if (ownerId != null && ownerId.isNotEmpty && ownerId != userId) {
      throw Exception('Cannot modify template owned by another user');
    }

    final template = CommunityWorkoutTemplate.fromJson(
      _normalizeFirestoreData(templateData),
    );

    final safeSets = sets?.clamp(1, 8);
    final safeReps = reps?.clamp(1, 50);
    var safeMinReps = minReps?.clamp(1, 50);
    var safeMaxReps = maxReps?.clamp(1, 50);
    if (safeMinReps != null &&
        safeMaxReps != null &&
        safeMinReps > safeMaxReps) {
      final tmp = safeMinReps;
      safeMinReps = safeMaxReps;
      safeMaxReps = tmp;
    }

    final indexed = template.exercises.asMap().entries.toList();
    late final Set<int> indexesToUpdate;

    if (applyToAllExercises) {
      indexesToUpdate = indexed.map((entry) => entry.key).toSet();
    } else {
      final target = exerciseName?.trim();
      if (target == null || target.isEmpty) {
        throw Exception(
          'Exercise name is required when applyToAllExercises is false',
        );
      }

      final normalizedTarget = target.toLowerCase();
      final exactMatches = indexed
          .where(
            (entry) =>
                entry.value.name.trim().toLowerCase() == normalizedTarget,
          )
          .toList();
      final matches = exactMatches.isNotEmpty
          ? exactMatches
          : indexed
                .where(
                  (entry) => entry.value.name.trim().toLowerCase().contains(
                    normalizedTarget,
                  ),
                )
                .toList();

      if (matches.isEmpty) {
        throw Exception('Exercise "$target" not found in template');
      }

      indexesToUpdate = updateAllMatches
          ? matches.map((entry) => entry.key).toSet()
          : {matches.first.key};
    }

    ExerciseSet buildSetFromBase({
      required ExerciseSet? base,
      required int setNumber,
      required int fallbackReps,
    }) {
      final useRange = safeMinReps != null && safeMaxReps != null;
      final resolvedReps = useRange
          ? null
          : (safeReps ?? base?.reps ?? fallbackReps);
      final resolvedMin = useRange
          ? safeMinReps
          : (safeReps != null ? null : base?.minReps);
      final resolvedMax = useRange
          ? safeMaxReps
          : (safeReps != null ? null : base?.maxReps);

      return ExerciseSet(
        id: base?.id,
        setNumber: setNumber,
        weight: base?.weight,
        reps: resolvedReps,
        minReps: resolvedMin,
        maxReps: resolvedMax,
        seconds: base?.seconds,
        distance: base?.distance,
        notes: base?.notes,
        isWarmup: base?.isWarmup ?? false,
        restTime: base?.restTime,
      );
    }

    final updatedExercises = <Exercise>[];
    for (final entry in indexed) {
      if (!indexesToUpdate.contains(entry.key)) {
        updatedExercises.add(entry.value);
        continue;
      }

      final existingSets = entry.value.sets;
      final currentSetCount = existingSets.isNotEmpty ? existingSets.length : 3;
      final targetSetCount = safeSets ?? currentSetCount;
      final sourceForExtra = existingSets.isNotEmpty ? existingSets.last : null;
      final fallbackReps = existingSets.isNotEmpty
          ? (existingSets.first.reps ??
                ((existingSets.first.minReps != null &&
                        existingSets.first.maxReps != null)
                    ? ((existingSets.first.minReps! +
                              existingSets.first.maxReps!) ~/
                          2)
                    : 10))
          : 10;

      final updatedSets = List.generate(targetSetCount, (index) {
        final baseSet = index < existingSets.length
            ? existingSets[index]
            : sourceForExtra;
        return buildSetFromBase(
          base: baseSet,
          setNumber: index + 1,
          fallbackReps: fallbackReps,
        );
      });

      updatedExercises.add(entry.value.copyWith(sets: updatedSets));
    }

    final now = DateTime.now();
    await _templatesCollection.doc(templateId).update({
      'exercises': updatedExercises.map((e) => e.toJson()).toList(),
      'updatedAt': now.toIso8601String(),
    });

    return template.copyWith(exercises: updatedExercises, updatedAt: now);
  }
}

// Provider
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});
