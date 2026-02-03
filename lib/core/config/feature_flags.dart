/// Feature Flags
///
/// Centralized feature flag management for conditional feature rollout.
/// Uses environment configuration to enable/disable features.
library;

import 'package:gymbro_flutter_new/core/config/environment_config.dart';

/// Feature flags for the app
class FeatureFlags {
  FeatureFlags._();

  /// AI Coach feature flag
  ///
  /// Enabled only if OpenRouter API key is configured.
  /// This allows graceful degradation if key is missing.
  static bool get aiCoachEnabled =>
      EnvironmentConfig.openRouterApiKey != null &&
      EnvironmentConfig.openRouterApiKey!.isNotEmpty;

  /// Debug mode flag
  static bool get isDebugMode => EnvironmentConfig.environment == 'development';

  /// Enable detailed logging
  static bool get verboseLogging => isDebugMode;
}
