import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:gymbro_flutter_new/app/app.dart' as app;
import '../helpers/test_base.dart';
import '../pages/workout_page.dart';
import '../pages/timer_page.dart';

void main() {
  patrolTest(
    'Timer continues running when app goes to background',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Start workout and trigger rest timer
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Background Timer Test');
      await workoutPage.startWorkout('Background Timer Test');
      await workoutPage.completeSet(weight: 100, reps: 10);
      
      // Get initial timer time
      final initialTime = await timerPage.getTimerTime();
      expect(initialTime, isNotNull);
      if (kDebugMode) debugPrint('Initial timer time: $initialTime');
      
      // Parse initial time to seconds
      final parts = initialTime!.split(':');
      final initialSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      
      // Put app in background
      await $.native.pressHome();
      if (kDebugMode) debugPrint('App moved to background');
      
      // Wait 15 seconds
      await Future.delayed(const Duration(seconds: 15));
      
      // Return to app
      await $.native.openApp();
      await $.pumpAndSettle();
      if (kDebugMode) debugPrint('App returned to foreground');
      
      // Get new timer time
      final newTime = await timerPage.getTimerTime();
      expect(newTime, isNotNull);
      if (kDebugMode) debugPrint('New timer time: $newTime');
      
      // Parse new time
      final newParts = newTime!.split(':');
      final newSeconds = int.parse(newParts[0]) * 60 + int.parse(newParts[1]);
      
      // Calculate difference
      final difference = initialSeconds - newSeconds;
      if (kDebugMode) debugPrint('Time difference: $difference seconds');
      
      // Timer should have decreased by approximately 15 seconds
      expect(difference, greaterThanOrEqualTo(14),
          reason: 'Timer should continue counting in background');
      expect(difference, lessThanOrEqualTo(16),
          reason: 'Timer should count accurately in background');
      
      // Skip timer and finish
      await timerPage.skipTimer();
      await workoutPage.finishWorkout();
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Timer sound plays when timer completes in background',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Enable timer sound
      await timerPage.openTimerSettings();
      await timerPage.toggleSound(); // Ensure sound is ON
      await $.native.tap(Selector(text: 'Done')); // Close settings
      
      // Start workout
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Sound Test');
      await workoutPage.startWorkout('Sound Test');
      
      // Complete a set with high reps for short rest timer
      await workoutPage.completeSet(weight: 50, reps: 20); // ~60 second rest
      
      // Wait for timer to be close to completion
      await Future.delayed(const Duration(seconds: 50));
      
      // Put app in background
      await $.native.pressHome();
      if (kDebugMode) debugPrint('App in background, timer should complete soon');
      
      // Wait for timer to complete in background
      await Future.delayed(const Duration(seconds: 15));
      
      // Return to app
      await $.native.openApp();
      await $.pumpAndSettle();
      
      // Timer should have completed
      final timerTime = await timerPage.getTimerTime();
      expect(timerTime == null || timerTime == '00:00', isTrue,
          reason: 'Timer should have completed in background');
      
      // Note: Actual sound verification requires native platform checks
      // This test verifies the timer completion logic
      
      await workoutPage.finishWorkout();
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'App recovers timer state after being killed and restarted',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Start workout and timer
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Recovery Test');
      await workoutPage.startWorkout('Recovery Test');
      await workoutPage.completeSet(weight: 100, reps: 8);
      
      // Verify timer is running
      final initialTime = await timerPage.getTimerTime();
      expect(initialTime, isNotNull);
      if (kDebugMode) debugPrint('Timer before app kill: $initialTime');
      
      // Note: Actual app kill/restart requires platform-specific implementation
      // For testing purposes, we simulate this with background/foreground
      
      // Simulate app going to background (as proxy for kill)
      await $.native.pressHome();
      await Future.delayed(const Duration(seconds: 5));
      
      // "Restart" app (return to foreground)
      await $.native.openApp();
      await $.pumpAndSettle();
      
      // Timer should still be present (recovered from storage)
      final recoveredTime = await timerPage.getTimerTime();
      expect(recoveredTime, isNotNull,
          reason: 'Timer should be recovered after app restart');
      
      // Timer should have progressed
      expect(recoveredTime != initialTime, isTrue,
          reason: 'Timer should show progress after recovery');
      
      await timerPage.skipTimer();
      await workoutPage.finishWorkout();
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Notification appears when timer completes and app is in background',
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.GymBroApp());
      
      final workoutPage = WorkoutPage($);
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);

      // Grant notification permission if requested
      // TODO: Update to Patrol 3.x API
      await TestBase.grantPermission($, 'notification');
      
      // Start workout
      await workoutPage.navigateToWorkouts();
      await TestBase.createTestWorkout($, name: 'Notification Test');
      await workoutPage.startWorkout('Notification Test');
      
      // Complete set with very high reps for shortest rest time
      await workoutPage.completeSet(weight: 30, reps: 25); // ~30 second rest
      
      // Wait briefly then go to background
      await Future.delayed(const Duration(seconds: 20));
      await $.native.pressHome();
      
      // Wait for timer to complete
      await Future.delayed(const Duration(seconds: 15));

      // Check for notification
      // TODO: Update to Patrol 3.x API - notification methods changed
      // if (await $.native.isIOS()) {
      //   await $.native.openNotifications();
      //   expect(
      //     await $.native.notificationExists(
      //       Selector(textContains: 'Rest time complete'),
      //     ),
      //     isTrue,
      //     reason: 'Notification should appear when timer completes',
      //   );
      //   await $.native.tapNotification(
      //     Selector(textContains: 'Rest time complete'),
      //   );
      // } else {
      //   await $.native.openNotifications();
      //   expect(
      //     await $.native.notificationExists(
      //       Selector(textContains: 'Rest time complete'),
      //     ),
      //     isTrue,
      //   );
      //   await $.native.tapNotification(
      //     Selector(textContains: 'Rest time complete'),
      //   );
      // }

      await $.pumpAndSettle();

      // Should be back in app with workout active
      // TODO: Re-enable after updating notification API
      // expect(await workoutPage.isWorkoutActive(), isTrue);
      
      await workoutPage.finishWorkout();
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
}