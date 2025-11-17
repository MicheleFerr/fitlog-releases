/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/entities
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FREQUENCY CAP ENTITY - Research-backed notification frequency limits
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'frequency_cap.freezed.dart';
part 'frequency_cap.g.dart';

/// Frequency cap configuration for notification throttling
///
/// Research-backed defaults:
/// - maxPerWeek: 5 (64% quit risk if exceeded - Localytics 2017)
/// - maxPerDay: 3 (prevents notification fatigue)
/// - minIntervalHours: 2 (prevents spam within same day)
@freezed
class FrequencyCap with _$FrequencyCap {
  const factory FrequencyCap({
    /// Maximum notifications per day
    /// Default: 3
    /// Range: 1-10
    @Default(3) int maxPerDay,

    /// Maximum notifications per week
    /// Default: 5 (research-backed optimal)
    /// Research: >5/week → 64% quit risk (Localytics 2017)
    @Default(5) int maxPerWeek,

    /// Minimum hours between notifications
    /// Default: 2 hours
    /// Prevents spam within same day
    @Default(2) int minIntervalHours,
  }) = _FrequencyCap;

  factory FrequencyCap.fromJson(Map<String, dynamic> json) =>
      _$FrequencyCapFromJson(json);
}

/// Extension for FrequencyCap operations
extension FrequencyCapExtensions on FrequencyCap {
  /// Validate frequency cap values are within acceptable ranges
  bool get isValid {
    return maxPerDay >= 1 &&
        maxPerDay <= 10 &&
        maxPerWeek >= 1 &&
        maxPerWeek <= 20 &&
        minIntervalHours >= 1 &&
        minIntervalHours <= 24;
  }

  /// Check if maxPerWeek exceeds research-backed limit
  /// Research: >5/week → 64% quit risk
  bool get exceedsResearchLimit => maxPerWeek > 5;

  /// Get recommended adjustment if exceeds research limit
  FrequencyCap get recommendedAdjustment {
    if (!exceedsResearchLimit) return this;

    return copyWith(
      maxPerWeek: 5, // Research-backed optimal
      maxPerDay: maxPerDay > 3 ? 3 : maxPerDay,
    );
  }

  /// Calculate if notification would exceed daily cap
  bool wouldExceedDailyLimit(int notificationsSentToday) {
    return notificationsSentToday >= maxPerDay;
  }

  /// Calculate if notification would exceed weekly cap
  bool wouldExceedWeeklyLimit(int notificationsSentThisWeek) {
    return notificationsSentThisWeek >= maxPerWeek;
  }

  /// Calculate hours until next notification allowed
  Duration? timeUntilNextAllowed(DateTime? lastNotificationTime) {
    if (lastNotificationTime == null) return Duration.zero;

    final now = DateTime.now();
    final hoursSinceLastNotification = now.difference(lastNotificationTime).inHours;

    if (hoursSinceLastNotification >= minIntervalHours) {
      return Duration.zero; // Can send now
    }

    final hoursRemaining = minIntervalHours - hoursSinceLastNotification;
    return Duration(hours: hoursRemaining);
  }
}

/// Preset frequency cap configurations
class FrequencyCapPresets {
  /// Conservative (minimal notifications)
  /// 2/day, 3/week, 4h interval
  static const FrequencyCap conservative = FrequencyCap(
    maxPerDay: 2,
    maxPerWeek: 3,
    minIntervalHours: 4,
  );

  /// Balanced (research-backed optimal)
  /// 3/day, 5/week, 2h interval
  static const FrequencyCap balanced = FrequencyCap(
    maxPerDay: 3,
    maxPerWeek: 5,
    minIntervalHours: 2,
  );

  /// Aggressive (high engagement users)
  /// 5/day, 7/week, 1h interval
  /// ⚠️ WARNING: Exceeds research limit (64% quit risk)
  static const FrequencyCap aggressive = FrequencyCap(
    maxPerDay: 5,
    maxPerWeek: 7,
    minIntervalHours: 1,
  );

  /// Minimal (only critical notifications)
  /// 1/day, 2/week, 6h interval
  static const FrequencyCap minimal = FrequencyCap(
    maxPerDay: 1,
    maxPerWeek: 2,
    minIntervalHours: 6,
  );
}
