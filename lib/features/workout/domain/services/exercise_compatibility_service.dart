import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

class ExerciseCompatibilityService {
  static const double primaryMuscleWeight = 0.40;
  static const double secondaryMuscleWeight = 0.25;
  static const double movementPatternWeight = 0.20;
  static const double equipmentWeight = 0.10;
  static const double difficultyWeight = 0.05;

  /// Calculate compatibility percentage between two exercises
  static double calculateCompatibility(Exercise exercise1, Exercise exercise2) {
    if (exercise1.name == exercise2.name)
      return 0.0; // Don't suggest the same exercise

    double score = 0.0;

    // Primary muscle group match (40%)
    if (exercise1.category == exercise2.category) {
      score += primaryMuscleWeight;
    } else if (_areRelatedMuscleGroups(
      exercise1.category,
      exercise2.category,
    )) {
      score += primaryMuscleWeight * 0.5;
    }

    // Secondary muscles (25%)
    score +=
        _calculateSecondaryMuscleScore(exercise1, exercise2) *
        secondaryMuscleWeight;

    // Movement pattern (20%)
    score +=
        _calculateMovementPatternScore(exercise1, exercise2) *
        movementPatternWeight;

    // Equipment similarity (10%)
    score += _calculateEquipmentScore(exercise1, exercise2) * equipmentWeight;

    // Difficulty level (5%)
    score += _calculateDifficultyScore(exercise1, exercise2) * difficultyWeight;

    return score * 100; // Convert to percentage
  }

