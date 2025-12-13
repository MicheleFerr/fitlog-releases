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
abstract class SleepWorkoutCorrelation with _$SleepWorkoutCorrelation {
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

  /// Message KEY explaining the correlation
  ///
  /// Returns a key that should be localized in presentation layer.
  /// Keys: 'not_enough_data', 'not_significant', 'significant'
  /// For 'significant': includes effect directions as additional info
  String get summaryMessageKey {
    if (!hasEnoughData) {
      return 'not_enough_data';
    }

    if (!isSignificant) {
      return 'not_significant';
    }

    // Return key with params: good_effect:increase|decrease,poor_effect:increase|decrease,good_change:X%,poor_change:Y%
    final goodEffect = volumeChangeAbove7h > 0 ? 'increase' : 'decrease';
    final poorEffect = volumeChangeBelow6h < 0 ? 'decrease' : 'increase';
    final goodChange = formattedGoodSleepChange.replaceAll('+', '').replaceAll('-', '');
    final poorChange = formattedPoorSleepChange.replaceAll('+', '').replaceAll('-', '');

    return 'significant:$goodEffect:$poorEffect:$goodChange:$poorChange';
  }
}

/// Individual data point for correlation analysis
@freezed
abstract class SleepWorkoutDataPoint with _$SleepWorkoutDataPoint {
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
