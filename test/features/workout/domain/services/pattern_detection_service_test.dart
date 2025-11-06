import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_detection_service.dart';

void main() {
  late PatternDetectionService service;

  setUp(() {
    service = PatternDetectionService();
  });

  group('PatternDetectionService - Basic Pattern Detection', () {
    test('detects simple 3-workout pattern (Push-Pull-Legs)', () async {
      // Arrange: Create 12 workouts = 4 complete cycles of [Push, Pull, Legs]
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs', // Cycle 1
        'Push', 'Pull', 'Legs', // Cycle 2
        'Push', 'Pull', 'Legs', // Cycle 3
        'Push', 'Pull', 'Legs', // Cycle 4
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, equals(['push', 'pull', 'legs']));
      expect(result.repetitions, equals(4));
      expect(result.confidence, greaterThanOrEqualTo(0.70));
      expect(result.patternLength, equals(3));
    });

    test('detects 2-workout alternating pattern (Upper-Lower)', () async {
      // Arrange: 10 workouts = 5 cycles of [Upper, Lower]
      final workouts = _createWorkoutSequence([
        'Upper', 'Lower',
        'Upper', 'Lower',
        'Upper', 'Lower',
        'Upper', 'Lower',
        'Upper', 'Lower',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, equals(['upper', 'lower']));
      expect(result.repetitions, equals(5));
      expect(result.confidence, greaterThanOrEqualTo(0.70));
    });

    test('detects pattern with arbitrary names (franco-ciccio-paolo)', () async {
      // Arrange: 9 workouts = 3 cycles
      final workouts = _createWorkoutSequence([
        'Franco', 'Ciccio', 'Paolo',
        'Franco', 'Ciccio', 'Paolo',
        'Franco', 'Ciccio', 'Paolo',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, equals(['franco', 'ciccio', 'paolo']));
      expect(result.repetitions, equals(3));
    });

    test('detects 5-workout pattern (PPL + Upper + Lower)', () async {
      // Arrange: 10 workouts = 2 cycles of 5-workout pattern
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs', 'Upper', 'Lower',
        'Push', 'Pull', 'Legs', 'Upper', 'Lower',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern.length, equals(5));
      expect(result.repetitions, equals(2));
    });
  });

  group('PatternDetectionService - Edge Cases', () {
    test('returns null when insufficient data (<6 workouts)', () async {
      // Arrange: Only 5 workouts
      final workouts = _createWorkoutSequence(['Push', 'Pull', 'Legs', 'Push', 'Pull']);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNull);
    });

    test('returns null when no repeating pattern found', () async {
      // Arrange: All unique workout names
      final workouts = _createWorkoutSequence([
        'Workout1', 'Workout2', 'Workout3',
        'Workout4', 'Workout5', 'Workout6',
        'Workout7', 'Workout8',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNull);
    });

    test('handles minimum repetitions (2 cycles)', () async {
      // Arrange: Pattern appears exactly 2 times
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', 'Legs',
      ]);

      // Act
      final result = await service.detectPattern(
        recentWorkouts: workouts,
        minRepetitions: 2,
      );

      // Assert: 2 complete cycles = valid
      expect(result, isNotNull);
    });

    test('handles empty workout list', () async {
      // Arrange
      final workouts = <Workout>[];

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNull);
    });
  });

  group('PatternDetectionService - Confidence Calculation', () {
    test('calculates higher confidence for more repetitions', () async {
      // Arrange: 6 cycles vs 3 cycles
      final manyReps = _createWorkoutSequence(
        List.generate(18, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
      );
      final fewReps = _createWorkoutSequence(
        List.generate(9, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
      );

      // Act
      final resultMany = await service.detectPattern(recentWorkouts: manyReps);
      final resultFew = await service.detectPattern(recentWorkouts: fewReps);

      // Assert
      expect(resultMany!.confidence, greaterThan(resultFew!.confidence));
    });

    test('confidence is capped at 0.95 (never 100%)', () async {
      // Arrange: Perfect pattern with 10 cycles
      final workouts = _createWorkoutSequence(
        List.generate(30, (i) => ['Push', 'Pull', 'Legs'][i % 3]),
      );

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result!.confidence, lessThanOrEqualTo(0.95));
    });

    test('confidence formula matches specification', () async {
      // Arrange: 3 cycles of 3-workout pattern (9 workouts)
      final workouts = _createWorkoutSequence(
        List.generate(9, (i) => ['A', 'B', 'C'][i % 3]),
      );

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      // Formula: base (0.5 + repetitions * 0.1) + coverage bonus + length bonus
      // Base: 0.5 + (3 * 0.1) = 0.80
      // Coverage: (9/9) * 0.2 = 0.20
      // Length: (3 - 2) * 0.02 = 0.02
      // Total: 0.80 + 0.20 + 0.02 = 1.02 → capped at 0.95
      expect(result!.confidence, equals(0.95));
      expect(result.repetitions, equals(3));
    });
  });

  group('PatternDetectionService - Normalization', () {
    test('normalizes workout names (case-insensitive matching)', () async {
      // Arrange: Mixed case names
      final workouts = _createWorkoutSequence([
        'PUSH', 'pull', 'LeGs',
        'Push', 'PULL', 'legs',
        'pUsH', 'Pull', 'LEGS',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, equals(['push', 'pull', 'legs']));
      expect(result.repetitions, equals(3));
    });

    test('handles extra whitespace in workout names', () async {
      // Arrange: Names with extra spaces
      final workouts = _createWorkoutSequence([
        '  Push  ', ' Pull', 'Legs ',
        'Push', '  Pull  ', '  Legs',
        ' Push ', 'Pull ', ' Legs ',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result, isNotNull);
      expect(result!.pattern, equals(['push', 'pull', 'legs']));
    });
  });

  group('PatternDetectionService - Last Position Detection', () {
    test('finds last position correctly when complete cycle', () async {
      // Arrange: 3 complete cycles, last workout is "Legs" (position 2)
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', 'Legs',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result!.lastPosition, equals(2)); // Legs is position 2 (0-indexed)
      expect(result.predictNext(), equals('push')); // Next should wrap to Push
    });

    test('finds last position correctly when incomplete cycle', () async {
      // Arrange: 2 complete cycles + partial (Push, Pull)
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', // Incomplete cycle
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      expect(result!.lastPosition, equals(1)); // Pull is position 1
      expect(result.predictNext(), equals('legs')); // Next should be Legs
    });
  });

  group('PatternDetectionService - Pattern Selection', () {
    test('prefers longer patterns over shorter ones with better score', () async {
      // Arrange: Could be [A,B] repeated 5 times OR [A,B,A,B,A] repeated 2 times
      final workouts = _createWorkoutSequence([
        'A', 'B', 'A', 'B', 'A',
        'A', 'B', 'A', 'B', 'A',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert
      // Scoring: [A,B] = 5 reps * 10 + 2 length = 52
      //          [A,B,A,B,A] = 2 reps * 10 + 5 length = 25
      // Should prefer [A,B] with higher score
      expect(result!.pattern.length, equals(2));
      expect(result.repetitions, equals(5));
    });

    test('handles pattern with one violation (soft transition)', () async {
      // Arrange: Mostly PPL but one "Rest Day" inserted
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', 'Legs',
        'Push', 'Rest Day', 'Pull', 'Legs', // Violation here
        'Push', 'Pull', 'Legs',
      ]);

      // Act
      final result = await service.detectPattern(recentWorkouts: workouts);

      // Assert: Should still detect PPL pattern with slightly lower confidence
      expect(result, isNotNull);
      expect(result!.pattern, equals(['push', 'pull', 'legs']));
      expect(result.confidence, lessThan(0.85)); // Penalty for violation
    });
  });

  group('PatternDetectionService - Performance', () {
    test('performance <100ms for 50 workouts', () async {
      // Arrange: 50 workouts with complex pattern
      final workouts = _createWorkoutSequence(
        List.generate(50, (i) => ['Push', 'Pull', 'Legs', 'Upper', 'Lower'][i % 5]),
      );

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await service.detectPattern(recentWorkouts: workouts);
      stopwatch.stop();

      // Assert
      expect(result, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Pattern detection should complete in <100ms');
    });
  });

  group('PatternDetectionService - Custom Parameters', () {
    test('respects minPatternLength parameter', () async {
      // Arrange: Pattern of length 2, but require minimum 3
      final workouts = _createWorkoutSequence([
        'A', 'B', 'A', 'B', 'A', 'B', 'A', 'B',
      ]);

      // Act
      final result = await service.detectPattern(
        recentWorkouts: workouts,
        minPatternLength: 3,
      );

      // Assert
      expect(result, isNull); // Should not find [A,B] pattern
    });

    test('respects maxPatternLength parameter', () async {
      // Arrange: Pattern of length 8
      final workouts = _createWorkoutSequence([
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
      ]);

      // Act
      final result = await service.detectPattern(
        recentWorkouts: workouts,
        maxPatternLength: 5, // Limit to 5
      );

      // Assert
      expect(result, isNull); // Should not find 8-workout pattern
    });

    test('respects minRepetitions parameter', () async {
      // Arrange: Pattern repeats 2 times
      final workouts = _createWorkoutSequence([
        'Push', 'Pull', 'Legs',
        'Push', 'Pull', 'Legs',
      ]);

      // Act
      final result = await service.detectPattern(
        recentWorkouts: workouts,
        minRepetitions: 3, // Require 3 cycles
      );

      // Assert
      expect(result, isNull); // Only 2 cycles, need 3
    });
  });
}

/// Helper function to create workout sequence from name list
List<Workout> _createWorkoutSequence(List<String> names) {
  final workouts = names.asMap().entries.map((entry) {
    final index = entry.key;
    final name = entry.value;
    final startTime = DateTime.now().subtract(Duration(days: names.length - index));
    return Workout(
      id: 'workout_$index',
      name: name,
      startTime: startTime,
      endTime: startTime.add(const Duration(minutes: 60)),
      exercises: [], // Empty for testing
      status: WorkoutStatus.completed,
    );
  }).toList();

  // Reverse to get newest first (most recent workout at index 0)
  return workouts.reversed.toList();
}