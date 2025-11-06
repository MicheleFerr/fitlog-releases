import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/utils/contrast_checker.dart';

void main() {
  group('ContrastChecker', () {
    test('should calculate correct contrast ratio for black on white', () {
      // Black on white should have max contrast (21:1)
      final ratio = ContrastChecker.contrastRatio(Colors.black, Colors.white);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('should calculate correct contrast ratio for white on black', () {
      // White on black should have max contrast (21:1)
      final ratio = ContrastChecker.contrastRatio(Colors.white, Colors.black);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('should calculate correct contrast ratio for same colors', () {
      // Same colors should have min contrast (1:1)
      final ratio = ContrastChecker.contrastRatio(Colors.blue, Colors.blue);
      expect(ratio, closeTo(1.0, 0.1));
    });

    test('should pass WCAG AA for normal text with high contrast', () {
      // Black on white should pass
      final passes = ContrastChecker.meetsWCAG_AA_Normal(
        Colors.black,
        Colors.white,
      );
      expect(passes, true);
    });

    test('should fail WCAG AA for normal text with low contrast', () {
      // Light gray on white should fail
      final passes = ContrastChecker.meetsWCAG_AA_Normal(
        const Color(0xFFEEEEEE),
        Colors.white,
      );
      expect(passes, false);
    });

    test('should pass WCAG AA for large text with moderate contrast', () {
      // Moderate contrast (3:1) should pass for large text
      final passes = ContrastChecker.meetsWCAG_AA_Large(
        const Color(0xFF767676),
        Colors.white,
      );
      expect(passes, true);
    });

    test('should verify ColorScheme compliance', () {
      // Create a compliant color scheme
      const scheme = ColorScheme.light(
        primary: Color(0xFF1976D2),
        onPrimary: Colors.white,
        secondary: Color(0xFFFF5722),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Color(0xFFD32F2F),
        onError: Colors.white,
      );

      final report = ContrastChecker.verifyColorScheme(scheme);

      // Should have minimal violations
      expect(report.passedChecks, greaterThan(4));
    });

    test('should suggest darker color to meet contrast ratio', () {
      const lightBlue = Color(0xFF90CAF9);
      const white = Colors.white;

      final suggested = ContrastChecker.suggestDarker(
        lightBlue,
        white,
        4.5, // WCAG AA normal text
      );

      // Suggested color should be darker
      final suggestedLightness = HSLColor.fromColor(suggested).lightness;
      final originalLightness = HSLColor.fromColor(lightBlue).lightness;
      expect(suggestedLightness, lessThan(originalLightness));

      // Suggested color should meet contrast requirement
      final ratio = ContrastChecker.contrastRatio(suggested, white);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('should suggest lighter color to meet contrast ratio', () {
      const darkBlue = Color(0xFF0D47A1);
      const black = Colors.black;

      final suggested = ContrastChecker.suggestLighter(
        darkBlue,
        black,
        4.5, // WCAG AA normal text
      );

      // Suggested color should be lighter
      final suggestedLightness = HSLColor.fromColor(suggested).lightness;
      final originalLightness = HSLColor.fromColor(darkBlue).lightness;
      expect(suggestedLightness, greaterThan(originalLightness));

      // Suggested color should meet contrast requirement
      final ratio = ContrastChecker.contrastRatio(suggested, black);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('should create violation report with correct details', () {
      final violation = ContrastViolation(
        foreground: const Color(0xFFEEEEEE),
        background: Colors.white,
        actualRatio: 1.2,
        requiredRatio: 4.5,
        context: 'Test text',
      );

      final message = violation.toString();
      expect(message, contains('Test text'));
      expect(message, contains('1.2'));
      expect(message, contains('4.5'));
    });

    test('should report compliant scheme correctly', () {
      const scheme = ColorScheme.light(
        primary: Color(0xFF0D47A1),
        onPrimary: Colors.white,
        secondary: Color(0xFFD84315),
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Color(0xFFC62828),
        onError: Colors.white,
      );

      final report = ContrastChecker.verifyColorScheme(scheme);

      // Should have high compliance (may not be 100% due to outline colors)
      expect(report.passedChecks, greaterThanOrEqualTo(5));
      expect(report.compliancePercentage, greaterThan(80.0));
    });
  });
}
