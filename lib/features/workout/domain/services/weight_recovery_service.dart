import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Servizio per applicare i pesi recuperati da una sessione precedente
class WeightRecoveryService {
  /// Applica i pesi dalla sessione precedente al workout corrente
  ///
  /// [currentWorkout]: Il workout appena creato (vuoto)
  /// [previousWorkout]: Il workout precedente con i pesi
  /// [multiplier]: Moltiplicatore da applicare (1.0 = esatti, 1.025 = +2.5%, 0.975 = -2.5%)
  static Workout applyPreviousWeights({
    required Workout currentWorkout,
    required Workout previousWorkout,
    required double multiplier,
  }) {
    // Crea una mappa nome esercizio -> esercizio precedente per accesso rapido
    final Map<String, Exercise> previousExercisesMap = {};
    for (final exercise in previousWorkout.exercises) {
      previousExercisesMap[exercise.name] = exercise;
    }

    // Aggiorna gli esercizi del workout corrente
    final updatedExercises = currentWorkout.exercises.map((currentExercise) {
      // Cerca l'esercizio corrispondente nel workout precedente
      final previousExercise = previousExercisesMap[currentExercise.name];

      if (previousExercise == null || previousExercise.sets.isEmpty) {
        // Non trovato o senza set, lascia l'esercizio invariato
        return currentExercise;
      }

      // Applica i pesi dal workout precedente
      return _applyWeightsToExercise(
        currentExercise: currentExercise,
        previousExercise: previousExercise,
        multiplier: multiplier,
      );
    }).toList();

    return currentWorkout.copyWith(exercises: updatedExercises);
  }

  static Exercise _applyWeightsToExercise({
    required Exercise currentExercise,
    required Exercise previousExercise,
    required double multiplier,
  }) {
    // Gestisci superset separatamente
    if (currentExercise.type == ExerciseType.superset &&
        currentExercise is SupersetExercise &&
        previousExercise is SupersetExercise) {
      return _applyWeightsToSuperset(
        currentExercise: currentExercise,
        previousExercise: previousExercise,
        multiplier: multiplier,
      );
    }

    // Per esercizi normali, aggiorna i set
    final updatedSets = <ExerciseSet>[];

    for (int i = 0; i < currentExercise.sets.length; i++) {
      final currentSet = currentExercise.sets[i];

      // Cerca il set corrispondente nel workout precedente
      // Se i set precedenti sono di meno, usa l'ultimo
      final previousSet = i < previousExercise.sets.length
          ? previousExercise.sets[i]
          : previousExercise.sets.last;

      // Applica il peso con il moltiplicatore se disponibile
      final previousWeight = previousSet.weight;
      final newWeight = previousWeight != null
          ? _smartRound(previousWeight * multiplier)
          : currentSet.weight; // Keep current weight if previous is null

      final updatedSet = currentSet.copyWith(
        weight: newWeight,
        reps: previousSet.reps, // Copia anche le reps
      );

      updatedSets.add(updatedSet);
    }

    return currentExercise.copyWith(sets: updatedSets);
  }

