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

/// Weight Settings Provider (StateNotifier)
final weightSettingsProvider = StateNotifierProvider<WeightSettingsNotifier, AsyncValue<WeightSettings>>((ref) {
  final dataSource = ref.watch(weightSettingsDataSourceProvider);
  final unit = ref.watch(measurementUnitProvider);
  return WeightSettingsNotifier(dataSource, unit);
});

class WeightSettingsNotifier extends StateNotifier<AsyncValue<WeightSettings>> {
  WeightSettingsNotifier(this._dataSource, this._unit) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  final WeightSettingsDataSource _dataSource;
  final String _unit; // 'kg' or 'lbs'

  /// Load settings from Hive
  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();

    try {
      final settings = await _dataSource.getSettings();

      if (settings == null) {
        // First time: use defaults based on unit
        final defaultSettings = _unit == 'kg'
            ? WeightSettings.defaultKg()
            : WeightSettings.defaultLbs();

        await _dataSource.saveSettings(defaultSettings);
        state = AsyncValue.data(defaultSettings);
      } else {
        state = AsyncValue.data(settings);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update default increment
  Future<void> updateDefaultIncrement(double value) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      defaultIncrement: WeightIncrement(value),
    );

    await _saveSettings(updated);
  }

  /// Update custom increment
  Future<void> updateCustomIncrement(double value) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      customIncrement: WeightIncrement(value),
    );

    await _saveSettings(updated);
  }

  /// Toggle use custom increment
  Future<void> toggleUseCustom() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      useCustomIncrement: !currentState.useCustomIncrement,
    );

    await _saveSettings(updated);
  }

  /// Update available plates
  Future<void> updateAvailablePlates(List<PlateOption> plates) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updated = currentState.copyWith(
      availablePlates: plates,
    );

    await _saveSettings(updated);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    final defaultSettings = _unit == 'kg'
        ? WeightSettings.defaultKg()
        : WeightSettings.defaultLbs();

    await _saveSettings(defaultSettings);
  }

  /// Save settings (local Hive + optional Firebase sync)
  Future<void> _saveSettings(WeightSettings settings) async {
    try {
      // 1. Save to Hive (instant, local-first)
      await _dataSource.saveSettings(settings);

      // 2. Update state
      state = AsyncValue.data(settings);

      // 3. TODO: Firebase sync in background (if premium)
      // _syncToFirebaseInBackground(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
