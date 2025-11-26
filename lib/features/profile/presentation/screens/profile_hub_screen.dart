/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/screens
/// Feature: Profile Hub
/// Type: Screen
///
/// Profile hub with user header, activity chart, quick actions, and workout feed.
/// Central hub for Statistiche, Esercizi, Misurazioni, Calendario access.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Profile hub screen - central navigation point for user-related features
class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => _buildContent(context, ref, user),
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, user) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // User header with settings icon
          SliverToBoxAdapter(
            child: _ProfileHeader(
              userName: user?.displayName ?? context.l10n.profile,
              userEmail: user?.email ?? '',
              onSettingsTap: () => context.pushNamed(AppRoutes.settingsName),
              onEditTap: () => context.pushNamed(AppRoutes.editProfileName),
            ),
          ),

          // Activity chart section with workout durations
          SliverToBoxAdapter(
            child: _ActivityChartSection(),
          ),

          // Quick actions grid (2x2)
          SliverToBoxAdapter(
            child: _QuickActionsGrid(),
          ),

          // Recent workouts feed (actual data)
          SliverToBoxAdapter(
            child: _RecentWorkoutsFeed(),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Profile header with user info and action icons (NO stats row)
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.userName,
    required this.userEmail,
    required this.onSettingsTap,
    required this.onEditTap,
  });

  final String userName;
  final String userEmail;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top row: Edit, Share, Settings icons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    AppIcons.edit,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onEditTap();
                  },
                  tooltip: context.l10n.edit,
                ),
                IconButton(
                  icon: Icon(
                    AppIcons.share,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: Share profile
                  },
                  tooltip: context.l10n.share,
                ),
                IconButton(
                  icon: Icon(
                    AppIcons.settingsOutlined,
                    size: AppIconSize.medium,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSettingsTap();
                  },
                  tooltip: context.l10n.settings,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: context.colors.primaryContainer,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              userName,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Email or subtitle
            Text(
              userEmail,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            // NOTE: Stats row (workouts, followers, following) removed per user request
          ],
        ),
      ),
    );
  }
}

/// Activity chart section showing workout duration cluster chart
class _ActivityChartSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: workoutsAsync.when(
          data: (workouts) => _buildChart(context, workouts),
          loading: () => const Center(child: LoadingIndicator()),
          error: (_, __) => Center(
            child: Text(
              context.l10n.errorLoadingData,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<WorkoutHistoryDetail> workouts) {
    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.analytics,
              size: AppIconSize.xlarge,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noWorkoutsYet,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Get last 14 days of workouts for the chart
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 13));

    // Group workouts by date and sum durations
    final durationsByDay = <int, int>{};
    for (var i = 0; i < 14; i++) {
      durationsByDay[i] = 0;
    }

    for (final workout in workouts) {
      final workoutDate = DateTime(
        workout.completedAt.year,
        workout.completedAt.month,
        workout.completedAt.day,
      );
      final daysDiff = workoutDate.difference(DateTime(twoWeeksAgo.year, twoWeeksAgo.month, twoWeeksAgo.day)).inDays;
      if (daysDiff >= 0 && daysDiff < 14) {
        durationsByDay[daysDiff] = (durationsByDay[daysDiff] ?? 0) + workout.duration.inMinutes;
      }
    }

    // Find max duration for scaling
    final maxDuration = durationsByDay.values.fold(0, (a, b) => a > b ? a : b);
    final maxForScale = maxDuration > 0 ? maxDuration : 60; // Default to 60 min if no workouts

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.activityChart,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                context.l10n.lastNDays(14),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(14, (index) {
                final duration = durationsByDay[index] ?? 0;
                final heightPercent = maxForScale > 0 ? duration / maxForScale : 0.0;
                final date = twoWeeksAgo.add(Duration(days: index));
                final isToday = date.day == now.day && date.month == now.month;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Tooltip(
                      message: '${DateFormat.MMMd(context.l10n.localeName).format(date)}: ${duration}min',
                      child: Container(
                        height: heightPercent > 0
                            ? (heightPercent * 100).clamp(8.0, 100.0)
                            : 4.0,
                        decoration: BoxDecoration(
                          color: duration > 0
                              ? (isToday
                                  ? context.colors.primary
                                  : context.colors.primary.withValues(alpha: 0.6))
                              : context.colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Day labels
          Row(
            children: List.generate(14, (index) {
              final date = twoWeeksAgo.add(Duration(days: index));
              // Only show label for every 3rd day
              if (index % 3 != 0 && index != 13) return const Expanded(child: SizedBox());
              return Expanded(
                child: Text(
                  DateFormat.d().format(date),
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Quick actions 2x2 grid
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.quickActions,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: AppIcons.analytics,
                  label: context.l10n.statistics,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pushNamed(AppRoutes.analyticsName);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: AppIcons.history,
                  label: context.l10n.workoutHistory,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Navigate to workout history
                    context.pushNamed(AppRoutes.workoutHistoryName);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: AppIcons.bodyMeasurements,
                  label: context.l10n.measurements,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pushNamed(AppRoutes.bodyMeasurementsName);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: AppIcons.calendar,
                  label: context.l10n.calendar,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.pushNamed(AppRoutes.streakCalendarName);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(
                icon,
                size: AppIconSize.large,
                color: context.colors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recent workouts feed section showing actual workout data
class _RecentWorkoutsFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.recentWorkouts,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigate to full workout history
                  context.pushNamed(AppRoutes.workoutHistoryName);
                },
                child: Text(context.l10n.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          workoutsAsync.when(
            data: (workouts) => _buildWorkoutsList(context, workouts),
            loading: () => Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: LoadingIndicator()),
            ),
            error: (_, __) => Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  context.l10n.errorLoadingData,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(BuildContext context, List<WorkoutHistoryDetail> workouts) {
    if (workouts.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            context.l10n.noRecentWorkouts,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Show last 3 workouts
    final recentWorkouts = workouts.take(3).toList();

    return Column(
      children: recentWorkouts.map((workout) {
        return _WorkoutCard(workout: workout);
      }).toList(),
    );
  }
}

/// Individual workout card
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final WorkoutHistoryDetail workout;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(context.l10n.localeName);
    final timeFormat = DateFormat.Hm(context.l10n.localeName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AppIcons.workout,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        title: Text(
          workout.name,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${dateFormat.format(workout.completedAt)} - ${timeFormat.format(workout.completedAt)}',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${workout.duration.inMinutes} min',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            Text(
              '${workout.exercises.length} ${context.l10n.exercises.toLowerCase()}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
