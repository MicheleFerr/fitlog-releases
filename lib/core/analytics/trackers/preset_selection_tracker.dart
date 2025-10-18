/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/analytics/trackers
/// 🎯 Feature: analytics
/// 🔧 Type: tracker helper
///
/// Preset selection tracking helper
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// Preset selection tracker
///
/// Helper class for tracking preset selections (rep ranges, set counts, rest times).
/// Provides convenient methods with predefined event names and parameters.
///
/// Usage:
/// ```dart
/// final tracker = PresetSelectionTracker(analytics);
///
/// // Track rep preset selection
/// await tracker.trackRepPresetSelected(
///   presetId: 'hypertrophy',
///   reps: 10,
///   source: 'add_exercise_modal',
/// );
///
/// // Track set count preset selection
/// await tracker.trackSetCountPresetSelected(
///   sets: 3,
///   source: 'exercise_customization',
/// );
///
/// // Track rest time preset selection
/// await tracker.trackRestTimePresetSelected(
///   presetId: 'rest_90',
///   seconds: 90,
///   source: 'rest_time_picker',
/// );
/// ```
class PresetSelectionTracker {
  PresetSelectionTracker(this.analytics);

  final IAnalyticsService analytics;

  /// Track rep range preset selection
  ///
  /// Logs when user selects a rep range preset (1-3, 8-12, etc.)
  ///
  /// Parameters:
  /// - [presetId] - Preset identifier (strength, hypertrophy, etc.)
  /// - [reps] - Number of reps selected
  /// - [source] - Where selection occurred (screen/modal name)
  /// - [exerciseId] - Optional exercise ID if applied to specific exercise
  Future<void> trackRepPresetSelected({
    required String presetId,
    required int reps,
    required String source,
    String? exerciseId,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.repPresetSelected,
        parameters: {
          AnalyticsParameters.presetType: 'rep_range',
          AnalyticsParameters.presetId: presetId,
          AnalyticsParameters.presetValue: reps,
          AnalyticsParameters.reps: reps,
          AnalyticsParameters.source: source,
          if (exerciseId != null) AnalyticsParameters.exerciseId: exerciseId,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Rep preset selected: $presetId ($reps reps) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking rep preset selection: $e');
      }
    }
  }

  /// Track set count preset selection
  ///
  /// Logs when user selects a set count preset (1-6 sets)
  ///
  /// Parameters:
  /// - [sets] - Number of sets selected
  /// - [source] - Where selection occurred
  /// - [exerciseId] - Optional exercise ID if applied to specific exercise
  Future<void> trackSetCountPresetSelected({
    required int sets,
    required String source,
    String? exerciseId,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.setCountPresetSelected,
        parameters: {
          AnalyticsParameters.presetType: 'set_count',
          AnalyticsParameters.presetId: 'sets_$sets',
          AnalyticsParameters.presetValue: sets,
          AnalyticsParameters.sets: sets,
          AnalyticsParameters.source: source,
          if (exerciseId != null) AnalyticsParameters.exerciseId: exerciseId,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Set count preset selected: $sets sets from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking set count preset selection: $e');
      }
    }
  }

  /// Track rest time preset selection
  ///
  /// Logs when user selects a rest time preset (30s, 1min, etc.)
  ///
  /// Parameters:
  /// - [presetId] - Preset identifier (rest_30, rest_60, etc.)
  /// - [seconds] - Duration in seconds (null for "no timer")
  /// - [source] - Where selection occurred
  /// - [exerciseId] - Optional exercise ID if applied to specific exercise
  Future<void> trackRestTimePresetSelected({
    required String presetId,
    required int? seconds,
    required String source,
    String? exerciseId,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.restTimePresetSelected,
        parameters: {
          AnalyticsParameters.presetType: 'rest_time',
          AnalyticsParameters.presetId: presetId,
          if (seconds != null) AnalyticsParameters.presetValue: seconds,
          if (seconds != null) AnalyticsParameters.timerDuration: seconds,
          AnalyticsParameters.source: source,
          if (exerciseId != null) AnalyticsParameters.exerciseId: exerciseId,
        },
      );

      if (kDebugMode) {
        final durationText = seconds != null ? '${seconds}s' : 'no timer';
        debugPrint('📊 Rest time preset selected: $presetId ($durationText) from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking rest time preset selection: $e');
      }
    }
  }

  /// Track custom timer set
  ///
  /// Logs when user sets a custom timer duration (not a preset)
  ///
  /// Parameters:
  /// - [seconds] - Custom duration in seconds
  /// - [source] - Where timer was set
  /// - [exerciseId] - Optional exercise ID
  Future<void> trackCustomTimerSet({
    required int seconds,
    required String source,
    String? exerciseId,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.customTimerSet,
        parameters: {
          AnalyticsParameters.timerType: 'custom',
          AnalyticsParameters.timerDuration: seconds,
          AnalyticsParameters.source: source,
          if (exerciseId != null) AnalyticsParameters.exerciseId: exerciseId,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Custom timer set: ${seconds}s from $source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking custom timer: $e');
      }
    }
  }

  /// Track preset usage pattern
  ///
  /// Logs aggregate data about which presets are most popular.
  /// Call this periodically (e.g., after workout completion).
  ///
  /// Parameters:
  /// - [repPresetUsageCount] - Map of preset ID to usage count
  /// - [setPresetUsageCount] - Map of set count to usage count
  /// - [restPresetUsageCount] - Map of preset ID to usage count
  Future<void> trackPresetUsagePattern({
    Map<String, int>? repPresetUsageCount,
    Map<int, int>? setPresetUsageCount,
    Map<String, int>? restPresetUsageCount,
  }) async {
    try {
      // Log rep preset usage
      if (repPresetUsageCount != null && repPresetUsageCount.isNotEmpty) {
        for (final entry in repPresetUsageCount.entries) {
          await analytics.logEvent(
            name: 'preset_usage_pattern',
            parameters: {
              AnalyticsParameters.presetType: 'rep_range',
              AnalyticsParameters.presetId: entry.key,
              'usage_count': entry.value,
            },
          );
        }
      }

      // Log set preset usage
      if (setPresetUsageCount != null && setPresetUsageCount.isNotEmpty) {
        for (final entry in setPresetUsageCount.entries) {
          await analytics.logEvent(
            name: 'preset_usage_pattern',
            parameters: {
              AnalyticsParameters.presetType: 'set_count',
              AnalyticsParameters.presetId: 'sets_${entry.key}',
              'usage_count': entry.value,
            },
          );
        }
      }

      // Log rest preset usage
      if (restPresetUsageCount != null && restPresetUsageCount.isNotEmpty) {
        for (final entry in restPresetUsageCount.entries) {
          await analytics.logEvent(
            name: 'preset_usage_pattern',
            parameters: {
              AnalyticsParameters.presetType: 'rest_time',
              AnalyticsParameters.presetId: entry.key,
              'usage_count': entry.value,
            },
          );
        }
      }

      if (kDebugMode) {
        debugPrint('📊 Preset usage pattern tracked');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking preset usage pattern: $e');
      }
    }
  }
}
