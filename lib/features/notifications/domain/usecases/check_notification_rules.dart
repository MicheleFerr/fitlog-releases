import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_decision.dart';

/// Intelligent notification rules engine (no AI, transparent logic)
///
/// Determines if user should receive workout reminder notification
/// Rules designed to maximize habit formation while avoiding spam
///
/// Business Rules:
/// 1. NO notification if user already worked out today
/// 2. NO notification if already notified today (prevent spam)
/// 3. YES notification if 48+ hours since last workout (gentle nudge)
/// 4. YES notification if no recent workout (>72 hours)
///
/// Part of P3 (+15-20% stickiness improvement)
/// Evidence: Smart timing reduces annoyance, improves compliance
class CheckNotificationRules {
  NotificationDecision execute({
    required DateTime lastWorkoutDate,
    required DateTime? lastNotificationDate,
    required DateTime currentDate,
  }) {
    // Rule 1: Already worked out today → NO notification (user is active!)
    if (_isSameDay(lastWorkoutDate, currentDate)) {
      return const NotificationDecision(
        shouldNotify: false,
        reason: 'Already worked out today - no need to remind',
      );
    }

    // Rule 2: Already notified today → NO notification (prevent spam)
    if (lastNotificationDate != null &&
        _isSameDay(lastNotificationDate, currentDate)) {
      return const NotificationDecision(
        shouldNotify: false,
        reason: 'Already notified today - avoid spamming user',
      );
    }

    final hoursSinceWorkout = currentDate.difference(lastWorkoutDate).inHours;

    // Rule 3: 48+ hours since workout → YES notification (gentle nudge)
    if (hoursSinceWorkout >= 48) {
      return const NotificationDecision(
        shouldNotify: true,
        reason: '48+ hours since last workout - time for a gentle reminder',
      );
    }

    // Rule 4: Less than 48 hours → NO notification (give user time)
    return const NotificationDecision(
      shouldNotify: false,
      reason: 'Less than 48 hours since workout - let user rest',
    );
  }

  /// Check if two dates are on the same calendar day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
