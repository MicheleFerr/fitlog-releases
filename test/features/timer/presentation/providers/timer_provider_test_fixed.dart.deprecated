import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/rest_timer.dart';
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
    // Initialize Hive for tests
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(WorkoutDraftAdapter());
    }
    
    // Mock MethodChannel for timer audio
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
    
    // Mock MethodChannel for audio session
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.audio/session'),
      (MethodCall methodCall) async {
        return null;
      },
    );
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
    
    // Clean up method channel mocks
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.timer/audio'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.gymbro.audio/session'),
      null,
    );
  });

  group('TimerNotifier Basic Tests', () {
    test('initial state is null', () {
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('startRestTimer creates timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Bench Press',
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNotNull);
      expect(timer!.isRunning, true);
      expect(timer.isPaused, false);
      expect(timer.exerciseName, 'Bench Press');
      expect(timer.totalDurationSeconds, 60);
      expect(timer.remainingSeconds, 60);
    });

    test('startSmartRestTimer creates smart timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startSmartRestTimer(
        reps: 10,
        exerciseName: 'Squat',
        currentSet: 2,
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNotNull);
      expect(timer!.exerciseName, 'Squat');
      expect(timer.totalDurationSeconds, greaterThan(0));
    });

    test('pauseTimer pauses running timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Deadlift',
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
      );
      
      await notifier.stopTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('skipTimer cancels current timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Skip Test',
      );
      
      await notifier.skipTimer();
      
      // Wait for auto-clear
      await Future.delayed(const Duration(seconds: 3));
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });

    test('addTime adds 30 seconds to timer', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'Rows',
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
      );
      
      // Let some time pass (simulate timer counting down)
      await Future.delayed(const Duration(milliseconds: 100));
      
      await notifier.resetTimer();
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.remainingSeconds, timer.totalDurationSeconds);
      expect(timer.isRunning, true);
    });
  });

  group('RestTimer Entity Tests', () {
    test('RestTimer creates with correct values', () {
      final timer = RestTimer(
        totalDurationSeconds: 120,
        exerciseName: 'Test Exercise',
        remainingSeconds: 120,
      );
      
      expect(timer.totalDurationSeconds, 120);
      expect(timer.exerciseName, 'Test Exercise');
      expect(timer.remainingSeconds, 120);
      // Default status is idle, not running
      expect(timer.status, TimerStatus.idle);
      expect(timer.isPaused, false);
      expect(timer.isCompleted, false);
    });

    test('RestTimer progress calculates correctly', () {
      final timer = RestTimer(
        totalDurationSeconds: 100,
        exerciseName: 'Progress Test',
        remainingSeconds: 100,
      );
      
      expect(timer.progress, 0.0);
      
      final halfTimer = timer.copyWith(remainingSeconds: 50);
      expect(halfTimer.progress, 0.5);
      
      final completedTimer = timer.copyWith(remainingSeconds: 0);
      expect(completedTimer.progress, 1.0);
    });

    test('RestTimer isCompleted detects completion', () {
      final timer = RestTimer(
        totalDurationSeconds: 60,
        exerciseName: 'Complete Test',
        remainingSeconds: 60,
      );
      
      expect(timer.isCompleted, false);
      
      final completedTimer = timer.copyWith(remainingSeconds: 0);
      expect(completedTimer.isCompleted, true);
    });

    test('RestTimer pause and resume', () {
      final timer = RestTimer(
        totalDurationSeconds: 60,
        exerciseName: 'Pause Test',
        remainingSeconds: 60,
      );
      
      expect(timer.isPaused, false);
      
      final pausedTimer = timer.pause();
      expect(pausedTimer.isPaused, true);
      expect(pausedTimer.isRunning, false);
      
      final resumedTimer = pausedTimer.resume();
      expect(resumedTimer.isPaused, false);
      expect(resumedTimer.isRunning, true);
    });

    test('RestTimer complete sets correct state', () {
      final timer = RestTimer(
        totalDurationSeconds: 60,
        exerciseName: 'Complete Test',
        remainingSeconds: 60,
      );
      
      final completed = timer.complete();
      expect(completed.isCompleted, true);
      expect(completed.remainingSeconds, 0);
      expect(completed.isRunning, false);
    });
  });

  group('Timer Edge Cases', () {
    test('handles very short durations', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 1,
        exerciseName: 'Ultra Short',
      );
      
      final timer = container.read(currentTimerProvider);
      // Should use minimum duration of 5 seconds
      expect(timer!.totalDurationSeconds, greaterThanOrEqualTo(5));
    });

    test('handles very long durations', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 3600,
        exerciseName: 'Marathon Rest',
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.totalDurationSeconds, 3600);
    });

    test('handles null or empty exercise name', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: '',
      );
      
      final timer = container.read(currentTimerProvider);
      expect(timer!.exerciseName, '');
    });

    test('multiple timers cancel previous', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      await notifier.startRestTimer(
        durationSeconds: 60,
        exerciseName: 'First Timer',
      );
      
      final firstTimer = container.read(currentTimerProvider);
      expect(firstTimer!.exerciseName, 'First Timer');
      
      await notifier.startRestTimer(
        durationSeconds: 90,
        exerciseName: 'Second Timer',
      );
      
      final secondTimer = container.read(currentTimerProvider);
      expect(secondTimer!.exerciseName, 'Second Timer');
      expect(secondTimer.totalDurationSeconds, 90);
    });

    test('handles rapid start/stop cycles', () async {
      final notifier = container.read(currentTimerProvider.notifier);
      
      for (int i = 0; i < 5; i++) {
        await notifier.startRestTimer(
          durationSeconds: 30,
          exerciseName: 'Rapid Test $i',
        );
        await notifier.stopTimer();
      }
      
      final timer = container.read(currentTimerProvider);
      expect(timer, isNull);
    });
  });
}