import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/shared/data/models/weight_settings_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';

/// Local DataSource for WeightSettings (Hive)
class WeightSettingsDataSource {
  static const String _boxName = 'weight_settings';
  static const String _settingsKey = 'user_weight_settings';

  Box<WeightSettingsModel>? _box;

  /// Get Hive box (lazy open)
  Future<Box<WeightSettingsModel>> get _settingsBox async {
    _box ??= await Hive.openBox<WeightSettingsModel>(_boxName);
    return _box!;
  }

  /// Save weight settings
  Future<void> saveSettings(WeightSettings settings) async {
    try {
      final box = await _settingsBox;
      final model = WeightSettingsModel.fromEntity(settings);
      await box.put(_settingsKey, model);

      if (kDebugMode) {
        debugPrint('✅ Weight settings saved to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving weight settings: $e');
      }
      rethrow;
    }
  }

  /// Get weight settings
  Future<WeightSettings?> getSettings() async {
    try {
      final box = await _settingsBox;
      final model = box.get(_settingsKey);

      if (model == null) {
        if (kDebugMode) {
          debugPrint('⚠️ No weight settings found in Hive');
        }
        return null;
      }

      return model.toEntity();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting weight settings: $e');
      }
      rethrow;
    }
  }

  /// Clear settings
  Future<void> clearSettings() async {
    try {
      final box = await _settingsBox;
      await box.delete(_settingsKey);

      if (kDebugMode) {
        debugPrint('✅ Weight settings cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing weight settings: $e');
      }
      rethrow;
    }
  }
}
