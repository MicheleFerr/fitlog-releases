import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_increment.dart';
import 'package:gymbro_flutter_new/shared/data/datasources/weight_settings_datasource.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// DataSource Provider
final weightSettingsDataSourceProvider = Provider<WeightSettingsDataSource>((ref) {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  return WeightSettingsDataSource(boxManager);
});

/// Weight Settings Provider (AsyncNotifier)
final weightSettingsProvider = AsyncNotifierProvider<WeightSettingsNotifier, WeightSettings>(
  WeightSettingsNotifier.new,
);

class WeightSettingsNotifier extends AsyncNotifier<WeightSettings> {
  @override
  Future<WeightSettings> build() async {
    final dataSource = ref.watch(weightSettingsDataSourceProvider);
    final unit = ref.watch(measurementUnitProvider);

    final settings = await dataSource.getSettings();

    if (settings == null) {
      // First time: use defaults based on unit
      final defaultSettings = unit == 'kg'
          ? WeightSettings.defaultKg()
          : WeightSettings.defaultLbs();

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

  /// Update default increment
  Future<void> updateDefaultIncrement(double value) async {
    final currentState = state.value;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      defaultIncrement: WeightIncrement(value),
    );

    await _saveSettings(updated);
  }

  /// Update custom increment
  Future<void> updateCustomIncrement(double value) async {
    final currentState = state.value;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      customIncrement: WeightIncrement(value),
    );

    await _saveSettings(updated);
  }

  /// Toggle use custom increment
  Future<void> toggleUseCustom() async {
    final currentState = state.value;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      useCustomIncrement: !currentState.useCustomIncrement,
    );

    await _saveSettings(updated);
  }

  /// Update available plates
  Future<void> updateAvailablePlates(List<PlateOption> plates) async {
    final currentState = state.value;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      availablePlates: plates,
    );

    await _saveSettings(updated);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    final unit = ref.read(measurementUnitProvider);
    final defaultSettings = unit == 'kg'
        ? WeightSettings.defaultKg()
        : WeightSettings.defaultLbs();

    await _saveSettings(defaultSettings);
  }

  /// Save settings (local Hive + optional Firebase sync)
  Future<void> _saveSettings(WeightSettings settings) async {
    final dataSource = ref.read(weightSettingsDataSourceProvider);

    try {
      // 1. Save to Hive (instant, local-first)
      await dataSource.saveSettings(settings);

      // 2. Update state
      state = AsyncValue.data(settings);

      // 3. TODO: Firebase sync in background (if premium)
      // _syncToFirebaseInBackground(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
