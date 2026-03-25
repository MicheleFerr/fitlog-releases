/// GymBro TrackLog - Flutter Fitness App
///
/// Dashboard Tab - Weekly overview for Statistics page
///
/// Shows:
/// 1. Weekly Summary Banner (natural language weekly performance)
/// 2. Quick Stats Summary (streak, volume, weekly goal, PRs)
/// 3. Muscle Body Map Card (heatmap of muscles trained this week)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/streak_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/weekly_modal.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/rep_zone_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Dashboard Tab - Main overview tab for Statistics page
///
/// Displays weekly summary, quick stats, and muscle body map.
class DashboardTab extends ConsumerWidget {
  const DashboardTab({
    required this.exerciseHistories,
    required this.userId,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.only(bottom: AppSpacing.xs + context.tabBarInset),
      children: [
        WeeklySummaryBanner(exerciseHistories: exerciseHistories),
        const SizedBox(height: AppSpacing.xs),
        QuickStatsSummary(exerciseHistories: exerciseHistories),
        const SizedBox(height: AppSpacing.sm),
        _MuscleBodyMapCard(exerciseHistories: exerciseHistories),
        const SizedBox(height: AppSpacing.sm),
        _VolumeCard(exerciseHistories: exerciseHistories),
        const SizedBox(height: AppSpacing.sm),
        _RepZoneCard(exerciseHistories: exerciseHistories),
      ],
    );
  }
}

DateTime _dashboardDateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

bool _isWithinDashboardRange(DateTime date, DateTime start, DateTime end) {
  final value = _dashboardDateOnly(date);
  return !value.isBefore(start) && !value.isAfter(end);
}

double? _maxSession1RM(Iterable<ExerciseSession> sessions) {
  double? maxValue;
  for (final session in sessions) {
    final value = session.highestEstimated1RM;
    if (maxValue == null || value > maxValue) {
      maxValue = value;
    }
  }
  return maxValue;
}

bool _hasNewPrInWindow(
  ExerciseHistory history, {
  required DateTime start,
  required DateTime end,
}) {
  final sessionsInWindow = history.sessions
      .where((session) => _isWithinDashboardRange(session.date, start, end))
      .toList();

  if (sessionsInWindow.isEmpty) {
    return false;
  }

  final currentMax = _maxSession1RM(sessionsInWindow);
  if (currentMax == null || currentMax <= 0) {
    return false;
  }

  final previousMax = _maxSession1RM(
    history.sessions.where(
      (session) => _dashboardDateOnly(session.date).isBefore(start),
    ),
  );

  return previousMax == null ? true : currentMax > previousMax;
}

int _countNewPrsInWindow(
  List<ExerciseHistory> exerciseHistories, {
  required DateTime start,
  required DateTime end,
}) {
  return exerciseHistories
      .where((history) => _hasNewPrInWindow(history, start: start, end: end))
      .length;
}

// ============================================================================
// QuickStatsSummary - Hybrid Motivator Card
// ============================================================================

/// Hybrid Motivator Card - Combines gamification + analytics
/// Shows: Streak, Weekly Goal, Volume Trend, Recent PRs
class QuickStatsSummary extends ConsumerWidget {
  const QuickStatsSummary({required this.exerciseHistories, super.key});

  final List<ExerciseHistory> exerciseHistories;

