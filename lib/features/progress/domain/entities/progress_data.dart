import 'package:flutter/foundation.dart';
import '../../../workout/domain/entities/exercise_activity.dart';

/// Entità che rappresenta i dati di progresso dell'utente
class ProgressData {
  final double totalVolume; // Volume totale sollevato in kg
  final double volumeIncrease; // Incremento percentuale volume ultimo mese
  final Map<String, double> personalRecords; // PR per esercizio
  final int totalWorkouts; // Totale workout completati
  final int currentStreak; // Giorni consecutivi attuali
  final double weeklyFrequency; // Frequenza settimanale media
  final QuickStats quickStats;

  const ProgressData({
    required this.totalVolume,
    required this.volumeIncrease,
    required this.personalRecords,
    required this.totalWorkouts,
    required this.currentStreak,
    required this.weeklyFrequency,
    required this.quickStats,
  });

  /// Crea ProgressData da una lista di ExerciseActivity
  factory ProgressData.fromActivities(List<ExerciseActivity> activities) {
    if (activities.isEmpty) {
      return ProgressData(
        totalVolume: 0,
        volumeIncrease: 0,
        personalRecords: {},
        totalWorkouts: 0,
        currentStreak: 0,
        weeklyFrequency: 0,
        quickStats: QuickStats.empty(),
      );
    }

    // Ordina per data
    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Calcola volume totale
    double totalVolume = 0;
    for (final activity in activities) {
      for (final set in activity.sets) {
        totalVolume += (double.tryParse(set.weight.toString()) ?? 0) * (int.tryParse(set.reps.toString()) ?? 0);
      }
    }

    // Calcola incremento volume ultimo mese
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentActivities = activities.where((a) => a.createdAt.isAfter(oneMonthAgo)).toList();
    final previousActivities = activities.where((a) => 
        a.createdAt.isBefore(oneMonthAgo) && 
        a.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 60)))
    ).toList();

    double recentVolume = 0;
    for (final activity in recentActivities) {
      for (final set in activity.sets) {
        recentVolume += (double.tryParse(set.weight.toString()) ?? 0) * (int.tryParse(set.reps.toString()) ?? 0);
      }
    }

    double previousVolume = 0;
    for (final activity in previousActivities) {
      for (final set in activity.sets) {
        previousVolume += (double.tryParse(set.weight.toString()) ?? 0) * (int.tryParse(set.reps.toString()) ?? 0);
      }
    }

    double volumeIncrease = 0;
    if (previousVolume > 0) {
      volumeIncrease = ((recentVolume - previousVolume) / previousVolume) * 100;
    }

    // Calcola PR per esercizio (solo ultimi 30 giorni)
    Map<String, double> personalRecords = {};
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentActivitiesForPR = activities.where((a) => a.createdAt.isAfter(thirtyDaysAgo)).toList();
    
    for (final activity in recentActivitiesForPR) {
      final exerciseName = activity.exerciseName;
      double maxWeight = 0;
      
      for (final set in activity.sets) {
        // Assicurati che il set sia completato
        if (set.done) {
          final weight = double.tryParse(set.weight.toString()) ?? 0;
          // Debug: stampa i pesi trovati
          if (weight > 0 && exerciseName.toLowerCase().contains('panca')) {
            debugPrint('DEBUG: Panca - Peso trovato: $weight kg');
          }
          if (weight > maxWeight) {
            maxWeight = weight;
          }
        }
      }
      
      if (maxWeight > 0) {
        if (!personalRecords.containsKey(exerciseName) || maxWeight > personalRecords[exerciseName]!) {
          personalRecords[exerciseName] = maxWeight;
          debugPrint('DEBUG: PR per $exerciseName: $maxWeight kg');
        }
      }
    }

    // Trova l'esercizio con il PR più alto
    String prExerciseName = 'N/A';
    double maxPRValue = 0;
    
    personalRecords.forEach((exercise, weight) {
      if (weight > maxPRValue) {
        maxPRValue = weight;
        prExerciseName = exercise;
      }
    });
    
    // Debug: stampa il PR finale
    if (maxPRValue > 0) {
      debugPrint('DEBUG: PR FINALE - $prExerciseName: $maxPRValue kg');
      debugPrint('DEBUG: Tutti i PR trovati:');
      personalRecords.forEach((exercise, weight) {
        debugPrint('  - $exercise: $weight kg');
      });
    }

    // Conta workout unici (per giornata)
    final uniqueWorkoutDays = <String>{};
    for (final activity in activities) {
      final dayKey = '${activity.createdAt.year}-${activity.createdAt.month}-${activity.createdAt.day}';
      uniqueWorkoutDays.add(dayKey);
    }

    final quickStats = QuickStats(
      totalVolume: totalVolume,
      volumeIncrease: volumeIncrease,
      maxPR: maxPRValue,
      prExercise: prExerciseName,
      totalWorkouts: uniqueWorkoutDays.length,
    );

    return ProgressData(
      totalVolume: totalVolume,
      volumeIncrease: volumeIncrease,
      personalRecords: personalRecords,
      totalWorkouts: uniqueWorkoutDays.length,
      currentStreak: 0, // Calcolato dal provider separato
      weeklyFrequency: 0, // Calcolato dal provider separato
      quickStats: quickStats,
    );
  }
}

/// Statistiche rapide per la home screen
class QuickStats {
  final double totalVolume;
  final double volumeIncrease; // Percentuale
  final double maxPR;
  final String prExercise;
  final int totalWorkouts;

  const QuickStats({
    required this.totalVolume,
    required this.volumeIncrease,
    required this.maxPR,
    required this.prExercise,
    required this.totalWorkouts,
  });

  factory QuickStats.empty() {
    return const QuickStats(
      totalVolume: 0,
      volumeIncrease: 0,
      maxPR: 0,
      prExercise: 'N/A',
      totalWorkouts: 0,
    );
  }

  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}k kg';
    }
    return '${totalVolume.toStringAsFixed(0)} kg';
  }

  String get formattedVolumeIncrease {
    if (volumeIncrease > 0) {
      return '+${volumeIncrease.toStringAsFixed(0)}%';
    } else if (volumeIncrease < 0) {
      return '${volumeIncrease.toStringAsFixed(0)}%';
    }
    return '0%';
  }

  String get formattedMaxPR {
    return '${maxPR.toStringAsFixed(0)} kg';
  }
}