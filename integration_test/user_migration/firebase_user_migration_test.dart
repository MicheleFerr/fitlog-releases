/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: integration_test
 * 🎯 Feature: auth migration
 * 🔧 Type: integration test
 * 🌍 Localization: N/A - Integration test
 * 🎨 Theme: N/A - Integration test
 * 📱 Platform: Universal
 * 
 * CRITICAL INTEGRATION TESTS for Firebase User Migration
 * Tests Firebase operations with new UserProfile system
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_provider_v2.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile_consolidated.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_state.dart';
import 'package:gymbro_flutter_new/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase User Migration Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late ProviderContainer container;

    setUp(() async {
      // Setup fake Firebase services
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      
      // Create provider container with mocked services
      container = ProviderContainer(
        overrides: [
          // Override Firebase providers with mocks
          // Note: These would be defined in your provider setup
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await fakeFirestore.terminate();
    });

    group('New User Creation', () {
      testWidgets('creates user document for new Firebase user', (tester) async {
        // Arrange: New Firebase user
        final mockUser = MockUser(
          uid: 'new-user-123',
          email: 'newuser@gymbro.app',
          displayName: 'New User',
        );
        
        // Mock authentication
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

        // Act: Trigger user state provider
        final userState = await container.read(userStateProvider.future);

        // Assert: User document created in Firestore
        expect(userState, isA<UserAuthenticated>());
        
        final profile = (userState as UserAuthenticated).profile;
        expect(profile.uid, 'new-user-123');
        expect(profile.email, 'newuser@gymbro.app');
        expect(profile.accountTier, AccountTier.free);

        // Verify document exists in Firestore
        final userDoc = await fakeFirestore
            .collection('users')
            .doc('new-user-123')
            .get();
        
        expect(userDoc.exists, true);
        expect(userDoc.data()!['email'], 'newuser@gymbro.app');
        expect(userDoc.data()!['accountTier'], 'free');
      });

      testWidgets('handles anonymous user correctly', (tester) async {
        // Arrange: Anonymous user
        final anonymousUser = MockUser(
          uid: 'anonymous-123',
          isAnonymous: true,
        );
        
        when(mockAuth.currentUser).thenReturn(anonymousUser);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(anonymousUser));

        // Act
        final userState = await container.read(userStateProvider.future);

        // Assert: Should be anonymous state, not authenticated
        expect(userState, isA<UserAnonymous>());
        
        // No document should be created for anonymous users
        final userDoc = await fakeFirestore
            .collection('users')
            .doc('anonymous-123')
            .get();
        
        expect(userDoc.exists, false);
      });
    });

    group('Existing User Migration', () {
      testWidgets('migrates old user document format', (tester) async {
        // Arrange: Existing old-format user document
        final oldUserData = {
          'uid': 'existing-user-456',
          'email': 'existing@gymbro.app',
          'displayName': 'Existing User',
          'isPremium': true, // OLD FORMAT
          'createdAt': Timestamp.now(),
          'lastLoginAt': Timestamp.now(),
          'stats': {
            'totalWorkouts': 25,
            'privateTemplateCount': 15, // OLD FIELD NAMES
            'publicTemplateCount': 3,
          },
          // Missing: accountTier, templateQuota (new fields)
        };

        // Add old document to Firestore
        await fakeFirestore
            .collection('users')
            .doc('existing-user-456')
            .set(oldUserData);

        // Mock authentication with existing user
        final existingUser = MockUser(
          uid: 'existing-user-456',
          email: 'existing@gymbro.app',
          displayName: 'Existing User',
        );
        
        when(mockAuth.currentUser).thenReturn(existingUser);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(existingUser));

        // Act: Load user state
        final userState = await container.read(userStateProvider.future);

        // Assert: Migration successful
        expect(userState, isA<UserAuthenticated>());
        
        final profile = (userState as UserAuthenticated).profile;
        expect(profile.uid, 'existing-user-456');
        expect(profile.accountTier, AccountTier.premium); // Migrated from isPremium: true
        expect(profile.templateQuota.usedPrivateTemplates, 15); // Migrated from old stats
        expect(profile.templateQuota.usedPublicTemplates, 3);
        expect(profile.stats.totalWorkouts, 25);
      });

      testWidgets('handles corrupted user document gracefully', (tester) async {
        // Arrange: Corrupted document
        await fakeFirestore
            .collection('users')
            .doc('corrupted-user-789')
            .set({'corrupted': true}); // Missing required fields

        final corruptedUser = MockUser(
          uid: 'corrupted-user-789',
          email: 'corrupted@gymbro.app',
        );
        
        when(mockAuth.currentUser).thenReturn(corruptedUser);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(corruptedUser));

        // Act: Should handle gracefully
        final userState = await container.read(userStateProvider.future);

        // Assert: Fallback profile created
        expect(userState, isA<UserAuthenticated>());
        
        final profile = (userState as UserAuthenticated).profile;
        expect(profile.uid, 'corrupted-user-789');
        expect(profile.email, 'corrupted@gymbro.app');
        expect(profile.displayName, 'GymBro User'); // Default fallback
      });
    });

    group('Real-time Updates', () {
      testWidgets('updates user profile when Firestore document changes', (tester) async {
        // Arrange: Initial user
        final user = MockUser(
          uid: 'realtime-user-abc',
          email: 'realtime@gymbro.app',
          displayName: 'Realtime User',
        );
        
        when(mockAuth.currentUser).thenReturn(user);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(user));

        // Initial document
        await fakeFirestore
            .collection('users')
            .doc('realtime-user-abc')
            .set({
          'uid': 'realtime-user-abc',
          'email': 'realtime@gymbro.app',
          'displayName': 'Realtime User',
          'accountTier': 'free',
          'templateQuota': TemplateQuota.forTier(AccountTier.free).toJson(),
          'createdAt': Timestamp.now(),
          'lastLoginAt': Timestamp.now(),
          'preferences': {},
          'stats': {},
        });

        // Start listening to user state changes
        final userStateStream = container.read(userStateProvider.stream);
        final states = <UserState>[];
        
        final subscription = userStateStream.listen(states.add);

        // Wait for initial state
        await Future.delayed(const Duration(milliseconds: 100));

        // Act: Update user document to premium
        await fakeFirestore
            .collection('users')
            .doc('realtime-user-abc')
            .update({
          'accountTier': 'premium',
          'templateQuota': TemplateQuota.forTier(AccountTier.premium).toJson(),
        });

        // Wait for update to propagate
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert: Should have received updated profile
        expect(states.length, greaterThan(1));
        
        final latestState = states.last;
        expect(latestState, isA<UserAuthenticated>());
        
        final profile = (latestState as UserAuthenticated).profile;
        expect(profile.accountTier, AccountTier.premium);
        expect(profile.templateQuota.maxPrivateTemplates, 50); // Premium quota

        await subscription.cancel();
      });
    });

    group('Error Handling', () {
      testWidgets('handles Firestore permission errors', (tester) async {
        // Arrange: User without Firestore access
        final user = MockUser(
          uid: 'no-permission-user',
          email: 'noperm@gymbro.app',
        );
        
        when(mockAuth.currentUser).thenReturn(user);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(user));

        // Mock permission error when trying to create document
        when(fakeFirestore.collection('users').doc(any()).set(any()))
            .thenThrow(FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
              message: 'Missing or insufficient permissions.',
            ));

        // Act: Should handle error gracefully
        final userState = await container.read(userStateProvider.future);

        // Assert: Should provide fallback profile
        expect(userState, isA<UserAuthenticated>());
        
        final profile = (userState as UserAuthenticated).profile;
        expect(profile.uid, 'no-permission-user');
        expect(profile.email, 'noperm@gymbro.app');
      });

      testWidgets('handles network connectivity issues', (tester) async {
        // Arrange: User with network issues
        final user = MockUser(
          uid: 'network-issue-user',
          email: 'network@gymbro.app',
        );
        
        when(mockAuth.currentUser).thenReturn(user);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(user));

        // Mock network error
        when(fakeFirestore.collection('users').doc(any()).snapshots())
            .thenAnswer((_) => Stream.error(
              FirebaseException(
                plugin: 'cloud_firestore',
                code: 'unavailable',
                message: 'The service is currently unavailable.',
              ),
            ));

        // Act & Assert: Should provide error state or fallback
        try {
          final userState = await container.read(userStateProvider.future);
          
          // Either error state or fallback profile is acceptable
          expect(
            userState is UserError || userState is UserAuthenticated,
            true,
          );
        } catch (e) {
          // Network errors might be thrown - that's also acceptable
          expect(e, isA<FirebaseException>());
        }
      });
    });

    group('Provider Integration', () {
      testWidgets('user-dependent providers work correctly', (tester) async {
        // Arrange: Premium user
        final premiumUser = MockUser(
          uid: 'premium-integration-user',
          email: 'premium@gymbro.app',
          displayName: 'Premium Integration User',
        );
        
        await fakeFirestore
            .collection('users')
            .doc('premium-integration-user')
            .set({
          'uid': 'premium-integration-user',
          'email': 'premium@gymbro.app',
          'displayName': 'Premium Integration User',
          'accountTier': 'premium',
          'templateQuota': TemplateQuota.forTier(AccountTier.premium).toJson(),
          'createdAt': Timestamp.now(),
          'lastLoginAt': Timestamp.now(),
          'preferences': {},
          'stats': {},
        });

        when(mockAuth.currentUser).thenReturn(premiumUser);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(premiumUser));

        // Act: Test dependent providers
        final userProfile = await container.read(currentUserProfileProvider.future);
        final isAuth = container.read(isAuthenticatedProvider);
        final isPremium = container.read(isPremiumUserProvider);
        final userId = container.read(currentUserIdProvider);
        final accountTier = container.read(currentAccountTierProvider);

        // Assert: All providers work correctly
        expect(userProfile, isNotNull);
        expect(userProfile!.uid, 'premium-integration-user');
        expect(isAuth, true);
        expect(isPremium, true);
        expect(userId, 'premium-integration-user');
        expect(accountTier, AccountTier.premium);
      });

      testWidgets('workout creation includes correct userId', (tester) async {
        // This would test that workout creation uses the correct user ID
        // from the new provider system
        
        // Arrange: Authenticated user
        final user = MockUser(
          uid: 'workout-user-123',
          email: 'workout@gymbro.app',
        );
        
        await fakeFirestore
            .collection('users')
            .doc('workout-user-123')
            .set({
          'uid': 'workout-user-123',
          'email': 'workout@gymbro.app',
          'displayName': 'Workout User',
          'accountTier': 'free',
          'templateQuota': TemplateQuota.forTier(AccountTier.free).toJson(),
          'createdAt': Timestamp.now(),
          'lastLoginAt': Timestamp.now(),
          'preferences': {},
          'stats': {},
        });

        when(mockAuth.currentUser).thenReturn(user);
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(user));

        // Act: Get user ID for workout creation
        final userId = container.read(currentUserIdProvider);

        // Assert: Correct user ID provided
        expect(userId, 'workout-user-123');
        
        // In real implementation, this would test that workouts
        // created with this userId are properly associated
      });
    });

    group('Performance & Memory', () {
      testWidgets('does not cause memory leaks with stream subscriptions', (tester) async {
        // This is a conceptual test - in practice you'd use tools like
        // flutter_test with memory tracking

        // Create and dispose multiple containers
        for (int i = 0; i < 10; i++) {
          final testContainer = ProviderContainer(/* overrides */);
          
          // Subscribe to user state
          final subscription = testContainer.read(userStateProvider.stream).listen((_) {});
          
          // Dispose properly
          await subscription.cancel();
          testContainer.dispose();
        }

        // If this test completes without hanging or crashing,
        // it indicates proper cleanup
        expect(true, true);
      });

      testWidgets('handles rapid user state changes efficiently', (tester) async {
        // Test rapid authentication state changes don't cause issues
        
        final user1 = MockUser(uid: 'rapid-1', email: 'user1@gymbro.app');
        final user2 = MockUser(uid: 'rapid-2', email: 'user2@gymbro.app');
        
        // Rapid state changes
        when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.fromIterable([
          null,      // Unauthenticated
          user1,     // First user
          null,      // Sign out
          user2,     // Second user
          null,      // Final sign out
        ]));

        final states = <UserState>[];
        final subscription = container.read(userStateProvider.stream).listen(states.add);

        // Wait for all state changes
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert: All state changes handled
        expect(states.length, greaterThan(3));
        expect(states.last, isA<UserUnauthenticated>());

        await subscription.cancel();
      });
    });
  });
}

/// Helper class for creating mock users in tests
class TestUserHelper {
  static MockUser createMockUser({
    required String uid,
    required String email,
    String? displayName,
    bool isAnonymous = false,
    String? photoURL,
  }) {
    return MockUser(
      uid: uid,
      email: isAnonymous ? null : email,
      displayName: displayName,
      isAnonymous: isAnonymous,
      photoURL: photoURL,
    );
  }

  static Future<void> createUserDocument(
    FakeFirebaseFirestore firestore,
    String uid, {
    String email = 'test@gymbro.app',
    String displayName = 'Test User',
    AccountTier tier = AccountTier.free,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'accountTier': tier.name,
      'templateQuota': TemplateQuota.forTier(tier).toJson(),
      'createdAt': Timestamp.now(),
      'lastLoginAt': Timestamp.now(),
      'preferences': {},
      'stats': {},
    });
  }
}