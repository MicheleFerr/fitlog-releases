import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Difficulty level for workout templates
///
/// Each level has a semantic color for visual distinction.
/// Colors are theme-aware for proper contrast in light/dark modes.
enum DifficultyLevel {
  /// Beginner level (1-2 exercises, low volume)
  /// Badge: Green (approachable, safe)
  beginner,

  /// Intermediate level (3-5 exercises, medium volume)
  /// Badge: Orange (moderate challenge)
  intermediate,

  /// Advanced level (6-8 exercises, high volume)
  /// Badge: Red (intense, demanding)
  advanced,

  /// Expert level (9+ exercises, very high volume)
  /// Badge: Purple (elite, comprehensive)
  expert;

  /// Parse difficulty from string (case-insensitive, null-safe)
  ///
  /// Returns null if string is invalid or null.
  /// Example: "INTERMEDIATE" → DifficultyLevel.intermediate
  static DifficultyLevel? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    final normalized = value.toLowerCase().trim();

    switch (normalized) {
      case 'beginner':
      case 'principiante':
        return DifficultyLevel.beginner;

      case 'intermediate':
      case 'intermedio':
        return DifficultyLevel.intermediate;

      case 'advanced':
      case 'avanzato':
        return DifficultyLevel.advanced;

      case 'expert':
      case 'esperto':
        return DifficultyLevel.expert;

      default:
        return null;
    }
  }

  /// Get localized display name
  String localizedName(BuildContext context) {
    switch (this) {
      case DifficultyLevel.beginner:
        return context.l10n.difficultyBeginner;
      case DifficultyLevel.intermediate:
        return context.l10n.difficultyIntermediate;
      case DifficultyLevel.advanced:
        return context.l10n.difficultyAdvanced;
      case DifficultyLevel.expert:
        return context.l10n.difficultyExpert;
    }
  }

  /// Get semantic badge color for this difficulty level
  ///
  /// Colors are theme-aware:
  /// - Light theme: Slightly desaturated for better readability
  /// - Dark theme: More vibrant for contrast
  Color badgeColor(bool isDark) {
    switch (this) {
      case DifficultyLevel.beginner:
        // Green: approachable, safe, entry-level
        return isDark
            ? const Color(0xFF66BB6A) // Material Green 400
            : const Color(0xFF4CAF50); // Material Green 500

      case DifficultyLevel.intermediate:
        // Orange: moderate challenge, progression
        return isDark
            ? const Color(0xFFFFB74D) // Material Orange 300
            : const Color(0xFFFF9800); // Material Orange 500

      case DifficultyLevel.advanced:
        // Red: intense, demanding, high effort
        return isDark
            ? const Color(0xFFEF5350) // Material Red 400
            : const Color(0xFFF44336); // Material Red 500

      case DifficultyLevel.expert:
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
