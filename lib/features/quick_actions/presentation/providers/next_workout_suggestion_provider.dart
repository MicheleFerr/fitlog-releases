/// Next Workout Suggestion Provider
///
/// Combines SplitDetectionService with template matching to provide
/// smart workout suggestions for the Quick Actions overlay.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/quick_actions/domain/services/split_detection_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/template_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Suggestion for next workout to display in Quick Actions
class NextWorkoutSuggestion {
  const NextWorkoutSuggestion({
    required this.type,
    this.suggestedCategory,
    this.templateId,
    this.templateName,
    this.daysSinceLast,
    this.isImbalance = false,
    this.detectedCycle,
  });

  final SplitDetectionType type;
  final ExerciseCategory? suggestedCategory;
  final String? templateId;
  final String? templateName;
  final int? daysSinceLast;
  final bool isImbalance;
  final List<ExerciseCategory>? detectedCycle;
}

/// Provider that computes the next workout suggestion
///
/// Combines split detection with template matching.
/// keepAlive with TTL of 5 minutes via Timer-based disposal.
final nextWorkoutSuggestionProvider =
    FutureProvider.autoDispose<NextWorkoutSuggestion>((ref) async {
      // Keep alive for 5 minutes to avoid recomputation
      final link = ref.keepAlive();
      Timer(const Duration(minutes: 5), link.close);

      // Get recent workouts (last 21 days)
      final workoutsAsync = ref.watch(workoutHistoryProvider);

      final workouts = workoutsAsync.when(
        data: (list) => list,
        loading: () => <dynamic>[],
        error: (_, __) => <dynamic>[],
      );

      if (workouts.isEmpty) {
        return const NextWorkoutSuggestion(type: SplitDetectionType.newUser);
      }

      // Filter to last 21 days
      final cutoff = DateTime.now().subtract(const Duration(days: 21));
      final recentWorkouts = workouts
          .where((w) => w.completedAt.isAfter(cutoff))
          .toList();

      // Run split detection
      final result = SplitDetectionService.detect(
        workouts: recentWorkouts,
      );

      // Try to find a matching template
      String? matchedTemplateId;
      String? matchedTemplateName;

      if (result.suggestedCategory != null) {
        final templateAnalyses = ref.watch(
          templateSuggestionProvider.select((async) => async.value),
        );

        if (templateAnalyses != null && templateAnalyses.isNotEmpty) {
          final matchingTemplate = _findTemplateForCategory(
            templateAnalyses,
            result.suggestedCategory!,
          );

          if (matchingTemplate != null) {
            matchedTemplateId = matchingTemplate.templateId;
            matchedTemplateName = matchingTemplate.templateName;
          }
        }
      }

      return NextWorkoutSuggestion(
        type: result.type,
        suggestedCategory: result.suggestedCategory,
        templateId: matchedTemplateId,
        templateName: matchedTemplateName,
        daysSinceLast: result.daysSinceLastForCategory,
        isImbalance: result.isImbalanceDetected,
        detectedCycle: result.detectedCycle,
      );
    });

/// Find the best template whose primary muscles match the suggested category
TemplateStressAnalysis? _findTemplateForCategory(
  List<TemplateStressAnalysis> analyses,
  ExerciseCategory category,
) {
  // Map ExerciseCategory to muscle abbreviation prefixes
  final musclePatterns = _categoryToMusclePatterns(category);

  if (musclePatterns.isEmpty) return null;

  // Find templates where primary muscles overlap with the category
  TemplateStressAnalysis? bestMatch;
  var bestScore = -1.0;

  for (final analysis in analyses) {
    // Count how many primary muscles match the category
    final matchCount = analysis.primaryMuscles.where((muscle) {
      final upperMuscle = muscle.toUpperCase();
      return musclePatterns.any((pattern) => upperMuscle.startsWith(pattern));
    }).length;

    if (matchCount > 0 && analysis.optimalityScore > bestScore) {
      bestScore = analysis.optimalityScore;
      bestMatch = analysis;
    }
  }

  return bestMatch;
}

/// Map ExerciseCategory to muscle abbreviation patterns for matching
List<String> _categoryToMusclePatterns(ExerciseCategory category) {
  return switch (category) {
    ExerciseCategory.chest => ['PETT', 'TRIC'],
    ExerciseCategory.back => ['DORS', 'TRAP', 'LOMB', 'BICI'],
    ExerciseCategory.shoulders => ['DELT', 'TRAP'],
    ExerciseCategory.arms => ['BICI', 'TRIC', 'AVBR'],
    ExerciseCategory.legs => ['QUAD', 'FEMO', 'GLUT', 'POLL', 'TIBI'],
    ExerciseCategory.abs => ['RETT', 'OBLI', 'TRAS'],
    ExerciseCategory.cardio => [],
    ExerciseCategory.other => [],
  };
}
