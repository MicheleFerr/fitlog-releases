import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_database.dart';

/// Service for calculating similarity between exercises
/// Uses multiple factors to determine exercise similarity for intelligent substitution suggestions
class ExerciseSimilarityService {
  static const double _primaryMuscleWeight = 0.4;
  static const double _secondaryMuscleWeight = 0.2;
  static const double _equipmentWeight = 0.2;
  static const double _movementPatternWeight = 0.15;
  static const double _categoryWeight = 0.05;

  /// Calculate similarity score between two exercises (0.0 to 1.0)
  static double calculateSimilarity(
    ExerciseDatabase exercise1,
    ExerciseDatabase exercise2,
  ) {
    if (exercise1.id == exercise2.id) return 1.0;

    // ⚠️ HARD BLOCK: Prevent absurd matches between incompatible muscle groups
    if (_areIncompatibleMuscleGroups(
      exercise1.primaryMuscleGroups ?? [],
      exercise2.primaryMuscleGroups ?? [],
    )) {
      return 0.0; // Force 0% similarity for incompatible exercises
    }

    double score = 0.0;

    // Primary muscle groups (most important)
    final primaryScore = _calculateMuscleGroupSimilarity(
      exercise1.primaryMuscleGroups ?? [],
      exercise2.primaryMuscleGroups ?? [],
    );
    score += primaryScore * _primaryMuscleWeight;

    // Secondary muscle groups
    final secondaryScore = _calculateMuscleGroupSimilarity(
      exercise1.secondaryMuscleGroups ?? [],
      exercise2.secondaryMuscleGroups ?? [],
    );
    score += secondaryScore * _secondaryMuscleWeight;

    // Equipment similarity
    final equipmentScore = _calculateEquipmentSimilarity(
      exercise1.equipment,
      exercise2.equipment,
    );
    score += equipmentScore * _equipmentWeight;

    // Movement pattern similarity
    final movementScore = _calculateMovementPatternSimilarity(
      exercise1,
      exercise2,
    );
    score += movementScore * _movementPatternWeight;

    // Category similarity
    final categoryScore = _calculateCategorySimilarity(
      exercise1.category,
      exercise2.category,
    );
    score += categoryScore * _categoryWeight;

    return score.clamp(0.0, 1.0);
  }

