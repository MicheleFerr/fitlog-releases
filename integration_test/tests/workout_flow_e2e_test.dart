import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:gymbro_flutter_new/app/app.dart' as app;
import '../helpers/test_base.dart';
import '../pages/workout_page.dart';
import '../pages/timer_page.dart';

void main() {
  patrolTest(
    'Complete workout flow from creation to completion',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      // Step 1: Login
      await TestBase.loginTestUser($);
      if (kDebugMode) debugPrint('✅ User logged in');
      
      // Step 2: Create a new workout
      await workoutPage.navigateToWorkouts();
      await workoutPage.createWorkout(
        name: 'Full Body E2E Test',
        exercises: ['Squat', 'Bench Press', 'Deadlift', 'Shoulder Press'],
      );
      if (kDebugMode) debugPrint('✅ Workout created with 4 exercises');
      
      // Step 3: Start the workout
      await workoutPage.startWorkout('Full Body E2E Test');
      expect(await workoutPage.isWorkoutActive(), isTrue);
      if (kDebugMode) debugPrint('✅ Workout started');
      
      // Step 4: Complete first exercise (Squat) - 3 sets
      for (int set = 1; set <= 3; set++) {
        await workoutPage.completeSet(
          weight: 100 + (set * 10), // Progressive overload
          reps: 12 - (set * 2), // Decreasing reps
          rpe: 6 + set, // Increasing RPE
        );
        if (kDebugMode) debugPrint('✅ Squat set $set completed');
        
        // Rest timer should start after each set except last
        if (set < 3) {
          expect(await timerPage.isTimerRunning(), isTrue);
          if (kDebugMode) debugPrint('  ⏱️ Rest timer started');

          // Test timer controls
          if (set == 1) {
            // Test pause/resume on first rest
            await timerPage.pauseTimer();
            expect(await timerPage.isTimerPaused(), isTrue);
            await Future.delayed(const Duration(seconds: 2));
            await timerPage.resumeTimer();
            if (kDebugMode) debugPrint('  ⏸️ Timer pause/resume tested');
          } else if (set == 2) {
            // Test add 30 seconds on second rest
            await timerPage.addThirtySeconds();
            if (kDebugMode) debugPrint('  ➕ Added 30 seconds to timer');
          }

          // Skip rest timer to continue
          await timerPage.skipTimer();
          if (kDebugMode) debugPrint('  ⏭️ Rest timer skipped');
        }
      }
      
      // Step 5: Test background behavior during second exercise
      if (kDebugMode) debugPrint('Starting Bench Press...');
      await workoutPage.completeSet(weight: 80, reps: 10, rpe: 7);
      
      // Put app in background during rest
      await $.native.pressHome();
      if (kDebugMode) debugPrint('📱 App moved to background during rest');
      await Future.delayed(const Duration(seconds: 5));
      
      // Return to app
      await $.native.openApp();
      await $.pumpAndSettle();
      if (kDebugMode) debugPrint('📱 App returned to foreground');
      
      // Timer should still be running
      expect(await timerPage.isTimerRunning(), isTrue);
      await timerPage.skipTimer();
      
      // Complete remaining Bench Press sets quickly
      for (int set = 2; set <= 3; set++) {
        await workoutPage.completeSet(weight: 85, reps: 8);
        if (set < 3) {
          await timerPage.skipTimer();
        }
      }
      if (kDebugMode) debugPrint('✅ Bench Press completed');
      
      // Step 6: Test timer minimization during third exercise
      if (kDebugMode) debugPrint('Starting Deadlift...');
      await workoutPage.completeSet(weight: 140, reps: 5, rpe: 8);
      
      // Minimize timer
      await timerPage.minimizeTimer();
      expect(await timerPage.isTimerMinimized(), isTrue);
      if (kDebugMode) debugPrint('  🔽 Timer minimized');

      // Do other actions while timer is minimized
      await $.scrollUntilVisible(
        finder: find.text('Previous Sets'),
      );

      // Expand timer
      await timerPage.expandTimer();
      await timerPage.skipTimer();
      
      // Skip remaining Deadlift sets
      for (int set = 2; set <= 3; set++) {
        await workoutPage.skipSet();
      }
      if (kDebugMode) debugPrint('✅ Deadlift completed (some sets skipped)');
      
      // Step 7: Test pause/resume workout during last exercise
      if (kDebugMode) debugPrint('Starting Shoulder Press...');
      await workoutPage.completeSet(weight: 50, reps: 10);
      await timerPage.skipTimer();
      
      // Pause workout
      await workoutPage.pauseWorkout();
      if (kDebugMode) debugPrint('⏸️ Workout paused');
      
      // Simulate user taking a break
      await Future.delayed(const Duration(seconds: 3));
      
      // Resume workout
      await workoutPage.resumeWorkout();
      if (kDebugMode) debugPrint('▶️ Workout resumed');
      
      // Complete final sets
      await workoutPage.completeSet(weight: 50, reps: 8);
      await timerPage.skipTimer();
      await workoutPage.completeSet(weight: 45, reps: 10);
      if (kDebugMode) debugPrint('✅ Shoulder Press completed');
      
      // Step 8: Finish workout
      await workoutPage.finishWorkout();
      expect(await workoutPage.isWorkoutCompleted(), isTrue);
      if (kDebugMode) debugPrint('🎉 Workout completed successfully!');
      
      // Step 9: Verify workout appears in history
      await workoutPage.navigateToWorkouts();
      expect(
        find.textContaining('Full Body E2E Test'),
        findsWidgets,
        reason: 'Completed workout should appear in history',
      );
      
      // Cleanup
      await TestBase.logoutUser($);
      await TestBase.cleanup();
      if (kDebugMode) debugPrint('✅ Test completed and cleaned up');
    },
  );
  
  patrolTest(
    'Workout with interruptions and recovery',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Create and start workout
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Interruption Test');
      await workoutPage.startWorkout('Interruption Test');
      
      // Complete first set
      await workoutPage.completeSet(weight: 100, reps: 10);

      // Simulate phone call interruption (iOS only)
      if (Platform.isIOS) {
        // Timer should continue during interruption
        await $.native.pressHome();
        await Future.delayed(const Duration(seconds: 10));
        await $.native.openApp();
        await $.pumpAndSettle();

        // Verify timer continued
        expect(await timerPage.isTimerRunning(), isTrue);
      }
      
      await timerPage.skipTimer();
      
      // Simulate low battery / app termination
      // Complete another set
      await workoutPage.completeSet(weight: 100, reps: 9);
      
      // "Kill" app (go to background as simulation)
      await $.native.pressHome();
      if (kDebugMode) debugPrint('App "killed" during workout');
      await Future.delayed(const Duration(seconds: 5));
      
      // "Restart" app
      await $.native.openApp();
      await $.pumpAndSettle();
      
      // Workout should be recovered
      expect(await workoutPage.isWorkoutActive(), isTrue,
          reason: 'Workout should be recovered after app restart');
      
      // Timer should be recovered
      final timerVisible = timerPage.timerDisplay.evaluate().isNotEmpty;
      expect(timerVisible, isTrue,
          reason: 'Timer should be visible after recovery');
      
      // Finish workout
      await timerPage.skipTimer();
      await workoutPage.finishWorkout();
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Workout with superset exercises',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Create workout with superset
      await workoutPage.navigateToWorkouts();
      await $.tap(find.byKey(const Key('create_workout_button')));
      
      // Add superset exercises
      await $.enterText(
        find.byKey(const Key('workout_name_field')),
        'Superset Test',
      );
      
      // Add first exercise of superset
      await $.tap(find.byKey(const Key('add_exercise_button')));
      await $.enterText(
        find.byKey(const Key('exercise_search')),
        'Bicep Curl',
      );
      await $.tap(find.text('Bicep Curl').first);
      
      // Mark as superset
      await $.tap(find.byKey(const Key('superset_toggle')));
      
      // Add second exercise of superset
      await $.tap(find.byKey(const Key('add_exercise_button')));
      await $.enterText(
        find.byKey(const Key('exercise_search')),
        'Tricep Extension',
      );
      await $.tap(find.text('Tricep Extension').first);
      
      await $.tap(find.byKey(const Key('save_workout_button')));
      await $.pumpAndSettle();
      
      // Start workout
      await workoutPage.startWorkout('Superset Test');
      
      // Complete superset - no rest between exercises
      await workoutPage.completeSet(weight: 30, reps: 12); // Bicep curl
      
      // Should immediately go to tricep extension (no rest timer)
      expect(await timerPage.isTimerRunning(), isFalse,
          reason: 'No rest timer between superset exercises');
      
      await workoutPage.completeSet(weight: 25, reps: 12); // Tricep extension
      
      // Now rest timer should start (after superset completion)
      expect(await timerPage.isTimerRunning(), isTrue,
          reason: 'Rest timer should start after superset completion');
      
      await timerPage.skipTimer();
      
      // Complete second round
      await workoutPage.completeSet(weight: 30, reps: 10);
      await workoutPage.completeSet(weight: 25, reps: 10);
      
      await timerPage.skipTimer();
      await workoutPage.finishWorkout();
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
}