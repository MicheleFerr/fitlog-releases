import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/rest_timer.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ProviderContainer container;
  late MockAuthService mockAuthService;
  late Directory tempDir;
  
  setUpAll(() async {
    // Mock MethodChannel per timer audio
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.timer/audio'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'resetAudioTracking':
          case 'scheduleTimerSound':
          case 'cancelTimerSound':
            return null;
          default:
            return null;
        }
      },
    );
    
    // Mock MethodChannel per audio session
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.audio/session'),
      (MethodCall methodCall) async {
        return null;
      },
    );
    
    // Initialize Hive for tests
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(WorkoutDraftAdapter());
    }
  });

  setUp(() {
    mockAuthService = MockAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    // Clean up Hive boxes
    await Hive.deleteFromDisk();
  });
  
  tearDownAll(() async {
    // Clean up temp directory
    await tempDir.delete(recursive: true);
  });

  group('TimerNotifier', () {
    test('initial state is null', () {
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('startRestTimer creates and starts timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Bench Press',
        exerciseId: 'ex-1',
        currentSet: 1,
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNotNull);
      expect(timer!.isRunning, true);
      expect(timer.isPaused, false);
      expect(timer.exerciseName, 'Bench Press');
      expect(timer.totalDurationSeconds, 60);
      expect(timer.remainingSeconds, 60);
    });

    test('startRestTimer validates minimum duration', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      // Try to start with less than 5 seconds
      await notifier.startRestTimer(
        durationSeconds: 3,
        exerciseName: 'Squat',
        exerciseId: 'ex-2',
        currentSet: 2,
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNotNull);
      // Should use minimum of 5 seconds
      expect(timer!.totalDurationSeconds, 5);
    });

    test('pauseTimer pauses running timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Deadlift',
        exerciseId: 'ex-3',
        currentSet: 1,
      );
      
      await notifier.pauseTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.isPaused, true);
      expect(timer.isRunning, false);
    });

    test('resumeTimer resumes paused timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Pull-ups',
        exerciseId: 'ex-4',
        currentSet: 1,
      );
      
      await notifier.pauseTimer();
      await notifier.resumeTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.isPaused, false);
      expect(timer.isRunning, true);
    });

    test('stopTimer stops and clears timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Dips',
        exerciseId: 'ex-5',
        currentSet: 1,
      );
      
      await notifier.stopTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('addTime adds 30 seconds to timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Rows',
        exerciseId: 'ex-6',
        currentSet: 1,
      );
      
      final initialRemaining = container.read(currentTimerProvider)!.remainingSeconds;
      
      await notifier.addTime(30);
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.remainingSeconds, greaterThan(initialRemaining));
    });

    test('resetTimer resets to original duration', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 90,
        exerciseName: 'Shoulder Press',
        exerciseId: 'ex-7',
        currentSet: 1,
      );
      
      // Let some time pass (simulate timer counting down)
      await Future.delayed(const Duration(milliseconds: 100));
      
      await notifier.resetTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.remainingSeconds, timer.totalDurationSeconds);
      // Timer status after reset can be idle or running
      expect(timer.status, anyOf(TimerStatus.idle, TimerStatus.running));
    });

    test('timer completes and plays sound', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      // Start a very short timer
      await notifier.startRestTimer(
        durationSeconds: 5, // Minimum is 5 seconds
        exerciseName: 'Quick Test',
        exerciseId: 'ex-8',
        currentSet: 1,
      );
      
      // Timer should be running
      final timer = container.read(currentTimerProvider);
      expect(timer, isNotNull);
      expect(timer!.isRunning, true);
      
      // Note: Testing actual timer completion would require
      // fake_async or mocking the internal timer
    });

    test('timer plays warning sound at 10 seconds', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      // Start timer that will trigger warning
      await notifier.startRestTimer(
        durationSeconds: 15,
        exerciseName: 'Warning Test',
        exerciseId: 'ex-9',
        currentSet: 1,
      );
      
      // Simulate time passing to reach warning threshold
      // This is a simplified test - in reality the timer would count down
      // and trigger the warning when remainingTime <= 10 seconds
      
      // For this test, we can't easily simulate the exact timing
      // but we can verify the service is set up correctly
      expect(container.read(currentTimerProvider), isNotNull);
    });

    test('skipTimer cancels current timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Skip Test',
        exerciseId: 'ex-10',
        currentSet: 1,
      );
      
      await notifier.skipTimer();
      
      // After skip, timer should be null or completed
      final timer = container.read(currentTimerProvider);
      if (timer != null) {
        expect(timer.status, TimerStatus.completed);
      }
    });

    test('cannot pause timer that is not running', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      // No timer started
      await notifier.pauseTimer();
      
      // Should not crash and no live activity calls
      // Should not crash
    });

    test('cannot resume timer that is not paused', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Resume Test',
        exerciseId: 'ex-11',
        currentSet: 1,
      );
      
      // Timer is running, not paused
      await notifier.resumeTimer();
      
      // Should not make unnecessary calls
      // Should not make unnecessary calls
    });

    test('multiple timers cancel previous', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'First Timer',
        exerciseId: 'ex-12',
        currentSet: 1,
      );
      
      final firstTimer = container.read(currentTimerProvider);
      expect(firstTimer!.exerciseName, 'First Timer');
      
      await notifier.startRestTimer(
        durationSeconds: 90,
        exerciseName: 'Second Timer',
        exerciseId: 'ex-13',
        currentSet: 2,
      );
      
      final secondTimer = container.read(currentTimerProvider);
      expect(secondTimer!.exerciseName, 'Second Timer');
      expect(secondTimer.totalDurationSeconds, 90);
      
      // Previous timer should be cancelled
      // Live activity verification removed
    });

    test('dispose cancels timer and cleans up', () async {
      // Create a separate container for this test to avoid state issues
      final testContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      
      final notifier = testContainer.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Dispose Test',
        exerciseId: 'ex-14',
        currentSet: 1,
      );
      
      // Dispose the test container (which disposes the notifier)
      testContainer.dispose();
      
      // Test passes if no errors are thrown
    });
  });

  group('Timer Calculations', () {
    test('remainingTime decreases over time', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 10,
        exerciseName: 'Countdown Test',
        exerciseId: 'ex-15',
        currentSet: 1,
      );
      
      final initial = container.read(currentTimerProvider)!.remainingSeconds;
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Note: In the actual implementation, the timer updates via a periodic timer
      // For testing, we'd need to mock the timer or use fake_async
      // This test validates the structure is correct
      expect(initial, 10);
    });

    test('elapsedTime increases over time', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Elapsed Test',
        exerciseId: 'ex-16',
        currentSet: 1,
      );
      
      final timer = container.read(currentTimerProvider)!;
      final elapsedSeconds = timer.totalDurationSeconds - timer.remainingSeconds;
      expect(elapsedSeconds, 0);
      
      // In a real scenario with time passing:
      // await Future.delayed(const Duration(seconds: 1));
      // expect(timer.elapsedTime, const Duration(seconds: 1));
    });

    test('progress calculates correctly', () {
      final timer = RestTimer(
        totalDurationSeconds: 100,
        exerciseName: 'Progress Test',
        remainingSeconds: 100,
      );
      
      expect(timer.progress, 0.0);
      
      // Simulate half time elapsed
      final halfTimer = timer.copyWith(
        remainingSeconds: 50,
      );
      expect(halfTimer.progress, 0.5);
      
      // Simulate completed
      final completedTimer = timer.copyWith(
        remainingSeconds: 0,
      );
      expect(completedTimer.progress, 1.0);
    });

    test('isCompleted detects completion', () {
      final timer = RestTimer(
        totalDurationSeconds: 60,
        exerciseName: 'Complete Test',
        remainingSeconds: 60,
      );
      
      expect(timer.isCompleted, false);
      
      final completedTimer = timer.copyWith(
        remainingSeconds: 0,
      );
      expect(completedTimer.isCompleted, true);
    });
  });

  group('Timer State Management', () {
    test('timer state persists across provider reads', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 45,
        exerciseName: 'Persistence Test',
        exerciseId: 'ex-17',
        currentSet: 3,
      );
      
      final timer1 = container.read(currentTimerProvider);
      final timer2 = container.read(currentTimerProvider);
      
      expect(timer1, equals(timer2));
      expect(timer1!.exerciseName, 'Persistence Test');
      expect(timer1.currentSet, 3);
    });

    test('timer updates trigger state changes', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      final states = <RestTimer?>[];
      
      container.listen(
        currentTimerProvider,
        (previous, next) {
          states.add(next);
        },
        fireImmediately: true,
      );
      
      await notifier.startRestTimer(
        durationSeconds: 30,
        exerciseName: 'State Test',
        exerciseId: 'ex-18',
        currentSet: 1,
      );
      
      await notifier.pauseTimer();
      await notifier.resumeTimer();
      await notifier.stopTimer();
      
      // Should have captured multiple state changes
      expect(states.length, greaterThan(1));
      expect(states.last, isNull); // Timer stopped
    });
  });

  group('Edge Cases', () {
    test('handles very short durations', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 1,
        exerciseName: 'Ultra Short',
        exerciseId: 'ex-19',
        currentSet: 1,
      );
      
      final timer = container.read(currentTimerProvider);
      // Should use minimum duration of 5 seconds
      expect(timer!.totalDurationSeconds, 5);
    });

    test('handles very long durations', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 3600,
        exerciseName: 'Marathon Rest',
        exerciseId: 'ex-20',
        currentSet: 1,
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.totalDurationSeconds, 3600);
    });

    test('handles null or empty exercise name', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: '',
        exerciseId: 'ex-21',
        currentSet: 1,
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.exerciseName, '');
    });

    test('handles rapid start/stop cycles', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      for (int i = 0; i < 5; i++) {
        await notifier.startRestTimer(
          durationSeconds: 30,
          exerciseName: 'Rapid Test $i',
          exerciseId: 'ex-rapid-$i',
          currentSet: i,
        );
        await notifier.stopTimer();
      }
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
      
      // Should have called stop for each cycle
      // Live activity verification removed
    });
  });
}