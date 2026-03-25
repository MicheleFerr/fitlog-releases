import 'package:flutter/material.dart';

/// Additional context shown when a template is opened from a scheduled workout
/// reminder notification.
class ScheduledWorkoutNotificationHighlight {
  const ScheduledWorkoutNotificationHighlight({
    required this.scheduledWorkoutId,
    required this.scheduledDate,
    required this.reminderHour,
    required this.reminderMinute,
  });

  final String scheduledWorkoutId;
  final DateTime scheduledDate;
  final int reminderHour;
  final int reminderMinute;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return scheduledDate.year == tomorrow.year &&
        scheduledDate.month == tomorrow.month &&
        scheduledDate.day == tomorrow.day;
  }

  static ScheduledWorkoutNotificationHighlight? fromUri(Uri uri) {
    if (uri.queryParameters['source'] != 'notification') {
      return null;
    }

    final scheduledWorkoutId = uri.queryParameters['scheduledWorkoutId'];
    final scheduledDateRaw = uri.queryParameters['scheduledDate'];
    final reminderHour = int.tryParse(
      uri.queryParameters['reminderHour'] ?? '',
    );
    final reminderMinute = int.tryParse(
      uri.queryParameters['reminderMinute'] ?? '',
    );

    if (scheduledWorkoutId == null ||
        scheduledWorkoutId.isEmpty ||
        scheduledDateRaw == null ||
        reminderHour == null ||
        reminderMinute == null) {
      return null;
    }

    final scheduledDate = DateTime.tryParse(scheduledDateRaw);
    if (scheduledDate == null) {
      return null;
    }

    return ScheduledWorkoutNotificationHighlight(
      scheduledWorkoutId: scheduledWorkoutId,
      scheduledDate: scheduledDate,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );
  }
}
