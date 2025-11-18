/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// Tests for ExerciseHistory entity computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';

void main() {
  group('ExerciseHistory', () {
    group('personalRecord', () {
      test('returns 0 when no sessions', () {
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [],
        );

        expect(history.personalRecord, 0);
      });

      test('returns highest estimated 1RM across all sessions', () {
        final sessions = [
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 1),
            sets: [
              AnalyticsSet(weight: 80, reps: 8, date: DateTime(2024, 1, 1)), // 1RM ≈ 97.07 kg
            ],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 8),
            sets: [
              AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 8)), // 1RM ≈ 113.33 kg (PR)
            ],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 15),
            sets: [
              AnalyticsSet(weight: 90, reps: 6, date: DateTime(2024, 1, 15)), // 1RM ≈ 104.4 kg
            ],
          ),
        ];

        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: sessions,
        );

        // PR should be from second session (100kg x 5 reps)
        // Epley formula: (100 * 5 / 37.5) + 100 = 113.33 kg
        expect(history.personalRecord, closeTo(113.33, 0.1));
      });

      test('handles single set correctly', () {
        final history = ExerciseHistory(
          exerciseName: 'Squat',
          muscleGroup: 'legs',
          sessions: [
            ExerciseSession(
              exerciseName: 'Squat',
              muscleGroup: 'legs',
              date: DateTime(2024, 1, 1),
              sets: [
                AnalyticsSet(weight: 120, reps: 3, date: DateTime(2024, 1, 1)), // 1RM ≈ 129.6 kg
              ],
            ),
          ],
        );

        // Epley formula: (120 * 3 / 37.5) + 120 = 129.6 kg
        expect(history.personalRecord, closeTo(129.6, 0.1));
      });
    });

    group('weeklyVolumeProgression', () {
      test('returns 0 when no sessions', () {
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [],
        );

        expect(history.weeklyVolumeProgression, 0);
      });

      test('returns 0 when no previous week data', () {
        final now = DateTime.now();
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 2)),
              sets: [
                AnalyticsSet(weight: 80, reps: 8, date: now.subtract(const Duration(days: 2))), // Volume: 640
              ],
            ),
          ],
        );

        // No previous week data, so progression is 0
        expect(history.weeklyVolumeProgression, 0);
      });

      test('calculates positive progression correctly', () {
        final now = DateTime.now();

        // Previous week: 2 sessions with 640kg each = 1280kg total
        // This week: 2 sessions with 800kg each = 1600kg total
        // Progression: ((1600 - 1280) / 1280) * 100 = 25%
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [
            // Previous week (8-14 days ago)
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 10)),
              sets: [
                AnalyticsSet(weight: 80, reps: 8, date: now.subtract(const Duration(days: 10))), // 640
              ],
            ),
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 12)),
              sets: [
                AnalyticsSet(weight: 80, reps: 8, date: now.subtract(const Duration(days: 12))), // 640
              ],
            ),
            // This week (last 7 days)
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 2)),
              sets: [
                AnalyticsSet(weight: 100, reps: 8, date: now.subtract(const Duration(days: 2))), // 800
              ],
            ),
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 4)),
              sets: [
                AnalyticsSet(weight: 100, reps: 8, date: now.subtract(const Duration(days: 4))), // 800
              ],
            ),
          ],
        );

        expect(history.weeklyVolumeProgression, closeTo(25.0, 0.1));
      });

      test('calculates negative progression correctly', () {
        final now = DateTime.now();

        // Previous week: 1600kg
        // This week: 1280kg
        // Progression: ((1280 - 1600) / 1600) * 100 = -20%
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [
            // Previous week
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 10)),
              sets: [
                AnalyticsSet(weight: 100, reps: 8, date: now.subtract(const Duration(days: 10))), // 800
                AnalyticsSet(weight: 100, reps: 8, date: now.subtract(const Duration(days: 10))), // 800
              ],
            ),
            // This week
            ExerciseSession(
              exerciseName: 'Bench Press',
              muscleGroup: 'chest',
              date: now.subtract(const Duration(days: 2)),
              sets: [
                AnalyticsSet(weight: 80, reps: 8, date: now.subtract(const Duration(days: 2))), // 640
                AnalyticsSet(weight: 80, reps: 8, date: now.subtract(const Duration(days: 2))), // 640
              ],
            ),
          ],
        );

        expect(history.weeklyVolumeProgression, closeTo(-20.0, 0.1));
      });
    });

    group('sessionsSortedByDateAscending', () {
      test('returns empty list when no sessions', () {
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [],
        );

        expect(history.sessionsSortedByDateAscending, isEmpty);
      });

      test('sorts sessions by date ascending', () {
        final sessions = [
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 15),
            sets: [AnalyticsSet(weight: 90, reps: 6, date: DateTime(2024, 1, 15))],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 1),
            sets: [AnalyticsSet(weight: 80, reps: 8, date: DateTime(2024, 1, 1))],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 8),
            sets: [AnalyticsSet(weight: 85, reps: 7, date: DateTime(2024, 1, 8))],
          ),
        ];

        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: sessions,
        );

        final sorted = history.sessionsSortedByDateAscending;

        expect(sorted.length, 3);
        expect(sorted[0].date, DateTime(2024, 1, 1));
        expect(sorted[1].date, DateTime(2024, 1, 8));
        expect(sorted[2].date, DateTime(2024, 1, 15));
      });

      test('handles single session', () {
        final history = ExerciseHistory(
          exerciseName: 'Squat',
          muscleGroup: 'legs',
          sessions: [
            ExerciseSession(
              exerciseName: 'Squat',
              muscleGroup: 'legs',
              date: DateTime(2024, 1, 1),
              sets: [AnalyticsSet(weight: 120, reps: 5, date: DateTime(2024, 1, 1))],
            ),
          ],
        );

        final sorted = history.sessionsSortedByDateAscending;

        expect(sorted.length, 1);
        expect(sorted[0].date, DateTime(2024, 1, 1));
      });
    });

    group('getSessionsByTimeframe', () {
      test('returns empty list when no sessions', () {
        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: [],
        );

        final filtered = history.getSessionsByTimeframe(
          DateTime.now().subtract(const Duration(days: 30)),
          DateTime.now(),
        );

        expect(filtered, isEmpty);
      });

      test('filters sessions after cutoff date', () {
        final now = DateTime.now();
        final sessions = [
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: now.subtract(const Duration(days: 45)),
            sets: [AnalyticsSet(weight: 80, reps: 8, date: now.subtract(const Duration(days: 45)))],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: now.subtract(const Duration(days: 20)),
            sets: [AnalyticsSet(weight: 85, reps: 7, date: now.subtract(const Duration(days: 20)))],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: now.subtract(const Duration(days: 5)),
            sets: [AnalyticsSet(weight: 90, reps: 6, date: now.subtract(const Duration(days: 5)))],
          ),
        ];

        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: sessions,
        );

        // Last 30 days
        final filtered = history.getSessionsByTimeframe(
          now.subtract(const Duration(days: 30)),
          now,
        );

        expect(filtered.length, 2);
        expect(filtered[0].sets[0].weight, 85);
        expect(filtered[1].sets[0].weight, 90);
      });

      test('returns all sessions in wide date range', () {
        final sessions = [
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 1, 1),
            sets: [AnalyticsSet(weight: 80, reps: 8, date: DateTime(2024, 1, 1))],
          ),
          ExerciseSession(
            exerciseName: 'Bench Press',
            muscleGroup: 'chest',
            date: DateTime(2024, 2, 1),
            sets: [AnalyticsSet(weight: 85, reps: 7, date: DateTime(2024, 2, 1))],
          ),
        ];

        final history = ExerciseHistory(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          sessions: sessions,
        );

        // Wide date range that includes all sessions
        final filtered = history.getSessionsByTimeframe(
          DateTime(2023, 1, 1),
          DateTime(2025, 1, 1),
        );

        expect(filtered.length, 2);
      });
    });
  });
}
