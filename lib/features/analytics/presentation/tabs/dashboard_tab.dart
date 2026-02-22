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
      padding: EdgeInsets.only(
        bottom: AppSpacing.xs + context.tabBarInset,
      ),
      children: [
        WeeklySummaryBanner(exerciseHistories: exerciseHistories),
        const SizedBox(height: AppSpacing.xs),
        QuickStatsSummary(exerciseHistories: exerciseHistories),
        const SizedBox(height: AppSpacing.sm),
        _MuscleBodyMapCard(exerciseHistories: exerciseHistories),
      ],
    );
  }
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
        if (!dateOnly.isBefore(currentWeekStart) &&
            !dateOnly.isAfter(today)) {
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
    int currentPRCount = 0;

    // Previous week (days 7-13 ago)
    final previousWeekStart = today.subtract(const Duration(days: 13));
    final previousWeekEnd = today.subtract(const Duration(days: 7));
    int previousPRCount = 0;

    for (final history in exerciseHistories) {
      if (history.sessions.isEmpty) continue;

      final pr = history.personalRecord;

      // Count PRs in current week
      for (final session in history.sessions) {
        final sessionDate = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (!sessionDate.isBefore(currentWeekStart) &&
            !sessionDate.isAfter(today) &&
            session.highestEstimated1RM >= pr * 0.99) {
          currentPRCount++;
          break; // Count once per exercise
        }
      }

      // Count PRs in previous week
      for (final session in history.sessions) {
        final sessionDate = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (!sessionDate.isBefore(previousWeekStart) &&
            !sessionDate.isAfter(previousWeekEnd) &&
            session.highestEstimated1RM >= pr * 0.99) {
          previousPRCount++;
          break; // Count once per exercise
        }
      }
    }

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

    int prCount = 0;

    for (final history in exerciseHistories) {
      if (history.sessions.isEmpty) continue;

      // Find personal record (highest 1RM)
      final pr = history.personalRecord;

      // Check if any session in last 7 days achieved this PR
      for (final session in history.sessions) {
        final sessionDate = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        if (!sessionDate.isBefore(weekStart) &&
            !sessionDate.isAfter(today) &&
            session.highestEstimated1RM >= pr * 0.99) {
          // Within 1% of PR (accounts for rounding)
          prCount++;
          break; // Count once per exercise
        }
      }
    }

    return prCount;
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
    final weekAgo = now.subtract(const Duration(days: 7));

    int prs = 0;
    for (final history in exerciseHistories) {
      final recentSessions =
          history.sessions.where((s) => s.date.isAfter(weekAgo)).toList();

      if (recentSessions.isNotEmpty) {
        final recentMaxWeight = recentSessions
            .map((s) => s.highestEstimated1RM)
            .reduce((a, b) => a > b ? a : b);
        final olderSessions =
            history.sessions.where((s) => s.date.isBefore(weekAgo)).toList();

        if (olderSessions.isNotEmpty) {
          final previousMaxWeight = olderSessions
              .map((s) => s.highestEstimated1RM)
              .reduce((a, b) => a > b ? a : b);
          if (recentMaxWeight > previousMaxWeight) {
            prs++;
          }
        } else if (recentMaxWeight > 0) {
          prs++; // First ever PR
        }
      }
    }
    return prs;
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
    } else if (weeklyWorkouts >= 4 &&
        recentPRs >= 1 &&
        volumeProgression > 0) {
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
            Icon(
              icon,
              color: context.colors.primary,
              size: AppIconSize.large,
            ),
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
                Icon(
                  AppIcons.accessibility,
                  color: context.colors.primary,
                ),
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
