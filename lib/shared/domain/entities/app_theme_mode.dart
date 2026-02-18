import 'package:flutter/material.dart';

/// Custom theme modes for the app, extending Flutter's ThemeMode
/// with Ultra Dark (AMOLED) and Pink themes.
enum AppThemeMode {
  system,
  light,
  dark,
  ultraDark,
  pink,
  darkPink;

  /// Convert to Flutter's ThemeMode for MaterialApp
  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
      case AppThemeMode.pink:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.ultraDark:
      case AppThemeMode.darkPink:
        return ThemeMode.dark;
    }
  }

  /// Whether this mode uses dark brightness
  bool get isDark => this == dark || this == ultraDark || this == darkPink;

  /// Whether this is a custom theme (not standard light/dark/system)
  bool get isCustomTheme => this == ultraDark || this == pink || this == darkPink;

  /// Parse from stored string value, with backward compatibility
  static AppThemeMode fromString(String? value) {
    if (value == null) return AppThemeMode.system;
    return AppThemeMode.values.firstWhere(
      (v) => v.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  /// Backward compatibility: convert from Flutter ThemeMode
  static AppThemeMode fromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}
