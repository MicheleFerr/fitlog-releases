import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rest_pause_template_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    RestPauseTemplateLoader.clearCache();
  });

  group('RestPauseTemplateLoader', () {
    group('loadPredefinedTemplates', () {
      test('loads templates from JSON asset', () async {
        final templates =
            await RestPauseTemplateLoader.loadPredefinedTemplates();

        expect(templates, isNotEmpty);
        expect(templates.length, 6);
      });

      test('returns cached data on subsequent calls', () async {
        final first = await RestPauseTemplateLoader.loadPredefinedTemplates();
        final second = await RestPauseTemplateLoader.loadPredefinedTemplates();

        expect(identical(first, second), isTrue);
      });

      test('all templates have required fields', () async {
        final templates =
            await RestPauseTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(t.id, isNotEmpty);
          expect(t.name, isNotEmpty);
          expect(t.exerciseName, isNotEmpty);
          expect(t.initialReps, isNotEmpty);
          expect(t.clusters, greaterThan(0));
          expect(t.clusterReps, isNotEmpty);
          expect(t.pauseDuration, greaterThan(0));
          expect(t.totalSets, greaterThan(0));
          expect(t.estimatedTimeMinutes, greaterThan(0));
          expect(t.scientificBasis, isNotEmpty);
        }
      });

      test('concurrent calls return same result', () async {
        final futures = List.generate(
          5,
          (_) => RestPauseTemplateLoader.loadPredefinedTemplates(),
        );
        final results = await Future.wait(futures);

        for (final result in results) {
          expect(result.length, results.first.length);
        }
      });
    });

    group('clearCache', () {
      test('clears cached data so next load fetches again', () async {
        final first = await RestPauseTemplateLoader.loadPredefinedTemplates();
        RestPauseTemplateLoader.clearCache();
        final second = await RestPauseTemplateLoader.loadPredefinedTemplates();

        expect(identical(first, second), isFalse);
        expect(first.length, second.length);
      });

      test('can be called without prior load', () {
        expect(() => RestPauseTemplateLoader.clearCache(), returnsNormally);
      });

      test('can be called multiple times', () {
        expect(() {
          RestPauseTemplateLoader.clearCache();
          RestPauseTemplateLoader.clearCache();
        }, returnsNormally);
      });
    });

    group('loadBeginner', () {
      test('returns only beginner templates', () async {
        final templates = await RestPauseTemplateLoader.loadBeginner();

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.difficulty, RestPauseDifficulty.beginner);
        }
      });

      test('returns 1 beginner template', () async {
        final templates = await RestPauseTemplateLoader.loadBeginner();
        expect(templates.length, 1);
      });
    });

    group('loadIntermediate', () {
      test('returns only intermediate templates', () async {
        final templates = await RestPauseTemplateLoader.loadIntermediate();

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.difficulty, RestPauseDifficulty.intermediate);
        }
      });

      test('returns 3 intermediate templates', () async {
        final templates = await RestPauseTemplateLoader.loadIntermediate();
        expect(templates.length, 3);
      });
    });

    group('loadAdvanced', () {
      test('returns only advanced templates', () async {
        final templates = await RestPauseTemplateLoader.loadAdvanced();

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.difficulty, RestPauseDifficulty.advanced);
        }
      });

      test('returns 2 advanced templates', () async {
        final templates = await RestPauseTemplateLoader.loadAdvanced();
        expect(templates.length, 2);
      });
    });

    group('loadTimeEfficient', () {
      test('returns templates within default time limit (20 min)', () async {
        final templates = await RestPauseTemplateLoader.loadTimeEfficient();

        for (final t in templates) {
          expect(t.estimatedTimeMinutes, lessThanOrEqualTo(20));
        }
      });

      test('returns templates within custom time limit', () async {
        final templates = await RestPauseTemplateLoader.loadTimeEfficient(
          maxMinutes: 12,
        );

        for (final t in templates) {
          expect(t.estimatedTimeMinutes, lessThanOrEqualTo(12));
        }
      });

      test('returns all templates with high time limit', () async {
        final all = await RestPauseTemplateLoader.loadPredefinedTemplates();
        final efficient = await RestPauseTemplateLoader.loadTimeEfficient(
          maxMinutes: 100,
        );

        expect(efficient.length, all.length);
      });

      test('returns empty list with very low time limit', () async {
        final templates = await RestPauseTemplateLoader.loadTimeEfficient(
          maxMinutes: 0,
        );

        expect(templates, isEmpty);
      });

      test('boundary: returns templates exactly at limit', () async {
        final all = await RestPauseTemplateLoader.loadPredefinedTemplates();
        // Find the minimum time
        final minTime = all
            .map((t) => t.estimatedTimeMinutes)
            .reduce((a, b) => a < b ? a : b);

        final templates = await RestPauseTemplateLoader.loadTimeEfficient(
          maxMinutes: minTime,
        );

        expect(templates, isNotEmpty);
        for (final t in templates) {
          expect(t.estimatedTimeMinutes, equals(minTime));
        }
      });
    });

    group('filter methods use cache', () {
      test('all filter methods share the same cache', () async {
        await RestPauseTemplateLoader.loadBeginner();
        final intermediate = await RestPauseTemplateLoader.loadIntermediate();
        final advanced = await RestPauseTemplateLoader.loadAdvanced();
        final efficient = await RestPauseTemplateLoader.loadTimeEfficient();

        expect(intermediate, isNotEmpty);
        expect(advanced, isNotEmpty);
        expect(efficient, isNotEmpty);
      });

      test('sum of difficulty filters covers all templates '
          '(excluding intermediateAdvanced)', () async {
        final all = await RestPauseTemplateLoader.loadPredefinedTemplates();
        final beginner = await RestPauseTemplateLoader.loadBeginner();
        final intermediate = await RestPauseTemplateLoader.loadIntermediate();
        final advanced = await RestPauseTemplateLoader.loadAdvanced();

        final totalFiltered =
            beginner.length + intermediate.length + advanced.length;

        expect(totalFiltered, lessThanOrEqualTo(all.length));
      });
    });

    group('template data integrity', () {
      test('each template has a unique id', () async {
        final templates =
            await RestPauseTemplateLoader.loadPredefinedTemplates();
        final ids = templates.map((t) => t.id).toSet();

        expect(ids.length, templates.length);
      });

      test('pause durations are reasonable (5-30s)', () async {
        final templates =
            await RestPauseTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(
            t.pauseDuration,
            inInclusiveRange(5, 30),
            reason: 'Template ${t.id} has unreasonable pause duration',
          );
        }
      });

      test('cluster count is reasonable (1-5)', () async {
        final templates =
            await RestPauseTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(
            t.clusters,
            inInclusiveRange(1, 5),
            reason: 'Template ${t.id} has unreasonable cluster count',
          );
        }
      });

      test('rest between sets is positive', () async {
        final templates =
            await RestPauseTemplateLoader.loadPredefinedTemplates();

        for (final t in templates) {
          expect(t.restBetweenSets, greaterThan(0));
        }
      });
    });
  });
}
