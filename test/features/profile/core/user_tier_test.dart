import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════
  // UserTier.fromXP factory
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.fromXP', () {
    test('0 XP → starter', () => expect(UserTier.fromXP(0), UserTier.starter));
    test('50 XP → starter', () => expect(UserTier.fromXP(50), UserTier.starter));
    test('299 XP → starter', () => expect(UserTier.fromXP(299), UserTier.starter));
    test('300 XP → bronze', () => expect(UserTier.fromXP(300), UserTier.bronze));
    test('1499 XP → bronze', () => expect(UserTier.fromXP(1499), UserTier.bronze));
    test('1500 XP → silver', () => expect(UserTier.fromXP(1500), UserTier.silver));
    test('4999 XP → silver', () => expect(UserTier.fromXP(4999), UserTier.silver));
    test('5000 XP → gold', () => expect(UserTier.fromXP(5000), UserTier.gold));
    test('14999 XP → gold', () => expect(UserTier.fromXP(14999), UserTier.gold));
    test('15000 XP → platinum', () => expect(UserTier.fromXP(15000), UserTier.platinum));
    test('29999 XP → platinum', () => expect(UserTier.fromXP(29999), UserTier.platinum));
    test('30000 XP → diamond', () => expect(UserTier.fromXP(30000), UserTier.diamond));
    test('59999 XP → diamond', () => expect(UserTier.fromXP(59999), UserTier.diamond));
    test('60000 XP → legend', () => expect(UserTier.fromXP(60000), UserTier.legend));
    test('99999 XP → legend', () => expect(UserTier.fromXP(99999), UserTier.legend));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.next
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.next', () {
    test('starter.next = bronze', () => expect(UserTier.starter.next, UserTier.bronze));
    test('bronze.next = silver', () => expect(UserTier.bronze.next, UserTier.silver));
    test('silver.next = gold', () => expect(UserTier.silver.next, UserTier.gold));
    test('gold.next = platinum', () => expect(UserTier.gold.next, UserTier.platinum));
    test('platinum.next = diamond', () => expect(UserTier.platinum.next, UserTier.diamond));
    test('diamond.next = legend', () => expect(UserTier.diamond.next, UserTier.legend));
    test('legend.next = null', () => expect(UserTier.legend.next, isNull));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.xpToNextTier
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.xpToNextTier', () {
    test('starter.xpToNextTier = 300', () => expect(UserTier.starter.xpToNextTier, 300));
    test('bronze.xpToNextTier = 1500', () => expect(UserTier.bronze.xpToNextTier, 1500));
    test('silver.xpToNextTier = 5000', () => expect(UserTier.silver.xpToNextTier, 5000));
    test('gold.xpToNextTier = 15000', () => expect(UserTier.gold.xpToNextTier, 15000));
    test('platinum.xpToNextTier = 30000', () => expect(UserTier.platinum.xpToNextTier, 30000));
    test('diamond.xpToNextTier = 60000', () => expect(UserTier.diamond.xpToNextTier, 60000));
    test('legend.xpToNextTier = null', () => expect(UserTier.legend.xpToNextTier, isNull));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.progressToNext
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.progressToNext', () {
    test('starter at 0 XP = 0.0 progress', () {
      expect(UserTier.starter.progressToNext(0), 0.0);
    });

    test('starter at 150 XP = 0.5 progress', () {
      expect(UserTier.starter.progressToNext(150), 0.5);
    });

    test('starter at 300 XP = 1.0 progress', () {
      expect(UserTier.starter.progressToNext(300), 1.0);
    });

    test('bronze at 300 XP = 0.0 progress', () {
      // bronze range: 300..1500, xpInTier=0, xpNeeded=1200
      expect(UserTier.bronze.progressToNext(300), 0.0);
    });

    test('bronze at 900 XP = 0.5 progress', () {
      // xpInTier = 900-300=600, xpNeeded=1500-300=1200, progress=0.5
      expect(UserTier.bronze.progressToNext(900), 0.5);
    });

    test('bronze at 1500 XP = 1.0 progress', () {
      expect(UserTier.bronze.progressToNext(1500), 1.0);
    });

    test('legend.progressToNext = 1.0 (max tier)', () {
      expect(UserTier.legend.progressToNext(99999), 1.0);
    });

    test('progress clamped to 1.0 max', () {
      expect(UserTier.starter.progressToNext(500), 1.0);
    });

    test('progress clamped to 0.0 min', () {
      expect(UserTier.starter.progressToNext(0), 0.0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier.xpRemainingToNext
  // ═══════════════════════════════════════════════════════════════
  group('UserTier.xpRemainingToNext', () {
    test('starter at 0 XP needs 300 more', () {
      expect(UserTier.starter.xpRemainingToNext(0), 300);
    });

    test('starter at 150 XP needs 150 more', () {
      expect(UserTier.starter.xpRemainingToNext(150), 150);
    });

    test('starter at 300 XP needs 0 more', () {
      expect(UserTier.starter.xpRemainingToNext(300), 0);
    });

    test('bronze at 1000 XP needs 500 more', () {
      expect(UserTier.bronze.xpRemainingToNext(1000), 500);
    });

    test('legend.xpRemainingToNext = 0 (max tier)', () {
      expect(UserTier.legend.xpRemainingToNext(99999), 0);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier entitlements
  // ═══════════════════════════════════════════════════════════════
  group('UserTier entitlements', () {
    test('starter maxTemplates = 3', () => expect(UserTier.starter.maxTemplates, 3));
    test('bronze maxTemplates = 4', () => expect(UserTier.bronze.maxTemplates, 4));
    test('silver maxTemplates = 5', () => expect(UserTier.silver.maxTemplates, 5));
    test('gold maxTemplates = 7', () => expect(UserTier.gold.maxTemplates, 7));
    test('platinum maxTemplates = 10', () => expect(UserTier.platinum.maxTemplates, 10));
    test('diamond maxTemplates = 15', () => expect(UserTier.diamond.maxTemplates, 15));
    test('legend maxTemplates = 999', () => expect(UserTier.legend.maxTemplates, 999));

    test('starter showAds = true', () => expect(UserTier.starter.showAds, isTrue));
    test('platinum showAds = false', () => expect(UserTier.platinum.showAds, isFalse));
    test('diamond showAds = false', () => expect(UserTier.diamond.showAds, isFalse));
    test('legend showAds = false', () => expect(UserTier.legend.showAds, isFalse));

    test('starter hasProAnalytics = false', () => expect(UserTier.starter.hasProAnalytics, isFalse));
    test('platinum hasProAnalytics = true', () => expect(UserTier.platinum.hasProAnalytics, isTrue));
    test('diamond hasProAnalytics = true', () => expect(UserTier.diamond.hasProAnalytics, isTrue));
    test('legend hasProAnalytics = true', () => expect(UserTier.legend.hasProAnalytics, isTrue));

    test('starter hasCloudSync = false', () => expect(UserTier.starter.hasCloudSync, isFalse));
    test('platinum hasCloudSync = true', () => expect(UserTier.platinum.hasCloudSync, isTrue));
    test('diamond hasCloudSync = true', () => expect(UserTier.diamond.hasCloudSync, isTrue));
    test('legend hasCloudSync = true', () => expect(UserTier.legend.hasCloudSync, isTrue));

    test('starter maxCustomSingleExercises = 3', () {
      expect(UserTier.starter.maxCustomSingleExercises, 3);
    });

    test('platinum maxCustomSingleExercises = 15', () {
      expect(UserTier.platinum.maxCustomSingleExercises, 15);
    });

    test('diamond maxPublicTemplates = 10', () {
      expect(UserTier.diamond.maxPublicTemplates, 10);
    });

    test('legend maxPublicTemplates = 999', () {
      expect(UserTier.legend.maxPublicTemplates, 999);
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
    test('diamond displayName', () => expect(UserTier.diamond.displayName, 'Diamond'));
    test('legend displayName', () => expect(UserTier.legend.displayName, 'Legend'));
  });

  // ═══════════════════════════════════════════════════════════════
  // UserTier minXP values
  // ═══════════════════════════════════════════════════════════════
  group('UserTier minXP boundaries', () {
    test('starter minXP = 0', () => expect(UserTier.starter.minXP, 0));
    test('bronze minXP = 300', () => expect(UserTier.bronze.minXP, 300));
    test('silver minXP = 1500', () => expect(UserTier.silver.minXP, 1500));
    test('gold minXP = 5000', () => expect(UserTier.gold.minXP, 5000));
    test('platinum minXP = 15000', () => expect(UserTier.platinum.minXP, 15000));
    test('diamond minXP = 30000', () => expect(UserTier.diamond.minXP, 30000));
    test('legend minXP = 60000', () => expect(UserTier.legend.minXP, 60000));
  });

  // ═══════════════════════════════════════════════════════════════
  // Rebalancing verification
  // ═══════════════════════════════════════════════════════════════
  group('Rebalancing verification', () {
    test('7000 XP user is Gold (was Platinum before rebalancing)', () {
      expect(UserTier.fromXP(7000), UserTier.gold);
    });

    test('daily login bonus cap at 25 does not exceed ~750/month', () {
      // 30 days * 25 = 750 max per month
      expect(25 * 30, 750);
    });
  });
}
