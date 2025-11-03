import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/pattern_detection_result.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/pattern_viability_checker.dart';

void main() {
  late PatternViabilityChecker checker;

  setUp(() {
    checker = PatternViabilityChecker();
  });

  group('PatternViabilityChecker - All Rules Pass', () {
    test('returns viable when all 5 rules pass', () {
      // Arrange: Perfect pattern that passes all rules
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull', 'legs'],
        repetitions: 4, // ≥3 ✅
        confidence: 0.85, // ≥0.70 ✅
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(
        count: 12, // 4 cycles * 3 workouts = ≥6 ✅
        daysSpan: 25, // ≥18 days ✅
      );

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isTrue);
      expect(result.passedRules, hasLength(5));
      expect(result.reason, contains('All viability checks passed'));
    });

    test('coverage is exactly 50% (edge case)', () {
      // Arrange: 6 workouts, pattern of length 3 repeated 1 time = 3/6 = 50%
      final pattern = PatternDetectionResult(
        pattern: ['a', 'b', 'c'],
        repetitions: 3,
        confidence: 0.75,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 18, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isTrue); // Exactly 50% should pass
    });
  });

  group('PatternViabilityChecker - Rule 1: Confidence', () {
    test('rejects pattern with confidence < 0.70', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.65, // ❌ Below threshold
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Confidence'));
      expect(result.reason, contains('Low confidence'));
      expect(result.reason, contains('65%'));
    });

    test('accepts pattern with confidence = 0.70 (edge case)', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.70, // Exactly at threshold
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isTrue);
    });
  });

  group('PatternViabilityChecker - Rule 2: Cycles', () {
    test('rejects pattern with < 3 cycles', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull', 'legs'],
        repetitions: 2, // ❌ Only 2 cycles
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Cycles'));
      expect(result.reason, contains('Insufficient cycles'));
      expect(result.reason, contains('2'));
    });

    test('accepts pattern with exactly 3 cycles (edge case)', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3, // Exactly 3 cycles
        confidence: 0.75,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isTrue);
    });
  });

  group('PatternViabilityChecker - Rule 3: Days of Data', () {
    test('rejects pattern with < 18 days of data', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(
        count: 10,
        daysSpan: 15, // ❌ Only 15 days
      );

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Days'));
      expect(result.reason, contains('Insufficient data'));
      expect(result.reason, contains('15 days'));
    });

    test('accepts pattern with exactly 18 days (edge case)', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.75,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 18);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isTrue);
    });
  });

  group('PatternViabilityChecker - Rule 4: Total Workouts', () {
    test('rejects pattern with < 6 total workouts', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(
        count: 5, // ❌ Only 5 workouts
        daysSpan: 20,
      );

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Workouts'));
      expect(result.reason, contains('Insufficient workouts'));
      expect(result.reason, contains('5'));
    });

    test('accepts pattern with exactly 6 workouts (edge case)', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['a', 'b'],
        repetitions: 3,
        confidence: 0.75,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 6, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isTrue);
    });
  });

  group('PatternViabilityChecker - Rule 5: Coverage', () {
    test('rejects pattern with coverage < 50%', () {
      // Arrange: 6 workouts, pattern length 2, 2 repetitions = 4/6 = 66%... wait that's >50%
      // Let me recalculate: Need < 50% coverage
      // 10 total workouts, pattern [A,B,C] with 1 repetition = 3/10 = 30% ❌
      final pattern = PatternDetectionResult(
        pattern: ['a', 'b', 'c'],
        repetitions: 1, // Only 1 cycle
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      // Will actually fail on Rule 2 (cycles < 3) first, so let's fix the test
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Cycles')); // Fails cycles first
    });

    test('rejects when coverage is low (independent of cycles)', () {
      // Arrange: To test coverage independently, need ≥3 cycles but low coverage
      // 20 total workouts, pattern [A,B] with 3 repetitions = 6/20 = 30% ❌
      final pattern = PatternDetectionResult(
        pattern: ['a', 'b'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 20, daysSpan: 25);

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Coverage'));
      expect(result.reason, contains('Low coverage'));
      expect(result.reason, contains('30%'));
    });
  });

  group('PatternViabilityChecker - Convenience Methods', () {
    test('isViableQuick returns boolean only', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final result = checker.isViableQuick(
        pattern: pattern,
        workoutHistory: workouts,
      );

      // Assert
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    test('getViabilityBreakdown returns all rule checks', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = _createWorkoutHistory(count: 10, daysSpan: 20);

      // Act
      final breakdown = checker.getViabilityBreakdown(
        pattern: pattern,
        workoutHistory: workouts,
      );

      // Assert
      expect(breakdown, hasLength(5));
      expect(breakdown.keys, containsAll([
        'Confidence ≥0.70',
        'Cycles ≥3',
        'Days ≥18',
        'Workouts ≥6',
        'Coverage ≥50%',
      ]));
      expect(breakdown.values.every((v) => v == true), isTrue);
    });
  });

  group('PatternViabilityChecker - Edge Cases', () {
    test('handles empty workout history', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = <Workout>[];

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Workouts'));
    });

    test('handles workouts without startTime', () {
      // Arrange
      final pattern = PatternDetectionResult(
        pattern: ['push', 'pull'],
        repetitions: 3,
        confidence: 0.80,
        lastPosition: 0,
      );

      final workouts = List.generate(
        10,
        (i) => Workout(
          id: 'workout_$i',
          name: 'Workout $i',
          startTime: null, // No startTime
        ),
      );

      // Act
      final result = checker.isViable(pattern: pattern, workoutHistory: workouts);

      // Assert
      expect(result.isViable, isFalse);
      expect(result.failedRule, equals('Days')); // 0 days covered
    });
  });
}

/// Helper function to create workout history with specific characteristics
///
/// Creates workouts distributed evenly across [daysSpan] days.
/// The FIRST workout will be [daysSpan] days ago, and the LAST workout will be today.
List<Workout> _createWorkoutHistory({
  required int count,
  required int daysSpan,
}) {
  final now = DateTime.now();
  final workouts = <Workout>[];

  for (int i = 0; i < count; i++) {
    // Distribute workouts evenly: first workout at daysSpan ago, last at 0 (today)
    // For count=10, daysSpan=15: i=0 -> 15 days ago, i=9 -> 0 days ago
    final daysAgo = count == 1
        ? 0
        : (daysSpan * (count - 1 - i) / (count - 1)).round();

    workouts.add(
      Workout(
        id: 'workout_$i',
        name: 'Workout $i',
        startTime: now.subtract(Duration(days: daysAgo)),
        status: WorkoutStatus.completed,
      ),
    );
  }

  return workouts;
}
