/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// Analytics initialization provider
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_profile_provider.dart';

/// Analytics initialization provider
///
/// Automatically sets user properties when the app starts and when they change.
/// This provider should be watched in FitLogApp to ensure user properties
/// are set immediately after app launch.
///
/// User properties set:
/// - `unit_system`: "kg" or "lbs"
/// - `theme_mode`: "light", "dark", or "system"
/// - `language`: "en" or "it"
/// - `premium_status`: true/false (from auth provider)
/// - `app_version`: Current app version
/// - `font_size`: Font size multiplier
///
/// Also:
/// - Sets the user ID for analytics tracking
/// - Logs the initial app_open event
final analyticsInitializationProvider = FutureProvider<void>((ref) async {
  // Watch all relevant providers
  final analytics = ref.watch(analyticsServiceProvider);
  final config = ref.watch(appConfigProvider);
  final locale = ref.watch(localeProvider);
  final themeMode = ref.watch(themeModeProvider);
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(userProfileProvider);

  // Extract user ID and premium status from async user profile
  String? userId;
  bool isPremium = false;

  userProfileAsync.whenData((profile) {
    userId = profile?.uid;
    isPremium = profile?.isPremium ?? false;
  });

  // Set user ID for analytics tracking (CRITICAL FOR USER TRACKING!)
  if (userId != null) {
    await analytics.setUserId(userId);

    if (kDebugMode) {
      debugPrint('📊 Analytics user ID set: $userId');
    }
  } else {
    // Clear user ID if user logged out
    await analytics.setUserId(null);

    if (kDebugMode) {
      debugPrint('📊 Analytics user ID cleared (user logged out)');
    }
  }

  // Set user properties based on current configuration
  await _setUserProperties(
    analytics: analytics,
    config: config,
    locale: locale,
    themeMode: themeMode,
    authState: authState,
    isPremium: isPremium,
  );

  // Log app open event
  await analytics.logAppOpen();

  if (kDebugMode) {
    debugPrint('✅ Analytics initialization complete');
  }
});

/// Set all user properties
///
/// This function is called whenever any configuration changes.
Future<void> _setUserProperties({
  required IAnalyticsService analytics,
  required AppConfig config,
  required Locale? locale,
  required ThemeMode themeMode,
  required AuthState authState,
  required bool isPremium,
}) async {
  try {
    // Unit system (kg or lbs)
    final unitSystem = config.measurementUnit; // "kg" or "lbs"
    await analytics.setUserProperty(
      name: AnalyticsUserProperties.preferredUnitSystem,
      value: unitSystem,
    );

    // Theme mode (light, dark, system)
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
      case ThemeMode.dark:
        themeModeString = 'dark';
      case ThemeMode.system:
        themeModeString = 'system';
    }
    await analytics.setUserProperty(
      name: AnalyticsUserProperties.preferredTheme,
      value: themeModeString,
    );

    // Language (en or it)
    final language = locale?.languageCode ?? 'en';
    await analytics.setUserProperty(
      name: AnalyticsUserProperties.preferredLanguage,
      value: language,
    );

    // Premium status
    await analytics.setUserProperty(
      name: AnalyticsUserProperties.premiumStatus,
      value: isPremium ? 'true' : 'false',
    );

    // Font size (custom property, not in AnalyticsUserProperties constants)
    await analytics.setUserProperty(
      name: 'font_size',
      value: config.fontSize.toString(),
    );

    // Authentication status
    final isAuthenticated = authState == AuthState.authenticated;
    await analytics.setUserProperty(
      name: 'auth_status',
      value: isAuthenticated ? 'authenticated' : 'unauthenticated',
    );

    if (kDebugMode) {
      debugPrint('📊 Analytics user properties set:');
      debugPrint('   Unit system: $unitSystem');
      debugPrint('   Theme: $themeModeString');
      debugPrint('   Language: $language');
      debugPrint('   Premium: $isPremium');
      debugPrint('   Font size: ${config.fontSize}');
      debugPrint('   Auth: ${isAuthenticated ? "authenticated" : "unauthenticated"}');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Error setting analytics user properties: $e');
    }
  }
}
