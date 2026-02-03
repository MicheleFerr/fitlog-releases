import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/models/scheduling_ui_state.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/providers/scheduling_provider.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/widgets/multi_select_calendar.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/widgets/reminder_time_picker.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Bottom sheet for scheduling workouts on multiple dates
class ScheduleBottomSheet extends ConsumerStatefulWidget {
  const ScheduleBottomSheet({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  final String templateId;
  final String templateName;

  /// Show the schedule bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    required String templateId,
    required String templateName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => ScheduleBottomSheet(
        templateId: templateId,
        templateName: templateName,
      ),
    );
  }

  @override
  ConsumerState<ScheduleBottomSheet> createState() =>
      _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends ConsumerState<ScheduleBottomSheet> {
  late ScheduleBottomSheetState _state;
  List<DateTime> _disabledDates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _state = const ScheduleBottomSheetState();
    _loadDisabledDates();
  }

  Future<void> _loadDisabledDates() async {
    final dates = await ref
        .read(schedulingProvider.notifier)
        .getScheduledDatesForTemplate(widget.templateId);
    if (mounted) {
      setState(() => _disabledDates = dates);
    }
  }

  void _onSelectionChanged(List<DateTime> dates) {
    HapticFeedback.selectionClick();
    setState(() {
      _state = _state.copyWith(selectedDates: dates);
    });
  }

  void _onTimeChanged(TimeOfDay time) {
    HapticFeedback.selectionClick();
    setState(() {
      _state = _state.copyWithReminderTime(time);
    });
  }

  Future<void> _onConfirm() async {
    if (_state.selectedDates.isEmpty) return;

    setState(() => _isLoading = true);
    unawaited(HapticFeedback.mediumImpact());

    try {
      await ref
          .read(schedulingProvider.notifier)
          .scheduleWorkouts(
            templateId: widget.templateId,
            templateName: widget.templateName,
            selectedDates: _state.selectedDates,
            reminderTime: _state.reminderTime,
            l10n: context.l10n,
          );

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.workoutScheduledSuccess(
            widget.templateName,
            _state.selectedDates.length,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarService.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  AppIcons.schedule,
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.scheduleWorkout,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.templateName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    AppIcons.close,
                    color: context.colors.onSurfaceVariant,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: context.colors.outlineVariant),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.info,
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            context.l10n.tapDaysToSelect,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Calendar
                  MultiSelectCalendar(
                    selectedDates: _state.selectedDates,
                    onSelectionChanged: _onSelectionChanged,
                    disabledDates: _disabledDates,
                  ),

                  // Selected dates count
                  if (_state.selectedDates.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.checkCircle,
                              size: AppIconSize.small,
                              color: context.colors.onPrimaryContainer,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              context.l10n.daysSelected(
                                _state.selectedDates.length,
                              ),
                              style: context.textTheme.labelLarge?.copyWith(
                                color: context.colors.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.sm),

                  // Divider
                  Divider(height: 1, color: context.colors.outlineVariant),

                  // Reminder time picker
                  ReminderTimePicker(
                    selectedTime: _state.reminderTime,
                    onTimeChanged: _onTimeChanged,
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md + MediaQuery.of(context).padding.bottom,
              top: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                top: BorderSide(color: context.colors.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(context.l10n.cancelSchedule),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isLoading || _state.selectedDates.isEmpty
                        ? null
                        : _onConfirm,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: AppIconSize.small,
                            width: AppIconSize.small,
                            child: LoadingIndicator(
                              color: context.colors.onPrimary,
                              size: AppIconSize.small,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                AppIcons.schedule,
                                size: AppIconSize.small,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(context.l10n.confirmSchedule),
                            ],
                          ),
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
