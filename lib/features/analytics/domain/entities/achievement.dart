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

  /// Form improvement count (5+ improvements)
  formMaster,
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
