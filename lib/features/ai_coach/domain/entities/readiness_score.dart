/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Readiness Score - Basic tier AI Coach insight
///
/// **Score Calculation** (0-100):
/// - **90-100**: Optimal readiness (well-recovered, high energy)
/// - **75-89**: Good readiness (ready for challenging workout)
/// - **60-74**: Moderate readiness (light/moderate workout recommended)
/// - **40-59**: Low readiness (active recovery or rest day)
/// - **0-39**: Very low readiness (rest day strongly recommended)
///
/// **Factors**:
/// 1. **Workout Frequency** (40%): Recent training volume vs baseline
/// 2. **Recovery Time** (30%): Days since last workout
/// 3. **Training Consistency** (30%): Adherence to workout schedule
///
/// **Basic Tier Feature**: Available after 6 workouts over 14 days
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'readiness_score.freezed.dart';
part 'readiness_score.g.dart';

/// Readiness score for training recommendations (Basic tier)
///
/// **Usage**:
/// ```dart
/// final score = ReadinessScore(
///   score: 85,
///   category: ReadinessCategory.good,
///   recommendation: 'Great! Ready for a challenging workout.',
/// );
///
/// print('${score.emoji} ${score.score}/100 - ${score.recommendation}');
/// // 💪 85/100 - Great! Ready for a challenging workout.
/// ```
@freezed
class ReadinessScore with _$ReadinessScore {
  const factory ReadinessScore({
    /// Readiness score (0-100)
    ///
    /// **Interpretation**:
    /// - 90-100: Optimal (🔥)
    /// - 75-89: Good (💪)
    /// - 60-74: Moderate (😐)
    /// - 40-59: Low (😴)
    /// - 0-39: Very Low (🚫)
    required int score,

    /// Category derived from score
    required ReadinessCategory category,

    /// Human-readable recommendation
    ///
    /// **Examples**:
    /// - "Great! Ready for a challenging workout."
    /// - "Moderate energy. Consider a light workout."
    /// - "Low readiness. Active recovery or rest recommended."
    required String recommendation,

    /// Optional: Factors contributing to score
    ReadinessFactors? factors,

    /// Timestamp when score was calculated
    @Default(null) DateTime? calculatedAt,
  }) = _ReadinessScore;

  const ReadinessScore._();

  factory ReadinessScore.fromJson(Map<String, dynamic> json) =>
      _$ReadinessScoreFromJson(json);

  /// Locked state (insufficient data for tier)
  static const locked = ReadinessScore(
    score: 0,
    category: ReadinessCategory.locked,
    recommendation: 'Unlock Basic tier by logging 6 workouts over 14 days',
  );

  /// Emoji representation of readiness category
  String get emoji {
    switch (category) {
      case ReadinessCategory.optimal:
        return '🔥';
      case ReadinessCategory.good:
        return '💪';
      case ReadinessCategory.moderate:
        return '😐';
      case ReadinessCategory.low:
        return '😴';
      case ReadinessCategory.veryLow:
        return '🚫';
      case ReadinessCategory.locked:
        return '🔒';
    }
  }

  /// Whether score indicates readiness for training
  bool get isReadyForTraining => score >= 60;

  /// Whether score recommends rest day
  bool get shouldRest => score < 40;
}

/// Readiness category derived from score
enum ReadinessCategory {
  /// Locked (insufficient data)
  @JsonValue('locked')
  locked,

  /// Very low readiness (0-39) - Rest day strongly recommended
  @JsonValue('very_low')
  veryLow,

  /// Low readiness (40-59) - Active recovery or rest
  @JsonValue('low')
  low,

  /// Moderate readiness (60-74) - Light/moderate workout
  @JsonValue('moderate')
  moderate,

  /// Good readiness (75-89) - Ready for challenging workout
  @JsonValue('good')
  good,

  /// Optimal readiness (90-100) - Peak performance
  @JsonValue('optimal')
  optimal,
}

/// Factors contributing to readiness score
///
/// **Usage**:
/// ```dart
/// final factors = ReadinessFactors(
///   workoutFrequencyScore: 85,
///   recoveryTimeScore: 75,
///   consistencyScore: 90,
/// );
///
/// print('Workout frequency: ${factors.workoutFrequencyScore}/100');
/// print('Recovery time: ${factors.recoveryTimeScore}/100');
/// print('Consistency: ${factors.consistencyScore}/100');
/// ```
@freezed
class ReadinessFactors with _$ReadinessFactors {
  const factory ReadinessFactors({
    /// Workout frequency score (0-100)
    ///
    /// **Calculation**: Recent training volume vs baseline (40% weight)
    required int workoutFrequencyScore,

    /// Recovery time score (0-100)
    ///
    /// **Calculation**: Days since last workout (30% weight)
    required int recoveryTimeScore,

    /// Training consistency score (0-100)
    ///
    /// **Calculation**: Adherence to workout schedule (30% weight)
    required int consistencyScore,

    /// Optional: Days since last workout
    int? daysSinceLastWorkout,

    /// Optional: Workouts in last 7 days
    int? workoutsLast7Days,

    /// Optional: Average workouts per week
    double? avgWorkoutsPerWeek,
  }) = _ReadinessFactors;

  factory ReadinessFactors.fromJson(Map<String, dynamic> json) =>
      _$ReadinessFactorsFromJson(json);
}

/// Extension on ReadinessCategory for convenience methods
extension ReadinessCategoryExtension on ReadinessCategory {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case ReadinessCategory.locked:
        return 'Locked';
      case ReadinessCategory.veryLow:
        return 'Very Low';
      case ReadinessCategory.low:
        return 'Low';
      case ReadinessCategory.moderate:
        return 'Moderate';
      case ReadinessCategory.good:
        return 'Good';
      case ReadinessCategory.optimal:
        return 'Optimal';
    }
  }

  /// Color for UI (semantic)
  ///
  /// Returns color name for theming:
  /// - locked: onSurface (gray)
  /// - veryLow/low: error (red)
  /// - moderate: warning (yellow)
  /// - good: success (green)
  /// - optimal: primary (blue)
  String get colorName {
    switch (this) {
      case ReadinessCategory.locked:
        return 'onSurface';
      case ReadinessCategory.veryLow:
      case ReadinessCategory.low:
        return 'error';
      case ReadinessCategory.moderate:
        return 'warning';
      case ReadinessCategory.good:
        return 'success';
      case ReadinessCategory.optimal:
        return 'primary';
    }
  }
}
