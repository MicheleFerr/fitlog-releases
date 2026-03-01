import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/superset_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import '../../../../test_helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
    setupFirebaseAuthPigeonMocks();
  });

  late SupersetTemplateRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = SupersetTemplateRepository();
  });

  group('SupersetTemplateRepository', () {
    group('getCustomTemplates', () {
      test('returns empty list when no custom templates stored', () async {
        final templates = await repository.getCustomTemplates();
        expect(templates, isEmpty);
      });

      test('returns custom templates from SharedPreferences', () async {
        final template = SupersetTemplate(
          id: 'custom-1',
          name: 'My Superset',
          exerciseIds: ['ex-1', 'ex-2'],
          exerciseNames: ['Bench Press', 'Row'],
          rounds: 4,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 120,
          difficulty: TemplateDifficulty.intermediate,
          estimatedTimeMinutes: 20,
          scientificBasis: 'Antagonist pairing',
          isCustom: true,
          createdAt: DateTime(2024, 1, 15),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([template.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        final templates = await repo.getCustomTemplates();

        expect(templates.length, 1);
        expect(templates[0].id, 'custom-1');
        expect(templates[0].name, 'My Superset');
        expect(templates[0].isCustom, true);
      });

      test('filters out non-custom templates', () async {
        final custom = SupersetTemplate(
          id: 'custom-1',
          name: 'Custom SS',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.beginner,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          isCustom: true,
        );
        final predefined = SupersetTemplate(
          id: 'pred-1',
          name: 'Predefined SS',
          exerciseIds: ['ex-3', 'ex-4'],
          rounds: 4,
          repsRange: '10-15',
          restAfterRound: 20,
          restAfterSuperset: 60,
          difficulty: TemplateDifficulty.advanced,
          estimatedTimeMinutes: 25,
          scientificBasis: 'basis',
          isCustom: false,
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([
            custom.toJson(),
            predefined.toJson(),
          ]),
        });
        final repo = SupersetTemplateRepository();

        final result = await repo.getCustomTemplates();
        expect(result.length, 1);
        expect(result[0].id, 'custom-1');
      });

      test('returns empty list on parse error', () async {
        SharedPreferences.setMockInitialValues({
          'superset_templates_null': 'invalid json',
        });
        final repo = SupersetTemplateRepository();

        final templates = await repo.getCustomTemplates();
        expect(templates, isEmpty);
      });
    });

    group('saveCustomTemplate', () {
      test('saves new custom template', () async {
        final template = SupersetTemplate(
          id: 'new-1',
          name: 'New Superset',
          exerciseIds: ['ex-1', 'ex-2'],
          exerciseNames: ['Bench', 'Row'],
          rounds: 4,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 120,
          difficulty: TemplateDifficulty.intermediate,
          estimatedTimeMinutes: 20,
          scientificBasis: 'Test',
          isCustom: true,
          createdAt: DateTime(2024, 1, 15),
        );

        await repository.saveCustomTemplate(
          template,
          maxCustomSupersets: 10,
        );

        final saved = await repository.getCustomTemplates();
        expect(saved.length, 1);
        expect(saved[0].id, 'new-1');
        expect(saved[0].isCustom, true);
      });

      test('updates existing template by ID', () async {
        final existing = SupersetTemplate(
          id: 'custom-1',
          name: 'Old Name',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.beginner,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([existing.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        final updated = existing.copyWith(name: 'New Name');
        await repo.saveCustomTemplate(updated, maxCustomSupersets: 10);

        final saved = await repo.getCustomTemplates();
        expect(saved.length, 1);
        expect(saved[0].name, 'New Name');
      });

      test('throws when limit reached for new template', () async {
        final templates = List.generate(
          3,
          (i) => SupersetTemplate(
            id: 'custom-$i',
            name: 'Template $i',
            exerciseIds: ['ex-1', 'ex-2'],
            rounds: 3,
            repsRange: '8-12',
            restAfterRound: 30,
            restAfterSuperset: 90,
            difficulty: TemplateDifficulty.beginner,
            estimatedTimeMinutes: 15,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = SupersetTemplateRepository();

        final newTemplate = SupersetTemplate(
          id: 'new-1',
          name: 'New',
          exerciseIds: ['ex-5', 'ex-6'],
          rounds: 3,
          repsRange: '10',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
        );

        expect(
          () => repo.saveCustomTemplate(
            newTemplate,
            maxCustomSupersets: 3,
          ),
          throwsException,
        );
      });

      test('allows update even when at limit', () async {
        final templates = List.generate(
          3,
          (i) => SupersetTemplate(
            id: 'custom-$i',
            name: 'Template $i',
            exerciseIds: ['ex-1', 'ex-2'],
            rounds: 3,
            repsRange: '8-12',
            restAfterRound: 30,
            restAfterSuperset: 90,
            difficulty: TemplateDifficulty.beginner,
            estimatedTimeMinutes: 15,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = SupersetTemplateRepository();

        final updated = templates[0].copyWith(name: 'Updated');
        await repo.saveCustomTemplate(updated, maxCustomSupersets: 3);

        final saved = await repo.getCustomTemplates();
        expect(saved.length, 3);
      });
    });

    group('deleteCustomTemplate', () {
      test('deletes existing custom template', () async {
        final template = SupersetTemplate(
          id: 'custom-1',
          name: 'To Delete',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.beginner,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([template.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        await repo.deleteCustomTemplate('custom-1');

        final remaining = await repo.getCustomTemplates();
        expect(remaining, isEmpty);
      });

      test('throws when template not found', () async {
        SharedPreferences.setMockInitialValues({});
        final repo = SupersetTemplateRepository();

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
          SupersetTemplate(
            id: 'c-1',
            name: 'Xyzzy Foundation SS',
            exerciseIds: ['ex-1', 'ex-2'],
            rounds: 4,
            repsRange: '8-12',
            restAfterRound: 30,
            restAfterSuperset: 120,
            difficulty: TemplateDifficulty.intermediate,
            estimatedTimeMinutes: 20,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          SupersetTemplate(
            id: 'c-2',
            name: 'Arm Finisher',
            exerciseIds: ['ex-3', 'ex-4'],
            rounds: 3,
            repsRange: '12-15',
            restAfterRound: 20,
            restAfterSuperset: 60,
            difficulty: TemplateDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'superset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = SupersetTemplateRepository();

        final results = await repo.searchTemplates('xyzzy');
        expect(results.length, 1);
        expect(results[0].id, 'c-1');
      });

      test('searches by scientific basis', () async {
        final template = SupersetTemplate(
          id: 'c-1',
          name: 'Superset',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.intermediate,
          estimatedTimeMinutes: 15,
          scientificBasis: 'Zqwvt pairing reduces fatigue by 20%',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([template.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        final results = await repo.searchTemplates('zqwvt');
        expect(results.length, 1);
      });

      test('searches by target muscles', () async {
        final template = SupersetTemplate(
          id: 'c-1',
          name: 'Superset',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.intermediate,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          targetMuscles: ['zqwvtmuscle', 'back'],
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([template.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        final results = await repo.searchTemplates('zqwvtmuscle');
        expect(results.length, 1);
      });

      test('returns empty when no match', () async {
        final template = SupersetTemplate(
          id: 'c-1',
          name: 'Superset',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.intermediate,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([template.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        final results = await repo.searchTemplates('zznonexistentzz');
        expect(results, isEmpty);
      });
    });

    group('getTemplatesByDifficulty', () {
      test('filters by difficulty', () async {
        final templates = [
          SupersetTemplate(
            id: 'c-1',
            name: 'Beginner SS',
            exerciseIds: ['ex-1', 'ex-2'],
            rounds: 3,
            repsRange: '10-12',
            restAfterRound: 60,
            restAfterSuperset: 120,
            difficulty: TemplateDifficulty.beginner,
            estimatedTimeMinutes: 15,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          SupersetTemplate(
            id: 'c-2',
            name: 'Advanced SS',
            exerciseIds: ['ex-3', 'ex-4'],
            rounds: 5,
            repsRange: '6-8',
            restAfterRound: 15,
            restAfterSuperset: 60,
            difficulty: TemplateDifficulty.advanced,
            estimatedTimeMinutes: 25,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'superset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = SupersetTemplateRepository();

        final beginnerResults =
            await repo.getTemplatesByDifficulty(TemplateDifficulty.beginner);

        // Verify custom beginner template is in results
        expect(beginnerResults.any((t) => t.id == 'c-1'), isTrue);
        // Verify advanced custom template is not in beginner results
        expect(beginnerResults.any((t) => t.id == 'c-2'), isFalse);
        // All results should have beginner difficulty
        for (final t in beginnerResults) {
          expect(t.difficulty, TemplateDifficulty.beginner);
        }
      });
    });

    group('getTemplatesByMuscles', () {
      test('filters by target muscles', () async {
        final templates = [
          SupersetTemplate(
            id: 'c-1',
            name: 'Zqwvt Chest SS',
            exerciseIds: ['ex-1', 'ex-2'],
            rounds: 3,
            repsRange: '8-12',
            restAfterRound: 30,
            restAfterSuperset: 90,
            difficulty: TemplateDifficulty.intermediate,
            estimatedTimeMinutes: 15,
            scientificBasis: 'basis',
            targetMuscles: ['zqwvtmuscle', 'triceps'],
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          SupersetTemplate(
            id: 'c-2',
            name: 'Back SS',
            exerciseIds: ['ex-3', 'ex-4'],
            rounds: 3,
            repsRange: '8-12',
            restAfterRound: 30,
            restAfterSuperset: 90,
            difficulty: TemplateDifficulty.intermediate,
            estimatedTimeMinutes: 15,
            scientificBasis: 'basis',
            targetMuscles: ['back', 'biceps'],
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'superset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = SupersetTemplateRepository();

        final results = await repo.getTemplatesByMuscles(['zqwvtmuscle']);
        expect(results.length, 1);
        expect(results[0].id, 'c-1');
      });

      test('excludes templates with no target muscles', () async {
        final template = SupersetTemplate(
          id: 'c-1',
          name: 'No Muscles',
          exerciseIds: ['ex-1', 'ex-2'],
          rounds: 3,
          repsRange: '8-12',
          restAfterRound: 30,
          restAfterSuperset: 90,
          difficulty: TemplateDifficulty.intermediate,
          estimatedTimeMinutes: 15,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'superset_templates_null': json.encode([template.toJson()]),
        });
        final repo = SupersetTemplateRepository();

        final results = await repo.getTemplatesByMuscles(['zqwvtmuscle']);
        expect(results, isEmpty);
      });
    });
  });
}
