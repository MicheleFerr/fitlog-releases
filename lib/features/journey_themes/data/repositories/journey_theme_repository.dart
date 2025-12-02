/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/data/repositories
/// Feature: Journey Themes Gamification
/// Type: Repository
///
/// Manages persistence of journey theme configuration using Hive.
library;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme_config.dart';

/// Repository for journey theme configuration persistence
class JourneyThemeRepository {
  JourneyThemeRepository._();

  static JourneyThemeRepository? _instance;
  static JourneyThemeRepository get instance {
    _instance ??= JourneyThemeRepository._();
    return _instance!;
  }

  /// Hive box name
  static const String _boxName = 'journey_theme';

  /// Config key within box
  static const String _configKey = 'config';

  Box<JourneyThemeConfig>? _box;

  /// Initialize the repository
  ///
  /// NOTE: Migration from typeId 50 to 70 (December 2024)
  /// Old data might be corrupted due to typeId conflict with WeightSettingsModel.
  /// If box fails to open/read, we delete and recreate it.
  Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;

    try {
      _box = await Hive.openBox<JourneyThemeConfig>(_boxName);

      // Verify box is readable (catches corrupted data from typeId conflict)
      try {
        _box!.get(_configKey);
      } catch (readError) {
        if (kDebugMode) {
          debugPrint('⚠️ JourneyThemeRepository: Corrupted data detected, resetting box');
          debugPrint('   Error: $readError');
        }
        await _box!.clear();
      }

      if (kDebugMode) {
        debugPrint('✅ JourneyThemeRepository initialized');
      }
    } catch (e) {
      // Box itself failed to open - try deleting and recreating
      if (kDebugMode) {
        debugPrint('⚠️ JourneyThemeRepository: Box corrupted, deleting and recreating');
        debugPrint('   Error: $e');
      }

      try {
        await Hive.deleteBoxFromDisk(_boxName);
        _box = await Hive.openBox<JourneyThemeConfig>(_boxName);
        if (kDebugMode) {
          debugPrint('✅ JourneyThemeRepository initialized (after reset)');
        }
      } catch (resetError) {
        if (kDebugMode) {
          debugPrint('❌ JourneyThemeRepository initialization failed: $resetError');
        }
        rethrow;
      }
    }
  }

  /// Ensure box is initialized
  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError('JourneyThemeRepository not initialized. Call initialize() first.');
    }
  }

  /// Get current theme configuration
  JourneyThemeConfig getConfig() {
    _ensureInitialized();
    return _box!.get(_configKey) ?? JourneyThemeConfig.defaultConfig;
  }

  /// Get currently selected theme
  JourneyTheme getSelectedTheme() {
    return getConfig().selectedTheme;
  }

  /// Check if in preview mode
  bool isPreviewMode() {
    return getConfig().previewMode;
  }

  /// Save a new theme selection
  Future<void> selectTheme(JourneyTheme theme) async {
    _ensureInitialized();

    final currentConfig = getConfig();
    final newConfig = currentConfig.copyWith(
      selectedTheme: theme,
      previewMode: false,
      lastChanged: DateTime.now(),
    );

    await _box!.put(_configKey, newConfig);

    if (kDebugMode) {
      debugPrint('🎨 Theme changed to: ${theme.displayName}');
    }
  }

  /// Enter preview mode for a theme (temporary viewing)
  Future<void> enterPreviewMode(JourneyTheme theme) async {
    _ensureInitialized();

    final currentConfig = getConfig();
    final newConfig = currentConfig.copyWith(
      selectedTheme: theme,
      previewMode: true,
    );

    await _box!.put(_configKey, newConfig);

    if (kDebugMode) {
      debugPrint('👀 Preview mode: ${theme.displayName}');
    }
  }

  /// Exit preview mode, reverting to previously saved theme
  Future<void> exitPreviewMode(JourneyTheme? revertToTheme) async {
    _ensureInitialized();

    final currentConfig = getConfig();

    if (revertToTheme != null) {
      final newConfig = currentConfig.copyWith(
        selectedTheme: revertToTheme,
        previewMode: false,
      );
      await _box!.put(_configKey, newConfig);
    } else {
      // Just exit preview mode, keep current theme
      final newConfig = currentConfig.copyWith(previewMode: false);
      await _box!.put(_configKey, newConfig);
    }

    if (kDebugMode) {
      debugPrint('🔙 Exited preview mode');
    }
  }

  /// Confirm preview selection (make it permanent)
  Future<void> confirmPreview() async {
    _ensureInitialized();

    final currentConfig = getConfig();
    if (!currentConfig.previewMode) return;

    final newConfig = currentConfig.copyWith(
      previewMode: false,
      lastChanged: DateTime.now(),
    );

    await _box!.put(_configKey, newConfig);

    if (kDebugMode) {
      debugPrint('✅ Preview confirmed: ${currentConfig.selectedTheme.displayName}');
    }
  }

  /// Watch config changes (Listenable for ValueListenableBuilder)
  ValueListenable<Box<JourneyThemeConfig>> watchConfig() {
    _ensureInitialized();
    return _box!.listenable();
  }

  /// Get last theme change timestamp
  DateTime? getLastChanged() {
    return getConfig().lastChanged;
  }

  /// Reset to default configuration
  Future<void> resetToDefault() async {
    _ensureInitialized();
    await _box!.put(_configKey, JourneyThemeConfig.defaultConfig);

    if (kDebugMode) {
      debugPrint('🔄 Theme reset to default (Hunter)');
    }
  }

  /// Update custom nickname for personalized greetings
  Future<void> updateNickname(String? nickname) async {
    _ensureInitialized();

    final currentConfig = getConfig();
    final newConfig = currentConfig.copyWith(
      customNickname: nickname,
      clearNickname: nickname == null || nickname.isEmpty,
    );

    await _box!.put(_configKey, newConfig);

    if (kDebugMode) {
      debugPrint('👤 Nickname updated: ${nickname ?? "(default theme name)"}');
    }
  }

  /// Get current greeting name (nickname or theme name)
  String getGreetingName() {
    return getConfig().greetingName;
  }

  /// Close the Hive box (call on app dispose if needed)
  Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
