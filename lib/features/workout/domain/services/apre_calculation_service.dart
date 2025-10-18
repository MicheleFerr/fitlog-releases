/// 🏋️‍♂️ GymBro TrackLog - APRE Calculation Service
///
/// Servizio estratto da workout_provider.dart per calcoli APRE.
/// Migliora testability e separation of concerns.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

class APRECalculationService {

  APRECalculationService(this.ref);
  final Ref ref;

  // Track concurrent calculations
  bool _calculationInProgress = false;

  /// Pre-calculate APRE weights for all exercises in workout
  Future<List<Exercise>> preCalculateAllAPREWeights(List<Exercise> exercises) async {
    if (_calculationInProgress) {
      debugPrint('[APRE] ⚠️ Calculation already in progress - skipping');
      return exercises;
    }

    _calculationInProgress = true;
    debugPrint('[APRE] 🔒 Starting batch calculation');

    try {
      final apreExercises = exercises
          .where((ex) => ex.useAPRE && ex.type == ExerciseType.single)
          .toList();

      if (apreExercises.isEmpty) {
        debugPrint('[APRE] No APRE exercises to calculate');
        return exercises;
      }

      debugPrint('[APRE] Found ${apreExercises.length} APRE exercises');

      // Calculate in parallel
      final futures = apreExercises.map((exercise) =>
        _calculateForExercise(exercise)
      );

      final results = await Future.wait(futures);

      // Merge results back
      return exercises.map((exercise) {
        final updated = results.firstWhere(
          (result) => result != null && result.id == exercise.id,
          orElse: () => null,
        );
        return updated ?? exercise;
      }).toList();

    } finally {
      _calculationInProgress = false;
      debugPrint('[APRE] 🔓 Calculation complete');
    }
  }

  /// Calculate APRE weights for single exercise
  Future<Exercise?> _calculateForExercise(Exercise exercise) async {
    try {
      // Skip if recent calculations exist
      if (exercise.calculated1RM != null &&
          !_shouldRecalculate(exercise)) {
        debugPrint('[APRE] Using cached calculations for ${exercise.name}');
        return null;
      }

      // TODO: Get exercise history
      // final history = await ref.read(exerciseHistoryProvider(exercise.name).future);

      // TODO: Calculate using APREAutoRegulationService

      // Return updated exercise with calculations
      return exercise.copyWith(
        // calculated1RM: ...,
        // calculated3RM: ...,
        // etc.
        lastCalculationDate: DateTime.now(),
      );

    } catch (e) {
      debugPrint('[APRE] Error calculating for ${exercise.name}: $e');
      return null;
    }
  }

  /// Check if recalculation is needed
  bool _shouldRecalculate(Exercise exercise) {
    if (exercise.lastCalculationDate == null) return true;

    final daysSinceCalc = DateTime.now()
        .difference(exercise.lastCalculationDate!)
        .inDays;

    return daysSinceCalc > 7; // Recalculate weekly
  }
}

/// Provider
final apreCalculationServiceProvider = Provider<APRECalculationService>((ref) {
  return APRECalculationService(ref);
});
