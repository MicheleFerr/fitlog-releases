/// Set Display Settings Provider
///
/// Manages user preference for set row display size (compact vs comfortable).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Display mode for set rows
enum SetDisplayMode {
  /// Compact mode - smaller padding, tighter layout
  compact,

  /// Comfortable mode (default) - larger padding, more spacious
  comfortable,
}

/// Extension to get display values
extension SetDisplayModeExtension on SetDisplayMode {
  /// Vertical padding for the set row
  double get verticalPadding => switch (this) {
    SetDisplayMode.compact => 6.0,
    SetDisplayMode.comfortable => 12.0,
  };

  /// Horizontal padding for the set row
  double get horizontalPadding => switch (this) {
    SetDisplayMode.compact => 8.0,
    SetDisplayMode.comfortable => 12.0,
  };

  /// Bottom margin between sets
  double get bottomMargin => switch (this) {
    SetDisplayMode.compact => 4.0,
    SetDisplayMode.comfortable => 8.0,
  };

  /// Set number circle size
  double get circleSize => switch (this) {
    SetDisplayMode.compact => 22.0,
    SetDisplayMode.comfortable => 28.0,
  };

  /// Border radius
  double get borderRadius => switch (this) {
    SetDisplayMode.compact => 8.0,
    SetDisplayMode.comfortable => 12.0,
  };

  /// Icon for the settings UI
  String get icon => switch (this) {
    SetDisplayMode.compact => '📦',
    SetDisplayMode.comfortable => '📐',
  };

  /// Label for settings
  String get label => switch (this) {
    SetDisplayMode.compact => 'Compatto',
    SetDisplayMode.comfortable => 'Comodo',
  };
}

/// Notifier for set display mode
class SetDisplayNotifier extends Notifier<SetDisplayMode> {
  // Cache key for persistence
  String get _prefsKey => userCacheKeys.userScopedKey('set_display_mode');

  @override
  SetDisplayMode build() {
    _loadPreference();
    return SetDisplayMode.comfortable; // Default
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_prefsKey);

    if (modeIndex != null && modeIndex < SetDisplayMode.values.length) {
      state = SetDisplayMode.values[modeIndex];
    }
  }

  Future<void> setMode(SetDisplayMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, mode.index);
  }

  void toggleMode() {
    final nextIndex = (state.index + 1) % SetDisplayMode.values.length;
    setMode(SetDisplayMode.values[nextIndex]);
  }
}

/// Provider for set display mode
final setDisplayProvider = NotifierProvider<SetDisplayNotifier, SetDisplayMode>(
  SetDisplayNotifier.new,
);
