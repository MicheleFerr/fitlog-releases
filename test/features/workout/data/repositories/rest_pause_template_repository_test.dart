import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/rest_pause_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import '../../../../test_helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
    setupFirebaseAuthPigeonMocks();
  });

  late RestPauseTemplateRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = RestPauseTemplateRepository();
  });

  group('RestPauseTemplateRepository', () {
    group('getCustomTemplates', () {
      test('returns empty list when no custom templates stored', () async {
        final templates = await repository.getCustomTemplates();
        expect(templates, isEmpty);
      });

      test('returns custom templates from SharedPreferences', () async {
        final template = RestPauseTemplate(
          id: 'custom-1',
          name: 'My Rest Pause',
          exerciseName: 'Bench Press',
          initialReps: '6-8',
          clusters: 3,
          clusterReps: '2-4',
          pauseDuration: 15,
          totalSets: 3,
          restBetweenSets: 180,
          difficulty: RestPauseDifficulty.intermediate,
          estimatedTimeMinutes: 20,
          scientificBasis: 'Test basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 15),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': json.encode([template.toJson()]),
        });
        final repo = RestPauseTemplateRepository();

        final templates = await repo.getCustomTemplates();

        expect(templates.length, 1);
        expect(templates[0].id, 'custom-1');
        expect(templates[0].name, 'My Rest Pause');
        expect(templates[0].isCustom, true);
      });

      test('filters out non-custom templates', () async {
        final customTemplate = RestPauseTemplate(
          id: 'custom-1',
          name: 'Custom',
          exerciseName: 'Press',
          initialReps: '6',
          clusters: 2,
          clusterReps: '3',
          pauseDuration: 15,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: RestPauseDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
        );
        final predefined = RestPauseTemplate(
          id: 'pred-1',
          name: 'Predefined',
          exerciseName: 'Row',
          initialReps: '8',
          clusters: 3,
          clusterReps: '2',
          pauseDuration: 20,
          totalSets: 2,
          restBetweenSets: 150,
          difficulty: RestPauseDifficulty.advanced,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          isCustom: false,
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': json.encode([
            customTemplate.toJson(),
            predefined.toJson(),
          ]),
        });
        final repo = RestPauseTemplateRepository();

        final result = await repo.getCustomTemplates();
        expect(result.length, 1);
        expect(result[0].id, 'custom-1');
      });

      test('returns empty list on parse error', () async {
        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': 'invalid json',
        });
        final repo = RestPauseTemplateRepository();

        final templates = await repo.getCustomTemplates();
        expect(templates, isEmpty);
      });
    });

    group('saveCustomTemplate', () {
      test('saves new custom template', () async {
        final template = RestPauseTemplate(
          id: 'new-1',
          name: 'New Rest Pause',
          exerciseName: 'Bench Press',
          initialReps: '6-8',
          clusters: 3,
          clusterReps: '2-4',
          pauseDuration: 15,
          totalSets: 3,
          restBetweenSets: 180,
          difficulty: RestPauseDifficulty.intermediate,
          estimatedTimeMinutes: 20,
          scientificBasis: 'Test',
          isCustom: true,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.saveCustomTemplate(template, maxCustomRestPause: 10);

        final saved = await repository.getCustomTemplates();
        expect(saved.length, 1);
        expect(saved[0].id, 'new-1');
        expect(saved[0].isCustom, true);
      });

      test('updates existing template by ID', () async {
        final existing = RestPauseTemplate(
          id: 'custom-1',
          name: 'Old Name',
          exerciseName: 'Press',
          initialReps: '6',
          clusters: 2,
          clusterReps: '3',
          pauseDuration: 15,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: RestPauseDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': json.encode([existing.toJson()]),
        });
        final repo = RestPauseTemplateRepository();

        final updated = existing.copyWith(name: 'New Name');
        await repo.saveCustomTemplate(updated, maxCustomRestPause: 10);

        final saved = await repo.getCustomTemplates();
        expect(saved.length, 1);
        expect(saved[0].name, 'New Name');
      });

      test('throws when limit reached for new template', () async {
        final templates = List.generate(
          3,
          (i) => RestPauseTemplate(
            id: 'custom-$i',
            name: 'Template $i',
            exerciseName: 'Exercise $i',
            initialReps: '8',
            clusters: 2,
            clusterReps: '3',
            pauseDuration: 15,
            totalSets: 2,
            restBetweenSets: 90,
            difficulty: RestPauseDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = RestPauseTemplateRepository();

        final newTemplate = RestPauseTemplate(
          id: 'new-1',
          name: 'New',
          exerciseName: 'Test',
          initialReps: '8',
          clusters: 2,
          clusterReps: '3',
          pauseDuration: 15,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: RestPauseDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
        );

        expect(
          () => repo.saveCustomTemplate(newTemplate, maxCustomRestPause: 3),
          throwsException,
        );
      });

      test('allows update even when at limit', () async {
        final templates = List.generate(
          3,
          (i) => RestPauseTemplate(
            id: 'custom-$i',
            name: 'Template $i',
            exerciseName: 'Exercise $i',
            initialReps: '8',
            clusters: 2,
            clusterReps: '3',
            pauseDuration: 15,
            totalSets: 2,
            restBetweenSets: 90,
            difficulty: RestPauseDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = RestPauseTemplateRepository();

        final updated = templates[0].copyWith(name: 'Updated');
        await repo.saveCustomTemplate(updated, maxCustomRestPause: 3);

        final saved = await repo.getCustomTemplates();
        expect(saved.length, 3);
      });
    });

    group('deleteCustomTemplate', () {
      test('deletes existing custom template', () async {
        final template = RestPauseTemplate(
          id: 'custom-1',
          name: 'To Delete',
          exerciseName: 'Press',
          initialReps: '6',
          clusters: 2,
          clusterReps: '3',
          pauseDuration: 15,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: RestPauseDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': json.encode([template.toJson()]),
        });
        final repo = RestPauseTemplateRepository();

        await repo.deleteCustomTemplate('custom-1');

        final remaining = await repo.getCustomTemplates();
        expect(remaining, isEmpty);
      });

      test('throws when template not found', () async {
        SharedPreferences.setMockInitialValues({});
        final repo = RestPauseTemplateRepository();

        expect(
          () => repo.deleteCustomTemplate('nonexistent'),
          throwsException,
        );
      });
    });

    group('searchTemplates', () {
      // searchTemplates calls getAllTemplates which combines predefined + custom.
      // Tests use unique names to avoid collisions with predefined templates.

      test('searches by name case-insensitively', () async {
        final templates = [
          RestPauseTemplate(
            id: 'c-1',
            name: 'Xyzzy Unique RP',
            exerciseName: 'Xyzzy Press',
            initialReps: '6',
            clusters: 3,
            clusterReps: '3',
            pauseDuration: 15,
            totalSets: 3,
            restBetweenSets: 180,
            difficulty: RestPauseDifficulty.intermediate,
            estimatedTimeMinutes: 20,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          RestPauseTemplate(
            id: 'c-2',
            name: 'Squat RP',
            exerciseName: 'Squat',
            initialReps: '5',
            clusters: 2,
            clusterReps: '2',
            pauseDuration: 20,
            totalSets: 2,
            restBetweenSets: 240,
            difficulty: RestPauseDifficulty.advanced,
            estimatedTimeMinutes: 25,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = RestPauseTemplateRepository();

        final results = await repo.searchTemplates('xyzzy');
        expect(results.length, 1);
        expect(results[0].id, 'c-1');
      });

      test('searches by target muscles', () async {
        final template = RestPauseTemplate(
          id: 'c-1',
          name: 'RP Set',
          exerciseName: 'Curl',
          initialReps: '8',
          clusters: 2,
          clusterReps: '3',
          pauseDuration: 15,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: RestPauseDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          targetMuscles: ['zqwvtmuscle', 'forearms'],
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': json.encode([template.toJson()]),
        });
        final repo = RestPauseTemplateRepository();

        final results = await repo.searchTemplates('zqwvtmuscle');
        expect(results.length, 1);
      });

      test('returns empty when no match', () async {
        final template = RestPauseTemplate(
          id: 'c-1',
          name: 'RP Set',
          exerciseName: 'Curl',
          initialReps: '8',
          clusters: 2,
          clusterReps: '3',
          pauseDuration: 15,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: RestPauseDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null': json.encode([template.toJson()]),
        });
        final repo = RestPauseTemplateRepository();

        final results = await repo.searchTemplates('zznonexistentzz');
        expect(results, isEmpty);
      });
    });

    group('getTemplatesByDifficulty', () {
      test('filters by difficulty', () async {
        final templates = [
          RestPauseTemplate(
            id: 'c-1',
            name: 'Beginner RP',
            exerciseName: 'Curl',
            initialReps: '8',
            clusters: 2,
            clusterReps: '3',
            pauseDuration: 20,
            totalSets: 2,
            restBetweenSets: 120,
            difficulty: RestPauseDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          RestPauseTemplate(
            id: 'c-2',
            name: 'Advanced RP',
            exerciseName: 'Bench',
            initialReps: '5',
            clusters: 4,
            clusterReps: '1-2',
            pauseDuration: 10,
            totalSets: 4,
            restBetweenSets: 180,
            difficulty: RestPauseDifficulty.advanced,
            estimatedTimeMinutes: 25,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'restpause_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = RestPauseTemplateRepository();

        final beginnerResults =
            await repo.getTemplatesByDifficulty(RestPauseDifficulty.beginner);

        // Verify custom beginner template is in results
        expect(beginnerResults.any((t) => t.id == 'c-1'), isTrue);
        // Verify advanced custom template is not in beginner results
        expect(beginnerResults.any((t) => t.id == 'c-2'), isFalse);
        // All results should have beginner difficulty
        for (final t in beginnerResults) {
          expect(t.difficulty, RestPauseDifficulty.beginner);
        }
      });
    });
  });
}
