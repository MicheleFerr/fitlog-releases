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

    return Container(
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
              'Error loading day stats: $error',
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
    final dateFormat = DateFormat('EEEE, MMMM d, y');
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
              Icon(statusIcon, size: 32, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stats.templateName ?? widget.dayInfo.templateId ?? 'Rest Day',
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
            Icon(statusIcon, color: statusColor, size: 20),
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
            'TODAY\'S PERFORMANCE',
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
                  icon: Icons.fitness_center,
                  label: 'Volume',
                  value: '${stats.totalVolume.toStringAsFixed(0)} kg',
                  trend: stats.volumeChangePercent,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: Icons.timer,
                  label: 'Duration',
                  value: _formatDuration(stats.duration),
                  trend: stats.durationChange?.inMinutes.toDouble(),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: Icons.check_circle,
                  label: 'Exercises',
                  value: '${stats.completedExercises}/${stats.totalExercises}',
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: Icons.speed,
                  label: 'Average RPE',
                  value: stats.averageRPE > 0 ? '${stats.averageRPE.toStringAsFixed(1)}/10' : 'N/A',
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
                    Colors.amber.withValues(alpha: 0.2),
                    Colors.orange.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '🎯 Personal Record!',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: Colors.amber.shade700,
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
        Icon(icon, color: context.colors.primary, size: 20),
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
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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
                'WORKOUT PREVIEW',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              // Change Template button
              TextButton.icon(
                onPressed: () => _changeTemplate(context),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Change'),
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
                  'Template not found',
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
                                Icon(
                                  _showAllExercises ? Icons.expand_less : Icons.expand_more,
                                  size: 18,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _showAllExercises
                                      ? 'Show Less'
                                      : 'Show All ($remainingCount more)',
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
              'Error loading template',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalSection(BuildContext context, DayStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORKOUT HISTORY',
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
                  final dateFormat = DateFormat('MMM d');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 16, color: context.colors.primary),
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
                      Icon(
                        stats.volumeChangePercent! > 0 ? Icons.trending_up : Icons.trending_down,
                        color: stats.volumeChangePercent! > 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${stats.volumeChangePercent!.abs().toStringAsFixed(1)}% volume vs last time',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: stats.volumeChangePercent! > 0 ? Colors.green : Colors.red,
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
                'INSIGHTS & SUGGESTIONS',
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
                child: Icon(
                  Icons.info_outline,
                  size: 18,
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
                          Icon(
                            Icons.lightbulb,
                            size: 16,
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
                    Colors.orange.withValues(alpha: 0.2),
                    Colors.red.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '🔥 ${stats.currentStreak} day streak',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: Colors.orange.shade700,
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
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
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

          if (stats.hasCompletedWorkout) ...[
            // View Full Details button
            OutlinedButton.icon(
              onPressed: () => _viewWorkoutDetails(context, stats),
              icon: const Icon(Icons.visibility),
              label: const Text('View Full Details'),
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
              if (!stats.hasCompletedWorkout) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _completeDay(context),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Complete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
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
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text('Skip'),
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
        return Icons.check_circle;
      case DayStatus.scheduled:
        return Icons.calendar_today;
      case DayStatus.skipped:
        return Icons.skip_next;
      case DayStatus.recovered:
        return AppIcons.replay;
      case DayStatus.rest:
        return Icons.hotel;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (widget.dayInfo.status) {
      case DayStatus.completed:
        return Colors.green;
      case DayStatus.scheduled:
        return context.colors.primary;
      case DayStatus.skipped:
        return Colors.orange;
      case DayStatus.recovered:
        return Colors.blue;
      case DayStatus.rest:
        return context.colors.secondary;
    }
  }

  String _getStatusText() {
    switch (widget.dayInfo.status) {
      case DayStatus.completed:
        return 'Completed';
      case DayStatus.scheduled:
        return 'Scheduled';
      case DayStatus.skipped:
        return 'Skipped';
      case DayStatus.recovered:
        return 'Recovered';
      case DayStatus.rest:
        return 'Rest Day';
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
          SnackBarService.showError(context, 'Template not found');
        }
        return;
      }

      // Start workout from template
      ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);

      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        context.goNamed('workout'); // Navigate to workout screen
        SnackBarService.showSuccess(context, 'Workout started! 💪');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, 'Error starting workout: $e');
      }
    }
  }

  Future<void> _completeDay(BuildContext context) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Complete Day',
      message: 'Mark this day as completed without starting a workout?',
      confirmText: 'Complete',
    );

    if (!confirmed || !context.mounted) return;

    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
    final success = await notifier.completeDayManual(
      routineId: widget.routine.id,
      date: widget.date,
    );

    if (context.mounted) {
      if (success) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, 'Day marked as completed');
      } else {
        SnackBarService.showError(context, 'Failed to complete day');
      }
    }
  }

  Future<void> _skipDay(BuildContext context) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Skip Day',
      message: 'Mark this day as skipped?',
      confirmText: 'Skip',
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
        SnackBarService.showSuccess(context, 'Day skipped');
      } else {
        SnackBarService.showError(context, 'Failed to skip day');
      }
    }
  }

  Future<void> _changeTemplate(BuildContext context) async {
    try {
      // Get all available templates
      final templates = await ref.read(allWorkoutTemplatesProvider.future);

      if (templates.isEmpty) {
        if (context.mounted) {
          SnackBarService.showInfo(context, 'No templates available');
        }
        return;
      }

      if (!context.mounted) return;

      // Show template selection dialog
      final selectedTemplate = await ModalService.showListDialog<WorkoutTemplate>(
        context,
        title: 'Change Workout Template',
        items: templates,
        itemLabel: (template) => template.name,
      );

      if (selectedTemplate == null || !context.mounted) return;

      // Update routine day with new template
      // Get current routine
      final routine = await ref.read(routineByIdProvider(widget.routine.id).future);
      if (routine == null) {
        if (context.mounted) {
          SnackBarService.showError(context, 'Routine not found');
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
            'Template changed to "${selectedTemplate.name}"',
          );
        } else {
          SnackBarService.showError(context, 'Failed to change template');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, 'Error changing template: $e');
      }
    }
  }

  void _viewWorkoutDetails(BuildContext context, DayStats stats) {
    if (stats.completedWorkout == null) return;

    // Navigate to workout detail screen
    Navigator.pop(context);
    SnackBarService.showInfo(context, 'Opening workout details...');
    // You'll need to implement navigation to workout detail screen
  }
}
