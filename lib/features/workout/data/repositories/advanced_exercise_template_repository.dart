/// Advanced Exercise Template Repository
///
/// Provides CRUD operations for advanced exercise templates.
/// Uses Hive for local storage with optional cloud sync for premium users.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/advanced_exercise_template.dart';

/// Repository interface for advanced exercise templates
abstract class AdvancedExerciseTemplateRepository {
  /// Get all templates for a user
  Future<List<AdvancedExerciseTemplate>> getTemplates(String userId);

  /// Get a specific template by ID
  Future<AdvancedExerciseTemplate?> getTemplateById(String id);

  /// Create a new template
  Future<AdvancedExerciseTemplate> createTemplate(
      AdvancedExerciseTemplate template);

  /// Update an existing template
  Future<AdvancedExerciseTemplate> updateTemplate(
      AdvancedExerciseTemplate template);

  /// Delete a template
  Future<void> deleteTemplate(String id);

  /// Get template count for a user
  Future<int> getTemplateCount(String userId);

  /// Toggle favorite status
  Future<AdvancedExerciseTemplate> toggleFavorite(String id);

  /// Increment usage count
  Future<void> incrementUsageCount(String id);

  /// Get templates by type
  Future<List<AdvancedExerciseTemplate>> getTemplatesByType(
    String userId,
    AdvancedExerciseType type,
  );

  /// Search templates by name
  Future<List<AdvancedExerciseTemplate>> searchTemplates(
    String userId,
    String query,
  );
}

/// Hive-based implementation of the template repository
class HiveAdvancedExerciseTemplateRepository
    implements AdvancedExerciseTemplateRepository {
  static const String _boxName = 'advanced_exercise_templates';
  final Uuid _uuid = const Uuid();

  Box<String>? _box;

  /// Initialize the repository
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
  }

  Box<String> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'Repository not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  @override
  Future<List<AdvancedExerciseTemplate>> getTemplates(String userId) async {
    await init();
    final templates = <AdvancedExerciseTemplate>[];

    for (final key in _safeBox.keys) {
      try {
        final json = _safeBox.get(key);
        if (json != null) {
          final template = AdvancedExerciseTemplate.fromJson(
            jsonDecode(json) as Map<String, dynamic>,
          );
          if (template.userId == userId) {
            templates.add(template);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing template $key: $e');
        }
      }
    }

    // Sort by lastUsedAt (most recent first), then by createdAt
    templates.sort((a, b) {
      final aDate = a.lastUsedAt ?? a.createdAt;
      final bDate = b.lastUsedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });

    return templates;
  }

  @override
  Future<AdvancedExerciseTemplate?> getTemplateById(String id) async {
    await init();
    final json = _safeBox.get(id);
    if (json == null) return null;

    try {
      return AdvancedExerciseTemplate.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing template $id: $e');
      }
      return null;
    }
  }

  @override
  Future<AdvancedExerciseTemplate> createTemplate(
    AdvancedExerciseTemplate template,
  ) async {
    await init();

    // Ensure unique ID
    final id = template.id.isEmpty ? _uuid.v4() : template.id;
    final now = DateTime.now();

    final newTemplate = template.copyWith(
      id: id,
      createdAt: now,
      updatedAt: now,
    );

    await _safeBox.put(id, jsonEncode(newTemplate.toJson()));

    if (kDebugMode) {
      debugPrint('Created template: ${newTemplate.name} (${newTemplate.type})');
    }

    return newTemplate;
  }

  @override
  Future<AdvancedExerciseTemplate> updateTemplate(
    AdvancedExerciseTemplate template,
  ) async {
    await init();

    final updatedTemplate = template.copyWith(
      updatedAt: DateTime.now(),
    );

    await _safeBox.put(template.id, jsonEncode(updatedTemplate.toJson()));

    if (kDebugMode) {
      debugPrint('Updated template: ${updatedTemplate.name}');
    }

    return updatedTemplate;
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await init();
    await _safeBox.delete(id);

    if (kDebugMode) {
      debugPrint('Deleted template: $id');
    }
  }

  @override
  Future<int> getTemplateCount(String userId) async {
    final templates = await getTemplates(userId);
    return templates.length;
  }

  @override
  Future<AdvancedExerciseTemplate> toggleFavorite(String id) async {
    final template = await getTemplateById(id);
    if (template == null) {
      throw Exception('Template not found: $id');
    }

    final updatedTemplate = template.copyWith(
      isFavorite: !template.isFavorite,
      updatedAt: DateTime.now(),
    );

    await _safeBox.put(id, jsonEncode(updatedTemplate.toJson()));

    return updatedTemplate;
  }

  @override
  Future<void> incrementUsageCount(String id) async {
    final template = await getTemplateById(id);
    if (template == null) return;

    final updatedTemplate = template.copyWith(
      usageCount: template.usageCount + 1,
      lastUsedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _safeBox.put(id, jsonEncode(updatedTemplate.toJson()));
  }

  @override
  Future<List<AdvancedExerciseTemplate>> getTemplatesByType(
    String userId,
    AdvancedExerciseType type,
  ) async {
    final allTemplates = await getTemplates(userId);
    return allTemplates.where((t) => t.type == type).toList();
  }

  @override
  Future<List<AdvancedExerciseTemplate>> searchTemplates(
    String userId,
    String query,
  ) async {
    if (query.isEmpty) return getTemplates(userId);

    final allTemplates = await getTemplates(userId);
    final lowerQuery = query.toLowerCase();

    return allTemplates.where((t) {
      return t.name.toLowerCase().contains(lowerQuery) ||
          (t.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Close the Hive box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
