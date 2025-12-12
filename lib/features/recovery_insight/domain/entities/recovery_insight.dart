/// Recovery Insight Entity
///
/// Combines sleep data with workout history to provide actionable recovery insights.
///
/// **Score Calculation**:
/// FinalScore = BaseScore × SleepModifier × ConsecutivePenalty
///
/// **Categories**:
/// - 85-100: Optimal - Ready for intense workout
/// - 70-84: Good - Ready for normal workout
/// - 55-69: Moderate - Consider lighter workout
/// - 40-54: Low - Prioritize rest
/// - 0-39: Critical - Rest day recommended
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_workout_correlation.dart';

part 'recovery_insight.freezed.dart';
part 'recovery_insight.g.dart';

/// Recovery category based on score
enum RecoveryCategory {
  /// 85-100 - Peak readiness
  @JsonValue('optimal')
  optimal,

  /// 70-84 - Good to go
  @JsonValue('good')
  good,

  /// 55-69 - Take it easy
  @JsonValue('moderate')
  moderate,

  /// 40-54 - Recovery needed
  @JsonValue('low')
  low,

  /// 0-39 - Rest recommended
  @JsonValue('critical')
  critical,
}

/// Extension for RecoveryCategory helpers
extension RecoveryCategoryExtension on RecoveryCategory {
  /// Get category from score
  static RecoveryCategory fromScore(int score) {
    if (score >= 85) return RecoveryCategory.optimal;
    if (score >= 70) return RecoveryCategory.good;
    if (score >= 55) return RecoveryCategory.moderate;
    if (score >= 40) return RecoveryCategory.low;
    return RecoveryCategory.critical;
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case RecoveryCategory.optimal:
        return 'Ottimale';
      case RecoveryCategory.good:
        return 'Buono';
      case RecoveryCategory.moderate:
        return 'Moderato';
      case RecoveryCategory.low:
        return 'Basso';
      case RecoveryCategory.critical:
        return 'Critico';
    }
  }

  /// Color name for theming
  String get colorName {
    switch (this) {
      case RecoveryCategory.optimal:
        return 'primary';
      case RecoveryCategory.good:
        return 'success';
      case RecoveryCategory.moderate:
        return 'warning';
      case RecoveryCategory.low:
        return 'error';
      case RecoveryCategory.critical:
        return 'error';
    }
  }

  /// Emoji for quick visual
  String get emoji {
    switch (this) {
      case RecoveryCategory.optimal:
        return '🔥';
      case RecoveryCategory.good:
        return '💪';
      case RecoveryCategory.moderate:
        return '😐';
      case RecoveryCategory.low:
        return '😴';
      case RecoveryCategory.critical:
        return '🛌';
    }
  }

  /// Number of filled dots (out of 5)
  int get filledDots {
    switch (this) {
      case RecoveryCategory.optimal:
        return 5;
      case RecoveryCategory.good:
        return 4;
      case RecoveryCategory.moderate:
        return 3;
      case RecoveryCategory.low:
        return 2;
      case RecoveryCategory.critical:
        return 1;
    }
  }
}

/// Complete recovery insight data
@freezed
class RecoveryInsight with _$RecoveryInsight {
  const factory RecoveryInsight({
    /// Recovery score (0-100)
    required int score,

    /// Category derived from score
    required RecoveryCategory category,

    /// Localized recommendation text
    required String recommendation,

    /// Last night's sleep duration
    required Duration lastNightSleep,

    /// Average sleep over last 7 days (in hours)
    required double weeklyAverageHours,

    /// Consecutive nights with <6h sleep
    required int consecutiveBadNights,

    /// Days in a row meeting sleep goal
    required int streakDays,

    /// Sleep-workout correlation data (Pro only)
    SleepWorkoutCorrelation? correlation,

    /// Timestamp when calculated
    @Default(null) DateTime? calculatedAt,

    /// Whether sleep data is available
    @Default(true) bool hasSleepData,
  }) = _RecoveryInsight;

  const RecoveryInsight._();

  factory RecoveryInsight.fromJson(Map<String, dynamic> json) =>
      _$RecoveryInsightFromJson(json);

  /// Create a placeholder when no sleep data available
  factory RecoveryInsight.noData() {
    return const RecoveryInsight(
      score: 75, // Default to "good" when no data
      category: RecoveryCategory.good,
      recommendation: 'Connetti Apple Health per insight personalizzati',
      lastNightSleep: Duration.zero,
      weeklyAverageHours: 0,
      consecutiveBadNights: 0,
      streakDays: 0,
      hasSleepData: false,
    );
  }

  /// Formatted last night sleep (e.g., "7h 32m")
  String get formattedLastNight {
    if (!hasSleepData || lastNightSleep == Duration.zero) {
      return '--';
    }
    final hours = lastNightSleep.inHours;
    final minutes = lastNightSleep.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Formatted weekly average (e.g., "7.2h")
  String get formattedWeeklyAverage {
    if (!hasSleepData || weeklyAverageHours == 0) {
      return '--';
    }
    return '${weeklyAverageHours.toStringAsFixed(1)}h';
  }

  /// Whether user is in a "bad sleep" state
  bool get isInBadSleepState => consecutiveBadNights >= 2;

  /// Whether score indicates readiness for training
  bool get isReadyForTraining => score >= 55;

  /// Whether rest is strongly recommended
  bool get shouldRest => score < 40;
}
