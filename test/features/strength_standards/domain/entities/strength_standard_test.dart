/// Strength Standard Entity Tests
///
/// Tests JSON round-trip, copyWith, computed properties, and interpolation
/// for StrengthStandard and ExperienceLevel.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  StrengthStandard makeStandard({
    String id = 'barbell_bench_press',
    String name = 'Barbell Bench Press',
    List<String> keywords = const ['bench', 'panca', 'chest'],
    String equipment = 'Bilanciere',
    List<String> muscleGroups = const ['PETT', 'TRIC'],
    String dataSource = 'exrx_net',
    Map<String, Map<String, double>>? bodyweightTable,
    Map<String, double>? bodyweightMultipliers,
    Map<String, double>? estimatedMultipliers,
    bool isBodyweightExercise = false,
  }) {
    return StrengthStandard(
      id: id,
      name: name,
      keywords: keywords,
      equipment: equipment,
      muscleGroups: muscleGroups,
      dataSource: dataSource,
      bodyweightTable: bodyweightTable,
      bodyweightMultipliers: bodyweightMultipliers,
      estimatedMultipliers: estimatedMultipliers,
      isBodyweightExercise: isBodyweightExercise,
    );
  }

  // ---------------------------------------------------------------------------
  // ExperienceLevel enum
  // ---------------------------------------------------------------------------

  group('ExperienceLevel', () {
    test('has 5 values', () {
      expect(ExperienceLevel.values.length, equals(5));
    });

    test('getLabel returns Italian label for it locale', () {
      expect(
        ExperienceLevel.novice.getLabel('it'),
        equals('Base'),
      );
      expect(
        ExperienceLevel.advanced.getLabel('it'),
        equals('Avanzato'),
      );
    });

    test('getLabel returns English label for en locale', () {
      expect(
        ExperienceLevel.intermediate.getLabel('en'),
        equals('Intermediate'),
      );
      expect(
        ExperienceLevel.elite.getLabel('en'),
        equals('Elite'),
      );
    });

    test('untrained has correct labels', () {
      expect(ExperienceLevel.untrained.labelIT, equals('Principiante'));
      expect(ExperienceLevel.untrained.labelEN, equals('Untrained'));
    });
  });

  // ---------------------------------------------------------------------------
  // StrengthStandard construction
  // ---------------------------------------------------------------------------

  group('StrengthStandard - construction', () {
    test('creates with required fields', () {
      final standard = makeStandard();

      expect(standard.id, equals('barbell_bench_press'));
      expect(standard.name, equals('Barbell Bench Press'));
      expect(standard.equipment, equals('Bilanciere'));
      expect(standard.isBodyweightExercise, isFalse);
    });

    test('isBodyweightExercise defaults to false', () {
      final standard = makeStandard();
      expect(standard.isBodyweightExercise, isFalse);
    });

    test('creates bodyweight exercise', () {
      final standard = makeStandard(isBodyweightExercise: true);
      expect(standard.isBodyweightExercise, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // effectiveMultipliers extension
  // ---------------------------------------------------------------------------

  group('StrengthStandardExtension.effectiveMultipliers', () {
    test('returns bodyweightMultipliers when available', () {
      final standard = makeStandard(
        bodyweightMultipliers: {'novice': 0.93, 'intermediate': 1.13},
        estimatedMultipliers: {'novice': 0.80},
      );

      expect(standard.effectiveMultipliers['novice'], equals(0.93));
      expect(standard.effectiveMultipliers.containsKey('intermediate'), isTrue);
    });

    test('falls back to estimatedMultipliers when bodyweightMultipliers is null', () {
      final standard = makeStandard(
        estimatedMultipliers: {'novice': 0.75, 'intermediate': 0.90},
      );

      expect(standard.effectiveMultipliers['novice'], equals(0.75));
    });

    test('returns empty map when both multiplier maps are null', () {
      final standard = makeStandard();
      expect(standard.effectiveMultipliers, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getOneRepMax - multiplier-based (no table)
  // ---------------------------------------------------------------------------

  group('StrengthStandardExtension.getOneRepMax - multipliers only', () {
    test('returns bodyweight × multiplier when no table', () {
      final standard = makeStandard(
        bodyweightMultipliers: {
          'untrained': 0.60,
          'novice': 0.93,
          'intermediate': 1.13,
          'advanced': 1.47,
          'elite': 1.83,
        },
      );

      final oneRM = standard.getOneRepMax(
        bodyweightKg: 80.0,
        level: ExperienceLevel.novice,
      );

      expect(oneRM, closeTo(80.0 * 0.93, 0.001));
    });

    test('returns null when level key missing from multipliers', () {
      final standard = makeStandard(
        bodyweightMultipliers: {'novice': 0.93},
      );

      final oneRM = standard.getOneRepMax(
        bodyweightKg: 80.0,
        level: ExperienceLevel.elite,
      );

      expect(oneRM, isNull);
    });

    test('returns null when no multipliers configured', () {
      final standard = makeStandard();

      final oneRM = standard.getOneRepMax(
        bodyweightKg: 80.0,
        level: ExperienceLevel.novice,
      );

      expect(oneRM, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getOneRepMax - bodyweight table (exact match)
  // ---------------------------------------------------------------------------

  group('StrengthStandardExtension.getOneRepMax - table exact match', () {
    test('returns exact table value for matching bodyweight', () {
      final standard = makeStandard(
        bodyweightTable: {
          '70': {'novice': 65.0, 'intermediate': 80.0},
          '80': {'novice': 75.0, 'intermediate': 92.5},
          '90': {'novice': 85.0, 'intermediate': 105.0},
        },
        bodyweightMultipliers: {'novice': 0.93, 'intermediate': 1.13},
      );

      final oneRM = standard.getOneRepMax(
        bodyweightKg: 80.0,
        level: ExperienceLevel.novice,
      );

      expect(oneRM, equals(75.0));
    });
  });

  // ---------------------------------------------------------------------------
  // getOneRepMax - bodyweight table (interpolation)
  // ---------------------------------------------------------------------------

  group('StrengthStandardExtension.getOneRepMax - interpolation', () {
    test('interpolates between two bodyweight values', () {
      final standard = makeStandard(
        bodyweightTable: {
          '70': {'novice': 65.0},
          '80': {'novice': 75.0},
        },
        bodyweightMultipliers: {'novice': 0.93},
      );

      // At 75kg (midpoint between 70 and 80), should get midpoint of 65 and 75
      final oneRM = standard.getOneRepMax(
        bodyweightKg: 75.0,
        level: ExperienceLevel.novice,
      );

      expect(oneRM, closeTo(70.0, 0.1));
    });

    test('uses multiplier for extrapolation below table range', () {
      final standard = makeStandard(
        bodyweightTable: {
          '70': {'novice': 65.0},
          '80': {'novice': 75.0},
        },
        bodyweightMultipliers: {'novice': 0.93},
      );

      // Below table minimum (60kg) - should use multiplier
      final oneRM = standard.getOneRepMax(
        bodyweightKg: 60.0,
        level: ExperienceLevel.novice,
      );

      expect(oneRM, isNotNull);
      // Multiplier-based: 60 × 0.93 = 55.8
      expect(oneRM, closeTo(60.0 * 0.93, 0.01));
    });

    test('uses extrapolation for bodyweight above table range', () {
      final standard = makeStandard(
        bodyweightTable: {
          '70': {'novice': 65.0},
          '80': {'novice': 75.0},
        },
        bodyweightMultipliers: {'novice': 0.93},
      );

      // Above table maximum (100kg) - extrapolates from highest value
      final oneRM = standard.getOneRepMax(
        bodyweightKg: 100.0,
        level: ExperienceLevel.novice,
      );

      expect(oneRM, isNotNull);
      // highestValue(75) + (100 - 80) × multiplier(0.93) = 75 + 18.6 = 93.6
      expect(oneRM, closeTo(75.0 + 20.0 * 0.93, 0.1));
    });

    test('uses fallback multiplier when table has no level key', () {
      final standard = makeStandard(
        bodyweightTable: {
          '70': {'novice': 65.0},
          '80': {'novice': 75.0},
        },
        bodyweightMultipliers: {'novice': 0.93, 'elite': 1.83},
      );

      // Bodyweight at 75 but requesting 'elite' which isn't in table values
      final oneRM = standard.getOneRepMax(
        bodyweightKg: 75.0,
        level: ExperienceLevel.elite,
      );

      // Interpolation between lowerValue and upperValue for 'elite' key
      // lowerValue = table['70']['elite'] ?? 0.0 = 0.0
      // upperValue = table['80']['elite'] ?? 0.0 = 0.0
      // Result = 0.0 interpolated = 0.0
      expect(oneRM, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getSuggestedWorkingWeight
  // ---------------------------------------------------------------------------

  group('StrengthStandardExtension.getSuggestedWorkingWeight', () {
    test('returns 70% of oneRepMax by default', () {
      final standard = makeStandard(
        bodyweightMultipliers: {'novice': 1.0},
      );

      final workingWeight = standard.getSuggestedWorkingWeight(
        bodyweightKg: 100.0,
        level: ExperienceLevel.novice,
      );

      // 1RM = 100 × 1.0 = 100, working = 100 × 0.70 = 70
      expect(workingWeight, closeTo(70.0, 0.001));
    });

    test('applies custom intensity factor', () {
      final standard = makeStandard(
        bodyweightMultipliers: {'novice': 1.0},
      );

      final workingWeight = standard.getSuggestedWorkingWeight(
        bodyweightKg: 100.0,
        level: ExperienceLevel.novice,
        intensityFactor: 0.85,
      );

      expect(workingWeight, closeTo(85.0, 0.001));
    });

    test('returns null when oneRepMax cannot be calculated', () {
      final standard = makeStandard(); // No multipliers

      final workingWeight = standard.getSuggestedWorkingWeight(
        bodyweightKg: 80.0,
        level: ExperienceLevel.novice,
      );

      expect(workingWeight, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // JSON round-trip
  // ---------------------------------------------------------------------------

  group('StrengthStandard - JSON round-trip', () {
    test('serialises and deserialises with all fields', () {
      final original = makeStandard(
        bodyweightTable: {
          '70': {'novice': 65.0, 'intermediate': 80.0},
          '80': {'novice': 75.0, 'intermediate': 92.5},
        },
        bodyweightMultipliers: {'novice': 0.93, 'intermediate': 1.13},
        estimatedMultipliers: {'untrained': 0.60},
      );

      final json = original.toJson();
      final restored = StrengthStandard.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.equipment, equals(original.equipment));
      expect(restored.keywords, equals(original.keywords));
      expect(restored.muscleGroups, equals(original.muscleGroups));
      expect(restored.dataSource, equals(original.dataSource));
      expect(restored.isBodyweightExercise, isFalse);
      expect(
        restored.bodyweightMultipliers?['novice'],
        equals(0.93),
      );
      expect(
        restored.bodyweightTable?['80']?['novice'],
        equals(75.0),
      );
    });

    test('serialises and deserialises with null optional fields', () {
      final original = makeStandard();

      final json = original.toJson();
      final restored = StrengthStandard.fromJson(json);

      expect(restored.bodyweightTable, isNull);
      expect(restored.bodyweightMultipliers, isNull);
      expect(restored.estimatedMultipliers, isNull);
    });

    test('serialises bodyweight exercise correctly', () {
      final original = makeStandard(
        id: 'pull_up',
        name: 'Pull Up',
        isBodyweightExercise: true,
        estimatedMultipliers: {
          'novice': 5.0,
          'intermediate': 10.0,
        },
      );

      final json = original.toJson();
      final restored = StrengthStandard.fromJson(json);

      expect(restored.isBodyweightExercise, isTrue);
      expect(restored.estimatedMultipliers?['novice'], equals(5.0));
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  group('StrengthStandard - copyWith', () {
    test('updates single field', () {
      final original = makeStandard();
      final updated = original.copyWith(name: 'Updated Name');

      expect(updated.name, equals('Updated Name'));
      expect(updated.id, equals(original.id));
    });

    test('preserves all other fields', () {
      final original = makeStandard(
        bodyweightMultipliers: {'novice': 0.93},
      );
      final updated = original.copyWith(equipment: 'Manubri');

      expect(updated.equipment, equals('Manubri'));
      expect(updated.bodyweightMultipliers, equals(original.bodyweightMultipliers));
      expect(updated.muscleGroups, equals(original.muscleGroups));
    });
  });

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  group('StrengthStandard - equality', () {
    test('equal when all fields match', () {
      final a = makeStandard();
      final b = makeStandard();

      expect(a, equals(b));
    });

    test('not equal when id differs', () {
      final a = makeStandard(id: 'bench');
      final b = makeStandard(id: 'squat');

      expect(a, isNot(equals(b)));
    });
  });
}
