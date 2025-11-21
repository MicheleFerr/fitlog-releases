/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/entities
/// 🎯 Feature: flexible_routine
/// 🔧 Type: enum
/// 🌍 Localization: N/A (backend enum)
/// 📱 Platform: Universal
///
/// ROUTINE PRESET ENUM - v2.0
///
/// Defines 5 preset routine types with default training day patterns.
/// Used for template matching and workout scheduling.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

/// Preset routine types with predefined training patterns
enum RoutinePreset {
  /// Push/Pull/Legs - 6 day split (Mon-Sat)
  /// Pattern: Push, Pull, Legs, Push, Pull, Legs
  @JsonValue('ppl_6_day')
  ppl6Day,

  /// Upper/Lower - 4 day split (Mon/Tue/Thu/Fri)
  /// Pattern: Upper, Lower, Upper, Lower
  @JsonValue('upper_lower_4_day')
  upperLower4Day,

  /// Full Body - 3 day split (Mon/Wed/Fri)
  /// Pattern: Full Body, Full Body, Full Body
  @JsonValue('full_body_3_day')
  fullBody3Day,

  /// Bro Split - 5 day split (Mon-Fri)
  /// Pattern: Chest, Back, Legs, Shoulders, Arms
  @JsonValue('bro_split_5_day')
  broSplit5Day,

  /// Custom - user-defined pattern
  /// No default training days (user selects manually)
  @JsonValue('custom')
  custom,
}

