/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/screens
/// Feature: Profile Hub
/// Type: Screen
///
/// Profile hub with fixed compact header and scrollable body.
/// Header stays pinned with avatar + name + settings.
/// Body contains tier progress, metric rings, quick actions, and workout feed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/metric_ring_card.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/quick_action_chips.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/modern_workout_card.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/weekly_workout_calendar.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/settings_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/weekly_stats_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/account_mode_section.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/user_goals_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_detail_modal.dart';
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/level_info_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/ghost_mode_provider.dart';

import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🚧 MVP FEATURE FLAGS
// ═══════════════════════════════════════════════════════════════════════════

/// Coach feature (Solo/Coach/Coached modes)
/// Disabled until Coach Agreement legal docs are ready
/// TODO: Enable when fitlogpro.it/legal/coach-agreement-*.html are published
const bool _coachFeatureEnabled = false;

/// Profile hub screen with fixed header and scrollable body
class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => _ProfileHubContent(
        userName: user?.displayName ?? context.l10n.profile,
      ),
      loading: () => const Scaffold(body: Center(child: LoadingIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

/// Main content with fixed header + scrollable body
class _ProfileHubContent extends ConsumerWidget {
  const _ProfileHubContent({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Fixed header - always visible
          CompactProfileHeader(
            userName: userName,
            onSettingsTap: () => showSettingsBottomSheet(context),
            onEditTap: () => context.pushNamed(AppRoutes.editProfileName),
          ),

          // Scrollable body
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Tier progress (moved from header)
                const SliverToBoxAdapter(
                  child: _TierProgressSection(),
                ),

                // Account mode section (Solo/Coach/Coached)
                // 🚧 MVP: Disabled until Coach Agreement legal docs ready
                if (_coachFeatureEnabled) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                  const SliverToBoxAdapter(child: AccountModeSection()),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                ],

                // Metric ring cards
                SliverToBoxAdapter(child: _MetricRingsSection()),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),

                // Quick action chips
                SliverToBoxAdapter(
                  child: ProfileQuickActions(
                    onStatsTap: () => context.pushNamed(AppRoutes.statsName),
                    onHistoryTap: () =>
                        context.pushNamed(AppRoutes.workoutHistoryName),
                    onMeasuresTap: () =>
                        context.pushNamed(AppRoutes.bodyMeasurementsName),
                    onCalendarTap: () =>
                        context.pushNamed(AppRoutes.streakCalendarName),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),

                // Recent workouts section
                SliverToBoxAdapter(child: _RecentWorkoutsSection()),

                // Bottom padding for tab bar overlay
                const SliverTabBarBottomPadding(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tier progress section - moved from header to scrollable body
///
/// Shows tier badge, progress bar to next tier, and info button.
/// Tappable to open the level info modal.
class _TierProgressSection extends ConsumerWidget {
  const _TierProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userXPState = ref.watch(userXPProvider);
    final shouldHideTier = ref.watch(shouldHideTierProvider);

    if (shouldHideTier) return const SizedBox(height: AppSpacing.md);

    final totalXP = userXPState.totalXP;
    final currentTier = userXPState.currentTier;
    final nextTier = currentTier.next;
    final tierProgress = currentTier.progressToNext(totalXP);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0,
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          LevelInfoModal.show(
            context: context,
            currentXP: totalXP,
            currentTier: currentTier,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: nextTier != null
              ? Row(
                  children: [
                    // Tier icon
                    Icon(
                      AppIcons.achievement,
                      size: AppSpacing.md,
                      color: currentTier.color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Current tier
                    Text(
                      currentTier.displayName,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: currentTier.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Progress bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: tierProgress,
                          minHeight: AppSpacing.xxs,
                          backgroundColor: context.colors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            currentTier.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Next tier
                    Text(
                      nextTier.displayName,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    // Info icon
                    Icon(
                      AppIcons.info,
                      size: AppIconSize.small,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Max tier reached
                    Icon(
                      AppIcons.achievement,
                      size: AppSpacing.md,
                      color: currentTier.color,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      currentTier.displayName,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: currentTier.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      AppIcons.info,
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

/// Metric rings section with weekly calendar and 2 progress indicators
class _MetricRingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyVolumeAsync = ref.watch(weeklyVolumeProgressProvider);
    final streakWeeksAsync = ref.watch(streakWeeksProgressProvider);

    final weeklyVolume =
        weeklyVolumeAsync.value ??
        const WeeklyVolumeProgress(
          currentKg: 0,
          goalKg: null,
          percentage: 0,
          isComplete: false,
        );

    final streakWeeks =
        streakWeeksAsync.value ??
        const StreakWeeksProgress(
          current: 0,
          goal: 4,
          percentage: 0,
          isComplete: false,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Weekly workout calendar (Mon-Sun)
          WeeklyWorkoutCalendar(
            onTap: () => showWeeklyStatsBottomSheet(context),
          ),
          const SizedBox(height: 12),

          // Two metric rings below
          Row(
            children: [
              // Streak Weeks (consecutive weeks with 2+ workouts)
              Expanded(
                child: MetricRingCard(
                  config: MetricRingConfig(
                    title: context.l10n.streakWeeks,
                    value: '${streakWeeks.current}',
                    // Empty ring when 0, full when > 0
                    percentage: streakWeeks.current > 0 ? 1.0 : 0.0,
                    // Neutral color when 0, success when active
                    color: streakWeeks.current > 0
                        ? context.colors.success
                        : context.colors.outline,
                    // No onTap - calendar already accessible via weekly calendar
                    onTap: null,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Volume Goal
              Expanded(
                child: MetricRingCard(
                  config: MetricRingConfig(
                    title: context.l10n.volumeGoal,
                    value: context.l10n.volumePercentage(
                      (weeklyVolume.percentage * 100).round(),
                    ),
                    percentage: weeklyVolume.percentage,
                    color: context.colors.secondary,
                    onTap: () =>
                        _showVolumeGoalSheet(context, ref, weeklyVolume.goalKg),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVolumeGoalSheet(
    BuildContext context,
    WidgetRef ref,
    double? currentValue,
  ) {
    HapticFeedback.lightImpact();
    ModalService.showSheet(context,
      builder: (context) => _VolumeGoalEditSheet(
        currentValue: currentValue,
        onSave: (newValue) async {
          final notifier = ref.read(userGoalsProvider.notifier);
          await notifier.setWeeklyVolumeTarget(newValue);
        },
      ),
    );
  }
}

/// Bottom sheet for editing volume goal
class _VolumeGoalEditSheet extends StatefulWidget {
  const _VolumeGoalEditSheet({
    required this.currentValue,
    required this.onSave,
  });

  final double? currentValue;
  final Future<void> Function(double?) onSave;

  @override
  State<_VolumeGoalEditSheet> createState() => _VolumeGoalEditSheetState();
}

class _VolumeGoalEditSheetState extends State<_VolumeGoalEditSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentValue?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24.0,
        24.0,
        24.0,
        24.0 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.modifyGoal,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.weeklyVolumeTarget,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Text input for volume
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: context.l10n.save,
              child: FilledButton(
                onPressed: () async {
                  await HapticFeedback.mediumImpact();
                  final text = _controller.text.trim();
                  final value = text.isEmpty ? null : double.tryParse(text);
                  await widget.onSave(value);
                  if (context.mounted) {
                    SnackBarService.showInfo(context, context.l10n.goalSaved);
                    Navigator.of(context).pop();
                  }
                },
                child: Text(context.l10n.save),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Recent workouts section with modern cards
class _RecentWorkoutsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              Semantics(
                label: context.l10n.seeAll,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.pushNamed(AppRoutes.workoutHistoryName);
                  },
                  child: Text(context.l10n.seeAll),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          workoutsAsync.when(
            data: (workouts) {
              if (workouts.isEmpty) {
                return _EmptyWorkoutsCard();
              }
              return ModernWorkoutCardsList(
                workouts: workouts,
                onWorkoutTap: (workout) {
                  HapticFeedback.lightImpact();
                  ModalService.showSheet(context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0),
                    builder: (_) => DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.8,
                      maxChildSize: 1.0,
                      expand: false,
                      snap: true,
                      builder: (context, scrollController) =>
                          WorkoutDetailModal(
                            workout: workout,
                            scrollController: scrollController,
                          ),
                    ),
                  );
                },
                maxItems: 3,
              );
            },
            loading: () => Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(child: LoadingIndicator()),
            ),
            error: (_, __) => Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
}

/// Empty state for workouts
class _EmptyWorkoutsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏋️', style: context.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              context.l10n.noRecentWorkouts,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
