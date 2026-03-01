/// UserFitnessQuestionnaire Entity Tests
///
/// Tests entity construction, JSON round-trip, validation extensions,
/// and all enum types for strength standards.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  UserFitnessQuestionnaire makeQuestionnaire({
    double bodyweightKg = 80.0,
    int age = 28,
    double heightCm = 178.0,
    BiologicalSex sex = BiologicalSex.male,
    ExperienceLevel experienceLevel = ExperienceLevel.intermediate,
    int? monthsOfTraining,
    double? benchPressMax,
    double? squatMax,
    double? deadliftMax,
    double? overheadPressMax,
    TrainingGoal trainingGoal = TrainingGoal.hypertrophy,
    bool hasInjuryHistory = false,
    InjuryDetails? injuryDetails,
    int currentPainLevel = 0,
    SuggestionStyle suggestionStyle = SuggestionStyle.balanced,
    DateTime? completedAt,
    bool allowPeriodicUpdates = true,
    SelfReportCalibration selfReportCalibration = SelfReportCalibration.realistic,
  }) {
    return UserFitnessQuestionnaire(
      bodyweightKg: bodyweightKg,
      age: age,
      heightCm: heightCm,
      sex: sex,
      experienceLevel: experienceLevel,
      monthsOfTraining: monthsOfTraining,
      benchPressMax: benchPressMax,
      squatMax: squatMax,
      deadliftMax: deadliftMax,
      overheadPressMax: overheadPressMax,
      trainingGoal: trainingGoal,
      hasInjuryHistory: hasInjuryHistory,
      injuryDetails: injuryDetails,
      currentPainLevel: currentPainLevel,
      suggestionStyle: suggestionStyle,
      completedAt: completedAt,
      allowPeriodicUpdates: allowPeriodicUpdates,
      selfReportCalibration: selfReportCalibration,
    );
  }

  // ---------------------------------------------------------------------------
  // BiologicalSex enum
  // ---------------------------------------------------------------------------

  group('BiologicalSex', () {
    test('male has correct labels', () {
      expect(BiologicalSex.male.labelIT, equals('Uomo'));
      expect(BiologicalSex.male.labelEN, equals('Male'));
    });

    test('female has correct labels', () {
      expect(BiologicalSex.female.labelIT, equals('Donna'));
      expect(BiologicalSex.female.labelEN, equals('Female'));
    });

    test('getLabel returns Italian for it locale', () {
      expect(BiologicalSex.male.getLabel('it'), equals('Uomo'));
      expect(BiologicalSex.female.getLabel('it'), equals('Donna'));
    });

    test('getLabel returns English for en locale', () {
      expect(BiologicalSex.male.getLabel('en'), equals('Male'));
      expect(BiologicalSex.female.getLabel('en'), equals('Female'));
    });
  });

  // ---------------------------------------------------------------------------
  // TrainingGoal enum
  // ---------------------------------------------------------------------------

  group('TrainingGoal', () {
    test('strength has 0.85 intensity factor', () {
      expect(TrainingGoal.strength.intensityFactor, equals(0.85));
    });

    test('hypertrophy has 0.70 intensity factor', () {
      expect(TrainingGoal.hypertrophy.intensityFactor, equals(0.70));
    });

    test('endurance has 0.55 intensity factor', () {
      expect(TrainingGoal.endurance.intensityFactor, equals(0.55));
    });

    test('all goals have unique intensity factors', () {
      final factors = TrainingGoal.values.map((g) => g.intensityFactor).toSet();
      expect(factors.length, equals(TrainingGoal.values.length));
    });

    test('getLabel returns Italian for it locale', () {
      expect(TrainingGoal.strength.getLabel('it'), equals('Forza'));
      expect(TrainingGoal.hypertrophy.getLabel('it'), equals('Ipertrofia'));
      expect(TrainingGoal.endurance.getLabel('it'), equals('Resistenza'));
    });

    test('getLabel returns English for en locale', () {
      expect(TrainingGoal.strength.getLabel('en'), equals('Strength'));
    });
  });

  // ---------------------------------------------------------------------------
  // SuggestionStyle enum
  // ---------------------------------------------------------------------------

  group('SuggestionStyle', () {
    test('conservative has 0.85 multiplier', () {
      expect(SuggestionStyle.conservative.multiplier, equals(0.85));
    });

    test('balanced has 1.00 multiplier', () {
      expect(SuggestionStyle.balanced.multiplier, equals(1.00));
    });

    test('aggressive has 1.15 multiplier', () {
      expect(SuggestionStyle.aggressive.multiplier, equals(1.15));
    });

    test('getLabel returns Italian for it locale', () {
      expect(SuggestionStyle.conservative.getLabel('it'), equals('Conservativo'));
      expect(SuggestionStyle.balanced.getLabel('it'), equals('Bilanciato'));
      expect(SuggestionStyle.aggressive.getLabel('it'), equals('Aggressivo'));
    });
  });

  // ---------------------------------------------------------------------------
  // SelfReportCalibration enum
  // ---------------------------------------------------------------------------

  group('SelfReportCalibration', () {
    test('has 3 values', () {
      expect(SelfReportCalibration.values.length, equals(3));
    });

    test('getLabel returns Italian for it locale', () {
      expect(SelfReportCalibration.optimistic.getLabel('it'), equals('Ottimista'));
      expect(SelfReportCalibration.realistic.getLabel('it'), equals('Realista'));
      expect(SelfReportCalibration.conservative.getLabel('it'), equals('Conservativo'));
    });

    test('getLabel returns English for en locale', () {
      expect(SelfReportCalibration.optimistic.getLabel('en'), equals('Optimistic'));
      expect(SelfReportCalibration.realistic.getLabel('en'), equals('Realistic'));
    });
  });

  // ---------------------------------------------------------------------------
  // InjuryRegion enum
  // ---------------------------------------------------------------------------

  group('InjuryRegion', () {
    test('has 9 values', () {
      expect(InjuryRegion.values.length, equals(9));
    });

    test('lowerBack has correct labels', () {
      expect(InjuryRegion.lowerBack.labelEN, equals('Lower Back'));
      expect(InjuryRegion.lowerBack.labelIT, equals('Lombare'));
    });

    test('shoulder returns correct locale label', () {
      expect(InjuryRegion.shoulder.getLabel('it'), equals('Spalla'));
      expect(InjuryRegion.shoulder.getLabel('en'), equals('Shoulder'));
    });
  });

  // ---------------------------------------------------------------------------
  // isValid extension
  // ---------------------------------------------------------------------------

  group('UserFitnessQuestionnaireExtension.isValid', () {
    test('returns true for valid data', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        age: 28,
        heightCm: 178.0,
      );
      expect(q.isValid, isTrue);
    });

    test('returns false when bodyweight < 40', () {
      final q = makeQuestionnaire(bodyweightKg: 35.0);
      expect(q.isValid, isFalse);
    });

    test('returns false when bodyweight > 200', () {
      final q = makeQuestionnaire(bodyweightKg: 250.0);
      expect(q.isValid, isFalse);
    });

    test('returns false when age < 13', () {
      final q = makeQuestionnaire(age: 10);
      expect(q.isValid, isFalse);
    });

    test('returns false when age > 100', () {
      final q = makeQuestionnaire(age: 110);
      expect(q.isValid, isFalse);
    });

    test('returns false when heightCm < 100', () {
      final q = makeQuestionnaire(heightCm: 80.0);
      expect(q.isValid, isFalse);
    });

    test('returns false when heightCm > 250', () {
      final q = makeQuestionnaire(heightCm: 260.0);
      expect(q.isValid, isFalse);
    });

    test('boundary: age 13 is valid', () {
      final q = makeQuestionnaire(age: 13);
      expect(q.isValid, isTrue);
    });

    test('boundary: bodyweight 40 is valid', () {
      final q = makeQuestionnaire(bodyweightKg: 40.0);
      expect(q.isValid, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // hasMaxLiftData
  // ---------------------------------------------------------------------------

  group('hasMaxLiftData', () {
    test('returns false when no max lift data', () {
      final q = makeQuestionnaire();
      expect(q.hasMaxLiftData, isFalse);
    });

    test('returns true when benchPressMax provided', () {
      final q = makeQuestionnaire(benchPressMax: 100.0);
      expect(q.hasMaxLiftData, isTrue);
    });

    test('returns true when squatMax provided', () {
      final q = makeQuestionnaire(squatMax: 120.0);
      expect(q.hasMaxLiftData, isTrue);
    });

    test('returns true when deadliftMax provided', () {
      final q = makeQuestionnaire(deadliftMax: 150.0);
      expect(q.hasMaxLiftData, isTrue);
    });

    test('returns true when overheadPressMax provided', () {
      final q = makeQuestionnaire(overheadPressMax: 60.0);
      expect(q.hasMaxLiftData, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // conservativeMultiplier
  // ---------------------------------------------------------------------------

  group('conservativeMultiplier', () {
    test('equals suggestionStyle.multiplier when no injury', () {
      final q = makeQuestionnaire(
        hasInjuryHistory: false,
        suggestionStyle: SuggestionStyle.balanced,
      );
      expect(q.conservativeMultiplier, equals(1.0));
    });

    test('reduces by 10% when hasInjuryHistory is true', () {
      final q = makeQuestionnaire(
        hasInjuryHistory: true,
        suggestionStyle: SuggestionStyle.balanced,
      );
      expect(q.conservativeMultiplier, closeTo(0.90, 0.001));
    });

    test('applies both style and injury adjustments', () {
      final q = makeQuestionnaire(
        hasInjuryHistory: true,
        suggestionStyle: SuggestionStyle.aggressive,
      );
      // 1.15 × 0.90 = 1.035
      expect(q.conservativeMultiplier, closeTo(1.15 * 0.90, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // adjustedExperienceLevel
  // ---------------------------------------------------------------------------

  group('adjustedExperienceLevel', () {
    test('returns same level when no injury', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.intermediate,
        hasInjuryHistory: false,
      );
      expect(q.adjustedExperienceLevel, equals(ExperienceLevel.intermediate));
    });

    test('drops one level when hasInjuryHistory is true', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.intermediate,
        hasInjuryHistory: true,
      );
      expect(q.adjustedExperienceLevel, equals(ExperienceLevel.novice));
    });

    test('untrained stays at untrained with injury (no drop)', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.untrained,
        hasInjuryHistory: true,
      );
      // Index 0 - 1 would underflow, code checks experienceLevel != untrained
      expect(q.adjustedExperienceLevel, equals(ExperienceLevel.untrained));
    });

    test('advanced drops to intermediate with injury', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.advanced,
        hasInjuryHistory: true,
      );
      expect(q.adjustedExperienceLevel, equals(ExperienceLevel.intermediate));
    });
  });

  // ---------------------------------------------------------------------------
  // isExperienceLevelRealistic
  // ---------------------------------------------------------------------------

  group('isExperienceLevelRealistic', () {
    test('returns true when monthsOfTraining is null', () {
      final q = makeQuestionnaire(monthsOfTraining: null);
      expect(q.isExperienceLevelRealistic, isTrue);
    });

    test('untrained: realistic when monthsOfTraining < 2', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.untrained,
        monthsOfTraining: 1,
      );
      expect(q.isExperienceLevelRealistic, isTrue);
    });

    test('untrained: unrealistic when monthsOfTraining >= 2', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.untrained,
        monthsOfTraining: 3,
      );
      expect(q.isExperienceLevelRealistic, isFalse);
    });

    test('novice: realistic when 2-6 months', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.novice,
        monthsOfTraining: 4,
      );
      expect(q.isExperienceLevelRealistic, isTrue);
    });

    test('intermediate: realistic when 6-24 months', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.intermediate,
        monthsOfTraining: 12,
      );
      expect(q.isExperienceLevelRealistic, isTrue);
    });

    test('advanced: realistic when 24-60 months', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.advanced,
        monthsOfTraining: 36,
      );
      expect(q.isExperienceLevelRealistic, isTrue);
    });

    test('elite: realistic when >= 60 months', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.elite,
        monthsOfTraining: 72,
      );
      expect(q.isExperienceLevelRealistic, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // isStale
  // ---------------------------------------------------------------------------

  group('isStale', () {
    test('returns true when completedAt is null', () {
      final q = makeQuestionnaire(completedAt: null);
      expect(q.isStale, isTrue);
    });

    test('returns false when completedAt is recent', () {
      final q = makeQuestionnaire(
        completedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(q.isStale, isFalse);
    });

    test('returns true when completedAt is > 6 months ago', () {
      final q = makeQuestionnaire(
        completedAt: DateTime.now().subtract(const Duration(days: 200)),
      );
      expect(q.isStale, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // areMaxLiftsRealisticForLevel
  // ---------------------------------------------------------------------------

  group('areMaxLiftsRealisticForLevel', () {
    test('returns true when no bench press max available', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.novice,
        benchPressMax: null,
      );
      expect(q.areMaxLiftsRealisticForLevel, isTrue);
    });

    test('returns true when no max lift data at all', () {
      final q = makeQuestionnaire(experienceLevel: ExperienceLevel.elite);
      expect(q.areMaxLiftsRealisticForLevel, isTrue);
    });

    test('novice with reasonable bench ratio is realistic', () {
      // Novice: benchRatio between 0.70 and 1.15
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        experienceLevel: ExperienceLevel.novice,
        benchPressMax: 72.0, // 0.90 ratio - within novice range
      );
      expect(q.areMaxLiftsRealisticForLevel, isTrue);
    });

    test('elite level with novice bench ratio is unrealistic', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        experienceLevel: ExperienceLevel.elite,
        benchPressMax: 60.0, // 0.75 ratio - way below elite range
      );
      expect(q.areMaxLiftsRealisticForLevel, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // calibratedExperienceLevel
  // ---------------------------------------------------------------------------

  group('calibratedExperienceLevel', () {
    test('returns experienceLevel when realistic self-reporting', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.intermediate,
        selfReportCalibration: SelfReportCalibration.realistic,
      );
      expect(q.calibratedExperienceLevel, equals(ExperienceLevel.intermediate));
    });

    test('drops one level when optimistic self-reporting', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.advanced,
        selfReportCalibration: SelfReportCalibration.optimistic,
      );
      expect(q.calibratedExperienceLevel, equals(ExperienceLevel.intermediate));
    });

    test('optimistic on untrained stays at untrained', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.untrained,
        selfReportCalibration: SelfReportCalibration.optimistic,
      );
      expect(q.calibratedExperienceLevel, equals(ExperienceLevel.untrained));
    });

    test('bumps up one level when conservative self-reporting', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.intermediate,
        selfReportCalibration: SelfReportCalibration.conservative,
      );
      expect(q.calibratedExperienceLevel, equals(ExperienceLevel.advanced));
    });

    test('conservative on elite stays at elite', () {
      final q = makeQuestionnaire(
        experienceLevel: ExperienceLevel.elite,
        selfReportCalibration: SelfReportCalibration.conservative,
      );
      expect(q.calibratedExperienceLevel, equals(ExperienceLevel.elite));
    });

    test('uses suggestedExperienceLevelFromLifts when unrealistic', () {
      // Elite level but with a bench ratio suggesting novice
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        experienceLevel: ExperienceLevel.elite,
        selfReportCalibration: SelfReportCalibration.realistic,
        benchPressMax: 60.0, // 0.75 ratio -> novice
      );
      // Since unrealistic, should use suggested level from lifts
      expect(
        q.calibratedExperienceLevel,
        isNot(equals(ExperienceLevel.elite)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // suggestedExperienceLevelFromLifts
  // ---------------------------------------------------------------------------

  group('suggestedExperienceLevelFromLifts', () {
    test('returns null when no benchPressMax', () {
      final q = makeQuestionnaire(benchPressMax: null);
      expect(q.suggestedExperienceLevelFromLifts, isNull);
    });

    test('returns untrained for low bench ratio', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        benchPressMax: 50.0, // 0.625 ratio < 0.75
      );
      expect(q.suggestedExperienceLevelFromLifts, equals(ExperienceLevel.untrained));
    });

    test('returns novice for bench ratio in [0.75, 1.0)', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        benchPressMax: 70.0, // 0.875 ratio
      );
      expect(q.suggestedExperienceLevelFromLifts, equals(ExperienceLevel.novice));
    });

    test('returns intermediate for bench ratio in [1.0, 1.3)', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        benchPressMax: 96.0, // 1.2 ratio
      );
      expect(q.suggestedExperienceLevelFromLifts, equals(ExperienceLevel.intermediate));
    });

    test('returns advanced for bench ratio in [1.3, 1.7)', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        benchPressMax: 120.0, // 1.5 ratio
      );
      expect(q.suggestedExperienceLevelFromLifts, equals(ExperienceLevel.advanced));
    });

    test('returns elite for bench ratio >= 1.7', () {
      final q = makeQuestionnaire(
        bodyweightKg: 80.0,
        benchPressMax: 160.0, // 2.0 ratio
      );
      expect(q.suggestedExperienceLevelFromLifts, equals(ExperienceLevel.elite));
    });
  });

  // ---------------------------------------------------------------------------
  // JSON round-trip
  // ---------------------------------------------------------------------------

  group('UserFitnessQuestionnaire - JSON round-trip', () {
    test('serialises and deserialises with defaults', () {
      final original = makeQuestionnaire();

      final json = original.toJson();
      final restored = UserFitnessQuestionnaire.fromJson(json);

      expect(restored.bodyweightKg, equals(80.0));
      expect(restored.age, equals(28));
      expect(restored.sex, equals(BiologicalSex.male));
      expect(restored.experienceLevel, equals(ExperienceLevel.intermediate));
      expect(restored.trainingGoal, equals(TrainingGoal.hypertrophy));
      expect(restored.suggestionStyle, equals(SuggestionStyle.balanced));
      expect(
        restored.selfReportCalibration,
        equals(SelfReportCalibration.realistic),
      );
    });

    test('serialises and deserialises with all optional fields', () {
      final now = DateTime(2025, 6, 1);
      final original = makeQuestionnaire(
        benchPressMax: 120.0,
        squatMax: 150.0,
        deadliftMax: 180.0,
        overheadPressMax: 80.0,
        monthsOfTraining: 36,
        hasInjuryHistory: true,
        injuryDetails: const InjuryDetails(
          injuryType: 'Lower back strain',
          region: InjuryRegion.lowerBack,
          monthsSinceInjury: 6,
          fullyRecovered: true,
        ),
        currentPainLevel: 2,
        completedAt: now,
        allowPeriodicUpdates: false,
        selfReportCalibration: SelfReportCalibration.optimistic,
      );

      final json = original.toJson();
      final restored = UserFitnessQuestionnaire.fromJson(json);

      expect(restored.benchPressMax, equals(120.0));
      expect(restored.squatMax, equals(150.0));
      expect(restored.monthsOfTraining, equals(36));
      expect(restored.hasInjuryHistory, isTrue);
      expect(restored.injuryDetails?.injuryType, equals('Lower back strain'));
      expect(restored.injuryDetails?.region, equals(InjuryRegion.lowerBack));
      expect(restored.injuryDetails?.fullyRecovered, isTrue);
      expect(restored.completedAt, equals(now));
      expect(restored.allowPeriodicUpdates, isFalse);
    });

    test('handles null optional fields gracefully', () {
      final original = makeQuestionnaire();
      final json = original.toJson();
      final restored = UserFitnessQuestionnaire.fromJson(json);

      expect(restored.benchPressMax, isNull);
      expect(restored.monthsOfTraining, isNull);
      expect(restored.injuryDetails, isNull);
      expect(restored.completedAt, isNull);
    });

    test('round-trips all BiologicalSex values', () {
      for (final sex in BiologicalSex.values) {
        final q = makeQuestionnaire(sex: sex);
        final json = q.toJson();
        final restored = UserFitnessQuestionnaire.fromJson(json);
        expect(restored.sex, equals(sex));
      }
    });

    test('round-trips all TrainingGoal values', () {
      for (final goal in TrainingGoal.values) {
        final q = makeQuestionnaire(trainingGoal: goal);
        final json = q.toJson();
        final restored = UserFitnessQuestionnaire.fromJson(json);
        expect(restored.trainingGoal, equals(goal));
      }
    });

    test('round-trips all SuggestionStyle values', () {
      for (final style in SuggestionStyle.values) {
        final q = makeQuestionnaire(suggestionStyle: style);
        final json = q.toJson();
        final restored = UserFitnessQuestionnaire.fromJson(json);
        expect(restored.suggestionStyle, equals(style));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // InjuryDetails - construction and JSON
  // ---------------------------------------------------------------------------

  group('InjuryDetails', () {
    test('creates with required fields and defaults', () {
      const details = InjuryDetails(
        injuryType: 'Shoulder impingement',
        region: InjuryRegion.shoulder,
        monthsSinceInjury: 3,
      );

      expect(details.injuryType, equals('Shoulder impingement'));
      expect(details.region, equals(InjuryRegion.shoulder));
      expect(details.monthsSinceInjury, equals(3));
      expect(details.fullyRecovered, isFalse);
      expect(details.inRehabilitation, isFalse);
      expect(details.aggravatingActivities, isEmpty);
    });

    test('JSON round-trip preserves all fields', () {
      const original = InjuryDetails(
        injuryType: 'Knee tendinitis',
        region: InjuryRegion.knee,
        monthsSinceInjury: 12,
        fullyRecovered: true,
        inRehabilitation: false,
        aggravatingActivities: ['Squats', 'Lunges'],
      );

      final json = original.toJson();
      final restored = InjuryDetails.fromJson(json);

      expect(restored.injuryType, equals('Knee tendinitis'));
      expect(restored.region, equals(InjuryRegion.knee));
      expect(restored.monthsSinceInjury, equals(12));
      expect(restored.fullyRecovered, isTrue);
      expect(restored.aggravatingActivities, equals(['Squats', 'Lunges']));
    });

    test('copyWith updates single field', () {
      const original = InjuryDetails(
        injuryType: 'Wrist pain',
        region: InjuryRegion.wrist,
        monthsSinceInjury: 2,
      );
      final updated = original.copyWith(monthsSinceInjury: 6);

      expect(updated.monthsSinceInjury, equals(6));
      expect(updated.injuryType, equals('Wrist pain'));
    });
  });

  // ---------------------------------------------------------------------------
  // UserFitnessQuestionnaire - copyWith
  // ---------------------------------------------------------------------------

  group('UserFitnessQuestionnaire - copyWith', () {
    test('updates trainingGoal', () {
      final original = makeQuestionnaire(trainingGoal: TrainingGoal.hypertrophy);
      final updated = original.copyWith(trainingGoal: TrainingGoal.strength);

      expect(updated.trainingGoal, equals(TrainingGoal.strength));
      expect(original.trainingGoal, equals(TrainingGoal.hypertrophy));
    });

    test('updates bodyweightKg', () {
      final original = makeQuestionnaire(bodyweightKg: 80.0);
      final updated = original.copyWith(bodyweightKg: 85.0);

      expect(updated.bodyweightKg, equals(85.0));
    });
  });
}
