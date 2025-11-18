/// Global feature flags for experimental/toggleable features
///
/// These flags allow enabling/disabling features without code changes.
/// Set to `false` to disable resource-intensive experimental features.
class FeatureFlags {
  const FeatureFlags._();

  /// Enable velocity tracking via accelerometer/gyroscope
  ///
  /// WARNING: High battery/memory impact when enabled
  /// - Battery: ~40% drain (continuous 50Hz sensor polling)
  /// - Memory: ~50MB (sensor data buffering)
  ///
  /// Use case: Experimental rep velocity analysis
  /// Status: Disabled (not used in production)
  ///
  /// To enable: Change to `true` and rebuild app
  static const bool enableVelocityTracking = false;

  /// Enable APRE (Autoregulatory Progressive Resistance Exercise) system
  ///
  /// WARNING: High CPU/memory impact when enabled
  /// - CPU: Heavy 1RM/3RM/6RM/10RM calculations (can block UI)
  /// - Memory: ~30-50MB (calculation cache + metadata)
  /// - Complexity: 20+ files, 10+ fields in Exercise entity
  ///
  /// Use case: Advanced auto-regulation for strength training
  /// Status: Disabled (not used in production - use RPE/RIR instead)
  ///
  /// To enable: Change to `true` and rebuild app
  static const bool enableAPRE = false;

  /// Enable repaint rainbow visualization (DEBUG ONLY)
  ///
  /// Shows colored overlays on widgets when they repaint.
  /// Useful for testing RepaintBoundary effectiveness.
  ///
  /// WARNING: Only works in debug mode (kDebugMode = true)
  /// - Performance: Minimal impact (visual overlay only)
  /// - Use case: Performance debugging and RepaintBoundary validation
  ///
  /// To enable: Change to `true` and rebuild app
  /// Status: Disabled by default (enable for performance testing)
  static const bool enableRepaintRainbow = false;

  // Future flags can be added here:
  // static const bool enableAICoach = true;
  // static const bool enableAdvancedAnalytics = false;
}
