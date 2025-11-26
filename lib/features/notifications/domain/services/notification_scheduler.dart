/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/domain/services
/// Feature: Local Notifications System
/// Type: Service - Notification Scheduler
///
/// Main service for scheduling retention notifications with anti-spam logic.
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_config.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Service for scheduling and managing retention notifications.
///
/// Handles:
/// - Workout forgotten reminders (when timer active + app in background)
/// - Inactivity reminders (3/7/14 day sequence)
/// - Insight notifications (PR, streak, volume)
class NotificationScheduler {
  NotificationScheduler({
    required NotificationRepository repository,
    required NotificationMessagePool messagePool,
  })  : _repository = repository,
        _messagePool = messagePool;

  final NotificationRepository _repository;
  final NotificationMessagePool _messagePool;

  // Track active workout forgotten notification (to cancel if user returns)
  String? _activeWorkoutForgottenRecordId;

  // Track current inactivity sequence position
  int? _currentInactivityDay;

  /// Initialize the scheduler
  Future<void> initialize() async {
    await _repository.initialize();
  }

  // ============================================
  // WORKOUT FORGOTTEN
  // ============================================

  /// Schedule a workout forgotten reminder.
  ///
  /// Called when app goes to background with active workout.
  /// Notification fires after [NotificationConfig.workoutForgottenDelay].
  Future<void> scheduleWorkoutForgotten(AppLocalizations l10n) async {
    // Cancel any existing workout forgotten notification
    await cancelWorkoutForgotten();

    // Check if we can send (anti-spam)
    if (!await _repository.canSendNotification(NotificationType.workoutForgotten)) {
      if (kDebugMode) {
        debugPrint('📵 Workout forgotten notification blocked by anti-spam');
      }
      return;
    }

    // Get message with rotation
    final lastKey = await _repository.getLastMessageKey(NotificationType.workoutForgotten);
    final message = _messagePool.getMessage(
      type: NotificationType.workoutForgotten,
      l10n: l10n,
      excludeKey: lastKey,
    );

    // Schedule notification
    final scheduledTime = DateTime.now().add(NotificationConfig.workoutForgottenDelay);
    final recordId = await _repository.scheduleNotification(
      type: NotificationType.workoutForgotten,
      message: message,
      scheduledTime: scheduledTime,
    );

    _activeWorkoutForgottenRecordId = recordId;

    if (kDebugMode) {
      debugPrint('📅 Workout forgotten notification scheduled for $scheduledTime');
    }
  }

  /// Cancel the workout forgotten reminder.
  ///
  /// Called when user returns to the app or completes/saves workout.
  Future<void> cancelWorkoutForgotten() async {
    if (_activeWorkoutForgottenRecordId != null) {
      await _repository.cancelNotification(_activeWorkoutForgottenRecordId!);
      _activeWorkoutForgottenRecordId = null;

      if (kDebugMode) {
        debugPrint('❌ Workout forgotten notification canceled');
      }
    }
  }

  // ============================================
  // INACTIVITY
  // ============================================

  /// Schedule an inactivity reminder.
  ///
  /// Called on app launch if user hasn't worked out recently.
  /// Uses 3/7/14 day sequence with stop-after-ignore.
  Future<void> scheduleInactivityIfNeeded({
    required DateTime? lastWorkoutDate,
    required AppLocalizations l10n,
  }) async {
    if (lastWorkoutDate == null) {
      // No workouts ever - wait for first workout before sending reminders
      return;
    }

    final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inDays;

    // Determine which inactivity day to use
    int? targetDay;
    for (final day in NotificationConfig.inactivitySequence) {
      if (daysSinceLastWorkout >= day) {
        targetDay = day;
      }
    }

    if (targetDay == null) {
      // Not enough days passed for any inactivity notification
      return;
    }

    // Don't resend if we've already sent for this day
    if (targetDay == _currentInactivityDay) {
      return;
    }

    // Check if we can send (anti-spam)
    if (!await _repository.canSendNotification(NotificationType.inactivity)) {
      if (kDebugMode) {
        debugPrint('📵 Inactivity notification blocked by anti-spam');
      }
      return;
    }

    // Get message with rotation
    final lastKey = await _repository.getLastMessageKey(NotificationType.inactivity);
    final message = _messagePool.getMessage(
      type: NotificationType.inactivity,
      l10n: l10n,
      excludeKey: lastKey,
    );

    // Schedule for next morning at 9:00
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      NotificationConfig.defaultScheduleTime.hour,
      NotificationConfig.defaultScheduleTime.minute,
    );

    final recordId = await _repository.scheduleNotification(
      type: NotificationType.inactivity,
      message: message,
      scheduledTime: scheduledTime,
      inactivityDay: targetDay,
    );

    if (recordId != null) {
      _currentInactivityDay = targetDay;
    }

