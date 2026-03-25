/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/entities
/// Feature: analytics
/// Type: entity
///
/// ExerciseAnalyticsData Entity - Comprehensive analytics for a single exercise
///
/// **Contains**:
/// - Weight history with RPE
/// - Volume history
/// - Trend analysis
/// - Progressive overload metrics
/// - Intensity analysis (1RM estimation)
/// - Correlation results (Weight vs RPE, Volume vs RPE)
///
/// **Note**: This entity is computed/cached in providers, NOT persisted to Firestore.
/// Therefore, no JSON serialization is needed.
///
/// **Usage**:
/// ```dart
/// final analytics = await ref.watch(
///   exerciseAnalyticsProvider(
///     (exerciseName: exerciseName, exerciseId: exerciseId),
///   ).future,
/// );
/// print(analytics.trend.type);  // TrendType.improving
/// print(analytics.correlations.weightRpe.rSquared);  // 0.72
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/scientific_metrics_service.dart';

part 'exercise_analytics_data.freezed.dart';

/// Single data point for charts
@freezed
abstract class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    /// Date of the data point
    required DateTime date,

    /// Primary value (weight, volume, etc.)
    required double value,

    /// Optional RPE for this data point
    int? rpe,

    /// Optional reps count
    int? reps,

    /// Optional session index (1, 2, 3...)
    int? sessionIndex,
  }) = _ChartDataPoint;

  const ChartDataPoint._();
}

/// Status of progressive overload
enum OverloadStatus {
  /// Within optimal range for user's level
  optimal,

  /// Below minimum progression rate
  belowTarget,

  /// Above maximum (risk of overtraining)
  aboveTarget,

  /// No previous data to compare
  noBaseline,
}

/// Progressive overload analysis result
@freezed
abstract class ProgressiveOverloadData with _$ProgressiveOverloadData {
  const factory ProgressiveOverloadData({
    /// Current weekly progression percentage
    required double currentPercent,

    /// Target min-max range for user's level
    required double targetMin,
    required double targetMax,

    /// Status classification
    required OverloadStatus status,

    /// User's experience level used for calculation
    required String userLevel,

    /// Current volume
    required double currentVolume,

    /// Previous volume (for comparison)
    required double previousVolume,
  }) = _ProgressiveOverloadData;

  const ProgressiveOverloadData._();

  /// Factory for no baseline data
  factory ProgressiveOverloadData.noBaseline() => const ProgressiveOverloadData(
    currentPercent: 0,
    targetMin: 0,
    targetMax: 0,
    status: OverloadStatus.noBaseline,
    userLevel: 'unknown',
    currentVolume: 0,
    previousVolume: 0,
  );

  /// Check if progressing optimally
  bool get isOptimal => status == OverloadStatus.optimal;
}

/// Intensity analysis (1RM estimation)
@freezed
abstract class IntensityData with _$IntensityData {
  const factory IntensityData({
    /// Estimated 1RM in kg
    required double estimated1RM,

    /// Current working weight
    required double currentWeight,

    /// Current reps performed
    required int currentReps,

    /// Percentage of 1RM being used
    required double percentOf1RM,

    /// Formula used (Epley, Brzycki, or Epley+Brzycki)
    required String formula,

    /// Confidence level (High, Medium, Low)
    required String confidence,

    /// Intensity zone
    required IntensityZone zone,
  }) = _IntensityData;

  const IntensityData._();

  /// Factory for no data
  factory IntensityData.empty() => const IntensityData(
    estimated1RM: 0,
    currentWeight: 0,
    currentReps: 0,
    percentOf1RM: 0,
    formula: 'None',
    confidence: 'No data',
    zone: IntensityZone.endurance,
  );
}

/// Main analytics data container
@freezed
abstract class ExerciseAnalyticsData with _$ExerciseAnalyticsData {
  const factory ExerciseAnalyticsData({
    /// Exercise identifier
    required String exerciseId,

    /// Exercise name for display
    required String exerciseName,

    /// Weight progression data points (for L1 chart)
    required List<ChartDataPoint> weightHistory,

    /// Volume progression data points
    required List<ChartDataPoint> volumeHistory,

    /// RPE history (separate for correlations)
    required List<ChartDataPoint> rpeHistory,

    /// Trend analysis result
    required TrendAnalysis trend,

    /// Progressive overload analysis
    required ProgressiveOverloadData overload,

    /// Intensity/1RM analysis
    required IntensityData intensity,

    /// Correlation results (cached - not recalculated on each access)
    required CorrelationResults correlations,

    /// Last updated timestamp
    required DateTime lastUpdated,

    /// Number of sessions analyzed
    @Default(0) int sessionCount,

    /// Time span of data (in days)
    @Default(0) int dataSpanDays,
  }) = _ExerciseAnalyticsData;

  const ExerciseAnalyticsData._();

  /// Check if we have enough data for correlation analysis
  bool get hasEnoughDataForCorrelations => sessionCount >= 3;

  /// Check if we have any data at all
  bool get hasData => sessionCount > 0;

  /// Get the most recent weight
  double? get latestWeight =>
      weightHistory.isNotEmpty ? weightHistory.last.value : null;

  /// Get the most recent RPE
  int? get latestRpe => rpeHistory.isNotEmpty ? rpeHistory.last.rpe : null;
}
