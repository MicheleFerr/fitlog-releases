/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/domain/services
/// 🎯 Feature: admin
/// 🔧 Type: service
///
/// Service for computing exercise statistics with memoization optimization
library;

import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/admin/domain/models/exercise_statistics.dart';

/// Service for computing exercise statistics with caching
class ExerciseStatisticsService {
  // Cache for computed statistics (key: "language-totalCount-hashCode")
  static final Map<String, ExerciseStatistics> _statsCache = {};

  /// Compute statistics for a list of exercises with memoization
  ///
  /// Cache key formula: "$language-${exercises.length}-${exercises.hashCode}"
  /// This ensures cache is invalidated when exercises list changes
  static ExerciseStatistics computeStats(List<Exercise> exercises, String language) {
    final cacheKey = '$language-${exercises.length}-${exercises.hashCode}';

    // Check cache first
    if (_statsCache.containsKey(cacheKey)) {
      return _statsCache[cacheKey]!;
    }

    // Compute stats if not cached
    final stats = _computeStatsInternal(exercises);
    _statsCache[cacheKey] = stats;

    return stats;
  }

  /// Internal computation logic (not cached)
  static ExerciseStatistics _computeStatsInternal(List<Exercise> exercises) {
    final equipmentMap = <String, int>{};
    final muscleGroupMap = <String, int>{};
    final difficultyMap = <String, int>{};
    final exerciseTypeMap = <String, int>{};

    int bodyweightCount = 0;
    int compoundCount = 0;
    int isolationCount = 0;

    for (final exercise in exercises) {
      // Equipment breakdown
      final equipment = exercise.attrezzatura;
      equipmentMap[equipment] = (equipmentMap[equipment] ?? 0) + 1;

      if (equipment.toLowerCase().contains('corpo') ||
          equipment.toLowerCase().contains('body')) {
        bodyweightCount++;
      }

      // Muscle group breakdown (primary focus)
      for (final muscle in exercise.focus) {
        muscleGroupMap[muscle] = (muscleGroupMap[muscle] ?? 0) + 1;
      }

      // Difficulty breakdown
      final difficulty = exercise.difficolta;
      difficultyMap[difficulty] = (difficultyMap[difficulty] ?? 0) + 1;

      // Exercise type breakdown
      final type = exercise.tipoEsercizio;
      exerciseTypeMap[type] = (exerciseTypeMap[type] ?? 0) + 1;

      if (type.toLowerCase().contains('compound') ||
          type.toLowerCase().contains('composto')) {
        compoundCount++;
      } else if (type.toLowerCase().contains('isolation') ||
          type.toLowerCase().contains('isolamento') ||
          type.toLowerCase().contains('isolato')) {
        isolationCount++;
      }
    }

    return ExerciseStatistics(
      equipmentBreakdown: equipmentMap,
      muscleGroupBreakdown: muscleGroupMap,
      difficultyBreakdown: difficultyMap,
      exerciseTypeBreakdown: exerciseTypeMap,
      totalExercises: exercises.length,
      bodyweightCount: bodyweightCount,
      compoundCount: compoundCount,
      isolationCount: isolationCount,
    );
  }

  /// Clear statistics cache (useful when force refreshing data)
  static void clearCache() {
    _statsCache.clear();
  }

  /// Get cache size (for debugging)
  static int getCacheSize() {
    return _statsCache.length;
  }
}
