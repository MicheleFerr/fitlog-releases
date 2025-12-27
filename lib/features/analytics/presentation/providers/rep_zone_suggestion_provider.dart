/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// Rep Zone Suggestion Provider - Riverpod provider for rep zone analysis
///
/// **Trigger Logic**:
/// - Analyzes user's training distribution
/// - Triggers suggestions when variety is low (>80% in one zone)
/// - Auto-detects best templates for suggestions
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/rep_zone_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

/// Provider for rep zone analysis
final repZoneAnalysisProvider = Provider.family<RepZoneAnalysis, List<ExerciseHistory>>((ref, histories) {
  final engine = RepZoneSuggestionEngine();
  return engine.analyzeDistribution(histories);
});

/// Provider for rep zone suggestions
final repZoneSuggestionsProvider = FutureProvider.family<List<RepZoneSuggestion>, List<ExerciseHistory>>((ref, histories) async {
  debugPrint('🔍 [REP_ZONE] Provider START - histories: ${histories.length}');

  try {
    // Get analysis
    debugPrint('🔍 [REP_ZONE] Step 1: Getting analysis...');
    final analysis = ref.watch(repZoneAnalysisProvider(histories));
    debugPrint('🔍 [REP_ZONE] Step 1 DONE: needsSuggestions=${analysis.needsSuggestions}, totalSets=${analysis.totalSets}');

    // Check if suggestions are needed
    if (!analysis.needsSuggestions) {
      debugPrint('🔍 [REP_ZONE] Early return: needsSuggestions=false');
      return [];
    }

    // Get templates - use read to avoid autoDispose issues
    debugPrint('🔍 [REP_ZONE] Step 2: Getting templates...');
    final templates = await ref.read(customWorkoutTemplatesProvider.future);
    debugPrint('🔍 [REP_ZONE] Step 2 DONE: ${templates.length} templates');

    if (templates.isEmpty) {
      debugPrint('🔍 [REP_ZONE] Early return: no templates');
      return [];
    }

    // Get exercise database - use read to avoid autoDispose issues
    debugPrint('🔍 [REP_ZONE] Step 3: Getting exercises...');
    final allExercises = await ref.read(allExercisesProvider.future);
    debugPrint('🔍 [REP_ZONE] Step 3 DONE: ${allExercises.length} exercises');

    // Get existing exercise IDs from templates
    final existingIds = <String>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        existingIds.add(exercise.exerciseId);
      }
    }
    debugPrint('🔍 [REP_ZONE] Step 4: ${existingIds.length} existing exercise IDs');

    // Generate suggestions
    debugPrint('🔍 [REP_ZONE] Step 5: Generating suggestions...');
    final engine = RepZoneSuggestionEngine();
    final suggestions = engine.generateSuggestions(
      analysis: analysis,
      templates: templates,
      allExercises: allExercises,
      existingExerciseIds: existingIds,
    );
    debugPrint('🔍 [REP_ZONE] Step 5 DONE: ${suggestions.length} suggestions generated');

    return suggestions;
  } catch (e, stack) {
    // Return empty list on error to prevent hanging
    debugPrint('❌ [REP_ZONE] ERROR: $e');
    debugPrint('❌ [REP_ZONE] STACK: $stack');
    return [];
  }
});

/// Provider to check if user needs optimization suggestions
final needsRepZoneOptimizationProvider = Provider.family<bool, List<ExerciseHistory>>((ref, histories) {
  final analysis = ref.watch(repZoneAnalysisProvider(histories));
  return analysis.needsSuggestions && analysis.totalSets >= RepZoneSuggestionEngine.minimumSetsForAnalysis;
});
