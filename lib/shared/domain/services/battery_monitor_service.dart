/// 🔋 Battery Monitor Service
///
/// Monitora stato batteria e adatta comportamento app per ottimizzare consumo.
///
/// Features:
/// - Rileva livello batteria
/// - Modalità risparmio energetico
/// - Riduzione frequenza sync in background
/// - Disabilitazione feature pesanti quando batteria bassa
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Aggiungi a pubspec.yaml: battery_plus: ^5.0.0

class BatteryMonitorService {
  // Battery thresholds
  static const int _lowBatteryThreshold = 20;
  static const int _criticalBatteryThreshold = 10;

  // Current state
  int? _currentLevel;
  final bool _isCharging = false;
  bool _powerSaveMode = false;

  /// Initialize monitoring
  Future<void> initialize() async {
    try {
      // TODO: Implementa con battery_plus
      // final battery = Battery();
      // _currentLevel = await battery.batteryLevel;
      // _isCharging = await battery.batteryState == BatteryState.charging;

      // Listen for changes
      // battery.onBatteryStateChanged.listen(_handleBatteryChange);

      _updatePowerSaveMode();
      debugPrint('🔋 Battery Monitor initialized: $_currentLevel%');

    } catch (e) {
      debugPrint('⚠️ Battery monitoring not available: $e');
    }
  }

  /// Check if app should reduce background activity
  bool get shouldReduceBackgroundActivity {
    if (_isCharging) return false;
    if (_currentLevel == null) return false;
    return _currentLevel! < _lowBatteryThreshold;
  }

  /// Check if app should enter critical power save mode
  bool get isCriticalBattery {
    if (_isCharging) return false;
    if (_currentLevel == null) return false;
    return _currentLevel! < _criticalBatteryThreshold;
  }

  /// Get recommended sync interval based on battery
  Duration getRecommendedSyncInterval() {
    if (_isCharging) {
      return const Duration(minutes: 5); // Sync frequente
    }

    if (isCriticalBattery) {
      return const Duration(hours: 1); // Sync molto ridotto
    }

    if (shouldReduceBackgroundActivity) {
      return const Duration(minutes: 30); // Sync moderato
    }

    return const Duration(minutes: 15); // Sync normale
  }

  /// Check if feature should be disabled for battery saving
  bool shouldDisableFeature(PowerHungryFeature feature) {
    if (!_powerSaveMode) return false;

    switch (feature) {
      case PowerHungryFeature.liveActivities:
        return isCriticalBattery; // Disabilita solo se critico
      case PowerHungryFeature.backgroundSync:
        return shouldReduceBackgroundActivity;
      case PowerHungryFeature.animations:
        return isCriticalBattery;
      case PowerHungryFeature.autoRefresh:
        return shouldReduceBackgroundActivity;
    }
  }

  void _updatePowerSaveMode() {
    _powerSaveMode = shouldReduceBackgroundActivity;
    if (_powerSaveMode) {
      debugPrint('🔋 Power save mode ENABLED ($_currentLevel%)');
    }
  }

  void _handleBatteryChange(dynamic state) {
    // TODO: Handle battery state changes
    _updatePowerSaveMode();
  }
}

enum PowerHungryFeature {
  liveActivities,
  backgroundSync,
  animations,
  autoRefresh,
}

/// Provider
final batteryMonitorServiceProvider = Provider<BatteryMonitorService>((ref) {
  final service = BatteryMonitorService();
  service.initialize();
  return service;
});
