import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';

void main() {
  group('CorrelationResult - factories and properties', () {
    test('insufficient() factory creates correct default values', () {
      final result = CorrelationResult.insufficient();

      expect(result.r, equals(0.0));
      expect(result.rSquared, equals(0.0));
      expect(result.strength, equals(CorrelationStrength.insufficient));
      expect(result.dataPoints, equals(0));
      expect(result.isSignificant, isFalse);
      expect(result.interpretation, contains('3+'));
    });

    test('isPositive returns true for positive r', () {
      final result = CorrelationResult(
        r: 0.85,
        rSquared: 0.72,
        strength: CorrelationStrength.strong,
        interpretation: 'Strong positive correlation',
      );

      expect(result.isPositive, isTrue);
      expect(result.isNegative, isFalse);
    });

    test('isNegative returns true for negative r', () {
      final result = CorrelationResult(
        r: -0.65,
        rSquared: 0.42,
        strength: CorrelationStrength.moderate,
        interpretation: 'Moderate negative correlation',
      );

      expect(result.isNegative, isTrue);
      expect(result.isPositive, isFalse);
    });

    test('absoluteStrength returns absolute value of r', () {
      final positiveResult = CorrelationResult(
        r: 0.75,
        rSquared: 0.56,
        strength: CorrelationStrength.strong,
        interpretation: 'Positive',
      );

      final negativeResult = CorrelationResult(
        r: -0.75,
        rSquared: 0.56,
        strength: CorrelationStrength.strong,
        interpretation: 'Negative',
      );

      expect(positiveResult.absoluteStrength, equals(0.75));
      expect(negativeResult.absoluteStrength, equals(0.75));
    });

    test('r = 0 is neither positive nor negative', () {
      final result = CorrelationResult(
        r: 0.0,
        rSquared: 0.0,
        strength: CorrelationStrength.weak,
        interpretation: 'No correlation',
      );

      expect(result.isPositive, isFalse);
      expect(result.isNegative, isFalse);
    });

    test('default dataPoints is 0 and isSignificant is false', () {
      final result = CorrelationResult(
        r: 0.9,
        rSquared: 0.81,
        strength: CorrelationStrength.strong,
        interpretation: 'Strong',
      );

      expect(result.dataPoints, equals(0));
      expect(result.isSignificant, isFalse);
    });

    test('creates with all fields specified', () {
      final result = CorrelationResult(
        r: 0.88,
        rSquared: 0.77,
        strength: CorrelationStrength.strong,
        interpretation: 'Weight correlates strongly with RPE',
        dataPoints: 15,
        isSignificant: true,
      );

      expect(result.r, equals(0.88));
      expect(result.rSquared, equals(0.77));
      expect(result.strength, equals(CorrelationStrength.strong));
      expect(result.dataPoints, equals(15));
      expect(result.isSignificant, isTrue);
    });
  });

  group('CorrelationResults - container and factories', () {
    test('empty() factory creates insufficient results for both metrics', () {
      final results = CorrelationResults.empty();

      expect(results.weightRpe.strength, equals(CorrelationStrength.insufficient));
      expect(results.volumeRpe.strength, equals(CorrelationStrength.insufficient));
      expect(results.weightVolume, isNull);
    });

    test('hasSignificantCorrelations is false when no correlations are significant', () {
      final results = CorrelationResults.empty();

      expect(results.hasSignificantCorrelations, isFalse);
    });

    test('hasSignificantCorrelations is true when weightRpe is significant', () {
      final results = CorrelationResults(
        weightRpe: CorrelationResult(
          r: 0.85,
          rSquared: 0.72,
          strength: CorrelationStrength.strong,
          interpretation: 'Strong',
          isSignificant: true,
        ),
        volumeRpe: CorrelationResult.insufficient(),
      );

      expect(results.hasSignificantCorrelations, isTrue);
    });

    test('hasSignificantCorrelations is true when volumeRpe is significant', () {
      final results = CorrelationResults(
        weightRpe: CorrelationResult.insufficient(),
        volumeRpe: CorrelationResult(
          r: 0.72,
          rSquared: 0.52,
          strength: CorrelationStrength.moderate,
          interpretation: 'Moderate',
          isSignificant: true,
        ),
      );

      expect(results.hasSignificantCorrelations, isTrue);
    });

    test('creates with optional weightVolume correlation', () {
      final results = CorrelationResults(
        weightRpe: CorrelationResult.insufficient(),
        volumeRpe: CorrelationResult.insufficient(),
        weightVolume: CorrelationResult(
          r: 0.6,
          rSquared: 0.36,
          strength: CorrelationStrength.moderate,
          interpretation: 'Moderate weight-volume correlation',
        ),
      );

      expect(results.weightVolume, isNotNull);
      expect(results.weightVolume!.r, equals(0.6));
    });

    test('fromJson round-trips basic fields correctly', () {
      final original = CorrelationResults(
        weightRpe: CorrelationResult(
          r: 0.5,
          rSquared: 0.25,
          strength: CorrelationStrength.moderate,
          interpretation: 'Moderate',
          dataPoints: 8,
          isSignificant: false,
        ),
        volumeRpe: CorrelationResult.insufficient(),
      );

      final json = original.toJson();
      final restored = CorrelationResults.fromJson(json);

      expect(restored.weightRpe.r, closeTo(0.5, 0.001));
      expect(restored.weightRpe.rSquared, closeTo(0.25, 0.001));
      expect(restored.weightRpe.strength, equals(CorrelationStrength.moderate));
    });
  });
}
