library;

import 'package:gymbro_flutter_new/core/config/environment_config.dart';

class RevenueCatConfig {
  RevenueCatConfig._();

  static const String premiumEntitlementId = 'premium';

  static const String monthlyProductId = 'fitlog_pro_monthly';
  static const String yearlyProductId = 'fitlog_pro_yearly';
  static const String lifetimeProductId = 'fitlog_pro_lifetime';

  static String get apiKey => EnvironmentConfig.revenueCatApiKey ?? '';

  static bool get isConfigured => apiKey.isNotEmpty;
}
