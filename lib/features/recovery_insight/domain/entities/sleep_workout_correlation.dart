/// Sleep-Workout Correlation Entity
///
/// Analyzes correlation between sleep patterns and workout performance.
///
/// **Pro Feature**: Shows how sleep affects training volume/intensity.
///
/// **Scientific Basis**:
/// - Res et al.: -22% MPS with sleep deprivation
/// - Skein et al. 2011: Cumulative performance decline with sleep restriction
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_workout_correlation.freezed.dart';
part 'sleep_workout_correlation.g.dart';

/// Correlation between sleep and workout performance
@freezed
class SleepWorkoutCorrelation with _$SleepWorkoutCorrelation {
  const factory SleepWorkoutCorrelation({
    /// Volume change when sleeping >7h (e.g., +8%)
    required double volumeChangeAbove7h,

    /// Volume change when sleeping <6h (e.g., -15%)
    required double volumeChangeBelow6h,

    /// Number of workout sessions analyzed
    required int workoutSampleSize,

    /// Number of nights with sleep data
    required int sleepSampleSize,

    /// Whether correlation is statistically significant
    /// (requires >10 data points in each category)
    required bool isSignificant,

    /// Period analyzed (in days)
    @Default(30) int periodDays,

    /// Workouts with >7h sleep the night before
    @Default(0) int workoutsWithGoodSleep,

    /// Workouts with <6h sleep the night before
    @Default(0) int workoutsWithPoorSleep,
  }) = _SleepWorkoutCorrelation;

  const SleepWorkoutCorrelation._();

  factory SleepWorkoutCorrelation.fromJson(Map<String, dynamic> json) =>
      _$SleepWorkoutCorrelationFromJson(json);

  /// Create empty correlation (not enough data)
  factory SleepWorkoutCorrelation.noData() {
    return const SleepWorkoutCorrelation(
      volumeChangeAbove7h: 0,
      volumeChangeBelow6h: 0,
      workoutSampleSize: 0,
      sleepSampleSize: 0,
      isSignificant: false,
    );
  }

  /// Format volume change as percentage string
  String formatVolumeChange(double change) {
    if (change > 0) {
      return '+${change.toStringAsFixed(0)}%';
    } else if (change < 0) {
      return '${change.toStringAsFixed(0)}%';
    } else {
      return '0%';
    }
  }

  /// Formatted volume change for >7h sleep
  String get formattedGoodSleepChange => formatVolumeChange(volumeChangeAbove7h);

  /// Formatted volume change for <6h sleep
  String get formattedPoorSleepChange => formatVolumeChange(volumeChangeBelow6h);

  /// Whether there's enough data to show correlation
  bool get hasEnoughData => workoutSampleSize >= 5 && sleepSampleSize >= 7;

  /// Message explaining the correlation
  String get summaryMessage {
    if (!hasEnoughData) {
      return 'Continua ad allenarti per vedere la correlazione sonno-performance.';
    }

    if (!isSignificant) {
      return 'Non abbastanza dati per una correlazione significativa.';
    }

    final goodEffect = volumeChangeAbove7h > 0 ? 'aumenta' : 'diminuisce';
    final poorEffect = volumeChangeBelow6h < 0 ? 'diminuisce' : 'aumenta';

    return 'Il tuo volume $goodEffect del ${formattedGoodSleepChange.replaceAll('+', '')} '
        'con >7h di sonno e $poorEffect del ${formattedPoorSleepChange.replaceAll('-', '')} '
        'con <6h.';
  }
}

/// Individual data point for correlation analysis
@freezed
class SleepWorkoutDataPoint with _$SleepWorkoutDataPoint {
  const factory SleepWorkoutDataPoint({
    /// Date of the workout
    required DateTime workoutDate,

    /// Sleep hours the night before
    required double sleepHours,

    /// Total workout volume (sets × reps × weight)
    required double workoutVolume,

    /// Workout duration in minutes
    required int workoutDurationMinutes,

    /// Number of exercises
    required int exerciseCount,

    /// Average RPE if available
    double? averageRpe,
  }) = _SleepWorkoutDataPoint;

  const SleepWorkoutDataPoint._();

  factory SleepWorkoutDataPoint.fromJson(Map<String, dynamic> json) =>
      _$SleepWorkoutDataPointFromJson(json);

  /// Sleep quality category
  String get sleepCategory {
    if (sleepHours < 6) return 'poor';
    if (sleepHours < 7) return 'moderate';
    return 'good';
  }
}
