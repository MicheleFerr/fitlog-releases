/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: service
///
/// Streak Calculator - Calculates workout consistency streaks
///
/// **Note**: This is a calculation service, NOT a repository.
/// For the actual StreakRepository (interface + impl), see:
/// `lib/features/streak/data/repositories/streak_repository.dart`
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/streak_data.dart';

/// @deprecated Use [StreakCalculator] instead to avoid naming conflicts
/// with streak feature's StreakRepository.
@Deprecated('Use StreakCalculator instead - avoids naming conflict with streak StreakRepository')
typedef StreakRepository = StreakCalculator;

/// Service for calculating and managing workout streaks
///
/// Responsibilities:
/// - Calculate current streak from workout history
/// - Track longest streak (all-time best)
/// - Detect milestone achievements
/// - Determine streak status (active/at-risk/broken)
///
/// Algorithm:
/// 1. Sort workout dates chronologically
/// 2. Count consecutive days with ≤48h gaps
/// 3. Break streak if gap >48h (allows 1 rest day)
/// 4. Track milestones: 7, 14, 30, 60, 90, 180, 365 days
class StreakCalculator {
  /// Milestone thresholds (days)
  static const List<int> milestones = [7, 14, 30, 60, 90, 180, 365];

  /// Maximum gap allowed between workouts (hours)
  static const int maxGapHours = 48; // 2 days (allows 1 rest day)

  /// Calculate streak data from workout history
  ///
  /// [workoutDates]: List of workout completion timestamps
  /// [previousStreakData]: Previous streak data (for longestStreak tracking)
  ///
  /// Returns: Updated StreakData with current streak calculated
  StreakData calculateStreak({
    required List<DateTime> workoutDates,
    StreakData? previousStreakData,
  }) {
    if (workoutDates.isEmpty) {
      return StreakData(
        currentStreak: 0,
        longestStreak: previousStreakData?.longestStreak ?? 0,
        lastWorkoutDate: null,
        workedOutToday: false,
        milestonesAchieved: previousStreakData?.milestonesAchieved ?? [],
        totalWorkouts: 0,
      );
    }

    // Sort workout dates chronologically (newest first)
    final sortedDates = List<DateTime>.from(workoutDates)
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final lastWorkout = sortedDates.first;

    // Check if worked out today
    final workedOutToday = _isSameDay(lastWorkout, now);

    // Calculate current streak
    int currentStreak = 0;
    DateTime? previousDate;

    for (final workoutDate in sortedDates) {
      if (previousDate == null) {
        // First workout in sorted list
        currentStreak = 1;
        previousDate = workoutDate;
        continue;
      }

      // Check gap between workouts
      final hoursBetween = previousDate.difference(workoutDate).inHours;

      if (hoursBetween <= maxGapHours) {
        // Consecutive workout (within 48h window)
        currentStreak++;
        previousDate = workoutDate;
      } else {
        // Gap too large, streak broken
        break;
      }
    }

    // If last workout was >48h ago and not today, streak is broken
    final hoursSinceLastWorkout = now.difference(lastWorkout).inHours;
    if (hoursSinceLastWorkout > maxGapHours && !workedOutToday) {
      currentStreak = 0;
    }

    // Calculate longest streak
    final previousLongestStreak = previousStreakData?.longestStreak ?? 0;
    final longestStreak =
        currentStreak > previousLongestStreak ? currentStreak : previousLongestStreak;

    // Calculate achieved milestones
    final achievedMilestones = milestones
        .where((milestone) => currentStreak >= milestone)
        .toList();

    // Merge with previous milestones (keep all-time achievements)
    final allMilestones = {
      ...previousStreakData?.milestonesAchieved ?? [],
      ...achievedMilestones,
    }.toList()
      ..sort();

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastWorkoutDate: lastWorkout,
      workedOutToday: workedOutToday,
      milestonesAchieved: allMilestones,
      totalWorkouts: workoutDates.length,
    );
  }

  /// Check if two dates are the same day (ignoring time)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get motivational message based on streak status
  ///
  /// Returns localization key for the message
  String getStreakMessage(StreakData streakData) {
    final status = streakData.status;

    switch (status) {
      case StreakStatus.none:
        return 'streakMessageNone'; // "Start your streak today!"

      case StreakStatus.active:
        if (streakData.isPersonalRecord) {
          return 'streakMessagePersonalRecord'; // "New personal record!"
        }
        final nextMilestone = streakData.nextMilestone;
        if (nextMilestone != null) {
          return 'streakMessageActive'; // "Keep going! Next milestone: {days} days"
        }
        return 'streakMessageAllMilestones'; // "All milestones achieved!"

      case StreakStatus.atRisk:
        return 'streakMessageAtRisk'; // "Don't break the streak! Workout today"

      case StreakStatus.broken:
        return 'streakMessageBroken'; // "Streak broken. Start fresh today!"
    }
  }

  /// Check if new milestone was just achieved
  ///
  /// Compares current streak with previous to detect milestone unlock
  bool checkNewMilestoneAchieved({
    required StreakData currentStreak,
    required StreakData? previousStreak,
  }) {
    if (previousStreak == null) return false;

    // Check if current streak hit a milestone that wasn't previously achieved
    for (final milestone in milestones) {
      if (currentStreak.currentStreak == milestone &&
          !previousStreak.milestonesAchieved.contains(milestone)) {
        return true;
      }
    }

    return false;
  }

  /// Get milestone name for UI display
  ///
  /// Returns localization key for milestone name
  String getMilestoneName(int days) {
    switch (days) {
      case 7:
        return 'milestoneWeek'; // "Week Warrior"
      case 14:
        return 'milestoneTwoWeeks'; // "Two-Week Champion"
      case 30:
        return 'milestoneMonth'; // "Monthly Master"
      case 60:
        return 'milestoneTwoMonths'; // "Two-Month Hero"
      case 90:
        return 'milestoneQuarter'; // "Quarterly Beast"
      case 180:
        return 'milestoneSixMonths'; // "Half-Year Legend"
      case 365:
        return 'milestoneYear'; // "Yearly Titan"
      default:
        return 'milestoneCustom'; // "{days} days"
    }
  }

  /// Calculate streak progress to next milestone (0.0 - 1.0)
  double calculateProgressToNextMilestone(StreakData streakData) {
    final nextMilestone = streakData.nextMilestone;
    if (nextMilestone == null) return 1.0; // All milestones achieved

    // Find previous milestone
    int previousMilestone = 0;
    for (final milestone in milestones) {
      if (milestone < nextMilestone) {
        previousMilestone = milestone;
      } else {
        break;
      }
    }

    final range = nextMilestone - previousMilestone;
    final progress = streakData.currentStreak - previousMilestone;

    return progress / range;
  }
}
