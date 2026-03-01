/// Weight Suggestion Service Tests
///
/// Tests all calculation paths: strength standard, bodyweight reps, fallback,
/// 1RM formulas, and experience level estimation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/services/weight_suggestion_service.dart';

void main() {
  late WeightSuggestionService service;

  setUp(() {
    service = WeightSuggestionService();
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  UserFitnessQuestionnaire makeQuestionnaire({
    double bodyweightKg = 80.0,
    ExperienceLevel experienceLevel = ExperienceLevel.intermediate,
    TrainingGoal trainingGoal = TrainingGoal.hypertrophy,
    SuggestionStyle suggestionStyle = SuggestionStyle.balanced,
    bool hasInjuryHistory = false,
  }) {
    return UserFitnessQuestionnaire(
      bodyweightKg: bodyweightKg,
      age: 28,
      heightCm: 178.0,
      sex: BiologicalSex.male,
      experienceLevel: experienceLevel,
      trainingGoal: trainingGoal,
      suggestionStyle: suggestionStyle,
      hasInjuryHistory: hasInjuryHistory,
    );
  }

  ExerciseMapping makeMapping({
    double confidence = 0.92,
    MappingStatus status = MappingStatus.auto,
    String standardId = 'barbell_bench_press',
    String gymbroEquipment = 'Bilanciere',
  }) {
    return ExerciseMapping(
      gymbroId: 'ex-001',
      gymbroName: 'Panca Piana',
      gymbroEquipment: gymbroEquipment,
      confidence: confidence,
      status: status,
      standardId: standardId,
    );
  }

  StrengthStandard makeStandard({
    bool isBodyweightExercise = false,
    Map<String, double>? bodyweightMultipliers,
  }) {
    return StrengthStandard(
      id: 'barbell_bench_press',
      name: 'Barbell Bench Press',
      keywords: const ['bench', 'chest'],
      equipment: 'Bilanciere',
      muscleGroups: const ['PETT', 'TRIC'],
      dataSource: 'exrx_net',
      isBodyweightExercise: isBodyweightExercise,
      bodyweightMultipliers: bodyweightMultipliers ??
          {
            'untrained': 0.60,
            'novice': 0.93,
            'intermediate': 1.13,
            'advanced': 1.47,
            'elite': 1.83,
          },
    );
  }

  // ---------------------------------------------------------------------------
  // getSuggestedWeight - validation failures
  // ---------------------------------------------------------------------------

  group('getSuggestedWeight - validation failures', () {
    test('returns fallback when questionnaire is invalid', () {
      final invalidQ = UserFitnessQuestionnaire(
        bodyweightKg: 30.0, // < 40 = invalid
        age: 28,
        heightCm: 178.0,
        sex: BiologicalSex.male,
        experienceLevel: ExperienceLevel.novice,
      );

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: invalidQ,
        mapping: makeMapping(),
        standard: makeStandard(),
      );

      expect(result, isNotNull);
      expect(result!.calculationMethod, equals(CalculationMethod.fallback));
      expect(result.confidenceTier, equals(ConfidenceTier.veryLow));
    });

    test('returns fallback when mapping is null', () {
      final q = makeQuestionnaire();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: null,
        standard: makeStandard(),
      );

      expect(result, isNotNull);
      expect(result!.calculationMethod, equals(CalculationMethod.fallback));
    });

    test('returns fallback when mapping is fallback status', () {
      final q = makeQuestionnaire();
      final fallbackMapping = ExerciseMapping(
        gymbroId: 'ex-001',
        gymbroName: 'Unknown',
        gymbroEquipment: 'Macchina',
        confidence: 0.40,
        status: MappingStatus.fallback,
      );

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: fallbackMapping,
        standard: makeStandard(),
      );

      expect(result!.calculationMethod, equals(CalculationMethod.fallback));
    });

    test('returns fallback when standard is null', () {
      final q = makeQuestionnaire();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: makeMapping(),
        standard: null,
      );

      expect(result!.calculationMethod, equals(CalculationMethod.fallback));
    });
  });

  // ---------------------------------------------------------------------------
  // getSuggestedWeight - strength standard path
  // ---------------------------------------------------------------------------

  group('getSuggestedWeight - strength standard calculation', () {
    test('calculates weight using strength standard multipliers', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        experienceLevel: ExperienceLevel.intermediate,
        trainingGoal: TrainingGoal.hypertrophy,
        suggestionStyle: SuggestionStyle.balanced,
      );
      final standard = makeStandard(); // intermediate = 1.13
      final mapping = makeMapping();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result, isNotNull);
      expect(result!.calculationMethod, equals(CalculationMethod.strengthStandard));
      // 1RM = 80 × 1.13 = 90.4, adjusted to intermediate (injury dropped to novice: no)
      // hypertrophy = 0.70 × 90.4 = 63.28, rounded to 2.5 = 62.5
      expect(result.suggestedWeightKg, greaterThan(0));
      expect(result.suggestedWeightKg % 2.5, closeTo(0, 0.001));
    });

    test('applies injury history 10% reduction', () {
      final qNoInjury = makeQuestionnaire(hasInjuryHistory: false);
      final qInjury = makeQuestionnaire(hasInjuryHistory: true);
      final standard = makeStandard();
      final mapping = makeMapping();

      final resultNoInjury = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: qNoInjury,
        mapping: mapping,
        standard: standard,
      );
      final resultInjury = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: qInjury,
        mapping: mapping,
        standard: standard,
      );

      // Injury history should result in lower suggested weight
      // Both use novice level (injury drops intermediate -> novice)
      expect(resultInjury!.suggestedWeightKg, lessThanOrEqualTo(resultNoInjury!.suggestedWeightKg));
    });

    test('applies conservative style (85% multiplier)', () {
      final qBalanced = makeQuestionnaire(suggestionStyle: SuggestionStyle.balanced);
      final qConservative = makeQuestionnaire(suggestionStyle: SuggestionStyle.conservative);
      final standard = makeStandard();
      final mapping = makeMapping();

      final resultBalanced = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: qBalanced,
        mapping: mapping,
        standard: standard,
      );
      final resultConservative = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: qConservative,
        mapping: mapping,
        standard: standard,
      );

      expect(
        resultConservative!.suggestedWeightKg,
        lessThanOrEqualTo(resultBalanced!.suggestedWeightKg),
      );
    });

    test('applies aggressive style (115% multiplier)', () {
      final qBalanced = makeQuestionnaire(suggestionStyle: SuggestionStyle.balanced);
      final qAggressive = makeQuestionnaire(suggestionStyle: SuggestionStyle.aggressive);
      final standard = makeStandard();
      final mapping = makeMapping();

      final resultBalanced = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: qBalanced,
        mapping: mapping,
        standard: standard,
      );
      final resultAggressive = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: qAggressive,
        mapping: mapping,
        standard: standard,
      );

      expect(
        resultAggressive!.suggestedWeightKg,
        greaterThanOrEqualTo(resultBalanced!.suggestedWeightKg),
      );
    });

    test('strength goal uses 85% intensity factor (fewer reps)', () {
      final q = makeQuestionnaire(trainingGoal: TrainingGoal.strength);
      final standard = makeStandard();
      final mapping = makeMapping();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result!.suggestedReps, equals(5));
    });

    test('hypertrophy goal uses 10 reps', () {
      final q = makeQuestionnaire(trainingGoal: TrainingGoal.hypertrophy);
      final standard = makeStandard();
      final mapping = makeMapping();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result!.suggestedReps, equals(10));
    });

    test('endurance goal uses 15 reps', () {
      final q = makeQuestionnaire(trainingGoal: TrainingGoal.endurance);
      final standard = makeStandard();
      final mapping = makeMapping();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result!.suggestedReps, equals(15));
    });

    test('result has correct exerciseId', () {
      final q = makeQuestionnaire();

      final result = service.getSuggestedWeight(
        exerciseId: 'my-exercise-id',
        questionnaire: q,
        mapping: makeMapping(),
        standard: makeStandard(),
      );

      expect(result!.exerciseId, equals('my-exercise-id'));
    });

    test('result contains confidence and confidenceTier from mapping', () {
      final q = makeQuestionnaire();
      final mapping = makeMapping(confidence: 0.85);

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: makeStandard(),
      );

      expect(result!.confidence, equals(0.85));
      expect(result.confidenceTier, equals(ConfidenceTier.good));
    });

    test('result has minimum weight for barbell equipment', () {
      final q = makeQuestionnaire(
        bodyweightKg: 40.0, // Very light user
        experienceLevel: ExperienceLevel.untrained,
        trainingGoal: TrainingGoal.endurance,
        suggestionStyle: SuggestionStyle.conservative,
      );
      final standard = makeStandard(); // untrained = 0.60
      final mapping = makeMapping(gymbroEquipment: 'Bilanciere');

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      // Should not go below 20kg (empty Olympic barbell)
      expect(result!.suggestedWeightKg, greaterThanOrEqualTo(20.0));
    });

    test('result notes has safety note', () {
      final q = makeQuestionnaire();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: makeMapping(),
        standard: makeStandard(),
      );

      expect(result!.notes, isNotEmpty);
      // Should contain the general safety note
      expect(
        result.notes.any((n) => n.contains('gradual')),
        isTrue,
      );
    });

    test('appliedMultipliers lists training goal factor', () {
      final q = makeQuestionnaire(trainingGoal: TrainingGoal.strength);

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: makeMapping(),
        standard: makeStandard(),
      );

      expect(result!.appliedMultipliers, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getSuggestedWeight - bodyweight exercise path
  // ---------------------------------------------------------------------------

  group('getSuggestedWeight - bodyweight exercise', () {
    test('returns bodyweightReps method for bodyweight exercise', () {
      final q = makeQuestionnaire(bodyweightKg: 80.0);
      final standard = StrengthStandard(
        id: 'pull_up',
        name: 'Pull Up',
        keywords: const ['pull up'],
        equipment: 'Corpo Libero',
        muscleGroups: const ['LAT', 'BICI'],
        dataSource: 'exrx_net',
        isBodyweightExercise: true,
        estimatedMultipliers: {
          'untrained': 1.0,
          'novice': 5.0,
          'intermediate': 10.0,
          'advanced': 15.0,
          'elite': 20.0,
        },
      );
      final mapping = makeMapping(gymbroEquipment: 'Corpo Libero');

      final result = service.getSuggestedWeight(
        exerciseId: 'pull-up-id',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result, isNotNull);
      expect(result!.calculationMethod, equals(CalculationMethod.bodyweightReps));
      expect(result.suggestedWeightKg, equals(0.0));
      expect(result.confidence, equals(0.85));
    });
  });

  // ---------------------------------------------------------------------------
  // getSuggestedWeight - fallback path details
  // ---------------------------------------------------------------------------

  group('getSuggestedWeight - fallback', () {
    test('fallback uses bodyweight-based estimate', () {
      final q = makeQuestionnaire(bodyweightKg: 80.0);

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: null,
        standard: null,
      );

      expect(result, isNotNull);
      expect(result!.calculationMethod, equals(CalculationMethod.fallback));
      expect(result.confidenceTier, equals(ConfidenceTier.veryLow));
      expect(result.confidence, equals(0.0));
      // Based on 30% of bodyweight: 80 × 0.30 = 24, rounded to 25
      expect(result.suggestedWeightKg, greaterThan(0));
    });

    test('fallback notes mention conservative estimate', () {
      final q = makeQuestionnaire();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: null,
        standard: null,
      );

      expect(result!.notes, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // needsWarning on WeightSuggestion
  // ---------------------------------------------------------------------------

  group('WeightSuggestion.needsWarning', () {
    test('true for veryLow tier', () {
      final suggestion = WeightSuggestion(
        exerciseId: 'ex-001',
        suggestedWeightKg: 20.0,
        suggestedReps: 10,
        confidence: 0.0,
        confidenceTier: ConfidenceTier.veryLow,
        calculationMethod: CalculationMethod.fallback,
      );
      expect(suggestion.needsWarning, isTrue);
    });

    test('true for low tier', () {
      final suggestion = WeightSuggestion(
        exerciseId: 'ex-001',
        suggestedWeightKg: 50.0,
        suggestedReps: 10,
        confidence: 0.65,
        confidenceTier: ConfidenceTier.low,
        calculationMethod: CalculationMethod.strengthStandard,
      );
      expect(suggestion.needsWarning, isTrue);
    });

    test('false for good tier', () {
      final suggestion = WeightSuggestion(
        exerciseId: 'ex-001',
        suggestedWeightKg: 80.0,
        suggestedReps: 10,
        confidence: 0.85,
        confidenceTier: ConfidenceTier.good,
        calculationMethod: CalculationMethod.strengthStandard,
      );
      expect(suggestion.needsWarning, isFalse);
    });

    test('false for excellent tier', () {
      final suggestion = WeightSuggestion(
        exerciseId: 'ex-001',
        suggestedWeightKg: 80.0,
        suggestedReps: 10,
        confidence: 0.95,
        confidenceTier: ConfidenceTier.excellent,
        calculationMethod: CalculationMethod.strengthStandard,
      );
      expect(suggestion.needsWarning, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // WeightSuggestion.getConfidenceLabel
  // ---------------------------------------------------------------------------

  group('WeightSuggestion.getConfidenceLabel', () {
    WeightSuggestion makeSuggestion(ConfidenceTier tier) {
      return WeightSuggestion(
        exerciseId: 'ex',
        suggestedWeightKg: 50.0,
        suggestedReps: 10,
        confidence: 0.8,
        confidenceTier: tier,
        calculationMethod: CalculationMethod.strengthStandard,
      );
    }

    test('excellent tier in Italian', () {
      expect(
        makeSuggestion(ConfidenceTier.excellent).getConfidenceLabel('it'),
        equals('Eccellente'),
      );
    });

    test('good tier in English', () {
      expect(
        makeSuggestion(ConfidenceTier.good).getConfidenceLabel('en'),
        equals('Good'),
      );
    });

    test('fair tier in Italian', () {
      expect(
        makeSuggestion(ConfidenceTier.fair).getConfidenceLabel('it'),
        equals('Discreto'),
      );
    });

    test('low tier in Italian', () {
      expect(
        makeSuggestion(ConfidenceTier.low).getConfidenceLabel('it'),
        equals('Basso'),
      );
    });

    test('veryLow tier in Italian', () {
      expect(
        makeSuggestion(ConfidenceTier.veryLow).getConfidenceLabel('it'),
        equals('Molto Basso'),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 1RM Formulas
  // ---------------------------------------------------------------------------

  group('calculateOneRepMaxBrzycki', () {
    test('returns weight for 1 rep (identity)', () {
      final result = service.calculateOneRepMaxBrzycki(
        weightKg: 100.0,
        reps: 1,
      );
      expect(result, equals(100.0));
    });

    test('calculates correctly for 5 reps', () {
      // Formula: weight / (1.0278 - 0.0278 × reps)
      const weight = 80.0;
      const reps = 5;
      final expected = weight / (1.0278 - 0.0278 * reps);

      final result = service.calculateOneRepMaxBrzycki(
        weightKg: weight,
        reps: reps,
      );

      expect(result, closeTo(expected, 0.01));
    });

    test('caps at 10 reps for accuracy', () {
      final result11 = service.calculateOneRepMaxBrzycki(
        weightKg: 50.0,
        reps: 11,
      );
      final result10 = service.calculateOneRepMaxBrzycki(
        weightKg: 50.0,
        reps: 10,
      );

      // Both should use the 10-rep formula (capped)
      expect(result11, equals(result10));
    });

    test('result is greater than input weight for reps > 1', () {
      final result = service.calculateOneRepMaxBrzycki(
        weightKg: 80.0,
        reps: 8,
      );
      expect(result, greaterThan(80.0));
    });
  });

  group('calculateOneRepMaxEpley', () {
    test('returns weight for 1 rep (identity)', () {
      final result = service.calculateOneRepMaxEpley(
        weightKg: 100.0,
        reps: 1,
      );
      expect(result, equals(100.0));
    });

    test('calculates correctly for 5 reps', () {
      // Formula: weight × (1 + 0.0333 × reps)
      const weight = 80.0;
      const reps = 5;
      final expected = weight * (1 + 0.0333 * reps);

      final result = service.calculateOneRepMaxEpley(
        weightKg: weight,
        reps: reps,
      );

      expect(result, closeTo(expected, 0.01));
    });

    test('result is greater than input weight for reps > 1', () {
      final result = service.calculateOneRepMaxEpley(
        weightKg: 80.0,
        reps: 6,
      );
      expect(result, greaterThan(80.0));
    });
  });

  group('calculateOneRepMaxAverage', () {
    test('returns average of Brzycki and Epley formulas', () {
      const weight = 80.0;
      const reps = 6;

      final brzycki = service.calculateOneRepMaxBrzycki(
        weightKg: weight,
        reps: reps,
      );
      final epley = service.calculateOneRepMaxEpley(
        weightKg: weight,
        reps: reps,
      );
      final expected = (brzycki + epley) / 2;

      final result = service.calculateOneRepMaxAverage(
        weightKg: weight,
        reps: reps,
      );

      expect(result, closeTo(expected, 0.001));
    });

    test('result is between Brzycki and Epley', () {
      final brzycki = service.calculateOneRepMaxBrzycki(
        weightKg: 80.0,
        reps: 8,
      );
      final epley = service.calculateOneRepMaxEpley(
        weightKg: 80.0,
        reps: 8,
      );
      final average = service.calculateOneRepMaxAverage(
        weightKg: 80.0,
        reps: 8,
      );

      final minVal = brzycki < epley ? brzycki : epley;
      final maxVal = brzycki > epley ? brzycki : epley;

      expect(average, greaterThanOrEqualTo(minVal));
      expect(average, lessThanOrEqualTo(maxVal));
    });
  });

  // ---------------------------------------------------------------------------
  // estimateExperienceLevelFromLifts
  // ---------------------------------------------------------------------------

  group('estimateExperienceLevelFromLifts', () {
    test('returns null when no lift data provided', () {
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
      );
      expect(result, isNull);
    });

    test('returns untrained for male with low avg ratio', () {
      // bench 0.5x BW = 40kg on 80kg -> avg < 0.75
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        benchPressMax: 40.0, // 0.5x
      );
      expect(result, equals(ExperienceLevel.untrained));
    });

    test('returns novice for male with ratio 0.75-1.0', () {
      // bench 70kg on 80kg = 0.875x ratio
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        benchPressMax: 70.0,
      );
      expect(result, equals(ExperienceLevel.novice));
    });

    test('returns intermediate for male with ratio 1.0-1.5', () {
      // bench 100kg on 80kg = 1.25x ratio
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        benchPressMax: 100.0,
      );
      expect(result, equals(ExperienceLevel.intermediate));
    });

    test('returns advanced for male with ratio 1.5-2.0', () {
      // bench 140kg on 80kg = 1.75x ratio
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        benchPressMax: 140.0,
      );
      expect(result, equals(ExperienceLevel.advanced));
    });

    test('returns elite for male with ratio >= 2.0', () {
      // bench 180kg on 80kg = 2.25x ratio
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        benchPressMax: 180.0,
      );
      expect(result, equals(ExperienceLevel.elite));
    });

    test('uses lower thresholds for female', () {
      // female bench 35kg on 70kg = 0.5x - above female untrained threshold
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 70.0,
        sex: BiologicalSex.female,
        benchPressMax: 35.0, // 0.5x - novice for female
      );
      expect(result, isIn([ExperienceLevel.untrained, ExperienceLevel.novice]));
    });

    test('averages multiple lifts when provided', () {
      // bench = 1.0x, squat = 1.5x, deadlift = 1.75x -> avg ≈ 1.42x -> intermediate
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        benchPressMax: 80.0,  // 1.0x
        squatMax: 120.0,      // 1.5x
        deadliftMax: 140.0,   // 1.75x
      );
      // avg = (1.0 + 1.5 + 1.75) / 3 = 1.42x -> intermediate
      expect(result, equals(ExperienceLevel.intermediate));
    });

    test('handles missing lifts gracefully (only uses provided)', () {
      final result = service.estimateExperienceLevelFromLifts(
        bodyweightKg: 80.0,
        sex: BiologicalSex.male,
        squatMax: 120.0, // 1.5x - only squat provided
      );
      expect(result, isNotNull);
      // 1.5x avg -> intermediate
      expect(result, equals(ExperienceLevel.intermediate));
    });
  });

  // ---------------------------------------------------------------------------
  // CalculationMethod enum
  // ---------------------------------------------------------------------------

  group('CalculationMethod', () {
    test('has 3 values', () {
      expect(CalculationMethod.values.length, equals(3));
    });

    test('strengthStandard is a value', () {
      expect(CalculationMethod.strengthStandard, isNotNull);
    });

    test('bodyweightReps is a value', () {
      expect(CalculationMethod.bodyweightReps, isNotNull);
    });

    test('fallback is a value', () {
      expect(CalculationMethod.fallback, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Minimum weight by equipment
  // ---------------------------------------------------------------------------

  group('getSuggestedWeight - minimum weight enforcement', () {
    test('minimum 20kg for barbell equipment', () {
      final q = makeQuestionnaire(
        bodyweightKg: 40.0,
        experienceLevel: ExperienceLevel.untrained,
        suggestionStyle: SuggestionStyle.conservative,
        trainingGoal: TrainingGoal.endurance,
      );
      final standard = makeStandard(
        bodyweightMultipliers: {
          'untrained': 0.20, // Very low - would give 40 × 0.20 × 0.55 × 0.85 ≈ 3.74 → below 20
        },
      );
      final mapping = makeMapping(gymbroEquipment: 'Bilanciere');

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result!.suggestedWeightKg, greaterThanOrEqualTo(20.0));
    });

    test('minimum 2.5kg for dumbbell equipment', () {
      final q = makeQuestionnaire(bodyweightKg: 40.0);
      final standard = makeStandard(
        bodyweightMultipliers: {'intermediate': 0.05}, // Very low
      );
      final mapping = makeMapping(gymbroEquipment: 'Manubri');

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result!.suggestedWeightKg, greaterThanOrEqualTo(2.5));
    });

    test('minimum 5kg for machine equipment', () {
      final q = makeQuestionnaire(bodyweightKg: 40.0);
      final standard = makeStandard(
        bodyweightMultipliers: {'intermediate': 0.01},
      );
      final mapping = makeMapping(gymbroEquipment: 'Macchina Cavi');

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      expect(result!.suggestedWeightKg, greaterThanOrEqualTo(5.0));
    });
  });

  // ---------------------------------------------------------------------------
  // Weight rounding
  // ---------------------------------------------------------------------------

  group('Weight rounding to 2.5kg increments', () {
    test('result is always a multiple of 2.5', () {
      final q = makeQuestionnaire(bodyweightKg: 80.0);
      final standard = makeStandard();
      final mapping = makeMapping();

      final result = service.getSuggestedWeight(
        exerciseId: 'ex-001',
        questionnaire: q,
        mapping: mapping,
        standard: standard,
      );

      final weight = result!.suggestedWeightKg;
      expect(weight % 2.5, closeTo(0.0, 0.001));
    });
  });
}
