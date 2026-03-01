/// TemplateStressAnalyzer tests - entities, enums, recommendation logic.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/template_stress_analyzer.dart';

void main() {
  group('MuscleRecoveryHistory', () {
    test('stores all fields', () {
      final now = DateTime.now();
      final history = MuscleRecoveryHistory(
        muscleId: 'PETT',
        displayName: 'Chest',
        lastWorkedAt: now,
        lastStressScore: 75.0,
      );
      expect(history.muscleId, 'PETT');
      expect(history.displayName, 'Chest');
      expect(history.lastWorkedAt, now);
      expect(history.lastStressScore, 75.0);
    });
  });

  group('TemplateRecommendation enum', () {
    test('has 4 values', () {
      expect(TemplateRecommendation.values.length, 4);
    });

    test('contains optimal, acceptable, suboptimal, avoid', () {
      expect(TemplateRecommendation.values,
          contains(TemplateRecommendation.optimal));
      expect(TemplateRecommendation.values,
          contains(TemplateRecommendation.acceptable));
      expect(TemplateRecommendation.values,
          contains(TemplateRecommendation.suboptimal));
      expect(TemplateRecommendation.values,
          contains(TemplateRecommendation.avoid));
    });
  });

  group('TemplateStressAnalysis', () {
    test('creates with required fields', () {
      final analysis = TemplateStressAnalysis(
        templateId: 'tmpl_1',
        templateName: 'Push Day',
        expectedStress: 50.0,
        currentStress: 20.0,
        resultingTotalStress: 70.0,
        muscleReadiness: const {},
        primaryMuscles: const ['PETT', 'DELT_ANT'],
        secondaryMuscles: const ['TRIC'],
        underRecoveredMuscles: const [],
        fatiguedMuscles: const [],
        recommendation: TemplateRecommendation.optimal,
        rationale: 'All muscles ready',
        optimalityScore: 95.0,
      );
      expect(analysis.templateId, 'tmpl_1');
      expect(analysis.templateName, 'Push Day');
      expect(analysis.expectedStress, 50.0);
      expect(analysis.resultingTotalStress, 70.0);
      expect(analysis.primaryMuscles.length, 2);
      expect(analysis.recommendation, TemplateRecommendation.optimal);
      expect(analysis.optimalityScore, 95.0);
    });

    test('optional fields default correctly', () {
      final analysis = TemplateStressAnalysis(
        templateId: 'tmpl_2',
        templateName: 'Test',
        expectedStress: 30.0,
        currentStress: 10.0,
        resultingTotalStress: 40.0,
        muscleReadiness: const {},
        primaryMuscles: const [],
        secondaryMuscles: const [],
        underRecoveredMuscles: const [],
        fatiguedMuscles: const [],
        recommendation: TemplateRecommendation.acceptable,
        rationale: 'Test',
        optimalityScore: 70.0,
      );
      expect(analysis.templateIcon, isNull);
      expect(analysis.sleepDataUsed, isFalse);
      expect(analysis.hrvDataUsed, isFalse);
      expect(analysis.sleepHoursLastNight, isNull);
      expect(analysis.hrvMs, isNull);
    });

    test('with health data flags', () {
      final analysis = TemplateStressAnalysis(
        templateId: 'tmpl_3',
        templateName: 'Test',
        expectedStress: 30.0,
        currentStress: 10.0,
        resultingTotalStress: 40.0,
        muscleReadiness: const {},
        primaryMuscles: const [],
        secondaryMuscles: const [],
        underRecoveredMuscles: const [],
        fatiguedMuscles: const [],
        recommendation: TemplateRecommendation.acceptable,
        rationale: 'Test',
        optimalityScore: 70.0,
        sleepDataUsed: true,
        hrvDataUsed: true,
        sleepHoursLastNight: 7.5,
        hrvMs: 65.0,
      );
      expect(analysis.sleepDataUsed, isTrue);
      expect(analysis.hrvDataUsed, isTrue);
      expect(analysis.sleepHoursLastNight, 7.5);
      expect(analysis.hrvMs, 65.0);
    });
  });

  group('MuscleReadinessData', () {
    test('fully ready muscle', () {
      const data = MuscleReadinessData(
        muscleId: 'PETT',
        displayName: 'Chest',
        recoveryPercent: 100,
        hoursSinceWorkout: 72,
        isPrimaryMuscle: true,
      );
      expect(data.muscleId, 'PETT');
      expect(data.recoveryPercent, 100);
      expect(data.isPrimaryMuscle, isTrue);
      expect(data.shouldAvoid, isFalse);
    });

    test('defaults for optional fields', () {
      const data = MuscleReadinessData(
        muscleId: 'LAT',
        displayName: 'Lats',
        recoveryPercent: 80,
        hoursSinceWorkout: 48,
      );
      expect(data.lastWorkoutStress, 0);
      expect(data.expectedStressFromWorkout, 0);
      expect(data.isPrimaryMuscle, isFalse);
    });
  });
}
