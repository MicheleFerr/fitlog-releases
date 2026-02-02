/// Calibration Service
///
/// Calculates personal calibration factors for the Stress Index system.
///
/// Based on:
/// - Banister FFM model adjustments
/// - McKay AKA et al. (2022) - Training caliber definitions
/// - Res et al. - Sleep-MPS correlation
/// - Knowles et al. - Sleep-strength correlation
library;

import 'dart:math';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/personal_calibration.dart';

/// Health data snapshot for calibration
class HealthDataSnapshot {
  const HealthDataSnapshot({
    this.sleepHoursLastNight,
    this.hrvMs,
    this.restingHeartRate,
  });

  /// Hours of sleep last night
  final double? sleepHoursLastNight;

  /// Heart rate variability in milliseconds
  final double? hrvMs;

  /// Resting heart rate in bpm
  final double? restingHeartRate;

  /// Empty snapshot (no health data available)
  static const HealthDataSnapshot empty = HealthDataSnapshot();

  /// Whether any health data is available
  bool get hasData =>
      sleepHoursLastNight != null || hrvMs != null || restingHeartRate != null;
}

/// Static service for personal calibration calculations
class CalibrationService {
  CalibrationService._();

  // ===================================
  // CALIBRATION FACTOR CALCULATION
  // ===================================

  /// Calculate personal calibration from profile and health data
  ///
  /// Parameters:
  /// - [userId]: User ID for the calibration
  /// - [questionnaire]: User fitness questionnaire (optional)
  /// - [healthData]: Current health data from HealthKit (optional)
  /// - [historicalHrv]: List of historical HRV values for baseline (optional)
  /// - [historicalSleep]: List of historical sleep hours for baseline (optional)
  static PersonalCalibration calculateCalibration({
    required String userId,
    UserFitnessQuestionnaire? questionnaire,
    HealthDataSnapshot? healthData,
    List<double>? historicalHrv,
    List<double>? historicalSleep,
  }) {
    // Calculate individual factors
    final ageFactor = _calculateAgeFactor(questionnaire?.age);
    final trainingAgeFactor = _calculateTrainingAgeFactor(
      questionnaire?.experienceLevel,
    );
    final sexFactor = _calculateSexFactor(questionnaire?.sex);
    final injuryFactor = _calculateInjuryFactor(questionnaire);

    // Calculate baselines from historical data
    final baselineHrv = historicalHrv != null && historicalHrv.isNotEmpty
        ? historicalHrv.reduce((a, b) => a + b) / historicalHrv.length
        : null;

    final baselineSleepHours =
        historicalSleep != null && historicalSleep.isNotEmpty
        ? historicalSleep.reduce((a, b) => a + b) / historicalSleep.length
        : null;

    // Calculate dynamic factors based on current health data
    final hrvFactor = _calculateHrvFactor(
      currentHrv: healthData?.hrvMs,
      baselineHrv: baselineHrv,
    );

    final sleepFactor = _calculateSleepFactor(healthData?.sleepHoursLastNight);

    // Calculate confidence level
    final confidenceLevel = _calculateConfidenceLevel(
      hasQuestionnaire: questionnaire != null,
      hasHealthData: healthData?.hasData ?? false,
      hasHistoricalData:
          (historicalHrv?.isNotEmpty ?? false) ||
          (historicalSleep?.isNotEmpty ?? false),
    );

    // Count data points
    final dataPointsUsed = _countDataPoints(
      questionnaire: questionnaire,
      healthData: healthData,
      historicalHrv: historicalHrv,
      historicalSleep: historicalSleep,
    );

    return PersonalCalibration(
      userId: userId,
      ageFactor: ageFactor,
      trainingAgeFactor: trainingAgeFactor,
      sexFactor: sexFactor,
      hrvFactor: hrvFactor,
      sleepFactor: sleepFactor,
      injuryFactor: injuryFactor,
      baselineHrv: baselineHrv,
      baselineSleepHours: baselineSleepHours,
      baselineRestingHr: healthData?.restingHeartRate,
      lastUpdated: DateTime.now(),
      dataPointsUsed: dataPointsUsed,
      confidenceLevel: confidenceLevel,
    );
  }

  // ===================================
  // MULTI-FACTOR MUSCLE RECOVERY
  // ===================================

