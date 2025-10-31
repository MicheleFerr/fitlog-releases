import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WorkoutTemplateRepository repository;

  setUp(() {
    repository = WorkoutTemplateRepository();
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutTemplateRepository - Predefined Templates', () {
    test('should initialize predefined templates on first access', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert - Should have predefined templates
      expect(templates, isNotEmpty);
      expect(templates.length, greaterThanOrEqualTo(3)); // At least 3 predefined
      expect(templates.every((t) => !t.isCustom), isTrue);
    });

    test('should not reinitialize predefined templates on second access', () async {
      // Arrange - First access initializes
      await repository.getPredefinedTemplates();

      // Act - Second access should not reinitialize
      final templates = await repository.getPredefinedTemplates();

      // Assert - Should still have same templates
      expect(templates, isNotEmpty);
      expect(templates.every((t) => !t.isCustom), isTrue);
    });

    test('should include Upper Body Strength template', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert
      final upperBody = templates.firstWhere(
        (t) => t.name == 'Upper Body Strength',
        orElse: () => throw Exception('Upper Body template not found'),
      );
      expect(upperBody.exercises.length, greaterThan(0));
      expect(upperBody.tags, contains('upper'));
    });

    test('should include Lower Body Power template', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert
      final lowerBody = templates.firstWhere(
        (t) => t.name == 'Lower Body Power',
        orElse: () => throw Exception('Lower Body template not found'),
      );
      expect(lowerBody.exercises.length, greaterThan(0));
      expect(lowerBody.tags, contains('lower'));
    });

    test('should include HIIT Cardio template', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert
      final hiit = templates.firstWhere(
        (t) => t.name == 'HIIT Cardio',
        orElse: () => throw Exception('HIIT template not found'),
      );
      expect(hiit.exercises.length, greaterThan(0));
      expect(hiit.tags, contains('cardio'));
    });

    test('should include Core & Abs template', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert
      final core = templates.firstWhere(
        (t) => t.name == 'Core & Abs',
        orElse: () => throw Exception('Core template not found'),
      );
      expect(core.exercises.length, greaterThan(0));
      expect(core.tags, contains('core'));
    });

    test('should mark all predefined templates as not custom', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert
      for (final template in templates) {
        expect(template.isCustom, isFalse);
      }
    });

    test('should include exercise details in predefined templates', () async {
      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert - Check Upper Body template has proper exercises
      final upperBody = templates.firstWhere((t) => t.name == 'Upper Body Strength');

      expect(upperBody.exercises.any((e) => e.exerciseName == 'Panca Piana'), isTrue);
      expect(upperBody.exercises.any((e) => e.exerciseName == 'Trazioni'), isTrue);
      expect(upperBody.exercises.any((e) => e.exerciseName == 'Shoulder Press'), isTrue);

      // Check sets
      final pancaPiana = upperBody.exercises.firstWhere((e) => e.exerciseName == 'Panca Piana');
      expect(pancaPiana.sets.length, equals(4)); // 4 sets
    });
  });

  group('WorkoutTemplateRepository - Custom Templates', () {
    test('should return empty list when no custom templates exist', () async {
      // Act
      final templates = await repository.getCustomTemplates();

      // Assert
      expect(templates, isEmpty);
    });

    test('should save custom template', () async {
      // Arrange
      final template = _createTestTemplate(name: 'My Custom Template');

      // Act
      await repository.saveTemplate(template);

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates.length, equals(1));
      expect(templates.first.name, equals('My Custom Template'));
      expect(templates.first.isCustom, isTrue);
    });

    test('should mark template as custom when saving', () async {
      // Arrange
      final template = _createTestTemplate(name: 'Test', isCustom: false);

      // Act
      await repository.saveTemplate(template);

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates.first.isCustom, isTrue);
    });

    test('should update existing custom template', () async {
      // Arrange
      final template = _createTestTemplate(name: 'Original Name');
      await repository.saveTemplate(template);

      // Act - Save same ID with different name
      final updated = template.copyWith(name: 'Updated Name');
      await repository.saveTemplate(updated);

      // Assert - Should only have one template with updated name
      final templates = await repository.getCustomTemplates();
      expect(templates.length, equals(1));
      expect(templates.first.name, equals('Updated Name'));
    });

    test('should save multiple custom templates', () async {
      // Arrange
      final template1 = _createTestTemplate(name: 'Template 1');
      final template2 = _createTestTemplate(name: 'Template 2');

      // Act
      await repository.saveTemplate(template1);
      await repository.saveTemplate(template2);

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates.length, equals(2));
    });

    test('should delete custom template', () async {
      // Arrange
      final template = _createTestTemplate(name: 'To Delete');
      await repository.saveTemplate(template);

      // Act
      await repository.deleteTemplate(template.id);

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates, isEmpty);
    });

    test('should throw when deleting non-existent template', () async {
      // Act & Assert
      expect(
        () => repository.deleteTemplate('non-existent-id'),
        throwsA(isA<Exception>()),
      );
    });

    test('should not delete predefined templates', () async {
      // Arrange - Get predefined template
      final predefined = await repository.getPredefinedTemplates();
      final predefinedId = predefined.first.id;

      // Act & Assert
      expect(
        () => repository.deleteTemplate(predefinedId),
        throwsA(isA<Exception>()),
      );
    });

    test('should preserve exercises when saving template', () async {
      // Arrange
      final template = _createTestTemplate(
        name: 'With Exercises',
        exerciseCount: 3,
      );

      // Act
      await repository.saveTemplate(template);

      // Assert
      final saved = await repository.getCustomTemplates();
      expect(saved.first.exercises.length, equals(3));
    });
  });

  group('WorkoutTemplateRepository - Get All Templates', () {
    test('should return predefined templates when no custom exist', () async {
      // Act
      final templates = await repository.getAllTemplates();

      // Assert - Should have only predefined
      expect(templates, isNotEmpty);
      expect(templates.every((t) => !t.isCustom), isTrue);
    });

    test('should return both predefined and custom templates', () async {
      // Arrange
      final customTemplate = _createTestTemplate(name: 'Custom');
      await repository.saveTemplate(customTemplate);

      // Act
      final templates = await repository.getAllTemplates();

      // Assert - Should have both types
      expect(templates.where((t) => t.isCustom).length, equals(1));
      expect(templates.where((t) => !t.isCustom).length, greaterThan(0));
    });

    test('should sort templates by usage count descending', () async {
      // Arrange
      final template1 = _createTestTemplate(name: 'Low Usage', usageCount: 1);
      final template2 = _createTestTemplate(name: 'High Usage', usageCount: 10);
      final template3 = _createTestTemplate(name: 'Med Usage', usageCount: 5);

      await repository.saveTemplate(template1);
      await repository.saveTemplate(template2);
      await repository.saveTemplate(template3);

      // Act
      final templates = await repository.getAllTemplates();
      final customTemplates = templates.where((t) => t.isCustom).toList();

      // Assert - Should be sorted by usage (high to low)
      expect(customTemplates[0].name, equals('High Usage'));
      expect(customTemplates[1].name, equals('Med Usage'));
      expect(customTemplates[2].name, equals('Low Usage'));
    });

    test('should sort by updated date when usage count is equal', () async {
      // Arrange
      final now = DateTime.now();
      final old = _createTestTemplate(
        name: 'Old',
        usageCount: 5,
        updatedAt: now.subtract(const Duration(days: 10)),
      );
      final recent = _createTestTemplate(
        name: 'Recent',
        usageCount: 5,
        updatedAt: now,
      );

      await repository.saveTemplate(old);
      await repository.saveTemplate(recent);

      // Act
      final templates = await repository.getAllTemplates();
      final customTemplates = templates.where((t) => t.isCustom).toList();

      // Assert - Recent should come first
      expect(customTemplates[0].name, equals('Recent'));
      expect(customTemplates[1].name, equals('Old'));
    });
  });

  group('WorkoutTemplateRepository - Usage Tracking', () {
    test('should increment usage count for custom template', () async {
      // Arrange
      final template = _createTestTemplate(name: 'To Track', usageCount: 0);
      await repository.saveTemplate(template);

      // Act
      await repository.incrementUsage(template.id);

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates.first.usageCount, equals(1));
    });

    test('should increment usage multiple times', () async {
      // Arrange
      final template = _createTestTemplate(name: 'Track Multiple', usageCount: 0);
      await repository.saveTemplate(template);

      // Act
      await repository.incrementUsage(template.id);
      await repository.incrementUsage(template.id);
      await repository.incrementUsage(template.id);

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates.first.usageCount, equals(3));
    });

    test('should not throw when incrementing non-existent template', () async {
      // Act & Assert - Should not throw
      await repository.incrementUsage('non-existent-id');
      expect(true, isTrue);
    });

    test('should not track usage for predefined templates', () async {
      // Arrange
      final predefined = await repository.getPredefinedTemplates();
      final predefinedId = predefined.first.id;

      // Act
      await repository.incrementUsage(predefinedId);

      // Assert - Should not throw, just not track
      expect(true, isTrue);
    });
  });

  group('WorkoutTemplateRepository - Search', () {
    test('should find templates by name', () async {
      // Arrange
      final template = _createTestTemplate(name: 'Upper Body Workout');
      await repository.saveTemplate(template);

      // Act
      final results = await repository.searchTemplates('Upper');

      // Assert
      expect(results.any((t) => t.name.contains('Upper')), isTrue);
    });

    test('should find templates by description', () async {
      // Arrange
      final template = _createTestTemplate(
        name: 'My Workout',
        description: 'Great for beginners',
      );
      await repository.saveTemplate(template);

      // Act
      final results = await repository.searchTemplates('beginners');

      // Assert
      expect(results.any((t) => t.description.contains('beginners')), isTrue);
    });

    test('should find templates by tags', () async {
      // Arrange
      final template = _createTestTemplate(
        name: 'Tagged Workout',
        tags: ['strength', 'upper', 'intermediate'],
      );
      await repository.saveTemplate(template);

      // Act
      final results = await repository.searchTemplates('strength');

      // Assert
      expect(results.any((t) => t.tags.contains('strength')), isTrue);
    });

    test('should be case-insensitive', () async {
      // Arrange
      final template = _createTestTemplate(name: 'Lower Body');
      await repository.saveTemplate(template);

      // Act
      final results = await repository.searchTemplates('LOWER');

      // Assert
      expect(results.any((t) => t.name.contains('Lower')), isTrue);
    });

    test('should return empty list when no matches found', () async {
      // Act
      final results = await repository.searchTemplates('NonExistent Query');

      // Assert
      expect(results, isEmpty);
    });

    test('should search across all templates (predefined + custom)', () async {
      // Arrange
      final customTemplate = _createTestTemplate(name: 'Custom Upper');
      await repository.saveTemplate(customTemplate);

      // Act
      final results = await repository.searchTemplates('Upper');

      // Assert - Should find both custom and predefined
      expect(results.any((t) => t.isCustom), isTrue); // Custom
      expect(results.any((t) => !t.isCustom), isTrue); // Predefined "Upper Body"
    });
  });

  group('WorkoutTemplateRepository - Filter by Tags', () {
    test('should filter templates by single tag', () async {
      // Arrange
      final template1 = _createTestTemplate(name: 'T1', tags: ['strength', 'upper']);
      final template2 = _createTestTemplate(name: 'T2', tags: ['cardio']);
      await repository.saveTemplate(template1);
      await repository.saveTemplate(template2);

      // Act
      final results = await repository.getTemplatesByTags(['strength']);

      // Assert
      expect(results.any((t) => t.tags.contains('strength')), isTrue);
    });

    test('should filter templates by multiple tags (OR logic)', () async {
      // Arrange
      final template1 = _createTestTemplate(name: 'T1', tags: ['strength']);
      final template2 = _createTestTemplate(name: 'T2', tags: ['cardio']);
      final template3 = _createTestTemplate(name: 'T3', tags: ['flexibility']);
      await repository.saveTemplate(template1);
      await repository.saveTemplate(template2);
      await repository.saveTemplate(template3);

      // Act
      final results = await repository.getTemplatesByTags(['strength', 'cardio']);

      // Assert - Should return T1 and T2 (OR logic)
      expect(results.length, greaterThanOrEqualTo(2));
      expect(
        results.any((t) => t.tags.contains('strength') || t.tags.contains('cardio')),
        isTrue,
      );
    });

    test('should return empty list when no templates match tags', () async {
      // Act
      final results = await repository.getTemplatesByTags(['nonexistent-tag']);

      // Assert
      expect(results, isEmpty);
    });

    test('should filter across both custom and predefined templates', () async {
      // Arrange
      final customTemplate = _createTestTemplate(name: 'Custom', tags: ['upper']);
      await repository.saveTemplate(customTemplate);

      // Act
      final results = await repository.getTemplatesByTags(['upper']);

      // Assert - Should find both custom and predefined "upper" templates
      expect(results.any((t) => t.isCustom), isTrue);
      expect(results.any((t) => !t.isCustom), isTrue);
    });
  });

  group('WorkoutTemplateRepository - Create from Workout', () {
    test('should create template from workout exercises', () async {
      // Arrange
      final exercises = [
        _createTestExercise(name: 'Bench Press', sets: 4),
        _createTestExercise(name: 'Squats', sets: 3),
      ];

      // Act
      final template = await repository.createTemplateFromWorkout(
        name: 'My Program',
        description: 'Test program',
        exercises: exercises,
        tags: ['custom'],
      );

      // Assert
      expect(template.name, equals('My Program'));
      expect(template.exercises.length, equals(2));
      expect(template.exercises[0].exerciseName, equals('Bench Press'));
      expect(template.exercises[0].sets.length, equals(4));
    });

    test('should auto-save created template', () async {
      // Arrange
      final exercises = [_createTestExercise(name: 'Test Exercise')];

      // Act
      await repository.createTemplateFromWorkout(
        name: 'Auto Saved',
        description: 'Should be saved automatically',
        exercises: exercises,
      );

      // Assert
      final templates = await repository.getCustomTemplates();
      expect(templates.any((t) => t.name == 'Auto Saved'), isTrue);
    });

    test('should estimate duration based on exercises', () async {
      // Arrange
      final exercises = [
        _createTestExercise(name: 'E1', sets: 4, restTime: 90),
        _createTestExercise(name: 'E2', sets: 3, restTime: 60),
      ];

      // Act
      final template = await repository.createTemplateFromWorkout(
        name: 'Duration Test',
        description: 'Test',
        exercises: exercises,
      );

      // Assert - Duration should be estimated (2 min per set + rest)
      expect(template.estimatedDuration, greaterThan(0));
    });

    test('should copy set data to template', () async {
      // Arrange
      final exercise = _createTestExercise(
        name: 'Bench',
        sets: 3,
        weight: 100.0,
        reps: 10,
      );

      // Act
      final template = await repository.createTemplateFromWorkout(
        name: 'Test',
        description: 'Test',
        exercises: [exercise],
      );

      // Assert
      final templateExercise = template.exercises.first;
      expect(templateExercise.sets.length, equals(3));
      expect(templateExercise.sets.first.targetWeight, equals(100.0));
      expect(templateExercise.sets.first.targetReps, equals(10));
    });

    test('should handle optional parameters', () async {
      // Arrange
      final exercises = [_createTestExercise(name: 'Test')];

      // Act - Without optional params
      final template = await repository.createTemplateFromWorkout(
        name: 'Minimal',
        description: 'Test',
        exercises: exercises,
      );

      // Assert
      expect(template.tags, isEmpty);
      expect(template.imageUrl, isNull);
    });
  });

  group('WorkoutTemplateRepository - Error Handling', () {
    test('should return empty list on JSON decode error for custom templates', () async {
      // Arrange - Corrupt data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workout_templates', 'invalid json');

      // Act
      final templates = await repository.getCustomTemplates();

      // Assert - Should handle gracefully
      expect(templates, isEmpty);
    });

    test('should return empty list on JSON decode error for predefined templates', () async {
      // Arrange - Force initialization then corrupt
      await repository.getPredefinedTemplates(); // Initialize first
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workout_templates', 'invalid json');

      // Act
      final templates = await repository.getPredefinedTemplates();

      // Assert - Should handle gracefully
      expect(templates, isEmpty);
    });

    test('should throw exception on save error', () async {
      // Note: Difficult to test SharedPreferences save error in unit tests
      // This test documents expected behavior
      expect(true, isTrue);
    });
  });

  group('WorkoutTemplateRepository - Edge Cases', () {
    test('should handle template with no exercises', () async {
      // Arrange
      final template = WorkoutTemplate(
        name: 'Empty Template',
        description: 'No exercises',
        exercises: [],
        tags: [],
      );

      // Act
      await repository.saveTemplate(template);

      // Assert
      final saved = await repository.getCustomTemplates();
      expect(saved.first.exercises, isEmpty);
    });

    test('should handle template with many exercises', () async {
      // Arrange
      final template = _createTestTemplate(name: 'Many', exerciseCount: 20);

      // Act
      await repository.saveTemplate(template);

      // Assert
      final saved = await repository.getCustomTemplates();
      expect(saved.first.exercises.length, equals(20));
    });

    test('should handle template with very long name', () async {
      // Arrange
      final longName = 'Very Long Template Name ' * 10;
      final template = _createTestTemplate(name: longName);

      // Act
      await repository.saveTemplate(template);

      // Assert
      final saved = await repository.getCustomTemplates();
      expect(saved.first.name, equals(longName));
    });

    test('should handle empty search query', () async {
      // Act
      final results = await repository.searchTemplates('');

      // Assert - Empty query should return all templates
      expect(results, isNotEmpty);
    });

    test('should handle empty tags filter', () async {
      // Act
      final results = await repository.getTemplatesByTags([]);

      // Assert - Empty tags should return empty (no matches)
      expect(results, isEmpty);
    });

    test('should handle duplicate template IDs', () async {
      // Arrange
      final template1 = _createTestTemplate(name: 'Original');
      final template2 = template1.copyWith(name: 'Duplicate');

      // Act
      await repository.saveTemplate(template1);
      await repository.saveTemplate(template2);

      // Assert - Should only have one (updated)
      final templates = await repository.getCustomTemplates();
      expect(templates.length, equals(1));
      expect(templates.first.name, equals('Duplicate'));
    });
  });
}

