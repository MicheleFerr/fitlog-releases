import 'dart:io';
import 'package:flutter/services.dart';

/// Android Timer Service
///
/// This service manages the Android Foreground Service for workout timers.
/// Unlike iOS Live Activities, Android uses a persistent foreground notification
/// with quick actions and progress tracking.
///
/// Features:
/// - Foreground service keeps timer running in background
/// - Rich notification with progress bar
/// - Quick actions (Pause/Resume/Stop)
/// - Battery efficient (no continuous updates like iOS)
///
/// Usage:
/// ```dart
/// if (Platform.isAndroid) {
///   await AndroidTimerService.startTimer(
///     exerciseName: 'Bench Press',
///     remainingSeconds: 90,
///     totalSeconds: 90,
///     currentSet: 2,
///     totalSets: 4,
///   );
/// }
/// ```
class AndroidTimerService {
  static const MethodChannel _channel = MethodChannel('com.gymbro.timer/android');
  static Function(String action)? _onTimerAction;

  /// Initialize the service and set up listeners
  static Future<void> initialize({
    Function(String action)? onTimerAction,
  }) async {
    if (!Platform.isAndroid) return;

    _onTimerAction = onTimerAction;

    // Setup method call handler for callbacks from Android
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTimerAction') {
        final action = call.arguments['action'] as String?;
        if (action != null && _onTimerAction != null) {
          _onTimerAction!(action);
        }
      }
    });
  }

  /// Start the timer foreground service
  ///
  /// This will show a persistent notification with:
  /// - Timer countdown
  /// - Progress bar
  /// - Pause/Resume button
  /// - Stop button
  static Future<bool> startTimer({
    required String exerciseName,
    String? workoutName,
    required int remainingSeconds,
    required int totalSeconds,
    required int currentSet,
    required int totalSets,
  }) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('startTimer', {
        'exerciseName': exerciseName,
        'workoutName': workoutName,
        'remainingSeconds': remainingSeconds,
        'totalSeconds': totalSeconds,
        'currentSet': currentSet,
        'totalSets': totalSets,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('❌ Failed to start Android timer: ${e.message}');
      return false;
    }
  }

  /// Update the timer notification
  ///
  /// Call this every second while the timer is running to update the notification.
  /// The notification will show the new remaining time and update the progress bar.
  static Future<bool> updateTimer({
    required int remainingSeconds,
    required bool isRunning,
    required int currentSet,
  }) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('updateTimer', {
        'remainingSeconds': remainingSeconds,
        'isRunning': isRunning,
        'currentSet': currentSet,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('❌ Failed to update Android timer: ${e.message}');
      return false;
    }
  }

  /// Stop the timer and dismiss the notification
  static Future<bool> stopTimer() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('stopTimer');
      return result ?? false;
    } on PlatformException catch (e) {
      print('❌ Failed to stop Android timer: ${e.message}');
      return false;
    }
  }

  /// Check if the service is available (Android only)
  static bool get isAvailable => Platform.isAndroid;
}
