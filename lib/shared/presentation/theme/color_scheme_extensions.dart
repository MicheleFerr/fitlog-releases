import 'package:flutter/material.dart';

/// Extension to add custom colors to ColorScheme
extension ColorSchemeExtensions on ColorScheme {
  Color get warning => brightness == Brightness.light
      ? const Color(0xFFFFB300) // Amber for light theme
      : const Color(0xFFFFD54F); // Lighter amber for dark theme

  Color get warningContainer => brightness == Brightness.light
      ? const Color(0xFFFFE082) // Light amber container
      : const Color(0xFF6A4C00); // Dark amber container

  Color get onWarning => brightness == Brightness.light
      ? const Color(0xFF000000) // Black text on warning
      : const Color(0xFF000000); // Black text on warning

  Color get onWarningContainer => brightness == Brightness.light
      ? const Color(0xFF3E2700) // Dark text on warning container
      : const Color(0xFFFFE082); // Light text on warning container

  Color get success => brightness == Brightness.light
      ? const Color(0xFF43A047) // Green for success
      : const Color(0xFF66BB6A); // Lighter green for dark theme

  Color get successContainer => brightness == Brightness.light
      ? const Color(0xFFC8E6C9) // Light green container
      : const Color(0xFF1B5E20); // Dark green container

  Color get onSuccess => brightness == Brightness.light
      ? const Color(0xFFFFFFFF) // White text on success
      : const Color(0xFF000000); // Black text on success

  Color get onSuccessContainer => brightness == Brightness.light
      ? const Color(0xFF1B5E20) // Dark text on success container
      : const Color(0xFFC8E6C9); // Light text on success container

  /// onSurface with 87% opacity
  Color get onSurface87 => onSurface.withValues(alpha: 0.87);

  /// onSurface with 26% opacity
  Color get onSurface26 => onSurface.withValues(alpha: 0.26);
}