/// Stress Index Prediction Service
///
/// Implements Banister FFM-based predictions with personalized decay factors.
///
/// **Scientific Basis**:
/// - Fitness-Fatigue Model (Banister et al.)
/// - Personal calibration from CalibrationService
/// - Sleep/HRV adjustments per research (PMC6204890, MDPI 2024)
///
/// **Core Formula**:
/// ```
/// Stress_tomorrow = Stress_today × e^(-24h / τ₂_personal)
/// If workout: Stress_tomorrow += workout_stress × k₂
/// ```
library;

import 'dart:math' show exp;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/calibration_service.dart';

/// Recovery recommendation based on stress level
enum RecoveryRecommendation {
  /// Stress 0-30: Ready for hard session
  readyHard,

  /// Stress 30-50: Moderate session recommended
  moderate,

  /// Stress 50-70: Light work only
  lightOnly,

  /// Stress 70-85: Active recovery or rest
  activeRecovery,

  /// Stress 85+: Rest required
  restRequired,
}

/// Extension for RecoveryRecommendation display
extension RecoveryRecommendationX on RecoveryRecommendation {
  /// Emoji for the recommendation
  String get emoji {
    switch (this) {
      case RecoveryRecommendation.readyHard:
        return '🟢';
      case RecoveryRecommendation.moderate:
        return '🟡';
      case RecoveryRecommendation.lightOnly:
        return '🟠';
      case RecoveryRecommendation.activeRecovery:
        return '🔴';
      case RecoveryRecommendation.restRequired:
        return '⛔';
    }
  }

  /// Label key for localization
  String get labelKey {
    switch (this) {
      case RecoveryRecommendation.readyHard:
        return 'stressRecommendationReadyHard';
      case RecoveryRecommendation.moderate:
        return 'stressRecommendationModerate';
      case RecoveryRecommendation.lightOnly:
        return 'stressRecommendationLightOnly';
      case RecoveryRecommendation.activeRecovery:
        return 'stressRecommendationActiveRecovery';
      case RecoveryRecommendation.restRequired:
        return 'stressRecommendationRestRequired';
    }
  }
}

/// Stress insight with prediction and recommendation
class StressInsight {
  const StressInsight({
    required this.currentStress,
    required this.predictedTomorrow,
    required this.predictedIfWorkout,
    required this.recommendation,
    required this.rationale,
    required this.factors,
    this.calibrationQuality = CalibrationQuality.poor,
    this.calculatedAt,
  });

  /// Creates empty/default insight when no data available
  factory StressInsight.empty() => const StressInsight(
    currentStress: 0,
    predictedTomorrow: 0,
    predictedIfWorkout: 30,
    recommendation: RecoveryRecommendation.readyHard,
    rationale: 'No data available',
    factors: {},
  );

  /// Current stress level (0-100)
  final double currentStress;

  /// Predicted stress tomorrow if resting
  final double predictedTomorrow;

  /// Predicted stress tomorrow if working out
  final double predictedIfWorkout;

  /// Recovery recommendation
  final RecoveryRecommendation recommendation;

  /// Human-readable explanation
  final String rationale;

  /// Contributing factors and their impact
  final Map<String, double> factors;

  /// Quality of the calibration data
  final CalibrationQuality calibrationQuality;

  /// When the insight was calculated
  final DateTime? calculatedAt;

  /// Display-friendly current stress (rounded)
  int get displayStress => currentStress.round();

  /// Display-friendly predicted stress (rounded)
  int get displayPredicted => predictedTomorrow.round();

  /// Whether prediction suggests training tomorrow is advisable
  bool get canTrainTomorrow => predictedTomorrow < 50;

  /// Recovery rate per hour
  double get recoveryRatePerHour {
    if (currentStress <= 0) return 0;
    return (currentStress - predictedTomorrow) / 24;
  }
}

/// Static service for stress predictions
class PredictionService {
  PredictionService._();

  // ===================================
  // DECAY CALCULATION
  // ===================================

  /// Calculate decay factor for given hours and time constant
  ///
  /// Formula: e^(-hours / τ)
  ///
  /// **Parameters**:
  /// - `hours`: Time elapsed in hours
  /// - `tauHours`: Time constant (τ) in hours
  ///
  /// **Returns**: Decay factor (0-1)
  static double calculateDecayFactor(double hours, double tauHours) {
    if (tauHours <= 0) return 0;
    return exp(-hours / tauHours);
  }

