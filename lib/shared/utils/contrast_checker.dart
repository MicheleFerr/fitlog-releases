import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Contrast Ratio Checker for WCAG 2.2 Compliance
///
/// WCAG 2.2 Level AA Requirements:
/// - Normal text (< 18pt): minimum 4.5:1 contrast ratio
/// - Large text (≥ 18pt or bold ≥ 14pt): minimum 3:1 contrast ratio
/// - UI components and states: minimum 3:1 contrast ratio
///
/// WCAG 2.2 Level AAA Requirements:
/// - Normal text: minimum 7:1 contrast ratio
/// - Large text: minimum 4.5:1 contrast ratio
///
/// References:
/// - WCAG 2.2 Success Criterion 1.4.3 (Contrast - Minimum - Level AA)
/// - WCAG 2.2 Success Criterion 1.4.6 (Contrast - Enhanced - Level AAA)
class ContrastChecker {
  /// WCAG AA minimum contrast ratio for normal text
  static const double minContrastNormalAA = 4.5;

  /// WCAG AA minimum contrast ratio for large text
  static const double minContrastLargeAA = 3.0;

  /// WCAG AAA minimum contrast ratio for normal text
  static const double minContrastNormalAAA = 7.0;

  /// WCAG AAA minimum contrast ratio for large text
  static const double minContrastLargeAAA = 4.5;

  /// Calculate relative luminance of a color
  ///
  /// Formula from WCAG 2.2:
  /// For sRGB colorspace (Flutter default):
  /// L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  /// where R, G, B are linearized (gamma corrected)
  static double _relativeLuminance(Color color) {
    // Extract RGB components (0-255)
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    // Linearize (gamma correction)
    final rLinear = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4);

    // Calculate relative luminance
    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  /// Calculate contrast ratio between two colors
  ///
  /// Formula from WCAG 2.2:
  /// (L1 + 0.05) / (L2 + 0.05)
  /// where L1 is the lighter luminance and L2 is the darker luminance
  ///
  /// Returns a value between 1:1 (no contrast) and 21:1 (max contrast)
  static double contrastRatio(Color foreground, Color background) {
    final luminance1 = _relativeLuminance(foreground);
    final luminance2 = _relativeLuminance(background);

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast ratio meets WCAG AA for normal text
  static bool meetsWCAG_AA_Normal(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastNormalAA;
  }

  /// Check if contrast ratio meets WCAG AA for large text
  static bool meetsWCAG_AA_Large(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastLargeAA;
  }

  /// Check if contrast ratio meets WCAG AAA for normal text
  static bool meetsWCAG_AAA_Normal(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastNormalAAA;
  }

  /// Check if contrast ratio meets WCAG AAA for large text
  static bool meetsWCAG_AAA_Large(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= minContrastLargeAAA;
  }

  /// Verify entire ColorScheme for WCAG AA compliance
  ///
  /// Checks common color combinations:
  /// - Text on backgrounds
  /// - Icons on surfaces
  /// - Buttons and interactive elements
  ///
  /// Returns a report of violations
  static ColorSchemeComplianceReport verifyColorScheme(ColorScheme scheme) {
    final violations = <ContrastViolation>[];

    // Check primary text on surface
    _checkContrast(
      violations: violations,
      foreground: scheme.onSurface,
      background: scheme.surface,
      context: 'onSurface on surface',
      isLargeText: false,
    );

    // Check primary text on background
    _checkContrast(
      violations: violations,
      foreground: scheme.onSurface,
      background: scheme.surface,
      context: 'onBackground on background',
      isLargeText: false,
    );

    // Check primary button text
    _checkContrast(
      violations: violations,
      foreground: scheme.onPrimary,
      background: scheme.primary,
      context: 'onPrimary on primary (button)',
      isLargeText: false,
    );

    // Check secondary button text
    _checkContrast(
      violations: violations,
      foreground: scheme.onSecondary,
      background: scheme.secondary,
      context: 'onSecondary on secondary (button)',
      isLargeText: false,
    );

    // Check error text
    _checkContrast(
      violations: violations,
      foreground: scheme.onError,
      background: scheme.error,
      context: 'onError on error',
      isLargeText: false,
    );

    // Check outline contrast
    _checkContrast(
      violations: violations,
      foreground: scheme.outline,
      background: scheme.surface,
      context: 'outline on surface',
      isLargeText: false,
      minRatio: minContrastLargeAA, // UI components need 3:1
    );

    return ColorSchemeComplianceReport(
      violations: violations,
      totalChecks: 6,
      passedChecks: 6 - violations.length,
    );
  }

  /// Helper to check contrast and add violation if needed
  static void _checkContrast({
    required List<ContrastViolation> violations,
    required Color foreground,
    required Color background,
    required String context,
    required bool isLargeText,
    double? minRatio,
  }) {
    final ratio = contrastRatio(foreground, background);
    final required = minRatio ?? (isLargeText ? minContrastLargeAA : minContrastNormalAA);

    if (ratio < required) {
      violations.add(ContrastViolation(
        foreground: foreground,
        background: background,
        actualRatio: ratio,
        requiredRatio: required,
        context: context,
      ));
    }
  }

  /// Suggest a darker version of a color to meet contrast ratio
  static Color suggestDarker(Color color, Color background, double targetRatio) {
    // Simple approach: darken by reducing lightness
    final hsl = HSLColor.fromColor(color);
    var lightness = hsl.lightness;

    while (lightness > 0 && contrastRatio(hsl.withLightness(lightness).toColor(), background) < targetRatio) {
      lightness -= 0.05;
    }

    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  /// Suggest a lighter version of a color to meet contrast ratio
  static Color suggestLighter(Color color, Color background, double targetRatio) {
    final hsl = HSLColor.fromColor(color);
    var lightness = hsl.lightness;

    while (lightness < 1.0 && contrastRatio(hsl.withLightness(lightness).toColor(), background) < targetRatio) {
      lightness += 0.05;
    }

    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  /// Log ColorScheme compliance report
  static void logComplianceReport(ColorSchemeComplianceReport report, {bool onlyViolations = false}) {
    if (!kDebugMode) return;

    if (report.isCompliant) {
      if (!onlyViolations) {
        debugPrint('✅ ColorScheme is WCAG 2.2 Level AA compliant!');
        debugPrint('   ${report.passedChecks}/${report.totalChecks} checks passed');
      }
    } else {
      debugPrint('❌ ColorScheme has ${report.violations.length} WCAG violations:');
      for (final violation in report.violations) {
        debugPrint('   - $violation');
      }
    }
  }
}

/// Contrast violation details
class ContrastViolation {

  ContrastViolation({
    required this.foreground,
    required this.background,
    required this.actualRatio,
    required this.requiredRatio,
    required this.context,
  });
  final Color foreground;
  final Color background;
  final double actualRatio;
  final double requiredRatio;
  final String context;

  @override
  String toString() {
    return '$context: ${actualRatio.toStringAsFixed(2)}:1 (required ${requiredRatio.toStringAsFixed(1)}:1)';
  }
}

/// ColorScheme compliance report
class ColorSchemeComplianceReport {

  ColorSchemeComplianceReport({
    required this.violations,
    required this.totalChecks,
    required this.passedChecks,
  });
  final List<ContrastViolation> violations;
  final int totalChecks;
  final int passedChecks;

  bool get isCompliant => violations.isEmpty;

  double get compliancePercentage => (passedChecks / totalChecks) * 100;
}
