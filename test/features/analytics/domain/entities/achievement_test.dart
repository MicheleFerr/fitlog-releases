import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';

void main() {
  group('BadgeType - xpReward', () {
    test('firstPR returns 50 XP', () {
      expect(BadgeType.firstPR.xpReward, equals(50));
    });

    test('streakMaster7 returns 100 XP', () {
      expect(BadgeType.streakMaster7.xpReward, equals(100));
    });

    test('volumeLegend10k returns 100 XP', () {
      expect(BadgeType.volumeLegend10k.xpReward, equals(100));
    });

    test('workoutCompletionist50 returns 100 XP', () {
      expect(BadgeType.workoutCompletionist50.xpReward, equals(100));
    });

    test('streakMaster14 returns 150 XP', () {
      expect(BadgeType.streakMaster14.xpReward, equals(150));
    });

    test('volumeLegend50k returns 150 XP', () {
      expect(BadgeType.volumeLegend50k.xpReward, equals(150));
    });

    test('workoutCompletionist100 returns 150 XP', () {
      expect(BadgeType.workoutCompletionist100.xpReward, equals(150));
    });

    test('streakMaster30 returns 200 XP', () {
      expect(BadgeType.streakMaster30.xpReward, equals(200));
    });

    test('balancedBuilder returns 200 XP', () {
      expect(BadgeType.balancedBuilder.xpReward, equals(200));
    });

    test('oneRepMonarch returns 200 XP', () {
      expect(BadgeType.oneRepMonarch.xpReward, equals(200));
    });

    test('consistencyChampion returns 200 XP', () {
      expect(BadgeType.consistencyChampion.xpReward, equals(200));
    });

    test('volumeLegend100k returns 300 XP', () {
      expect(BadgeType.volumeLegend100k.xpReward, equals(300));
    });

    test('workoutCompletionist500 returns 300 XP', () {
      expect(BadgeType.workoutCompletionist500.xpReward, equals(300));
    });

    test('all BadgeType values have a positive xpReward', () {
      for (final badge in BadgeType.values) {
        expect(badge.xpReward, greaterThan(0),
            reason: '${badge.name} should have xpReward > 0');
      }
    });

    test('elite badges have higher XP than common badges', () {
      // Elite (300) > Advanced (200) > Intermediate (150) > Common (100) > Starter (50)
      expect(BadgeType.volumeLegend100k.xpReward,
          greaterThan(BadgeType.balancedBuilder.xpReward));
      expect(BadgeType.balancedBuilder.xpReward,
          greaterThan(BadgeType.volumeLegend50k.xpReward));
      expect(BadgeType.volumeLegend50k.xpReward,
          greaterThan(BadgeType.volumeLegend10k.xpReward));
      expect(BadgeType.volumeLegend10k.xpReward,
          greaterThan(BadgeType.firstPR.xpReward));
    });
  });

  group('Achievement - construction and equality', () {
    final now = DateTime(2025, 1, 15, 10, 30);

    test('creates achievement with all required fields', () {
      final achievement = Achievement(
        id: 'ach_001',
        userId: 'user_123',
        badgeType: BadgeType.firstPR,
        unlockedAt: now,
        evidence: {'prType': 'weight', 'exercise': 'Bench Press', 'value': 100},
      );

      expect(achievement.id, equals('ach_001'));
      expect(achievement.userId, equals('user_123'));
      expect(achievement.badgeType, equals(BadgeType.firstPR));
      expect(achievement.unlockedAt, equals(now));
      expect(achievement.evidence['exercise'], equals('Bench Press'));
    });

    test('two achievements with same data are equal (freezed equality)', () {
      final a1 = Achievement(
        id: 'ach_001',
        userId: 'user_123',
        badgeType: BadgeType.streakMaster7,
        unlockedAt: now,
        evidence: {'streakDays': 7},
      );

      final a2 = Achievement(
        id: 'ach_001',
        userId: 'user_123',
        badgeType: BadgeType.streakMaster7,
        unlockedAt: now,
        evidence: {'streakDays': 7},
      );

      expect(a1, equals(a2));
    });

    test('two achievements with different ids are not equal', () {
      final a1 = Achievement(
        id: 'ach_001',
        userId: 'user_123',
        badgeType: BadgeType.firstPR,
        unlockedAt: now,
        evidence: {},
      );

      final a2 = Achievement(
        id: 'ach_002',
        userId: 'user_123',
        badgeType: BadgeType.firstPR,
        unlockedAt: now,
        evidence: {},
      );

      expect(a1, isNot(equals(a2)));
    });

    test('copyWith creates new achievement with updated field', () {
      final original = Achievement(
        id: 'ach_001',
        userId: 'user_123',
        badgeType: BadgeType.firstPR,
        unlockedAt: now,
        evidence: {},
      );

      final updated = original.copyWith(badgeType: BadgeType.streakMaster7);

      expect(updated.id, equals('ach_001'));
      expect(updated.badgeType, equals(BadgeType.streakMaster7));
      expect(original.badgeType, equals(BadgeType.firstPR));
    });

    test('achievement with volume evidence stores expected data', () {
      final achievement = Achievement(
        id: 'ach_002',
        userId: 'user_456',
        badgeType: BadgeType.volumeLegend10k,
        unlockedAt: now,
        evidence: {'totalVolume': 10000, 'unit': 'kg'},
      );

      expect(achievement.evidence['totalVolume'], equals(10000));
      expect(achievement.evidence['unit'], equals('kg'));
    });

    test('fromJson round-trips correctly', () {
      final original = Achievement(
        id: 'ach_003',
        userId: 'user_789',
        badgeType: BadgeType.workoutCompletionist50,
        unlockedAt: now,
        evidence: {'count': 50},
      );

      final json = original.toJson();
      final restored = Achievement.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.userId, equals(original.userId));
      expect(restored.badgeType, equals(original.badgeType));
    });
  });
}