  /// Calculate muscle recovery with multiple factors
  ///
  /// Implements the multi-factor recovery model from design doc:
  /// - Base recovery from time elapsed
  /// - Sleep modifier (-30% to 0%)
  /// - HRV modifier (-25% to +10%)
  /// - Age modifier (-20% to 0%)
  /// - Previous session intensity modifier
  ///
  /// Returns MuscleReadinessData with detailed breakdown
  static MuscleReadinessData calculateMuscleRecovery({
    required String muscleId,
    required String displayName,
    required DateTime lastWorkedAt,
    required double lastWorkoutStress,
    required PersonalCalibration calibration,
    HealthDataSnapshot? healthData,
    bool isPrimaryMuscle = true,
  }) {
    final now = DateTime.now();
    final hoursSinceWorkout = now.difference(lastWorkedAt).inHours;

    // 1. BASE: Time elapsed vs theoretical recovery time
    final baseRecoveryHours =
        StressIndexConstants.muscleRecoveryHours[muscleId.toUpperCase()] ??
        StressIndexConstants.defaultRecoveryHours;

    double recoveryPercent = (hoursSinceWorkout / baseRecoveryHours) * 100;

    // Track modifiers for transparency
    double sleepModifier = 0;
    double hrvModifier = 0;
    double ageModifier = 0;

    // 2. SLEEP MODIFIER (HealthKit)
    if (healthData?.sleepHoursLastNight != null) {
      final sleep = healthData!.sleepHoursLastNight!;
      if (sleep < 6) {
        sleepModifier = -30; // Critical: -30%
        recoveryPercent *= 0.70;
      } else if (sleep < 7) {
        sleepModifier = -15; // Suboptimal: -15%
        recoveryPercent *= 0.85;
      } else if (sleep >= 8) {
        sleepModifier = 5; // Bonus for good sleep
        recoveryPercent *= 1.05;
      }
    }

    // 3. HRV MODIFIER (HealthKit)
    if (healthData?.hrvMs != null && calibration.baselineHrv != null) {
      final hrvRatio = healthData!.hrvMs! / calibration.baselineHrv!;
      if (hrvRatio < 0.7) {
        hrvModifier = -25; // System stressed
        recoveryPercent *= 0.75;
      } else if (hrvRatio < 0.85) {
        hrvModifier = -10;
        recoveryPercent *= 0.90;
      } else if (hrvRatio > 1.1) {
        hrvModifier = 10; // Accelerated recovery!
        recoveryPercent *= 1.10;
      }
    }

    // 4. AGE MODIFIER (from calibration)
    // ageFactor is 0.8-1.0, convert to percentage modifier
    ageModifier = (calibration.ageFactor - 1.0) * 100; // e.g., 0.9 -> -10%
    recoveryPercent *= calibration.ageFactor;

    // 5. PREVIOUS SESSION INTENSITY
    double intensityModifier = 1.0;
    if (lastWorkoutStress > 80) {
      intensityModifier = 0.85; // Very hard session
    } else if (lastWorkoutStress > 60) {
      intensityModifier = 0.92; // Hard session
    }
    recoveryPercent *= intensityModifier;

    // Clamp to valid range (max 150% = supercompensation)
    recoveryPercent = recoveryPercent.clamp(0, 150);

    return MuscleReadinessData(
      muscleId: muscleId,
      displayName: displayName,
      recoveryPercent: recoveryPercent,
      lastWorkedAt: lastWorkedAt,
      hoursSinceWorkout: hoursSinceWorkout,
      lastWorkoutStress: lastWorkoutStress,
      isPrimaryMuscle: isPrimaryMuscle,
      sleepModifier: sleepModifier,
      hrvModifier: hrvModifier,
      ageModifier: ageModifier,
    );
  }

  // ===================================
  // PRIVATE FACTOR CALCULATIONS
  // ===================================

  /// Calculate age factor (0.8-1.0)
  /// 20-30: 1.0, 40: 0.9, 50+: 0.8
  static double _calculateAgeFactor(int? age) {
    if (age == null) return 1.0;

    if (age <= 30) return 1.0;
    if (age >= 50) return 0.8;

    // Linear interpolation between 30 and 50
    // age 30 -> 1.0, age 50 -> 0.8
    return 1.0 - ((age - 30) / 20) * 0.2;
  }

