import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as db;
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/superset_template_loader.dart';

/// Helper to create a minimal ExerciseDefinition for mocking.
db.ExerciseDefinition _makeDbExercise(String id, String name) {
  return db.ExerciseDefinition(
    id: id,
    nome: name,
    focus: const ['PETT'],
    muscoliSecondari: const ['TRIC'],
    difficolta: 'intermedio',
    tipoEsercizio: 'composto',
    attrezzatura: 'bilanciere',
    patternMovimento: 'push',
    rangeRipetizioni: '8-12',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SupersetTemplateLoader.clearCache();
  });

  group('SupersetTemplateLoader', () {
    group('loadPredefinedTemplates', () {
      test('loads templates from JSON asset', () async {
        final templates =
            await SupersetTemplateLoader.loadPredefinedTemplates();

        expect(templates, isNotEmpty);
        expect(templates.length, 18);
      });

      test('returns cached data on subsequent calls', () async {
        final first = await SupersetTemplateLoader.loadPredefinedTemplates();
        final second = await SupersetTemplateLoader.loadPredefinedTemplates();

        expect(identical(first, second), isTrue);
      });

      test('all templates have required fields', () async {
        final templates =
            await SupersetTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(t.id, isNotEmpty);
          expect(t.name, isNotEmpty);
          expect(t.exerciseIds, isNotEmpty);
          expect(t.rounds, greaterThan(0));
          expect(t.repsRange, isNotEmpty);
          expect(t.estimatedTimeMinutes, greaterThan(0));
          expect(t.scientificBasis, isNotEmpty);
        }
      });

      test('concurrent calls return same result', () async {
        final futures = List.generate(
          5,
          (_) => SupersetTemplateLoader.loadPredefinedTemplates(),
        );
        final results = await Future.wait(futures);

        for (final result in results) {
          expect(result.length, results.first.length);
        }
      });

      test('without lookupExercise returns empty exerciseNames', () async {
        final templates =
            await SupersetTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(t.exerciseNames, isEmpty);
        }
      });

      test('with lookupExercise resolves exercise names', () async {
        Future<db.Exercise?> mockLookup(String exerciseId) async {
          return _makeDbExercise(exerciseId, 'Exercise $exerciseId');
        }

        final templates = await SupersetTemplateLoader.loadPredefinedTemplates(
          lookupExercise: mockLookup,
        );

        for (final t in templates) {
          expect(t.exerciseNames.length, t.exerciseIds.length);
          for (final name in t.exerciseNames) {
            expect(name, startsWith('Exercise '));
          }
        }
      });

      test('lookupExercise fallback when exercise not found', () async {
        Future<db.Exercise?> mockLookup(String exerciseId) async {
          return null;
        }

        final templates = await SupersetTemplateLoader.loadPredefinedTemplates(
          lookupExercise: mockLookup,
        );

        // Should use ID-based fallback (replaceAll('_', ' ').capitalize())
        for (final t in templates) {
          expect(t.exerciseNames.length, t.exerciseIds.length);
          for (final name in t.exerciseNames) {
            expect(name, isNotEmpty);
          }
        }
      });

      test('lookupExercise fallback when lookup throws', () async {
        Future<db.Exercise?> mockLookup(String exerciseId) async {
          throw Exception('Lookup failed');
        }

        final templates = await SupersetTemplateLoader.loadPredefinedTemplates(
          lookupExercise: mockLookup,
        );

        // Should use ID-based fallback
        for (final t in templates) {
          expect(t.exerciseNames.length, t.exerciseIds.length);
        }
      });

      test('lookupExercise does not cache resolved names', () async {
        int callCount = 0;
        Future<db.Exercise?> mockLookup(String exerciseId) async {
          callCount++;
          return _makeDbExercise(exerciseId, 'Name $callCount');
        }

        await SupersetTemplateLoader.loadPredefinedTemplates(
          lookupExercise: mockLookup,
        );
        final firstCallCount = callCount;

        await SupersetTemplateLoader.loadPredefinedTemplates(
          lookupExercise: mockLookup,
        );

        // The base templates are cached, but exercise name resolution runs again
        expect(callCount, greaterThan(firstCallCount));
      });
    });

    group('clearCache', () {
      test('clears cached data', () async {
        final first = await SupersetTemplateLoader.loadPredefinedTemplates();
        SupersetTemplateLoader.clearCache();
        final second = await SupersetTemplateLoader.loadPredefinedTemplates();

        expect(identical(first, second), isFalse);
        expect(first.length, second.length);
      });

      test('can be called without prior load', () {
        expect(() => SupersetTemplateLoader.clearCache(), returnsNormally);
      });
    });

    group('loadForPersona', () {
      test('returns templates for specific persona', () async {
        final templates = await SupersetTemplateLoader.loadForPersona(
          UserPersona.marco,
        );

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(
            t.targetPersona == UserPersona.marco || t.targetPersona == null,
            isTrue,
            reason: 'Template ${t.id} should target marco or be generic',
          );
        }
      });

      test('includes generic (null persona) templates', () async {
        final templates = await SupersetTemplateLoader.loadForPersona(
          UserPersona.luca,
        );

        final genericCount = templates
            .where((t) => t.targetPersona == null)
            .length;
        expect(genericCount, greaterThan(0));
      });

      test('different personas get different results', () async {
        final marco = await SupersetTemplateLoader.loadForPersona(
          UserPersona.marco,
        );
        final luca = await SupersetTemplateLoader.loadForPersona(
          UserPersona.luca,
        );

        // Both should include generic templates but also persona-specific ones
        final marcoIds = marco.map((t) => t.id).toSet();
        final lucaIds = luca.map((t) => t.id).toSet();

        // They should share some generic templates but differ
        expect(marcoIds, isNot(equals(lucaIds)));
      });

      test('passes lookupExercise through', () async {
        Future<db.Exercise?> mockLookup(String exerciseId) async {
          return _makeDbExercise(exerciseId, 'Resolved $exerciseId');
        }

        final templates = await SupersetTemplateLoader.loadForPersona(
          UserPersona.chiara,
          lookupExercise: mockLookup,
        );

        for (final t in templates) {
          expect(t.exerciseNames, isNotEmpty);
        }
      });
    });

    group('loadEvidenceBased', () {
      test('returns only templates with scientific basis', () async {
        final templates = await SupersetTemplateLoader.loadEvidenceBased();

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.scientificBasis, isNotEmpty);
        }
      });

      test('all current templates are evidence-based', () async {
        final all = await SupersetTemplateLoader.loadPredefinedTemplates();
        final evidenceBased = await SupersetTemplateLoader.loadEvidenceBased();

        // All 18 templates have scientificBasis
        expect(evidenceBased.length, all.length);
      });
    });

    group('loadTimeEfficient', () {
      test('returns templates within default range (15-20 min)', () async {
        final templates = await SupersetTemplateLoader.loadTimeEfficient();

        for (final t in templates) {
          expect(t.estimatedTimeMinutes, greaterThanOrEqualTo(15));
          expect(t.estimatedTimeMinutes, lessThanOrEqualTo(20));
        }
      });

      test('returns templates within custom range', () async {
        final templates = await SupersetTemplateLoader.loadTimeEfficient(
          minMinutes: 10,
          maxMinutes: 15,
        );

        for (final t in templates) {
          expect(t.estimatedTimeMinutes, greaterThanOrEqualTo(10));
          expect(t.estimatedTimeMinutes, lessThanOrEqualTo(15));
        }
      });

      test('returns empty with impossible range', () async {
        final templates = await SupersetTemplateLoader.loadTimeEfficient(
          minMinutes: 100,
          maxMinutes: 200,
        );

        expect(templates, isEmpty);
      });

      test('wide range returns all templates', () async {
        final all = await SupersetTemplateLoader.loadPredefinedTemplates();
        final wide = await SupersetTemplateLoader.loadTimeEfficient(
          minMinutes: 0,
          maxMinutes: 1000,
        );

        expect(wide.length, all.length);
      });
    });

    group('loadBeginner', () {
      test('returns only beginner templates', () async {
        final templates = await SupersetTemplateLoader.loadBeginner();

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.difficulty, TemplateDifficulty.beginner);
        }
      });

      test('returns 4 beginner templates', () async {
        final templates = await SupersetTemplateLoader.loadBeginner();
        expect(templates.length, 4);
      });
    });

    group('loadAdvanced', () {
      test('returns only advanced templates', () async {
        final templates = await SupersetTemplateLoader.loadAdvanced();

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.difficulty, TemplateDifficulty.advanced);
        }
      });

      test('returns 3 advanced templates', () async {
        final templates = await SupersetTemplateLoader.loadAdvanced();
        expect(templates.length, 3);
      });
    });

    group('template data integrity', () {
      test('each template has a unique id', () async {
        final templates =
            await SupersetTemplateLoader.loadPredefinedTemplates();
        final ids = templates.map((t) => t.id).toSet();

        expect(ids.length, templates.length);
      });

      test('each template has at least 2 exercise IDs', () async {
        final templates =
            await SupersetTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(
            t.exerciseIds.length,
            greaterThanOrEqualTo(2),
            reason: 'Superset ${t.id} should have at least 2 exercises',
          );
        }
      });

      test('rest times are positive', () async {
        final templates =
            await SupersetTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(t.restAfterRound, greaterThanOrEqualTo(0));
          expect(t.restAfterSuperset, greaterThanOrEqualTo(0));
        }
      });
    });
  });

  group('StringCapitalize extension', () {
    test('capitalizes first letter', () {
      expect('hello'.capitalize(), 'Hello');
    });

    test('handles single character', () {
      expect('a'.capitalize(), 'A');
    });

    test('returns empty string for empty input', () {
      expect(''.capitalize(), '');
    });

    test('handles already capitalized', () {
      expect('Hello'.capitalize(), 'Hello');
    });

    test('preserves rest of string', () {
      expect('hELLO wORLD'.capitalize(), 'HELLO wORLD');
    });
  });
}
