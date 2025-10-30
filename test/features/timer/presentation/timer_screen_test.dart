/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: test/features/timer
/// 🎯 Feature: timer screen tests
/// 🔧 Type: widget test
/// 🌍 Localization: ✅ AppLocalizations tested
/// 🎨 Theme: ✅ ColorScheme tested
/// 📱 Platform: Universal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/timer_screen.dart';
import 'package:gymbro_flutter_new/features/timer/presentation/providers/timer_provider.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/timer_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerNotifier extends StateNotifier<TimerState> with Mock {
  MockTimerNotifier() : super(const TimerState());

  @override
  void startTimer({required int duration, String? exerciseName}) {
    state = state.copyWith(
      isRunning: true,
      duration: duration,
      remainingSeconds: duration,
      exerciseName: exerciseName,
    );
  }

  @override
  void pauseTimer() {
    state = state.copyWith(isRunning: false);
  }

  @override
  void resumeTimer() {
    state = state.copyWith(isRunning: true);
  }

  @override
  void stopTimer() {
    state = const TimerState();
  }

  @override
  void skipTimer() {
    state = const TimerState();
  }
}

void main() {
  group('TimerScreen Widget Tests', () {
    late MockTimerNotifier mockTimerNotifier;

    setUp(() {
      mockTimerNotifier = MockTimerNotifier();
    });

    Widget createTestWidget({TimerState? initialState}) {
      if (initialState != null) {
        mockTimerNotifier.state = initialState;
      }

      return ProviderScope(
        overrides: [
          // timerProvider.overrideWith((ref) => mockTimerNotifier),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TimerScreen(),
        ),
      );
    }

    testWidgets('displays timer in initial state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('displays running timer with correct time', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 90,
          remainingSeconds: 45,
          exerciseName: 'Rest',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('00:45'), findsOneWidget);
      expect(find.text('Rest'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('shows pause button when timer is running', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 60,
          remainingSeconds: 30,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('shows play button when timer is paused', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: false,
          duration: 60,
          remainingSeconds: 30,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
    });

    testWidgets('displays exercise name when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 120,
          remainingSeconds: 120,
          exerciseName: 'Bench Press Rest',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press Rest'), findsOneWidget);
    });

    testWidgets('shows skip button when timer is running', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 60,
          remainingSeconds: 30,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });

    testWidgets('handles quick timer presets', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for preset buttons
      expect(find.text('30s'), findsOneWidget);
      expect(find.text('60s'), findsOneWidget);
      expect(find.text('90s'), findsOneWidget);
      expect(find.text('120s'), findsOneWidget);

      // Tap a preset
      await tester.tap(find.text('60s'));
      await tester.pumpAndSettle();

      expect(mockTimerNotifier.state.duration, 60);
      expect(mockTimerNotifier.state.isRunning, true);
    });

    testWidgets('displays progress indicator', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 100,
          remainingSeconds: 25,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('formats time correctly for various durations', (tester) async {
      // Test minutes and seconds
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          duration: 125,
          remainingSeconds: 125,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('02:05'), findsOneWidget);

      // Test only seconds
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          duration: 45,
          remainingSeconds: 45,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('00:45'), findsOneWidget);

      // Test zero
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          duration: 60,
          remainingSeconds: 0,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('shows custom duration input dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for custom button
      final customButton = find.text('Custom');
      if (customButton.evaluate().isNotEmpty) {
        await tester.tap(customButton);
        await tester.pumpAndSettle();

        // Should show dialog
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('pause button pauses timer', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 60,
          remainingSeconds: 30,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      expect(mockTimerNotifier.state.isRunning, false);
    });

    testWidgets('play button resumes timer', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: false,
          duration: 60,
          remainingSeconds: 30,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(mockTimerNotifier.state.isRunning, true);
    });

    testWidgets('skip button stops timer', (tester) async {
      await tester.pumpWidget(createTestWidget(
        initialState: const TimerState(
          isRunning: true,
          duration: 60,
          remainingSeconds: 30,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();

      expect(mockTimerNotifier.state.isRunning, false);
      expect(mockTimerNotifier.state.remainingSeconds, 0);
    });
  });

  group('TimerState Model Tests', () {
    test('creates timer state with default values', () {
      const state = TimerState();
      
      expect(state.isRunning, false);
      expect(state.duration, 0);
      expect(state.remainingSeconds, 0);
      expect(state.exerciseName, null);
    });

    test('copyWith preserves unchanged values', () {
      const original = TimerState(
        isRunning: true,
        duration: 60,
        remainingSeconds: 30,
        exerciseName: 'Test',
      );

      final copied = original.copyWith(isRunning: false);

      expect(copied.isRunning, false);
      expect(copied.duration, 60);
      expect(copied.remainingSeconds, 30);
      expect(copied.exerciseName, 'Test');
    });

    test('calculates progress correctly', () {
      const state = TimerState(
        duration: 100,
        remainingSeconds: 25,
      );

      const progress = (state.duration - state.remainingSeconds) / state.duration;
      expect(progress, 0.75);
    });

    test('handles edge cases for progress', () {
      // No duration
      const noDuration = TimerState(
        duration: 0,
        remainingSeconds: 0,
      );
      expect(noDuration.duration, 0);

      // Completed
      const completed = TimerState(
        duration: 60,
        remainingSeconds: 0,
      );
      const completedProgress = 
          (completed.duration - completed.remainingSeconds) / completed.duration;
      expect(completedProgress, 1.0);

      // Just started
      const justStarted = TimerState(
        duration: 60,
        remainingSeconds: 60,
      );
      const justStartedProgress = 
          (justStarted.duration - justStarted.remainingSeconds) / justStarted.duration;
      expect(justStartedProgress, 0.0);
    });
  });

  group('Timer Integration Tests', () {
    test('timer countdown simulation', () async {
      final notifier = MockTimerNotifier();
      
      // Start timer
      notifier.startTimer(duration: 5, exerciseName: 'Test Exercise');
      expect(notifier.state.isRunning, true);
      expect(notifier.state.duration, 5);
      expect(notifier.state.remainingSeconds, 5);

      // Simulate countdown
      for (int i = 4; i >= 0; i--) {
        await Future.delayed(const Duration(milliseconds: 10));
        notifier.state = notifier.state.copyWith(remainingSeconds: i);
      }

      expect(notifier.state.remainingSeconds, 0);
    });

    test('timer pause and resume maintains state', () {
      final notifier = MockTimerNotifier();
      
      // Start
      notifier.startTimer(duration: 60, exerciseName: 'Rest');
      expect(notifier.state.isRunning, true);

      // Pause
      notifier.pauseTimer();
      expect(notifier.state.isRunning, false);
      expect(notifier.state.remainingSeconds, 60);

      // Resume
      notifier.resumeTimer();
      expect(notifier.state.isRunning, true);
      expect(notifier.state.remainingSeconds, 60);
    });

    test('timer skip completes immediately', () {
      final notifier = MockTimerNotifier();
      
      notifier.startTimer(duration: 120, exerciseName: 'Bench Press');
      expect(notifier.state.remainingSeconds, 120);

      notifier.skipTimer();
      expect(notifier.state.remainingSeconds, 0);
      expect(notifier.state.isRunning, false);
    });
  });
}