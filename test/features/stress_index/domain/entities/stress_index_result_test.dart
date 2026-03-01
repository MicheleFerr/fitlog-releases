/// StressIndexResult unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';

void main() {
  StressIndexResult _make({
    double primaryScore = 50,
    double fallbackScore = 40,
    double confidence = 0.8,
  }) {
    return StressIndexResult(
      primaryScore: primaryScore,
      fallbackScore: fallbackScore,
      confidence: confidence,
      totalSets: 10,
      setsWithRpe: 8,
      workoutId: 'w-1',
      muscleBreakdown: {},
      calculatedAt: DateTime(2024, 6, 15),
      rawScore: 5000,
    );
  }

  group('displayScore', () {
    test('returns primaryScore when confidence >= 0.5', () {
      expect(_make(confidence: 0.5, primaryScore: 70).displayScore, 70);
    });

    test('returns fallbackScore when confidence < 0.5', () {
      expect(
        _make(confidence: 0.49, primaryScore: 70, fallbackScore: 30)
            .displayScore,
        30,
      );
    });
  });

  group('confidence levels', () {
    test('isHighConfidence >= 0.80', () {
      expect(_make(confidence: 0.80).isHighConfidence, true);
      expect(_make(confidence: 0.79).isHighConfidence, false);
    });

    test('isMediumConfidence 0.50-0.79', () {
      expect(_make(confidence: 0.50).isMediumConfidence, true);
      expect(_make(confidence: 0.79).isMediumConfidence, true);
      expect(_make(confidence: 0.80).isMediumConfidence, false);
      expect(_make(confidence: 0.49).isMediumConfidence, false);
    });

    test('isLowConfidence < 0.50', () {
      expect(_make(confidence: 0.49).isLowConfidence, true);
      expect(_make(confidence: 0.50).isLowConfidence, false);
    });
  });

  group('stressLevel', () {
    test('< 30 => light', () {
      expect(_make(primaryScore: 20).stressLevel, StressLevel.light);
    });

    test('30-59 => moderate', () {
      expect(_make(primaryScore: 30).stressLevel, StressLevel.moderate);
      expect(_make(primaryScore: 59).stressLevel, StressLevel.moderate);
    });

    test('60-79 => hard', () {
      expect(_make(primaryScore: 60).stressLevel, StressLevel.hard);
      expect(_make(primaryScore: 79).stressLevel, StressLevel.hard);
    });

    test('>= 80 => veryHard', () {
      expect(_make(primaryScore: 80).stressLevel, StressLevel.veryHard);
      expect(_make(primaryScore: 100).stressLevel, StressLevel.veryHard);
    });

    test('uses fallback when low confidence', () {
      final r = _make(
        primaryScore: 90,
        fallbackScore: 20,
        confidence: 0.3,
      );
      expect(r.stressLevel, StressLevel.light);
    });
  });

  group('scoreRange', () {
    test('high confidence returns single value', () {
      expect(_make(primaryScore: 50, confidence: 0.9).scoreRange, '50');
    });

    test('medium confidence returns range', () {
      final range = _make(primaryScore: 50, confidence: 0.6).scoreRange;
      expect(range, contains('-'));
    });
  });

  group('StressLevel', () {
    test('has 4 values', () {
      expect(StressLevel.values.length, 4);
    });
  });
}
