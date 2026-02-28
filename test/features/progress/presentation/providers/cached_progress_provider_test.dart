import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';

void main() {
  // =========================================================================
  // DashboardStats
  // =========================================================================
  group('DashboardStats', () {
    test('constructor stores all fields', () {
      const stats = DashboardStats(
        currentStreak: 5,
        totalWorkouts: 42,
        weeklyFrequency: 3.5,
        totalVolume: 50000,
        volumeIncrease: 12.5,
        maxPR: 140,
        prExercise: 'Deadlift',
      );
      expect(stats.currentStreak, 5);
      expect(stats.totalWorkouts, 42);
      expect(stats.weeklyFrequency, 3.5);
      expect(stats.totalVolume, 50000);
      expect(stats.volumeIncrease, 12.5);
      expect(stats.maxPR, 140);
      expect(stats.prExercise, 'Deadlift');
    });

    test('empty factory returns zeroes', () {
      final stats = DashboardStats.empty();
      expect(stats.currentStreak, 0);
      expect(stats.totalWorkouts, 0);
      expect(stats.weeklyFrequency, 0.0);
      expect(stats.totalVolume, 0.0);
      expect(stats.volumeIncrease, 0.0);
      expect(stats.maxPR, 0.0);
      expect(stats.prExercise, 'N/A');
    });
  });

  // =========================================================================
  // CachedDashboardStats
  // =========================================================================
  group('CachedDashboardStats', () {
    CachedDashboardStats _make({
      int totalWorkouts = 10,
      int totalExercises = 30,
      int currentStreak = 2,
      double weeklyFrequency = 3.0,
      double totalVolume = 5000,
      double maxPR = 120,
      String prExercise = 'Bench',
      Map<String, bool>? workoutDates,
      DateTime? lastCalculated,
    }) {
      return CachedDashboardStats(
        totalWorkouts: totalWorkouts,
        totalExercises: totalExercises,
        currentStreak: currentStreak,
        weeklyFrequency: weeklyFrequency,
        totalVolume: totalVolume,
        maxPR: maxPR,
        prExercise: prExercise,
        workoutDates: workoutDates ?? {},
        lastCalculated: lastCalculated ?? DateTime.now(),
      );
    }

    group('empty factory', () {
      test('returns zeroed stats', () {
        final stats = CachedDashboardStats.empty();
        expect(stats.totalWorkouts, 0);
        expect(stats.totalExercises, 0);
        expect(stats.currentStreak, 0);
        expect(stats.weeklyFrequency, 0.0);
        expect(stats.totalVolume, 0.0);
        expect(stats.maxPR, 0.0);
        expect(stats.prExercise, 'N/A');
        expect(stats.workoutDates, isEmpty);
      });
    });

    group('JSON round-trip', () {
      test('toJson -> fromJson preserves all fields', () {
        final original = _make(
          totalWorkouts: 25,
          totalExercises: 75,
          currentStreak: 4,
          weeklyFrequency: 3.5,
          totalVolume: 12345.6,
          maxPR: 180.0,
          prExercise: 'Squat',
          workoutDates: {'2026-01-15': true, '2026-01-16': true},
          lastCalculated: DateTime(2026, 1, 20, 10, 30),
        );

        final json = original.toJson();
        final restored = CachedDashboardStats.fromJson(json);

        expect(restored.totalWorkouts, original.totalWorkouts);
        expect(restored.totalExercises, original.totalExercises);
        expect(restored.currentStreak, original.currentStreak);
        expect(restored.weeklyFrequency, original.weeklyFrequency);
        expect(restored.totalVolume, original.totalVolume);
        expect(restored.maxPR, original.maxPR);
        expect(restored.prExercise, original.prExercise);
        expect(restored.workoutDates, original.workoutDates);
        expect(
          restored.lastCalculated.toIso8601String(),
          original.lastCalculated.toIso8601String(),
        );
      });

      test('fromJson handles missing fields with defaults', () {
        final stats = CachedDashboardStats.fromJson({});
        expect(stats.totalWorkouts, 0);
        expect(stats.totalExercises, 0);
        expect(stats.currentStreak, 0);
        expect(stats.weeklyFrequency, 0.0);
        expect(stats.totalVolume, 0.0);
        expect(stats.maxPR, 0.0);
        expect(stats.prExercise, 'N/A');
        expect(stats.workoutDates, isEmpty);
      });

      test('fromJson handles int weeklyFrequency', () {
        final stats = CachedDashboardStats.fromJson({
          'weeklyFrequency': 3,
        });
        expect(stats.weeklyFrequency, 3.0);
      });
    });

    group('isValid', () {
      test('cache less than 24h old is valid', () {
        final stats = _make(
          lastCalculated: DateTime.now().subtract(const Duration(hours: 23)),
        );
        expect(stats.isValid, isTrue);
      });

      test('cache just now is valid', () {
        final stats = _make(lastCalculated: DateTime.now());
        expect(stats.isValid, isTrue);
      });

      test('new user (< 100 workouts) valid up to 3 days', () {
        final stats = _make(
          totalWorkouts: 50,
          lastCalculated: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(stats.isValid, isTrue);
      });

      test('medium user (< 500 workouts) valid up to 7 days', () {
        final stats = _make(
          totalWorkouts: 200,
          lastCalculated: DateTime.now().subtract(const Duration(days: 6)),
        );
        expect(stats.isValid, isTrue);
      });

      test('power user valid up to 30 days', () {
        final stats = _make(
          totalWorkouts: 1000,
          lastCalculated: DateTime.now().subtract(const Duration(days: 25)),
        );
        expect(stats.isValid, isTrue);
      });

      test('cache older than 30 days is invalid', () {
        final stats = _make(
          totalWorkouts: 1000,
          lastCalculated: DateTime.now().subtract(const Duration(days: 31)),
        );
        expect(stats.isValid, isFalse);
      });

      test('new user cache at 4 days depends on workout count', () {
        // < 100 workouts, 4 days old: isValid checks age.inDays < 3 first (false),
        // then < 7 with < 500 (true)
        final stats = _make(
          totalWorkouts: 50,
          lastCalculated: DateTime.now().subtract(const Duration(days: 4)),
        );
        expect(stats.isValid, isTrue);
      });
    });

    group('toDashboardStats', () {
      test('converts all fields correctly', () {
        final cached = _make(
          currentStreak: 5,
          totalWorkouts: 20,
          weeklyFrequency: 4.0,
          totalVolume: 8000,
          maxPR: 150,
          prExercise: 'Deadlift',
        );
        final dashboard = cached.toDashboardStats();
        expect(dashboard.currentStreak, 5);
        expect(dashboard.totalWorkouts, 20);
        expect(dashboard.weeklyFrequency, 4.0);
        expect(dashboard.totalVolume, 8000);
        expect(dashboard.volumeIncrease, 0.0); // always 0 per TODO
        expect(dashboard.maxPR, 150);
        expect(dashboard.prExercise, 'Deadlift');
      });
    });

    group('addWorkout', () {
      test('increments totalWorkouts by 1', () {
        final stats = _make(totalWorkouts: 10, workoutDates: {});
        final updated = stats.addWorkout('2026-02-20');
        expect(updated.totalWorkouts, 11);
      });

      test('adds dateKey to workoutDates', () {
        final stats = _make(workoutDates: {'2026-02-19': true});
        final updated = stats.addWorkout('2026-02-20');
        expect(updated.workoutDates, containsPair('2026-02-19', true));
        expect(updated.workoutDates, containsPair('2026-02-20', true));
      });

      test('does not mutate original', () {
        final stats = _make(totalWorkouts: 5, workoutDates: {});
        stats.addWorkout('2026-02-20');
        expect(stats.totalWorkouts, 5);
        expect(stats.workoutDates, isEmpty);
      });

      test('preserves maxPR and prExercise', () {
        final stats = _make(maxPR: 200, prExercise: 'Squat');
        final updated = stats.addWorkout('2026-02-20');
        expect(updated.maxPR, 200);
        expect(updated.prExercise, 'Squat');
      });

      test('recalculates streak', () {
        final now = DateTime.now();
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final yesterdayDate = now.subtract(const Duration(days: 1));
        final yesterdayKey =
            '${yesterdayDate.year}-${yesterdayDate.month.toString().padLeft(2, '0')}-${yesterdayDate.day.toString().padLeft(2, '0')}';

        final stats = _make(
          workoutDates: {yesterdayKey: true},
        );
        final updated = stats.addWorkout(todayKey);
        expect(updated.currentStreak, greaterThanOrEqualTo(2));
      });

      test('updates lastCalculated to now', () {
        final oldTime = DateTime(2026, 1, 1);
        final stats = _make(lastCalculated: oldTime);
        final updated = stats.addWorkout('2026-02-20');
        expect(
          updated.lastCalculated.isAfter(oldTime),
          isTrue,
        );
      });
    });

    group('_calculateStreak (via addWorkout)', () {
      test('no dates gives 0 streak', () {
        final stats = CachedDashboardStats.empty();
        // addWorkout adds one date, should give streak of 0 or 1
        // depending on if it's today
        final now = DateTime.now();
        final farDate = '2025-01-01'; // old date
        final updated = stats.addWorkout(farDate);
        // Far date won't match recent days
        expect(updated.currentStreak, 0);
      });

      test('consecutive days build streak', () {
        final now = DateTime.now();
        String dateKey(DateTime d) =>
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

        final dates = <String, bool>{};
        // Add 5 consecutive days ending today
        for (int i = 0; i < 5; i++) {
          final d = now.subtract(Duration(days: i));
          dates[dateKey(d)] = true;
        }

        final stats = _make(workoutDates: dates);
        final todayKey = dateKey(now);
        // Adding today again should still show streak
        final updated = stats.addWorkout(todayKey);
        expect(updated.currentStreak, greaterThanOrEqualTo(5));
      });
    });

    group('_calculateWeeklyFrequency (via addWorkout)', () {
      test('recent workouts give positive frequency', () {
        final now = DateTime.now();
        String dateKey(DateTime d) =>
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

        final dates = <String, bool>{};
        // 4 workouts in last 30 days
        for (int i = 0; i < 4; i++) {
          dates[dateKey(now.subtract(Duration(days: i * 7)))] = true;
        }

        final stats = _make(workoutDates: dates);
        final newDateKey = dateKey(now.subtract(const Duration(days: 1)));
        final updated = stats.addWorkout(newDateKey);
        // 5 dates in 30 days -> 5 * 7 / 30 ≈ 1.17
        expect(updated.weeklyFrequency, greaterThan(0));
      });

      test('old dates give 0 frequency', () {
        final stats = _make(
          workoutDates: {'2024-01-01': true, '2024-01-02': true},
        );
        final updated = stats.addWorkout('2024-01-03');
        expect(updated.weeklyFrequency, 0.0);
      });
    });
  });
}
