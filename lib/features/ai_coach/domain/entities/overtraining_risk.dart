/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Overtraining Risk - Advanced tier AI Coach insight
///
/// **Detection Methods**:
/// 1. **HRV (Heart Rate Variability) Baseline**: Deviation from personal baseline
/// 2. **TSB (Training Stress Balance)**: Acute load vs chronic load ratio
/// 3. **Subjective Markers**: Sleep quality, mood, muscle soreness
///
/// **Risk Levels**:
/// - **Low Risk** (TSB > 0, HRV normal): Well-recovered, training effective
/// - **Moderate Risk** (TSB 0 to -10, HRV slightly low): Monitor recovery
/// - **High Risk** (TSB -10 to -20, HRV low): Deload recommended
/// - **Very High Risk** (TSB < -20, HRV very low): Rest week required
///
/// **Advanced Tier Feature**: Available after 20 workouts over 42 days
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'overtraining_risk.freezed.dart';
part 'overtraining_risk.g.dart';

/// Overtraining risk assessment for Advanced tier
///
/// **Usage**:
/// ```dart
/// final risk = OvertrainingRisk(
///   riskLevel: RiskLevel.moderate,
///   tsbScore: -5.2,
///   hrvDeviation: -8.5,
///   recommendation: 'Monitor recovery. Consider reducing volume next week.',
/// );
///
/// print('${risk.emoji} TSB: ${risk.tsbScore.toStringAsFixed(1)}');
/// // ⚠️ TSB: -5.2
/// ```
@freezed
class OvertrainingRisk with _$OvertrainingRisk {
  const factory OvertrainingRisk({
    /// Overall risk level for overtraining
    required RiskLevel riskLevel,

    /// TSB (Training Stress Balance) score
    ///
    /// **Interpretation**:
    /// - TSB > 0: Fresh, well-recovered
    /// - TSB 0 to -10: Normal training load
    /// - TSB -10 to -20: Approaching overreaching
    /// - TSB < -20: Overtraining risk (deload needed)
    ///
    /// **Formula**: TSB = Chronic Training Load - Acute Training Load
    required double tsbScore,

    /// HRV (Heart Rate Variability) deviation from baseline (%)
    ///
    /// **Interpretation**:
    /// - HRV deviation > +5%: Excellent recovery
    /// - HRV deviation 0% to +5%: Good recovery
    /// - HRV deviation -5% to 0%: Acceptable recovery
    /// - HRV deviation -10% to -5%: Low recovery (monitor)
    /// - HRV deviation < -10%: Very low recovery (rest needed)
    ///
    /// **Note**: Negative values indicate HRV below personal baseline
    required double hrvDeviation,

    /// Human-readable recommendation based on risk assessment
    ///
    /// **Examples**:
    /// - "Well-recovered! Continue current training load."
    /// - "Monitor recovery. Consider reducing volume next week."
    /// - "High overtraining risk. Deload week recommended."
    /// - "Very high risk. Take 3-5 days complete rest."
    required String recommendation,

    /// Optional: Detailed breakdown of risk factors
    RiskFactors? factors,

    /// Timestamp when risk was calculated
    @Default(null) DateTime? calculatedAt,
  }) = _OvertrainingRisk;

  const OvertrainingRisk._();

  factory OvertrainingRisk.fromJson(Map<String, dynamic> json) =>
      _$OvertrainingRiskFromJson(json);

  /// Locked state (insufficient data for tier)
  static const locked = OvertrainingRisk(
    riskLevel: RiskLevel.locked,
    tsbScore: 0.0,
    hrvDeviation: 0.0,
    recommendation:
        'Unlock Advanced tier by logging 20 workouts over 42 days',
  );

  /// Emoji representation of risk level
  String get emoji {
    switch (riskLevel) {
      case RiskLevel.locked:
        return '🔒';
      case RiskLevel.low:
        return '✅';
      case RiskLevel.moderate:
        return '⚠️';
      case RiskLevel.high:
        return '🚨';
      case RiskLevel.veryHigh:
        return '🛑';
    }
  }

  /// Whether a deload week is recommended
  bool get shouldDeload => riskLevel == RiskLevel.high;

  /// Whether complete rest is required
  bool get needsRest => riskLevel == RiskLevel.veryHigh;
}

