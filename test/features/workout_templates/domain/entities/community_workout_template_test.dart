import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Fixtures
  // ---------------------------------------------------------------------------
  final baseDate = DateTime(2025, 1, 1, 12);

  CommunityWorkoutTemplate _makeTemplate({
    String id = 'template-1',
    String userId = 'user-1',
    String name = 'Push Day',
    List<Exercise>? exercises,
    TemplateCategory category = TemplateCategory.strength,
    TemplateVisibility visibility = TemplateVisibility.private,
  }) {
    return CommunityWorkoutTemplate(
      id: id,
      userId: userId,
      name: name,
      exercises: exercises ?? [],
      category: category,
      visibility: visibility,
      createdAt: baseDate,
    );
  }

  // ---------------------------------------------------------------------------
  // TemplateVisibility enum
  // ---------------------------------------------------------------------------
  group('TemplateVisibility', () {
    test('has the three expected values', () {
      expect(TemplateVisibility.values.length, 3);
      expect(TemplateVisibility.values, contains(TemplateVisibility.private));
      expect(TemplateVisibility.values, contains(TemplateVisibility.public));
      expect(TemplateVisibility.values, contains(TemplateVisibility.friends));
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateCategory enum
  // ---------------------------------------------------------------------------
  group('TemplateCategory', () {
    test('has the expected number of values', () {
      expect(TemplateCategory.values.length, 10);
    });

    test('contains custom and strength categories', () {
      expect(TemplateCategory.values, contains(TemplateCategory.custom));
      expect(TemplateCategory.values, contains(TemplateCategory.strength));
    });
  });

  // ---------------------------------------------------------------------------
  // CommunityWorkoutTemplate construction
  // ---------------------------------------------------------------------------
  group('CommunityWorkoutTemplate construction', () {
    test('creates with required fields', () {
      final template = _makeTemplate();

      expect(template.id, 'template-1');
      expect(template.userId, 'user-1');
      expect(template.name, 'Push Day');
      expect(template.exercises, isEmpty);
      expect(template.createdAt, baseDate);
    });

    test('defaults category to custom when not specified', () {
      final template = CommunityWorkoutTemplate(
        id: 'id',
        userId: 'uid',
        name: 'Test',
        exercises: const [],
        createdAt: baseDate,
      );

      expect(template.category, TemplateCategory.custom);
    });

    test('defaults visibility to private when not specified', () {
      final template = CommunityWorkoutTemplate(
        id: 'id',
        userId: 'uid',
        name: 'Test',
        exercises: const [],
        createdAt: baseDate,
      );

      expect(template.visibility, TemplateVisibility.private);
    });

    test('defaults numeric stats to zero', () {
      final template = _makeTemplate();

      expect(template.downloadCount, 0);
      expect(template.likeCount, 0);
      expect(template.reviewCount, 0);
      expect(template.averageRating, 0.0);
    });

    test('defaults tags and equipment lists to empty', () {
      final template = _makeTemplate();

      expect(template.tags, isEmpty);
      expect(template.requiredEquipment, isEmpty);
      expect(template.targetMuscles, isEmpty);
    });

    test('defaults isAnonymous to false', () {
      final template = _makeTemplate();

      expect(template.isAnonymous, isFalse);
    });

    test('accepts optional fields', () {
      final template = CommunityWorkoutTemplate(
        id: 'id',
        userId: 'uid',
        name: 'Advanced Push',
        description: 'Full chest and triceps',
        exercises: const [],
        category: TemplateCategory.hypertrophy,
        visibility: TemplateVisibility.public,
        createdAt: baseDate,
        updatedAt: baseDate.add(const Duration(days: 1)),
        downloadCount: 42,
        likeCount: 10,
        reviewCount: 5,
        averageRating: 4.5,
        authorName: 'Luca',
        authorPhotoUrl: 'https://example.com/photo.jpg',
        tags: ['chest', 'hypertrophy'],
        estimatedDurationMinutes: 60,
        difficultyLevel: 'intermediate',
        requiredEquipment: ['barbell', 'bench'],
        targetMuscles: ['chest', 'triceps'],
        isAnonymous: false,
        forkedFromTemplateId: 'original-1',
        originalAuthorName: 'Marco',
      );

      expect(template.description, 'Full chest and triceps');
      expect(template.downloadCount, 42);
      expect(template.likeCount, 10);
      expect(template.averageRating, 4.5);
      expect(template.authorName, 'Luca');
      expect(template.tags, ['chest', 'hypertrophy']);
      expect(template.estimatedDurationMinutes, 60);
      expect(template.difficultyLevel, 'intermediate');
      expect(template.requiredEquipment, ['barbell', 'bench']);
      expect(template.forkedFromTemplateId, 'original-1');
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------
  group('CommunityWorkoutTemplate.copyWith', () {
    test('returns a new instance with updated name', () {
      final original = _makeTemplate(name: 'Push Day');
      final updated = original.copyWith(name: 'Pull Day');

      expect(updated.name, 'Pull Day');
      expect(original.name, 'Push Day'); // immutable — original unchanged
    });

    test('returns a new instance with updated visibility', () {
      final original = _makeTemplate(visibility: TemplateVisibility.private);
      final updated = original.copyWith(visibility: TemplateVisibility.public);

      expect(updated.visibility, TemplateVisibility.public);
      expect(original.visibility, TemplateVisibility.private);
    });

    test('preserves all other fields when only one is changed', () {
      final original = _makeTemplate(
        id: 'template-99',
        userId: 'user-99',
        category: TemplateCategory.powerlifting,
      );
      final updated = original.copyWith(name: 'New Name');

      expect(updated.id, 'template-99');
      expect(updated.userId, 'user-99');
      expect(updated.category, TemplateCategory.powerlifting);
      expect(updated.createdAt, baseDate);
    });

    test('can update download count', () {
      final template = _makeTemplate().copyWith(downloadCount: 100);

      expect(template.downloadCount, 100);
    });
  });

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------
  group('CommunityWorkoutTemplate equality', () {
    test('two templates with same fields are equal', () {
      final a = _makeTemplate(id: 'x');
      final b = _makeTemplate(id: 'x');

      expect(a, equals(b));
    });

    test('two templates with different IDs are not equal', () {
      final a = _makeTemplate(id: 'a');
      final b = _makeTemplate(id: 'b');

      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // JSON serialization round-trip
  // ---------------------------------------------------------------------------
  group('CommunityWorkoutTemplate JSON', () {
    test('fromJson/toJson round-trip preserves required fields', () {
      final original = _makeTemplate(
        id: 'tmpl-json-1',
        userId: 'user-json',
        name: 'JSON Template',
        category: TemplateCategory.bodybuilding,
        visibility: TemplateVisibility.public,
      );

      final json = original.toJson();
      final restored = CommunityWorkoutTemplate.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.name, original.name);
      expect(restored.category, original.category);
      expect(restored.visibility, original.visibility);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson/toJson round-trip preserves default numeric fields', () {
      final original = _makeTemplate();
      final json = original.toJson();
      final restored = CommunityWorkoutTemplate.fromJson(json);

      expect(restored.downloadCount, 0);
      expect(restored.likeCount, 0);
      expect(restored.averageRating, 0.0);
      expect(restored.isAnonymous, isFalse);
    });

    test('fromJson/toJson round-trip preserves optional string fields', () {
      final original = _makeTemplate().copyWith(
        description: 'My description',
        authorName: 'Sofia',
        difficultyLevel: 'advanced',
        forkedFromTemplateId: 'fork-parent',
      );

      final json = original.toJson();
      final restored = CommunityWorkoutTemplate.fromJson(json);

      expect(restored.description, 'My description');
      expect(restored.authorName, 'Sofia');
      expect(restored.difficultyLevel, 'advanced');
      expect(restored.forkedFromTemplateId, 'fork-parent');
    });

    test('fromJson/toJson round-trip preserves list fields', () {
      final original = _makeTemplate().copyWith(
        tags: ['strength', 'beginner'],
        requiredEquipment: ['dumbbell'],
        targetMuscles: ['back', 'biceps'],
      );

      final json = original.toJson();
      final restored = CommunityWorkoutTemplate.fromJson(json);

      expect(restored.tags, ['strength', 'beginner']);
      expect(restored.requiredEquipment, ['dumbbell']);
      expect(restored.targetMuscles, ['back', 'biceps']);
    });
  });
}
