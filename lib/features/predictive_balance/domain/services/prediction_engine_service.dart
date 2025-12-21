/// Predictive Balance - Prediction Engine Service
///
/// Calculates which workouts are missing from the current week
/// based on detected pattern.
library;

import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/pattern_prediction.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/weekly_pattern.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/services/pattern_detector_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Prediction Engine Service
///
/// Given a detected pattern and this week's completed workouts,
/// predicts which workout(s) are missing.
///
/// **Usage**:
/// ```dart
/// final prediction = PredictionEngineService.predict(
///   pattern: weeklyPattern,
///   thisWeekWorkouts: completedThisWeek,
///   muscleMap: exerciseMuscleMap,
///   templates: userTemplates, // Optional for template suggestions
/// );
///
/// if (prediction != null) {
///   print('Missing: ${prediction.displayName}');
///   print('Will cover: ${prediction.musclesCovered.join(', ')}');
/// }
/// ```
class PredictionEngineService {
  /// Predict missing workout for this week
  ///
  /// Returns null if:
  /// - Pattern is null or invalid
  /// - All cycle workouts are already completed this week
  static PatternPrediction? predict({
    required WeeklyPattern? pattern,
    required List<Workout> thisWeekWorkouts,
    required Map<String, ExerciseMuscleData> muscleMap,
    List<WorkoutTemplate>? templates,
  }) {
    if (pattern == null || !pattern.isValid) return null;

    // Create fingerprints for this week's workouts
    final doneFingerprints = <WorkoutFingerprint>[];
    for (final workout in thisWeekWorkouts) {
      if (workout.status != WorkoutStatus.completed) continue;

      final fp = _createFingerprint(workout, muscleMap);
      if (fp.dominantMuscles.isNotEmpty) {
        doneFingerprints.add(fp);
      }
    }

    // Find which cycle items haven't been done
    final missing = <WorkoutFingerprint>[];

    for (final cycleItem in pattern.cycle) {
      final isDone = doneFingerprints.any(
        (done) => done.matches(cycleItem),
      );
      if (!isDone) {
        missing.add(cycleItem);
      }
    }

    if (missing.isEmpty) return null; // All done!

    // Get first missing (prioritized by pattern order)
    final next = missing.first;

    // Try to find matching template
    String? suggestedTemplateId;
    String? suggestedTemplateName;

    if (templates != null && templates.isNotEmpty) {
      final matchingTemplate = _findMatchingTemplate(
        fingerprint: next,
        templates: templates,
        muscleMap: muscleMap,
      );
      if (matchingTemplate != null) {
        suggestedTemplateId = matchingTemplate.id;
        suggestedTemplateName = matchingTemplate.name;
      }
    }

    // If no template found but fingerprint has template info, use it
    if (suggestedTemplateId == null && next.templateId != null) {
      suggestedTemplateId = next.templateId;
      suggestedTemplateName = next.templateName;
    }

    return PatternPrediction(
      missing: next,
      musclesCovered: next.dominantMuscles,
      suggestedTemplateId: suggestedTemplateId,
      suggestedTemplateName: suggestedTemplateName,
      missingCount: missing.length,
      patternConfidence: pattern.confidence,
    );
  }

  /// Get all missing workouts (not just the first one)
  static List<PatternPrediction> predictAll({
    required WeeklyPattern? pattern,
    required List<Workout> thisWeekWorkouts,
    required Map<String, ExerciseMuscleData> muscleMap,
    List<WorkoutTemplate>? templates,
  }) {
    if (pattern == null || !pattern.isValid) return [];

    // Create fingerprints for this week's workouts
    final doneFingerprints = <WorkoutFingerprint>[];
    for (final workout in thisWeekWorkouts) {
      if (workout.status != WorkoutStatus.completed) continue;

      final fp = _createFingerprint(workout, muscleMap);
      if (fp.dominantMuscles.isNotEmpty) {
        doneFingerprints.add(fp);
      }
    }

    // Find all missing cycle items
    final predictions = <PatternPrediction>[];

    for (final cycleItem in pattern.cycle) {
      final isDone = doneFingerprints.any(
        (done) => done.matches(cycleItem),
      );

      if (!isDone) {
        // Try to find matching template
        String? suggestedTemplateId;
        String? suggestedTemplateName;

        if (templates != null && templates.isNotEmpty) {
          final matchingTemplate = _findMatchingTemplate(
            fingerprint: cycleItem,
            templates: templates,
            muscleMap: muscleMap,
          );
          if (matchingTemplate != null) {
            suggestedTemplateId = matchingTemplate.id;
            suggestedTemplateName = matchingTemplate.name;
          }
        }

        // Fallback to fingerprint template info
        if (suggestedTemplateId == null && cycleItem.templateId != null) {
          suggestedTemplateId = cycleItem.templateId;
          suggestedTemplateName = cycleItem.templateName;
        }

        predictions.add(PatternPrediction(
          missing: cycleItem,
          musclesCovered: cycleItem.dominantMuscles,
          suggestedTemplateId: suggestedTemplateId,
          suggestedTemplateName: suggestedTemplateName,
          missingCount: 1,
          patternConfidence: pattern.confidence,
        ));
      }
    }

    return predictions;
  }

