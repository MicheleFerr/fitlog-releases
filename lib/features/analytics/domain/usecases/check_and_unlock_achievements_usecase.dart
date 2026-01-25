import 'package:fpdart/fpdart.dart' as fpdart show Either, Right, Left;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/achievement.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/achievement_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/repositories/workout_repository.dart';
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
    required this.streakRepository,
    required this.workoutRepository,
  });

  final AchievementRepository achievementRepository;
  final PRTracker prTracker;
  final StreakRepository streakRepository;
  final WorkoutRepository workoutRepository;

  /// Check for new achievements and unlock them
  ///
  /// Implemented (7/8):
  /// 1. FirstPR - First personal record ever achieved ✅
  /// 2. StreakMaster (7, 14, 30 days) - Workout streak milestones ✅
  /// 3. VolumeLegend (10k, 50k, 100k kg) - Total volume milestones ✅
  /// 4. BalancedBuilder - Push/pull balance ✅
  /// 5. OneRepMonarch - Multiple one-rep max PRs (3+) ✅
  /// 6. WorkoutCompletionist (50, 100, 500) - Workout count milestones ✅
  /// 7. ConsistencyChampion - Max 7-day gap in 90 days ✅
  ///
  /// TODO:
  /// 8. FormMaster - Requires form tracking integration (FUTURE FEATURE)
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

      // 2. Check StreakMaster badges (7, 14, 30 days)
      final streakBadges = await _checkStreakMasterBadges(userId);
      newlyUnlockedBadges.addAll(streakBadges);

      // 3. Check VolumeLegend badges (10k, 50k, 100k kg)
      final volumeBadges = await _checkVolumeLegendBadges(userId);
      newlyUnlockedBadges.addAll(volumeBadges);

      // 4. Check BalancedBuilder badge
      final balancedBadge = await _checkBalancedBuilderBadge(userId);
      if (balancedBadge != null) newlyUnlockedBadges.add(balancedBadge);

      // 5. Check OneRepMonarch badge
      final strengthBadge = await _checkOneRepMonarchBadge(userId);
      if (strengthBadge != null) newlyUnlockedBadges.add(strengthBadge);

      // 6. Check WorkoutCompletionist badges (50, 100, 500)
      final completionBadges = await _checkWorkoutCompletionistBadges(userId);
      newlyUnlockedBadges.addAll(completionBadges);

      // 7. Check ConsistencyChampion badge
      final consistencyBadge = await _checkConsistencyChampionBadge(userId);
      if (consistencyBadge != null) newlyUnlockedBadges.add(consistencyBadge);

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

  /// Check if StreakMaster badges should be unlocked
  Future<List<BadgeType>> _checkStreakMasterBadges(String userId) async {
    try {
      final streak = await streakRepository.getCurrentStreak();
      final currentStreak = streak.currentStreak;
      final newBadges = <BadgeType>[];

      // Check 7-day streak
      if (currentStreak >= 7) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.streakMaster7,
        );
        isUnlocked.fold(
          (l) => null,
          (unlocked) {
            if (!unlocked) newBadges.add(BadgeType.streakMaster7);
          },
        );
      }

      // Check 14-day streak
      if (currentStreak >= 14) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.streakMaster14,
        );
        isUnlocked.fold(
          (l) => null,
          (unlocked) {
            if (!unlocked) newBadges.add(BadgeType.streakMaster14);
          },
        );
      }

      // Check 30-day streak
      if (currentStreak >= 30) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.streakMaster30,
        );
        isUnlocked.fold(
          (l) => null,
          (unlocked) {
            if (!unlocked) newBadges.add(BadgeType.streakMaster30);
          },
        );
      }

      return newBadges;
    } catch (e) {
      return []; // Ignore errors for streak checks
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

  /// Check if VolumeLegend badges should be unlocked
  Future<List<BadgeType>> _checkVolumeLegendBadges(String userId) async {
    try {
      // Calculate lifetime volume from all completed workouts
      final workoutsResult = await workoutRepository.getWorkouts();
      final workouts = workoutsResult.fold((l) => <dynamic>[], (r) => r);

      double totalVolume = 0;
      for (final workout in workouts) {
        if (workout.isCompleted) {
          // Sum volume from all exercises
          for (final exercise in workout.exercises) {
            for (final set in exercise.sets) {
              if (!set.isWarmup) {
                totalVolume += (set.weight ?? 0) * (set.actualReps ?? 0);
              }
            }
          }
        }
      }

      final newBadges = <BadgeType>[];

      // Check 10k kg
      if (totalVolume >= 10000) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.volumeLegend10k,
        );
        isUnlocked.fold((l) => null, (unlocked) {
          if (!unlocked) newBadges.add(BadgeType.volumeLegend10k);
        });
      }

      // Check 50k kg
      if (totalVolume >= 50000) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.volumeLegend50k,
        );
        isUnlocked.fold((l) => null, (unlocked) {
          if (!unlocked) newBadges.add(BadgeType.volumeLegend50k);
        });
      }

      // Check 100k kg
      if (totalVolume >= 100000) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.volumeLegend100k,
        );
        isUnlocked.fold((l) => null, (unlocked) {
          if (!unlocked) newBadges.add(BadgeType.volumeLegend100k);
        });
      }

      return newBadges;
    } catch (e) {
      return [];
    }
  }

  /// Check if BalancedBuilder badge should be unlocked
  Future<BadgeType?> _checkBalancedBuilderBadge(String userId) async {
    try {
      // Calculate push/pull ratio from recent workouts (last 30 days)
      final workoutsResult = await workoutRepository.getWorkouts();
      final workouts = workoutsResult.fold((l) => <dynamic>[], (r) => r);

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentWorkouts = workouts.where((w) =>
        w.isCompleted && (w.endTime ?? w.createdAt).isAfter(thirtyDaysAgo)
      ).toList();

      double pushVolume = 0;
      double pullVolume = 0;

      for (final workout in recentWorkouts) {
        for (final exercise in workout.exercises) {
          double exerciseVolume = 0;
          for (final set in exercise.sets) {
            if (!set.isWarmup) {
              exerciseVolume += (set.weight ?? 0) * (set.actualReps ?? 0);
            }
          }

          // Classify exercise (simplified - would need proper muscle group mapping)
          final exerciseName = exercise.exerciseName.toLowerCase();
          if (exerciseName.contains('press') || exerciseName.contains('fly') ||
              exerciseName.contains('dip') || exerciseName.contains('extension')) {
            pushVolume += exerciseVolume;
          } else if (exerciseName.contains('pull') || exerciseName.contains('row') ||
                     exerciseName.contains('curl') || exerciseName.contains('lat')) {
            pullVolume += exerciseVolume;
          }
        }
      }

      final totalVolume = pushVolume + pullVolume;
      if (totalVolume > 0) {
        final ratio = (pushVolume - pullVolume).abs() / totalVolume;

        // Badge unlocks if ratio is < 0.15 (within 15% balance)
        if (ratio < 0.15) {
          final isUnlocked = await achievementRepository.isAchievementUnlocked(
            userId,
            BadgeType.balancedBuilder,
          );
          return isUnlocked.fold(
            (l) => null,
            (unlocked) => unlocked ? null : BadgeType.balancedBuilder,
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if WorkoutCompletionist badges should be unlocked
  Future<List<BadgeType>> _checkWorkoutCompletionistBadges(String userId) async {
    try {
      final workoutsResult = await workoutRepository.getWorkouts();
      final workouts = workoutsResult.fold((l) => <dynamic>[], (r) => r);
      final completedCount = workouts.where((w) => w.isCompleted).length;

      final newBadges = <BadgeType>[];

      // Check 50 workouts
      if (completedCount >= 50) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.workoutCompletionist50,
        );
        isUnlocked.fold((l) => null, (unlocked) {
          if (!unlocked) newBadges.add(BadgeType.workoutCompletionist50);
        });
      }

      // Check 100 workouts
      if (completedCount >= 100) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.workoutCompletionist100,
        );
        isUnlocked.fold((l) => null, (unlocked) {
          if (!unlocked) newBadges.add(BadgeType.workoutCompletionist100);
        });
      }

      // Check 500 workouts
      if (completedCount >= 500) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.workoutCompletionist500,
        );
        isUnlocked.fold((l) => null, (unlocked) {
          if (!unlocked) newBadges.add(BadgeType.workoutCompletionist500);
        });
      }

      return newBadges;
    } catch (e) {
      return [];
    }
  }

  /// Check if ConsistencyChampion badge should be unlocked
  Future<BadgeType?> _checkConsistencyChampionBadge(String userId) async {
    try {
      // Check max gap in last 90 days
      final workoutsResult = await workoutRepository.getWorkouts();
      final workouts = workoutsResult.fold((l) => <dynamic>[], (r) => r);

      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      final recentWorkouts = workouts.where((w) =>
        w.isCompleted && (w.endTime ?? w.createdAt).isAfter(ninetyDaysAgo)
      ).toList();

      if (recentWorkouts.isEmpty) return null;

      // Get unique workout dates
      final workoutDates = recentWorkouts
          .map((w) => DateTime(
                (w.endTime ?? w.createdAt).year,
                (w.endTime ?? w.createdAt).month,
                (w.endTime ?? w.createdAt).day,
              ))
          .toSet()
          .toList()
        ..sort();

      // Calculate max gap
      int maxGap = 0;
      for (int i = 1; i < workoutDates.length; i++) {
        final gap = workoutDates[i].difference(workoutDates[i - 1]).inDays;
        if (gap > maxGap) maxGap = gap;
      }

      // Badge unlocks if max gap <= 7 days
      if (maxGap <= 7) {
        final isUnlocked = await achievementRepository.isAchievementUnlocked(
          userId,
          BadgeType.consistencyChampion,
        );
        return isUnlocked.fold(
          (l) => null,
          (unlocked) => unlocked ? null : BadgeType.consistencyChampion,
        );
      }

      return null;
    } catch (e) {
      return null;
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

      case BadgeType.streakMaster7:
      case BadgeType.streakMaster14:
      case BadgeType.streakMaster30:
        return {
          'streakType': badgeType.name,
          'timestamp': DateTime.now().toIso8601String(),
        };

      case BadgeType.volumeLegend10k:
      case BadgeType.volumeLegend50k:
      case BadgeType.volumeLegend100k:
        return {
          'volumeType': badgeType.name,
          'timestamp': DateTime.now().toIso8601String(),
        };

      case BadgeType.balancedBuilder:
        return {
          'timestamp': DateTime.now().toIso8601String(),
        };

      case BadgeType.workoutCompletionist50:
      case BadgeType.workoutCompletionist100:
      case BadgeType.workoutCompletionist500:
        return {
          'completionType': badgeType.name,
          'timestamp': DateTime.now().toIso8601String(),
        };

      case BadgeType.consistencyChampion:
        return {
          'timestamp': DateTime.now().toIso8601String(),
        };
    }
  }
}
