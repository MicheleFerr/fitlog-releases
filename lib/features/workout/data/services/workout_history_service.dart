/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/services
/// 🎯 Feature: workout
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Service per leggere i dati storici dalla nuova collection 'workouts'
/// dopo la migrazione da 'exerciseActivities'
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';

class WorkoutHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _workoutsCollection = 'workouts';

  /// Ottiene l'ultima attività per un esercizio specifico
  /// Rimpiazza il metodo getActivitiesByExercise dell'ExerciseActivityRepository
  Future<ExerciseActivity?> getLastActivityByExercise({
    required String exerciseName,
    String? userEmail,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final uid = currentUser.uid;

      // Query per trovare workout che contengono l'esercizio
      final querySnapshot = await _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: uid)
          .orderBy('completedAt', descending: true)
          .limit(50) // Prendiamo più workout per cercare l'esercizio
          .get();

      // Cerca l'esercizio nei workout
      for (final doc in querySnapshot.docs) {
        try {
          final workoutData = WorkoutHistoryDetail.fromFirestore(doc);

          // Trova l'esercizio nel workout
          final exercise = workoutData.exercises
              .where((ex) => _isExerciseMatch(ex.name, exerciseName))
              .firstOrNull;

          if (exercise != null && exercise.sets.isNotEmpty) {
            // Converti in ExerciseActivity per compatibilità
            return _convertToExerciseActivity(workoutData, exercise);
          }
        } catch (e) {
          // Salta workout corrotti
          continue;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore getLastActivityByExercise: $e');
      }
      return null;
    }
  }

  /// Ottiene tutte le attività per un esercizio specifico
  Future<List<ExerciseActivity>> getActivitiesByExercise({
    required String userEmail,
    required String exerciseName,
    int limit = 50,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final uid = currentUser.uid;
      final activities = <ExerciseActivity>[];

      // Query per trovare workout che contengono l'esercizio
      final querySnapshot = await _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: uid)
          .orderBy('completedAt', descending: true)
          .limit(100) // Prendiamo più workout per cercare l'esercizio
          .get();

      // Cerca l'esercizio nei workout
      for (final doc in querySnapshot.docs) {
        try {
          final workoutData = WorkoutHistoryDetail.fromFirestore(doc);

          // Trova l'esercizio nel workout
          final exercise = workoutData.exercises
              .where((ex) => _isExerciseMatch(ex.name, exerciseName))
              .firstOrNull;

          if (exercise != null && exercise.sets.isNotEmpty) {
            // Converti in ExerciseActivity per compatibilità
            final activity = _convertToExerciseActivity(workoutData, exercise);
            activities.add(activity);

            if (activities.length >= limit) break;
          }
        } catch (e) {
          // Salta workout corrotti
          continue;
        }
      }

      return activities;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore getActivitiesByExercise: $e');
      }
      return [];
    }
  }

  /// Ottiene i dati storici dell'esercizio nel nuovo formato
  Future<List<ExerciseHistoryData>> getExerciseHistory({
    required String exerciseName,
    required String userId,
    int limit = 50,
  }) async {
    try {
      final history = <ExerciseHistoryData>[];

      // Query per trovare workout che contengono l'esercizio
      final querySnapshot = await _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(100) // Prendiamo più workout per cercare l'esercizio
          .get();

      // Cerca l'esercizio nei workout
      for (final doc in querySnapshot.docs) {
        try {
          final workoutData = WorkoutHistoryDetail.fromFirestore(doc);

          // Trova l'esercizio nel workout
          final exercise = workoutData.exercises
              .where((ex) => _isExerciseMatch(ex.name, exerciseName))
              .firstOrNull;

          if (exercise != null && exercise.sets.isNotEmpty) {
            // Aggiungi ogni serie come history data (escludi warmup)
            for (final set in exercise.sets) {
              if ((set.weight > 0 || set.reps > 0) && !set.isWarmup) {
                history.add(
                  ExerciseHistoryData(
                    weight: set.weight > 0 ? set.weight : null,
                    reps: set.reps > 0 ? set.reps : null,
                    rpe: set.rpe, // ✅ FIX: Include RPE from set
                    date: workoutData.completedAt,
                    workoutName: workoutData.name,
                  ),
                );
              }
            }

            if (history.length >= limit) break;
          }
        } catch (e) {
          // Salta workout corrotti
          continue;
        }
      }

      // Ordina per data decrescente
      history.sort((a, b) => b.date.compareTo(a.date));

      return history.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Ottiene i dati storici dell'esercizio con i dettagli di ogni set
  /// Usato per Feature Pre-fill Last Workout - ritorna i dati completi dei set
  Future<List<Map<String, dynamic>>> getExerciseHistoryWithSetDetails({
    required String exerciseName,
    required String userId,
    int limit = 50,
  }) async {
    try {
      final historyWithSets = <Map<String, dynamic>>[];

      // Query per trovare workout che contengono l'esercizio
      final querySnapshot = await _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(100) // Prendiamo più workout per cercare l'esercizio
          .get();

      // Cerca l'esercizio nei workout
      for (final doc in querySnapshot.docs) {
        try {
          final workoutData = WorkoutHistoryDetail.fromFirestore(doc);

          // Trova l'esercizio nel workout
          final exercise = workoutData.exercises
              .where((ex) => _isExerciseMatch(ex.name, exerciseName))
              .firstOrNull;

          if (exercise != null && exercise.sets.isNotEmpty) {
            // Converti i set in Map per accesso flessibile
            final setsList = exercise.sets
                .map(
                  (set) => {
                    'setNumber': set.setNumber,
                    'weight': set.weight,
                    'reps': set.reps,
                    'actualReps': set
                        .reps, // Nel nuovo formato, reps è già il valore effettivo
                    'rpe': set.rpe,
                    'isWarmup': set.isWarmup,
                  },
                )
                .toList();

            historyWithSets.add({
              'workoutId': workoutData.id,
              'workoutName': workoutData.name,
              'date': workoutData.completedAt,
              'exerciseName': exercise.name,
              'sets': setsList,
            });

            if (historyWithSets.length >= limit) break;
          }
        } catch (e) {
          // Salta workout corrotti
          continue;
        }
      }

      return historyWithSets;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore getExerciseHistoryWithSetDetails: $e');
      }
      return [];
    }
  }

  /// Ottiene l'ultimo peso e data per un esercizio
  Future<({double? weight, DateTime? date})> getLastExerciseData({
    required String exerciseName,
    required String userId,
  }) async {
    try {
      final history = await getExerciseHistory(
        exerciseName: exerciseName,
        userId: userId,
        limit: 1,
      );

      if (history.isNotEmpty) {
        final lastData = history.first;
        return (weight: lastData.weight, date: lastData.date);
      }

      return (weight: null, date: null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Errore getLastExerciseData: $e');
      }
      return (weight: null, date: null);
    }
  }

  /// Controlla se il nome dell'esercizio corrisponde (con variazioni)
  bool _isExerciseMatch(String exerciseName1, String exerciseName2) {
    final name1 = exerciseName1.toLowerCase().trim();
    final name2 = exerciseName2.toLowerCase().trim();

    // Controllo esatto
    if (name1 == name2) return true;

    // Controllo parziale
    if (name1.contains(name2) || name2.contains(name1)) return true;

    // Variazioni comuni
    final variations = _getExerciseVariations(name2);
    for (final variation in variations) {
      if (name1 == variation ||
          name1.contains(variation) ||
          variation.contains(name1)) {
        return true;
      }
    }

    return false;
  }

  /// Ottiene variazioni comuni dei nomi degli esercizi
  List<String> _getExerciseVariations(String exerciseName) {
    final variations = <String>[];
    final nameLower = exerciseName.toLowerCase().trim();

    // Traduzioni comuni Italiano <-> Inglese
    final translations = {
      'panca piana': [
        'bench press',
        'flat bench',
        'panca',
        'distensioni su panca',
      ],
      'bench press': ['panca piana', 'panca', 'distensioni su panca'],
      'squat': ['squat', 'accosciata', 'squats'],
      'stacco': ['deadlift', 'stacco da terra', 'stacchi'],
      'deadlift': ['stacco', 'stacco da terra', 'stacchi'],
      'military press': ['lento avanti', 'spinte militari', 'shoulder press'],
      'lento avanti': ['military press', 'spinte militari', 'shoulder press'],
      'curl': ['curl bicipiti', 'bicep curl', 'curl con bilanciere'],
      'lat machine': ['lat pulldown', 'lat machine al petto', 'pulldown'],
      'leg press': ['pressa', 'leg press', 'pressa gambe'],
      'pressa': ['leg press', 'pressa gambe'],
    };

    // Aggiungi variazioni dalla mappa di traduzione
    for (final entry in translations.entries) {
      if (entry.key == nameLower || entry.value.contains(nameLower)) {
        variations.addAll(entry.value);
        variations.add(entry.key);
      }
    }

    // Aggiungi il nome originale
    variations.add(nameLower);

    // Rimuovi duplicati
    return variations.toSet().toList();
  }

  /// Converte WorkoutHistoryDetail + ExerciseHistoryDetail in ExerciseActivity
  /// per mantenere compatibilità con il codice esistente
  ExerciseActivity _convertToExerciseActivity(
    WorkoutHistoryDetail workout,
    ExerciseHistoryDetail exercise,
  ) {
    // Converti i set
    final sets = exercise.sets.map((set) {
      return ExerciseActivitySet(
        set: set.setNumber,
        reps: set.reps.toString(),
        weight: set.weight.toString(),
        actualReps: set.reps.toString(),
        rpe: set.rpe,
        done: true, // Assumiamo che i set salvati siano completi
        effort: 3, // Valore di default
        isWarmup: set.isWarmup,
        setDurationMillis: null, // Non disponibile nel nuovo formato
      );
    }).toList();

    return ExerciseActivity(
      id: '${workout.id}_${exercise.id}',
      email: '', // Non più necessario nel nuovo formato
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      exerciseImage: (exercise.exerciseData['image'] as String?) ?? '',
      schedaName: workout.name,
      sets: sets,
      createdAt: workout.completedAt,
      lastModified: workout.updatedAt,
      category: ExerciseCategory.other, // Default for legacy data conversion
    );
  }
}
