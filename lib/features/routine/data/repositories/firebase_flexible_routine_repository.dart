/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FIREBASE FLEXIBLE ROUTINE REPOSITORY - v2.0 Simplified Implementation
///
/// This repository handles:
/// - Firebase Firestore operations
/// - Real-time sync with Stream
/// - Active routine management
///
/// ⚠️ **v2.0 SIMPLIFIED**: Removed v1.0 complex features:
/// - Day-level operations (completeDay, skipDay, recoverDay)
/// - Archive/Complete states
/// - Complex statistics queries
///
/// Dependencies:
/// - Cloud Firestore
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';

/// Firebase implementation of FlexibleRoutineRepository (v2.0 simplified)
class FirebaseFlexibleRoutineRepository implements FlexibleRoutineRepository {
  FirebaseFlexibleRoutineRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Collection name in Firestore
  static const String _collectionName = 'routines';

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  // === CRUD OPERATIONS ===

  @override
  Future<void> createRoutine(FlexibleRoutine routine) async {
    try {
      await _collection.doc(routine.id).set(routine.toJson());
      if (kDebugMode) {
        debugPrint('✅ [FirebaseRoutineRepo] Created routine: ${routine.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to create routine: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateRoutine(FlexibleRoutine routine) async {
    try {
      await _collection.doc(routine.id).update(routine.toJson());
      if (kDebugMode) {
        debugPrint('✅ [FirebaseRoutineRepo] Updated routine: ${routine.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to update routine: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    try {
      await _collection.doc(routineId).delete();
      if (kDebugMode) {
        debugPrint('✅ [FirebaseRoutineRepo] Deleted routine: $routineId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to delete routine: $e');
      }
      rethrow;
    }
  }

  @override
  Future<FlexibleRoutine?> getRoutineById(String routineId) async {
    try {
      final doc = await _collection.doc(routineId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return FlexibleRoutine.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to get routine: $e');
      }
      rethrow;
    }
  }

  // === QUERY OPERATIONS ===

  @override
  Future<List<FlexibleRoutine>> getUserRoutines(String userId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FlexibleRoutine.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to get user routines: $e');
      }
      rethrow;
    }
  }

  // === ACTIVATION MANAGEMENT ===

  @override
  Future<void> activateRoutine(String userId, String routineId) async {
    try {
      // Step 1: Deactivate all other routines
      await deactivateAllRoutines(userId);

      // Step 2: Activate this routine
      await _collection.doc(routineId).update({'isActive': true});

      if (kDebugMode) {
        debugPrint('✅ [FirebaseRoutineRepo] Activated routine: $routineId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to activate routine: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deactivateRoutine(String routineId) async {
    try {
      await _collection.doc(routineId).update({'isActive': false});
      if (kDebugMode) {
        debugPrint('✅ [FirebaseRoutineRepo] Deactivated routine: $routineId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to deactivate routine: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deactivateAllRoutines(String userId) async {
    try {
      final routines = await getUserRoutines(userId);
      final batch = _firestore.batch();

      for (final routine in routines) {
        if (routine.isActive) {
          batch.update(
            _collection.doc(routine.id),
            {'isActive': false},
          );
        }
      }

      await batch.commit();
      if (kDebugMode) {
        debugPrint('✅ [FirebaseRoutineRepo] Deactivated all routines for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to deactivate all routines: $e');
      }
      rethrow;
    }
  }

  // === HELPER METHODS ===

  @override
  Future<FlexibleRoutine?> getActiveRoutine(String userId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      return FlexibleRoutine.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to get active routine: $e');
      }
      rethrow;
    }
  }

  @override
  Future<bool> hasActiveRoutines(String userId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to check active routines: $e');
      }
      return false;
    }
  }

  @override
  Future<RoutineStatistics?> getRoutineStatistics(String routineId) async {
    try {
      final routine = await getRoutineById(routineId);
      if (routine == null) {
        return null;
      }
      return RoutineStatistics.fromRoutine(routine);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FirebaseRoutineRepo] Failed to get routine statistics: $e');
      }
      return null;
    }
  }

  // === STREAM OPERATIONS (Real-time) ===

  @override
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return FlexibleRoutine.fromJson(snapshot.docs.first.data());
    });
  }

  @override
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FlexibleRoutine.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Stream<FlexibleRoutine?> watchRoutineById(String routineId) {
    return _collection
        .doc(routineId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return FlexibleRoutine.fromJson(snapshot.data()!);
    });
  }
}
