library;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:gymbro_flutter_new/core/config/environment_config.dart';

class RevenueCatConfig {
  RevenueCatConfig._();

  static const String premiumEntitlementId = 'premium';

  static const String monthlyProductId = 'fitlog_pro_monthly';
  static const String yearlyProductId = 'fitlog_pro_yearly';
  static const String lifetimeProductId = 'fitlog_pro_lifetime';

  // RevenueCat SDK keys are public, publishable keys. Keeping the Apple key as
  // an iOS fallback prevents manual Xcode archives from shipping a broken
  // paywall when DART_DEFINES were not injected.
  static const String defaultAppleApiKey = 'appl_jFDCyUUyzawfQQpQCOUMjrgAvgy';

  static String resolveApiKey({
    String? configuredValue,
    TargetPlatform? targetPlatform,
    bool isWeb = kIsWeb,
  }) {
    final normalized = configuredValue?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    if (isWeb) return '';

    final resolvedPlatform = targetPlatform ?? defaultTargetPlatform;
    if (resolvedPlatform == TargetPlatform.iOS) {
      return defaultAppleApiKey;
    }

    return '';
  }

  static String get apiKey =>
      resolveApiKey(configuredValue: EnvironmentConfig.revenueCatApiKey);

  static bool get isConfigured => apiKey.isNotEmpty;
}
