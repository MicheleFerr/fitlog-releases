/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ROUTINE DETAIL SCREEN - Detailed view of a flexible routine
///
/// Features:
/// - Routine header with stats
/// - Calendar view with day statuses
/// - Daily workout card
/// - Skip/Recovery actions
/// - Progress tracking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/skip_tracker.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/calendar_view.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/daily_workout_card.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/stats_dashboard.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/day_detail_sheet.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/dialogs/skip_day_dialog.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/dialogs/recovery_picker_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Detail screen for a specific flexible routine
class RoutineDetailScreen extends ConsumerWidget {

  const RoutineDetailScreen({
    super.key,
    required this.routineId,
  });
  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineAsync = ref.watch(routineByIdProvider(routineId));

    return Scaffold(
      body: routineAsync.when(
        data: (routine) {
          if (routine == null) {
            return _buildNotFound(context);
          }
          return _buildContent(context, ref, routine);
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
  ) {
    return CustomScrollView(
      slivers: [
        // Header with routine info
        _buildHeader(context, ref, routine),

        // Stats dashboard
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StatsDashboard(routine: routine),
          ),
        ),

        // Calendar view
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CalendarView(
              routine: routine,
              onDayTap: (date) => _handleDayTap(context, ref, routine, date),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Today's workout card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DailyWorkoutCard(
              routine: routine,
              date: DateTime.now(),
              onComplete: () => _completeDay(context, ref, routine, DateTime.now()),
              onSkip: () => _skipDay(context, ref, routine, DateTime.now()),
            ),
          ),
        ),

        // Unrecovered skips section
        if (routine.skipTracker.unrecoveredSkips.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
              child: Text(
                'Missed Workouts',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.error,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final skip = routine.skipTracker.unrecoveredSkips[index];
                return _buildSkipCard(context, ref, routine, skip);
              },
              childCount: routine.skipTracker.unrecoveredSkips.length,
            ),
          ),
        ],

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: context.colors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          routine.name,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.primaryContainer.withValues(alpha: 0.3),
                context.colors.primaryContainer.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48), // Space for title
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        icon: Icons.calendar_today,
                        label: _formatDateRange(routine.startDate, routine.endDate),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        icon: Icons.fitness_center,
                        label: '${routine.totalWorkoutDays} workouts',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (routine.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: context.colors.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ACTIVE',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // More actions menu
        IconButton(
          onPressed: () => _showMoreActions(context, ref, routine),
          icon: const Icon(AppIcons.moreVert),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipCard(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    SkipEntry skip,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.errorContainer,
          child: Icon(
            AppIcons.eventBusy,
            color: context.colors.error,
          ),
        ),
        title: Text(
          _formatDate(skip.date),
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: skip.reason != null
            ? Text('Reason: ${skip.reason}')
            : const Text('No reason provided'),
        trailing: TextButton(
          onPressed: () => _recoverDay(context, ref, routine, skip.date),
          child: const Text('Recover'),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Routine not found',
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colors.error,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading routine',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // === ACTIONS ===

  void _handleDayTap(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    DateTime date,
  ) {
    final day = routine.getDayInfo(date);
    if (day == null) return;

    // Show rich day detail sheet with stats and history
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailSheet(
        routine: routine,
        date: date,
        dayInfo: day,
      ),
    );
  }

  Future<void> _completeDay(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    DateTime date,
  ) async {
    final day = routine.getDayInfo(date);
    if (day == null || day.templateId == null) return;

    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
    final success = await notifier.completeDayWorkout(
      routineId: routine.id,
      date: date,
      workoutId: day.templateId!,
    );

    if (context.mounted) {
      if (success) {
        SnackBarService.showSuccess(context, 'Day completed! 💪');
      } else {
        SnackBarService.showError(context, 'Failed to complete day');
      }
    }
  }

  Future<void> _skipDay(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    DateTime date,
  ) async {
    // Show skip reason dialog
    final result = await SkipDayDialog.show(
      context,
      date: date,
      routine: routine,
    );

    // User cancelled
    if (result == null) return;

    // Proceed with skip
    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
    final success = await notifier.skipDay(
      routineId: routine.id,
      date: date,
      reason: result.note ?? result.reason,
    );

    if (context.mounted) {
      if (success) {
        SnackBarService.showInfo(context, 'Day skipped');
      } else {
        SnackBarService.showError(context, 'Failed to skip day');
      }
    }
  }

  Future<void> _recoverDay(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    DateTime originalDate,
  ) async {
    // Show recovery date picker dialog
    final recoveryDate = await RecoveryPickerDialog.show(
      context,
      originalDate: originalDate,
      routine: routine,
    );

    // User cancelled
    if (recoveryDate == null) return;

    // Proceed with recovery
    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);
    final success = await notifier.recoverDay(
      routineId: routine.id,
      originalDate: originalDate,
      recoveryDate: recoveryDate,
    );

    if (context.mounted) {
      if (success) {
        SnackBarService.showSuccess(context, 'Day recovered! 🔥');
      } else {
        SnackBarService.showError(context, 'Failed to recover day');
      }
    }
  }

  void _showMoreActions(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                AppIcons.editCalendar,
                color: context.colors.primary,
              ),
              title: const Text('Edit Schedule'),
              subtitle: const Text('Change workout templates for each day'),
              onTap: () {
                Navigator.pop(modalContext);
                _editSchedule(context, ref, routine);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Archive action
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: context.colors.error),
              title: Text(
                'Delete',
                style: TextStyle(color: context.colors.error),
              ),
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Delete action
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSchedule(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
  ) async {
    // Navigate to edit schedule screen (simplified version)
    SnackBarService.showInfo(
      context,
      'Edit Schedule feature coming soon! You\'ll be able to change workout templates for each day.',
    );
    // TODO: Implement full edit schedule screen
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDayStatus(DayStatus status) {
    switch (status) {
      case DayStatus.scheduled:
        return 'Scheduled';
      case DayStatus.completed:
        return 'Completed';
      case DayStatus.skipped:
        return 'Skipped';
      case DayStatus.recovered:
        return 'Recovered';
      case DayStatus.rest:
        return 'Rest Day';
    }
  }
}
