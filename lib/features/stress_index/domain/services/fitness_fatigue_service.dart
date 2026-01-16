/// Fitness-Fatigue Model Service
///
/// Implements the Banister Fitness-Fatigue Model (FFM) for accurate
/// recovery prediction based on accumulated training stress.
///
/// The FFM accounts for the dual nature of training adaptation:
/// 1. Fitness: Long-term positive adaptation (decays slowly, ~42 days)
/// 2. Fatigue: Short-term negative effect (decays quickly, ~10 days)
///
/// Performance(t) = Baseline + Fitness(t) - Fatigue(t)
///
/// Research basis:
/// - Banister et al. (1975): Impulse-Response Model
/// - Morton et al. (1990): Two-Component Model
/// - Busso et al. (1997): Muscle-Specific Adaptations
library;

import 'dart:math';

import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';

/// Training impulse for FFM calculation
class TrainingImpulse {
  const TrainingImpulse({
    required this.timestamp,
    required this.muscleId,
    required this.stressScore,
  });

  /// When the training occurred
  final DateTime timestamp;

  /// Which muscle was trained
  final String muscleId;

  /// Normalized stress score (0-100)
  final double stressScore;
}

/// Recovery prediction result for a single muscle
class MuscleRecoveryPrediction {
  const MuscleRecoveryPrediction({
    required this.muscleId,
    required this.displayName,
    required this.performanceLevel,
    required this.fitnessComponent,
    required this.fatigueComponent,
    required this.state,
    required this.optimalTrainingIn,
    required this.lastTrainedAt,
  });

  /// Muscle identifier
  final String muscleId;

  /// Display name for UI
  final String displayName;

  /// Current predicted performance (percentage of baseline)
  /// 100 = baseline, >100 = supercompensation, <100 = fatigued
  final double performanceLevel;

  /// Accumulated fitness effect (positive)
  final double fitnessComponent;

  /// Current fatigue effect (negative)
  final double fatigueComponent;

  /// Recovery state based on performance level
  final FFMRecoveryState state;

  /// Hours until optimal training window
  /// Null if already in optimal window or never trained
  final int? optimalTrainingIn;

  /// When this muscle was last trained
  final DateTime? lastTrainedAt;

  /// Check if in optimal training window
  bool get isOptimalToTrain =>
      state == FFMRecoveryState.supercompensation ||
      state == FFMRecoveryState.optimal;

  /// Check if training would be harmful
  bool get shouldRest =>
      state == FFMRecoveryState.overtraining ||
      state == FFMRecoveryState.critical;
}

/// FFM-based recovery states (more nuanced than simple linear)
enum FFMRecoveryState {
  /// Performance above baseline - best time to train
  supercompensation,

  /// Performance 95-100% - good for training
  optimal,

  /// Performance 85-95% - acceptable but not ideal
  acceptable,

  /// Performance 70-85% - suboptimal, light work only
  suboptimal,

  /// Performance 50-70% - overtraining risk
  overtraining,

  /// Performance below 50% - need rest
  critical,

  /// Never trained / no data
  untrained,
}

/// Static service for Fitness-Fatigue Model calculations
class FitnessFatigueService {
  FitnessFatigueService._();

