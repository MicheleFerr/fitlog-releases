/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/providers
/// Feature: Weight Update Nudge
/// Type: Provider
///
/// Manages weight update reminders to encourage users
/// to keep their bodyweight data current for accurate
/// bodyweight exercise volume calculations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Configuration for weight update nudge
class WeightUpdateNudgeConfig {
  const WeightUpdateNudgeConfig._();

  /// Days between weight update reminders (4 weeks)
  static const int reminderIntervalDays = 28;

  /// Minimum days before showing first nudge after dismissal
  static const int dismissalCooldownDays = 7;
}

/// State for weight update nudge
class WeightNudgeState {
  const WeightNudgeState({
    required this.shouldShowNudge,
    required this.daysSinceLastUpdate,
    required this.lastUpdateDate,
    required this.isDismissed,
  });

  /// Default state - no nudge needed
  static const hidden = WeightNudgeState(
    shouldShowNudge: false,
    daysSinceLastUpdate: 0,
    lastUpdateDate: null,
    isDismissed: false,
  );

  /// Whether to show the nudge widget
  final bool shouldShowNudge;

  /// Days since last weight update
  final int daysSinceLastUpdate;

  /// Last weight update date (null if never updated)
  final DateTime? lastUpdateDate;

  /// Whether user dismissed the nudge recently
  final bool isDismissed;

  WeightNudgeState copyWith({
    bool? shouldShowNudge,
    int? daysSinceLastUpdate,
    DateTime? lastUpdateDate,
    bool? isDismissed,
  }) {
    return WeightNudgeState(
      shouldShowNudge: shouldShowNudge ?? this.shouldShowNudge,
      daysSinceLastUpdate: daysSinceLastUpdate ?? this.daysSinceLastUpdate,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

/// Provider for weight update nudge state
final weightUpdateNudgeProvider =
    AsyncNotifierProvider<WeightUpdateNudgeNotifier, WeightNudgeState>(
  WeightUpdateNudgeNotifier.new,
);

/// Notifier for managing weight update nudge
class WeightUpdateNudgeNotifier extends AsyncNotifier<WeightNudgeState> {
  // 🔐 User-scoped cache keys
  String get _keyLastWeightUpdate =>
      userCacheKeys.userScopedKey('weight_nudge_last_update');
  String get _keyLastDismissed =>
      userCacheKeys.userScopedKey('weight_nudge_last_dismissed');

  @override
  Future<WeightNudgeState> build() async {
    return await _calculateNudgeState();
  }

  /// Calculate whether to show the nudge
  Future<WeightNudgeState> _calculateNudgeState() async {
    final prefs = await SharedPreferences.getInstance();

    // Get last weight update timestamp
    final lastUpdateMillis = prefs.getInt(_keyLastWeightUpdate);
    final lastDismissedMillis = prefs.getInt(_keyLastDismissed);

    final now = DateTime.now();
    DateTime? lastUpdateDate;
    int daysSinceLastUpdate = 0;
    bool isDismissed = false;

    // Calculate days since last update
    if (lastUpdateMillis != null) {
      lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
      daysSinceLastUpdate = now.difference(lastUpdateDate).inDays;
    } else {
      // Never updated - assume it was set during onboarding (today)
      // Will start nudging after reminderIntervalDays
      daysSinceLastUpdate = 0;
    }

    // Check if recently dismissed
    if (lastDismissedMillis != null) {
      final lastDismissed =
          DateTime.fromMillisecondsSinceEpoch(lastDismissedMillis);
      final daysSinceDismissal = now.difference(lastDismissed).inDays;
      isDismissed =
          daysSinceDismissal < WeightUpdateNudgeConfig.dismissalCooldownDays;
    }

    // Determine if should show nudge
    final shouldShow = !isDismissed &&
        daysSinceLastUpdate >= WeightUpdateNudgeConfig.reminderIntervalDays;

    return WeightNudgeState(
      shouldShowNudge: shouldShow,
      daysSinceLastUpdate: daysSinceLastUpdate,
      lastUpdateDate: lastUpdateDate,
      isDismissed: isDismissed,
    );
  }

  /// Mark weight as updated (call when user saves weight in profile)
  Future<void> markWeightUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setInt(_keyLastWeightUpdate, now.millisecondsSinceEpoch);
    // Clear dismissal when weight is updated
    await prefs.remove(_keyLastDismissed);

    state = AsyncValue.data(WeightNudgeState(
      shouldShowNudge: false,
      daysSinceLastUpdate: 0,
      lastUpdateDate: now,
      isDismissed: false,
    ));
  }

  /// Dismiss the nudge temporarily
  Future<void> dismissNudge() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setInt(_keyLastDismissed, now.millisecondsSinceEpoch);

    final currentState = state.valueOrNull ?? WeightNudgeState.hidden;
    state = AsyncValue.data(currentState.copyWith(
      shouldShowNudge: false,
      isDismissed: true,
    ));
  }

  /// Force refresh the nudge state
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _calculateNudgeState());
  }
}

/// Quick access provider for whether to show the nudge
final shouldShowWeightNudgeProvider = Provider<bool>((ref) {
  final nudgeState = ref.watch(weightUpdateNudgeProvider);
  return nudgeState.valueOrNull?.shouldShowNudge ?? false;
});

/// Provider for days since last weight update
final daysSinceWeightUpdateProvider = Provider<int>((ref) {
  final nudgeState = ref.watch(weightUpdateNudgeProvider);
  return nudgeState.valueOrNull?.daysSinceLastUpdate ?? 0;
});
