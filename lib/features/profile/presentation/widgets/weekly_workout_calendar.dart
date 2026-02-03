/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Weekly Workout Calendar
/// Type: Widget
///
/// Horizontal calendar showing Mon-Sun with workout indicators
/// and current day highlight.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';

/// Weekly workout calendar card
///
/// Shows Mon-Sun with indicators for workout days.
/// Tapping opens a detail sheet with weekly stats.
class WeeklyWorkoutCalendar extends ConsumerWidget {
  const WeeklyWorkoutCalendar({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    // Get current week dates (Monday to Sunday)
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));

    // Get workout dates from history
    final workoutDates =
        workoutsAsync.value
            ?.map(
              (w) => DateTime(
                w.completedAt.year,
                w.completedAt.month,
                w.completedAt.day,
              ),
            )
            .toSet() ??
        {};

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              context.l10n.thisWeek,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Week days row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDates.map((date) {
                final isToday = _isSameDay(date, now);
                final hasWorkout = workoutDates.contains(
                  DateTime(date.year, date.month, date.day),
                );
                final isPast = date.isBefore(
                  DateTime(now.year, now.month, now.day),
                );

                return _DayIndicator(
                  dayLabel: _getDayLabel(context, date.weekday),
                  dayNumber: date.day,
                  isToday: isToday,
                  hasWorkout: hasWorkout,
                  isPast: isPast,
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Weekly progress
            _WeeklyProgressBar(
              completed: workoutDates
                  .where(
                    (d) =>
                        d.isAfter(monday.subtract(const Duration(days: 1))) &&
                        d.isBefore(monday.add(const Duration(days: 7))),
                  )
                  .length,
              total: 7,
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayLabel(BuildContext context, int weekday) {
    final labels = [
      context.l10n.mondayShort,
      context.l10n.tuesdayShort,
      context.l10n.wednesdayShort,
      context.l10n.thursdayShort,
      context.l10n.fridayShort,
      context.l10n.saturdayShort,
      context.l10n.sundayShort,
    ];
    return labels[weekday - 1];
  }
}

/// Individual day indicator
class _DayIndicator extends StatelessWidget {
  const _DayIndicator({
    required this.dayLabel,
    required this.dayNumber,
    required this.isToday,
    required this.hasWorkout,
    required this.isPast,
  });

  final String dayLabel;
  final int dayNumber;
  final bool isToday;
  final bool hasWorkout;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day label
        Text(
          dayLabel,
          style: context.textTheme.labelSmall?.copyWith(
            color: isToday
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),

        // Circle indicator
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasWorkout
                ? context.colors.success
                : isToday
                ? context.colors.primaryContainer
                : context.colors.surfaceContainerLow,
            border: isToday && !hasWorkout
                ? Border.all(color: context.colors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: hasWorkout
                ? Icon(
                    AppIcons.check,
                    size: 18,
                    color: context.colors.onPrimary,
                  )
                : Text(
                    '$dayNumber',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isToday
                          ? context.colors.primary
                          : isPast
                          ? context.colors.onSurfaceVariant
                          : context.colors.onSurface,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Weekly progress bar
class _WeeklyProgressBar extends StatelessWidget {
  const _WeeklyProgressBar({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? completed / total : 0.0;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 4,
              backgroundColor: context.colors.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.success),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completed/$total',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
