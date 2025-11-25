/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: routine
/// 🔧 Type: widget
///
/// Skip Recovery Dialog - UI for recovering skipped routine days
///
/// Allows users to:
/// - View skipped days from the last 30 days
/// - View available rest days for recovery
/// - Select a skipped day and assign it to a rest day
///
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_reminder_service.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/routine_reminder_service_provider.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Skip Recovery Dialog
class SkipRecoveryDialog extends ConsumerStatefulWidget {
  const SkipRecoveryDialog({super.key});

  @override
  ConsumerState<SkipRecoveryDialog> createState() =>
      _SkipRecoveryDialogState();
}

class _SkipRecoveryDialogState extends ConsumerState<SkipRecoveryDialog> {
  List<SkippableDay>? _recoverableDays;
  List<RecoveryDay>? _availableDays;
  bool _isLoading = true;
  String? _error;
  SkippableDay? _selectedSkippedDay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activeRoutineAsync = ref.read(activeFlexibleRoutineProvider);
      final activeRoutine = activeRoutineAsync.when(
        data: (routine) => routine,
        loading: () => null,
        error: (_, __) => null,
      );

      if (activeRoutine == null) {
        if (mounted) {
          setState(() {
            _error = context.l10n.routineNoActiveRoutine;
            _isLoading = false;
          });
        }
        return;
      }

      final reminderService = ref.read(routineReminderServiceProvider);

      final recoverable = await reminderService.getRecoverableSkippedDays(
        routine: activeRoutine,
      );

      final available = await reminderService.getAvailableRecoveryDays(
        routine: activeRoutine,
      );

      setState(() {
        _recoverableDays = recoverable;
        _availableDays = available;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _recoverDay(RecoveryDay recoveryDay) async {
    if (_selectedSkippedDay == null) return;

    try {
      final activeRoutineAsync = ref.read(activeFlexibleRoutineProvider);
      final activeRoutine = activeRoutineAsync.when(
        data: (routine) => routine,
        loading: () => null,
        error: (_, __) => null,
      );

      if (activeRoutine == null) return;

      final reminderService = ref.read(routineReminderServiceProvider);

      final success = await reminderService.recoverSkippedDay(
        routine: activeRoutine,
        skippedDate: _selectedSkippedDay!.date,
        recoveryDate: recoveryDay.date,
      );

      if (success && mounted) {
        // Success haptic feedback
        HapticFeedback.mediumImpact();

        SnackBarService.showSuccess(
          context,
          context.l10n.routineWorkoutRecovered(_formatDate(recoveryDay.date)),
        );

        // Reload data to show updated state
        await _loadData();
        setState(() {
          _selectedSkippedDay = null;
        });
      } else if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.routineRecoveryFailed,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.routineRecoveryError(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  AppIcons.restore,
                  color: context.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.routineRecoverSkippedDays,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.routineRecoverSkippedDaysSubtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            if (_isLoading)
              const Expanded(
                child: Center(child: LoadingIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
  size: AppIconSize.xxlarge,
  color: context.colors.error,
),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: context.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_recoverableDays?.isEmpty ?? true)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SemanticIcon(
  icon: AppIcons.completeOutline,
  semanticLabel: 'Complete outline',
  size: AppIconSize.medium,
  color: context.colors.primary,
),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.routineNoSkippedDays,
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.routineOnTrack,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Row(
                  children: [
                    // Skipped Days List
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.routineSkippedDaysCount(_recoverableDays!.length),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _recoverableDays!.length,
                              itemBuilder: (context, index) {
                                final day = _recoverableDays![index];
                                final isSelected = _selectedSkippedDay == day;
                                return _buildSkippedDayCard(day, isSelected);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Available Recovery Days
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.routineAvailableDaysCount(_availableDays!.length),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedSkippedDay == null)
                            Expanded(
                              child: Center(
                                child: Text(
                                  context.l10n.routineSelectSkippedDayFirst,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            )
                          else if (_availableDays!.isEmpty)
                            Expanded(
                              child: Center(
                                child: Text(
                                  context.l10n.routineNoRestDaysAvailable,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: _availableDays!.length,
                                itemBuilder: (context, index) {
                                  final day = _availableDays![index];
                                  return _buildRecoveryDayCard(day);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkippedDayCard(SkippableDay day, bool isSelected) {
    return Card(
      color: isSelected
          ? context.colors.primary.withValues(alpha: 0.1)
          : context.colors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Selection haptic feedback
          HapticFeedback.selectionClick();

          setState(() {
            _selectedSkippedDay = isSelected ? null : day;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected ? AppIcons.radioButtonChecked : AppIcons.radioButtonUnchecked,
                    size: 20,
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(day.date),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  day.templateId ?? 'No template',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryDayCard(RecoveryDay day) {
    return Card(
      color: context.colors.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _recoverDay(day),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SemanticIcon(
  icon: AppIcons.eventAvailable,
  semanticLabel: 'Event available',
  size: AppIconSize.small,
  color: context.colors.primary,
),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatDate(day.date),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SemanticIcon(
  icon: AppIcons.forward,
  semanticLabel: 'Forward',
  size: AppIconSize.small,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    // Use localized relative dates
    if (diff == 0) return context.l10n.today;
    if (diff == -1) return context.l10n.yesterday;
    if (diff == 1) return context.l10n.tomorrow;
    if (diff == -2) return context.l10n.daysAgo(2);

    // For future dates beyond tomorrow
    if (diff > 1 && diff <= 7) {
      // Format as "In 2 days", "In 3 days", etc.
      return context.l10n.daysAgo(diff.abs()).replaceFirst('ago', 'from now');
    }

    // Use locale-aware date formatting for other dates
    // Format: "Mon 15 Jan" (locale-aware)
    final locale = Localizations.localeOf(context).languageCode;
    final formatter = DateFormat.MMMEd(locale);
    return formatter.format(date);
  }
}