/// Difficulty level for routine presets
enum PresetDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// Extension methods for RoutinePreset
extension RoutinePresetExtension on RoutinePreset {
  /// Returns default training days for each preset
  /// Monday = 1, Sunday = 7
  Set<int> get defaultTrainingDays {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return {1, 2, 3, 4, 5, 6}; // Mon-Sat
      case RoutinePreset.upperLower4Day:
        return {1, 2, 4, 5}; // Mon/Tue/Thu/Fri
      case RoutinePreset.fullBody3Day:
        return {1, 3, 5}; // Mon/Wed/Fri
      case RoutinePreset.broSplit5Day:
        return {1, 2, 3, 4, 5}; // Mon-Fri
      case RoutinePreset.custom:
        return {}; // No defaults, user-defined
    }
  }

  /// Returns expected muscle groups for a given day in the preset
  /// Used for template scoring algorithm
  Set<String> expectedMuscleGroupsForDay(int dayOfWeek) {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return _pplMuscleGroups(dayOfWeek);
      case RoutinePreset.upperLower4Day:
        return _upperLowerMuscleGroups(dayOfWeek);
      case RoutinePreset.fullBody3Day:
        return _fullBodyMuscleGroups();
      case RoutinePreset.broSplit5Day:
        return _broSplitMuscleGroups(dayOfWeek);
      case RoutinePreset.custom:
        return {}; // Custom presets have no expected pattern
    }
  }

  /// Push/Pull/Legs muscle group rotation
  Set<String> _pplMuscleGroups(int dayOfWeek) {
    final dayIndex = (dayOfWeek - 1) % 3; // 0=Push, 1=Pull, 2=Legs
    switch (dayIndex) {
      case 0:
        return {'chest', 'shoulders', 'triceps'}; // Push
      case 1:
        return {'back', 'biceps'}; // Pull
      case 2:
        return {'quads', 'hamstrings', 'glutes', 'calves'}; // Legs
      default:
        return {};
    }
  }

  /// Upper/Lower muscle group pattern
  Set<String> _upperLowerMuscleGroups(int dayOfWeek) {
    final trainingDays = [1, 2, 4, 5]; // Mon/Tue/Thu/Fri
    final dayPosition = trainingDays.indexOf(dayOfWeek);
    if (dayPosition == -1) return {};

    final isUpper = dayPosition % 2 == 0; // 0=Upper, 1=Lower, 2=Upper, 3=Lower
    if (isUpper) {
      return {'chest', 'back', 'shoulders', 'biceps', 'triceps'}; // Upper
    } else {
      return {'quads', 'hamstrings', 'glutes', 'calves'}; // Lower
    }
  }

  /// Full body targets all muscle groups every session
  Set<String> _fullBodyMuscleGroups() {
    return {
      'chest',
      'back',
      'shoulders',
      'biceps',
      'triceps',
      'quads',
      'hamstrings',
      'glutes',
      'calves',
    };
  }

  /// Bro split muscle group isolation
  Set<String> _broSplitMuscleGroups(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return {'chest'}; // Monday: Chest
      case 2:
        return {'back'}; // Tuesday: Back
      case 3:
        return {'quads', 'hamstrings', 'glutes', 'calves'}; // Wednesday: Legs
      case 4:
        return {'shoulders'}; // Thursday: Shoulders
      case 5:
        return {'biceps', 'triceps'}; // Friday: Arms
      default:
        return {};
    }
  }

  /// Human-readable preset name (for debugging/logging)
  /// UI should use localized strings via context.l10n
  String get displayName {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return 'Push/Pull/Legs (6 days)';
      case RoutinePreset.upperLower4Day:
        return 'Upper/Lower (4 days)';
      case RoutinePreset.fullBody3Day:
        return 'Full Body (3 days)';
      case RoutinePreset.broSplit5Day:
        return 'Bro Split (5 days)';
      case RoutinePreset.custom:
        return 'Custom';
    }
  }

  /// Training frequency (days per week)
  int get frequencyDays {
    return defaultTrainingDays.length;
  }

  // ────────────────────────────────────────────────────────────────────────
  // METADATA (FASE 1: UI Enhancement)
  // ────────────────────────────────────────────────────────────────────────

  /// Difficulty level for the preset
  PresetDifficulty get difficulty {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return PresetDifficulty.intermediate; // Requires understanding of push/pull/legs
      case RoutinePreset.upperLower4Day:
        return PresetDifficulty.beginner; // Simple split, good for beginners
      case RoutinePreset.fullBody3Day:
        return PresetDifficulty.beginner; // Easiest to follow, 3 days/week
      case RoutinePreset.broSplit5Day:
        return PresetDifficulty.advanced; // Requires dedication, 5 days/week
      case RoutinePreset.custom:
        return PresetDifficulty.beginner; // User-defined, assume beginner-friendly
    }
  }

  /// Estimated session duration range in minutes
  /// Returns a user-friendly string like "60-90 min"
  String get estimatedDuration {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return '60-90'; // Longer sessions (3 muscle groups)
      case RoutinePreset.upperLower4Day:
        return '60-75'; // Moderate sessions (upper/lower split)
      case RoutinePreset.fullBody3Day:
        return '45-60'; // Shorter sessions (full body, lighter)
      case RoutinePreset.broSplit5Day:
        return '45-60'; // Focused sessions (single muscle group)
      case RoutinePreset.custom:
        return '30-90'; // Variable (user-defined)
    }
  }

  /// Localization key for preset description
  /// UI should use: context.l10n.{this.descriptionKey}
  String get descriptionKey {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return 'presetPpl6DayDescription';
      case RoutinePreset.upperLower4Day:
        return 'presetUpperLower4DayDescription';
      case RoutinePreset.fullBody3Day:
        return 'presetFullBody3DayDescription';
      case RoutinePreset.broSplit5Day:
        return 'presetBroSplit5DayDescription';
      case RoutinePreset.custom:
        return 'presetCustomDescription';
    }
  }

  /// Asset path for preset image
  /// Images should be added to assets/images/presets/
  String get imageAssetPath {
    switch (this) {
      case RoutinePreset.ppl6Day:
        return 'assets/images/presets/ppl_6_day.png';
      case RoutinePreset.upperLower4Day:
        return 'assets/images/presets/upper_lower_4_day.png';
      case RoutinePreset.fullBody3Day:
        return 'assets/images/presets/full_body_3_day.png';
      case RoutinePreset.broSplit5Day:
        return 'assets/images/presets/bro_split_5_day.png';
      case RoutinePreset.custom:
        return 'assets/images/presets/custom.png';
    }
  }

  /// Difficulty level display name (for debugging/logging)
  /// UI should use localized strings via context.l10n
  String get difficultyDisplayName {
    switch (difficulty) {
      case PresetDifficulty.beginner:
        return 'Beginner';
      case PresetDifficulty.intermediate:
        return 'Intermediate';
      case PresetDifficulty.advanced:
        return 'Advanced';
    }
  }
}
