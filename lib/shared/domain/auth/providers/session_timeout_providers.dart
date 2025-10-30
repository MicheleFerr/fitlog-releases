/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain/auth/providers
/// 🎯 Feature: Session Timeout Providers
/// 🔧 Type: Riverpod Providers
///
/// Providers for session timeout and auto-logout functionality
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/auth/session_timeout_service.dart';

/// Session timeout service provider
/// Manages automatic user logout after inactivity period
final sessionTimeoutServiceProvider = Provider<SessionTimeoutService>((ref) {
  return SessionTimeoutService(
    authService: FirebaseAuth.instance,
  );
});

/// Session timeout events provider
/// Stream of session-related events (warnings, expiration)
final sessionTimeoutEventsProvider = StreamProvider<SessionEvent>((ref) {
  // TODO: Connect to actual event stream from SessionTimeoutService.events
  // For now, return empty stream until service is fully integrated
  return const Stream.empty();
});
