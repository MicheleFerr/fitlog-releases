import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Accessible icon widget with mandatory semantic label
///
/// This widget wraps Flutter's Icon with proper accessibility support.
/// The [semanticLabel] is REQUIRED to ensure screen readers can announce
/// the icon's purpose to visually impaired users.
///
/// **Usage:**
/// ```dart
/// // ✅ CORRECT - With semantic label
/// SemanticIcon(
///   icon: AppIcons.workout,
///   semanticLabel: context.l10n.workoutLabel,
///   size: AppIconSize.medium,
///   color: context.iconPrimary,
/// )
///
/// // ❌ WRONG - Regular Icon without semantics
/// Icon(AppIcons.workout)  // Pre-commit hook will warn/block this
/// ```
///
/// **Why SemanticIcon?**
/// - Ensures all icons have screen reader labels (WCAG 2.1 AA compliance)
/// - Centralizes icon accessibility logic
/// - Encourages localized labels via context.l10n
/// - Provides consistent icon behavior across app
///
/// See also:
/// - [AppIconSize] for semantic sizing constants
/// - [IconColorContext] for semantic color helpers
class SemanticIcon extends StatelessWidget {

  const SemanticIcon({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.size = AppIconSize.medium,
    this.color,
    this.semanticHint,
    this.isButton = false,
    this.isEnabled = true,
    this.textDirection,
    this.opacity,
  });

  /// Factory constructor for button icons (isButton = true)
  ///
  /// Use this when the icon is part of an IconButton or other tappable widget.
  factory SemanticIcon.button({
    Key? key,
    required IconData icon,
    required String semanticLabel,
    double size = AppIconSize.medium,
    Color? color,
    String? semanticHint,
    bool isEnabled = true,
  }) {
    return SemanticIcon(
      key: key,
      icon: icon,
      semanticLabel: semanticLabel,
      size: size,
      color: color,
      semanticHint: semanticHint,
      isButton: true,
      isEnabled: isEnabled,
    );
  }

  /// Factory constructor for state-based icons
  ///
  /// Automatically adjusts semanticLabel and color based on state.
  ///
  /// Example:
  /// ```dart
  /// SemanticIcon.state(
  ///   icon: AppIcons.workout,
  ///   labelActive: context.l10n.pauseWorkout,
  ///   labelInactive: context.l10n.startWorkout,
  ///   isActive: workoutState.isRunning,
  /// )
  /// ```
  factory SemanticIcon.state({
    Key? key,
    required IconData icon,
    required String labelActive,
    required String labelInactive,
    required bool isActive,
    double size = AppIconSize.medium,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return SemanticIcon(
      key: key,
      icon: icon,
      semanticLabel: isActive ? labelActive : labelInactive,
      size: size,
      color: isActive ? activeColor : inactiveColor,
      isEnabled: true,
    );
  }
  /// The icon to display
  final IconData icon;

  /// Semantic label for screen readers (REQUIRED)
  ///
  /// This text is announced by screen readers like TalkBack (Android)
  /// and VoiceOver (iOS) when the icon is focused.
  ///
  /// **Best practices:**
  /// - Use localized strings: `context.l10n.workoutLabel`
  /// - Be descriptive: "Start workout" not just "Workout"
  /// - Include state if relevant: "Pause workout" vs "Resume workout"
  final String semanticLabel;

  /// Icon size in logical pixels
  ///
  /// Prefer using [AppIconSize] constants for consistency:
  /// - [AppIconSize.small] (20dp)
  /// - [AppIconSize.medium] (24dp) - default
  /// - [AppIconSize.large] (28dp)
  final double size;

  /// Icon color
  ///
  /// Prefer using semantic color helpers:
  /// - [context.iconPrimary] for main actions
  /// - [context.iconSuccess] for positive states
  /// - [context.iconError] for errors
  ///
  /// If null, uses theme's default icon color.
  final Color? color;

  /// Optional semantic hint (additional context for screen readers)
  ///
  /// Use this for extra information beyond the label.
  /// Example: "Double tap to start workout"
  final String? semanticHint;

  /// Whether this icon represents a button/interactive element
  ///
  /// Set to true if the icon is tappable (has onTap handler).
  /// This helps screen readers announce it as a button.
  final bool isButton;

  /// Whether the icon is currently enabled/interactive
  ///
  /// When false, screen readers will announce "disabled" state.
  final bool isEnabled;

  /// Text direction for the icon
  ///
  /// Rarely needed - only for icons that should flip in RTL languages.
  final TextDirection? textDirection;

  /// Optional opacity for the icon
  ///
  /// If specified, wraps icon in Opacity widget.
  /// Prefer using semantic colors with opacity instead.
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: size,
      color: color ?? context.colors.onSurface,
      textDirection: textDirection,
      semanticLabel: null, // We handle semantics with Semantics widget below
    );

    // Apply opacity if specified
    if (opacity != null) {
      iconWidget = Opacity(
        opacity: opacity!,
        child: iconWidget,
      );
    }

    // Wrap with Semantics for accessibility
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: isButton,
      enabled: isEnabled,
      // Exclude if empty label (edge case, but possible)
      excludeSemantics: semanticLabel.isEmpty,
      child: iconWidget,
    );
  }
}

/// Extension to easily create SemanticIcon from IconData
///
/// Provides syntactic sugar for creating SemanticIcon instances.
///
/// Usage:
/// ```dart
/// AppIcons.workout.semantic(
///   label: context.l10n.workoutLabel,
///   size: AppIconSize.large,
/// )
/// ```
extension IconDataSemantics on IconData {
  /// Create a SemanticIcon from this IconData
  SemanticIcon semantic({
    Key? key,
    required String label,
    double size = AppIconSize.medium,
    Color? color,
    String? hint,
    bool isButton = false,
    bool isEnabled = true,
  }) {
    return SemanticIcon(
      key: key,
      icon: this,
      semanticLabel: label,
      size: size,
      color: color,
      semanticHint: hint,
      isButton: isButton,
      isEnabled: isEnabled,
    );
  }
}
