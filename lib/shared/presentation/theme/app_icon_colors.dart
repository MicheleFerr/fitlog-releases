import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Semantic icon color system
///
/// Provides intent-based color getters for consistent icon coloring across the app.
/// All colors are theme-aware (support dark/light mode).
///
/// Usage:
/// ```dart
/// Icon(
///   AppIcons.workout,
///   color: context.iconPrimary,
/// )
/// ```
extension IconColorContext on BuildContext {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎨 PRIMARY COLORS (Brand & Actions)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Primary brand color
  /// Use for: Main actions, highlighted features, brand elements
  Color get iconPrimary => colors.primary;

  /// Secondary accent color
  /// Use for: Secondary actions, complementary features
  Color get iconSecondary => colors.secondary;

  /// Tertiary color
  /// Use for: Info icons, additional accents
  Color get iconTertiary => colors.tertiary;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎯 SEMANTIC COLORS (Intent-Based)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Success/positive state
  /// Use for: Completed actions, positive feedback, success messages
  Color get iconSuccess => colors.success;

  /// Error/danger state
  /// Use for: Errors, destructive actions, warnings that need attention
  Color get iconError => colors.error;

  /// Warning/caution state
  /// Use for: Warnings, caution messages, review needed
  Color get iconWarning => colors.warning;

  /// Info/neutral state
  /// Use for: Information, help, neutral notifications
  Color get iconInfo => colors.tertiary;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔘 SURFACE & TEXT COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Default icon color (high emphasis)
  /// Use for: Primary content, important icons, default state
  Color get iconDefault => colors.onSurface;

  /// Medium emphasis icon color (60% opacity)
  /// Use for: Secondary content, less important icons
  Color get iconMediumEmphasis => colors.onSurface.withValues(alpha: 0.6);

  /// Low emphasis icon color (40% opacity)
  /// Use for: Hints, placeholders, subtle indicators
  Color get iconLowEmphasis => colors.onSurface.withValues(alpha: 0.4);

  /// Disabled icon color
  /// Use for: Disabled actions, inactive elements
  Color get iconDisabled => colors.outline;

  /// Inverse icon color (for dark backgrounds)
  /// Use for: Icons on colored backgrounds, FAB icons, primary button icons
  Color get iconOnPrimary => colors.onPrimary;

  /// Icon color on secondary backgrounds
  Color get iconOnSecondary => colors.onSecondary;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🏋️ WORKOUT-SPECIFIC COLORS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Active workout/timer color (energetic orange)
  Color get iconWorkoutActive => colors.secondary;

  /// Rest timer color (calming blue)
  Color get iconRestTimer => colors.tertiary;

  /// Personal record color (gold)
  Color get iconPersonalRecord => const Color(0xFFFFD700);

  /// Progress/analytics color
  Color get iconProgress => colors.primary;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎭 CONTEXTUAL HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get icon color based on boolean state
  ///
  /// Returns success color if active, disabled color if inactive.
  /// Useful for toggles, checkboxes, active/inactive states.
  Color iconStateActive(bool isActive) {
    return isActive ? iconSuccess : iconDisabled;
  }

  /// Get icon color based on percentage (gradient from error to success)
  ///
  /// 0-30%: error (red)
  /// 30-70%: warning (orange)
  /// 70-100%: success (green)
  Color iconProgressColor(double percentage) {
    if (percentage < 30) {
      return iconError;
    } else if (percentage < 70) {
      return iconWarning;
    } else {
      return iconSuccess;
    }
  }

  /// Get icon color for priority level
  ///
  /// high: error (urgent)
  /// medium: warning (attention needed)
  /// low: medium emphasis (normal)
  Color iconPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return iconError;
      case 'medium':
        return iconWarning;
      case 'low':
      default:
        return iconMediumEmphasis;
    }
  }

  /// Get icon color with custom opacity
  ///
  /// Useful for creating emphasis variations on the fly.
  Color iconWithOpacity(Color baseColor, double opacity) {
    return baseColor.withValues(alpha: opacity);
  }
}

/// Static color constants (for use outside BuildContext)
///
/// Use these when you don't have access to BuildContext.
/// Note: These are NOT theme-aware - prefer context extensions when possible.
class AppIconColors {
  AppIconColors._();

  // Semantic colors (Material Design 3 defaults)
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFE53935); // Red
  static const Color warning = Color(0xFFFFB300); // Amber
  static const Color info = Color(0xFF2196F3); // Blue

  // Grayscale
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF9E9E9E);

  // Workout-specific
  static const Color workoutActive = Color(0xFFFF6F00); // Deep orange
  static const Color restTimer = Color(0xFF1976D2); // Blue
  static const Color personalRecord = Color(0xFFFFD700); // Gold
}