  /// Calculate predicted stress after rest period
  ///
  /// Formula: Stress_current × e^(-hours / τ₂)
  ///
  /// **Scientific Basis** (Banister FFM):
  /// - Fatigue decays exponentially with time constant τ₂
  /// - τ₂_base = 10 days (240h) but varies by individual
  /// - Sleep/HRV modulate effective τ₂
  static double predictStressAfterRest({
    required double currentStress,
    required double hours,
    required double tau2Hours,
  }) {
    final decayFactor = calculateDecayFactor(hours, tau2Hours);
    return currentStress * decayFactor;
  }

  /// Calculate predicted stress after workout
  ///
  /// Formula: Stress_rest + workout_stress × k₂
  ///
  /// **Parameters**:
  /// - `currentStress`: Current stress level
  /// - `hours`: Hours until workout
  /// - `tau2Hours`: Personal fatigue decay constant
  /// - `workoutStress`: Expected workout stress (0-100)
  /// - `k2`: Fatigue gain coefficient (default 2.0)
  static double predictStressAfterWorkout({
    required double currentStress,
    required double hours,
    required double tau2Hours,
    required double workoutStress,
    double k2 = 2.0,
  }) {
    // First, decay current stress until workout time
    final stressAtWorkout = predictStressAfterRest(
      currentStress: currentStress,
      hours: hours,
      tau2Hours: tau2Hours,
    );

    // Add new workout stress (with k₂ factor)
    // Cap at 100
    return (stressAtWorkout + workoutStress * k2 / 2).clamp(0.0, 100.0);
  }

  // ===================================
  // RECOMMENDATION ENGINE
  // ===================================

  /// Get recommendation based on stress level
  ///
  /// **Thresholds** (from design doc):
  /// - 0-30: Ready for hard session
  /// - 30-50: Moderate session recommended
  /// - 50-70: Light work only
  /// - 70-85: Active recovery or rest
  /// - 85+: Rest required
  static RecoveryRecommendation getRecommendation(double stress) {
    if (stress < 30) {
      return RecoveryRecommendation.readyHard;
    } else if (stress < 50) {
      return RecoveryRecommendation.moderate;
    } else if (stress < 70) {
      return RecoveryRecommendation.lightOnly;
    } else if (stress < 85) {
      return RecoveryRecommendation.activeRecovery;
    } else {
      return RecoveryRecommendation.restRequired;
    }
  }

  // ===================================
  // FULL INSIGHT CALCULATION
  // ===================================

  /// Calculate full stress insight with predictions and recommendations
  ///
  /// **Inputs**:
  /// - Current stress from recent calculation
  /// - Personal calibration factors
  /// - Health data snapshot (sleep, HRV)
  ///
  /// **Outputs**:
  /// - Current stress with context
  /// - Prediction for tomorrow (rest vs workout)
  /// - Personalized recommendation
  /// - Contributing factors explained
  static StressInsight calculateInsight({
    required double currentStress,
    required PersonalCalibration calibration,
    HealthDataSnapshot? healthData,
    double? averageWorkoutStress,
  }) {
    // Get personal τ₂ for fatigue decay
    final tau2Hours = calibration.personalTau2Hours;

    // Predict stress tomorrow if resting (24h)
    final predictedRest = predictStressAfterRest(
      currentStress: currentStress,
      hours: 24,
      tau2Hours: tau2Hours,
    );

    // Predict stress tomorrow if working out
    // Assume workout in ~12h and lasts until 24h mark
    final avgWorkout = averageWorkoutStress ?? 40.0;
    final predictedWorkout = predictStressAfterWorkout(
      currentStress: currentStress,
      hours: 12, // Workout midday tomorrow
      tau2Hours: tau2Hours,
      workoutStress: avgWorkout,
    );

    // Get recommendation based on current stress
    final recommendation = getRecommendation(currentStress);

    // Build factors map
    final factors = <String, double>{
      'current_stress': currentStress,
      'tau2_hours': tau2Hours,
      'decay_24h': calculateDecayFactor(24, tau2Hours),
    };

    // Add health factors if available
    if (healthData?.sleepHoursLastNight != null) {
      factors['sleep_hours'] = healthData!.sleepHoursLastNight!;
    }
    if (healthData?.hrvMs != null) {
      factors['hrv_ms'] = healthData!.hrvMs!;
    }
    if (healthData?.restingHeartRate != null) {
      factors['resting_hr'] = healthData!.restingHeartRate!;
    }

    // Build rationale
    final rationale = _buildRationale(
      currentStress: currentStress,
      predictedRest: predictedRest,
      recommendation: recommendation,
      healthData: healthData,
      calibration: calibration,
    );

    if (kDebugMode) {
      debugPrint('[PredictionService] Calculated insight:');
      debugPrint('  - Current: ${currentStress.toStringAsFixed(1)}');
      debugPrint('  - Predicted (rest): ${predictedRest.toStringAsFixed(1)}');
      debugPrint(
        '  - Predicted (workout): ${predictedWorkout.toStringAsFixed(1)}',
      );
      debugPrint('  - Recommendation: ${recommendation.name}');
    }

    return StressInsight(
      currentStress: currentStress,
      predictedTomorrow: predictedRest,
      predictedIfWorkout: predictedWorkout,
      recommendation: recommendation,
      rationale: rationale,
      factors: factors,
      calibrationQuality: calibration.quality,
      calculatedAt: DateTime.now(),
    );
  }

