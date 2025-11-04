/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data
/// 🎯 Feature: routine_pause
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FIREBASE ROUTINE PAUSE REPOSITORY - Firestore implementation
///
/// This repository handles:
/// - Firebase Firestore operations for routine pauses
/// - Real-time sync with Stream
/// - Batch operations for bulk resume
/// - Auto-generated IDs
/// - Error handling
///
/// Dependencies:
/// - Cloud Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pause.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/routine_pause_repository.dart';
import 'package:uuid/uuid.dart';

/// Firebase implementation of RoutinePauseRepository
class FirebaseRoutinePauseRepository implements RoutinePauseRepository {
  FirebaseRoutinePauseRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  /// Collection name in Firestore
  static const String _collectionName = 'routine_pauses';

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  // === CRUD OPERATIONS ===

  @override
  Future<RoutinePause?> getPauseById(String pauseId) async {
    try {
      final doc = await _collection.doc(pauseId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return RoutinePause.fromJson(data);
    } catch (e) {
      throw _handleError(e, 'getPauseById');
    }
  }

  @override
  Future<List<RoutinePause>> getActivePausesForRoutine(
    String routineId,
  ) async {
    try {
      final query = await _collection
          .where('routineId', isEqualTo: routineId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => RoutinePause.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getActivePausesForRoutine');
    }
  }

  @override
  Future<List<RoutinePause>> getActivePausesForUser(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => RoutinePause.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getActivePausesForUser');
    }
  }

  @override
  Future<List<RoutinePause>> getAllPausesForRoutine(String routineId) async {
    try {
      final query = await _collection
          .where('routineId', isEqualTo: routineId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => RoutinePause.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getAllPausesForRoutine');
    }
  }

  @override
  Future<List<RoutinePause>> getExpiredPauses(String userId) async {
    try {
      // Get all active pauses for user
      final activePauses = await getActivePausesForUser(userId);

      // Filter for expired ones (endDate < today)
      final now = DateTime.now();
      return activePauses
          .where((pause) => pause.endDate.isBefore(now))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getExpiredPauses');
    }
  }

  @override
  Future<RoutinePause> createPause(RoutinePause pause) async {
    try {
      // Generate ID if not provided
      final pauseId = pause.id.isEmpty ? _uuid.v4() : pause.id;
      final pauseWithId = pause.copyWith(id: pauseId);

      await _collection.doc(pauseId).set(pauseWithId.toJson());

      return pauseWithId;
    } catch (e) {
      throw _handleError(e, 'createPause');
    }
  }

  @override
  Future<void> updatePause(RoutinePause pause) async {
    try {
      await _collection.doc(pause.id).update(pause.toJson());
    } catch (e) {
      throw _handleError(e, 'updatePause');
    }
  }

  @override
  Future<void> deletePause(String pauseId) async {
    try {
      await _collection.doc(pauseId).delete();
    } catch (e) {
      throw _handleError(e, 'deletePause');
    }
  }

  // === BATCH OPERATIONS ===

  @override
  Future<void> resumePauses(List<RoutinePause> pauses) async {
    if (pauses.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final pause in pauses) {
        final resumedPause = pause.resume();
        batch.update(
          _collection.doc(pause.id),
          resumedPause.toJson(),
        );
      }

      // Firestore batch limit is 500 operations
      if (pauses.length > 500) {
        throw Exception('Cannot batch update more than 500 pauses at once');
      }

      await batch.commit();
    } catch (e) {
      throw _handleError(e, 'resumePauses');
    }
  }

  // === QUERY HELPERS ===

  @override
  Future<bool> isRoutinePaused(String routineId) async {
    try {
      final activePause = await getActivePause(routineId);
      return activePause != null && activePause.isActiveAndValid;
    } catch (e) {
      throw _handleError(e, 'isRoutinePaused');
    }
  }

  @override
  Future<RoutinePause?> getActivePause(String routineId) async {
    try {
      final pauses = await getActivePausesForRoutine(routineId);

      if (pauses.isEmpty) return null;

      // Filter for non-expired pauses
      final validPauses = pauses.where((p) => p.isActiveAndValid).toList();

      if (validPauses.isEmpty) return null;

      // Return the most recent one (should only be one, but handle edge case)
      return validPauses.first;
    } catch (e) {
      throw _handleError(e, 'getActivePause');
    }
  }

  // === STREAMS ===

  @override
  Stream<List<RoutinePause>> watchActivePauses(String userId) {
    try {
      return _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => RoutinePause.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw _handleError(e, 'watchActivePauses');
    }
  }

  @override
  Stream<RoutinePause?> watchRoutinePause(String routineId) {
    try {
      return _collection
          .where('routineId', isEqualTo: routineId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;

        final pause = RoutinePause.fromJson(snapshot.docs.first.data());

        // Only return if not expired
        return pause.isActiveAndValid ? pause : null;
      });
    } catch (e) {
      throw _handleError(e, 'watchRoutinePause');
    }
  }

  // === ERROR HANDLING ===

  /// Handle Firestore errors
  Exception _handleError(Object error, String operation) {
    if (error is FirebaseException) {
      return Exception(
        'Firestore error in $operation: ${error.message}',
      );
    }
    return Exception('Error in $operation: $error');
  }
}
