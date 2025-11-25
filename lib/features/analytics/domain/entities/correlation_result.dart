/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/entities
/// Feature: analytics
/// Type: entity
///
/// CorrelationResult Entity - Pearson correlation between two metrics
///
/// **Scientific Basis**:
/// - Pearson's r measures linear relationship (-1 to +1)
/// - r² (coefficient of determination) shows variance explained (0 to 1)
///
/// **Usage**:
/// ```dart
/// final correlation = CorrelationResult(
///   r: 0.85,
///   rSquared: 0.72,
///   strength: CorrelationStrength.strong,
///   interpretation: 'Higher RPE correlates with better weight progress',
/// );
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'correlation_result.freezed.dart';
part 'correlation_result.g.dart';

/// Strength classification for correlations
enum CorrelationStrength {
  /// r² >= 0.7 - Strong relationship
  strong,

  /// r² 0.4-0.69 - Moderate relationship
  moderate,

  /// r² < 0.4 - Weak or no relationship
  weak,

  /// Not enough data points (< 3)
  insufficient,
}

@freezed
class CorrelationResult with _$CorrelationResult {
  const factory CorrelationResult({
    /// Pearson correlation coefficient (-1 to +1)
    /// - +1: Perfect positive correlation
    /// - 0: No correlation
    /// - -1: Perfect negative correlation
    required double r,

    /// Coefficient of determination (0 to 1)
    /// - Shows how much variance in Y is explained by X
    /// - 0.72 means 72% of variance explained
    required double rSquared,

    /// Strength classification
    required CorrelationStrength strength,

    /// Human-readable interpretation
    required String interpretation,

    /// Number of data points used
    @Default(0) int dataPoints,

    /// Whether the result is statistically significant
    @Default(false) bool isSignificant,
  }) = _CorrelationResult;

  const CorrelationResult._();

  factory CorrelationResult.fromJson(Map<String, dynamic> json) =>
      _$CorrelationResultFromJson(json);

  /// Factory for insufficient data
  factory CorrelationResult.insufficient() => const CorrelationResult(
        r: 0,
        rSquared: 0,
        strength: CorrelationStrength.insufficient,
        interpretation: 'Need 3+ data points for correlation analysis',
        dataPoints: 0,
        isSignificant: false,
      );

  /// Check if correlation is positive
  bool get isPositive => r > 0;

  /// Check if correlation is negative
  bool get isNegative => r < 0;

  /// Get absolute strength (ignoring direction)
  double get absoluteStrength => r.abs();
}

/// Results container for all metric correlations
@freezed
class CorrelationResults with _$CorrelationResults {
  const factory CorrelationResults({
    /// Weight vs RPE correlation
    required CorrelationResult weightRpe,

    /// Volume vs RPE correlation
    required CorrelationResult volumeRpe,

    /// Weight vs Volume correlation (optional)
    CorrelationResult? weightVolume,
  }) = _CorrelationResults;

  const CorrelationResults._();

  factory CorrelationResults.fromJson(Map<String, dynamic> json) =>
      _$CorrelationResultsFromJson(json);

  /// Factory for empty/insufficient data
  factory CorrelationResults.empty() => CorrelationResults(
        weightRpe: CorrelationResult.insufficient(),
        volumeRpe: CorrelationResult.insufficient(),
      );

  /// Check if any correlation is significant
  bool get hasSignificantCorrelations =>
      weightRpe.isSignificant || volumeRpe.isSignificant;
}
