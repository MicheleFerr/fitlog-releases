import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Badge types representing different achievement categories
enum BadgeType {
  /// First personal record achieved
  firstPR,

  /// Workout streak milestones (7, 14, 30 days)
  streakMaster7,
  streakMaster14,
  streakMaster30,

  /// Total volume lifted milestones (10k, 50k, 100k kg)
  volumeLegend10k,
  volumeLegend50k,
  volumeLegend100k,

  /// Balanced push/pull volume ratio
  balancedBuilder,

  /// One-rep max PR count milestones (3+ PRs)
  oneRepMonarch,

  /// Total workout count milestones (50, 100, 500)
  workoutCompletionist50,
  workoutCompletionist100,
  workoutCompletionist500,

  /// Consistency in last 90 days (max gap ≤ 7 days)
  consistencyChampion,
}

/// Achievement entity representing an unlocked badge/milestone
///
/// Tracks when a user achieves specific fitness milestones with evidence
/// to support gamification and retention features.
@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    /// Unique achievement identifier
    required String id,

    /// User who unlocked this achievement
    required String userId,

    /// Type of badge/achievement
    required BadgeType badgeType,

    /// When the achievement was unlocked
    required DateTime unlockedAt,

    /// Evidence/context for the achievement
    /// Examples:
    /// - FirstPR: {"prType": "weight", "exercise": "Bench Press", "value": 100}
    /// - StreakMaster: {"streakDays": 14, "startDate": "2025-01-01"}
    /// - VolumeLegend: {"totalVolume": 50000, "unit": "kg"}
    required Map<String, dynamic> evidence,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Extension for badge XP rewards
extension BadgeTypeXP on BadgeType {
  /// XP awarded when unlocking this badge
  int get xpReward {
    switch (this) {
      // Starter badges - 50 XP
      case BadgeType.firstPR:
        return 50;

      // Common milestones - 100 XP
      case BadgeType.streakMaster7:
      case BadgeType.volumeLegend10k:
      case BadgeType.workoutCompletionist50:
        return 100;

      // Intermediate milestones - 150 XP
      case BadgeType.streakMaster14:
      case BadgeType.volumeLegend50k:
      case BadgeType.workoutCompletionist100:
        return 150;

      // Advanced milestones - 200 XP
      case BadgeType.streakMaster30:
      case BadgeType.balancedBuilder:
      case BadgeType.oneRepMonarch:
      case BadgeType.consistencyChampion:
        return 200;

      // Elite milestones - 300 XP
      case BadgeType.volumeLegend100k:
      case BadgeType.workoutCompletionist500:
        return 300;
    }
  }
}
