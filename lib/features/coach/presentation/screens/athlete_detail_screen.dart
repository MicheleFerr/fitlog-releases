/// Athlete Detail Screen
///
/// Shows detailed workout history and stats for a single athlete.
/// Used by coaches to monitor athlete progress and compliance.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/chat/presentation/providers/chat_providers.dart';
import 'package:gymbro_flutter_new/features/coach/domain/repositories/coach_repository.dart';
import 'package:gymbro_flutter_new/features/coach/presentation/providers/coach_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Screen showing detailed workout info for an athlete
class AthleteDetailScreen extends ConsumerWidget {
  const AthleteDetailScreen({
    required this.athleteId,
    this.athleteName = '',
    super.key,
  });

  final String athleteId;
  final String athleteName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(athleteWeeklyStatsProvider(athleteId));
    final workoutsAsync = ref.watch(athleteWorkoutsProvider(athleteId));

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: CustomScrollView(
        slivers: [
          // App bar with athlete name
          SliverAppBar.medium(
            title: Text(
              athleteName.isEmpty ? context.l10n.athlete : athleteName,
            ),
            actions: [
              // Message button
              IconButton(
                icon: const Icon(AppIcons.chatBubbleOutline),
                tooltip: context.l10n.sendMessage,
                onPressed: () => _openChat(context, ref),
              ),
              IconButton(
                icon: const Icon(AppIcons.moreVert),
                onPressed: () => _showAthleteOptions(context),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Weekly Compliance Card
                statsAsync.when(
                  data: (stats) => _ComplianceCard(stats: stats),
                  loading: () => const _ComplianceCardSkeleton(),
                  error: (_, __) =>
                      const _ComplianceCard(stats: AthleteWeeklyStats.empty()),
                ),
                const SizedBox(height: AppSpacing.md),

                // Weekly Stats Row
                statsAsync.when(
                  data: (stats) => _WeeklyStatsRow(stats: stats),
                  loading: () => const _WeeklyStatsRowSkeleton(),
                  error: (_, __) =>
                      const _WeeklyStatsRow(stats: AthleteWeeklyStats.empty()),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Recent Activity Header
                Row(
                  children: [
                    Icon(
                      AppIcons.history,
                      color: context.colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.recentActivity,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Recent Workouts List
                workoutsAsync.when(
                  data: (workouts) => _RecentActivityList(
                    workouts: workouts,
                    onWorkoutTap: (workout) =>
                        _showWorkoutDetail(context, workout),
                  ),
                  loading: () => const _RecentActivityListSkeleton(),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        'Error: $error',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom padding for tab bar overlay
                const TabBarBottomPadding(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    try {
      // Get current user (coach)
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        SnackBarService.showError(context, context.l10n.notAuthenticated);
        return;
      }

      // Get or create the conversation
      final conversation = await ref.read(
        getOrCreateConversationProvider({
          'coachId': currentUser.uid,
          'athleteId': athleteId,
          'coachName': currentUser.displayName,
          'athleteName': athleteName.isNotEmpty ? athleteName : 'Athlete',
        }).future,
      );

      // Navigate to chat
      if (context.mounted) {
        unawaited(
          context.pushNamed(
          AppRoutes.chatName,
          pathParameters: {'conversationId': conversation.id},
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.errorStartingChat);
      }
    }
  }

  void _showAthleteOptions(BuildContext context) {
    ModalService.showSheet<void>(context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.edit),
              title: Text(context.l10n.editPermissions),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open permissions editor
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.note),
              title: Text(context.l10n.addNote),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open notes editor
              },
            ),
            ListTile(
              leading: Icon(
                AppIcons.removeCircleOutline,
                color: context.colors.error,
              ),
              title: Text(
                context.l10n.removeAthlete,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show remove confirmation
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetail(BuildContext context, AthleteWorkoutSummary workout) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _WorkoutDetailModal(workout: workout),
    );
  }
}

// ============================================================
// COMPLIANCE CARD
// ============================================================

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.stats});

  final AthleteWeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.weeklyCompliance,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: _getComplianceColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.compliancePercent}%',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.compliancePercent / 100,
              minHeight: 8,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(_getComplianceColor(context)),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Stats text
          Text(
            context.l10n.workoutsCompletedThisWeek(
              stats.totalWorkouts,
              stats.plannedWorkouts,
            ),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getComplianceColor(BuildContext context) {
    if (stats.compliancePercent >= 75) {
      return context.colors.primary;
    } else if (stats.compliancePercent >= 50) {
      return context.colors.tertiary;
    } else {
      return context.colors.error;
    }
  }
}

class _ComplianceCardSkeleton extends StatelessWidget {
  const _ComplianceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: LoadingIndicator()),
    );
  }
}

// ============================================================
// WEEKLY STATS ROW
// ============================================================

class _WeeklyStatsRow extends StatelessWidget {
  const _WeeklyStatsRow({required this.stats});

  final AthleteWeeklyStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '${stats.totalWorkouts}',
              label: context.l10n.sessions,
              icon: AppIcons.fitnessCenter,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              value: '${stats.totalMinutes}',
              label: context.l10n.minutes,
              icon: AppIcons.timerOutlined,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: context.colors.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              value: _formatVolume(stats.totalVolume),
              label: context.l10n.volume,
              icon: AppIcons.barChart,
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toInt()}kg';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: context.colors.primary, size: 20),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _WeeklyStatsRowSkeleton extends StatelessWidget {
  const _WeeklyStatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: LoadingIndicator()),
    );
  }
}

