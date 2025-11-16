/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Smart Notifications Provider - Manages AI Coach notification scheduling
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/notification_timing_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

/// Notification preferences state
class NotificationPreferences {
  const NotificationPreferences({
    required this.enabled,
    required this.optimalHours,
    required this.maxPerWeek,
    this.doNotDisturbHours = const [],
    this.enabledInsightTypes = const [],
  });

  final bool enabled;
  final List<int> optimalHours; // 24-hour format
  final int maxPerWeek;
  final List<int> doNotDisturbHours; // Hours when notifications are blocked
  final List<String> enabledInsightTypes; // Empty = all enabled

  NotificationPreferences copyWith({
    bool? enabled,
    List<int>? optimalHours,
    int? maxPerWeek,
    List<int>? doNotDisturbHours,
    List<String>? enabledInsightTypes,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      optimalHours: optimalHours ?? this.optimalHours,
      maxPerWeek: maxPerWeek ?? this.maxPerWeek,
      doNotDisturbHours: doNotDisturbHours ?? this.doNotDisturbHours,
      enabledInsightTypes: enabledInsightTypes ?? this.enabledInsightTypes,
    );
  }
}

/// Notification statistics for dismissal rate tracking
class NotificationStats {
  const NotificationStats({
    required this.insightType,
    required this.totalSent,
    required this.totalDismissed,
    required this.totalOpened,
  });

  final String insightType;
  final int totalSent;
  final int totalDismissed;
  final int totalOpened;

  double get dismissalRate =>
      totalSent == 0 ? 0.0 : totalDismissed / totalSent;
  double get openRate => totalSent == 0 ? 0.0 : totalOpened / totalSent;

  NotificationStats copyWith({
    String? insightType,
    int? totalSent,
    int? totalDismissed,
    int? totalOpened,
  }) {
    return NotificationStats(
      insightType: insightType ?? this.insightType,
      totalSent: totalSent ?? this.totalSent,
      totalDismissed: totalDismissed ?? this.totalDismissed,
      totalOpened: totalOpened ?? this.totalOpened,
    );
  }
}

