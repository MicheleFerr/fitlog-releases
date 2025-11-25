import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';

/// Repository interface for achievement/badge management
///
/// Handles CRUD operations for user achievements and badge unlocking logic.
/// Follows Clean Architecture pattern with Either for error handling.
abstract class AchievementRepository {
  /// Unlock a specific badge for a user
  ///
  /// Persists the achievement with evidence metadata and triggers
  /// any necessary notifications or analytics events.
  ///
  /// Returns the unlocked Achievement or Failure if:
  /// - Badge already unlocked
  /// - Persistence failed
  /// - Invalid badge type
  Future<fpdart.Either<Failure, Achievement>> unlockAchievement(
    String userId,
    BadgeType badgeType, {
    Map<String, dynamic>? evidence,
  });

  /// Get all unlocked achievements for a user
  ///
  /// Returns cached data if available (1h TTL), otherwise fetches from
  /// Firestore. Includes offline support via Hive.
  ///
  /// Returns List<Achievement> or Failure if fetch fails.
  Future<fpdart.Either<Failure, List<Achievement>>> getUnlockedAchievements(
    String userId,
  );

  /// Check which new achievements should be unlocked based on workout metrics
  ///
  /// Evaluates all 8 badge types against current user metrics:
  /// - FirstPR: First PR ever detected
  /// - StreakMaster: 7/14/30 day streaks
  /// - VolumeLegend: 10k/50k/100k kg milestones
  /// - BalancedBuilder: Push/pull ratio ≤ 1.2
  /// - OneRepMonarch: 3+ one-rep max PRs
  /// - WorkoutCompletionist: 50/100/500 workout milestones
  /// - ConsistencyChampion: Max 7-day gap in 90 days
  /// - FormMaster: 5+ form improvements
  ///
  /// Returns List<BadgeType> of newly-eligible badges (not already unlocked).
  Future<fpdart.Either<Failure, List<BadgeType>>> checkNewAchievements(
    String userId,
    WorkoutMetrics metrics,
  );

  /// Check if a specific achievement has already been unlocked
  ///
  /// Used to prevent duplicate unlocks and for conditional UI rendering.
  ///
  /// Returns true if unlocked, false otherwise, or Failure if check fails.
  Future<fpdart.Either<Failure, bool>> isAchievementUnlocked(
    String userId,
    BadgeType badgeType,
  );

  /// Get recently unlocked achievements (last 30 days)
  ///
  /// Useful for displaying recent accomplishments in UI.
  ///
  /// [limit] - Maximum number of achievements to return (default: 10)
  Future<fpdart.Either<Failure, List<Achievement>>> getRecentAchievements(
    String userId, {
    int limit = 10,
  });
}
