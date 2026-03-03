/// UserTier entity tests - enum values, fromXP, entitlements, progression.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

void main() {
  group('UserTier', () {
    test('has 7 values', () {
      expect(UserTier.values.length, 7);
    });

    test('minXP ascending order', () {
      expect(UserTier.starter.minXP, 0);
      expect(UserTier.bronze.minXP, 300);
      expect(UserTier.silver.minXP, 1500);
      expect(UserTier.gold.minXP, 5000);
      expect(UserTier.platinum.minXP, 15000);
      expect(UserTier.diamond.minXP, 30000);
      expect(UserTier.legend.minXP, 60000);
    });

    test('fromXP', () {
      expect(UserTier.fromXP(0), UserTier.starter);
      expect(UserTier.fromXP(50), UserTier.starter);
      expect(UserTier.fromXP(299), UserTier.starter);
      expect(UserTier.fromXP(300), UserTier.bronze);
      expect(UserTier.fromXP(1499), UserTier.bronze);
      expect(UserTier.fromXP(1500), UserTier.silver);
      expect(UserTier.fromXP(5000), UserTier.gold);
      expect(UserTier.fromXP(15000), UserTier.platinum);
      expect(UserTier.fromXP(30000), UserTier.diamond);
      expect(UserTier.fromXP(60000), UserTier.legend);
      expect(UserTier.fromXP(99999), UserTier.legend);
    });

    test('next tier', () {
      expect(UserTier.starter.next, UserTier.bronze);
      expect(UserTier.bronze.next, UserTier.silver);
      expect(UserTier.silver.next, UserTier.gold);
      expect(UserTier.gold.next, UserTier.platinum);
      expect(UserTier.platinum.next, UserTier.diamond);
      expect(UserTier.diamond.next, UserTier.legend);
      expect(UserTier.legend.next, isNull);
    });

    test('xpToNextTier', () {
      expect(UserTier.starter.xpToNextTier, 300);
      expect(UserTier.bronze.xpToNextTier, 1500);
      expect(UserTier.legend.xpToNextTier, isNull);
    });

    test('progressToNext', () {
      // Starter: 0-300 range
      expect(UserTier.starter.progressToNext(0), 0.0);
      expect(UserTier.starter.progressToNext(150), 0.5);
      expect(UserTier.starter.progressToNext(300), 1.0);
    });

    test('progressToNext max tier returns 1.0', () {
      expect(UserTier.legend.progressToNext(60000), 1.0);
      expect(UserTier.legend.progressToNext(99999), 1.0);
    });

    test('xpRemainingToNext', () {
      expect(UserTier.starter.xpRemainingToNext(0), 300);
      expect(UserTier.starter.xpRemainingToNext(150), 150);
      expect(UserTier.starter.xpRemainingToNext(300), 0);
    });

    test('xpRemainingToNext max tier returns 0', () {
      expect(UserTier.legend.xpRemainingToNext(60000), 0);
    });

    test('entitlements - starter', () {
      expect(UserTier.starter.maxTemplates, 3);
      expect(UserTier.starter.maxPublicTemplates, 3);
      expect(UserTier.starter.maxCustomSingleExercises, 3);
      expect(UserTier.starter.maxCustomSupersets, 3);
      expect(UserTier.starter.maxCustomDropsets, 3);
      expect(UserTier.starter.maxCustomRestPause, 3);
      expect(UserTier.starter.showAds, isTrue);
      expect(UserTier.starter.hasProAnalytics, isFalse);
      expect(UserTier.starter.hasCloudSync, isFalse);
    });

    test('entitlements - bronze', () {
      expect(UserTier.bronze.maxTemplates, 4);
      expect(UserTier.bronze.maxPublicTemplates, 4);
      expect(UserTier.bronze.maxCustomSingleExercises, 5);
      expect(UserTier.bronze.maxCustomSupersets, 5);
      expect(UserTier.bronze.maxCustomDropsets, 5);
      expect(UserTier.bronze.maxCustomRestPause, 5);
    });

    test('entitlements - silver', () {
      expect(UserTier.silver.maxTemplates, 4);
      expect(UserTier.silver.maxPublicTemplates, 4);
      expect(UserTier.silver.maxCustomSingleExercises, 7);
      expect(UserTier.silver.maxCustomSupersets, 7);
    });

    test('entitlements - gold', () {
      expect(UserTier.gold.maxTemplates, 5);
      expect(UserTier.gold.maxPublicTemplates, 5);
      expect(UserTier.gold.maxCustomSingleExercises, 10);
      expect(UserTier.gold.maxCustomSupersets, 10);
    });

    test('entitlements - platinum', () {
      expect(UserTier.platinum.maxTemplates, 5);
      expect(UserTier.platinum.maxPublicTemplates, 5);
      expect(UserTier.platinum.maxCustomSingleExercises, 15);
      expect(UserTier.platinum.maxCustomSupersets, 15);
      expect(UserTier.platinum.showAds, isFalse);
      expect(UserTier.platinum.hasProAnalytics, isTrue);
      expect(UserTier.platinum.hasCloudSync, isTrue);
    });

    test('entitlements - diamond', () {
      expect(UserTier.diamond.maxTemplates, 6);
      expect(UserTier.diamond.maxPublicTemplates, 6);
      expect(UserTier.diamond.maxCustomSingleExercises, 999);
      expect(UserTier.diamond.showAds, isFalse);
      expect(UserTier.diamond.hasProAnalytics, isTrue);
      expect(UserTier.diamond.hasCloudSync, isTrue);
    });

    test('entitlements - legend', () {
      expect(UserTier.legend.maxTemplates, 7);
      expect(UserTier.legend.maxPublicTemplates, 7);
      expect(UserTier.legend.maxCustomSingleExercises, 999);
      expect(UserTier.legend.showAds, isFalse);
      expect(UserTier.legend.hasProAnalytics, isTrue);
      expect(UserTier.legend.hasCloudSync, isTrue);
    });

    test('displayName unique', () {
      final names = UserTier.values.map((t) => t.displayName).toSet();
      expect(names.length, 7);
    });

    test('maxTemplates increases with tier', () {
      expect(UserTier.starter.maxTemplates, lessThanOrEqualTo(UserTier.legend.maxTemplates));
    });

    test('rebalancing: 7000 XP user is Gold (not Platinum)', () {
      expect(UserTier.fromXP(7000), UserTier.gold);
    });
  });
}
