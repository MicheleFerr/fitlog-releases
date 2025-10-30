/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/timer/presentation/providers
/// 🎯 Feature: Timer Provider (STUB - Temporarily disabled)
/// 🔧 Type: Riverpod Provider
///
/// Temporary stub to prevent compilation errors
/// TODO: Re-implement timer system properly
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/session_timeout_service.dart';

/// Stub timer controller with startTimer method
class TimerController extends StateNotifier<TimerState?> {
  TimerController() : super(null);

  /// Start timer with given duration
  void startTimer({
    required int durationSeconds,
    String? exerciseName,
    int? currentSet,
    int? totalSets,
    String? exerciseId,
  }) {
    // Stub implementation - just set a basic state
    state = TimerState(
      remainingSeconds: durationSeconds,
      isRunning: true,
    );
  }

  /// Stop timer
  void stopTimer() {
    state = null;
  }

  /// Pause timer
  void pauseTimer() {
    if (state != null) {
      state = TimerState(
        remainingSeconds: state!.remainingSeconds,
        isRunning: false,
      );
    }
  }
}

/// Stub timer provider - timer functionality temporarily disabled
final unifiedTimerProvider = StateNotifierProvider<TimerController, TimerState?>((ref) {
  return TimerController();
});

/// Stub timer v2 provider (for compatibility)
final unifiedTimerV2Provider = StateProvider<TimerState?>((ref) => null);

/// Stub session timeout service provider
final sessionTimeoutServiceProvider = Provider<SessionTimeoutService>((ref) {
  return SessionTimeoutService();
});

/// Stub session timeout events provider
final sessionTimeoutEventsProvider = StreamProvider<SessionTimeoutEvent>((ref) {
  return const Stream.empty();
});

/// Stub timer state - mimics Freezed union behavior
class TimerState {

  TimerState({
    required this.remainingSeconds,
    required this.isRunning,
  });
  final int remainingSeconds;
  final bool isRunning;

  // Mimics freezed union type whenOrNull
  T? whenOrNull<T>({
    T Function(TimerState state)? data,
    T Function(Object error, StackTrace stackTrace)? error,
    T Function()? loading,
  }) {
    // Default stub behavior - returns data callback if provided
    return data?.call(this);
  }
}

/// Stub session timeout service
/// Real implementation is in shared/domain/auth/session_timeout_service.dart
class SessionTimeoutService {
  void recordActivity() {}
  void pause() {}
  void resume() {}

  /// Handle app going to background
  void handleAppBackground() {}

  /// Handle app coming to foreground
  void handleAppForeground() {}
}
