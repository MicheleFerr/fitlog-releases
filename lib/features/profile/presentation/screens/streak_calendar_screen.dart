/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/screens
/// Feature: Streak Calendar
/// Type: Screen
///
/// Full-screen streak calendar with GitHub-style contribution visualization.
/// Shows workout history in monthly, annual, and multi-year views.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// View modes for streak visualization
enum _StreakViewMode {
  monthly,
  annual,
  multiYear,
}

/// Extension for localized labels
extension _StreakViewModeExtension on _StreakViewMode {
  String getLabel(BuildContext context) {
    switch (this) {
      case _StreakViewMode.monthly:
        return context.l10n.streakViewMonthly;
      case _StreakViewMode.annual:
        return context.l10n.streakViewAnnual;
      case _StreakViewMode.multiYear:
        return context.l10n.streakViewMultiYear;
    }
  }
}

/// Streak calendar screen with GitHub-style contribution calendar
class StreakCalendarScreen extends ConsumerStatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  ConsumerState<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends ConsumerState<StreakCalendarScreen> {
  _StreakViewMode _viewMode = _StreakViewMode.monthly;
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.calendar),
        leading: IconButton(
          icon: Icon(AppIcons.arrowBackIos, size: AppIconSize.medium),
          onPressed: () => context.pop(),
        ),
        actions: [
          // View mode dropdown
          PopupMenuButton<_StreakViewMode>(
            icon: Icon(AppIcons.viewList, size: AppIconSize.medium),
            tooltip: context.l10n.viewMode,
            onSelected: (mode) {
              HapticFeedback.selectionClick();
              setState(() {
                _viewMode = mode;
              });
            },
            itemBuilder: (context) => _StreakViewMode.values.map((mode) {
              return PopupMenuItem(
                value: mode,
                child: Row(
                  children: [
                    if (mode == _viewMode)
                      Icon(AppIcons.check, size: AppIconSize.small, color: context.colors.primary)
                    else
                      SizedBox(width: AppIconSize.small),
                    const SizedBox(width: 8),
                    Text(mode.getLabel(context)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: workoutsAsync.when(
        data: (workouts) => _buildContent(context, workouts),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: Text(
            context.l10n.errorLoadingData,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<WorkoutHistoryDetail> workouts) {
    // Extract workout dates
    final workoutDates = <DateTime>{};
    for (final workout in workouts) {
      workoutDates.add(DateTime(
        workout.completedAt.year,
        workout.completedAt.month,
        workout.completedAt.day,
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards (Total workouts + Days since last workout)
          _buildStatsCards(context, workouts, workoutDates),
          const SizedBox(height: 24),

          // Calendar view based on mode
          switch (_viewMode) {
            _StreakViewMode.monthly => _buildMonthlyView(context, workoutDates),
            _StreakViewMode.annual => _buildAnnualView(context, workoutDates),
            _StreakViewMode.multiYear => _buildMultiYearView(context, workoutDates),
          },
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    List<WorkoutHistoryDetail> workouts,
    Set<DateTime> workoutDates,
  ) {
    final daysSinceLastWorkout = _calculateDaysSinceLastWorkout(workoutDates);

    return Row(
      children: [
        // Total workouts
        Expanded(
          child: _EmojiStatCard(
            emoji: '💪',
            label: context.l10n.totalWorkouts,
            value: '${workouts.length}',
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        // Days since last workout (riposo)
        Expanded(
          child: _EmojiStatCard(
            emoji: '⏱️',
            label: context.l10n.daysSinceLastWorkout,
            value: '$daysSinceLastWorkout',
            color: daysSinceLastWorkout == 0
                ? context.colors.primary // Worked out today
                : daysSinceLastWorkout <= 2
                    ? context.colors.primary // Recent
                    : context.colors.error, // Warning - need to workout
          ),
        ),
      ],
    );
  }

  /// Calculate days since last workout
  int _calculateDaysSinceLastWorkout(Set<DateTime> workoutDates) {
    if (workoutDates.isEmpty) return 0;

    // Find most recent workout date
    final mostRecentWorkout = workoutDates.reduce((a, b) => a.isAfter(b) ? a : b);

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Calculate days since last workout
    final daysSince = todayOnly.difference(mostRecentWorkout).inDays;

    // Return 0 if workout was today
    return daysSince < 0 ? 0 : daysSince;
  }

  Widget _buildMonthlyView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Month navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(AppIcons.arrowBackIos, size: AppIconSize.small),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
              },
            ),
            Text(
              DateFormat.yMMMM(context.l10n.localeName).format(_selectedMonth),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(AppIcons.arrowForwardIos, size: AppIconSize.small),
              onPressed: _selectedMonth.month == now.month && _selectedMonth.year == now.year
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                      });
                    },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekday headers
        Row(
          children: ['L', 'M', 'M', 'G', 'V', 'S', 'D'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) {
              return const SizedBox(); // Empty space before first day
            }

            final day = index - (firstWeekday - 1) + 1;
            final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
            final hasWorkout = workoutDates.contains(date);
            final isToday = date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;
            final isFuture = date.isAfter(now);

            return Container(
              decoration: BoxDecoration(
                color: hasWorkout
                    ? context.colors.primary
                    : (isToday
                        ? context.colors.primaryContainer
                        : context.colors.surfaceContainerHighest),
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(color: context.colors.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: hasWorkout
                        ? context.colors.onPrimary
                        : (isFuture
                            ? context.colors.onSurfaceVariant.withValues(alpha: 0.5)
                            : context.colors.onSurface),
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          },
        ),

        // Legend
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: context.colors.surfaceContainerHighest,
              label: context.l10n.noWorkout,
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: context.colors.primary,
              label: context.l10n.workoutCompleted,
            ),
          ],
        ),
      ],
    );
  }

  /// GitHub-style annual view: 3x4 grid with mini heatmaps per month
  Widget _buildAnnualView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final currentYear = now.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$currentYear',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // GitHub-style 3x4 grid of mini month heatmaps
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: 12,
          itemBuilder: (context, monthIndex) {
            final month = monthIndex + 1;
            return _buildMiniMonthHeatmap(context, currentYear, month, workoutDates);
          },
        ),
      ],
    );
  }

  /// Mini month heatmap for GitHub-style annual view
  Widget _buildMiniMonthHeatmap(
    BuildContext context,
    int year,
    int month,
    Set<DateTime> workoutDates,
  ) {
    // Short month names
    final monthNames = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];
    final monthName = monthNames[month - 1];

    // Calculate days in month
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    // Total cells
    final totalCells = daysInMonth + (startWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedMonth = DateTime(year, month);
          _viewMode = _StreakViewMode.monthly;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month name
          Text(
            monthName,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Mini heatmap grid
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: rows * 7,
              itemBuilder: (context, index) {
                final dayNumber = index - (startWeekday - 1) + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(year, month, dayNumber);
                final hasWorkout = workoutDates.contains(date);
                final today = DateTime.now();
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                return Container(
                  decoration: BoxDecoration(
                    color: hasWorkout
                        ? context.colors.primary
                        : context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                    border: isToday
                        ? Border.all(
                            color: context.colors.primary,
                            width: 1,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// GitHub-style multi-year view: horizontal strip for each year
  Widget _buildMultiYearView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final years = <int>{};
    for (final date in workoutDates) {
      years.add(date.year);
    }
    years.add(now.year); // Always include current year
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

    // Month names for header
    final monthNames = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with month labels
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Year label spacer
              const SizedBox(width: 60),
              ...List.generate(12, (index) {
                return SizedBox(
                  width: 50,
                  child: Text(
                    monthNames[index],
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Year strips
        ...sortedYears.take(5).map((year) {
          return _buildYearStrip(context, year, workoutDates);
        }),
      ],
    );
  }

  /// GitHub-style horizontal strip for a single year
  Widget _buildYearStrip(BuildContext context, int year, Set<DateTime> workoutDates) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedMonth = DateTime(year, 1);
            _viewMode = _StreakViewMode.annual;
          });
        },
        child: Row(
          children: [
            // Year label
            SizedBox(
              width: 56,
              child: Text(
                '$year',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Horizontal month strips
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(12, (monthIndex) {
                    final month = monthIndex + 1;
                    return _buildMonthStrip(context, year, month, workoutDates);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// GitHub-style horizontal strip for a single month
  Widget _buildMonthStrip(
    BuildContext context,
    int year,
    int month,
    Set<DateTime> workoutDates,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = DateTime.now();

    return Row(
      children: List.generate(daysInMonth, (dayIndex) {
        final day = dayIndex + 1;
        final date = DateTime(year, month, day);
        final hasWorkout = workoutDates.contains(date);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        return Container(
          width: 6,
          height: 24,
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: hasWorkout
                ? context.colors.primary
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
            border: isToday
                ? Border.all(
                    color: context.colors.primary,
                    width: 1,
                  )
                : null,
          ),
        );
      }),
    );
  }

}

/// Emoji-based stat card widget (matches StreakModal design)
class _EmojiStatCard extends StatelessWidget {
  const _EmojiStatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
