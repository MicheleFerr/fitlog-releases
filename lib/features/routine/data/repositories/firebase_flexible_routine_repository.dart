/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FIREBASE FLEXIBLE ROUTINE REPOSITORY - Firebase implementation
///
/// This repository handles:
/// - Firebase Firestore operations
/// - Real-time sync with Stream
/// - Offline caching
/// - Batch operations
/// - Error handling
///
/// Dependencies:
/// - Cloud Firestore
/// - RxDart for stream operations
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';

/// Firebase implementation of FlexibleRoutineRepository
class FirebaseFlexibleRoutineRepository implements FlexibleRoutineRepository {

  FirebaseFlexibleRoutineRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Collection name in Firestore
  static const String _collectionName = 'flexibleRoutines';

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  // === CRUD OPERATIONS ===

  @override
  Future<FlexibleRoutine?> getRoutineById(String routineId) async {
    try {
      final doc = await _collection.doc(routineId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return FlexibleRoutine.fromJson(data);
    } catch (e) {
      throw _handleError(e, 'getRoutineById');
    }
  }

  @override
  Future<List<FlexibleRoutine>> getUserRoutines(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FlexibleRoutine.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getUserRoutines');
    }
  }

  @override
  Future<List<FlexibleRoutine>> getActiveRoutines(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FlexibleRoutine.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getActiveRoutines');
    }
  }

  @override
  Future<List<FlexibleRoutine>> getArchivedRoutines(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FlexibleRoutine.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getArchivedRoutines');
    }
  }

  @override
  Future<void> createRoutine(FlexibleRoutine routine) async {
    try {
      await _collection.doc(routine.id).set(routine.toJson());
    } catch (e) {
      throw _handleError(e, 'createRoutine');
    }
  }

  @override
  Future<void> updateRoutine(FlexibleRoutine routine) async {
    try {
      final updatedRoutine = routine.copyWith(
        updatedAt: DateTime.now(),
        isSyncPending: false,
      );

      await _collection.doc(routine.id).update(updatedRoutine.toJson());
    } catch (e) {
      throw _handleError(e, 'updateRoutine');
    }
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    try {
      await _collection.doc(routineId).delete();
    } catch (e) {
      throw _handleError(e, 'deleteRoutine');
    }
  }

  // === ACTIVE ROUTINE MANAGEMENT ===

  @override
  Future<FlexibleRoutine?> getActiveRoutine(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return FlexibleRoutine.fromJson(query.docs.first.data());
    } catch (e) {
      throw _handleError(e, 'getActiveRoutine');
    }
  }

  @override
  Future<void> activateRoutine(String routineId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Deactivate all other routines
      final existingActive = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in existingActive.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      // Activate the target routine
      batch.update(_collection.doc(routineId), {
        'isActive': true,
        'isArchived': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await batch.commit();
    } catch (e) {
      throw _handleError(e, 'activateRoutine');
    }
  }

  @override
  Future<void> deactivateCurrentRoutine(String userId) async {
    try {
      final activeRoutine = await getActiveRoutine(userId);
      if (activeRoutine == null) return;

      await _collection.doc(activeRoutine.id).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw _handleError(e, 'deactivateCurrentRoutine');
    }
  }

  @override
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId) {
    try {
      return _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return FlexibleRoutine.fromJson(snapshot.docs.first.data());
      });
    } catch (e) {
      throw _handleError(e, 'watchActiveRoutine');
    }
  }

  @override
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId) {
    try {
      return _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => FlexibleRoutine.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw _handleError(e, 'watchUserRoutines');
    }
  }

  @override
  Stream<FlexibleRoutine?> watchRoutineById(String routineId) {
    try {
      return _collection.doc(routineId).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        final data = snapshot.data();
        if (data == null) return null;
        return FlexibleRoutine.fromJson(data);
      });
    } catch (e) {
      throw _handleError(e, 'watchRoutineById');
    }
  }

  // === ROUTINE STATE OPERATIONS ===

  @override
  Future<void> archiveRoutine(String routineId) async {
    try {
      await _collection.doc(routineId).update({
        'isArchived': true,
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw _handleError(e, 'archiveRoutine');
    }
  }

  @override
  Future<void> unarchiveRoutine(String routineId) async {
    try {
      await _collection.doc(routineId).update({
        'isArchived': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw _handleError(e, 'unarchiveRoutine');
    }
  }

  @override
  Future<void> completeRoutine(String routineId) async {
    try {
      await _collection.doc(routineId).update({
        'isCompleted': true,
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw _handleError(e, 'completeRoutine');
    }
  }

  // === DAY OPERATIONS ===

  @override
  Future<void> completeDayWorkout({
    required String routineId,
    required DateTime date,
    required String workoutId,
  }) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found: $routineId');
      }

      final updatedRoutine = routine.completeDay(date, workoutId);
      await updateRoutine(updatedRoutine);
    } catch (e) {
      throw _handleError(e, 'completeDayWorkout');
    }
  }

  @override
  Future<void> skipDay({
    required String routineId,
    required DateTime date,
    String? reason,
    String? notes,
  }) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found: $routineId');
      }

      final updatedRoutine = routine.skipDay(date, reason);
      await updateRoutine(updatedRoutine);
    } catch (e) {
      throw _handleError(e, 'skipDay');
    }
  }

  @override
  Future<void> recoverDay({
    required String routineId,
    required DateTime originalDate,
    required DateTime recoveryDate,
    String? notes,
  }) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found: $routineId');
      }

      final updatedRoutine = routine.recoverDay(originalDate, recoveryDate);
      await updateRoutine(updatedRoutine);
    } catch (e) {
      throw _handleError(e, 'recoverDay');
    }
  }

  // === QUERY OPERATIONS ===

  @override
  Future<List<FlexibleRoutine>> getRoutinesInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get all user routines and filter by date range
      final allRoutines = await getUserRoutines(userId);

      return allRoutines.where((routine) {
        return routine.startDate.isBefore(endDate.add(const Duration(days: 1))) &&
            routine.endDate.isAfter(startDate.subtract(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw _handleError(e, 'getRoutinesInDateRange');
    }
  }

  @override
  Future<List<FlexibleRoutine>> getRoutinesByType({
    required String userId,
    required RoutineType type,
  }) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => FlexibleRoutine.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw _handleError(e, 'getRoutinesByType');
    }
  }

  @override
  Future<bool> hasActiveRoutines(String userId) async {
    try {
      final query = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw _handleError(e, 'hasActiveRoutines');
    }
  }

  @override
  Future<RoutineStatistics> getRoutineStatistics(String routineId) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) {
        throw Exception('Routine not found: $routineId');
      }

      return RoutineStatistics.fromRoutine(routine);
    } catch (e) {
      throw _handleError(e, 'getRoutineStatistics');
    }
  }

  // === SYNC OPERATIONS ===

  @override
  Future<void> syncPendingChanges(String userId) async {
    try {
      // Get all routines with pending sync
      final allRoutines = await getUserRoutines(userId);
      final pendingRoutines = allRoutines.where((r) => r.isSyncPending).toList();

      if (pendingRoutines.isEmpty) return;

      // Batch update all pending routines
      await batchUpdateRoutines(pendingRoutines);
    } catch (e) {
      throw _handleError(e, 'syncPendingChanges');
    }
  }

  @override
  Future<void> batchUpdateRoutines(List<FlexibleRoutine> routines) async {
    try {
      final batch = _firestore.batch();

      for (final routine in routines) {
        final updatedRoutine = routine.copyWith(
          updatedAt: DateTime.now(),
          isSyncPending: false,
        );

        batch.update(
          _collection.doc(routine.id),
          updatedRoutine.toJson(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw _handleError(e, 'batchUpdateRoutines');
    }
  }

  // === ERROR HANDLING ===

  /// Handle Firebase errors and convert to meaningful exceptions
  Exception _handleError(Object error, String operation) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception(
              'Permission denied: You do not have access to this routine.');
        case 'not-found':
          return Exception('Routine not found.');
        case 'already-exists':
          return Exception('A routine with this ID already exists.');
        case 'unavailable':
          return Exception(
              'Firestore service is temporarily unavailable. Please try again.');
        default:
          return Exception('Firebase error in $operation: ${error.message}');
      }
    }

    return Exception('Error in $operation: ${error.toString()}');
  }
}
