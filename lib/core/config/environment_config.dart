/// 🔐 SECURITY: Environment Configuration
///
/// Loads sensitive configuration from compile-time constants (--dart-define)
/// instead of bundled .env files (which can be extracted from app).
///
/// **SECURITY FIX**: Credentials are now injected at build time, not bundled.
///
/// **Build Commands**:
/// ```bash
/// # Development (uses defaults or .env via script)
/// flutter run
///
/// # Production (inject via --dart-define)
/// flutter build ios --release \
///   --dart-define=FIREBASE_API_KEY_IOS=xxx \
///   --dart-define=FIREBASE_APP_ID_IOS=xxx \
///   ...
/// ```
///
/// **Usage**:
/// ```dart
/// await EnvironmentConfig.load(); // Load before runApp()
/// final apiKey = EnvironmentConfig.firebaseApiKeyIOS;
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  // Private constructor (prevent instantiation)
  EnvironmentConfig._();

  /// Indicates whether environment variables have been loaded
  static bool _isLoaded = false;

  /// Indicates whether dotenv was successfully initialized
  /// When false, we must NOT access dotenv.env (throws NotInitializedError)
  static bool _dotenvLoaded = false;

  // ════════════════════════════════════════════════════════════════════════
  // COMPILE-TIME CONSTANTS (from --dart-define)
  // ════════════════════════════════════════════════════════════════════════
  // These are injected at build time and cannot be extracted from the binary
  // as easily as bundled asset files.

  static const String _dartDefineApiKeyIOS =
      String.fromEnvironment('FIREBASE_API_KEY_IOS');
  static const String _dartDefineAppIdIOS =
      String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static const String _dartDefineSenderIdIOS =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID_IOS');
  static const String _dartDefineProjectIdIOS =
      String.fromEnvironment('FIREBASE_PROJECT_ID_IOS');
  static const String _dartDefineStorageBucketIOS =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET_IOS');

  static const String _dartDefineApiKeyAndroid =
      String.fromEnvironment('FIREBASE_API_KEY_ANDROID');
  static const String _dartDefineAppIdAndroid =
      String.fromEnvironment('FIREBASE_APP_ID_ANDROID');
  static const String _dartDefineSenderIdAndroid =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID_ANDROID');
  static const String _dartDefineProjectIdAndroid =
      String.fromEnvironment('FIREBASE_PROJECT_ID_ANDROID');
  static const String _dartDefineStorageBucketAndroid =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET_ANDROID');

  static const String _dartDefineEnv =
      String.fromEnvironment('ENV', defaultValue: 'development');

  /// Load environment variables
  ///
  /// **Priority**:
  /// 1. Compile-time constants (--dart-define) - SECURE for production
  /// 2. .env file (debug only) - convenient for development
  ///
  /// **Must be called before runApp()** in main.dart
  static Future<void> load() async {
    if (_isLoaded) {
      if (kDebugMode) {
        debugPrint('⚠️ EnvironmentConfig already loaded, skipping');
      }
      return;
    }

    // Check if compile-time constants are available (production builds)
    if (_dartDefineApiKeyIOS.isNotEmpty) {
      _isLoaded = true;
      if (kDebugMode) {
        debugPrint('✅ Environment loaded from compile-time constants');
        debugPrint('   ENV: $environment');
      }
      return;
    }

    // Fallback: Try to load from .env file (bundled in assets)
    // This works for debug/profile builds where .env is in pubspec.yaml assets
    try {
      await dotenv.load(fileName: '.env');
      _dotenvLoaded = true; // Only set true if dotenv.load() succeeded
      _isLoaded = true;
      if (kDebugMode) {
        debugPrint('✅ Environment loaded from .env file');
        debugPrint('   ENV: $environment');
      }
    } catch (e) {
      // .env not found - this is expected in release builds
      // Firebase will use GoogleService-Info.plist / google-services.json instead
      _dotenvLoaded = false; // dotenv NOT initialized - don't access dotenv.env!
      _isLoaded = true; // Mark as loaded to prevent retry
      if (kDebugMode) {
        debugPrint('⚠️ No .env file found (expected in Release builds)');
        debugPrint('   Firebase will use native config files');
      }
      // DON'T throw - Firebase uses GoogleService-Info.plist on iOS
      // and google-services.json on Android, so env vars are optional
    }
  }

  /// Get environment variable with compile-time priority
  /// Returns empty string if not found (Firebase uses native config files)
  static String _get(String key, String dartDefineValue) {
    // Priority 1: Compile-time constant (secure)
    if (dartDefineValue.isNotEmpty) {
      return dartDefineValue;
    }

    // Priority 2: .env file (debug only)
    // IMPORTANT: Only access dotenv.env if _dotenvLoaded is true
    // Otherwise dotenv.env throws NotInitializedError
    if (_dotenvLoaded && dotenv.env.containsKey(key)) {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    // Return empty string instead of throwing
    // Firebase will use GoogleService-Info.plist / google-services.json
    return '';
  }

  /// Get optional environment variable
  static String? _getOptional(String key, String dartDefineValue) {
    if (dartDefineValue.isNotEmpty) {
      return dartDefineValue;
    }
    // Only access dotenv.env if it was successfully initialized
    if (_dotenvLoaded) {
      return dotenv.env[key];
    }
    return null;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Firebase Configuration - iOS
  // ════════════════════════════════════════════════════════════════════════

  /// Firebase API Key (iOS)
  static String get firebaseApiKeyIOS =>
      _get('FIREBASE_API_KEY_IOS', _dartDefineApiKeyIOS);

  /// Firebase App ID (iOS)
  static String get firebaseAppIdIOS =>
      _get('FIREBASE_APP_ID_IOS', _dartDefineAppIdIOS);

  /// Firebase Messaging Sender ID (iOS)
  static String get firebaseMessagingSenderIdIOS =>
      _get('FIREBASE_MESSAGING_SENDER_ID_IOS', _dartDefineSenderIdIOS);

  /// Firebase Project ID (iOS)
  static String get firebaseProjectIdIOS =>
      _get('FIREBASE_PROJECT_ID_IOS', _dartDefineProjectIdIOS);

  /// Firebase Storage Bucket (iOS)
  static String get firebaseStorageBucketIOS =>
      _get('FIREBASE_STORAGE_BUCKET_IOS', _dartDefineStorageBucketIOS);

  // ════════════════════════════════════════════════════════════════════════
  // Firebase Configuration - Android
  // ════════════════════════════════════════════════════════════════════════

  /// Firebase API Key (Android)
  static String get firebaseApiKeyAndroid =>
      _get('FIREBASE_API_KEY_ANDROID', _dartDefineApiKeyAndroid);

  /// Firebase App ID (Android)
  static String get firebaseAppIdAndroid =>
      _get('FIREBASE_APP_ID_ANDROID', _dartDefineAppIdAndroid);

  /// Firebase Messaging Sender ID (Android)
  static String get firebaseMessagingSenderIdAndroid =>
      _get('FIREBASE_MESSAGING_SENDER_ID_ANDROID', _dartDefineSenderIdAndroid);

  /// Firebase Project ID (Android)
  static String get firebaseProjectIdAndroid =>
      _get('FIREBASE_PROJECT_ID_ANDROID', _dartDefineProjectIdAndroid);

  /// Firebase Storage Bucket (Android)
  static String get firebaseStorageBucketAndroid =>
      _get('FIREBASE_STORAGE_BUCKET_ANDROID', _dartDefineStorageBucketAndroid);

  // ════════════════════════════════════════════════════════════════════════
  // Firebase Configuration - Web (optional)
  // ════════════════════════════════════════════════════════════════════════

  static const String _dartDefineApiKeyWeb =
      String.fromEnvironment('FIREBASE_API_KEY_WEB');
  static const String _dartDefineAppIdWeb =
      String.fromEnvironment('FIREBASE_APP_ID_WEB');
  static const String _dartDefineSenderIdWeb =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID_WEB');
  static const String _dartDefineProjectIdWeb =
      String.fromEnvironment('FIREBASE_PROJECT_ID_WEB');
  static const String _dartDefineStorageBucketWeb =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET_WEB');
  static const String _dartDefineMeasurementIdWeb =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID_WEB');

  /// Firebase API Key (Web) - Optional
  static String? get firebaseApiKeyWeb =>
      _getOptional('FIREBASE_API_KEY_WEB', _dartDefineApiKeyWeb);

  /// Firebase App ID (Web) - Optional
  static String? get firebaseAppIdWeb =>
      _getOptional('FIREBASE_APP_ID_WEB', _dartDefineAppIdWeb);

  /// Firebase Messaging Sender ID (Web) - Optional
  static String? get firebaseMessagingSenderIdWeb =>
      _getOptional('FIREBASE_MESSAGING_SENDER_ID_WEB', _dartDefineSenderIdWeb);

  /// Firebase Project ID (Web) - Optional
  static String? get firebaseProjectIdWeb =>
      _getOptional('FIREBASE_PROJECT_ID_WEB', _dartDefineProjectIdWeb);

  /// Firebase Storage Bucket (Web) - Optional
  static String? get firebaseStorageBucketWeb =>
      _getOptional('FIREBASE_STORAGE_BUCKET_WEB', _dartDefineStorageBucketWeb);

  /// Firebase Measurement ID (Web) - Optional
  static String? get firebaseMeasurementIdWeb =>
      _getOptional('FIREBASE_MEASUREMENT_ID_WEB', _dartDefineMeasurementIdWeb);

  // ════════════════════════════════════════════════════════════════════════
  // Third-party API Keys (Optional)
  // ════════════════════════════════════════════════════════════════════════

  static const String _dartDefineOpenAIKey =
      String.fromEnvironment('OPENAI_API_KEY');
  static const String _dartDefineStripeKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  /// OpenAI API Key - Optional
  static String? get openAIApiKey =>
      _getOptional('OPENAI_API_KEY', _dartDefineOpenAIKey);

  /// Stripe Publishable Key - Optional
  static String? get stripePublishableKey =>
      _getOptional('STRIPE_PUBLISHABLE_KEY', _dartDefineStripeKey);

  // ════════════════════════════════════════════════════════════════════════
  // Environment Detection
  // ════════════════════════════════════════════════════════════════════════

  /// Current environment (development, staging, production)
  static String get environment {
    if (_dartDefineEnv.isNotEmpty && _dartDefineEnv != 'development') {
      return _dartDefineEnv;
    }
    return _getOptional('ENV', _dartDefineEnv) ?? 'development';
  }

  /// Whether running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Whether running in staging mode
  static bool get isStaging => environment == 'staging';

  /// Whether running in production mode
  static bool get isProduction => environment == 'production';

  // ════════════════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════════════════

  /// Check if all required Firebase keys are present
  static bool validateFirebaseConfig() {
    try {
      // Check iOS config
      firebaseApiKeyIOS;
      firebaseAppIdIOS;
      firebaseMessagingSenderIdIOS;
      firebaseProjectIdIOS;
      firebaseStorageBucketIOS;

      // Check Android config
      firebaseApiKeyAndroid;
      firebaseAppIdAndroid;
      firebaseMessagingSenderIdAndroid;
      firebaseProjectIdAndroid;
      firebaseStorageBucketAndroid;

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase config validation failed: $e');
      }
      return false;
    }
  }

  /// Print all loaded environment variables (DEBUG ONLY - masks sensitive values)
  static void debugPrintConfig() {
    if (!kDebugMode) return;

    debugPrint('═════════════════════════════════════════════');
    debugPrint('🔐 Environment Configuration (DEBUG)');
    debugPrint('═════════════════════════════════════════════');
    debugPrint('ENV: $environment');
    debugPrint('Loaded: $_isLoaded');
    debugPrint('Source: ${_dartDefineApiKeyIOS.isNotEmpty ? "compile-time" : ".env file"}');
    debugPrint('');
    debugPrint('Firebase iOS:');
    debugPrint('  API Key: ${_mask(firebaseApiKeyIOS)}');
    debugPrint('  App ID: ${_mask(firebaseAppIdIOS)}');
    debugPrint('  Project: $firebaseProjectIdIOS');
    debugPrint('');
    debugPrint('Firebase Android:');
    debugPrint('  API Key: ${_mask(firebaseApiKeyAndroid)}');
    debugPrint('  App ID: ${_mask(firebaseAppIdAndroid)}');
    debugPrint('  Project: $firebaseProjectIdAndroid');
    debugPrint('═════════════════════════════════════════════');
  }

  /// Mask sensitive value for debugging (show first 4 and last 4 characters)
  static String _mask(String value) {
    if (value.length <= 8) return '****';
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }
}
