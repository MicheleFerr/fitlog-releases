/// Import Preview Widget
///
/// Shows a preview of parsed workout data before import.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:intl/intl.dart';

/// Preview widget for parsed import data
class ImportPreviewWidget extends StatelessWidget {
  const ImportPreviewWidget({super.key, required this.result});

  final ImportParseResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary stats
        _buildStatCards(context),
        const SizedBox(height: 16),

        // Workout list preview
        Text(context.l10n.recentWorkouts, style: context.textTheme.titleSmall),
        const SizedBox(height: 8),
        ...result.workouts.take(5).map((w) => _buildWorkoutTile(context, w)),

        if (result.workouts.length > 5) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.andMoreWorkouts(result.workouts.length - 5),
            style: context.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: AppIcons.workout,
            label: context.l10n.workouts,
            value: '${result.workouts.length}',
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: AppIcons.exercise,
            label: context.l10n.exercises,
            value: '${result.unmappedExercises.length}',
            color: context.colors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: AppIcons.check,
            label: context.l10n.rows,
            value: '${result.parsedRows}/${result.totalRows}',
            color: context.colors.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTile(BuildContext context, ParsedWorkout workout) {
    final dateFormat = DateFormat.yMMMd();
    final exerciseCount = workout.exercises.length;
    final setCount = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.length,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              AppIcons.workout,
              color: context.colors.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(workout.name),
        subtitle: Text(
          '${dateFormat.format(workout.date)} • $exerciseCount ${context.l10n.exercises} • $setCount sets',
        ),
        trailing: workout.durationMinutes != null
            ? Text(
                '${workout.durationMinutes} min',
                style: context.textTheme.bodySmall,
              )
            : null,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
    );
  }
}
