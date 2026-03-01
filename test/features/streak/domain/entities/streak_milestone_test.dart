import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/streak_milestone.dart';

void main() {
  group('StreakMilestone enum values', () {
    test('weekWarrior has correct days and badge', () {
      expect(StreakMilestone.weekWarrior.days, 7);
      expect(StreakMilestone.weekWarrior.badge, '🔥 Week Warrior');
    });

    test('consistentChampion has correct days and badge', () {
      expect(StreakMilestone.consistentChampion.days, 30);
      expect(StreakMilestone.consistentChampion.badge, '💪 Consistent Champion');
    });

    test('legendary has correct days and badge', () {
      expect(StreakMilestone.legendary.days, 100);
      expect(StreakMilestone.legendary.badge, '🏆 Legendary');
    });
  });

  group('StreakMilestone.getNextMilestone', () {
    test('returns weekWarrior when streak is 0', () {
      expect(StreakMilestone.getNextMilestone(0), StreakMilestone.weekWarrior);
    });

    test('returns weekWarrior when streak is 1', () {
      expect(StreakMilestone.getNextMilestone(1), StreakMilestone.weekWarrior);
    });

    test('returns weekWarrior when streak is 6', () {
      expect(StreakMilestone.getNextMilestone(6), StreakMilestone.weekWarrior);
    });

    test('returns consistentChampion when streak is 7', () {
      expect(
        StreakMilestone.getNextMilestone(7),
        StreakMilestone.consistentChampion,
      );
    });

    test('returns consistentChampion when streak is 15', () {
      expect(
        StreakMilestone.getNextMilestone(15),
        StreakMilestone.consistentChampion,
      );
    });

    test('returns consistentChampion when streak is 29', () {
      expect(
        StreakMilestone.getNextMilestone(29),
        StreakMilestone.consistentChampion,
      );
    });

    test('returns legendary when streak is 30', () {
      expect(StreakMilestone.getNextMilestone(30), StreakMilestone.legendary);
    });

    test('returns legendary when streak is 50', () {
      expect(StreakMilestone.getNextMilestone(50), StreakMilestone.legendary);
    });

    test('returns legendary when streak is 99', () {
      expect(StreakMilestone.getNextMilestone(99), StreakMilestone.legendary);
    });

    test('returns null when streak is 100 (max milestone reached)', () {
      expect(StreakMilestone.getNextMilestone(100), isNull);
    });

    test('returns null when streak is 200 (beyond max)', () {
      expect(StreakMilestone.getNextMilestone(200), isNull);
    });
  });

  group('StreakMilestone.getCurrentMilestone', () {
    test('returns null when streak is 0', () {
      expect(StreakMilestone.getCurrentMilestone(0), isNull);
    });

    test('returns null when streak is 6 (below first milestone)', () {
      expect(StreakMilestone.getCurrentMilestone(6), isNull);
    });

    test('returns weekWarrior when streak is exactly 7', () {
      expect(
        StreakMilestone.getCurrentMilestone(7),
        StreakMilestone.weekWarrior,
      );
    });

    test('returns weekWarrior when streak is 10', () {
      expect(
        StreakMilestone.getCurrentMilestone(10),
        StreakMilestone.weekWarrior,
      );
    });

    test('returns weekWarrior when streak is 29', () {
      expect(
        StreakMilestone.getCurrentMilestone(29),
        StreakMilestone.weekWarrior,
      );
    });

    test('returns consistentChampion when streak is exactly 30', () {
      expect(
        StreakMilestone.getCurrentMilestone(30),
        StreakMilestone.consistentChampion,
      );
    });

    test('returns consistentChampion when streak is 50', () {
      expect(
        StreakMilestone.getCurrentMilestone(50),
        StreakMilestone.consistentChampion,
      );
    });

    test('returns consistentChampion when streak is 99', () {
      expect(
        StreakMilestone.getCurrentMilestone(99),
        StreakMilestone.consistentChampion,
      );
    });

    test('returns legendary when streak is exactly 100', () {
      expect(
        StreakMilestone.getCurrentMilestone(100),
        StreakMilestone.legendary,
      );
    });

    test('returns legendary when streak is 150', () {
      expect(
        StreakMilestone.getCurrentMilestone(150),
        StreakMilestone.legendary,
      );
    });
  });

  group('StreakMilestone.getProgressToNext', () {
    test('returns 0.0 when at streak 0 (start of weekWarrior range)', () {
      // currentStreak=0, previousDays=0, nextDays=7 → (0-0)/(7-0) = 0.0
      expect(StreakMilestone.getProgressToNext(0), closeTo(0.0, 0.001));
    });

    test('returns correct fraction progressing to weekWarrior', () {
      // currentStreak=3, no current milestone → previousDays=0, nextDays=7
      // progress = (3 - 0) / (7 - 0) = 3/7 ≈ 0.4286
      final progress = StreakMilestone.getProgressToNext(3);
      expect(progress, closeTo(3 / 7, 0.001));
    });

    test('returns correct fraction at 6 days (just before weekWarrior)', () {
      // progress = 6/7 ≈ 0.857
      final progress = StreakMilestone.getProgressToNext(6);
      expect(progress, closeTo(6 / 7, 0.001));
    });

    test('returns correct fraction progressing from weekWarrior to consistentChampion', () {
      // currentStreak=14, current=weekWarrior(7), next=consistentChampion(30)
      // progress = (14 - 7) / (30 - 7) = 7/23 ≈ 0.304
      final progress = StreakMilestone.getProgressToNext(14);
      expect(progress, closeTo(7 / 23, 0.001));
    });

    test('returns correct fraction progressing from consistentChampion to legendary', () {
      // currentStreak=65, current=consistentChampion(30), next=legendary(100)
      // progress = (65 - 30) / (100 - 30) = 35/70 = 0.5
      final progress = StreakMilestone.getProgressToNext(65);
      expect(progress, closeTo(0.5, 0.001));
    });

    test('returns 1.0 when at or beyond max milestone (100)', () {
      expect(StreakMilestone.getProgressToNext(100), 1.0);
    });

    test('returns 1.0 when streak exceeds max milestone', () {
      expect(StreakMilestone.getProgressToNext(365), 1.0);
    });

    test('returns 0.0 at the start of weekWarrior window', () {
      // currentStreak=7 means next=consistentChampion, current=weekWarrior
      // progress = (7 - 7) / (30 - 7) = 0/23 = 0.0
      final progress = StreakMilestone.getProgressToNext(7);
      expect(progress, closeTo(0.0, 0.001));
    });

    test('returns 0.0 at the start of legendray window (streak=30)', () {
      // next=legendary(100), current=consistentChampion(30)
      // progress = (30 - 30) / (100 - 30) = 0/70 = 0.0
      final progress = StreakMilestone.getProgressToNext(30);
      expect(progress, closeTo(0.0, 0.001));
    });
  });
}
