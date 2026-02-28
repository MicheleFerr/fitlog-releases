import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_folder.dart';

void main() {
  final baseDate = DateTime(2025, 3, 15);

  TemplateFolder _makeFolder({
    String id = 'folder-1',
    String userId = 'user-1',
    String name = 'Push/Pull/Legs',
    String? parentId,
    int depth = 0,
    int sortOrder = 0,
  }) {
    return TemplateFolder(
      id: id,
      userId: userId,
      name: name,
      parentId: parentId,
      depth: depth,
      sortOrder: sortOrder,
      createdAt: baseDate,
    );
  }

  // ---------------------------------------------------------------------------
  // FolderIcon enum
  // ---------------------------------------------------------------------------
  group('FolderIcon', () {
    test('has the expected number of values', () {
      expect(FolderIcon.values.length, 10);
    });

    test('contains standard icons', () {
      expect(FolderIcon.values, contains(FolderIcon.folder));
      expect(FolderIcon.values, contains(FolderIcon.star));
      expect(FolderIcon.values, contains(FolderIcon.dumbbell));
      expect(FolderIcon.values, contains(FolderIcon.trophy));
    });
  });

  // ---------------------------------------------------------------------------
  // kMaxFolderDepth constant
  // ---------------------------------------------------------------------------
  group('kMaxFolderDepth', () {
    test('is 3', () {
      expect(kMaxFolderDepth, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateFolder construction
  // ---------------------------------------------------------------------------
  group('TemplateFolder construction', () {
    test('creates root folder with required fields', () {
      final folder = _makeFolder();

      expect(folder.id, 'folder-1');
      expect(folder.userId, 'user-1');
      expect(folder.name, 'Push/Pull/Legs');
      expect(folder.parentId, isNull);
      expect(folder.depth, 0);
      expect(folder.createdAt, baseDate);
    });

    test('defaults icon to FolderIcon.folder', () {
      final folder = _makeFolder();

      expect(folder.icon, FolderIcon.folder);
    });

    test('defaults sortOrder to 0', () {
      final folder = _makeFolder();

      expect(folder.sortOrder, 0);
    });

    test('defaults templateCount to 0', () {
      final folder = _makeFolder();

      expect(folder.templateCount, 0);
    });

    test('creates nested folder with parentId', () {
      final folder = _makeFolder(parentId: 'parent-1', depth: 1);

      expect(folder.parentId, 'parent-1');
      expect(folder.depth, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateFolderX extension: isRoot
  // ---------------------------------------------------------------------------
  group('TemplateFolderX.isRoot', () {
    test('returns true for root folder (no parentId)', () {
      final folder = _makeFolder(parentId: null);

      expect(folder.isRoot, isTrue);
    });

    test('returns false for nested folder', () {
      final folder = _makeFolder(parentId: 'parent-folder');

      expect(folder.isRoot, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateFolderX extension: canHaveChildren
  // ---------------------------------------------------------------------------
  group('TemplateFolderX.canHaveChildren', () {
    test('depth 0 can have children', () {
      final folder = _makeFolder(depth: 0);

      expect(folder.canHaveChildren, isTrue);
    });

    test('depth 1 can have children', () {
      final folder = _makeFolder(depth: 1);

      expect(folder.canHaveChildren, isTrue);
    });

    test('depth 2 (kMaxFolderDepth - 1) cannot have children', () {
      final folder = _makeFolder(depth: 2);

      // canHaveChildren = depth < kMaxFolderDepth - 1 = depth < 2
      expect(folder.canHaveChildren, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateFolderX extension: pathIds
  // ---------------------------------------------------------------------------
  group('TemplateFolderX.pathIds', () {
    test('root folder pathIds contains only its own id', () {
      final folder = _makeFolder(id: 'root', parentId: null);

      expect(folder.pathIds, ['root']);
    });

    test('nested folder pathIds includes parentId then own id', () {
      final folder = _makeFolder(id: 'child', parentId: 'parent');

      expect(folder.pathIds, ['parent', 'child']);
    });
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------
  group('TemplateFolder.copyWith', () {
    test('updates name while preserving other fields', () {
      final original = _makeFolder(name: 'Old Name');
      final updated = original.copyWith(name: 'New Name');

      expect(updated.name, 'New Name');
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
    });

    test('updates templateCount', () {
      final folder = _makeFolder().copyWith(templateCount: 5);

      expect(folder.templateCount, 5);
    });

    test('updates sortOrder', () {
      final folder = _makeFolder().copyWith(sortOrder: 3);

      expect(folder.sortOrder, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // JSON serialization round-trip
  // ---------------------------------------------------------------------------
  group('TemplateFolder JSON', () {
    test('fromJson/toJson round-trip preserves required fields', () {
      final original = _makeFolder(
        id: 'json-folder',
        userId: 'json-user',
        name: 'Serialized Folder',
      );

      final json = original.toJson();
      final restored = TemplateFolder.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.name, original.name);
      expect(restored.depth, original.depth);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromJson/toJson round-trip preserves nested folder fields', () {
      final original = _makeFolder(
        id: 'child-folder',
        parentId: 'parent-folder',
        depth: 1,
        sortOrder: 2,
      ).copyWith(
        icon: FolderIcon.dumbbell,
        color: 'FF5733',
        description: 'Strength templates',
        templateCount: 3,
      );

      final json = original.toJson();
      final restored = TemplateFolder.fromJson(json);

      expect(restored.parentId, 'parent-folder');
      expect(restored.depth, 1);
      expect(restored.sortOrder, 2);
      expect(restored.icon, FolderIcon.dumbbell);
      expect(restored.color, 'FF5733');
      expect(restored.description, 'Strength templates');
      expect(restored.templateCount, 3);
    });
  });
}
