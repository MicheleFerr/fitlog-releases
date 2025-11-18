/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/usecases
/// 🎯 Feature: ai_coach
/// 🔧 Type: use_case
///
/// Evaluate Advanced Tier Unlock - Detect overtraining via HRV + TSB
///
/// **Requirements**:
/// - Minimum 20 workouts logged
/// - Minimum 42 days of data
///
/// **Overtraining Detection**:
/// 1. **TSB (Training Stress Balance)**: Acute load (7d) vs Chronic load (28d)
/// 2. **HRV (Heart Rate Variability)**: Deviation from personal baseline
/// 3. **Combined Risk Assessment**: Integrate both metrics for final risk level
///
/// **Risk Determination**:
/// - **Low Risk**: TSB > 0, HRV normal → Continue training
/// - **Moderate Risk**: TSB 0 to -10, HRV slightly low → Monitor recovery
/// - **High Risk**: TSB -10 to -20, HRV low → Deload week
/// - **Very High Risk**: TSB < -20, HRV very low → Rest week required
///
/// **Returns**:
/// - `OvertrainingRisk.locked` if requirements not met
/// - `OvertrainingRisk` with TSB, HRV, and recommendation if unlocked
///
/// **Note**: Full HRV baseline calculation (Task 6.5) and TSB service (Task 6.6)
///          will be integrated in subsequent tasks. This use case provides
///          simplified estimation for now.
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/overtraining_risk.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Evaluate Advanced Tier unlock and detect overtraining risk
///
/// **Usage**:
/// ```dart
/// final useCase = EvaluateAdvancedTierUnlock();
/// final risk = await useCase.call(
///   workouts: userWorkouts,
///   accountCreatedAt: userCreatedDate,
///   hrvReadings: heartRateData, // Optional for now
/// );
///
/// if (risk.riskLevel == RiskLevel.locked) {
///   // Show lock screen
/// } else {
///   // Show risk: ${risk.emoji} ${risk.recommendation}
/// }
/// ```
class EvaluateAdvancedTierUnlock {
  /// Evaluate if user meets Advanced tier requirements and detect overtraining
  ///
  /// **Parameters**:
  /// - `workouts`: List of completed workouts
  /// - `accountCreatedAt`: Date when user account was created
  /// - `hrvReadings`: Optional HRV data (will be integrated with Task 6.5)
  ///
  /// **Returns**: OvertrainingRisk with TSB, HRV, and risk level
  Future<OvertrainingRisk> call({
    required List<Workout> workouts,
    required DateTime accountCreatedAt,
    List<HrvReading>? hrvReadings,
  }) async {
    // Check if user meets Advanced tier unlock criteria
    const config = RecoveryTierConfig.advanced;
    final daysSinceCreation =
        DateTime.now().difference(accountCreatedAt).inDays;

    if (workouts.length < config.minWorkouts ||
        daysSinceCreation < config.minDays) {
      // Return locked state
      return OvertrainingRisk.locked;
    }

    // User has unlocked Advanced tier - detect overtraining risk
    return _detectOvertrainingRisk(workouts, hrvReadings);
  }

  /// Detect overtraining risk using TSB and HRV metrics
  OvertrainingRisk _detectOvertrainingRisk(
    List<Workout> workouts,
    List<HrvReading>? hrvReadings,
  ) {
    // Calculate TSB (Training Stress Balance)
    // NOTE: Full implementation in Task 6.6
    final tsbScore = _calculateSimplifiedTSB(workouts);

    // Calculate HRV deviation from baseline
    // NOTE: Full implementation in Task 6.5
    final hrvDeviation = _calculateSimplifiedHrvDeviation(hrvReadings);

    // Determine risk level based on TSB and HRV
    final riskLevel = _determineRiskLevel(tsbScore, hrvDeviation);

    // Generate recommendation
    final recommendation = _generateRecommendation(riskLevel, tsbScore);

    // Create risk factors breakdown
    final factors = _createRiskFactors(workouts, hrvReadings, tsbScore);

    return OvertrainingRisk(
      riskLevel: riskLevel,
      tsbScore: tsbScore,
      hrvDeviation: hrvDeviation,
      recommendation: recommendation,
      factors: factors,
      calculatedAt: DateTime.now(),
    );
  }

  /// Simplified TSB calculation (placeholder for Task 6.6)
  ///
  /// **Formula**: TSB = Chronic Training Load - Acute Training Load
  /// - Acute Load: 7-day total volume
  /// - Chronic Load: 28-day total volume
  ///
  /// **Interpretation**:
  /// - TSB > 0: Well-recovered, fresh
  /// - TSB 0 to -10: Normal training load
  /// - TSB -10 to -20: High load, approaching overreaching
  /// - TSB < -20: Overtraining risk
  double _calculateSimplifiedTSB(List<Workout> workouts) {
    final now = DateTime.now();

    // Calculate Acute Training Load (last 7 days)
    final last7Days = now.subtract(const Duration(days: 7));
    final acuteWorkouts = workouts
        .where((w) => w.startTime != null && w.startTime!.isAfter(last7Days))
        .toList();

    // Calculate Chronic Training Load (last 28 days)
    final last28Days = now.subtract(const Duration(days: 28));
    final chronicWorkouts = workouts
        .where((w) => w.startTime != null && w.startTime!.isAfter(last28Days))
        .toList();

    // Simplified volume calculation (number of workouts × average duration)
    // NOTE: Task 6.6 will implement proper volume load calculation
    final acuteLoad = acuteWorkouts.length;
    final chronicLoad = chronicWorkouts.length / 4; // Average per week

    // TSB = Chronic Load - Acute Load
    // Negative values indicate high acute load relative to chronic
    final tsb = chronicLoad - acuteLoad;

    return tsb;
  }

