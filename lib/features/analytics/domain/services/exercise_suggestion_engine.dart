/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Exercise Suggestion Engine - Suggests exercises for neglected muscles
///
/// **Features**:
/// - Muscle-specific exercise recommendations
/// - Priority-based sorting
/// - Equipment availability filtering
/// - Difficulty level matching
library;

import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';

/// Exercise Suggestion - Recommended exercise for neglected muscle
class ExerciseSuggestion {
  const ExerciseSuggestion({
    required this.exerciseName,
    required this.targetMuscle,
    required this.priority,
    required this.difficulty,
    required this.equipment,
    required this.description,
  });

  /// Exercise name (e.g., "Barbell Row", "Pull-ups")
  final String exerciseName;

  /// Target muscle group
  final String targetMuscle;

  /// Priority score (0-10) - inherited from neglected muscle
  final double priority;

  /// Difficulty level
  final ExerciseDifficulty difficulty;

  /// Required equipment
  final List<String> equipment;

  /// Brief description
  final String description;
}

/// Exercise Difficulty Levels
enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// Exercise Suggestion Engine Service
///
/// **Usage**:
/// ```dart
/// final engine = ExerciseSuggestionEngine();
/// final suggestions = engine.generateSuggestions(
///   neglectedMuscles: detector.detectNeglectedMuscles(balance),
///   maxSuggestions: 5,
/// );
///
/// for (final suggestion in suggestions) {
///   print('Try: ${suggestion.exerciseName} for ${suggestion.targetMuscle}');
/// }
/// ```
class ExerciseSuggestionEngine {
  /// Exercise database mapping: muscle → exercises
  ///
  /// **Note**: In production, this should query the real exercise database
  /// from `exercise_database` feature. For now, using hardcoded mappings.
  static final Map<String, List<_ExerciseTemplate>> _exerciseDatabase = {
    'back': [
      _ExerciseTemplate(
        name: 'Pull-ups',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['pull_up_bar'],
        description: 'Classic compound movement for back width',
      ),
      _ExerciseTemplate(
        name: 'Barbell Row',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['barbell'],
        description: 'Build back thickness and strength',
      ),
      _ExerciseTemplate(
        name: 'Lat Pulldown',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['cable_machine'],
        description: 'Machine alternative to pull-ups',
      ),
      _ExerciseTemplate(
        name: 'Dumbbell Row',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['dumbbells'],
        description: 'Unilateral back development',
      ),
    ],
    'hamstrings': [
      _ExerciseTemplate(
        name: 'Romanian Deadlift',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['barbell'],
        description: 'Target hamstrings and glutes',
      ),
      _ExerciseTemplate(
        name: 'Leg Curl',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['leg_curl_machine'],
        description: 'Isolate hamstrings',
      ),
      _ExerciseTemplate(
        name: 'Nordic Curls',
        difficulty: ExerciseDifficulty.advanced,
        equipment: ['bodyweight'],
        description: 'Advanced hamstring strength',
      ),
    ],
    'glutes': [
      _ExerciseTemplate(
        name: 'Hip Thrust',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['barbell', 'bench'],
        description: 'Best glute activation exercise',
      ),
      _ExerciseTemplate(
        name: 'Bulgarian Split Squat',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['dumbbells', 'bench'],
        description: 'Unilateral glute and quad work',
      ),
    ],
    'calves': [
      _ExerciseTemplate(
        name: 'Standing Calf Raise',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['calf_raise_machine'],
        description: 'Build calf size',
      ),
      _ExerciseTemplate(
        name: 'Seated Calf Raise',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['seated_calf_machine'],
        description: 'Target soleus muscle',
      ),
    ],
    'triceps': [
      _ExerciseTemplate(
        name: 'Close-Grip Bench Press',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['barbell', 'bench'],
        description: 'Compound tricep builder',
      ),
      _ExerciseTemplate(
        name: 'Tricep Dips',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['dip_bar'],
        description: 'Bodyweight tricep mass',
      ),
      _ExerciseTemplate(
        name: 'Overhead Tricep Extension',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['dumbbells'],
        description: 'Isolate long head',
      ),
    ],
    'abs': [
      _ExerciseTemplate(
        name: 'Hanging Leg Raise',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['pull_up_bar'],
        description: 'Full core activation',
      ),
      _ExerciseTemplate(
        name: 'Cable Crunch',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['cable_machine'],
        description: 'Progressive ab overload',
      ),
      _ExerciseTemplate(
        name: 'Plank Variations',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['bodyweight'],
        description: 'Core stability',
      ),
    ],
    'shoulders': [
      _ExerciseTemplate(
        name: 'Overhead Press',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: ['barbell'],
        description: 'Compound shoulder builder',
      ),
      _ExerciseTemplate(
        name: 'Lateral Raise',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['dumbbells'],
        description: 'Side delt isolation',
      ),
      _ExerciseTemplate(
        name: 'Face Pulls',
        difficulty: ExerciseDifficulty.beginner,
        equipment: ['cable_machine'],
        description: 'Rear delt and rotator cuff',
      ),
    ],
  };

