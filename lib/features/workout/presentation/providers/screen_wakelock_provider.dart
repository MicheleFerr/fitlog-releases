import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Provider per gestire lo stato dello schermo always on durante l'allenamento
///
/// Usa [keepScreenAwakeProvider] (AppConfig) come fonte di verità per l'impostazione.
/// Questo provider gestisce solo l'attivazione/disattivazione effettiva del wakelock.
final screenWakelockProvider =
    NotifierProvider<ScreenWakelockNotifier, bool>(
      ScreenWakelockNotifier.new,
    );

/// Notifier che gestisce il wakelock dello schermo.
///
/// Lo state [bool] indica se il wakelock è attualmente ATTIVO (non se è abilitato).
/// L'impostazione "abilitato" viene letta da [keepScreenAwakeProvider].
class ScreenWakelockNotifier extends Notifier<bool> {
  /// Tracks if we're in a workout context (between startWakelock and stopWakelock calls)
  /// This allows us to enable wakelock when the setting is toggled ON during a workout.
  bool _isInWorkoutContext = false;

  @override
  bool build() {
    // 🔧 FIX: Listen to setting changes and react in real-time
    // This fixes the issue where toggling the setting in global settings
    // has no effect until the next workout starts.
    ref.listen<bool>(keepScreenAwakeProvider, (previous, next) {
      if (previous == next) return; // No change

      if (kDebugMode) {
        debugPrint(
          '🔄 [Wakelock] Setting changed: $previous → $next (inWorkout: $_isInWorkoutContext)',
        );
      }

      // If wakelock is currently active and setting was disabled, turn off
      if (state && !next) {
        _disableWakelockOnly(); // Don't reset workout context
      }
      // If we're in a workout context and setting was enabled, turn on wakelock
      else if (_isInWorkoutContext && !state && next) {
        _enableWakelockOnly(); // Enable without changing workout context
      }
    });

    // Set up cleanup on dispose
    // CRITICAL: We must always disable wakelock on dispose to prevent battery drain.
    // We can't check `state` inside onDispose (Riverpod restriction), so we always
    // call disable() which is safe even if wakelock is not currently enabled.
    ref.onDispose(() {
      unawaited(
        WakelockPlus.disable().catchError((error) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ [Wakelock] Error disabling wakelock in dispose: $error',
            );
          }
          // Don't rethrow - we're in dispose, just log the error
          return null;
        }),
      );
    });

    // Initial state: wakelock not active
    return false;
  }

  /// Attiva il wakelock se l'impostazione in AppConfig è abilitata.
  /// Called when a workout starts.
  Future<void> startWakelock() async {
    _isInWorkoutContext = true; // Mark that we're in a workout

    // Leggi l'impostazione da AppConfig (fonte di verità unica)
    final isEnabled = ref.read(keepScreenAwakeProvider);

    if (isEnabled) {
      await _enableWakelockOnly();
    } else {
      if (kDebugMode) {
        debugPrint('ℹ️ [Wakelock] Wakelock not enabled (disabled in settings)');
      }
    }
  }

  /// Disattiva il wakelock.
  /// Called when a workout ends.
  Future<void> stopWakelock() async {
    _isInWorkoutContext = false; // Mark that we're no longer in a workout
    await _disableWakelockOnly();
  }

  /// Internal: enables wakelock without changing workout context
  Future<void> _enableWakelockOnly() async {
    try {
      await WakelockPlus.enable();
      state = true;
      if (kDebugMode) {
        debugPrint('✅ [Wakelock] Screen wakelock enabled');
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('⚠️ [Wakelock] Error enabling wakelock: $e');
    }
  }

  /// Internal: disables wakelock without changing workout context
  Future<void> _disableWakelockOnly() async {
    try {
      await WakelockPlus.disable();
      state = false;
      if (kDebugMode) {
        debugPrint('✅ [Wakelock] Screen wakelock disabled');
      }
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('⚠️ [Wakelock] Error disabling wakelock: $e');
    }
  }
}
