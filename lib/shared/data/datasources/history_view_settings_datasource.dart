/// 📊 History View Settings DataSource
///
/// Handles local persistence of history view preferences using Hive.
///
/// ✅ MIGRATED to HiveBoxManagerEnhanced pattern (Oct 2025)
/// - No direct Hive.openBox() calls
/// - Centralized box lifecycle management
library;

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/shared/data/models/history_view_settings_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/history_view_settings.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

class HistoryViewSettingsDataSource {

  /// Constructor with dependency injection
  HistoryViewSettingsDataSource(this._boxManager);
  final HiveBoxManagerEnhanced _boxManager;
  static const String _settingsKey = 'history_view_settings';

  /// Get settings box via HiveBoxManagerEnhanced
  Future<Box> _getSettingsBox() async {
    return await _boxManager.openBox(HiveBoxNames.settingsBox);
  }

  /// Get current settings from Hive
  Future<HistoryViewSettings?> getSettings() async {
    try {
      final box = await _getSettingsBox();
      final model = box.get(_settingsKey) as HistoryViewSettingsModel?;

      return model?.toDomain();
    } catch (e) {
      // Return null if error or not found
      return null;
    }
  }

  /// Save settings to Hive
  Future<void> saveSettings(HistoryViewSettings settings) async {
    try {
      final box = await _getSettingsBox();
      final model = HistoryViewSettingsModel.fromDomain(settings);

      await box.put(_settingsKey, model);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    try {
      final box = await _getSettingsBox();
      await box.delete(_settingsKey);
    } catch (e) {
      rethrow;
    }
  }
}
