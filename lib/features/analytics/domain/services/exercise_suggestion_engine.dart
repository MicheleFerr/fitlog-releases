/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Exercise Suggestion Engine - Suggests exercises for neglected muscles
///
/// **Features**:
/// - Query real exercise database for suggestions
/// - Muscle-specific exercise recommendations
/// - Priority-based sorting
/// - Equipment availability filtering
/// - Difficulty level matching
/// - Correct countingMode from database
library;

import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Exercise Suggestion - Recommended exercise for neglected muscle
class ExerciseSuggestion {
  const ExerciseSuggestion({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetMuscle,
    required this.priority,
    required this.difficulty,
    required this.equipment,
    required this.description,
    required this.countingMode,
    required this.exerciseType,
    this.imageUrl,
  });

  /// Exercise ID from database (for adding to templates)
  final String exerciseId;

  /// Exercise name (e.g., "Barbell Row", "Pull-ups")
  final String exerciseName;

  /// Target muscle group
  final String targetMuscle;

  /// Priority score (0-10) - inherited from neglected muscle
  final double priority;

  /// Difficulty level
  final ExerciseDifficulty difficulty;

  /// Required equipment
  final String equipment;

  /// Brief description (pattern movimento or rep range)
  final String description;

  /// How this exercise is counted (weighted/reps/time)
  final ExerciseCountingMode countingMode;

  /// Exercise type (Compound/Isolamento)
  final String exerciseType;

  /// URL to exercise image/GIF (from exercisedb.dev)
  final String? imageUrl;
}

/// Exercise Difficulty Levels
enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced;

  /// Convert from Italian difficulty string
  static ExerciseDifficulty fromItalianString(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'principiante':
        return ExerciseDifficulty.beginner;
      case 'intermedio':
        return ExerciseDifficulty.intermediate;
      case 'avanzato':
        return ExerciseDifficulty.advanced;
      default:
        return ExerciseDifficulty.intermediate;
    }
  }
}

/// Exercise Suggestion Engine Service
///
/// **Usage**:
/// ```dart
/// final engine = ExerciseSuggestionEngine();
/// final suggestions = await engine.generateSuggestionsFromDatabase(
///   neglectedMuscles: detector.detectNeglectedMuscles(balance),
///   allExercises: exercises,
///   maxPerMuscle: 4,
/// );
///
/// for (final suggestion in suggestions) {
///   print('Try: ${suggestion.exerciseName} for ${suggestion.targetMuscle}');
/// }
/// ```
class ExerciseSuggestionEngine {
  /// Get focus codes for a muscle name
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper.getSearchAbbreviations()
  ///
  /// Balance system uses English lowercase names.
  /// Database uses Italian uppercase codes.
  static List<String> _getFocusCodesForMuscle(String muscleName) {
    final codes = MuscleAbbreviationMapper.getSearchAbbreviations(muscleName);
    if (codes.isNotEmpty) return codes;

    // Fallback for specific balance system names
    return switch (muscleName) {
      'back' => ['LAT', 'TRAP', 'LOMBAR'],
      'abs' => ['CORE'],
      'lower_back' => ['LOMBAR', 'CORE'],
      _ => [],
    };
  }

