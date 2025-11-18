/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// Tests for ExerciseSession entity computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';

void main() {
  group('ExerciseSession', () {
    group('totalVolume', () {
      test('returns 0 when no sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [],
        );

        expect(session.totalVolume, 0);
      });

      test('calculates total volume for single set', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 100, reps: 8, date: DateTime(2024, 1, 1)), // 800
          ],
        );

        expect(session.totalVolume, 800);
      });

      test('calculates total volume for multiple sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 100, reps: 8, date: DateTime(2024, 1, 1)), // 800
            AnalyticsSet(weight: 100, reps: 6, date: DateTime(2024, 1, 1)), // 600
            AnalyticsSet(weight: 100, reps: 4, date: DateTime(2024, 1, 1)), // 400
          ],
        );

        // Total: 800 + 600 + 400 = 1800
        expect(session.totalVolume, 1800);
      });
    });

    group('highestEstimated1RM', () {
      test('returns 0 when no sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [],
        );

        expect(session.highestEstimated1RM, 0);
      });

      test('returns highest 1RM from single set', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 1)), // 1RM ≈ 113.33
          ],
        );

        // Epley: (100 * 5 / 37.5) + 100 = 113.33
        expect(session.highestEstimated1RM, closeTo(113.33, 0.1));
      });

      test('returns highest 1RM from multiple sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 80, reps: 8, date: DateTime(2024, 1, 1)),   // 1RM ≈ 97.07
            AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 1)),  // 1RM ≈ 113.33 (highest)
            AnalyticsSet(weight: 90, reps: 6, date: DateTime(2024, 1, 1)),   // 1RM ≈ 104.4
          ],
        );

        // Highest should be 100kg x 5 reps
        expect(session.highestEstimated1RM, closeTo(113.33, 0.1));
      });
    });

    group('maxWeight', () {
      test('returns 0 when no sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [],
        );

        expect(session.maxWeight, 0);
      });

      test('returns max weight from single set', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 1)),
          ],
        );

        expect(session.maxWeight, 100);
      });

      test('returns max weight from multiple sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 80, reps: 8, date: DateTime(2024, 1, 1)),
            AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 1)),  // Max
            AnalyticsSet(weight: 90, reps: 6, date: DateTime(2024, 1, 1)),
          ],
        );

        expect(session.maxWeight, 100);
      });
    });

    group('maxReps', () {
      test('returns 0 when no sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [],
        );

        expect(session.maxReps, 0);
      });

      test('returns max reps from single set', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 1)),
          ],
        );

        expect(session.maxReps, 5);
      });

      test('returns max reps from multiple sets', () {
        final session = ExerciseSession(
          exerciseName: 'Bench Press',
          muscleGroup: 'chest',
          date: DateTime(2024, 1, 1),
          sets: [
            AnalyticsSet(weight: 80, reps: 8, date: DateTime(2024, 1, 1)),  // Max reps
            AnalyticsSet(weight: 100, reps: 5, date: DateTime(2024, 1, 1)),
            AnalyticsSet(weight: 90, reps: 6, date: DateTime(2024, 1, 1)),
          ],
        );

        expect(session.maxReps, 8);
      });
    });

  });
}
