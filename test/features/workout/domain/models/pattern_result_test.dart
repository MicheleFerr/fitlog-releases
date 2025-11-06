import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/models/pattern_result.dart';

void main() {
  group('PatternResult', () {
    late PatternResult patternResult;

    setUp(() {
      patternResult = const PatternResult(
        pattern: ['PUSH', 'PULL', 'LEGS'],
        occurrences: 3,
        confidence: 0.85,
      );
    });

    group('predictNext', () {
      test('should predict next workout correctly for PPL pattern', () {
        expect(patternResult.predictNext([]), 'PUSH');
        expect(patternResult.predictNext(['PUSH']), 'PULL');
        expect(patternResult.predictNext(['PUSH', 'PULL']), 'LEGS');
        expect(patternResult.predictNext(['PUSH', 'PULL', 'LEGS']), 'PUSH');
        expect(patternResult.predictNext(['PUSH', 'PULL', 'LEGS', 'PUSH']), 'PULL');
      });

      test('should handle long sequences with modulo', () {
        final longSequence = List.generate(10, (i) => 'WORKOUT_$i');
        final nextWorkout = patternResult.predictNext(longSequence);

        // 10 % 3 = 1, so should predict the second item
        expect(nextWorkout, 'PULL');
      });

      test('should throw error for empty pattern', () {
        const emptyPattern = PatternResult(
          pattern: [],
          occurrences: 0,
          confidence: 0.0,
        );

        expect(
          () => emptyPattern.predictNext(['PUSH']),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('predictNextN', () {
      test('should predict next N workouts correctly', () {
        final predictions = patternResult.predictNextN(['PUSH'], 5);

        expect(predictions, equals(['PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS']));
      });

      test('should handle starting from different positions', () {
        final predictions = patternResult.predictNextN(['PUSH', 'PULL'], 3);

        expect(predictions, equals(['LEGS', 'PUSH', 'PULL']));
      });

      test('should handle empty recent workouts', () {
        final predictions = patternResult.predictNextN([], 4);

        expect(predictions, equals(['PUSH', 'PULL', 'LEGS', 'PUSH']));
      });
    });

    group('daysUntilWorkoutType', () {
      test('should calculate days until specific workout type', () {
        // After ['PUSH'] (position 1), LEGS is 1 day away (at position 2)
        expect(patternResult.daysUntilWorkoutType(['PUSH'], 'LEGS'), 1);
        // After ['PUSH', 'PULL'] (position 2), PUSH is 1 day away (at position 0)
        expect(patternResult.daysUntilWorkoutType(['PUSH', 'PULL'], 'PUSH'), 1);
        // At position 0, PULL is 1 day away (at position 1)
        expect(patternResult.daysUntilWorkoutType([], 'PULL'), 1);
      });

      test('should return -1 for workout type not in pattern', () {
        expect(patternResult.daysUntilWorkoutType(['PUSH'], 'UPPER'), -1);
        expect(patternResult.daysUntilWorkoutType([], 'FULL_BODY'), -1);
      });
    });

    group('properties', () {
      test('includesRest should detect REST days', () {
        const withRest = PatternResult(
          pattern: ['PUSH', 'PULL', 'REST', 'LEGS', 'REST'],
          occurrences: 2,
          confidence: 0.9,
        );

        expect(withRest.includesRest, isTrue);
        expect(patternResult.includesRest, isFalse);
      });

      test('weeklyFrequency should calculate correct frequency', () {
        // PPL pattern: 3 workouts in 3 days = 7 workouts per week
        expect(patternResult.weeklyFrequency, closeTo(7.0, 0.01));

        // Pattern with rest: 3 workouts in 5 days = 4.2 workouts per week
        const withRest = PatternResult(
          pattern: ['PUSH', 'REST', 'PULL', 'REST', 'LEGS'],
          occurrences: 2,
          confidence: 0.9,
        );
        expect(withRest.weeklyFrequency, closeTo(4.2, 0.01));
      });

      test('description should create readable pattern description', () {
        expect(patternResult.description, 'PUSH → PULL → LEGS');

        // Should remove consecutive duplicates
        const withDuplicates = PatternResult(
          pattern: ['PUSH', 'PUSH', 'PULL', 'LEGS', 'LEGS'],
          occurrences: 2,
          confidence: 0.8,
        );
        expect(withDuplicates.description, 'PUSH → PULL → LEGS');
      });
    });

    group('getLocalizedDescription', () {
      test('should translate pattern types', () {
        final translations = {
          'push': 'Spinta',
          'pull': 'Tirata',
          'legs': 'Gambe',
          'no_pattern': 'Nessun pattern',
        };

        final localized = patternResult.getLocalizedDescription(translations);
        expect(localized, 'Spinta → Tirata → Gambe');
      });

      test('should fallback to original if translation missing', () {
        final translations = {
          'push': 'Spinta',
          // Missing 'pull' and 'legs'
        };

        final localized = patternResult.getLocalizedDescription(translations);
        expect(localized, 'Spinta → PULL → LEGS');
      });

      test('should handle empty pattern', () {
        const emptyPattern = PatternResult(
          pattern: [],
          occurrences: 0,
          confidence: 0.0,
        );

        final translations = {
          'no_pattern': 'Nessun pattern',
        };

        expect(emptyPattern.getLocalizedDescription(translations), 'Nessun pattern');
      });
    });

    group('isConsistentWithPattern', () {
      test('should validate suggested workout against pattern', () {
        expect(
          patternResult.isConsistentWithPattern(['PUSH'], 'PULL'),
          isTrue,
        );

        expect(
          patternResult.isConsistentWithPattern(['PUSH', 'PULL'], 'LEGS'),
          isTrue,
        );

        expect(
          patternResult.isConsistentWithPattern(['PUSH'], 'LEGS'),
          isFalse,
        );
      });
    });

    group('calculateAdherenceScore', () {
      test('should calculate perfect adherence', () {
        final actualWorkouts = ['PUSH', 'PULL', 'LEGS', 'PUSH', 'PULL', 'LEGS'];
        final score = patternResult.calculateAdherenceScore(actualWorkouts);

        expect(score, equals(1.0));
      });

      test('should calculate partial adherence', () {
        final actualWorkouts = ['PUSH', 'PULL', 'LEGS', 'PUSH', 'LEGS', 'LEGS'];
        final score = patternResult.calculateAdherenceScore(actualWorkouts);

        // 5 out of 6 match = 0.833 (positions 0,1,2,3,5 match, position 4 doesn't)
        expect(score, closeTo(0.833, 0.01));
      });

      test('should skip REST days in adherence calculation', () {
        const patternWithRest = PatternResult(
          pattern: ['PUSH', 'REST', 'PULL', 'REST', 'LEGS'],
          occurrences: 2,
          confidence: 0.9,
        );

        final actualWorkouts = ['PUSH', 'REST', 'PULL', 'REST', 'LEGS'];
        final score = patternWithRest.calculateAdherenceScore(actualWorkouts);

        // Only non-REST days count: 3 out of 3 match
        expect(score, equals(1.0));
      });

      test('should handle empty workouts', () {
        expect(patternResult.calculateAdherenceScore([]), equals(0.0));
      });
    });

    group('equality and hashCode', () {
      test('should be equal for same values', () {
        const pattern1 = PatternResult(
          pattern: ['PUSH', 'PULL'],
          occurrences: 2,
          confidence: 0.8,
        );

        const pattern2 = PatternResult(
          pattern: ['PUSH', 'PULL'],
          occurrences: 2,
          confidence: 0.8,
        );

        expect(pattern1, equals(pattern2));
        expect(pattern1.hashCode, equals(pattern2.hashCode));
      });

      test('should not be equal for different values', () {
        const pattern1 = PatternResult(
          pattern: ['PUSH', 'PULL'],
          occurrences: 2,
          confidence: 0.8,
        );

        const pattern2 = PatternResult(
          pattern: ['PUSH', 'PULL', 'LEGS'],
          occurrences: 2,
          confidence: 0.8,
        );

        expect(pattern1, isNot(equals(pattern2)));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = patternResult.toJson();

        expect(json['pattern'], equals(['PUSH', 'PULL', 'LEGS']));
        expect(json['occurrences'], equals(3));
        expect(json['confidence'], equals(0.85));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'pattern': ['UPPER', 'LOWER'],
          'occurrences': 5,
          'confidence': 0.95,
        };

        final result = PatternResult.fromJson(json);

        expect(result.pattern, equals(['UPPER', 'LOWER']));
        expect(result.occurrences, equals(5));
        expect(result.confidence, equals(0.95));
      });

      test('round-trip serialization should maintain data', () {
        final json = patternResult.toJson();
        final deserialized = PatternResult.fromJson(json);

        expect(deserialized, equals(patternResult));
      });
    });

    group('factory constructors', () {
      test('empty() should create empty pattern', () {
        final empty = PatternResult.empty();

        expect(empty.pattern, isEmpty);
        expect(empty.occurrences, equals(0));
        expect(empty.confidence, equals(0.0));
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        final str = patternResult.toString();

        expect(str, contains('PUSH→PULL→LEGS'));
        expect(str, contains('occurrences: 3'));
        expect(str, contains('confidence: 0.85'));
      });
    });
  });
}