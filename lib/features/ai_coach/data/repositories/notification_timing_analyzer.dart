/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository
///
/// Notification Timing Analyzer - Predicts optimal notification times
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

/// Analyzes user behavior to predict optimal notification timing
///
/// Features:
/// - Analyzes app open history (last 30 days)
/// - Predicts top 3 optimal notification times
/// - Respects Do Not Disturb periods
/// - Adapts frequency based on experience level
/// - Tracks dismissal rate per insight type
///
/// Algorithm:
/// 1. Cluster app open times into 3-hour windows
/// 2. Select top 3 windows by frequency
/// 3. Apply user preferences (DND, frequency limits)
/// 4. Filter out insight types with >70% dismissal rate
class NotificationTimingAnalyzer {
  /// Default optimal times (used when no history available)
  static const List<int> defaultOptimalHours = [7, 11, 19]; // 7am, 11am, 7pm

  /// Maximum notifications per week by experience level
  static const Map<ExperienceLevel, int> maxNotificationsPerWeek = {
    ExperienceLevel.beginner: 2, // Less experienced = fewer notifications
    ExperienceLevel.intermediate: 3,
    ExperienceLevel.advanced: 4, // More experienced = more technical insights
  };

  /// Dismissal rate threshold (stop sending if exceeded)
  static const double dismissalRateThreshold = 0.7; // 70%

  /// Analyze user's app open history and return optimal notification hours
  ///
  /// Returns list of 3 hours (24-hour format) sorted by predicted engagement
  ///
  /// Example: [7, 12, 19] means 7am, 12pm, 7pm are optimal times
  List<int> predictOptimalNotificationTimes({
    List<DateTime>? appOpenHistory,
    List<int>? doNotDisturbHours,
  }) {
    // If no history, return defaults (filtered by DND)
    if (appOpenHistory == null || appOpenHistory.isEmpty) {
      return _filterByDoNotDisturb(
        defaultOptimalHours,
        doNotDisturbHours ?? [],
      );
    }

    // Analyze history: count opens per hour
    final hourCounts = <int, int>{};
    for (final openTime in appOpenHistory) {
      final hour = openTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Get top 3 hours by frequency
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topHours = sortedHours.take(3).map((e) => e.key).toList();

    // Filter by DND hours
    final filtered = _filterByDoNotDisturb(
      topHours,
      doNotDisturbHours ?? [],
    );

    // If filtering removed too many, fill with defaults
    while (filtered.length < 3) {
      for (final hour in defaultOptimalHours) {
        if (!filtered.contains(hour) &&
            !(doNotDisturbHours ?? []).contains(hour)) {
          filtered.add(hour);
          if (filtered.length >= 3) break;
        }
      }
      break; // Avoid infinite loop
    }

    return filtered.take(3).toList();
  }

  /// Calculate recommended notification frequency for experience level
  int getRecommendedFrequencyPerWeek(ExperienceLevel level) {
    return maxNotificationsPerWeek[level] ?? 3; // Default to intermediate
  }

  /// Check if insight type should be sent based on dismissal rate
  ///
  /// Returns false if dismissal rate exceeds threshold (70%)
  bool shouldSendInsightType({
    required String insightType,
    required int totalSent,
    required int totalDismissed,
  }) {
    if (totalSent == 0) return true; // No history, send it

    final dismissalRate = totalDismissed / totalSent;
    return dismissalRate < dismissalRateThreshold;
  }

  /// Generate notification content based on experience level
  ///
  /// - Beginner: Motivational and encouraging
  /// - Intermediate: Balanced technical + motivational
  /// - Advanced: Technical and detailed
  String generateNotificationContent({
    required ExperienceLevel level,
    required String insightTitle,
    required String insightType,
  }) {
    switch (level) {
      case ExperienceLevel.beginner:
        // Motivational style
        return '🔥 $insightTitle';

      case ExperienceLevel.intermediate:
        // Balanced style
        return '💪 $insightTitle';

      case ExperienceLevel.advanced:
        // Technical style
        return '📊 [$insightType] $insightTitle';
    }
  }

  /// Check if notification should be sent now
  ///
  /// Considers:
  /// - Current time vs optimal times (±1 hour tolerance)
  /// - Weekly frequency limit
  /// - Last notification time (minimum 24h gap)
  bool shouldSendNotificationNow({
    required DateTime now,
    required List<int> optimalHours,
    required int notificationsSentThisWeek,
    required int maxPerWeek,
    DateTime? lastNotificationTime,
  }) {
    // Check frequency limit
    if (notificationsSentThisWeek >= maxPerWeek) {
      return false;
    }

    // Check minimum gap (24 hours)
    if (lastNotificationTime != null) {
      final hoursSinceLastNotification =
          now.difference(lastNotificationTime).inHours;
      if (hoursSinceLastNotification < 24) {
        return false;
      }
    }

    // Check if current hour is within ±1 hour of optimal times
    final currentHour = now.hour;
    for (final optimalHour in optimalHours) {
      if ((currentHour - optimalHour).abs() <= 1) {
        return true;
      }
    }

    return false;
  }

  /// Filter hours by removing Do Not Disturb periods
  List<int> _filterByDoNotDisturb(
    List<int> hours,
    List<int> dndHours,
  ) {
    return hours.where((hour) => !dndHours.contains(hour)).toList();
  }

  /// Calculate dismissal rate for insight type
  double calculateDismissalRate({
    required int totalSent,
    required int totalDismissed,
  }) {
    if (totalSent == 0) return 0.0;
    return totalDismissed / totalSent;
  }

  /// Get notification frequency description for UI
  String getFrequencyDescription(
    ExperienceLevel level,
    String Function(int) localizedDescriptionFn,
  ) {
    final perWeek = getRecommendedFrequencyPerWeek(level);
    return localizedDescriptionFn(perWeek);
  }
}
