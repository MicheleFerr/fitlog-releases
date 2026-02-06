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
  @override
  bool build() {
    // Set up cleanup on dispose
    ref.onDispose(() {
      // CRITICAL: Ensure wakelock is disabled even if dispose is synchronous
      // Using unawaited to explicitly mark that we don't await the Future
      if (state) {
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
      }
    });

    // Initial state: wakelock not active
    return false;
  }

  /// Attiva il wakelock se l'impostazione in AppConfig è abilitata.
  Future<void> startWakelock() async {
    // Leggi l'impostazione da AppConfig (fonte di verità unica)
    final isEnabled = ref.read(keepScreenAwakeProvider);

    if (isEnabled) {
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
    } else {
      if (kDebugMode) {
        debugPrint('ℹ️ [Wakelock] Wakelock not enabled (disabled in settings)');
      }
    }
  }

  /// Disattiva il wakelock.
  Future<void> stopWakelock() async {
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
