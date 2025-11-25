/// 🔐 SECURITY: Environment Configuration
///
/// Loads sensitive configuration from .env file (not committed to version control)
/// Uses flutter_dotenv package for secure environment variable management.
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

  /// Load environment variables from .env file
  ///
  /// **Must be called before runApp()** in main.dart:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await EnvironmentConfig.load();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Throws [Exception] if .env file not found or loading fails
  static Future<void> load() async {
    if (_isLoaded) {
      if (kDebugMode) {
        debugPrint('⚠️ EnvironmentConfig already loaded, skipping');
      }
      return;
    }

    try {
      await dotenv.load(fileName: '.env');
      _isLoaded = true;
      if (kDebugMode) {
        debugPrint('✅ Environment variables loaded successfully');
        debugPrint('   ENV: ${environment}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to load .env file: $e');
        debugPrint('   Make sure .env exists (copy from .env.example)');
      }
      throw Exception('Failed to load environment configuration: $e');
    }
  }

  /// Get environment variable (throws if not set)
  static String _get(String key) {
    if (!_isLoaded) {
      throw Exception(
          'EnvironmentConfig not loaded. Call await EnvironmentConfig.load() before accessing variables.');
    }

    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Environment variable "$key" not found in .env file');
    }
    return value;
  }

  /// Get optional environment variable (returns null if not set)
  static String? _getOptional(String key) {
    if (!_isLoaded) return null;
    return dotenv.env[key];
  }

  // ════════════════════════════════════════════════════════════════════════
  // Firebase Configuration - iOS
  // ════════════════════════════════════════════════════════════════════════

  /// Firebase API Key (iOS)
  static String get firebaseApiKeyIOS => _get('FIREBASE_API_KEY_IOS');

  /// Firebase App ID (iOS)
  static String get firebaseAppIdIOS => _get('FIREBASE_APP_ID_IOS');

  /// Firebase Messaging Sender ID (iOS)
  static String get firebaseMessagingSenderIdIOS =>
      _get('FIREBASE_MESSAGING_SENDER_ID_IOS');

  /// Firebase Project ID (iOS)
  static String get firebaseProjectIdIOS => _get('FIREBASE_PROJECT_ID_IOS');

  /// Firebase Storage Bucket (iOS)
  static String get firebaseStorageBucketIOS =>
      _get('FIREBASE_STORAGE_BUCKET_IOS');

  // ════════════════════════════════════════════════════════════════════════
  // Firebase Configuration - Android
  // ════════════════════════════════════════════════════════════════════════

  /// Firebase API Key (Android)
  static String get firebaseApiKeyAndroid => _get('FIREBASE_API_KEY_ANDROID');

  /// Firebase App ID (Android)
  static String get firebaseAppIdAndroid => _get('FIREBASE_APP_ID_ANDROID');

  /// Firebase Messaging Sender ID (Android)
  static String get firebaseMessagingSenderIdAndroid =>
      _get('FIREBASE_MESSAGING_SENDER_ID_ANDROID');

  /// Firebase Project ID (Android)
  static String get firebaseProjectIdAndroid =>
      _get('FIREBASE_PROJECT_ID_ANDROID');

  /// Firebase Storage Bucket (Android)
  static String get firebaseStorageBucketAndroid =>
      _get('FIREBASE_STORAGE_BUCKET_ANDROID');

  // ════════════════════════════════════════════════════════════════════════
  // Firebase Configuration - Web (optional)
  // ════════════════════════════════════════════════════════════════════════

  /// Firebase API Key (Web) - Optional
  static String? get firebaseApiKeyWeb => _getOptional('FIREBASE_API_KEY_WEB');

  /// Firebase App ID (Web) - Optional
  static String? get firebaseAppIdWeb => _getOptional('FIREBASE_APP_ID_WEB');

  /// Firebase Messaging Sender ID (Web) - Optional
  static String? get firebaseMessagingSenderIdWeb =>
      _getOptional('FIREBASE_MESSAGING_SENDER_ID_WEB');

  /// Firebase Project ID (Web) - Optional
  static String? get firebaseProjectIdWeb =>
      _getOptional('FIREBASE_PROJECT_ID_WEB');

  /// Firebase Storage Bucket (Web) - Optional
  static String? get firebaseStorageBucketWeb =>
      _getOptional('FIREBASE_STORAGE_BUCKET_WEB');

  /// Firebase Measurement ID (Web) - Optional
  static String? get firebaseMeasurementIdWeb =>
      _getOptional('FIREBASE_MEASUREMENT_ID_WEB');

  // ════════════════════════════════════════════════════════════════════════
  // Third-party API Keys (Optional)
  // ════════════════════════════════════════════════════════════════════════

  /// OpenAI API Key - Optional
  static String? get openAIApiKey => _getOptional('OPENAI_API_KEY');

  /// Stripe Publishable Key - Optional
  static String? get stripePublishableKey =>
      _getOptional('STRIPE_PUBLISHABLE_KEY');

  // ════════════════════════════════════════════════════════════════════════
  // Environment Detection
  // ════════════════════════════════════════════════════════════════════════

  /// Current environment (development, staging, production)
  static String get environment => _getOptional('ENV') ?? 'development';

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
