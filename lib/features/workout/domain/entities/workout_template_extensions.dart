import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';

/// Extensions for WorkoutTemplate to auto-detect metadata
///
/// Provides intelligent auto-detection of:
/// - Difficulty level (beginner/intermediate/advanced/expert)
/// - Template category (strength/cardio/flexibility/hybrid)
/// - Target muscle groups (chest/back/shoulders/arms/legs/abs/cardio)
///
/// Auto-detection uses heuristics based on exercises, sets, and volume.
/// Results can be manually overridden in template editor.
extension WorkoutTemplateExtensions on WorkoutTemplate {
  /// Auto-detect difficulty level based on total sets and exercises
  ///
  /// Algorithm:
  /// - Beginner: 1-12 sets total, OR 1-3 exercises
  /// - Intermediate: 13-20 sets total, OR 4-5 exercises
  /// - Advanced: 21-30 sets total, OR 6-8 exercises
  /// - Expert: 31+ sets total, OR 9+ exercises
  ///
  /// Uses the higher difficulty if set count and exercise count disagree.
  DifficultyLevel detectDifficulty() {
    final totalSets = _calculateTotalSets();
    final exerciseCount = exercises.length;

    // Determine difficulty from sets
    DifficultyLevel setBasedDifficulty;
    if (totalSets <= 12) {
      setBasedDifficulty = DifficultyLevel.beginner;
    } else if (totalSets <= 20) {
      setBasedDifficulty = DifficultyLevel.intermediate;
    } else if (totalSets <= 30) {
      setBasedDifficulty = DifficultyLevel.advanced;
    } else {
      setBasedDifficulty = DifficultyLevel.expert;
    }

    // Determine difficulty from exercise count
    DifficultyLevel exerciseBasedDifficulty;
    if (exerciseCount <= 3) {
      exerciseBasedDifficulty = DifficultyLevel.beginner;
    } else if (exerciseCount <= 5) {
      exerciseBasedDifficulty = DifficultyLevel.intermediate;
    } else if (exerciseCount <= 8) {
      exerciseBasedDifficulty = DifficultyLevel.advanced;
    } else {
      exerciseBasedDifficulty = DifficultyLevel.expert;
    }

    // Return higher difficulty (more conservative)
    return setBasedDifficulty.index > exerciseBasedDifficulty.index
        ? setBasedDifficulty
        : exerciseBasedDifficulty;
  }

  /// Auto-detect template category based on exercise types
  ///
  /// Algorithm:
  /// - Cardio: ≥ 70% cardio exercises
  /// - Strength: ≥ 70% resistance exercises (chest/back/shoulders/arms/legs)
  /// - Flexibility: ≥ 70% abs/core exercises
  /// - Hybrid: Mixed modalities (no single type ≥ 70%)
  TemplateCategory detectCategory() {
    if (exercises.isEmpty) {
      return TemplateCategory.hybrid;
    }

    final categoryDistribution = _calculateCategoryDistribution();
    final totalExercises = exercises.length;

    // Count cardio exercises
    final cardioCount = categoryDistribution[ExerciseCategory.cardio] ?? 0;
    final cardioPercentage = (cardioCount / totalExercises);

    // Count strength exercises (chest, back, shoulders, arms, legs)
    final strengthCategories = [
      ExerciseCategory.chest,
      ExerciseCategory.back,
      ExerciseCategory.shoulders,
      ExerciseCategory.arms,
      ExerciseCategory.legs,
    ];

    final strengthCount = strengthCategories
        .map((cat) => categoryDistribution[cat] ?? 0)
        .reduce((a, b) => a + b);
    final strengthPercentage = (strengthCount / totalExercises);

    // Count flexibility/core exercises (abs)
    final flexibilityCount = categoryDistribution[ExerciseCategory.abs] ?? 0;
    final flexibilityPercentage = (flexibilityCount / totalExercises);

    // Determine category (≥ 70% threshold for single-modality)
    if (cardioPercentage >= 0.7) {
      return TemplateCategory.cardio;
    } else if (strengthPercentage >= 0.7) {
      return TemplateCategory.strength;
    } else if (flexibilityPercentage >= 0.7) {
      return TemplateCategory.flexibility;
    } else {
      // Mixed modalities → hybrid
      return TemplateCategory.hybrid;
    }
  }

  /// Auto-detect target muscle groups from exercises
  ///
  /// Returns list of unique muscle groups, sorted by frequency (most to least).
  /// Excludes "other" and "cardio" from muscle group list.
  ///
  /// Example: ["Petto", "Schiena", "Spalle"]
  List<ExerciseCategory> detectMuscleGroups() {
    final categoryDistribution = _calculateCategoryDistribution();

    // Filter out non-muscle categories
    final muscleCategories = categoryDistribution.keys
        .where(
          (cat) =>
              cat != ExerciseCategory.other && cat != ExerciseCategory.cardio,
        )
        .toList();

    // Sort by frequency (descending)
    muscleCategories.sort((a, b) {
      final countA = categoryDistribution[a] ?? 0;
      final countB = categoryDistribution[b] ?? 0;
      return countB.compareTo(countA);
    });

    return muscleCategories;
  }

  /// Get existing difficulty level, or auto-detect if null
  ///
  /// Respects manual difficulty if set, otherwise auto-detects.
  DifficultyLevel get effectiveDifficulty {
    final existingDifficulty = DifficultyLevel.fromString(difficulty);
    return existingDifficulty ?? detectDifficulty();
  }

  /// Get effective category (auto-detected, no manual override yet)
  TemplateCategory get effectiveCategory => detectCategory();

  /// Get effective muscle groups (auto-detected, no manual override yet)
  List<ExerciseCategory> get effectiveMuscleGroups => detectMuscleGroups();

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculate total sets across all exercises (including sub-exercises)
  int _calculateTotalSets() {
    int total = 0;

    for (final exercise in exercises) {
      total += exercise.sets.length;

      // If superset, count sub-exercise sets too
      if (exercise.type == ExerciseType.superset &&
          exercise.subExercises != null) {
        for (final subExercise in exercise.subExercises!) {
          total += subExercise.sets.length;
        }
      }
    }

    return total;
  }

  /// Calculate distribution of exercise categories
  ///
  /// Returns map of ExerciseCategory → count
  Map<ExerciseCategory, int> _calculateCategoryDistribution() {
    final distribution = <ExerciseCategory, int>{};

    for (final exercise in exercises) {
      // Increment count for this category
      distribution[exercise.category] =
          (distribution[exercise.category] ?? 0) + 1;

      // If superset, count sub-exercises too
      if (exercise.type == ExerciseType.superset &&
          exercise.subExercises != null) {
        for (final subExercise in exercise.subExercises!) {
          distribution[subExercise.category] =
              (distribution[subExercise.category] ?? 0) + 1;
        }
      }
    }

    return distribution;
  }
}
