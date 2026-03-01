/// UserProfile and TemplateQuota entity tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

void main() {
  group('AccountTier', () {
    test('has 2 values', () {
      expect(AccountTier.values.length, 2);
      expect(AccountTier.values, contains(AccountTier.free));
      expect(AccountTier.values, contains(AccountTier.premium));
    });
  });

  group('TemplateQuota', () {
    test('constructor', () {
      const quota = TemplateQuota(
        maxPrivateTemplates: 10,
        maxPublicTemplates: 5,
        usedPrivateTemplates: 3,
        usedPublicTemplates: 1,
      );
      expect(quota.maxPrivateTemplates, 10);
      expect(quota.maxPublicTemplates, 5);
      expect(quota.usedPrivateTemplates, 3);
      expect(quota.usedPublicTemplates, 1);
    });

    test('defaults for used', () {
      const quota = TemplateQuota(maxPrivateTemplates: 4, maxPublicTemplates: 2);
      expect(quota.usedPrivateTemplates, 0);
      expect(quota.usedPublicTemplates, 0);
    });

    test('canSavePrivate', () {
      const canSave = TemplateQuota(
        maxPrivateTemplates: 4, maxPublicTemplates: 2,
        usedPrivateTemplates: 3,
      );
      expect(canSave.canSavePrivate, true);

      const cantSave = TemplateQuota(
        maxPrivateTemplates: 4, maxPublicTemplates: 2,
        usedPrivateTemplates: 4,
      );
      expect(cantSave.canSavePrivate, false);
    });

    test('canSavePublic', () {
      const canSave = TemplateQuota(
        maxPrivateTemplates: 4, maxPublicTemplates: 2,
        usedPublicTemplates: 1,
      );
      expect(canSave.canSavePublic, true);

      const cantSave = TemplateQuota(
        maxPrivateTemplates: 4, maxPublicTemplates: 2,
        usedPublicTemplates: 2,
      );
      expect(cantSave.canSavePublic, false);
    });

    test('remainingPrivate', () {
      const quota = TemplateQuota(
        maxPrivateTemplates: 10, maxPublicTemplates: 5,
        usedPrivateTemplates: 3,
      );
      expect(quota.remainingPrivate, 7);
    });

    test('remainingPublic', () {
      const quota = TemplateQuota(
        maxPrivateTemplates: 10, maxPublicTemplates: 5,
        usedPublicTemplates: 2,
      );
      expect(quota.remainingPublic, 3);
    });

    test('forTier free', () {
      final quota = TemplateQuota.forTier(AccountTier.free, usedPrivate: 2);
      expect(quota.maxPrivateTemplates, 4);
      expect(quota.maxPublicTemplates, 2);
      expect(quota.usedPrivateTemplates, 2);
    });

    test('forTier premium', () {
      final quota = TemplateQuota.forTier(AccountTier.premium);
      expect(quota.maxPrivateTemplates, 999);
      expect(quota.maxPublicTemplates, 999);
    });

    test('forUserTier', () {
      final quota = TemplateQuota.forUserTier(UserTier.starter, usedPrivate: 1, usedPublic: 0);
      expect(quota.maxPrivateTemplates, UserTier.starter.maxTemplates);
      expect(quota.maxPublicTemplates, UserTier.starter.maxPublicTemplates);
      expect(quota.usedPrivateTemplates, 1);
    });

    test('consolidated takes max of XP and account', () {
      final quota = TemplateQuota.consolidated(
        userTier: UserTier.starter,
        accountTier: AccountTier.premium,
        usedPrivate: 2,
        usedPublic: 1,
      );
      // Premium gives 999, starter gives tier-based value
      // consolidated takes the max
      expect(quota.maxPrivateTemplates, 999);
      expect(quota.maxPublicTemplates, 999);
      expect(quota.usedPrivateTemplates, 2);
      expect(quota.usedPublicTemplates, 1);
    });

    test('fromJson', () {
      final json = {
        'maxPrivateTemplates': 10,
        'maxPublicTemplates': 5,
        'usedPrivateTemplates': 3,
        'usedPublicTemplates': 1,
      };
      final quota = TemplateQuota.fromJson(json);
      expect(quota.maxPrivateTemplates, 10);
      expect(quota.usedPublicTemplates, 1);
    });

    test('fromJson with defaults', () {
      final quota = TemplateQuota.fromJson({});
      expect(quota.maxPrivateTemplates, 4);
      expect(quota.maxPublicTemplates, 2);
      expect(quota.usedPrivateTemplates, 0);
    });

    test('toJson round-trip', () {
      const quota = TemplateQuota(
        maxPrivateTemplates: 10,
        maxPublicTemplates: 5,
        usedPrivateTemplates: 3,
        usedPublicTemplates: 1,
      );
      final json = quota.toJson();
      final restored = TemplateQuota.fromJson(json);
      expect(restored.maxPrivateTemplates, 10);
      expect(restored.usedPublicTemplates, 1);
    });
  });

  group('UserProfile', () {
    UserProfile createTestProfile({
      AccountTier accountTier = AccountTier.free,
      TemplateQuota? quota,
      Map<String, dynamic>? preferences,
      bool isAdmin = false,
    }) {
      return UserProfile(
        uid: 'test-uid',
        email: 'test@test.com',
        displayName: 'Test User',
        accountTier: accountTier,
        templateQuota: quota ?? const TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        preferences: preferences ?? {},
        isAdmin: isAdmin,
      );
    }

    test('constructor with defaults', () {
      final profile = createTestProfile();
      expect(profile.uid, 'test-uid');
      expect(profile.email, 'test@test.com');
      expect(profile.displayName, 'Test User');
      expect(profile.accountTier, AccountTier.free);
      expect(profile.isGuest, false);
      expect(profile.isAdmin, false);
      expect(profile.photoURL, isNull);
      expect(profile.debugTierOverride, isNull);
    });

    test('isPremium', () {
      final free = createTestProfile(accountTier: AccountTier.free);
      expect(free.isPremium, false);

      final premium = createTestProfile(accountTier: AccountTier.premium);
      expect(premium.isPremium, true);
    });

    test('dayCutoffHour default is 4', () {
      final profile = createTestProfile();
      expect(profile.dayCutoffHour, 4);
    });

    test('dayCutoffHour from preferences', () {
      final profile = createTestProfile(preferences: {'dayCutoffHour': 6});
      expect(profile.dayCutoffHour, 6);
    });

    test('updateDayCutoffHour', () {
      final profile = createTestProfile();
      final updated = profile.updateDayCutoffHour(6);
      expect(updated.dayCutoffHour, 6);
      expect(updated.uid, 'test-uid');
    });

    test('incrementTemplateUsage private', () {
      final profile = createTestProfile();
      final updated = profile.incrementTemplateUsage(isPublic: false);
      expect(updated.templateQuota.usedPrivateTemplates, 1);
      expect(updated.templateQuota.usedPublicTemplates, 0);
    });

    test('incrementTemplateUsage public', () {
      final profile = createTestProfile();
      final updated = profile.incrementTemplateUsage(isPublic: true);
      expect(updated.templateQuota.usedPrivateTemplates, 0);
      expect(updated.templateQuota.usedPublicTemplates, 1);
    });

    test('decrementTemplateUsage private clamps to 0', () {
      final profile = createTestProfile();
      final updated = profile.decrementTemplateUsage(isPublic: false);
      expect(updated.templateQuota.usedPrivateTemplates, 0);
    });

    test('decrementTemplateUsage public', () {
      final profile = createTestProfile(
        quota: const TemplateQuota(
          maxPrivateTemplates: 4, maxPublicTemplates: 2,
          usedPublicTemplates: 2,
        ),
      );
      final updated = profile.decrementTemplateUsage(isPublic: true);
      expect(updated.templateQuota.usedPublicTemplates, 1);
    });

    test('copyWith', () {
      final profile = createTestProfile();
      final copy = profile.copyWith(
        displayName: 'New Name',
        isAdmin: true,
      );
      expect(copy.displayName, 'New Name');
      expect(copy.isAdmin, true);
      expect(copy.uid, 'test-uid');
    });

    test('fromJson', () {
      final json = {
        'uid': 'u-1',
        'email': 'user@test.com',
        'displayName': 'User',
        'photoURL': 'https://example.com/photo.jpg',
        'accountTier': 'premium',
        'templateQuota': {
          'maxPrivateTemplates': 999,
          'maxPublicTemplates': 999,
          'usedPrivateTemplates': 5,
          'usedPublicTemplates': 2,
        },
        'createdAt': '2024-01-01T00:00:00.000',
        'lastLoginAt': '2024-06-01T00:00:00.000',
        'preferences': {'dayCutoffHour': 5},
        'stats': {'workoutCount': 100},
        'isGuest': false,
        'isAdmin': true,
        'debugTierOverride': 'starter',
        'debugAccountOverride': 'premium',
        'debugXPOverride': 5000,
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.uid, 'u-1');
      expect(profile.email, 'user@test.com');
      expect(profile.photoURL, 'https://example.com/photo.jpg');
      expect(profile.accountTier, AccountTier.premium);
      expect(profile.templateQuota.maxPrivateTemplates, 999);
      expect(profile.templateQuota.usedPrivateTemplates, 5);
      expect(profile.isAdmin, true);
      expect(profile.dayCutoffHour, 5);
      expect(profile.debugTierOverride, UserTier.starter);
      expect(profile.debugAccountOverride, AccountTier.premium);
      expect(profile.debugXPOverride, 5000);
    });

    test('fromJson with minimal data', () {
      final json = <String, dynamic>{};
      final profile = UserProfile.fromJson(json);
      expect(profile.uid, '');
      expect(profile.email, '');
      expect(profile.displayName, 'GymBro User');
      expect(profile.accountTier, AccountTier.free);
      expect(profile.isGuest, false);
      expect(profile.isAdmin, false);
    });

    test('fromJson backward compat without templateQuota', () {
      final json = {
        'uid': 'u-1',
        'email': 'test@test.com',
        'displayName': 'Test',
        'createdAt': '2024-01-01T00:00:00.000',
        'lastLoginAt': '2024-01-01T00:00:00.000',
        'stats': {
          'privateTemplateCount': 2,
          'publicTemplateCount': 1,
        },
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.templateQuota.usedPrivateTemplates, 2);
      expect(profile.templateQuota.usedPublicTemplates, 1);
    });

    test('toJson round-trip', () {
      final profile = UserProfile(
        uid: 'u-1',
        email: 'test@test.com',
        displayName: 'Test',
        accountTier: AccountTier.premium,
        templateQuota: const TemplateQuota(
          maxPrivateTemplates: 999,
          maxPublicTemplates: 999,
        ),
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 6, 1),
        isAdmin: true,
        debugTierOverride: UserTier.starter,
        debugXPOverride: 5000,
      );
      final json = profile.toJson();
      expect(json['uid'], 'u-1');
      expect(json['accountTier'], 'premium');
      expect(json['isAdmin'], true);
      expect(json['debugTierOverride'], 'starter');
      expect(json['debugXPOverride'], 5000);

      final restored = UserProfile.fromJson(json);
      expect(restored.uid, profile.uid);
      expect(restored.accountTier, profile.accountTier);
    });
  });
}
