/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/usecases
/// 🎯 Feature: flexible_routine
/// 🔧 Type: use case
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// TEMPLATE SCORER USE CASE - Muscle Group Coverage Scoring
///
/// Scores workout templates based on muscle group coverage (0.0-1.0).
/// Used for suggesting templates during routine creation.
///
/// Algorithm:
/// - Score = (covered muscle groups ∩ desired muscle groups) / desired muscle groups
/// - Example: Template covers {Chest, Triceps}, desired {Chest, Triceps, Shoulders}
///   → Score = 2/3 = 0.67
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Use case for scoring workout templates against desired muscle groups
///
/// Usage:
/// ```dart
/// final scorer = TemplateScorer();
/// final score = scorer.scoreTemplate(
///   template: chestTemplate,
///   desiredMuscleGroups: {'Chest', 'Triceps', 'Shoulders'},
/// );
/// // score = 0.67 if template covers Chest + Triceps only
/// ```
class TemplateScorer {
  /// Score a template against desired muscle groups
  ///
  /// Parameters:
  /// - template: WorkoutTemplate to score
  /// - desiredMuscleGroups: Set of muscle group names to match against
  ///
  /// Returns:
  /// - 0.0 if no overlap (template covers 0 desired muscle groups)
  /// - 1.0 if perfect match (template covers all desired muscle groups)
  /// - 0.0-1.0 for partial overlap (percentage of desired groups covered)
  double scoreTemplate({
    required WorkoutTemplate template,
    required Set<String> desiredMuscleGroups,
  }) {
    // Edge case: no desired muscle groups → score is 0.0
    if (desiredMuscleGroups.isEmpty) {
      return 0.0;
    }

    // Extract muscle groups from template exercises
    final templateMuscleGroups = _extractMuscleGroupsFromTemplate(template);

    // Edge case: template has no exercises → score is 0.0
    if (templateMuscleGroups.isEmpty) {
      return 0.0;
    }

    // Calculate intersection (muscle groups covered by template AND desired)
    final coveredGroups = templateMuscleGroups.intersection(desiredMuscleGroups);

    // Score = covered / desired (percentage of desired groups covered)
    return coveredGroups.length / desiredMuscleGroups.length;
  }

  /// Extract unique muscle groups from template exercises
  ///
  /// Returns:
  /// - Set of unique muscle group names (normalized to lowercase)
  ///
  /// NOTE: Stub implementation for v2.0 MVP
  /// ExerciseTemplate doesn't have muscle group info (only Exercise entity does)
  /// For now, returns desiredMuscleGroups to always score 1.0 (perfect match)
  /// TODO: Enhance when needed - requires Exercise lookup by exerciseName
  Set<String> _extractMuscleGroupsFromTemplate(WorkoutTemplate template) {
    // Stub: return empty set for now
    // This will cause all templates to score 0.0
    // User will manually select templates anyway in v2.0 wizard
    return {};
  }

  /// Score multiple templates and return sorted by score (highest first)
  ///
  /// Parameters:
  /// - templates: List of templates to score
  /// - desiredMuscleGroups: Set of muscle group names to match against
  ///
  /// Returns:
  /// - List of (template, score) tuples sorted by score descending
  List<TemplateScoringResult> scoreMultipleTemplates({
    required List<WorkoutTemplate> templates,
    required Set<String> desiredMuscleGroups,
  }) {
    final results = <TemplateScoringResult>[];

    for (final template in templates) {
      final score = scoreTemplate(
        template: template,
        desiredMuscleGroups: desiredMuscleGroups,
      );

      results.add(TemplateScoringResult(
        template: template,
        score: score,
      ));
    }

    // Sort by score descending (highest score first)
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }
}

/// Scoring result for a single template
class TemplateScoringResult {
  const TemplateScoringResult({
    required this.template,
    required this.score,
  });

  final WorkoutTemplate template;
  final double score; // 0.0-1.0
}
