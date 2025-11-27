/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/providers
/// Feature: User Goals
/// Type: Provider
///
/// Manages user fitness goals (workouts per week, volume targets)
/// with persistence and derived progress calculations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';

/// User fitness goals configuration
class UserGoals {
  const UserGoals({
    this.workoutsPerWeek = 2,
    this.weeklyVolumeTargetKg,
    this.streakWeeksGoal = 4,
  });

  /// Default empty goals
  static const empty = UserGoals();

  /// Target workouts per week (default: 2)
  final int workoutsPerWeek;

  /// Target weekly volume in kg (optional)
  final double? weeklyVolumeTargetKg;

  /// Target streak weeks (consecutive weeks meeting workout goal)
  final int streakWeeksGoal;

  UserGoals copyWith({
    int? workoutsPerWeek,
    double? weeklyVolumeTargetKg,
    int? streakWeeksGoal,
    bool clearVolumeTarget = false,
  }) {
    return UserGoals(
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      weeklyVolumeTargetKg:
          clearVolumeTarget ? null : (weeklyVolumeTargetKg ?? this.weeklyVolumeTargetKg),
      streakWeeksGoal: streakWeeksGoal ?? this.streakWeeksGoal,
    );
  }
}

/// Weekly workout progress data
class WeeklyWorkoutProgress {
  const WeeklyWorkoutProgress({
    required this.current,
    required this.goal,
    required this.percentage,
    required this.isComplete,
  });

  final int current;
  final int goal;
  final double percentage;
  final bool isComplete;
}

/// Weekly volume progress data
class WeeklyVolumeProgress {
  const WeeklyVolumeProgress({
    required this.currentKg,
    required this.goalKg,
    required this.percentage,
    required this.isComplete,
  });

  final double currentKg;
  final double? goalKg;
  final double percentage;
  final bool isComplete;
}

/// Streak weeks progress data
class StreakWeeksProgress {
  const StreakWeeksProgress({
    required this.current,
    required this.goal,
    required this.percentage,
    required this.isComplete,
  });

  final int current;
  final int goal;
  final double percentage;
  final bool isComplete;
}

/// Provider for user goals with persistence
final userGoalsProvider =
    AsyncNotifierProvider<UserGoalsNotifier, UserGoals>(UserGoalsNotifier.new);

/// Notifier for managing user fitness goals
class UserGoalsNotifier extends AsyncNotifier<UserGoals> {
  static const String _keyWorkoutsPerWeek = 'user_goals_workouts_per_week';
  static const String _keyWeeklyVolumeTarget = 'user_goals_weekly_volume_target';
  static const String _keyStreakWeeksGoal = 'user_goals_streak_weeks_goal';

  @override
  Future<UserGoals> build() async {
    return await _loadGoals();
  }

  /// Load goals from SharedPreferences
  Future<UserGoals> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    final workoutsPerWeek = prefs.getInt(_keyWorkoutsPerWeek) ?? 2;
    final weeklyVolumeTarget = prefs.getDouble(_keyWeeklyVolumeTarget);
    final streakWeeksGoal = prefs.getInt(_keyStreakWeeksGoal) ?? 4;

    return UserGoals(
      workoutsPerWeek: workoutsPerWeek,
      weeklyVolumeTargetKg: weeklyVolumeTarget,
      streakWeeksGoal: streakWeeksGoal,
    );
  }

  /// Save goals to SharedPreferences
  Future<void> _saveGoals(UserGoals goals) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_keyWorkoutsPerWeek, goals.workoutsPerWeek);
    if (goals.weeklyVolumeTargetKg != null) {
      await prefs.setDouble(_keyWeeklyVolumeTarget, goals.weeklyVolumeTargetKg!);
    } else {
      await prefs.remove(_keyWeeklyVolumeTarget);
    }
    await prefs.setInt(_keyStreakWeeksGoal, goals.streakWeeksGoal);
  }

  /// Update workouts per week goal
  Future<void> setWorkoutsPerWeek(int value) async {
    final currentGoals = state.valueOrNull ?? UserGoals.empty;
    final newGoals = currentGoals.copyWith(workoutsPerWeek: value.clamp(1, 7));

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _saveGoals(newGoals);
      return newGoals;
    });
  }

  /// Update weekly volume target
  Future<void> setWeeklyVolumeTarget(double? value) async {
    final currentGoals = state.valueOrNull ?? UserGoals.empty;
    final newGoals = value == null
        ? currentGoals.copyWith(clearVolumeTarget: true)
        : currentGoals.copyWith(weeklyVolumeTargetKg: value);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _saveGoals(newGoals);
      return newGoals;
    });
  }

  /// Update streak weeks goal
  Future<void> setStreakWeeksGoal(int value) async {
    final currentGoals = state.valueOrNull ?? UserGoals.empty;
    final newGoals = currentGoals.copyWith(streakWeeksGoal: value.clamp(1, 52));

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _saveGoals(newGoals);
      return newGoals;
    });
  }

  /// Reset all goals to defaults
  Future<void> resetToDefaults() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _saveGoals(UserGoals.empty);
      return UserGoals.empty;
    });
  }
}

