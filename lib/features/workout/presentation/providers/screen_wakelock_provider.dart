import 'dart:async' show unawaited;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Provider per gestire lo stato dello schermo always on durante l'allenamento
final screenWakelockProvider =
    NotifierProvider<ScreenWakelockNotifier, ScreenWakelockState>(
      ScreenWakelockNotifier.new,
    );

class ScreenWakelockState {
  const ScreenWakelockState({required this.isEnabled, required this.isActive});
  final bool isEnabled;
  final bool isActive;

  ScreenWakelockState copyWith({bool? isEnabled, bool? isActive}) {
    return ScreenWakelockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ScreenWakelockNotifier extends Notifier<ScreenWakelockState> {
  @override
  ScreenWakelockState build() {
    _loadPreference();

    // Set up cleanup on dispose
    ref.onDispose(() {
      // CRITICAL: Ensure wakelock is disabled even if dispose is synchronous
      // Using unawaited to explicitly mark that we don't await the Future
      if (state.isActive) {
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

    return const ScreenWakelockState(isEnabled: false, isActive: false);
  }

  // 🔐 User-scoped cache key
  String get _prefsKey =>
      userCacheKeys.userScopedKey('workout_screen_always_on');

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefsKey) ?? false;
    state = state.copyWith(isEnabled: isEnabled);
  }

  Future<void> toggleEnabled() async {
    final newValue = !state.isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, newValue);

    state = state.copyWith(isEnabled: newValue);

    // Se disabilitato e attualmente attivo, disattiva wakelock
    if (!newValue && state.isActive) {
      await stopWakelock();
    }
  }

  Future<void> startWakelock() async {
    if (state.isEnabled) {
      try {
        await WakelockPlus.enable();
        state = state.copyWith(isActive: true);
      } catch (e) {
        // Log error but don't crash the app
        debugPrint('⚠️ [Wakelock] Error enabling wakelock: $e');
      }
    }
  }

  Future<void> stopWakelock() async {
    try {
      await WakelockPlus.disable();
      state = state.copyWith(isActive: false);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('⚠️ [Wakelock] Error disabling wakelock: $e');
    }
  }
}
