import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:flutter/foundation.dart';

/// Provider per recuperare l'ultimo workout completato di un template specifico
final previousWorkoutFromTemplateProvider = FutureProvider.family<Workout?, String>(
  (ref, templateId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Query per trovare ultimo workout completato con questo templateId
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('templateId', isEqualTo: templateId)
          .where('status', isEqualTo: 'completed')
          .orderBy('endTime', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final data = querySnapshot.docs.first.data();
      return Workout.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching previous workout: $e');
      }
      return null;
    }
  },
);

/// Modello per rappresentare i dati di recupero pesi
class WeightRecoveryData {

  WeightRecoveryData({
    this.previousWorkout,
    this.lastSessionDate,
    required this.daysSinceLastSession,
    required this.hasData,
  });

  factory WeightRecoveryData.fromWorkout(Workout? workout) {
    if (workout == null || workout.endTime == null) {
      return WeightRecoveryData(
        hasData: false,
        daysSinceLastSession: 0,
      );
    }

    final now = DateTime.now();
    final daysDiff = now.difference(workout.endTime!).inDays;

    return WeightRecoveryData(
      previousWorkout: workout,
      lastSessionDate: workout.endTime,
      daysSinceLastSession: daysDiff,
      hasData: true,
    );
  }
  final Workout? previousWorkout;
  final DateTime? lastSessionDate;
  final int daysSinceLastSession;
  final bool hasData;
}

/// Provider per ottenere i dati di recupero pesi in formato comodo
final weightRecoveryDataProvider = FutureProvider.family<WeightRecoveryData, String>(
  (ref, templateId) async {
    final previousWorkout = await ref.watch(previousWorkoutFromTemplateProvider(templateId).future);
    return WeightRecoveryData.fromWorkout(previousWorkout);
  },
);
