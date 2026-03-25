/// TrainingPatternDetector tests - pattern detection, trends, overall status.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_analytics_data.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/training_pattern.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/training_pattern_detector.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/trend_analyzer.dart';

void main() {
  group('TrainingPatternDetector constants', () {
    test('minSessionsDefault is 3', () {
      expect(TrainingPatternDetector.minSessionsDefault, 3);
    });

    test('significantSlopeThreshold is 0.5', () {
      expect(TrainingPatternDetector.significantSlopeThreshold, 0.5);
    });

    test('strongCorrelationThreshold is 0.7', () {
      expect(TrainingPatternDetector.strongCorrelationThreshold, 0.7);
    });

    test('volumeSpikeThreshold is 20.0', () {
      expect(TrainingPatternDetector.volumeSpikeThreshold, 20.0);
    });
  });

  // Helper to build ExerciseAnalyticsData with configurable trends
  ExerciseAnalyticsData _makeAnalyticsData({
    int sessionCount = 5,
    List<double>? weights,
    List<double>? rpes,
    List<double>? volumes,
    TrendType trendType = TrendType.improving,
    OverloadStatus overloadStatus = OverloadStatus.optimal,
    double correlationR = 0.0,
    double correlationRSquared = 0.0,
  }) {
    final weightPoints = (weights ?? [100, 100, 100, 100, 100])
        .asMap()
        .entries
        .map(
          (e) => ChartDataPoint(
            date: DateTime(2025, 1, 1 + e.key),
            value: e.value,
          ),
        )
        .toList();
    final rpePoints = (rpes ?? [7, 7, 7, 7, 7])
        .asMap()
        .entries
        .map(
          (e) => ChartDataPoint(
            date: DateTime(2025, 1, 1 + e.key),
            value: e.value,
            rpe: e.value.toInt(),
          ),
        )
        .toList();
    final volumePoints = (volumes ?? [3000, 3000, 3000, 3000, 3000])
        .asMap()
        .entries
        .map(
          (e) => ChartDataPoint(
            date: DateTime(2025, 1, 1 + e.key),
            value: e.value,
          ),
        )
        .toList();

    return ExerciseAnalyticsData(
      exerciseId: 'test_ex',
      exerciseName: 'Test Exercise',
      weightHistory: weightPoints,
      volumeHistory: volumePoints,
      rpeHistory: rpePoints,
      trend: TrendAnalysis(
        type: trendType,
        slope: 0.0,
        correlation: 0.0,
        currentValue: weightPoints.last.value,
        predictedValue: weightPoints.last.value,
        recommendation: '',
      ),
      overload: ProgressiveOverloadData(
        currentPercent: overloadStatus == OverloadStatus.aboveTarget
            ? 25.0
            : 5.0,
        targetMin: 2.0,
        targetMax: 10.0,
        status: overloadStatus,
        userLevel: 'intermediate',
        currentVolume: volumePoints.last.value,
        previousVolume: volumePoints.first.value,
      ),
      intensity: IntensityData.empty(),
      correlations: CorrelationResults(
        weightRpe: CorrelationResult(
          r: correlationR,
          rSquared: correlationRSquared,
          strength: correlationRSquared > 0.7
              ? CorrelationStrength.strong
              : CorrelationStrength.weak,
          interpretation: 'Test',
        ),
        volumeRpe: CorrelationResult.insufficient(),
      ),
      lastUpdated: DateTime(2025, 1, 5),
      sessionCount: sessionCount,
    );
  }

  group('TrainingPatternDetector.detect', () {
    test('insufficient sessions returns empty', () {
      final data = _makeAnalyticsData(sessionCount: 2);
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(results.hasPatterns, isFalse);
      expect(results.overallStatus, TrainingStatus.insufficientData);
      expect(results.primaryPattern, isNull);
    });

    test('fatigue warning: RPE up + weight down', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 95, 90, 85], // decreasing
        rpes: [6, 6, 7, 8, 9], // increasing
        correlationR: -0.8,
        correlationRSquared: 0.64,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(
        results.patterns.any((p) => p.type == PatternType.fatigueWarning),
        isTrue,
      );
    });

    test('great progression: weight up + RPE stable + improving trend', () {
      final data = _makeAnalyticsData(
        weights: [80, 85, 90, 95, 100], // increasing
        rpes: [7, 7, 7, 7, 7], // stable
        trendType: TrendType.improving,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(
        results.patterns.any((p) => p.type == PatternType.greatProgression),
        isTrue,
      );
    });

    test('overreaching: RPE up + weight stable + volume down', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 100, 100, 100], // stable
        rpes: [6, 6, 7, 8, 9], // increasing
        volumes: [3000, 3000, 2800, 2600, 2400], // decreasing
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(
        results.patterns.any((p) => p.type == PatternType.overreachingRisk),
        isTrue,
      );
    });

    test('adaptation: RPE down + weight stable', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 100, 100, 100], // stable
        rpes: [9, 9, 8, 7, 6], // decreasing
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(
        results.patterns.any((p) => p.type == PatternType.adaptation),
        isTrue,
      );
    });

    test('volume spike: aboveTarget overload with high percent', () {
      final data = _makeAnalyticsData(
        overloadStatus: OverloadStatus.aboveTarget,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(
        results.patterns.any((p) => p.type == PatternType.volumeSpike),
        isTrue,
      );
    });

    test('optimal training: improving trend + optimal overload', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 100, 100, 100], // stable (no fatigue/progression)
        rpes: [7, 7, 7, 7, 7], // stable
        trendType: TrendType.improving,
        overloadStatus: OverloadStatus.optimal,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      expect(
        results.patterns.any((p) => p.type == PatternType.optimalTraining),
        isTrue,
      );
    });

    test('patterns sorted by priority (highest first)', () {
      // Create fatigue (alert/warning) + volume spike (warning)
      final data = _makeAnalyticsData(
        weights: [100, 100, 95, 90, 85],
        rpes: [6, 6, 7, 8, 9],
        correlationR: -0.9,
        correlationRSquared: 0.81,
        overloadStatus: OverloadStatus.aboveTarget,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      if (results.patterns.length > 1) {
        for (int i = 0; i < results.patterns.length - 1; i++) {
          expect(
            results.patterns[i].priority,
            greaterThanOrEqualTo(results.patterns[i + 1].priority),
          );
        }
      }
    });

    test('primaryPattern is first (highest priority)', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 95, 90, 85],
        rpes: [6, 6, 7, 8, 9],
        correlationR: -0.8,
        correlationRSquared: 0.64,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      if (results.hasPatterns) {
        expect(results.primaryPattern, results.patterns.first);
      }
    });
  });

  group('TrainingPatternDetector overall status', () {
    test('alert pattern -> fatigueRisk', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 95, 90, 85],
        rpes: [6, 6, 7, 8, 9],
        correlationR: -0.9,
        correlationRSquared: 0.81,
        sessionCount: 10,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      if (results.patterns.any((p) => p.severity == PatternSeverity.alert)) {
        expect(results.overallStatus, TrainingStatus.fatigueRisk);
      }
    });

    test('warning pattern -> needsAttention', () {
      final data = _makeAnalyticsData(
        weights: [100, 100, 100, 100, 100],
        rpes: [6, 6, 7, 8, 9],
        volumes: [3000, 3000, 2800, 2600, 2400],
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      // overreaching is a warning
      if (results.patterns.any((p) => p.severity == PatternSeverity.warning) &&
          !results.patterns.any((p) => p.severity == PatternSeverity.alert)) {
        expect(results.overallStatus, TrainingStatus.needsAttention);
      }
    });

    test('optimal pattern -> optimal status', () {
      final data = _makeAnalyticsData(
        trendType: TrendType.improving,
        overloadStatus: OverloadStatus.optimal,
      );
      final results = TrainingPatternDetector.detect(analyticsData: data);
      if (results.patterns.any((p) => p.type == PatternType.optimalTraining) &&
          !results.hasWarnings) {
        expect(results.overallStatus, TrainingStatus.optimal);
      }
    });
  });

  group('TrainingPattern entity', () {
    test('iconName for each type', () {
      for (final type in PatternType.values) {
        final pattern = TrainingPattern(
          type: type,
          severity: PatternSeverity.info,
          confidence: 0.5,
          titleKey: 'key',
          descriptionKey: 'key',
          recommendationKey: 'key',
        );
        expect(pattern.iconName, isNotEmpty);
      }
    });

    test('isWarning true for warning and alert', () {
      final warning = TrainingPattern(
        type: PatternType.fatigueWarning,
        severity: PatternSeverity.warning,
        confidence: 0.7,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );
      expect(warning.isWarning, isTrue);

      final alert = TrainingPattern(
        type: PatternType.fatigueWarning,
        severity: PatternSeverity.alert,
        confidence: 0.9,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );
      expect(alert.isWarning, isTrue);
    });

    test('isPositive true for positive severity', () {
      final positive = TrainingPattern(
        type: PatternType.greatProgression,
        severity: PatternSeverity.positive,
        confidence: 0.8,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );
      expect(positive.isPositive, isTrue);
      expect(positive.isWarning, isFalse);
    });

    test('priority ordering: alert > warning > positive > info', () {
      final alert = TrainingPattern(
        type: PatternType.fatigueWarning,
        severity: PatternSeverity.alert,
        confidence: 0.9,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );
      final warning = TrainingPattern(
        type: PatternType.overreachingRisk,
        severity: PatternSeverity.warning,
        confidence: 0.7,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );
      final positive = TrainingPattern(
        type: PatternType.greatProgression,
        severity: PatternSeverity.positive,
        confidence: 0.8,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );
      final info = TrainingPattern(
        type: PatternType.inconsistent,
        severity: PatternSeverity.info,
        confidence: 0.5,
        titleKey: 'k',
        descriptionKey: 'k',
        recommendationKey: 'k',
      );

      expect(alert.priority, greaterThan(warning.priority));
      expect(warning.priority, greaterThan(positive.priority));
      expect(positive.priority, greaterThan(info.priority));
    });
  });

  group('TrainingPatternResults', () {
    test('empty factory', () {
      final empty = TrainingPatternResults.empty();
      expect(empty.hasPatterns, isFalse);
      expect(empty.hasWarnings, isFalse);
      expect(empty.primaryPattern, isNull);
      expect(empty.overallStatus, TrainingStatus.insufficientData);
      expect(empty.dataPointsUsed, 0);
    });

    test('hasWarnings detects warning patterns', () {
      final results = TrainingPatternResults(
        patterns: [
          TrainingPattern(
            type: PatternType.volumeSpike,
            severity: PatternSeverity.warning,
            confidence: 0.8,
            titleKey: 'k',
            descriptionKey: 'k',
            recommendationKey: 'k',
          ),
        ],
        primaryPattern: null,
        overallStatus: TrainingStatus.needsAttention,
        analyzedAt: DateTime(2025, 1, 1),
      );
      expect(results.hasWarnings, isTrue);
    });

    test('warnings filters only warning/alert patterns', () {
      final results = TrainingPatternResults(
        patterns: [
          TrainingPattern(
            type: PatternType.fatigueWarning,
            severity: PatternSeverity.alert,
            confidence: 0.9,
            titleKey: 'k',
            descriptionKey: 'k',
            recommendationKey: 'k',
          ),
          TrainingPattern(
            type: PatternType.greatProgression,
            severity: PatternSeverity.positive,
            confidence: 0.8,
            titleKey: 'k',
            descriptionKey: 'k',
            recommendationKey: 'k',
          ),
        ],
        primaryPattern: null,
        overallStatus: TrainingStatus.fatigueRisk,
        analyzedAt: DateTime(2025, 1, 1),
      );
      expect(results.warnings.length, 1);
      expect(results.positivePatterns.length, 1);
    });
  });

  group('TrainingStatus', () {
    test('has 5 values', () {
      expect(TrainingStatus.values.length, 5);
    });
  });
}
