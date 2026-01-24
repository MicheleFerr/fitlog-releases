import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rest_pause_template_loader.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Repository for rest-pause templates with local storage
///
/// Manages both predefined templates (loaded from JSON) and user custom templates
/// (stored in SharedPreferences).
///
/// 🔐 USER ISOLATION: Cache keys are user-scoped via UserCacheKeyManager
class RestPauseTemplateRepository {
  // 🔐 User-scoped cache keys
  String get _customTemplatesKey => userCacheKeys.restPauseTemplatesCacheKey;

  /// Get all templates (predefined + custom)
  Future<List<RestPauseTemplate>> getAllTemplates() async {
    final predefined = await getPredefinedTemplates();
    final custom = await getCustomTemplates();

    // Combine and sort by creation date (newer first)
    final allTemplates = [...predefined, ...custom];
    allTemplates.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    return allTemplates;
  }

  /// Get predefined templates from JSON
  Future<List<RestPauseTemplate>> getPredefinedTemplates() async {
    try {
      return await RestPauseTemplateLoader.loadPredefinedTemplates();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load predefined rest-pause templates: $e');
      }
      return [];
    }
  }

  /// Get user custom templates
  Future<List<RestPauseTemplate>> getCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_customTemplatesKey);

      if (templatesJson == null) {
        return [];
      }

      final List<dynamic> templatesList = json.decode(templatesJson);
      final customTemplates = templatesList
          .map((json) => RestPauseTemplate.fromJson(json))
          .where((template) => template.isCustom)
          .toList();

      return customTemplates;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load custom rest-pause templates: $e');
      }
      return [];
    }
  }

  /// Get beginner-friendly templates
  Future<List<RestPauseTemplate>> getBeginnerTemplates() async {
    try {
      return await RestPauseTemplateLoader.loadBeginner();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load beginner rest-pause templates: $e');
      }
      return [];
    }
  }

  /// Get advanced templates
  Future<List<RestPauseTemplate>> getAdvancedTemplates() async {
    try {
      return await RestPauseTemplateLoader.loadAdvanced();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load advanced rest-pause templates: $e');
      }
      return [];
    }
  }

  /// Save a custom template
  Future<void> saveCustomTemplate(RestPauseTemplate template) async {
    if (kDebugMode) {
      debugPrint(
        '💾 Saving custom rest-pause template "${template.name}"',
      );
    }

    try {
      final customTemplates = await getCustomTemplates();

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
          '✅ Custom rest-pause template saved. Total: ${customTemplates.length}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving custom rest-pause template: $e');
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
        debugPrint('✅ Custom rest-pause template $templateId deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting rest-pause template $templateId: $e');
      }
      throw Exception('Failed to delete template: $e');
    }
  }

  /// Search templates by name, notes, or target muscles
  Future<List<RestPauseTemplate>> searchTemplates(String query) async {
    final templates = await getAllTemplates();
    final lowerQuery = query.toLowerCase();

    return templates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
          (template.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
          template.exerciseName.toLowerCase().contains(lowerQuery) ||
          (template.targetMuscles?.any(
                (muscle) => muscle.toLowerCase().contains(lowerQuery),
              ) ??
              false);
    }).toList();
  }

  /// Filter templates by difficulty
  Future<List<RestPauseTemplate>> getTemplatesByDifficulty(
    RestPauseDifficulty difficulty,
  ) async {
    final templates = await getAllTemplates();
    return templates.where((t) => t.difficulty == difficulty).toList();
  }

  /// Save custom templates to SharedPreferences
  Future<void> _saveCustomTemplates(
    List<RestPauseTemplate> customTemplates,
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
        debugPrint('✅ Saved ${customOnly.length} custom rest-pause templates');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving custom rest-pause templates: $e');
      }
      throw Exception('Failed to save custom templates');
    }
  }
}