  /// Simplified HRV deviation calculation (placeholder for Task 6.5)
  ///
  /// **Formula**: HRV Deviation % = ((Current HRV - Baseline HRV) / Baseline HRV) × 100
  ///
  /// **Interpretation**:
  /// - HRV deviation > +5%: Excellent recovery
  /// - HRV deviation 0% to +5%: Good recovery
  /// - HRV deviation -5% to 0%: Acceptable recovery
  /// - HRV deviation -10% to -5%: Low recovery
  /// - HRV deviation < -10%: Very low recovery (overtraining risk)
  double _calculateSimplifiedHrvDeviation(List<HrvReading>? hrvReadings) {
    if (hrvReadings == null || hrvReadings.isEmpty) {
      // No HRV data available - return neutral deviation
      return 0.0;
    }

    // Simplified calculation using last 7 days vs last 28 days
    // NOTE: Task 6.5 will implement proper baseline calculation
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last28Days = now.subtract(const Duration(days: 28));

    final recentReadings = hrvReadings
        .where((r) => r.timestamp.isAfter(last7Days))
        .map((r) => r.value)
        .toList();

    final baselineReadings = hrvReadings
        .where((r) => r.timestamp.isAfter(last28Days))
        .map((r) => r.value)
        .toList();

    if (recentReadings.isEmpty || baselineReadings.isEmpty) {
      return 0.0;
    }

    // Calculate averages
    final currentHrv =
        recentReadings.reduce((a, b) => a + b) / recentReadings.length;
    final baselineHrv =
        baselineReadings.reduce((a, b) => a + b) / baselineReadings.length;

    // Calculate % deviation
    final deviation = ((currentHrv - baselineHrv) / baselineHrv) * 100;

    return deviation;
  }

  /// Determine risk level based on TSB and HRV metrics
  ///
  /// **Priority Matrix**:
  /// 1. If TSB < -20 OR HRV < -10%: Very High Risk
  /// 2. If TSB < -10 OR HRV < -5%: High Risk
  /// 3. If TSB < 0 OR HRV < 0%: Moderate Risk
  /// 4. Otherwise: Low Risk
  RiskLevel _determineRiskLevel(double tsb, double hrvDeviation) {
    // Very high risk: Severe overtraining indicators
    if (tsb < -20 || hrvDeviation < -10) {
      return RiskLevel.veryHigh;
    }

    // High risk: Significant overtraining indicators
    if (tsb < -10 || hrvDeviation < -5) {
      return RiskLevel.high;
    }

    // Moderate risk: Early overtraining indicators
    if (tsb < 0 || hrvDeviation < 0) {
      return RiskLevel.moderate;
    }

    // Low risk: Well-recovered
    return RiskLevel.low;
  }

  /// Generate human-readable recommendation based on risk level and TSB
  String _generateRecommendation(RiskLevel riskLevel, double tsb) {
    switch (riskLevel) {
      case RiskLevel.locked:
        return 'Unlock Advanced tier by logging 20 workouts over 42 days';

      case RiskLevel.low:
        return 'Well-recovered! Continue current training load.';

      case RiskLevel.moderate:
        if (tsb < -5) {
          return 'Monitor recovery. Consider reducing volume next week.';
        }
        return 'Monitor recovery closely. Maintain current intensity.';

      case RiskLevel.high:
        return 'High overtraining risk. Deload week recommended (50-60% volume).';

      case RiskLevel.veryHigh:
        return 'Very high risk. Take 3-5 days complete rest, then reassess.';
    }
  }

  /// Create risk factors breakdown for detailed analysis
  RiskFactors _createRiskFactors(
    List<Workout> workouts,
    List<HrvReading>? hrvReadings,
    double tsbScore,
  ) {
    final now = DateTime.now();

    // Calculate Acute Training Load (last 7 days)
    final last7Days = now.subtract(const Duration(days: 7));
    final acuteWorkouts = workouts
        .where((w) => w.startTime != null && w.startTime!.isAfter(last7Days))
        .length;

    // Calculate Chronic Training Load (last 28 days)
    final last28Days = now.subtract(const Duration(days: 28));
    final chronicWorkouts = workouts
        .where((w) => w.startTime != null && w.startTime!.isAfter(last28Days))
        .length;

    // Calculate HRV baseline and current
    double hrvBaseline = 0.0;
    double currentHrv = 0.0;

    if (hrvReadings != null && hrvReadings.isNotEmpty) {
      final recentReadings = hrvReadings
          .where((r) => r.timestamp.isAfter(last7Days))
          .map((r) => r.value)
          .toList();

      final baselineReadings = hrvReadings
          .where((r) => r.timestamp.isAfter(last28Days))
          .map((r) => r.value)
          .toList();

      if (recentReadings.isNotEmpty) {
        currentHrv =
            recentReadings.reduce((a, b) => a + b) / recentReadings.length;
      }

      if (baselineReadings.isNotEmpty) {
        hrvBaseline =
            baselineReadings.reduce((a, b) => a + b) / baselineReadings.length;
      }
    }

    return RiskFactors(
      acuteTrainingLoad: acuteWorkouts,
      chronicTrainingLoad: chronicWorkouts,
      hrvBaseline: hrvBaseline,
      currentHrv: currentHrv,
      // Subjective markers not yet implemented (future enhancement)
      sleepQualityScore: null,
      muscleSorenessScore: null,
      moodEnergyScore: null,
    );
  }
}

/// Placeholder class for HRV reading (will be defined in Task 6.5)
///
/// **Structure**:
/// - `value`: HRV value in milliseconds (ms)
/// - `timestamp`: When reading was taken
class HrvReading {
  const HrvReading({
    required this.value,
    required this.timestamp,
  });

  final double value;
  final DateTime timestamp;
}
