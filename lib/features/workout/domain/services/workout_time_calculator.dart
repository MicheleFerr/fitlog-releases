/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: domain/services
/// Feature: Workout Time Calculation
///
/// Utility service to calculate workout time metrics and suggest
/// adjusted workout durations when actual time < rest time.
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Service per calcoli tempo workout
///
/// Calcola:
/// - Tempo totale recuperi (sum of rest times between sets)
/// - Tempo suggerito (rest_time + 2min × numero_serie)
/// - Verifica se workout time sembra breve
class WorkoutTimeCalculator {
  /// Calcola il tempo totale dei recuperi impostati nel workout
  ///
  /// Per ogni esercizio:
  /// - Usa `exercise.restTime` se impostato, altrimenti default 60s
  /// - Moltiplica per (numero_set - 1) perché non c'è recupero dopo l'ultimo set
  ///
  /// Per i superset:
  /// - Calcola rest time tra i round del superset
  static Duration calculateTotalRestTime(Workout workout) {
    int totalRestSeconds = 0;

    for (final exercise in workout.exercises) {
      final restTimePerSet = exercise.restTime ?? 60; // Default 60s

      if (exercise is SupersetExercise) {
        // Per superset: rest tra i round
        final roundCount = exercise.supersetSets.length;
        if (roundCount > 1) {
          totalRestSeconds += restTimePerSet * (roundCount - 1);
        }
      } else {
        // Per esercizi normali: rest tra i set
        final setCount = exercise.sets.length;
        if (setCount > 1) {
          totalRestSeconds += restTimePerSet * (setCount - 1);
        }
      }
    }

    return Duration(seconds: totalRestSeconds);
  }

  /// Calcola il numero totale di set nel workout (per il tempo suggerito)
  static int calculateTotalSets(Workout workout) {
    int totalSets = 0;

    for (final exercise in workout.exercises) {
      if (exercise is SupersetExercise) {
        // Per superset: conta i round × esercizi
        totalSets += exercise.supersetSets.length * exercise.exercises.length;
      } else {
        totalSets += exercise.sets.length;
      }
    }

    return totalSets;
  }

  /// Calcola il tempo suggerito per il workout
  ///
  /// Formula: tempo_recuperi + (2 min × numero_serie)
  ///
  /// Il razionale è:
  /// - Tempo recuperi è il minimo tempo trascorso a riposare
  /// - 2 min × serie stima il tempo per eseguire i set
  static Duration calculateSuggestedDuration(Workout workout) {
    final restTime = calculateTotalRestTime(workout);
    final totalSets = calculateTotalSets(workout);

    // 2 minuti per set
    final executionTime = Duration(minutes: totalSets * 2);

    return restTime + executionTime;
  }

  /// Verifica se il tempo del workout sembra troppo breve
  ///
  /// Ritorna `true` se `actualDuration < totalRestTime`
  /// Questo indica che il workout è stato probabilmente
  /// eseguito offline o il timer non era attivo.
  static bool isWorkoutDurationSuspicious(Workout workout) {
    final actualDuration = workout.duration;
    if (actualDuration == null) return false;

    final totalRestTime = calculateTotalRestTime(workout);

    // Se non ci sono recuperi (workout vuoto o tutti set singoli)
    // non possiamo giudicare
    if (totalRestTime.inSeconds == 0) return false;

    return actualDuration < totalRestTime;
  }

  /// Crea un sommario delle metriche tempo per debug/display
  static WorkoutTimeMetrics getTimeMetrics(Workout workout) {
    return WorkoutTimeMetrics(
      actualDuration: workout.duration ?? Duration.zero,
      totalRestTime: calculateTotalRestTime(workout),
      suggestedDuration: calculateSuggestedDuration(workout),
      totalSets: calculateTotalSets(workout),
      isSuspicious: isWorkoutDurationSuspicious(workout),
    );
  }
}

/// DTO con tutte le metriche tempo del workout
class WorkoutTimeMetrics {
  const WorkoutTimeMetrics({
    required this.actualDuration,
    required this.totalRestTime,
    required this.suggestedDuration,
    required this.totalSets,
    required this.isSuspicious,
  });

  /// Durata effettiva registrata (endTime - startTime)
  final Duration actualDuration;

  /// Somma di tutti i tempi di recupero
  final Duration totalRestTime;

  /// Tempo suggerito = restTime + (2min × sets)
  final Duration suggestedDuration;

  /// Numero totale di serie
  final int totalSets;

  /// true se actualDuration < totalRestTime
  final bool isSuspicious;

  /// Formatta la durata in HH:MM:SS o MM:SS
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  String get actualDurationFormatted => formatDuration(actualDuration);
  String get totalRestTimeFormatted => formatDuration(totalRestTime);
  String get suggestedDurationFormatted => formatDuration(suggestedDuration);
}
