/// 🔐 SECURITY: Firebase Configuration from Environment Variables
///
/// Loads Firebase credentials from .env file instead of hardcoding them.
/// This prevents API keys from being exposed in version control.
///
/// **Usage**:
/// ```dart
/// await EnvironmentConfig.load(); // Load .env first
/// final firebaseOptions = FirebaseConfig.fromEnvironment();
/// await Firebase.initializeApp(options: firebaseOptions);
/// ```
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:gymbro_flutter_new/core/config/environment_config.dart';

class FirebaseConfig {
  // Private constructor (prevent instantiation)
  FirebaseConfig._();

  /// Get Firebase options for current platform (from environment variables)
  ///
  /// **Requires**: `EnvironmentConfig.load()` must be called first!
  ///
  /// Automatically detects platform (iOS, Android, Web, macOS, Windows)
  /// and returns appropriate FirebaseOptions.
  static FirebaseOptions fromEnvironment() {
    if (kIsWeb) {
      return _webOptions;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidOptions;
      case TargetPlatform.iOS:
        return _iOSOptions;
      case TargetPlatform.macOS:
        return _macOSOptions;
      case TargetPlatform.windows:
        return _windowsOptions;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is not supported on Linux platform',
        );
      default:
        throw UnsupportedError(
          'Firebase is not supported on this platform',
        );
    }
  }

  /// Firebase options for iOS (from environment variables)
  static FirebaseOptions get _iOSOptions => FirebaseOptions(
        apiKey: EnvironmentConfig.firebaseApiKeyIOS,
        appId: EnvironmentConfig.firebaseAppIdIOS,
        messagingSenderId: EnvironmentConfig.firebaseMessagingSenderIdIOS,
        projectId: EnvironmentConfig.firebaseProjectIdIOS,
        storageBucket: EnvironmentConfig.firebaseStorageBucketIOS,
        iosBundleId: 'com.michele.gymbro.flutter', // Static - not secret
      );

  /// Firebase options for Android (from environment variables)
  static FirebaseOptions get _androidOptions => FirebaseOptions(
        apiKey: EnvironmentConfig.firebaseApiKeyAndroid,
        appId: EnvironmentConfig.firebaseAppIdAndroid,
        messagingSenderId: EnvironmentConfig.firebaseMessagingSenderIdAndroid,
        projectId: EnvironmentConfig.firebaseProjectIdAndroid,
        storageBucket: EnvironmentConfig.firebaseStorageBucketAndroid,
      );

  /// Firebase options for Web (from environment variables)
  static FirebaseOptions get _webOptions {
    // Use optional getters since web config might not be set
    final apiKey = EnvironmentConfig.firebaseApiKeyWeb;
    final appId = EnvironmentConfig.firebaseAppIdWeb;
    final messagingSenderId = EnvironmentConfig.firebaseMessagingSenderIdWeb;
    final projectId = EnvironmentConfig.firebaseProjectIdWeb;
    final storageBucket = EnvironmentConfig.firebaseStorageBucketWeb;
    final measurementId = EnvironmentConfig.firebaseMeasurementIdWeb;

    if (apiKey == null || appId == null || projectId == null) {
      throw Exception(
        'Web Firebase configuration not found in .env file. '
        'Add FIREBASE_API_KEY_WEB, FIREBASE_APP_ID_WEB, FIREBASE_PROJECT_ID_WEB',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId ?? '',
      projectId: projectId,
      storageBucket: storageBucket ?? '$projectId.appspot.com',
      authDomain: '$projectId.firebaseapp.com',
      measurementId: measurementId,
    );
  }

  /// Firebase options for macOS (from environment variables)
  ///
  /// Uses same config as iOS (macOS apps use iOS Firebase project)
  static FirebaseOptions get _macOSOptions => FirebaseOptions(
        apiKey: EnvironmentConfig.firebaseApiKeyIOS,
        appId: EnvironmentConfig.firebaseAppIdIOS,
        messagingSenderId: EnvironmentConfig.firebaseMessagingSenderIdIOS,
        projectId: EnvironmentConfig.firebaseProjectIdIOS,
        storageBucket: EnvironmentConfig.firebaseStorageBucketIOS,
        iosBundleId: 'com.michele.gymbro.flutter', // Static - not secret
      );

  /// Firebase options for Windows (from environment variables)
  ///
  /// Uses same config as Web (Windows apps use Web Firebase project)
  static FirebaseOptions get _windowsOptions {
    final apiKey = EnvironmentConfig.firebaseApiKeyWeb;
    final appId = EnvironmentConfig.firebaseAppIdWeb;
    final messagingSenderId = EnvironmentConfig.firebaseMessagingSenderIdWeb;
    final projectId = EnvironmentConfig.firebaseProjectIdWeb;
    final storageBucket = EnvironmentConfig.firebaseStorageBucketWeb;
    final measurementId = EnvironmentConfig.firebaseMeasurementIdWeb;

    if (apiKey == null || appId == null || projectId == null) {
      throw Exception(
        'Windows Firebase configuration not found in .env file. '
        'Add FIREBASE_API_KEY_WEB, FIREBASE_APP_ID_WEB, FIREBASE_PROJECT_ID_WEB',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId ?? '',
      projectId: projectId,
      storageBucket: storageBucket ?? '$projectId.appspot.com',
      authDomain: '$projectId.firebaseapp.com',
      measurementId: measurementId,
    );
  }
}
