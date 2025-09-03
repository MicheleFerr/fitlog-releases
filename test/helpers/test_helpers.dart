import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';

/// Mock Firebase initialization for tests
Future<void> setupFirebaseForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Mock Firebase initialization - prevents actual Firebase connection
}

/// Create a test widget wrapper with Riverpod
Widget createTestWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// Mock user for testing
class MockUser {
  static UserModel createTestUser({
    String uid = 'test-user-id',
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      isGuest: false,
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
  }
}

/// Mock Firebase Auth User
class MockFirebaseUser {
  final String uid;
  final String? email;
  final String? displayName;
  
  MockFirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

/// Test data generators
class TestData {
  static Map<String, dynamic> validLoginCredentials() => {
    'email': 'test@example.com',
    'password': 'Test123!@#',
  };
  
  static Map<String, dynamic> invalidLoginCredentials() => {
    'email': 'invalid@example.com',
    'password': 'wrong',
  };
  
  static Map<String, dynamic> validRegistrationData() => {
    'email': 'newuser@example.com',
    'password': 'NewUser123!@#',
    'displayName': 'New User',
  };
}