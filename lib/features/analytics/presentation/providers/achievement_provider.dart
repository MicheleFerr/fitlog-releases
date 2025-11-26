import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/pr_celebration.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/achievement_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/usecases/check_and_unlock_achievements_usecase.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/achievement_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/pr_celebration_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider for AchievementRepository
///
/// Implements cache-first strategy with Firestore + Hive.
/// Cache box name: 'achievements_cache'
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    cacheBoxName: 'achievements_cache',
  );
});

/// Provider for PRTracker service
///
/// Used by CheckAndUnlockAchievementsUseCase for PR-based badge logic.
final prTrackerProvider = Provider<PRTracker>((ref) {
  return PRTracker(firestore: FirebaseFirestore.instance);
});

/// Provider for PRCelebrationRepository
///
/// Handles PR celebration tracking with Firestore + analytics.
final prCelebrationRepositoryProvider = Provider((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return PRCelebrationRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    analyticsService: analyticsService,
  );
});

/// Provider for CheckAndUnlockAchievementsUseCase
///
/// Use case for checking and unlocking achievements after workout completion.
final checkAndUnlockAchievementsUseCaseProvider =
    Provider<CheckAndUnlockAchievementsUseCase>((ref) {
  return CheckAndUnlockAchievementsUseCase(
    achievementRepository: ref.watch(achievementRepositoryProvider),
    prTracker: ref.watch(prTrackerProvider),
  );
});

/// State provider for unlocked achievements
///
/// Holds current list of unlocked achievements for the active user.
/// Updated after each unlock operation or on app startup.
final unlockedAchievementsProvider =
    StateProvider<List<Achievement>>((ref) => []);

/// State provider for newly detected PRs after workout completion
///
/// Holds PRs detected in the most recent workout completion.
/// UI can watch this to display PR celebration modal.
/// Cleared after modal is shown or dismissed.
final newlyDetectedPRsProvider =
    StateProvider<List<PRCelebration>>((ref) => []);

/// FutureProvider to load unlocked achievements for a user
///
/// Usage: ref.watch(loadUnlockedAchievementsProvider(userId))
final loadUnlockedAchievementsProvider =
    FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final repository = ref.watch(achievementRepositoryProvider);
  final result = await repository.getUnlockedAchievements(userId);

  return result.fold(
    (failure) => [], // On error, return empty list
    (achievements) {
      // Update state provider
      ref.read(unlockedAchievementsProvider.notifier).state = achievements;
      return achievements;
    },
  );
});

/// Provider for recent achievements (last 10)
///
/// Usage: ref.watch(recentAchievementsProvider(userId))
final recentAchievementsProvider =
    FutureProvider.family<List<Achievement>, String>((ref, userId) async {
  final repository = ref.watch(achievementRepositoryProvider);
  final result = await repository.getRecentAchievements(userId, limit: 10);

  return result.fold(
    (failure) => [],
    (achievements) => achievements,
  );
});

/// Provider for checking if a specific achievement is unlocked
///
/// Usage: ref.watch(isAchievementUnlockedProvider((userId, badgeType)))
final isAchievementUnlockedProvider = FutureProvider.family<bool,
    ({String userId, BadgeType badgeType})>((ref, params) async {
  final repository = ref.watch(achievementRepositoryProvider);
  final result = await repository.isAchievementUnlocked(
    params.userId,
    params.badgeType,
  );

  return result.fold(
    (failure) => false,
    (isUnlocked) => isUnlocked,
  );
});

/// StateNotifier for achievement unlock operations
///
/// Manages the process of unlocking achievements and updating UI state.
class AchievementNotifier extends StateNotifier<AsyncValue<List<Achievement>>> {
  AchievementNotifier({
    required this.achievementRepository,
    required this.checkAndUnlockUseCase,
  }) : super(const AsyncValue.data([]));

  final AchievementRepository achievementRepository;
  final CheckAndUnlockAchievementsUseCase checkAndUnlockUseCase;

  /// Check for new achievements based on workout metrics
  ///
  /// Called after workout completion to evaluate badge eligibility.
  /// Returns newly unlocked achievements or empty list on error.
  Future<List<Achievement>> checkAndUnlockAchievements(
    String userId,
    WorkoutMetrics metrics,
  ) async {
    state = const AsyncValue.loading();

    final result = await checkAndUnlockUseCase(userId, metrics);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return [];
      },
      (newAchievements) {
        state = AsyncValue.data(newAchievements);
        return newAchievements;
      },
    );
  }

  /// Manually unlock a specific achievement
  ///
  /// Used for testing or admin operations.
  /// Not normally called from production UI flow.
  Future<void> unlockAchievement(
    String userId,
    BadgeType badgeType, {
    Map<String, dynamic>? evidence,
  }) async {
    state = const AsyncValue.loading();

    final result = await achievementRepository.unlockAchievement(
      userId,
      badgeType,
      evidence: evidence,
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (achievement) {
        // Add to current state
        final current = state.value ?? [];
        state = AsyncValue.data([...current, achievement]);
      },
    );
  }

  /// Load all unlocked achievements for a user
  Future<void> loadUnlockedAchievements(String userId) async {
    state = const AsyncValue.loading();

    final result = await achievementRepository.getUnlockedAchievements(userId);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (achievements) {
        state = AsyncValue.data(achievements);
      },
    );
  }
}

/// Provider for AchievementNotifier
///
/// Usage: ref.read(achievementNotifierProvider.notifier).checkAndUnlockAchievements(...)
final achievementNotifierProvider = StateNotifierProvider<AchievementNotifier,
    AsyncValue<List<Achievement>>>((ref) {
  return AchievementNotifier(
    achievementRepository: ref.watch(achievementRepositoryProvider),
    checkAndUnlockUseCase: ref.watch(checkAndUnlockAchievementsUseCaseProvider),
  );
});
