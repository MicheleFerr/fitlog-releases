import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Strength Progression Chart - Shows strength progression over time for selected exercise
class StrengthProgressionChart extends StatelessWidget {
  const StrengthProgressionChart({
    super.key,
    required this.activities,
    this.selectedExerciseId,
    this.onExerciseSelected,
  });

  final List<ExerciseActivity> activities;
  final String? selectedExerciseId;
  final Function(String?)? onExerciseSelected;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement strength progression chart with fl_chart
    // For now, return a placeholder card

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.trendingUp,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Strength Progression',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.barChart,
                    size: 48,
                    color: context.colors.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chart implementation coming soon',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${activities.length} activities loaded',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.4),
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
}
