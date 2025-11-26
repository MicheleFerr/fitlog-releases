/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/screens
/// Feature: Profile Hub
/// Type: Screen
///
/// Apple Fitness+ style profile hub with compact header,
/// metric ring cards, quick actions, and modern workout feed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/metric_ring_card.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/quick_action_chips.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/modern_workout_card.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/user_goals_provider.dart';

/// Profile hub screen - Apple Fitness+ style design
///
/// Features:
/// - Compact horizontal header with tier progress
/// - 3 metric ring cards (streak weeks, workout week, volume goal)
/// - Quick action chips (Stats, History, Measures, Calendar)
/// - Modern workout feed with exercise previews
class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => _ProfileHubContent(
        userName: user?.displayName ?? context.l10n.profile,
      ),
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Main content of the Profile Hub
class _ProfileHubContent extends ConsumerWidget {
  const _ProfileHubContent({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Compact header with tier progress
          SliverToBoxAdapter(
            child: CompactProfileHeader(
              userName: userName,
              onSettingsTap: () => context.pushNamed(AppRoutes.settingsName),
              onEditTap: () => context.pushNamed(AppRoutes.editProfileName),
            ),
          ),

          // Metric ring cards
          SliverToBoxAdapter(
            child: _MetricRingsSection(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          // Quick action chips
          SliverToBoxAdapter(
            child: ProfileQuickActions(
              onStatsTap: () => context.pushNamed(AppRoutes.analyticsName),
              onHistoryTap: () => context.pushNamed(AppRoutes.workoutHistoryName),
              onMeasuresTap: () => context.pushNamed(AppRoutes.bodyMeasurementsName),
              onCalendarTap: () => context.pushNamed(AppRoutes.streakCalendarName),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),

          // Recent workouts section
          SliverToBoxAdapter(
            child: _RecentWorkoutsSection(),
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

/// Metric rings section with 3 progress indicators
class _MetricRingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyWorkoutAsync = ref.watch(weeklyWorkoutProgressProvider);
    final weeklyVolumeAsync = ref.watch(weeklyVolumeProgressProvider);
    final streakWeeksAsync = ref.watch(streakWeeksProgressProvider);

    // Default values while loading
    final weeklyWorkout = weeklyWorkoutAsync.valueOrNull ??
        const WeeklyWorkoutProgress(
          current: 0,
          goal: 2,
          percentage: 0,
          isComplete: false,
        );

    final weeklyVolume = weeklyVolumeAsync.valueOrNull ??
        const WeeklyVolumeProgress(
          currentKg: 0,
          goalKg: null,
          percentage: 0,
          isComplete: false,
        );

    final streakWeeks = streakWeeksAsync.valueOrNull ??
        const StreakWeeksProgress(
          current: 0,
          goal: 4,
          percentage: 0,
          isComplete: false,
        );

    return MetricRingsRow(
      rings: [
        // Streak Weeks
        MetricRingConfig(
          title: context.l10n.streakWeeks,
          value: context.l10n.streakWeeksValue(
            streakWeeks.current,
            streakWeeks.goal,
          ),
          percentage: streakWeeks.percentage,
          color: context.colors.success,
          onTap: () => _showGoalSheet(
            context,
            ref,
            _GoalType.streakWeeks,
            streakWeeks.goal,
          ),
        ),

        // Workout Week
        MetricRingConfig(
          title: context.l10n.workoutWeek,
          value: context.l10n.workoutsWeekGoal(
            weeklyWorkout.current,
            weeklyWorkout.goal,
          ),
          percentage: weeklyWorkout.percentage,
          color: context.colors.primary,
          onTap: () => _showGoalSheet(
            context,
            ref,
            _GoalType.workoutsPerWeek,
            weeklyWorkout.goal,
          ),
        ),

        // Volume Goal
        MetricRingConfig(
          title: context.l10n.volumeGoal,
          value: context.l10n.volumePercentage(
            (weeklyVolume.percentage * 100).round(),
          ),
          percentage: weeklyVolume.percentage,
          color: context.colors.secondary,
          onTap: () => _showVolumeGoalSheet(
            context,
            ref,
            weeklyVolume.goalKg,
          ),
        ),
      ],
    );
  }

  void _showGoalSheet(
    BuildContext context,
    WidgetRef ref,
    _GoalType type,
    int currentValue,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => _GoalEditSheet(
        type: type,
        currentValue: currentValue,
        onSave: (newValue) async {
          final notifier = ref.read(userGoalsProvider.notifier);
          switch (type) {
            case _GoalType.workoutsPerWeek:
              await notifier.setWorkoutsPerWeek(newValue);
            case _GoalType.streakWeeks:
              await notifier.setStreakWeeksGoal(newValue);
          }
        },
      ),
    );
  }

  void _showVolumeGoalSheet(
    BuildContext context,
    WidgetRef ref,
    double? currentValue,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
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

enum _GoalType { workoutsPerWeek, streakWeeks }

/// Bottom sheet for editing numeric goals
class _GoalEditSheet extends StatefulWidget {
  const _GoalEditSheet({
    required this.type,
    required this.currentValue,
    required this.onSave,
  });

  final _GoalType type;
  final int currentValue;
  final Future<void> Function(int) onSave;

  @override
  State<_GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<_GoalEditSheet> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  int get _minValue => widget.type == _GoalType.workoutsPerWeek ? 1 : 1;
  int get _maxValue => widget.type == _GoalType.workoutsPerWeek ? 7 : 52;

  String get _title {
    switch (widget.type) {
      case _GoalType.workoutsPerWeek:
        return context.l10n.workoutsPerWeek;
      case _GoalType.streakWeeks:
        return context.l10n.streakWeeks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
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
            _title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Value selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > _minValue
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() => _value--);
                      }
                    : null,
                icon: Icon(
                  AppIcons.removeCircleOutline,
                  size: 32,
                  color: _value > _minValue
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '$_value',
                style: context.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _value < _maxValue
                    ? () {
                        HapticFeedback.lightImpact();
                        setState(() => _value++);
                      }
                    : null,
                icon: Icon(
                  AppIcons.addCircleOutline,
                  size: 32,
                  color: _value < _maxValue
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.currentGoalValue('$_value'),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await widget.onSave(_value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.goalSaved)),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text(context.l10n.save),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
            child: FilledButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final text = _controller.text.trim();
                final value = text.isEmpty ? null : double.tryParse(text);
                await widget.onSave(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.goalSaved)),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text(context.l10n.save),
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
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.pushNamed(AppRoutes.workoutHistoryName);
                },
                child: Text(context.l10n.seeAll),
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
                  // Navigate to workout detail
                  // TODO: Add workout detail navigation
                },
                maxItems: 3,
              );
            },
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
}

/// Empty state for workouts
class _EmptyWorkoutsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🏋️',
              style: context.textTheme.headlineMedium,
            ),
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
