/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/services
/// Feature: analytics
/// Type: service
///
/// Exercise Template Adder - Adds suggested exercises to workout templates
///
/// Extracted from AddExerciseToTemplateSheet for reuse in inline add flow.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_recommendation_service.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

/// Service that adds an exercise suggestion to a workout template.
///
/// Calculates personalized volume based on user questionnaire data,
/// creates the ExerciseTemplate, and saves the updated template.
class ExerciseTemplateAdder {
  /// Adds a suggested exercise to an existing template.
  ///
  /// Calculates personalized volume based on user questionnaire.
  /// Returns the updated template after saving.
  static Future<WorkoutTemplate> addSuggestionToTemplate({
    required ExerciseSuggestion suggestion,
    required WorkoutTemplate template,
    required WidgetRef ref,
  }) async {
    // Calculate personalized volume based on user questionnaire
    final questionnaire = ref.read(userFitnessQuestionnaireProvider);
    const volumeService = VolumeRecommendationService();

    final VolumeRecommendation volume;
    if (questionnaire != null) {
      volume = volumeService.calculate(
        experience: questionnaire.experienceLevel,
        goal: questionnaire.trainingGoal,
        hasInjuryHistory: questionnaire.hasInjuryHistory,
      );
    } else {
      volume = volumeService.calculateDefault();
    }

    // Create sets based on calculated volume
    final sets = List.generate(
      volume.sets,
      (index) => SetTemplate(setNumber: index + 1, targetReps: volume.reps),
    );

    // Create ExerciseTemplate from suggestion with personalized volume
    final newExercise = ExerciseTemplate(
      exerciseId: suggestion.exerciseId,
      exerciseName: suggestion.exerciseName,
      category: _mapMuscleToCategory(suggestion.targetMuscle),
      type: ExerciseType.single,
      sets: sets,
      restTime: volume.restSeconds,
      countingMode: suggestion.countingMode,
    );

    // Update template with new exercise
    final updated = template.copyWith(
      exercises: [...template.exercises, newExercise],
      updatedAt: DateTime.now(),
    );

    // Save template
    await ref
        .read(workoutTemplateNotifierProvider.notifier)
        .saveTemplate(updated);

    return updated;
  }

  /// Maps muscle name to ExerciseCategory
  static ExerciseCategory _mapMuscleToCategory(String muscleName) {
    final lowerMuscle = muscleName.toLowerCase();

    // Chest muscles
    if (lowerMuscle.contains('chest') || lowerMuscle.contains('pec')) {
      return ExerciseCategory.chest;
    }

    // Back muscles
    if (lowerMuscle.contains('back') ||
        lowerMuscle.contains('lat') ||
        lowerMuscle.contains('trap') ||
        lowerMuscle.contains('rhomboid') ||
        lowerMuscle.contains('erector')) {
      return ExerciseCategory.back;
    }

    // Shoulder muscles
    if (lowerMuscle.contains('shoulder') ||
        lowerMuscle.contains('delt') ||
        lowerMuscle.contains('rear delt')) {
      return ExerciseCategory.shoulders;
    }

    // Arm muscles
    if (lowerMuscle.contains('bicep') ||
        lowerMuscle.contains('tricep') ||
        lowerMuscle.contains('forearm') ||
        lowerMuscle.contains('arm')) {
      return ExerciseCategory.arms;
    }

    // Leg muscles
    if (lowerMuscle.contains('quad') ||
        lowerMuscle.contains('hamstring') ||
        lowerMuscle.contains('glute') ||
        lowerMuscle.contains('calf') ||
        lowerMuscle.contains('leg')) {
      return ExerciseCategory.legs;
    }

    // Core muscles
    if (lowerMuscle.contains('ab') ||
        lowerMuscle.contains('core') ||
        lowerMuscle.contains('oblique')) {
      return ExerciseCategory.abs;
    }

    return ExerciseCategory.other;
  }
}
