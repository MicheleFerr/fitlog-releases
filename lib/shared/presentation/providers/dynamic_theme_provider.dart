import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider that creates ThemeData dynamically based on user's color and font preferences
/// Rebuilds whenever AppConfig changes (primaryColor or fontSize)
final dynamicThemeProvider = Provider.family<ThemeData, Brightness>((ref, brightness) {
  final config = ref.watch(appConfigProvider);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _parseColor(config.primaryColor),
      brightness: brightness,
    ),
    textTheme: _getScaledTextTheme(brightness, config.fontSize),
  );
});

/// Parse hex color string to Color
/// Accepts both "#RRGGBB" and "RRGGBB" formats
Color _parseColor(String hexColor) {
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
