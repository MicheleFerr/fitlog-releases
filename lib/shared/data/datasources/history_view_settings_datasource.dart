/// 📊 History View Settings DataSource
///
/// Handles local persistence of history view preferences using Hive.
library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/shared/data/models/history_view_settings_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/history_view_settings.dart';

class HistoryViewSettingsDataSource {
  static const String _boxName = 'settings_box';
  static const String _settingsKey = 'history_view_settings';

  /// Get current settings from Hive
  Future<HistoryViewSettings?> getSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
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
      final box = await Hive.openBox(_boxName);
      final model = HistoryViewSettingsModel.fromDomain(settings);

      await box.put(_settingsKey, model);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_settingsKey);
    } catch (e) {
      rethrow;
    }
  }
}
