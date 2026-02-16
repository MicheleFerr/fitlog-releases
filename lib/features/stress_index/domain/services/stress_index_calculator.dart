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

import 'package:gymbro_flutter_new/features/analytics/domain/services/emg_movement_ratios.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/fitness_fatigue_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';

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
  /// - [exerciseFocusMap]: Optional map of exercise name → focus list (deprecated)
  /// - [exerciseMuscleMap]: Optional map of exercise name → muscle data (primary + secondary)
  ///   If not provided, uses ExerciseCategory as fallback.
  /// - [userBodyWeightKg]: Optional user body weight for bodyweight exercise stress calculation
  ///
  /// Stress distribution:
  /// - Primary muscles (focus): 70% of total stress
  /// - Secondary muscles: 30% of total stress (split among them)
  ///
  /// Bodyweight Exercise Handling:
  /// - Exercises with countingMode == ExerciseCountingMode.reps are bodyweight
  /// - Uses userBodyWeightKg as effective weight if provided
  /// - Falls back to default 70kg if no body weight available
  ///
  /// Returns: [StressIndexResult] with primary/fallback scores and muscle breakdown
  static StressIndexResult calculate(
    Workout workout, {
    @Deprecated('Use exerciseMuscleMap instead')
    Map<String, List<String>>? exerciseFocusMap,
    Map<String, ExerciseMuscleData>? exerciseMuscleMap,
    double? userBodyWeightKg,
  }) {
    final muscleStress = <String, _MuscleAccumulator>{};
    int totalSets = 0;
    int setsWithRpe = 0;
    double rawScoreWithRpe = 0.0;
    double rawScoreWithoutRpe = 0.0;

    for (final exercise in workout.exercises) {
      // Get muscles from muscle map or fallback
      final muscleData = _getMuscleDataForExercise(
        exercise,
        exerciseMuscleMap,
        exerciseFocusMap,
      );

      // Get movement multiplier
      final movementMultiplier = _getMovementMultiplier(exercise.movementType);

      // 🏋️ Check if this is a bodyweight exercise
      final isBodyweight = exercise.countingMode == ExerciseCountingMode.reps;

      for (final set in exercise.sets) {
        if (!set.isCompleted || set.isWarmup) continue;

        final reps = set.actualReps ?? set.reps ?? 0;
        if (reps <= 0) continue;

        // 🏋️ FIX: Handle bodyweight exercises
        double effectiveWeight;
        if (isBodyweight) {
          // Bodyweight: use user's body weight or default 70kg
          effectiveWeight = userBodyWeightKg ?? 70.0;
        } else {
          final weight = set.weight ?? 0.0;
          if (weight <= 0) continue; // Weighted exercise needs weight
          effectiveWeight = weight;
        }

        totalSets++;

        // Calculate stress with RPE if available
        final rpe = set.rpe;
        final intensityWithRpe = rpe != null
            ? StressIndexConstants.rpeToIntensity[rpe.round()] ??
                  StressIndexConstants.defaultIntensity
            : StressIndexConstants.defaultIntensity;

        final setStressWithRpe =
            effectiveWeight * reps * intensityWithRpe * movementMultiplier;
        final setStressWithoutRpe =
            effectiveWeight *
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

        // Distribute stress to muscles with weighted distribution
        final totalVolume = effectiveWeight * reps;
        _distributeStressToMuscles(
          muscleStress: muscleStress,
          muscleData: muscleData,
          totalStress: setStressWithRpe,
          totalVolume: totalVolume,
          rpe: rpe?.toDouble(),
        );
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
      final recoveryHours =
          StressIndexConstants.muscleRecoveryHours[entry.key.toUpperCase()] ??
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
      workoutName: workout.name,
      workoutDate: workout.endTime ?? workout.createdAt,
      calculatedAt: DateTime.now(),
      rawScore: rawScoreWithRpe,
    );
  }

  /// Internal structure for muscle distribution with movement pattern
  ///
  /// Now includes MovementPattern for EMG-based ratio distribution.
  static ({
    List<MuscleInfo> primary,
    List<MuscleInfo> secondary,
    MovementPattern pattern,
  })
  _getMuscleDataForExercise(
    Exercise exercise,
    Map<String, ExerciseMuscleData>? exerciseMuscleMap,
    Map<String, List<String>>? exerciseFocusMap,
  ) {
    // Try new muscle map first (has primary + secondary + patternMovimento)
    // Supports aliases and case-insensitive matching via expanded map
    if (exerciseMuscleMap != null) {
      // Try exact match first, then lowercase for alias/case-insensitive matching
      final muscleData =
          exerciseMuscleMap[exercise.name] ??
          exerciseMuscleMap[exercise.name.toLowerCase()];
      if (muscleData != null && muscleData.hasData) {
        // Determine movement pattern from patternMovimento (stored in fileCategory)
        final pattern = muscleData.fileCategory.isNotEmpty
            ? EmgMovementRatios.fromPatternMovimento(
                muscleData.fileCategory,
                exerciseName: muscleData.exerciseName.isNotEmpty
                    ? muscleData.exerciseName
                    : exercise.name,
              )
            : EmgMovementRatios.inferPattern(
                fileCategory: '',
                exerciseName: exercise.name,
                focusMuscle: muscleData.primary.isNotEmpty
                    ? muscleData.primary.first
                    : null,
              );

        return (
          primary: muscleData.primary
              .map((abbr) => MuscleAbbreviationMapper.getMuscleInfo(abbr))
              .whereType<MuscleInfo>()
              .toList(),
          secondary: muscleData.secondary
              .map((abbr) => MuscleAbbreviationMapper.getMuscleInfo(abbr))
              .whereType<MuscleInfo>()
              .toList(),
          pattern: pattern,
        );
      }
    }

    // Fallback to old focus map (primary only)
    if (exerciseFocusMap != null) {
      final focusList =
          exerciseFocusMap[exercise.name] ??
          exerciseFocusMap[exercise.name.toLowerCase()];
      if (focusList != null && focusList.isNotEmpty) {
        // Infer pattern from exercise name
        final pattern = EmgMovementRatios.inferPattern(
          fileCategory: '',
          exerciseName: exercise.name,
          focusMuscle: focusList.isNotEmpty ? focusList.first : null,
        );

        return (
          primary: focusList
              .map((abbr) => MuscleAbbreviationMapper.getMuscleInfo(abbr))
              .whereType<MuscleInfo>()
              .toList(),
          secondary: <MuscleInfo>[],
          pattern: pattern,
        );
      }
    }

    // Fallback to category-based default muscles with inferred pattern
    final pattern = EmgMovementRatios.inferPattern(
      fileCategory: '',
      exerciseName: exercise.name,
    );

    return (
      primary: _getDefaultMusclesForCategory(exercise.category),
      secondary: <MuscleInfo>[],
      pattern: pattern,
    );
  }

  /// Distribute stress to muscles with EMG-based weighted distribution
  ///
  /// Uses dynamic ratios based on movement pattern (from EMG research):
  /// - Push Horizontal: Primary 60%, Synergists 40% (25% high, 15% moderate)
  /// - Squat: Primary 50%, Synergists 50% (35% high, 15% moderate)
  /// - Isolation: Primary 85%, Synergists 15%
  ///
  /// Synergist tiers:
  /// - First synergist (secondary[0]) = High synergist (more activation)
  /// - Other synergists (secondary[1+]) = Moderate synergists (split remaining)
  static void _distributeStressToMuscles({
    required Map<String, _MuscleAccumulator> muscleStress,
    required ({
      List<MuscleInfo> primary,
      List<MuscleInfo> secondary,
      MovementPattern pattern,
    })
    muscleData,
    required double totalStress,
    required double totalVolume,
    double? rpe,
  }) {
    final primaryMuscles = muscleData.primary;
    final secondaryMuscles = muscleData.secondary;
    final pattern = muscleData.pattern;

    // If no muscles at all, skip
    if (primaryMuscles.isEmpty && secondaryMuscles.isEmpty) return;

    // Get EMG-based tiered ratios for this movement pattern
    final (primaryRatio, highSynergistRatio, moderateSynergistRatio) =
        EmgMovementRatios.getTieredRatios(pattern);

    // Handle edge cases
    double actualPrimaryRatio;
    double actualHighRatio;
    double actualModRatio;

    if (primaryMuscles.isNotEmpty && secondaryMuscles.isNotEmpty) {
      // Both primary and secondary: use full EMG ratios
      actualPrimaryRatio = primaryRatio;
      actualHighRatio = highSynergistRatio;
      actualModRatio = moderateSynergistRatio;
    } else if (primaryMuscles.isNotEmpty) {
      // Only primary: 100% to primary
      actualPrimaryRatio = 1.0;
      actualHighRatio = 0.0;
      actualModRatio = 0.0;
    } else {
      // Only secondary (rare): distribute all to secondary
      actualPrimaryRatio = 0.0;
      actualHighRatio = 0.6; // Main secondary gets 60%
      actualModRatio = 0.4; // Others split 40%
    }

    // Distribute to primary muscles (split evenly among them)
    if (primaryMuscles.isNotEmpty) {
      final stressPerPrimary =
          (totalStress * actualPrimaryRatio) / primaryMuscles.length;
      final volumePerPrimary =
          (totalVolume * actualPrimaryRatio) / primaryMuscles.length;

      for (final muscle in primaryMuscles) {
        muscleStress.putIfAbsent(
          muscle.id,
          () => _MuscleAccumulator(muscle.displayNameEn),
        );
        muscleStress[muscle.id]!.add(
          stress: stressPerPrimary,
          volume: volumePerPrimary,
          rpe: rpe,
        );
      }
    }

    // Distribute to secondary muscles with tiered approach
    if (secondaryMuscles.isNotEmpty) {
      // First synergist gets highSynergistRatio
      final firstSynergist = secondaryMuscles.first;
      final highStress = totalStress * actualHighRatio;
      final highVolume = totalVolume * actualHighRatio;

      muscleStress.putIfAbsent(
        firstSynergist.id,
        () => _MuscleAccumulator(firstSynergist.displayNameEn),
      );
      muscleStress[firstSynergist.id]!.add(
        stress: highStress,
        volume: highVolume,
        rpe: rpe,
      );

      // Remaining synergists split moderateSynergistRatio
      if (secondaryMuscles.length > 1) {
        final remainingSynergists = secondaryMuscles.sublist(1);
        final stressPerMod =
            (totalStress * actualModRatio) / remainingSynergists.length;
        final volumePerMod =
            (totalVolume * actualModRatio) / remainingSynergists.length;

        for (final muscle in remainingSynergists) {
          muscleStress.putIfAbsent(
            muscle.id,
            () => _MuscleAccumulator(muscle.displayNameEn),
          );
          muscleStress[muscle.id]!.add(
            stress: stressPerMod,
            volume: volumePerMod,
            rpe: rpe,
          );
        }
      }
    }
  }

  /// Get default muscles based on ExerciseCategory
  ///
  /// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper.
  static List<MuscleInfo> _getDefaultMusclesForCategory(
    ExerciseCategory category,
  ) {
    // Use centralized mapper for category → abbreviations
    final abbrs = MuscleAbbreviationMapper.categoryToAbbreviations(category);

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
    final logScore =
        log(rawScore + 1) / log(StressIndexConstants.rawScoreForMax100 + 1);
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
      final recoveryHours =
          StressIndexConstants.muscleRecoveryHours[entry.key.toUpperCase()] ??
          StressIndexConstants.defaultRecoveryHours;

      final hoursSinceWork = now.difference(lastWorked).inHours;
      final recoveryPercentage = (hoursSinceWork / recoveryHours * 100).clamp(
        0.0,
        150.0,
      );

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
  ///
  /// **Bodyweight Support**:
  /// - Weighted exercises: need weight > 0 AND reps > 0
  /// - Bodyweight exercises (countingMode == reps): only need reps > 0
  static bool canCalculate(Workout workout) {
    return workout.exercises.any((exercise) {
      final isBodyweight = exercise.countingMode == ExerciseCountingMode.reps;

      return exercise.sets.any((set) {
        if (!set.isCompleted || set.isWarmup) return false;

        final reps = (set.actualReps ?? set.reps) ?? 0;
        if (reps <= 0) return false;

        if (isBodyweight) {
          // Bodyweight: only need valid reps
          return true;
        } else {
          // Weighted: need weight > 0
          return (set.weight ?? 0) > 0;
        }
      });
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

  // === FITNESS-FATIGUE MODEL (FFM) INTEGRATION ===

  /// Calculate recovery using Fitness-Fatigue Model (more accurate)
  ///
  /// FFM accounts for accumulated fitness and fatigue, providing
  /// more nuanced recovery predictions than simple linear decay.
  ///
  /// Parameters:
  /// - [recentWorkouts]: List of stress results (60+ days recommended for accuracy)
  /// - [atTime]: Calculate prediction for this time (defaults to now)
  ///
  /// Returns: Map of muscle ID → FFM recovery prediction
  static Map<String, MuscleRecoveryPrediction> calculateRecoveryFFM(
    List<StressIndexResult> recentWorkouts, {
    DateTime? atTime,
  }) {
    return FitnessFatigueService.calculateRecovery(
      recentWorkouts,
      atTime: atTime,
    );
  }

  /// Get overall readiness score using FFM
  ///
  /// Returns a weighted average of all muscle performance levels.
  /// 100 = baseline, >100 = supercompensation, <100 = fatigued
  static double getOverallReadinessFFM(List<StressIndexResult> recentWorkouts) {
    return FitnessFatigueService.getOverallReadiness(recentWorkouts);
  }

  /// Find optimal day to train a specific muscle group
  ///
  /// Searches the next [maxDays] to find when performance will peak.
  static DateTime? findOptimalTrainingDay({
    required List<StressIndexResult> recentWorkouts,
    required String muscleId,
    int maxDays = 7,
  }) {
    return FitnessFatigueService.findOptimalTrainingDay(
      workoutHistory: recentWorkouts,
      muscleId: muscleId,
      maxDays: maxDays,
    );
  }

  /// Convert FFM state to legacy RecoveryState for backward compatibility
  static RecoveryState ffmStateToRecoveryState(FFMRecoveryState ffmState) {
    return switch (ffmState) {
      FFMRecoveryState.supercompensation => RecoveryState.fullyRecovered,
      FFMRecoveryState.optimal => RecoveryState.fullyRecovered,
      FFMRecoveryState.acceptable => RecoveryState.almostReady,
      FFMRecoveryState.suboptimal => RecoveryState.recovering,
      FFMRecoveryState.overtraining => RecoveryState.fatigued,
      FFMRecoveryState.critical => RecoveryState.exhausted,
      FFMRecoveryState.untrained => RecoveryState.fullyRecovered,
    };
  }

  /// Convert FFM predictions to legacy MuscleRecoveryStatus format
  ///
  /// For backward compatibility with existing UI components.
  static Map<String, MuscleRecoveryStatus> ffmToLegacyRecovery(
    Map<String, MuscleRecoveryPrediction> ffmPredictions,
  ) {
    final legacyMap = <String, MuscleRecoveryStatus>{};

    for (final entry in ffmPredictions.entries) {
      final prediction = entry.value;
      legacyMap[entry.key] = MuscleRecoveryStatus(
        muscleId: prediction.muscleId,
        displayName: prediction.displayName,
        // Map FFM performance to percentage (performance of 100 = 100% recovery)
        recoveryPercentage: prediction.performanceLevel,
        lastWorked: prediction.lastTrainedAt ?? DateTime.now(),
        lastStressScore: prediction.fatigueComponent,
        state: ffmStateToRecoveryState(prediction.state),
      );
    }

    return legacyMap;
  }

  // === SLEEP-AWARE STRESS CALCULATION ===

  /// Apply sleep modifier to FFM performance
  ///
  /// Adjusts the FFM-calculated readiness based on sleep quality.
  /// This provides a more complete picture of recovery by considering
  /// both training fatigue and sleep quality.
  ///
  /// **Formula**:
  /// ```
  /// AdjustedPerformance = Baseline + (FFM_Deviation × SleepModifier × ConsecutivePenalty)
  /// ```
  ///
  /// **Example**:
  /// - FFM Performance: 89% (fatigued from training)
  /// - Sleep: 3.5h (critical)
  /// - SleepModifier: 0.70
  /// - Adjusted: 100 + (89-100) × 0.70 = 100 + (-11 × 0.70) = 92.3
  ///   → But this is wrong direction! Sleep should REDUCE readiness further.
  ///
  /// **Correct approach**: Sleep amplifies fatigue effect
  /// - FFM Deviation from baseline: 89 - 100 = -11 (fatigued)
  /// - With poor sleep, fatigue impact is worse: -11 / 0.70 = -15.7
  /// - Adjusted: 100 + (-15.7) = 84.3 (more fatigued)
  ///
  /// Returns: Adjusted performance level (0-150+)
  static double applySleepModifier({
    required double ffmPerformance,
    required double sleepHours,
    required int consecutiveBadNights,
  }) {
    final sleepMod = _getSleepModifier(sleepHours);
    final consecPenalty = _getConsecutivePenalty(consecutiveBadNights);

    // FFM deviation from baseline (can be negative if fatigued, positive if supercompensating)
    final deviation = ffmPerformance - StressIndexConstants.ffmBaseline;

    if (deviation < 0) {
      // Fatigued: poor sleep amplifies fatigue (divide by modifier < 1.0)
      // Example: -11 deviation, 0.70 sleep mod → -11 / 0.70 = -15.7
      final adjustedDeviation = deviation / (sleepMod * consecPenalty);
      return StressIndexConstants.ffmBaseline + adjustedDeviation;
    } else {
      // Supercompensating or at baseline: poor sleep reduces gains
      // Example: +5 deviation, 0.70 sleep mod → +5 * 0.70 = +3.5
      final adjustedDeviation = deviation * sleepMod * consecPenalty;
      return StressIndexConstants.ffmBaseline + adjustedDeviation;
    }
  }

  /// Get sleep modifier based on hours slept
  ///
  /// Based on research:
  /// - Res et al.: -22% MPS with sleep deprivation
  /// - Knowles et al.: Reduced strength output with <6h sleep
  /// - AASM: 7-9h recommended for adults
  static double _getSleepModifier(double sleepHours) {
    if (sleepHours < StressIndexConstants.sleepCriticalThreshold) {
      return StressIndexConstants.sleepModifierCritical; // 0.70
    } else if (sleepHours < StressIndexConstants.sleepSuboptimalThreshold) {
      return StressIndexConstants.sleepModifierSuboptimal; // 0.85
    } else if (sleepHours <= StressIndexConstants.sleepExcessiveThreshold) {
      return StressIndexConstants.sleepModifierOptimal; // 1.0
    } else {
      return StressIndexConstants.sleepModifierExcessive; // 0.95
    }
  }

  /// Get penalty for consecutive bad nights (<6h)
  ///
  /// Based on Skein et al. 2011: Cumulative decline with consecutive sleep restriction
  static double _getConsecutivePenalty(int consecutiveBadNights) {
    if (consecutiveBadNights >= 3) {
      return StressIndexConstants.consecutiveBadNights3Penalty; // 0.90
    } else if (consecutiveBadNights >= 2) {
      return StressIndexConstants.consecutiveBadNights2Penalty; // 0.95
    } else {
      return 1.0; // No penalty
    }
  }

  /// Get overall readiness with sleep adjustment
  ///
  /// Combines FFM readiness with sleep quality for complete picture.
  ///
  /// Parameters:
  /// - [recentWorkouts]: Workout history for FFM calculation
  /// - [sleepHours]: Last night's sleep duration (or weekly average)
  /// - [consecutiveBadNights]: Number of consecutive nights with <6h sleep
  ///
  /// Returns: Sleep-adjusted readiness (0-150+)
  static double getOverallReadinessWithSleep({
    required List<StressIndexResult> recentWorkouts,
    required double sleepHours,
    required int consecutiveBadNights,
  }) {
    // Get base FFM readiness
    final ffmReadiness = FitnessFatigueService.getOverallReadiness(
      recentWorkouts,
    );

    // Apply sleep modifier
    return applySleepModifier(
      ffmPerformance: ffmReadiness,
      sleepHours: sleepHours,
      consecutiveBadNights: consecutiveBadNights,
    );
  }

  /// Get sleep quality category for UI display
  static SleepQualityCategory getSleepQualityCategory(double sleepHours) {
    if (sleepHours < StressIndexConstants.sleepCriticalThreshold) {
      return SleepQualityCategory.critical;
    } else if (sleepHours < StressIndexConstants.sleepSuboptimalThreshold) {
      return SleepQualityCategory.suboptimal;
    } else if (sleepHours <= StressIndexConstants.sleepExcessiveThreshold) {
      return SleepQualityCategory.optimal;
    } else {
      return SleepQualityCategory.excessive;
    }
  }

  /// Alias for getSleepQualityCategory (shorter name)
  static SleepQualityCategory getSleepCategory(double sleepHours) =>
      getSleepQualityCategory(sleepHours);

  /// Get sleep modifier for UI display
  ///
  /// Returns the multiplier that will be applied to performance
  /// based on sleep hours.
  static double getSleepModifier(double sleepHours) =>
      _getSleepModifier(sleepHours);
}

/// Sleep quality categories for UI display
enum SleepQualityCategory {
  /// <6h - Significant performance impact
  critical,

  /// 6-7h - Moderate impact
  suboptimal,

  /// 7-9h - Optimal (no impact)
  optimal,

  /// >9h - May indicate overtraining
  excessive,
}
