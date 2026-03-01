import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';

void main() {
  group('UserPersona', () {
    test('has all expected values', () {
      expect(UserPersona.values.length, 6);
      expect(UserPersona.values, contains(UserPersona.marco));
      expect(UserPersona.values, contains(UserPersona.chiara));
      expect(UserPersona.values, contains(UserPersona.luca));
      expect(UserPersona.values, contains(UserPersona.sofia));
      expect(UserPersona.values, contains(UserPersona.roberto));
      expect(UserPersona.values, contains(UserPersona.generic));
    });

    test('enum name strings are correct', () {
      expect(UserPersona.marco.name, 'marco');
      expect(UserPersona.chiara.name, 'chiara');
      expect(UserPersona.luca.name, 'luca');
      expect(UserPersona.sofia.name, 'sofia');
      expect(UserPersona.roberto.name, 'roberto');
      expect(UserPersona.generic.name, 'generic');
    });
  });

  group('TemplateDifficulty', () {
    test('has all expected values', () {
      expect(TemplateDifficulty.values.length, 4);
      expect(TemplateDifficulty.values, contains(TemplateDifficulty.beginner));
      expect(
        TemplateDifficulty.values,
        contains(TemplateDifficulty.intermediate),
      );
      expect(
        TemplateDifficulty.values,
        contains(TemplateDifficulty.intermediateAdvanced),
      );
      expect(TemplateDifficulty.values, contains(TemplateDifficulty.advanced));
    });

    test('enum name strings are correct', () {
      expect(TemplateDifficulty.beginner.name, 'beginner');
      expect(TemplateDifficulty.intermediate.name, 'intermediate');
      expect(
        TemplateDifficulty.intermediateAdvanced.name,
        'intermediateAdvanced',
      );
      expect(TemplateDifficulty.advanced.name, 'advanced');
    });
  });

  group('SupersetTemplate', () {
    final testDate = DateTime(2026, 2, 10);

    SupersetTemplate createSubject({
      String id = 'ss-1',
      String name = 'Chest-Back Superset',
      String? nameKey,
      List<String> exerciseIds = const ['ex-1', 'ex-2'],
      List<String> exerciseNames = const [],
      int rounds = 4,
      String repsRange = '8-12',
      int restAfterRound = 60,
      int restAfterSuperset = 120,
      TemplateDifficulty difficulty = TemplateDifficulty.intermediate,
      int estimatedTimeMinutes = 20,
      String scientificBasis = 'Agonist-antagonist pairing',
      String? notes,
      String? tut,
      List<String>? equipmentRequired,
      List<String>? equipmentAlternatives,
      UserPersona? targetPersona,
      List<String>? targetMuscles,
      bool isCustom = false,
      DateTime? createdAt,
    }) {
      return SupersetTemplate(
        id: id,
        name: name,
        nameKey: nameKey,
        exerciseIds: exerciseIds,
        exerciseNames: exerciseNames,
        rounds: rounds,
        repsRange: repsRange,
        restAfterRound: restAfterRound,
        restAfterSuperset: restAfterSuperset,
        difficulty: difficulty,
        estimatedTimeMinutes: estimatedTimeMinutes,
        scientificBasis: scientificBasis,
        notes: notes,
        tut: tut,
        equipmentRequired: equipmentRequired,
        equipmentAlternatives: equipmentAlternatives,
        targetPersona: targetPersona,
        targetMuscles: targetMuscles,
        isCustom: isCustom,
        createdAt: createdAt,
      );
    }

    group('factory creation', () {
      test('creates with all required fields', () {
        final template = createSubject();

        expect(template.id, 'ss-1');
        expect(template.name, 'Chest-Back Superset');
        expect(template.exerciseIds, ['ex-1', 'ex-2']);
        expect(template.rounds, 4);
        expect(template.repsRange, '8-12');
        expect(template.restAfterRound, 60);
        expect(template.restAfterSuperset, 120);
        expect(template.difficulty, TemplateDifficulty.intermediate);
        expect(template.estimatedTimeMinutes, 20);
        expect(template.scientificBasis, 'Agonist-antagonist pairing');
      });

      test('exerciseNames defaults to empty list', () {
        final template = createSubject();
        expect(template.exerciseNames, isEmpty);
      });

      test('isCustom defaults to false', () {
        final template = createSubject();
        expect(template.isCustom, false);
      });

      test('nullable fields default to null', () {
        final template = createSubject();

        expect(template.nameKey, isNull);
        expect(template.notes, isNull);
        expect(template.tut, isNull);
        expect(template.equipmentRequired, isNull);
        expect(template.equipmentAlternatives, isNull);
        expect(template.targetPersona, isNull);
        expect(template.targetMuscles, isNull);
        expect(template.createdAt, isNull);
      });

      test('creates with all optional fields', () {
        final template = createSubject(
          nameKey: 'templateChestBack',
          exerciseNames: ['Bench Press', 'Barbell Row'],
          notes: 'Great combo',
          tut: '2-0-2',
          equipmentRequired: ['Barbell', 'Bench'],
          equipmentAlternatives: ['Dumbbells'],
          targetPersona: UserPersona.luca,
          targetMuscles: ['Chest', 'Back'],
          isCustom: true,
          createdAt: testDate,
        );

        expect(template.nameKey, 'templateChestBack');
        expect(template.exerciseNames, ['Bench Press', 'Barbell Row']);
        expect(template.notes, 'Great combo');
        expect(template.tut, '2-0-2');
        expect(template.equipmentRequired, ['Barbell', 'Bench']);
        expect(template.equipmentAlternatives, ['Dumbbells']);
        expect(template.targetPersona, UserPersona.luca);
        expect(template.targetMuscles, ['Chest', 'Back']);
        expect(template.isCustom, true);
        expect(template.createdAt, testDate);
      });

      test('creates with each persona type', () {
        for (final persona in UserPersona.values) {
          final template = createSubject(targetPersona: persona);
          expect(template.targetPersona, persona);
        }
      });

      test('creates with each difficulty level', () {
        for (final difficulty in TemplateDifficulty.values) {
          final template = createSubject(difficulty: difficulty);
          expect(template.difficulty, difficulty);
        }
      });
    });

    group('equality', () {
      test('two instances with same values are equal', () {
        final a = createSubject();
        final b = createSubject();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different id means not equal', () {
        final a = createSubject(id: 'ss-1');
        final b = createSubject(id: 'ss-2');

        expect(a, isNot(equals(b)));
      });

      test('different exerciseIds means not equal', () {
        final a = createSubject(exerciseIds: ['ex-1', 'ex-2']);
        final b = createSubject(exerciseIds: ['ex-3', 'ex-4']);

        expect(a, isNot(equals(b)));
      });

      test('different targetPersona means not equal', () {
        final a = createSubject(targetPersona: UserPersona.marco);
        final b = createSubject(targetPersona: UserPersona.luca);

        expect(a, isNot(equals(b)));
      });

      test('different difficulty means not equal', () {
        final a = createSubject(difficulty: TemplateDifficulty.beginner);
        final b = createSubject(difficulty: TemplateDifficulty.advanced);

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new name', () {
        final original = createSubject();
        final copy = original.copyWith(name: 'Arms Superset');

        expect(copy.name, 'Arms Superset');
        expect(copy.id, original.id);
      });

      test('copies with new exerciseNames', () {
        final original = createSubject();
        final copy = original.copyWith(
          exerciseNames: ['Curl', 'Tricep Extension'],
        );

        expect(copy.exerciseNames, ['Curl', 'Tricep Extension']);
      });

      test('copies with new rounds', () {
        final original = createSubject();
        final copy = original.copyWith(rounds: 5);

        expect(copy.rounds, 5);
        expect(copy.repsRange, original.repsRange);
      });

      test('copies with new targetPersona', () {
        final original = createSubject();
        final copy = original.copyWith(targetPersona: UserPersona.sofia);

        expect(copy.targetPersona, UserPersona.sofia);
      });

      test('copies with new isCustom', () {
        final original = createSubject();
        final copy = original.copyWith(isCustom: true);

        expect(copy.isCustom, true);
      });

      test('returns equal object when no changes', () {
        final original = createSubject();
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('JSON serialization', () {
      test('toJson contains required fields', () {
        final template = createSubject();
        final json = template.toJson();

        expect(json['id'], 'ss-1');
        expect(json['name'], 'Chest-Back Superset');
        expect(json['exerciseIds'], ['ex-1', 'ex-2']);
        expect(json['rounds'], 4);
        expect(json['repsRange'], '8-12');
        expect(json['restAfterRound'], 60);
        expect(json['restAfterSuperset'], 120);
        expect(json['estimatedTimeMinutes'], 20);
        expect(json['isCustom'], false);
      });

      test('toJson serializes difficulty enum correctly', () {
        final beginner = createSubject(
          difficulty: TemplateDifficulty.beginner,
        );
        expect(beginner.toJson()['difficulty'], 'beginner');

        final intAdv = createSubject(
          difficulty: TemplateDifficulty.intermediateAdvanced,
        );
        expect(intAdv.toJson()['difficulty'], 'intermediate-advanced');
      });

      test('toJson serializes persona enum correctly', () {
        final template = createSubject(targetPersona: UserPersona.luca);
        expect(template.toJson()['targetPersona'], 'luca');
      });

      test('fromJson round-trip preserves all data', () {
        final original = createSubject(
          nameKey: 'key1',
          exerciseNames: ['Bench', 'Row'],
          notes: 'Notes here',
          tut: '3-0-1',
          equipmentRequired: ['Barbell'],
          equipmentAlternatives: ['Cables'],
          targetPersona: UserPersona.chiara,
          targetMuscles: ['Chest', 'Back'],
          isCustom: true,
          createdAt: testDate,
        );
        final json = original.toJson();
        final restored = SupersetTemplate.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson round-trip with minimal data', () {
        final original = createSubject();
        final json = original.toJson();
        final restored = SupersetTemplate.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson handles intermediate-advanced JSON value', () {
        final json = createSubject().toJson();
        json['difficulty'] = 'intermediate-advanced';

        final template = SupersetTemplate.fromJson(json);
        expect(
          template.difficulty,
          TemplateDifficulty.intermediateAdvanced,
        );
      });

      test('fromJson with empty exerciseNames defaults correctly', () {
        final json = createSubject().toJson();
        // exerciseNames should default to []
        json.remove('exerciseNames');

        final template = SupersetTemplate.fromJson(json);
        expect(template.exerciseNames, isEmpty);
      });
    });
  });
}