  /// Calculate recovery prediction for all muscles
  ///
  /// Parameters:
  /// - [workoutHistory]: List of recent stress index results (last 60+ days recommended)
  /// - [atTime]: Calculate prediction for this time (defaults to now)
  ///
  /// Returns: Map of muscle ID → recovery prediction
  static Map<String, MuscleRecoveryPrediction> calculateRecovery(
    List<StressIndexResult> workoutHistory, {
    DateTime? atTime,
  }) {
    final now = atTime ?? DateTime.now();
    final predictions = <String, MuscleRecoveryPrediction>{};

    // Build training impulses per muscle
    final muscleImpulses = <String, List<TrainingImpulse>>{};
    final muscleDisplayNames = <String, String>{};

    for (final workout in workoutHistory) {
      for (final entry in workout.muscleBreakdown.entries) {
        final muscleId = entry.key;
        final data = entry.value;

        muscleImpulses.putIfAbsent(muscleId, () => []);
        muscleImpulses[muscleId]!.add(TrainingImpulse(
          timestamp: workout.calculatedAt,
          muscleId: muscleId,
          stressScore: data.stressScore,
        ));

        muscleDisplayNames[muscleId] = data.displayName;
      }
    }

    // Calculate FFM for each muscle
    for (final entry in muscleImpulses.entries) {
      final muscleId = entry.key;
      final impulses = entry.value;
      final displayName = muscleDisplayNames[muscleId] ?? muscleId;

      final prediction = _calculateMuscleFFM(
        muscleId: muscleId,
        displayName: displayName,
        impulses: impulses,
        atTime: now,
      );

      predictions[muscleId] = prediction;
    }

    return predictions;
  }

  /// Calculate FFM for a single muscle
  static MuscleRecoveryPrediction _calculateMuscleFFM({
    required String muscleId,
    required String displayName,
    required List<TrainingImpulse> impulses,
    required DateTime atTime,
  }) {
    if (impulses.isEmpty) {
      return MuscleRecoveryPrediction(
        muscleId: muscleId,
        displayName: displayName,
        performanceLevel: StressIndexConstants.ffmBaseline,
        fitnessComponent: 0,
        fatigueComponent: 0,
        state: FFMRecoveryState.untrained,
        optimalTrainingIn: null,
        lastTrainedAt: null,
      );
    }

    // Sort impulses by time
    final sortedImpulses = List<TrainingImpulse>.from(impulses)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final lastTrainedAt = sortedImpulses.last.timestamp;

    // Calculate fitness and fatigue components
    double fitnessSum = 0;
    double fatigueSum = 0;

    // Get muscle-specific fatigue modifier
    final fatigueModifier = StressIndexConstants
            .muscleFatigueModifiers[muscleId.toUpperCase()] ??
        StressIndexConstants.defaultFatigueModifier;

    for (final impulse in sortedImpulses) {
      final hoursSince = atTime.difference(impulse.timestamp).inMinutes / 60.0;

      if (hoursSince < 0) continue; // Future workout, skip

      // Normalize stress to training load (0-1 scale for formula)
      final trainingLoad = impulse.stressScore / 100.0;

      // Fitness component: k₁ × w × e^(-t/τ₁)
      final fitnessDecay = exp(-hoursSince / StressIndexConstants.fitnessTimeConstant);
      fitnessSum += StressIndexConstants.fitnessGainK1 * trainingLoad * fitnessDecay;

      // Fatigue component: k₂ × w × e^(-t/τ₂)
      // Apply muscle-specific modifier to fatigue time constant
      final effectiveFatigueTC =
          StressIndexConstants.fatigueTimeConstant * fatigueModifier;
      final fatigueDecay = exp(-hoursSince / effectiveFatigueTC);
      fatigueSum += StressIndexConstants.fatigueGainK2 * trainingLoad * fatigueDecay;
    }

    // Scale components to percentage points
    // Typical training load of 0.7 should produce visible effects
    // NOTE: Increased from 15 to 25 to make individual workouts more impactful
    // With k₂=3.5 and scale=25, a workout with muscle stress 30 produces ~25 stress
    final fitnessEffect = fitnessSum * 25; // Scale factor for visibility
    final fatigueEffect = fatigueSum * 25;

    // Performance = Baseline + Fitness - Fatigue
    final performanceLevel =
        StressIndexConstants.ffmBaseline + fitnessEffect - fatigueEffect;

    // Determine state
    final state = _getFFMState(performanceLevel);

    // Calculate optimal training window
    final optimalIn = _calculateOptimalTrainingHours(
      muscleId: muscleId,
      currentPerformance: performanceLevel,
      lastTrainedAt: lastTrainedAt,
      atTime: atTime,
    );

    return MuscleRecoveryPrediction(
      muscleId: muscleId,
      displayName: displayName,
      performanceLevel: performanceLevel,
      fitnessComponent: fitnessEffect,
      fatigueComponent: fatigueEffect,
      state: state,
      optimalTrainingIn: optimalIn,
      lastTrainedAt: lastTrainedAt,
    );
  }

