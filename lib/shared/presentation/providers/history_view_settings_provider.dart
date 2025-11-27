import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/history_view_settings.dart';
import 'package:gymbro_flutter_new/shared/data/datasources/history_view_settings_datasource.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// DataSource Provider
final historyViewSettingsDataSourceProvider = Provider<HistoryViewSettingsDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return HistoryViewSettingsDataSource(boxManager);
});

/// History View Settings Provider (AsyncNotifier)
final historyViewSettingsProvider = AsyncNotifierProvider<HistoryViewSettingsNotifier, HistoryViewSettings>(
  HistoryViewSettingsNotifier.new,
);

class HistoryViewSettingsNotifier extends AsyncNotifier<HistoryViewSettings> {
  @override
  Future<HistoryViewSettings> build() async {
    final dataSource = ref.watch(historyViewSettingsDataSourceProvider);

    final settings = await dataSource.getSettings();

    if (settings == null) {
      // First time: use defaults
      final defaultSettings = HistoryViewSettings.defaults();
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

  /// Change view mode
  Future<void> changeViewMode(HistoryViewMode mode) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(viewMode: mode);
    await _saveSettings(updated);
  }

  /// Toggle thumbnails visibility
  Future<void> toggleThumbnails() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      showThumbnails: !currentState.showThumbnails,
    );
    await _saveSettings(updated);
  }

  /// Toggle duration visibility
  Future<void> toggleDuration() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      showDuration: !currentState.showDuration,
    );
    await _saveSettings(updated);
  }

  /// Toggle exercise count visibility
  Future<void> toggleExerciseCount() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      showExerciseCount: !currentState.showExerciseCount,
    );
    await _saveSettings(updated);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    final defaultSettings = HistoryViewSettings.defaults();
    await _saveSettings(defaultSettings);
  }

  /// Save settings (local Hive)
  Future<void> _saveSettings(HistoryViewSettings settings) async {
    final dataSource = ref.read(historyViewSettingsDataSourceProvider);

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
