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
  RatioBreakdown calculateBreakdown(List<ExerciseHistory> exerciseHistories) {
    if (exerciseHistories.isEmpty) {
      return RatioBreakdown.empty();
    }

    // Aggregate exercise volumes
    final Map<String, _ExerciseData> exerciseVolumes = {};

    for (final history in exerciseHistories) {
      final key = history.exerciseName.toLowerCase();
      final volume = history.sessions.fold<double>(
        0,
        (sum, session) => sum + session.totalVolume,
      );

      if (exerciseVolumes.containsKey(key)) {
        exerciseVolumes[key] = _ExerciseData(
          name: history.exerciseName,
          muscleGroup: history.muscleGroup,
          volume: exerciseVolumes[key]!.volume + volume,
        );
      } else {
        exerciseVolumes[key] = _ExerciseData(
          name: history.exerciseName,
          muscleGroup: history.muscleGroup,
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
  bool _isPushMuscle(String muscle) {
    const pushMuscles = [
      'chest',
      'pectorals',
      'triceps',
      'shoulders',
      'delts',
      'anterior delts',
      'quads',
      'quadriceps',
    ];
    return pushMuscles.any((push) => muscle.contains(push));
  }

  /// Check if muscle is a pull muscle
  bool _isPullMuscle(String muscle) {
    const pullMuscles = [
      'back',
      'lats',
      'traps',
      'biceps',
      'hamstrings',
      'rear delts',
      'posterior',
      'rhomboids',
    ];
    return pullMuscles.any((pull) => muscle.contains(pull));
  }

  /// Check if muscle is upper body
  bool _isUpperBody(String muscle) {
    const upperMuscles = [
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
      'abs',
      'core',
    ];
    return upperMuscles.any((upper) => muscle.contains(upper));
  }

  /// Check if muscle is lower body
  bool _isLowerBody(String muscle) {
    const lowerMuscles = [
      'legs',
      'quads',
      'quadriceps',
      'hamstrings',
      'glutes',
      'calves',
      'hips',
    ];
    return lowerMuscles.any((lower) => muscle.contains(lower));
  }

  /// Determine correct muscle classification based on exercise name
  /// Used as fallback when muscleGroup data might be incorrect
  String _inferMuscleFromName(String exerciseName) {
    final nameLower = exerciseName.toLowerCase();

    // Leg exercises - Italian and English patterns
    const legPatterns = [
      'leg extension',
      'leg curl',
      'leg press',
      'squat',
      'affond', // affondo, affondi
      'lunge',
      'hip thrust',
      'stacco', // stacco rumeno, stacco da terra
      'deadlift',
      'calf',
      'polpacci',
      'glutei',
      'femorali',
      'quadricip',
      'bulgarian',
    ];

    for (final pattern in legPatterns) {
      if (nameLower.contains(pattern)) {
        return 'legs';
      }
    }

    // Keep original if no pattern matches
    return '';
  }

  /// Get corrected muscle group for an exercise
  /// Uses inference from exercise name when stored data might be wrong
  String _getCorrectedMuscleGroup(String exerciseName, String storedMuscleGroup) {
    final inferred = _inferMuscleFromName(exerciseName);
    if (inferred.isNotEmpty) {
      // Use inferred value if it differs from stored
      // This fixes historical data issues
      return inferred;
    }
    return storedMuscleGroup;
  }

  /// Calculate breakdown with name-based correction
  RatioBreakdown calculateCorrectedBreakdown(List<ExerciseHistory> exerciseHistories) {
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

      // Use corrected muscle group
      final correctedMuscle = _getCorrectedMuscleGroup(
        history.exerciseName,
        history.muscleGroup,
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
