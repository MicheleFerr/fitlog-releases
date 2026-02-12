/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: presentation/widgets
/// Feature: Workout Time Edit Sheet
///
/// Bottom sheet to modify workout duration when actual time < rest time.
/// Shows suggested time (rest + 2min × sets) and allows manual editing.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_time_calculator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Bottom sheet per modificare il tempo del workout
///
/// Mostra:
/// - Tempo attuale (registrato)
/// - Tempo suggerito (rest + 2min × sets)
/// - Opzione per usare suggerito o modificare manualmente
class WorkoutTimeEditSheet extends ConsumerStatefulWidget {
  const WorkoutTimeEditSheet({
    super.key,
    required this.workout,
    required this.onTimeSelected,
    this.showSuspiciousWarning = true,
  });

  /// Il workout da modificare
  final Workout workout;

  /// Callback quando l'utente seleziona un tempo
  /// Ritorna la nuova durata in minuti
  final void Function(Duration newDuration) onTimeSelected;

  /// Se true, mostra il warning "tempo sembra breve"
  final bool showSuspiciousWarning;

  /// Mostra il bottom sheet e ritorna la durata selezionata
  static Future<Duration?> show({
    required BuildContext context,
    required Workout workout,
    bool showSuspiciousWarning = true,
  }) async {
    Duration? result;

    await ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => WorkoutTimeEditSheet(
        workout: workout,
        showSuspiciousWarning: showSuspiciousWarning,
        onTimeSelected: (duration) {
          result = duration;
          Navigator.of(context).pop();
        },
      ),
    );

    return result;
  }

  @override
  ConsumerState<WorkoutTimeEditSheet> createState() =>
      _WorkoutTimeEditSheetState();
}

class _WorkoutTimeEditSheetState extends ConsumerState<WorkoutTimeEditSheet> {
  late WorkoutTimeMetrics _metrics;
  late int _selectedHours;
  late int _selectedMinutes;
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    _metrics = WorkoutTimeCalculator.getTimeMetrics(widget.workout);

    // Inizializza con il tempo suggerito
    _selectedHours = _metrics.suggestedDuration.inHours;
    _selectedMinutes = _metrics.suggestedDuration.inMinutes.remainder(60);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title with warning icon
              Row(
                children: [
                  if (widget.showSuspiciousWarning) ...[
                    SemanticIcon(
                      icon: AppIcons.warning,
                      size: AppIconSize.large,
                      color: context.colors.warning,
                      semanticLabel: l10n.warning,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      l10n.workoutTimeSeemsShort,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Explanation
              Text(
                l10n.workoutTimeExplanation,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Time comparison cards
              _buildTimeComparisonSection(context),
              const SizedBox(height: 24),

              // Action buttons
              if (_isManualMode)
                _buildManualTimePicker(context)
              else
                _buildQuickActions(context),
              const SizedBox(height: 16),

              // Keep original button (always visible)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.keepOriginalTime),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeComparisonSection(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        // Actual time card
        Expanded(
          child: _TimeCard(
            label: l10n.recordedTime,
            duration: _metrics.actualDurationFormatted,
            icon: AppIcons.timer,
            color: context.colors.error.withValues(alpha: 0.1),
            iconColor: context.colors.error,
          ),
        ),
        const SizedBox(width: 12),
        // Suggested time card
        Expanded(
          child: _TimeCard(
            label: l10n.suggestedTime,
            duration: _metrics.suggestedDurationFormatted,
            icon: AppIcons.lightbulb,
            color: context.colors.primary.withValues(alpha: 0.1),
            iconColor: context.colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        // Use suggested time (primary action)
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onTimeSelected(_metrics.suggestedDuration);
            },
            icon: SemanticIcon(
              icon: AppIcons.check,
              size: AppIconSize.small,
              semanticLabel: l10n.useSuggestedTime,
            ),
            label: Text(l10n.useSuggestedTime),
          ),
        ),
        const SizedBox(height: 12),
        // Modify manually (secondary action)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isManualMode = true;
              });
            },
            icon: SemanticIcon(
              icon: AppIcons.edit,
              size: AppIconSize.small,
              semanticLabel: l10n.modifyManually,
            ),
            label: Text(l10n.modifyManually),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTimePicker(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setWorkoutDuration,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Time picker row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hours
            _TimePickerWheel(
              value: _selectedHours,
              maxValue: 5,
              label: l10n.hours,
              onChanged: (value) {
                setState(() {
                  _selectedHours = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: context.textTheme.headlineLarge),
            ),
            // Minutes
            _TimePickerWheel(
              value: _selectedMinutes,
              maxValue: 59,
              label: l10n.minutes,
              onChanged: (value) {
                setState(() {
                  _selectedMinutes = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Confirm button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final duration = Duration(
                hours: _selectedHours,
                minutes: _selectedMinutes,
              );
              widget.onTimeSelected(duration);
            },
            icon: SemanticIcon(
              icon: AppIcons.check,
              size: AppIconSize.small,
              semanticLabel: l10n.confirm,
            ),
            label: Text(l10n.confirm),
          ),
        ),
        const SizedBox(height: 8),
        // Back to quick actions
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              setState(() {
                _isManualMode = false;
              });
            },
            child: Text(l10n.back),
          ),
        ),
      ],
    );
  }
}

/// Card per mostrare un tempo (registrato o suggerito)
class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.duration,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String label;
  final String duration;
  final IconData icon;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: AppIconSize.large),
          const SizedBox(height: 8),
          Text(
            duration,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Ruota picker per ore/minuti
class _TimePickerWheel extends StatelessWidget {
  const _TimePickerWheel({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final int maxValue;
  final String label;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: (index) {
              HapticFeedback.selectionClick();
              onChanged(index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue + 1,
              builder: (context, index) {
                final isSelected = index == value;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
