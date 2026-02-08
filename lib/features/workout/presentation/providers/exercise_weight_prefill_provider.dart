import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';

// ---------------------------------------------------------------------------
// Entity
// ---------------------------------------------------------------------------

/// Source of the weight pre-fill suggestion.
enum PrefillSource {
  /// Last recorded weight from workout history.
  history,

  /// History-based with +2.5 kg progressive overload bump.
  progressiveOverload,

  /// Calculated from 1RM × intensity via strength standards.
  strengthStandard,

  /// Conservative fallback (30 % bodyweight).
  fallback,
}

/// A weight + reps suggestion for pre-filling a new exercise's sets.
class WeightPrefill {
  const WeightPrefill({
    required this.weight,
    required this.reps,
    required this.source,
    this.confidence,
  });

  final double weight;
  final int reps;
  final PrefillSource source;
  final double? confidence;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Returns a [WeightPrefill] for [exerciseName].
///
/// Priority: history → strength standard → fallback → null.
///
/// The key is the **exercise name** (not id), because
/// [ExerciseHistoryService] matches by name.
/// 🔧 PERFORMANCE FIX: Added keepAlive to cache prefill calculations
final exerciseWeightPrefillProvider = FutureProvider.autoDispose
    .family<WeightPrefill?, String>((ref, exerciseName) async {
      // FIX: keepAlive to cache weight calculations during session
      ref.keepAlive();

      // ── 1. History ──────────────────────────────────────────────────────────
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        final historyService = ref.read(exerciseHistoryServiceProvider);
        final lastData = await historyService.getLastExerciseData(
          exerciseName,
          userId,
        );

        if (lastData.weight != null) {
          // Fetch last N session-weights (including duplicates) for overload check
          final history = await historyService.getExerciseHistory(
            exerciseName,
            userId,
            limit: 10,
          );

          // Group by workout date and take the max weight per session
          final sessionWeights = _extractSessionWeights(history, limit: 4);
          final shouldIncrease = _shouldProgressiveOverload(
            sessionWeights,
            lastData.weight!,
          );

          return WeightPrefill(
            weight: shouldIncrease ? lastData.weight! + 2.5 : lastData.weight!,
            reps: 10,
            source: shouldIncrease
                ? PrefillSource.progressiveOverload
                : PrefillSource.history,
          );
        }
      }

      // ── 2. Strength standard ───────────────────────────────────────────────
      final questionnaire = ref.read(userFitnessQuestionnaireProvider);
      if (questionnaire != null && questionnaire.isValid) {
        final service = ref.read(weightSuggestionServiceProvider);
        final repository = ref.read(strengthStandardsRepositoryProvider);

        // exerciseName may not be a valid exerciseId for the mapping lookup,
        // but the repository does a name-based search internally.
        final mapping = await repository.getMappingForExercise(exerciseName);

        StrengthStandard? standard;
        if (mapping != null &&
            mapping.canSuggestWeight &&
            mapping.standardId != null) {
          standard = await repository.getStrengthStandardById(
            mapping.standardId!,
          );
        }

        final suggestion = service.getSuggestedWeight(
          exerciseId: exerciseName,
          questionnaire: questionnaire,
          mapping: mapping,
          standard: standard,
        );

        if (suggestion != null) {
          return WeightPrefill(
            weight: suggestion.suggestedWeightKg,
            reps: suggestion.suggestedReps,
            source: PrefillSource.strengthStandard,
            confidence: suggestion.confidence,
          );
        }
      }

      // ── 3. null – no suggestion available ──────────────────────────────────
      return null;
    });

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// From a flat list of [ExerciseHistoryData], extract the **max weight per
/// unique workout-day** (most-recent first), up to [limit] sessions.
List<double> _extractSessionWeights(
  List<ExerciseHistoryData> history, {
  int limit = 4,
}) {
  final seen = <String>{};
  final weights = <double>[];

  for (final data in history) {
    if (data.weight == null) continue;
    final dayKey = '${data.date.year}-${data.date.month}-${data.date.day}';
    if (seen.contains(dayKey)) continue;
    seen.add(dayKey);
    weights.add(data.weight!);
    if (weights.length >= limit) break;
  }

  return weights;
}

/// Returns `true` when the last 4 sessions all used the same weight
/// (±0.1 kg), signaling that a progressive overload bump is warranted.
bool _shouldProgressiveOverload(
  List<double> sessionWeights,
  double currentWeight,
) {
  if (sessionWeights.length < 4) return false;
  return sessionWeights.take(4).every((w) => (w - currentWeight).abs() < 0.1);
}
