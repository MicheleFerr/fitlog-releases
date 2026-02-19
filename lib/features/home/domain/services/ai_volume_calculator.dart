/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/home/domain/services
/// 🎯 Feature: home
/// 🔧 Type: service
///
/// Servizio per calcolo scientifico del volume di allenamento per muscle group
/// Implementa le linee guida scientifiche (MEV, MAV, MRV)
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Risultato del calcolo volume per un muscle group
class MuscleGroupVolume {
  const MuscleGroupVolume({
    required this.muscleGroup,
    required this.totalSets,
    required this.totalVolume,
    required this.exercises,
  });
  final String muscleGroup;
  final int totalSets;
  final double totalVolume; // peso x reps
  final List<String> exercises;

  /// Classifica il volume secondo linee guida scientifiche
  VolumeClassification classify() {
    if (totalSets < 10) return VolumeClassification.belowMEV;
    if (totalSets < 15) return VolumeClassification.mev;
    if (totalSets <= 20) return VolumeClassification.mav;
    if (totalSets <= 25) return VolumeClassification.approaching_mrv;
    return VolumeClassification.above_mrv;
  }

  bool get isOptimal => totalSets >= 15 && totalSets <= 20;
  bool get isTooLow => totalSets < 10;
  bool get isTooHigh => totalSets > 25;
}

/// Classificazione volume secondo ricerca scientifica
enum VolumeClassification {
  belowMEV, // < 10 sets: Sotto il Minimum Effective Volume
  mev, // 10-15 sets: Minimum Effective Volume
  mav, // 15-20 sets: Maximum Adaptive Volume (OPTIMAL)
  approaching_mrv, // 20-25 sets: Vicino al Maximum Recoverable Volume
  above_mrv, // > 25 sets: Sopra il Maximum Recoverable Volume (rischio overtraining)
}

/// Servizio per calcolo volume di allenamento scientificamente accurato
class AIVolumeCalculator {
  /// Calcola volume settimanale per muscle group
  ///
  /// Questo è il metodo CORRETTO per analizzare il volume:
  /// - Raggruppa per muscle group (non per workout)
  /// - Calcola su base settimanale (non per singolo workout)
  /// - Considera sia muscoli primari che secondari
  /// - Usa il database esercizi per mappatura accurata
  static Map<String, MuscleGroupVolume> calculateWeeklyVolumeByMuscleGroup(
    List<ExerciseActivity> weeklyActivities,
    Map<String, Exercise> exerciseDatabase,
  ) {
    final volumeByMuscle = <String, _MuscleGroupData>{};

    for (final activity in weeklyActivities) {
      // Ottieni l'esercizio dal database per mappatura muscoli corretta (case-insensitive)
      final exercise = exerciseDatabase[activity.exerciseName.toLowerCase()];

      // Calcola sets completati per questa attività
      final completedSets = activity.sets.where((s) => s.done).length;
      final activityVolume = _calculateActivityVolume(activity);

      if (exercise != null) {
        // Usa i dati del database per muscoli primari e secondari
        for (final muscle in exercise.focus) {
          _addVolumeToMuscle(
            volumeByMuscle,
            muscle,
            completedSets,
            activityVolume,
            activity.exerciseName,
            isPrimary: true,
          );
        }

        // Muscoli secondari contano per metà
        for (final muscle in exercise.muscoliSecondari) {
          _addVolumeToMuscle(
            volumeByMuscle,
            muscle,
            (completedSets * 0.5).round(),
            activityVolume * 0.5,
            activity.exerciseName,
            isPrimary: false,
          );
        }
      } else {
        // Fallback: usa categorizzazione SSOT se esercizio non trovato (custom exercise)
        // **Uses SSOT**: MuscleAbbreviationMapper.categorizeExerciseToAbbreviation
        final muscleGroup =
            MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
              activity.exerciseName,
            );
        _addVolumeToMuscle(
          volumeByMuscle,
          muscleGroup,
          completedSets,
          activityVolume,
          activity.exerciseName,
          isPrimary: true,
        );
      }
    }

    // Converti in MuscleGroupVolume
    return volumeByMuscle.map(
      (muscle, data) => MapEntry(
        muscle,
        MuscleGroupVolume(
          muscleGroup: muscle,
          totalSets: data.totalSets,
          totalVolume: data.totalVolume,
          exercises: data.exercises.toList(),
        ),
      ),
    );
  }

  /// Helper per aggiungere volume a un muscle group
  static void _addVolumeToMuscle(
    Map<String, _MuscleGroupData> volumeMap,
    String muscle,
    int sets,
    double volume,
    String exerciseName, {
    required bool isPrimary,
  }) {
    volumeMap.putIfAbsent(muscle, () => _MuscleGroupData());

    volumeMap[muscle]!.totalSets += sets;
    volumeMap[muscle]!.totalVolume += volume;
    volumeMap[muscle]!.exercises.add(exerciseName);
  }

  /// Calcola volume totale per un'attività
  static double _calculateActivityVolume(ExerciseActivity activity) {
    double volume = 0;
    for (final set in activity.sets) {
      if (set.done) {
        final weight = _parseWeight(set.weight);
        final reps = _parseReps(set.reps);
        volume += weight * reps;
      }
    }
    return volume;
  }

  // NOTE: _fallbackCategorization REMOVED
  // Use MuscleAbbreviationMapper.categorizeExerciseToAbbreviation as SSOT

  /// Parse weight safely
  static double _parseWeight(dynamic weight) {
    if (weight == null) return 0.0;
    if (weight is double) return weight;
    if (weight is int) return weight.toDouble();
    if (weight is String) return double.tryParse(weight) ?? 0.0;
    return 0.0;
  }

  /// Parse reps safely
  static double _parseReps(dynamic reps) {
    if (reps == null) return 0.0;
    if (reps is double) return reps;
    if (reps is int) return reps.toDouble();
    if (reps is String) return double.tryParse(reps) ?? 0.0;
    return 0.0;
  }

  /// Identifica muscle groups sbilanciati
  static List<String> findImbalancedMuscles(
    Map<String, MuscleGroupVolume> volumeMap,
  ) {
    final imbalanced = <String>[];

    for (final entry in volumeMap.entries) {
      if (entry.value.isTooLow) {
        imbalanced.add(entry.key);
      }
    }

    return imbalanced;
  }

  /// Identifica muscle groups con volume eccessivo
  static List<String> findOvertrainedMuscles(
    Map<String, MuscleGroupVolume> volumeMap,
  ) {
    final overtrained = <String>[];

    for (final entry in volumeMap.entries) {
      if (entry.value.isTooHigh) {
        overtrained.add(entry.key);
      }
    }

    return overtrained;
  }
}

/// Classe helper per accumulare dati volume
class _MuscleGroupData {
  int totalSets = 0;
  double totalVolume = 0;
  final Set<String> exercises = {};
}
