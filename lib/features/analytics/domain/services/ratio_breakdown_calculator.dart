/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/services
/// 🎯 Feature: analytics
/// 🔧 Type: service
///
/// Ratio Breakdown Calculator - Calculates exercise contributions to ratio categories
///
/// **Design Rationale**:
/// - Single Responsibility: Dedicated service for breakdown calculation
/// - Separated from MuscleBalanceCalculator: Different concerns
/// - Reusable muscle classification methods
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/ratio_breakdown.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';

/// Ratio Breakdown Calculator Service
///
/// Calculates detailed exercise contributions to push/pull and upper/lower ratios.
///
/// **Usage**:
/// ```dart
/// final calculator = RatioBreakdownCalculator();
/// final breakdown = calculator.calculateBreakdown(exerciseHistories);
///
/// // Access push exercises
/// for (final exercise in breakdown.pushBreakdown.allExercises) {
///   print('${exercise.exerciseName}: ${exercise.percentage}%');
/// }
/// ```
class RatioBreakdownCalculator {
  /// Calculate complete ratio breakdown from exercise histories
  ///
  /// Uses custom exercise categorization first, then exercise name inference
  /// to correctly classify push/pull when the stored muscleGroup is generic.
  ///
  /// [customExercises] - Map of exercise name (lowercase) to CustomExercise
  /// for proper categorization of user-defined exercises
  RatioBreakdown calculateBreakdown(
    List<ExerciseHistory> exerciseHistories, {
    Map<String, CustomExercise>? customExercises,
  }) {
    if (exerciseHistories.isEmpty) {
      return RatioBreakdown.empty();
    }

    // Aggregate exercise volumes with corrected muscle groups
    final Map<String, _ExerciseData> exerciseVolumes = {};

    for (final history in exerciseHistories) {
      final key = history.exerciseName.toLowerCase();
      final volume = history.sessions.fold<double>(
        0,
        (sum, session) => sum + session.totalVolume,
      );

      // Use corrected muscle group with custom exercise data first
      final customExercise = customExercises?[key];
      final correctedMuscle = _getCorrectedMuscleGroup(
        history.exerciseName,
        history.muscleGroup,
        customExercise: customExercise,
      );

      if (exerciseVolumes.containsKey(key)) {
        exerciseVolumes[key] = _ExerciseData(
          name: history.exerciseName,
          muscleGroup: correctedMuscle,
          volume: exerciseVolumes[key]!.volume + volume,
        );
      } else {
        exerciseVolumes[key] = _ExerciseData(
          name: history.exerciseName,
          muscleGroup: correctedMuscle,
          volume: volume,
        );
      }
    }

    // Classify into categories
    final pushExercises = <String, List<_ExerciseData>>{};
    final pullExercises = <String, List<_ExerciseData>>{};
    final upperExercises = <String, List<_ExerciseData>>{};
    final lowerExercises = <String, List<_ExerciseData>>{};

    double pushTotal = 0;
    double pullTotal = 0;
    double upperTotal = 0;
    double lowerTotal = 0;

    for (final data in exerciseVolumes.values) {
      final muscle = data.muscleGroup.toLowerCase();

      // Classify as push
      if (_isPushMuscle(muscle)) {
        pushExercises.putIfAbsent(muscle, () => []).add(data);
        pushTotal += data.volume;
      }

      // Classify as pull
      if (_isPullMuscle(muscle)) {
        pullExercises.putIfAbsent(muscle, () => []).add(data);
        pullTotal += data.volume;
      }

      // Classify as upper body
      if (_isUpperBody(muscle)) {
        upperExercises.putIfAbsent(muscle, () => []).add(data);
        upperTotal += data.volume;
      }

      // Classify as lower body
      if (_isLowerBody(muscle)) {
        lowerExercises.putIfAbsent(muscle, () => []).add(data);
        lowerTotal += data.volume;
      }
    }

    return RatioBreakdown(
      pushBreakdown: _buildCategoryBreakdown('Push', pushExercises, pushTotal),
      pullBreakdown: _buildCategoryBreakdown('Pull', pullExercises, pullTotal),
      upperBreakdown: _buildCategoryBreakdown('Upper', upperExercises, upperTotal),
      lowerBreakdown: _buildCategoryBreakdown('Lower', lowerExercises, lowerTotal),
    );
  }

