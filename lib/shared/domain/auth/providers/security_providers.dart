/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/domain/auth/providers
/// 🎯 Feature: Security Providers (STUB)
/// 🔧 Type: Riverpod Providers
///
/// Temporary stub to prevent compilation errors
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub RBAC service provider
final rbacServiceProvider = Provider<RbacService>((ref) {
  return RbacService();
});

/// Stub session activity recorder provider
final sessionActivityRecorderProvider = Provider<SessionActivityRecorder>((ref) {
  return SessionActivityRecorder();
});

/// Stub RBAC service
class RbacService {
  /// Get current user role
  String get currentRole => 'user'; // Default role

  bool hasPermission(String permission) => true;
  bool canAccessRoute(String route) => true;
}

/// Stub session activity recorder
class SessionActivityRecorder {
  void recordActivity(String activity) {}
}
