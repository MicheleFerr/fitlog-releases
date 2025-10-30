import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/data/datasources/feedback_settings_datasource.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// DataSource Provider
final feedbackSettingsDataSourceProvider = Provider<FeedbackSettingsDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return FeedbackSettingsDataSource(boxManager);
});

/// Feedback Settings Provider (StateNotifier)
final feedbackSettingsProvider = StateNotifierProvider<FeedbackSettingsNotifier, AsyncValue<FeedbackSettings>>((ref) {
  final dataSource = ref.watch(feedbackSettingsDataSourceProvider);
  return FeedbackSettingsNotifier(dataSource);
});

class FeedbackSettingsNotifier extends StateNotifier<AsyncValue<FeedbackSettings>> {
  FeedbackSettingsNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  final FeedbackSettingsDataSource _dataSource;

  /// Load settings from Hive
  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();

    try {
      final settings = await _dataSource.getSettings();

      if (settings == null) {
        // First time: use defaults
        final defaultSettings = FeedbackSettings.defaults();
        await _dataSource.saveSettings(defaultSettings);
        state = AsyncValue.data(defaultSettings);
      } else {
        state = AsyncValue.data(settings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle haptic feedback on/off
  Future<void> toggleHaptic() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      hapticEnabled: !currentState.hapticEnabled,
    );

    await _saveSettings(updated);
  }

  /// Update haptic intensity
  Future<void> updateHapticIntensity(HapticIntensity intensity) async {
    final currentState = state.valueOrNull;
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
    try {
      // 1. Save to Hive (instant, local-first)
      await _dataSource.saveSettings(settings);

      // 2. Update state
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