    if (kDebugMode) {
      debugPrint('📅 Inactivity ($targetDay days) notification scheduled for $scheduledTime');
    }
  }

  /// Reset inactivity sequence (called when user completes a workout).
  Future<void> resetInactivitySequence() async {
    _currentInactivityDay = null;
    await _repository.cancelNotificationsByType(NotificationType.inactivity);
    await _repository.resetIgnoreCount(NotificationType.inactivity);

    if (kDebugMode) {
      debugPrint('🔄 Inactivity sequence reset');
    }
  }

  // ============================================
  // INSIGHTS
  // ============================================

  /// Schedule a PR notification.
  ///
  /// Called when a new personal record is detected.
  /// Notification fires after [NotificationConfig.prNotificationDelay] (high value = fast).
  Future<void> schedulePrNotification({
    required String exerciseName,
    required AppLocalizations l10n,
  }) async {
    // Check if we can send (anti-spam)
    if (!await _repository.canSendNotification(NotificationType.insightPr)) {
      if (kDebugMode) {
        debugPrint('📵 PR notification blocked by anti-spam');
      }
      return;
    }

    // Get message with rotation and exercise name
    final lastKey = await _repository.getLastMessageKey(NotificationType.insightPr);
    final message = _messagePool.getMessage(
      type: NotificationType.insightPr,
      l10n: l10n,
      excludeKey: lastKey,
      params: {'exerciseName': exerciseName},
    );

    // Schedule with short delay (high value notification)
    final scheduledTime = DateTime.now().add(NotificationConfig.prNotificationDelay);
    await _repository.scheduleNotification(
      type: NotificationType.insightPr,
      message: message,
      scheduledTime: scheduledTime,
      context: exerciseName,
    );

    if (kDebugMode) {
      debugPrint('📅 PR notification for "$exerciseName" scheduled for $scheduledTime');
    }
  }

  /// Schedule a streak milestone notification.
  ///
  /// Called when user reaches a streak milestone (7, 14, 30 days).
  /// Notification fires next morning (low value = batched).
  Future<void> scheduleStreakNotification({
    required int streakDays,
    required AppLocalizations l10n,
  }) async {
    // Only notify on milestones
    if (!NotificationConfig.isStreakMilestone(streakDays)) {
      return;
    }

    // Check if we can send (anti-spam)
    if (!await _repository.canSendNotification(NotificationType.insightStreak)) {
      if (kDebugMode) {
        debugPrint('📵 Streak notification blocked by anti-spam');
      }
      return;
    }

    // Get message with rotation and streak count
    final lastKey = await _repository.getLastMessageKey(NotificationType.insightStreak);
    final message = _messagePool.getMessage(
      type: NotificationType.insightStreak,
      l10n: l10n,
      excludeKey: lastKey,
      params: {'streakDays': streakDays},
    );

    // Schedule for next morning (low value = batched)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      NotificationConfig.defaultScheduleTime.hour,
      NotificationConfig.defaultScheduleTime.minute,
    );

    await _repository.scheduleNotification(
      type: NotificationType.insightStreak,
      message: message,
      scheduledTime: scheduledTime,
      context: streakDays.toString(),
    );

    if (kDebugMode) {
      debugPrint('📅 Streak ($streakDays days) notification scheduled for $scheduledTime');
    }
  }

  /// Schedule a volume increase notification.
  ///
  /// Called when weekly volume increases by >= 20%.
  /// Notification fires next morning (low value = batched).
  Future<void> scheduleVolumeNotification({
    required int volumePercentIncrease,
    required AppLocalizations l10n,
  }) async {
    // Only notify if increase is significant
    if (volumePercentIncrease < (NotificationConfig.volumeIncreaseThreshold * 100).round()) {
      return;
    }

    // Check if we can send (anti-spam)
    if (!await _repository.canSendNotification(NotificationType.insightVolume)) {
      if (kDebugMode) {
        debugPrint('📵 Volume notification blocked by anti-spam');
      }
      return;
    }

    // Get message with rotation and volume percent
    final lastKey = await _repository.getLastMessageKey(NotificationType.insightVolume);
    final message = _messagePool.getMessage(
      type: NotificationType.insightVolume,
      l10n: l10n,
      excludeKey: lastKey,
      params: {'volumePercent': volumePercentIncrease},
    );

    // Schedule for next morning (low value = batched)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      NotificationConfig.defaultScheduleTime.hour,
      NotificationConfig.defaultScheduleTime.minute,
    );

    await _repository.scheduleNotification(
      type: NotificationType.insightVolume,
      message: message,
      scheduledTime: scheduledTime,
      context: volumePercentIncrease.toString(),
    );

    if (kDebugMode) {
      debugPrint('📅 Volume (+$volumePercentIncrease%) notification scheduled for $scheduledTime');
    }
  }

  // ============================================
  // UTILITY
  // ============================================

  /// Get current notification stats summary
  Future<Map<NotificationType, int>> getStatsSummary() async {
    final stats = <NotificationType, int>{};
    for (final type in NotificationType.values) {
      final typeStats = await _repository.getNotificationStats(type);
      stats[type] = typeStats.totalSent;
    }
    return stats;
  }

  /// Get weekly notification count
  Future<int> getWeeklyCount() async {
    return _repository.getWeeklyNotificationCount();
  }

  /// Close the scheduler
  Future<void> close() async {
    await _repository.close();
  }
}
