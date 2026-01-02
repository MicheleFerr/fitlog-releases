/// Template Folder Entity (P2-3)
///
/// Allows coaches to organize their workout templates into folders.
/// Supports nested folders for hierarchical organization.
///
/// **Features:**
/// - Nested folders (up to 3 levels deep)
/// - Custom icons per folder
/// - Sort order control
/// - Coach-specific folders
///
/// **Example:**
/// ```
/// "Push/Pull/Legs"
///   ├── "Push Day Variations"
///   │   ├── Template: "Push A - Chest Focus"
///   │   └── Template: "Push B - Shoulder Focus"
///   ├── "Pull Day Variations"
///   └── "Legs"
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_folder.freezed.dart';
part 'template_folder.g.dart';

/// Maximum nesting depth for folders
const int kMaxFolderDepth = 3;

/// Predefined folder icons (maps to IconData name)
enum FolderIcon {
  folder,
  star,
  fire,
  muscle,
  dumbbell,
  run,
  heart,
  trophy,
  calendar,
  target,
}

@freezed
abstract class TemplateFolder with _$TemplateFolder {
  const factory TemplateFolder({
    /// Unique folder ID
    required String id,

    /// Owner user ID (coach)
    required String userId,

    /// Folder name
    required String name,

    /// Parent folder ID (null for root folders)
    String? parentId,

    /// Folder color (hex string, e.g., 'FF5733')
    String? color,

    /// Folder icon
    @Default(FolderIcon.folder) FolderIcon icon,

    /// Sort order within parent
    @Default(0) int sortOrder,

    /// Nested depth level (0 = root, max = kMaxFolderDepth - 1)
    @Default(0) int depth,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    DateTime? updatedAt,

    /// Number of templates in this folder (denormalized for UI)
    @Default(0) int templateCount,

    /// Description/notes for the folder
    String? description,
  }) = _TemplateFolder;

  factory TemplateFolder.fromJson(Map<String, dynamic> json) =>
      _$TemplateFolderFromJson(json);
}

/// Extension with helper methods
extension TemplateFolderX on TemplateFolder {
  /// Check if this folder can have children
  bool get canHaveChildren => depth < kMaxFolderDepth - 1;

  /// Check if this is a root folder
  bool get isRoot => parentId == null;

  /// Get full path as list of folder IDs
  List<String> get pathIds => isRoot ? [id] : [parentId!, id];
}
