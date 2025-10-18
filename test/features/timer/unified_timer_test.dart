import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/timer/domain/models/unified_timer_state.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/unified_timer_provider.dart';

void main() {
  group('UnifiedTimerState', () {
    test('should create timer with correct initial state', () {
      final timer = UnifiedTimerState(
        totalDurationSeconds: 60,
        type: TimerType.rest,
        exerciseName: 'Test Exercise',
      );

      expect(timer.totalDurationSeconds, 60);
      expect(timer.remainingSeconds, 60);
      expect(timer.status, TimerStatus.idle);
      expect(timer.type, TimerType.rest);
      expect(timer.exerciseName, 'Test Exercise');
      expect(timer.progress, 0.0);
      expect(timer.isActive, false);
      expect(timer.canStart, true);
    });

    test('should transition states correctly', () {
      var timer = UnifiedTimerState(totalDurationSeconds: 60);

      // Start timer
      timer = timer.start();
      expect(timer.status, TimerStatus.running);
      expect(timer.isActive, true);
      expect(timer.canPause, true);
      expect(timer.startTime, isNotNull);

      // Pause timer
      timer = timer.pause();
      expect(timer.status, TimerStatus.paused);
      expect(timer.isPaused, true);
      expect(timer.pausedTime, isNotNull);
      expect(timer.pauseHistory.length, 1);

      // Resume timer
      timer = timer.resume();
      expect(timer.status, TimerStatus.running);
      expect(timer.isActive, true);
      expect(timer.pausedTime, isNull);

      // Complete timer
      timer = timer.complete();
      expect(timer.status, TimerStatus.completed);
      expect(timer.isCompleted, true);
      expect(timer.completionTime, isNotNull);
    });

    test('should handle timer ticks correctly', () {
      var timer = UnifiedTimerState(totalDurationSeconds: 3).start();

      // First tick
      timer = timer.tick();
      expect(timer.remainingSeconds, 2);
      expect(timer.progress, closeTo(0.33, 0.01));
      expect(timer.tickCount, 1);

      // Second tick
      timer = timer.tick();
      expect(timer.remainingSeconds, 1);
      expect(timer.progress, closeTo(0.67, 0.01));

      // Final tick - should complete
      timer = timer.tick();
      expect(timer.remainingSeconds, 0);
      expect(timer.progress, 1.0);
      expect(timer.status, TimerStatus.completed);
    });

    test('should reset timer correctly', () {
      var timer = UnifiedTimerState(totalDurationSeconds: 60)
          .start()
          .tick()
          .tick();

      expect(timer.remainingSeconds, 58);
      expect(timer.tickCount, 2);

      timer = timer.reset();
      expect(timer.remainingSeconds, 60);
      expect(timer.status, TimerStatus.idle);
      expect(timer.tickCount, 0);
      expect(timer.startTime, isNull);
      expect(timer.audioPlayed, false);
    });

    test('should handle audio state correctly', () {
      var timer = UnifiedTimerState(
        totalDurationSeconds: 60,
        audioEnabled: true,
        customSoundName: 'custom_sound',
      );

      expect(timer.audioEnabled, true);
      expect(timer.audioPlayed, false);
      expect(timer.customSoundName, 'custom_sound');

      timer = timer.markAudioPlayed();
      expect(timer.audioPlayed, true);
    });

    test('should serialize and deserialize correctly', () {
      final original = UnifiedTimerState(
        totalDurationSeconds: 120,
        remainingSeconds: 90,
        type: TimerType.workout,
        exerciseName: 'Push ups',
        currentSet: 2,
        totalSets: 3,
        audioEnabled: true,
        customSoundName: 'beep',
      );

      final json = original.toJson();
      final restored = UnifiedTimerState.fromJson(json);

      expect(restored.totalDurationSeconds, original.totalDurationSeconds);
      expect(restored.remainingSeconds, original.remainingSeconds);
      expect(restored.type, original.type);
      expect(restored.exerciseName, original.exerciseName);
      expect(restored.currentSet, original.currentSet);
      expect(restored.totalSets, original.totalSets);
      expect(restored.audioEnabled, original.audioEnabled);
      expect(restored.customSoundName, original.customSoundName);
    });
  });

  group('UnifiedTimerProvider Integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with null state', () {
      final timer = container.read(unifiedTimerProvider);
      expect(timer, isNull);
    });

    test('should provide correct selective values', () {
      final isActive = container.read(timerIsActiveProvider);
      final remaining = container.read(timerRemainingSecondsProvider);
      final progress = container.read(timerProgressProvider);
      final status = container.read(timerStatusProvider);

      expect(isActive, false);
      expect(remaining, 0);
      expect(progress, 0.0);
      expect(status, isNull);
    });

    // Note: Full provider testing would require mocking platform channels
    // and async operations, which is beyond the scope of this basic test
  });

  group('Timer Edge Cases', () {
    test('should handle zero duration timer', () {
      final timer = UnifiedTimerState(totalDurationSeconds: 0);
      expect(timer.remainingSeconds, 0);
      expect(timer.progress, 0.0);
      
      final started = timer.start();
      expect(started.status, TimerStatus.running);
      
      final ticked = started.tick();
      expect(ticked.status, TimerStatus.completed);
      expect(ticked.remainingSeconds, 0);
    });

    test('should not tick when not running', () {
      var timer = UnifiedTimerState(totalDurationSeconds: 60);

      // Idle timer
      var ticked = timer.tick();
      expect(ticked.remainingSeconds, 60);
      expect(ticked.status, TimerStatus.idle);

      // Paused timer
      timer = timer.start().pause();
      ticked = timer.tick();
      expect(ticked.status, TimerStatus.paused);
      expect(ticked.remainingSeconds, timer.remainingSeconds);

      // Completed timer
      timer = timer.complete();
      ticked = timer.tick();
      expect(ticked.status, TimerStatus.completed);
    });

    test('should handle invalid state transitions gracefully', () {
      final timer = UnifiedTimerState(totalDurationSeconds: 60);

      // Can't pause idle timer according to business logic
      expect(timer.canPause, false);
      
      // But pause() method handles it gracefully
      final pausedIdle = timer.pause();
      expect(pausedIdle.status, TimerStatus.paused); // Implementation allows it
      
      // Resume should work from paused state
      final resumedFromPaused = pausedIdle.resume();
      expect(resumedFromPaused.status, TimerStatus.running);
    });
  });
}