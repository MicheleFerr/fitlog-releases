import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';

/// Service for loading predefined rest-pause templates from assets
class RestPauseTemplateLoader {
  static const String _templatesPath = 'assets/data/rest_pause_templates.json';

  /// Load all predefined templates from JSON file
  static Future<List<RestPauseTemplate>> loadPredefinedTemplates() async {
    try {
      final jsonString = await rootBundle.loadString(_templatesPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final templatesJson = json['templates'] as List;
      final templates = templatesJson
          .map((t) => RestPauseTemplate.fromJson(t as Map<String, dynamic>))
          .toList();

      return templates;
    } catch (e) {
      throw Exception('Failed to load rest-pause templates: $e');
    }
  }

  /// Load only beginner-friendly templates
  static Future<List<RestPauseTemplate>> loadBeginner() async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.difficulty == RestPauseDifficulty.beginner)
        .toList();
  }

  /// Load only intermediate templates
  static Future<List<RestPauseTemplate>> loadIntermediate() async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.difficulty == RestPauseDifficulty.intermediate)
        .toList();
  }

  /// Load only advanced templates
  static Future<List<RestPauseTemplate>> loadAdvanced() async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.difficulty == RestPauseDifficulty.advanced)
        .toList();
  }

  /// Load only time-efficient templates (under 20min)
  static Future<List<RestPauseTemplate>> loadTimeEfficient({
    int maxMinutes = 20,
  }) async {
    final all = await loadPredefinedTemplates();
    return all
        .where((t) => t.estimatedTimeMinutes <= maxMinutes)
        .toList();
  }
}
