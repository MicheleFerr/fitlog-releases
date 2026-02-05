/// Firebase Service
///
/// Provides Firebase-related utilities and configurations.
/// Constructs Cloud Functions base URL from Firebase project settings.
///
/// **Layer**: Core - Services
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment_config.dart';

/// Firebase service for accessing Firebase utilities
class FirebaseService {
  FirebaseService._();

  /// Singleton instance
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;

  /// Get Cloud Functions base URL based on current environment
  ///
  /// **Production**: https://us-central1-{projectId}.cloudfunctions.net
  /// **Emulator**: http://localhost:5001/{projectId}/us-central1
  ///
  /// Uses iOS project ID as default (same for both platforms in FitLog)
  String get functionsBaseUrl {
    final projectId = EnvironmentConfig.firebaseProjectIdIOS;

    if (kDebugMode && _useEmulator) {
      // Use Firebase emulator for local development
      return 'http://localhost:5001/$projectId/us-central1';
    }

    // Production Cloud Functions URL (US region)
    return 'https://us-central1-$projectId.cloudfunctions.net';
  }

  /// Check if using Firebase emulator (can be overridden for testing)
  bool get _useEmulator => false; // Set to true to use local emulator

  /// Get project ID for current platform
  String get projectId => EnvironmentConfig.firebaseProjectIdIOS;
}

/// Provider for Firebase service (singleton)
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