  /// Generate exercise suggestions for neglected muscles
  ///
  /// Parameters:
  /// - [neglectedMuscles]: List of muscles needing attention
  /// - [maxSuggestions]: Maximum suggestions to return
  /// - [maxDifficulty]: Filter out exercises above this difficulty
  /// - [excludeExercises]: Exercise names to exclude (e.g., already in templates)
  ///
  /// Returns sorted list (highest priority first)
  List<ExerciseSuggestion> generateSuggestions({
    required List<NeglectedMuscle> neglectedMuscles,
    int maxSuggestions = 5,
    ExerciseDifficulty? maxDifficulty,
    Set<String>? excludeExercises,
  }) {
    final suggestions = <ExerciseSuggestion>[];
    final excludeSet = excludeExercises ?? {};

    for (final neglectedMuscle in neglectedMuscles) {
      final exercises = _exerciseDatabase[neglectedMuscle.muscleName] ?? [];

      for (final exercise in exercises) {
        // Filter by difficulty if specified
        if (maxDifficulty != null &&
            exercise.difficulty.index > maxDifficulty.index) {
          continue;
        }

        // Skip exercises already in user's templates
        if (_isExerciseExcluded(exercise.name, excludeSet)) {
          continue;
        }

        suggestions.add(
          ExerciseSuggestion(
            exerciseName: exercise.name,
            targetMuscle: neglectedMuscle.muscleName,
            priority: neglectedMuscle.priority,
            difficulty: exercise.difficulty,
            equipment: exercise.equipment,
            description: exercise.description,
          ),
        );
      }
    }

    // Sort by priority (highest first)
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));

    // Limit to maxSuggestions
    return suggestions.take(maxSuggestions).toList();
  }

  /// Check if exercise name matches any excluded exercise (case-insensitive)
  bool _isExerciseExcluded(String exerciseName, Set<String> excludeSet) {
    if (excludeSet.isEmpty) return false;

    final lowerName = exerciseName.toLowerCase();
    return excludeSet.any((excluded) =>
        excluded.toLowerCase() == lowerName ||
        lowerName.contains(excluded.toLowerCase()) ||
        excluded.toLowerCase().contains(lowerName));
  }

  /// Get all suggestions grouped by muscle
  ///
  /// Useful for UI that displays suggestions per muscle group
  ///
  /// Parameters:
  /// - [neglectedMuscles]: List of muscles needing attention
  /// - [maxDifficulty]: Filter out exercises above this difficulty
  /// - [excludeExercises]: Exercise names to exclude (e.g., already in templates)
  Map<String, List<ExerciseSuggestion>> generateSuggestionsGroupedByMuscle({
    required List<NeglectedMuscle> neglectedMuscles,
    ExerciseDifficulty? maxDifficulty,
    Set<String>? excludeExercises,
  }) {
    final grouped = <String, List<ExerciseSuggestion>>{};
    final excludeSet = excludeExercises ?? {};

    for (final neglectedMuscle in neglectedMuscles) {
      final exercises = _exerciseDatabase[neglectedMuscle.muscleName] ?? [];
      final muscleSuggestions = <ExerciseSuggestion>[];

      for (final exercise in exercises) {
        // Filter by difficulty if specified
        if (maxDifficulty != null &&
            exercise.difficulty.index > maxDifficulty.index) {
          continue;
        }

        // Skip exercises already in user's templates
        if (_isExerciseExcluded(exercise.name, excludeSet)) {
          continue;
        }

        muscleSuggestions.add(
          ExerciseSuggestion(
            exerciseName: exercise.name,
            targetMuscle: neglectedMuscle.muscleName,
            priority: neglectedMuscle.priority,
            difficulty: exercise.difficulty,
            equipment: exercise.equipment,
            description: exercise.description,
          ),
        );
      }

      if (muscleSuggestions.isNotEmpty) {
        grouped[neglectedMuscle.muscleName] = muscleSuggestions;
      }
    }

    return grouped;
  }
}

/// Internal exercise template
class _ExerciseTemplate {
  const _ExerciseTemplate({
    required this.name,
    required this.difficulty,
    required this.equipment,
    required this.description,
  });

  final String name;
  final ExerciseDifficulty difficulty;
  final List<String> equipment;
  final String description;
}
