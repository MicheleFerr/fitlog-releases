import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/progress/domain/entities/progress_data.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExerciseActivitySet _makeSet({
  int setNum = 1,
  dynamic weight = '100',
  dynamic reps = '10',
  bool done = true,
}) {
  return ExerciseActivitySet(
    set: setNum,
    weight: weight.toString(),
    reps: reps.toString(),
    done: done,
    effort: 3,
  );
}

ExerciseActivity _makeActivity({
  String name = 'Bench Press',
  required DateTime createdAt,
  List<ExerciseActivitySet>? sets,
}) {
  return ExerciseActivity(
    id: 'act-${createdAt.millisecondsSinceEpoch}',
    email: 'test@test.com',
    exerciseId: 'ex-1',
    exerciseName: name,
    schedaName: 'Push',
    sets: sets ?? [_makeSet()],
    createdAt: createdAt,
    lastModified: createdAt,
    category: ExerciseCategory.chest,
  );
}

void main() {
  // =========================================================================
  // QuickStats
  // =========================================================================
  group('QuickStats', () {
    group('empty factory', () {
      test('returns all zeroes and N/A', () {
        final qs = QuickStats.empty();
        expect(qs.totalVolume, 0);
        expect(qs.volumeIncrease, 0);
        expect(qs.maxPR, 0);
        expect(qs.prExercise, 'N/A');
        expect(qs.totalWorkouts, 0);
      });
    });

    group('formattedVolume', () {
      test('below 1000 shows integer kg', () {
        const qs = QuickStats(
          totalVolume: 500,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolume, '500 kg');
      });

      test('exactly 1000 shows 1.0k kg', () {
        const qs = QuickStats(
          totalVolume: 1000,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolume, '1.0k kg');
      });

      test('above 1000 shows decimal k kg', () {
        const qs = QuickStats(
          totalVolume: 2500,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolume, '2.5k kg');
      });

      test('zero volume shows 0 kg', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolume, '0 kg');
      });

      test('999.9 shows integer kg', () {
        const qs = QuickStats(
          totalVolume: 999.9,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolume, '1000 kg');
      });
    });

    group('formattedVolumeIncrease', () {
      test('positive shows plus sign with percent', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: 15.7,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolumeIncrease, '+16%');
      });

      test('negative shows minus sign with percent', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: -10.3,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolumeIncrease, '-10%');
      });

      test('zero shows 0%', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolumeIncrease, '0%');
      });

      test('large positive rounds correctly', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: 150.6,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedVolumeIncrease, '+151%');
      });
    });

    group('formattedMaxPR', () {
      test('formats as integer kg', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: 0,
          maxPR: 120.5,
          prExercise: 'Squat',
          totalWorkouts: 0,
        );
        expect(qs.formattedMaxPR, '121 kg');
      });

      test('zero PR', () {
        const qs = QuickStats(
          totalVolume: 0,
          volumeIncrease: 0,
          maxPR: 0,
          prExercise: 'N/A',
          totalWorkouts: 0,
        );
        expect(qs.formattedMaxPR, '0 kg');
      });
    });
  });

  // =========================================================================
  // ProgressData
  // =========================================================================
  group('ProgressData', () {
    group('constructor', () {
      test('stores all fields', () {
        final pd = ProgressData(
          totalVolume: 1000,
          volumeIncrease: 5,
          personalRecords: {'Bench': 100.0},
          totalWorkouts: 10,
          currentStreak: 3,
          weeklyFrequency: 4.0,
          quickStats: QuickStats.empty(),
        );
        expect(pd.totalVolume, 1000);
        expect(pd.volumeIncrease, 5);
        expect(pd.personalRecords, {'Bench': 100.0});
        expect(pd.totalWorkouts, 10);
        expect(pd.currentStreak, 3);
        expect(pd.weeklyFrequency, 4.0);
      });
    });

    group('fromActivities - empty list', () {
      test('returns zeroed ProgressData', () {
        final pd = ProgressData.fromActivities([]);
        expect(pd.totalVolume, 0);
        expect(pd.volumeIncrease, 0);
        expect(pd.personalRecords, isEmpty);
        expect(pd.totalWorkouts, 0);
        expect(pd.currentStreak, 0);
        expect(pd.weeklyFrequency, 0);
        expect(pd.quickStats.totalVolume, 0);
        expect(pd.quickStats.prExercise, 'N/A');
      });
    });

    group('fromActivities - volume calculation', () {
      test('sums weight * reps for done sets only', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now,
            sets: [
              _makeSet(weight: '100', reps: '10', done: true), // 1000
              _makeSet(weight: '50', reps: '5', done: true), // 250
              _makeSet(weight: '200', reps: '8', done: false), // skipped
            ],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.totalVolume, 1250);
      });

      test('handles numeric weight/reps types (int, double)', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now,
            sets: [
              // ExerciseActivitySet uses String for weight/reps
              // but _parseWeight/_parseReps handle various types
              _makeSet(weight: 80, reps: 12, done: true), // 960
            ],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.totalVolume, 960);
      });

      test('handles zero weight and reps', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now,
            sets: [_makeSet(weight: '0', reps: '0', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.totalVolume, 0);
      });
    });

    group('fromActivities - volume increase', () {
      test('calculates percentage increase between recent and previous month',
          () {
        final now = DateTime.now();
        // Recent month: 2000 volume
        // Previous month: 1000 volume
        // Increase = ((2000-1000)/1000)*100 = 100%
        final activities = [
          _makeActivity(
            createdAt: now.subtract(const Duration(days: 5)),
            sets: [_makeSet(weight: '100', reps: '20', done: true)], // 2000
          ),
          _makeActivity(
            createdAt: now.subtract(const Duration(days: 45)),
            sets: [_makeSet(weight: '100', reps: '10', done: true)], // 1000
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.volumeIncrease, 100.0);
      });

      test('returns 0 when no previous month data', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now.subtract(const Duration(days: 5)),
            sets: [_makeSet(weight: '100', reps: '10', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.volumeIncrease, 0);
      });

      test('negative increase when volume drops', () {
        final now = DateTime.now();
        // Recent: 500, Previous: 1000 -> -50%
        final activities = [
          _makeActivity(
            createdAt: now.subtract(const Duration(days: 5)),
            sets: [_makeSet(weight: '50', reps: '10', done: true)], // 500
          ),
          _makeActivity(
            createdAt: now.subtract(const Duration(days: 45)),
            sets: [_makeSet(weight: '100', reps: '10', done: true)], // 1000
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.volumeIncrease, -50.0);
      });
    });

    group('fromActivities - personal records', () {
      test('finds max weight per exercise in last 30 days', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            name: 'Bench Press',
            createdAt: now.subtract(const Duration(days: 5)),
            sets: [
              _makeSet(weight: '100', reps: '5', done: true),
              _makeSet(weight: '120', reps: '3', done: true),
            ],
          ),
          _makeActivity(
            name: 'Squat',
            createdAt: now.subtract(const Duration(days: 3)),
            sets: [_makeSet(weight: '150', reps: '5', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.personalRecords['Bench Press'], 120);
        expect(pd.personalRecords['Squat'], 150);
      });

      test('ignores activities older than 30 days for PR', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            name: 'Bench Press',
            createdAt: now.subtract(const Duration(days: 35)),
            sets: [_makeSet(weight: '200', reps: '1', done: true)],
          ),
          _makeActivity(
            name: 'Bench Press',
            createdAt: now.subtract(const Duration(days: 5)),
            sets: [_makeSet(weight: '100', reps: '5', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.personalRecords['Bench Press'], 100);
      });

      test('ignores undone sets for PR', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            name: 'Bench Press',
            createdAt: now.subtract(const Duration(days: 2)),
            sets: [
              _makeSet(weight: '200', reps: '1', done: false),
              _makeSet(weight: '80', reps: '10', done: true),
            ],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.personalRecords['Bench Press'], 80);
      });

      test('quickStats.maxPR is the highest PR across all exercises', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            name: 'Bench',
            createdAt: now.subtract(const Duration(days: 2)),
            sets: [_makeSet(weight: '100', done: true)],
          ),
          _makeActivity(
            name: 'Squat',
            createdAt: now.subtract(const Duration(days: 1)),
            sets: [_makeSet(weight: '180', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.quickStats.maxPR, 180);
        expect(pd.quickStats.prExercise, 'Squat');
      });

      test('empty PRs when all sets undone', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now,
            sets: [_makeSet(weight: '100', done: false)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.personalRecords, isEmpty);
        expect(pd.quickStats.maxPR, 0);
        expect(pd.quickStats.prExercise, 'N/A');
      });

      test('zero-weight done sets are excluded from PR', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            name: 'Pushups',
            createdAt: now,
            sets: [_makeSet(weight: '0', reps: '20', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.personalRecords, isEmpty);
      });
    });

    group('fromActivities - workout counting', () {
      test('counts unique days', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: DateTime(now.year, now.month, now.day, 10, 0),
          ),
          _makeActivity(
            createdAt: DateTime(now.year, now.month, now.day, 15, 0),
          ),
          _makeActivity(
            createdAt: DateTime(now.year, now.month, now.day - 1, 10, 0),
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        // 2 unique days: today and yesterday
        expect(pd.totalWorkouts, 2);
        expect(pd.quickStats.totalWorkouts, 2);
      });

      test('single activity gives 1 workout', () {
        final pd = ProgressData.fromActivities([
          _makeActivity(createdAt: DateTime.now()),
        ]);
        expect(pd.totalWorkouts, 1);
      });
    });

    group('fromActivities - streak and frequency', () {
      test('currentStreak is always 0 (calculated separately)', () {
        final pd = ProgressData.fromActivities([
          _makeActivity(createdAt: DateTime.now()),
        ]);
        expect(pd.currentStreak, 0);
      });

      test('weeklyFrequency is always 0 (calculated separately)', () {
        final pd = ProgressData.fromActivities([
          _makeActivity(createdAt: DateTime.now()),
        ]);
        expect(pd.weeklyFrequency, 0);
      });
    });

    group('fromActivities - sorting', () {
      test('processes activities sorted by date descending', () {
        final now = DateTime.now();
        final old = now.subtract(const Duration(days: 10));
        // Pass in non-sorted order
        final activities = [
          _makeActivity(createdAt: old, name: 'Old'),
          _makeActivity(createdAt: now, name: 'New'),
        ];
        // Should not throw, just process correctly
        final pd = ProgressData.fromActivities(activities);
        expect(pd.totalWorkouts, greaterThanOrEqualTo(1));
      });
    });

    group('fromActivities - edge cases with weight/reps parsing', () {
      test('string weight and reps parsed correctly', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now,
            sets: [_makeSet(weight: '75.5', reps: '8', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.totalVolume, 604.0); // 75.5 * 8
      });

      test('invalid string weight/reps default to 0', () {
        final now = DateTime.now();
        final activities = [
          _makeActivity(
            createdAt: now,
            sets: [_makeSet(weight: 'abc', reps: 'xyz', done: true)],
          ),
        ];
        final pd = ProgressData.fromActivities(activities);
        expect(pd.totalVolume, 0);
      });
    });
  });
}