  /// Get suggested replacements for an exercise
  static List<ExerciseSuggestion> getSuggestedReplacements(
    Exercise currentExercise,
    List<Exercise> availableExercises,
  ) {
    final suggestions = <ExerciseSuggestion>[];

    for (final exercise in availableExercises) {
      final compatibility = calculateCompatibility(currentExercise, exercise);
      if (compatibility > 30) {
        // Only suggest if > 30% compatible
        suggestions.add(
          ExerciseSuggestion(
            exercise: exercise,
            compatibilityScore: compatibility,
            reason: _getReplacementReason(
              currentExercise,
              exercise,
              compatibility,
            ),
          ),
        );
      }
    }

    // Sort by compatibility score
    suggestions.sort(
      (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
    );

    // Return top 10 suggestions
    return suggestions.take(10).toList();
  }

  static bool _areRelatedMuscleGroups(
    ExerciseCategory cat1,
    ExerciseCategory cat2,
  ) {
    // Define related muscle groups
    const relatedGroups = {
      ExerciseCategory.chest: [
        ExerciseCategory.shoulders,
        ExerciseCategory.arms,
      ],
      ExerciseCategory.back: [
        ExerciseCategory.arms,
        ExerciseCategory.shoulders,
      ],
      ExerciseCategory.shoulders: [
        ExerciseCategory.chest,
        ExerciseCategory.arms,
      ],
      ExerciseCategory.arms: [
        ExerciseCategory.back,
        ExerciseCategory.chest,
        ExerciseCategory.shoulders,
      ],
      ExerciseCategory.legs: [ExerciseCategory.abs],
      ExerciseCategory.abs: [ExerciseCategory.legs],
    };

    return relatedGroups[cat1]?.contains(cat2) ?? false;
  }

  static double _calculateSecondaryMuscleScore(Exercise ex1, Exercise ex2) {
    // Simplified scoring based on category relationships
    if (_areRelatedMuscleGroups(ex1.category, ex2.category)) {
      return 0.7;
    }

    // Check movement patterns for secondary muscle involvement
    final pattern1 = _getMovementPattern(ex1);
    final pattern2 = _getMovementPattern(ex2);

    if (pattern1 == pattern2) {
      return 0.5;
    }

    return 0.0;
  }

  static double _calculateMovementPatternScore(Exercise ex1, Exercise ex2) {
    final pattern1 = _getMovementPattern(ex1);
    final pattern2 = _getMovementPattern(ex2);

    if (pattern1 == pattern2) {
      return 1.0;
    } else if (_areCompatiblePatterns(pattern1, pattern2)) {
      return 0.5;
    }

    return 0.0;
  }

  static MovementPattern _getMovementPattern(Exercise exercise) {
    // Determine movement pattern based on exercise name and category
    final name = exercise.name.toLowerCase();

    // Push patterns
    if (name.contains('press') ||
        name.contains('push') ||
        name.contains('panca') ||
        name.contains('dips')) {
      return MovementPattern.push;
    }

    // Pull patterns
    if (name.contains('pull') ||
        name.contains('row') ||
        name.contains('traz') ||
        name.contains('lat') ||
        name.contains('chin')) {
      return MovementPattern.pull;
    }

    // Squat patterns
    if (name.contains('squat') || name.contains('accosciat')) {
      return MovementPattern.squat;
    }

    // Hinge patterns
    if (name.contains('deadlift') ||
        name.contains('stacco') ||
        name.contains('hip thrust') ||
        name.contains('good morning')) {
      return MovementPattern.hinge;
    }

    // Lunge patterns
    if (name.contains('lunge') ||
        name.contains('affond') ||
        name.contains('step')) {
      return MovementPattern.lunge;
    }

    // Carry patterns
    if (name.contains('carry') || name.contains('walk')) {
      return MovementPattern.carry;
    }

    // Default based on category
    switch (exercise.category) {
      case ExerciseCategory.chest:
      case ExerciseCategory.shoulders:
        return MovementPattern.push;
      case ExerciseCategory.back:
        return MovementPattern.pull;
      case ExerciseCategory.arms:
        // Arms can be push or pull, check exercise name
        if (name.contains('tricep') || name.contains('extension')) {
          return MovementPattern.push;
        } else if (name.contains('bicep') || name.contains('curl')) {
          return MovementPattern.pull;
        }
        return MovementPattern.isolation;
      case ExerciseCategory.legs:
        return MovementPattern.squat;
      case ExerciseCategory.abs:
        return MovementPattern.isolation;
      default:
        return MovementPattern.isolation;
    }
  }

  static bool _areCompatiblePatterns(MovementPattern p1, MovementPattern p2) {
    const compatiblePatterns = {
      MovementPattern.push: [MovementPattern.press],
      MovementPattern.pull: [MovementPattern.row],
      MovementPattern.squat: [MovementPattern.lunge],
      MovementPattern.hinge: [MovementPattern.squat],
    };

    return compatiblePatterns[p1]?.contains(p2) ?? false;
  }

  static double _calculateEquipmentScore(Exercise ex1, Exercise ex2) {
    // Simplified equipment scoring based on exercise names
    final name1 = ex1.name.toLowerCase();
    final name2 = ex2.name.toLowerCase();

    // Check for common equipment keywords
    final equipment = [
      'barbell',
      'dumbbell',
      'cable',
      'machine',
      'smith',
      'bilanciere',
      'manubr',
      'cavo',
      'macchin',
    ];

    String? equipment1;
    String? equipment2;

    for (final eq in equipment) {
      if (name1.contains(eq)) equipment1 = eq;
      if (name2.contains(eq)) equipment2 = eq;
    }

    if (equipment1 == equipment2 && equipment1 != null) {
      return 1.0;
    } else if (equipment1 == null && equipment2 == null) {
      return 0.8; // Both bodyweight
    }

    return 0.3; // Different equipment
  }

  static double _calculateDifficultyScore(Exercise ex1, Exercise ex2) {
    // Estimate difficulty based on exercise type and name
    final difficulty1 = _estimateDifficulty(ex1);
    final difficulty2 = _estimateDifficulty(ex2);

    final diff = (difficulty1 - difficulty2).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.5;
    return 0.0;
  }

  static int _estimateDifficulty(Exercise exercise) {
    final name = exercise.name.toLowerCase();

    // Advanced exercises (3)
    if (name.contains('olympic') ||
        name.contains('snatch') ||
        name.contains('clean') ||
        name.contains('muscle up')) {
      return 3;
    }

    // Intermediate exercises (2)
    if (name.contains('deadlift') ||
        name.contains('squat') ||
        name.contains('bench') ||
        name.contains('pull up') ||
        name.contains('dips')) {
      return 2;
    }

    // Beginner exercises (1)
    return 1;
  }

  static String _getReplacementReason(
    Exercise current,
    Exercise suggested,
    double compatibility,
  ) {
    final reasons = <String>[];

    // Same muscle group
    if (current.category == suggested.category) {
      reasons.add('Same muscle group');
    } else if (_areRelatedMuscleGroups(current.category, suggested.category)) {
      reasons.add('Works related muscles');
    }

    // Movement pattern
    final pattern1 = _getMovementPattern(current);
    final pattern2 = _getMovementPattern(suggested);
    if (pattern1 == pattern2) {
      reasons.add('Same movement pattern');
    }

    // Equipment
    final name1 = current.name.toLowerCase();
    final name2 = suggested.name.toLowerCase();
    if ((name1.contains('barbell') && name2.contains('barbell')) ||
        (name1.contains('dumbbell') && name2.contains('dumbbell'))) {
      reasons.add('Same equipment');
    }

    if (reasons.isEmpty) {
      if (compatibility > 70) {
        reasons.add('Highly compatible');
      } else if (compatibility > 50) {
        reasons.add('Good alternative');
      } else {
        reasons.add('Possible variation');
      }
    }

    return reasons.join(' • ');
  }
}

enum MovementPattern {
  push,
  pull,
  squat,
  hinge,
  lunge,
  carry,
  press,
  row,
  isolation,
}

class ExerciseSuggestion {
  const ExerciseSuggestion({
    required this.exercise,
    required this.compatibilityScore,
    required this.reason,
  });
  final Exercise exercise;
  final double compatibilityScore;
  final String reason;
}
