import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scheduled_workout.freezed.dart';
part 'scheduled_workout.g.dart';

/// Status of a scheduled workout
enum ScheduleStatus {
  /// Scheduled but not yet due
  pending,

  /// It's workout day (due today)
  due,

  /// Workout was completed
  completed,

  /// User skipped this scheduled workout
  skipped,

  /// Day passed without completing the workout
  missed,
}

/// Extension to get display properties for ScheduleStatus
extension ScheduleStatusExtension on ScheduleStatus {
  bool get isActionable =>
      this == ScheduleStatus.pending || this == ScheduleStatus.due;
  bool get isCompleted => this == ScheduleStatus.completed;
  bool get isPast =>
      this == ScheduleStatus.completed ||
      this == ScheduleStatus.skipped ||
      this == ScheduleStatus.missed;
}

/// Represents a workout scheduled for a specific date
@freezed
abstract class ScheduledWorkout with _$ScheduledWorkout {

  const factory ScheduledWorkout({
    /// Unique identifier
    required String id,

    /// ID of the template this workout is based on
    required String templateId,

    /// Name of the template (cached for display)
    required String templateName,

    /// Date when the workout is scheduled
    required DateTime scheduledDate,

    /// Hour component of reminder time (0-23)
    required int reminderHour,

    /// Minute component of reminder time (0-59)
    required int reminderMinute,

    /// Current status of the scheduled workout
    @Default(ScheduleStatus.pending) ScheduleStatus status,

    /// When the workout was completed (if applicable)
    DateTime? completedAt,

    /// When this schedule was created
    DateTime? createdAt,

    /// ID of the notification scheduled for this workout (for cancellation)
    String? notificationId,
  }) = _ScheduledWorkout;

  /// Create a new ScheduledWorkout with current date/time as createdAt
  factory ScheduledWorkout.create({
    required String id,
    required String templateId,
    required String templateName,
    required DateTime scheduledDate,
    required TimeOfDay reminderTime,
  }) {
    return ScheduledWorkout(
      id: id,
      templateId: templateId,
      templateName: templateName,
      scheduledDate: DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      ),
      reminderHour: reminderTime.hour,
      reminderMinute: reminderTime.minute,
      status: ScheduleStatus.pending,
      createdAt: DateTime.now(),
    );
  }
  const ScheduledWorkout._();

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) =>
      _$ScheduledWorkoutFromJson(json);

  /// Get reminder time as TimeOfDay
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// Check if this workout is scheduled for today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  /// Check if this workout is scheduled for tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return scheduledDate.year == tomorrow.year &&
        scheduledDate.month == tomorrow.month &&
        scheduledDate.day == tomorrow.day;
  }

  /// Check if the scheduled date is in the past
  bool get isPastDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );
    return scheduled.isBefore(today);
  }

  /// Get the full DateTime for the reminder (scheduled date + reminder time)
  DateTime get reminderDateTime => DateTime(
    scheduledDate.year,
    scheduledDate.month,
    scheduledDate.day,
    reminderHour,
    reminderMinute,
  );

  /// Formatted reminder time string (HH:MM)
  String get formattedReminderTime {
    final hour = reminderHour.toString().padLeft(2, '0');
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
