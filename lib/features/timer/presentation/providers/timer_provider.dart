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

/// Stub timer provider - timer functionality temporarily disabled
final unifiedTimerProvider = StateProvider<TimerState?>((ref) => null);

/// Stub timer v2 provider
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
class SessionTimeoutService {
  void recordActivity() {}
  void pause() {}
  void resume() {}

  /// Handle app going to background
  void handleAppBackground() {}

  /// Handle app coming to foreground
  void handleAppForeground() {}
}

/// Stub session timeout event base class
abstract class SessionTimeoutEvent {
  const SessionTimeoutEvent();

  T when<T>({
    required T Function() warning,
    required T Function() timeout,
  });
}

/// Session warning event (session expiring soon)
class SessionWarningEvent extends SessionTimeoutEvent {
  const SessionWarningEvent({
    required this.remainingSeconds,
  });

  final int remainingSeconds;

  @override
  T when<T>({
    required T Function() warning,
    required T Function() timeout,
  }) {
    return warning();
  }
}

/// Session expired event
class SessionExpiredEvent extends SessionTimeoutEvent {
  const SessionExpiredEvent({
    required this.reason,
  });

  final String reason;

  @override
  T when<T>({
    required T Function() warning,
    required T Function() timeout,
  }) {
    return timeout();
  }
}
