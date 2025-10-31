import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';

void main() {
  group('SetDurationTracker', () {
    late SetDurationTracker tracker;

    setUp(() {
      tracker = SetDurationTracker();
    });

    test('startSet should record start time and return it', () {
      final startTime = tracker.startSet('exercise-1', 1);

      expect(startTime, isNotNull);
      expect(startTime.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
    });

    test('onSetCompleted should return duration when set was started', () async {
      tracker.startSet('exercise-1', 1);

      // Wait a bit to accumulate duration
      await Future.delayed(const Duration(milliseconds: 100));

      final duration = tracker.onSetCompleted('exercise-1', 1);

      expect(duration, isNotNull);
      expect(duration, greaterThan(0));
      expect(duration, greaterThanOrEqualTo(100)); // At least 100ms
    });

    test('onSetCompleted should return null when set was not started', () {
      final duration = tracker.onSetCompleted('exercise-1', 1);

      expect(duration, isNull);
    });

    test('onSetCompleted should clear start time after completion', () async {
      tracker.startSet('exercise-1', 1);
      tracker.onSetCompleted('exercise-1', 1);

      // Try to complete again - should return null (no start time)
      final secondDuration = tracker.onSetCompleted('exercise-1', 1);

      expect(secondDuration, isNull);
    });

    test('getSetStartTime should return start time for tracked set', () {
      final startTime = tracker.startSet('exercise-1', 1);

      final retrievedTime = tracker.getSetStartTime('exercise-1', 1);

      expect(retrievedTime, equals(startTime));
    });

    test('getSetStartTime should return null for untracked set', () {
      final retrievedTime = tracker.getSetStartTime('exercise-1', 999);

      expect(retrievedTime, isNull);
    });

    test('markExerciseStarted should start tracking set 1', () {
      tracker.markExerciseStarted('exercise-1');

      final startTime = tracker.getSetStartTime('exercise-1', 1);

      expect(startTime, isNotNull);
    });

    test('clearExercise should remove all set times for exercise', () {
      tracker.startSet('exercise-1', 1);
      tracker.startSet('exercise-1', 2);
      tracker.startSet('exercise-1', 3);

      tracker.clearExercise('exercise-1');

      expect(tracker.getSetStartTime('exercise-1', 1), isNull);
      expect(tracker.getSetStartTime('exercise-1', 2), isNull);
      expect(tracker.getSetStartTime('exercise-1', 3), isNull);
    });

    test('clearExercise should not affect other exercises', () {
      tracker.startSet('exercise-1', 1);
      tracker.startSet('exercise-2', 1);

      tracker.clearExercise('exercise-1');

      expect(tracker.getSetStartTime('exercise-1', 1), isNull);
      expect(tracker.getSetStartTime('exercise-2', 1), isNotNull);
    });

    test('clear should remove all tracking data', () {
      tracker.startSet('exercise-1', 1);
      tracker.startSet('exercise-2', 1);
      tracker.startSet('exercise-3', 2);

      tracker.clear();

      expect(tracker.getSetStartTime('exercise-1', 1), isNull);
      expect(tracker.getSetStartTime('exercise-2', 1), isNull);
      expect(tracker.getSetStartTime('exercise-3', 2), isNull);
    });

    test('should track multiple sets for same exercise independently', () async {
      final start1 = tracker.startSet('exercise-1', 1);
      await Future.delayed(const Duration(milliseconds: 50));

      final start2 = tracker.startSet('exercise-1', 2);
      await Future.delayed(const Duration(milliseconds: 50));

      final duration1 = tracker.onSetCompleted('exercise-1', 1);
      final duration2 = tracker.onSetCompleted('exercise-1', 2);

      expect(duration1, isNotNull);
      expect(duration2, isNotNull);
      expect(duration1, greaterThan(duration2!));  // Set 1 started earlier
    });

    test('should track multiple exercises independently', () async {
      tracker.startSet('exercise-1', 1);
      tracker.startSet('exercise-2', 1);

      await Future.delayed(const Duration(milliseconds: 100));

      final duration1 = tracker.onSetCompleted('exercise-1', 1);
      final duration2 = tracker.onSetCompleted('exercise-2', 1);

      expect(duration1, isNotNull);
      expect(duration2, isNotNull);
      expect(duration1, greaterThanOrEqualTo(100));
      expect(duration2, greaterThanOrEqualTo(100));
    });
  });
}
