/// Template Stress Analysis Entity
///
/// Contains the analysis of a workout template against current muscle recovery.
/// Used to recommend which template to do today.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';

part 'template_stress_analysis.freezed.dart';
part 'template_stress_analysis.g.dart';

@freezed
abstract class TemplateStressAnalysis with _$TemplateStressAnalysis {
  const factory TemplateStressAnalysis({
    /// Template ID
    required String templateId,

    /// Template name for display
    required String templateName,

    /// Template icon (if set)
    String? templateIcon,

    /// Stress this template would add (0-100)
    required double expectedStress,

    /// Current stress level before workout
    required double currentStress,

    /// Resulting total stress after workout (current + expected)
    required double resultingTotalStress,

    /// Readiness data for each muscle involved
    required Map<String, MuscleReadinessData> muscleReadiness,

    /// Primary muscles targeted by this template
    required List<String> primaryMuscles,

    /// Secondary muscles targeted by this template
    required List<String> secondaryMuscles,

    /// Under-recovered muscles that would be stressed
    required List<String> underRecoveredMuscles,

    /// Fatigued muscles (should avoid)
    required List<String> fatiguedMuscles,

    /// Overall recommendation
    required TemplateRecommendation recommendation,

    /// Human-readable rationale
    required String rationale,

    /// Optimality score (0-100) - higher is better
    required double optimalityScore,

    // === FACTORS THAT INFLUENCED THE RECOMMENDATION ===

    /// Whether sleep data was considered
    @Default(false) bool sleepDataUsed,

    /// Whether HRV data was considered
    @Default(false) bool hrvDataUsed,

    /// Sleep hours if available
    double? sleepHoursLastNight,

    /// HRV if available (ms)
    double? hrvMs,
  }) = _TemplateStressAnalysis;

  const TemplateStressAnalysis._();

  factory TemplateStressAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TemplateStressAnalysisFromJson(json);

  /// Average recovery percentage across all muscles
  double get averageMuscleRecovery {
    if (muscleReadiness.isEmpty) return 100.0;
    final sum = muscleReadiness.values
        .map((m) => m.recoveryPercent)
        .fold(0.0, (a, b) => a + b);
    return sum / muscleReadiness.length;
  }

  /// Lowest recovery percentage (weakest link)
  double get lowestMuscleRecovery {
    if (muscleReadiness.isEmpty) return 100.0;
    return muscleReadiness.values
        .map((m) => m.recoveryPercent)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Number of muscles fully ready (>90%)
  int get musclesReadyCount =>
      muscleReadiness.values.where((m) => m.isReady).length;

  /// Number of muscles needing caution (<70%)
  int get musclesNeedCautionCount => muscleReadiness.values
      .where((m) => m.shouldAvoid || m.isSuboptimal)
      .length;

  /// Whether this template is safe to do
  bool get isSafe => recommendation != TemplateRecommendation.avoid;

  /// Whether this template is optimal
  bool get isOptimal => recommendation == TemplateRecommendation.optimal;

  /// Whether this is the best choice for today
  bool get isRecommended =>
      recommendation == TemplateRecommendation.optimal ||
      recommendation == TemplateRecommendation.acceptable;

  /// Color hint for UI (green, yellow, orange, red)
  String get colorHint {
    switch (recommendation) {
      case TemplateRecommendation.optimal:
        return 'green';
      case TemplateRecommendation.acceptable:
        return 'yellow';
      case TemplateRecommendation.suboptimal:
        return 'orange';
      case TemplateRecommendation.avoid:
        return 'red';
    }
  }

  /// Icon hint for UI
  String get iconHint {
    switch (recommendation) {
      case TemplateRecommendation.optimal:
        return '✓';
      case TemplateRecommendation.acceptable:
        return '~';
      case TemplateRecommendation.suboptimal:
        return '!';
      case TemplateRecommendation.avoid:
        return '✗';
    }
  }
}

/// Template recommendation levels
enum TemplateRecommendation {
  /// All muscles >90% recovered - Best choice for today
  optimal,

  /// Most muscles 70-90% - Doable but not ideal
  acceptable,

  /// Key muscles <70% - Risk of accumulated fatigue
  suboptimal,

  /// Critical muscles <50% - Avoid this template today
  avoid,
}
