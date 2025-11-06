import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/onerm_calculation_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for APRE calculation configuration with persistence
///
/// Manages the user's preferred 1RM calculation strategy for APRE workouts.
/// Configuration is persisted to SharedPreferences and loaded on app startup.
///
/// Available configurations:
/// - topThreeSets: Use 3 most recent sets (recency focus)
/// - topFiveSets: Use 5 most recent sets (balanced, default)
/// - allSetsInWindow: Use all sets within 7-day window (comprehensive)
/// - medianOfTop5: Use median of top 5 sets (stability focus)
final apreCalculationConfigProvider =
    AsyncNotifierProvider<APRECalculationConfigNotifier, OneRMCalculationConfig>(
  APRECalculationConfigNotifier.new,
);

/// Notifier for managing APRE calculation configuration
class APRECalculationConfigNotifier
    extends AsyncNotifier<OneRMCalculationConfig> {
  static const String _storageKey = 'apre_calculation_config';

  @override
  Future<OneRMCalculationConfig> build() async {
    return await _loadConfig();
  }

  /// Load configuration from SharedPreferences
  Future<OneRMCalculationConfig> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(_storageKey);

    if (savedValue == null) {
      return OneRMCalculationConfig.topFiveSets; // Default
    }

    // Parse enum from string
    try {
      return OneRMCalculationConfig.values.firstWhere(
        (config) => config.name == savedValue,
      );
    } catch (_) {
      return OneRMCalculationConfig.topFiveSets; // Fallback to default
    }
  }

  /// Save configuration to SharedPreferences
  Future<void> _saveConfig(OneRMCalculationConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, config.name);
  }

  /// Update configuration and persist to storage
  Future<void> setConfig(OneRMCalculationConfig config) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _saveConfig(config);
      return config;
    });
  }

  /// Reset configuration to default (topFiveSets)
  Future<void> resetToDefault() async {
    await setConfig(OneRMCalculationConfig.topFiveSets);
  }
}
