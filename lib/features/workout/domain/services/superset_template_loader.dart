import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Typedef for exercise lookup function
typedef ExerciseLookupFunction = Future<Exercise?> Function(String exerciseId);

/// Service for loading predefined superset templates from assets
class SupersetTemplateLoader {
  static const String _templatesPath = 'assets/data/superset_templates.json';

  /// Load all predefined templates from JSON file
  /// If [lookupExercise] is provided, populates exerciseNames with localized names
  static Future<List<SupersetTemplate>> loadPredefinedTemplates({
    ExerciseLookupFunction? lookupExercise,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(_templatesPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final templatesJson = json['templates'] as List;
      final templates = templatesJson
          .map((t) => SupersetTemplate.fromJson(t as Map<String, dynamic>))
          .toList();

      // If lookup function provided, resolve exercise names
      if (lookupExercise != null) {
        return _resolveExerciseNames(templates, lookupExercise);
      }

      return templates;
    } catch (e) {
      throw Exception('Failed to load superset templates: $e');
    }
  }

  /// Resolves exercise IDs to localized exercise names
  static Future<List<SupersetTemplate>> _resolveExerciseNames(
    List<SupersetTemplate> templates,
    ExerciseLookupFunction lookupExercise,
  ) async {
    final resolvedTemplates = <SupersetTemplate>[];

    for (final template in templates) {
      final exerciseNames = <String>[];

      for (final exerciseId in template.exerciseIds) {
        try {
          final exercise = await lookupExercise(exerciseId);
          if (exercise != null) {
            exerciseNames.add(exercise.nome);
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ SUPERSET LOADER: Exercise not found for ID: $exerciseId',
              );
            }
            // Fallback: use the ID as name (better than empty)
            exerciseNames.add(exerciseId.replaceAll('_', ' ').capitalize());
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ SUPERSET LOADER: Error looking up $exerciseId: $e');
          }
          exerciseNames.add(exerciseId.replaceAll('_', ' ').capitalize());
        }
      }

      resolvedTemplates.add(template.copyWith(exerciseNames: exerciseNames));
    }

    return resolvedTemplates;
  }

  /// Load only templates for specific persona
  static Future<List<SupersetTemplate>> loadForPersona(
    UserPersona persona, {
    ExerciseLookupFunction? lookupExercise,
  }) async {
    final all = await loadPredefinedTemplates(lookupExercise: lookupExercise);
    return all
        .where((t) => t.targetPersona == persona || t.targetPersona == null)
        .toList();
  }

  /// Load only evidence-based templates (with scientific backing)
  static Future<List<SupersetTemplate>> loadEvidenceBased({
    ExerciseLookupFunction? lookupExercise,
  }) async {
    final all = await loadPredefinedTemplates(lookupExercise: lookupExercise);
    return all.where((t) => t.scientificBasis.isNotEmpty).toList();
  }

  /// Load only time-efficient templates (15-20min range)
  static Future<List<SupersetTemplate>> loadTimeEfficient({
    int minMinutes = 15,
    int maxMinutes = 20,
    ExerciseLookupFunction? lookupExercise,
  }) async {
    final all = await loadPredefinedTemplates(lookupExercise: lookupExercise);
    return all
        .where(
          (t) =>
              t.estimatedTimeMinutes >= minMinutes &&
              t.estimatedTimeMinutes <= maxMinutes,
        )
        .toList();
  }

  /// Load only beginner-friendly templates
  static Future<List<SupersetTemplate>> loadBeginner({
    ExerciseLookupFunction? lookupExercise,
  }) async {
    final all = await loadPredefinedTemplates(lookupExercise: lookupExercise);
    return all
        .where((t) => t.difficulty == TemplateDifficulty.beginner)
        .toList();
  }

  /// Load only advanced templates
  static Future<List<SupersetTemplate>> loadAdvanced({
    ExerciseLookupFunction? lookupExercise,
  }) async {
    final all = await loadPredefinedTemplates(lookupExercise: lookupExercise);
    return all
        .where((t) => t.difficulty == TemplateDifficulty.advanced)
        .toList();
  }
}

/// Extension for string capitalize
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