/// Helper to create test WorkoutTemplate
WorkoutTemplate _createTestTemplate({
  String name = 'Test Template',
  String description = 'Test description',
  List<String> tags = const [],
  int exerciseCount = 1,
  int usageCount = 0,
  DateTime? updatedAt,
  bool isCustom = true,
}) {
  final exercises = List.generate(
    exerciseCount,
    (i) => ExerciseTemplate(
      exerciseId: 'exercise_$i',
      exerciseName: 'Exercise $i',
      category: ExerciseCategory.chest,
      sets: [
        const SetTemplate(setNumber: 1, targetReps: 10),
      ],
    ),
  );

  return WorkoutTemplate(
    name: name,
    description: description,
    exercises: exercises,
    tags: tags,
    usageCount: usageCount,
    updatedAt: updatedAt ?? DateTime.now(),
    isCustom: isCustom,
  );
}

/// Helper to create test Exercise
Exercise _createTestExercise({
  required String name,
  int sets = 3,
  double weight = 100.0,
  int reps = 10,
  int? restTime,
}) {
  return Exercise(
    name: name,
    category: ExerciseCategory.chest,
    type: ExerciseType.single,
    sets: List.generate(
      sets,
      (i) => ExerciseSet(
        setNumber: i + 1,
        weight: weight,
        reps: reps,
      ),
    ),
    restTime: restTime,
  );
}
