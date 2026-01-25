/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test/unit
/// 🎯 Feature: auth migration
/// 🔧 Type: unit test
/// 🌍 Localization: N/A - Test file
/// 🎨 Theme: N/A - Test file
/// 📱 Platform: Universal
/// 
/// CRITICAL UNIT TESTS for User Model Migration
/// Tests backwards compatibility and new UserProfile functionality
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

// Mocks
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockFirebaseUser extends Mock implements User {}
class MockTimestamp extends Mock implements Timestamp {}

// Test Factory for creating UserProfile instances
class UserProfileFactory {
  static UserProfile createFreeUser({
    String uid = 'test-free-user',
    String email = 'free@gymbro.app',
    String displayName = 'Free User',
    String? photoURL,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      accountTier: AccountTier.free,
      isGuest: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      templateQuota: const TemplateQuota(
        maxPrivateTemplates: 10,
        maxPublicTemplates: 5,
        usedPrivateTemplates: 0,
        usedPublicTemplates: 0,
      ),
      stats: const UserStats(
        totalWorkouts: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalVolume: 0,
        totalExercises: 0,
        achievements: {},
      ),
      preferences: const UserPreferences(
        language: 'en',
        theme: 'light',
        notificationsEnabled: true,
      ),
    );
  }

  static UserProfile createPremiumUser({
    String uid = 'test-premium-user',
    String email = 'premium@gymbro.app',
    String displayName = 'Premium User',
    String? photoURL,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      accountTier: AccountTier.premium,
      isGuest: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      templateQuota: const TemplateQuota(
        maxPrivateTemplates: 50,
        maxPublicTemplates: 25,
        usedPrivateTemplates: 0,
        usedPublicTemplates: 0,
      ),
      stats: const UserStats(
        totalWorkouts: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalVolume: 0,
        totalExercises: 0,
        achievements: {},
      ),
      preferences: const UserPreferences(
        language: 'en',
        theme: 'light',
        notificationsEnabled: true,
      ),
    );
  }
}

