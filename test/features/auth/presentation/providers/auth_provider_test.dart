import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../test_helpers/firebase_test_helper.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockFirebaseUser extends Mock implements firebase_auth.User {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });
  
  late ProviderContainer container;
  late MockAuthService mockAuthService;
  late StreamController<firebase_auth.User?> authStateController;
  
  setUp(() {
    mockAuthService = MockAuthService();
    authStateController = StreamController<firebase_auth.User?>.broadcast();
    
    // Setup default auth state stream
    when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateController.stream);
    
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  });

  tearDown(() {
    authStateController.close();
    container.dispose();
  });

  group('firebaseUserProvider', () {
    test('emits null when user is not authenticated', () async {
      authStateController.add(null);
      
      // Give stream time to process
      await Future.delayed(const Duration(milliseconds: 100));
      
      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.value, isNull);
    });

    test('emits user when authenticated', () async {
      final mockUser = MockFirebaseUser();
      when(() => mockUser.uid).thenReturn('test-uid');
      
      // Listen to the provider to ensure it builds
      final sub = container.listen(firebaseUserProvider, (_, __) {});
      
      authStateController.add(mockUser);
      
      // Give stream time to process
      await Future.delayed(const Duration(milliseconds: 200));
      
      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.hasValue, true);
      expect(asyncUser.value, isA<firebase_auth.User>());
      expect(asyncUser.value?.uid, 'test-uid');
      
      sub.close();
    });

    test('handles authentication state changes', () async {
      final mockUser = MockFirebaseUser();
      when(() => mockUser.uid).thenReturn('test-uid');
      
      // Test null state
      authStateController.add(null);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(firebaseUserProvider).value, isNull);
      
      // Test authenticated state
      authStateController.add(mockUser);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(firebaseUserProvider).hasValue, true);
      expect(container.read(firebaseUserProvider).value?.uid, 'test-uid');
      
      // Test back to null
      authStateController.add(null);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(container.read(firebaseUserProvider).value, isNull);
    });
  });

  group('currentUserProvider', () {
    test('emits null when user is not authenticated', () async {
      authStateController.add(null);
      
      // Give stream time to process
      await Future.delayed(const Duration(milliseconds: 200));
      
      final asyncUser = container.read(currentUserProvider);
      expect(asyncUser.value, isNull);
    });

    // test('emits UserModel when user document exists', () async {
    //   final mockUser = MockFirebaseUser();
    //   final mockDoc = MockDocumentSnapshot();
    //   
    //   when(() => mockUser.uid).thenReturn('test-uid');
    //   when(() => mockUser.email).thenReturn('test@example.com');
    //   when(() => mockUser.displayName).thenReturn('Test User');
    //   when(() => mockUser.photoURL).thenReturn(null);
    //   
    //   when(() => mockDoc.exists).thenReturn(true);
    //   when(() => mockDoc.id).thenReturn('test-uid');
    //   when(() => mockDoc.data()).thenReturn({
    //     'uid': 'test-uid',
    //     'email': 'test@example.com',
    //     'displayName': 'Test User',
    //     'photoURL': null,
    //     'isGuest': false,
    //     'preferences': {},
    //     'stats': {},
    //     'createdAt': DateTime.now().toIso8601String(),
    //   });
    //   
    //   when(() => mockAuthService.getUserDocument('test-uid'))
    //       .thenAnswer((_) async => mockDoc);
    //   
    //   authStateController.add(mockUser);
    //   
    //   final userModel = await container.read(currentUserProvider.future);
    //   expect(userModel, isNotNull);
    //   expect(userModel!.uid, 'test-uid');
    //   expect(userModel.email, 'test@example.com');
    //   expect(userModel.displayName, 'Test User');
    // });

    // test('creates UserModel when document does not exist initially', () async {
    //   final mockUser = MockFirebaseUser();
    //   final mockDoc = MockDocumentSnapshot();
    //   
    //   when(() => mockUser.uid).thenReturn('test-uid');
    //   when(() => mockUser.email).thenReturn('new@example.com');
    //   when(() => mockUser.displayName).thenReturn('New User');
    //   when(() => mockUser.photoURL).thenReturn(null);
    //   
    //   // First call returns non-existent doc
    //   when(() => mockDoc.exists).thenReturn(false);
    //   
    //   // Second call returns existing doc after creation
    //   final mockNewDoc = MockDocumentSnapshot();
    //   when(() => mockNewDoc.exists).thenReturn(true);
    //   when(() => mockNewDoc.id).thenReturn('test-uid');
    //   when(() => mockNewDoc.data()).thenReturn({
    //     'uid': 'test-uid',
    //     'email': 'new@example.com',
    //     'displayName': 'New User',
    //     'photoURL': null,
    //     'isGuest': false,
    //     'preferences': {},
    //     'stats': {},
    //     'createdAt': DateTime.now().toIso8601String(),
    //   });
    //   
    //   var callCount = 0;
    //   when(() => mockAuthService.getUserDocument('test-uid'))
    //       .thenAnswer((_) async {
    //         callCount++;
    //         if (callCount == 1) {
    //           return mockDoc;
    //         } else {
    //           return mockNewDoc;
    //         }
    //       });
    //   
    //   authStateController.add(mockUser);
    //   
    //   final userModel = await container.read(currentUserProvider.future);
    //   expect(userModel, isNotNull);
    //   expect(userModel!.uid, 'test-uid');
    //   expect(userModel.email, 'new@example.com');
    // });

    test('creates fallback UserModel when document creation fails', 
      timeout: const Timeout(Duration(seconds: 5)),
      () async {
      final mockUser = MockFirebaseUser();
      final mockDoc = MockDocumentSnapshot();
      
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('fallback@example.com');
      when(() => mockUser.displayName).thenReturn(null);
      when(() => mockUser.photoURL).thenReturn(null);
      
      // Document doesn't exist both times it's checked
      when(() => mockDoc.exists).thenReturn(false);
      
      // Mock getUserDocument to always return non-existent doc
      // (called twice in the provider when doc doesn't exist)
      when(() => mockAuthService.getUserDocument('test-uid'))
          .thenAnswer((_) async => mockDoc);
      
      // Listen to the provider to ensure it builds
      final sub = container.listen(currentUserProvider, (_, __) {});
      
      // First emit null to initialize, then the user
      authStateController.add(null);
      await Future.delayed(const Duration(milliseconds: 100));
      authStateController.add(mockUser);
      
      // Give time for stream to process
      await Future.delayed(const Duration(milliseconds: 500));
      
      final asyncUserModel = container.read(currentUserProvider);
      // The provider might be loading, but we can still check the value
      final userModel = asyncUserModel.valueOrNull;
      expect(userModel, isNotNull);
      expect(userModel!.uid, 'test-uid');
      expect(userModel.email, 'fallback@example.com');
      expect(userModel.displayName, 'GymBro User');
      expect(userModel.isGuest, false);
      
      sub.close();
    });

    test('handles errors by creating basic UserModel', 
      timeout: const Timeout(Duration(seconds: 5)),
      () async {
      final mockUser = MockFirebaseUser();
      
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.email).thenReturn('error@example.com');
      when(() => mockUser.displayName).thenReturn('Error User');
      when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
      
      when(() => mockAuthService.getUserDocument('test-uid'))
          .thenThrow(Exception('Database error'));
      
      // Listen to the provider to ensure it builds
      final sub = container.listen(currentUserProvider, (_, __) {});
      
      // First emit null to initialize, then the user
      authStateController.add(null);
      await Future.delayed(const Duration(milliseconds: 100));
      authStateController.add(mockUser);
      
      // Give time for stream to process
      await Future.delayed(const Duration(milliseconds: 500));
      
      final asyncUserModel = container.read(currentUserProvider);
      // The provider might be loading, but we can still check the value
      final userModel = asyncUserModel.valueOrNull;
      expect(userModel, isNotNull);
      expect(userModel!.uid, 'test-uid');
      expect(userModel.email, 'error@example.com');
      expect(userModel.displayName, 'Error User');
      expect(userModel.photoURL, 'https://example.com/photo.jpg');
      
      sub.close();
    });
  });

  group('authStateProvider', () {
    test('returns loading initially', () {
      // Don't emit any auth state yet
      final state = container.read(authStateProvider);
      expect(state, AuthState.loading);
    });

    test('returns authenticated when user exists', () async {
      final mockUser = MockFirebaseUser();
      when(() => mockUser.uid).thenReturn('test-uid');
      
      // Listen to firebaseUserProvider to ensure it builds
      final sub = container.listen(firebaseUserProvider, (_, __) {});
      
      // First emit null then the user to ensure the stream updates
      authStateController.add(null);
      await Future.delayed(const Duration(milliseconds: 50));
      authStateController.add(mockUser);
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Verify firebaseUserProvider has the user
      final firebaseUser = container.read(firebaseUserProvider);
      expect(firebaseUser.hasValue, true);
      expect(firebaseUser.value, mockUser);
      
      // Now check authStateProvider
      final state = container.read(authStateProvider);
      expect(state, AuthState.authenticated);
      
      sub.close();
    });

    test('returns unauthenticated when user is null', () async {
      // Listen to firebaseUserProvider to ensure it builds
      final sub = container.listen(firebaseUserProvider, (_, __) {});
      
      // Emit null value
      authStateController.add(null);
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Verify firebaseUserProvider has null
      final firebaseUser = container.read(firebaseUserProvider);
      expect(firebaseUser.hasValue, true);
      expect(firebaseUser.value, isNull);
      
      // Now check authStateProvider
      final state = container.read(authStateProvider);
      expect(state, AuthState.unauthenticated);
      
      sub.close();
    });

    test('returns unauthenticated on error', () async {
      authStateController.addError(Exception('Auth error'));
      
      // Give time for error to propagate
      await Future.delayed(const Duration(milliseconds: 100));
      
      // The firebaseUserProvider should be in error state
      final asyncUser = container.read(firebaseUserProvider);
      expect(asyncUser.hasError, true);
      
      final state = container.read(authStateProvider);
      expect(state, AuthState.unauthenticated);
    });
  });

  group('AuthController', () {
    test('initial state is AsyncValue.data(null)', () {
      final state = container.read(authControllerProvider);
      expect(state, const AsyncValue<void>.data(null));
    });

    group('registerWithEmailAndPassword', () {
      test('successfully registers user', () async {
        final controller = container.read(authControllerProvider.notifier);
        
        when(() => mockAuthService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        )).thenAnswer((_) async => MockUserCredential());
        
        await controller.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );
        
        final state = container.read(authControllerProvider);
        expect(state, const AsyncValue<void>.data(null));
        
        verify(() => mockAuthService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        )).called(1);
      });

      test('handles registration error', () async {
        final controller = container.read(authControllerProvider.notifier);
        final error = Exception('Registration failed');
        
        when(() => mockAuthService.registerWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        )).thenThrow(error);
        
        await controller.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );
        
        final state = container.read(authControllerProvider);
        expect(state.hasError, true);
        expect(state.error, error);
      });

      test('sets loading state during registration', () async {
        final controller = container.read(authControllerProvider.notifier);
        final completer = Completer<firebase_auth.UserCredential>();
        
        when(() => mockAuthService.registerWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) => completer.future);
        
        final future = controller.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );
        
        // Check loading state
        expect(container.read(authControllerProvider), const AsyncValue<void>.loading());
        
        // Complete registration
        completer.complete(MockUserCredential());
        await future;
        
        // Check final state
        expect(container.read(authControllerProvider), const AsyncValue<void>.data(null));
      });
    });

    group('signInWithEmailAndPassword', () {
      test('successfully signs in user', () async {
        final controller = container.read(authControllerProvider.notifier);
        
        when(() => mockAuthService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => MockUserCredential());
        
        await controller.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );
        
        final state = container.read(authControllerProvider);
        expect(state, const AsyncValue<void>.data(null));
        
        verify(() => mockAuthService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('handles sign in error', () async {
        final controller = container.read(authControllerProvider.notifier);
        final error = Exception('Invalid credentials');
        
        when(() => mockAuthService.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(error);
        
        await controller.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrong-password',
        );
        
        final state = container.read(authControllerProvider);
        expect(state.hasError, true);
        expect(state.error, error);
      });
    });

    group('signInWithGoogle', () {
      test('successfully signs in with Google', () async {
        final controller = container.read(authControllerProvider.notifier);
        
        when(() => mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => MockUserCredential());
        
        await controller.signInWithGoogle();
        
        final state = container.read(authControllerProvider);
        expect(state, const AsyncValue<void>.data(null));
        
        verify(() => mockAuthService.signInWithGoogle()).called(1);
      });

      test('handles Google sign in error', () async {
        final controller = container.read(authControllerProvider.notifier);
        final error = Exception('Google sign in failed');
        
        when(() => mockAuthService.signInWithGoogle()).thenThrow(error);
        
        await controller.signInWithGoogle();
        
        final state = container.read(authControllerProvider);
        expect(state.hasError, true);
        expect(state.error, error);
      });
    });

    group('signInWithApple', () {
      test('successfully signs in with Apple', () async {
        final controller = container.read(authControllerProvider.notifier);
        
        when(() => mockAuthService.signInWithApple())
            .thenAnswer((_) async => MockUserCredential());
        
        await controller.signInWithApple();
        
        final state = container.read(authControllerProvider);
        expect(state, const AsyncValue<void>.data(null));
        
        verify(() => mockAuthService.signInWithApple()).called(1);
      });

      test('handles Apple sign in error', () async {
        final controller = container.read(authControllerProvider.notifier);
        final error = Exception('Apple sign in failed');
        
        when(() => mockAuthService.signInWithApple()).thenThrow(error);
        
        await controller.signInWithApple();
        
        final state = container.read(authControllerProvider);
        expect(state.hasError, true);
        expect(state.error, error);
      });
    });

    group('signOut', () {
      test('successfully signs out user', () async {
        final controller = container.read(authControllerProvider.notifier);
        
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});
        
        await controller.signOut();
        
        final state = container.read(authControllerProvider);
        expect(state, const AsyncValue<void>.data(null));
        
        verify(() => mockAuthService.signOut()).called(1);
      });

      test('handles sign out error', () async {
        final controller = container.read(authControllerProvider.notifier);
        final error = Exception('Sign out failed');
        
        when(() => mockAuthService.signOut()).thenThrow(error);
        
        await controller.signOut();
        
        final state = container.read(authControllerProvider);
        expect(state.hasError, true);
        expect(state.error, error);
      });
    });

    group('sendPasswordResetEmail', () {
      test('successfully sends password reset email', () async {
        final controller = container.read(authControllerProvider.notifier);
        
        when(() => mockAuthService.sendPasswordResetEmail('test@example.com'))
            .thenAnswer((_) async {});
        
        await controller.sendPasswordResetEmail('test@example.com');
        
        final state = container.read(authControllerProvider);
        expect(state, const AsyncValue<void>.data(null));
        
        verify(() => mockAuthService.sendPasswordResetEmail('test@example.com')).called(1);
      });

      test('handles password reset error', () async {
        final controller = container.read(authControllerProvider.notifier);
        final error = Exception('User not found');
        
        when(() => mockAuthService.sendPasswordResetEmail(any())).thenThrow(error);
        
        await controller.sendPasswordResetEmail('nonexistent@example.com');
        
        final state = container.read(authControllerProvider);
        expect(state.hasError, true);
        expect(state.error, error);
      });
    });
  });

  group('AuthState enum', () {
    test('has correct values', () {
      expect(AuthState.values, [
        AuthState.loading,
        AuthState.authenticated,
        AuthState.unauthenticated,
      ]);
    });
  });
}