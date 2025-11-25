/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/utils
/// 🎯 Feature: shared
/// 🔧 Type: utility
///
/// Accessibility Utilities
///
/// Helpers per verificare conformità WCAG (Web Content Accessibility Guidelines)
/// e garantire che l'app sia accessibile a tutti gli utenti.
///
/// ## WCAG Standards:
///
/// - **WCAG AA**: Minimum contrast ratio 4.5:1 (testo normale)
/// - **WCAG AA Large**: Minimum contrast ratio 3:1 (testo grande ≥ 18pt)
/// - **WCAG AAA**: Enhanced contrast ratio 7:1 (testo normale)
/// - **WCAG AAA Large**: Enhanced contrast ratio 4.5:1 (testo grande)
///
/// ## Utilizzo:
///
/// ```dart
/// // Test contrast ratio
/// final ratio = AccessibilityUtils.getContrastRatio(
///   context.colors.surface,
///   context.colors.onSurface,
/// );
/// print(ratio); // 21.0 (massimo contrasto)
///
/// // Check WCAG conformance
/// final isAccessible = AccessibilityUtils.meetsWCAG_AA(
///   foreground: context.colors.primary,
///   background: context.colors.surface,
/// );
/// ```
///
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Utility class per accessibility checks
class AccessibilityUtils {
  AccessibilityUtils._(); // Private constructor

  // ========================================
  // WCAG Contrast Ratio Thresholds
  // ========================================

  /// WCAG AA minimum contrast for normal text (< 18pt)
  static const double wcagAA = 4.5;

  /// WCAG AA minimum contrast for large text (≥ 18pt or bold ≥ 14pt)
  static const double wcagAALarge = 3.0;

  /// WCAG AAA enhanced contrast for normal text
  static const double wcagAAA = 7.0;

  /// WCAG AAA enhanced contrast for large text
  static const double wcagAAALarge = 4.5;

  // ========================================
  // Contrast Ratio Calculation
  // ========================================

  /// Calcola contrast ratio tra due colori secondo formula WCAG
  ///
  /// Formula: (L1 + 0.05) / (L2 + 0.05)
  /// dove L1 = luminance del colore più chiaro
  ///      L2 = luminance del colore più scuro
  ///
  /// Range: 1:1 (stesso colore) to 21:1 (bianco/nero)
  ///
  /// Esempio:
  /// ```dart
  /// final ratio = AccessibilityUtils.getContrastRatio(
  ///   context.colors.surface,  // foreground
  ///   context.colors.primary,   // background
  /// );
  /// ```
  static double getContrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calcola relative luminance di un colore (0.0 - 1.0)
  ///
  /// Formula W3C:
  /// L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  /// dove R,G,B sono linearized RGB values
  static double _relativeLuminance(Color color) {
    // Converti RGB da 0-255 a 0-1
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    // Linearize RGB values
    final rLinear = _linearizeColorComponent(r);
    final gLinear = _linearizeColorComponent(g);
    final bLinear = _linearizeColorComponent(b);

    // Calcola luminance weighted
    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  /// Linearizza componente colore per calcolo luminance
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  // ========================================
  // WCAG Conformance Checks
  // ========================================

  /// Verifica se contrast ratio soddisfa WCAG AA (4.5:1 min)
  ///
  /// Uso: Testo normale (< 18pt o < 14pt bold)
  ///
  /// Esempio:
  /// ```dart
  /// if (AccessibilityUtils.meetsWCAG_AA(
  ///   foreground: context.colors.primary,
  ///   background: context.colors.surface,
  /// )) {
  ///   print('Testo accessibile!');
  /// }
  /// ```
  static bool meetsWCAG_AA({
    required Color foreground,
    required Color background,
  }) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= wcagAA;
  }

  /// Verifica se contrast ratio soddisfa WCAG AA Large (3:1 min)
  ///
  /// Uso: Testo grande (≥ 18pt o ≥ 14pt bold)
  static bool meetsWCAG_AALarge({
    required Color foreground,
    required Color background,
  }) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= wcagAALarge;
  }

  /// Verifica se contrast ratio soddisfa WCAG AAA (7:1 min)
  ///
  /// Uso: Enhanced accessibility per testo normale
  static bool meetsWCAG_AAA({
    required Color foreground,
    required Color background,
  }) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= wcagAAA;
  }

  /// Verifica se contrast ratio soddisfa WCAG AAA Large (4.5:1 min)
  ///
  /// Uso: Enhanced accessibility per testo grande
  static bool meetsWCAG_AAALarge({
    required Color foreground,
    required Color background,
  }) {
    final ratio = getContrastRatio(foreground, background);
    return ratio >= wcagAAALarge;
  }

  // ========================================
  // Color Suggestions
  // ========================================

  /// Suggerisce se usare testo bianco o nero su un background dato
  ///
  /// Calcola quale ha contrast ratio migliore.
  ///
  /// Esempio:
  /// ```dart
  /// final textColor = AccessibilityUtils.suggestTextColor(context.colors.primary);
  /// // Returns Colors.white o Colors.black
  /// ```
  static Color suggestTextColor(Color background) {
    final whiteRatio = getContrastRatio(Colors.white, background);
    final blackRatio = getContrastRatio(Colors.black, background);

    return whiteRatio > blackRatio ? Colors.white : Colors.black;
  }

  /// Verifica se un colore è "chiaro" (luminance > 0.5)
  ///
  /// Utile per decidere colore testo automaticamente.
  static bool isLightColor(Color color) {
    return _relativeLuminance(color) > 0.5;
  }

  /// Verifica se un colore è "scuro" (luminance ≤ 0.5)
  static bool isDarkColor(Color color) {
    return !isLightColor(color);
  }

  // ========================================
  // Debugging & Reporting
  // ========================================

  /// Genera report accessibilità per una coppia di colori
  ///
  /// Ritorna string formattata con tutte le info.
  ///
  /// Esempio:
  /// ```dart
  /// print(AccessibilityUtils.getAccessibilityReport(
  ///   foreground: context.colors.primary,
  ///   background: context.colors.surface,
  ///   label: 'Primary Button',
  /// ));
  /// ```
  static String getAccessibilityReport({
    required Color foreground,
    required Color background,
    String? label,
  }) {
    final ratio = getContrastRatio(foreground, background);
    final aa = meetsWCAG_AA(foreground: foreground, background: background);
    final aaLarge = meetsWCAG_AALarge(foreground: foreground, background: background);
    final aaa = meetsWCAG_AAA(foreground: foreground, background: background);
    final aaaLarge = meetsWCAG_AAALarge(foreground: foreground, background: background);

    final buffer = StringBuffer();

    if (label != null) {
      buffer.writeln('🎨 Accessibility Report: $label');
    } else {
      buffer.writeln('🎨 Accessibility Report');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Foreground: ${_colorToHex(foreground)}');
    buffer.writeln('Background: ${_colorToHex(background)}');
    buffer.writeln('Contrast Ratio: ${ratio.toStringAsFixed(2)}:1');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('WCAG AA (4.5:1):        ${aa ? "✅ PASS" : "❌ FAIL"}');
    buffer.writeln('WCAG AA Large (3:1):    ${aaLarge ? "✅ PASS" : "❌ FAIL"}');
    buffer.writeln('WCAG AAA (7:1):         ${aaa ? "✅ PASS" : "❌ FAIL"}');
    buffer.writeln('WCAG AAA Large (4.5:1): ${aaaLarge ? "✅ PASS" : "❌ FAIL"}');

    return buffer.toString();
  }

  /// Converti Color a hex string per debug
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
