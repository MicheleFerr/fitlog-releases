import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Typedef for exercise lookup function
typedef ExerciseLookupFunction = Future<Exercise?> Function(String exerciseId);

/// Service for loading predefined superset templates from assets
///
/// ⚡ PERFORMANCE: Static cache prevents duplicate loads when multiple
/// filter methods are called (loadForPersona, loadEvidenceBased, etc.)
class SupersetTemplateLoader {
  static const String _templatesPath = 'assets/data/superset_templates.json';

  /// Static cache to prevent duplicate asset loads
  static List<SupersetTemplate>? _cache;

  /// In-flight request to prevent concurrent loads
  static Future<List<SupersetTemplate>>? _pending;

  /// Load all predefined templates from JSON file
  /// If [lookupExercise] is provided, populates exerciseNames with localized names
  /// ⚡ CACHED: Returns cached data if available (without exercise name resolution)
  static Future<List<SupersetTemplate>> loadPredefinedTemplates({
    ExerciseLookupFunction? lookupExercise,
  }) async {
    // Load base templates (cached)
    List<SupersetTemplate> templates;

    // Return cached data if available
    if (_cache != null) {
      templates = _cache!;
    } else if (_pending != null) {
      // If already loading, wait for it
      templates = await _pending!;
    } else {
      // Start new load
      _pending = _loadInternal();

      try {
        templates = await _pending!;
        _cache = templates;
      } finally {
        _pending = null;
      }
    }

    // If lookup function provided, resolve exercise names
    // NOTE: This is NOT cached as it depends on current locale
    if (lookupExercise != null) {
      return _resolveExerciseNames(templates, lookupExercise);
    }

    return templates;
  }

  /// Internal method to actually load from assets
  static Future<List<SupersetTemplate>> _loadInternal() async {
    try {
      final jsonString = await rootBundle.loadString(_templatesPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final templatesJson = json['templates'] as List;
      final templates = templatesJson
          .map((t) => SupersetTemplate.fromJson(t as Map<String, dynamic>))
          .toList();

      return templates;
    } catch (e) {
      throw Exception('Failed to load superset templates: $e');
    }
  }

  /// Resolves exercise IDs to localized exercise names
  /// ⚡ PERF FIX: Uses Future.wait() for parallel lookups instead of sequential
  static Future<List<SupersetTemplate>> _resolveExerciseNames(
    List<SupersetTemplate> templates,
    ExerciseLookupFunction lookupExercise,
  ) async {
    final resolvedTemplates = <SupersetTemplate>[];

    for (final template in templates) {
      // ⚡ PERF: Lookup all exercises in parallel instead of sequentially
      final exerciseNamesFutures = template.exerciseIds.map((exerciseId) async {
        try {
          final exercise = await lookupExercise(exerciseId);
          if (exercise != null) {
            return exercise.nome;
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ SUPERSET LOADER: Exercise not found for ID: $exerciseId',
              );
            }
            // Fallback: use the ID as name (better than empty)
            return exerciseId.replaceAll('_', ' ').capitalize();
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ SUPERSET LOADER: Error looking up $exerciseId: $e');
          }
          return exerciseId.replaceAll('_', ' ').capitalize();
        }
      });

      final exerciseNames = await Future.wait(exerciseNamesFutures);
      resolvedTemplates.add(template.copyWith(exerciseNames: exerciseNames));
    }

    return resolvedTemplates;
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _cache = null;
    _pending = null;
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
