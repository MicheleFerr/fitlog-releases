/// Analytics domain entities tests - PRCelebration, MuscleCorrection,
/// RepZone, VarietyLevel, ScoreBreakdown, ExerciseAnalyticsData sub-entities.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_analytics_data.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

void main() {
  group('CelebrationEngagement', () {
    test('has 3 values', () {
      expect(CelebrationEngagement.values.length, 3);
    });
  });

  group('PRCelebration', () {
    PRCelebration makeCelebration({
      double previousValue = 80,
      double newValue = 100,
    }) {
      return PRCelebration(
        id: 'c1',
        userId: 'u1',
        prId: 'pr1',
        prType: PRType.weight,
        celebratedAt: DateTime(2025, 3, 1),
        engagement: CelebrationEngagement.viewed,
        previousValue: previousValue,
        newValue: newValue,
      );
    }

    test('improvementPercentage', () {
      final c = makeCelebration(previousValue: 80, newValue: 100);
      expect(c.improvementPercentage, 25.0);
    });

    test('improvementPercentage zero previous', () {
      final c = makeCelebration(previousValue: 0, newValue: 100);
      expect(c.improvementPercentage, 0);
    });

    test('isSignificantPR', () {
      final significant = makeCelebration(previousValue: 80, newValue: 100);
      expect(significant.isSignificantPR, isTrue); // 25%

      final minor = makeCelebration(previousValue: 100, newValue: 105);
      expect(minor.isSignificantPR, isFalse); // 5%
    });
  });

  group('MuscleCorrection', () {
    test('stores all fields', () {
      final mc = MuscleCorrection(
        exerciseName: 'Bench Press',
        oldMuscleGroup: 'Back',
        newMuscleGroup: 'Chest',
        timestamp: DateTime(2025, 3, 1),
      );
      expect(mc.exerciseName, 'Bench Press');
      expect(mc.oldMuscleGroup, 'Back');
      expect(mc.newMuscleGroup, 'Chest');
    });

    test('JSON round-trip', () {
      final mc = MuscleCorrection(
        exerciseName: 'Squat',
        oldMuscleGroup: 'Back',
        newMuscleGroup: 'Legs',
        timestamp: DateTime(2025, 3, 1),
      );
      final json = mc.toJson();
      final restored = MuscleCorrection.fromJson(json);
      expect(restored, equals(mc));
    });
  });

  group('RepZone', () {
    test('has 3 values', () {
      expect(RepZone.values.length, 3);
    });

    test('label', () {
      expect(RepZone.strength.label, 'Forza');
      expect(RepZone.hypertrophy.label, 'Ipertrofia');
      expect(RepZone.endurance.label, 'Resistenza');
    });

    test('repRange', () {
      expect(RepZone.strength.repRange, '1-5 rep');
      expect(RepZone.hypertrophy.repRange, '6-15 rep');
      expect(RepZone.endurance.repRange, '15+ rep');
    });

    test('recommendedSets', () {
      expect(RepZone.strength.recommendedSets, 3);
      expect(RepZone.hypertrophy.recommendedSets, 4);
      expect(RepZone.endurance.recommendedSets, 3);
    });

    test('recommendedReps', () {
      expect(RepZone.strength.recommendedReps, 5);
      expect(RepZone.hypertrophy.recommendedReps, 10);
      expect(RepZone.endurance.recommendedReps, 15);
    });

    test('recommendedRestSeconds', () {
      expect(RepZone.strength.recommendedRestSeconds, 180);
      expect(RepZone.hypertrophy.recommendedRestSeconds, 90);
      expect(RepZone.endurance.recommendedRestSeconds, 60);
    });
  });

  group('VarietyLevel', () {
    test('has 4 values', () {
      expect(VarietyLevel.values.length, 4);
    });

    test('needsSuggestions', () {
      expect(VarietyLevel.excellent.needsSuggestions, isFalse);
      expect(VarietyLevel.good.needsSuggestions, isFalse);
      expect(VarietyLevel.low.needsSuggestions, isTrue);
      expect(VarietyLevel.veryLow.needsSuggestions, isTrue);
    });
  });

  group('ScoreBreakdown', () {
    test('total', () {
      const sb = ScoreBreakdown(
        muscleRelevance: 30,
        exerciseType: 20,
        equipment: 15,
        difficultyMatch: 10,
        variety: 10,
        weeklyVolume: 15,
        intensityMatch: 10,
      );
      expect(sb.total, 110);
    });

    test('normalizedScore', () {
      const sb = ScoreBreakdown(
        muscleRelevance: 30,
        exerciseType: 20,
        equipment: 15,
        difficultyMatch: 10,
        variety: 10,
        weeklyVolume: 15,
        intensityMatch: 10,
      );
      expect(sb.normalizedScore, 100);
    });

    test('normalizedScore with zero', () {
      const sb = ScoreBreakdown();
      expect(sb.normalizedScore, 0);
    });

    test('defaults are all zero', () {
      const sb = ScoreBreakdown();
      expect(sb.total, 0);
    });
  });

  group('RepZoneAnalysis', () {
    test('needsSuggestions delegates to varietyLevel', () {
      const analysis = RepZoneAnalysis(
        strengthPercentage: 90,
        hypertrophyPercentage: 5,
        endurancePercentage: 5,
        strengthSets: 18,
        hypertrophySets: 1,
        enduranceSets: 1,
        totalSets: 20,
        varietyLevel: VarietyLevel.veryLow,
        dominantZone: RepZone.strength,
        neglectedZones: [RepZone.hypertrophy, RepZone.endurance],
      );
      expect(analysis.needsSuggestions, isTrue);
    });

    test('getPercentage', () {
      const analysis = RepZoneAnalysis(
        strengthPercentage: 40,
        hypertrophyPercentage: 35,
        endurancePercentage: 25,
        strengthSets: 8,
        hypertrophySets: 7,
        enduranceSets: 5,
        totalSets: 20,
        varietyLevel: VarietyLevel.good,
        dominantZone: null,
        neglectedZones: [],
      );
      expect(analysis.getPercentage(RepZone.strength), 40);
      expect(analysis.getPercentage(RepZone.hypertrophy), 35);
      expect(analysis.getPercentage(RepZone.endurance), 25);
    });
  });

  group('OverloadStatus', () {
    test('has 4 values', () {
      expect(OverloadStatus.values.length, 4);
    });
  });

  group('ProgressiveOverloadData', () {
    test('noBaseline factory', () {
      final data = ProgressiveOverloadData.noBaseline();
      expect(data.status, OverloadStatus.noBaseline);
      expect(data.isOptimal, isFalse);
      expect(data.currentPercent, 0);
    });

    test('isOptimal', () {
      const data = ProgressiveOverloadData(
        currentPercent: 5,
        targetMin: 2,
        targetMax: 10,
        status: OverloadStatus.optimal,
        userLevel: 'intermediate',
        currentVolume: 1000,
        previousVolume: 950,
      );
      expect(data.isOptimal, isTrue);
    });
  });

  group('IntensityData', () {
    test('empty factory', () {
      final data = IntensityData.empty();
      expect(data.estimated1RM, 0);
      expect(data.currentWeight, 0);
      expect(data.formula, 'None');
    });
  });
}
