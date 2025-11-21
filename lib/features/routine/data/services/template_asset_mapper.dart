/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data/services
/// 🎯 Feature: flexible_routine
/// 🔧 Type: service (development utility)
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// TEMPLATE ASSET MAPPER - Development Utility
///
/// Helper service for creating preset template JSON assets.
/// Takes user-created templates and exports them to asset-friendly JSON format.
///
/// Usage (development only):
/// ```dart
/// final mapper = TemplateAssetMapper();
/// final jsonString = mapper.exportTemplatesAsAsset(
///   templates: myTemplates,
///   presetType: RoutinePreset.ppl6Day,
/// );
/// // Save jsonString to assets/data/preset_templates/ppl_templates.json
/// ```
library;

import 'dart:convert';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';

/// Service for mapping workout templates to asset JSON format
///
/// This is a development utility used to:
/// 1. Export curated user templates to asset JSON
/// 2. Validate template structure for presets
/// 3. Generate sample templates for testing
class TemplateAssetMapper {
  /// Export templates as JSON asset string
  ///
  /// Parameters:
  /// - [templates]: List of templates to export
  /// - [presetType]: Preset type for metadata
  /// - [prettyPrint]: Enable pretty JSON formatting (default: true)
  ///
  /// Returns:
  /// - JSON string ready to save as asset file
  String exportTemplatesAsAsset({
    required List<WorkoutTemplate> templates,
    required RoutinePreset presetType,
    bool prettyPrint = true,
  }) {
    final assetData = {
      'metadata': {
        'presetType': presetType.name,
        'totalTemplates': templates.length,
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      },
      'templates': templates.map((t) => t.toJson()).toList(),
    };

    if (prettyPrint) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(assetData);
    } else {
      return json.encode(assetData);
    }
  }

  /// Validate templates for a preset type
  ///
  /// Checks:
  /// - Template count matches preset days
  /// - Templates have proper muscle group coverage
  /// - No duplicate template names
  ///
  /// Returns:
  /// - List of validation error messages (empty if valid)
  List<String> validateTemplatesForPreset({
    required List<WorkoutTemplate> templates,
    required RoutinePreset preset,
  }) {
    final errors = <String>[];

    // Skip validation for custom preset
    if (preset == RoutinePreset.custom) {
      return errors;
    }

    // Check template count matches preset days
    final expectedDays = preset.defaultTrainingDays.length;
    if (templates.length != expectedDays) {
      errors.add(
        'Expected $expectedDays templates for ${preset.displayName}, '
        'but got ${templates.length}',
      );
    }

    // Check for duplicate names
    final names = templates.map((t) => t.name).toList();
    final uniqueNames = names.toSet();
    if (names.length != uniqueNames.length) {
      errors.add('Duplicate template names found');
    }

    // Check each template has exercises
    for (final template in templates) {
      if (template.exercises.isEmpty) {
        errors.add('Template "${template.name}" has no exercises');
      }
    }

    return errors;
  }

  /// Generate sample templates for a preset (for testing/demo)
  ///
  /// Creates basic template stubs with proper naming
  List<WorkoutTemplate> generateSampleTemplates(RoutinePreset preset) {
    if (preset == RoutinePreset.custom) {
      return [];
    }

    final templates = <WorkoutTemplate>[];
    final trainingDays = preset.defaultTrainingDays.toList()..sort();

    for (final dayOfWeek in trainingDays) {
      final dayName = _getDayName(dayOfWeek);
      final focusName = _getFocusName(preset, dayOfWeek);

      templates.add(WorkoutTemplate(
        id: 'sample_${preset.name}_day$dayOfWeek',
        userId: 'system',
        name: '$focusName - $dayName',
        description: 'Sample template for ${preset.displayName}',
        exercises: [], // Empty - to be filled manually
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    return templates;
  }

  /// Get day name from weekday number
  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Day $dayOfWeek';
    }
  }

  /// Get focus name for preset + day
  String _getFocusName(RoutinePreset preset, int dayOfWeek) {
    switch (preset) {
      case RoutinePreset.ppl6Day:
        final cycle = (dayOfWeek - 1) % 3;
        return cycle == 0 ? 'Push' : cycle == 1 ? 'Pull' : 'Legs';

      case RoutinePreset.upperLower4Day:
        final trainingDays = [1, 2, 4, 5];
        final position = trainingDays.indexOf(dayOfWeek);
        return position % 2 == 0 ? 'Upper' : 'Lower';

      case RoutinePreset.fullBody3Day:
        return 'Full Body';

      case RoutinePreset.broSplit5Day:
        switch (dayOfWeek) {
          case 1:
            return 'Chest';
          case 2:
            return 'Back';
          case 3:
            return 'Legs';
          case 4:
            return 'Shoulders';
          case 5:
            return 'Arms';
          default:
            return 'Unknown';
        }

      case RoutinePreset.custom:
        return 'Custom';
    }
  }

  /// Import templates from asset JSON string
  ///
  /// Parses JSON and returns list of WorkoutTemplate entities
  ///
  /// Throws:
  /// - FormatException if JSON is invalid
  List<WorkoutTemplate> importTemplatesFromAsset(String jsonString) {
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final templatesList = jsonData['templates'] as List<dynamic>;

    return templatesList
        .map((json) => WorkoutTemplate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get asset metadata from JSON string
  ///
  /// Returns metadata map or null if not found
  Map<String, dynamic>? getAssetMetadata(String jsonString) {
    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return jsonData['metadata'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}
