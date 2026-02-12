/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/analytics/trackers
/// 🎯 Feature: analytics
/// 🔧 Type: tracker helper
///
/// Superset template event tracking helper
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';

/// Superset template event tracker
///
/// Helper class for tracking superset template events and operations.
/// Provides convenient methods with predefined event names and parameters.
///
/// Tracks:
/// - Template viewing (preview sheet opened)
/// - Template usage (user clicks "Use Template")
/// - Custom copy saving (user saves personalized copy)
/// - Tab navigation (superset tab opened)
///
/// Usage:
/// ```dart
/// final tracker = SupersetTemplateEventTracker(analytics);
///
/// // Track template viewed
/// await tracker.trackTemplateViewed(
///   template: template,
///   source: 'exercise_search',
/// );
///
/// // Track template used
/// await tracker.trackTemplateUsed(
///   template: template,
///   workoutId: 'workout_123',
/// );
/// ```
class SupersetTemplateEventTracker {
  SupersetTemplateEventTracker(this.analytics);

  final IAnalyticsService analytics;

  /// Track superset template viewed
  ///
  /// Logs when user opens the preview sheet for a superset template.
  ///
  /// Parameters:
  /// - [template] - The template being viewed
  /// - [source] - Where template was viewed from (exercise_search, workout_templates)
  Future<void> trackTemplateViewed({
    required SupersetTemplate template,
    String source = 'unknown',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.supersetTemplateViewed,
        parameters: {
          AnalyticsParameters.templateId: template.id,
          AnalyticsParameters.templateName: template.name,
          AnalyticsParameters.templateDifficulty: template.difficulty.name,
          AnalyticsParameters.isCustomTemplate: template.isCustom,
          AnalyticsParameters.isPredefinedTemplate: !template.isCustom,
          AnalyticsParameters.hasScientificBasis:
              template.scientificBasis.isNotEmpty,
          AnalyticsParameters.exerciseCount: template.exerciseNames.length,
          AnalyticsParameters.source: source,
        },
      );

      if (kDebugMode) {
        debugPrint(
          '📊 Superset template viewed: ${template.name} (${template.difficulty.name}) from $source',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking superset template viewed: $e');
      }
    }
  }

  /// Track superset template used
  ///
  /// Logs when user clicks "Use Template" to apply it to their workout.
  ///
  /// Parameters:
  /// - [template] - The template being used
  /// - [workoutId] - Optional workout ID if applying to existing workout
  /// - [source] - Where template was used from
  Future<void> trackTemplateUsed({
    required SupersetTemplate template,
    String? workoutId,
    String source = 'unknown',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.templateUsed,
        parameters: {
          AnalyticsParameters.templateId: template.id,
          AnalyticsParameters.templateName: template.name,
          AnalyticsParameters.templateDifficulty: template.difficulty.name,
          AnalyticsParameters.isCustomTemplate: template.isCustom,
          AnalyticsParameters.isPredefinedTemplate: !template.isCustom,
          AnalyticsParameters.hasScientificBasis:
              template.scientificBasis.isNotEmpty,
          AnalyticsParameters.exerciseCount: template.exerciseNames.length,
          if (workoutId != null) AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.source: source,
          AnalyticsParameters.templateType: 'superset', // Distinguish from regular templates
        },
      );

      if (kDebugMode) {
        debugPrint(
          '📊 Superset template used: ${template.name} (${template.difficulty.name}) from $source',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking superset template used: $e');
      }
    }
  }

  /// Track superset template custom copy saved
  ///
  /// Logs when user saves a personalized copy of a superset template.
  ///
  /// Parameters:
  /// - [template] - The original template being copied
  /// - [customTemplateName] - Name of the custom copy
  Future<void> trackCustomTemplateSaved({
    required SupersetTemplate template,
    required String customTemplateName,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.supersetTemplateSaved,
        parameters: {
          AnalyticsParameters.templateId: template.id,
          AnalyticsParameters.templateName: customTemplateName,
          AnalyticsParameters.originalTemplateName: template.name,
          AnalyticsParameters.templateDifficulty: template.difficulty.name,
          AnalyticsParameters.hasScientificBasis:
              template.scientificBasis.isNotEmpty,
          AnalyticsParameters.exerciseCount: template.exerciseNames.length,
          AnalyticsParameters.isPredefinedTemplate: !template.isCustom,
        },
      );

      if (kDebugMode) {
        debugPrint(
          '📊 Superset template custom copy saved: $customTemplateName (from ${template.name})',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking superset template saved: $e');
      }
    }
  }

  /// Track superset tab opened
  ///
  /// Logs when user navigates to the Superset tab in workout templates screen.
  ///
  /// Parameters:
  /// - [source] - How tab was accessed (tap, swipe, deep_link)
  Future<void> trackSupersetTabOpened({
    String source = 'tap',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.supersetTabOpened,
        parameters: {
          AnalyticsParameters.source: source,
          AnalyticsParameters.screenName: 'WorkoutTemplatesScreen',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Superset tab opened (source: $source)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking superset tab opened: $e');
      }
    }
  }

  /// Track superset template deleted
  ///
  /// Logs when user deletes a custom superset template.
  ///
  /// Parameters:
  /// - [templateId] - ID of deleted template
  /// - [templateName] - Name of deleted template
  Future<void> trackTemplateDeleted({
    required String templateId,
    required String templateName,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.templateDeleted,
        parameters: {
          AnalyticsParameters.templateId: templateId,
          AnalyticsParameters.templateName: templateName,
          AnalyticsParameters.templateType: 'superset',
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Superset template deleted: $templateName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking superset template deleted: $e');
      }
    }
  }
}
