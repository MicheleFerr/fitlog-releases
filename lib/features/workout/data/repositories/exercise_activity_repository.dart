import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/data/repositories/rate_limited_firestore_mixin.dart';

/// 🔒 RATE LIMITING: All Firestore operations are rate-limited to prevent quota exhaustion
///
/// ⚠️ **DEPRECATED**: This repository queries the old 'exerciseActivities' collection
/// which no longer exists. Use HybridExerciseActivityRepository instead.
///
/// **Migration Plan**:
/// - Old structure: exerciseActivities/{activityId} (flat, one doc per exercise)
/// - New structure: workouts/{workoutId} with nested exercises[] array
///
/// **Status**: Temporarily fixed to query 'workouts' but this is NOT the correct
/// architecture. This repository should be replaced with workout_history_repository_enhanced.dart
///
/// Repository per gestire le attività degli esercizi in Firestore
/// ⚠️ TEMPORARY FIX: Now queries 'workouts' collection instead of non-existent 'exerciseActivities'
class ExerciseActivityRepository with RateLimitedFirestoreMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ⚠️ CHANGED: exerciseActivities → workouts (2025-01-18)
  // Old: static const String _collectionName = 'exerciseActivities';
  static const String _collectionName = 'workouts';

  /// Salva un allenamento completato salvando ogni esercizio come ExerciseActivity
  ///
  /// ⚠️ DEPRECATED: Use workout_history_repository_enhanced.dart instead
  @Deprecated('Use WorkoutHistoryRepositoryEnhanced.saveWorkout() instead')
  Future<List<String>> saveCompletedWorkout({
    required Workout workout,
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
  }) async {
    debugPrint(
      '⚠️ DEPRECATED: ExerciseActivityRepository.saveCompletedWorkout() is deprecated. Use WorkoutHistoryRepositoryEnhanced instead.',
    );

    if (!workout.isCompleted) {
      throw Exception('Il workout deve essere completato per essere salvato');
    }

    final List<String> savedActivityIds = [];

    try {
      // Itera attraverso tutti gli esercizi con set completati
      for (int i = 0; i < workout.exercises.length; i++) {
        final exercise = workout.exercises[i];
        final completedSets = exercise.sets
            .where((set) => set.isCompleted)
            .toList();

        debugPrint('💾 Exercise: ${exercise.name}');
        debugPrint('💾 Total sets: ${exercise.sets.length}');
        debugPrint('💾 Completed sets: ${completedSets.length}');
        debugPrint(
          '💾 Warmup sets: ${completedSets.where((s) => s.isWarmup).length}',
        );

        // Salva solo esercizi che hanno almeno un set completato
        if (completedSets.isNotEmpty) {
          final activityId = await saveExerciseActivity(
            exercise: exercise,
            userId: userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
            workoutName: workout.name,
          );

          if (activityId != null) {
            savedActivityIds.add(activityId);
            debugPrint('✅ Saved exercise activity: $activityId');
          }
        } else {
          debugPrint('⚠️ Skipping exercise with no completed sets');
        }
      }

      return savedActivityIds;
    } catch (e) {
      rethrow;
    }
  }

  /// Salva una singola attività di esercizio
  ///
  /// ⚠️ DEPRECATED: Use workout_history_repository_enhanced.dart instead
  @Deprecated('Use WorkoutHistoryRepositoryEnhanced.saveWorkout() instead')
  Future<String?> saveExerciseActivity({
    required Exercise exercise,
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
    required String workoutName,
    String? exerciseImageUrl,
  }) async {
    debugPrint(
      '⚠️ DEPRECATED: ExerciseActivityRepository.saveExerciseActivity() is deprecated. Use WorkoutHistoryRepositoryEnhanced instead.',
    );
    try {
      // ⚠️ NOTE: This saves to 'workouts' collection but structure is wrong
      // Should use workout_history_repository_enhanced.dart for proper nested structure

      // Crea ExerciseActivity dal Exercise
      final exerciseActivity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail:
            userId, // ⚠️ Parameter name is userEmail (expects email string)
        workoutName: workoutName,
        exerciseImageUrl: exerciseImageUrl,
      );

      // Salva in Firestore
      final docRef = await rateLimitedWrite(() async {
        return await _firestore
            .collection(_collectionName)
            .add(exerciseActivity.toFirestore());
      });

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Ottiene tutte le attività di un utente
  ///
  /// ⚠️ DEPRECATED: Use workout_history_repository_enhanced.dart instead
  /// ⚠️ WARNING: This queries 'workouts' but expects flat ExerciseActivity structure.
  /// Will fail to parse nested workout.exercises[] correctly.
  @Deprecated(
    'Use WorkoutHistoryRepositoryEnhanced.getWorkoutHistory() instead',
  )
  Future<List<ExerciseActivity>> getUserActivities({
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint(
      '⚠️ DEPRECATED: ExerciseActivityRepository.getUserActivities() is deprecated',
    );

    try {
      return await rateLimitedQuery(() async {
        Query query = _firestore
            .collection(_collectionName)
            .where(
              'userId',
              isEqualTo: userId,
            ) // ⚠️ CHANGED: email → userId (2025-01-18)
            .orderBy(
              'completedAt',
              descending: true,
            ); // ⚠️ CHANGED: createdAt → completedAt (2025-01-18)

        // Applica filtri opzionali
        if (startDate != null) {
          query = query.where(
            'completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          ); // ⚠️ CHANGED
        }

        if (endDate != null) {
          query = query.where(
            'completedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          ); // ⚠️ CHANGED
        }

        if (limit != null) {
          query = query.limit(limit);
        }

        final querySnapshot = await query.get();

        if (querySnapshot.docs.isEmpty) {}

        final activities = querySnapshot.docs
            .map((doc) => ExerciseActivity.fromFirestore(doc))
            .toList();

        return activities;
      });
    } catch (e) {
      return [];
    }
  }

  /// Ottiene attività per nome esercizio
  ///
  /// ⚠️ DEPRECATED: Use workout_history_repository_enhanced.dart instead
  /// ⚠️ WARNING: This queries 'workouts' but expects flat ExerciseActivity structure.
  /// Will fail to parse nested workout.exercises[] correctly.
  @Deprecated(
    'Use WorkoutHistoryRepositoryEnhanced.getWorkoutHistory() instead',
  )
  Future<List<ExerciseActivity>> getActivitiesByExercise({
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
    required String exerciseName,
    int? limit,
  }) async {
    debugPrint(
      '⚠️ DEPRECATED: ExerciseActivityRepository.getActivitiesByExercise() is deprecated',
    );
    try {
      return await rateLimitedQuery(() async {
        Query query = _firestore
            .collection(_collectionName)
            .where(
              'userId',
              isEqualTo: userId,
            ) // ⚠️ CHANGED: email → userId (2025-01-18)
            .where('exerciseName', isEqualTo: exerciseName)
            .orderBy(
              'completedAt',
              descending: true,
            ); // ⚠️ CHANGED: createdAt → completedAt (2025-01-18)

        if (limit != null) {
          query = query.limit(limit);
        }

        final querySnapshot = await query.get();

        return querySnapshot.docs
            .map((doc) => ExerciseActivity.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore nel recuperare attività per esercizio: $e');
      }
      return [];
    }
  }

  /// Ottiene statistiche di un esercizio (es: massimo peso, volume totale)
  ///
  /// ⚠️ DEPRECATED: Use workout_history_repository_enhanced.dart instead
  @Deprecated('Use WorkoutHistoryRepositoryEnhanced for exercise stats')
  Future<ExerciseStats?> getExerciseStats({
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
    required String exerciseName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    debugPrint(
      '⚠️ DEPRECATED: ExerciseActivityRepository.getExerciseStats() is deprecated',
    );
    try {
      final activities = await getActivitiesByExercise(
        userId: userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
        exerciseName: exerciseName,
      );

      if (activities.isEmpty) return null;

      // Calcola statistiche
      double maxWeight = 0;
      int totalVolume = 0;
      int totalSets = 0;
      int totalReps = 0;

      for (final activity in activities) {
        for (final set in activity.sets) {
          if (set.done) {
            final weight = double.tryParse(set.weight) ?? 0;
            final reps = int.tryParse(set.reps) ?? 0;

            maxWeight = maxWeight > weight ? maxWeight : weight;
            totalVolume += (weight * reps).round();
            totalSets++;
            totalReps += reps;
          }
        }
      }

      return ExerciseStats(
        exerciseName: exerciseName,
        maxWeight: maxWeight,
        totalVolume: totalVolume,
        totalSets: totalSets,
        totalReps: totalReps,
        totalWorkouts: activities.length,
        lastWorkout: activities.first.createdAt,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore nel calcolare statistiche esercizio: $e');
      }
      return null;
    }
  }

  /// Elimina un'attività
  Future<bool> deleteActivity(String activityId) async {
    try {
      await rateLimitedDelete(() async {
        await _firestore.collection(_collectionName).doc(activityId).delete();
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore nell\'eliminare attività: $e');
      }
      return false;
    }
  }

  /// Stream di attività utente in tempo reale
  ///
  /// ⚠️ DEPRECATED: Use workout_history_repository_enhanced.dart instead
  @Deprecated('Use WorkoutHistoryRepositoryEnhanced.workoutsStream instead')
  Stream<List<ExerciseActivity>> getUserActivitiesStream({
    required String userId, // ⚠️ CHANGED: userEmail → userId (2025-01-18)
    int? limit,
  }) {
    Query query = _firestore
        .collection(_collectionName)
        .where(
          'userId',
          isEqualTo: userId,
        ) // ⚠️ CHANGED: email → userId (2025-01-18)
        .orderBy(
          'completedAt',
          descending: true,
        ); // ⚠️ CHANGED: createdAt → completedAt (2025-01-18)

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ExerciseActivity.fromFirestore(doc))
          .toList(),
    );
  }
}

/// Statistiche di un esercizio
class ExerciseStats {
  ExerciseStats({
    required this.exerciseName,
    required this.maxWeight,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
    required this.totalWorkouts,
    required this.lastWorkout,
  });
  final String exerciseName;
  final double maxWeight;
  final int totalVolume;
  final int totalSets;
  final int totalReps;
  final int totalWorkouts;
  final DateTime lastWorkout;
}
