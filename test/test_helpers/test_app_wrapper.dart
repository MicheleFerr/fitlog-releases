/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test/helpers
/// 🎯 Feature: universal test wrapper
/// 🔧 Type: test helper
/// 🌍 Localization: ✅ AppLocalizations setup
/// 🎨 Theme: ✅ Light/Dark theme support
/// 📱 Platform: Universal
/// 
/// Universal test wrapper for widget tests with proper setup
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_provider_v2.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_state.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'firebase_test_helper.dart';

/// Universal test wrapper that provides proper Material app setup
/// with localization, themes, and common providers
class TestAppWrapper extends StatelessWidget {

  const TestAppWrapper({
    super.key,
    required this.child,
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.overrides = const [],
  });
  final Widget child;
  final ThemeMode themeMode;
  final Locale locale;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Default mock providers - can be overridden
        // Mock HiveBoxManager for tests
        hiveBoxManagerProvider.overrideWithValue(HiveBoxManagerEnhanced()),
        appConfigProvider.overrideWith((ref) {
          final boxManager = ref.watch(hiveBoxManagerProvider);
          final notifier = AppConfigNotifier(boxManager);
          notifier.state = AppConfig(
            themeMode: themeMode,
            languageCode: locale.languageCode,
            countryCode: locale.countryCode ?? 'US',
          );
          return notifier;
        }),
        userStateProvider.overrideWith((ref) => Stream.value(
          const UserUnauthenticated()
        )),
        ...overrides,
      ],
      child: MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}

/// Helper function to create a proper widget test environment
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
  bool setupFirebase = false,
}) async {
  // Setup Firebase if needed
  if (setupFirebase) {
    await setupTestEnvironment();
  }

  // Pump the widget with proper wrapper
  await tester.pumpWidget(
    TestAppWrapper(
      themeMode: themeMode,
      locale: locale,
      overrides: overrides,
      child: child,
    ),
  );
  
  // Wait for all animations and async operations to complete
  await tester.pumpAndSettle();
}

/// Convenience function for authenticated user tests
Future<void> pumpAuthenticatedWidget(
  WidgetTester tester,
  Widget child, {
  required UserState userState,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  List<Override> additionalOverrides = const [],
}) async {
  await pumpTestWidget(
    tester,
    child,
    themeMode: themeMode,
    locale: locale,
    overrides: [
      userStateProvider.overrideWith((ref) => Stream.value(userState)),
      ...additionalOverrides,
    ],
  );
}

/// Helper to create basic test scenarios
class TestScenarios {
  /// Create a MaterialApp with basic setup (no providers)
  static Widget basicApp(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  /// Create a Scaffold with AppBar for widget tests
  static Widget scaffoldWithAppBar({
    required String title,
    Widget? body,
    List<Widget>? actions,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body ?? const Center(child: Text('Test Body')),
    );
  }
}