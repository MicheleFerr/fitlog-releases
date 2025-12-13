import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

// App Configuration State Provider
final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

class AppConfigNotifier extends Notifier<AppConfig> {
  static const String _boxName = 'app_config';
  Box<AppConfig>? _configBox;

  // CRITICAL: Initialization tracking
  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;

  @override
  AppConfig build() {
    // Register disposal callback
    ref.onDispose(() {
      if (kDebugMode) {
        debugPrint('🧹 [AppConfig] Starting disposal');
      }

      try {
        _isDisposed = true;

        // Close Hive box if open
        if (_configBox != null && _configBox!.isOpen) {
          _configBox!.close();
          if (kDebugMode) {
            debugPrint('✅ [AppConfig] Config box closed');
          }
        }

        // Null assignment for memory cleanup
        _configBox = null;
        _initCompleter = null;

        if (kDebugMode) {
          debugPrint('✅ [AppConfig] Disposal completed');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [AppConfig] Error during disposal: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
      }
    });

    // Initialize asynchronously
    _initCompleter = Completer<void>();
    _initializeConfig();

    // Return default config immediately (will update once loaded)
    return const AppConfig();
  }

  Future<void> _initializeConfig() async {
    try {
      if (kDebugMode) {
        debugPrint('📱 [AppConfig] Starting initialization (attempt ${_initRetryCount + 1})');
      }

      final boxManager = ref.read(hiveBoxManagerProvider);
      _configBox = await boxManager.openBox<AppConfig>(_boxName);
      final savedConfig = _configBox!.get('config');

      if (savedConfig != null) {
        state = savedConfig;
        if (kDebugMode) {
          debugPrint('✅ [AppConfig] Loaded saved configuration');
        }
      } else {
        if (kDebugMode) {
          debugPrint('📋 [AppConfig] No saved config, using defaults');
        }
      }

      _isInitialized = true;
      _initRetryCount = 0;
      _initCompleter?.complete();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Initialization completed successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Initialization failed (attempt ${_initRetryCount + 1}): $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }

      // Use default config as fallback
      state = const AppConfig();

      // Complete with error to prevent hanging
      if (!_initCompleter!.isCompleted) {
        _initCompleter?.completeError(e, stackTrace);
      }
    }
  }

