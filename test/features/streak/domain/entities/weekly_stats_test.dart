import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/streak/domain/entities/weekly_stats.dart';

void main() {
  group('WeeklyStats', () {
    group('empty factory', () {
      test('creates instance with zero workouts', () {
        final stats = WeeklyStats.empty();
        expect(stats.totalWorkouts, 0);
        expect(stats.totalActiveDays, 0);
        expect(stats.avgWorkoutsPerWeek, 0.0);
      });

      test('sets avgRestDaysPerWeek to 7 (all rest by default)', () {
        final stats = WeeklyStats.empty();
        expect(stats.avgRestDaysPerWeek, 7.0);
      });

      test('sets totalRestDays to 7', () {
        final stats = WeeklyStats.empty();
        expect(stats.totalRestDays, 7);
      });

      test('weekStartDate and weekEndDate are null', () {
        final stats = WeeklyStats.empty();
        expect(stats.weekStartDate, isNull);
        expect(stats.weekEndDate, isNull);
      });
    });

    group('constructor with values', () {
      test('stores all provided values correctly', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 7);

        final stats = WeeklyStats(
          avgWorkoutsPerWeek: 4.0,
          avgRestDaysPerWeek: 3.0,
          totalWorkouts: 4,
          totalRestDays: 3,
          totalActiveDays: 4,
          weekStartDate: start,
          weekEndDate: end,
        );

        expect(stats.avgWorkoutsPerWeek, 4.0);
        expect(stats.avgRestDaysPerWeek, 3.0);
        expect(stats.totalWorkouts, 4);
        expect(stats.totalRestDays, 3);
        expect(stats.totalActiveDays, 4);
        expect(stats.weekStartDate, start);
        expect(stats.weekEndDate, end);
      });

      test('default values apply when not specified', () {
        final stats = WeeklyStats();
        expect(stats.avgWorkoutsPerWeek, 0.0);
        expect(stats.avgRestDaysPerWeek, 0.0);
        expect(stats.totalWorkouts, 0);
        expect(stats.totalRestDays, 0);
        expect(stats.totalActiveDays, 0);
        expect(stats.weekStartDate, isNull);
        expect(stats.weekEndDate, isNull);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated values', () {
        final original = WeeklyStats.empty();
        final updated = original.copyWith(totalWorkouts: 5, avgWorkoutsPerWeek: 3.5);

        expect(updated.totalWorkouts, 5);
        expect(updated.avgWorkoutsPerWeek, 3.5);
        // Other fields unchanged
        expect(updated.totalActiveDays, original.totalActiveDays);
        expect(updated.avgRestDaysPerWeek, original.avgRestDaysPerWeek);
      });
    });

    group('equality', () {
      test('two empty instances are equal', () {
        final a = WeeklyStats.empty();
        final b = WeeklyStats.empty();
        expect(a, equals(b));
      });

      test('instances with different values are not equal', () {
        final a = WeeklyStats(totalWorkouts: 3);
        final b = WeeklyStats(totalWorkouts: 5);
        expect(a, isNot(equals(b)));
      });
    });

    group('fromJson / toJson', () {
      test('fromJson parses all numeric fields correctly', () {
        final json = {
          'avgWorkoutsPerWeek': 4.2,
          'avgRestDaysPerWeek': 2.8,
          'totalWorkouts': 12,
          'totalRestDays': 18,
          'totalActiveDays': 12,
          'weekStartDate': null,
          'weekEndDate': null,
        };

        final stats = WeeklyStats.fromJson(json);

        expect(stats.avgWorkoutsPerWeek, 4.2);
        expect(stats.avgRestDaysPerWeek, 2.8);
        expect(stats.totalWorkouts, 12);
        expect(stats.totalRestDays, 18);
        expect(stats.totalActiveDays, 12);
        expect(stats.weekStartDate, isNull);
        expect(stats.weekEndDate, isNull);
      });

      test('fromJson with date strings parses DateTime correctly', () {
        final json = {
          'avgWorkoutsPerWeek': 3.0,
          'avgRestDaysPerWeek': 4.0,
          'totalWorkouts': 3,
          'totalRestDays': 4,
          'totalActiveDays': 3,
          'weekStartDate': '2025-01-01T00:00:00.000',
          'weekEndDate': '2025-01-07T00:00:00.000',
        };

        final stats = WeeklyStats.fromJson(json);

        expect(stats.weekStartDate, DateTime(2025, 1, 1));
        expect(stats.weekEndDate, DateTime(2025, 1, 7));
      });

      test('fromJson applies defaults for missing fields', () {
        final json = <String, dynamic>{
          // Only required field structure (all optional with defaults)
        };

        final stats = WeeklyStats.fromJson(json);

        expect(stats.avgWorkoutsPerWeek, 0.0);
        expect(stats.avgRestDaysPerWeek, 0.0);
        expect(stats.totalWorkouts, 0);
        expect(stats.totalRestDays, 0);
        expect(stats.totalActiveDays, 0);
      });

      test('toJson serializes all fields', () {
        final start = DateTime(2025, 3, 1);
        final end = DateTime(2025, 3, 7);
        final stats = WeeklyStats(
          avgWorkoutsPerWeek: 4.0,
          avgRestDaysPerWeek: 3.0,
          totalWorkouts: 4,
          totalRestDays: 3,
          totalActiveDays: 4,
          weekStartDate: start,
          weekEndDate: end,
        );

        final json = stats.toJson();

        expect(json['avgWorkoutsPerWeek'], 4.0);
        expect(json['avgRestDaysPerWeek'], 3.0);
        expect(json['totalWorkouts'], 4);
        expect(json['totalRestDays'], 3);
        expect(json['totalActiveDays'], 4);
        expect(json['weekStartDate'], isNotNull);
        expect(json['weekEndDate'], isNotNull);
      });

      test('round-trip fromJson(toJson()) preserves values', () {
        final original = WeeklyStats(
          avgWorkoutsPerWeek: 3.5,
          avgRestDaysPerWeek: 2.5,
          totalWorkouts: 7,
          totalRestDays: 5,
          totalActiveDays: 7,
        );

        final json = original.toJson();
        final restored = WeeklyStats.fromJson(json);

        expect(restored.avgWorkoutsPerWeek, original.avgWorkoutsPerWeek);
        expect(restored.avgRestDaysPerWeek, original.avgRestDaysPerWeek);
        expect(restored.totalWorkouts, original.totalWorkouts);
        expect(restored.totalRestDays, original.totalRestDays);
        expect(restored.totalActiveDays, original.totalActiveDays);
      });
    });
  });
}