/// Provider for weekly workout progress
///
/// Calculates how many workouts completed this week vs goal
final weeklyWorkoutProgressProvider = FutureProvider.autoDispose<WeeklyWorkoutProgress>((ref) async {
  final goalsAsync = ref.watch(userGoalsProvider);
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  final goals = goalsAsync.valueOrNull ?? UserGoals.empty;
  final workouts = workoutsAsync.valueOrNull ?? [];

  // Calculate current week boundaries (Monday to Sunday)
  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: currentWeekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  // Count workouts this week
  final workoutsThisWeek = workouts.where((w) {
    return w.completedAt.isAfter(startOfWeek) &&
        w.completedAt.isBefore(endOfWeek);
  }).length;

  final goal = goals.workoutsPerWeek;
  final percentage = goal > 0 ? (workoutsThisWeek / goal).clamp(0.0, 1.0) : 0.0;

  return WeeklyWorkoutProgress(
    current: workoutsThisWeek,
    goal: goal,
    percentage: percentage,
    isComplete: workoutsThisWeek >= goal,
  );
});

/// Provider for weekly volume progress
///
/// Calculates total volume lifted this week vs target
final weeklyVolumeProgressProvider = FutureProvider.autoDispose<WeeklyVolumeProgress>((ref) async {
  final goalsAsync = ref.watch(userGoalsProvider);
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  final goals = goalsAsync.valueOrNull ?? UserGoals.empty;
  final workouts = workoutsAsync.valueOrNull ?? [];

  // Calculate current week boundaries (Monday to Sunday)
  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: currentWeekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));

  // Calculate total volume this week
  double totalVolumeKg = 0;
  for (final workout in workouts) {
    if (workout.completedAt.isAfter(startOfWeek) &&
        workout.completedAt.isBefore(endOfWeek)) {
      // Sum volume from all exercises
      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          totalVolumeKg += set.weight * set.reps;
        }
      }
    }
  }

  final goalKg = goals.weeklyVolumeTargetKg;
  final percentage = (goalKg != null && goalKg > 0)
      ? (totalVolumeKg / goalKg).clamp(0.0, 1.0)
      : 0.0;

  return WeeklyVolumeProgress(
    currentKg: totalVolumeKg,
    goalKg: goalKg,
    percentage: percentage,
    isComplete: goalKg != null && totalVolumeKg >= goalKg,
  );
});

/// Provider for streak weeks progress
///
/// Counts consecutive weeks where workout goal was met
final streakWeeksProgressProvider = FutureProvider.autoDispose<StreakWeeksProgress>((ref) async {
  final goalsAsync = ref.watch(userGoalsProvider);
  final workoutsAsync = ref.watch(workoutHistoryProvider);

  final goals = goalsAsync.valueOrNull ?? UserGoals.empty;
  final workouts = workoutsAsync.valueOrNull ?? [];

  if (workouts.isEmpty) {
    return StreakWeeksProgress(
      current: 0,
      goal: goals.streakWeeksGoal,
      percentage: 0.0,
      isComplete: false,
    );
  }

  // Calculate streak weeks (consecutive weeks meeting workout goal)
  int streakWeeks = 0;
  final now = DateTime.now();
  final currentWeekday = now.weekday;

  // Start from current week and go backwards
  DateTime weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: currentWeekday - 1));

  // Check up to 52 weeks back
  for (int i = 0; i < 52; i++) {
    final weekEnd = weekStart.add(const Duration(days: 7));

    // Count workouts in this week
    final workoutsInWeek = workouts.where((w) {
      return w.completedAt.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
          w.completedAt.isBefore(weekEnd);
    }).length;

    if (workoutsInWeek >= goals.workoutsPerWeek) {
      streakWeeks++;
    } else {
      // If not current week and goal not met, streak ends
      if (i > 0) break;
      // For current week, continue checking past weeks
    }

    // Move to previous week
    weekStart = weekStart.subtract(const Duration(days: 7));
  }

  final goal = goals.streakWeeksGoal;
  final percentage = goal > 0 ? (streakWeeks / goal).clamp(0.0, 1.0) : 0.0;

  return StreakWeeksProgress(
    current: streakWeeks,
    goal: goal,
    percentage: percentage,
    isComplete: streakWeeks >= goal,
  );
});

/// Quick access provider for current workouts per week goal
final workoutsPerWeekGoalProvider = Provider<int>((ref) {
  final goals = ref.watch(userGoalsProvider);
  return goals.valueOrNull?.workoutsPerWeek ?? 2;
});

/// Quick access provider for current weekly volume target
final weeklyVolumeTargetProvider = Provider<double?>((ref) {
  final goals = ref.watch(userGoalsProvider);
  return goals.valueOrNull?.weeklyVolumeTargetKg;
});