/// Risk levels for overtraining
enum RiskLevel {
  /// Locked (insufficient data)
  @JsonValue('locked')
  locked,

  /// Low risk - Well-recovered, training effective
  @JsonValue('low')
  low,

  /// Moderate risk - Monitor recovery
  @JsonValue('moderate')
  moderate,

  /// High risk - Deload recommended
  @JsonValue('high')
  high,

  /// Very high risk - Rest week required
  @JsonValue('very_high')
  veryHigh,
}

/// Detailed breakdown of overtraining risk factors
///
/// **Usage**:
/// ```dart
/// final factors = RiskFactors(
///   acuteTrainingLoad: 450,
///   chronicTrainingLoad: 420,
///   hrvBaseline: 65,
///   currentHrv: 58,
///   sleepQualityScore: 6,
///   muscleSorenessScore: 7,
/// );
/// ```
@freezed
class RiskFactors with _$RiskFactors {
  const factory RiskFactors({
    /// Acute Training Load (7-day average)
    ///
    /// **Calculation**: Sum of daily training stress scores (last 7 days)
    required int acuteTrainingLoad,

    /// Chronic Training Load (28-day average)
    ///
    /// **Calculation**: Sum of daily training stress scores (last 28 days)
    required int chronicTrainingLoad,

    /// HRV baseline (personal average from 20+ days)
    ///
    /// **Unit**: Milliseconds (ms)
    /// **Typical Range**: 40-90 ms (varies by individual)
    required double hrvBaseline,

    /// Current HRV (7-day average)
    ///
    /// **Unit**: Milliseconds (ms)
    /// **Comparison**: Compare to hrvBaseline for deviation %
    required double currentHrv,

    /// Optional: Sleep quality score (1-10)
    ///
    /// **Scale**:
    /// - 8-10: Excellent sleep
    /// - 6-7: Good sleep
    /// - 4-5: Poor sleep
    /// - 1-3: Very poor sleep
    int? sleepQualityScore,

    /// Optional: Muscle soreness score (1-10)
    ///
    /// **Scale**:
    /// - 1-3: Minimal soreness
    /// - 4-6: Moderate soreness
    /// - 7-8: Significant soreness
    /// - 9-10: Severe soreness (DOMS)
    int? muscleSorenessScore,

    /// Optional: Mood/energy score (1-10)
    ///
    /// **Scale**:
    /// - 8-10: High energy, positive mood
    /// - 6-7: Normal energy
    /// - 4-5: Low energy, irritability
    /// - 1-3: Fatigue, depression symptoms
    int? moodEnergyScore,
  }) = _RiskFactors;

  factory RiskFactors.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorsFromJson(json);
}

/// Extension on RiskLevel for convenience methods
extension RiskLevelExtension on RiskLevel {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case RiskLevel.locked:
        return 'Locked';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.veryHigh:
        return 'Very High Risk';
    }
  }

  /// Color for UI (semantic)
  ///
  /// Returns color name for theming:
  /// - locked: onSurface (gray)
  /// - low: success (green)
  /// - moderate: warning (yellow)
  /// - high: error (red)
  /// - veryHigh: error (red, darker variant)
  String get colorName {
    switch (this) {
      case RiskLevel.locked:
        return 'onSurface';
      case RiskLevel.low:
        return 'success';
      case RiskLevel.moderate:
        return 'warning';
      case RiskLevel.high:
      case RiskLevel.veryHigh:
        return 'error';
    }
  }

  /// Score (0-100) for this risk level
  ///
  /// Lower scores = higher risk
  int get score {
    switch (this) {
      case RiskLevel.locked:
        return 0;
      case RiskLevel.low:
        return 90;
      case RiskLevel.moderate:
        return 70;
      case RiskLevel.high:
        return 40;
      case RiskLevel.veryHigh:
        return 10;
    }
  }

  /// Short description of what action to take
  String get actionDescription {
    switch (this) {
      case RiskLevel.locked:
        return 'Complete 20 workouts to unlock';
      case RiskLevel.low:
        return 'Continue current training';
      case RiskLevel.moderate:
        return 'Monitor recovery closely';
      case RiskLevel.high:
        return 'Deload week recommended';
      case RiskLevel.veryHigh:
        return 'Take 3-5 days complete rest';
    }
  }
}