  /// Generate exercise suggestions from the real database
  ///
  /// Parameters:
  /// - [neglectedMuscles]: List of muscles needing attention
  /// - [allExercises]: All exercises from database
  /// - [maxPerMuscle]: Maximum suggestions per muscle group
  /// - [excludeExercises]: Exercise names to exclude (e.g., already in templates)
  ///
  /// Returns list sorted by priority (highest first)
  List<ExerciseSuggestion> generateSuggestionsFromDatabase({
    required List<NeglectedMuscle> neglectedMuscles,
    required List<ExerciseDefinition> allExercises,
    int maxPerMuscle = 4,
    Set<String>? excludeExercises,
  }) {
    final suggestions = <ExerciseSuggestion>[];
    final excludeSet = excludeExercises ?? {};

    for (final neglectedMuscle in neglectedMuscles) {
      final focusCodes = _getFocusCodesForMuscle(neglectedMuscle.muscleName);
      if (focusCodes.isEmpty) continue;

      // Find exercises targeting this muscle
      final matchingExercises = allExercises.where((exercise) {
        return exercise.focus.any((focus) => focusCodes.contains(focus));
      }).toList();

      // Filter out excluded exercises
      final filteredExercises = matchingExercises.where((exercise) {
        return !_isExerciseExcluded(exercise.nome, excludeSet) &&
            !_isExerciseExcluded(exercise.id, excludeSet);
      }).toList();

      // Sort by: 1) countingMode (weighted first), 2) type (Compound first), 3) difficulty
      filteredExercises.sort((a, b) {
        // 1. Prefer weighted exercises (more effective for muscle building)
        final countingCompare = _countingModeOrder(
          a.countingMode,
        ).compareTo(_countingModeOrder(b.countingMode));
        if (countingCompare != 0) return countingCompare;

        // 2. Prefer Compound over Isolamento
        final typeCompare = _typeOrder(
          a.tipoEsercizio,
        ).compareTo(_typeOrder(b.tipoEsercizio));
        if (typeCompare != 0) return typeCompare;

        // 3. Then by difficulty (beginner first for accessibility)
        return _difficultyOrder(
          a.difficolta,
        ).compareTo(_difficultyOrder(b.difficolta));
      });

      // Take max per muscle and convert to suggestions
      for (final exercise in filteredExercises.take(maxPerMuscle)) {
        suggestions.add(
          _exerciseToSuggestion(
            exercise: exercise,
            targetMuscle: neglectedMuscle.muscleName,
            priority: neglectedMuscle.priority,
          ),
        );
      }
    }

    // Sort all suggestions by priority (highest first)
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));

    return suggestions;
  }

  /// Generate suggestions grouped by muscle (for UI display)
  Map<String, List<ExerciseSuggestion>> generateSuggestionsGroupedByMuscle({
    required List<NeglectedMuscle> neglectedMuscles,
    required List<ExerciseDefinition> allExercises,
    int maxPerMuscle = 4,
    Set<String>? excludeExercises,
  }) {
    final grouped = <String, List<ExerciseSuggestion>>{};
    final excludeSet = excludeExercises ?? {};

    for (final neglectedMuscle in neglectedMuscles) {
      final focusCodes = _getFocusCodesForMuscle(neglectedMuscle.muscleName);
      if (focusCodes.isEmpty) continue;

      // Find exercises targeting this muscle
      final matchingExercises = allExercises.where((exercise) {
        return exercise.focus.any((focus) => focusCodes.contains(focus));
      }).toList();

      // Filter out excluded exercises
      final filteredExercises = matchingExercises.where((exercise) {
        return !_isExerciseExcluded(exercise.nome, excludeSet) &&
            !_isExerciseExcluded(exercise.id, excludeSet);
      }).toList();

      // Sort by: 1) countingMode (weighted first), 2) type (Compound first), 3) difficulty
      filteredExercises.sort((a, b) {
        // 1. Prefer weighted exercises (more effective for muscle building)
        final countingCompare = _countingModeOrder(
          a.countingMode,
        ).compareTo(_countingModeOrder(b.countingMode));
        if (countingCompare != 0) return countingCompare;

        // 2. Prefer Compound over Isolamento
        final typeCompare = _typeOrder(
          a.tipoEsercizio,
        ).compareTo(_typeOrder(b.tipoEsercizio));
        if (typeCompare != 0) return typeCompare;

        // 3. Then by difficulty
        return _difficultyOrder(
          a.difficolta,
        ).compareTo(_difficultyOrder(b.difficolta));
      });

      // Take max per muscle and convert to suggestions
      final muscleSuggestions = filteredExercises.take(maxPerMuscle).map((
        exercise,
      ) {
        return _exerciseToSuggestion(
          exercise: exercise,
          targetMuscle: neglectedMuscle.muscleName,
          priority: neglectedMuscle.priority,
        );
      }).toList();

      if (muscleSuggestions.isNotEmpty) {
        grouped[neglectedMuscle.muscleName] = muscleSuggestions;
      }
    }

    return grouped;
  }

  /// Convert ExerciseDefinition to ExerciseSuggestion
  ExerciseSuggestion _exerciseToSuggestion({
    required ExerciseDefinition exercise,
    required String targetMuscle,
    required double priority,
  }) {
    return ExerciseSuggestion(
      exerciseId: exercise.id,
      exerciseName: exercise.nome,
      targetMuscle: targetMuscle,
      priority: priority,
      difficulty: ExerciseDifficulty.fromItalianString(exercise.difficolta),
      equipment: exercise.attrezzatura,
      description: exercise.patternMovimento.isNotEmpty
          ? exercise.patternMovimento
          : exercise.rangeRipetizioni,
      countingMode: exercise.countingMode,
      exerciseType: exercise.tipoEsercizio,
      imageUrl: exercise.imageUrl,
    );
  }

  /// Order for exercise types (Compound first)
  int _typeOrder(String type) {
    switch (type.toLowerCase()) {
      case 'compound':
        return 0;
      case 'isolamento':
        return 1;
      default:
        return 2;
    }
  }

  /// Order for difficulty (beginner first for accessibility)
  int _difficultyOrder(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return 0;
      case 'intermedio':
        return 1;
      case 'avanzato':
        return 2;
      default:
        return 1;
    }
  }

  /// Order for counting mode (weighted first - more effective for hypertrophy)
  int _countingModeOrder(ExerciseCountingMode mode) {
    switch (mode) {
      case ExerciseCountingMode.weighted:
        return 0; // Preferred - allows progressive overload with weights
      case ExerciseCountingMode.reps:
        return 1; // Bodyweight - good but harder to progressively overload
      case ExerciseCountingMode.time:
        return 2; // Time-based - less common for strength training
    }
  }

  /// Check if exercise name matches any excluded exercise (case-insensitive)
  bool _isExerciseExcluded(String exerciseName, Set<String> excludeSet) {
    if (excludeSet.isEmpty) return false;

    final lowerName = exerciseName.toLowerCase();
    return excludeSet.any(
      (excluded) =>
          excluded.toLowerCase() == lowerName ||
          lowerName.contains(excluded.toLowerCase()) ||
          excluded.toLowerCase().contains(lowerName),
    );
  }

  // ========== LEGACY SYNC METHODS (for backward compatibility) ==========

  /// Fallback static database for when async loading isn't possible
  /// This is used by widgets that can't easily be converted to async
  static final Map<String, List<_LegacyExerciseTemplate>> _legacyDatabase = {
    'back': [
      const _LegacyExerciseTemplate(
        id: 'pull_up',
        name: 'Pull-ups',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Sbarra',
        description: 'Pull Pattern',
        countingMode: ExerciseCountingMode.reps,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'barbell_row',
        name: 'Barbell Row',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Pull Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'lat_pulldown',
        name: 'Lat Pulldown',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Cavi',
        description: 'Pull Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
    ],
    'hamstrings': [
      const _LegacyExerciseTemplate(
        id: 'romanian_deadlift',
        name: 'Romanian Deadlift',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Hip Hinge Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'leg_curl',
        name: 'Leg Curl',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Macchina',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
    ],
    'glutes': [
      const _LegacyExerciseTemplate(
        id: 'hip_thrust',
        name: 'Hip Thrust',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Bilanciere',
        description: 'Hip Hinge Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'bulgarian_split_squat',
        name: 'Bulgarian Split Squat',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Manubri',
        description: 'Lunge Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
    ],
    'calves': [
      const _LegacyExerciseTemplate(
        id: 'standing_calf_raise',
        name: 'Standing Calf Raise',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Macchina',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
    ],
    'triceps': [
      const _LegacyExerciseTemplate(
        id: 'close_grip_bench',
        name: 'Close-Grip Bench Press',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Push Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'tricep_pushdown',
        name: 'Tricep Pushdown',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Cavi',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
    ],
    'abs': [
      const _LegacyExerciseTemplate(
        id: 'hanging_leg_raise',
        name: 'Hanging Leg Raise',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Sbarra',
        description: 'Core Pattern',
        countingMode: ExerciseCountingMode.reps,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'plank',
        name: 'Plank',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Corpo Libero',
        description: 'Core Stability',
        countingMode: ExerciseCountingMode.time,
        exerciseType: 'Isolamento',
      ),
    ],
    'shoulders': [
      const _LegacyExerciseTemplate(
        id: 'overhead_press',
        name: 'Overhead Press',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Push Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'lateral_raise',
        name: 'Lateral Raise',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Manubri',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
    ],
    'chest': [
      const _LegacyExerciseTemplate(
        id: 'bench_press',
        name: 'Bench Press',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Push Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'dumbbell_fly',
        name: 'Dumbbell Fly',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Manubri',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
    ],
    'biceps': [
      const _LegacyExerciseTemplate(
        id: 'barbell_curl',
        name: 'Barbell Curl',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Bilanciere',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
      const _LegacyExerciseTemplate(
        id: 'chin_up',
        name: 'Chin-ups',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Sbarra',
        description: 'Pull Pattern',
        countingMode: ExerciseCountingMode.reps,
        exerciseType: 'Compound',
      ),
    ],
    'quads': [
      const _LegacyExerciseTemplate(
        id: 'squat',
        name: 'Squat',
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Squat Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
      ),
      const _LegacyExerciseTemplate(
        id: 'leg_extension',
        name: 'Leg Extension',
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'Macchina',
        description: 'Isolation',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Isolamento',
      ),
    ],
  };

  /// Legacy sync method - uses static database as fallback
  /// @deprecated Use generateSuggestionsFromDatabase with real exercises instead
  List<ExerciseSuggestion> generateSuggestions({
    required List<NeglectedMuscle> neglectedMuscles,
    int maxSuggestions = 5,
    ExerciseDifficulty? maxDifficulty,
    Set<String>? excludeExercises,
  }) {
    final suggestions = <ExerciseSuggestion>[];
    final excludeSet = excludeExercises ?? {};

    for (final neglectedMuscle in neglectedMuscles) {
      final exercises = _legacyDatabase[neglectedMuscle.muscleName] ?? [];

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
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            targetMuscle: neglectedMuscle.muscleName,
            priority: neglectedMuscle.priority,
            difficulty: exercise.difficulty,
            equipment: exercise.equipment,
            description: exercise.description,
            countingMode: exercise.countingMode,
            exerciseType: exercise.exerciseType,
          ),
        );
      }
    }

    // Sort by priority (highest first)
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));

    // Limit to maxSuggestions
    return suggestions.take(maxSuggestions).toList();
  }

  /// Legacy sync method grouped by muscle
  /// @deprecated Use generateSuggestionsGroupedByMuscle with real exercises instead
  Map<String, List<ExerciseSuggestion>>
  generateSuggestionsGroupedByMuscleLegacy({
    required List<NeglectedMuscle> neglectedMuscles,
    ExerciseDifficulty? maxDifficulty,
    Set<String>? excludeExercises,
  }) {
    final grouped = <String, List<ExerciseSuggestion>>{};
    final excludeSet = excludeExercises ?? {};

    for (final neglectedMuscle in neglectedMuscles) {
      final exercises = _legacyDatabase[neglectedMuscle.muscleName] ?? [];
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
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            targetMuscle: neglectedMuscle.muscleName,
            priority: neglectedMuscle.priority,
            difficulty: exercise.difficulty,
            equipment: exercise.equipment,
            description: exercise.description,
            countingMode: exercise.countingMode,
            exerciseType: exercise.exerciseType,
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

/// Internal legacy exercise template (for fallback only)
class _LegacyExerciseTemplate {
  const _LegacyExerciseTemplate({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.equipment,
    required this.description,
    required this.countingMode,
    required this.exerciseType,
  });

  final String id;
  final String name;
  final ExerciseDifficulty difficulty;
  final String equipment;
  final String description;
  final ExerciseCountingMode countingMode;
  final String exerciseType;
}
