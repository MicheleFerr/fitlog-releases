import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/providers/scheduling_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// Screen showing all scheduled workouts
class ScheduledWorkoutsScreen extends ConsumerWidget {
  const ScheduledWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schedulingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scheduledWorkouts),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(schedulingProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: LoadingIndicator())
          : state.scheduledWorkouts.isEmpty
              ? _EmptyState()
              : _WorkoutsList(workouts: state.scheduledWorkouts),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.schedule,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.noScheduledWorkouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutsList extends ConsumerWidget {
  const _WorkoutsList({required this.workouts});

  final List<ScheduledWorkout> workouts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group workouts by date
    final groupedWorkouts = <DateTime, List<ScheduledWorkout>>{};
    for (final workout in workouts) {
      final dateKey = DateTime(
        workout.scheduledDate.year,
        workout.scheduledDate.month,
        workout.scheduledDate.day,
      );
      groupedWorkouts.putIfAbsent(dateKey, () => []).add(workout);
    }

    final sortedDates = groupedWorkouts.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateWorkouts = groupedWorkouts[date]!;

        return _DateSection(
          date: date,
          workouts: dateWorkouts,
        );
      },
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.date,
    required this.workouts,
  });

  final DateTime date;
  final List<ScheduledWorkout> workouts;

  String _formatDateHeader(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return context.l10n.scheduledForToday;
    } else if (date.isAtSameMomentAs(tomorrow)) {
      return context.l10n.scheduledForTomorrow;
    }

    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMMd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            _formatDateHeader(context, date),
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Workout cards
        ...workouts.map((workout) => _ScheduledWorkoutCard(workout: workout)),
      ],
    );
  }
}

class _ScheduledWorkoutCard extends ConsumerWidget {
  const _ScheduledWorkoutCard({required this.workout});

  final ScheduledWorkout workout;

  Color _getStatusColor(BuildContext context, ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.pending:
        return context.colors.primary;
      case ScheduleStatus.due:
        return context.colors.warning;
      case ScheduleStatus.completed:
        return context.colors.success;
      case ScheduleStatus.skipped:
        return context.colors.onSurfaceVariant;
      case ScheduleStatus.missed:
        return context.colors.error;
    }
  }

  IconData _getStatusIcon(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.pending:
        return AppIcons.schedule;
      case ScheduleStatus.due:
        return AppIcons.warning;
      case ScheduleStatus.completed:
        return AppIcons.checkCircle;
      case ScheduleStatus.skipped:
        return AppIcons.skipNext;
      case ScheduleStatus.missed:
        return AppIcons.close;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: context.l10n.deleteScheduleConfirm,
      message: context.l10n.deleteScheduleMessage,
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref.read(schedulingProvider.notifier).deleteSchedule(workout.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(context, workout.status);
    final statusIcon = _getStatusIcon(workout.status);

    return Dismissible(
      key: Key(workout.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _showDeleteConfirmation(context, ref);
        return false; // We handle deletion in the confirmation
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: context.colors.errorContainer,
        child: Icon(
          AppIcons.delete,
          color: context.colors.onErrorContainer,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outlineVariant,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.selectionClick();
            // TODO: Navigate to template or start workout
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Status icon
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: AppIconSize.medium,
                ),
                const SizedBox(width: AppSpacing.sm),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.templateName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            AppIcons.clock,
                            size: AppIconSize.tiny,
                            color: context.colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            workout.formattedReminderTime,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions for pending/due workouts
                if (workout.status == ScheduleStatus.pending ||
                    workout.status == ScheduleStatus.due) ...[
                  IconButton(
                    icon: Icon(
                      AppIcons.skipNext,
                      color: context.colors.onSurfaceVariant,
                      size: AppIconSize.small,
                    ),
                    tooltip: context.l10n.skipScheduledWorkout,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(schedulingProvider.notifier)
                          .markAsSkipped(workout.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      AppIcons.play,
                      color: context.colors.primary,
                      size: AppIconSize.small,
                    ),
                    tooltip: context.l10n.startScheduledWorkout,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Start workout
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
