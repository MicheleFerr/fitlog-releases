import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/level_system.dart';

void main() {
  // ---------------------------------------------------------------------------
  // LevelSystem.getXpForLevel
  // ---------------------------------------------------------------------------
  group('LevelSystem.getXpForLevel', () {
    test('level 1 requires 0 XP', () {
      expect(LevelSystem.getXpForLevel(1), 0);
    });

    test('level 0 or below returns 0 XP (treated as level 1)', () {
      expect(LevelSystem.getXpForLevel(0), 0);
      expect(LevelSystem.getXpForLevel(-1), 0);
    });

    test('level 2 requires base XP (100)', () {
      // baseXpPerLevel * xpMultiplier^(2-1) = 100 * 1.15^1 = 115, rounded
      expect(LevelSystem.getXpForLevel(2), 115);
    });

    test('XP required increases with level', () {
      final xp2 = LevelSystem.getXpForLevel(2);
      final xp5 = LevelSystem.getXpForLevel(5);
      final xp10 = LevelSystem.getXpForLevel(10);

      expect(xp5, greaterThan(xp2));
      expect(xp10, greaterThan(xp5));
    });

    test('XP above maxLevel returns xp for maxLevel', () {
      final xpMax = LevelSystem.getXpForLevel(LevelSystem.maxLevel);
      final xpOverMax = LevelSystem.getXpForLevel(LevelSystem.maxLevel + 1);

      expect(xpOverMax, xpMax);
    });
  });

  // ---------------------------------------------------------------------------
  // LevelSystem.getTotalXpForLevel
  // ---------------------------------------------------------------------------
  group('LevelSystem.getTotalXpForLevel', () {
    test('total XP for level 1 is 0', () {
      expect(LevelSystem.getTotalXpForLevel(1), 0);
    });

    test('total XP for level 2 equals XP for level 2', () {
      expect(
        LevelSystem.getTotalXpForLevel(2),
        LevelSystem.getXpForLevel(2),
      );
    });

    test('total XP is cumulative sum', () {
      final total3 = LevelSystem.getTotalXpForLevel(3);
      final expected = LevelSystem.getXpForLevel(2) + LevelSystem.getXpForLevel(3);

      expect(total3, expected);
    });

    test('total XP increases monotonically', () {
      final total5 = LevelSystem.getTotalXpForLevel(5);
      final total10 = LevelSystem.getTotalXpForLevel(10);
      final total20 = LevelSystem.getTotalXpForLevel(20);

      expect(total10, greaterThan(total5));
      expect(total20, greaterThan(total10));
    });
  });

  // ---------------------------------------------------------------------------
  // LevelSystem.getLevelInfo
  // ---------------------------------------------------------------------------
  group('LevelSystem.getLevelInfo', () {
    test('0 XP returns level 1', () {
      final info = LevelSystem.getLevelInfo(0);

      expect(info.level, 1);
      expect(info.totalXp, 0);
    });

    test('level 1 has title Principiante', () {
      final info = LevelSystem.getLevelInfo(0);

      expect(info.title, 'Principiante');
    });

    test('XP exactly at level boundary promotes correctly', () {
      // Get total XP needed to reach level 2
      final xpToLevel2 = LevelSystem.getTotalXpForLevel(2);
      final info = LevelSystem.getLevelInfo(xpToLevel2);

      expect(info.level, 2);
    });

    test('partial XP progress calculates progressPercentage correctly', () {
      // 0 XP → level 1, progressPercentage depends on xpForNextLevel
      final info = LevelSystem.getLevelInfo(0);

      expect(info.progressPercentage, greaterThanOrEqualTo(0.0));
      expect(info.progressPercentage, lessThanOrEqualTo(1.0));
    });

    test('at max level progressPercentage is 1.0 (capped)', () {
      // At max level (100) the xpForNextLevel is 0, so progressPercentage = 1.0
      final xpAtMax = LevelSystem.getTotalXpForLevel(LevelSystem.maxLevel);
      final info = LevelSystem.getLevelInfo(xpAtMax);

      expect(info.level, LevelSystem.maxLevel);
      // When xpForNextLevel == 0, progressPercentage is set to 1.0
      expect(info.progressPercentage, 1.0);
    });

    test('level info includes correct totalXp', () {
      final totalXp = LevelSystem.getTotalXpForLevel(3) + 50;
      final info = LevelSystem.getLevelInfo(totalXp);

      expect(info.totalXp, totalXp);
    });

    test('level 5 has customWorkoutTemplates perk', () {
      // Get XP for level 5
      final xp = LevelSystem.getTotalXpForLevel(5);
      final info = LevelSystem.getLevelInfo(xp);

      expect(info.perks, contains(LevelPerk.customWorkoutTemplates));
    });

    test('level 1 has no perks', () {
      final info = LevelSystem.getLevelInfo(0);

      expect(info.perks, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Level title boundaries
  // ---------------------------------------------------------------------------
  group('LevelSystem titles', () {
    final cases = [
      (1, 'Principiante'),
      (10, 'Principiante'),
      (11, 'Apprendista'),
      (20, 'Apprendista'),
      (21, 'Intermedio'),
      (30, 'Intermedio'),
      (31, 'Avanzato'),
      (50, 'Esperto'),
      (60, 'Maestro'),
      (70, 'Veterano'),
      (80, 'Elite'),
      (90, 'Campione'),
      (99, 'Leggenda'),
      (100, 'Titano'),
    ];

    for (final (level, expectedTitle) in cases) {
      test('level $level has title "$expectedTitle"', () {
        final xp = LevelSystem.getTotalXpForLevel(level);
        final info = LevelSystem.getLevelInfo(xp);

        expect(info.title, expectedTitle);
      });
    }
  });

  // ---------------------------------------------------------------------------
  // LevelSystem.calculateWorkoutXp
  // ---------------------------------------------------------------------------
  group('LevelSystem.calculateWorkoutXp', () {
    test('minimum workout returns at least 50 base XP', () {
      final xp = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 0,
      );

      expect(xp, 50);
    });

    test('duration adds up to 60 XP (capped)', () {
      // 120 min workout: duration XP should be capped at 60
      final xpWithLongWorkout = LevelSystem.calculateWorkoutXp(
        duration: 120,
        exercises: 0,
        totalVolume: 0,
      );
      final xpWith60Min = LevelSystem.calculateWorkoutXp(
        duration: 60,
        exercises: 0,
        totalVolume: 0,
      );

      expect(xpWithLongWorkout, xpWith60Min);
      expect(xpWith60Min, 50 + 60); // base + capped duration
    });

    test('exercises add 5 XP each up to 50 XP', () {
      final xpWith10Exercises = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 10,
        totalVolume: 0,
      );
      final xpWith15Exercises = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 15, // would be 75 XP but capped at 50
        totalVolume: 0,
      );

      expect(xpWith10Exercises, 50 + 50); // 10 * 5 = 50 (exactly at cap)
      expect(xpWith15Exercises, 50 + 50); // capped at 50
    });

    test('personal record adds 50 bonus XP', () {
      final xpNoPR = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 0,
        isPersonalRecord: false,
      );
      final xpWithPR = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 0,
        isPersonalRecord: true,
      );

      expect(xpWithPR - xpNoPR, 50);
    });

    test('streak bonus adds 2 XP per day up to 50 XP', () {
      final xpNoStreak = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 0,
        streakDays: 0,
      );
      final xpStreak5 = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 0,
        streakDays: 5,
      );
      final xpStreak100 = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 0,
        streakDays: 100,
      );

      expect(xpStreak5 - xpNoStreak, 10); // 5 * 2 = 10
      expect(xpStreak100 - xpNoStreak, 50); // capped at 50
    });

    test('volume adds 1 XP per 100 kg up to 100 XP', () {
      final xpLowVolume = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 500, // 5 XP
      );
      final xpHighVolume = LevelSystem.calculateWorkoutXp(
        duration: 0,
        exercises: 0,
        totalVolume: 20000, // would be 200 XP, capped at 100
      );

      expect(xpLowVolume, 55); // 50 base + 5
      expect(xpHighVolume, 150); // 50 base + 100 capped
    });

    test('full workout with all bonuses calculates correctly', () {
      final xp = LevelSystem.calculateWorkoutXp(
        duration: 60, // +60 XP
        exercises: 10, // +50 XP
        totalVolume: 10000, // +100 XP
        isPersonalRecord: true, // +50 XP
        streakDays: 25, // +50 XP
      );

      // 50 base + 60 + 50 + 100 + 50 + 50 = 360
      expect(xp, 360);
    });
  });

  // ---------------------------------------------------------------------------
  // LevelSystem.calculateDailyLoginBonus
  // ---------------------------------------------------------------------------
  group('LevelSystem.calculateDailyLoginBonus', () {
    test('0 or negative days returns 0', () {
      expect(LevelSystem.calculateDailyLoginBonus(0), 0);
      expect(LevelSystem.calculateDailyLoginBonus(-1), 0);
    });

    test('day 1 returns 1 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(1), 1);
    });

    test('day 2 returns 2 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(2), 2);
    });

    test('day 3 returns 4 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(3), 4);
    });

    test('day 4 returns 8 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(4), 8);
    });

    test('day 5 returns 16 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(5), 16);
    });

    test('day 6 returns 32 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(6), 32);
    });

    test('day 7 returns 100 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(7), 100);
    });

    test('day 8+ always returns 100 XP', () {
      expect(LevelSystem.calculateDailyLoginBonus(8), 100);
      expect(LevelSystem.calculateDailyLoginBonus(30), 100);
      expect(LevelSystem.calculateDailyLoginBonus(365), 100);
    });
  });

  // ---------------------------------------------------------------------------
  // LevelSystem.getDailyLoginBonusInfo
  // ---------------------------------------------------------------------------
  group('LevelSystem.getDailyLoginBonusInfo', () {
    test('0 days shows start message', () {
      final info = LevelSystem.getDailyLoginBonusInfo(0);

      expect(info.consecutiveDays, 0);
      expect(info.currentDayBonus, 0);
      expect(info.isMaxBonus, isFalse);
      expect(info.message, isNotEmpty);
    });

    test('day 3 shows next day bonus preview', () {
      final info = LevelSystem.getDailyLoginBonusInfo(3);

      expect(info.consecutiveDays, 3);
      expect(info.currentDayBonus, 4);
      expect(info.nextDayBonus, LevelSystem.calculateDailyLoginBonus(4));
      expect(info.isMaxBonus, isFalse);
      expect(info.message, contains('8')); // tomorrow's 8 XP
    });

    test('day 7 is max bonus', () {
      final info = LevelSystem.getDailyLoginBonusInfo(7);

      expect(info.isMaxBonus, isTrue);
      expect(info.currentDayBonus, 100);
    });

    test('day 15 is still max bonus', () {
      final info = LevelSystem.getDailyLoginBonusInfo(15);

      expect(info.isMaxBonus, isTrue);
      expect(info.currentDayBonus, 100);
      expect(info.message, contains('100'));
    });
  });

  // ---------------------------------------------------------------------------
  // LevelPerk.title and description
  // ---------------------------------------------------------------------------
  group('LevelPerk extension', () {
    test('all perks have non-empty titles', () {
      for (final perk in LevelPerk.values) {
        expect(perk.title, isNotEmpty, reason: 'Perk $perk missing title');
      }
    });

    test('all perks have non-empty descriptions', () {
      for (final perk in LevelPerk.values) {
        expect(
          perk.description,
          isNotEmpty,
          reason: 'Perk $perk missing description',
        );
      }
    });

    test('coachingMode has expected title', () {
      expect(LevelPerk.coachingMode.title, 'Modalità Coach');
    });

    test('advancedAnalytics has expected title', () {
      expect(LevelPerk.advancedAnalytics.title, 'Analisi Avanzate');
    });
  });

  // ---------------------------------------------------------------------------
  // LevelInfo class
  // ---------------------------------------------------------------------------
  group('LevelInfo', () {
    test('stores all fields correctly', () {
      const info = LevelInfo(
        level: 5,
        currentXp: 50,
        xpForNextLevel: 200,
        totalXp: 350,
        progressPercentage: 0.25,
        title: 'Principiante',
        perks: [LevelPerk.customWorkoutTemplates],
      );

      expect(info.level, 5);
      expect(info.currentXp, 50);
      expect(info.xpForNextLevel, 200);
      expect(info.totalXp, 350);
      expect(info.progressPercentage, 0.25);
      expect(info.title, 'Principiante');
      expect(info.perks, [LevelPerk.customWorkoutTemplates]);
    });
  });
}
