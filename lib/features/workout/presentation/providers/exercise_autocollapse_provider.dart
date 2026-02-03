/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: workout
/// 🔧 Type: provider
/// 📱 Platform: Universal
///
/// Exercise auto-collapse provider
/// Manages automatic collapse with countdown timer
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for exercise auto-collapse
class AutoCollapseState {
  // Signal that collapse should be executed

  const AutoCollapseState({
    this.inProgress = false,
    this.countdown = 0,
    this.enabled = true,
    this.shouldExecuteCollapse = false,
  });
  final bool inProgress;
  final int countdown;
  final bool enabled;
  final bool shouldExecuteCollapse;

  AutoCollapseState copyWith({
    bool? inProgress,
    int? countdown,
    bool? enabled,
    bool? shouldExecuteCollapse,
  }) {
    return AutoCollapseState(
      inProgress: inProgress ?? this.inProgress,
      countdown: countdown ?? this.countdown,
      enabled: enabled ?? this.enabled,
      shouldExecuteCollapse:
          shouldExecuteCollapse ?? this.shouldExecuteCollapse,
    );
  }
}

/* TEMPORARY: Disabled for Riverpod 3.x migration - TODO: Migrate to @riverpod codegen
/// Notifier for managing auto-collapse with countdown
class AutoCollapseNotifier extends AutoDisposeFamilyNotifier<AutoCollapseState, String> {
  Timer? _countdownTimer;
  Timer? _autoCollapseTimer;
  bool _disposed = false;

  @override
  AutoCollapseState build(String exerciseId) {
    // Setup disposal on provider cleanup
    ref.onDispose(() {
      _disposed = true;
      _countdownTimer?.cancel();
      _autoCollapseTimer?.cancel();
    });

    return const AutoCollapseState();
  }

  /// Check if notifier is still active
  bool get mounted => !_disposed;

  /// Start auto-collapse with initial delay + countdown
  /// [initialDelay] - delay before countdown starts
  /// [countdownSeconds] - countdown duration (0 = instant collapse)
  /// [showCountdown] - whether to show countdown UI
  void startAutoCollapse({
    required Duration initialDelay,
    required int countdownSeconds,
    required bool showCountdown,
  }) {
    if (!state.enabled || state.inProgress) return;

    // Cancel any existing timers
    _countdownTimer?.cancel();
    _autoCollapseTimer?.cancel();

    state = state.copyWith(inProgress: true);

    // Initial delay before countdown starts
    _autoCollapseTimer = Timer(initialDelay, () {
      if (!mounted || !state.inProgress) return;

      // If countdown disabled or zero, collapse immediately
      if (!showCountdown || countdownSeconds <= 0) {
        _executeCollapse();
        return;
      }

      // Start countdown
      _startCountdown(countdownSeconds);
    });
  }

  /// Internal countdown logic
  void _startCountdown(int seconds) {
    state = state.copyWith(countdown: seconds);

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Start countdown timer (updates every second)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final newCountdown = state.countdown - 1;

      if (newCountdown <= 0) {
        timer.cancel();
        _executeCollapse();
      } else {
        state = state.copyWith(countdown: newCountdown);
        // Subtle haptic on each second
        HapticFeedback.selectionClick();
      }
    });

    // Safety timer - force collapse after delay
    _autoCollapseTimer = Timer(Duration(seconds: seconds + 1), () {
      if (mounted && state.inProgress) {
        _executeCollapse();
      }
    });
  }

  /// Execute the collapse
  void _executeCollapse() {
    if (!mounted) return;

    // Medium haptic for completion
    HapticFeedback.mediumImpact();

    // Signal that collapse should be executed
    state = state.copyWith(
      inProgress: false,
      countdown: 0,
      shouldExecuteCollapse: true,
    );

    if (kDebugMode) {
      debugPrint('✅ [AutoCollapse] Signaling collapse execution');
    }
  }

  /// Acknowledge collapse execution (reset flag)
  void acknowledgeCollapse() {
    state = state.copyWith(shouldExecuteCollapse: false);
  }

  /// Cancel auto-collapse
  void cancel() {
    _countdownTimer?.cancel();
    _autoCollapseTimer?.cancel();

    state = state.copyWith(inProgress: false, countdown: 0);

    if (kDebugMode) {
      debugPrint('❌ [AutoCollapse] Cancelled');
    }
  }

  /// Disable auto-collapse
  void disable() {
    cancel();
    state = state.copyWith(enabled: false);
  }

  /// Enable auto-collapse
  void enable() {
    state = state.copyWith(enabled: true);
  }
}
*/

/// Provider for exercise auto-collapse state
/// Family provider indexed by exercise ID
/// TEMPORARY: Disabled for Riverpod 3.x migration
/// TODO: Migrate to @riverpod codegen
final exerciseAutoCollapseProvider =
    StateProvider.family.autoDispose<AutoCollapseState, String>(
  (ref, exerciseId) => const AutoCollapseState(),
);
