import 'package:gymbro_flutter_new/features/notifications/domain/entities/schedule_result.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/usecases/check_notification_rules.dart';

/// Schedules workout reminder notifications at optimal times
///
/// Determines WHEN to send notifications based on:
/// - User's preferred notification hour (e.g., 6 PM)
/// - Whether notification rules allow sending (via CheckNotificationRules)
/// - Current time (schedule for today or tomorrow)
///
/// Part of P3 habit formation (+15-20% stickiness improvement)
/// Evidence: Consistent timing creates habit anchors
class ScheduleWorkoutReminders {
  ScheduleWorkoutReminders() : _rulesEngine = CheckNotificationRules();

  final CheckNotificationRules _rulesEngine;

  ScheduleResult execute({
    required DateTime lastWorkoutDate,
    required DateTime? lastNotificationDate,
    required DateTime currentTime,
    required int preferredNotificationHour,
  }) {
    // First, check if notification rules allow sending
    final decision = _rulesEngine.execute(
      lastWorkoutDate: lastWorkoutDate,
      lastNotificationDate: lastNotificationDate,
      currentDate: currentTime,
    );

    // If rules say NO, don't schedule
    if (!decision.shouldNotify) {
      return ScheduleResult(
        shouldSchedule: false,
        scheduledTime: currentTime, // Dummy value (not used)
        reason: decision.reason,
      );
    }

    // Rules say YES - calculate WHEN to schedule
    DateTime scheduledTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      preferredNotificationHour,
      0, // minute
    );

    // If preferred time already passed today, schedule for tomorrow
    if (currentTime.hour >= preferredNotificationHour) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return ScheduleResult(
      shouldSchedule: true,
      scheduledTime: scheduledTime,
      reason: decision.reason,
    );
  }
}