// ============================================================
// RECENT ACTIVITY LIST
// ============================================================

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({
    required this.workouts,
    required this.onWorkoutTap,
  });

  final List<AthleteWorkoutSummary> workouts;
  final void Function(AthleteWorkoutSummary) onWorkoutTap;

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              AppIcons.fitnessCenter,
              size: 48,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.noWorkoutsYet,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: workouts.map((workout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _WorkoutListItem(
            workout: workout,
            onTap: () => onWorkoutTap(workout),
          ),
        );
      }).toList(),
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  const _WorkoutListItem({required this.workout, required this.onTap});

  final AthleteWorkoutSummary workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.MMMd();
    final timeFormat = DateFormat.Hm();
    final isToday = _isToday(workout.completedAt);
    final isYesterday = _isYesterday(workout.completedAt);

    String dateLabel;
    if (isToday) {
      dateLabel = context.l10n.today;
    } else if (isYesterday) {
      dateLabel = context.l10n.yesterday;
    } else {
      dateLabel = dateFormat.format(workout.completedAt);
    }

    // Accessibility: Workout card with semantic label
    return Semantics(
      label: '${workout.name}, $dateLabel ${timeFormat.format(workout.completedAt)}, ${workout.durationMinutes} minutes',
      button: true,
      child: Material(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Checkmark icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.complete,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Workout info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateLabel ${timeFormat.format(workout.completedAt)} • ${workout.durationMinutes} min',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                AppIcons.chevronRight,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}

class _RecentActivityListSkeleton extends StatelessWidget {
  const _RecentActivityListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================
// WORKOUT DETAIL MODAL
// ============================================================

class _WorkoutDetailModal extends StatelessWidget {
  const _WorkoutDetailModal({required this.workout});

  final AthleteWorkoutSummary workout;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.Hm();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${dateFormat.format(workout.completedAt)}, ${timeFormat.format(workout.completedAt)} • ${workout.durationMinutes} ${context.l10n.minutes}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: context.colors.outlineVariant.withValues(alpha: 0.5),
              ),

              // Exercises list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: workout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = workout.exercises[index];
                    return _ExerciseDetailItem(
                      index: index + 1,
                      exercise: exercise,
                    );
                  },
                ),
              ),

              // Footer stats
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(
                      color: context.colors.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _FooterStat(
                        label: context.l10n.exercises,
                        value: '${workout.exerciseCount}',
                      ),
                      _FooterStat(
                        label: context.l10n.sets,
                        value: '${workout.totalSets}',
                      ),
                      _FooterStat(
                        label: context.l10n.volume,
                        value: _formatVolume(workout.totalVolume),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toInt()} kg';
  }
}

class _ExerciseDetailItem extends StatelessWidget {
  const _ExerciseDetailItem({required this.index, required this.exercise});

  final int index;
  final AthleteExerciseSummary exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.formattedSets,
                  style: context.textTheme.bodyMedium?.copyWith(
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

class _FooterStat extends StatelessWidget {
  const _FooterStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
