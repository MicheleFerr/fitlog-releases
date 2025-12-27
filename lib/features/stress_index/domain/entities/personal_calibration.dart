/// Personal Calibration Entity
///
/// Contains personalized calibration factors for the Stress Index calculation.
/// Based on:
/// - Banister FFM model adjustments
/// - Individual profile data (age, sex, experience)
/// - HealthKit data (HRV, sleep)
/// - Injury status
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'personal_calibration.freezed.dart';
part 'personal_calibration.g.dart';

@freezed
abstract class PersonalCalibration with _$PersonalCalibration {
  const factory PersonalCalibration({
    /// User ID for this calibration
    required String userId,

    // === FITNESS DECAY FACTORS (τ₁) ===

    /// Age-based factor: 0.8-1.0
    /// 20-30: 1.0, 40: 0.9, 50+: 0.8
    @Default(1.0) double ageFactor,

    /// Training experience factor: 0.9-1.2
    /// Novice: 1.2 (adapts faster), Advanced: 0.9
    @Default(1.0) double trainingAgeFactor,

    /// Biological sex factor: 0.95-1.0
    /// Male: 1.0, Female: 0.95 (hormonal differences)
    @Default(1.0) double sexFactor,

    // === FATIGUE DECAY FACTORS (τ₂) ===

    /// HRV-based factor: 0.8-1.3
    /// High HRV (>70ms): 0.8 (fast recovery)
    /// Low HRV (<40ms): 1.3 (slow recovery)
    @Default(1.0) double hrvFactor,

    /// Sleep-based factor: 0.9-1.4
    /// 7-9h: 1.0, <6h: 1.4 (slow recovery)
    @Default(1.0) double sleepFactor,

    /// Injury-based factor: 1.0-1.3
    /// None: 1.0, Active injury: 1.3
    @Default(1.0) double injuryFactor,

    // === BASELINE VALUES ===

    /// User's average HRV in milliseconds
    /// Used to detect deviations from personal norm
    double? baselineHrv,

    /// User's average sleep duration in hours
    double? baselineSleepHours,

    /// User's resting heart rate
    double? baselineRestingHr,

    // === METADATA ===

    /// When calibration was last updated
    DateTime? lastUpdated,

    /// How many data points were used for calibration
    @Default(0) int dataPointsUsed,

    /// Confidence level: 0-1 (how reliable the calibration is)
    @Default(0.5) double confidenceLevel,
  }) = _PersonalCalibration;

  const PersonalCalibration._();

  factory PersonalCalibration.fromJson(Map<String, dynamic> json) =>
      _$PersonalCalibrationFromJson(json);

  /// Create default calibration (no personalization)
  factory PersonalCalibration.defaultFor(String userId) => PersonalCalibration(
        userId: userId,
        lastUpdated: DateTime.now(),
      );

  // === COMPUTED PROPERTIES ===

  /// Combined τ₁ modifier (fitness decay)
  /// τ₁_personal = τ₁_base × ageFactor × trainingAgeFactor × sexFactor
  double get tau1Modifier => ageFactor * trainingAgeFactor * sexFactor;

  /// Combined τ₂ modifier (fatigue decay)
  /// τ₂_personal = τ₂_base × hrvFactor × sleepFactor × injuryFactor
  double get tau2Modifier => hrvFactor * sleepFactor * injuryFactor;

  /// Personal τ₁ in hours (default: 1008h = 42 days)
  double get personalTau1Hours => 1008.0 * tau1Modifier;

  /// Personal τ₂ in hours (default: 240h = 10 days)
  double get personalTau2Hours => 240.0 * tau2Modifier;

  /// Whether this calibration has HealthKit data
  bool get hasHealthKitData => baselineHrv != null || baselineSleepHours != null;

  /// Whether calibration is high confidence (>0.7)
  bool get isHighConfidence => confidenceLevel >= 0.7;

  /// Description of calibration quality
  CalibrationQuality get quality {
    if (confidenceLevel >= 0.8) return CalibrationQuality.excellent;
    if (confidenceLevel >= 0.6) return CalibrationQuality.good;
    if (confidenceLevel >= 0.4) return CalibrationQuality.fair;
    return CalibrationQuality.poor;
  }
}

/// Calibration quality levels
enum CalibrationQuality {
  /// 80%+ confidence - Very reliable predictions
  excellent,

  /// 60-79% - Good predictions
  good,

  /// 40-59% - Acceptable predictions
  fair,

  /// <40% - Needs more data
  poor,
}
