/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Weekly Stats Bottom Sheet
/// Type: Widget
///
/// Shows weekly statistics when tapping the weekly calendar.
/// Displays workouts, volume, time, and sets for the current week.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Shows the weekly stats bottom sheet
void showWeeklyStatsBottomSheet(BuildContext context) {
  HapticFeedback.lightImpact();
  ModalService.showSheet(context,
    isScrollControlled: true,
    builder: (context) => const _WeeklyStatsBottomSheetContent(),
  );
}

/// Content of the weekly stats bottom sheet
class _WeeklyStatsBottomSheetContent extends ConsumerWidget {
  const _WeeklyStatsBottomSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    // Get current week dates (Monday to Sunday)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    // Filter workouts for this week
    final thisWeekWorkouts =
        workoutsAsync.value?.where((w) {
          final workoutDate = DateTime(
            w.completedAt.year,
            w.completedAt.month,
            w.completedAt.day,
          );
          final mondayDate = DateTime(monday.year, monday.month, monday.day);
          final sundayDate = DateTime(sunday.year, sunday.month, sunday.day);
          return workoutDate.isAfter(
                mondayDate.subtract(const Duration(days: 1)),
              ) &&
              workoutDate.isBefore(sundayDate.add(const Duration(days: 1)));
        }).toList() ??
        [];

    // Calculate stats
    final totalWorkouts = thisWeekWorkouts.length;
    final totalVolume = thisWeekWorkouts.fold<double>(
      0.0,
      (sum, w) => sum + w.totalVolume,
    );
    final totalTime = thisWeekWorkouts.fold<Duration>(
      Duration.zero,
      (sum, w) => sum + w.duration,
    );
    final totalSets = thisWeekWorkouts.fold<int>(
      0,
      (sum, w) => sum + w.totalSets,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.calendar,
                    size: AppIconSize.medium,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.thisWeek,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: AppIcons.workout,
                      value: '$totalWorkouts',
                      label: context.l10n.workouts,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: AppIcons.barChart,
                      value: '${(totalVolume / 1000).toStringAsFixed(1)}t',
                      label: context.l10n.volume,
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: AppIcons.timer,
                      value: _formatDuration(totalTime),
                      label: context.l10n.time,
                      color: context.colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: AppIcons.repeat,
                      value: '$totalSets',
                      label: context.l10n.sets,
                      color: context.colors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Motivational message
            if (totalWorkouts > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text('💪', style: context.textTheme.headlineSmall),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMotivationalMessage(context, totalWorkouts),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _getMotivationalMessage(BuildContext context, int workouts) {
    if (workouts >= 5) {
      return context.l10n.weeklyStatsExcellent;
    } else if (workouts >= 3) {
      return context.l10n.weeklyStatsGreat;
    } else if (workouts >= 1) {
      return context.l10n.weeklyStatsGood;
    }
    return context.l10n.weeklyStatsStart;
  }
}

/// Individual stat card
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppIconSize.medium, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
