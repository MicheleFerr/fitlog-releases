/// Coach Templates Repository
///
/// Handles coach template CRUD operations and assignments to athletes.
/// Uses Firestore `coachTemplates` collection for templates and
/// `users/{athleteId}/assignedTemplates` for assignments.
///
/// **Layer**: Data
/// **Feature**: Coach
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/assigned_template.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:uuid/uuid.dart';

/// Repository for coach templates and assignments
class CoachTemplatesRepository with FirebaseErrorMapperMixin {
  CoachTemplatesRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Collection references
  CollectionReference<Map<String, dynamic>> get _templates =>
      _firestore.collection('coachTemplates');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ============================================================
  // COACH TEMPLATE CRUD
  // ============================================================

  /// Create a new coach template
  Future<String> createTemplate(CoachTemplate template) async {
    final result = await handleFirebaseOperation<String>(
      () async {
        final id = template.id.isEmpty ? const Uuid().v4() : template.id;
        final newTemplate = template.copyWith(
          id: id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
        await _templates.doc(id).set(newTemplate.toJson()).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore createTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Created template: $id');
        }

        return id;
      },
      operationName: 'createTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to create template: ${failure.message}'),
      (value) => value,
    );
  }

  /// Update an existing template
  ///
  /// Changes are automatically synced to athletes via lastSyncedAt check
  Future<void> updateTemplate(CoachTemplate template) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        final updated = template.copyWith(updatedAt: DateTime.now());
        // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
        await _templates.doc(template.id).update(updated.toJson()).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore updateTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Updated template: ${template.id}');
        }
      },
      operationName: 'updateTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to update template: ${failure.message}'),
      (_) {},
    );
  }

  /// Delete a template and remove all assignments
  Future<void> deleteTemplate(String templateId) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        // Get template to find assigned athletes
        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        final doc = await _templates.doc(templateId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore getTemplate timed out'),
        );
        if (!doc.exists) return;

        final template = CoachTemplate.fromJson(doc.data()!);

        // Remove assignments from all athletes
        final batch = _firestore.batch();

        for (final athleteId in template.assignedTo) {
          final assignmentRef = _users
              .doc(athleteId)
              .collection('assignedTemplates')
              .doc(templateId);
          batch.delete(assignmentRef);
        }

        // Delete the template
        batch.delete(_templates.doc(templateId));

        // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
        await batch.commit().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore deleteTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Deleted template: $templateId');
        }
      },
      operationName: 'deleteTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to delete template: ${failure.message}'),
      (_) {},
    );
  }

  /// Archive a template (soft delete)
  Future<void> archiveTemplate(String templateId) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        await _templates.doc(templateId).update({
          'isArchived': true,
          'updatedAt': DateTime.now().toIso8601String(),
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore archiveTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Archived template: $templateId');
        }
      },
      operationName: 'archiveTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to archive template: ${failure.message}'),
      (_) {},
    );
  }

  // ============================================================
  // TEMPLATE QUERIES
  // ============================================================

  /// Get a single template by ID
  Future<CoachTemplate?> getTemplate(String templateId) async {
    final result = await handleFirebaseOperation<CoachTemplate?>(
      () async {
        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        final doc = await _templates.doc(templateId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore getTemplate timed out'),
        );
        if (!doc.exists) return null;

        return CoachTemplate.fromJson(doc.data()!);
      },
      operationName: 'getTemplate',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Error getting template: ${failure.message}');
        }
        return null;
      },
      (value) => value,
    );
  }

  /// Watch all templates for a coach
  Stream<List<CoachTemplate>> watchCoachTemplates(String coachId) {
    return _templates
        .where('coachId', isEqualTo: coachId)
        .where('isArchived', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CoachTemplate.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get all templates for a coach (one-time read)
  Future<List<CoachTemplate>> getCoachTemplates(String coachId) async {
    final result = await handleFirebaseOperation<List<CoachTemplate>>(
      () async {
        // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
        final snapshot = await _templates
            .where('coachId', isEqualTo: coachId)
            .where('isArchived', isEqualTo: false)
            .orderBy('updatedAt', descending: true)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Firestore getCoachTemplates timed out'),
            );

        return snapshot.docs
            .map((doc) => CoachTemplate.fromJson(doc.data()))
            .toList();
      },
      operationName: 'getCoachTemplates',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Error getting coach templates: ${failure.message}');
        }
        return [];
      },
      (value) => value,
    );
  }

  // ============================================================
  // ASSIGNMENT MANAGEMENT
  // ============================================================

  /// Assign template to athletes
  Future<void> assignTemplate({
    required String templateId,
    required List<String> athleteIds,
    required String coachId,
    required String coachName,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        // Get template details for denormalization
        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        final templateDoc = await _templates.doc(templateId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore assignTemplate get timed out'),
        );
        if (!templateDoc.exists) {
          throw Exception('Template not found');
        }

        final template = CoachTemplate.fromJson(templateDoc.data()!);

        // Verify ownership
        if (template.coachId != coachId) {
          throw Exception('Not authorized to assign this template');
        }

        final batch = _firestore.batch();
        final now = DateTime.now();

        // Create assignments for each athlete
        for (final athleteId in athleteIds) {
          final assignedTemplate = AssignedTemplate(
            id: templateId,
            coachTemplateId: templateId,
            coachId: coachId,
            assignedAt: now,
            lastSyncedAt: now,
            templateName: template.name,
            coachName: coachName,
            exerciseCount: template.exercises.length,
            estimatedDuration: template.estimatedDuration,
          );

          final assignmentRef = _users
              .doc(athleteId)
              .collection('assignedTemplates')
              .doc(templateId);

          batch.set(assignmentRef, assignedTemplate.toJson());
        }

        // Update template's assignedTo list
        final updatedAssignedTo = {...template.assignedTo, ...athleteIds}.toList();
        batch.update(_templates.doc(templateId), {
          'assignedTo': updatedAssignedTo,
          'updatedAt': now.toIso8601String(),
        });

        // 🔧 FIX: Added 15s timeout to prevent infinite hanging on poor network
        await batch.commit().timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Firestore assignTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint(
            '[CoachTemplatesRepo] Assigned template $templateId to ${athleteIds.length} athletes',
          );
        }
      },
      operationName: 'assignTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to assign template: ${failure.message}'),
      (_) {},
    );
  }

  /// Remove template assignment from athletes
  Future<void> unassignTemplate({
    required String templateId,
    required List<String> athleteIds,
    required String coachId,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        // Get template to verify ownership
        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        final templateDoc = await _templates.doc(templateId).get().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore unassignTemplate get timed out'),
        );
        if (!templateDoc.exists) return;

        final template = CoachTemplate.fromJson(templateDoc.data()!);

        if (template.coachId != coachId) {
          throw Exception('Not authorized to unassign this template');
        }

        final batch = _firestore.batch();

        // Remove assignments
        for (final athleteId in athleteIds) {
          final assignmentRef = _users
              .doc(athleteId)
              .collection('assignedTemplates')
              .doc(templateId);

          batch.delete(assignmentRef);
        }

        // Update template's assignedTo list
        final updatedAssignedTo = template.assignedTo
            .where((id) => !athleteIds.contains(id))
            .toList();

        batch.update(_templates.doc(templateId), {
          'assignedTo': updatedAssignedTo,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
        await batch.commit().timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore unassignTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint(
            '[CoachTemplatesRepo] Unassigned template $templateId from ${athleteIds.length} athletes',
          );
        }
      },
      operationName: 'unassignTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to unassign template: ${failure.message}'),
      (_) {},
    );
  }

  /// Update assignments - add and remove in one operation
  Future<void> updateAssignments({
    required String templateId,
    required List<String> athleteIds,
    required String coachId,
    required String coachName,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        final template = await getTemplate(templateId);
        if (template == null) {
          throw Exception('Template not found');
        }

        if (template.coachId != coachId) {
          throw Exception('Not authorized to modify this template');
        }

        final currentAssigned = template.assignedTo.toSet();
        final newAssigned = athleteIds.toSet();

        final toAdd = newAssigned.difference(currentAssigned).toList();
        final toRemove = currentAssigned.difference(newAssigned).toList();

        if (toAdd.isNotEmpty) {
          await assignTemplate(
            templateId: templateId,
            athleteIds: toAdd,
            coachId: coachId,
            coachName: coachName,
          );
        }

        if (toRemove.isNotEmpty) {
          await unassignTemplate(
            templateId: templateId,
            athleteIds: toRemove,
            coachId: coachId,
          );
        }

        if (kDebugMode) {
          debugPrint(
            '[CoachTemplatesRepo] Updated assignments: +${toAdd.length}, -${toRemove.length}',
          );
        }
      },
      operationName: 'updateAssignments',
    );

    return result.fold(
      (failure) => throw Exception('Failed to update assignments: ${failure.message}'),
      (_) {},
    );
  }

  // ============================================================
  // ATHLETE SIDE - ASSIGNED TEMPLATES
  // ============================================================

  /// Watch templates assigned to an athlete
  Stream<List<AssignedTemplate>> watchAssignedTemplates(String athleteId) {
    return _users
        .doc(athleteId)
        .collection('assignedTemplates')
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssignedTemplate.fromJson(doc.data()))
          .toList();
    });
  }

  /// Get assigned templates for an athlete (one-time read)
  Future<List<AssignedTemplate>> getAssignedTemplates(String athleteId) async {
    final result = await handleFirebaseOperation<List<AssignedTemplate>>(
      () async {
        // 🔧 FIX: Added 10s timeout to prevent infinite hanging on poor network
        final snapshot = await _users
            .doc(athleteId)
            .collection('assignedTemplates')
            .orderBy('assignedAt', descending: true)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Firestore getAssignedTemplates timed out'),
            );

        return snapshot.docs
            .map((doc) => AssignedTemplate.fromJson(doc.data()))
            .toList();
      },
      operationName: 'getAssignedTemplates',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Error getting assigned templates: ${failure.message}');
        }
        return [];
      },
      (value) => value,
    );
  }

  /// Get full template data for an assigned template
  ///
  /// Returns the coach's current version of the template
  Future<CoachTemplate?> getAssignedTemplateData(String templateId) async {
    return getTemplate(templateId);
  }

  /// Update athlete notes on an assigned template
  Future<void> updateAthleteNotes({
    required String athleteId,
    required String templateId,
    required String? notes,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        await _users
            .doc(athleteId)
            .collection('assignedTemplates')
            .doc(templateId)
            .update({
          'athleteNotes': notes,
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore updateAthleteNotes timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Updated athlete notes for $templateId');
        }
      },
      operationName: 'updateAthleteNotes',
    );

    return result.fold(
      (failure) => throw Exception('Failed to update athlete notes: ${failure.message}'),
      (_) {},
    );
  }

  /// Sync assigned template with coach's version
  Future<void> syncAssignedTemplate({
    required String athleteId,
    required String templateId,
  }) async {
    final result = await handleFirebaseVoidOperation(
      () async {
        final template = await getTemplate(templateId);
        if (template == null) return;

        // 🔧 FIX: Added 5s timeout to prevent infinite hanging on poor network
        await _users
            .doc(athleteId)
            .collection('assignedTemplates')
            .doc(templateId)
            .update({
          'lastSyncedAt': DateTime.now().toIso8601String(),
          'templateName': template.name,
          'exerciseCount': template.exercises.length,
          'estimatedDuration': template.estimatedDuration,
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Firestore syncAssignedTemplate timed out'),
        );

        if (kDebugMode) {
          debugPrint('[CoachTemplatesRepo] Synced template $templateId');
        }
      },
      operationName: 'syncAssignedTemplate',
    );

    return result.fold(
      (failure) => throw Exception('Failed to sync assigned template: ${failure.message}'),
      (_) {},
    );
  }
}