  /// Calculate muscle group overlap similarity
  static double _calculateMuscleGroupSimilarity(
    List<String> muscles1,
    List<String> muscles2,
  ) {
    if (muscles1.isEmpty || muscles2.isEmpty) return 0.0;

    final set1 = muscles1.toSet();
    final set2 = muscles2.toSet();
    
    // Jaccard similarity coefficient
    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;
    
    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// Calculate equipment similarity
  static double _calculateEquipmentSimilarity(
    String? equipment1,
    String? equipment2,
  ) {
    if (equipment1 == null || equipment2 == null) return 0.5;
    if (equipment1 == equipment2) return 1.0;

    // Equipment compatibility matrix
    final compatibilityMap = <String, Set<String>>{
      'barbell': {'dumbbell', 'smith_machine', 'ez_bar'},
      'dumbbell': {'barbell', 'kettlebell', 'cable'},
      'cable': {'dumbbell', 'machine', 'bands'},
      'machine': {'cable', 'smith_machine'},
      'bodyweight': {'bands', 'suspension'},
      'smith_machine': {'barbell', 'machine'},
      'kettlebell': {'dumbbell', 'medicine_ball'},
      'bands': {'cable', 'bodyweight'},
    };

    final e1Lower = equipment1.toLowerCase();
    final e2Lower = equipment2.toLowerCase();

    // Check if equipment types are compatible
    if (compatibilityMap[e1Lower]?.contains(e2Lower) == true ||
        compatibilityMap[e2Lower]?.contains(e1Lower) == true) {
      return 0.7; // Partial compatibility
    }

    return 0.0;
  }

  /// Calculate movement pattern similarity
  static double _calculateMovementPatternSimilarity(
    ExerciseDatabase exercise1,
    ExerciseDatabase exercise2,
  ) {
    // Extract movement patterns from exercise names and categories
    final patterns = {
      'push': ['press', 'push', 'fly', 'dip', 'extension'],
      'pull': ['pull', 'row', 'curl', 'lat', 'chin'],
      'squat': ['squat', 'lunge', 'leg press', 'hack'],
      'hinge': ['deadlift', 'romanian', 'good morning', 'hip thrust'],
      'carry': ['carry', 'walk', 'hold'],
      'rotation': ['twist', 'rotation', 'wood', 'russian'],
    };

    String? getPattern(ExerciseDatabase exercise) {
      final name = exercise.name.toLowerCase();
      for (final entry in patterns.entries) {
        if (entry.value.any((keyword) => name.contains(keyword))) {
          return entry.key;
        }
      }
      return null;
    }

    final pattern1 = getPattern(exercise1);
    final pattern2 = getPattern(exercise2);

    if (pattern1 == null || pattern2 == null) return 0.5;
    return pattern1 == pattern2 ? 1.0 : 0.0;
  }

  /// Calculate category similarity
  static double _calculateCategorySimilarity(
    String? category1,
    String? category2,
  ) {
    if (category1 == null || category2 == null) return 0.5;
    if (category1 == category2) return 1.0;

    // Related categories
    final relatedCategories = <String, Set<String>>{
      'chest': {'shoulders', 'triceps'},
      'back': {'biceps', 'traps'},
      'shoulders': {'chest', 'triceps'},
      'legs': {'glutes', 'calves'},
      'core': {'abs', 'obliques'},
    };

    final c1Lower = category1.toLowerCase();
    final c2Lower = category2.toLowerCase();

    if (relatedCategories[c1Lower]?.contains(c2Lower) == true ||
        relatedCategories[c2Lower]?.contains(c1Lower) == true) {
      return 0.5; // Related categories
    }

    return 0.0;
  }

  /// Check if two muscle groups are incompatible (should NEVER be matched)
  /// Example: Core exercises should NEVER match with Leg/Glute exercises
  static bool _areIncompatibleMuscleGroups(
    List<String> muscles1,
    List<String> muscles2,
  ) {
    if (muscles1.isEmpty || muscles2.isEmpty) return false;

    // Define incompatible muscle group pairs
    final incompatiblePairs = <Set<String>>[
      // Core/Abs should NOT match with lower body
      {'CORE', 'GLUT'}, // Core ≠ Glutes
      {'CORE', 'FEMOR'}, // Core ≠ Hamstrings
      {'CORE', 'QUAD'}, // Core ≠ Quads
      {'CORE', 'LAT'}, // Core ≠ Lats (back)
      {'CORE', 'TRAP'}, // Core ≠ Traps (back)

      // Upper body should NOT match with lower body
      {'PETT', 'GLUT'}, // Chest ≠ Glutes
      {'PETT', 'FEMOR'}, // Chest ≠ Hamstrings
      {'PETT', 'QUAD'}, // Chest ≠ Quads
      {'SPALL', 'GLUT'}, // Shoulders ≠ Glutes
      {'SPALL', 'FEMOR'}, // Shoulders ≠ Hamstrings
      {'SPALL', 'QUAD'}, // Shoulders ≠ Quads

      // Arms should NOT match with legs
      {'BIC', 'GLUT'}, // Biceps ≠ Glutes
      {'BIC', 'FEMOR'}, // Biceps ≠ Hamstrings
      {'BIC', 'QUAD'}, // Biceps ≠ Quads
      {'TRIC', 'GLUT'}, // Triceps ≠ Glutes
      {'TRIC', 'FEMOR'}, // Triceps ≠ Hamstrings
      {'TRIC', 'QUAD'}, // Triceps ≠ Quads
    ];

    final set1 = muscles1.map((m) => m.toUpperCase()).toSet();
    final set2 = muscles2.map((m) => m.toUpperCase()).toSet();

    // Check if any incompatible pair exists
    for (final pair in incompatiblePairs) {
      final pairList = pair.toList();
      if ((set1.contains(pairList[0]) && set2.contains(pairList[1])) ||
          (set1.contains(pairList[1]) && set2.contains(pairList[0]))) {
        return true; // Found incompatible pair - block match
      }
    }

    return false;
  }

  /// Get exercise recommendations sorted by similarity
  static List<ExerciseRecommendation> getRecommendations({
    required ExerciseDatabase targetExercise,
    required List<ExerciseDatabase> availableExercises,
    int maxRecommendations = 10,
    double minSimilarityThreshold = 0.3,
  }) {
    final recommendations = <ExerciseRecommendation>[];

    for (final exercise in availableExercises) {
      if (exercise.id == targetExercise.id) continue;

      final similarity = calculateSimilarity(targetExercise, exercise);

      if (similarity >= minSimilarityThreshold) {
        recommendations.add(ExerciseRecommendation(
          exercise: exercise,
          similarityScore: similarity,
          matchedFactors: _getMatchedFactors(targetExercise, exercise),
        ));
      }
    }

    // Sort by similarity score (highest first)
    recommendations.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

    // Return top recommendations
    return recommendations.take(maxRecommendations).toList();
  }

  /// Identify which factors matched between exercises
  static List<MatchFactor> _getMatchedFactors(
    ExerciseDatabase exercise1,
    ExerciseDatabase exercise2,
  ) {
    final factors = <MatchFactor>[];

    // Check primary muscles
    final primaryMuscles1 = (exercise1.primaryMuscleGroups ?? []).toSet();
    final primaryMuscles2 = (exercise2.primaryMuscleGroups ?? []).toSet();
    final sharedPrimary = primaryMuscles1.intersection(primaryMuscles2);
    
    if (sharedPrimary.isNotEmpty) {
      factors.add(MatchFactor(
        type: MatchFactorType.primaryMuscles,
        description: sharedPrimary.join(', '),
        importance: 1.0,
      ));
    }

    // Check equipment
    if (exercise1.equipment == exercise2.equipment && exercise1.equipment != null) {
      factors.add(MatchFactor(
        type: MatchFactorType.equipment,
        description: exercise1.equipment!,
        importance: 0.7,
      ));
    }

    // Check movement pattern
    if (_calculateMovementPatternSimilarity(exercise1, exercise2) > 0.8) {
      factors.add(MatchFactor(
        type: MatchFactorType.movementPattern,
        description: 'Similar movement pattern',
        importance: 0.6,
      ));
    }

    return factors;
  }
}

/// Recommendation with similarity score and matched factors
class ExerciseRecommendation {

  ExerciseRecommendation({
    required this.exercise,
    required this.similarityScore,
    required this.matchedFactors,
  });
  final ExerciseDatabase exercise;
  final double similarityScore;
  final List<MatchFactor> matchedFactors;

  /// Get similarity percentage (0-100)
  int get similarityPercentage => (similarityScore * 100).round();

  /// Get primary reason for recommendation
  String get primaryReason {
    if (matchedFactors.isEmpty) return '';
    
    final mostImportant = matchedFactors.reduce((a, b) => 
      a.importance > b.importance ? a : b
    );
    
    return mostImportant.description;
  }
}

/// Factor that matched between exercises
class MatchFactor {

  MatchFactor({
    required this.type,
    required this.description,
    required this.importance,
  });
  final MatchFactorType type;
  final String description;
  final double importance;
}

/// Types of matching factors
enum MatchFactorType {
  primaryMuscles,
  secondaryMuscles,
  equipment,
  movementPattern,
  category,
}