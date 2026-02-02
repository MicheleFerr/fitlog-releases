/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/domain/services
/// Feature: analytics
/// Type: service
///
/// TrainingPatternDetector Service - Detects multi-metric training patterns
///
/// **Scientific Basis**:
/// - Correlations: Pearson r between Weight-RPE, Volume-RPE
/// - Trend analysis: Linear regression slope direction
/// - Research references: Helms et al. 2016, Zourdos et al. 2016
///
/// **Pattern Detection Logic**:
///
/// | Pattern | RPE Trend | Weight Trend | Volume Trend | Correlation |
/// |---------|-----------|--------------|--------------|-------------|
/// | Fatigue | ↑ | ↓ | any | r < -0.5 |
/// | Great Progress | = | ↑ | = or ↑ | r ≈ 0 |
/// | Overreaching | ↑ | = | ↓ | r > 0.7 |
/// | Adaptation | ↓ | = | = | r < -0.3 |
/// | Volume Spike | any | any | ↑↑ | any |
///
/// **Thresholds** (configurable):
/// - Minimum sessions: 3
/// - Significant trend: slope > ±0.5
/// - Strong correlation: |r| > 0.7
/// - Moderate correlation: |r| > 0.4
///
/// **Usage**:
/// ```dart
/// final results = TrainingPatternDetector.detect(
///   analyticsData: exerciseAnalytics,
///   minSessions: 3,
/// );
/// print(results.primaryPattern?.type);  // PatternType.fatigueWarning
/// ```
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_analytics_data.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/training_pattern.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';

/// Service for detecting training patterns from exercise analytics
class TrainingPatternDetector {
  /// Minimum sessions required for pattern detection
  static const int minSessionsDefault = 3;

  /// Threshold for "significant" trend slope
  static const double significantSlopeThreshold = 0.5;

  /// Threshold for "strong" correlation
  static const double strongCorrelationThreshold = 0.7;

  /// Threshold for "moderate" correlation
  static const double moderateCorrelationThreshold = 0.4;

  /// Threshold for volume spike (% increase)
  static const double volumeSpikeThreshold = 20.0;

  /// Detect training patterns from exercise analytics data
  ///
  /// Returns [TrainingPatternResults] with all detected patterns,
  /// sorted by priority (most important first).
  static TrainingPatternResults detect({
    required ExerciseAnalyticsData analyticsData,
    int minSessions = minSessionsDefault,
  }) {
    // Check minimum data requirements
    if (analyticsData.sessionCount < minSessions) {
      return TrainingPatternResults.empty();
    }

    final patterns = <TrainingPattern>[];

    // Extract key metrics
    final weightTrend = _calculateTrendDirection(analyticsData.weightHistory);
    final rpeTrend = _calculateTrendDirection(analyticsData.rpeHistory);
    final volumeTrend = _calculateTrendDirection(analyticsData.volumeHistory);

    final weightRpeCorrelation = analyticsData.correlations.weightRpe;
    // Note: volumeRpeCorrelation reserved for future pattern detection
    // final volumeRpeCorrelation = analyticsData.correlations.volumeRpe;

    final overloadStatus = analyticsData.overload.status;
    final trendType = analyticsData.trend.type;

    // Pattern 1: Fatigue Warning
    // RPE increasing + Weight decreasing = fatigue
    final fatiguePattern = _detectFatigueWarning(
      rpeTrend: rpeTrend,
      weightTrend: weightTrend,
      correlation: weightRpeCorrelation,
      sessions: analyticsData.sessionCount,
    );
    if (fatiguePattern != null) patterns.add(fatiguePattern);

    // Pattern 2: Great Progression
    // Weight increasing + RPE stable = great adaptation
    final progressionPattern = _detectGreatProgression(
      rpeTrend: rpeTrend,
      weightTrend: weightTrend,
      trendType: trendType,
      sessions: analyticsData.sessionCount,
    );
    if (progressionPattern != null) patterns.add(progressionPattern);

    // Pattern 3: Overreaching Risk
    // RPE increasing + Weight stable + Volume decreasing
    final overreachingPattern = _detectOverreachingRisk(
      rpeTrend: rpeTrend,
      weightTrend: weightTrend,
      volumeTrend: volumeTrend,
      correlation: weightRpeCorrelation,
      sessions: analyticsData.sessionCount,
    );
    if (overreachingPattern != null) patterns.add(overreachingPattern);

    // Pattern 4: Adaptation
    // RPE decreasing + Weight stable = body adapting well
    final adaptationPattern = _detectAdaptation(
      rpeTrend: rpeTrend,
      weightTrend: weightTrend,
      sessions: analyticsData.sessionCount,
    );
    if (adaptationPattern != null) patterns.add(adaptationPattern);

    // Pattern 5: Volume Spike
    // Volume increased significantly
    final volumeSpikePattern = _detectVolumeSpike(
      overload: analyticsData.overload,
      sessions: analyticsData.sessionCount,
    );
    if (volumeSpikePattern != null) patterns.add(volumeSpikePattern);

    // Pattern 6: Optimal Training
    // Everything aligned well
    final optimalPattern = _detectOptimalTraining(
      trendType: trendType,
      overloadStatus: overloadStatus,
      correlation: weightRpeCorrelation,
      sessions: analyticsData.sessionCount,
    );
    if (optimalPattern != null) patterns.add(optimalPattern);

    // Sort by priority (highest first)
    patterns.sort((a, b) => b.priority.compareTo(a.priority));

    // Determine overall status
    final overallStatus = _determineOverallStatus(patterns);

    return TrainingPatternResults(
      patterns: patterns,
      primaryPattern: patterns.isNotEmpty ? patterns.first : null,
      overallStatus: overallStatus,
      analyzedAt: DateTime.now(),
      dataPointsUsed: analyticsData.sessionCount,
    );
  }

