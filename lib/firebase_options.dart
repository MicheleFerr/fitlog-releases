// 🔐 SECURITY: Firebase Options (Environment-based)
//
// This file has been refactored to load Firebase credentials from .env
// instead of hardcoding them in source code.
//
// **BREAKING CHANGE**: Hardcoded API keys removed (security vulnerability fix)
//
// **Migration**: Create .env file from .env.example and populate with your
// Firebase credentials. Call EnvironmentConfig.load() before using this class.
//
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:gymbro_flutter_new/core/config/firebase_config.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// **🔐 SECURITY UPDATE**: This class now loads credentials from .env file
/// instead of hardcoding them.
///
/// **Setup Required**:
/// 1. Copy .env.example to .env
/// 2. Fill in your Firebase credentials
/// 3. Call `await EnvironmentConfig.load()` before Firebase.initializeApp()
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// import 'package:gymbro_flutter_new/core/config/environment_config.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Load environment variables from .env
///   await EnvironmentConfig.load();
///
///   // Initialize Firebase with environment-based options
///   await Firebase.initializeApp(
///     options: DefaultFirebaseOptions.currentPlatform,
///   );
///
///   runApp(MyApp());
/// }
/// ```
class DefaultFirebaseOptions {
  /// Get Firebase options for current platform (from environment variables)
  ///
  /// **REQUIRES**: `EnvironmentConfig.load()` must be called first!
  ///
  /// Automatically detects platform and returns appropriate FirebaseOptions.
  ///
  /// Throws [Exception] if environment variables not loaded or missing required keys.
  static FirebaseOptions get currentPlatform {
    return FirebaseConfig.fromEnvironment();
  }

  // ══════════════════════════════════════════════════════════════════════
  // DEPRECATED: Hardcoded options removed (security vulnerability)
  // ══════════════════════════════════════════════════════════════════════
  //
  // The following static const options have been removed to prevent
  // API key exposure in version control:
  //
  // - static const FirebaseOptions web
  // - static const FirebaseOptions android
  // - static const FirebaseOptions ios
  // - static const FirebaseOptions macos
  // - static const FirebaseOptions windows
  //
  // They are now dynamically generated from .env file via FirebaseConfig.
  //
  // **Migration Path**:
  // If you were accessing these directly (e.g., `DefaultFirebaseOptions.ios`),
  // use `DefaultFirebaseOptions.currentPlatform` instead (platform auto-detected).
  // ══════════════════════════════════════════════════════════════════════
}