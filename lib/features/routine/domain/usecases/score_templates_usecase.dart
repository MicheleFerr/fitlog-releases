/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/usecases
/// 🎯 Feature: flexible_routine
/// 🔧 Type: use_case
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// TEMPLATE SCORER USE CASE - v2.0
///
/// Scores workout templates based on muscle group relevance for a given
/// routine preset and day of week.
///
/// Algorithm:
/// - Calculates overlap between template's muscle groups and preset's expected groups
/// - Returns relevance score 0.0-1.0 (1.0 = perfect match, 0.0 = no match)
/// - Sorts templates by score descending (best matches first)
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';

/// Scores and ranks workout templates based on relevance to a routine preset day
///
/// Use Case Pattern:
/// ```dart
/// final scorer = ScoreTemplatesUseCase();
/// final scored = scorer.call(
///   preset: RoutinePreset.ppl6Day,
///   dayOfWeek: 1, // Monday
///   userTemplates: allTemplates,
/// );
/// final bestMatch = scored.first.$1; // Template with highest score
/// final score = scored.first.$2; // Score 0.0-1.0
/// ```
class ScoreTemplatesUseCase {
  /// Score and rank templates for a specific preset day
  ///
  /// Parameters:
  /// - [preset]: The routine preset type (PPL, Upper/Lower, etc.)
  /// - [dayOfWeek]: The day to score for (1 = Monday, 7 = Sunday)
  /// - [userTemplates]: List of user's workout templates to score
  ///
  /// Returns:
  /// - List of (WorkoutTemplate, score) tuples sorted by score descending
  /// - Empty list if [userTemplates] is empty or [preset] is custom
  ///
  /// Score calculation:
  /// - 1.0: Perfect match (all expected muscle groups present)
  /// - 0.5: Partial match (50% of expected muscle groups)
  /// - 0.0: No match (no expected muscle groups present)
  List<(WorkoutTemplate, double)> call({
    required RoutinePreset preset,
    required int dayOfWeek,
    required List<WorkoutTemplate> userTemplates,
  }) {
    // Custom presets have no expected pattern, return empty scoring
    if (preset == RoutinePreset.custom) {
      return [];
    }

    // Empty templates list, return empty scoring
    if (userTemplates.isEmpty) {
      return [];
    }

    // Get expected muscle groups for this preset + day
    final expectedMuscleGroups = preset.expectedMuscleGroupsForDay(dayOfWeek);

    // If no expected groups (e.g., rest day), return empty scoring
    if (expectedMuscleGroups.isEmpty) {
      return [];
    }

    // Score each template
    final scored = userTemplates.map((template) {
      final score = _calculateRelevance(
        templateMuscleGroups: template.effectiveMuscleGroups
            .map((category) => category.name)
            .toSet(),
        expectedGroups: expectedMuscleGroups,
      );
      return (template, score);
    }).toList();

    // Sort by score descending (highest scores first)
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored;
  }

  /// Calculate relevance score between template and expected muscle groups
  ///
  /// Algorithm:
  /// - Intersection: Count matching muscle groups
  /// - Divide by expected groups count
  /// - Result: 0.0 (no match) to 1.0 (perfect match)
  ///
  /// Examples:
  /// - Expected: {chest, shoulders, triceps} (3 groups)
  ///   Template: {chest, shoulders} (2 groups)
  ///   Score: 2/3 = 0.67 (67% match)
  ///
  /// - Expected: {back, biceps} (2 groups)
  ///   Template: {back, biceps} (2 groups)
  ///   Score: 2/2 = 1.0 (100% match)
  ///
  /// - Expected: {quads, hamstrings, glutes} (3 groups)
  ///   Template: {chest, shoulders} (0 match)
  ///   Score: 0/3 = 0.0 (0% match)
  double _calculateRelevance({
    required Set<String> templateMuscleGroups,
    required Set<String> expectedGroups,
  }) {
    if (expectedGroups.isEmpty) {
      return 0.0;
    }

    final intersection = templateMuscleGroups.intersection(expectedGroups).length;
    return intersection / expectedGroups.length;
  }

  /// Get top N templates by score
  ///
  /// Convenience method to get only the best matches.
  ///
  /// Example:
  /// ```dart
  /// final topTemplates = scorer.getTopTemplates(
  ///   scored: allScored,
  ///   count: 5,
  /// );
  /// ```
  List<(WorkoutTemplate, double)> getTopTemplates({
    required List<(WorkoutTemplate, double)> scored,
    required int count,
  }) {
    return scored.take(count).toList();
  }

  /// Filter templates by minimum score threshold
  ///
  /// Example:
  /// ```dart
  /// // Get templates with at least 50% relevance
  /// final relevant = scorer.filterByMinScore(
  ///   scored: allScored,
  ///   minScore: 0.5,
  /// );
  /// ```
  List<(WorkoutTemplate, double)> filterByMinScore({
    required List<(WorkoutTemplate, double)> scored,
    required double minScore,
  }) {
    return scored.where((item) => item.$2 >= minScore).toList();
  }

  /// Get suggested template for a day (highest score ≥ threshold)
  ///
  /// Returns null if no template meets the minimum score.
  ///
  /// Example:
  /// ```dart
  /// final suggestion = scorer.getSuggestedTemplate(
  ///   preset: RoutinePreset.ppl6Day,
  ///   dayOfWeek: 1,
  ///   userTemplates: allTemplates,
  ///   minScore: 0.5, // At least 50% relevance required
  /// );
  /// ```
  WorkoutTemplate? getSuggestedTemplate({
    required RoutinePreset preset,
    required int dayOfWeek,
    required List<WorkoutTemplate> userTemplates,
    double minScore = 0.5,
  }) {
    final scored = call(
      preset: preset,
      dayOfWeek: dayOfWeek,
      userTemplates: userTemplates,
    );

    if (scored.isEmpty) return null;

    final bestMatch = scored.first;
    if (bestMatch.$2 < minScore) return null;

    return bestMatch.$1;
  }
}
