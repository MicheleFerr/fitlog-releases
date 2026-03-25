library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class RecentWorkoutsPopup extends StatelessWidget {
  const RecentWorkoutsPopup({
    required this.onWorkoutSelected,
    required this.onViewHistory,
    super.key,
  });

  final void Function(WorkoutHistoryDetail workout) onWorkoutSelected;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ModalService.showSheet(
          context,
          isScrollControlled: true,
          useRootNavigator: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => _RecentWorkoutsSheet(
            onWorkoutSelected: onWorkoutSelected,
            onViewHistory: onViewHistory,
          ),
        );
      },
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: AppBorderRadius.buttonRadius,
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          context.l10n.recentWorkouts,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _RecentWorkoutsSheet extends ConsumerWidget {
  const _RecentWorkoutsSheet({
    required this.onWorkoutSelected,
    required this.onViewHistory,
  });

  final void Function(WorkoutHistoryDetail workout) onWorkoutSelected;
  final VoidCallback onViewHistory;

  static const int _maxRecentWorkouts = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.recentWorkouts,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const SemanticIcon(
                      icon: AppIcons.close,
                      semanticLabel: 'Close',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: workoutsAsync.when(
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (_, __) => _EmptyRecentWorkoutsState(
                    onViewHistory: () {
                      Navigator.of(context).pop();
                      onViewHistory();
                    },
                  ),
                  data: (workouts) {
                    final recentWorkouts = [...workouts]
                      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

                    final displayWorkouts = recentWorkouts
                        .take(_maxRecentWorkouts)
                        .toList();

                    if (displayWorkouts.isEmpty) {
                      return _EmptyRecentWorkoutsState(
                        onViewHistory: () {
                          Navigator.of(context).pop();
                          onViewHistory();
                        },
                      );
                    }

                    return ListView.separated(
                      itemCount: displayWorkouts.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        if (index == displayWorkouts.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onViewHistory();
                              },
                              icon: const Icon(AppIcons.history),
                              label: Text(context.l10n.workoutDatabase),
                            ),
                          );
                        }

                        final workout = displayWorkouts[index];
                        return _RecentWorkoutTile(
                          workout: workout,
                          onTap: () {
                            Navigator.of(context).pop();
                            onWorkoutSelected(workout);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentWorkoutTile extends StatelessWidget {
  const _RecentWorkoutTile({required this.workout, required this.onTap});

  final WorkoutHistoryDetail workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd(
      context.l10n.localeName,
    ).format(workout.completedAt);

    return Material(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.history,
                  color: context.colors.onSecondaryContainer,
                  size: AppIconSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${context.l10n.exerciseCount(workout.exercises.length)} • $dateLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                AppIcons.chevronRight,
                size: AppIconSize.small,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecentWorkoutsState extends StatelessWidget {
  const _EmptyRecentWorkoutsState({required this.onViewHistory});

  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SemanticIcon(
            icon: AppIcons.history,
            semanticLabel: 'Recent workouts',
            size: AppIconSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.noRecentWorkoutsFound,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(AppIcons.history),
            label: Text(context.l10n.workoutDatabase),
          ),
        ],
      ),
    );
  }
}
