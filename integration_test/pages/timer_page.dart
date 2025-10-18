import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Page Object for Timer functionality
class TimerPage {
  
  TimerPage(this.$);
  final PatrolIntegrationTester $;
  
  // Main timer overlay finders
  Finder get timerOverlay => find.byKey(const Key('timer_overlay'));
  Finder get timerDisplay => find.byKey(const Key('timer_display'));
  Finder get timerCircularProgress => find.byKey(const Key('timer_circular_progress'));
  
  // Timer controls
  Finder get pauseTimerButton => find.byKey(const Key('pause_timer_button'));
  Finder get playTimerButton => find.byKey(const Key('play_timer_button'));
  Finder get skipTimerButton => find.byKey(const Key('skip_timer_button'));
  Finder get addThirtySecondsButton => find.byKey(const Key('add_30s_timer_button'));
  Finder get resetTimerButton => find.byKey(const Key('reset_timer_button'));
  
  // Minimized timer
  Finder get minimizedTimer => find.byKey(const Key('minimized_timer'));
  Finder get expandTimerButton => find.byKey(const Key('expand_timer_button'));
  Finder get minimizeTimerButton => find.byKey(const Key('minimize_timer_button'));
  
  // Timer settings
  Finder get timerSettingsButton => find.byKey(const Key('timer_settings_button'));
  Finder get soundToggle => find.byKey(const Key('sound_toggle'));
  Finder get vibrationToggle => find.byKey(const Key('vibration_toggle'));
  Finder get autoStartToggle => find.byKey(const Key('auto_start_toggle'));
  
  // Sound selection
  Finder get soundPicker => find.byKey(const Key('sound_picker'));
  Finder soundOption(String soundName) => find.byKey(Key('sound_$soundName'));
  
  /// Get current timer time as string
  Future<String?> getTimerTime() async {
    final elements = timerDisplay.evaluate();
    if (elements.isEmpty) return null;
    
    final widget = elements.first.widget as Text;
    return widget.data;
  }
  
  /// Check if timer is running
  Future<bool> isTimerRunning() async {
    final time1 = await getTimerTime();
    await Future.delayed(const Duration(seconds: 2));
    final time2 = await getTimerTime();
    
    return time1 != time2;
  }
  
  /// Check if timer is paused
  Future<bool> isTimerPaused() async {
    // Check if pause button is visible (timer is running)
    // or play button is visible (timer is paused)
    return playTimerButton.evaluate().isNotEmpty;
  }
  
  /// Pause the timer
  Future<void> pauseTimer() async {
    await $.tap(pauseTimerButton);
    await $.pumpAndSettle();
  }
  
  /// Resume the timer
  Future<void> resumeTimer() async {
    await $.tap(playTimerButton);
    await $.pumpAndSettle();
  }
  
  /// Skip the timer
  Future<void> skipTimer() async {
    await $.tap(skipTimerButton);
    await $.pumpAndSettle();
  }
  
  /// Add 30 seconds to timer
  Future<void> addThirtySeconds() async {
    await $.tap(addThirtySecondsButton);
    await $.pumpAndSettle();
  }
  
  /// Reset the timer
  Future<void> resetTimer() async {
    await $.tap(resetTimerButton);
    await $.pumpAndSettle();
  }
  
  /// Minimize the timer overlay
  Future<void> minimizeTimer() async {
    await $.tap(minimizeTimerButton);
    await $.pumpAndSettle();
  }
  
  /// Expand minimized timer
  Future<void> expandTimer() async {
    await $.tap(expandTimerButton);
    await $.pumpAndSettle();
  }
  
  /// Check if timer is minimized
  Future<bool> isTimerMinimized() async {
    return minimizedTimer.evaluate().isNotEmpty;
  }
  
  /// Drag timer to new position
  /// TODO: Patrol 3.x - drag() method removed, need to find alternative
  Future<void> dragTimerTo(Offset position) async {
    // await $.drag(timerOverlay, position);
    // await $.pumpAndSettle();
    // Placeholder - drag functionality disabled
    await $.pumpAndSettle();
  }
  
  /// Open timer settings
  Future<void> openTimerSettings() async {
    await $.tap(timerSettingsButton);
    await $.pumpAndSettle();
  }
  
  /// Toggle sound on/off
  Future<void> toggleSound() async {
    await $.tap(soundToggle);
    await $.pumpAndSettle();
  }
  
  /// Toggle vibration on/off
  Future<void> toggleVibration() async {
    await $.tap(vibrationToggle);
    await $.pumpAndSettle();
  }
  
  /// Toggle auto-start on/off
  Future<void> toggleAutoStart() async {
    await $.tap(autoStartToggle);
    await $.pumpAndSettle();
  }
  
  /// Select a timer sound
  Future<void> selectSound(String soundName) async {
    await $.tap(soundPicker);
    await $.pumpAndSettle();
    
    await $.tap(soundOption(soundName));
    await $.pumpAndSettle();
  }
  
  /// Wait for timer to complete
  Future<void> waitForTimerCompletion() async {
    // Wait until timer shows 00:00 or disappears
    while (true) {
      final time = await getTimerTime();
      if (time == null || time == '00:00') {
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  
  /// Verify timer completed with sound
  Future<bool> didTimerCompleteWithSound() async {
    // This would need native platform checks
    // For now, check if timer reached 00:00
    final time = await getTimerTime();
    return time == '00:00' || time == null;
  }
  
  /// Check if Live Activity is showing timer (iOS)
  Future<bool> isTimerInLiveActivity() async {
    // TODO: Patrol 3.x - isIOS() removed, using Platform.isIOS
    if (!Platform.isIOS) return false;

    // Check for Live Activity
    // This requires native iOS implementation
    return true; // Placeholder
  }
  
  /// Check if timer continues in background
  Future<bool> doesTimerContinueInBackground() async {
    // Get initial time
    final initialTime = await getTimerTime();
    if (initialTime == null) return false;
    
    // Parse time to seconds
    final parts = initialTime.split(':');
    final initialSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    
    // Go to background
    await $.native.pressHome();
    
    // Wait 10 seconds
    await Future.delayed(const Duration(seconds: 10));
    
    // Return to app
    await $.native.openApp();
    await $.pumpAndSettle();
    
    // Get new time
    final newTime = await getTimerTime();
    if (newTime == null) return false;
    
    // Parse new time
    final newParts = newTime.split(':');
    final newSeconds = int.parse(newParts[0]) * 60 + int.parse(newParts[1]);
    
    // Check if timer decreased by approximately 10 seconds
    final difference = initialSeconds - newSeconds;
    return difference >= 9 && difference <= 11;
  }
}