  /// CRITICAL: Ensure initialization before operations
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    if (_initRetryCount >= _maxInitRetries) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Initialization failed after $_maxInitRetries attempts');
      }
      throw Exception('AppConfig initialization failed after $_maxInitRetries attempts');
    }

    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('AppConfig initialization timeout');
          },
        );
      } catch (e) {
        _initRetryCount++;
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Retrying initialization (attempt ${_initRetryCount + 1})');
        }

        _initCompleter = Completer<void>();
        await _initializeConfig();
      }
    }
  }

  Future<void> _saveConfig() async {
    try {
      // CRITICAL: Ensure initialized before saving
      await _ensureInitialized();

      if (_isDisposed) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Cannot save: provider disposed');
        }
        return;
      }

      if (_configBox == null) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Cannot save: config box not initialized');
        }
        return;
      }

      await _configBox!.put('config', state);

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Configuration saved successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Failed to save configuration: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Don't rethrow - allow app to continue even if save fails
    }
  }

  // Language settings
  Future<void> setLanguage(String languageCode, String countryCode) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      // Input validation
      if (languageCode.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Invalid language code: empty');
        }
        return;
      }

      state = state.copyWith(
        languageCode: languageCode,
        countryCode: countryCode,
      );
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Language set to: $languageCode-$countryCode');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting language: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Theme settings
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(themeMode: themeMode);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Theme mode set to: ${themeMode.name}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting theme mode: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  Future<void> setPrimaryColor(String color) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(primaryColor: color);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Primary color set to: $color');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting primary color: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  Future<void> setFontSize(double fontSize) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      // Input validation
      if (fontSize < 0.8 || fontSize > 1.2) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Invalid font size: $fontSize (must be 0.8-1.2)');
        }
        return;
      }

      state = state.copyWith(fontSize: fontSize);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Font size set to: $fontSize');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting font size: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Effort scale settings (RPE or RIR)
  Future<void> setEffortScale(String scale) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      // Input validation
      if (scale != 'rpe' && scale != 'rir') {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Invalid effort scale: $scale');
        }
        return;
      }

      state = state.copyWith(effortScale: scale);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Effort scale set to: $scale');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting effort scale: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Measurement settings
  Future<void> setMeasurementUnit(String unit) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      // Input validation
      if (unit != 'kg' && unit != 'lbs') {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Invalid measurement unit: $unit');
        }
        return;
      }

      state = state.copyWith(measurementUnit: unit);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Measurement unit set to: $unit');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting measurement unit: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Sound and feedback settings
  Future<void> setSoundEnabled(bool enabled) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(soundEnabled: enabled);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Sound enabled set to: $enabled');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting sound enabled: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Workout settings
  Future<void> setDefaultRestTime(int seconds) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      // Input validation
      if (seconds < 0 || seconds > 600) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Invalid rest time: $seconds (must be 0-600)');
        }
        return;
      }

      state = state.copyWith(defaultRestTime: seconds);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Default rest time set to: ${seconds}s');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting default rest time: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  Future<void> setAutoStartTimer(bool autoStart) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(autoStartTimer: autoStart);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Auto start timer set to: $autoStart');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting auto start timer: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Preset configurations
  Future<void> applyPreset(AppConfig preset) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = preset;
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Preset applied successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error applying preset: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Beta Mode settings
  Future<void> setBetaMode(bool enabled) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(betaModeEnabled: enabled);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Beta mode set to: $enabled');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting beta mode: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = const AppConfig();
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Reset to defaults completed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error resetting to defaults: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Preferred template setting
  Future<void> setPreferredTemplateId(String? templateId) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(preferredTemplateId: templateId);
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Preferred template ID set to: $templateId');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error setting preferred template ID: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }
  
  // Workout customization settings
  Future<void> updateWorkoutSettings({
    bool? rpeTracking,
    bool? autoRestTimer,
    bool? setDurationTracking,
    bool? plateCalculator,
    bool? autoCollapseCompleted,
    bool? isProMode,
    bool? autoAdjustRestTime,
    bool? autoAdjustWeightFromRpe,
    bool? autoAdjustRestFromRpe,
  }) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(
        rpeTracking: rpeTracking,
        autoRestTimer: autoRestTimer,
        setDurationTracking: setDurationTracking,
        plateCalculator: plateCalculator,
        autoCollapseCompleted: autoCollapseCompleted,
        isProMode: isProMode,
        autoAdjustRestTime: autoAdjustRestTime,
        autoAdjustWeightFromRpe: autoAdjustWeightFromRpe,
        autoAdjustRestFromRpe: autoAdjustRestFromRpe,
      );
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Workout settings updated');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error updating workout settings: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // UI Display settings
  Future<void> updateDisplaySettings({
    bool? showTutInfo,
    bool? showExerciseNotes,
    bool? showCommunitySuggestions,
    bool? showExerciseInsights,
    bool? showCustomTimers,
    bool? showAdvancedMenu,
    bool? showCollapseCountdown,
    bool? simplifiedAnimations,
    bool? showQuickInfoIcon,
    bool? showWarmupIcon,
    bool? showPreventionIcon,
  }) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(
        showTutInfo: showTutInfo,
        showExerciseNotes: showExerciseNotes,
        showCommunitySuggestions: showCommunitySuggestions,
        showExerciseInsights: showExerciseInsights,
        showCustomTimers: showCustomTimers,
        showAdvancedMenu: showAdvancedMenu,
        showCollapseCountdown: showCollapseCountdown,
        simplifiedAnimations: simplifiedAnimations,
        showQuickInfoIcon: showQuickInfoIcon,
        showWarmupIcon: showWarmupIcon,
        showPreventionIcon: showPreventionIcon,
      );
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Display settings updated');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error updating display settings: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }
  
  // General update method
  Future<void> updateConfig(AppConfig newConfig) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = newConfig;
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Configuration updated');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error updating configuration: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // DEPRECATED: Legacy onboarding method - use OnboardingStateProvider instead
  @Deprecated('Use OnboardingStateProvider.resetOnboarding() instead')
  Future<void> resetOnboarding() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(
        hasSeenWorkoutOnboarding: false,
        onboardingVersion: 1,
      );
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Onboarding reset (DEPRECATED method)');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error resetting onboarding: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }
  }

  // Import/Export configuration
  Map<String, dynamic> exportConfig() {
    // Synchronous read-only operation - no need for error handling
    // State is always valid, toJson() should never fail
    if (kDebugMode) {
      debugPrint('📤 [AppConfig] Exporting configuration');
    }
    return state.toJson();
  }

  Future<void> importConfig(Map<String, dynamic> configJson) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      // Input validation
      if (configJson.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Cannot import empty configuration');
        }
        throw Exception('Empty configuration data');
      }

      // Attempt to parse config
      final newConfig = AppConfig.fromJson(configJson);

      // Additional validation after parsing
      if (newConfig.languageCode.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ [AppConfig] Invalid config: empty language code');
        }
        throw Exception('Invalid configuration: empty language code');
      }

      state = newConfig;
      await _saveConfig();

      if (kDebugMode) {
        debugPrint('✅ [AppConfig] Configuration imported successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [AppConfig] Error importing configuration: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      // Rethrow to let caller know import failed
      throw Exception('Invalid configuration format: $e');
    }
  }

}

