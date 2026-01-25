import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/superset_template_loader.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/hybrid_exercise_repository.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Repository for superset templates with local storage
///
/// Manages both predefined templates (loaded from JSON) and user custom templates
/// (stored in SharedPreferences).
///
/// 🔐 USER ISOLATION: Cache keys are user-scoped via UserCacheKeyManager
class SupersetTemplateRepository {
  SupersetTemplateRepository({
    this.exerciseRepository,
  });

  /// Exercise repository for looking up localized exercise names
  final HybridExerciseRepository? exerciseRepository;

  // 🔐 User-scoped cache keys
  String get _customTemplatesKey => userCacheKeys.supersetTemplatesCacheKey;
  String get _predefinedLoadedKey =>
      userCacheKeys.supersetPredefinedLoadedKey;

  /// Exercise lookup function that uses the injected repository
  Future<ExerciseLookupFunction?> get _lookupFunction async {
    if (exerciseRepository == null) return null;
    return (String exerciseId) => exerciseRepository!.getExerciseById(exerciseId);
  }

  /// Get all templates (predefined + custom)
  Future<List<SupersetTemplate>> getAllTemplates() async {
    final predefined = await getPredefinedTemplates();
    final custom = await getCustomTemplates();

    // Combine and sort by usage and date
    final allTemplates = [...predefined, ...custom];
    allTemplates.sort((a, b) {
      // Sort by creation date (newer first) for now
      // Can add usage tracking later
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return allTemplates;
  }

  /// Get predefined templates from JSON
  Future<List<SupersetTemplate>> getPredefinedTemplates() async {
    try {
      final lookup = await _lookupFunction;
      return await SupersetTemplateLoader.loadPredefinedTemplates(
        lookupExercise: lookup,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load predefined superset templates: $e');
      }
      return [];
    }
  }

  /// Get user custom templates
  Future<List<SupersetTemplate>> getCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_customTemplatesKey);

      if (templatesJson == null) {
        return [];
      }

      final List<dynamic> templatesList = json.decode(templatesJson);
      final customTemplates = templatesList
          .map((json) => SupersetTemplate.fromJson(json))
          .where((template) => template.isCustom)
          .toList();

      return customTemplates;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load custom superset templates: $e');
      }
      return [];
    }
  }

  /// Get templates for specific persona
  Future<List<SupersetTemplate>> getTemplatesForPersona(
    UserPersona persona,
  ) async {
    try {
      final lookup = await _lookupFunction;
      // Get predefined templates for persona
      final predefined = await SupersetTemplateLoader.loadForPersona(
        persona,
        lookupExercise: lookup,
      );

      // Get custom templates (all are generic persona)
      final custom = await getCustomTemplates();

      return [...predefined, ...custom];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load templates for persona $persona: $e');
      }
      return [];
    }
  }

  /// Get evidence-based templates
  Future<List<SupersetTemplate>> getEvidenceBasedTemplates() async {
    try {
      final lookup = await _lookupFunction;
      return await SupersetTemplateLoader.loadEvidenceBased(
        lookupExercise: lookup,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load evidence-based templates: $e');
      }
      return [];
    }
  }

  /// Get time-efficient templates (15-20min range)
  Future<List<SupersetTemplate>> getTimeEfficientTemplates({
    int minMinutes = 15,
    int maxMinutes = 20,
  }) async {
    try {
      final lookup = await _lookupFunction;
      return await SupersetTemplateLoader.loadTimeEfficient(
        minMinutes: minMinutes,
        maxMinutes: maxMinutes,
        lookupExercise: lookup,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load time-efficient templates: $e');
      }
      return [];
    }
  }

  /// Get beginner-friendly templates
  Future<List<SupersetTemplate>> getBeginnerTemplates() async {
    try {
      final lookup = await _lookupFunction;
      return await SupersetTemplateLoader.loadBeginner(
        lookupExercise: lookup,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load beginner templates: $e');
      }
      return [];
    }
  }

  /// Get advanced templates
  Future<List<SupersetTemplate>> getAdvancedTemplates() async {
    try {
      final lookup = await _lookupFunction;
      return await SupersetTemplateLoader.loadAdvanced(
        lookupExercise: lookup,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load advanced templates: $e');
      }
      return [];
    }
  }

  /// Save a custom template
  ///
  /// [maxCustomSupersets] - Maximum custom superset templates (from tierEntitlementsProvider)
  Future<void> saveCustomTemplate(
    SupersetTemplate template, {
    required int maxCustomSupersets,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '💾 Saving custom superset template "${template.name}" with ${template.exerciseNames.length} exercises',
      );
    }

    try {
      final customTemplates = await getCustomTemplates();

      // Check limit BEFORE saving (skip if updating existing template)
      final isUpdate = customTemplates.any((t) => t.id == template.id);
      if (!isUpdate && customTemplates.length >= maxCustomSupersets) {
        throw Exception(
          'Custom superset limit reached: ${customTemplates.length}/$maxCustomSupersets. '
          'Delete existing templates or upgrade tier for more slots.',
        );
      }

      // Remove existing template if updating
      customTemplates.removeWhere((t) => t.id == template.id);

      // Add updated template (ensure it's marked as custom)
      final customTemplate = template.copyWith(
        isCustom: true,
        createdAt: template.createdAt ?? DateTime.now(),
      );
      customTemplates.add(customTemplate);

      // Save custom templates
      await _saveCustomTemplates(customTemplates);

      if (kDebugMode) {
        debugPrint(
          '✅ Custom template saved. Total custom templates: ${customTemplates.length}/$maxCustomSupersets',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving custom template: $e');
      }
      throw Exception('Failed to save custom template: $e');
    }
  }

  /// Delete a custom template
  Future<void> deleteCustomTemplate(String templateId) async {
    try {
      final customTemplates = await getCustomTemplates();
      final templateToDelete = customTemplates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found'),
      );

      // Don't allow deletion of predefined templates
      if (!templateToDelete.isCustom) {
        throw Exception('Cannot delete predefined templates');
      }

      // Remove from custom templates
      customTemplates.removeWhere((t) => t.id == templateId);

      // Save updated list
      await _saveCustomTemplates(customTemplates);

      if (kDebugMode) {
        debugPrint('✅ Custom template $templateId deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting template $templateId: $e');
      }
      throw Exception('Failed to delete template: $e');
    }
  }

  /// Search templates by name, notes, or target muscles
  Future<List<SupersetTemplate>> searchTemplates(String query) async {
    final templates = await getAllTemplates();
    final lowerQuery = query.toLowerCase();

    return templates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
          (template.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
          (template.scientificBasis.toLowerCase().contains(lowerQuery)) ||
          (template.targetMuscles?.any(
                (muscle) => muscle.toLowerCase().contains(lowerQuery),
              ) ??
              false);
    }).toList();
  }

  /// Filter templates by difficulty
  Future<List<SupersetTemplate>> getTemplatesByDifficulty(
    TemplateDifficulty difficulty,
  ) async {
    final templates = await getAllTemplates();
    return templates.where((t) => t.difficulty == difficulty).toList();
  }

  /// Filter templates by target muscles
  Future<List<SupersetTemplate>> getTemplatesByMuscles(
    List<String> muscles,
  ) async {
    final templates = await getAllTemplates();

    return templates.where((template) {
      if (template.targetMuscles == null) return false;
      return muscles.any(
        (muscle) => template.targetMuscles!.contains(muscle),
      );
    }).toList();
  }

  /// Save custom templates to SharedPreferences
  Future<void> _saveCustomTemplates(
    List<SupersetTemplate> customTemplates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Filter to ensure only custom templates are saved
      final customOnly = customTemplates.where((t) => t.isCustom).toList();
      final templatesJson = json.encode(
        customOnly.map((template) => template.toJson()).toList(),
      );
      await prefs.setString(_customTemplatesKey, templatesJson);

      if (kDebugMode) {
        debugPrint('✅ Saved ${customOnly.length} custom superset templates');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving custom superset templates: $e');
      }
      throw Exception('Failed to save custom templates');
    }
  }
}
