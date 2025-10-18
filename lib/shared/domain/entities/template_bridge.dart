/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain
/// 🎯 Feature: Template Bridge
/// 🔧 Type: Compatibility Bridge
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Purpose: Bridge class per compatibility durante integrazione sistema unificato
library;

import 'package:gymbro_flutter_new/shared/domain/entities/unified_workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as legacy;
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';


/// Bridge class per conversion sicura tra sistemi
class TemplateBridge {
  /// Converte UnifiedWorkoutTemplate a legacy WorkoutTemplate
  static legacy.WorkoutTemplate toLegacy(UnifiedWorkoutTemplate unified) {
    // Converti gli esercizi dal formato raw a ExerciseTemplate
    final exercises = <legacy.ExerciseTemplate>[];

    for (final rawExercise in unified.exercisesRaw) {
      if (rawExercise is Map<String, dynamic>) {
        // Converti i set
        final rawSets = rawExercise['sets'] as List<dynamic>? ?? [];
        final sets = rawSets.map((setData) {
          final setMap = setData as Map<String, dynamic>;
          return legacy.SetTemplate(
            setNumber: setMap['setNumber'] ?? setMap['number'] ?? 1,
            targetReps: setMap['targetReps'] ?? setMap['reps'] ?? 10,
            targetWeight: (setMap['targetWeight'] ?? setMap['weight'] ?? 0).toDouble(),
            notes: setMap['notes'],
          );
        }).toList();

        exercises.add(legacy.ExerciseTemplate(
          exerciseId: rawExercise['exerciseId'] ?? rawExercise['id'] ?? 'unknown',
          exerciseName: rawExercise['exerciseName'] ?? rawExercise['name'] ?? 'Unknown Exercise',
          category: _parseExerciseCategory(rawExercise['category']),
          sets: sets,
          notes: rawExercise['notes'],
          restTime: rawExercise['restTime'] ?? 90,
        ));
      }
    }

    return legacy.WorkoutTemplate(
      id: unified.id,
      name: unified.name,
      description: unified.description,
      exercises: exercises,
      tags: unified.tags,
      estimatedDuration: unified.estimatedDuration,
      isCustom: unified.isCustom,
      isPublic: unified.isPublic,
      usageCount: unified.usageCount,
      imageUrl: unified.imageUrl,
      userId: unified.userId,
      authorName: unified.authorName,
      downloadCount: unified.downloadCount,
      averageRating: unified.averageRating,
      reviewCount: unified.reviewCount,
      difficulty: unified.difficulty,
      createdAt: unified.createdAt,
      updatedAt: unified.updatedAt,
    );
  }

  /// Converte legacy WorkoutTemplate a UnifiedWorkoutTemplate
  static UnifiedWorkoutTemplate fromLegacy(legacy.WorkoutTemplate legacyTemplate) {
    return UnifiedWorkoutTemplate(
      id: legacyTemplate.id,
      name: legacyTemplate.name,
      description: legacyTemplate.description,
      userId: legacyTemplate.userId ?? '',
      exercisesRaw: legacyTemplate.exercises.map((e) => _exerciseToMap(e)).toList(),
      exerciseFormat: ExerciseFormat.legacy,
      visibility: legacyTemplate.isPublic ? UnifiedTemplateVisibility.public : UnifiedTemplateVisibility.private,
      category: UnifiedTemplateCategory.custom,
      createdAt: legacyTemplate.createdAt,
      updatedAt: legacyTemplate.updatedAt,
      tags: legacyTemplate.tags,
      estimatedDuration: legacyTemplate.estimatedDuration,
      source: TemplateSource.legacy,
      useCount: legacyTemplate.usageCount,
      isCustom: legacyTemplate.isCustom,
      isPublic: legacyTemplate.isPublic,
      usageCount: legacyTemplate.usageCount,
      imageUrl: legacyTemplate.imageUrl,
      authorName: legacyTemplate.authorName,
      downloadCount: legacyTemplate.downloadCount,
      averageRating: legacyTemplate.averageRating,
      reviewCount: legacyTemplate.reviewCount,
      difficulty: legacyTemplate.difficulty,
    );
  }

  /// Converte ExerciseTemplate a Map per storage
  static Map<String, dynamic> _exerciseToMap(legacy.ExerciseTemplate exercise) {
    return {
      'exerciseId': exercise.exerciseId,
      'exerciseName': exercise.exerciseName,
      'category': exercise.category.name,
      'sets': exercise.sets.map((set) => {
        'setNumber': set.setNumber,
        'targetReps': set.targetReps,
        'targetWeight': set.targetWeight,
        'notes': set.notes,
      }).toList(),
      'notes': exercise.notes,
      'restTime': exercise.restTime,
    };
  }

  /// Parse category string to ExerciseCategory enum
  static ExerciseCategory _parseExerciseCategory(dynamic category) {
    if (category == null) return ExerciseCategory.chest;

    final categoryStr = category.toString().toLowerCase();

    switch (categoryStr) {
      case 'chest':
        return ExerciseCategory.chest;
      case 'back':
        return ExerciseCategory.back;
      case 'shoulders':
        return ExerciseCategory.shoulders;
      case 'arms':
        return ExerciseCategory.arms;
      case 'legs':
        return ExerciseCategory.legs;
      case 'core':
      case 'abs':
        return ExerciseCategory.abs;
      case 'cardio':
        return ExerciseCategory.cardio;
      default:
        return ExerciseCategory.chest;
    }
  }
}