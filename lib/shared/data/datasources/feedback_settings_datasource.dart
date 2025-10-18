import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/data/models/feedback_settings_model.dart';

/// DataSource for FeedbackSettings (Hive local storage)
class FeedbackSettingsDataSource {
  static const String _boxName = 'feedback_settings_box';
  static const String _key = 'feedback_settings';

  /// Get feedback settings from Hive
  Future<FeedbackSettings?> getSettings() async {
    final box = await Hive.openBox<FeedbackSettingsModel>(_boxName);
    final model = box.get(_key);
    return model?.toEntity();
  }

  /// Save feedback settings to Hive
  Future<void> saveSettings(FeedbackSettings settings) async {
    final box = await Hive.openBox<FeedbackSettingsModel>(_boxName);
    final model = FeedbackSettingsModel.fromEntity(settings);
    await box.put(_key, model);
  }

  /// Delete settings (reset to defaults)
  Future<void> deleteSettings() async {
    final box = await Hive.openBox<FeedbackSettingsModel>(_boxName);
    await box.delete(_key);
  }
}