  /// Build category breakdown from exercise data
  CategoryBreakdown _buildCategoryBreakdown(
    String categoryName,
    Map<String, List<_ExerciseData>> exercisesByMuscle,
    double totalVolume,
  ) {
    final Map<String, List<ExerciseContribution>> contributions = {};

    for (final entry in exercisesByMuscle.entries) {
      final muscle = entry.key;
      final exercises = entry.value;

      contributions[muscle] = exercises.map((data) {
        final percentage = totalVolume > 0 ? (data.volume / totalVolume) * 100 : 0.0;
        return ExerciseContribution(
          exerciseName: data.name,
          muscleGroup: data.muscleGroup,
          volume: data.volume,
          percentage: percentage,
          isPrimary: true,
        );
      }).toList()
        ..sort((a, b) => b.volume.compareTo(a.volume));
    }

    return CategoryBreakdown(
      categoryName: categoryName,
      totalVolume: totalVolume,
      exercisesByMuscle: contributions,
    );
  }

  /// Check if muscle is a push muscle
  ///
  /// Supports both English and Italian abbreviations:
  /// - English: chest, pectorals, triceps, shoulders, delts, quads
  /// - Italian: pett (pettorali), tric (tricipiti), delt (deltoidi), quad (quadricipiti)
  ///
  /// **Deltoid Classification** (P0 fix):
  /// - DELT_ANT (anterior) → PUSH
  /// - DELT_LAT (lateral) → NEUTRAL (excluded from push/pull)
  /// - DELT_POST (posterior) → PULL (see _isPullMuscle)
  /// - DELT (generic) → PUSH (backward compatibility)
  bool _isPushMuscle(String muscle) {
    // First, check for specific deltoid portions
    final muscleLower = muscle.toLowerCase();

    // DELT_LAT is neutral (not push, not pull) - skip it
    if (muscleLower.contains('delt_lat')) {
      return false;
    }

    // DELT_POST is a pull muscle - skip it
    if (muscleLower.contains('delt_post')) {
      return false;
    }

    // DELT_ANT is a push muscle
    if (muscleLower.contains('delt_ant')) {
      return true;
    }

    const pushMuscles = [
      // English
      'chest',
      'pectorals',
      'triceps',
      'shoulders',
      'anterior delts',
      'front delts',
      'quads',
      'quadriceps',
      // Italian abbreviations from JSON
      'pett', // Pettorali
      'tric', // Tricipiti
      'delt', // Deltoidi (generic - legacy, backward compatibility)
      'quad', // Quadricipiti
    ];
    return pushMuscles.any((push) => muscle.contains(push));
  }

  /// Check if muscle is a pull muscle
  ///
  /// Supports both English and Italian abbreviations:
  /// - English: back, lats, traps, biceps, hamstrings, rear delts
  /// - Italian: lat (latissimus), trap (trapezio), bic (bicipiti), femor (femorali)
  ///
  /// **Deltoid Classification** (P0 fix):
  /// - DELT_POST (posterior) → PULL
  /// - DELT_ANT (anterior) → PUSH (see _isPushMuscle)
  /// - DELT_LAT (lateral) → NEUTRAL (excluded from push/pull)
  bool _isPullMuscle(String muscle) {
    // First, check for specific deltoid portions
    final muscleLower = muscle.toLowerCase();

    // DELT_POST is a pull muscle
    if (muscleLower.contains('delt_post')) {
      return true;
    }

    // DELT_ANT and DELT_LAT are NOT pull muscles
    if (muscleLower.contains('delt_ant') || muscleLower.contains('delt_lat')) {
      return false;
    }

    const pullMuscles = [
      // English
      'back',
      'lats',
      'traps',
      'biceps',
      'hamstrings',
      'rear delts',
      'posterior delts',
      'posterior',
      'rhomboids',
      // Italian abbreviations from JSON
      'lat', // Latissimus
      'trap', // Trapezio
      'bic', // Bicipiti
      'femor', // Femorali (hamstrings)
      'dorso', // Back
    ];
    return pullMuscles.any((pull) => muscle.contains(pull));
  }

  /// Check if muscle is upper body
  ///
  /// Supports both English and Italian abbreviations
  bool _isUpperBody(String muscle) {
    const upperMuscles = [
      // English
      'chest',
      'pectorals',
      'back',
      'lats',
      'traps',
      'shoulders',
      'delts',
      'biceps',
      'triceps',
      'arms',
      'forearms',
      'abs',
      'core',
      'neck',
      // Italian abbreviations
      'pett', // Pettorali
      'lat', // Latissimus
      'trap', // Trapezio
      'delt', // Deltoidi
      'bic', // Bicipiti
      'tric', // Tricipiti
      'ava', // Avambracci (forearms)
      'avamb', // Avambracci
      'addom', // Addominali
      'dorso', // Back
      'lombar', // Lombari
      'lomb', // Lombari
      'lom', // Lombari
      'collo', // Collo (neck)
    ];
    return upperMuscles.any((upper) => muscle.contains(upper));
  }