void main() {
  group('UserProfile Migration Tests', () {
    late MockDocumentSnapshot mockDoc;
    late MockFirebaseUser mockFirebaseUser;

    setUp(() {
      mockDoc = MockDocumentSnapshot();
      mockFirebaseUser = MockFirebaseUser();
    });

    group('Backwards Compatibility', () {
      test('should migrate old user document format to new UserProfile', () {
        // Arrange: Old format user document (pre-migration)
        final oldFormatData = {
          'uid': 'test-user-123',
          'email': 'test@gymbro.app',
          'displayName': 'Test User',
          'photoURL': null,
          'createdAt': Timestamp.now(),
          'lastLoginAt': Timestamp.now(),
          'isGuest': false,
          // OLD FORMAT: isPremium boolean instead of accountTier
          'isPremium': false,
          // OLD FORMAT: nested stats without template counts
          'stats': {
            'totalWorkouts': 15,
            'currentStreak': 3,
            'longestStreak': 7,
            'totalVolume': 12500.5,
            'totalExercises': 45,
            'achievements': {'first_workout': true},
          },
          // OLD FORMAT: preferences as simple map
          'preferences': {
            'language': 'en',
            'theme': 'dark',
            'notificationsEnabled': true,
          },
          // MISSING: templateQuota (should default)
        };

        when(() => mockDoc.id).thenReturn('test-user-123');
        when(() => mockDoc.data()).thenReturn(oldFormatData);
        when(() => mockDoc.exists).thenReturn(true);

        // Act: Parse with new system
        final profile = UserProfile.fromFirestore(mockDoc);

        // Assert: All fields migrated correctly
        expect(profile.uid, 'test-user-123');
        expect(profile.email, 'test@gymbro.app');
        expect(profile.displayName, 'Test User');
        expect(profile.accountTier, AccountTier.free); // isPremium: false -> free
        expect(profile.templateQuota.maxPrivateTemplates, 10); // Default for free tier
        expect(profile.stats.totalWorkouts, 15);
        expect(profile.preferences.language, 'en');
        expect(profile.isPremium, false);
      });

      test('should migrate premium user from old boolean to new accountTier', () {
        // Arrange: Old premium user
        final oldPremiumData = {
          'uid': 'premium-user-456',
          'email': 'premium@gymbro.app',
          'displayName': 'Premium User',
          'isPremium': true, // OLD FORMAT
          'stats': {
            'totalWorkouts': 50,
            'privateTemplateCount': 25, // OLD: separate counters
            'publicTemplateCount': 5,
          },
        };

        when(() => mockDoc.id).thenReturn('premium-user-456');
        when(() => mockDoc.data()).thenReturn(oldPremiumData);
        when(() => mockDoc.exists).thenReturn(true);

        // Act
        final profile = UserProfile.fromFirestore(mockDoc);

        // Assert: Premium status correctly migrated
        expect(profile.accountTier, AccountTier.premium); // Auto-detected from isPremium
        expect(profile.isPremium, true);
        expect(profile.templateQuota.maxPrivateTemplates, 50); // Premium limits
        expect(profile.templateQuota.usedPrivateTemplates, 25); // Migrated from old stats
        expect(profile.templateQuota.usedPublicTemplates, 5);
      });

      test('should handle completely missing fields gracefully', () {
        // Arrange: Minimal document (edge case)
        final minimalData = {
          'uid': 'minimal-user',
          'email': 'minimal@gymbro.app',
          // Missing almost everything else
        };

        when(() => mockDoc.id).thenReturn('minimal-user');
        when(() => mockDoc.data()).thenReturn(minimalData);
        when(() => mockDoc.exists).thenReturn(true);

        // Act
        final profile = UserProfile.fromFirestore(mockDoc);

        // Assert: Sensible defaults applied
        expect(profile.uid, 'minimal-user');
        expect(profile.displayName, 'GymBro User'); // Default
        expect(profile.accountTier, AccountTier.free); // Default
        expect(profile.templateQuota.maxPrivateTemplates, 10); // Free tier default
        expect(profile.stats.totalWorkouts, 0); // Default
        expect(profile.preferences.language, null); // Default
      });

      test('should throw exception for null document data', () {
        // Arrange: Null document data (error case)
        when(() => mockDoc.id).thenReturn('null-user');
        when(() => mockDoc.data()).thenReturn(null);
        when(() => mockDoc.exists).thenReturn(true);

        // Act & Assert: Should throw exception
        expect(
          () => UserProfile.fromFirestore(mockDoc),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Document data is null'),
          )),
        );
      });
    });

    group('UserProfile.fromFirebaseUser', () {
      test('should create profile from Firebase user for new users', () {
        // Arrange
        when(() => mockFirebaseUser.uid).thenReturn('new-firebase-user');
        when(() => mockFirebaseUser.email).thenReturn('new@gymbro.app');
        when(() => mockFirebaseUser.displayName).thenReturn('New User');
        when(() => mockFirebaseUser.photoURL).thenReturn('https://photo.url');
        when(() => mockFirebaseUser.isAnonymous).thenReturn(false);

        // Act
        final profile = UserProfile.fromFirebaseUser(mockFirebaseUser);

        // Assert
        expect(profile.uid, 'new-firebase-user');
        expect(profile.email, 'new@gymbro.app');
        expect(profile.displayName, 'New User');
        expect(profile.photoURL, 'https://photo.url');
        expect(profile.isGuest, false);
        expect(profile.accountTier, AccountTier.free); // Default for new users
        expect(profile.templateQuota.maxPrivateTemplates, 10); // Free tier
      });

      test('should handle anonymous users correctly', () {
        // Arrange: Anonymous user
        when(() => mockFirebaseUser.uid).thenReturn('anon-user-123');
        when(() => mockFirebaseUser.email).thenReturn(null); // Anonymous users have no email
        when(() => mockFirebaseUser.displayName).thenReturn(null);
        when(() => mockFirebaseUser.photoURL).thenReturn(null);
        when(() => mockFirebaseUser.isAnonymous).thenReturn(true);

        // Act
        final profile = UserProfile.fromFirebaseUser(mockFirebaseUser);

        // Assert: Anonymous user handled correctly
        expect(profile.uid, 'anon-user-123');
        expect(profile.email, ''); // Empty string for null email
        expect(profile.displayName, 'GymBro User'); // Default
        expect(profile.isGuest, true); // Anonymous = guest
      });
    });

    group('Template Quota Management', () {
      test('should calculate quota correctly for each tier', () {
        // Free tier
        final freeQuota = TemplateQuota.forTier(AccountTier.free);
        expect(freeQuota.maxPrivateTemplates, 10);
        expect(freeQuota.maxPublicTemplates, 2);

        // Premium tier
        final premiumQuota = TemplateQuota.forTier(AccountTier.premium);
        expect(premiumQuota.maxPrivateTemplates, 50);
        expect(premiumQuota.maxPublicTemplates, 10);

        // Pro tier
        final proQuota = TemplateQuota.forTier(AccountTier.pro);
        expect(proQuota.maxPrivateTemplates, 999);
        expect(proQuota.maxPublicTemplates, 999);
      });

      test('should track template usage correctly', () {
        // Arrange
        final baseProfile = UserProfileFactory.createFreeUser();
        
        // Act: Add private template
        final afterPrivate = baseProfile.incrementTemplateUsage(isPublic: false);
        
        // Assert
        expect(afterPrivate.templateQuota.usedPrivateTemplates, 1);
        expect(afterPrivate.templateQuota.usedPublicTemplates, 0);
        
        // Act: Add public template
        final afterPublic = afterPrivate.incrementTemplateUsage(isPublic: true);
        
        // Assert
        expect(afterPublic.templateQuota.usedPrivateTemplates, 1);
        expect(afterPublic.templateQuota.usedPublicTemplates, 1);
      });

      test('should prevent decrementing below zero', () {
        // Arrange: Profile with no templates
        final profile = UserProfileFactory.createFreeUser();
        
        // Act: Try to decrement (should clamp to 0)
        final afterDecrement = profile.decrementTemplateUsage(isPublic: false);
        
        // Assert: Should stay at 0
        expect(afterDecrement.templateQuota.usedPrivateTemplates, 0);
      });

      test('should check quota limits correctly', () {
        // Arrange: Free user near limit
        final quota = TemplateQuota.forTier(
          AccountTier.free, 
          usedPrivate: 9, // Near limit of 10
          usedPublic: 2,  // At limit of 2
        );
        
        // Assert
        expect(quota.canSavePrivate, true);  // 9 < 10
        expect(quota.canSavePublic, false);  // 2 >= 2
        expect(quota.remainingPrivate, 1);
        expect(quota.remainingPublic, 0);
      });
    });

    group('UserProfile Serialization', () {
      test('should serialize and deserialize consistently', () {
        // Arrange: Complex profile
        final original = UserProfile(
          uid: 'test-uid',
          email: 'test@gymbro.app',
          displayName: 'Test User',
          photoURL: 'https://photo.url',
          accountTier: AccountTier.premium,
          templateQuota: TemplateQuota.forTier(AccountTier.premium, usedPrivate: 5),
          createdAt: DateTime(2024, 1, 1),
          lastLoginAt: DateTime(2024, 12, 25),
          isGuest: false,
          preferences: const UserPreferences(
            language: 'it',
            theme: 'dark',
            notificationsEnabled: false,
            customSettings: {'advanced': true},
          ),
          stats: const UserStats(
            totalWorkouts: 100,
            currentStreak: 5,
            longestStreak: 20,
            totalVolume: 50000.0,
            totalExercises: 200,
            achievements: {'badge_100_workouts': true},
          ),
        );

        // Act: Serialize to Firestore format
        final firestoreData = original.toFirestore();
        
        // Mock document with serialized data
        when(() => mockDoc.id).thenReturn('test-uid');
        when(() => mockDoc.data()).thenReturn(firestoreData);
        when(() => mockDoc.exists).thenReturn(true);
        
        // Deserialize back
        final deserialized = UserProfile.fromFirestore(mockDoc);

        // Assert: Should be identical
        expect(deserialized.uid, original.uid);
        expect(deserialized.email, original.email);
        expect(deserialized.accountTier, original.accountTier);
        expect(deserialized.templateQuota.usedPrivateTemplates, 5);
        expect(deserialized.preferences.language, 'it');
        expect(deserialized.stats.totalWorkouts, 100);
      });
    });
  });
}