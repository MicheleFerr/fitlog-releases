/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Streak Data Entity - Tracks workout consistency streaks
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_data.freezed.dart';
part 'streak_data.g.dart';

/// Workout Streak Data
///
/// Tracks user's consistency streak with gamification elements:
/// - Current active streak (consecutive days)
/// - Longest streak ever achieved
/// - Last workout date
/// - Streak milestones (7, 14, 30, 60, 90, 180, 365 days)
/// - Today's workout status
///
/// Algorithm:
/// - Streak continues if workouts within 24-48h window
/// - Breaks if gap >48h (allows 1 rest day)
/// - Resets to 0 on break, but preserves longestStreak
@freezed
abstract class StreakData with _$StreakData {
  const factory StreakData({
    /// Current consecutive workout days
    @Default(0) int currentStreak,

    /// Longest streak ever achieved (all-time best)
    @Default(0) int longestStreak,

    /// Last workout timestamp (null if never worked out)
    DateTime? lastWorkoutDate,

    /// Whether user worked out today
    @Default(false) bool workedOutToday,

    /// Streak milestones achieved (7, 14, 30, etc.)
    @Default([]) List<int> milestonesAchieved,

    /// Total workouts completed (all-time)
    @Default(0) int totalWorkouts,
  }) = _StreakData;

  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);
}

/// Streak status enum for UI
enum StreakStatus {
  /// No workouts yet (currentStreak = 0)
  none,

  /// Active streak (worked out today)
  active,

  /// At risk (last workout yesterday, need to workout today)
  atRisk,

  /// Broken (gap >48h since last workout)
  broken,
}

/// Extension methods for StreakData
extension StreakDataX on StreakData {
  /// Get current streak status
  StreakStatus get status {
    if (currentStreak == 0) return StreakStatus.none;
    if (workedOutToday) return StreakStatus.active;

    final now = DateTime.now();
    final lastWorkout = lastWorkoutDate;

    if (lastWorkout == null) return StreakStatus.none;

    final hoursSinceLastWorkout = now.difference(lastWorkout).inHours;

    // At risk if last workout 24-48h ago
    if (hoursSinceLastWorkout >= 24 && hoursSinceLastWorkout < 48) {
      return StreakStatus.atRisk;
    }

    // Broken if >48h
    if (hoursSinceLastWorkout >= 48) {
      return StreakStatus.broken;
    }

    return StreakStatus.active;
  }

  /// Check if milestone was just achieved
  bool isNewMilestone(int days) {
    return currentStreak == days && !milestonesAchieved.contains(days);
  }

  /// Get next milestone to achieve
  int? get nextMilestone {
    const milestones = [7, 14, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    return null; // All milestones achieved
  }

  /// Days until next milestone
  int? get daysToNextMilestone {
    final next = nextMilestone;
    if (next == null) return null;
    return next - currentStreak;
  }

  /// Check if streak is personal record
  bool get isPersonalRecord {
    return currentStreak > 0 && currentStreak == longestStreak;
  }
}
