import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/timer_position.dart';

/// Provider per le impostazioni del timer
final timerDisplaySettingsProvider = StateNotifierProvider<TimerSettingsNotifier, TimerDisplaySettingsExtended>(
  (ref) => TimerSettingsNotifier(),
);

/// Stato esteso con posizione libera
class TimerDisplaySettingsExtended {
  final TimerDisplayMode displayMode;
  final bool isVisible;
  final Offset position;

  const TimerDisplaySettingsExtended({
    this.displayMode = TimerDisplayMode.normal,
    this.isVisible = true,
    this.position = const Offset(20, 100),
  });

  TimerDisplaySettingsExtended copyWith({
    TimerDisplayMode? displayMode,
    bool? isVisible,
    Offset? position,
  }) {
    return TimerDisplaySettingsExtended(
      displayMode: displayMode ?? this.displayMode,
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
    );
  }
}

/// Notifier per gestire le impostazioni del timer con posizione libera
class TimerSettingsNotifier extends StateNotifier<TimerDisplaySettingsExtended> {
  TimerSettingsNotifier() : super(const TimerDisplaySettingsExtended()) {
    _loadSettings();
  }

  static const String _settingsKey = 'timer_settings_v2';

  /// Aggiorna la posizione del timer (trascinamento libero)
  Future<void> updatePosition(Offset newPosition) async {
    state = state.copyWith(position: newPosition);
    await _saveSettings();
  }

  /// Cambia la modalità di visualizzazione
  Future<void> changeDisplayMode(TimerDisplayMode displayMode) async {
    state = state.copyWith(displayMode: displayMode);
    await _saveSettings();
  }

  /// Toggle della modalità compatta
  Future<void> toggleCompactMode() async {
    final newMode = state.displayMode == TimerDisplayMode.compact
        ? TimerDisplayMode.normal
        : TimerDisplayMode.compact;
    await changeDisplayMode(newMode);
  }

  /// Toggle della visibilità del timer
  Future<void> toggleVisibility() async {
    state = state.copyWith(isVisible: !state.isVisible);
    await _saveSettings();
  }

  /// Nasconde il timer
  Future<void> hideTimer() async {
    state = state.copyWith(isVisible: false);
    await _saveSettings();
  }

  /// Mostra il timer
  Future<void> showTimer() async {
    state = state.copyWith(isVisible: true);
    await _saveSettings();
  }

  /// Carica le impostazioni salvate
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final parts = settingsJson.split(',');
        if (parts.length >= 4) {
          final displayMode = TimerDisplayMode.values.firstWhere(
            (e) => e.name == parts[0],
            orElse: () => TimerDisplayMode.normal,
          );
          final isVisible = parts[1] == 'true';
          final x = double.tryParse(parts[2]) ?? 20.0;
          final y = double.tryParse(parts[3]) ?? 100.0;
          
          state = TimerDisplaySettingsExtended(
            displayMode: displayMode,
            isVisible: isVisible,
            position: Offset(x, y),
          );
        }
      }
    } catch (e) {
      // In caso di errore, usa impostazioni di default
      state = const TimerDisplaySettingsExtended();
    }
  }

  /// Salva le impostazioni
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = '${state.displayMode.name},${state.isVisible},${state.position.dx},${state.position.dy}';
      await prefs.setString(_settingsKey, settingsString);
    } catch (e) {
      // Ignora errori di salvataggio
    }
  }
}

/// Provider computed per verificare se il timer è in modalità compatta
final isCompactModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(timerDisplaySettingsProvider);
  return settings.displayMode == TimerDisplayMode.compact;
});

/// Provider computed per verificare se il timer è visibile
final isTimerVisibleProvider = Provider<bool>((ref) {
  final settings = ref.watch(timerDisplaySettingsProvider);
  return settings.isVisible;
});

/// Provider computed per ottenere la posizione corrente come Offset
final currentTimerOffsetProvider = Provider<Offset>((ref) {
  final settings = ref.watch(timerDisplaySettingsProvider);
  return settings.position;
});