  /// Calculate training age factor (0.9-1.2)
  /// Novice: 1.2 (adapts faster), Advanced: 0.9
  static double _calculateTrainingAgeFactor(ExperienceLevel? level) {
    if (level == null) return 1.0;

    switch (level) {
      case ExperienceLevel.untrained:
        return 1.2; // Beginners adapt faster
      case ExperienceLevel.novice:
        return 1.15;
      case ExperienceLevel.intermediate:
        return 1.0; // Reference
      case ExperienceLevel.advanced:
        return 0.95;
      case ExperienceLevel.elite:
        return 0.9; // Elite needs more recovery
    }
  }

  /// Calculate sex factor (0.95-1.0)
  /// Male: 1.0, Female: 0.95
  static double _calculateSexFactor(BiologicalSex? sex) {
    if (sex == null) return 1.0;

    switch (sex) {
      case BiologicalSex.male:
        return 1.0;
      case BiologicalSex.female:
        return 0.95; // Slightly faster fatigue decay
    }
  }

  /// Calculate HRV factor (0.8-1.3)
  /// High HRV (>70ms): 0.8 (fast recovery)
  /// Low HRV (<40ms): 1.3 (slow recovery)
  static double _calculateHrvFactor({double? currentHrv, double? baselineHrv}) {
    // If we have baseline, use ratio
    if (currentHrv != null && baselineHrv != null && baselineHrv > 0) {
      final ratio = currentHrv / baselineHrv;

      if (ratio > 1.2) return 0.8; // Excellent recovery
      if (ratio > 1.0) return 0.9;
      if (ratio > 0.85) return 1.0; // Normal
      if (ratio > 0.7) return 1.15;
      return 1.3; // Stressed system
    }

    // If only current HRV, use absolute values
    if (currentHrv != null) {
      if (currentHrv > 70) return 0.8; // High HRV
      if (currentHrv > 50) return 0.9;
      if (currentHrv > 40) return 1.0; // Normal
      if (currentHrv > 30) return 1.15;
      return 1.3; // Low HRV
    }

    return 1.0; // Default
  }

  /// Calculate sleep factor (0.9-1.4)
  /// 7-9h: 1.0, <6h: 1.4 (slow recovery)
  static double _calculateSleepFactor(double? sleepHours) {
    if (sleepHours == null) return 1.0;

    if (sleepHours >= 8) return 0.9; // Bonus for excellent sleep
    if (sleepHours >= 7) return 1.0; // Optimal
    if (sleepHours >= 6) return 1.15; // Suboptimal
    return 1.4; // Critical sleep deprivation
  }

  /// Calculate injury factor (1.0-1.3)
  /// None: 1.0, Active injury: 1.3
  static double _calculateInjuryFactor(
    UserFitnessQuestionnaire? questionnaire,
  ) {
    if (questionnaire == null) return 1.0;
    if (!questionnaire.hasInjuryHistory) return 1.0;

    final details = questionnaire.injuryDetails;
    if (details == null) return 1.1; // Has history but no details

    // Active injury or in rehabilitation
    if (details.inRehabilitation) return 1.3;
    if (!details.fullyRecovered) return 1.2;

    // Recently recovered (within 6 months)
    if (details.monthsSinceInjury < 6) return 1.1;

    return 1.0; // Fully recovered, long ago
  }

  /// Calculate confidence level (0-1)
  static double _calculateConfidenceLevel({
    required bool hasQuestionnaire,
    required bool hasHealthData,
    required bool hasHistoricalData,
  }) {
    double confidence = 0.4; // Base confidence

    if (hasQuestionnaire) confidence += 0.2;
    if (hasHealthData) confidence += 0.2;
    if (hasHistoricalData) confidence += 0.2;

    return min(1.0, confidence);
  }

  /// Count data points used for calibration
  static int _countDataPoints({
    UserFitnessQuestionnaire? questionnaire,
    HealthDataSnapshot? healthData,
    List<double>? historicalHrv,
    List<double>? historicalSleep,
  }) {
    int count = 0;

    if (questionnaire != null) {
      if (questionnaire.age > 0) count++;
      count++; // sex
      count++; // experienceLevel
      if (questionnaire.hasInjuryHistory) count++;
    }

    if (healthData != null) {
      if (healthData.sleepHoursLastNight != null) count++;
      if (healthData.hrvMs != null) count++;
      if (healthData.restingHeartRate != null) count++;
    }

    count += historicalHrv?.length ?? 0;
    count += historicalSleep?.length ?? 0;

    return count;
  }
}