  /// Check if muscle is lower body
  ///
  /// Supports both English and Italian abbreviations
  bool _isLowerBody(String muscle) {
    const lowerMuscles = [
      // English
      'legs',
      'quads',
      'quadriceps',
      'hamstrings',
      'glutes',
      'calves',
      'hips',
      'adductors',
      'abductors',
      // Italian abbreviations
      'quad', // Quadricipiti
      'femor', // Femorali
      'femo', // Femorali (short)
      'glut', // Glutei
      'polp', // Polpacci
      'poll', // Polpacci (variant)
      'addut', // Adduttori (specific, avoids matching 'addom')
      'addu', // Adduttori (specific, avoids matching 'addom')
      'abdut', // Abduttori
      'abdu', // Abduttori
    ];
    return lowerMuscles.any((lower) => muscle.contains(lower));
  }

  /// Determine correct muscle classification based on exercise name
  /// Used as fallback when muscleGroup data might be incorrect
  ///
  /// Returns specific muscle groups for push/pull classification:
  /// - 'quads' for quad-dominant exercises (push)
  /// - 'hamstrings' for hamstring-dominant exercises (pull)
  /// - 'biceps' for curl exercises (pull)
  /// - 'triceps' for extension exercises (push)
  /// - 'chest' for chest exercises (push)
  /// - 'back' for back exercises (pull)
  String _inferMuscleFromName(String exerciseName) {
    final nameLower = exerciseName.toLowerCase();

    // === PUSH EXERCISES ===

    // Quad-dominant (PUSH) - squat patterns
    const quadPatterns = [
      'leg extension',
      'leg press',
      'squat',
      'sissy squat',
      'hack squat',
      'front squat',
      'affond', // affondo, affondi (lunges)
      'lunge',
      'bulgarian',
      'step up',
      'pressa', // leg press italiano
      'quadricip',
    ];

    for (final pattern in quadPatterns) {
      if (nameLower.contains(pattern)) {
        return 'quads';
      }
    }

    // Triceps (PUSH)
    const tricepsPatterns = [
      'tricep',
      'pushdown',
      'push down',
      'skull crusher',
      'french press',
      'dip', // Note: dips can also work chest
      'close grip',
      'diamond',
      'kickback',
      'estensione tricipiti',
      'push-down',
    ];

    for (final pattern in tricepsPatterns) {
      if (nameLower.contains(pattern)) {
        return 'triceps';
      }
    }

    // Chest (PUSH)
    const chestPatterns = [
      'bench press',
      'panca piana',
      'panca inclinata',
      'panca declinata',
      'chest',
      'pettoral',
      'fly',
      'flye',
      'crossover',
      'pec deck',
      'push up',
      'pushup',
    ];

    for (final pattern in chestPatterns) {
      if (nameLower.contains(pattern)) {
        return 'chest';
      }
    }

    // === PULL EXERCISES ===

    // Hamstring-dominant (PULL) - hip hinge patterns
    const hamstringPatterns = [
      'leg curl',
      'lying curl',
      'seated curl',
      'stacco rumeno',
      'romanian deadlift',
      'rdl',
      'good morning',
      'glute ham',
      'hip thrust',
      'femorali',
      'nordic',
      'hyperextension',
    ];

    for (final pattern in hamstringPatterns) {
      if (nameLower.contains(pattern)) {
        return 'hamstrings';
      }
    }

    // Biceps (PULL)
    const bicepsPatterns = [
      'bicep',
      'curl', // General curl = biceps (leg curl handled above)
      'preacher',
      'hammer',
      'concentration',
      'spider curl',
      'incline curl',
      'ez bar curl',
      'barbell curl',
    ];

    for (final pattern in bicepsPatterns) {
      if (nameLower.contains(pattern)) {
        // Avoid false match with "leg curl"
        if (nameLower.contains('leg curl')) continue;
        return 'biceps';
      }
    }

    // Back (PULL)
    const backPatterns = [
      'row',
      'pull up',
      'pullup',
      'pull-up',
      'chin up',
      'chinup',
      'chin-up',
      'lat pull',
      'pulldown',
      'deadlift', // Standard deadlift (not RDL) is more back-focused
      'stacco da terra',
      'rematore',
      'trazioni',
      'lat machine',
      't-bar',
      'seal row',
      'meadow',
      'dorso',
    ];

    for (final pattern in backPatterns) {
      if (nameLower.contains(pattern)) {
        return 'back';
      }
    }

    // Keep original if no pattern matches
    return '';
  }

