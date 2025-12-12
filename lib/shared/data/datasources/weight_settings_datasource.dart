import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/shared/data/models/weight_settings_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Local DataSource for WeightSettings (Hive)
///
/// ✅ MIGRATED to HiveBoxManagerEnhanced pattern (Oct 2025)
/// - No direct Hive.openBox() calls
/// - Removed lazy caching (HiveBoxManagerEnhanced handles it)
/// - Centralized box lifecycle management
class WeightSettingsDataSource {

  /// Constructor with dependency injection
  WeightSettingsDataSource(this._boxManager);
  final HiveBoxManagerEnhanced _boxManager;
  // 🔐 User-scoped cache key
  String get _settingsKey => userCacheKeys.userScopedKey('user_weight_settings');

  /// Get settings box via HiveBoxManagerEnhanced (already cached)
  Future<Box<WeightSettingsModel>> _getSettingsBox() async {
    return await _boxManager.openBox<WeightSettingsModel>(HiveBoxNames.settingsBox);
  }

  /// Save weight settings
  Future<void> saveSettings(WeightSettings settings) async {
    try {
      final box = await _getSettingsBox();
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
      final box = await _getSettingsBox();
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
      final box = await _getSettingsBox();
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
