/// Stress Index Result Entity
///
/// Represents the calculated stress index for a completed workout.
/// Uses dual calculation approach (RPE-based + weight-only fallback).
///
/// **Scale**: Logarithmic 0-100 (like WHOOP)
/// - 0-30: Light session
/// - 30-60: Moderate session
/// - 60-80: Hard session
/// - 80-100: Very hard session
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';

part 'stress_index_result.freezed.dart';
part 'stress_index_result.g.dart';

@freezed
abstract class StressIndexResult with _$StressIndexResult {
  const factory StressIndexResult({
    /// Primary stress score (0-100, logarithmic)
    /// Based on RPE when available
    required double primaryScore,

    /// Fallback score (weight-only calculation)
    /// Used when RPE data is incomplete
    required double fallbackScore,

    /// Confidence level (0.0 - 1.0)
    /// Percentage of sets with RPE data
    required double confidence,

    /// Breakdown by muscle group
    required Map<String, MuscleStressData> muscleBreakdown,

    /// Total sets analyzed
    required int totalSets,

    /// Sets with RPE data
    required int setsWithRpe,

    /// Workout ID this belongs to
    required String workoutId,

    /// Calculation timestamp
    required DateTime calculatedAt,

    /// Raw score before logarithmic conversion
    required double rawScore,
  }) = _StressIndexResult;

  const StressIndexResult._();

  factory StressIndexResult.fromJson(Map<String, dynamic> json) =>
      _$StressIndexResultFromJson(json);

  /// Get the display score based on confidence
  ///
  /// Returns primary score if confidence >= 50%, otherwise fallback
  double get displayScore => confidence >= 0.5 ? primaryScore : fallbackScore;

  /// Check if confidence is high (>= 80%)
  bool get isHighConfidence => confidence >= 0.80;

  /// Check if confidence is medium (50-79%)
  bool get isMediumConfidence => confidence >= 0.50 && confidence < 0.80;

  /// Check if confidence is low (< 50%)
  bool get isLowConfidence => confidence < 0.50;

  /// Get stress level category
  StressLevel get stressLevel {
    final score = displayScore;
    if (score < 30) return StressLevel.light;
    if (score < 60) return StressLevel.moderate;
    if (score < 80) return StressLevel.hard;
    return StressLevel.veryHard;
  }

  /// Get confidence range for display
  /// E.g., "72-84" when confidence affects the estimate
  String get scoreRange {
    if (isHighConfidence) {
      return displayScore.toStringAsFixed(0);
    }

    final lower = (displayScore * 0.9).round();
    final upper = (displayScore * 1.1).round().clamp(0, 100);
    return '$lower-$upper';
  }
}

/// Stress level categories
enum StressLevel { light, moderate, hard, veryHard }
