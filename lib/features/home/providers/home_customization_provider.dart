import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';

/// Provider per gestire la personalizzazione della home screen
final homeCustomizationProvider = NotifierProvider<HomeCustomizationNotifier, List<HomeWidgetConfig>>(HomeCustomizationNotifier.new);

/// Provider per lo stato di editing
final isHomeEditingProvider = StateProvider<bool>((ref) => false);

class HomeCustomizationNotifier extends Notifier<List<HomeWidgetConfig>> {
  Ref get _ref => ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  List<HomeWidgetConfig> build() {
    _loadUserConfiguration();
    return DefaultHomeWidgets.defaultWidgets;
  }

  /// Carica la configurazione personalizzata dell'utente
  Future<void> _loadUserConfiguration() async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) {
        state = DefaultHomeWidgets.defaultWidgets;
        return;
      }
      
      final doc = await _firestore
          .collection('user_preferences')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['homeWidgets'] != null) {
          final widgetsList = data['homeWidgets'] as List<dynamic>;
          // Safe Map casting with validation (Task 6.1)
          final configs = widgetsList
              .whereType<Map<String, dynamic>>()
              .map((json) => HomeWidgetConfig.fromJson(json))
              .toList();

          // Merge with defaults to include any new widgets
          state = _mergeWithDefaults(configs);
        } else {
          state = DefaultHomeWidgets.defaultWidgets;
        }
      } else {
        state = DefaultHomeWidgets.defaultWidgets;
      }
    } catch (e) {
      // In case of error, use defaults
      state = DefaultHomeWidgets.defaultWidgets;
    }
  }
  
  /// Merge user config with defaults to include new widgets
  List<HomeWidgetConfig> _mergeWithDefaults(List<HomeWidgetConfig> userConfigs) {
    const defaults = DefaultHomeWidgets.defaultWidgets;
    final merged = <HomeWidgetConfig>[];

    // Add all user configs
    merged.addAll(userConfigs);

    // Add any new default widgets that aren't in user config
    for (final defaultWidget in defaults) {
      if (!userConfigs.any((w) => w.id == defaultWidget.id)) {
        // New widget - preserve default visibility (not always hidden)
        merged.add(defaultWidget.copyWith(
          order: merged.length,
          // Use defaultWidget.isVisible instead of always hiding
        ));
      }
    }

    return merged;
  }
  
  /// Salva la configurazione su Firebase
  Future<void> _saveConfiguration() async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) return;
      
      await _firestore
          .collection('user_preferences')
          .doc(user.uid)
          .set({
            'homeWidgets': state.map((w) => w.toJson()).toList(),
            'lastModified': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      // Handle error silently
    }
  }
  
  /// Riordina i widget
  void reorderWidgets(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final widgets = [...state];
    final widget = widgets.removeAt(oldIndex);
    widgets.insert(newIndex, widget);
    
    // Update order values
    for (int i = 0; i < widgets.length; i++) {
      widgets[i] = widgets[i].copyWith(order: i);
    }
    
    state = widgets;
    _saveConfiguration();
  }
  
  /// Toggle visibilità widget
  void toggleWidgetVisibility(String widgetId) {
    state = state.map((widget) {
      if (widget.id == widgetId && !widget.isRequired) {
        return widget.copyWith(isVisible: !widget.isVisible);
      }
      return widget;
    }).toList();
    
    _saveConfiguration();
  }
  
  /// Cambia dimensione widget
  void changeWidgetSize(String widgetId, WidgetSize size) {
    state = state.map((widget) {
      if (widget.id == widgetId) {
        return widget.copyWith(size: size);
      }
      return widget;
    }).toList();
    
    _saveConfiguration();
  }
  
  /// Aggiorna impostazioni widget
  void updateWidgetSettings(String widgetId, Map<String, dynamic> settings) {
    state = state.map((widget) {
      if (widget.id == widgetId) {
        return widget.copyWith(settings: settings);
      }
      return widget;
    }).toList();
    
    _saveConfiguration();
  }
  
  /// Reset to defaults
  void resetToDefaults() {
    state = DefaultHomeWidgets.defaultWidgets;
    _saveConfiguration();
  }
  
  /// Get visible widgets sorted by order
  List<HomeWidgetConfig> get visibleWidgets {
    return state
        .where((w) => w.isVisible)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
  
  /// Get hidden widgets for the catalog
  List<HomeWidgetConfig> get hiddenWidgets {
    return state
        .where((w) => !w.isVisible && !w.isRequired)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }
}