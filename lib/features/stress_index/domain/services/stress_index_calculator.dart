/// Stress Index Calculator Service
///
/// Calculates training stress index using RTS (Reactive Training Systems)
/// methodology with logarithmic scaling (like WHOOP).
///
/// Formula (RTS-based):
///   SetStress = weight × reps × RPE_intensity × movementMultiplier
///   WorkoutStress = sum(SetStress) → logarithmic scale (0-100)
///
/// Features:
/// - Dual calculation: Primary (RPE-based) + Fallback (weight-only)
/// - Per-muscle stress breakdown
/// - Confidence score based on RPE availability
///
/// Based on:
/// - Helms et al. (2018): RPE-Based Training Load Monitoring
/// - Zourdos et al. (2016): Novel Resistance Training-Specific RPE Scale
library;

import 'dart:math';

import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Internal accumulator for muscle stress data
class _MuscleAccumulator {
  _MuscleAccumulator(this.displayName);

  final String displayName;
  double totalStress = 0.0;
  double totalVolume = 0.0;
  double totalRpe = 0.0;
  int setCount = 0;
  int rpeCount = 0;

  void add({required double stress, required double volume, double? rpe}) {
    totalStress += stress;
    totalVolume += volume;
    setCount++;
    if (rpe != null) {
      totalRpe += rpe;
      rpeCount++;
    }
  }

  double get avgRpe => rpeCount > 0 ? totalRpe / rpeCount : 0.0;
}

/// Static utility class for stress index calculations
///
/// Follows the same pattern as VolumeCalculator: static methods, no state.
class StressIndexCalculator {
  StressIndexCalculator._();

  /// Calculate stress index for a completed workout
  ///
  /// Parameters:
  /// - [workout]: The completed workout to analyze
  /// - [exerciseFocusMap]: Optional map of exercise name → focus list
  ///   (e.g., {"Panca Piana": ["PETT", "TRIC"]})
  ///   If not provided, uses ExerciseCategory as fallback.
  ///
  /// Returns: [StressIndexResult] with primary/fallback scores and muscle breakdown
  static StressIndexResult calculate(
    Workout workout, {
    Map<String, List<String>>? exerciseFocusMap,
  }) {
    final muscleStress = <String, _MuscleAccumulator>{};
    int totalSets = 0;
    int setsWithRpe = 0;
    double rawScoreWithRpe = 0.0;
    double rawScoreWithoutRpe = 0.0;

    for (final exercise in workout.exercises) {
      // Get muscles from focus map or fallback to category
      final muscles = _getMusclesForExercise(exercise, exerciseFocusMap);

      // Get movement multiplier
      final movementMultiplier = _getMovementMultiplier(exercise.movementType);

      for (final set in exercise.sets) {
        if (!set.isCompleted || set.isWarmup) continue;

        final weight = set.weight ?? 0.0;
        final reps = set.actualReps ?? set.reps ?? 0;

        if (weight <= 0 || reps <= 0) continue;

        totalSets++;

        // Calculate stress with RPE if available
        final rpe = set.rpe;
        final intensityWithRpe = rpe != null
            ? StressIndexConstants.rpeToIntensity[rpe.round()] ??
                StressIndexConstants.defaultIntensity
            : StressIndexConstants.defaultIntensity;

        final setStressWithRpe =
            weight * reps * intensityWithRpe * movementMultiplier;
        final setStressWithoutRpe = weight *
            reps *
            StressIndexConstants.defaultIntensity *
            movementMultiplier;

        if (rpe != null) {
          setsWithRpe++;
          rawScoreWithRpe += setStressWithRpe;
        } else {
          // For sets without RPE, use default intensity for both scores
          rawScoreWithRpe += setStressWithoutRpe;
        }
        rawScoreWithoutRpe += setStressWithoutRpe;

        // Distribute stress to muscles
        if (muscles.isNotEmpty) {
          // Distribute evenly across targeted muscles
          final stressPerMuscle = setStressWithRpe / muscles.length;
          final volumePerMuscle = (weight * reps) / muscles.length;

          for (final muscle in muscles) {
            muscleStress.putIfAbsent(
              muscle.id,
              () => _MuscleAccumulator(muscle.displayNameEn),
            );
            muscleStress[muscle.id]!.add(
              stress: stressPerMuscle,
              volume: volumePerMuscle,
              rpe: rpe?.toDouble(),
            );
          }
        }
      }
    }

    // Calculate confidence
    final confidence = totalSets > 0 ? setsWithRpe / totalSets : 0.0;

    // Convert to logarithmic 0-100 scale
    final primaryScore = _toLogarithmicScale(rawScoreWithRpe);
    final fallbackScore = _toLogarithmicScale(rawScoreWithoutRpe);

    // Build muscle breakdown
    final muscleBreakdown = <String, MuscleStressData>{};
    for (final entry in muscleStress.entries) {
      final acc = entry.value;
      final recoveryHours = StressIndexConstants
              .muscleRecoveryHours[entry.key.toUpperCase()] ??
          StressIndexConstants.defaultRecoveryHours;

      muscleBreakdown[entry.key] = MuscleStressData(
        muscleId: entry.key,
        displayName: acc.displayName,
        stressScore: _toLogarithmicScale(acc.totalStress),
        setsCount: acc.setCount,
        totalVolume: acc.totalVolume,
        avgRpe: acc.avgRpe,
        recoveryHours: recoveryHours,
        estimatedRecovery: DateTime.now().add(Duration(hours: recoveryHours)),
      );
    }

    return StressIndexResult(
      primaryScore: primaryScore,
      fallbackScore: fallbackScore,
      confidence: confidence,
      muscleBreakdown: muscleBreakdown,
      totalSets: totalSets,
      setsWithRpe: setsWithRpe,
      workoutId: workout.id,
      calculatedAt: DateTime.now(),
      rawScore: rawScoreWithRpe,
    );
  }

