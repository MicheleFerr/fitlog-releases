import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/exercise_activity.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';

/// Repository per gestire le attività degli esercizi in Firestore
/// Salva nella collezione /exerciseActivities come nella vecchia app
class ExerciseActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _collectionName = 'exerciseActivities';

  /// Salva un allenamento completato salvando ogni esercizio come ExerciseActivity
  Future<List<String>> saveCompletedWorkout({
    required Workout workout,
    required String userEmail,
  }) async {
    
    if (!workout.isCompleted) {
      throw Exception('Il workout deve essere completato per essere salvato');
    }

    final List<String> savedActivityIds = [];

    try {
      
      // Itera attraverso tutti gli esercizi con set completati
      for (int i = 0; i < workout.exercises.length; i++) {
        final exercise = workout.exercises[i];
        final completedSets = exercise.sets.where((set) => set.isCompleted).toList();
        
        debugPrint('💾 Exercise: ${exercise.name}');
        debugPrint('💾 Total sets: ${exercise.sets.length}');
        debugPrint('💾 Completed sets: ${completedSets.length}');
        debugPrint('💾 Warmup sets: ${completedSets.where((s) => s.isWarmup).length}');
        
        // Salva solo esercizi che hanno almeno un set completato
        if (completedSets.isNotEmpty) {
          
          final activityId = await saveExerciseActivity(
            exercise: exercise,
            userEmail: userEmail,
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
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Salva una singola attività di esercizio
  Future<String?> saveExerciseActivity({
    required Exercise exercise,
    required String userEmail,
    required String workoutName,
    String? exerciseImageUrl,
  }) async {
    try {
      // Normalizza email per consistency
      final normalizedEmail = userEmail.toLowerCase().trim();
      
      // Crea ExerciseActivity dal Exercise
      final exerciseActivity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: normalizedEmail,
        workoutName: workoutName,
        exerciseImageUrl: exerciseImageUrl,
      );

      // Salva in Firestore
      final docRef = await _firestore
          .collection(_collectionName)
          .add(exerciseActivity.toFirestore());

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Ottiene tutte le attività di un utente
  Future<List<ExerciseActivity>> getUserActivities({
    required String userEmail,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Normalizza email per consistency
    final normalizedEmail = userEmail.toLowerCase().trim();
    
    
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: normalizedEmail)
          .orderBy('createdAt', descending: true);


      // Applica filtri opzionali
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
      }
      
      final activities = querySnapshot.docs
          .map((doc) => ExerciseActivity.fromFirestore(doc))
          .toList();
      
      return activities;
      
    } catch (e, stackTrace) {
      return [];
    }
  }

  /// Ottiene attività per nome esercizio
  Future<List<ExerciseActivity>> getActivitiesByExercise({
    required String userEmail,
    required String exerciseName,
    int? limit,
  }) async {
    try {
      // Normalizza email per consistency
      final normalizedEmail = userEmail.toLowerCase().trim();
      
      Query query = _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: normalizedEmail)
          .where('exerciseName', isEqualTo: exerciseName)
          .orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => ExerciseActivity.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Errore nel recuperare attività per esercizio: $e');
      return [];
    }
  }

  /// Ottiene statistiche di un esercizio (es: massimo peso, volume totale)
  Future<ExerciseStats?> getExerciseStats({
    required String userEmail,
    required String exerciseName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Normalizza email per consistency
      final normalizedEmail = userEmail.toLowerCase().trim();
      
      final activities = await getActivitiesByExercise(
        userEmail: normalizedEmail,
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
      print('Errore nel calcolare statistiche esercizio: $e');
      return null;
    }
  }

  /// Elimina un'attività
  Future<bool> deleteActivity(String activityId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(activityId)
          .delete();
      return true;
    } catch (e) {
      print('Errore nell\'eliminare attività: $e');
      return false;
    }
  }

  /// Stream di attività utente in tempo reale
  Stream<List<ExerciseActivity>> getUserActivitiesStream({
    required String userEmail,
    int? limit,
  }) {
    // Normalizza email per consistency
    final normalizedEmail = userEmail.toLowerCase().trim();
    
    Query query = _firestore
        .collection(_collectionName)
        .where('email', isEqualTo: normalizedEmail)
        .orderBy('createdAt', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => ExerciseActivity.fromFirestore(doc))
            .toList()
    );
  }
}

/// Statistiche di un esercizio
class ExerciseStats {
  final String exerciseName;
  final double maxWeight;
  final int totalVolume;
  final int totalSets;
  final int totalReps;
  final int totalWorkouts;
  final DateTime lastWorkout;

  ExerciseStats({
    required this.exerciseName,
    required this.maxWeight,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
    required this.totalWorkouts,
    required this.lastWorkout,
  });
}