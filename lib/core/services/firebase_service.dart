/// Firebase Service
///
/// Provides Firebase-related utilities and configurations.
/// Constructs API base URLs for backend services.
///
/// **Layer**: Core - Services
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/config/environment_config.dart';

/// Firebase service for accessing Firebase utilities
class FirebaseService {
  FirebaseService._();

  /// Singleton instance
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;

  /// Get backend API base URL
  ///
  /// **Production**: https://fitlogpro.it (Next.js on Vercel)
  /// **Development**: http://localhost:3000 (local Next.js dev server)
  ///
  /// This URL is used for:
  /// - AI Coach document sync API
  /// - Other public API endpoints
  String get functionsBaseUrl {
    if (kDebugMode && _useLocalBackend) {
      // Use local Next.js dev server for development
      return 'http://localhost:3000';
    }

    // Production backend (Next.js on Vercel)
    return 'https://fitlogpro.it';
  }

  /// Check if using local backend (can be overridden for testing)
  /// Set to true when running website locally with `npm run dev`
  bool get _useLocalBackend => false;

  /// Get project ID for current platform
  String get projectId => EnvironmentConfig.firebaseProjectIdIOS;
}

/// Provider for Firebase service (singleton)
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
