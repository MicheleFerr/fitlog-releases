import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/providers/shared_preferences_provider.dart';

enum ProgressWidgetLayout {
  full,      // Vista completa con grafici
  compact,   // Vista compatta con statistiche essenziali
  minimal,   // Solo badge livello e XP
}

class ProgressWidgetPreferences {
  
  ProgressWidgetPreferences({
    this.layout = ProgressWidgetLayout.full,
    Set<String>? visibleMetrics,
  }) : visibleMetrics = visibleMetrics ?? defaultMetrics;
  final ProgressWidgetLayout layout;
  final Set<String> visibleMetrics;
  
  static const Set<String> defaultMetrics = {
    'totalWorkouts',
    'monthlyWorkouts',
    'currentStreak',
    'weeklyVolume',
    'weekdayDistribution',
  };
  
  ProgressWidgetPreferences copyWith({
    ProgressWidgetLayout? layout,
    Set<String>? visibleMetrics,
  }) {
    return ProgressWidgetPreferences(
      layout: layout ?? this.layout,
      visibleMetrics: visibleMetrics ?? this.visibleMetrics,
    );
  }
}

class ProgressWidgetPreferencesNotifier extends Notifier<ProgressWidgetPreferences> {
  late final SharedPreferences _prefs;

  @override
  ProgressWidgetPreferences build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    _loadPreferences();
    return ProgressWidgetPreferences();
  }
  static const String _layoutKey = 'progress_widget_layout';
  static const String _metricsKey = 'progress_widget_metrics';
  
  void _loadPreferences() {
    final layoutIndex = _prefs.getInt(_layoutKey) ?? 0;
    final metricsJson = _prefs.getStringList(_metricsKey);
    
    state = ProgressWidgetPreferences(
      layout: ProgressWidgetLayout.values[layoutIndex],
      visibleMetrics: metricsJson?.toSet() ?? ProgressWidgetPreferences.defaultMetrics,
    );
  }
  
  Future<void> setLayout(ProgressWidgetLayout layout) async {
    state = state.copyWith(layout: layout);
    await _prefs.setInt(_layoutKey, layout.index);
  }
  
  Future<void> toggleMetric(String metric) async {
    final newMetrics = Set<String>.from(state.visibleMetrics);
    if (newMetrics.contains(metric)) {
      newMetrics.remove(metric);
    } else {
      newMetrics.add(metric);
    }
    
    state = state.copyWith(visibleMetrics: newMetrics);
    await _prefs.setStringList(_metricsKey, newMetrics.toList());
  }
  
  Future<void> setVisibleMetrics(Set<String> metrics) async {
    state = state.copyWith(visibleMetrics: metrics);
    await _prefs.setStringList(_metricsKey, metrics.toList());
  }
  
  Future<void> resetToDefaults() async {
    state = ProgressWidgetPreferences();
    await _prefs.remove(_layoutKey);
    await _prefs.remove(_metricsKey);
  }
}

final progressWidgetPreferencesProvider = NotifierProvider<ProgressWidgetPreferencesNotifier, ProgressWidgetPreferences>(ProgressWidgetPreferencesNotifier.new);