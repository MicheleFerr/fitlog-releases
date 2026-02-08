/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/domain/entities
/// 🎯 Feature: exercise_merge
/// 🔧 Type: entity
///
/// Preview delle modifiche che verranno applicate dal merge
library;

/// Preview di un merge esercizio
///
/// Mostra all'utente esattamente cosa cambierà prima di confermare.
class MergePreview {
  const MergePreview({
    required this.sourceExerciseName,
    required this.targetExerciseName,
    required this.targetExerciseId,
    required this.sessionsToMerge,
    required this.templatesAffected,
    required this.currentPR,
    required this.newPR,
    required this.targetMuscleGroups,
    required this.targetSecondaryMuscles,
  });

  /// Nome esercizio sorgente (custom)
  final String sourceExerciseName;

  /// Nome esercizio target (database)
  final String targetExerciseName;

  /// ID esercizio target nel database
  final String targetExerciseId;

  /// Numero di sessioni che verranno migrate
  final int sessionsToMerge;

  /// Numero di template workout che verranno aggiornati
  final int templatesAffected;

  /// PR attuale dell'esercizio custom
  final double? currentPR;

  /// Nuovo PR dopo il merge (potrebbe cambiare se target ha già history)
  final double? newPR;

  /// Muscoli primari dell'esercizio target
  final List<String> targetMuscleGroups;

  /// Muscoli secondari dell'esercizio target
  final List<String> targetSecondaryMuscles;

  /// Verifica se il PR cambierà
  bool get prWillChange =>
      currentPR != null && newPR != null && currentPR != newPR;

  /// Verifica se il PR aumenterà (positivo)
  bool get prWillIncrease =>
      currentPR != null && newPR != null && newPR! > currentPR!;
}

/// Risultato dell'operazione di merge
class MergeResult {
  const MergeResult({
    required this.success,
    required this.sessionsUpdated,
    required this.templatesUpdated,
    this.errorMessage,
  });

  /// Factory per successo
  factory MergeResult.success({
    required int sessionsUpdated,
    required int templatesUpdated,
  }) => MergeResult(
    success: true,
    sessionsUpdated: sessionsUpdated,
    templatesUpdated: templatesUpdated,
  );

  /// Factory per errore
  factory MergeResult.failure(String message) => MergeResult(
    success: false,
    sessionsUpdated: 0,
    templatesUpdated: 0,
    errorMessage: message,
  );

  /// Merge completato con successo
  final bool success;

  /// Numero di sessioni aggiornate
  final int sessionsUpdated;

  /// Numero di template aggiornati
  final int templatesUpdated;

  /// Messaggio di errore (se fallito)
  final String? errorMessage;
}
