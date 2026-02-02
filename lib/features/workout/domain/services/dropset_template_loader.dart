import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';

/// Service for loading predefined dropset templates from assets
class DropsetTemplateLoader {
  static const String _templatesPath = 'assets/data/dropset_templates.json';

  /// Load all predefined templates from JSON file
  static Future<List<DropsetTemplate>> loadPredefinedTemplates() async {
    try {
      final jsonString = await rootBundle.loadString(_templatesPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final templatesJson = json['templates'] as List;
      final templates = templatesJson
          .map((t) => DropsetTemplate.fromJson(t as Map<String, dynamic>))
          .toList();

      return templates;
    } catch (e) {
      throw Exception('Failed to load dropset templates: $e');
    }
  }

  /// Load only beginner-friendly templates
  static Future<List<DropsetTemplate>> loadBeginner() async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.difficulty == DropsetDifficulty.beginner)
        .toList();
  }

  /// Load only intermediate templates
  static Future<List<DropsetTemplate>> loadIntermediate() async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.difficulty == DropsetDifficulty.intermediate)
        .toList();
  }

  /// Load only advanced templates
  static Future<List<DropsetTemplate>> loadAdvanced() async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.difficulty == DropsetDifficulty.advanced)
        .toList();
  }

  /// Load only time-efficient templates (under 15min)
  static Future<List<DropsetTemplate>> loadTimeEfficient({
    int maxMinutes = 15,
  }) async {
    final all = await loadPredefinedTemplates();
    return all.where((t) => t.estimatedTimeMinutes <= maxMinutes).toList();
  }
}
