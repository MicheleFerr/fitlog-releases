/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/services
/// 🎯 Feature: workout
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Helper per leggere workout completati da Firestore con compatibilita
/// schema legacy (`endTime` / `completedAt`) e rispetto del cutoff free.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/premium/data/services/premium_entitlement_store.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

class FirestoreWorkoutHistoryReader {
  FirestoreWorkoutHistoryReader({
    FirebaseFirestore? firestore,
    PremiumEntitlementStore? entitlementStore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _entitlementStore =
           entitlementStore ??
           PremiumEntitlementStore(
             firestore: firestore ?? FirebaseFirestore.instance,
           );

  static const _sortFields = ['endTime', 'completedAt'];
  static const _freeHistoryDays = 90;

  final FirebaseFirestore _firestore;
  final PremiumEntitlementStore _entitlementStore;

  Future<List<WorkoutHistoryDetail>> getRecentCompletedWorkouts({
    required String userId,
    int limit = 50,
    int scanLimit = 100,
    String? templateId,
  }) async {
    final cutoffDate = await _getHistoryCutoffDate(userId);
    final workoutsById = <String, WorkoutHistoryDetail>{};
    final workoutsCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts');

    for (final sortField in _sortFields) {
      try {
        final snapshot = await workoutsCollection
            .orderBy(sortField, descending: true)
            .limit(scanLimit)
            .get();

        for (final doc in snapshot.docs) {
          if (workoutsById.containsKey(doc.id)) continue;

          final data = doc.data();
          if (!_isCompletedWorkout(data)) continue;

          final workout = WorkoutHistoryDetail.fromFirestore(doc);

          if (templateId != null && workout.templateId != templateId) {
            continue;
          }

          if (cutoffDate != null && workout.completedAt.isBefore(cutoffDate)) {
            continue;
          }

          workoutsById[doc.id] = workout;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ [FirestoreWorkoutHistoryReader] Query fallback failed for $sortField: $e',
          );
        }
      }
    }

    final workouts = workoutsById.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (workouts.length <= limit) {
      return workouts;
    }

    return workouts.take(limit).toList();
  }

  bool _isCompletedWorkout(Map<String, dynamic> data) {
    return data['status'] == 'completed' ||
        data['endTime'] != null ||
        data['completedAt'] != null;
  }

  Future<DateTime?> _getHistoryCutoffDate(String userId) async {
    try {
      final accountTier = await _entitlementStore.getEffectiveAccountTier(
        userId,
      );
      if (accountTier != AccountTier.free) {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [FirestoreWorkoutHistoryReader] Failed to load account tier, applying free cutoff: $e',
        );
      }
    }

    return DateTime.now().subtract(const Duration(days: _freeHistoryDays));
  }
}