  /// Determine recovery state from performance level
  static FFMRecoveryState _getFFMState(double performanceLevel) {
    if (performanceLevel >= StressIndexConstants.supercompensationThreshold) {
      return FFMRecoveryState.supercompensation;
    }
    if (performanceLevel >= StressIndexConstants.optimalTrainingMin) {
      return FFMRecoveryState.optimal;
    }
    if (performanceLevel >= StressIndexConstants.acceptableTrainingMin) {
      return FFMRecoveryState.acceptable;
    }
    if (performanceLevel >= StressIndexConstants.overtrainingWarning) {
      return FFMRecoveryState.suboptimal;
    }
    if (performanceLevel >= StressIndexConstants.criticalFatigue) {
      return FFMRecoveryState.overtraining;
    }
    return FFMRecoveryState.critical;
  }

  /// Estimate hours until optimal training window
  static int? _calculateOptimalTrainingHours({
    required String muscleId,
    required double currentPerformance,
    required DateTime lastTrainedAt,
    required DateTime atTime,
  }) {
    // Already in optimal window
    if (currentPerformance >= StressIndexConstants.optimalTrainingMin) {
      return null;
    }

    // Get muscle-specific fatigue modifier
    final fatigueModifier = StressIndexConstants
            .muscleFatigueModifiers[muscleId.toUpperCase()] ??
        StressIndexConstants.defaultFatigueModifier;

    final effectiveFatigueTC =
        StressIndexConstants.fatigueTimeConstant * fatigueModifier;

    // Estimate when performance will reach optimal
    // Simplified: fatigue decays exponentially, so we solve for t
    // Performance reaches 95% when fatigue effect drops enough
    // This is an approximation - actual FFM is more complex

    final hoursSinceLastTraining =
        atTime.difference(lastTrainedAt).inMinutes / 60.0;

    // Rough estimate: 2-3 half-lives of fatigue to reach optimal
    final estimatedHoursToOptimal =
        (effectiveFatigueTC * 2.5) - hoursSinceLastTraining;

    return estimatedHoursToOptimal > 0 ? estimatedHoursToOptimal.ceil() : null;
  }

  /// Predict performance at a future time
  ///
  /// Useful for workout planning - see what performance will be
  /// if training is scheduled for a specific time.
  static Map<String, double> predictPerformanceAt(
    List<StressIndexResult> workoutHistory,
    DateTime futureTime,
  ) {
    final predictions = calculateRecovery(workoutHistory, atTime: futureTime);
    return predictions.map((k, v) => MapEntry(k, v.performanceLevel));
  }

  /// Find optimal training day for a muscle group
  ///
  /// Searches the next [maxDays] to find when performance will peak.
  static DateTime? findOptimalTrainingDay({
    required List<StressIndexResult> workoutHistory,
    required String muscleId,
    int maxDays = 7,
  }) {
    final now = DateTime.now();
    double bestPerformance = 0;
    DateTime? bestDay;

    for (int day = 0; day <= maxDays; day++) {
      final checkTime = now.add(Duration(days: day));
      final predictions = calculateRecovery(workoutHistory, atTime: checkTime);
      final prediction = predictions[muscleId];

      if (prediction != null && prediction.performanceLevel > bestPerformance) {
        bestPerformance = prediction.performanceLevel;
        bestDay = checkTime;
      }
    }

    return bestDay;
  }

