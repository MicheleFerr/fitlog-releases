/// 🏋️‍♂️ FitLog Pro - Flutter Fitness App
///
/// 📁 Layer: shared/domain/auth
/// 🎯 Feature: session_management
/// 🔧 Type: service
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// **CRITICAL SECURITY COMPONENT**
/// Auto-logout after inactivity to prevent unauthorized access
/// GDPR/HIPAA compliance for health data protection
///
/// **Configuration:**
/// - Timeout: 30 minutes of inactivity
/// - Warning: 1 minute before logout
/// - Biometric re-auth: For sensitive operations
///
/// **Example:**
/// ```dart
/// final sessionService = SessionTimeoutService(
///   authService: ref.read(authServiceProvider),
///   timeoutDuration: Duration(minutes: 30),
/// );
///
/// sessionService.startMonitoring();
///
/// // On user interaction:
/// sessionService.recordActivity();
/// ```
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing session timeouts and auto-logout
///
/// **Security Benefits:**
/// - Prevents unauthorized access on shared devices
/// - GDPR compliance for data protection
/// - Auto-lock after inactivity
///
/// **User Experience:**
/// - Warning 1 minute before logout
/// - Option to extend session
/// - Seamless biometric re-auth
class SessionTimeoutService {
  SessionTimeoutService({
    required this.authService,
    this.timeoutDuration = const Duration(minutes: 30),
    this.warningDuration = const Duration(minutes: 1),
  });

  final FirebaseAuth authService;
  final Duration timeoutDuration;
  final Duration warningDuration;

  /// Last activity timestamp
  DateTime _lastActivity = DateTime.now();

  /// Is monitoring active?
  bool _isMonitoring = false;

  /// Timer for checking inactivity
  Timer? _inactivityTimer;

  /// Stream controller for session events
  final _eventController = StreamController<SessionEvent>.broadcast();

  /// Stream of session events (timeout warnings, logout)
  Stream<SessionEvent> get events => _eventController.stream;

  /// Start monitoring session timeout
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _lastActivity = DateTime.now();

    // Check every 10 seconds
    _inactivityTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkInactivity(),
    );

    if (kDebugMode) {
      debugPrint('🔒 [SessionTimeout] Monitoring started. Timeout: $timeoutDuration');
    }
  }

  /// Stop monitoring (e.g., when user logs out)
  void stopMonitoring() {
    _isMonitoring = false;
    _inactivityTimer?.cancel();
    _inactivityTimer = null;

    if (kDebugMode) {
      debugPrint('🔒 [SessionTimeout] Monitoring stopped');
    }
  }

  /// Record user activity (reset timer)
  ///
  /// Call this on:
  /// - Screen tap
  /// - Button press
  /// - Workout interaction
  /// - Any user-initiated action
  void recordActivity() {
    if (!_isMonitoring) return;

    _lastActivity = DateTime.now();

    if (kDebugMode) {
      debugPrint('🔒 [SessionTimeout] Activity recorded');
    }
  }

  /// Check if session has timed out
  void _checkInactivity() {
    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivity);

    // Warning threshold (1 minute before timeout)
    final warningThreshold = timeoutDuration - warningDuration;

    if (inactiveDuration >= timeoutDuration) {
      // TIMEOUT! Force logout
      _handleTimeout();
    } else if (inactiveDuration >= warningThreshold) {
      // Warning: About to timeout
      final remainingSeconds = (timeoutDuration - inactiveDuration).inSeconds;
      _eventController.add(
        SessionWarningEvent(
          remainingSeconds: remainingSeconds,
          message: 'Session will expire in $remainingSeconds seconds',
        ),
      );

      if (kDebugMode) {
        debugPrint('⚠️ [SessionTimeout] Warning: $remainingSeconds seconds remaining');
      }
    }
  }

  /// Handle session timeout (force logout)
  Future<void> _handleTimeout() async {
    if (kDebugMode) {
      debugPrint('🚨 [SessionTimeout] Session expired. Logging out...');
    }

    _eventController.add(
      SessionExpiredEvent(
        reason: 'Session expired due to inactivity',
        inactiveDuration: timeoutDuration,
      ),
    );

    // Force logout
    await authService.signOut();

    stopMonitoring();
  }

  /// Extend session (e.g., user clicks "Keep me logged in")
  void extendSession() {
    recordActivity();

    if (kDebugMode) {
      debugPrint('🔒 [SessionTimeout] Session extended');
    }
  }

  /// Get time until timeout
  Duration get timeUntilTimeout {
    final now = DateTime.now();
    final inactiveDuration = now.difference(_lastActivity);
    return timeoutDuration - inactiveDuration;
  }

  /// Is session about to expire?
  bool get isAboutToExpire {
    final remaining = timeUntilTimeout;
    return remaining <= warningDuration && remaining > Duration.zero;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _eventController.close();
  }
}

/// Base class for session events
abstract class SessionEvent {
  const SessionEvent();
}

/// Event: Session is about to expire (warning)
class SessionWarningEvent extends SessionEvent {
  const SessionWarningEvent({
    required this.remainingSeconds,
    required this.message,
  });

  final int remainingSeconds;
  final String message;
}

/// Event: Session has expired (user logged out)
class SessionExpiredEvent extends SessionEvent {
  const SessionExpiredEvent({
    required this.reason,
    required this.inactiveDuration,
  });

  final String reason;
  final Duration inactiveDuration;
}
