/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/workout_templates/data/datasources
/// Feature: Default Templates DataSource
/// Type: DataSource
///
/// Loads default workout templates from bundled JSON assets.
/// Templates are evidence-based programs for different experience levels.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Local datasource for loading default workout templates from assets.
///
/// Loads JSON files bundled with the app:
/// - assets/data/default_templates/beginner_templates.json
/// - assets/data/default_templates/intermediate_templates.json
/// - assets/data/default_templates/_index.json
class DefaultTemplatesDataSource {
  static const _basePath = 'assets/data/default_templates';
  static const _indexPath = '$_basePath/_index.json';
  static const _beginnerPath = '$_basePath/beginner_templates.json';
  static const _intermediatePath = '$_basePath/intermediate_templates.json';
  static const _advancedPath = '$_basePath/advanced_templates.json';
  static const _homePath = '$_basePath/home_bodyweight_templates.json';
  static const _dumbbellPath = '$_basePath/dumbbell_templates.json';
  static const _expressPath = '$_basePath/express_templates.json';
  static const _specialtyPath = '$_basePath/specialty_templates.json';

  /// All template file paths for loading
  static const _allTemplatePaths = [
    _beginnerPath,
    _intermediatePath,
    _advancedPath,
    _homePath,
    _dumbbellPath,
    _expressPath,
    _specialtyPath,
  ];

  // Cache for loaded templates
  List<WorkoutTemplate>? _cachedTemplates;
  Map<String, dynamic>? _cachedIndex;

  /// Load all default templates from all categories
  Future<List<WorkoutTemplate>> loadAllTemplates() async {
    // Return cached if available
    if (_cachedTemplates != null) {
      return _cachedTemplates!;
    }

    try {
      final allTemplates = <WorkoutTemplate>[];

      // Load all template files
      for (final path in _allTemplatePaths) {
        final templates = await _loadTemplatesFromFile(path);
        allTemplates.addAll(templates);
      }

      _cachedTemplates = allTemplates;

      if (kDebugMode) {
        debugPrint(
          '📚 DefaultTemplates: Loaded ${allTemplates.length} default templates',
        );
      }

      return allTemplates;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DefaultTemplates: Failed to load templates: $e');
      }
      throw DefaultTemplatesLoadException(
        'Failed to load default templates: $e',
      );
    }
  }

  /// Load templates by difficulty level
  Future<List<WorkoutTemplate>> loadTemplatesByDifficulty(
    String difficulty,
  ) async {
    final allTemplates = await loadAllTemplates();
    return allTemplates
        .where((t) => t.difficulty?.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  /// Load beginner templates only
  Future<List<WorkoutTemplate>> loadBeginnerTemplates() async {
    return _loadTemplatesFromFile(_beginnerPath);
  }

  /// Load intermediate templates only
  Future<List<WorkoutTemplate>> loadIntermediateTemplates() async {
    return _loadTemplatesFromFile(_intermediatePath);
  }

  /// Load the index file with all template metadata
  Future<Map<String, dynamic>> loadIndex() async {
    if (_cachedIndex != null) {
      return _cachedIndex!;
    }

    try {
      final jsonString = await rootBundle.loadString(_indexPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      _cachedIndex = jsonData;
      return jsonData;
    } catch (e) {
      throw DefaultTemplatesLoadException('Failed to load index: $e');
    }
  }

  /// Get template categories from index
  Future<List<DefaultTemplateCategory>> loadCategories() async {
    final index = await loadIndex();
    final categoriesList = index['categories'] as List<dynamic>? ?? [];

    return categoriesList
        .map((e) => DefaultTemplateCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Load templates from a specific file
  Future<List<WorkoutTemplate>> _loadTemplatesFromFile(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final templatesList = jsonData['templates'] as List<dynamic>? ?? [];

      return templatesList.map((e) {
        final templateJson = e as Map<String, dynamic>;
        return WorkoutTemplate.fromJson(templateJson);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DefaultTemplates: Failed to load from $path: $e');
      }
      return [];
    }
  }

  /// Clear cache (useful for testing or refresh)
  void clearCache() {
    _cachedTemplates = null;
    _cachedIndex = null;
  }
}

/// Exception thrown when default templates cannot be loaded
class DefaultTemplatesLoadException implements Exception {
  DefaultTemplatesLoadException(this.message);
  final String message;

  @override
  String toString() => 'DefaultTemplatesLoadException: $message';
}

/// Represents a default template category from the index (beginner, intermediate, etc.)
class DefaultTemplateCategory {
  const DefaultTemplateCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.file,
    required this.templateCount,
    required this.icon,
  });

  factory DefaultTemplateCategory.fromJson(Map<String, dynamic> json) {
    return DefaultTemplateCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionEn:
          json['descriptionEn'] as String? ?? json['description'] as String? ?? '',
      file: json['file'] as String? ?? '',
      templateCount: json['templateCount'] as int? ?? 0,
      icon: json['icon'] as String? ?? 'fitness_center',
    );
  }

  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String descriptionEn;
  final String file;
  final int templateCount;
  final String icon;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameEn': nameEn,
        'description': description,
        'descriptionEn': descriptionEn,
        'file': file,
        'templateCount': templateCount,
        'icon': icon,
      };
}
