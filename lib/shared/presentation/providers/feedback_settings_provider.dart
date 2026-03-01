import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/data/datasources/feedback_settings_datasource.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// DataSource Provider
final feedbackSettingsDataSourceProvider = Provider<FeedbackSettingsDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return FeedbackSettingsDataSource(boxManager);
});

/// Feedback Settings Provider (AsyncNotifier)
final feedbackSettingsProvider = AsyncNotifierProvider<FeedbackSettingsNotifier, FeedbackSettings>(
  FeedbackSettingsNotifier.new,
);

class FeedbackSettingsNotifier extends AsyncNotifier<FeedbackSettings> {
  @override
  Future<FeedbackSettings> build() async {
    final dataSource = ref.watch(feedbackSettingsDataSourceProvider);

    final settings = await dataSource.getSettings();

    if (settings == null) {
      // First time: use defaults
      final defaultSettings = FeedbackSettings.defaults();
      await dataSource.saveSettings(defaultSettings);
      return defaultSettings;
    }

    return settings;
  }

  /// Refresh settings from data source
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Toggle haptic feedback on/off
  Future<void> toggleHaptic() async {
    final currentState = state.value;
    if (currentState == null) return;
    final updated = currentState.copyWith(
      hapticEnabled: !currentState.hapticEnabled,
    );
    await _saveSettings(updated);
  }

  /// Update haptic intensity
  Future<void> updateHapticIntensity(HapticIntensity intensity) async {
    final currentState = state.value;
    if (currentState == null) return;
    final updated = currentState.copyWith(
      hapticIntensity: intensity,
    );
    await _saveSettings(updated);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    final defaultSettings = FeedbackSettings.defaults();
    await _saveSettings(defaultSettings);
  }

  /// Save settings (local Hive)
  Future<void> _saveSettings(FeedbackSettings settings) async {
    final dataSource = ref.read(feedbackSettingsDataSourceProvider);

    try {
      // 1. Save to Hive (instant, local-first)
      await dataSource.saveSettings(settings);

      // 2. Update state
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
