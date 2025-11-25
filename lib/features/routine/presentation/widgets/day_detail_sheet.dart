/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// DAY DETAIL SHEET - Complete day statistics and actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/day_stats.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/day_stats_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/workout_selector_sheet.dart';
import 'package:gymbro_flutter_new/features/history/presentation/widgets/workout_detail_modal.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/workout_event_tracker.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class DayDetailSheet extends ConsumerStatefulWidget {

  const DayDetailSheet({
    super.key,
    required this.routine,
    required this.date,
    required this.dayInfo,
  });
  final FlexibleRoutine routine;
  final DateTime date;
  final ScheduledDay dayInfo;

  @override
  ConsumerState<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends ConsumerState<DayDetailSheet> {
  bool _showAllExercises = false;

  @override
  Widget build(BuildContext context) {
    final statsParams = DayStatsParams(
      date: widget.date,
      templateId: widget.dayInfo.templateId,
      workoutId: widget.dayInfo.workoutId,
    );

    final statsAsync = ref.watch(dayStatsProvider(statsParams));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: statsAsync.when(
        data: (stats) => _buildContent(context, stats),
        loading: () => const SizedBox(
          height: 400,
          child: Center(child: LoadingIndicator()),
        ),
        error: (error, stack) => SizedBox(
          height: 400,
          child: Center(
            child: Text(
              context.l10n.errorLoadingStats,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DayStats stats) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          _buildHeader(context, stats),

          const SizedBox(height: 16),

          // Status badge
          _buildStatusBadge(context),

          const SizedBox(height: 24),

          // 🆕 Off-Schedule Workout Badge (if workout done on rest day)
          if (widget.dayInfo.status == DayStatus.rest && stats.hasCompletedWorkout) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withValues(alpha: 0.2),
                      context.colors.tertiary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.star,
                      semanticLabel: context.l10n.routineExtraWorkout,
                      size: AppIconSize.small,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.routineExtraWorkout,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: Color.lerp(context.colors.primary, context.colors.onSurface, 0.3)!,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.routineExtraWorkoutMessage,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Performance section (if completed)
          if (stats.hasCompletedWorkout) ...[
            _buildPerformanceSection(context, stats),
            const SizedBox(height: 24),
          ],

          // Workout preview (if scheduled and not completed)
          if (!stats.hasCompletedWorkout && widget.dayInfo.templateId != null) ...[
            _buildWorkoutPreview(context, widget.dayInfo.templateId!),
            const SizedBox(height: 24),
          ],

          // Historical comparison (if has history)
          if (stats.previousWorkouts.isNotEmpty) ...[
            _buildHistoricalSection(context, stats),
            const SizedBox(height: 24),
          ],

          // Recovery suggestions
          _buildRecoverySuggestions(context, stats),

          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(context, stats),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DayStats stats) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('EEEE, MMMM d, y', locale);
    final statusIcon = _getStatusIcon();
    final statusColor = _getStatusColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template name
          Row(
            children: [
              SemanticIcon(
                icon: statusIcon,
                semanticLabel: _getStatusText(),
                size: AppIconSize.xlarge,
                color: statusColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stats.templateName ?? widget.dayInfo.templateId ?? context.l10n.routineRestDay,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date
          Text(
            dateFormat.format(widget.date),
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor(context);
    final statusIcon = _getStatusIcon();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SemanticIcon(
              icon: statusIcon,
              semanticLabel: statusText,
              size: AppIconSize.small,
              color: statusColor,
            ),
            const SizedBox(width: 12),
            Text(
              statusText,
              style: context.textTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, DayStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.routineTodayPerformance,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatRow(
                  context,
                  icon: AppIcons.workout,
                  label: context.l10n.routineVolume,
                  value: '${stats.totalVolume.toStringAsFixed(0)} kg',
                  trend: stats.volumeChangePercent,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: AppIcons.timer,
                  label: context.l10n.routineDuration,
                  value: _formatDuration(stats.duration),
                  trend: stats.durationChange?.inMinutes.toDouble(),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: AppIcons.complete,
                  label: context.l10n.exercisesLabel,
                  value: '${stats.completedExercises}/${stats.totalExercises}',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: AppIcons.speed,
                  label: context.l10n.routineAverageRPE,
                  value: stats.averageRPE > 0 ? '${stats.averageRPE.toStringAsFixed(1)}/10' : context.l10n.notAvailable,
                ),
              ],
            ),
          ),

          // Personal record badge
          if (stats.isPersonalRecord) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.warning.withValues(alpha: 0.2),
                    context.colors.warning.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.warning),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.achievement,
                    semanticLabel: context.l10n.personalRecord,
                    size: AppIconSize.small,
                    color: context.colors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '🎯 ${context.l10n.personalRecord}',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    double? trend,
  }) {
    return Row(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          size: AppIconSize.small,
          color: context.colors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        if (trend != null) ...[
          const SizedBox(width: 8),
          _buildTrendIndicator(context, trend),
        ],
      ],
    );
  }

  Widget _buildTrendIndicator(BuildContext context, double trend) {
    final isPositive = trend > 0;
    final color = isPositive ? context.colors.success : context.colors.error;
    final icon = isPositive ? AppIcons.trendUp : AppIcons.trendDown;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: icon,
            semanticLabel: isPositive ? 'Trending up' : 'Trending down',
            size: AppIconSize.tiny,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutPreview(BuildContext context, String templateId) {
    final templateAsync = ref.watch(templateByIdProvider(templateId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.routineWorkoutPreview,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              // Change Template button
              TextButton.icon(
                onPressed: () => _changeTemplate(context),
                icon: const SemanticIcon(
  icon: AppIcons.swapHoriz,
  semanticLabel: 'Swap horiz',
  size: AppIconSize.small,
),
                label: Text(context.l10n.routineChange),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          templateAsync.when(
            data: (template) {
              if (template == null) {
                return Text(
                  context.l10n.routineTemplateNotFound,
                  style: TextStyle(color: context.colors.error),
                );
              }

              // Show 3 or all exercises based on state
              final exercisesToShow = _showAllExercises
                  ? template.exercises
                  : template.exercises.take(3).toList();
              final remainingCount = template.exercises.length - 3;
              final hasMore = template.exercises.length > 3;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...exercisesToShow.map((exercise) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: context.colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${exercise.exerciseName}: ${exercise.sets.length}x${exercise.sets.first.targetReps}',
                                  style: context.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                    // Show More/Less button
                    if (hasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showAllExercises = !_showAllExercises;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SemanticIcon(
                                  icon: _showAllExercises ? AppIcons.expandLess : AppIcons.expandMore,
                                  semanticLabel: _showAllExercises ? context.l10n.routineShowLess : context.l10n.routineShowAll(remainingCount),
                                  size: AppIconSize.tiny,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showAllExercises
                                      ? context.l10n.routineShowLess
                                      : context.l10n.routineShowAll(remainingCount),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            loading: () => const LoadingIndicator(),
            error: (_, __) => Text(
              context.l10n.errorLoadingTemplates,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSection(BuildContext context, DayStats stats) {
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.routineWorkoutHistory,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...stats.previousWorkouts.take(3).map((workout) {
                  final dateFormat = DateFormat('MMM d', locale);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.history,
                          semanticLabel: context.l10n.routineWorkoutHistory,
                          size: AppIconSize.tiny,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(workout.completedAt),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${workout.totalVolume.toStringAsFixed(0)} kg • ${workout.duration.inMinutes} min',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (stats.volumeChangePercent != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      SemanticIcon(
                        icon: stats.volumeChangePercent! > 0 ? AppIcons.trendUp : AppIcons.trendDown,
                        semanticLabel: stats.volumeChangePercent! > 0 ? 'Volume increased' : 'Volume decreased',
                        size: AppIconSize.small,
                        color: stats.volumeChangePercent! > 0 ? context.colors.success : context.colors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${stats.volumeChangePercent!.abs().toStringAsFixed(1)}% volume vs last time',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: stats.volumeChangePercent! > 0 ? context.colors.success : context.colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoverySuggestions(BuildContext context, DayStats stats) {
    final suggestionsAsync = ref.watch(recoverySuggestionsProvider(stats));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.routineInsightsSuggestions,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'AI-powered insights based on:\n'
                    '• RPE (Rate of Perceived Exertion)\n'
                    '• Volume changes vs previous workouts\n'
                    '• Current training streak\n'
                    '• Rest day patterns\n'
                    '• Personal records',
                child: SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: 'Information',
                  size: AppIconSize.small,
                  color: context.colors.primary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your performance metrics',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          suggestionsAsync.when(
            data: (suggestions) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: suggestions.map((suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SemanticIcon(
                            icon: AppIcons.lightbulb,
                            semanticLabel: context.l10n.routineInsightsSuggestions,
                            size: AppIconSize.tiny,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
              ),
            ),
            loading: () => const LoadingIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Streak badge
          if (stats.currentStreak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.warning.withValues(alpha: 0.2),
                    context.colors.error.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.warning),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.streak,
                    semanticLabel: 'Streak',
                    size: AppIconSize.small,
                    color: context.colors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '🔥 ${stats.currentStreak} day streak',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, DayStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Primary action based on status
          if (!stats.hasCompletedWorkout && widget.dayInfo.status == DayStatus.scheduled) ...[
            // Start Workout button
            ElevatedButton.icon(
              onPressed: () => _startWorkout(context),
              icon: SemanticIcon(
                icon: AppIcons.play,
                semanticLabel: context.l10n.routineStartWorkout,
              ),
              label: Text(context.l10n.routineStartWorkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (widget.dayInfo.status == DayStatus.completed) ...[
            // View Full Details button
            OutlinedButton.icon(
              onPressed: () => _viewWorkoutDetails(context, stats),
              icon: SemanticIcon(
                icon: AppIcons.visibility,
                semanticLabel: context.l10n.routineViewFullDetails,
              ),
              label: Text(context.l10n.routineViewFullDetails),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.primary,
                minimumSize: const Size(double.infinity, 54),
                side: BorderSide(color: context.colors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Secondary actions row
          Row(
            children: [
              if (widget.dayInfo.status != DayStatus.completed) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _completeDay(context),
                    icon: SemanticIcon(
                      icon: AppIcons.check,
                      semanticLabel: context.l10n.routineComplete,
                      size: AppIconSize.small,
                    ),
                    label: Text(context.l10n.routineComplete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.success,
                      side: BorderSide(color: context.colors.success),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _skipDay(context),
                  icon: SemanticIcon(
                    icon: AppIcons.skipNext,
                    semanticLabel: context.l10n.routineSkip,
                    size: AppIconSize.small,
                  ),
                  label: Text(context.l10n.routineSkip),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.error,
                    side: BorderSide(color: context.colors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getStatusIcon() {
    switch (widget.dayInfo.status) {
      case DayStatus.completed:
        return AppIcons.complete;
      case DayStatus.scheduled:
        return AppIcons.calendar;
      case DayStatus.skipped:
        return AppIcons.skipNext;
      case DayStatus.recovered:
        return AppIcons.replay;
      case DayStatus.rest:
        return AppIcons.hotel;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (widget.dayInfo.status) {
      case DayStatus.completed:
        return context.colors.success;
      case DayStatus.scheduled:
        return context.colors.primary;
      case DayStatus.skipped:
        return context.colors.warning;
      case DayStatus.recovered:
        return context.colors.primary;
      case DayStatus.rest:
        return context.colors.secondary;
    }
  }

  String _getStatusText() {
    switch (widget.dayInfo.status) {
      case DayStatus.completed:
        return context.l10n.routineStatusCompleted;
      case DayStatus.scheduled:
        return context.l10n.routineStatusScheduled;
      case DayStatus.skipped:
        return context.l10n.routineStatusSkipped;
      case DayStatus.recovered:
        return context.l10n.routineStatusRecovered;
      case DayStatus.rest:
        return context.l10n.routineRestDay;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  // Actions
  Future<void> _startWorkout(BuildContext context) async {
    if (widget.dayInfo.templateId == null) return;

    try {
      // Get template
      final template = await ref.read(templateByIdProvider(widget.dayInfo.templateId!).future);
      if (template == null) {
        if (context.mounted) {
          SnackBarService.showError(context, context.l10n.routineTemplateNotFound);
        }
        return;
      }

      // Start workout from template
      ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);

      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        context.goNamed('workout'); // Navigate to workout screen
        SnackBarService.showSuccess(context, context.l10n.routineWorkoutStarted);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.routineErrorStartingWorkout(e.toString()));
      }
    }
  }

  Future<void> _completeDay(BuildContext context) async {
    // Show workout selector sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutSelectorSheet(
        routine: widget.routine,
        date: widget.date,
        templateId: widget.dayInfo.templateId,

        // Callback: Complete with workout
        onWorkoutSelected: (workoutId) async {
          final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
          final success = await notifier.completeDayWorkout(
            routineId: widget.routine.id,
            date: widget.date,
            workoutId: workoutId,
          );

          if (context.mounted) {
            if (success) {
              Navigator.pop(context); // Close selector
              Navigator.pop(context); // Close day detail
              SnackBarService.showSuccess(
                context,
                context.l10n.dayCompletedWithWorkout,
              );

              // Analytics
              WorkoutEventTracker.trackRoutineDayCompleted(
                routineId: widget.routine.id,
                date: widget.date,
                method: 'manual_with_workout',
                workoutId: workoutId,
              );
            } else {
              SnackBarService.showError(
                context,
                context.l10n.failedToCompleteDay,
              );
            }
          }
        },

        // Callback: Complete without workout (fallback)
        onCompleteWithoutWorkout: () async {
          final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
          final success = await notifier.completeDayManual(
            routineId: widget.routine.id,
            date: widget.date,
          );

          if (context.mounted) {
            if (success) {
              Navigator.pop(context); // Close selector
              Navigator.pop(context); // Close day detail
              SnackBarService.showSuccess(
                context,
                context.l10n.dayCompletedManually,
              );

              // Analytics
              WorkoutEventTracker.trackRoutineDayCompleted(
                routineId: widget.routine.id,
                date: widget.date,
                method: 'manual_without_workout',
              );
            } else {
              SnackBarService.showError(
                context,
                context.l10n.failedToCompleteDay,
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _skipDay(BuildContext context) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: context.l10n.routineSkipDay,
      message: context.l10n.routineSkipDayConfirm,
      confirmText: context.l10n.routineSkip,
      isDangerous: true,
    );

    if (!confirmed || !context.mounted) return;

    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
    final success = await notifier.skipDay(
      routineId: widget.routine.id,
      date: widget.date,
    );

    if (context.mounted) {
      if (success) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, context.l10n.routineDaySkipped);
      } else {
        SnackBarService.showError(context, context.l10n.routineFailedToSkip);
      }
    }
  }

  Future<void> _changeTemplate(BuildContext context) async {
    try {
      // Get all available templates
      final templates = await ref.read(allWorkoutTemplatesProvider.future);

      if (templates.isEmpty) {
        if (context.mounted) {
          SnackBarService.showInfo(context, context.l10n.routineNoTemplatesAvailable);
        }
        return;
      }

      if (!context.mounted) return;

      // Show template selection dialog
      final selectedTemplate = await ModalService.showListDialog<WorkoutTemplate>(
        context,
        title: context.l10n.routineChangeTemplate,
        items: templates,
        itemLabel: (template) => template.name,
      );

      if (selectedTemplate == null || !context.mounted) return;

      // Update routine day with new template
      // Get current routine
      final routine = await ref.read(routineByIdProvider(widget.routine.id).future);
      if (routine == null) {
        if (context.mounted) {
          SnackBarService.showError(context, context.l10n.routineNotFound);
        }
        return;
      }

      // Update the scheduled day
      final dateKey = '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';
      final updatedDay = widget.dayInfo.copyWith(templateId: selectedTemplate.id);
      final updatedSchedule = Map<String, ScheduledDay>.from(routine.schedule);
      updatedSchedule[dateKey] = updatedDay;

      final updatedRoutine = routine.copyWith(schedule: updatedSchedule);

      // Save changes
      final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
      final success = await notifier.updateRoutine(updatedRoutine);

      if (context.mounted) {
        if (success) {
          Navigator.pop(context); // Close sheet
          SnackBarService.showSuccess(
            context,
            context.l10n.routineTemplateChanged(selectedTemplate.name),
          );
        } else {
          SnackBarService.showError(context, context.l10n.routineFailedToChange);
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.routineErrorChanging(e.toString()));
      }
    }
  }

  void _viewWorkoutDetails(BuildContext context, DayStats stats) {
    if (stats.completedWorkout == null) return;

    // Show workout detail modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutDetailModal(workout: stats.completedWorkout!),
    );
  }
}
