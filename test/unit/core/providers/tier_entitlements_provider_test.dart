/// 🧪 Test: Tier Entitlements Provider
///
/// Tests consolidation logic (UserTier + AccountTier) for all limit types.
/// Verifies that Premium/Pro users get 999 unlimited regardless of XP tier.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/tier_entitlements_provider.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';

void main() {
  group('TierEntitlementsProvider - Consolidation Logic', () {
    test('Free user Starter tier should get Starter limits', () {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.free,
        templateQuota: TemplateQuota.forUserTier(UserTier.starter),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Templates: Starter (4 private, 2 public)
      expect(entitlements.maxTemplates, 4);
      expect(entitlements.maxPublicTemplates, 2);

      // Custom exercises: Starter (3 for all types)
      expect(entitlements.maxCustomSingleExercises, 3);
      expect(entitlements.maxCustomSupersets, 3);
      expect(entitlements.maxCustomDropsets, 3);
      expect(entitlements.maxCustomRestPause, 3);

      container.dispose();
    });

    test('Free user Bronze tier should get Bronze limits', () {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.free,
        templateQuota: TemplateQuota.forUserTier(UserTier.bronze),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.bronze),
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Templates: Bronze (4 private, 2 public)
      expect(entitlements.maxTemplates, 4);
      expect(entitlements.maxPublicTemplates, 2);

      // Custom exercises: Bronze (5 for all types)
      expect(entitlements.maxCustomSingleExercises, 5);
      expect(entitlements.maxCustomSupersets, 5);
      expect(entitlements.maxCustomDropsets, 5);
      expect(entitlements.maxCustomRestPause, 5);

      container.dispose();
    });

    test('Free user Platinum tier should get Platinum limits', () {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.free,
        templateQuota: TemplateQuota.forUserTier(UserTier.platinum),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.platinum),
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Templates: Platinum (7 private, 5 public)
      expect(entitlements.maxTemplates, 7);
      expect(entitlements.maxPublicTemplates, 5);

      // Custom exercises: Platinum (999 unlimited for all types)
      expect(entitlements.maxCustomSingleExercises, 999);
      expect(entitlements.maxCustomSupersets, 999);
      expect(entitlements.maxCustomDropsets, 999);
      expect(entitlements.maxCustomRestPause, 999);

      container.dispose();
    });

    test('CRITICAL: Premium user with Starter tier should get 999 unlimited', () {
      final now = DateTime.now();
      final premiumProfile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.premium,
        templateQuota: TemplateQuota.forTier(AccountTier.premium),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          // LOW XP (Starter tier)
          userTierProvider.overrideWithValue(UserTier.starter),
          // BUT Premium account!
          userProfileProvider.overrideWith((ref) => Stream.value(premiumProfile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Templates: MUST be 999 (not 4!)
      expect(entitlements.maxTemplates, 999,
          reason: 'Premium user should get 999 templates regardless of XP');
      expect(entitlements.maxPublicTemplates, 999,
          reason: 'Premium user should get 999 public templates');

      // Custom exercises: MUST be 999 (not 3!)
      expect(entitlements.maxCustomSingleExercises, 999,
          reason: 'Premium user should get 999 custom singles');
      expect(entitlements.maxCustomSupersets, 999,
          reason: 'Premium user should get 999 supersets');
      expect(entitlements.maxCustomDropsets, 999,
          reason: 'Premium user should get 999 dropsets');
      expect(entitlements.maxCustomRestPause, 999,
          reason: 'Premium user should get 999 rest-pause');

      container.dispose();
    });

    test('Pro user with Starter tier should get 999 unlimited', () {
      final now = DateTime.now();
      final proProfile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.pro,
        templateQuota: TemplateQuota.forTier(AccountTier.pro),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => Stream.value(proProfile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // All limits should be 999
      expect(entitlements.maxTemplates, 999);
      expect(entitlements.maxPublicTemplates, 999);
      expect(entitlements.maxCustomSingleExercises, 999);
      expect(entitlements.maxCustomSupersets, 999);
      expect(entitlements.maxCustomDropsets, 999);
      expect(entitlements.maxCustomRestPause, 999);

      container.dispose();
    });

    test('Premium user with Platinum tier should still get 999 unlimited', () {
      final now = DateTime.now();
      final premiumProfile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.premium,
        templateQuota: TemplateQuota.forTier(AccountTier.premium),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.platinum),
          userProfileProvider.overrideWith((ref) => Stream.value(premiumProfile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // All limits should be 999 (Platinum already gives 999, Premium also gives 999)
      expect(entitlements.maxTemplates, 999);
      expect(entitlements.maxPublicTemplates, 999);
      expect(entitlements.maxCustomSingleExercises, 999);
      expect(entitlements.maxCustomSupersets, 999);
      expect(entitlements.maxCustomDropsets, 999);
      expect(entitlements.maxCustomRestPause, 999);

      container.dispose();
    });

    test('Tier progression: Starter → Bronze → Silver → Gold → Platinum', () {
      final tiers = [
        UserTier.starter,
        UserTier.bronze,
        UserTier.silver,
        UserTier.gold,
        UserTier.platinum,
      ];

      final expectedCustomExercises = [3, 5, 7, 10, 999];
      final now = DateTime.now();

      for (var i = 0; i < tiers.length; i++) {
        final profile = UserProfile(
          uid: 'test-user',
          email: 'test@example.com',
          displayName: 'Test User',
          accountTier: AccountTier.free,
          templateQuota: TemplateQuota.forUserTier(tiers[i]),
          createdAt: now,
          lastLoginAt: now,
        );

        final container = ProviderContainer(
          overrides: [
            userTierProvider.overrideWithValue(tiers[i]),
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          ],
        );

        final entitlements = container.read(tierEntitlementsProvider);

        expect(
          entitlements.maxCustomSingleExercises,
          expectedCustomExercises[i],
          reason: '${tiers[i].name} tier should have ${expectedCustomExercises[i]} custom singles',
        );

        container.dispose();
      }
    });

    test('Selective providers should expose individual limits', () {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.free,
        templateQuota: TemplateQuota.forUserTier(UserTier.silver),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.silver),
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
      );

      // Test selective providers (PEP pattern)
      expect(container.read(maxCustomSingleExercisesProvider), 7);
      expect(container.read(maxCustomSupersetsProvider), 7);
      expect(container.read(maxCustomDropsetsProvider), 7);
      expect(container.read(maxCustomRestPauseProvider), 7);

      container.dispose();
    });
  });

  group('TierEntitlementsProvider - Edge Cases', () {
    test('Should handle null/uninitialized user profile gracefully', () {
      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );

      // Should not throw, should use default AccountTier.free
      expect(
        () => container.read(tierEntitlementsProvider),
        returnsNormally,
      );

      container.dispose();
    });

    test('Free user limits should never exceed 999', () {
      final now = DateTime.now();
      final profile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.free,
        templateQuota: TemplateQuota.forUserTier(UserTier.platinum),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.platinum),
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Even Platinum shouldn't exceed 999
      expect(entitlements.maxCustomSingleExercises, lessThanOrEqualTo(999));
      expect(entitlements.maxCustomSupersets, lessThanOrEqualTo(999));

      container.dispose();
    });

    test('Premium limits should always be exactly 999', () {
      final now = DateTime.now();
      final premiumProfile = UserProfile(
        uid: 'test-user',
        email: 'test@example.com',
        displayName: 'Test User',
        accountTier: AccountTier.premium,
        templateQuota: TemplateQuota.forTier(AccountTier.premium),
        createdAt: now,
        lastLoginAt: now,
      );

      final container = ProviderContainer(
        overrides: [
          userTierProvider.overrideWithValue(UserTier.starter),
          userProfileProvider.overrideWith((ref) => Stream.value(premiumProfile)),
        ],
      );

      final entitlements = container.read(tierEntitlementsProvider);

      // Premium should be EXACTLY 999, not more
      expect(entitlements.maxTemplates, equals(999));
      expect(entitlements.maxPublicTemplates, equals(999));
      expect(entitlements.maxCustomSingleExercises, equals(999));
      expect(entitlements.maxCustomSupersets, equals(999));
      expect(entitlements.maxCustomDropsets, equals(999));
      expect(entitlements.maxCustomRestPause, equals(999));

      container.dispose();
    });
  });
}
