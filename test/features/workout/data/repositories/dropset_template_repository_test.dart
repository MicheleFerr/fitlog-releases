import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/dropset_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import '../../../../test_helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
    setupFirebaseAuthPigeonMocks();
  });

  late DropsetTemplateRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = DropsetTemplateRepository();
  });

  group('DropsetTemplateRepository', () {
    group('getCustomTemplates', () {
      test('returns empty list when no custom templates stored', () async {
        SharedPreferences.setMockInitialValues({});

        final templates = await repository.getCustomTemplates();

        expect(templates, isEmpty);
      });

      test('returns custom templates from SharedPreferences', () async {
        final template = DropsetTemplate(
          id: 'custom-1',
          name: 'My Dropset',
          exerciseName: 'Curl',
          drops: 3,
          initialReps: '8-10',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 15,
          scientificBasis: 'Test basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 15),
        );

        final jsonList = json.encode([template.toJson()]);

        // Use every possible key pattern since we don't know the exact key
        // used by the repository (it depends on Firebase Auth user ID)
        // The key pattern is 'dropset_templates_{userId}'
        // With no user logged in, userId will be null
        SharedPreferences.setMockInitialValues({
          'dropset_templates_null': jsonList,
        });
        final repo = DropsetTemplateRepository();

        final templates = await repo.getCustomTemplates();

        expect(templates.length, 1);
        expect(templates[0].id, 'custom-1');
        expect(templates[0].name, 'My Dropset');
        expect(templates[0].isCustom, true);
      });

      test('filters out non-custom templates from storage', () async {
        final templates = [
          DropsetTemplate(
            id: 'custom-1',
            name: 'Custom',
            exerciseName: 'Curl',
            drops: 3,
            initialReps: '8',
            dropPercentage: 20,
            restBetweenDrops: 5,
            totalSets: 3,
            restBetweenSets: 120,
            difficulty: DropsetDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
          ),
          DropsetTemplate(
            id: 'predefined-1',
            name: 'Predefined',
            exerciseName: 'Press',
            drops: 2,
            initialReps: '10',
            dropPercentage: 15,
            restBetweenDrops: 5,
            totalSets: 2,
            restBetweenSets: 90,
            difficulty: DropsetDifficulty.intermediate,
            estimatedTimeMinutes: 8,
            scientificBasis: 'basis',
            isCustom: false,
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = DropsetTemplateRepository();

        final result = await repo.getCustomTemplates();

        expect(result.length, 1);
        expect(result[0].id, 'custom-1');
      });

      test('returns empty list on parse error', () async {
        SharedPreferences.setMockInitialValues({
          'dropset_templates_null': 'invalid json',
        });
        final repo = DropsetTemplateRepository();

        final templates = await repo.getCustomTemplates();

        expect(templates, isEmpty);
      });
    });

    group('saveCustomTemplate', () {
      test('saves new custom template', () async {
        SharedPreferences.setMockInitialValues({});
        final repo = DropsetTemplateRepository();

        final template = DropsetTemplate(
          id: 'new-1',
          name: 'New Dropset',
          exerciseName: 'Curl',
          drops: 3,
          initialReps: '8-10',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 15,
          scientificBasis: 'Test',
          isCustom: true,
          createdAt: DateTime(2024, 1, 15),
        );

        await repo.saveCustomTemplate(template, maxCustomDropsets: 10);

        // Verify saved by reading back
        final saved = await repo.getCustomTemplates();
        expect(saved.length, 1);
        expect(saved[0].id, 'new-1');
        expect(saved[0].isCustom, true);
      });

      test('updates existing template', () async {
        final existing = DropsetTemplate(
          id: 'custom-1',
          name: 'Old Name',
          exerciseName: 'Curl',
          drops: 3,
          initialReps: '8',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 3,
          restBetweenSets: 120,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null':
              json.encode([existing.toJson()]),
        });
        final repo = DropsetTemplateRepository();

        final updated = existing.copyWith(name: 'New Name');
        await repo.saveCustomTemplate(updated, maxCustomDropsets: 10);

        final saved = await repo.getCustomTemplates();
        expect(saved.length, 1);
        expect(saved[0].name, 'New Name');
      });

      test('throws when limit reached for new template', () async {
        final templates = List.generate(
          3,
          (i) => DropsetTemplate(
            id: 'custom-$i',
            name: 'Template $i',
            exerciseName: 'Exercise $i',
            drops: 2,
            initialReps: '8',
            dropPercentage: 20,
            restBetweenDrops: 5,
            totalSets: 2,
            restBetweenSets: 90,
            difficulty: DropsetDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = DropsetTemplateRepository();

        final newTemplate = DropsetTemplate(
          id: 'new-1',
          name: 'New',
          exerciseName: 'Test',
          drops: 2,
          initialReps: '8',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
        );

        expect(
          () => repo.saveCustomTemplate(newTemplate, maxCustomDropsets: 3),
          throwsException,
        );
      });

      test('allows update even when at limit', () async {
        final templates = List.generate(
          3,
          (i) => DropsetTemplate(
            id: 'custom-$i',
            name: 'Template $i',
            exerciseName: 'Exercise $i',
            drops: 2,
            initialReps: '8',
            dropPercentage: 20,
            restBetweenDrops: 5,
            totalSets: 2,
            restBetweenSets: 90,
            difficulty: DropsetDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = DropsetTemplateRepository();

        // Updating existing template should not throw
        final updated = templates[0].copyWith(name: 'Updated');
        await repo.saveCustomTemplate(updated, maxCustomDropsets: 3);

        final saved = await repo.getCustomTemplates();
        expect(saved.length, 3);
      });
    });

    group('deleteCustomTemplate', () {
      test('deletes existing custom template', () async {
        final template = DropsetTemplate(
          id: 'custom-1',
          name: 'To Delete',
          exerciseName: 'Curl',
          drops: 2,
          initialReps: '8',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null': json.encode([template.toJson()]),
        });
        final repo = DropsetTemplateRepository();

        await repo.deleteCustomTemplate('custom-1');

        final remaining = await repo.getCustomTemplates();
        expect(remaining, isEmpty);
      });

      test('throws when template not found', () async {
        SharedPreferences.setMockInitialValues({});
        final repo = DropsetTemplateRepository();

        expect(
          () => repo.deleteCustomTemplate('nonexistent'),
          throwsException,
        );
      });
    });

    group('searchTemplates', () {
      // searchTemplates calls getAllTemplates which combines predefined + custom.
      // Predefined templates load from JSON assets. Tests use unique names
      // and check for presence rather than exact counts.

      test('searches by template name (case insensitive)', () async {
        final templates = [
          DropsetTemplate(
            id: 'c-1',
            name: 'Xyzzy Unique Drop',
            exerciseName: 'Xyzzy Curl',
            drops: 3,
            initialReps: '8',
            dropPercentage: 20,
            restBetweenDrops: 5,
            totalSets: 2,
            restBetweenSets: 90,
            difficulty: DropsetDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          DropsetTemplate(
            id: 'c-2',
            name: 'Leg Press Drop',
            exerciseName: 'Leg Press',
            drops: 2,
            initialReps: '10',
            dropPercentage: 15,
            restBetweenDrops: 5,
            totalSets: 2,
            restBetweenSets: 120,
            difficulty: DropsetDifficulty.intermediate,
            estimatedTimeMinutes: 12,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = DropsetTemplateRepository();

        final results = await repo.searchTemplates('xyzzy');

        expect(results.length, 1);
        expect(results[0].id, 'c-1');
      });

      test('searches by exercise name', () async {
        final template = DropsetTemplate(
          id: 'c-1',
          name: 'Drop Set',
          exerciseName: 'Zqwvt Unusual Exercise',
          drops: 3,
          initialReps: '8',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null': json.encode([template.toJson()]),
        });
        final repo = DropsetTemplateRepository();

        final results = await repo.searchTemplates('zqwvt');

        expect(results.length, 1);
      });

      test('searches by target muscles', () async {
        final template = DropsetTemplate(
          id: 'c-1',
          name: 'Arm Dropset',
          exerciseName: 'Curl',
          drops: 3,
          initialReps: '8',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          targetMuscles: ['zqwvtmuscle', 'forearms'],
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null': json.encode([template.toJson()]),
        });
        final repo = DropsetTemplateRepository();

        final results = await repo.searchTemplates('zqwvtmuscle');

        expect(results.length, 1);
      });

      test('returns empty when no match', () async {
        final template = DropsetTemplate(
          id: 'c-1',
          name: 'Arm Dropset',
          exerciseName: 'Curl',
          drops: 3,
          initialReps: '8',
          dropPercentage: 20,
          restBetweenDrops: 5,
          totalSets: 2,
          restBetweenSets: 90,
          difficulty: DropsetDifficulty.beginner,
          estimatedTimeMinutes: 10,
          scientificBasis: 'basis',
          isCustom: true,
          createdAt: DateTime(2024, 1, 1),
        );

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null': json.encode([template.toJson()]),
        });
        final repo = DropsetTemplateRepository();

        final results = await repo.searchTemplates('zznonexistentzz');

        expect(results, isEmpty);
      });
    });

    group('getTemplatesByDifficulty', () {
      test('filters templates by difficulty', () async {
        final templates = [
          DropsetTemplate(
            id: 'c-1',
            name: 'Beginner Drop',
            exerciseName: 'Curl',
            drops: 2,
            initialReps: '8',
            dropPercentage: 20,
            restBetweenDrops: 10,
            totalSets: 2,
            restBetweenSets: 120,
            difficulty: DropsetDifficulty.beginner,
            estimatedTimeMinutes: 10,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          DropsetTemplate(
            id: 'c-2',
            name: 'Advanced Drop',
            exerciseName: 'Press',
            drops: 4,
            initialReps: '6',
            dropPercentage: 25,
            restBetweenDrops: 5,
            totalSets: 4,
            restBetweenSets: 90,
            difficulty: DropsetDifficulty.advanced,
            estimatedTimeMinutes: 20,
            scientificBasis: 'basis',
            isCustom: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        SharedPreferences.setMockInitialValues({
          'dropset_templates_null':
              json.encode(templates.map((t) => t.toJson()).toList()),
        });
        final repo = DropsetTemplateRepository();

        final beginnerResults =
            await repo.getTemplatesByDifficulty(DropsetDifficulty.beginner);
        final advancedResults =
            await repo.getTemplatesByDifficulty(DropsetDifficulty.advanced);

        // Verify custom beginner template is in results
        expect(beginnerResults.any((t) => t.id == 'c-1'), isTrue);
        // Verify custom advanced template is NOT in beginner results
        expect(beginnerResults.any((t) => t.id == 'c-2'), isFalse);
        // Verify advanced results contain the advanced custom template
        expect(advancedResults.any((t) => t.id == 'c-2'), isTrue);
        // All returned beginner results should have beginner difficulty
        for (final t in beginnerResults) {
          expect(t.difficulty, DropsetDifficulty.beginner);
        }
      });
    });
  });
}