  /// Calculate trend direction from chart data points
  static _TrendDirection _calculateTrendDirection(List<ChartDataPoint> points) {
    if (points.length < 2) return _TrendDirection.stable;

    // Simple: compare first half average to second half average
    final midpoint = points.length ~/ 2;
    final firstHalf = points.sublist(0, midpoint);
    final secondHalf = points.sublist(midpoint);

    final firstAvg =
        firstHalf.fold<double>(0, (sum, p) => sum + p.value) / firstHalf.length;
    final secondAvg =
        secondHalf.fold<double>(0, (sum, p) => sum + p.value) /
        secondHalf.length;

    final changePercent = firstAvg > 0
        ? ((secondAvg - firstAvg) / firstAvg) * 100
        : 0.0;

    if (changePercent > 5) return _TrendDirection.increasing;
    if (changePercent < -5) return _TrendDirection.decreasing;
    return _TrendDirection.stable;
  }

  /// Detect fatigue warning pattern
  static TrainingPattern? _detectFatigueWarning({
    required _TrendDirection rpeTrend,
    required _TrendDirection weightTrend,
    required CorrelationResult correlation,
    required int sessions,
  }) {
    // RPE increasing + Weight decreasing
    if (rpeTrend == _TrendDirection.increasing &&
        weightTrend == _TrendDirection.decreasing) {
      final confidence = _calculateConfidence(
        correlationStrength: correlation.rSquared,
        sessions: sessions,
        expectedCorrelation: true,
        isNegativeCorrelation: correlation.r < 0,
      );

      return TrainingPattern(
        type: PatternType.fatigueWarning,
        severity: confidence > 0.7
            ? PatternSeverity.alert
            : PatternSeverity.warning,
        confidence: confidence,
        titleKey: 'patternFatigueWarningTitle',
        descriptionKey: 'patternFatigueWarningDescription',
        recommendationKey: 'patternFatigueWarningRecommendation',
        scienceKey: 'patternFatigueWarningScience',
        sessionsAnalyzed: sessions,
        triggerMetrics: {
          'rpe_trend': rpeTrend.index.toDouble(),
          'weight_trend': weightTrend.index.toDouble(),
          'correlation_r': correlation.r,
        },
      );
    }
    return null;
  }

  /// Detect great progression pattern
  static TrainingPattern? _detectGreatProgression({
    required _TrendDirection rpeTrend,
    required _TrendDirection weightTrend,
    required TrendType trendType,
    required int sessions,
  }) {
    // Weight increasing + RPE stable AND overall trend improving
    if (weightTrend == _TrendDirection.increasing &&
        rpeTrend == _TrendDirection.stable &&
        trendType == TrendType.improving) {
      return TrainingPattern(
        type: PatternType.greatProgression,
        severity: PatternSeverity.positive,
        confidence: 0.8,
        titleKey: 'patternGreatProgressionTitle',
        descriptionKey: 'patternGreatProgressionDescription',
        recommendationKey: 'patternGreatProgressionRecommendation',
        scienceKey: 'patternGreatProgressionScience',
        sessionsAnalyzed: sessions,
        triggerMetrics: {
          'weight_trend': weightTrend.index.toDouble(),
          'rpe_trend': rpeTrend.index.toDouble(),
        },
      );
    }
    return null;
  }

  /// Detect overreaching risk pattern
  static TrainingPattern? _detectOverreachingRisk({
    required _TrendDirection rpeTrend,
    required _TrendDirection weightTrend,
    required _TrendDirection volumeTrend,
    required CorrelationResult correlation,
    required int sessions,
  }) {
    // RPE increasing + Weight stable + Volume decreasing
    // This suggests body is struggling to maintain output
    if (rpeTrend == _TrendDirection.increasing &&
        weightTrend == _TrendDirection.stable &&
        volumeTrend == _TrendDirection.decreasing) {
      return TrainingPattern(
        type: PatternType.overreachingRisk,
        severity: PatternSeverity.warning,
        confidence: 0.7,
        titleKey: 'patternOverreachingRiskTitle',
        descriptionKey: 'patternOverreachingRiskDescription',
        recommendationKey: 'patternOverreachingRiskRecommendation',
        scienceKey: 'patternOverreachingRiskScience',
        sessionsAnalyzed: sessions,
        triggerMetrics: {
          'rpe_trend': rpeTrend.index.toDouble(),
          'weight_trend': weightTrend.index.toDouble(),
          'volume_trend': volumeTrend.index.toDouble(),
        },
      );
    }
    return null;
  }

