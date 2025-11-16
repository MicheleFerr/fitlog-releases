/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Achievement Provider - Manages achievement state and unlocking
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/achievement_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/achievement_data.dart';

/// Achievement State
class AchievementState {
  const AchievementState({
    required this.achievements,
    required this.totalPoints,
    this.recentlyUnlocked = const [],
  });

  final List<AchievementData> achievements;
  final int totalPoints;
  final List<AchievementData> recentlyUnlocked;

  AchievementState copyWith({
    List<AchievementData>? achievements,
    int? totalPoints,
    List<AchievementData>? recentlyUnlocked,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      totalPoints: totalPoints ?? this.totalPoints,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
    );
  }
}

/// Achievement Notifier
///
/// Manages:
/// - Achievement list (locked/unlocked)
/// - Achievement progress tracking
/// - Unlock detection and celebration
/// - Total points calculation
class AchievementNotifier extends StateNotifier<AsyncValue<AchievementState>> {
  AchievementNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  final AchievementRepository _repository;

  /// Map of unlocked achievements (id → timestamp)
  final Map<String, DateTime> _unlockedAchievements = {};

  /// Initialize achievement state
  Future<void> _initialize() async {
    try {
      // TODO: Load previously unlocked achievements from storage
      // _unlockedAchievements = await _loadFromStorage();

      final achievements = _repository.getAllAchievements(
        unlockedAchievements: _unlockedAchievements,
      );

      final totalPoints = _repository.getTotalPoints(achievements);

      state = AsyncValue.data(
        AchievementState(
          achievements: achievements,
          totalPoints: totalPoints,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Check for newly unlocked achievements
  ///
  /// Called after user statistics update (workout completed, PR achieved, etc.)
  Future<void> checkAchievements({
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolumeKg,
    required int templateCount,
    required int personalRecordCount,
    List<DateTime>? recentWorkoutTimes,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final newlyUnlocked = _repository.checkAchievements(
        totalWorkouts: totalWorkouts,
        currentStreak: currentStreak,
        totalVolumeKg: totalVolumeKg,
        templateCount: templateCount,
        personalRecordCount: personalRecordCount,
        recentWorkoutTimes: recentWorkoutTimes ?? [],
        previouslyUnlocked: _unlockedAchievements,
      );

      if (newlyUnlocked.isNotEmpty) {
        // Update unlocked map
        for (final achievement in newlyUnlocked) {
          _unlockedAchievements[achievement.id] = achievement.unlockedAt!;
        }

        // TODO: Save to storage
        // await _saveToStorage(_unlockedAchievements);

        // Refresh achievement list
        final updatedAchievements = _repository.getAllAchievements(
          unlockedAchievements: _unlockedAchievements,
        );

        final totalPoints = _repository.getTotalPoints(updatedAchievements);

        state = AsyncValue.data(
          AchievementState(
            achievements: updatedAchievements,
            totalPoints: totalPoints,
            recentlyUnlocked: newlyUnlocked,
          ),
        );

        // TODO: Trigger celebration animation/notification
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update achievement progress
  ///
  /// Called periodically to update progress bars
  Future<void> updateProgress({
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolumeKg,
    required int templateCount,
    required int personalRecordCount,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final updatedAchievements = _repository.updateAchievementProgress(
        achievements: currentState.achievements,
        totalWorkouts: totalWorkouts,
        currentStreak: currentStreak,
        totalVolumeKg: totalVolumeKg,
        templateCount: templateCount,
        personalRecordCount: personalRecordCount,
      );

      state = AsyncValue.data(
        currentState.copyWith(achievements: updatedAchievements),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear recently unlocked achievements
  ///
  /// Called after showing unlock animation
  void clearRecentlyUnlocked() {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(recentlyUnlocked: []),
    );
  }

  /// Refresh achievement list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _initialize();
  }
}

/// Provider: Achievement Repository
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

/// Provider: Achievement Notifier
final achievementProvider =
    StateNotifierProvider<AchievementNotifier, AsyncValue<AchievementState>>(
        (ref) {
  final repository = ref.watch(achievementRepositoryProvider);
  return AchievementNotifier(repository);
});

/// Provider: Total Points
///
/// Convenience provider for accessing total achievement points
final totalAchievementPointsProvider = Provider<int>((ref) {
  final achievementState = ref.watch(achievementProvider);
  return achievementState.value?.totalPoints ?? 0;
});

/// Provider: Unlock Percentage for Category
///
/// Returns unlock percentage (0.0 - 1.0) for specific category
final categoryUnlockPercentageProvider =
    Provider.family<double, AchievementCategory>((ref, category) {
  final achievementState = ref.watch(achievementProvider);
  final achievements = achievementState.value?.achievements ?? [];

  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getCategoryUnlockPercentage(
    category: category,
    achievements: achievements,
  );
});

/// Provider: Recently Unlocked Achievements
///
/// For displaying unlock animations/notifications
final recentlyUnlockedAchievementsProvider =
    Provider<List<AchievementData>>((ref) {
  final achievementState = ref.watch(achievementProvider);
  return achievementState.value?.recentlyUnlocked ?? [];
});

/// Provider: Achievements by Category
///
/// Returns filtered list of achievements for specific category
final achievementsByCategoryProvider =
    Provider.family<List<AchievementData>, AchievementCategory>((ref, category) {
  final achievementState = ref.watch(achievementProvider);
  final achievements = achievementState.value?.achievements ?? [];

  return achievements.where((a) => a.category == category).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
});
