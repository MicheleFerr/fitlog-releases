/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/entities
/// Feature: analytics
/// Type: entity
///
/// TrainingPattern Entity - Detected multi-metric training patterns
///
/// **Scientific Basis**:
/// - Pearson correlation analysis between RPE, Weight, Volume
/// - Research-backed thresholds for fatigue/progression detection
/// - References: Helms et al. 2016, Zourdos et al. 2016
///
/// **Patterns Detected**:
/// - Fatigue Warning: RPE ↑ + Weight ↓ (same effort, less output)
/// - Great Progression: Weight ↑ + RPE = (more weight, same effort)
/// - Overreaching Risk: RPE ↑ + Weight = + Volume ↓
/// - Adaptation: RPE ↓ + Weight = (easier at same weight)
///
/// **Usage**:
/// ```dart
/// final patterns = TrainingPatternDetector.detect(analyticsData);
/// for (final pattern in patterns) {
///   print(pattern.type);  // PatternType.fatigueWarning
///   print(pattern.severity);  // PatternSeverity.moderate
/// }
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_pattern.freezed.dart';

/// Types of training patterns that can be detected
enum PatternType {
  /// RPE increasing while weight decreasing - possible fatigue/overtraining
  fatigueWarning,

  /// Weight increasing while RPE stable - great adaptation
  greatProgression,

  /// RPE increasing with stable weight but decreasing volume - overreaching
  overreachingRisk,

  /// RPE decreasing at same weight - successful adaptation
  adaptation,

  /// Volume increasing significantly - possible overtraining risk
  volumeSpike,

  /// Consistent improvement across metrics - optimal training
  optimalTraining,

  /// Inconsistent patterns - need more data or technique focus
  inconsistent,
}

/// Severity levels for detected patterns
enum PatternSeverity {
  /// Informational - just an observation
  info,

  /// Positive - good progress indicator
  positive,

  /// Warning - something to monitor
  warning,

  /// Alert - action recommended
  alert,
}

/// Detected training pattern with context and recommendations
@freezed
abstract class TrainingPattern with _$TrainingPattern {
  const factory TrainingPattern({
    /// Type of pattern detected
    required PatternType type,

    /// Severity level
    required PatternSeverity severity,

    /// Confidence score (0.0 to 1.0)
    /// Based on correlation strength and data points
    required double confidence,

    /// Localization key for title
    required String titleKey,

    /// Localization key for description
    required String descriptionKey,

    /// Localization key for recommendation
    required String recommendationKey,

    /// Scientific explanation key (for expanded view)
    String? scienceKey,

    /// Number of sessions analyzed for this pattern
    @Default(0) int sessionsAnalyzed,

    /// Raw metrics that triggered this pattern
    @Default({}) Map<String, double> triggerMetrics,
  }) = _TrainingPattern;

  const TrainingPattern._();

  /// Get icon name for this pattern type
  String get iconName {
    switch (type) {
      case PatternType.fatigueWarning:
        return 'warningAmber';
      case PatternType.greatProgression:
        return 'trendingUp';
      case PatternType.overreachingRisk:
        return 'warningAmber';
      case PatternType.adaptation:
        return 'checkCircle';
      case PatternType.volumeSpike:
        return 'showChart';
      case PatternType.optimalTraining:
        return 'star';
      case PatternType.inconsistent:
        return 'helpOutline';
    }
  }

  /// Check if this is a warning/alert pattern
  bool get isWarning =>
      severity == PatternSeverity.warning || severity == PatternSeverity.alert;

  /// Check if this is a positive pattern
  bool get isPositive => severity == PatternSeverity.positive;

  /// Get display priority (higher = show first)
  int get priority {
    switch (severity) {
      case PatternSeverity.alert:
        return 4;
      case PatternSeverity.warning:
        return 3;
      case PatternSeverity.positive:
        return 2;
      case PatternSeverity.info:
        return 1;
    }
  }
}

/// Collection of detected patterns for an exercise
@freezed
abstract class TrainingPatternResults with _$TrainingPatternResults {
  const factory TrainingPatternResults({
    /// All detected patterns, sorted by priority
    required List<TrainingPattern> patterns,

    /// The most significant pattern (highest priority)
    TrainingPattern? primaryPattern,

    /// Overall training status summary
    required TrainingStatus overallStatus,

    /// Timestamp when patterns were analyzed
    required DateTime analyzedAt,

    /// Number of data points used
    @Default(0) int dataPointsUsed,
  }) = _TrainingPatternResults;

  const TrainingPatternResults._();

  /// Factory for empty/insufficient data
  factory TrainingPatternResults.empty() => TrainingPatternResults(
    patterns: const [],
    primaryPattern: null,
    overallStatus: TrainingStatus.insufficientData,
    analyzedAt: DateTime.now(),
    dataPointsUsed: 0,
  );

  /// Check if any patterns were detected
  bool get hasPatterns => patterns.isNotEmpty;

  /// Check if there are any warnings
  bool get hasWarnings => patterns.any((p) => p.isWarning);

  /// Get only warning patterns
  List<TrainingPattern> get warnings =>
      patterns.where((p) => p.isWarning).toList();

  /// Get only positive patterns
  List<TrainingPattern> get positivePatterns =>
      patterns.where((p) => p.isPositive).toList();
}

/// Overall training status
enum TrainingStatus {
  /// Everything looks good
  optimal,

  /// Progressing well
  progressing,

  /// Some concerns to monitor
  needsAttention,

  /// Potential overtraining/fatigue
  fatigueRisk,

  /// Not enough data to determine
  insufficientData,
}
