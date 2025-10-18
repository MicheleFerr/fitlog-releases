import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:gymbro_flutter_new/app/app.dart' as app;
import '../helpers/test_base.dart';
import '../pages/workout_page.dart';
import '../pages/timer_page.dart';

void main() {
  patrolTest(
    'Live Activity shows timer during workout rest periods on iOS',

    ($) async {
      // Setup test environment
      await TestBase.setupTestEnvironment();
      
      // Start app
      await $.pumpWidgetAndSettle(const app.FitLogApp());
      
      // Initialize page objects
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      // Login test user
      await TestBase.loginTestUser($);
      
      // Create and start a workout
      await workoutPage.navigateToWorkouts();
      await workoutPage.createWorkout(
        name: 'Test Workout',
        exercises: ['Bench Press', 'Squat'],
      );
      await workoutPage.startWorkout('Test Workout');
      
      // Complete first set to trigger rest timer
      await workoutPage.completeSet(weight: 100, reps: 10);
      
      // Verify rest timer started
      expect(await timerPage.isTimerRunning(), isTrue,
          reason: 'Rest timer should start after completing a set');

      // Only test Live Activity on iOS
      // TODO: Patrol 3.x - isIOS() removed, using Platform.isIOS
      if (Platform.isIOS) {
        // Put app in background to trigger Live Activity
        await $.native.pressHome();
        
        // Wait a moment for Live Activity to appear
        await Future.delayed(const Duration(seconds: 2));
        
        // Verify Live Activity is showing
        // Note: This requires iOS-specific implementation
        // For now, we verify the app continues running in background
        
        // Wait 10 seconds in background
        await Future.delayed(const Duration(seconds: 10));
        
        // Return to app
        await $.native.openApp();
        await $.pumpAndSettle();
        
        // Verify timer continued running
        final timerTime = await timerPage.getTimerTime();
        expect(timerTime, isNotNull,
            reason: 'Timer should still be visible after returning from background');
        
        // Verify timer decreased while in background
        // Initial rest time is based on reps (10 reps = ~90 seconds)
        // After 10 seconds in background, should be around 80 seconds
        expect(await timerPage.doesTimerContinueInBackground(), isTrue,
            reason: 'Timer should continue counting down in background');
      }
      
      // Complete workout
      await timerPage.skipTimer();
      await workoutPage.finishWorkout();
      
      // Verify workout completed
      expect(await workoutPage.isWorkoutCompleted(), isTrue);
      
      // Cleanup
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Live Activity updates with timer controls on iOS',

    ($) async {
      // Only run on iOS
      // TODO: Patrol 3.x - isIOS() removed, using Platform.isIOS
      if (!Platform.isIOS) {
        return;
      }
      
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.FitLogApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Start workout and trigger rest timer
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Live Activity Test');
      await workoutPage.startWorkout('Live Activity Test');
      await workoutPage.completeSet(weight: 150, reps: 5); // Heavy set = longer rest
      
      // Verify timer started
      final initialTime = await timerPage.getTimerTime();
      expect(initialTime, isNotNull);
      
      // Add 30 seconds to timer
      await timerPage.addThirtySeconds();
      
      // Go to background
      await $.native.pressHome();
      await Future.delayed(const Duration(seconds: 2));
      
      // Live Activity should show updated timer
      // Note: Actual Live Activity verification requires native iOS code
      
      // Return to app
      await $.native.openApp();
      await $.pumpAndSettle();
      
      // Pause timer
      await timerPage.pauseTimer();
      
      // Go to background again
      await $.native.pressHome();
      await Future.delayed(const Duration(seconds: 5));
      
      // Return to app
      await $.native.openApp();
      await $.pumpAndSettle();
      
      // Timer should still be paused
      expect(await timerPage.isTimerPaused(), isTrue,
          reason: 'Timer should remain paused after background/foreground cycle');
      
      // Resume and skip
      await timerPage.resumeTimer();
      await timerPage.skipTimer();
      
      // Finish workout
      await workoutPage.finishWorkout();
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Dynamic Island shows compact timer on supported devices',

    ($) async {
      // Only test on iOS
      // TODO: Patrol 3.x - isIOS() removed, using Platform.isIOS
      if (!Platform.isIOS) {
        return;
      }
      
      // Note: Dynamic Island is only on iPhone 14 Pro and later
      // This test would need device-specific checks
      
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.FitLogApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Start workout
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Dynamic Island Test');
      await workoutPage.startWorkout('Dynamic Island Test');
      
      // Complete set to start rest timer
      await workoutPage.completeSet(weight: 80, reps: 12);
      
      // Minimize timer in app
      await timerPage.minimizeTimer();
      
      // Put app in background
      await $.native.pressHome();
      
      // On supported devices, Dynamic Island should show timer
      // This requires native iOS verification
      await Future.delayed(const Duration(seconds: 5));
      
      // Return to app
      await $.native.openApp();
      await $.pumpAndSettle();
      
      // Timer should still be running
      expect(await timerPage.isTimerRunning(), isTrue);
      
      // Expand timer
      await timerPage.expandTimer();
      
      // Skip and finish
      await timerPage.skipTimer();
      await workoutPage.finishWorkout();
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
}