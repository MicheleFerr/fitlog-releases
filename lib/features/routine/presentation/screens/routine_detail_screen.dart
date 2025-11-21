/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/screens
/// 🎯 Feature: flexible_routine
/// 🔧 Type: screen
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// ROUTINE DETAIL SCREEN - Display Routine Details & Management
///
/// Features:
/// - Display routine name, preset type, training days
/// - Show workout schedule (day → template assignments)
/// - Statistics: total workouts, completed days, last workout date
/// - Action buttons: Activate/Deactivate, Delete (with confirmation)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_notifier.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:intl/intl.dart';

/// Routine Detail Screen - Display routine details and management options
class RoutineDetailScreen extends ConsumerWidget {
  const RoutineDetailScreen({
    super.key,
    required this.routine,
  });

  /// Route name for navigation
  static const String routeName = '/routine-detail';

  /// Routine to display
  final FlexibleRoutine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, ref),
            tooltip: context.l10n.delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card - Active status badge
            if (routine.isActive)
              Card(
                color: context.colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n.activeRoutine,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Basic info section
            Text(
              context.l10n.basicInfo,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      icon: Icons.fitness_center,
                      label: context.l10n.presetType,
                      value: routine.presetType.displayName,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      label: context.l10n.trainingDays,
                      value: '${routine.trainingDays.length} ${context.l10n.daysPerWeek}',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      icon: Icons.access_time,
                      label: context.l10n.createdAt,
                      value: _formatDate(routine.createdAt),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Workout schedule section
            Text(
              context.l10n.workoutSchedule,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildWorkoutSchedule(context),

            const SizedBox(height: 24),

            // Statistics section
            Text(
              context.l10n.statistics,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildStatistics(context),

            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  /// Build info row (icon + label + value)
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build workout schedule cards (day → template)
  Widget _buildWorkoutSchedule(BuildContext context) {
    final sortedDays = routine.trainingDays.toList()..sort();

    return Column(
      children: sortedDays.map((day) {
        final dayName = _getDayName(context, day);
        final templateId = routine.workoutSchedule[day];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colors.primaryContainer,
              child: Text(
                dayName.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(dayName),
            subtitle: Text(
              templateId ?? context.l10n.noTemplateAssigned,
              style: TextStyle(
                fontStyle: templateId == null ? FontStyle.italic : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build statistics cards
  Widget _buildStatistics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: context.colors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${routine.totalWorkouts}',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.totalWorkouts,
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: context.colors.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${routine.completedDays.length}',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.completedDays,
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build action buttons (Activate/Deactivate, Delete)
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Activate/Deactivate button
        if (!routine.isActive)
          FilledButton.icon(
            onPressed: () => _activateRoutine(context, ref),
            icon: const Icon(Icons.play_arrow),
            label: Text(context.l10n.activate),
          )
        else
          OutlinedButton.icon(
            onPressed: () => _deactivateRoutine(context, ref),
            icon: const Icon(Icons.pause),
            label: Text(context.l10n.deactivate),
          ),
      ],
    );
  }

  /// Get weekday name by number (1=Monday, 7=Sunday)
  String _getDayName(BuildContext context, int day) {
    switch (day) {
      case 1:
        return context.l10n.monday;
      case 2:
        return context.l10n.tuesday;
      case 3:
        return context.l10n.wednesday;
      case 4:
        return context.l10n.thursday;
      case 5:
        return context.l10n.friday;
      case 6:
        return context.l10n.saturday;
      case 7:
        return context.l10n.sunday;
      default:
        return '';
    }
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteRoutine),
        content: Text(context.l10n.deleteRoutineConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        _deleteRoutine(context, ref);
      }
    });
  }

  /// Activate routine
  Future<void> _activateRoutine(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final errorColor = context.colors.error;

    await ref.read(flexibleRoutineNotifierProvider.notifier).activateRoutine(routine.id);

    final state = ref.read(flexibleRoutineNotifierProvider);
    if (state.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.routineActivated)),
    );
    navigator.pop(); // Go back to Routine Center
  }

  /// Deactivate routine
  Future<void> _deactivateRoutine(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final errorColor = context.colors.error;

    await ref.read(flexibleRoutineNotifierProvider.notifier).deactivateAllRoutines();

    final state = ref.read(flexibleRoutineNotifierProvider);
    if (state.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.routineDeactivated)),
    );
    navigator.pop(); // Go back to Routine Center
  }

  /// Delete routine
  Future<void> _deleteRoutine(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    final errorColor = context.colors.error;

    await ref.read(flexibleRoutineNotifierProvider.notifier).deleteRoutine(routine.id);

    final state = ref.read(flexibleRoutineNotifierProvider);
    if (state.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.routineDeleted)),
    );
    navigator.pop(); // Go back to Routine Center
  }
}