  /// Get corrected muscle group using custom exercise data first, then name inference
  ///
  /// Priority order:
  /// 1. User's custom exercise categorization (if exists)
  /// 2. Name-based inference patterns
  /// 3. Original stored muscle group
  String _getCorrectedMuscleGroup(
    String exerciseName,
    String storedMuscleGroup, {
    CustomExercise? customExercise,
  }) {
    // 1. Check custom exercise patternMovimento first (only if user modified it)
    if (customExercise != null &&
        customExercise.isModifiedFromBase &&
        customExercise.patternMovimento.isNotEmpty) {
      final pattern = customExercise.patternMovimento.toLowerCase();

      // Map pattern to muscle group for push/pull classification
      if (pattern == 'push') {
        // Use first focus muscle or default to 'chest' for push
        return customExercise.focus.isNotEmpty
            ? customExercise.focus.first.toLowerCase()
            : 'chest';
      } else if (pattern == 'pull') {
        // Use first focus muscle or default to 'back' for pull
        return customExercise.focus.isNotEmpty
            ? customExercise.focus.first.toLowerCase()
            : 'back';
      } else if (pattern == 'hinge' || pattern == 'squat' || pattern == 'accessory') {
        // For other patterns, use first focus muscle if available
        if (customExercise.focus.isNotEmpty) {
          return customExercise.focus.first.toLowerCase();
        }
      }
    }

    // 2. Fallback to name-based inference
    final inferred = _inferMuscleFromName(exerciseName);
    return inferred.isNotEmpty ? inferred : storedMuscleGroup;
  }

  /// Calculate breakdown with name-based correction
  ///
  /// Uses custom exercise categorization first, then exercise name inference.
  ///
  /// [customExercises] - Map of exercise name (lowercase) to CustomExercise
  /// for proper categorization of user-defined exercises
  RatioBreakdown calculateCorrectedBreakdown(
    List<ExerciseHistory> exerciseHistories, {
    Map<String, CustomExercise>? customExercises,
  }) {
    if (exerciseHistories.isEmpty) {
      return RatioBreakdown.empty();
    }

    // Aggregate exercise volumes with corrected muscle groups
    final Map<String, _ExerciseData> exerciseVolumes = {};

    for (final history in exerciseHistories) {
      final key = history.exerciseName.toLowerCase();
      final volume = history.sessions.fold<double>(
        0,
        (sum, session) => sum + session.totalVolume,
      );

      // Use corrected muscle group with custom exercise data first
      final customExercise = customExercises?[key];
      final correctedMuscle = _getCorrectedMuscleGroup(
        history.exerciseName,
        history.muscleGroup,
        customExercise: customExercise,
      );

      if (exerciseVolumes.containsKey(key)) {
        exerciseVolumes[key] = _ExerciseData(
          name: history.exerciseName,
          muscleGroup: correctedMuscle,
          volume: exerciseVolumes[key]!.volume + volume,
        );
      } else {
        exerciseVolumes[key] = _ExerciseData(
          name: history.exerciseName,
          muscleGroup: correctedMuscle,
          volume: volume,
        );
      }
    }

    // Classify into categories (same logic as calculateBreakdown)
    final pushExercises = <String, List<_ExerciseData>>{};
    final pullExercises = <String, List<_ExerciseData>>{};
    final upperExercises = <String, List<_ExerciseData>>{};
    final lowerExercises = <String, List<_ExerciseData>>{};

    double pushTotal = 0;
    double pullTotal = 0;
    double upperTotal = 0;
    double lowerTotal = 0;

    for (final data in exerciseVolumes.values) {
      final muscle = data.muscleGroup.toLowerCase();

      if (_isPushMuscle(muscle)) {
        pushExercises.putIfAbsent(muscle, () => []).add(data);
        pushTotal += data.volume;
      }

      if (_isPullMuscle(muscle)) {
        pullExercises.putIfAbsent(muscle, () => []).add(data);
        pullTotal += data.volume;
      }

      if (_isUpperBody(muscle)) {
        upperExercises.putIfAbsent(muscle, () => []).add(data);
        upperTotal += data.volume;
      }

      if (_isLowerBody(muscle)) {
        lowerExercises.putIfAbsent(muscle, () => []).add(data);
        lowerTotal += data.volume;
      }
    }

    return RatioBreakdown(
      pushBreakdown: _buildCategoryBreakdown('Push', pushExercises, pushTotal),
      pullBreakdown: _buildCategoryBreakdown('Pull', pullExercises, pullTotal),
      upperBreakdown: _buildCategoryBreakdown('Upper', upperExercises, upperTotal),
      lowerBreakdown: _buildCategoryBreakdown('Lower', lowerExercises, lowerTotal),
    );
  }
}

/// Internal data class for exercise aggregation
class _ExerciseData {
  const _ExerciseData({
    required this.name,
    required this.muscleGroup,
    required this.volume,
  });

  final String name;
  final String muscleGroup;
  final double volume;
}
