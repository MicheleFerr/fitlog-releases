import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';

void main() {
  group('RestPauseDifficulty', () {
    test('has all expected values', () {
      expect(RestPauseDifficulty.values.length, 4);
      expect(RestPauseDifficulty.values, contains(RestPauseDifficulty.beginner));
      expect(
        RestPauseDifficulty.values,
        contains(RestPauseDifficulty.intermediate),
      );
      expect(
        RestPauseDifficulty.values,
        contains(RestPauseDifficulty.intermediateAdvanced),
      );
      expect(RestPauseDifficulty.values, contains(RestPauseDifficulty.advanced));
    });

    test('enum name strings are correct', () {
      expect(RestPauseDifficulty.beginner.name, 'beginner');
      expect(RestPauseDifficulty.intermediate.name, 'intermediate');
      expect(
        RestPauseDifficulty.intermediateAdvanced.name,
        'intermediateAdvanced',
      );
      expect(RestPauseDifficulty.advanced.name, 'advanced');
    });
  });

  group('RestPauseTemplate', () {
    final testDate = DateTime(2026, 1, 15);

    RestPauseTemplate createSubject({
      String id = 'rp-1',
      String name = 'Bench Rest-Pause',
      String? nameKey,
      String exerciseName = 'Bench Press',
      String initialReps = '6-8',
      int clusters = 3,
      String clusterReps = '2-4',
      int pauseDuration = 15,
      int totalSets = 3,
      int restBetweenSets = 180,
      RestPauseDifficulty difficulty = RestPauseDifficulty.intermediate,
      int estimatedTimeMinutes = 15,
      String scientificBasis = 'Maximizes motor unit recruitment',
      String? notes,
      String? tut,
      List<String>? equipmentRequired,
      List<String>? equipmentAlternatives,
      List<String>? targetMuscles,
      bool isCustom = false,
      DateTime? createdAt,
    }) {
      return RestPauseTemplate(
        id: id,
        name: name,
        nameKey: nameKey,
        exerciseName: exerciseName,
        initialReps: initialReps,
        clusters: clusters,
        clusterReps: clusterReps,
        pauseDuration: pauseDuration,
        totalSets: totalSets,
        restBetweenSets: restBetweenSets,
        difficulty: difficulty,
        estimatedTimeMinutes: estimatedTimeMinutes,
        scientificBasis: scientificBasis,
        notes: notes,
        tut: tut,
        equipmentRequired: equipmentRequired,
        equipmentAlternatives: equipmentAlternatives,
        targetMuscles: targetMuscles,
        isCustom: isCustom,
        createdAt: createdAt,
      );
    }

    group('factory creation', () {
      test('creates with all required fields', () {
        final template = createSubject();

        expect(template.id, 'rp-1');
        expect(template.name, 'Bench Rest-Pause');
        expect(template.exerciseName, 'Bench Press');
        expect(template.initialReps, '6-8');
        expect(template.clusters, 3);
        expect(template.clusterReps, '2-4');
        expect(template.pauseDuration, 15);
        expect(template.totalSets, 3);
        expect(template.restBetweenSets, 180);
        expect(template.difficulty, RestPauseDifficulty.intermediate);
        expect(template.estimatedTimeMinutes, 15);
        expect(template.scientificBasis, 'Maximizes motor unit recruitment');
      });

      test('nullable fields default to null', () {
        final template = createSubject();

        expect(template.nameKey, isNull);
        expect(template.notes, isNull);
        expect(template.tut, isNull);
        expect(template.equipmentRequired, isNull);
        expect(template.equipmentAlternatives, isNull);
        expect(template.targetMuscles, isNull);
        expect(template.createdAt, isNull);
      });

      test('isCustom defaults to false', () {
        final template = createSubject();
        expect(template.isCustom, false);
      });

      test('creates with all optional fields populated', () {
        final template = createSubject(
          nameKey: 'templateBenchRestPause',
          notes: 'Use spotter',
          tut: '2-0-1',
          equipmentRequired: ['Barbell', 'Bench'],
          equipmentAlternatives: ['Dumbbells'],
          targetMuscles: ['Chest', 'Triceps'],
          isCustom: true,
          createdAt: testDate,
        );

        expect(template.nameKey, 'templateBenchRestPause');
        expect(template.notes, 'Use spotter');
        expect(template.tut, '2-0-1');
        expect(template.equipmentRequired, ['Barbell', 'Bench']);
        expect(template.equipmentAlternatives, ['Dumbbells']);
        expect(template.targetMuscles, ['Chest', 'Triceps']);
        expect(template.isCustom, true);
        expect(template.createdAt, testDate);
      });

      test('creates beginner difficulty', () {
        final template = createSubject(
          difficulty: RestPauseDifficulty.beginner,
        );
        expect(template.difficulty, RestPauseDifficulty.beginner);
      });

      test('creates advanced difficulty', () {
        final template = createSubject(
          difficulty: RestPauseDifficulty.advanced,
        );
        expect(template.difficulty, RestPauseDifficulty.advanced);
      });

      test('creates intermediateAdvanced difficulty', () {
        final template = createSubject(
          difficulty: RestPauseDifficulty.intermediateAdvanced,
        );
        expect(template.difficulty, RestPauseDifficulty.intermediateAdvanced);
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
        final a = createSubject(id: 'rp-1');
        final b = createSubject(id: 'rp-2');

        expect(a, isNot(equals(b)));
      });

      test('different difficulty means not equal', () {
        final a = createSubject(difficulty: RestPauseDifficulty.beginner);
        final b = createSubject(difficulty: RestPauseDifficulty.advanced);

        expect(a, isNot(equals(b)));
      });

      test('different isCustom means not equal', () {
        final a = createSubject(isCustom: false);
        final b = createSubject(isCustom: true);

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new name', () {
        final original = createSubject();
        final copy = original.copyWith(name: 'Squat Rest-Pause');

        expect(copy.name, 'Squat Rest-Pause');
        expect(copy.id, original.id);
        expect(copy.exerciseName, original.exerciseName);
      });

      test('copies with new difficulty', () {
        final original = createSubject();
        final copy = original.copyWith(
          difficulty: RestPauseDifficulty.advanced,
        );

        expect(copy.difficulty, RestPauseDifficulty.advanced);
        expect(copy.name, original.name);
      });

      test('copies with new isCustom', () {
        final original = createSubject();
        final copy = original.copyWith(isCustom: true);

        expect(copy.isCustom, true);
      });

      test('copies with new notes', () {
        final original = createSubject();
        final copy = original.copyWith(notes: 'Warm up first');

        expect(copy.notes, 'Warm up first');
      });

      test('copies with new equipment lists', () {
        final original = createSubject();
        final copy = original.copyWith(
          equipmentRequired: ['Smith Machine'],
          targetMuscles: ['Legs'],
        );

        expect(copy.equipmentRequired, ['Smith Machine']);
        expect(copy.targetMuscles, ['Legs']);
      });

      test('returns equal object when no changes', () {
        final original = createSubject();
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('JSON serialization', () {
      test('toJson contains all required fields', () {
        final template = createSubject();
        final json = template.toJson();

        expect(json['id'], 'rp-1');
        expect(json['name'], 'Bench Rest-Pause');
        expect(json['exerciseName'], 'Bench Press');
        expect(json['initialReps'], '6-8');
        expect(json['clusters'], 3);
        expect(json['clusterReps'], '2-4');
        expect(json['pauseDuration'], 15);
        expect(json['totalSets'], 3);
        expect(json['restBetweenSets'], 180);
        expect(json['estimatedTimeMinutes'], 15);
        expect(json['scientificBasis'], 'Maximizes motor unit recruitment');
        expect(json['isCustom'], false);
      });

      test('toJson serializes difficulty enum correctly', () {
        final beginner = createSubject(
          difficulty: RestPauseDifficulty.beginner,
        );
        expect(beginner.toJson()['difficulty'], 'beginner');

        final intAdv = createSubject(
          difficulty: RestPauseDifficulty.intermediateAdvanced,
        );
        // intermediateAdvanced has @JsonValue('intermediate-advanced')
        expect(intAdv.toJson()['difficulty'], 'intermediate-advanced');
      });

      test('fromJson round-trip preserves all data', () {
        final original = createSubject(
          nameKey: 'key1',
          notes: 'Important notes',
          tut: '3-1-2',
          equipmentRequired: ['Barbell'],
          equipmentAlternatives: ['Dumbbells', 'Cables'],
          targetMuscles: ['Chest', 'Shoulders'],
          isCustom: true,
          createdAt: testDate,
        );
        final json = original.toJson();
        final restored = RestPauseTemplate.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson round-trip with minimal data', () {
        final original = createSubject();
        final json = original.toJson();
        final restored = RestPauseTemplate.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson handles intermediate-advanced JSON value', () {
        final json = createSubject().toJson();
        json['difficulty'] = 'intermediate-advanced';

        final template = RestPauseTemplate.fromJson(json);
        expect(
          template.difficulty,
          RestPauseDifficulty.intermediateAdvanced,
        );
      });

      test('fromJson with equipment lists', () {
        final json = createSubject().toJson();
        json['equipmentRequired'] = ['Bench', 'Barbell'];
        json['targetMuscles'] = ['Pectorals', 'Deltoids'];

        final template = RestPauseTemplate.fromJson(json);
        expect(template.equipmentRequired, ['Bench', 'Barbell']);
        expect(template.targetMuscles, ['Pectorals', 'Deltoids']);
      });
    });
  });
}
