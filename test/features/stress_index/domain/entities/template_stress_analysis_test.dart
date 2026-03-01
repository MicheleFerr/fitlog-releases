/// TemplateStressAnalysis unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';

void main() {
  MuscleReadinessData _makeReadiness({
    String muscleId = 'PETT',
    String displayName = 'Chest',
    double recoveryPercent = 95,
    int hoursSinceWorkout = 48,
  }) {
    return MuscleReadinessData(
      muscleId: muscleId,
      displayName: displayName,
      recoveryPercent: recoveryPercent,
      hoursSinceWorkout: hoursSinceWorkout,
    );
  }

  TemplateStressAnalysis _make({
    TemplateRecommendation recommendation = TemplateRecommendation.optimal,
    Map<String, MuscleReadinessData>? muscleReadiness,
    double expectedStress = 50,
    double currentStress = 20,
    double resultingTotalStress = 70,
    double optimalityScore = 85,
    List<String> underRecoveredMuscles = const [],
    List<String> fatiguedMuscles = const [],
  }) {
    return TemplateStressAnalysis(
      templateId: 't-1',
      templateName: 'Push Day',
      expectedStress: expectedStress,
      currentStress: currentStress,
      resultingTotalStress: resultingTotalStress,
      muscleReadiness: muscleReadiness ?? {},
      primaryMuscles: ['PETT', 'DELT'],
      secondaryMuscles: ['TRIC'],
      underRecoveredMuscles: underRecoveredMuscles,
      fatiguedMuscles: fatiguedMuscles,
      recommendation: recommendation,
      rationale: 'Good to go',
      optimalityScore: optimalityScore,
    );
  }

  group('TemplateStressAnalysis - averageMuscleRecovery', () {
    test('returns 100 when no muscle readiness data', () {
      final analysis = _make(muscleReadiness: {});
      expect(analysis.averageMuscleRecovery, 100.0);
    });

    test('returns average of muscle recovery percentages', () {
      final analysis = _make(muscleReadiness: {
        'PETT': _makeReadiness(recoveryPercent: 80),
        'DELT': _makeReadiness(
            muscleId: 'DELT',
            displayName: 'Shoulders',
            recoveryPercent: 60),
      });
      expect(analysis.averageMuscleRecovery, 70.0);
    });

    test('single muscle returns its recovery', () {
      final analysis = _make(muscleReadiness: {
        'PETT': _makeReadiness(recoveryPercent: 75),
      });
      expect(analysis.averageMuscleRecovery, 75.0);
    });
  });

  group('TemplateStressAnalysis - lowestMuscleRecovery', () {
    test('returns 100 when no muscle data', () {
      expect(_make().lowestMuscleRecovery, 100.0);
    });

    test('returns minimum recovery', () {
      final analysis = _make(muscleReadiness: {
        'PETT': _makeReadiness(recoveryPercent: 90),
        'DELT': _makeReadiness(
            muscleId: 'DELT',
            displayName: 'Shoulders',
            recoveryPercent: 40),
        'TRIC': _makeReadiness(
            muscleId: 'TRIC', displayName: 'Triceps', recoveryPercent: 70),
      });
      expect(analysis.lowestMuscleRecovery, 40.0);
    });
  });

  group('TemplateStressAnalysis - musclesReadyCount', () {
    test('returns 0 when no muscles', () {
      expect(_make().musclesReadyCount, 0);
    });

    test('counts muscles with >90% recovery', () {
      final analysis = _make(muscleReadiness: {
        'PETT': _makeReadiness(recoveryPercent: 95), // ready
        'DELT': _makeReadiness(
            muscleId: 'DELT',
            displayName: 'Shoulders',
            recoveryPercent: 100), // ready
        'TRIC': _makeReadiness(
            muscleId: 'TRIC',
            displayName: 'Triceps',
            recoveryPercent: 60), // not ready
      });
      expect(analysis.musclesReadyCount, 2);
    });
  });

  group('TemplateStressAnalysis - musclesNeedCautionCount', () {
    test('counts muscles needing caution (<70%)', () {
      final analysis = _make(muscleReadiness: {
        'PETT': _makeReadiness(recoveryPercent: 95), // fine
        'DELT': _makeReadiness(
            muscleId: 'DELT',
            displayName: 'Shoulders',
            recoveryPercent: 60), // underRecovered
        'TRIC': _makeReadiness(
            muscleId: 'TRIC',
            displayName: 'Triceps',
            recoveryPercent: 30), // fatigued
      });
      expect(analysis.musclesNeedCautionCount, 2);
    });
  });

  group('TemplateStressAnalysis - isSafe', () {
    test('optimal is safe', () {
      expect(
          _make(recommendation: TemplateRecommendation.optimal).isSafe, true);
    });

    test('acceptable is safe', () {
      expect(_make(recommendation: TemplateRecommendation.acceptable).isSafe,
          true);
    });

    test('suboptimal is safe', () {
      expect(_make(recommendation: TemplateRecommendation.suboptimal).isSafe,
          true);
    });

    test('avoid is not safe', () {
      expect(
          _make(recommendation: TemplateRecommendation.avoid).isSafe, false);
    });
  });

  group('TemplateStressAnalysis - isOptimal', () {
    test('optimal returns true', () {
      expect(_make(recommendation: TemplateRecommendation.optimal).isOptimal,
          true);
    });

    test('non-optimal returns false', () {
      expect(
          _make(recommendation: TemplateRecommendation.acceptable).isOptimal,
          false);
    });
  });

  group('TemplateStressAnalysis - isRecommended', () {
    test('optimal is recommended', () {
      expect(
          _make(recommendation: TemplateRecommendation.optimal).isRecommended,
          true);
    });

    test('acceptable is recommended', () {
      expect(
          _make(recommendation: TemplateRecommendation.acceptable)
              .isRecommended,
          true);
    });

    test('suboptimal is not recommended', () {
      expect(
          _make(recommendation: TemplateRecommendation.suboptimal)
              .isRecommended,
          false);
    });

    test('avoid is not recommended', () {
      expect(
          _make(recommendation: TemplateRecommendation.avoid).isRecommended,
          false);
    });
  });

  group('TemplateStressAnalysis - colorHint', () {
    test('optimal => green', () {
      expect(_make(recommendation: TemplateRecommendation.optimal).colorHint,
          'green');
    });

    test('acceptable => yellow', () {
      expect(
          _make(recommendation: TemplateRecommendation.acceptable).colorHint,
          'yellow');
    });

    test('suboptimal => orange', () {
      expect(
          _make(recommendation: TemplateRecommendation.suboptimal).colorHint,
          'orange');
    });

    test('avoid => red', () {
      expect(_make(recommendation: TemplateRecommendation.avoid).colorHint,
          'red');
    });
  });

  group('TemplateStressAnalysis - iconHint', () {
    test('optimal => check', () {
      expect(_make(recommendation: TemplateRecommendation.optimal).iconHint,
          '✓');
    });

    test('acceptable => tilde', () {
      expect(
          _make(recommendation: TemplateRecommendation.acceptable).iconHint,
          '~');
    });

    test('suboptimal => exclamation', () {
      expect(
          _make(recommendation: TemplateRecommendation.suboptimal).iconHint,
          '!');
    });

    test('avoid => x', () {
      expect(
          _make(recommendation: TemplateRecommendation.avoid).iconHint, '✗');
    });
  });

  group('TemplateRecommendation', () {
    test('has 4 values', () {
      expect(TemplateRecommendation.values.length, 4);
    });
  });
}
