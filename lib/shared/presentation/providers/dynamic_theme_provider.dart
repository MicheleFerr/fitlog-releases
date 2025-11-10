import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider that creates ThemeData dynamically based on user's color and font preferences
/// Rebuilds ONLY when primaryColor or fontSize changes (optimized with select)
final dynamicThemeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  // ⚡ PERFORMANCE: Use select() to avoid rebuilds when other config fields change
  final primaryColor = ref.watch(appConfigProvider.select((c) => c.primaryColor));
  final fontSize = ref.watch(appConfigProvider.select((c) => c.fontSize));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _parseColor(primaryColor),
      brightness: brightness,
    ),
    textTheme: _getScaledTextTheme(brightness, fontSize),
  );
});

/// Parse color string to Color
/// Supports hex codes ("#RRGGBB", "RRGGBB") AND color names ("blue", "red", etc.)
Color _parseColor(String colorString) {
  // Handle named colors (legacy support for existing databases)
  final namedColors = {
    'blue': '2196F3', // Material Blue 500
    'red': 'F44336',   // Material Red 500
    'green': '4CAF50', // Material Green 500
    'purple': '9C27B0', // Material Purple 500
    'orange': 'FF9800', // Material Orange 500
    'teal': '009688',   // Material Teal 500
    'pink': 'E91E63',   // Material Pink 500
    'indigo': '3F51B5', // Material Indigo 500
  };

  // Convert named color to hex if needed
  final hexColor = namedColors[colorString.toLowerCase()] ?? colorString;

  // Parse hex color
  final hex = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

/// Get text theme scaled by fontSize multiplier
TextTheme _getScaledTextTheme(Brightness brightness, double scale) {
  final baseTheme = brightness == Brightness.dark
      ? ThemeData.dark()
      : ThemeData.light();
  final base = baseTheme.textTheme;

  return TextTheme(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: (base.displayLarge?.fontSize ?? 57) * scale,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: (base.displayMedium?.fontSize ?? 45) * scale,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: (base.displaySmall?.fontSize ?? 36) * scale,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: (base.headlineLarge?.fontSize ?? 32) * scale,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: (base.headlineMedium?.fontSize ?? 28) * scale,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: (base.headlineSmall?.fontSize ?? 24) * scale,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: (base.titleLarge?.fontSize ?? 22) * scale,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: (base.titleMedium?.fontSize ?? 16) * scale,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: (base.titleSmall?.fontSize ?? 14) * scale,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: (base.bodyLarge?.fontSize ?? 16) * scale,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: (base.bodyMedium?.fontSize ?? 14) * scale,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: (base.bodySmall?.fontSize ?? 12) * scale,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: (base.labelLarge?.fontSize ?? 14) * scale,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: (base.labelMedium?.fontSize ?? 12) * scale,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: (base.labelSmall?.fontSize ?? 11) * scale,
    ),
  );
}
