/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: test/helpers
 * 🎯 Feature: firebase test helper
 * 🔧 Type: test helper
 * 🌍 Localization: ✅ Not applicable
 * 🎨 Theme: ✅ Not applicable
 * 📱 Platform: Universal
 * 
 * Firebase Mock Setup for Tests
 * Handles Firebase initialization and mocking
 */

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

// Mock classes
class MockFirebaseApp extends Mock implements FirebaseApp {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

/// Firebase test helper that properly mocks Firebase services
class FirebaseTestHelper {
  static MockFirebaseApp? _mockApp;
  static MockFirebaseAuth? _mockAuth;
  static MockFirestore? _mockFirestore;
  static MockUser? _mockUser;
  
  /// Initialize Firebase mocks for testing
  static Future<void> setupFirebaseAuthMocks({
    bool isUserSignedIn = false,
    String? uid,
    String? email,
    String? displayName,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    _mockApp = MockFirebaseApp();
    _mockAuth = MockFirebaseAuth();
    _mockFirestore = MockFirestore();
    
    // Mock Firebase app
    when(() => _mockApp!.name).thenReturn('[DEFAULT]');
    when(() => _mockApp!.options).thenReturn(const FirebaseOptions(
      apiKey: 'fake-api-key',
      appId: 'fake-app-id',
      messagingSenderId: 'fake-sender-id',
      projectId: 'fake-project-id',
    ));
    
    // Note: We don't mock Firebase.initializeApp to avoid platform interface issues
    
    // Setup user state
    if (isUserSignedIn) {
      _mockUser = MockUser();
      when(() => _mockUser!.uid).thenReturn(uid ?? 'test-user-123');
      when(() => _mockUser!.email).thenReturn(email ?? 'test@example.com');
      when(() => _mockUser!.displayName).thenReturn(displayName ?? 'Test User');
      when(() => _mockUser!.emailVerified).thenReturn(true);
      when(() => _mockUser!.photoURL).thenReturn(null);
      when(() => _mockUser!.phoneNumber).thenReturn(null);
      when(() => _mockUser!.isAnonymous).thenReturn(false);
      when(() => _mockUser!.metadata).thenReturn(MockUserMetadata());
      when(() => _mockUser!.providerData).thenReturn([]);
      when(() => _mockUser!.refreshToken).thenReturn('fake-refresh-token');
      when(() => _mockUser!.tenantId).thenReturn(null);
      
      when(() => _mockAuth!.currentUser).thenReturn(_mockUser);
      when(() => _mockAuth!.authStateChanges()).thenAnswer(
        (_) => Stream.value(_mockUser),
      );
      when(() => _mockAuth!.idTokenChanges()).thenAnswer(
        (_) => Stream.value(_mockUser),
      );
      when(() => _mockAuth!.userChanges()).thenAnswer(
        (_) => Stream.value(_mockUser),
      );
    } else {
      when(() => _mockAuth!.currentUser).thenReturn(null);
      when(() => _mockAuth!.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => _mockAuth!.idTokenChanges()).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => _mockAuth!.userChanges()).thenAnswer(
        (_) => Stream.value(null),
      );
    }
    
    // Mock auth operations
    when(() => _mockAuth!.signOut()).thenAnswer((_) async {});
    when(() => _mockAuth!.signInAnonymously()).thenAnswer((_) async {
      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(_mockUser);
      return mockCredential;
    });
  }
  
  /// Clean up Firebase mocks
  static void tearDown() {
    _mockApp = null;
    _mockAuth = null;
    _mockFirestore = null;
    _mockUser = null;
  }
  
  /// Get the mock Firebase Auth instance
  static MockFirebaseAuth get mockAuth => _mockAuth!;
  
  /// Get the mock Firebase User instance
  static MockUser? get mockUser => _mockUser;
  
  /// Get the mock Firestore instance
  static MockFirestore get mockFirestore => _mockFirestore!;
}

// Note: Firebase platform mocking removed to avoid compatibility issues

/// Mock User Metadata
class MockUserMetadata extends Mock implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  
  @override
  DateTime? get lastSignInTime => DateTime.now();
}

/// Setupd Firebase for testing with default user
Future<void> setupTestFirebase({
  bool withUser = true,
  String? uid,
  String? email,
  String? displayName,
}) async {
  await FirebaseTestHelper.setupFirebaseAuthMocks(
    isUserSignedIn: withUser,
    uid: uid ?? 'test-user-123',
    email: email ?? 'test@example.com',
    displayName: displayName ?? 'Test User',
  );
}

/// Teardown Firebase test setup
void tearDownTestFirebase() {
  FirebaseTestHelper.tearDown();
}