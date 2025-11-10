/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain
/// 🎯 Feature: workout
/// 🔧 Type: entity (enum)
/// 🌍 Localization: ✅ AppLocalizations used
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Experience level for workout personalization
///
/// Used in context gathering to suggest appropriate:
/// - Exercise count (2-5 exercises)
/// - Weight suggestions (conservative vs aggressive)
/// - Rep ranges (8-12 for beginners, 6-10 for advanced)
/// - Form tips (detailed for beginners, brief for advanced)
enum ExperienceLevel {
  /// Beginner level (< 6 months training)
  /// - 2-3 exercises per workout
  /// - Conservative weight suggestions
  /// - Detailed form tips
  /// - Icon: 🌱
  beginner,

  /// Intermediate level (6-24 months training)
  /// - 3-4 exercises per workout
  /// - Moderate weight suggestions
  /// - Brief form tips
  /// - Icon: 💪
  intermediate,

  /// Advanced level (2+ years training)
  /// - 4-5 exercises per workout
  /// - Aggressive weight suggestions
  /// - Minimal form tips (assumed knowledge)
  /// - Icon: 🏆
  advanced;

  /// Parse experience level from string (case-insensitive, null-safe)
  ///
  /// Returns null if string is invalid or null.
  /// Example: "INTERMEDIATE" → ExperienceLevel.intermediate
  static ExperienceLevel? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    final normalized = value.toLowerCase().trim();

    switch (normalized) {
      case 'beginner':
      case 'principiante':
        return ExperienceLevel.beginner;

      case 'intermediate':
      case 'intermedio':
        return ExperienceLevel.intermediate;

      case 'advanced':
      case 'avanzato':
        return ExperienceLevel.advanced;

      default:
        return null;
    }
  }

  /// Get localized display name
  String localizedName(BuildContext context) {
    switch (this) {
      case ExperienceLevel.beginner:
        return context.l10n.experienceBeginner;
      case ExperienceLevel.intermediate:
        return context.l10n.experienceIntermediate;
      case ExperienceLevel.advanced:
        return context.l10n.experienceAdvanced;
    }
  }

  /// Get localized description (short explanation)
  String localizedDescription(BuildContext context) {
    switch (this) {
      case ExperienceLevel.beginner:
        return context.l10n.experienceBeginnerDesc;
      case ExperienceLevel.intermediate:
        return context.l10n.experienceIntermediateDesc;
      case ExperienceLevel.advanced:
        return context.l10n.experienceAdvancedDesc;
    }
  }

  /// Get emoji icon for this experience level
  String get emoji {
    switch (this) {
      case ExperienceLevel.beginner:
        return '🌱';
      case ExperienceLevel.intermediate:
        return '💪';
      case ExperienceLevel.advanced:
        return '🏆';
    }
  }

  /// Get suggested exercise count based on experience level
  int get suggestedExerciseCount {
    switch (this) {
      case ExperienceLevel.beginner:
        return 3;
      case ExperienceLevel.intermediate:
        return 4;
      case ExperienceLevel.advanced:
        return 5;
    }
  }

  /// Get semantic badge color for this experience level
  ///
  /// Colors are theme-aware:
  /// - Beginner: Green (approachable, safe)
  /// - Intermediate: Orange (moderate)
  /// - Advanced: Purple (mastery)
  Color badgeColor(bool isDark) {
    switch (this) {
      case ExperienceLevel.beginner:
        // Green: approachable, safe, entry-level
        return isDark
            ? const Color(0xFF66BB6A) // Material Green 400
            : const Color(0xFF4CAF50); // Material Green 500

      case ExperienceLevel.intermediate:
        // Orange: moderate challenge, progression
        return isDark
            ? const Color(0xFFFFB74D) // Material Orange 300
            : const Color(0xFFFF9800); // Material Orange 500

      case ExperienceLevel.advanced:
        // Purple: elite, comprehensive, mastery
        return isDark
            ? const Color(0xFF9575CD) // Material Deep Purple 300
            : const Color(0xFF7E57C2); // Material Deep Purple 500
    }
  }

  /// Get badge color with opacity (for backgrounds)
  Color badgeColorWithOpacity(bool isDark, {double opacity = 0.15}) {
    return badgeColor(isDark).withValues(alpha: opacity);
  }
}
