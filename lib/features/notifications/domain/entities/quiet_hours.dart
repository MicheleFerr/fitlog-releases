/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/entities
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// QUIET HOURS ENTITY - Per-category notification quiet hours
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiet_hours.freezed.dart';
part 'quiet_hours.g.dart';

/// Quiet hours configuration for notification suppression
///
/// Supports per-category quiet hours (e.g., workout reminders quiet 22:00-08:00,
/// but achievement notifications allowed)
@freezed
class QuietHours with _$QuietHours {
  const factory QuietHours({
    /// Start time (hour component 0-23, minute component 0-59)
    /// Example: DateTime(2024, 1, 1, 22, 0) = 22:00
    required DateTime startTime,

    /// End time (hour component 0-23, minute component 0-59)
    /// Example: DateTime(2024, 1, 1, 8, 0) = 08:00
    /// Note: If end < start, assumes overnight (e.g., 22:00 - 08:00)
    required DateTime endTime,

    /// Allow high-priority notifications to bypass quiet hours
    /// Default: true (critical alerts always allowed)
    @Default(true) bool allowPriorityBypass,

    /// Days of week when quiet hours apply (1=Monday, 7=Sunday)
    /// Empty list = applies every day
    /// Example: [1,2,3,4,5] = weekdays only
    @Default([]) List<int> daysOfWeek,
  }) = _QuietHours;

  factory QuietHours.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursFromJson(json);
}

/// Extension for QuietHours operations
extension QuietHoursExtensions on QuietHours {
  /// Check if given time is within quiet hours
  bool isTimeInQuietHours(DateTime time) {
    // Check if day of week matches (if specified)
    if (daysOfWeek.isNotEmpty) {
      final dayOfWeek = time.weekday; // 1=Monday, 7=Sunday
      if (!daysOfWeek.contains(dayOfWeek)) {
        return false; // Quiet hours don't apply on this day
      }
    }

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Handle overnight quiet hours (e.g., 22:00 - 08:00)
    if (startMinutes > endMinutes) {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }

    // Normal quiet hours (e.g., 12:00 - 14:00)
    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  /// Adjust notification time to avoid quiet hours
  /// Returns adjusted time (moved to end of quiet hours) or original time if not in quiet hours
  DateTime adjustTimeToAvoidQuietHours(DateTime scheduledTime) {
    if (!isTimeInQuietHours(scheduledTime)) {
      return scheduledTime; // Not in quiet hours, no adjustment needed
    }

    // Move to end of quiet hours
    return DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      endTime.hour,
      endTime.minute,
    );
  }

  /// Get duration of quiet hours window
  Duration get duration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes > endMinutes) {
      // Overnight: 24h - start + end
      return Duration(minutes: (24 * 60) - startMinutes + endMinutes);
    }

    return Duration(minutes: endMinutes - startMinutes);
  }

  /// Check if quiet hours span overnight (e.g., 22:00 - 08:00)
  bool get isOvernight {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return startMinutes > endMinutes;
  }

  /// Format quiet hours as human-readable string
  /// Example: "22:00 - 08:00 (weekdays)"
  String toDisplayString() {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    final daysStr = daysOfWeek.isEmpty
        ? 'every day'
        : daysOfWeek.length == 7
            ? 'every day'
            : daysOfWeek.length == 5 && daysOfWeek.every((d) => d <= 5)
                ? 'weekdays'
                : daysOfWeek.length == 2 && daysOfWeek.contains(6) && daysOfWeek.contains(7)
                    ? 'weekends'
                    : _formatDaysOfWeek(daysOfWeek);

    return '$start - $end ($daysStr)';
  }

  String _formatDaysOfWeek(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }
}

/// Preset quiet hours configurations
class QuietHoursPresets {
  /// Standard overnight quiet hours (22:00 - 08:00, every day)
  static QuietHours overnight() => QuietHours(
        startTime: DateTime(2024, 1, 1, 22, 0),
        endTime: DateTime(2024, 1, 1, 8, 0),
        allowPriorityBypass: true,
        daysOfWeek: const [],
      );

  /// Weekday work hours quiet (09:00 - 17:00, Mon-Fri)
  static QuietHours workHours() => QuietHours(
        startTime: DateTime(2024, 1, 1, 9, 0),
        endTime: DateTime(2024, 1, 1, 17, 0),
        allowPriorityBypass: false,
        daysOfWeek: const [1, 2, 3, 4, 5], // Mon-Fri
      );

  /// Weekend quiet hours (10:00 - 12:00, Sat-Sun)
  static QuietHours weekendMorning() => QuietHours(
        startTime: DateTime(2024, 1, 1, 10, 0),
        endTime: DateTime(2024, 1, 1, 12, 0),
        allowPriorityBypass: true,
        daysOfWeek: const [6, 7], // Sat-Sun
      );

  /// Afternoon siesta (13:00 - 15:00, every day)
  static QuietHours siesta() => QuietHours(
        startTime: DateTime(2024, 1, 1, 13, 0),
        endTime: DateTime(2024, 1, 1, 15, 0),
        allowPriorityBypass: false,
        daysOfWeek: const [],
      );

  /// No quiet hours (24/7 notifications allowed)
  static QuietHours none() => QuietHours(
        startTime: DateTime(2024, 1, 1, 0, 0),
        endTime: DateTime(2024, 1, 1, 0, 0),
        allowPriorityBypass: true,
        daysOfWeek: const [],
      );
}
