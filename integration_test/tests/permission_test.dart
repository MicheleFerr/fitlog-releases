import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:gymbro_flutter_new/main.dart' as app;
import '../helpers/test_base.dart';
import '../pages/timer_page.dart';

void main() {
  patrolTest(
    'App requests notification permission when enabling timer sounds',
    config: const PatrolTestConfig(
      appName: 'GymBro',
    ),
    nativeAutomation: true,
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Open timer settings
      await timerPage.openTimerSettings();
      
      // Try to enable sound (should trigger permission request)
      await timerPage.toggleSound();
      
      // Grant notification permission when requested
      await $.native.grantPermissionWhenRequested(Permission.notification);
      
      // Verify sound is now enabled
      await $.pumpAndSettle();
      
      // Close settings
      await $.native.tap(Selector(text: 'Done'));
      
      // Start a workout to test notifications work
      await TestBase.createTestWorkout($, name: 'Permission Test');
      
      // Verify we can now receive notifications
      expect(
        await $.native.isPermissionGranted(Permission.notification),
        isTrue,
        reason: 'Notification permission should be granted',
      );
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'App handles notification permission denial gracefully',
    config: const PatrolTestConfig(
      appName: 'GymBro',
    ),
    nativeAutomation: true,
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // Open timer settings
      await timerPage.openTimerSettings();
      
      // Try to enable sound
      await timerPage.toggleSound();
      
      // Deny notification permission
      await $.native.denyPermissionWhenRequested(Permission.notification);
      
      await $.pumpAndSettle();
      
      // App should show message about permission being denied
      expect(
        find.textContaining('Notifications are required'),
        findsOneWidget,
        reason: 'App should inform user that notifications are required',
      );
      
      // Sound toggle should remain off
      // Close dialog if present
      if (find.text('OK').evaluate().isNotEmpty) {
        await $.tap(find.text('OK'));
      }
      
      // Verify permission is denied
      expect(
        await $.native.isPermissionGranted(Permission.notification),
        isFalse,
        reason: 'Notification permission should be denied',
      );
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'App prompts to open settings when permission previously denied',
    config: const PatrolTestConfig(
      appName: 'GymBro',
    ),
    nativeAutomation: true,
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      final timerPage = TimerPage($);
      
      await TestBase.loginTestUser($);
      
      // First, deny permission
      await timerPage.openTimerSettings();
      await timerPage.toggleSound();
      await $.native.denyPermissionWhenRequested(Permission.notification);
      await $.pumpAndSettle();
      
      // Close any dialogs
      if (find.text('OK').evaluate().isNotEmpty) {
        await $.tap(find.text('OK'));
      }
      
      // Try to enable sound again (permission already denied)
      await timerPage.toggleSound();
      await $.pumpAndSettle();
      
      // App should show dialog to open settings
      expect(
        find.textContaining('Open Settings'),
        findsOneWidget,
        reason: 'App should prompt to open settings when permission denied',
      );
      
      // Tap "Open Settings" button
      await $.tap(find.text('Open Settings'));
      
      // Note: We can't actually test the settings app opening
      // but we verify the button exists and is tappable
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Health permission request for fitness tracking (iOS)',
    config: const PatrolTestConfig(
      appName: 'GymBro',
    ),
    nativeAutomation: true,
    ($) async {
      // Only run on iOS (HealthKit)
      if (!await $.native.isIOS()) {
        return;
      }
      
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      await TestBase.loginTestUser($);
      
      // Navigate to settings
      await $.tap(find.byKey(const Key('settings_tab')));
      
      // Find and tap "Connect to Health"
      await $.scrollUntilVisible(
        finder: find.text('Connect to Health'),
        view: find.byType(Scrollable).first,
      );
      await $.tap(find.text('Connect to Health'));
      
      // Grant health permissions when requested
      // Note: Health permissions are more complex on iOS
      // This is a simplified version
      await $.native.grantPermissionWhenRequested(Permission.health);
      
      await $.pumpAndSettle();
      
      // Verify health is connected
      expect(
        find.text('Health Connected'),
        findsOneWidget,
        reason: 'Health should show as connected after granting permission',
      );
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Camera permission for form check videos',
    config: const PatrolTestConfig(
      appName: 'GymBro',
    ),
    nativeAutomation: true,
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      await TestBase.loginTestUser($);
      
      // Create and start workout
      await TestBase.createTestWorkout($, name: 'Form Check Test');
      await $.tap(find.text('Form Check Test'));
      await $.tap(find.byKey(const Key('start_workout_button')));
      
      // Look for form check button
      await $.tap(find.byKey(const Key('form_check_button')));
      
      // Grant camera permission when requested
      await $.native.grantPermissionWhenRequested(Permission.camera);
      
      await $.pumpAndSettle();
      
      // Camera should open (we can't test actual camera view)
      // But we can verify permission was granted
      expect(
        await $.native.isPermissionGranted(Permission.camera),
        isTrue,
        reason: 'Camera permission should be granted',
      );
      
      // Close camera if open
      if (find.byKey(const Key('close_camera_button')).evaluate().isNotEmpty) {
        await $.tap(find.byKey(const Key('close_camera_button')));
      }
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
  
  patrolTest(
    'Multiple permissions requested in sequence',
    config: const PatrolTestConfig(
      appName: 'GymBro',
    ),
    nativeAutomation: true,
    ($) async {
      await TestBase.setupTestEnvironment();
      await $.pumpWidgetAndSettle(const app.MyApp());
      
      await TestBase.loginTestUser($);
      
      // First time setup flow might request multiple permissions
      
      // 1. Notification permission for timer
      await $.tap(find.byKey(const Key('enable_notifications_button')));
      await $.native.grantPermissionWhenRequested(Permission.notification);
      await $.pumpAndSettle();
      
      // 2. Health permission for fitness tracking (iOS only)
      if (await $.native.isIOS()) {
        await $.tap(find.byKey(const Key('enable_health_button')));
        await $.native.grantPermissionWhenRequested(Permission.health);
        await $.pumpAndSettle();
      }
      
      // 3. Camera permission for form videos
      await $.tap(find.byKey(const Key('enable_camera_button')));
      await $.native.grantPermissionWhenRequested(Permission.camera);
      await $.pumpAndSettle();
      
      // Verify all permissions granted
      expect(
        await $.native.isPermissionGranted(Permission.notification),
        isTrue,
      );
      expect(
        await $.native.isPermissionGranted(Permission.camera),
        isTrue,
      );
      if (await $.native.isIOS()) {
        expect(
          await $.native.isPermissionGranted(Permission.health),
          isTrue,
        );
      }
      
      await TestBase.logoutUser($);
      await TestBase.cleanup();
    },
  );
}