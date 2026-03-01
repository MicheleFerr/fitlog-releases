/// RepZoneSuggestion entity tests - RepZone, VarietyLevel, analysis, scoring.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

void main() {
  group('RepZone', () {
    test('has 3 values', () {
      expect(RepZone.values.length, 3);
    });

    test('label returns localized name', () {
      expect(RepZone.strength.label, 'Forza');
      expect(RepZone.hypertrophy.label, 'Ipertrofia');
      expect(RepZone.endurance.label, 'Resistenza');
    });

    test('repRange returns correct ranges', () {
      expect(RepZone.strength.repRange, '1-5 rep');
      expect(RepZone.hypertrophy.repRange, '6-15 rep');
      expect(RepZone.endurance.repRange, '15+ rep');
    });

    test('recommendedSets values', () {
      expect(RepZone.strength.recommendedSets, 3);
      expect(RepZone.hypertrophy.recommendedSets, 4);
      expect(RepZone.endurance.recommendedSets, 3);
    });

    test('recommendedReps values', () {
      expect(RepZone.strength.recommendedReps, 5);
      expect(RepZone.hypertrophy.recommendedReps, 10);
      expect(RepZone.endurance.recommendedReps, 15);
    });

    test('recommendedRestSeconds values', () {
      expect(RepZone.strength.recommendedRestSeconds, 180);
      expect(RepZone.hypertrophy.recommendedRestSeconds, 90);
      expect(RepZone.endurance.recommendedRestSeconds, 60);
    });
  });

  group('VarietyLevel', () {
    test('has 4 values', () {
      expect(VarietyLevel.values.length, 4);
    });

    test('needsSuggestions for low and veryLow', () {
      expect(VarietyLevel.excellent.needsSuggestions, isFalse);
      expect(VarietyLevel.good.needsSuggestions, isFalse);
      expect(VarietyLevel.low.needsSuggestions, isTrue);
      expect(VarietyLevel.veryLow.needsSuggestions, isTrue);
    });
  });

  group('RepZoneAnalysis', () {
    test('stores all fields', () {
      const analysis = RepZoneAnalysis(
        strengthPercentage: 20.0,
        hypertrophyPercentage: 60.0,
        endurancePercentage: 20.0,
        strengthSets: 4,
        hypertrophySets: 12,
        enduranceSets: 4,
        totalSets: 20,
        varietyLevel: VarietyLevel.excellent,
        dominantZone: RepZone.hypertrophy,
        neglectedZones: [],
      );
      expect(analysis.totalSets, 20);
      expect(analysis.dominantZone, RepZone.hypertrophy);
      expect(analysis.neglectedZones, isEmpty);
    });

    test('needsSuggestions delegates to varietyLevel', () {
      const low = RepZoneAnalysis(
        strengthPercentage: 5.0,
        hypertrophyPercentage: 90.0,
        endurancePercentage: 5.0,
        strengthSets: 1,
        hypertrophySets: 18,
        enduranceSets: 1,
        totalSets: 20,
        varietyLevel: VarietyLevel.low,
        dominantZone: RepZone.hypertrophy,
        neglectedZones: [RepZone.strength, RepZone.endurance],
      );
      expect(low.needsSuggestions, isTrue);
    });

    test('getPercentage returns correct zone percentage', () {
      const analysis = RepZoneAnalysis(
        strengthPercentage: 30.0,
        hypertrophyPercentage: 50.0,
        endurancePercentage: 20.0,
        strengthSets: 6,
        hypertrophySets: 10,
        enduranceSets: 4,
        totalSets: 20,
        varietyLevel: VarietyLevel.good,
        dominantZone: RepZone.hypertrophy,
        neglectedZones: [],
      );
      expect(analysis.getPercentage(RepZone.strength), 30.0);
      expect(analysis.getPercentage(RepZone.hypertrophy), 50.0);
      expect(analysis.getPercentage(RepZone.endurance), 20.0);
    });
  });

  group('ScoreBreakdown', () {
    test('total sums all criteria', () {
      const breakdown = ScoreBreakdown(
        muscleRelevance: 25,
        exerciseType: 15,
        equipment: 10,
        difficultyMatch: 8,
        variety: 7,
        weeklyVolume: 12,
        intensityMatch: 8,
      );
      expect(breakdown.total, 85);
    });

    test('default values are zero', () {
      const breakdown = ScoreBreakdown();
      expect(breakdown.total, 0);
      expect(breakdown.normalizedScore, 0);
    });

    test('normalizedScore caps at 100', () {
      const maxBreakdown = ScoreBreakdown(
        muscleRelevance: 30,
        exerciseType: 20,
        equipment: 15,
        difficultyMatch: 10,
        variety: 10,
        weeklyVolume: 15,
        intensityMatch: 10,
      );
      expect(maxBreakdown.total, 110);
      expect(maxBreakdown.normalizedScore, 100);
    });

    test('normalizedScore scales correctly', () {
      const half = ScoreBreakdown(
        muscleRelevance: 15,
        exerciseType: 10,
        equipment: 8,
        difficultyMatch: 5,
        variety: 5,
        weeklyVolume: 7,
        intensityMatch: 5,
      );
      // 55/110 * 100 = 50
      expect(half.normalizedScore, 50);
    });
  });

  group('AlternativeExercise', () {
    test('stores all fields', () {
      const alt = AlternativeExercise(
        exerciseId: 'ex_1',
        exerciseName: 'Dumbbell Bench Press',
        score: 85,
        shortReason: 'Same pattern, dumbbells',
        equipment: 'Dumbbells',
        countingMode: ExerciseCountingMode.reps,
      );
      expect(alt.exerciseId, 'ex_1');
      expect(alt.score, 85);
      expect(alt.countingMode, ExerciseCountingMode.reps);
    });
  });

  group('RepZoneSuggestion', () {
    test('copyWith preserves unchanged fields', () {
      const original = RepZoneSuggestion(
        exerciseId: 'ex_1',
        exerciseName: 'Bench Press',
        targetZone: RepZone.strength,
        targetTemplate: 'Push Day',
        targetTemplateId: 'tmpl_1',
        recommendedSets: 3,
        recommendedReps: 5,
        recommendedRestSeconds: 180,
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Barbell',
        reasonKey: 'balanceStrength',
        countingMode: ExerciseCountingMode.reps,
        score: 80,
      );

      final copied = original.copyWith(score: 95);
      expect(copied.exerciseId, 'ex_1');
      expect(copied.exerciseName, 'Bench Press');
      expect(copied.targetZone, RepZone.strength);
      expect(copied.score, 95);
    });

    test('copyWith updates specified fields', () {
      const original = RepZoneSuggestion(
        exerciseId: 'ex_1',
        exerciseName: 'Bench Press',
        targetZone: RepZone.strength,
        targetTemplate: 'Push Day',
        targetTemplateId: 'tmpl_1',
        recommendedSets: 3,
        recommendedReps: 5,
        recommendedRestSeconds: 180,
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Barbell',
        reasonKey: 'balanceStrength',
        countingMode: ExerciseCountingMode.reps,
      );

      final copied = original.copyWith(
        exerciseName: 'Incline Bench Press',
        targetZone: RepZone.hypertrophy,
        recommendedReps: 10,
      );
      expect(copied.exerciseName, 'Incline Bench Press');
      expect(copied.targetZone, RepZone.hypertrophy);
      expect(copied.recommendedReps, 10);
      expect(copied.exerciseId, 'ex_1'); // Unchanged
    });

    test('default v2 fields', () {
      const suggestion = RepZoneSuggestion(
        exerciseId: 'ex_1',
        exerciseName: 'Test',
        targetZone: RepZone.strength,
        targetTemplate: 'Test',
        targetTemplateId: 'tmpl_1',
        recommendedSets: 3,
        recommendedReps: 5,
        recommendedRestSeconds: 180,
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'None',
        reasonKey: 'test',
        countingMode: ExerciseCountingMode.reps,
      );
      expect(suggestion.score, 0);
      expect(suggestion.motivations, isEmpty);
      expect(suggestion.alternatives, isEmpty);
      expect(suggestion.exerciseType, isNull);
      expect(suggestion.musclesFocus, isEmpty);
      expect(suggestion.daysSinceLastDone, isNull);
    });
  });
}
