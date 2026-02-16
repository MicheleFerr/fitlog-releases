import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/utils/contrast_checker.dart';

class AppTheme {
  // Cache to avoid running WCAG check multiple times for same ColorScheme
  static final Set<int> _checkedColorSchemes = {};

  // Gym-inspired color palette
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryOrange = Color(0xFFFF7043);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningAmber = Color(0xFFFFB300);
  static const Color errorRed = Color(0xFFE53935);

  /// Available theme colors with their display names
  static const Map<String, Color> themeColors = {
    'blue': Color(0xFF2196F3),    // Material Blue 500
    'red': Color(0xFFF44336),     // Material Red 500
    'green': Color(0xFF4CAF50),   // Material Green 500
    'purple': Color(0xFF9C27B0),  // Material Purple 500
    'orange': Color(0xFFFF9800),  // Material Orange 500
    'teal': Color(0xFF009688),    // Material Teal 500
    'pink': Color(0xFFE91E63),    // Material Pink 500
  };

  /// Get Color from color name string
  static Color getColorFromName(String colorName) {
    return themeColors[colorName] ?? themeColors['blue']!;
  }

  /// Build light theme with custom seed color
  static ThemeData buildLightTheme([String? colorName]) {
    final seedColor = colorName != null
        ? getColorFromName(colorName)
        : primaryBlue;

    // Create color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme);
  }

  /// Build dark theme with custom seed color
  static ThemeData buildDarkTheme([String? colorName]) {
    final seedColor = colorName != null
        ? getColorFromName(colorName)
        : primaryBlue;

    // Create color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme, isDark: true);
  }

  /// Legacy static getters for backward compatibility
  static ThemeData get lightTheme => buildLightTheme();
  static ThemeData get darkTheme => buildDarkTheme();

  /// Internal theme builder
  static ThemeData _buildTheme(ColorScheme colorScheme, {bool isDark = false}) {
    // Verify WCAG 2.2 Level AA compliance (Issue #2 - P1)
    // Only check once per unique ColorScheme to avoid log spam
    if (kDebugMode) {
      final schemeHash = Object.hash(
        colorScheme.primary.value,
        colorScheme.brightness,
      );
      if (!_checkedColorSchemes.contains(schemeHash)) {
        _checkedColorSchemes.add(schemeHash);
        final report = ContrastChecker.verifyColorScheme(colorScheme);
        ContrastChecker.logComplianceReport(report);
      }
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        foregroundColor: null, // Will use theme colors
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: isDark ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Floating Action Button Theme (deprecated - using CNButton.icon Liquid Glass instead)
      // floatingActionButtonTheme: const FloatingActionButtonThemeData(
      //   shape: CircleBorder(),
      //   elevation: 4,
      // ),

      // Bottom Sheet Theme - solid bg, no gap
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: colorScheme.primary,
      ),
    );
  }

  // Custom colors for specific use cases
  static const Color timerActiveColor = successGreen;
  static const Color timerInactiveColor = Color(0xFFE7E0EC); // surfaceVariant equivalent
  static const Color workoutInProgressColor = secondaryOrange;
  static const Color completedWorkoutColor = successGreen;
}