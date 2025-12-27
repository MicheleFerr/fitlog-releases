/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// Exercise Suggestion Provider - Provides exercise suggestions from real database
///
/// **Features**:
/// - Uses real exercise database (1500+ exercises)
/// - Maps neglected muscles to database focus codes
/// - Provides correct countingMode for each exercise
/// - Excludes exercises already in user templates
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

/// Parameters for exercise suggestions query
class ExerciseSuggestionParams {
  const ExerciseSuggestionParams({
    required this.neglectedMuscles,
    this.maxPerMuscle = 4,
  });

  final List<NeglectedMuscle> neglectedMuscles;
  final int maxPerMuscle;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExerciseSuggestionParams) return false;
    if (neglectedMuscles.length != other.neglectedMuscles.length) return false;
    if (maxPerMuscle != other.maxPerMuscle) return false;

    for (var i = 0; i < neglectedMuscles.length; i++) {
      if (neglectedMuscles[i].muscleName != other.neglectedMuscles[i].muscleName) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(neglectedMuscles.map((m) => m.muscleName)),
        maxPerMuscle,
      );
}

/// Provider for exercise suggestions from real database
///
/// **Usage**:
/// ```dart
/// final suggestionsAsync = ref.watch(
///   exerciseSuggestionsProvider(
///     ExerciseSuggestionParams(neglectedMuscles: neglectedMuscles),
///   ),
/// );
///
/// suggestionsAsync.when(
///   loading: () => LoadingIndicator(),
///   error: (e, _) => ErrorWidget(e),
///   data: (suggestions) => ExerciseList(suggestions: suggestions),
/// );
/// ```
final exerciseSuggestionsProvider = FutureProvider.autoDispose
    .family<List<ExerciseSuggestion>, ExerciseSuggestionParams>(
  (ref, params) async {
    // Get all exercises from real database
    final allExercises = await ref.watch(allExercisesProvider.future);

    // Get user templates to exclude exercises already in templates
    final templates = await ref.watch(customWorkoutTemplatesProvider.future);

    // Extract exercise names from templates
    final exercisesInTemplates = <String>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        exercisesInTemplates.add(exercise.exerciseName);
        exercisesInTemplates.add(exercise.exerciseId);
      }
    }

    // Generate suggestions from real database
    final engine = ExerciseSuggestionEngine();
    final suggestions = engine.generateSuggestionsFromDatabase(
      neglectedMuscles: params.neglectedMuscles,
      allExercises: allExercises,
      maxPerMuscle: params.maxPerMuscle,
      excludeExercises: exercisesInTemplates,
    );

    return suggestions;
  },
);

/// Provider for exercise suggestions grouped by muscle
///
/// Better for UI display with muscle group sections.
///
/// **Usage**:
/// ```dart
/// final suggestionsAsync = ref.watch(
///   exerciseSuggestionsGroupedProvider(
///     ExerciseSuggestionParams(neglectedMuscles: neglectedMuscles),
///   ),
/// );
/// ```
final exerciseSuggestionsGroupedProvider = FutureProvider.autoDispose
    .family<Map<String, List<ExerciseSuggestion>>, ExerciseSuggestionParams>(
  (ref, params) async {
    // Get all exercises from real database
    final allExercises = await ref.watch(allExercisesProvider.future);

    // Get user templates to exclude exercises already in templates
    final templates = await ref.watch(customWorkoutTemplatesProvider.future);

    // Extract exercise names from templates
    final exercisesInTemplates = <String>{};
    for (final template in templates) {
      for (final exercise in template.exercises) {
        exercisesInTemplates.add(exercise.exerciseName);
        exercisesInTemplates.add(exercise.exerciseId);
      }
    }

    // Generate suggestions grouped by muscle from real database
    final engine = ExerciseSuggestionEngine();
    final suggestions = engine.generateSuggestionsGroupedByMuscle(
      neglectedMuscles: params.neglectedMuscles,
      allExercises: allExercises,
      maxPerMuscle: params.maxPerMuscle,
      excludeExercises: exercisesInTemplates,
    );

    return suggestions;
  },
);
