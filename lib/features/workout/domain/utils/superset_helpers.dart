import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Helper class per gestire conversioni e operazioni sui superset
class SupersetHelpers {
  /// Converte SupersetExerciseData in ExerciseSet per compatibilità UI
  static ExerciseSet exerciseDataToSet(
    SupersetExerciseData data, {
    required int setNumber,
  }) {
    return ExerciseSet(
      setNumber: setNumber,
      weight: data.actualWeight ?? data.targetWeight,
      reps: data.targetReps,
      actualReps: data.actualReps,
      rpe: data.rpe,
      isCompleted: data.isCompleted,
      notes: data.notes,
    );
  }

  /// Converte ExerciseSet in SupersetExerciseData
  static SupersetExerciseData setToExerciseData(
    ExerciseSet set, {
    required String exerciseId,
    required String exerciseName,
    SupersetExerciseData? existingData,
  }) {
    return SupersetExerciseData(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      targetWeight: existingData?.targetWeight ?? set.weight,
      targetReps: existingData?.targetReps ?? set.reps,
      actualWeight: set.weight,
      actualReps: set.actualReps,
      rpe: set.rpe,
      isCompleted: set.isCompleted,
      notes: set.notes,
    );
  }

  /// Crea un nuovo SupersetSet con dati di default per tutti gli esercizi
  static SupersetSet createDefaultRound({
    required List<Exercise> exercises,
    required int roundNumber,
    SupersetSet? templateRound,
  }) {
    final Map<String, SupersetExerciseData> exerciseData = {};

    for (final exercise in exercises) {
      final templateData = templateRound?.exerciseData[exercise.id];
      exerciseData[exercise.id] = SupersetExerciseData(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        targetWeight: templateData?.targetWeight ?? templateData?.actualWeight ?? 0.0,
        targetReps: templateData?.targetReps ?? templateData?.actualReps ?? 10,
        actualWeight: null,
        actualReps: null,
        rpe: null,
        isCompleted: false,
        notes: null,
      );
    }

    return SupersetSet(
      setNumber: roundNumber,
      exerciseData: exerciseData,
      isCompleted: false,
    );
  }

  /// Valida che un SupersetSet contenga dati per tutti gli esercizi
  static bool validateSupersetSet(
    SupersetSet set,
    List<Exercise> exercises,
  ) {
    // Verifica che ci sia un exerciseData per ogni esercizio
    for (final exercise in exercises) {
      if (!set.exerciseData.containsKey(exercise.id)) {
        return false;
      }
    }
    return true;
  }

  /// Sincronizza un SupersetSet con la lista corrente di esercizi
  /// Aggiunge esercizi mancanti e rimuove quelli non più presenti
  static SupersetSet syncSupersetSetWithExercises(
    SupersetSet set,
    List<Exercise> exercises,
  ) {
    final updatedExerciseData = <String, SupersetExerciseData>{};

    // Copia i dati esistenti per gli esercizi ancora presenti
    for (final exercise in exercises) {
      if (set.exerciseData.containsKey(exercise.id)) {
        updatedExerciseData[exercise.id] = set.exerciseData[exercise.id]!;
      } else {
        // Aggiungi dati di default per nuovi esercizi
        updatedExerciseData[exercise.id] = SupersetExerciseData(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          targetWeight: 0.0,
          targetReps: 10,
          actualWeight: null,
          actualReps: null,
          rpe: null,
          isCompleted: false,
          notes: null,
        );
      }
    }

    return set.copyWith(
      exerciseData: updatedExerciseData,
      // Se erano tutti completati e abbiamo aggiunto esercizi, non è più completato
      isCompleted: set.isCompleted &&
                   updatedExerciseData.length == set.exerciseData.length,
    );
  }

  /// Aggiorna tutti i SupersetSet di un superset per sincronizzarli con gli esercizi
  static List<SupersetSet> syncAllSetsWithExercises(
    List<SupersetSet> sets,
    List<Exercise> exercises,
  ) {
    return sets.map((set) => syncSupersetSetWithExercises(set, exercises)).toList();
  }

  /// Calcola il volume totale di un SupersetSet
  static double calculateSetVolume(SupersetSet set) {
    double total = 0.0;
    for (final data in set.exerciseData.values) {
      final weight = data.actualWeight ?? data.targetWeight ?? 0.0;
      final reps = data.actualReps ?? data.targetReps ?? 0;
      total += weight * reps;
    }
    return total;
  }

  /// Verifica se un esercizio specifico in un set è completato
  static bool isExerciseCompletedInSet(
    SupersetSet set,
    String exerciseId,
  ) {
    final data = set.exerciseData[exerciseId];
    return data?.isCompleted ?? false;
  }

  /// Conta quanti esercizi sono completati in un set
  static int countCompletedExercises(SupersetSet set) {
    return set.exerciseData.values
        .where((data) => data.isCompleted)
        .length;
  }

  /// Aggiorna un singolo esercizio in un SupersetSet
  static SupersetSet updateExerciseInSet(
    SupersetSet set,
    String exerciseId,
    SupersetExerciseData updatedData,
  ) {
    final updatedExerciseData = Map<String, SupersetExerciseData>.from(set.exerciseData);
    updatedExerciseData[exerciseId] = updatedData;

    // Verifica se tutti gli esercizi sono ora completati
    final allCompleted = updatedExerciseData.values.every((data) => data.isCompleted);

    return set.copyWith(
      exerciseData: updatedExerciseData,
      isCompleted: allCompleted,
      completedAt: allCompleted ? DateTime.now() : null,
    );
  }
}