// Helper providers for specific config values
final localeProvider = Provider<Locale>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.locale;
});

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(localeProvider);
  return lookupAppLocalizations(locale);
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

// DEPRECATED: Legacy provider - use OnboardingState instead
// final hasSeenWorkoutOnboardingProvider = Provider<bool>((ref) {
//   return ref.watch(appConfigProvider).hasSeenWorkoutOnboarding;
// });

final onboardingVersionProvider = Provider<int>((ref) {
  return ref.watch(appConfigProvider).onboardingVersion;
});

/// Effort scale provider - 'rpe' or 'rir'
final effortScaleProvider = Provider<String>((ref) {
  return ref.watch(appConfigProvider).effortScale;
});

/// Helper to check if using RIR mode
final useRirModeProvider = Provider<bool>((ref) {
  return ref.watch(effortScaleProvider) == 'rir';
});

// Beta mode provider
final betaModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).betaModeEnabled ?? false;
});

// Utility functions
extension WeightConversion on double {
  /// Convert from kg (stored) to display unit (kg or lbs)
  double toDisplayUnit(String unit) {
    if (unit == 'lbs') {
      return this * 2.20462; // kg to lbs
    }
    return this; // already in kg
  }

  /// Convert from display unit (kg or lbs) to kg (storage)
  double fromDisplayUnit(String unit) {
    if (unit == 'lbs') {
      return this / 2.20462; // lbs to kg
    }
    return this; // already in kg
  }

  /// Format weight with proper decimals and unit
  /// - kg: 2 decimals (27.75 kg)
  /// - lbs: 1 decimal (180.5 lbs)
  String formatWeight(String unit, {bool withSpace = true}) {
    final displayWeight = toDisplayUnit(unit);
    final separator = withSpace ? ' ' : '';

    if (displayWeight == 0) {
      return '0$separator$unit';
    }

    // For kg: use 2 decimals, for lbs: use 1 decimal
    final decimals = unit == 'kg' ? 2 : 1;

    // Show integer if no decimal part
    if (displayWeight % 1 == 0) {
      return '${displayWeight.toInt()}$separator$unit';
    }

    return '${displayWeight.toStringAsFixed(decimals)}$separator$unit';
  }

  /// Get weight increment based on unit
  /// - kg: 0.25 kg increments
  /// - lbs: 0.5 lbs increments
  static double getIncrement(String unit) {
    return unit == 'lbs' ? 0.5 : 0.25;
  }

  /// Get picker child count (number of items) based on unit
  /// - kg: 0-200 kg in 0.25 increments = 801 items
  /// - lbs: 0-440 lbs in 0.5 increments = 881 items
  static int getChildCount(String unit) {
    return unit == 'lbs' ? 881 : 801;
  }

  /// Get picker divisor for index calculation
  /// - kg: index / 4.0 (0.25 increments)
  /// - lbs: index / 2.0 (0.5 increments)
  static double getDivisor(String unit) {
    return unit == 'lbs' ? 2.0 : 4.0;
  }

  /// Get max weight for picker based on unit
  /// - kg: 200 kg
  /// - lbs: 440 lbs
  static double getMaxWeight(String unit) {
    return unit == 'lbs' ? 440.0 : 200.0;
  }
}