import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // UserTier.fromXP factory
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.fromXP', () {
    test('0 XP → starter', () => expect(UserTier.fromXP(0), UserTier.starter));
    test('50 XP → starter', () => expect(UserTier.fromXP(50), UserTier.starter));
    test('99 XP → starter', () => expect(UserTier.fromXP(99), UserTier.starter));
    test('100 XP → bronze', () => expect(UserTier.fromXP(100), UserTier.bronze));
    test('499 XP → bronze', () => expect(UserTier.fromXP(499), UserTier.bronze));
    test('500 XP → silver', () => expect(UserTier.fromXP(500), UserTier.silver));
    test('1499 XP → silver', () => expect(UserTier.fromXP(1499), UserTier.silver));
    test('1500 XP → gold', () => expect(UserTier.fromXP(1500), UserTier.gold));
    test('4999 XP → gold', () => expect(UserTier.fromXP(4999), UserTier.gold));
    test('5000 XP → platinum', () => expect(UserTier.fromXP(5000), UserTier.platinum));
    test('99999 XP → platinum', () => expect(UserTier.fromXP(99999), UserTier.platinum));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.next
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.next', () {
    test('starter.next = bronze', () => expect(UserTier.starter.next, UserTier.bronze));
    test('bronze.next = silver', () => expect(UserTier.bronze.next, UserTier.silver));
    test('silver.next = gold', () => expect(UserTier.silver.next, UserTier.gold));
    test('gold.next = platinum', () => expect(UserTier.gold.next, UserTier.platinum));
    test('platinum.next = null', () => expect(UserTier.platinum.next, isNull));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.xpToNextTier
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.xpToNextTier', () {
    test('starter.xpToNextTier = 100', () => expect(UserTier.starter.xpToNextTier, 100));
    test('bronze.xpToNextTier = 500', () => expect(UserTier.bronze.xpToNextTier, 500));
    test('silver.xpToNextTier = 1500', () => expect(UserTier.silver.xpToNextTier, 1500));
    test('gold.xpToNextTier = 5000', () => expect(UserTier.gold.xpToNextTier, 5000));
    test('platinum.xpToNextTier = null', () => expect(UserTier.platinum.xpToNextTier, isNull));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.progressToNext
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.progressToNext', () {
    test('starter at 0 XP = 0.0 progress', () {
      expect(UserTier.starter.progressToNext(0), 0.0);
    });

    test('starter at 50 XP = 0.5 progress', () {
      expect(UserTier.starter.progressToNext(50), 0.5);
    });

    test('starter at 100 XP = 1.0 progress', () {
      expect(UserTier.starter.progressToNext(100), 1.0);
    });

    test('bronze at 100 XP = 0.0 progress', () {
      // bronze range: 100..500, xpInTier=0, xpNeeded=400
      expect(UserTier.bronze.progressToNext(100), 0.0);
    });

    test('bronze at 300 XP = 0.5 progress', () {
      // xpInTier = 300-100=200, xpNeeded=500-100=400, progress=0.5
      expect(UserTier.bronze.progressToNext(300), 0.5);
    });

    test('bronze at 500 XP = 1.0 progress', () {
      expect(UserTier.bronze.progressToNext(500), 1.0);
    });

    test('platinum.progressToNext = 1.0 (max tier)', () {
      expect(UserTier.platinum.progressToNext(9999), 1.0);
    });

    test('progress clamped to 1.0 max', () {
      // XP exceeding next tier boundary
      expect(UserTier.starter.progressToNext(200), 1.0);
    });

    test('progress clamped to 0.0 min', () {
      expect(UserTier.starter.progressToNext(0), 0.0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.xpRemainingToNext
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.xpRemainingToNext', () {
    test('starter at 0 XP needs 100 more', () {
      expect(UserTier.starter.xpRemainingToNext(0), 100);
    });

    test('starter at 50 XP needs 50 more', () {
      expect(UserTier.starter.xpRemainingToNext(50), 50);
    });

    test('starter at 100 XP needs 0 more', () {
      expect(UserTier.starter.xpRemainingToNext(100), 0);
    });

    test('bronze at 400 XP needs 100 more', () {
      expect(UserTier.bronze.xpRemainingToNext(400), 100);
    });

    test('platinum.xpRemainingToNext = 0 (max tier)', () {
      expect(UserTier.platinum.xpRemainingToNext(99999), 0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier entitlements
  // ═══════════════════════════════════════════════════════════════
  group('UserTier entitlements', () {
    test('starter maxTemplates = 4', () => expect(UserTier.starter.maxTemplates, 4));
    test('bronze maxTemplates = 4', () => expect(UserTier.bronze.maxTemplates, 4));
    test('silver maxTemplates = 5', () => expect(UserTier.silver.maxTemplates, 5));
    test('gold maxTemplates = 5', () => expect(UserTier.gold.maxTemplates, 5));
    test('platinum maxTemplates = 7', () => expect(UserTier.platinum.maxTemplates, 7));

    test('starter showAds = true', () => expect(UserTier.starter.showAds, isTrue));
    test('platinum showAds = false', () => expect(UserTier.platinum.showAds, isFalse));

    test('starter hasProAnalytics = false', () => expect(UserTier.starter.hasProAnalytics, isFalse));
    test('platinum hasProAnalytics = true', () => expect(UserTier.platinum.hasProAnalytics, isTrue));

    test('starter hasCloudSync = false', () => expect(UserTier.starter.hasCloudSync, isFalse));
    test('platinum hasCloudSync = true', () => expect(UserTier.platinum.hasCloudSync, isTrue));

    test('starter maxCustomSingleExercises = 3', () {
      expect(UserTier.starter.maxCustomSingleExercises, 3);
    });

    test('platinum maxCustomSingleExercises = 999', () {
      expect(UserTier.platinum.maxCustomSingleExercises, 999);
    });

    test('platinum maxPublicTemplates = 5', () {
      expect(UserTier.platinum.maxPublicTemplates, 5);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier display names
  // ═══════════════════════════════════════════════════════════════
  group('UserTier displayName', () {
    test('starter displayName', () => expect(UserTier.starter.displayName, 'Starter'));
    test('bronze displayName', () => expect(UserTier.bronze.displayName, 'Bronze'));
    test('silver displayName', () => expect(UserTier.silver.displayName, 'Silver'));
    test('gold displayName', () => expect(UserTier.gold.displayName, 'Gold'));
    test('platinum displayName', () => expect(UserTier.platinum.displayName, 'Platinum'));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier minXP values
  // ═══════════════════════════════════════════════════════════════
  group('UserTier minXP boundaries', () {
    test('starter minXP = 0', () => expect(UserTier.starter.minXP, 0));
    test('bronze minXP = 100', () => expect(UserTier.bronze.minXP, 100));
    test('silver minXP = 500', () => expect(UserTier.silver.minXP, 500));
    test('gold minXP = 1500', () => expect(UserTier.gold.minXP, 1500));
    test('platinum minXP = 5000', () => expect(UserTier.platinum.minXP, 5000));
  });
}
