/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// DAILY WORKOUT CARD - Shows today's scheduled workout
///
/// Features:
/// - Workout template info
/// - Quick actions (Complete, Skip)
/// - Status indicator
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/widgets/day_detail_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Card showing today's workout
class DailyWorkoutCard extends ConsumerWidget {

  const DailyWorkoutCard({
    super.key,
    required this.routine,
    required this.date,
    this.onComplete,
    this.onSkip,
  });
  final FlexibleRoutine routine;
  final DateTime date;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayInfo = routine.getDayInfo(date);

    if (dayInfo == null) {
      return const SizedBox.shrink();
    }

    // Check auto-complete status if day is scheduled and it's today
    final shouldCheckAutoComplete = dayInfo.status == DayStatus.scheduled && _isToday(date);

    final autoCompleteStatus = shouldCheckAutoComplete && dayInfo.templateId != null
        ? ref.watch(dayAutoCompleteStatusProvider(DayCheckParams(
            date: date,
            scheduledTemplateId: dayInfo.templateId,
          )))
        : null;

    // Auto-complete the day if needed
    if (autoCompleteStatus != null) {
      autoCompleteStatus.whenData((status) {
        if (status.shouldAutoComplete && dayInfo.status == DayStatus.scheduled) {
          // Automatically mark day as completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoCompleteDayWithWorkout(context, ref, routine, date, status.workoutId!);
          });
        }
      });
    }

    return InkWell(
      onTap: () => _showDayDetailSheet(context, dayInfo),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(context, dayInfo.status),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBorderColor(context, dayInfo.status),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getBorderColor(context, dayInfo.status).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              _buildStatusIcon(context, dayInfo.status),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isToday(date) ? context.l10n.routineTodayWorkout : _formatDate(context, date),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _getStatusLabel(context, dayInfo.status),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(context, dayInfo.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Workout info
          if (dayInfo.status == DayStatus.rest)
            _buildRestDay(context)
          else if (dayInfo.status == DayStatus.scheduled)
            _buildScheduledWorkout(context, ref, dayInfo)
          else
            _buildCompletedInfo(context, dayInfo),

          // Action buttons - conditionally shown based on auto-complete status
          if (dayInfo.status == DayStatus.scheduled && _isToday(date)) ...[
            const SizedBox(height: 20),
            if (autoCompleteStatus != null)
              autoCompleteStatus.when(
                data: (status) {
                  // If workout matches scheduled template, hide buttons (auto-completing)
                  if (status.shouldAutoComplete) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.complete, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.dailyWorkoutAutoCompleting,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // If different workout completed, show substitution option
                  if (status.hasAlternativeWorkout) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(AppIcons.info, color: context.colors.secondary, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.l10n.dailyWorkoutDifferentWorkoutCompleted,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showSubstitutionDialog(context, ref, routine, date, status),
                                icon: Icon(AppIcons.swapHoriz, size: 20),
                                label: Text(context.l10n.dailyWorkoutSubstitute),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.secondary,
                                  foregroundColor: context.colors.onSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onSkip,
                                icon: Icon(AppIcons.eventBusy, size: 20),
                                label: Text(context.l10n.dailyWorkoutSkip),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.colors.error,
                                  side: BorderSide(color: context.colors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  // No workout completed - show regular buttons
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(AppIcons.complete, size: 20),
                          label: Text(context.l10n.dailyWorkoutComplete),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSkip,
                          icon: Icon(AppIcons.eventBusy, size: 20),
                          label: Text(context.l10n.dailyWorkoutSkip),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.error,
                            side: BorderSide(color: context.colors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (_, __) => Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(AppIcons.complete, size: 20),
                        label: Text(context.l10n.dailyWorkoutComplete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSkip,
                        icon: Icon(AppIcons.eventBusy, size: 20),
                        label: Text(context.l10n.dailyWorkoutSkip),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.error,
                          side: BorderSide(color: context.colors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(AppIcons.complete, size: 20),
                      label: Text(context.l10n.dailyWorkoutComplete),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSkip,
                      icon: Icon(AppIcons.eventBusy, size: 20),
                      label: Text(context.l10n.dailyWorkoutSkip),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.error,
                        side: BorderSide(color: context.colors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
        ),
      ),
    );
  }

  /// Show day detail sheet
  void _showDayDetailSheet(BuildContext context, ScheduledDay dayInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailSheet(
        routine: routine,
        date: date,
        dayInfo: dayInfo,
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, DayStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case DayStatus.completed:
        icon = AppIcons.complete;
        color = Colors.green;
        break;
      case DayStatus.skipped:
        icon = AppIcons.cancel;
        color = context.colors.error;
        break;
      case DayStatus.recovered:
        icon = AppIcons.refresh;
        color = Colors.blue;
        break;
      case DayStatus.rest:
        icon = AppIcons.bed;
        color = context.colors.secondary;
        break;
      case DayStatus.scheduled:
        icon = AppIcons.schedule;
        color = context.colors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildRestDay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.spa,
            color: context.colors.secondary,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.dailyWorkoutRestAndRecovery,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  context.l10n.dailyWorkoutRestAndRecoverySubtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledWorkout(BuildContext context, WidgetRef ref, ScheduledDay day) {
    // Fetch template name if templateId is available
    final templateAsync = day.templateId != null
        ? ref.watch(templateByIdProvider(day.templateId!))
        : null;

    String workoutName = context.l10n.dailyWorkoutDefaultWorkoutName;
    if (templateAsync != null) {
      workoutName = templateAsync.when(
        data: (template) => template?.name ?? context.l10n.dailyWorkoutDefaultWorkoutName,
        loading: () => context.l10n.dailyWorkoutLoading,
        error: (_, __) => day.templateId ?? context.l10n.dailyWorkoutDefaultWorkoutName,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.workout,
            color: context.colors.primary,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  context.l10n.dailyWorkoutTapCompleteWhenDone,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            AppIcons.forwardIos,
            color: context.colors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedInfo(BuildContext context, ScheduledDay day) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.celebration,
            color: Colors.green,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              day.status == DayStatus.completed
                  ? context.l10n.dailyWorkoutGreatWork
                  : day.status == DayStatus.skipped
                      ? context.l10n.dailyWorkoutDaySkipped
                      : context.l10n.dailyWorkoutDayRecovered,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(BuildContext context, DayStatus status) {
    switch (status) {
      case DayStatus.completed:
        return [
          Colors.green.withValues(alpha: 0.15),
          Colors.green.withValues(alpha: 0.05),
        ];
      case DayStatus.skipped:
        return [
          context.colors.error.withValues(alpha: 0.15),
          context.colors.error.withValues(alpha: 0.05),
        ];
      case DayStatus.rest:
        return [
          context.colors.secondary.withValues(alpha: 0.15),
          context.colors.secondary.withValues(alpha: 0.05),
        ];
      default:
        return [
          context.colors.primaryContainer.withValues(alpha: 0.3),
          context.colors.primaryContainer.withValues(alpha: 0.1),
        ];
    }
  }

  Color _getBorderColor(BuildContext context, DayStatus status) {
    switch (status) {
      case DayStatus.completed:
        return Colors.green;
      case DayStatus.skipped:
        return context.colors.error;
      case DayStatus.rest:
        return context.colors.secondary;
      default:
        return context.colors.primary;
    }
  }

  Color _getStatusColor(BuildContext context, DayStatus status) {
    switch (status) {
      case DayStatus.completed:
        return Colors.green;
      case DayStatus.skipped:
        return context.colors.error;
      case DayStatus.recovered:
        return Colors.blue;
      case DayStatus.rest:
        return context.colors.secondary;
      case DayStatus.scheduled:
        return context.colors.primary;
    }
  }

  String _getStatusLabel(BuildContext context, DayStatus status) {
    switch (status) {
      case DayStatus.completed:
        return context.l10n.dailyWorkoutStatusCompleted;
      case DayStatus.skipped:
        return context.l10n.dailyWorkoutStatusSkipped;
      case DayStatus.recovered:
        return context.l10n.dailyWorkoutStatusRecovered;
      case DayStatus.rest:
        return context.l10n.restDay;
      case DayStatus.scheduled:
        return context.l10n.dailyWorkoutStatusReadyToGo;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('MMM d, y', locale);
    return dateFormat.format(date);
  }

  /// Auto-complete day with the workout instance
  Future<void> _autoCompleteDayWithWorkout(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    DateTime date,
    String workoutId,
  ) async {
    final notifier = ref.read(flexibleRoutineNotifierProvider.notifier);

    final success = await notifier.completeDayWorkout(
      routineId: routine.id,
      date: date,
      workoutId: workoutId,
    );

    if (context.mounted && !success) {
      // Only show error if it fails, success is silent (auto-completed)
      if (kDebugMode) {
        debugPrint('⚠️ Failed to auto-complete day');
      }
    }
  }

  /// Show dialog to substitute scheduled workout with completed workout
  Future<void> _showSubstitutionDialog(
    BuildContext context,
    WidgetRef ref,
    FlexibleRoutine routine,
    DateTime date,
    DayAutoCompleteStatus status,
  ) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: context.l10n.dailyWorkoutSubstituteDialogTitle,
      message: context.l10n.dailyWorkoutSubstituteDialogMessage,
      confirmText: context.l10n.dailyWorkoutSubstituteDialogConfirm,
      cancelText: context.l10n.dailyWorkoutSubstituteDialogCancel,
    );

    if (confirmed && context.mounted) {
      await _autoCompleteDayWithWorkout(context, ref, routine, date, status.workoutId!);
    }
  }
}
