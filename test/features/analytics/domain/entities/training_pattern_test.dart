/// TrainingPattern entity tests - computed properties, enums, factories.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/training_pattern.dart';

void main() {
  group('PatternType', () {
    test('has 7 values', () {
      expect(PatternType.values.length, 7);
    });
  });

  group('PatternSeverity', () {
    test('has 4 values', () {
      expect(PatternSeverity.values.length, 4);
    });
  });

  group('TrainingStatus', () {
    test('has 5 values', () {
      expect(TrainingStatus.values.length, 5);
    });
  });

  group('TrainingPattern computed', () {
    TrainingPattern make({
      PatternType type = PatternType.fatigueWarning,
      PatternSeverity severity = PatternSeverity.warning,
      double confidence = 0.8,
    }) {
      return TrainingPattern(
        type: type,
        severity: severity,
        confidence: confidence,
        titleKey: 'title',
        descriptionKey: 'desc',
        recommendationKey: 'rec',
      );
    }

    test('iconName for all types', () {
      expect(make(type: PatternType.fatigueWarning).iconName, 'warningAmber');
      expect(make(type: PatternType.greatProgression).iconName, 'trendingUp');
      expect(make(type: PatternType.overreachingRisk).iconName, 'warningAmber');
      expect(make(type: PatternType.adaptation).iconName, 'checkCircle');
      expect(make(type: PatternType.volumeSpike).iconName, 'showChart');
      expect(make(type: PatternType.optimalTraining).iconName, 'star');
      expect(make(type: PatternType.inconsistent).iconName, 'helpOutline');
    });

    test('isWarning', () {
      expect(make(severity: PatternSeverity.warning).isWarning, isTrue);
      expect(make(severity: PatternSeverity.alert).isWarning, isTrue);
      expect(make(severity: PatternSeverity.info).isWarning, isFalse);
      expect(make(severity: PatternSeverity.positive).isWarning, isFalse);
    });

    test('isPositive', () {
      expect(make(severity: PatternSeverity.positive).isPositive, isTrue);
      expect(make(severity: PatternSeverity.warning).isPositive, isFalse);
    });

    test('priority', () {
      expect(make(severity: PatternSeverity.alert).priority, 4);
      expect(make(severity: PatternSeverity.warning).priority, 3);
      expect(make(severity: PatternSeverity.positive).priority, 2);
      expect(make(severity: PatternSeverity.info).priority, 1);
    });
  });

  group('TrainingPatternResults', () {
    test('empty factory', () {
      final results = TrainingPatternResults.empty();
      expect(results.patterns, isEmpty);
      expect(results.primaryPattern, isNull);
      expect(results.overallStatus, TrainingStatus.insufficientData);
      expect(results.dataPointsUsed, 0);
      expect(results.hasPatterns, isFalse);
      expect(results.hasWarnings, isFalse);
    });

    test('hasPatterns and hasWarnings', () {
      final warning = TrainingPattern(
        type: PatternType.fatigueWarning,
        severity: PatternSeverity.warning,
        confidence: 0.7,
        titleKey: 't',
        descriptionKey: 'd',
        recommendationKey: 'r',
      );
      final positive = TrainingPattern(
        type: PatternType.greatProgression,
        severity: PatternSeverity.positive,
        confidence: 0.8,
        titleKey: 't',
        descriptionKey: 'd',
        recommendationKey: 'r',
      );

      final results = TrainingPatternResults(
        patterns: [warning, positive],
        primaryPattern: warning,
        overallStatus: TrainingStatus.needsAttention,
        analyzedAt: DateTime(2025, 3, 1),
        dataPointsUsed: 10,
      );

      expect(results.hasPatterns, isTrue);
      expect(results.hasWarnings, isTrue);
      expect(results.warnings.length, 1);
      expect(results.positivePatterns.length, 1);
    });
  });
}
