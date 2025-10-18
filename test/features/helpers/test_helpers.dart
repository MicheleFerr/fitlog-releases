/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test
/// 🎯 Feature: helpers
/// 🔧 Type: test helpers
/// 🌍 Localization: ✅ AppLocalizations included
/// 🎨 Theme: ✅ ColorScheme included
/// 📱 Platform: Universal
/// 
/// Test helpers for buddy matching enhanced features
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class TestHelpers {
  /// Creates a complete test app with localization and theme
  static Widget createTestApp({
    required Widget child,
    Brightness brightness = Brightness.light,
    Locale locale = const Locale('en', 'US'),
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: _createTheme(brightness),
        home: Scaffold(body: child),
      ),
    );
  }

  /// Creates a test widget with minimal setup for unit tests
  static Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Creates theme data for testing
  static ThemeData _createTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: brightness,
      ),
    );
  }

  /// Helper to test widget with multiple locales
  static Future<void> testWithLocales(
    WidgetTester tester,
    Widget child,
    List<Locale> locales,
    Future<void> Function() testCallback,
  ) async {
    for (final locale in locales) {
      await tester.pumpWidget(
        createTestApp(child: child, locale: locale),
      );
      await testCallback();
    }
  }

  /// Helper to test widget with both light and dark themes
  static Future<void> testWithThemes(
    WidgetTester tester,
    Widget child,
    Future<void> Function() testCallback,
  ) async {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(
        createTestApp(child: child, brightness: brightness),
      );
      await testCallback();
    }
  }

  /// Commonly used test locales
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('it', 'IT'),
  ];

  /// Helper to find text in any supported locale
  static Finder findLocalizedText(String englishText, String italianText) {
    return find.byWidgetPredicate((widget) =>
        widget is Text &&
        (widget.data == englishText || widget.data == italianText));
  }

  /// Helper to tap and settle animations
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Helper to enter text and settle
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Helper to scroll until visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable,
  ) async {
    await tester.scrollUntilVisible(
      finder,
      500.0,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
  }

  /// Helper to verify accessibility compliance
  static Future<void> verifyAccessibility(WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    handle.dispose();
  }

  /// Helper to test responsive behavior at different sizes
  static Future<void> testAtDifferentSizes(
    WidgetTester tester,
    Widget child,
    Future<void> Function() testCallback,
  ) async {
    final sizes = [
      const Size(375, 667), // iPhone SE
      const Size(414, 896), // iPhone 11 Pro Max
      const Size(768, 1024), // iPad
    ];

    for (final size in sizes) {
      tester.binding.window.physicalSizeTestValue = size;
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createTestApp(child: child));
      await testCallback();
    }

    // Reset to default
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  }
}