/// AppThemeMode entity tests - enum values, fromString, computed properties.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_theme_mode.dart';

void main() {
  group('AppThemeMode', () {
    test('has 6 values', () {
      expect(AppThemeMode.values.length, 6);
    });

    test('flutterThemeMode', () {
      expect(AppThemeMode.system.flutterThemeMode, ThemeMode.system);
      expect(AppThemeMode.light.flutterThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.flutterThemeMode, ThemeMode.dark);
      expect(AppThemeMode.ultraDark.flutterThemeMode, ThemeMode.dark);
      expect(AppThemeMode.pink.flutterThemeMode, ThemeMode.light);
      expect(AppThemeMode.darkPink.flutterThemeMode, ThemeMode.dark);
    });

    test('isDark', () {
      expect(AppThemeMode.system.isDark, isFalse);
      expect(AppThemeMode.light.isDark, isFalse);
      expect(AppThemeMode.dark.isDark, isTrue);
      expect(AppThemeMode.ultraDark.isDark, isTrue);
      expect(AppThemeMode.pink.isDark, isFalse);
      expect(AppThemeMode.darkPink.isDark, isTrue);
    });

    test('isCustomTheme', () {
      expect(AppThemeMode.system.isCustomTheme, isFalse);
      expect(AppThemeMode.light.isCustomTheme, isFalse);
      expect(AppThemeMode.dark.isCustomTheme, isFalse);
      expect(AppThemeMode.ultraDark.isCustomTheme, isTrue);
      expect(AppThemeMode.pink.isCustomTheme, isTrue);
      expect(AppThemeMode.darkPink.isCustomTheme, isTrue);
    });

    test('fromString valid', () {
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
      expect(AppThemeMode.fromString('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromString('ultraDark'), AppThemeMode.ultraDark);
      expect(AppThemeMode.fromString('pink'), AppThemeMode.pink);
    });

    test('fromString null returns system', () {
      expect(AppThemeMode.fromString(null), AppThemeMode.system);
    });

    test('fromString invalid returns system', () {
      expect(AppThemeMode.fromString('invalid'), AppThemeMode.system);
    });

    test('fromThemeMode', () {
      expect(AppThemeMode.fromThemeMode(ThemeMode.system), AppThemeMode.system);
      expect(AppThemeMode.fromThemeMode(ThemeMode.light), AppThemeMode.light);
      expect(AppThemeMode.fromThemeMode(ThemeMode.dark), AppThemeMode.dark);
    });
  });
}
