import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/data/models/feedback_settings_model.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// DataSource for FeedbackSettings (Hive local storage)
///
/// ✅ MIGRATED to HiveBoxManagerEnhanced pattern (Oct 2025)
/// - No direct Hive.openBox() calls
/// - Centralized box lifecycle management
class FeedbackSettingsDataSource {

  /// Constructor with dependency injection
  FeedbackSettingsDataSource(this._boxManager);
  final HiveBoxManagerEnhanced _boxManager;
  static const String _key = 'feedback_settings';

  /// Get settings box via HiveBoxManagerEnhanced
  Future<Box<FeedbackSettingsModel>> _getSettingsBox() async {
    return await _boxManager.openBox<FeedbackSettingsModel>(HiveBoxNames.settingsBox);
  }

  /// Get feedback settings from Hive
  Future<FeedbackSettings?> getSettings() async {
    final box = await _getSettingsBox();
    final model = box.get(_key);
    return model?.toEntity();
  }

  /// Save feedback settings to Hive
  Future<void> saveSettings(FeedbackSettings settings) async {
    final box = await _getSettingsBox();
    final model = FeedbackSettingsModel.fromEntity(settings);
    await box.put(_key, model);
  }

  /// Delete settings (reset to defaults)
  Future<void> deleteSettings() async {
    final box = await _getSettingsBox();
    await box.delete(_key);
  }
}
