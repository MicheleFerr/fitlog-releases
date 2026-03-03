// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

// ---------------------------------------------------------------------------
// Tests for pure logic extracted from CompactProfileHeader and _MiniTierAvatar.
// We test the gradient color selection and initial extraction logic.
// ---------------------------------------------------------------------------

void main() {
  // ================================================================
  // Avatar initial extraction logic
  // ================================================================
  group('avatar initial extraction', () {
    String getInitial(String userName) {
      return userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    }

    test('normal name returns uppercase first char', () {
      expect(getInitial('Michele'), 'M');
    });

    test('lowercase name returns uppercase initial', () {
      expect(getInitial('alice'), 'A');
    });

    test('empty name returns ?', () {
      expect(getInitial(''), '?');
    });

    test('single char name', () {
      expect(getInitial('Z'), 'Z');
    });

    test('name starting with digit', () {
      expect(getInitial('42User'), '4');
    });

    test('name starting with space', () {
      expect(getInitial(' Bob'), ' ');
    });

    test('unicode name', () {
      expect(getInitial('Élise'), 'É');
    });
  });

  // ================================================================
  // Gradient colors per UserTier
  // ================================================================
  group('tier gradient colors', () {
    List<Color> getGradientColors(UserTier tier) {
      switch (tier) {
        case UserTier.starter:
          return [const Color(0xFF9E9E9E), const Color(0xFF757575)];
        case UserTier.bronze:
          return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
        case UserTier.silver:
          return [const Color(0xFFE8E8E8), const Color(0xFF9E9E9E)];
        case UserTier.gold:
          return [const Color(0xFFFFD700), const Color(0xFFDAA520)];
        case UserTier.platinum:
          return [
            const Color(0xFFE5E4E2),
            const Color(0xFFB0B0B0),
            const Color(0xFFE5E4E2),
          ];
        case UserTier.diamond:
          return [
            const Color(0xFFB9F2FF),
            const Color(0xFF4FC3F7),
            const Color(0xFFB9F2FF),
          ];
        case UserTier.legend:
          return [
            const Color(0xFFFF6B35),
            const Color(0xFFFF8A65),
            const Color(0xFFFFD54F),
          ];
      }
    }

    test('starter has 2 grey colors', () {
      final colors = getGradientColors(UserTier.starter);
      expect(colors.length, 2);
      expect(colors[0], const Color(0xFF9E9E9E));
      expect(colors[1], const Color(0xFF757575));
    });

    test('bronze has 2 brown/orange colors', () {
      final colors = getGradientColors(UserTier.bronze);
      expect(colors.length, 2);
      expect(colors[0], const Color(0xFFCD7F32));
      expect(colors[1], const Color(0xFF8B4513));
    });

    test('silver has 2 light grey colors', () {
      final colors = getGradientColors(UserTier.silver);
      expect(colors.length, 2);
      expect(colors[0], const Color(0xFFE8E8E8));
      expect(colors[1], const Color(0xFF9E9E9E));
    });

    test('gold has 2 gold colors', () {
      final colors = getGradientColors(UserTier.gold);
      expect(colors.length, 2);
      expect(colors[0], const Color(0xFFFFD700));
      expect(colors[1], const Color(0xFFDAA520));
    });

    test('platinum has 3 colors (tri-color gradient)', () {
      final colors = getGradientColors(UserTier.platinum);
      expect(colors.length, 3);
      expect(colors[0], const Color(0xFFE5E4E2));
      expect(colors[1], const Color(0xFFB0B0B0));
      expect(colors[2], const Color(0xFFE5E4E2));
    });

    test('all tiers return non-empty color lists', () {
      for (final tier in UserTier.values) {
        final colors = getGradientColors(tier);
        expect(colors, isNotEmpty, reason: '$tier should have colors');
      }
    });

    test('each tier has distinct primary color', () {
      final primaryColors = UserTier.values.map(
        (t) => getGradientColors(t).first,
      ).toList();
      final distinctColors = primaryColors.toSet();
      // All 7 tiers should have distinct primary colors
      expect(distinctColors.length, UserTier.values.length);
    });
  });

  // ================================================================
  // hideTier flag logic
  // ================================================================
  group('hideTier affects avatar appearance', () {
    // When hideTier is true, use neutral colors instead of tier colors.
    // This mirrors the ternary in _MiniTierAvatar.build

    Color getAccentColor({required bool hideTier, required UserTier tier}) {
      // Simplified: in real code, uses context.colors.outline or tier.color
      return hideTier ? const Color(0xFF9E9E9E) : tier.color;
    }

    test('hideTier=true uses neutral accent', () {
      final color = getAccentColor(hideTier: true, tier: UserTier.gold);
      expect(color, const Color(0xFF9E9E9E)); // neutral grey
    });

    test('hideTier=false uses tier color', () {
      final color = getAccentColor(hideTier: false, tier: UserTier.gold);
      expect(color, UserTier.gold.color);
    });

    test('hideTier=true for all tiers returns same neutral color', () {
      for (final tier in UserTier.values) {
        final color = getAccentColor(hideTier: true, tier: tier);
        expect(
          color,
          const Color(0xFF9E9E9E),
          reason: 'tier $tier should be hidden',
        );
      }
    });

    test('hideTier=false preserves each tier distinct color', () {
      final colors = UserTier.values.map(
        (t) => getAccentColor(hideTier: false, tier: t),
      ).toSet();
      expect(colors.length, UserTier.values.length);
    });
  });

  // ================================================================
  // UserTier.color property coverage
  // ================================================================
  group('UserTier.color property', () {
    test('starter color is 0xFF9E9E9E', () {
      expect(UserTier.starter.color, const Color(0xFF9E9E9E));
    });

    test('bronze color is 0xFFCD7F32', () {
      expect(UserTier.bronze.color, const Color(0xFFCD7F32));
    });

    test('silver color is 0xFFC0C0C0', () {
      expect(UserTier.silver.color, const Color(0xFFC0C0C0));
    });

    test('gold color is 0xFFFFD700', () {
      expect(UserTier.gold.color, const Color(0xFFFFD700));
    });

    test('platinum color is 0xFFE5E4E2', () {
      expect(UserTier.platinum.color, const Color(0xFFE5E4E2));
    });

    test('all tiers have non-null colors', () {
      for (final tier in UserTier.values) {
        expect(tier.color, isNotNull, reason: '$tier.color must not be null');
      }
    });

    test('tier colors are all distinct', () {
      final colors = UserTier.values.map((t) => t.color).toList();
      final distinctColors = colors.toSet();
      expect(distinctColors.length, UserTier.values.length);
    });
  });

  // ================================================================
  // UserTier entitlements additional coverage
  // ================================================================
  group('UserTier entitlements comprehensive', () {
    test('bronze maxPublicTemplates = 2', () {
      expect(UserTier.bronze.maxPublicTemplates, 2);
    });

    test('silver maxPublicTemplates = 3', () {
      expect(UserTier.silver.maxPublicTemplates, 3);
    });

    test('gold maxPublicTemplates = 3', () {
      expect(UserTier.gold.maxPublicTemplates, 3);
    });

    test('starter maxCustomSupersets = 3', () {
      expect(UserTier.starter.maxCustomSupersets, 3);
    });

    test('bronze maxCustomSupersets = 5', () {
      expect(UserTier.bronze.maxCustomSupersets, 5);
    });

    test('platinum maxCustomSupersets = 999', () {
      expect(UserTier.platinum.maxCustomSupersets, 999);
    });

    test('starter maxCustomDropsets = 3', () {
      expect(UserTier.starter.maxCustomDropsets, 3);
    });

    test('platinum maxCustomDropsets = 999', () {
      expect(UserTier.platinum.maxCustomDropsets, 999);
    });

    test('starter maxCustomRestPause = 3', () {
      expect(UserTier.starter.maxCustomRestPause, 3);
    });

    test('silver maxCustomRestPause = 7', () {
      expect(UserTier.silver.maxCustomRestPause, 7);
    });

    test('gold maxCustomRestPause = 10', () {
      expect(UserTier.gold.maxCustomRestPause, 10);
    });

    test('platinum maxCustomRestPause = 999', () {
      expect(UserTier.platinum.maxCustomRestPause, 999);
    });

    test('gold showAds = true', () {
      expect(UserTier.gold.showAds, isTrue);
    });

    test('silver hasProAnalytics = false', () {
      expect(UserTier.silver.hasProAnalytics, isFalse);
    });

    test('gold hasProAnalytics = false', () {
      expect(UserTier.gold.hasProAnalytics, isFalse);
    });

    test('gold hasCloudSync = false', () {
      expect(UserTier.gold.hasCloudSync, isFalse);
    });

    test('silver hasCloudSync = false', () {
      expect(UserTier.silver.hasCloudSync, isFalse);
    });

    test('progression: each tier has more or equal maxTemplates than starter', () {
      for (final tier in UserTier.values) {
        expect(
          tier.maxTemplates,
          greaterThanOrEqualTo(UserTier.starter.maxTemplates),
          reason: '$tier should have at least as many templates as starter',
        );
      }
    });

    test('platinum has more maxTemplates than starter', () {
      expect(UserTier.platinum.maxTemplates, greaterThan(UserTier.starter.maxTemplates));
    });

    test('platinum+ tiers are ad-free', () {
      final adFreeTiers = UserTier.values.where((t) => !t.showAds).toList();
      expect(adFreeTiers.length, 3);
      expect(adFreeTiers, containsAll([UserTier.platinum, UserTier.diamond, UserTier.legend]));
    });

    test('platinum+ tiers have pro analytics', () {
      final proTiers = UserTier.values.where((t) => t.hasProAnalytics).toList();
      expect(proTiers.length, 3);
      expect(proTiers, containsAll([UserTier.platinum, UserTier.diamond, UserTier.legend]));
    });

    test('platinum+ tiers have cloud sync', () {
      final cloudTiers = UserTier.values.where((t) => t.hasCloudSync).toList();
      expect(cloudTiers.length, 3);
      expect(cloudTiers, containsAll([UserTier.platinum, UserTier.diamond, UserTier.legend]));
    });
  });

  // ================================================================
  // UserTier boundary XP values
  // ================================================================
  group('UserTier XP boundary precision', () {
    test('299 XP is still starter', () {
      expect(UserTier.fromXP(299), UserTier.starter);
    });

    test('300 XP is exactly bronze', () {
      expect(UserTier.fromXP(300), UserTier.bronze);
    });

    test('1499 XP is still bronze', () {
      expect(UserTier.fromXP(1499), UserTier.bronze);
    });

    test('1500 XP is exactly silver', () {
      expect(UserTier.fromXP(1500), UserTier.silver);
    });

    test('4999 XP is still silver', () {
      expect(UserTier.fromXP(4999), UserTier.silver);
    });

    test('5000 XP is exactly gold', () {
      expect(UserTier.fromXP(5000), UserTier.gold);
    });

    test('14999 XP is still gold', () {
      expect(UserTier.fromXP(14999), UserTier.gold);
    });

    test('15000 XP is exactly platinum', () {
      expect(UserTier.fromXP(15000), UserTier.platinum);
    });

    test('30000 XP is exactly diamond', () {
      expect(UserTier.fromXP(30000), UserTier.diamond);
    });

    test('60000 XP is exactly legend', () {
      expect(UserTier.fromXP(60000), UserTier.legend);
    });

    test('1000000 XP is legend (max tier)', () {
      expect(UserTier.fromXP(1000000), UserTier.legend);
    });
  });

  // ================================================================
  // UserTier progressToNext precision
  // ================================================================
  group('UserTier progressToNext precision', () {
    test('silver at 1500 XP: 0.0 progress (just entered silver)', () {
      expect(UserTier.silver.progressToNext(1500), 0.0);
    });

    test('silver at 3250 XP: 0.5 progress (midway to gold)', () {
      // xpInTier = 3250 - 1500 = 1750, xpNeeded = 5000 - 1500 = 3500
      expect(UserTier.silver.progressToNext(3250), closeTo(0.5, 0.001));
    });

    test('silver at 5000 XP: 1.0 progress (exactly at gold)', () {
      expect(UserTier.silver.progressToNext(5000), 1.0);
    });

    test('gold at 10000 XP: 0.5 progress', () {
      // xpInTier = 10000 - 5000 = 5000, xpNeeded = 15000 - 5000 = 10000
      expect(UserTier.gold.progressToNext(10000), closeTo(0.5, 0.001));
    });

    test('bronze at 600 XP: 0.25 progress', () {
      // xpInTier = 600 - 300 = 300, xpNeeded = 1500 - 300 = 1200
      expect(UserTier.bronze.progressToNext(600), closeTo(0.25, 0.001));
    });
  });

  // ================================================================
  // UserTier xpRemainingToNext precision
  // ================================================================
  group('UserTier xpRemainingToNext precision', () {
    test('gold at 5000 XP needs 10000 more to reach platinum', () {
      expect(UserTier.gold.xpRemainingToNext(5000), 10000);
    });

    test('gold at 10000 XP needs 5000 more', () {
      expect(UserTier.gold.xpRemainingToNext(10000), 5000);
    });

    test('gold at 15000 XP needs 0 more (reached platinum)', () {
      expect(UserTier.gold.xpRemainingToNext(15000), 0);
    });

    test('silver at 1500 XP needs 3500 more to reach gold', () {
      expect(UserTier.silver.xpRemainingToNext(1500), 3500);
    });

    test('silver at 3250 XP needs 1750 more', () {
      expect(UserTier.silver.xpRemainingToNext(3250), 1750);
    });

    test('bronze at 300 XP needs 1200 more to reach silver', () {
      expect(UserTier.bronze.xpRemainingToNext(300), 1200);
    });
  });
}
