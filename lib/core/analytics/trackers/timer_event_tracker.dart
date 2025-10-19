/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: core/analytics/trackers
/// 🎯 Feature: analytics
/// 🔧 Type: tracker helper
///
/// Timer event tracking helper
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/core/services/analytics/i_analytics_service.dart';

/// Timer event tracker
///
/// Helper class for tracking timer usage (rest timers, workout timers, Live Activities).
/// Provides convenient methods with predefined event names and parameters.
///
/// Tracks:
/// - Rest timer lifecycle (start, complete, cancel, skip)
/// - Live Activity interactions (iOS)
/// - Timer statistics (duration, completion rate)
/// - Custom timer usage
///
/// Usage:
/// ```dart
/// final tracker = TimerEventTracker(analytics);
///
/// // Track rest timer started
/// await tracker.trackRestTimerStarted(
///   duration: 90,
///   exerciseId: 'exercise_123',
/// );
///
/// // Track rest timer completed
/// await tracker.trackRestTimerCompleted(
///   duration: 90,
///   exerciseId: 'exercise_123',
/// );
///
/// // Track Live Activity started (iOS)
/// await tracker.trackLiveActivityStarted(
///   workoutId: 'workout_123',
/// );
/// ```
class TimerEventTracker {
  TimerEventTracker(this.analytics);

  final IAnalyticsService analytics;

  /// Timers in progress (for tracking skips/cancellations)
  final Map<String, DateTime> _activeTimers = {};

  // ===== REST TIMER EVENTS =====

  /// Track rest timer started
  ///
  /// Logs when rest timer begins between sets.
  ///
  /// Parameters:
  /// - [duration] - Timer duration in seconds
  /// - [exerciseId] - Exercise identifier
  /// - [workoutId] - Workout identifier
  /// - [source] - Where timer was started (preset, custom, auto)
  Future<void> trackRestTimerStarted({
    required int duration,
    required String exerciseId,
    String? workoutId,
    String source = 'unknown',
  }) async {
    try {
      final timerId = '${workoutId ?? ''}_$exerciseId';
      _activeTimers[timerId] = DateTime.now();

      await analytics.logEvent(
        name: AnalyticsEvents.restTimerStarted,
        parameters: {
          AnalyticsParameters.timerDuration: duration,
          AnalyticsParameters.timerType: 'rest',
          AnalyticsParameters.exerciseId: exerciseId,
          if (workoutId != null) AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.source: source,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Rest timer started: ${duration}s for exercise $exerciseId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking rest timer started: $e');
      }
    }
  }

  /// Track rest timer completed
  ///
  /// Logs when rest timer finishes naturally (not skipped).
  ///
  /// Parameters:
  /// - [duration] - Timer duration in seconds
  /// - [exerciseId] - Exercise identifier
  /// - [workoutId] - Workout identifier
  /// - [actualDuration] - Actual elapsed time (may differ from planned)
  Future<void> trackRestTimerCompleted({
    required int duration,
    required String exerciseId,
    String? workoutId,
    int? actualDuration,
  }) async {
    try {
      final timerId = '${workoutId ?? ''}_$exerciseId';
      final startTime = _activeTimers[timerId];

      // Calculate actual duration if not provided
      final elapsed = actualDuration ??
          (startTime != null
              ? DateTime.now().difference(startTime).inSeconds
              : duration);

      _activeTimers.remove(timerId);

      await analytics.logEvent(
        name: AnalyticsEvents.restTimerCompleted,
        parameters: {
          AnalyticsParameters.timerDuration: duration,
          AnalyticsParameters.timerType: 'rest',
          AnalyticsParameters.exerciseId: exerciseId,
          if (workoutId != null) AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.timerCompleted: true,
          'actual_duration': elapsed,
          if (actualDuration != null && actualDuration != duration)
            'duration_difference': actualDuration - duration,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Rest timer completed: ${duration}s (actual: ${elapsed}s)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking rest timer completed: $e');
      }
    }
  }

  /// Track rest timer cancelled
  ///
  /// Logs when user manually cancels the timer before completion.
  ///
  /// Parameters:
  /// - [duration] - Original timer duration in seconds
  /// - [elapsedSeconds] - Time elapsed before cancellation
  /// - [exerciseId] - Exercise identifier
  /// - [workoutId] - Workout identifier
  Future<void> trackRestTimerCancelled({
    required int duration,
    required int elapsedSeconds,
    required String exerciseId,
    String? workoutId,
  }) async {
    try {
      final timerId = '${workoutId ?? ''}_$exerciseId';
      _activeTimers.remove(timerId);

      await analytics.logEvent(
        name: AnalyticsEvents.restTimerCancelled,
        parameters: {
          AnalyticsParameters.timerDuration: duration,
          AnalyticsParameters.timerType: 'rest',
          AnalyticsParameters.exerciseId: exerciseId,
          if (workoutId != null) AnalyticsParameters.workoutId: workoutId,
          'elapsed_seconds': elapsedSeconds,
          'completion_percentage': ((elapsedSeconds / duration) * 100).round(),
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Rest timer cancelled: ${elapsedSeconds}s / ${duration}s');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking rest timer cancelled: $e');
      }
    }
  }

  /// Track rest timer skipped
  ///
  /// Logs when user skips to next set without waiting for timer.
  ///
  /// Parameters:
  /// - [duration] - Original timer duration in seconds
  /// - [elapsedSeconds] - Time elapsed before skip
  /// - [exerciseId] - Exercise identifier
  /// - [workoutId] - Workout identifier
  Future<void> trackRestTimerSkipped({
    required int duration,
    required int elapsedSeconds,
    required String exerciseId,
    String? workoutId,
  }) async {
    try {
      final timerId = '${workoutId ?? ''}_$exerciseId';
      _activeTimers.remove(timerId);

      await analytics.logEvent(
        name: AnalyticsEvents.restTimerSkipped,
        parameters: {
          AnalyticsParameters.timerDuration: duration,
          AnalyticsParameters.timerType: 'rest',
          AnalyticsParameters.exerciseId: exerciseId,
          if (workoutId != null) AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.timerSkipped: true,
          'elapsed_seconds': elapsedSeconds,
          'skipped_seconds': duration - elapsedSeconds,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Rest timer skipped: ${elapsedSeconds}s / ${duration}s');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking rest timer skipped: $e');
      }
    }
  }

  // ===== LIVE ACTIVITY EVENTS (iOS) =====

  /// Track Live Activity started
  ///
  /// Logs when Live Activity is displayed on iOS lock screen.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [activityType] - Type of Live Activity (rest_timer, workout_timer)
  /// - [duration] - Duration if timer-based
  Future<void> trackLiveActivityStarted({
    required String workoutId,
    String activityType = 'rest_timer',
    int? duration,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.liveActivityStarted,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          'activity_type': activityType,
          if (duration != null) AnalyticsParameters.timerDuration: duration,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Live Activity started: $activityType for $workoutId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking Live Activity started: $e');
      }
    }
  }

  /// Track Live Activity stopped
  ///
  /// Logs when Live Activity is dismissed.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [activityType] - Type of Live Activity
  /// - [reason] - Why it stopped (completed, cancelled, workout_ended)
  Future<void> trackLiveActivityStopped({
    required String workoutId,
    String activityType = 'rest_timer',
    String reason = 'unknown',
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.liveActivityStopped,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          'activity_type': activityType,
          'stop_reason': reason,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Live Activity stopped: $activityType ($reason)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking Live Activity stopped: $e');
      }
    }
  }

