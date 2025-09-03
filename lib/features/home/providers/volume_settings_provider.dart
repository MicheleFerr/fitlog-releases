import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';

enum WeightUnit {
  kg,
  lbs,
}

enum VolumePeriod {
  week,     // Ultima settimana
  month,    // Ultimo mese  
  year,     // Ultimo anno
  allTime,  // Tutto il tempo
}

class VolumeSettings {
  final WeightUnit unit;
  final VolumePeriod period;
  
  VolumeSettings({
    this.unit = WeightUnit.kg,
    this.period = VolumePeriod.week,
  });
  
  VolumeSettings copyWith({
    WeightUnit? unit,
    VolumePeriod? period,
  }) {
    return VolumeSettings(
      unit: unit ?? this.unit,
      period: period ?? this.period,
    );
  }
  
  // Helper per conversione unità
  double convertWeight(double weightInKg) {
    if (unit == WeightUnit.lbs) {
      return weightInKg * 2.20462;
    }
    return weightInKg;
  }
  
  String get unitSymbol => unit == WeightUnit.kg ? 'kg' : 'lbs';
  
  // Helper per ottenere il range di date basato sul periodo
  DateRange getDateRange() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case VolumePeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case VolumePeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case VolumePeriod.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case VolumePeriod.allTime:
        startDate = DateTime(2020); // Data arbitraria nel passato
        break;
    }
    
    return DateRange(start: startDate, end: now);
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange({required this.start, required this.end});
}

class VolumeSettingsNotifier extends StateNotifier<VolumeSettings> {
  final SharedPreferences _prefs;
  static const String _unitKey = 'volume_weight_unit';
  static const String _periodKey = 'volume_period';
  
  VolumeSettingsNotifier(this._prefs) : super(VolumeSettings()) {
    _loadSettings();
  }
  
  void _loadSettings() {
    final unitIndex = _prefs.getInt(_unitKey) ?? 0;
    final periodIndex = _prefs.getInt(_periodKey) ?? 0;
    
    state = VolumeSettings(
      unit: WeightUnit.values[unitIndex],
      period: VolumePeriod.values[periodIndex],
    );
  }
  
  Future<void> setUnit(WeightUnit unit) async {
    state = state.copyWith(unit: unit);
    await _prefs.setInt(_unitKey, unit.index);
  }
  
  Future<void> setPeriod(VolumePeriod period) async {
    state = state.copyWith(period: period);
    await _prefs.setInt(_periodKey, period.index);
  }
  
  Future<void> resetToDefaults() async {
    state = VolumeSettings();
    await _prefs.remove(_unitKey);
    await _prefs.remove(_periodKey);
  }
}

final volumeSettingsProvider = StateNotifierProvider<VolumeSettingsNotifier, VolumeSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return VolumeSettingsNotifier(prefs);
});