/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data/repositories
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository implementation
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// FIREBASE ROUTINE REPOSITORY - v2.0
///
/// Firestore implementation of RoutineRepository.
/// Handles real-time streaming, batch operations, and automatic timestamps.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/data/models/routine_model.dart';

/// Firestore implementation of RoutineRepository
///
/// Collection: `routines`
/// Document ID: Auto-generated or user-specified
///
/// Features:
/// - Real-time streams via `watchActiveRoutine` and `watchUserRoutines`
/// - Batch operations for atomic multi-document updates
/// - Automatic `updatedAt` timestamp management
/// - Only one active routine per user enforcement
class FirebaseRoutineRepository implements RoutineRepository {

  FirebaseRoutineRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Collection reference for routines
  static const String _collectionName = 'routines';

  CollectionReference<Map<String, dynamic>> get _routinesCollection =>
      _firestore.collection(_collectionName);

  // ──────────────────────────────────────────────────────────────────────────
  // CREATE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<void> createRoutine(FlexibleRoutine routine) async {
    try {
      // Step 1: Deactivate all existing routines for this user
      await deactivateAllRoutines(routine.userId);

      // Step 2: Create new routine as active
      final model = RoutineModel.fromEntity(routine);
      await _routinesCollection.doc(routine.id).set(model.toJson());
    } on FirebaseException catch (e) {
      throw Exception('Failed to create routine: ${e.message}');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<void> updateRoutine(FlexibleRoutine routine) async {
    try {
      // Update with automatic updatedAt timestamp
      final updatedRoutine = routine.copyWith(updatedAt: DateTime.now());
      final model = RoutineModel.fromEntity(updatedRoutine);

      await _routinesCollection.doc(routine.id).update(model.toJson());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception('Routine not found: ${routine.id}');
      }
      throw Exception('Failed to update routine: ${e.message}');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELETE
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteRoutine(String routineId) async {
    try {
      // Step 1: Get the routine to check if it's active
      final doc = await _routinesCollection.doc(routineId).get();

      if (!doc.exists) {
        throw Exception('Routine not found: $routineId');
      }

      final data = doc.data()!;
      final model = RoutineModel.fromJson(data);
      final routine = model.toEntity();

      // Step 2: Delete the routine
      await _routinesCollection.doc(routineId).delete();

      // Step 3: If deleted routine was active, activate most recent inactive routine
      if (routine.isActive) {
        await _activateMostRecentInactiveRoutine(routine.userId);
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete routine: ${e.message}');
    }
  }

  /// Helper: Activate the most recently created inactive routine
  Future<void> _activateMostRecentInactiveRoutine(String userId) async {
    try {
      // Find most recent inactive routine
      final snapshot = await _routinesCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return; // No inactive routines to activate
      }

      // Activate it
      final routineId = snapshot.docs.first.id;
      await _routinesCollection.doc(routineId).update({
        'isActive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      // Log but don't throw - deletion already succeeded
      if (kDebugMode) {
        debugPrint('Warning: Failed to auto-activate routine: ${e.message}');
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // READ (One-time)
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<FlexibleRoutine?> getActiveRoutine(String userId) async {
    try {
      final snapshot = await _routinesCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data();
      final model = RoutineModel.fromJson(data);
      return model.toEntity();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get active routine: ${e.message}');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WATCH (Real-time Streams)
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId) {
    return _routinesCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data();
      final model = RoutineModel.fromJson(data);
      return model.toEntity();
    });
  }

  @override
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId) {
    return _routinesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final model = RoutineModel.fromJson(data);
        return model.toEntity();
      }).toList();
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BATCH OPERATIONS
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Future<void> deactivateAllRoutines(String userId) async {
    try {
      // Step 1: Get all active routines for this user
      final snapshot = await _routinesCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return; // No active routines to deactivate
      }

      // Step 2: Batch update all to inactive
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'updatedAt': now,
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Failed to deactivate routines: ${e.message}');
    }
  }

  @override
  Future<void> activateRoutine(String routineId) async {
    try {
      // Step 1: Get the routine to activate
      final doc = await _routinesCollection.doc(routineId).get();

      if (!doc.exists) {
        throw Exception('Routine not found: $routineId');
      }

      final data = doc.data()!;
      final model = RoutineModel.fromJson(data);
      final routine = model.toEntity();

      // Step 2: Deactivate all other routines for this user
      await deactivateAllRoutines(routine.userId);

      // Step 3: Activate the target routine
      await _routinesCollection.doc(routineId).update({
        'isActive': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to activate routine: ${e.message}');
    }
  }
}