  /// Get muscles for an exercise
  ///
  /// Priority:
  /// 1. Exercise focus map (if provided)
  /// 2. Fallback to ExerciseCategory → default muscles
  static List<MuscleInfo> _getMusclesForExercise(
    Exercise exercise,
    Map<String, List<String>>? exerciseFocusMap,
  ) {
    // Try focus map first
    if (exerciseFocusMap != null) {
      final focusList = exerciseFocusMap[exercise.name];
      if (focusList != null && focusList.isNotEmpty) {
        return focusList
            .map((abbr) => MuscleAbbreviationMapper.getMuscleInfo(abbr))
            .whereType<MuscleInfo>()
            .toList();
      }
    }

    // Fallback to category-based default muscles
    return _getDefaultMusclesForCategory(exercise.category);
  }

  /// Get default muscles based on ExerciseCategory
  static List<MuscleInfo> _getDefaultMusclesForCategory(
      ExerciseCategory category) {
    // Map category to default muscle abbreviations
    final abbrs = switch (category) {
      ExerciseCategory.chest => ['PETT'],
      ExerciseCategory.back => ['LAT', 'TRAP'],
      ExerciseCategory.shoulders => ['DELT'],
      ExerciseCategory.arms => ['BICI', 'TRIC'],
      ExerciseCategory.legs => ['QUAD', 'GLUT', 'FEMOR'],
      ExerciseCategory.abs => ['CORE'],
      ExerciseCategory.cardio => <String>[],
      ExerciseCategory.other => <String>[],
    };

    return abbrs
        .map((abbr) => MuscleAbbreviationMapper.getMuscleInfo(abbr))
        .whereType<MuscleInfo>()
        .toList();
  }

