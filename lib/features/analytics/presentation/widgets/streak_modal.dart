/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics_streak
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// STREAK MODAL - GitHub-style contribution calendar for workout streaks
///
/// This modal provides:
/// - Three view modes: Monthly (calendar), Annual (12-month grid), Multi-year (condensed strip)
/// - Dropdown to switch between views
/// - Current streak stats (weeks in a row, rest days)
/// - GitHub-like heatmap visualization
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => StreakModal(
///     exerciseHistories: histories,
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// View modes for streak visualization
enum StreakViewMode {
  monthly,
  annual,
  multiYear,
}

/// Extension for localized labels
extension StreakViewModeExtension on StreakViewMode {
  String getLabel(BuildContext context) {
    switch (this) {
      case StreakViewMode.monthly:
        return context.l10n.streakViewMonthly;
      case StreakViewMode.annual:
        return context.l10n.streakViewAnnual;
      case StreakViewMode.multiYear:
        return context.l10n.streakViewMultiYear;
    }
  }
}

/// Modal for displaying workout streak details with GitHub-style contribution calendar
class StreakModal extends StatefulWidget {
  const StreakModal({
    required this.exerciseHistories,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  State<StreakModal> createState() => _StreakModalState();
}

class _StreakModalState extends State<StreakModal> {
  // View mode state
  StreakViewMode _viewMode = StreakViewMode.monthly;

  /// Get all unique workout dates (normalized to day precision)
  Set<DateTime> _getAllWorkoutDates() {
    final dates = <DateTime>{};
    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );
        dates.add(dateOnly);
      }
    }
    return dates;
  }

  /// Calculate current streak (consecutive weeks with at least 1 workout)
  int _calculateWeekStreak() {
    final workoutDates = _getAllWorkoutDates();
    if (workoutDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Group dates by week (ISO week number)
    final weekMap = <String, bool>{};
    for (final date in workoutDates) {
      final weekKey = _getWeekKey(date);
      weekMap[weekKey] = true;
    }

    // Count consecutive weeks backwards from current week
    final currentWeekKey = _getWeekKey(todayOnly);
    int streak = 0;
    DateTime checkDate = todayOnly;

    // Check if current week has workout
    if (!weekMap.containsKey(currentWeekKey)) {
      // Check last week
      checkDate = todayOnly.subtract(const Duration(days: 7));
      final lastWeekKey = _getWeekKey(checkDate);
      if (!weekMap.containsKey(lastWeekKey)) {
        return 0; // Streak broken
      }
    }

    // Count consecutive weeks
    while (true) {
      final weekKey = _getWeekKey(checkDate);
      if (weekMap.containsKey(weekKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get week key (year-weekNumber format)
  String _getWeekKey(DateTime date) {
    // ISO 8601 week number
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final weekNumber = ((dayOfYear + DateTime(date.year, 1, 1).weekday - 1) / 7).floor() + 1;
    return '${date.year}-W$weekNumber';
  }

  /// Calculate rest days (days without workout in last year)
  int _calculateRestDays() {
    final workoutDates = _getAllWorkoutDates();
    final today = DateTime.now();
    final oneYearAgo = today.subtract(const Duration(days: 365));

    // Count days in last year
    int totalDays = 365;
    int workoutDaysInYear = 0;

    for (final date in workoutDates) {
      if (date.isAfter(oneYearAgo.subtract(const Duration(days: 1))) && !date.isAfter(today)) {
        workoutDaysInYear++;
      }
    }

    return totalDays - workoutDaysInYear;
  }

  @override
  Widget build(BuildContext context) {
    final weekStreak = _calculateWeekStreak();
    final restDays = _calculateRestDays();
    final workoutDates = _getAllWorkoutDates();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with dropdown and close button
            _buildHeader(context),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats header (weeks in a row, rest days)
                    _buildStatsHeader(context, weekStreak, restDays),
                    const SizedBox(height: 24),

                    // Calendar view based on mode
                    _buildCalendarView(context, workoutDates),
                    const SizedBox(height: 24),

                    // Close button
                    _buildCloseButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with dropdown and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SemanticIcon(
              icon: AppIcons.back,
              semanticLabel: context.l10n.back,
              size: AppIconSize.medium,
            ),
          ),
          const SizedBox(width: 12),

          // View mode dropdown
          Expanded(
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              child: DropdownButton<StreakViewMode>(
                value: _viewMode,
                isExpanded: true,
                isDense: false,
                underline: const SizedBox.shrink(),
                icon: SemanticIcon(
                  icon: AppIcons.expandMore,
                  semanticLabel: 'Select view',
                  size: AppIconSize.small,
                ),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: context.colors.surfaceContainerHighest,
                items: StreakViewMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.getLabel(context)),
                  );
                }).toList(),
                onChanged: (mode) {
                  if (mode != null) {
                    setState(() => _viewMode = mode);
                    HapticFeedback.selectionClick();
                  }
                },
              ),
            ),
          ),

          // Share/export button
          IconButton(
            onPressed: () {
              // TODO: Implement share functionality
              HapticFeedback.lightImpact();
            },
            icon: SemanticIcon(
              icon: AppIcons.share,
              semanticLabel: 'Share',
              size: AppIconSize.medium,
            ),
          ),

          // Settings button
          IconButton(
            onPressed: () {
              // TODO: Implement settings (customize colors, etc.)
              HapticFeedback.lightImpact();
            },
            icon: SemanticIcon(
              icon: AppIcons.settings,
              semanticLabel: context.l10n.settings,
              size: AppIconSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  /// Stats header (weeks in a row, rest days)
  Widget _buildStatsHeader(BuildContext context, int weekStreak, int restDays) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: '🔥',
            value: '$weekStreak',
            label: context.l10n.weeksInRow,
            color: context.colors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: '🌙',
            value: '$restDays',
            label: context.l10n.restDaysCount,
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }

  /// Individual stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
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

  /// Calendar view based on selected mode
  Widget _buildCalendarView(BuildContext context, Set<DateTime> workoutDates) {
    switch (_viewMode) {
      case StreakViewMode.monthly:
        return _buildMonthlyView(context, workoutDates);
      case StreakViewMode.annual:
        return _buildAnnualView(context, workoutDates);
      case StreakViewMode.multiYear:
        return _buildMultiYearView(context, workoutDates);
    }
  }

  /// Monthly view: traditional calendar with day headers
  Widget _buildMonthlyView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Show current month and previous month
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day of week headers
        _buildDayHeaders(context),
        const SizedBox(height: 12),

        // Previous month
        _buildMonthCalendar(context, previousMonth, workoutDates, today),
        const SizedBox(height: 24),

        // Current month
        _buildMonthCalendar(context, currentMonth, workoutDates, today),
      ],
    );
  }

  /// Day of week headers (Lun, Mar, Mer, Gio, Ven, Sab, Dom)
  Widget _buildDayHeaders(BuildContext context) {
    final dayNames = [
      context.l10n.mondayShort,
      context.l10n.tuesdayShort,
      context.l10n.wednesdayShort,
      context.l10n.thursdayShort,
      context.l10n.fridayShort,
      context.l10n.saturdayShort,
      context.l10n.sundayShort,
    ];

    return Row(
      children: dayNames.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Single month calendar
  Widget _buildMonthCalendar(
    BuildContext context,
    DateTime month,
    Set<DateTime> workoutDates,
    DateTime today,
  ) {
    // Month title (e.g., "ottobre 2025")
    final monthName = DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(month);

    // Calculate first day of month and total days
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Get starting weekday (1 = Monday, 7 = Sunday)
    final startWeekday = firstDayOfMonth.weekday;

    // Total cells (including empty cells for alignment)
    final totalCells = daysInMonth + (startWeekday - 1);
    final rows = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month name
        Text(
          monthName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            // Calculate day number
            final dayNumber = index - (startWeekday - 1) + 1;

            // Empty cell before month starts
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(month.year, month.month, dayNumber);
            final hasWorkout = workoutDates.contains(date);
            final isToday = date.isAtSameMomentAs(today);

            return Container(
              decoration: BoxDecoration(
                color: hasWorkout
                    ? context.colors.primary.withValues(alpha: 0.15)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: isToday
                    ? Border.all(
                        color: context.colors.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '$dayNumber',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday
                        ? context.colors.primary
                        : hasWorkout
                            ? context.colors.onSurface
                            : context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Annual view: 3x4 grid with 12 months (mini heatmaps)
  Widget _buildAnnualView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final year = now.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year title
        Text(
          '$year',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 3x4 grid of months
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
          itemBuilder: (context, index) {
            final monthNumber = index + 1;
            return _buildMiniMonth(context, year, monthNumber, workoutDates);
          },
        ),
      ],
    );
  }

  /// Mini month heatmap for annual view
  Widget _buildMiniMonth(
    BuildContext context,
    int year,
    int month,
    Set<DateTime> workoutDates,
  ) {
    // Month name (short form: gen, feb, mar, etc.)
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

    return Column(
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
    );
  }

  /// Multi-year view: horizontal strip for entire year
  Widget _buildMultiYearView(BuildContext context, Set<DateTime> workoutDates) {
    final now = DateTime.now();
    final year = now.year;

    // Month names
    final monthNames = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year title
        Text(
          '$year',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal month labels
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(12, (index) {
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
          ),
        ),
        const SizedBox(height: 8),

        // Single horizontal strip (all 365 days)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(12, (monthIndex) {
              final month = monthIndex + 1;
              return _buildMonthStrip(context, year, month, workoutDates);
            }),
          ),
        ),
      ],
    );
  }

  /// Month strip for multi-year view (horizontal cells)
  Widget _buildMonthStrip(
    BuildContext context,
    int year,
    int month,
    Set<DateTime> workoutDates,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Row(
      children: List.generate(daysInMonth, (dayIndex) {
        final day = dayIndex + 1;
        final date = DateTime(year, month, day);
        final hasWorkout = workoutDates.contains(date);
        final today = DateTime.now();
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        return Container(
          width: 6,
          height: 30,
          margin: const EdgeInsets.only(right: 2),
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

  /// Close button
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: SemanticIcon(
          icon: AppIcons.close,
          semanticLabel: context.l10n.close,
          size: AppIconSize.buttonPrimary,
        ),
        label: Text(context.l10n.close),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