  /// Track Live Activity interaction
  ///
  /// Logs when user interacts with Live Activity from lock screen.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [action] - Action performed (skip, pause, resume, view)
  Future<void> trackLiveActivityInteraction({
    required String workoutId,
    required String action,
  }) async {
    try {
      await analytics.logEvent(
        name: AnalyticsEvents.liveActivityInteraction,
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          AnalyticsParameters.liveActivityAction: action,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Live Activity interaction: $action on $workoutId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking Live Activity interaction: $e');
      }
    }
  }

  // ===== TIMER STATISTICS =====

  /// Track timer usage statistics
  ///
  /// Logs aggregate data about timer usage patterns.
  /// Call this after workout completion to analyze timer behavior.
  ///
  /// Parameters:
  /// - [workoutId] - Workout identifier
  /// - [totalTimers] - Total timers started
  /// - [completedTimers] - Timers that finished naturally
  /// - [skippedTimers] - Timers that were skipped
  /// - [cancelledTimers] - Timers that were cancelled
  /// - [averageDuration] - Average timer duration
  /// - [averageCompletionRate] - Average percentage completed
  Future<void> trackTimerStatistics({
    required String workoutId,
    required int totalTimers,
    required int completedTimers,
    required int skippedTimers,
    required int cancelledTimers,
    int? averageDuration,
    int? averageCompletionRate,
  }) async {
    try {
      await analytics.logEvent(
        name: 'timer_statistics',
        parameters: {
          AnalyticsParameters.workoutId: workoutId,
          'total_timers': totalTimers,
          'completed_timers': completedTimers,
          'skipped_timers': skippedTimers,
          'cancelled_timers': cancelledTimers,
          if (averageDuration != null) 'average_duration': averageDuration,
          if (averageCompletionRate != null)
            'average_completion_rate': averageCompletionRate,
          'completion_rate_percent':
              totalTimers > 0 ? ((completedTimers / totalTimers) * 100).round() : 0,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Timer statistics: $completedTimers/$totalTimers completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error tracking timer statistics: $e');
      }
    }
  }

  /// Clear active timers (call when workout ends)
  void clearActiveTimers() {
    _activeTimers.clear();
  }
}
