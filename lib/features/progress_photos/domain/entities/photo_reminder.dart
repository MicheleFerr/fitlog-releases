/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/progress_photos/domain/entities
/// Feature: Photo Reminders
/// Type: Entity - Photo Reminder Settings
///
/// Configurable reminder settings for progress photo capture.
/// Based on competitor analysis:
/// - Hevy recommends: photos every 4-5 weeks (not weekly - changes too small)
/// - UX best practice: gentle tone, anti-spam after consecutive ignores
library;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_reminder.freezed.dart';
part 'photo_reminder.g.dart';

/// Reminder frequency options based on research
/// Hevy recommends 4-5 weeks as optimal frequency for visible changes
enum PhotoReminderFrequency {
  /// Every 2 weeks - for users who want frequent tracking
  biweekly,

  /// Every 4 weeks - recommended by Hevy for optimal visibility
  monthly,

  /// Every 6 weeks - for users who prefer less frequent reminders
  sixWeeks,

  /// Custom interval in days
  custom,
}

/// Extension for PhotoReminderFrequency display and logic
extension PhotoReminderFrequencyExtension on PhotoReminderFrequency {
  /// Days between reminders for each frequency
  int get days => switch (this) {
    PhotoReminderFrequency.biweekly => 14,
    PhotoReminderFrequency.monthly => 28, // 4 weeks (Hevy recommendation)
    PhotoReminderFrequency.sixWeeks => 42,
    PhotoReminderFrequency.custom => 28, // Default for custom
  };

  /// Localization key suffix
  String get labelKey => switch (this) {
    PhotoReminderFrequency.biweekly => 'everyTwoWeeks',
    PhotoReminderFrequency.monthly => 'everyFourWeeks',
    PhotoReminderFrequency.sixWeeks => 'everySixWeeks',
    PhotoReminderFrequency.custom => 'customInterval',
  };

  /// Whether this is the recommended frequency
  bool get isRecommended => this == PhotoReminderFrequency.monthly;
}

/// User's photo reminder preferences
@freezed
abstract class PhotoReminderSettings with _$PhotoReminderSettings {

  const factory PhotoReminderSettings({
    /// Whether reminders are enabled
    @Default(false) bool isEnabled,

    /// Selected frequency
    @Default(PhotoReminderFrequency.monthly) PhotoReminderFrequency frequency,

    /// Custom interval in days (used when frequency == custom)
    @Default(28) int customIntervalDays,

    /// Preferred reminder time (hour component)
    @Default(9) int reminderHour,

    /// Preferred reminder time (minute component)
    @Default(0) int reminderMinute,

    /// Whether to include specific pose suggestions in reminder
    @Default(true) bool suggestPose,

    /// Last reminder sent timestamp
    DateTime? lastReminderSent,

    /// Next scheduled reminder timestamp
    DateTime? nextReminderScheduled,

    /// Notification ID for cancellation
    int? notificationId,

    /// Anti-spam: consecutive ignores count
    @Default(0) int consecutiveIgnores,

    /// Anti-spam: max ignores before auto-disable (0 = no limit)
    @Default(3) int maxIgnoresBeforeDisable,

    /// Whether user manually disabled after too many ignores
    @Default(false) bool disabledByAntiSpam,
  }) = _PhotoReminderSettings;

  /// Create default settings (disabled by default - opt-in)
  factory PhotoReminderSettings.defaults() => const PhotoReminderSettings();

  /// Create enabled settings with recommended frequency
  factory PhotoReminderSettings.recommended({int hour = 9, int minute = 0}) =>
      PhotoReminderSettings(
        isEnabled: true,
        frequency: PhotoReminderFrequency.monthly,
        reminderHour: hour,
        reminderMinute: minute,
      );
  const PhotoReminderSettings._();

  factory PhotoReminderSettings.fromJson(Map<String, dynamic> json) =>
      _$PhotoReminderSettingsFromJson(json);

  /// Get reminder time as TimeOfDay
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// Get effective interval in days
  int get effectiveIntervalDays => frequency == PhotoReminderFrequency.custom
      ? customIntervalDays
      : frequency.days;

  /// Calculate next reminder date from a given date
  DateTime calculateNextReminder(DateTime from) {
    final nextDate = from.add(Duration(days: effectiveIntervalDays));
    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      reminderHour,
      reminderMinute,
    );
  }

  /// Whether anti-spam should disable reminders
  bool get shouldDisableForAntiSpam =>
      maxIgnoresBeforeDisable > 0 &&
      consecutiveIgnores >= maxIgnoresBeforeDisable;

  /// Formatted reminder time string (HH:MM)
  String get formattedReminderTime {
    final hour = reminderHour.toString().padLeft(2, '0');
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Record of a sent photo reminder for tracking
@freezed
abstract class PhotoReminderRecord with _$PhotoReminderRecord {

  const factory PhotoReminderRecord({
    /// Unique identifier
    required String id,

    /// When the reminder was sent
    required DateTime sentAt,

    /// When the reminder was opened/acted upon (null if not)
    DateTime? openedAt,

    /// When a photo was taken in response (null if not)
    DateTime? photoTakenAt,

    /// Message variation used (for rotation tracking)
    required int messageVariation,

    /// Whether this reminder was canceled before delivery
    @Default(false) bool wasCanceled,
  }) = _PhotoReminderRecord;
  const PhotoReminderRecord._();

  factory PhotoReminderRecord.fromJson(Map<String, dynamic> json) =>
      _$PhotoReminderRecordFromJson(json);

  /// Whether the reminder was opened
  bool get wasOpened => openedAt != null;

  /// Whether a photo was taken after this reminder
  bool get photoWasTaken => photoTakenAt != null;

  /// Whether this reminder was successful (led to photo)
  bool get wasSuccessful => photoWasTaken;

  /// Whether this reminder was ignored
  bool get wasIgnored => !wasCanceled && openedAt == null;
}
