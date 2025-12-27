/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_merge/domain/services
/// 🎯 Feature: exercise_merge
/// 🔧 Type: service
///
/// Servizio per trovare e gestire candidati di merge esercizi
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_preview.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Servizio per identificare esercizi custom che potrebbero essere consolidati
///
/// **Logica di identificazione**:
/// 1. Prende tutti gli esercizi dalla history dell'utente
/// 2. Cerca quali NON hanno corrispondenza esatta nel database
/// 3. Per quelli senza match esatto, cerca match fuzzy
/// 4. Restituisce candidati con score > 50%
class ExerciseMergeService {
  /// Soglia minima per considerare un match (50%)
  static const double _minMatchThreshold = 0.50;

  /// Soglia per match di alta qualità (75%)
  static const double _highQualityThreshold = 0.75;

  /// Trova tutti gli esercizi custom che potrebbero essere mergati
  ///
  /// [exerciseHistories] - Storico esercizi dell'utente
  /// [databaseExercises] - Esercizi dal database ufficiale
  ///
  /// Returns: Lista di candidati ordinati per qualità del match
  static Future<List<MergeCandidate>> findMergeCandidates({
    required List<ExerciseHistory> exerciseHistories,
    required List<Exercise> databaseExercises,
  }) async {
    final candidates = <MergeCandidate>[];

    // Crea set di nomi esercizi del database (lowercase per confronto)
    final databaseNames = databaseExercises
        .map((e) => e.nome.toLowerCase())
        .toSet();

    // Trova esercizi senza match esatto
    for (final history in exerciseHistories) {
      final exerciseName = history.exerciseName;
      final normalizedName = exerciseName.toLowerCase();

      // Skip se ha match esatto nel database
      if (databaseNames.contains(normalizedName)) {
        continue;
      }

      // Cerca match fuzzy
      final fuzzyResults = await ExerciseFuzzyMatcher.searchExercises(
        exercises: databaseExercises,
        query: exerciseName,
        strictThreshold: _highQualityThreshold,
        typeThreshold: _minMatchThreshold,
        maxResults: 5, // Top 5 candidati
      );

      // Skip se non ci sono match sopra la soglia
      if (fuzzyResults.isEmpty ||
          fuzzyResults.first.score < _minMatchThreshold) {
        continue;
      }

      // Converti risultati fuzzy in ExerciseMatch
      final matches = fuzzyResults
          .where((r) => r.score >= _minMatchThreshold)
          .map((r) => ExerciseMatch(
                exercise: r.exercise,
                score: r.score,
                matchedOn: r.matchedText,
              ))
          .toList();

      // Calcola statistiche dalla history
      final sessions = history.sessions;
      final lastUsed = sessions.isNotEmpty
          ? sessions.map((s) => s.date).reduce((a, b) => a.isAfter(b) ? a : b)
          : DateTime.now();

      candidates.add(MergeCandidate(
        customExerciseName: exerciseName,
        sessionCount: sessions.length,
        lastUsed: lastUsed,
        matchingExercises: matches,
        personalRecord: history.personalRecord,
      ));
    }

    // Ordina per: 1) qualità match, 2) numero sessioni
    candidates.sort((a, b) {
      // Prima per score (decrescente)
      final scoreCompare = b.bestMatchScore.compareTo(a.bestMatchScore);
      if (scoreCompare != 0) return scoreCompare;

      // Poi per numero sessioni (decrescente)
      return b.sessionCount.compareTo(a.sessionCount);
    });

    if (kDebugMode) {
      debugPrint('🔀 Found ${candidates.length} merge candidates');
    }

    return candidates;
  }

  /// Genera preview del merge
  ///
  /// [sourceExerciseName] - Nome esercizio custom da mergare
  /// [targetExercise] - Esercizio target del database
  /// [exerciseHistories] - Per calcolare statistiche
  /// [templates] - Per contare template affected
  static MergePreview generateMergePreview({
    required String sourceExerciseName,
    required Exercise targetExercise,
    required List<ExerciseHistory> exerciseHistories,
    required List<WorkoutTemplate> templates,
  }) {
    // Trova history dell'esercizio sorgente
    final sourceHistory = exerciseHistories.firstWhere(
      (h) => h.exerciseName.toLowerCase() == sourceExerciseName.toLowerCase(),
      orElse: () => ExerciseHistory(
        exerciseName: sourceExerciseName,
        muscleGroup: '',
        sessions: [],
      ),
    );

    // Trova history dell'esercizio target (se esiste)
    final targetHistory = exerciseHistories
        .where(
          (h) =>
              h.exerciseName.toLowerCase() == targetExercise.nome.toLowerCase(),
        )
        .firstOrNull;

    // Calcola PR dopo merge
    final sourcePR = sourceHistory.personalRecord;
    final targetPR = targetHistory?.personalRecord ?? 0;
    final newPR = sourcePR > targetPR ? sourcePR : targetPR;

    // Conta template affected
    final templatesAffected = templates.where((t) {
      return t.exercises.any((e) =>
          e.exerciseName.toLowerCase() == sourceExerciseName.toLowerCase());
    }).length;

    return MergePreview(
      sourceExerciseName: sourceExerciseName,
      targetExerciseName: targetExercise.nome,
      targetExerciseId: targetExercise.id,
      sessionsToMerge: sourceHistory.sessions.length,
      templatesAffected: templatesAffected,
      currentPR: sourcePR > 0 ? sourcePR : null,
      newPR: newPR > 0 ? newPR : null,
      targetMuscleGroups: targetExercise.focus,
      targetSecondaryMuscles: targetExercise.muscoliSecondari,
    );
  }

  /// Conta il numero totale di candidati disponibili
  static Future<int> countMergeCandidates({
    required List<ExerciseHistory> exerciseHistories,
    required List<Exercise> databaseExercises,
  }) async {
    final candidates = await findMergeCandidates(
      exerciseHistories: exerciseHistories,
      databaseExercises: databaseExercises,
    );
    return candidates.length;
  }

  /// Filtra candidati per qualità (solo high quality)
  static List<MergeCandidate> filterHighQualityCandidates(
    List<MergeCandidate> candidates,
  ) {
    return candidates.where((c) => c.hasHighQualityMatch).toList();
  }
}
