import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for Firebase Emulator integration testing
///
/// Usage:
/// ```dart
/// setUpAll(() async {
///   await FirebaseEmulatorHelper.initialize();
/// });
///
/// setUp(() async {
///   await FirebaseEmulatorHelper.clearFirestore();
/// });
///
/// tearDownAll(() async {
///   await FirebaseEmulatorHelper.cleanup();
/// });
/// ```
class FirebaseEmulatorHelper {
  static const String _firestoreHost = 'localhost';
  static const int _firestorePort = 8080;
  static const String _authHost = 'localhost';
  static const int _authPort = 9099;

  static bool _initialized = false;
  static FirebaseApp? _app;

  /// Initialize Firebase with emulator configuration
  ///
  /// This should be called in setUpAll() of your test suite
  static Future<void> initialize() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      // Initialize Firebase app for testing
      _app = await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        ),
      );

      // Connect Firestore to emulator
      FirebaseFirestore.instance.useFirestoreEmulator(
        _firestoreHost,
        _firestorePort,
      );

      // Connect Auth to emulator
      await FirebaseAuth.instance.useAuthEmulator(
        _authHost,
        _authPort,
      );

      _initialized = true;
      print('✅ Firebase Emulator initialized successfully');
    } catch (e) {
      print('⚠️  Firebase Emulator initialization error: $e');
      rethrow;
    }
  }

  /// Clear all Firestore data
  ///
  /// This should be called in setUp() to ensure clean state for each test
  static Future<void> clearFirestore() async {
    if (!_initialized) {
      throw StateError('Firebase Emulator not initialized. Call initialize() first.');
    }

    try {
      // Clear emulator data via HTTP API
      final client = HttpClient();
      final request = await client.deleteUrl(
        Uri.parse('http://$_firestoreHost:$_firestorePort/emulator/v1/projects/test-project-id/databases/(default)/documents'),
      );
      final response = await request.close();
      await response.drain();
      client.close();

      print('🧹 Firestore data cleared');
    } catch (e) {
      print('⚠️  Failed to clear Firestore: $e');
      // Don't rethrow - clearing is best effort
    }
  }

  /// Sign in anonymous user for testing
  ///
  /// Returns the authenticated user
  static Future<User> signInAnonymously() async {
    if (!_initialized) {
      throw StateError('Firebase Emulator not initialized. Call initialize() first.');
    }

    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    if (userCredential.user == null) {
      throw StateError('Failed to sign in anonymously');
    }

    return userCredential.user!;
  }

  /// Create a test user with email/password
  ///
  /// Returns the authenticated user
  static Future<User> createTestUser({
    required String email,
    required String password,
  }) async {
    if (!_initialized) {
      throw StateError('Firebase Emulator not initialized. Call initialize() first.');
    }

    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw StateError('Failed to create test user');
    }

    return userCredential.user!;
  }

  /// Sign out current user
  static Future<void> signOut() async {
    if (!_initialized) return;
    await FirebaseAuth.instance.signOut();
  }

  /// Get Firestore instance connected to emulator
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw StateError('Firebase Emulator not initialized. Call initialize() first.');
    }
    return FirebaseFirestore.instance;
  }

  /// Get Auth instance connected to emulator
  static FirebaseAuth get auth {
    if (!_initialized) {
      throw StateError('Firebase Emulator not initialized. Call initialize() first.');
    }
    return FirebaseAuth.instance;
  }

  /// Check if emulator is running
  ///
  /// Returns true if emulator is accessible
  static Future<bool> isEmulatorRunning() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('http://$_firestoreHost:$_firestorePort/'),
      );
      request.headers.set('Connection', 'close');

      final response = await request.close().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          client.close(force: true);
          throw TimeoutException('Connection timeout');
        },
      );

      await response.drain();
      client.close();

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Cleanup resources
  ///
  /// This should be called in tearDownAll() of your test suite
  static Future<void> cleanup() async {
    if (!_initialized) return;

    try {
      await signOut();
      await _app?.delete();
      _app = null;
      _initialized = false;
      print('🧹 Firebase Emulator cleaned up');
    } catch (e) {
      print('⚠️  Cleanup error: $e');
    }
  }

  /// Create test data in Firestore
  ///
  /// Helper method to populate test data
  static Future<DocumentReference> createTestDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    if (!_initialized) {
      throw StateError('Firebase Emulator not initialized. Call initialize() first.');
    }

    final docRef = documentId != null
        ? firestore.collection(collection).doc(documentId)
        : firestore.collection(collection).doc();

    await docRef.set(data);
    return docRef;
  }

  /// Verify emulator setup before running tests
  ///
  /// Call this in main() before running tests
  static Future<void> verifySetup() async {
    final isRunning = await isEmulatorRunning();

    if (!isRunning) {
      print('');
      print('❌ Firebase Emulator is not running!');
      print('');
      print('Please start the emulator with:');
      print('  firebase emulators:start');
      print('');
      throw StateError('Firebase Emulator not accessible at http://$_firestoreHost:$_firestorePort');
    }

    print('✅ Firebase Emulator is running');
  }
}
