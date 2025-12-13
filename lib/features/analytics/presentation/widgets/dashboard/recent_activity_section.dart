import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Data model for recent workout activity
class RecentWorkoutData {
  const RecentWorkoutData({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.totalVolume,
    required this.muscleGroups,
    this.prCount = 0,
  });

  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final int exerciseCount;
  final double totalVolume;
  final List<String> muscleGroups;
  final int prCount;
}

/// Section displaying recent workout activity with cards
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.workouts,
    this.maxVisible = 3,
    this.measurementUnit = 'kg',
    this.onWorkoutTap,
    this.onSeeAllTap,
  });

  final List<RecentWorkoutData> workouts;
  final int maxVisible;
  final String measurementUnit;
  final void Function(String workoutId)? onWorkoutTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final visibleWorkouts = workouts.take(maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                AppIcons.calendar,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.thisWeek,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Workout cards
        if (visibleWorkouts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                context.l10n.noRecentWorkouts,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...visibleWorkouts.map((workout) => _WorkoutCard(
                workout: workout,
                measurementUnit: measurementUnit,
                onTap: onWorkoutTap != null ? () => onWorkoutTap!(workout.id) : null,
              )),

        // See all button
        if (visibleWorkouts.isNotEmpty && workouts.length > maxVisible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: onSeeAllTap,
                icon: const Icon(AppIcons.history, size: 16),
                label: Text(context.l10n.viewFullHistory),
              ),
            ),
          ),
      ],
    );
  }
}

/// Individual workout card widget
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.measurementUnit,
    this.onTap,
  });

  final RecentWorkoutData workout;
  final String measurementUnit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date indicator row
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isToday(workout.date)
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatRelativeDate(context, workout.date),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isToday(workout.date)
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Workout name and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${workout.durationMinutes} ${context.l10n.minutes}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Muscle groups
              if (workout.muscleGroups.isNotEmpty)
                Text(
                  workout.muscleGroups.join(' • '),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  // Exercise count
                  Icon(
                    AppIcons.exercise,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.exerciseCount} ${context.l10n.exercises}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Volume
                  Icon(
                    AppIcons.scale,
                    size: 16,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatVolume(workout.totalVolume)} $measurementUnit',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),

                  // PR badge
                  if (workout.prCount > 0) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.achievement,
                            size: 14,
                            color: context.colors.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.prCount}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Format date as relative string (TODAY, YESTERDAY, N DAYS AGO)
  String _formatRelativeDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return context.l10n.today.toUpperCase();
    } else if (difference == 1) {
      return context.l10n.yesterday.toUpperCase();
    } else {
      // Note: daysAgo in l10n already includes the count placeholder
      // So we just uppercase the entire string
      return context.l10n.daysAgo(difference).toUpperCase();
    }
  }

  /// Format volume with k suffix for thousands
  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return (volume / 1000).toStringAsFixed(1);
    }
    return volume.toStringAsFixed(0);
  }
}
