import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/utils/contrast_checker.dart';

class AppTheme {
  // Gym-inspired color palette
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryOrange = Color(0xFFFF7043);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningAmber = Color(0xFFFFB300);
  static const Color errorRed = Color(0xFFE53935);
  
  static ThemeData get lightTheme {
    // Create color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: const Color(0xFF1565C0), // Darker blue for WCAG
      secondary: const Color(0xFFE65100), // Darker orange for WCAG
      tertiary: successGreen,
      error: const Color(0xFFC62828), // Darker red for WCAG
    );

    // Verify WCAG 2.2 Level AA compliance (Issue #2 - P1)
    if (kDebugMode) {
      final report = ContrastChecker.verifyColorScheme(colorScheme);
      ContrastChecker.logComplianceReport(report);
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
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
        elevation: 2,
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
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: primaryBlue,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Create color scheme
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
      primary: const Color(0xFF90CAF9), // Lighter blue for dark theme
      secondary: const Color(0xFFFFAB91), // Lighter orange for dark theme
      tertiary: successGreen,
      error: const Color(0xFFEF9A9A), // Lighter red for dark theme
    );

    // Verify WCAG 2.2 Level AA compliance (Issue #2 - P1)
    if (kDebugMode) {
      final report = ContrastChecker.verifyColorScheme(colorScheme);
      ContrastChecker.logComplianceReport(report);
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
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
        elevation: 4,
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
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: primaryBlue,
      ),
    );
  }
  
  // Custom colors for specific use cases
  static const Color timerActiveColor = successGreen;
  static const Color timerInactiveColor = Colors.grey;
  static const Color workoutInProgressColor = secondaryOrange;
  static const Color completedWorkoutColor = successGreen;
}