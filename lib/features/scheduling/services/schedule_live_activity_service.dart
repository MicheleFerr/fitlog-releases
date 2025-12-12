import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for managing Schedule Countdown Live Activities on iOS.
///
/// Shows a countdown on the lock screen when a scheduled workout is approaching.
/// Displays workout name, remaining time, and urgency-based colors.
///
/// Features:
/// - Countdown to scheduled workout time
/// - Urgency-based colors (green when ready, red when starting soon)
/// - Dynamic Island support on iPhone 14 Pro+
/// - Deep linking to start the scheduled workout
class ScheduleLiveActivityService {
  ScheduleLiveActivityService._();
  static final ScheduleLiveActivityService _instance =
      ScheduleLiveActivityService._();
  static ScheduleLiveActivityService get instance => _instance;

  /// Method channel for Live Activities (shared with timer)
  static const _channel = MethodChannel('com.gymbro.timer/live_activity');

  /// Currently active schedule Live Activity ID
  String? _currentActivityId;

  /// Get the current activity ID
  String? get currentActivityId => _currentActivityId;

  /// Check if a schedule Live Activity is currently active
  bool get isActive => _currentActivityId != null;

  /// Start a schedule countdown Live Activity
  ///
  /// [workoutName] - Name of the scheduled workout (e.g., "Leg Day")
  /// [workoutId] - Template ID for deep linking
  /// [scheduledTime] - When the workout is scheduled
  /// [reminderTime] - Optional reminder time before workout
  ///
  /// Returns the activity ID if successful, null otherwise.
  Future<String?> startScheduleLiveActivity({
    required String workoutName,
    required String workoutId,
    required DateTime scheduledTime,
    DateTime? reminderTime,
  }) async {
    // Only supported on iOS 16.1+
    if (!Platform.isIOS) {
      if (kDebugMode) {
        debugPrint(
            '[ScheduleLiveActivity] Not on iOS, skipping Live Activity start');
      }
      return null;
    }

    try {
      // End any existing schedule activity first
      if (_currentActivityId != null) {
        await endScheduleLiveActivity();
      }

      if (kDebugMode) {
        debugPrint('''
  📅 [ScheduleLiveActivity] Starting Live Activity:
     - Workout: $workoutName
     - Scheduled: $scheduledTime
     - Reminder: $reminderTime
  ''');
      }

      final result = await _channel.invokeMethod('startScheduleLiveActivity', {
        'workoutName': workoutName,
        'workoutId': workoutId,
        'scheduledTimestamp': scheduledTime.millisecondsSinceEpoch,
        if (reminderTime != null)
          'reminderTimestamp': reminderTime.millisecondsSinceEpoch,
      });

      if (result != null && result is String && result.isNotEmpty) {
        _currentActivityId = result;
        if (kDebugMode) {
          debugPrint(
              '[ScheduleLiveActivity] ✅ Live Activity started: $_currentActivityId');
        }
        return result;
      }

      return null;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ❌ Platform error: ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ❌ Error starting Live Activity: $e');
      }
      return null;
    }
  }

  /// Update the schedule countdown Live Activity
  ///
  /// Call this periodically (e.g., every minute) to update the countdown.
  /// The iOS side recalculates remaining time from scheduledTime.
  Future<bool> updateScheduleLiveActivity({
    required DateTime scheduledTime,
  }) async {
    if (!Platform.isIOS || _currentActivityId == null) {
      return false;
    }

    try {
      await _channel.invokeMethod('updateScheduleLiveActivity', {
        'activityId': _currentActivityId,
        'scheduledTimestamp': scheduledTime.millisecondsSinceEpoch,
      });

      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ✅ Live Activity updated');
      }
      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ❌ Update error: ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ❌ Error updating Live Activity: $e');
      }
      return false;
    }
  }

  /// End the schedule countdown Live Activity
  ///
  /// [dismissPolicy] - How to dismiss:
  ///   - "immediate": Remove immediately
  ///   - "after_5s": Show for 5 more seconds
  ///   - "after_30s": Show for 30 more seconds
  Future<bool> endScheduleLiveActivity({
    String dismissPolicy = 'immediate',
  }) async {
    if (!Platform.isIOS || _currentActivityId == null) {
      _currentActivityId = null;
      return true;
    }

    try {
      await _channel.invokeMethod('endScheduleLiveActivity', {
        'activityId': _currentActivityId,
        'dismissPolicy': dismissPolicy,
      });

      if (kDebugMode) {
        debugPrint(
            '[ScheduleLiveActivity] ✅ Live Activity ended: $_currentActivityId');
      }
      _currentActivityId = null;
      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ❌ End error: ${e.message}');
      }
      _currentActivityId = null;
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ❌ Error ending Live Activity: $e');
      }
      _currentActivityId = null;
      return false;
    }
  }

  /// End all schedule Live Activities
  ///
  /// Useful for cleanup on logout or app reset.
  Future<bool> endAllScheduleLiveActivities() async {
    if (!Platform.isIOS) {
      return true;
    }

    try {
      await _channel.invokeMethod('endAllScheduleLiveActivities');
      _currentActivityId = null;
      if (kDebugMode) {
        debugPrint('[ScheduleLiveActivity] ✅ All Live Activities ended');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[ScheduleLiveActivity] ❌ Error ending all Live Activities: $e');
      }
      return false;
    }
  }

  /// Get list of active schedule Live Activity IDs
  Future<List<String>> getActiveScheduleLiveActivities() async {
    if (!Platform.isIOS) {
      return [];
    }

    try {
      final result =
          await _channel.invokeMethod('getActiveScheduleLiveActivities');
      if (result is List) {
        return result.cast<String>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[ScheduleLiveActivity] ❌ Error getting active activities: $e');
      }
      return [];
    }
  }

  /// Check if Live Activities are supported and enabled
  Future<bool> isLiveActivitySupported() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('isLiveActivitySupported');
      return result == true;
    } catch (e) {
      return false;
    }
  }
}
