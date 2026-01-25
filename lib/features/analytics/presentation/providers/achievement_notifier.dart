/// Achievement Notifier - Auto-unlock flow
///
/// Listens to workout completions and automatically checks/unlocks achievements.
/// This is the central hub for gamification triggers.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// Achievement auto-unlock state
class AchievementNotifierState {
  const AchievementNotifierState({
    this.isProcessing = false,
    this.lastUnlockedAchievements = const [],
    this.error,
  });

  final bool isProcessing;
  final List<Achievement> lastUnlockedAchievements;
  final String? error;

  AchievementNotifierState copyWith({
    bool? isProcessing,
    List<Achievement>? lastUnlockedAchievements,
    String? error,
    bool clearError = false,
  }) {
    return AchievementNotifierState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastUnlockedAchievements:
          lastUnlockedAchievements ?? this.lastUnlockedAchievements,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Achievement Notifier - Auto-unlock flow
class AchievementNotifier extends Notifier<AchievementNotifierState> {
  @override
  AchievementNotifierState build() {
    // Setup listeners for auto-unlock triggers
    _setupListeners();

    return const AchievementNotifierState();
  }

  void _setupListeners() {
    // TODO: Auto-trigger on workout completion
    // Currently triggered manually from workout_screen_controller
    // Future: Listen to workout completion stream and auto-trigger
  }

  /// Check and unlock achievements after workout completion
  Future<void> _checkAndUnlockAchievements(WorkoutMetrics metrics) async {
    try {
      state = state.copyWith(isProcessing: true, clearError: true);

      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        state = const AchievementNotifierState();
        return;
      }

      // Call the use case
      final useCase = ref.read(checkAndUnlockAchievementsUseCaseProvider);
      final result = await useCase(user.uid, metrics);

      result.fold(
        (failure) {
          state = state.copyWith(
            isProcessing: false,
            error: 'Failed to check achievements: ${failure.message}',
          );
          if (kDebugMode) {
            debugPrint('❌ [Achievements] Auto-unlock failed: ${failure.message}');
          }
        },
        (unlockedAchievements) {
          state = state.copyWith(
            isProcessing: false,
            lastUnlockedAchievements: unlockedAchievements,
          );

          if (unlockedAchievements.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('🎉 [Achievements] Auto-unlocked ${unlockedAchievements.length} badges:');
              for (final achievement in unlockedAchievements) {
                debugPrint('   - ${achievement.badgeType.name}');
              }
            }

            // TODO: Show celebration modal for unlocked achievements
            // Will be implemented in UI layer (Day 4-5)
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Unexpected error: $e',
      );
      if (kDebugMode) {
        debugPrint('❌ [Achievements] Auto-unlock error: $e');
      }
    }
  }

  /// Manual trigger for achievement check (for testing/admin)
  Future<void> manualCheckAchievements(WorkoutMetrics metrics) async {
    await _checkAndUnlockAchievements(metrics);
  }

  /// Clear last unlocked achievements (after showing modal)
  void clearLastUnlocked() {
    state = state.copyWith(lastUnlockedAchievements: []);
  }
}

/// Provider for Achievement Notifier
final achievementNotifierProvider =
    NotifierProvider<AchievementNotifier, AchievementNotifierState>(
  AchievementNotifier.new,
);

/// Convenience provider for last unlocked achievements
final lastUnlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  return ref.watch(achievementNotifierProvider).lastUnlockedAchievements;
});
