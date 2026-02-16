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

  /// Workout Import from text/photo - requires OpenRouter API key
  /// TEMPORARILY DISABLED - Remove this line to re-enable
  static bool get workoutImportEnabled => false; // was: aiCoachEnabled

  /// Debug mode flag
  static bool get isDebugMode => EnvironmentConfig.environment == 'development';

  /// Enable detailed logging
  static bool get verboseLogging => isDebugMode;
}