/// Smart Notifications State Manager
///
/// Handles:
/// - Notification scheduling based on behavioral timing
/// - Dismissal rate tracking
/// - User preferences (frequency, DND, types)
/// - Content personalization by experience level
class SmartNotificationsNotifier
    extends StateNotifier<NotificationPreferences> {
  SmartNotificationsNotifier(this._analyzer, this._experienceLevel)
      : super(
          NotificationPreferences(
            enabled: true,
            optimalHours: NotificationTimingAnalyzer.defaultOptimalHours,
            maxPerWeek: NotificationTimingAnalyzer.maxNotificationsPerWeek[
                    _experienceLevel] ??
                3,
          ),
        );

  final NotificationTimingAnalyzer _analyzer;
  final ExperienceLevel _experienceLevel;

  /// Statistics per insight type
  final Map<String, NotificationStats> _stats = {};

  /// App open history (last 30 days)
  final List<DateTime> _appOpenHistory = [];

  /// Last notification sent time
  DateTime? _lastNotificationTime;

  /// Notifications sent this week
  int _notificationsSentThisWeek = 0;

  /// Enable/disable notifications
  void setEnabled(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  /// Update Do Not Disturb hours
  void setDoNotDisturbHours(List<int> hours) {
    state = state.copyWith(doNotDisturbHours: hours);
    _updateOptimalTimes();
  }

  /// Enable/disable specific insight types
  void setEnabledInsightTypes(List<String> types) {
    state = state.copyWith(enabledInsightTypes: types);
  }

  /// Record app open for timing analysis
  void recordAppOpen(DateTime time) {
    _appOpenHistory.add(time);

    // Keep only last 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    _appOpenHistory.removeWhere((t) => t.isBefore(thirtyDaysAgo));

    // Update optimal times after collecting enough data
    if (_appOpenHistory.length >= 10) {
      _updateOptimalTimes();
    }
  }

  /// Record notification sent
  void recordNotificationSent(String insightType) {
    _lastNotificationTime = DateTime.now();
    _notificationsSentThisWeek++;

    // Update stats
    final currentStats = _stats[insightType] ??
        const NotificationStats(
          insightType: '',
          totalSent: 0,
          totalDismissed: 0,
          totalOpened: 0,
        );

    _stats[insightType] = currentStats.copyWith(
      totalSent: currentStats.totalSent + 1,
    );
  }

  /// Record notification dismissed
  void recordNotificationDismissed(String insightType) {
    final currentStats = _stats[insightType];
    if (currentStats == null) return;

    _stats[insightType] = currentStats.copyWith(
      totalDismissed: currentStats.totalDismissed + 1,
    );

    // Check if dismissal rate exceeded threshold
    if (!_analyzer.shouldSendInsightType(
      insightType: insightType,
      totalSent: currentStats.totalSent,
      totalDismissed: currentStats.totalDismissed + 1,
    )) {
      // Auto-disable this insight type
      final enabledTypes = List<String>.from(state.enabledInsightTypes);
      enabledTypes.remove(insightType);
      setEnabledInsightTypes(enabledTypes);
    }
  }

  /// Record notification opened
  void recordNotificationOpened(String insightType) {
    final currentStats = _stats[insightType];
    if (currentStats == null) return;

    _stats[insightType] = currentStats.copyWith(
      totalOpened: currentStats.totalOpened + 1,
    );
  }

  /// Check if notification should be sent now
  bool shouldSendNotificationNow() {
    if (!state.enabled) return false;

    return _analyzer.shouldSendNotificationNow(
      now: DateTime.now(),
      optimalHours: state.optimalHours,
      notificationsSentThisWeek: _notificationsSentThisWeek,
      maxPerWeek: state.maxPerWeek,
      lastNotificationTime: _lastNotificationTime,
    );
  }

  /// Check if specific insight type should be sent
  bool shouldSendInsightType(String insightType) {
    // Check if type is enabled
    if (state.enabledInsightTypes.isNotEmpty &&
        !state.enabledInsightTypes.contains(insightType)) {
      return false;
    }

    // Check dismissal rate
    final stats = _stats[insightType];
    if (stats == null) return true; // No history, allow

    return _analyzer.shouldSendInsightType(
      insightType: insightType,
      totalSent: stats.totalSent,
      totalDismissed: stats.totalDismissed,
    );
  }

  /// Generate notification content for insight
  String generateNotificationContent({
    required String insightTitle,
    required String insightType,
  }) {
    return _analyzer.generateNotificationContent(
      level: _experienceLevel,
      insightTitle: insightTitle,
      insightType: insightType,
    );
  }

  /// Get dismissal rate for insight type
  double getDismissalRate(String insightType) {
    final stats = _stats[insightType];
    if (stats == null) return 0.0;
    return stats.dismissalRate;
  }

  /// Get all notification statistics
  Map<String, NotificationStats> getAllStats() => Map.from(_stats);

  /// Reset weekly counter (call at start of week)
  void resetWeeklyCounter() {
    _notificationsSentThisWeek = 0;
  }

  /// Update optimal notification times based on app open history
  void _updateOptimalTimes() {
    final optimalHours = _analyzer.predictOptimalNotificationTimes(
      appOpenHistory: _appOpenHistory,
      doNotDisturbHours: state.doNotDisturbHours,
    );

    state = state.copyWith(optimalHours: optimalHours);
  }
}

/// Provider: Notification Timing Analyzer
final notificationTimingAnalyzerProvider =
    Provider<NotificationTimingAnalyzer>((ref) {
  return NotificationTimingAnalyzer();
});

/// Provider: Smart Notifications (requires user context)
///
/// Note: In production, fetch experienceLevel from user profile provider
final smartNotificationsProvider = StateNotifierProvider.autoDispose<
    SmartNotificationsNotifier, NotificationPreferences>((ref) {
  final analyzer = ref.watch(notificationTimingAnalyzerProvider);

  // TODO: Replace with actual user experience level from profile
  const defaultExperienceLevel = ExperienceLevel.intermediate;

  return SmartNotificationsNotifier(analyzer, defaultExperienceLevel);
});
