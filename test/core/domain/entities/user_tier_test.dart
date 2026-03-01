/// UserTier entity tests - enum values, fromXP, entitlements, progression.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

void main() {
  group('UserTier', () {
    test('has 5 values', () {
      expect(UserTier.values.length, 5);
    });

    test('minXP ascending order', () {
      expect(UserTier.starter.minXP, 0);
      expect(UserTier.bronze.minXP, 100);
      expect(UserTier.silver.minXP, 500);
      expect(UserTier.gold.minXP, 1500);
      expect(UserTier.platinum.minXP, 5000);
    });

    test('fromXP', () {
      expect(UserTier.fromXP(0), UserTier.starter);
      expect(UserTier.fromXP(50), UserTier.starter);
      expect(UserTier.fromXP(100), UserTier.bronze);
      expect(UserTier.fromXP(499), UserTier.bronze);
      expect(UserTier.fromXP(500), UserTier.silver);
      expect(UserTier.fromXP(1500), UserTier.gold);
      expect(UserTier.fromXP(5000), UserTier.platinum);
      expect(UserTier.fromXP(99999), UserTier.platinum);
    });

    test('next tier', () {
      expect(UserTier.starter.next, UserTier.bronze);
      expect(UserTier.bronze.next, UserTier.silver);
      expect(UserTier.silver.next, UserTier.gold);
      expect(UserTier.gold.next, UserTier.platinum);
      expect(UserTier.platinum.next, isNull);
    });

    test('xpToNextTier', () {
      expect(UserTier.starter.xpToNextTier, 100);
      expect(UserTier.bronze.xpToNextTier, 500);
      expect(UserTier.platinum.xpToNextTier, isNull);
    });

    test('progressToNext', () {
      // Starter: 0-100 range
      expect(UserTier.starter.progressToNext(0), 0.0);
      expect(UserTier.starter.progressToNext(50), 0.5);
      expect(UserTier.starter.progressToNext(100), 1.0);
    });

    test('progressToNext max tier returns 1.0', () {
      expect(UserTier.platinum.progressToNext(5000), 1.0);
      expect(UserTier.platinum.progressToNext(99999), 1.0);
    });

    test('xpRemainingToNext', () {
      expect(UserTier.starter.xpRemainingToNext(0), 100);
      expect(UserTier.starter.xpRemainingToNext(50), 50);
      expect(UserTier.starter.xpRemainingToNext(100), 0);
    });

    test('xpRemainingToNext max tier returns 0', () {
      expect(UserTier.platinum.xpRemainingToNext(5000), 0);
    });

    test('entitlements - starter', () {
      expect(UserTier.starter.maxTemplates, 4);
      expect(UserTier.starter.maxPublicTemplates, 2);
      expect(UserTier.starter.maxCustomSingleExercises, 3);
      expect(UserTier.starter.showAds, isTrue);
      expect(UserTier.starter.hasProAnalytics, isFalse);
      expect(UserTier.starter.hasCloudSync, isFalse);
    });

    test('entitlements - platinum', () {
      expect(UserTier.platinum.maxTemplates, 7);
      expect(UserTier.platinum.maxPublicTemplates, 5);
      expect(UserTier.platinum.maxCustomSingleExercises, 999);
      expect(UserTier.platinum.showAds, isFalse);
      expect(UserTier.platinum.hasProAnalytics, isTrue);
      expect(UserTier.platinum.hasCloudSync, isTrue);
    });

    test('displayName unique', () {
      final names = UserTier.values.map((t) => t.displayName).toSet();
      expect(names.length, 5);
    });

    test('maxTemplates increases with tier', () {
      expect(UserTier.starter.maxTemplates, lessThanOrEqualTo(UserTier.platinum.maxTemplates));
    });
  });
}
