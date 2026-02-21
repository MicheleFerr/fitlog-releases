import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// State for the TUT metronome feature.
///
/// Tracks whether the metronome is running, the elapsed seconds (received from
/// the native iOS side via [MetronomeNotifier.updateFromNative]), and which
/// exercise/set it is currently associated with.
class MetronomeState {
  const MetronomeState({
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.exerciseId,
    this.setNumber,
  });

  final bool isRunning;
  final int elapsedSeconds;
  final String? exerciseId;
  final int? setNumber;

  MetronomeState copyWith({
    bool? isRunning,
    int? elapsedSeconds,
    String? exerciseId,
    int? setNumber,
  }) {
    return MetronomeState(
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
    );
  }

  @override
  String toString() =>
      'MetronomeState(isRunning: $isRunning, elapsedSeconds: $elapsedSeconds, '
      'exerciseId: $exerciseId, setNumber: $setNumber)';
}

/// Riverpod 3.x [Notifier] that manages the TUT metronome lifecycle.
///
/// Platform behaviour:
/// - iOS  : delegates to native via [PlatformChannels.unified]
///           (`startMetronome` / `stopMetronome`).  Tick events come back
///           through [updateFromNative] which is called by the
///           `metronomeTick` branch in `unified_timer_provider.dart`.
/// - Android: falls back to a Dart [Timer.periodic] with [AudioPlayer]
///            (tick sound) and [HapticFeedback] (vibration).
class MetronomeNotifier extends Notifier<MetronomeState> {
  static const _channel = MethodChannel(PlatformChannels.unified);

  // Android-only resources — null on iOS.
  Timer? _androidTimer;
  AudioPlayer? _androidPlayer;

  @override
  MetronomeState build() {
    ref.onDispose(_cleanupAndroidResources);
    return const MetronomeState();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Start the metronome for the given [exerciseId] and [setNumber].
  ///
  /// Safe to call even if the metronome is already running — the previous
  /// session is stopped first.
  Future<void> start(String exerciseId, int setNumber) async {
    // Stop any previous session cleanly.
    await stop();

    final config = ref.read(appConfigProvider);
    final soundEnabled = config.soundEnabled;
    final hapticEnabled = config.vibrationsEnabled;

    state = MetronomeState(
      isRunning: true,
      elapsedSeconds: 0,
      exerciseId: exerciseId,
      setNumber: setNumber,
    );

    if (Platform.isIOS) {
      await _startIOS(soundEnabled: soundEnabled, hapticEnabled: hapticEnabled);
    } else {
      _startAndroid(soundEnabled: soundEnabled, hapticEnabled: hapticEnabled);
    }

    if (kDebugMode) {
      debugPrint(
        '[Metronome] Started — exercise: $exerciseId, set: $setNumber, '
        'sound: $soundEnabled, haptic: $hapticEnabled',
      );
    }
  }

  /// Stop the metronome and return the total elapsed seconds.
  Future<int> stop() async {
    if (!state.isRunning) return state.elapsedSeconds;

    int elapsed = state.elapsedSeconds;

    if (Platform.isIOS) {
      elapsed = await _stopIOS() ?? elapsed;
    } else {
      _cleanupAndroidResources();
    }

    state = state.copyWith(isRunning: false, elapsedSeconds: elapsed);

    if (kDebugMode) {
      debugPrint('[Metronome] Stopped — elapsed: ${elapsed}s');
    }

    return elapsed;
  }

  /// Called by [unified_timer_provider.dart] when the native iOS side sends
  /// a `metronomeTick` method call with the current elapsed seconds.
  void updateFromNative(int seconds) {
    if (!state.isRunning) return;
    state = state.copyWith(elapsedSeconds: seconds);
  }

  /// Returns true when the metronome is active for the given set identity.
  bool isRunningForSet(String exerciseId, int setNumber) {
    return state.isRunning &&
        state.exerciseId == exerciseId &&
        state.setNumber == setNumber;
  }

  // ---------------------------------------------------------------------------
  // iOS helpers
  // ---------------------------------------------------------------------------

  Future<void> _startIOS({
    required bool soundEnabled,
    required bool hapticEnabled,
  }) async {
    try {
      await _channel.invokeMethod<void>(
        'startMetronome',
        {
          'soundEnabled': soundEnabled,
          'hapticEnabled': hapticEnabled,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Metronome] iOS startMetronome error: $e');
      }
    }
  }

  /// Returns elapsed seconds reported by native, or null on error.
  Future<int?> _stopIOS() async {
    try {
      final result = await _channel.invokeMethod<int>('stopMetronome');
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Metronome] iOS stopMetronome error: $e');
      }
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Android helpers
  // ---------------------------------------------------------------------------

  void _startAndroid({
    required bool soundEnabled,
    required bool hapticEnabled,
  }) {
    _androidTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newElapsed = state.elapsedSeconds + 1;
      state = state.copyWith(elapsedSeconds: newElapsed);

      if (soundEnabled) {
        _playTickSound();
      }
      if (hapticEnabled) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  Future<void> _playTickSound() async {
    try {
      _androidPlayer ??= AudioPlayer();
      await _androidPlayer!.play(AssetSource('sounds/metronome_tick.wav'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Metronome] Android tick sound error: $e');
      }
    }
  }

  void _cleanupAndroidResources() {
    _androidTimer?.cancel();
    _androidTimer = null;
    _androidPlayer?.dispose();
    _androidPlayer = null;
  }
}

final metronomeProvider =
    NotifierProvider<MetronomeNotifier, MetronomeState>(MetronomeNotifier.new);
