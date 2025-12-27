/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: presentation/widgets
/// Feature: workout
/// Type: widget
///
/// Clean exercise history bottom sheet following Material Design 3 principles.
/// Matches the consistent design pattern used in ExerciseDetailsModal.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/user_exercise_preferences_provider.dart';

class ExerciseHistoryBottomSheet extends ConsumerStatefulWidget {
  const ExerciseHistoryBottomSheet({
    super.key,
    required this.exerciseName,
    this.exerciseId,
  });

  final String exerciseName;
  final String? exerciseId;

  @override
  ConsumerState<ExerciseHistoryBottomSheet> createState() =>
      _ExerciseHistoryBottomSheetState();
}

class _ExerciseHistoryBottomSheetState
    extends ConsumerState<ExerciseHistoryBottomSheet> {
  final Map<DateTime, bool> _expandedDays = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyAsync =
        ref.watch(exerciseHistoryDataGroupedProvider(widget.exerciseName));
    final statsAsync =
        ref.watch(exerciseStatsFromActivitiesProvider(widget.exerciseName));

    // Watch Form Cues for this exercise
    // ⚠️ FIX: Use null for exerciseId to always use name-based key
    final formCuesAsync = ref.watch(formCuesProvider((
      exerciseId: null, // Use name-based key for persistence across workouts
      exerciseName: widget.exerciseName,
    )));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            _buildHandleBar(context),

            // Header
            _buildHeader(context, l10n),

            // Content
            Expanded(
              child: historyAsync.when(
                data: (groupedHistory) => _buildContent(
                  context,
                  l10n,
                  scrollController,
                  groupedHistory,
                  statsAsync,
                  formCuesAsync,
                ),
                loading: () => _buildLoadingState(context),
                error: (_, __) => _buildErrorState(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with close button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.exerciseHistory,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.exerciseName,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppIcons.closeRounded,
                    color: context.colors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    ScrollController scrollController,
    Map<DateTime, List<ExerciseHistoryData>> groupedHistory,
    AsyncValue<
            ({
              double? maxWeight,
              int totalSets,
              double avgWeight,
              DateTime? firstWorkout,
              DateTime? lastWorkout,
            })>
        statsAsync,
    AsyncValue<String?> formCuesAsync,
  ) {
    if (groupedHistory.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    final sortedDates = groupedHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Initialize expanded state
    for (final date in sortedDates) {
      _expandedDays.putIfAbsent(date, () => true);
    }

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Stats section
        SliverToBoxAdapter(
          child: statsAsync.when(
            data: (stats) =>
                stats.totalSets > 0 ? _buildStatsSection(context, l10n, stats) : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // Form Cues section
        SliverToBoxAdapter(
          child: formCuesAsync.when(
            data: (formCues) => formCues != null && formCues.isNotEmpty
                ? _buildFormCuesSection(context, l10n, formCues)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // History list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = sortedDates[index];
                final dayHistory = groupedHistory[date]!;
                return _buildDaySection(context, l10n, date, dayHistory);
              },
              childCount: sortedDates.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCuesSection(BuildContext context, AppLocalizations l10n, String formCues) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.lightbulb,
                color: context.colors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.formCues,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formCues,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    AppLocalizations l10n,
    ({
      double? maxWeight,
      int totalSets,
      double avgWeight,
      DateTime? firstWorkout,
      DateTime? lastWorkout,
    }) stats,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SemanticIcon(
                  icon: AppIcons.analyticsRounded,
                  semanticLabel: l10n.statistics,
                  size: AppIconSize.small,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.statistics,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: l10n.maxWeight,
                  value: stats.maxWeight != null
                      ? '${stats.maxWeight!.toStringAsFixed(1)}kg'
                      : '--',
                  icon: AppIcons.fitnessCenterRounded,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: l10n.totalSets,
                  value: stats.totalSets.toString(),
                  icon: AppIcons.repeatRounded,
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: l10n.avgWeight,
                  value: stats.avgWeight > 0
                      ? '${stats.avgWeight.toStringAsFixed(1)}kg'
                      : '--',
                  icon: AppIcons.trendingUpRounded,
                  color: context.colors.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: l10n.lastWorkout,
                  value: stats.lastWorkout != null
                      ? DateFormat('d MMM').format(stats.lastWorkout!)
                      : '--',
                  icon: AppIcons.scheduleRounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
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

  Widget _buildDaySection(
    BuildContext context,
    AppLocalizations l10n,
    DateTime date,
    List<ExerciseHistoryData> dayHistory,
  ) {
    final isExpanded = _expandedDays[date] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          InkWell(
            onTap: () {
              setState(() {
                _expandedDays[date] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDateIcon(date),
                    color: context.colors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatDate(date, l10n),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${dayHistory.length}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      AppIcons.keyboardArrowDownRounded,
                      color: context.colors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated expand/collapse for sets list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: dayHistory
                    .asMap()
                    .entries
                    .map((entry) => TweenAnimationBuilder<double>(
                          key: ValueKey('${date.toIso8601String()}_${entry.key}'),
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 150 + (entry.key * 50)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          ),
                          child: _buildHistoryItem(context, l10n, entry.value),
                        ))
                    .toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeOutCubic,
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    AppLocalizations l10n,
    ExerciseHistoryData data,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (data.weight != null) ...[
            Icon(
              AppIcons.fitnessCenterRounded,
              size: 16,
              color: context.colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '${data.weight!.toStringAsFixed(data.weight! % 1 == 0 ? 0 : 1)}kg',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (data.reps != null) ...[
            Icon(
              AppIcons.repeatRounded,
              size: 16,
              color: context.colors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              '${data.reps}',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.reps.toLowerCase(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: SemanticIcon(
                icon: AppIcons.historyRounded,
                semanticLabel: l10n.noHistoryFound,
                size: AppIconSize.large,
                color: context.colors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noHistoryFound,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completeWorkoutsToSeeHistory,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: LoadingIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
            icon: AppIcons.errorOutlineRounded,
            semanticLabel: l10n.errorLoadingHistory,
            size: AppIconSize.large,
            color: context.colors.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingHistory,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.today;
    } else if (dateOnly == yesterday) {
      return l10n.yesterday;
    } else if (now.difference(dateOnly).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  IconData _getDateIcon(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return AppIcons.todayRounded;
    } else if (dateOnly == yesterday) {
      return AppIcons.scheduleRounded;
    } else if (now.difference(dateOnly).inDays < 7) {
      return AppIcons.dateRangeRounded;
    } else {
      return AppIcons.calendarMonthRounded;
    }
  }
}