  static SupersetExercise _applyWeightsToSuperset({
    required SupersetExercise currentExercise,
    required SupersetExercise previousExercise,
    required double multiplier,
  }) {
    // Crea mappa degli esercizi precedenti per nome
    final Map<String, Exercise> previousExercisesMap = {};
    for (final ex in previousExercise.exercises) {
      previousExercisesMap[ex.name] = ex;
    }

    // Aggiorna gli esercizi del superset
    final updatedExercises = currentExercise.exercises.map((currentEx) {
      final previousEx = previousExercisesMap[currentEx.name];

      if (previousEx == null || previousEx.sets.isEmpty) {
        return currentEx;
      }

      return _applyWeightsToExercise(
        currentExercise: currentEx,
        previousExercise: previousEx,
        multiplier: multiplier,
      );
    }).toList();

    // Aggiorna anche i superset sets se presenti
    final updatedSupersetSets = <SupersetSet>[];
    for (int i = 0; i < currentExercise.supersetSets.length; i++) {
      final currentSet = currentExercise.supersetSets[i];

      if (i < previousExercise.supersetSets.length) {
        final previousSet = previousExercise.supersetSets[i];

        // Aggiorna ogni exercise data nel superset set
        final updatedExerciseData = <String, SupersetExerciseData>{};

        currentSet.exerciseData.forEach((exerciseName, currentData) {
          final previousData = previousSet.exerciseData[exerciseName];

          if (previousData != null) {
            final targetWeight =
                previousData.targetWeight ?? previousData.actualWeight ?? 0.0;
            final newWeight = _smartRound(targetWeight * multiplier);
            final targetReps =
                previousData.targetReps ?? previousData.actualReps ?? 0;

            updatedExerciseData[exerciseName] = currentData.copyWith(
              targetWeight: newWeight,
              targetReps: targetReps,
            );
          } else {
            updatedExerciseData[exerciseName] = currentData;
          }
        });

        updatedSupersetSets.add(
          currentSet.copyWith(exerciseData: updatedExerciseData),
        );
      } else {
        updatedSupersetSets.add(currentSet);
      }
    }

    return SupersetExercise(
      id: currentExercise.id,
      name: currentExercise.name,
      exercises: updatedExercises,
      supersetSets: updatedSupersetSets,
      notes: currentExercise.notes,
      restTime: currentExercise.restTime,
    );
  }

  /// Arrotondamento intelligente basato su dischi comuni
  /// - Fino a 20kg: arrotonda a 0.5kg (manubri)
  /// - Oltre 20kg: arrotonda a 2.5kg (bilanciere con dischi 1.25kg)
  static double _smartRound(double weight) {
    if (weight <= 0) return weight;

    if (weight < 20) {
      // Arrotonda a 0.5kg (manubri)
      return (weight * 2).round() / 2;
    } else {
      // Arrotonda a 2.5kg (bilanciere)
      return (weight / 2.5).round() * 2.5;
    }
  }

  /// Ottiene il moltiplicatore in base alla percentuale
  static double getMultiplier(double percentage) {
    return 1.0 + (percentage / 100);
  }

  /// Calcola la differenza di peso tra due workout
  static Map<String, WeightDifference> calculateDifferences({
    required Workout currentWorkout,
    required Workout previousWorkout,
  }) {
    final differences = <String, WeightDifference>{};

    final previousMap = <String, Exercise>{};
    for (final ex in previousWorkout.exercises) {
      previousMap[ex.name] = ex;
    }

    for (final currentEx in currentWorkout.exercises) {
      final previousEx = previousMap[currentEx.name];

      if (previousEx == null ||
          previousEx.sets.isEmpty ||
          currentEx.sets.isEmpty) {
        continue;
      }

      final currentAvg = _calculateAverageWeight(currentEx.sets);
      final previousAvg = _calculateAverageWeight(previousEx.sets);

      if (currentAvg > 0 && previousAvg > 0) {
        final diffPercent = ((currentAvg - previousAvg) / previousAvg) * 100;

        differences[currentEx.name] = WeightDifference(
          exerciseName: currentEx.name,
          previousWeight: previousAvg,
          currentWeight: currentAvg,
          differencePercent: diffPercent,
        );
      }
    }

    return differences;
  }

  static double _calculateAverageWeight(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 0;

    final totalWeight = sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight ?? 0),
    );

    return totalWeight / sets.length;
  }
}

/// Rappresenta la differenza di peso tra due workout
class WeightDifference {
  WeightDifference({
    required this.exerciseName,
    required this.previousWeight,
    required this.currentWeight,
    required this.differencePercent,
  });
  final String exerciseName;
  final double previousWeight;
  final double currentWeight;
  final double differencePercent;

  bool get isIncrease => differencePercent > 0;
  bool get isDecrease => differencePercent < 0;
  bool get isEqual => differencePercent == 0;
}