  /// Check if a specific muscle would be resolved by completing the pattern
  ///
  /// Returns true if the missing workout(s) cover the specified muscle.
  static bool wouldResolveMuscle({
    required WeeklyPattern? pattern,
    required List<Workout> thisWeekWorkouts,
    required Map<String, ExerciseMuscleData> muscleMap,
    required String muscleName,
  }) {
    final prediction = predict(
      pattern: pattern,
      thisWeekWorkouts: thisWeekWorkouts,
      muscleMap: muscleMap,
    );

    if (prediction == null) return false;

    return prediction.resolvesMuscle(muscleName);
  }

  /// Create fingerprint from workout (reuse pattern detector logic)
  static WorkoutFingerprint _createFingerprint(
    Workout workout,
    Map<String, ExerciseMuscleData> muscleMap,
  ) {
    // Calculate volume per muscle
    final muscleVolume = <String, double>{};

    for (final exercise in workout.exercises) {
      final nameLower = exercise.name.toLowerCase();
      final data = muscleMap[exercise.name] ?? muscleMap[nameLower];

      if (data == null || !data.hasData) continue;

      final volume = _calculateExerciseVolume(exercise);

      // Primary muscles get 100% volume credit
      for (final muscle in data.primary) {
        final normalized = PatternDetectorService.normalizeMuscle(muscle);
        muscleVolume[normalized] = (muscleVolume[normalized] ?? 0) + volume;
      }

      // Secondary muscles get 50% volume credit
      for (final muscle in data.secondary) {
        final normalized = PatternDetectorService.normalizeMuscle(muscle);
        muscleVolume[normalized] =
            (muscleVolume[normalized] ?? 0) + volume * 0.5;
      }
    }

    // Get top 3 muscles
    final sorted = muscleVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dominantMuscles = sorted.take(3).map((e) => e.key).toList();

    // Infer category
    final category = PatternDetectorService.inferCategory(dominantMuscles);

    // Calculate total volume
    final totalVolume = muscleVolume.values.fold(0.0, (a, b) => a + b);

    return WorkoutFingerprint(
      id: PatternDetectorService.generateId(dominantMuscles, category),
      templateName: workout.name,
      templateId: workout.templateId,
      dominantMuscles: dominantMuscles,
      category: category,
      totalVolume: totalVolume,
      workoutDate: workout.completedAt,
    );
  }

  /// Calculate volume for an exercise
  static double _calculateExerciseVolume(dynamic exercise) {
    double total = 0.0;

    for (final set in exercise.sets) {
      if (!set.isCompleted) continue;

      final reps = set.actualReps ?? set.reps ?? 0;
      final weight = set.weight ?? 1.0;

      total += reps * weight;
    }

    return total;
  }

  /// Find template that matches the fingerprint
  static WorkoutTemplate? _findMatchingTemplate({
    required WorkoutFingerprint fingerprint,
    required List<WorkoutTemplate> templates,
    required Map<String, ExerciseMuscleData> muscleMap,
  }) {
    // First try exact template ID match
    if (fingerprint.templateId != null) {
      final exactMatch = templates.where((t) => t.id == fingerprint.templateId);
      if (exactMatch.isNotEmpty) {
        return exactMatch.first;
      }
    }

    // Then try template name match
    if (fingerprint.templateName != null &&
        fingerprint.templateName!.isNotEmpty) {
      final nameMatch = templates.where(
        (t) => t.name.toLowerCase() == fingerprint.templateName!.toLowerCase(),
      );
      if (nameMatch.isNotEmpty) {
        return nameMatch.first;
      }
    }

    // Finally, try to match by muscle composition
    for (final template in templates) {
      final templateMuscles = _getTemplateDominantMuscles(template, muscleMap);

      // Match if 2/3 muscles overlap
      final overlap =
          fingerprint.dominantMuscles.where((m) => templateMuscles.contains(m));
      if (overlap.length >= 2) {
        return template;
      }
    }

    return null;
  }

  /// Get dominant muscles for a template
  static Set<String> _getTemplateDominantMuscles(
    WorkoutTemplate template,
    Map<String, ExerciseMuscleData> muscleMap,
  ) {
    final muscleVolume = <String, double>{};

    for (final exercise in template.exercises) {
      final nameLower = exercise.exerciseName.toLowerCase();
      final data = muscleMap[exercise.exerciseName] ?? muscleMap[nameLower];

      if (data == null || !data.hasData) continue;

      // Estimate volume (sets × 10 reps × 50kg as baseline)
      final estimatedVolume = exercise.sets.length * 10 * 50.0;

      for (final muscle in data.primary) {
        final normalized = PatternDetectorService.normalizeMuscle(muscle);
        muscleVolume[normalized] =
            (muscleVolume[normalized] ?? 0) + estimatedVolume;
      }

      for (final muscle in data.secondary) {
        final normalized = PatternDetectorService.normalizeMuscle(muscle);
        muscleVolume[normalized] =
            (muscleVolume[normalized] ?? 0) + estimatedVolume * 0.5;
      }
    }

    // Return top 3 muscles
    final sorted = muscleVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toSet();
  }
}
