/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data/repositories
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository
/// 🌍 Localization: N/A (uses asset JSON files)
/// 📱 Platform: Universal
///
/// PRESET TEMPLATE REPOSITORY - Local Asset Loading
///
/// Loads preset workout templates from bundled JSON assets.
/// These templates are used for routine creation suggestions based on preset type.
///
/// Asset Files:
/// - assets/data/preset_templates/ppl_templates.json
/// - assets/data/preset_templates/upper_lower_templates.json
/// - assets/data/preset_templates/full_body_templates.json
/// - assets/data/preset_templates/bro_split_templates.json
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Repository for loading preset workout templates from local assets
///
/// Usage:
/// ```dart
/// final repo = PresetTemplateRepository();
/// final templates = await repo.getTemplatesForPreset(RoutinePreset.ppl6Day);
/// ```
class PresetTemplateRepository {
  /// Cache for loaded templates (preset type → templates)
  final Map<RoutinePreset, List<WorkoutTemplate>> _cache = {};

  /// Load templates for a specific preset type
  ///
  /// Returns:
  /// - List of WorkoutTemplate for the preset
  /// - Empty list for custom presets (no defaults)
  /// - Cached result on subsequent calls
  Future<List<WorkoutTemplate>> getTemplatesForPreset(
    RoutinePreset preset,
  ) async {
    // Return empty for custom (no default templates)
    if (preset == RoutinePreset.custom) {
      return [];
    }

    // Return cached if available
    if (_cache.containsKey(preset)) {
      return _cache[preset]!;
    }

    try {
      // Load from asset
      final assetPath = _getAssetPathForPreset(preset);
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Parse templates
      final templatesList = jsonData['templates'] as List<dynamic>;
      final templates = templatesList
          .map((json) => WorkoutTemplate.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache and return
      _cache[preset] = templates;
      return templates;
    } catch (e) {
      _log('Failed to load templates for $preset: $e');
      // Return empty list on error (graceful degradation)
      return [];
    }
  }

  /// Get asset path for a preset type
  String _getAssetPathForPreset(RoutinePreset preset) {
    switch (preset) {
      case RoutinePreset.ppl6Day:
        return 'assets/data/preset_templates/ppl_templates.json';
      case RoutinePreset.upperLower4Day:
        return 'assets/data/preset_templates/upper_lower_templates.json';
      case RoutinePreset.fullBody3Day:
        return 'assets/data/preset_templates/full_body_templates.json';
      case RoutinePreset.broSplit5Day:
        return 'assets/data/preset_templates/bro_split_templates.json';
      case RoutinePreset.custom:
        return ''; // No asset for custom
    }
  }

  /// Clear cache (useful for testing or memory management)
  void clearCache() {
    _cache.clear();
  }

  /// Get all templates for all presets (preload)
  ///
  /// Useful for warming up cache on app startup
  Future<void> preloadAllTemplates() async {
    final presets = [
      RoutinePreset.ppl6Day,
      RoutinePreset.upperLower4Day,
      RoutinePreset.fullBody3Day,
      RoutinePreset.broSplit5Day,
    ];

    for (final preset in presets) {
      await getTemplatesForPreset(preset);
    }

    _log('Preloaded templates for ${presets.length} presets');
  }

  /// Log message (debug mode only)
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[PresetTemplateRepository] $message');
    }
  }
}
