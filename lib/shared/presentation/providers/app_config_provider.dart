import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/app_config.dart';

// App Configuration State Provider
final appConfigProvider = StateNotifierProvider<AppConfigNotifier, AppConfig>((ref) {
  return AppConfigNotifier();
});

class AppConfigNotifier extends StateNotifier<AppConfig> {
  static const String _boxName = 'app_config';
  late Box<AppConfig> _configBox;

  AppConfigNotifier() : super(const AppConfig()) {
    _initializeConfig();
  }

  Future<void> _initializeConfig() async {
    try {
      _configBox = await Hive.openBox<AppConfig>(_boxName);
      final savedConfig = _configBox.get('config');
      if (savedConfig != null) {
        state = savedConfig;
      }
    } catch (e) {
      // If there's an error, use default config
      state = const AppConfig();
    }
  }

  Future<void> _saveConfig() async {
    try {
      await _configBox.put('config', state);
    } catch (e) {
      // Handle save error - could show a snackbar or log
    }
  }

  // Language settings
  Future<void> setLanguage(String languageCode, String countryCode) async {
    state = state.copyWith(
      languageCode: languageCode,
      countryCode: countryCode,
    );
    await _saveConfig();
  }

  // Theme settings
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveConfig();
  }

  Future<void> setPrimaryColor(String color) async {
    state = state.copyWith(primaryColor: color);
    await _saveConfig();
  }

  Future<void> setFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _saveConfig();
  }

  // Measurement settings
  Future<void> setMeasurementUnit(String unit) async {
    state = state.copyWith(measurementUnit: unit);
    await _saveConfig();
  }

  // Sound and feedback settings
  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveConfig();
  }

  Future<void> setVibrationsEnabled(bool enabled) async {
    state = state.copyWith(vibrationsEnabled: enabled);
    await _saveConfig();
  }

  Future<void> setTimerSound(String timerSound) async {
    state = state.copyWith(timerSound: timerSound);
    await _saveConfig();
  }

  // Workout settings
  Future<void> setDefaultRestTime(int seconds) async {
    state = state.copyWith(defaultRestTime: seconds);
    await _saveConfig();
  }

  Future<void> setAutoStartTimer(bool autoStart) async {
    state = state.copyWith(autoStartTimer: autoStart);
    await _saveConfig();
  }

  Future<void> setShowIntensityTechniques(bool show) async {
    state = state.copyWith(showIntensityTechniques: show);
    await _saveConfig();
  }

  // iOS specific settings
  Future<void> setEnableLiveActivities(bool enabled) async {
    state = state.copyWith(enableLiveActivities: enabled);
    await _saveConfig();
  }

  Future<void> setSyncWithHealthKit(bool enabled) async {
    state = state.copyWith(syncWithHealthKit: enabled);
    await _saveConfig();
  }

  // Preset configurations
  Future<void> applyPreset(AppConfig preset) async {
    state = preset;
    await _saveConfig();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    state = const AppConfig();
    await _saveConfig();
  }

  // Preferred template setting
  Future<void> setPreferredTemplateId(String? templateId) async {
    state = state.copyWith(preferredTemplateId: templateId);
    await _saveConfig();
  }
  
  // Workout customization settings
  Future<void> updateWorkoutSettings({
    bool? rpeTracking,
    bool? autoRestTimer,
    bool? setDurationTracking,
    bool? plateCalculator,
    bool? warmupSuggestions,
  }) async {
    state = state.copyWith(
      rpeTracking: rpeTracking,
      autoRestTimer: autoRestTimer,
      setDurationTracking: setDurationTracking,
      plateCalculator: plateCalculator,
      warmupSuggestions: warmupSuggestions,
    );
    await _saveConfig();
  }
  
  // General update method
  Future<void> updateConfig(AppConfig newConfig) async {
    state = newConfig;
    await _saveConfig();
  }

  // Import/Export configuration
  Map<String, dynamic> exportConfig() {
    return state.toJson();
  }

  Future<void> importConfig(Map<String, dynamic> configJson) async {
    try {
      state = AppConfig.fromJson(configJson);
      await _saveConfig();
    } catch (e) {
      // Handle import error - invalid config format
      throw Exception('Invalid configuration format');
    }
  }
}

// Helper providers for specific config values
final localeProvider = Provider<Locale>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.locale;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appConfigProvider).themeMode;
});

final measurementUnitProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).measurementUnit;
});

final soundEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).soundEnabled;
});

final defaultRestTimeProvider = Provider<int>((ref) {
  return ref.watch(appConfigProvider).defaultRestTime;
});

final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(appConfigProvider).fontSize;
});

final preferredTemplateIdProvider = Provider<String?>((ref) {
  return ref.watch(appConfigProvider).preferredTemplateId;
});

// Utility functions
extension WeightConversion on double {
  double toDisplayUnit(String unit) {
    if (unit == 'lbs') {
      return this * 2.20462; // kg to lbs
    }
    return this; // already in kg
  }

  double fromDisplayUnit(String unit) {
    if (unit == 'lbs') {
      return this / 2.20462; // lbs to kg
    }
    return this; // already in kg
  }

  String formatWeight(String unit) {
    final displayWeight = toDisplayUnit(unit);
    return '${displayWeight.toStringAsFixed(displayWeight % 1 == 0 ? 0 : 1)}$unit';
  }
}