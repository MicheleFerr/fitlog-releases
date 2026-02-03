import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';

/// Service for loading predefined dropset templates from assets
///
/// ⚡ PERFORMANCE: Static cache prevents duplicate loads when multiple
/// filter methods are called (loadBeginner, loadIntermediate, etc.)
class DropsetTemplateLoader {
  static const String _templatesPath = 'assets/data/dropset_templates.json';

  /// Static cache to prevent duplicate asset loads
  static List<DropsetTemplate>? _cache;

  /// In-flight request to prevent concurrent loads
  static Future<List<DropsetTemplate>>? _pending;

  /// Load all predefined templates from JSON file
  /// ⚡ CACHED: Returns cached data if available
  static Future<List<DropsetTemplate>> loadPredefinedTemplates() async {
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
  static Future<List<DropsetTemplate>> _loadInternal() async {
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

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cache = null;
    _pending = null;
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
