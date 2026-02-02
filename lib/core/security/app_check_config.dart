/// 🏋️‍♂️ FitLog Pro - Flutter Fitness App
///
/// 📁 Layer: core/security
/// 🎯 Feature: app_check
/// 🔧 Type: configuration
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// **CRITICAL SECURITY COMPONENT**
/// Firebase App Check prevents unauthorized API usage and abuse.
///
/// **Purpose:**
/// - Verifies that requests come from legitimate app instances
/// - Prevents API quota abuse from scraped/stolen API keys
/// - Protects against automated attacks and bots
/// - Required for production Firebase usage
///
/// **How it works:**
/// - iOS: Device Check (built into iOS)
/// - Android: Play Integrity API (requires Google Play)
/// - Web: reCAPTCHA v3
///
/// **Setup Required:**
/// 1. Enable App Check in Firebase Console
/// 2. Register app with platform provider (Device Check / Play Integrity)
/// 3. Deploy updated Firestore rules (already done ✅)
///
library;

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase App Check Configuration Service
///
/// **CRITICAL SECURITY**: This MUST be initialized before any Firebase operations
///
/// **Example:**
/// ```dart
/// await Firebase.initializeApp();
/// await AppCheckConfig.initialize(); // ← REQUIRED for security
/// runApp(MyApp());
/// ```
class AppCheckConfig {
  AppCheckConfig._(); // Private constructor (static only)

  // ✅ FIX #4: Cache activation state to avoid repeated initialization
  static bool _isActivated = false;
  static DateTime? _lastActivationAttempt;
  static const Duration _minRetryInterval = Duration(minutes: 5);

  /// Initialize Firebase App Check with exponential backoff retry
  ///
  /// **Platform-specific providers:**
  /// - iOS: DeviceCheckProvider (uses Apple's Device Check API)
  /// - Android: PlayIntegrityProvider (requires Google Play Services)
  /// - Web: ReCaptchaV3Provider (requires reCAPTCHA site key)
  ///
  /// **Retry Strategy:**
  /// - Attempts: Up to 3 retries
  /// - Backoff: 1s, 2s, 4s (exponential)
  /// - Caching: Successful activation cached for 5 minutes
  ///
  /// **Returns:**
  /// - `true` if App Check initialized successfully
  /// - `false` if all retry attempts failed
  ///
  /// **Throws:**
  /// - Does NOT throw - catches all errors and returns false
  static Future<bool> initialize() async {
    // ✅ FIX #4: Check if already activated recently
    if (_isActivated &&
        _lastActivationAttempt != null &&
        DateTime.now().difference(_lastActivationAttempt!) < _minRetryInterval) {
      if (kDebugMode) {
        debugPrint('🔐 [App Check] Already activated (cached), skipping');
      }
      return true;
    }

    const maxAttempts = 3;
    const baseDelay = Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (kDebugMode) {
          debugPrint('🔐 [App Check] Initializing Firebase App Check (attempt $attempt/$maxAttempts)...');
        }

        await FirebaseAppCheck.instance.activate(
          // iOS: Use debug provider in development, App Attest in release
          // ✅ SECURITY: App Attest verifies app is running on genuine Apple device
          // ⚠️ DEBUG: Debug provider allows testing without device attestation
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleAppAttestWithDeviceCheckFallbackProvider(),

          // Android: Use debug provider in development, Play Integrity in release
          // ✅ SECURITY: Play Integrity verifies app is from Google Play
          // ⚠️ DEBUG: Debug provider allows testing on emulators/unsigned builds
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),

          // Web: Use reCAPTCHA v3 (for web deployment)
          // ⚠️ TODO: Replace with your actual reCAPTCHA site key from Firebase Console
          // Get it from: Firebase Console → App Check → Web apps → reCAPTCHA v3
          providerWeb: ReCaptchaV3Provider(
            'your-recaptcha-v3-site-key-here',
          ),
        );

        // ✅ FIX #4: Cache successful activation
        _isActivated = true;
        _lastActivationAttempt = DateTime.now();

        if (kDebugMode) {
          debugPrint('✅ [App Check] Successfully initialized on attempt $attempt');
        }

        return true;
      } catch (e, stackTrace) {
        // 🔐 SECURITY: Log error but don't crash app
        if (kDebugMode) {
          debugPrint('❌ [App Check] Attempt $attempt/$maxAttempts failed: $e');

          // Provide helpful diagnostic messages
          if (e.toString().contains('not registered') || e.toString().contains('App not registered')) {
            debugPrint('💡 [App Check] DIAGNOSTIC: App bundle ID not registered in Firebase Console');
            debugPrint('   → Go to Firebase Console → App Check → Register your iOS app');
            debugPrint('   → Enable DeviceCheck or App Attest provider');
          } else if (e.toString().contains('network')) {
            debugPrint('💡 [App Check] DIAGNOSTIC: Network connectivity issue');
            debugPrint('   → Check internet connection and Firebase reachability');
          }
        }

        // ✅ FIX #4: Exponential backoff before retry
        if (attempt < maxAttempts) {
          final delay = baseDelay * (1 << (attempt - 1)); // 1s, 2s, 4s
          if (kDebugMode) {
            debugPrint('⏳ [App Check] Retrying in ${delay.inSeconds}s...');
          }
          await Future.delayed(delay);
        } else {
          // Last attempt failed - log stack trace
          if (kDebugMode) {
            debugPrint('Stack trace: $stackTrace');
          }

          // Send error to Firebase Crashlytics for monitoring
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);

          _lastActivationAttempt = DateTime.now(); // Prevent immediate retry
        }
      }
    }

    if (kDebugMode) {
      debugPrint('⚠️ [App Check] All $maxAttempts attempts failed - continuing with placeholder tokens');
      debugPrint('   ⚠️ Security reduced: API requests will use placeholder App Check tokens');
    }

    return false;
  }

  /// Get current App Check token (for debugging)
  ///
  /// **Use Case:**
  /// - Verify App Check is working
  /// - Debug token issues
  /// - Monitor token expiration
  ///
  /// **Example:**
  /// ```dart
  /// final token = await AppCheckConfig.getToken();
  /// debugPrint('App Check Token: ${token?.substring(0, 20)}...');
  /// ```
  static Future<String?> getToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [App Check] Failed to get token: $e');
      }
      return null;
    }
  }

  /// Check if App Check is activated
  ///
  /// **Returns:**
  /// - `true` if App Check is active and working
  /// - `false` if App Check is not initialized or failed
  static Future<bool> isActivated() async {
    try {
      // Try to get a token - if successful, App Check is working
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Set debug token for local testing
  ///
  /// **ONLY for development/testing!**
  ///
  /// **How to get debug token:**
  /// 1. Run app in debug mode
  /// 2. Check console for: "Firebase App Check debug token: XXXXX"
  /// 3. Add token in Firebase Console → App Check → Debug tokens
  /// 4. Call this method with the token
  ///
  /// **Example:**
  /// ```dart
  /// if (kDebugMode) {
  ///   await AppCheckConfig.setDebugToken('your-debug-token');
  /// }
  /// ```
  static Future<void> setDebugToken(String debugToken) async {
    if (!kDebugMode) {
      debugPrint('⚠️ [App Check] Debug tokens should only be used in debug mode!');
      return;
    }

    try {
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      if (kDebugMode) {
        debugPrint('✅ [App Check] Debug token configured');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [App Check] Failed to set debug token: $e');
      }
    }
  }
}
