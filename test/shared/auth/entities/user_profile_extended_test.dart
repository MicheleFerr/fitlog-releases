/// Extended UserProfile tests - covering toFirestore, fromFirestore,
/// and edge cases not covered by user_profile_test.dart.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // ---------------------------------------------------------------------------
  // UserProfile toJson - debug overrides
  // ---------------------------------------------------------------------------
  group('UserProfile toJson with debug overrides', () {
    test('omits debug keys when all overrides are null', () {
      final profile = UserProfile(
        uid: 'u-1',
        email: 'test@test.com',
        displayName: 'Test',
        accountTier: AccountTier.free,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
      );

      final json = profile.toJson();

      expect(json.containsKey('debugTierOverride'), isFalse);
      expect(json.containsKey('debugAccountOverride'), isFalse);
      expect(json.containsKey('debugXPOverride'), isFalse);
    });

    test('includes debugAccountOverride when set', () {
      final profile = UserProfile(
        uid: 'u-1',
        email: 'test@test.com',
        displayName: 'Test',
        accountTier: AccountTier.free,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        debugAccountOverride: AccountTier.premium,
      );

      final json = profile.toJson();

      expect(json['debugAccountOverride'], 'premium');
    });

    test('includes all debug overrides when set', () {
      final profile = UserProfile(
        uid: 'u-1',
        email: 'test@test.com',
        displayName: 'Test',
        accountTier: AccountTier.free,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        debugTierOverride: UserTier.gold,
        debugAccountOverride: AccountTier.premium,
        debugXPOverride: 2000,
      );

      final json = profile.toJson();

      expect(json['debugTierOverride'], 'gold');
      expect(json['debugAccountOverride'], 'premium');
      expect(json['debugXPOverride'], 2000);
    });
  });

  // ---------------------------------------------------------------------------
  // UserProfile toFirestore
  // ---------------------------------------------------------------------------
  group('UserProfile toFirestore', () {
    test('basic profile - contains all required keys with Timestamp dates', () {
      final profile = UserProfile(
        uid: 'u-1',
        email: 'user@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.free,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
          usedPrivateTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        preferences: {'theme': 'dark'},
        stats: {'workoutCount': 10},
        isGuest: false,
        isAdmin: false,
      );

      final data = profile.toFirestore();

      expect(data['uid'], 'u-1');
      expect(data['email'], 'user@example.com');
      expect(data['displayName'], 'Test User');
      expect(data['accountTier'], 'free');
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['lastLoginAt'], isA<Timestamp>());
      expect(data['preferences'], {'theme': 'dark'});
      expect(data['stats'], {'workoutCount': 10});
      expect(data['isGuest'], false);
      expect(data['isAdmin'], false);
      expect(data['templateQuota'], isNotNull);

      // No debug overrides
      expect(data.containsKey('debugTierOverride'), isFalse);
      expect(data.containsKey('debugAccountOverride'), isFalse);
      expect(data.containsKey('debugXPOverride'), isFalse);
    });

    test('admin profile includes photoURL and debug overrides', () {
      final profile = UserProfile(
        uid: 'admin-1',
        email: 'admin@example.com',
        displayName: 'Admin',
        photoURL: 'https://example.com/photo.jpg',
        accountTier: AccountTier.premium,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 999,
          maxPublicTemplates: 999,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        isAdmin: true,
        debugTierOverride: UserTier.platinum,
        debugAccountOverride: AccountTier.premium,
        debugXPOverride: 10000,
      );

      final data = profile.toFirestore();

      expect(data['photoURL'], 'https://example.com/photo.jpg');
      expect(data['accountTier'], 'premium');
      expect(data['isAdmin'], true);
      expect(data['debugTierOverride'], 'platinum');
      expect(data['debugAccountOverride'], 'premium');
      expect(data['debugXPOverride'], 10000);
    });

    test('premium profile - accountTier is premium', () {
      final profile = UserProfile(
        uid: 'u-2',
        email: 'premium@example.com',
        displayName: 'Premium User',
        accountTier: AccountTier.premium,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 999,
          maxPublicTemplates: 999,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
      );

      final data = profile.toFirestore();

      expect(data['accountTier'], 'premium');
    });
  });

  // ---------------------------------------------------------------------------
  // UserProfile fromFirestore
  // ---------------------------------------------------------------------------
  group('UserProfile fromFirestore', () {
    test('parses full profile from Firestore', () async {
      final createdAt = DateTime(2024, 1, 1);
      final lastLoginAt = DateTime(2024, 6, 1);

      final ref = fakeFirestore.collection('users').doc('u-1');
      await ref.set({
        'email': 'user@example.com',
        'displayName': 'Test User',
        'photoURL': 'https://example.com/photo.jpg',
        'accountTier': 'premium',
        'templateQuota': {
          'maxPrivateTemplates': 999,
          'maxPublicTemplates': 999,
          'usedPrivateTemplates': 5,
          'usedPublicTemplates': 2,
        },
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLoginAt': Timestamp.fromDate(lastLoginAt),
        'preferences': {'dayCutoffHour': 5},
        'stats': {'workoutCount': 50},
        'isGuest': false,
        'isAdmin': true,
        'debugTierOverride': 'gold',
        'debugAccountOverride': 'premium',
        'debugXPOverride': 1500,
      });

      final snap = await ref.get();
      final profile = UserProfile.fromFirestore(snap);

      expect(profile.uid, 'u-1'); // uses doc.id
      expect(profile.email, 'user@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.photoURL, 'https://example.com/photo.jpg');
      expect(profile.accountTier, AccountTier.premium);
      expect(profile.templateQuota.maxPrivateTemplates, 999);
      expect(profile.templateQuota.usedPrivateTemplates, 5);
      expect(profile.isAdmin, true);
      expect(profile.dayCutoffHour, 5);
      expect(profile.debugTierOverride, UserTier.gold);
      expect(profile.debugAccountOverride, AccountTier.premium);
      expect(profile.debugXPOverride, 1500);
    });

    test('parses profile without templateQuota using backward compat', () async {
      final ref = fakeFirestore.collection('users').doc('u-2');
      await ref.set({
        'email': 'user2@example.com',
        'displayName': 'User 2',
        'accountTier': 'free',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'lastLoginAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
        'stats': {
          'privateTemplateCount': 3,
          'publicTemplateCount': 1,
        },
        'isGuest': false,
        'isAdmin': false,
      });

      final snap = await ref.get();
      final profile = UserProfile.fromFirestore(snap);

      // Should fall back to forTier with used counts from stats
      expect(profile.templateQuota.usedPrivateTemplates, 3);
      expect(profile.templateQuota.usedPublicTemplates, 1);
    });

    test('handles minimal document with all defaults', () async {
      final ref = fakeFirestore.collection('users').doc('u-3');
      await ref.set({
        'email': '',
      });

      final snap = await ref.get();
      final profile = UserProfile.fromFirestore(snap);

      expect(profile.uid, 'u-3');
      expect(profile.email, '');
      expect(profile.displayName, 'GymBro User');
      expect(profile.accountTier, AccountTier.free);
      expect(profile.isGuest, false);
      expect(profile.isAdmin, false);
      expect(profile.debugTierOverride, isNull);
      expect(profile.debugAccountOverride, isNull);
      expect(profile.debugXPOverride, isNull);
    });

    test('handles unknown accountTier string as free', () async {
      final ref = fakeFirestore.collection('users').doc('u-4');
      await ref.set({
        'email': 'user@example.com',
        'displayName': 'User',
        'accountTier': 'enterprise', // unknown tier
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'lastLoginAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
        'isGuest': false,
        'isAdmin': false,
      });

      final snap = await ref.get();
      final profile = UserProfile.fromFirestore(snap);

      expect(profile.accountTier, AccountTier.free);
    });

    test('handles unknown debugTierOverride as starter', () async {
      final ref = fakeFirestore.collection('users').doc('u-5');
      await ref.set({
        'email': 'admin@example.com',
        'displayName': 'Admin',
        'accountTier': 'free',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'lastLoginAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
        'isGuest': false,
        'isAdmin': true,
        'debugTierOverride': 'legendaryTier', // invalid
      });

      final snap = await ref.get();
      final profile = UserProfile.fromFirestore(snap);

      expect(profile.debugTierOverride, UserTier.starter);
    });

    test('handles unknown debugAccountOverride as free', () async {
      final ref = fakeFirestore.collection('users').doc('u-6');
      await ref.set({
        'email': 'admin@example.com',
        'displayName': 'Admin',
        'accountTier': 'free',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'lastLoginAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
        'isGuest': false,
        'isAdmin': true,
        'debugAccountOverride': 'enterprise', // invalid
      });

      final snap = await ref.get();
      final profile = UserProfile.fromFirestore(snap);

      expect(profile.debugAccountOverride, AccountTier.free);
    });
  });

  // ---------------------------------------------------------------------------
  // UserProfile.fromJson - additional edge cases
  // ---------------------------------------------------------------------------
  group('UserProfile fromJson additional edge cases', () {
    test('handles unknown accountTier as free', () {
      final json = {
        'uid': 'u-1',
        'email': 'test@test.com',
        'displayName': 'Test',
        'accountTier': 'enterprise',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'lastLoginAt': DateTime(2024, 6, 1).toIso8601String(),
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.accountTier, AccountTier.free);
    });

    test('handles unknown debugTierOverride as starter', () {
      final json = {
        'uid': 'u-1',
        'email': 'test@test.com',
        'displayName': 'Test',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'lastLoginAt': DateTime(2024, 6, 1).toIso8601String(),
        'debugTierOverride': 'invalid_tier',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.debugTierOverride, UserTier.starter);
    });

    test('handles unknown debugAccountOverride as free', () {
      final json = {
        'uid': 'u-1',
        'email': 'test@test.com',
        'displayName': 'Test',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'lastLoginAt': DateTime(2024, 6, 1).toIso8601String(),
        'debugAccountOverride': 'vip',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.debugAccountOverride, AccountTier.free);
    });
  });

  // ---------------------------------------------------------------------------
  // UserProfile copyWith - edge cases
  // ---------------------------------------------------------------------------
  group('UserProfile copyWith edge cases', () {
    test('preserves all unchanged fields', () {
      final original = UserProfile(
        uid: 'u-1',
        email: 'test@test.com',
        displayName: 'Test',
        photoURL: 'https://example.com/photo.jpg',
        accountTier: AccountTier.premium,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 999,
          maxPublicTemplates: 999,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        preferences: {'theme': 'dark'},
        stats: {'workouts': 100},
        isGuest: false,
        isAdmin: true,
        debugTierOverride: UserTier.platinum,
        debugAccountOverride: AccountTier.premium,
        debugXPOverride: 9999,
      );

      final copy = original.copyWith(displayName: 'New Name');

      expect(copy.uid, 'u-1');
      expect(copy.email, 'test@test.com');
      expect(copy.displayName, 'New Name');
      expect(copy.photoURL, 'https://example.com/photo.jpg');
      expect(copy.accountTier, AccountTier.premium);
      expect(copy.isAdmin, true);
      expect(copy.debugTierOverride, UserTier.platinum);
      expect(copy.debugXPOverride, 9999);
    });

    test('can update multiple fields at once', () {
      final profile = UserProfile(
        uid: 'u-1',
        email: 'old@test.com',
        displayName: 'Old',
        accountTier: AccountTier.free,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
      );

      final updated = profile.copyWith(
        email: 'new@test.com',
        displayName: 'New',
        accountTier: AccountTier.premium,
        isAdmin: true,
      );

      expect(updated.email, 'new@test.com');
      expect(updated.displayName, 'New');
      expect(updated.accountTier, AccountTier.premium);
      expect(updated.isAdmin, true);
    });
  });

  // ---------------------------------------------------------------------------
  // UserProfile updateDayCutoffHour
  // ---------------------------------------------------------------------------
  group('UserProfile updateDayCutoffHour', () {
    UserProfile makeProfile({Map<String, dynamic>? preferences}) {
      return UserProfile(
        uid: 'u-1',
        email: 'test@test.com',
        displayName: 'Test',
        accountTier: AccountTier.free,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        preferences: preferences ?? {},
      );
    }

    test('updates cutoff hour and preserves other preferences', () {
      final profile = makeProfile(preferences: {'theme': 'dark', 'dayCutoffHour': 4});
      final updated = profile.updateDayCutoffHour(6);

      expect(updated.dayCutoffHour, 6);
      expect(updated.preferences['theme'], 'dark');
    });

    test('adds cutoff hour to empty preferences', () {
      final profile = makeProfile();
      final updated = profile.updateDayCutoffHour(3);

      expect(updated.dayCutoffHour, 3);
    });

    test('does not mutate original preferences map', () {
      final profile = makeProfile();
      profile.updateDayCutoffHour(5);

      // Original preferences should not have dayCutoffHour
      expect(profile.preferences.containsKey('dayCutoffHour'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // TemplateQuota.consolidated edge cases
  // ---------------------------------------------------------------------------
  group('TemplateQuota consolidated XP beats account', () {
    test('platinum XP tier beats free account tier', () {
      final quota = TemplateQuota.consolidated(
        userTier: UserTier.platinum,
        accountTier: AccountTier.free,
        usedPrivate: 1,
        usedPublic: 0,
      );

      // Platinum gives 7 templates, free gives 4 - platinum wins
      expect(quota.maxPrivateTemplates, UserTier.platinum.maxTemplates); // 7
      expect(quota.maxPublicTemplates, UserTier.platinum.maxPublicTemplates); // 5
      expect(quota.usedPrivateTemplates, 1);
    });

    test('starter XP + premium account - premium wins on both limits', () {
      final quota = TemplateQuota.consolidated(
        userTier: UserTier.starter, // 4 private, 2 public
        accountTier: AccountTier.premium, // 999 private, 999 public
      );

      expect(quota.maxPrivateTemplates, 999);
      expect(quota.maxPublicTemplates, 999);
    });

    test('silver XP + free account - silver wins where higher', () {
      final quota = TemplateQuota.consolidated(
        userTier: UserTier.silver, // 5 private, 3 public
        accountTier: AccountTier.free, // 4 private, 2 public
      );

      // Silver (5) > Free (4)
      expect(quota.maxPrivateTemplates, UserTier.silver.maxTemplates); // 5
      // Silver (3) > Free (2)
      expect(quota.maxPublicTemplates, UserTier.silver.maxPublicTemplates); // 3
    });
  });
}
