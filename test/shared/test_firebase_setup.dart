import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Initialize Firebase for testing environment
///
/// This helper ensures Firebase is properly initialized before tests run.
/// It handles the case where Firebase might already be initialized
/// (e.g., in other test files) to avoid duplicate initialization errors.
Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      // Initialize with minimal configuration for testing
      // Using fake options since we're mocking Firebase services anyway
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        ),
      );
    }
  } catch (e) {
    // If initialization fails, it's likely already initialized
    // or Firebase is not available in test environment.
    // This is acceptable since we're using mocked services.
    // ignore: avoid_print
    print('Firebase init warning (expected in test): $e');
  }
}
