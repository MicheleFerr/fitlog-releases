import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Volume Heatmap - Shows training volume distribution over time
class VolumeHeatmap extends StatelessWidget {
  const VolumeHeatmap({
    super.key,
    required this.activities,
  });

  final List<ExerciseActivity> activities;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement volume heatmap with calendar heatmap
    // Similar to GitHub contribution graph
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
                  AppIcons.calendarMonth,
                  color: context.colors.secondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Volume Heatmap',
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
                    AppIcons.gridOn,
                    size: 48,
                    color: context.colors.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Heatmap implementation coming soon',
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