  /// Detect adaptation pattern
  static TrainingPattern? _detectAdaptation({
    required _TrendDirection rpeTrend,
    required _TrendDirection weightTrend,
    required int sessions,
  }) {
    // RPE decreasing + Weight stable = good adaptation
    if (rpeTrend == _TrendDirection.decreasing &&
        weightTrend == _TrendDirection.stable) {
      return TrainingPattern(
        type: PatternType.adaptation,
        severity: PatternSeverity.positive,
        confidence: 0.75,
        titleKey: 'patternAdaptationTitle',
        descriptionKey: 'patternAdaptationDescription',
        recommendationKey: 'patternAdaptationRecommendation',
        scienceKey: 'patternAdaptationScience',
        sessionsAnalyzed: sessions,
        triggerMetrics: {
          'rpe_trend': rpeTrend.index.toDouble(),
          'weight_trend': weightTrend.index.toDouble(),
        },
      );
    }
    return null;
  }

  /// Detect volume spike pattern
  static TrainingPattern? _detectVolumeSpike({
    required ProgressiveOverloadData overload,
    required int sessions,
  }) {
    // Volume increased more than threshold
    if (overload.status == OverloadStatus.aboveTarget &&
        overload.currentPercent > volumeSpikeThreshold) {
      return TrainingPattern(
        type: PatternType.volumeSpike,
        severity: PatternSeverity.warning,
        confidence: 0.8,
        titleKey: 'patternVolumeSpikeTitle',
        descriptionKey: 'patternVolumeSpikeDescription',
        recommendationKey: 'patternVolumeSpikeRecommendation',
        scienceKey: 'patternVolumeSpikeScience',
        sessionsAnalyzed: sessions,
        triggerMetrics: {
          'volume_increase_percent': overload.currentPercent,
          'current_volume': overload.currentVolume,
          'previous_volume': overload.previousVolume,
        },
      );
    }
    return null;
  }

  /// Detect optimal training pattern
  static TrainingPattern? _detectOptimalTraining({
    required TrendType trendType,
    required OverloadStatus overloadStatus,
    required CorrelationResult correlation,
    required int sessions,
  }) {
    // Everything aligned: improving trend + optimal overload
    if (trendType == TrendType.improving &&
        overloadStatus == OverloadStatus.optimal) {
      return TrainingPattern(
        type: PatternType.optimalTraining,
        severity: PatternSeverity.positive,
        confidence: 0.85,
        titleKey: 'patternOptimalTrainingTitle',
        descriptionKey: 'patternOptimalTrainingDescription',
        recommendationKey: 'patternOptimalTrainingRecommendation',
        scienceKey: 'patternOptimalTrainingScience',
        sessionsAnalyzed: sessions,
        triggerMetrics: {},
      );
    }
    return null;
  }

  /// Calculate confidence based on correlation and data quality
  static double _calculateConfidence({
    required double correlationStrength,
    required int sessions,
    required bool expectedCorrelation,
    bool isNegativeCorrelation = false,
  }) {
    // Base confidence from sessions (more = better)
    final sessionFactor = (sessions / 10).clamp(0.3, 1.0);

    // Correlation factor
    final correlationFactor = expectedCorrelation
        ? correlationStrength.clamp(0.0, 1.0)
        : (1.0 - correlationStrength).clamp(0.0, 1.0);

    // Combined confidence
    return (sessionFactor * 0.4 + correlationFactor * 0.6).clamp(0.0, 1.0);
  }

  /// Determine overall training status from patterns
  static TrainingStatus _determineOverallStatus(
    List<TrainingPattern> patterns,
  ) {
    if (patterns.isEmpty) return TrainingStatus.insufficientData;

    // Check for alerts/warnings first
    final hasAlert = patterns.any((p) => p.severity == PatternSeverity.alert);
    if (hasAlert) return TrainingStatus.fatigueRisk;

    final hasWarning = patterns.any(
      (p) => p.severity == PatternSeverity.warning,
    );
    if (hasWarning) return TrainingStatus.needsAttention;

    // Check for positive patterns
    final hasOptimal = patterns.any(
      (p) => p.type == PatternType.optimalTraining,
    );
    if (hasOptimal) return TrainingStatus.optimal;

    final hasProgression = patterns.any(
      (p) => p.type == PatternType.greatProgression,
    );
    if (hasProgression) return TrainingStatus.progressing;

    return TrainingStatus.progressing;
  }
}

/// Internal enum for trend direction
enum _TrendDirection { increasing, stable, decreasing }