  /// Simulate stress after a hypothetical workout using FFM
  ///
  /// This is the SINGLE SOURCE OF TRUTH for "if workout" predictions.
  /// Uses the same FFM model as actual stress calculation.
  ///
  /// Parameters:
  /// - [workoutHistory]: Existing workout history
  /// - [simulatedWorkoutStress]: Expected stress of the simulated workout (0-100)
  /// - [workoutTime]: When the simulated workout would occur (default: 12h from now)
  /// - [evaluateAt]: When to evaluate the result (default: 24h from now)
  ///
  /// Returns: Predicted stress level (0-100) after the simulated workout
  static double predictStressAfterSimulatedWorkout({
    required List<StressIndexResult> workoutHistory,
    required double simulatedWorkoutStress,
    DateTime? workoutTime,
    DateTime? evaluateAt,
  }) {
    final now = DateTime.now();
    final workoutAt = workoutTime ?? now.add(const Duration(hours: 12));
    final evalAt = evaluateAt ?? now.add(const Duration(hours: 24));

    // Create a simulated workout result
    // Distribute stress across common muscle groups (simplified)
    final simulatedMuscleBreakdown = <String, MuscleStressData>{
      'PETT': MuscleStressData(
        muscleId: 'PETT',
        displayName: 'Chest',
        stressScore: simulatedWorkoutStress,
        setsCount: 4,
        totalVolume: 1000,
        avgRpe: 8.0,
        recoveryHours: 72,
        estimatedRecovery: workoutAt.add(const Duration(hours: 72)),
      ),
      'LAT': MuscleStressData(
        muscleId: 'LAT',
        displayName: 'Back',
        stressScore: simulatedWorkoutStress * 0.8,
        setsCount: 4,
        totalVolume: 1000,
        avgRpe: 8.0,
        recoveryHours: 72,
        estimatedRecovery: workoutAt.add(const Duration(hours: 72)),
      ),
      'DELT_ANT': MuscleStressData(
        muscleId: 'DELT_ANT',
        displayName: 'Shoulders',
        stressScore: simulatedWorkoutStress * 0.6,
        setsCount: 3,
        totalVolume: 500,
        avgRpe: 8.0,
        recoveryHours: 48,
        estimatedRecovery: workoutAt.add(const Duration(hours: 48)),
      ),
    };

    final simulatedWorkout = StressIndexResult(
      workoutId: 'simulated_${workoutAt.millisecondsSinceEpoch}',
      primaryScore: simulatedWorkoutStress,
      fallbackScore: simulatedWorkoutStress,
      confidence: 1.0,
      muscleBreakdown: simulatedMuscleBreakdown,
      totalSets: 10,
      setsWithRpe: 10,
      calculatedAt: workoutAt,
      rawScore: simulatedWorkoutStress * 100, // Approximate raw score
    );

    // Combine with existing history
    final combinedHistory = [...workoutHistory, simulatedWorkout];

    // Calculate FFM readiness at evaluation time
    final readiness = getOverallReadiness(combinedHistory, atTime: evalAt);

    // Convert readiness to stress (100 - readiness, clamped)
    return (100 - readiness).clamp(0.0, 100.0);
  }

  /// Get overall readiness score across all muscles
  ///
  /// Returns weighted average of muscle performance levels,
  /// weighted by typical training frequency.
  static double getOverallReadiness(
    List<StressIndexResult> workoutHistory, {
    DateTime? atTime,
  }) {
    final predictions = calculateRecovery(workoutHistory, atTime: atTime);

    if (predictions.isEmpty) return 100.0;

    // Weight by muscle group importance (large muscles weighted more)
    const muscleWeights = {
      'QUAD': 1.2,
      'GLUT': 1.2,
      'LAT': 1.1,
      'PETT': 1.1,
      'FEMOR': 1.0,
      'DELT_ANT': 0.8,
      'DELT_LAT': 0.8,
      'DELT_POST': 0.8,
      'TRAP': 0.7,
      'BICI': 0.6,
      'TRIC': 0.6,
    };

    double weightedSum = 0;
    double totalWeight = 0;

    for (final entry in predictions.entries) {
      final weight = muscleWeights[entry.key.toUpperCase()] ?? 0.5;
      weightedSum += entry.value.performanceLevel * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 100.0;
  }
}
