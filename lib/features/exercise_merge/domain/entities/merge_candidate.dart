/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/domain/entities
/// 🎯 Feature: exercise_merge
/// 🔧 Type: entity
///
/// Rappresenta un candidato per il merge di esercizi simili
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Candidato per merge esercizio
///
/// Contiene le informazioni su un esercizio custom che potrebbe
/// essere consolidato con un esercizio del database.
class MergeCandidate {
  const MergeCandidate({
    required this.customExerciseName,
    required this.sessionCount,
    required this.lastUsed,
    required this.matchingExercises,
    this.personalRecord,
  });

  /// Nome dell'esercizio custom (quello da mergare)
  final String customExerciseName;

  /// Numero di sessioni con questo esercizio
  final int sessionCount;

  /// Ultima volta che è stato usato
  final DateTime lastUsed;

  /// Esercizi del database che potrebbero corrispondere
  final List<ExerciseMatch> matchingExercises;

  /// Personal record (1RM stimato) per questo esercizio
  final double? personalRecord;

  /// Best match score (0.0-1.0)
  double get bestMatchScore =>
      matchingExercises.isNotEmpty ? matchingExercises.first.score : 0.0;

  /// Verifica se ha match di alta qualità (>75%)
  bool get hasHighQualityMatch => bestMatchScore >= 0.75;

  @override
  String toString() =>
      'MergeCandidate($customExerciseName → ${matchingExercises.length} matches)';
}

/// Match tra esercizio custom e esercizio del database
class ExerciseMatch {
  const ExerciseMatch({
    required this.exercise,
    required this.score,
    required this.matchedOn,
  });

  /// Esercizio del database
  final Exercise exercise;

  /// Score di similarità (0.0-1.0)
  final double score;

  /// Su cosa ha matchato (nome, sinonimo, etc.)
  final String matchedOn;

  /// Score come percentuale formattata
  String get scorePercentage => '${(score * 100).toStringAsFixed(0)}%';

  @override
  String toString() => 'ExerciseMatch(${exercise.nome}, $scorePercentage)';
}
