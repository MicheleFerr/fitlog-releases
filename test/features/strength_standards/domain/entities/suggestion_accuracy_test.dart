/// SuggestionAccuracy entity tests - accuracy tiers, error direction,
/// AccuracyMetrics confidence.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/suggestion_accuracy.dart';

void main() {
  group('AccuracyTier', () {
    test('has 5 values', () {
      expect(AccuracyTier.values.length, 5);
    });
  });

  group('ErrorDirection', () {
    test('has 3 values', () {
      expect(ErrorDirection.values.length, 3);
    });
  });

  group('AccuracyTrend', () {
    test('has 4 values', () {
      expect(AccuracyTrend.values.length, 4);
    });
  });

  group('SuggestionAccuracy', () {
    SuggestionAccuracy make({
      double suggestedWeight = 80,
      double actualWeight = 80,
      int suggestedReps = 10,
      int actualReps = 10,
      double weightErrorPercent = 0,
    }) {
      return SuggestionAccuracy(
        id: 'sa1',
        userId: 'u1',
        exerciseId: 'e1',
        suggestedWeight: suggestedWeight,
        actualWeight: actualWeight,
        suggestedReps: suggestedReps,
        actualReps: actualReps,
        weightErrorPercent: weightErrorPercent,
        repsError: actualReps - suggestedReps,
        timestamp: DateTime(2025, 3, 1),
        experienceLevel: 'intermediate',
        trainingGoal: 'hypertrophy',
      );
    }

    test('isAcceptable within 15%', () {
      expect(make(weightErrorPercent: 10).isAcceptable, isTrue);
      expect(make(weightErrorPercent: 15).isAcceptable, isTrue);
      expect(make(weightErrorPercent: 16).isAcceptable, isFalse);
    });

    test('isVeryAccurate within 5%', () {
      expect(make(weightErrorPercent: 3).isVeryAccurate, isTrue);
      expect(make(weightErrorPercent: 5).isVeryAccurate, isTrue);
      expect(make(weightErrorPercent: 6).isVeryAccurate, isFalse);
    });

    test('accuracyTier', () {
      expect(make(weightErrorPercent: 3).accuracyTier, AccuracyTier.excellent);
      expect(make(weightErrorPercent: 8).accuracyTier, AccuracyTier.good);
      expect(make(weightErrorPercent: 12).accuracyTier, AccuracyTier.acceptable);
      expect(make(weightErrorPercent: 20).accuracyTier, AccuracyTier.poor);
      expect(make(weightErrorPercent: 30).accuracyTier, AccuracyTier.veryPoor);
    });

    test('errorDirection justRight', () {
      expect(make(weightErrorPercent: 3).errorDirection, ErrorDirection.justRight);
    });

    test('errorDirection tooLight (user used more)', () {
      final sa = make(
        suggestedWeight: 80,
        actualWeight: 100,
        weightErrorPercent: 25,
      );
      expect(sa.errorDirection, ErrorDirection.tooLight);
    });

    test('errorDirection tooHeavy (user used less)', () {
      final sa = make(
        suggestedWeight: 100,
        actualWeight: 80,
        weightErrorPercent: 20,
      );
      expect(sa.errorDirection, ErrorDirection.tooHeavy);
    });

    test('JSON round-trip', () {
      final sa = make(weightErrorPercent: 8);
      final json = sa.toJson();
      final restored = SuggestionAccuracy.fromJson(json);
      expect(restored, equals(sa));
    });
  });

  group('AccuracyMetrics', () {
    test('isReliable with enough samples', () {
      final metrics = AccuracyMetrics(
        exerciseId: 'e1',
        sampleSize: 5,
        averageErrorPercent: 10,
        standardDeviation: 3,
        trend: AccuracyTrend.stable,
        lastUpdated: DateTime(2025, 3, 1),
      );
      expect(metrics.isReliable, isTrue);
    });

    test('not reliable with few samples', () {
      final metrics = AccuracyMetrics(
        exerciseId: 'e1',
        sampleSize: 2,
        averageErrorPercent: 10,
        standardDeviation: 3,
        trend: AccuracyTrend.insufficient,
        lastUpdated: DateTime(2025, 3, 1),
      );
      expect(metrics.isReliable, isFalse);
    });

    test('confidence high with low error and many samples', () {
      final metrics = AccuracyMetrics(
        exerciseId: 'e1',
        sampleSize: 10,
        averageErrorPercent: 5,
        standardDeviation: 2,
        trend: AccuracyTrend.improving,
        lastUpdated: DateTime(2025, 3, 1),
      );
      expect(metrics.confidence, greaterThan(0.8));
    });

    test('confidence medium with low samples', () {
      final metrics = AccuracyMetrics(
        exerciseId: 'e1',
        sampleSize: 1,
        averageErrorPercent: 10,
        standardDeviation: 5,
        trend: AccuracyTrend.insufficient,
        lastUpdated: DateTime(2025, 3, 1),
      );
      expect(metrics.confidence, 0.5);
    });
  });
}
