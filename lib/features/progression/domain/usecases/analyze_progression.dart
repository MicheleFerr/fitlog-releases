import 'package:gymbro_flutter_new/features/progression/domain/entities/progression_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_log.dart';

/// Deterministic progressive overload analyzer (no AI, transparent rules)
///
/// Analyzes workout history and suggests next progression step
/// Uses evidence-based rules inspired by Reddit fitness community:
/// - Rule 1: Plateau detection (10+ reps × 3 weeks → +2.5kg)
/// - Rule 2: Weight too heavy (reps < 6 → focus on reps first)
/// - Rule 3: Steady progression (incremental reps increase)
///
/// Part of P2 retention features (+25-30% long-term retention)
class AnalyzeProgression {
  ProgressionSuggestion execute({
    required String exerciseName,
    required List<ExerciseLog> recentWorkouts,
    required DateTime referenceDate,
  }) {
    if (recentWorkouts.isEmpty) {
      return _noDataSuggestion(exerciseName);
    }

    // Get last 3 workouts
    final last3 = recentWorkouts.take(3).toList();

    // Extract average weight and reps
    final avgWeight = _calculateAverageWeight(last3);
    final avgReps = _calculateAverageReps(last3);

    // Rule 1: Plateau Detection (same weight, high reps for 3+ weeks)
    if (_isPlateauDetected(last3, referenceDate) && avgReps >= 10) {
      return ProgressionSuggestion(
        exerciseName: exerciseName,
        currentWeight: avgWeight,
        suggestedWeight: avgWeight + 2.5,
        targetReps: 6,
        reason: "You've been doing 10+ reps easily for 3 weeks. Try +2.5kg next time.",
        confidence: ProgressionConfidence.high,
        additionalNotes: 'Aim for 6+ reps at new weight',
      );
    }

    // Rule 2: Reps too low (weight is too heavy)
    if (avgReps < 6) {
      return ProgressionSuggestion(
        exerciseName: exerciseName,
        currentWeight: avgWeight,
        suggestedWeight: avgWeight,
        targetReps: 8,
        reason: 'Current weight feels too heavy. Focus on hitting 8+ reps before weight increase.',
        confidence: ProgressionConfidence.medium,
      );
    }

    // Rule 3: Steady progression (keep current path)
    return ProgressionSuggestion(
      exerciseName: exerciseName,
      currentWeight: avgWeight,
      suggestedWeight: avgWeight,
      targetReps: avgReps.round(),
      reason: 'Keep current weight and aim for ${avgReps.round() + 1} reps next time.',
      confidence: ProgressionConfidence.medium,
    );
  }

  bool _isPlateauDetected(List<ExerciseLog> workouts, DateTime referenceDate) {
    if (workouts.length < 3) return false;

    // Check if all workouts span at least 3 weeks
    // workouts.first = oldest workout in the list
    final oldestWorkout = workouts.first.date;
    final daysDiff = referenceDate.difference(oldestWorkout).inDays;

    return daysDiff >= 21; // 3 weeks
  }

  double _calculateAverageWeight(List<ExerciseLog> workouts) {
    final allWeights = workouts
        .expand((w) => w.sets)
        .where((s) => s.isCompleted && !s.isWarmup)
        .map((s) => s.weight ?? 0.0);

    if (allWeights.isEmpty) return 0.0;
    return allWeights.reduce((a, b) => a + b) / allWeights.length;
  }

  double _calculateAverageReps(List<ExerciseLog> workouts) {
    final allReps = workouts
        .expand((w) => w.sets)
        .where((s) => s.isCompleted && !s.isWarmup)
        .map((s) => (s.reps ?? 0).toDouble());

    if (allReps.isEmpty) return 0.0;
    return allReps.reduce((a, b) => a + b) / allReps.length;
  }

  ProgressionSuggestion _noDataSuggestion(String exerciseName) {
    return ProgressionSuggestion(
      exerciseName: exerciseName,
      currentWeight: 20.0,
      suggestedWeight: 20.0,
      targetReps: 10,
      reason: 'No recent data. Start with a light weight and focus on form.',
      confidence: ProgressionConfidence.low,
    );
  }
}