  /// Calculate current streak (consecutive days with workouts)
  int _calculateStreak() {
    if (exerciseHistories.isEmpty) return 0;

    // Get all unique workout dates (across all exercises)
    final allDates = <DateTime>{};
    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        // Normalize to date only (remove time)
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        allDates.add(dateOnly);
      }
    }

    // Sort dates descending (newest first)
    final sortedDates = allDates.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Check if most recent workout is today or yesterday
    final mostRecent = sortedDates.first;
    final daysSinceRecent = todayOnly.difference(mostRecent).inDays;

    // If last workout was more than 1 day ago, streak is broken
    if (daysSinceRecent > 1) return 0;

    // Count consecutive days backwards from most recent
    int streak = 1;
    DateTime expectedDate = mostRecent.subtract(const Duration(days: 1));

    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        // Gap in streak, stop counting
        break;
      }
    }

    return streak;
  }

  /// Calculate workouts this week (last 7 days including today)
  int _calculateWeeklyWorkouts() {
    final now = DateTime.now();
    // Use date-only comparison (no time component) for consistency
    final today = DateTime(now.year, now.month, now.day);
    // 6 days back = 7 day range (today + 6 previous days)
    final weekStart = today.subtract(const Duration(days: 6));

    final weeklyDates = <DateTime>{};
    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        // Include if within [weekStart, today] inclusive
        if (!dateOnly.isBefore(weekStart) && !dateOnly.isAfter(today)) {
          weeklyDates.add(dateOnly);
        }
      }
    }

    return weeklyDates.length;
  }

  /// Calculate weekly workouts delta (current week vs previous week)
  int _calculateWeeklyDelta() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Current week (last 7 days)
    final currentWeekStart = today.subtract(const Duration(days: 6));
    final currentWeekDates = <DateTime>{};

    // Previous week (days 7-13 ago)
    final previousWeekStart = today.subtract(const Duration(days: 13));
    final previousWeekEnd = today.subtract(const Duration(days: 7));
    final previousWeekDates = <DateTime>{};

    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );

        // Current week
        if (!dateOnly.isBefore(currentWeekStart) && !dateOnly.isAfter(today)) {
          currentWeekDates.add(dateOnly);
        }

        // Previous week
        if (!dateOnly.isBefore(previousWeekStart) &&
            !dateOnly.isAfter(previousWeekEnd)) {
          previousWeekDates.add(dateOnly);
        }
      }
    }

    return currentWeekDates.length - previousWeekDates.length;
  }

  /// Calculate streak delta (current streak vs one week ago streak)
  ///
  /// Simplified implementation: Checks if user worked out 7 days ago
  /// - If yes -> delta +1 (streak maintained/improved)
  /// - If no -> delta 0 (new streak or gap)
  int _calculateStreakDelta() {
    if (exerciseHistories.isEmpty) return 0;

    // Get all unique workout dates
    final allDates = <DateTime>{};
    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        allDates.add(dateOnly);
      }
    }

    if (allDates.isEmpty) return 0;

    // Check if there was a workout 7 days ago (with +/-1 day tolerance)
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 7));

    final sixDaysAgo = sevenDaysAgo.subtract(const Duration(days: 1));
    final eightDaysAgo = sevenDaysAgo.add(const Duration(days: 1));

    // Check if any workout exists in the range [8 days ago, 6 days ago]
    final hadWorkoutWeekAgo = allDates.any(
      (date) => !date.isBefore(sixDaysAgo) && !date.isAfter(eightDaysAgo),
    );

    // Simple logic:
    // - If workout 7 days ago: streak maintained (+1)
    // - If no workout 7 days ago: new streak or break (0)
    return hadWorkoutWeekAgo ? 1 : 0;
  }

  /// Calculate PR delta (this week vs previous week)
  int _calculatePRDelta() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Current week (last 7 days)
    final currentWeekStart = today.subtract(const Duration(days: 6));

    // Previous week (days 7-13 ago)
    final previousWeekStart = today.subtract(const Duration(days: 13));
    final previousWeekEnd = today.subtract(const Duration(days: 7));
    final currentPRCount = _countNewPrsInWindow(
      exerciseHistories,
      start: currentWeekStart,
      end: today,
    );
    final previousPRCount = _countNewPrsInWindow(
      exerciseHistories,
      start: previousWeekStart,
      end: previousWeekEnd,
    );

    return currentPRCount - previousPRCount;
  }

  /// Calculate average weekly volume progression across all exercises
  double _calculateVolumeProgression() {
    if (exerciseHistories.isEmpty) return 0;

    final progressions = exerciseHistories
        .map((h) => h.weeklyVolumeProgression)
        .where((p) => p != 0) // Exclude exercises with no baseline
        .toList();

    if (progressions.isEmpty) return 0;

    final avgProgression =
        progressions.reduce((a, b) => a + b) / progressions.length;
    return avgProgression;
  }

  /// Calculate recent PRs (last 7 days including today)
  int _calculateRecentPRs() {
    final now = DateTime.now();
    // Use date-only comparison (no time component) for consistency
    final today = DateTime(now.year, now.month, now.day);
    // 6 days back = 7 day range (today + 6 previous days)
    final weekStart = today.subtract(const Duration(days: 6));
    return _countNewPrsInWindow(
      exerciseHistories,
      start: weekStart,
      end: today,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = _calculateStreak();
    final weeklyWorkouts = _calculateWeeklyWorkouts();
    final volumeProgression = _calculateVolumeProgression();
    final recentPRs = _calculateRecentPRs();
    final weeklyGoal = ref.watch(weeklyWorkoutGoalProvider);

    // Calculate deltas for each metric
    final streakDelta = _calculateStreakDelta();
    final weeklyDelta = _calculateWeeklyDelta();
    final prDelta = _calculatePRDelta();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primaryContainer,
            context.colors.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Streak
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.streak,
              label: context.l10n.streak,
              value: '$streak',
              suffix: streak == 1 ? context.l10n.day : context.l10n.days,
              color: context.colors.onPrimaryContainer,
              trend: streakDelta > 0
                  ? 'up'
                  : streakDelta < 0
                  ? 'down'
                  : null,
              trendColor: streakDelta > 0
                  ? context.colors.success
                  : streakDelta < 0
                  ? context.colors.warning
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(
                  context,
                  isScrollControlled: true,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => StreakModal(
                      exerciseHistories: exerciseHistories,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),

          // Volume (vs last week comparison)
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.trendUp,
              label: '${context.l10n.volume} (${context.l10n.vsLastWeek})',
              value: volumeProgression >= 0
                  ? '+${volumeProgression.toStringAsFixed(0)}'
                  : volumeProgression.toStringAsFixed(0),
              suffix: '%',
              color: context.colors.onPrimaryContainer,
              trend: volumeProgression >= 0 ? 'up' : 'down',
              trendColor: volumeProgression >= 0
                  ? context.colors.success
                  : context.colors.error,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(
                  context,
                  isScrollControlled: true,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => VolumeModal(
                      exerciseHistories: exerciseHistories,
                      volumeProgression: volumeProgression,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),

          // Weekly (configurable goal)
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.calendar,
              label: context.l10n.weekly,
              value: '$weeklyWorkouts',
              suffix: '/$weeklyGoal ${context.l10n.workouts.toLowerCase()}',
              color: context.colors.onPrimaryContainer,
              trend: weeklyDelta > 0
                  ? 'up'
                  : weeklyDelta < 0
                  ? 'down'
                  : null,
              trendColor: weeklyDelta > 0
                  ? context.colors.success
                  : weeklyDelta < 0
                  ? context.colors.warning
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(
                  context,
                  isScrollControlled: true,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => WeeklyModal(
                      exerciseHistories: exerciseHistories,
                      weeklyWorkouts: weeklyWorkouts,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),

          // PR
          Expanded(
            child: _HybridStatItem(
              icon: AppIcons.achievement,
              label: '${context.l10n.pr} (7 ${context.l10n.days})',
              value: '$recentPRs',
              suffix: recentPRs == 1
                  ? context.l10n.newSingular
                  : context.l10n.newPlural,
              color: context.colors.onPrimaryContainer,
              trend: prDelta > 0
                  ? 'up'
                  : prDelta < 0
                  ? 'down'
                  : null,
              trendColor: prDelta > 0
                  ? context.colors.success
                  : prDelta < 0
                  ? context.colors.warning
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                ModalService.showSheet(
                  context,
                  isScrollControlled: true,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.8,
                    minChildSize: 0.8,
                    maxChildSize: 1.0,
                    expand: false,
                    snap: true,
                    builder: (context, scrollController) => PRModal(
                      exerciseHistories: exerciseHistories,
                      recentPRCount: recentPRs,
                      scrollController: scrollController,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WeeklySummaryBanner
// ============================================================================

/// Weekly summary banner - Natural language summary of weekly performance
class WeeklySummaryBanner extends ConsumerWidget {
  const WeeklySummaryBanner({required this.exerciseHistories, super.key});

  final List<ExerciseHistory> exerciseHistories;

  /// Calculate workouts this week (last 7 days)
  int _calculateWeeklyWorkouts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));

    final weeklyDates = <DateTime>{};
    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (!dateOnly.isBefore(weekStart) && !dateOnly.isAfter(today)) {
          weeklyDates.add(dateOnly);
        }
      }
    }
    return weeklyDates.length;
  }

  /// Calculate recent PRs (last 7 days)
  int _calculateRecentPRs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));
    return _countNewPrsInWindow(
      exerciseHistories,
      start: weekStart,
      end: today,
    );
  }

  /// Calculate average volume progression
  double _calculateVolumeProgression() {
    if (exerciseHistories.isEmpty) return 0;

    final progressions = exerciseHistories
        .map((h) => h.weeklyVolumeProgression)
        .where((p) => p != 0)
        .toList();

    if (progressions.isEmpty) return 0;

    return progressions.reduce((a, b) => a + b) / progressions.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (exerciseHistories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primaryContainer.withValues(alpha: 0.5),
                context.colors.tertiaryContainer.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.celebration,
                color: context.colors.primary,
                size: AppIconSize.large,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.weeklySummaryFirstWeek,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final weeklyWorkouts = _calculateWeeklyWorkouts();
    final recentPRs = _calculateRecentPRs();
    final volumeProgression = _calculateVolumeProgression();

    // Determine summary category
    String message;
    IconData icon;
    List<Color> gradientColors;

    if (weeklyWorkouts == 0) {
      message = context.l10n.weeklySummaryNoRecent;
      icon = AppIcons.clock;
      gradientColors = [
        context.colors.surfaceContainer,
        context.colors.surfaceContainer,
      ];
    } else if (weeklyWorkouts >= 4 && recentPRs >= 1 && volumeProgression > 0) {
      // Strong week
      message = context.l10n.weeklySummaryStrong(
        weeklyWorkouts,
        recentPRs,
        volumeProgression.toStringAsFixed(0),
      );
      icon = AppIcons.celebration;
      gradientColors = [
        context.colors.successContainer.withValues(alpha: 0.6),
        context.colors.primaryContainer.withValues(alpha: 0.4),
      ];
    } else if (weeklyWorkouts == 1) {
      // Weak week
      message = context.l10n.weeklySummaryWeak(weeklyWorkouts);
      icon = AppIcons.trendFlat;
      gradientColors = [
        context.colors.surfaceContainer,
        context.colors.surfaceContainer.withValues(alpha: 0.8),
      ];
    } else {
      // Normal week
      message = context.l10n.weeklySummaryNormal(weeklyWorkouts);
      icon = AppIcons.check;
      gradientColors = [
        context.colors.primaryContainer.withValues(alpha: 0.4),
        context.colors.secondaryContainer.withValues(alpha: 0.3),
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.colors.primary, size: AppIconSize.large),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Muscle Body Map Card (NEW)
// ============================================================================

/// Card showing a weekly muscle heatmap using ProfessionalBodyHeatmap
class _MuscleBodyMapCard extends StatelessWidget {
  const _MuscleBodyMapCard({required this.exerciseHistories});

  final List<ExerciseHistory> exerciseHistories;

  /// Calculate weekly muscle heat data from exercise histories
  ///
  /// Filters sessions from last 7 days, groups by muscleGroup,
  /// counts sets per muscle, normalizes to percentages (0-100).
  Map<String, double> _calculateWeeklyMuscleHeat() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));

    // Count sets per muscle group in the last 7 days
    final setsPerMuscle = <String, int>{};

    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (!dateOnly.isBefore(weekStart) && !dateOnly.isAfter(today)) {
          final muscleGroup = history.muscleGroup.toLowerCase();
          setsPerMuscle[muscleGroup] =
              (setsPerMuscle[muscleGroup] ?? 0) + session.sets.length;
        }
      }
    }

    if (setsPerMuscle.isEmpty) return {};

    // Find max sets for normalization
    final maxSets = setsPerMuscle.values.reduce((a, b) => a > b ? a : b);
    if (maxSets == 0) return {};

    // Normalize to 0-100 percentage
    final heatData = <String, double>{};
    for (final entry in setsPerMuscle.entries) {
      heatData[entry.key] = (entry.value / maxSets) * 100;
    }

    return heatData;
  }

  @override
  Widget build(BuildContext context) {
    final heatData = _calculateWeeklyMuscleHeat();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(AppIcons.accessibility, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.weeklyMuscleMap,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Body: Heatmap or empty state
            if (heatData.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    context.l10n.noWorkoutDataThisWeek,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: ProfessionalBodyHeatmap(
                  heatValues: MuscleHeatValues(heatData),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Volume Card
// ============================================================================

/// Card showing weekly volume in kg with a 4-week sparkline and trend badge
class _VolumeCard extends StatelessWidget {
  const _VolumeCard({required this.exerciseHistories});

  final List<ExerciseHistory> exerciseHistories;

  /// Calcola il volume totale (kg) per una finestra temporale
  double _volumeForWindow(DateTime start, DateTime end) {
    double total = 0;
    for (final history in exerciseHistories) {
      for (final session in history.sessions) {
        if (!session.date.isBefore(start) && !session.date.isAfter(end)) {
          total += session.totalVolume;
        }
      }
    }
    return total;
  }

  /// Volume kg questa settimana (last 7 days)
  double _calculateWeeklyVolumeKg() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));
    return _volumeForWindow(weekStart, today.add(const Duration(days: 1)));
  }

  /// Ultime 4 settimane per sparkline (oldest → newest)
  List<double> _calculateWeeklyVolumeHistory() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <double>[];
    for (int i = 3; i >= 0; i--) {
      final end = today.subtract(Duration(days: i * 7));
      final start = end.subtract(const Duration(days: 6));
      result.add(_volumeForWindow(start, end.add(const Duration(days: 1))));
    }
    return result;
  }

  /// Trend % vs settimana scorsa
  double _calculateTrendPercent() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(const Duration(days: 6));
    final prevWeekEnd = today.subtract(const Duration(days: 7));
    final prevWeekStart = today.subtract(const Duration(days: 13));

    final thisWeek = _volumeForWindow(
      thisWeekStart,
      today.add(const Duration(days: 1)),
    );
    final prevWeek = _volumeForWindow(
      prevWeekStart,
      prevWeekEnd.add(const Duration(days: 1)),
    );

    if (prevWeek == 0) return 0;
    return ((thisWeek - prevWeek) / prevWeek) * 100;
  }

  String _formatVolume(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}t';
    }
    return '${kg.toStringAsFixed(0)} kg';
  }

  @override
  Widget build(BuildContext context) {
    final weeklyKg = _calculateWeeklyVolumeKg();
    final history = _calculateWeeklyVolumeHistory();
    final trend = _calculateTrendPercent();

    final maxVal = history.isEmpty
        ? 1.0
        : history.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxVal == 0 ? 1.0 : maxVal;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: InkWell(
        borderRadius: AppBorderRadius.mdRadius,
        onTap: () {
          ModalService.showSheet(
            context,
            isScrollControlled: true,
            builder: (_) => DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.8,
              maxChildSize: 1.0,
              expand: false,
              snap: true,
              builder: (ctx, scrollController) => VolumeModal(
                exerciseHistories: exerciseHistories,
                volumeProgression: trend,
                scrollController: scrollController,
              ),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(AppIcons.exercise, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.weeklyVolumeCard,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (weeklyKg == 0)
                Text(
                  context.l10n.noWorkoutDataThisWeek,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                )
              else ...[
                // Value + trend badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatVolume(weeklyKg),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (trend != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: trend >= 0
                              ? context.colors.successContainer
                              : context.colors.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trend >= 0
                              ? '+${trend.toStringAsFixed(0)}%'
                              : '${trend.toStringAsFixed(0)}%',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: trend >= 0
                                ? context.colors.success
                                : context.colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Sparkline — 4 settimane
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: history.map((val) {
                    final height = (val / effectiveMax) * 40;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          height: height.clamp(4.0, 40.0),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(
                              alpha: val == maxVal ? 1.0 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Rep Zone Card
// ============================================================================

/// Card showing rep zone distribution (Strength / Hypertrophy / Endurance)
class _RepZoneCard extends ConsumerWidget {
  const _RepZoneCard({required this.exerciseHistories});

  final List<ExerciseHistory> exerciseHistories;

  Color _zoneColor(RepZone zone, BuildContext context) {
    switch (zone) {
      case RepZone.strength:
        return context.colors.primary;
      case RepZone.hypertrophy:
        return context.colors.tertiary;
      case RepZone.endurance:
        return context.colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(repZoneAnalysisProvider(exerciseHistories));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mdRadius),
      child: InkWell(
        borderRadius: AppBorderRadius.mdRadius,
        onTap: () => context.push(AppRoutes.proAnalyticsPath),
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(AppIcons.analytics, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.repZoneCard,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (analysis.totalSets == 0)
                Text(
                  context.l10n.noWorkoutDataThisWeek,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                )
              else ...[
                // Zone strip
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      for (final zone in RepZone.values)
                        _buildZoneSegment(context, zone, analysis),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Legend row
                Row(
                  children: RepZone.values.map((zone) {
                    final pct = analysis.getPercentage(zone);
                    return Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _zoneColor(zone, context),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${zone.label} ${pct.toStringAsFixed(0)}%',
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: context.colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Dominant zone label
                if (analysis.dominantZone != null)
                  Text(
                    context.l10n.dominantZoneLabel(
                      analysis.dominantZone!.label,
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneSegment(
    BuildContext context,
    RepZone zone,
    RepZoneAnalysis analysis,
  ) {
    final pct = analysis.getPercentage(zone);
    if (pct < 1) return const SizedBox.shrink();

    return Expanded(
      flex: pct.round().clamp(1, 100),
      child: Container(
        height: 28,
        color: _zoneColor(zone, context),
        alignment: Alignment.center,
        child: pct >= 10
            ? Text(
                '${pct.toStringAsFixed(0)}%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              )
            : null,
      ),
    );
  }
}

// ============================================================================
// Private Helper Widgets
// ============================================================================

/// Animated counter widget - Smoothly animates from 0 to target value
/// **Used in**: Quick Stats card for dynamic number animation
class _AnimatedCounter extends StatefulWidget {
  const _AnimatedCounter({required this.value, required this.style});

  final String value; // Can be "123", "12.5t", etc.
  final TextStyle? style;

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _targetValue = 0;
  String _suffix = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _parseValueAndAnimate();
  }

  @override
  void didUpdateWidget(_AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _parseValueAndAnimate();
    }
  }

  void _parseValueAndAnimate() {
    // Extract number and suffix (e.g., "12.5t" -> 12.5 + "t")
    final match = RegExp(r'([\d.]+)(.*)').firstMatch(widget.value);
    if (match != null) {
      _targetValue = double.tryParse(match.group(1)!) ?? 0;
      _suffix = match.group(2)!;

      _animation = Tween<double>(begin: 0, end: _targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Format based on suffix
        final currentValue = _animation.value;
        final formattedValue = _suffix == 't'
            ? currentValue.toStringAsFixed(1) // Decimal for tons
            : currentValue.toInt().toString(); // Integer for counts

        return Text('$formattedValue$_suffix', style: widget.style);
      },
    );
  }
}

/// Hybrid stat item - compact horizontal layout with optional trend indicator
class _HybridStatItem extends StatelessWidget {
  const _HybridStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    this.trend,
    this.trendColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  final Color color;
  final String? trend; // 'up', 'down', or null
  final Color? trendColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Label
              Row(
                children: [
                  SemanticIcon(
                    icon: icon,
                    semanticLabel: label,
                    size: AppIconSize.tiny,
                    color: color.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Trend indicator (if provided)
                  if (trend != null && trendColor != null)
                    SemanticIcon(
                      icon: trend == 'up'
                          ? AppIcons.trendingUp
                          : AppIcons.trendingDown,
                      semanticLabel: trend == 'up' ? 'Aumentato' : 'Diminuito',
                      size: AppIconSize.tiny,
                      color: trendColor!,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),

              // Value + Suffix
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      suffix,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.6),
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