  /// Convert raw score to logarithmic 0-100 scale
  ///
  /// Uses natural log scaling where:
  /// - Higher scores become progressively harder to achieve
  /// - A typical heavy workout (~15000 raw) maps to ~100
  static double _toLogarithmicScale(double rawScore) {
    if (rawScore <= 0) return 0.0;

    // log(rawScore + 1) / log(maxRaw + 1) * 100
    final logScore = log(rawScore + 1) /
        log(StressIndexConstants.rawScoreForMax100 + 1);
    return (logScore * 100).clamp(0.0, 100.0);
  }

  /// Get movement type multiplier
  ///
  /// Compound heavy exercises contribute more stress per set
  static double _getMovementMultiplier(MovementType? type) {
    if (type == null) return 1.0;
    return type.stressMultiplier;
  }

  /// Calculate current recovery status for all muscles
  ///
  /// Parameters:
  /// - [recentWorkouts]: List of recent stress index results (last 7 days)
  ///
  /// Returns: Map of muscle ID → recovery status
  static Map<String, MuscleRecoveryStatus> calculateRecoveryStatus(
    List<StressIndexResult> recentWorkouts,
  ) {
    final recoveryMap = <String, MuscleRecoveryStatus>{};
    final now = DateTime.now();

    // Track last work per muscle: (date, stress, displayName)
    final lastMuscleWork = <String, (DateTime, double, String)>{};

    for (final workout in recentWorkouts) {
      for (final entry in workout.muscleBreakdown.entries) {
        final existing = lastMuscleWork[entry.key];
        if (existing == null || workout.calculatedAt.isAfter(existing.$1)) {
          lastMuscleWork[entry.key] = (
            workout.calculatedAt,
            entry.value.stressScore,
            entry.value.displayName,
          );
        }
      }
    }

    // Calculate recovery percentage for each muscle
    for (final entry in lastMuscleWork.entries) {
      final (lastWorked, lastStress, displayName) = entry.value;
      final recoveryHours = StressIndexConstants
              .muscleRecoveryHours[entry.key.toUpperCase()] ??
          StressIndexConstants.defaultRecoveryHours;

      final hoursSinceWork = now.difference(lastWorked).inHours;
      final recoveryPercentage =
          (hoursSinceWork / recoveryHours * 100).clamp(0.0, 150.0);

      final state = _getRecoveryState(recoveryPercentage);

      recoveryMap[entry.key] = MuscleRecoveryStatus(
        muscleId: entry.key,
        displayName: displayName,
        recoveryPercentage: recoveryPercentage,
        lastWorked: lastWorked,
        lastStressScore: lastStress,
        state: state,
      );
    }

    return recoveryMap;
  }

  /// Get recovery state based on percentage
  static RecoveryState _getRecoveryState(double recoveryPercentage) {
    if (recoveryPercentage >= StressIndexConstants.fullyRecoveredMin) {
      return RecoveryState.fullyRecovered;
    }
    if (recoveryPercentage >= StressIndexConstants.almostReadyMin) {
      return RecoveryState.almostReady;
    }
    if (recoveryPercentage >= StressIndexConstants.recoveringMin) {
      return RecoveryState.recovering;
    }
    if (recoveryPercentage >= StressIndexConstants.fatiguedMin) {
      return RecoveryState.fatigued;
    }
    return RecoveryState.exhausted;
  }

  /// Check if a workout can be calculated (has valid sets)
  static bool canCalculate(Workout workout) {
    return workout.exercises.any((exercise) {
      return exercise.sets.any((set) =>
          set.isCompleted &&
          !set.isWarmup &&
          (set.weight ?? 0) > 0 &&
          ((set.actualReps ?? set.reps) ?? 0) > 0);
    });
  }

  /// Get stress level description
  static String getStressLevelDescription(StressLevel level) {
    return switch (level) {
      StressLevel.light => 'Light Session',
      StressLevel.moderate => 'Moderate Session',
      StressLevel.hard => 'Hard Session',
      StressLevel.veryHard => 'Very Hard Session',
    };
  }
}
