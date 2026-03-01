import 'package:flutter_test/flutter_test.dart';

/// Tests for pure logic extracted from WeeklyStatsBottomSheet
/// and WeeklyWorkoutCalendar widgets.
void main() {
  // ═══════════════════════════════════════════════════════════════
  // Format Duration Logic
  // ═══════════════════════════════════════════════════════════════
  group('formatDuration logic', () {
    String formatDuration(Duration duration) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    }

    test('zero duration = "0m"', () {
      expect(formatDuration(Duration.zero), '0m');
    });

    test('30 minutes = "30m"', () {
      expect(formatDuration(const Duration(minutes: 30)), '30m');
    });

    test('59 minutes = "59m"', () {
      expect(formatDuration(const Duration(minutes: 59)), '59m');
    });

    test('60 minutes = "1h 0m"', () {
      expect(formatDuration(const Duration(minutes: 60)), '1h 0m');
    });

    test('90 minutes = "1h 30m"', () {
      expect(formatDuration(const Duration(minutes: 90)), '1h 30m');
    });

    test('120 minutes = "2h 0m"', () {
      expect(formatDuration(const Duration(hours: 2)), '2h 0m');
    });

    test('75 minutes = "1h 15m"', () {
      expect(formatDuration(const Duration(minutes: 75)), '1h 15m');
    });

    test('1 minute = "1m"', () {
      expect(formatDuration(const Duration(minutes: 1)), '1m');
    });

    test('5 hours 45 minutes = "5h 45m"', () {
      expect(
        formatDuration(const Duration(hours: 5, minutes: 45)),
        '5h 45m',
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Weekly workout filtering logic
  // ═══════════════════════════════════════════════════════════════
  group('weekly workout date range logic', () {
    bool isInWeek(DateTime workoutDate, DateTime monday) {
      final sunday = monday.add(const Duration(days: 6));
      final workoutDay = DateTime(
        workoutDate.year,
        workoutDate.month,
        workoutDate.day,
      );
      final mondayDate = DateTime(monday.year, monday.month, monday.day);
      final sundayDate = DateTime(sunday.year, sunday.month, sunday.day);
      return workoutDay.isAfter(
            mondayDate.subtract(const Duration(days: 1)),
          ) &&
          workoutDay.isBefore(sundayDate.add(const Duration(days: 1)));
    }

    late DateTime monday;

    setUp(() {
      // Use a fixed Monday: 2026-02-23
      monday = DateTime(2026, 2, 23);
    });

    test('Monday workout is in week', () {
      expect(isInWeek(DateTime(2026, 2, 23, 10, 0), monday), isTrue);
    });

    test('Tuesday workout is in week', () {
      expect(isInWeek(DateTime(2026, 2, 24, 8, 0), monday), isTrue);
    });

    test('Sunday workout is in week', () {
      expect(isInWeek(DateTime(2026, 3, 1, 20, 0), monday), isTrue);
    });

    test('previous Sunday not in week', () {
      expect(isInWeek(DateTime(2026, 2, 22, 20, 0), monday), isFalse);
    });

    test('next Monday not in week', () {
      expect(isInWeek(DateTime(2026, 3, 2, 6, 0), monday), isFalse);
    });

    test('workout with time component on Monday is in week', () {
      expect(isInWeek(DateTime(2026, 2, 23, 23, 59), monday), isTrue);
    });

    test('workout from two weeks ago not in week', () {
      expect(isInWeek(DateTime(2026, 2, 9, 12, 0), monday), isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // isSameDay logic
  // ═══════════════════════════════════════════════════════════════
  group('isSameDay logic', () {
    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    test('same date returns true', () {
      expect(
        isSameDay(DateTime(2026, 2, 23), DateTime(2026, 2, 23)),
        isTrue,
      );
    });

    test('different time same day returns true', () {
      expect(
        isSameDay(DateTime(2026, 2, 23, 8, 0), DateTime(2026, 2, 23, 20, 0)),
        isTrue,
      );
    });

    test('different day returns false', () {
      expect(
        isSameDay(DateTime(2026, 2, 23), DateTime(2026, 2, 24)),
        isFalse,
      );
    });

    test('different month returns false', () {
      expect(
        isSameDay(DateTime(2026, 2, 23), DateTime(2026, 3, 23)),
        isFalse,
      );
    });

    test('different year returns false', () {
      expect(
        isSameDay(DateTime(2025, 2, 23), DateTime(2026, 2, 23)),
        isFalse,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Week start (Monday) calculation
  // ═══════════════════════════════════════════════════════════════
  group('week start calculation', () {
    DateTime getMondayOfWeek(DateTime date) {
      return DateTime(date.year, date.month, date.day)
          .subtract(Duration(days: date.weekday - 1));
    }

    test('Monday stays Monday', () {
      // 2026-02-23 is a Monday (weekday=1)
      final monday = DateTime(2026, 2, 23);
      expect(getMondayOfWeek(monday), DateTime(2026, 2, 23));
    });

    test('Wednesday gives previous Monday', () {
      // 2026-02-25 is Wednesday (weekday=3)
      final wednesday = DateTime(2026, 2, 25);
      expect(getMondayOfWeek(wednesday), DateTime(2026, 2, 23));
    });

    test('Sunday gives previous Monday', () {
      // 2026-03-01 is Sunday (weekday=7)
      final sunday = DateTime(2026, 3, 1);
      expect(getMondayOfWeek(sunday), DateTime(2026, 2, 23));
    });

    test('Saturday gives previous Monday', () {
      // 2026-02-28 is Saturday (weekday=6)
      final saturday = DateTime(2026, 2, 28);
      expect(getMondayOfWeek(saturday), DateTime(2026, 2, 23));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // Volume formatting (t display)
  // ═══════════════════════════════════════════════════════════════
  group('volume display logic (tonnes)', () {
    String formatVolume(double volumeKg) {
      return '${(volumeKg / 1000).toStringAsFixed(1)}t';
    }

    test('0 kg = "0.0t"', () => expect(formatVolume(0), '0.0t'));
    test('1000 kg = "1.0t"', () => expect(formatVolume(1000), '1.0t'));
    test('1500 kg = "1.5t"', () => expect(formatVolume(1500), '1.5t'));
    test('500 kg = "0.5t"', () => expect(formatVolume(500), '0.5t'));
    test('10000 kg = "10.0t"', () => expect(formatVolume(10000), '10.0t'));
    test('1234 kg = "1.2t"', () => expect(formatVolume(1234), '1.2t'));
  });

  // ═══════════════════════════════════════════════════════════════
  // Relative date logic
  // ═══════════════════════════════════════════════════════════════
  group('relative date difference calculation', () {
    int getDaysDifference(DateTime workoutDate, DateTime now) {
      final today = DateTime(now.year, now.month, now.day);
      final workoutDay = DateTime(
        workoutDate.year,
        workoutDate.month,
        workoutDate.day,
      );
      return today.difference(workoutDay).inDays;
    }

    final now = DateTime(2026, 3, 1, 12, 0);

    test('today = 0 days', () {
      final today = DateTime(2026, 3, 1, 8, 0);
      expect(getDaysDifference(today, now), 0);
    });

    test('yesterday = 1 day', () {
      final yesterday = DateTime(2026, 2, 28, 20, 0);
      expect(getDaysDifference(yesterday, now), 1);
    });

    test('2 days ago = 2', () {
      final twoDaysAgo = DateTime(2026, 2, 27, 10, 0);
      expect(getDaysDifference(twoDaysAgo, now), 2);
    });

    test('7 days ago = 7', () {
      final oneWeekAgo = DateTime(2026, 2, 22, 15, 0);
      expect(getDaysDifference(oneWeekAgo, now), 7);
    });
  });
}
