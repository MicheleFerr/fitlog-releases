/// ExerciseDefinitionTemplate tests - JSON round-trip, computed properties,
/// toExercise conversion.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  ExerciseDefinitionTemplate buildTemplate({
    String id = 'tmpl1',
    String name = 'Bench Press',
    String description = 'Flat barbell bench press',
    ExerciseCategory category = ExerciseCategory.chest,
    ExerciseType type = ExerciseType.single,
    List<String> muscleGroups = const ['Pectorals', 'Triceps'],
    List<String> equipment = const ['Barbell', 'Bench'],
    List<String>? instructions,
    String? imageUrl,
    String? videoUrl,
    String? difficulty,
    Map<String, dynamic>? metadata,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseDefinitionTemplate(
      id: id,
      name: name,
      description: description,
      category: category,
      type: type,
      muscleGroups: muscleGroups,
      equipment: equipment,
      instructions: instructions,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      difficulty: difficulty,
      metadata: metadata,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  group('JSON round-trip', () {
    test('all fields', () {
      final original = buildTemplate(
        instructions: ['Step 1', 'Step 2'],
        imageUrl: 'https://example.com/img.png',
        videoUrl: 'https://example.com/vid.mp4',
        difficulty: 'intermediate',
        metadata: {'tips': 'keep elbows tucked'},
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );
      final json = original.toJson();
      final restored = ExerciseDefinitionTemplate.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.category, original.category);
      expect(restored.type, original.type);
      expect(restored.muscleGroups, original.muscleGroups);
      expect(restored.equipment, original.equipment);
      expect(restored.instructions, original.instructions);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.videoUrl, original.videoUrl);
      expect(restored.difficulty, original.difficulty);
      expect(restored.metadata, original.metadata);
      expect(restored.isActive, original.isActive);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('null optional fields', () {
      final original = buildTemplate();
      final restored = ExerciseDefinitionTemplate.fromJson(original.toJson());
      expect(restored.instructions, isNull);
      expect(restored.imageUrl, isNull);
      expect(restored.videoUrl, isNull);
      expect(restored.difficulty, isNull);
      expect(restored.metadata, isNull);
      expect(restored.createdAt, isNull);
      expect(restored.updatedAt, isNull);
    });

    test('isActive defaults to true', () {
      final json = {
        'id': 't1',
        'name': 'Test',
        'description': 'Desc',
        'category': 'chest',
        'type': 'single',
        'muscleGroups': ['Chest'],
        'equipment': ['Barbell'],
      };
      final restored = ExerciseDefinitionTemplate.fromJson(json);
      expect(restored.isActive, isTrue);
    });

    test('isActive false preserved', () {
      final original = buildTemplate(isActive: false);
      final restored = ExerciseDefinitionTemplate.fromJson(original.toJson());
      expect(restored.isActive, isFalse);
    });

    test('all ExerciseCategory values', () {
      for (final cat in ExerciseCategory.values) {
        final t = buildTemplate(category: cat);
        final restored = ExerciseDefinitionTemplate.fromJson(t.toJson());
        expect(restored.category, cat);
      }
    });

    test('all ExerciseType values', () {
      for (final type in ExerciseType.values) {
        final t = buildTemplate(type: type);
        final restored = ExerciseDefinitionTemplate.fromJson(t.toJson());
        expect(restored.type, type);
      }
    });
  });

  group('toExercise', () {
    test('converts with empty sets', () {
      final template = buildTemplate(
        name: 'Squat',
        category: ExerciseCategory.legs,
        type: ExerciseType.single,
      );
      final exercise = template.toExercise();

      expect(exercise.name, 'Squat');
      expect(exercise.category, ExerciseCategory.legs);
      expect(exercise.type, ExerciseType.single);
      expect(exercise.sets, isEmpty);
    });

    test('converts instructions to notes', () {
      final template = buildTemplate(
        instructions: ['Line 1', 'Line 2', 'Line 3'],
      );
      final exercise = template.toExercise();
      expect(exercise.notes, 'Line 1\nLine 2\nLine 3');
    });

    test('null instructions -> null notes', () {
      final template = buildTemplate(instructions: null);
      final exercise = template.toExercise();
      expect(exercise.notes, isNull);
    });
  });

  group('copyWith', () {
    test('changes specified fields', () {
      final original = buildTemplate();
      final copy = original.copyWith(name: 'Incline Bench', isActive: false);
      expect(copy.name, 'Incline Bench');
      expect(copy.isActive, isFalse);
      expect(copy.id, original.id);
      expect(copy.category, original.category);
    });
  });
}
