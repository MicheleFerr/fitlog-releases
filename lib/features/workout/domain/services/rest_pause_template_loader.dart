import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';

/// Service for loading predefined rest-pause templates from assets
///
/// ⚡ PERFORMANCE: Static cache prevents duplicate loads when multiple
/// filter methods are called (loadBeginner, loadIntermediate, etc.)
class RestPauseTemplateLoader {
  static const String _templatesPath = 'assets/data/rest_pause_templates.json';

  /// Static cache to prevent duplicate asset loads
  static List<RestPauseTemplate>? _cache;

  /// In-flight request to prevent concurrent loads
  static Future<List<RestPauseTemplate>>? _pending;

  /// Load all predefined templates from JSON file
  /// ⚡ CACHED: Returns cached data if available
  static Future<List<RestPauseTemplate>> loadPredefinedTemplates() async {
    // Return cached data if available
    if (_cache != null) {
      return _cache!;
    }

    // If already loading, return the pending future
    if (_pending != null) {
      return _pending!;
    }

    // Start new load
    _pending = _loadInternal();

    try {
      final templates = await _pending!;
      _cache = templates;
      return templates;
    } finally {
      _pending = null;
    }
  }

  /// Internal method to actually load from assets
  static Future<List<RestPauseTemplate>> _loadInternal() async {
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

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cache = null;
    _pending = null;
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
    return all.where((t) => t.estimatedTimeMinutes <= maxMinutes).toList();
  }
}
