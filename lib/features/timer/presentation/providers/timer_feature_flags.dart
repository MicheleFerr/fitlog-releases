import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature flags for timer system migration
/// Allows gradual rollout of unified timer system
class TimerFeatureFlags {
  static const String _useUnifiedTimerKey = 'use_unified_timer_system';
  static const String _enableLegacyFallbackKey = 'enable_legacy_timer_fallback';
  static const String _debugTimerMetricsKey = 'debug_timer_metrics';
  
  final SharedPreferences _prefs;
  
  TimerFeatureFlags(this._prefs);
  
  /// Whether to use the new unified timer system
  bool get useUnifiedTimer => _prefs.getBool(_useUnifiedTimerKey) ?? true;
  
  /// Whether to enable fallback to legacy system on errors
  bool get enableLegacyFallback => _prefs.getBool(_enableLegacyFallbackKey) ?? true;
  
  /// Whether to show debug timer metrics in UI
  bool get debugTimerMetrics => _prefs.getBool(_debugTimerMetricsKey) ?? false;
  
  /// Enable unified timer system
  Future<void> enableUnifiedTimer() async {
    await _prefs.setBool(_useUnifiedTimerKey, true);
  }
  
  /// Disable unified timer system (fallback to legacy)
  Future<void> disableUnifiedTimer() async {
    await _prefs.setBool(_useUnifiedTimerKey, false);
  }
  
  /// Enable debug metrics display
  Future<void> enableDebugMetrics() async {
    await _prefs.setBool(_debugTimerMetricsKey, true);
  }
  
  /// Disable debug metrics display
  Future<void> disableDebugMetrics() async {
    await _prefs.setBool(_debugTimerMetricsKey, false);
  }
  
  /// Enable legacy fallback
  Future<void> setLegacyFallbackEnabled() async {
    await _prefs.setBool(_enableLegacyFallbackKey, true);
  }
  
  /// Disable legacy fallback
  Future<void> disableLegacyFallback() async {
    await _prefs.setBool(_enableLegacyFallbackKey, false);
  }
  
  /// Reset all flags to defaults
  Future<void> resetToDefaults() async {
    await _prefs.remove(_useUnifiedTimerKey);
    await _prefs.remove(_enableLegacyFallbackKey);
    await _prefs.remove(_debugTimerMetricsKey);
  }
  
  /// Get all flag states for debugging
  Map<String, bool> getAllFlags() {
    return {
      'useUnifiedTimer': useUnifiedTimer,
      'enableLegacyFallback': enableLegacyFallback,
      'debugTimerMetrics': debugTimerMetrics,
    };
  }
}

// Provider for timer feature flags
final timerFeatureFlagsProvider = FutureProvider<TimerFeatureFlags>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return TimerFeatureFlags(prefs);
});

// Synchronous provider for when flags are already loaded
final timerFeatureFlagsAsyncProvider = Provider<AsyncValue<TimerFeatureFlags>>((ref) {
  return ref.watch(timerFeatureFlagsProvider);
});

// Quick access providers for individual flags
final useUnifiedTimerProvider = Provider<bool>((ref) {
  final flags = ref.watch(timerFeatureFlagsProvider);
  return flags.when(
    data: (flags) => flags.useUnifiedTimer,
    loading: () => false, // Default to legacy during loading
    error: (_, __) => false, // Default to legacy on error
  );
});

final enableTimerDebugProvider = Provider<bool>((ref) {
  final flags = ref.watch(timerFeatureFlagsProvider);
  return flags.when(
    data: (flags) => flags.debugTimerMetrics,
    loading: () => false,
    error: (_, __) => false,
  );
});