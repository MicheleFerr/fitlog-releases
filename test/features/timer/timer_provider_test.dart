import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/rest_timer.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../helpers/test_setup.dart';

// Mocks
class MockBox extends Mock implements Box {}
class MockAppConfig extends Mock implements AppConfig {}
class MockRef extends Mock implements Ref {}

void main() {
  late ProviderContainer container;
  late MockBox mockBox;
  
  setUpAll(() async {
    await initializeTestEnvironment();
  });
  
  setUp(() {
    mockBox = createMockBox();
    
    container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWith((ref) => AppConfigNotifier()..state = AppConfig()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });
  
  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group('TimerNotifier', () {
    test('initial state should be null', () {
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('startRestTimer should create and start a timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Bench Press',
        durationSeconds: 60,
        currentSet: 2,
        totalSets: 3,
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNotNull);
      expect(timer!.exerciseName, 'Bench Press');
      expect(timer.totalDurationSeconds, 60);
      expect(timer.currentSet, 2);
      expect(timer.totalSets, 3);
      expect(timer.isRunning, true);
    });

    test('pauseTimer should pause a running timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Squat',
        durationSeconds: 90,
      );
      
      await notifier.pauseTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.isPaused, true);
      expect(timer.isRunning, false);
    });

    test('resumeTimer should resume a paused timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Deadlift',
        durationSeconds: 120,
      );
      
      await notifier.pauseTimer();
      await notifier.resumeTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.isRunning, true);
      expect(timer.isPaused, false);
    });

    test('stopTimer should clear the timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Pull-ups',
        durationSeconds: 45,
      );
      
      await notifier.stopTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('addTime should increase timer duration', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Dips',
        durationSeconds: 60,
      );
      
      final initialRemaining = container.read(currentTimerProvider)!.remainingSeconds;
      
      await notifier.addTime(30);
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.remainingSeconds, initialRemaining + 30);
      expect(timer.totalDurationSeconds, 90);
    });

    test('skipTimer should complete the timer immediately', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Rows',
        durationSeconds: 75,
      );
      
      await notifier.skipTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.isCompleted, true);
      
      // Timer should auto-clear after skip
      await Future.delayed(const Duration(seconds: 3));
      final clearedTimer = container.read(currentTimerProvider);
      expect(clearedTimer, isNull);
    });

    test('timer should handle minimum duration validation', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      // Try to start timer with duration less than 5 seconds
      await notifier.startRestTimer(
        exerciseName: 'Test',
        durationSeconds: 3,
      );
      
      final timer = container.read(currentTimerProvider);
      // Should be set to minimum 5 seconds
      expect(timer!.totalDurationSeconds, 5);
    });

    test('resetTimer should reset to original duration', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        exerciseName: 'Curls',
        durationSeconds: 60,
      );
      
      // Let timer run for a bit (simulated)
      final timer1 = container.read(currentTimerProvider);
      expect(timer1!.remainingSeconds, 60);
      
      // Simulate timer ticking down
      await Future.delayed(const Duration(milliseconds: 100));
      
      await notifier.resetTimer();
      
      final resetTimer = container.read(currentTimerProvider);
      expect(resetTimer!.remainingSeconds, resetTimer.totalDurationSeconds);
      expect(resetTimer.status, TimerStatus.idle);
    });

    group('Smart Rest Timer', () {
      test('should use 180s for strength training (<=5 reps)', () async {
        final notifier = container.read(currentTimerProvider.notifier);
        
        await notifier.startSmartRestTimer(
          exerciseName: 'Heavy Squats',
          reps: 3,
          currentSet: 1,
          totalSets: 5,
        );
        
        final timer = container.read(currentTimerProvider);
        expect(timer!.totalDurationSeconds, 180);
      });

      test('should use 90s for hypertrophy (6-12 reps)', () async {
        final notifier = container.read(currentTimerProvider.notifier);
        
        await notifier.startSmartRestTimer(
          exerciseName: 'Bench Press',
          reps: 10,
          currentSet: 2,
          totalSets: 4,
        );
        
        final timer = container.read(currentTimerProvider);
        expect(timer!.totalDurationSeconds, 90);
      });

      test('should use 60s for endurance (>12 reps)', () async {
        final notifier = container.read(currentTimerProvider.notifier);
        
        await notifier.startSmartRestTimer(
          exerciseName: 'Push-ups',
          reps: 20,
          currentSet: 3,
          totalSets: 3,
        );
        
        final timer = container.read(currentTimerProvider);
        expect(timer!.totalDurationSeconds, 60);
      });
    });
  });

  group('TimerSettings', () {
    test('getRestTimeForReps should return correct rest times', () {
      const settings = TimerSettings(
        strengthRestTime: 180,
        hypertrophyRestTime: 90,
        enduranceRestTime: 60,
        autoStartTimer: true,
        soundEnabled: true,
        vibrationEnabled: true,
      );

      expect(settings.getRestTimeForReps(3), 180);  // Strength
      expect(settings.getRestTimeForReps(5), 180);  // Strength
      expect(settings.getRestTimeForReps(6), 90);   // Hypertrophy
      expect(settings.getRestTimeForReps(10), 90);  // Hypertrophy
      expect(settings.getRestTimeForReps(12), 90);  // Hypertrophy
      expect(settings.getRestTimeForReps(13), 60);  // Endurance
      expect(settings.getRestTimeForReps(20), 60);  // Endurance
    });
  });

  group('TimerHistoryNotifier', () {
    test('should add completed timers to history', () {
      final container = ProviderContainer();
      final notifier = container.read(timerHistoryProvider.notifier);
      
      final completedTimer = RestTimer(
        type: TimerType.rest,
        totalDurationSeconds: 60,
        exerciseName: 'Test Exercise',
      ).complete();
      
      notifier.addCompletedTimer(completedTimer);
      
      final history = container.read(timerHistoryProvider);
      expect(history.length, 1);
      expect(history.first.exerciseName, 'Test Exercise');
      expect(history.first.isCompleted, true);
    });

    test('should keep only last 100 timers', () {
      final container = ProviderContainer();
      final notifier = container.read(timerHistoryProvider.notifier);
      
      // Add 105 timers
      for (int i = 0; i < 105; i++) {
        final timer = RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 60,
          exerciseName: 'Exercise $i',
        ).complete();
        notifier.addCompletedTimer(timer);
      }
      
      final history = container.read(timerHistoryProvider);
      expect(history.length, 100);
      // Most recent should be at the beginning
      expect(history.first.exerciseName, 'Exercise 104');
    });

    test('should calculate average rest time', () {
      final container = ProviderContainer();
      final notifier = container.read(timerHistoryProvider.notifier);
      
      // Add timers with different durations
      notifier.addCompletedTimer(
        RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 60,
          exerciseName: 'Exercise 1',
        ).complete(),
      );
      
      notifier.addCompletedTimer(
        RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 90,
          exerciseName: 'Exercise 2',
        ).complete(),
      );
      
      notifier.addCompletedTimer(
        RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 120,
          exerciseName: 'Exercise 3',
        ).complete(),
      );
      
      final avgDuration = notifier.getAverageRestTime();
      expect(avgDuration.inSeconds, 90); // (60 + 90 + 120) / 3
    });

    test('should filter timers by workout', () {
      final container = ProviderContainer();
      final notifier = container.read(timerHistoryProvider.notifier);
      
      // Add timers for different workouts
      notifier.addCompletedTimer(
        RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 60,
          exerciseName: 'Squat',
          workoutId: 'workout1',
        ).complete(),
      );
      
      notifier.addCompletedTimer(
        RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 90,
          exerciseName: 'Bench',
          workoutId: 'workout2',
        ).complete(),
      );
      
      notifier.addCompletedTimer(
        RestTimer(
          type: TimerType.rest,
          totalDurationSeconds: 75,
          exerciseName: 'Deadlift',
          workoutId: 'workout1',
        ).complete(),
      );
      
      final workout1Timers = notifier.getTimersForWorkout('workout1');
      expect(workout1Timers.length, 2);
      expect(workout1Timers.every((t) => t.workoutId == 'workout1'), true);
    });

    test('clearHistory should remove all timers', () {
      final container = ProviderContainer();
      final notifier = container.read(timerHistoryProvider.notifier);
      
      // Add some timers
      for (int i = 0; i < 5; i++) {
        notifier.addCompletedTimer(
          RestTimer(
            type: TimerType.rest,
            totalDurationSeconds: 60,
            exerciseName: 'Exercise $i',
          ).complete(),
        );
      }
      
      expect(container.read(timerHistoryProvider).length, 5);
      
      notifier.clearHistory();
      
      expect(container.read(timerHistoryProvider).isEmpty, true);
    });
  });
}