/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// Tests for AnalyticsSet entity computed properties
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';

void main() {
  group('AnalyticsSet', () {
    group('volume', () {
      test('calculates volume correctly', () {
        final set = AnalyticsSet(
          weight: 100,
          reps: 8,
          date: DateTime(2024, 1, 1),
        );

        // Volume = weight × reps = 100 × 8 = 800
        expect(set.volume, 800);
      });

      test('handles different weight/reps combinations', () {
        final testCases = [
          {'weight': 80.0, 'reps': 10, 'expected': 800.0},
          {'weight': 120.0, 'reps': 5, 'expected': 600.0},
          {'weight': 60.0, 'reps': 12, 'expected': 720.0},
        ];

        for (final testCase in testCases) {
          final set = AnalyticsSet(
            weight: testCase['weight']! as double,
            reps: testCase['reps']! as int,
            date: DateTime(2024, 1, 1),
          );

          expect(set.volume, testCase['expected']);
        }
      });
    });

    group('estimatedOneRM', () {
      test('returns weight for 1 rep (1RM = actual weight)', () {
        final set = AnalyticsSet(
          weight: 100,
          reps: 1,
          date: DateTime(2024, 1, 1),
        );

        expect(set.estimatedOneRM, 100);
      });

      test('calculates 1RM using Epley formula for 5 reps', () {
        final set = AnalyticsSet(
          weight: 100,
          reps: 5,
          date: DateTime(2024, 1, 1),
        );

        // Epley: (100 * 5 / 37.5) + 100 = 13.33 + 100 = 113.33
        expect(set.estimatedOneRM, closeTo(113.33, 0.1));
      });

      test('calculates 1RM using Epley formula for 8 reps', () {
        final set = AnalyticsSet(
          weight: 80,
          reps: 8,
          date: DateTime(2024, 1, 1),
        );

        // Epley: (80 * 8 / 37.5) + 80 = 17.07 + 80 = 97.07
        expect(set.estimatedOneRM, closeTo(97.07, 0.1));
      });

      test('calculates 1RM using Epley formula for 10 reps', () {
        final set = AnalyticsSet(
          weight: 60,
          reps: 10,
          date: DateTime(2024, 1, 1),
        );

        // Epley: (60 * 10 / 37.5) + 60 = 16 + 60 = 76
        expect(set.estimatedOneRM, closeTo(76.0, 0.1));
      });

      test('handles various rep ranges correctly', () {
        final testCases = [
          {'weight': 100.0, 'reps': 1, 'expected': 100.0},     // 1 rep
          {'weight': 100.0, 'reps': 3, 'expected': 108.0},     // 3 reps
          {'weight': 100.0, 'reps': 5, 'expected': 113.33},    // 5 reps
          {'weight': 100.0, 'reps': 8, 'expected': 121.33},    // 8 reps
          {'weight': 100.0, 'reps': 10, 'expected': 126.67},   // 10 reps
        ];

        for (final testCase in testCases) {
          final set = AnalyticsSet(
            weight: testCase['weight']! as double,
            reps: testCase['reps']! as int,
            date: DateTime(2024, 1, 1),
          );

          expect(
            set.estimatedOneRM,
            closeTo(testCase['expected']! as double, 0.1),
            reason: 'Failed for ${testCase['weight']}kg x ${testCase['reps']} reps',
          );
        }
      });
    });

    group('validate', () {
      test('passes validation for valid set', () {
        final set = AnalyticsSet(
          weight: 100,
          reps: 8,
          date: DateTime(2024, 1, 1),
        );

        // Should not throw
        expect(() => set.validate(), returnsNormally);
      });

      test('throws ArgumentError for weight <= 0', () {
        final invalidWeights = [0.0, -10.0, -0.1];

        for (final weight in invalidWeights) {
          final set = AnalyticsSet(
            weight: weight,
            reps: 8,
            date: DateTime(2024, 1, 1),
          );

          expect(
            () => set.validate(),
            throwsA(isA<ArgumentError>()),
            reason: 'Should throw for weight: $weight',
          );
        }
      });

      test('throws ArgumentError for reps <= 0', () {
        final invalidReps = [0, -1, -10];

        for (final reps in invalidReps) {
          final set = AnalyticsSet(
            weight: 100,
            reps: reps,
            date: DateTime(2024, 1, 1),
          );

          expect(
            () => set.validate(),
            throwsA(isA<ArgumentError>()),
            reason: 'Should throw for reps: $reps',
          );
        }
      });

      test('throws ArgumentError with correct message for invalid weight', () {
        final set = AnalyticsSet(
          weight: 0,
          reps: 8,
          date: DateTime(2024, 1, 1),
        );

        expect(
          () => set.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Weight must be greater than 0'),
            ),
          ),
        );
      });

      test('throws ArgumentError with correct message for invalid reps', () {
        final set = AnalyticsSet(
          weight: 100,
          reps: 0,
          date: DateTime(2024, 1, 1),
        );

        expect(
          () => set.validate(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Reps must be greater than 0'),
            ),
          ),
        );
      });
    });
  });
}