  /// Build human-readable rationale
  static String _buildRationale({
    required double currentStress,
    required double predictedRest,
    required RecoveryRecommendation recommendation,
    required HealthDataSnapshot? healthData,
    required PersonalCalibration calibration,
  }) {
    final parts = <String>[];

    // Current stress context
    parts.add('Stress: ${currentStress.round()}');

    // Health factors
    if (healthData != null) {
      if (healthData.sleepHoursLastNight != null) {
        final sleep = healthData.sleepHoursLastNight!;
        if (sleep < 6) {
          parts.add('${sleep.toStringAsFixed(1)}h sleep (critical)');
        } else if (sleep < 7) {
          parts.add('${sleep.toStringAsFixed(1)}h sleep (suboptimal)');
        }
      }

      if (healthData.hrvMs != null) {
        final hrv = healthData.hrvMs!;
        if (hrv < 40) {
          parts.add('HRV ${hrv.round()}ms (stressed)');
        } else if (hrv > 70) {
          parts.add('HRV ${hrv.round()}ms (excellent)');
        }
      }
    }

    // Prediction
    parts.add('Expected: ${predictedRest.round()} tomorrow');

    // Join with separator
    return parts.join(' | ');
  }

  // ===================================
  // MUSCLE-SPECIFIC PREDICTIONS
  // ===================================

  /// Predict muscle recovery using CalibrationService
  ///
  /// Wraps CalibrationService.calculateMuscleRecovery for convenience.
  ///
  /// **Returns**: MuscleReadinessData with recovery percentage and modifiers
  static MuscleReadinessData predictMuscleRecovery({
    required String muscleId,
    required String displayName,
    required DateTime lastWorkedAt,
    required double lastWorkoutStress,
    required PersonalCalibration calibration,
    HealthDataSnapshot? healthData,
    bool isPrimaryMuscle = true,
  }) {
    return CalibrationService.calculateMuscleRecovery(
      muscleId: muscleId,
      displayName: displayName,
      lastWorkedAt: lastWorkedAt,
      lastWorkoutStress: lastWorkoutStress,
      calibration: calibration,
      healthData: healthData,
      isPrimaryMuscle: isPrimaryMuscle,
    );
  }

  /// Predict hours to full recovery for a muscle
  ///
  /// Uses binary search to find when recovery reaches target.
  ///
  /// **Parameters**:
  /// - `currentRecoveryPercent`: Current recovery percentage
  /// - `baseRecoveryHours`: Theoretical full recovery time
  /// - `targetRecovery`: Target recovery % (default 95%)
  ///
  /// **Returns**: Additional hours until target recovery
  static double predictHoursToFullRecovery({
    required double currentRecoveryPercent,
    required double baseRecoveryHours,
    double targetRecovery = 95.0,
  }) {
    if (currentRecoveryPercent >= targetRecovery) return 0;

    // Linear approximation: remaining % × base time
    final remainingPercent = targetRecovery - currentRecoveryPercent;
    return (remainingPercent / 100.0) * baseRecoveryHours;
  }
}
