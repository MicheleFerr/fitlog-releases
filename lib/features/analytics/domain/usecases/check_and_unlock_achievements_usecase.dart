import 'package:fpdart/fpdart.dart' hide Either, Right, Left;
import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/achievement_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

/// Use case for checking and unlocking achievements based on workout metrics
///
/// Evaluates all 8 badge types against current user performance and unlocks
/// newly-eligible achievements. Called after workout completion or on demand.
///
/// Note: This is a simplified implementation that checks basic badge conditions.
/// Full implementation with all 8 badge types will be completed in future iterations.
class CheckAndUnlockAchievementsUseCase {
  CheckAndUnlockAchievementsUseCase({
    required this.achievementRepository,
    required this.prTracker,
  });

  final AchievementRepository achievementRepository;
  final PRTracker prTracker;

  /// Check for new achievements and unlock them
  ///
  /// Currently implements:
  /// 1. FirstPR - First personal record ever achieved
  /// 5. OneRepMonarch - Multiple one-rep max PRs (3+)
  ///
  /// TODO: Implement remaining 6 badge types:
  /// 2. StreakMaster - Requires StreakRepository integration
  /// 3. VolumeLegend - Requires VolumeCalculator.calculateLifetimeVolume()
  /// 4. BalancedBuilder - Requires MuscleBalanceAnalyzer.analyze()
  /// 6. WorkoutCompletionist - Requires workout count tracking
  /// 7. ConsistencyChampion - Requires streak analysis
  /// 8. FormMaster - Requires form tracking integration
  ///
  /// [userId] - User to check achievements for
  /// [metrics] - Current workout metrics
  ///
  /// Returns List<Achievement> of newly unlocked achievements.
  Future<fpdart.Either<Failure, List<Achievement>>> call(
    String userId,
    WorkoutMetrics metrics,
  ) async {
    try {
      final newlyUnlockedBadges = <BadgeType>[];

      // 1. Check FirstPR badge
      final firstPRBadge = await _checkFirstPRBadge(userId, metrics);
      if (firstPRBadge != null) newlyUnlockedBadges.add(firstPRBadge);

      // 5. Check OneRepMonarch badge
      final strengthBadge = await _checkOneRepMonarchBadge(userId);
      if (strengthBadge != null) newlyUnlockedBadges.add(strengthBadge);

      // Unlock all newly-eligible badges
      final unlockedAchievements = <Achievement>[];
      for (final badgeType in newlyUnlockedBadges) {
        final result = await achievementRepository.unlockAchievement(
          userId,
          badgeType,
          evidence: _getEvidenceForBadge(badgeType, metrics),
        );
        result.fold(
          (failure) => null, // Ignore failures for individual unlocks
          (achievement) => unlockedAchievements.add(achievement),
        );
      }

      return fpdart.Right(unlockedAchievements);
    } catch (e) {
      return fpdart.Left(
        UnexpectedFailure('Failed to check achievements: $e'),
      );
    }
  }

  /// Check if FirstPR badge should be unlocked
  Future<BadgeType?> _checkFirstPRBadge(
    String userId,
    WorkoutMetrics metrics,
  ) async {
    try {
      final existingPRs = await prTracker.getUserPRs(userId);
      final hasNewPR = metrics.personalRecords.isNotEmpty;

      // Unlock if this is the user's first PR ever
      if (existingPRs.isEmpty && hasNewPR) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.firstPR,
        );
        return isUnlocked.fold(
          (l) => null,
          (unlocked) => unlocked ? null : BadgeType.firstPR,
        );
      }
      return null;
    } catch (e) {
      return null; // Ignore errors for individual checks
    }
  }

  /// Check if OneRepMonarch badge should be unlocked
  Future<BadgeType?> _checkOneRepMonarchBadge(String userId) async {
    try {
      final allPRs = await prTracker.getUserPRs(userId);
      final oneRepMaxPRs = allPRs.where((pr) => pr.type == PRType.oneRM).length;

      if (oneRepMaxPRs >= 3) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.oneRepMonarch,
        );
        return isUnlocked.fold(
          (l) => null,
          (unlocked) => unlocked ? null : BadgeType.oneRepMonarch,
        );
      }

      return null;
    } catch (e) {
      return null; // Ignore errors for individual checks
    }
  }

  /// Get evidence metadata for a specific badge type
  Map<String, dynamic> _getEvidenceForBadge(
    BadgeType badgeType,
    WorkoutMetrics metrics,
  ) {
    switch (badgeType) {
      case BadgeType.firstPR:
        if (metrics.personalRecords.isNotEmpty) {
          final firstPR = metrics.personalRecords.first;
          return {
            'prType': firstPR.type.name,
            'exerciseName': firstPR.exerciseName,
            'newValue': firstPR.newValue,
            'achievedAt': firstPR.achievedAt.toIso8601String(),
          };
        }
        return {'timestamp': DateTime.now().toIso8601String()};

      case BadgeType.oneRepMonarch:
        final oneRMPRs = metrics.personalRecords
            .where((pr) => pr.type == PRType.oneRM)
            .toList();
        return {
          'oneRepMaxCount': oneRMPRs.length,
          'exercises': oneRMPRs.map((pr) => pr.exerciseName).toList(),
          'timestamp': DateTime.now().toIso8601String(),
        };

      // TODO: Add evidence for remaining badge types
      default:
        return {'timestamp': DateTime.now().toIso8601String()};
    }
  }
}
