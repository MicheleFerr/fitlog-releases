/// Provider per gestione upgrade esercizi inline nel workout
///
/// Fornisce una mappa cached di esercizi custom che hanno match
/// nel database ufficiale con soglia >= 60%.
///
/// Usato per mostrare l'icona upgrade inline nell'header esercizio.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/presentation/providers/exercise_merge_providers.dart';

/// Soglia minima per mostrare icona upgrade (60%)
const double kUpgradeMatchThreshold = 0.60;

/// Provider per mappa lookup veloce: exerciseName -> MergeCandidate
///
/// Restituisce solo candidati con score >= 60%
/// Usato per O(1) lookup nell'header esercizio
final upgradeMatchesMapProvider =
    Provider.autoDispose<Map<String, MergeCandidate>>((ref) {
  final candidatesAsync = ref.watch(mergeCandidatesProvider);
  final candidates = candidatesAsync.valueOrNull ?? [];

  // Filtra per soglia 60% e crea mappa per lookup veloce
  final Map<String, MergeCandidate> matchesMap = {};

  for (final candidate in candidates) {
    if (candidate.bestMatchScore >= kUpgradeMatchThreshold) {
      // Normalizza il nome per matching case-insensitive
      final normalizedName = candidate.customExerciseName.toLowerCase();
      matchesMap[normalizedName] = candidate;
    }
  }

  return matchesMap;
});

/// Provider per verificare se un esercizio specifico ha upgrade disponibile
///
/// Usage: ref.watch(hasUpgradeAvailableProvider('Curl Manubri'))
final hasUpgradeAvailableProvider =
    Provider.autoDispose.family<bool, String>((ref, exerciseName) {
  final matchesMap = ref.watch(upgradeMatchesMapProvider);
  final normalizedName = exerciseName.toLowerCase();
  return matchesMap.containsKey(normalizedName);
});

/// Provider per ottenere il candidato upgrade per un esercizio
///
/// Usage: ref.watch(upgradeMatchForExerciseProvider('Curl Manubri'))
final upgradeMatchForExerciseProvider =
    Provider.autoDispose.family<MergeCandidate?, String>((ref, exerciseName) {
  final matchesMap = ref.watch(upgradeMatchesMapProvider);
  final normalizedName = exerciseName.toLowerCase();
  return matchesMap[normalizedName];
});

/// Provider per conteggio esercizi upgradabili nel workout corrente
///
/// [exerciseNames] - Lista nomi esercizi nel workout attivo
final upgradableExercisesCountProvider =
    Provider.autoDispose.family<int, List<String>>((ref, exerciseNames) {
  final matchesMap = ref.watch(upgradeMatchesMapProvider);

  int count = 0;
  for (final name in exerciseNames) {
    final normalizedName = name.toLowerCase();
    if (matchesMap.containsKey(normalizedName)) {
      count++;
    }
  }
  return count;
});
