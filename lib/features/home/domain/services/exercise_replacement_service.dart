/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/home/domain/services
/// 🎯 Feature: home
/// 🔧 Type: service
///
/// Servizio che trova esercizi simili per la sostituzione in template
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Service to find similar exercises for replacement
class ExerciseReplacementService {
  /// Find similar exercises to replace the given exercise
  ///
  /// Matches on:
  /// - Same primary muscle groups (focus)
  /// - Same movement pattern
  /// - Similar equipment (optional)
  /// - Excludes the current exercise
  static List<Exercise> findSimilarExercises({
    required String currentExerciseName,
    required Map<String, Exercise> exerciseDatabase,
    bool matchEquipment = false,
  }) {
    // Find current exercise in database
    final currentExercise = exerciseDatabase.values.firstWhere(
      (ex) => ex.nome.toLowerCase() == currentExerciseName.toLowerCase(),
      orElse: () => throw Exception('Exercise not found: $currentExerciseName'),
    );

    // Find similar exercises
    final similarExercises = exerciseDatabase.values.where((exercise) {
      // Skip the current exercise
      if (exercise.nome.toLowerCase() == currentExerciseName.toLowerCase()) {
        return false;
      }

      // Must have at least one matching primary muscle group
      final hasMatchingMuscle = exercise.focus.any(
        (muscle) => currentExercise.focus.contains(muscle),
      );

      if (!hasMatchingMuscle) return false;

      // Must have the same movement pattern
      if (exercise.patternMovimento != currentExercise.patternMovimento) {
        return false;
      }

      // Optionally match equipment
      if (matchEquipment &&
          exercise.attrezzatura != currentExercise.attrezzatura) {
        return false;
      }

      return true;
    }).toList();

    // Sort by relevance (more matching muscle groups first)
    similarExercises.sort((a, b) {
      final aMatchCount = a.focus
          .where((m) => currentExercise.focus.contains(m))
          .length;
      final bMatchCount = b.focus
          .where((m) => currentExercise.focus.contains(m))
          .length;
      return bMatchCount.compareTo(aMatchCount);
    });

    return similarExercises;
  }

  /// Get exercise details for display
  static String getExerciseDetails(Exercise exercise) {
    final muscles = exercise.focusDisplayName;
    final equipment = exercise.attrezzatura;
    final difficulty = exercise.difficolta;

    return '$muscles • $equipment • $difficulty';
  }

  /// Calculate similarity score between two exercises (0-100)
  static int calculateSimilarity(Exercise exercise1, Exercise exercise2) {
    int score = 0;

    // Primary muscles (40 points max)
    final matchingPrimaryMuscles = exercise1.focus
        .where((m) => exercise2.focus.contains(m))
        .length;
    final totalPrimaryMuscles = exercise1.focus.length;
    score += ((matchingPrimaryMuscles / totalPrimaryMuscles) * 40).round();

    // Movement pattern (30 points)
    if (exercise1.patternMovimento == exercise2.patternMovimento) {
      score += 30;
    }

    // Equipment (15 points)
    if (exercise1.attrezzatura == exercise2.attrezzatura) {
      score += 15;
    }

    // Exercise type (15 points)
    if (exercise1.tipoEsercizio == exercise2.tipoEsercizio) {
      score += 15;
    }

    return score.clamp(0, 100);
  }
}
