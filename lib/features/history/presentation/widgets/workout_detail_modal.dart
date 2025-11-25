/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/history/presentation/widgets
/// 🎯 Feature: workout_history
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (AppLocalizations)
/// 🎨 Theme: ✅ YES (Theme.of(context))
/// 📱 Platform: Universal
///
/// WORKOUT DETAIL MODAL - Full details of a completed workout
///
/// Shows:
/// - Workout name and date
/// - All exercises with sets, reps, weight, RPE
/// - Color-coded RPE indicators
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal showing full workout details
class WorkoutDetailModal extends StatelessWidget {
  const WorkoutDetailModal({
    super.key,
    required this.workout,
  });

  final WorkoutHistoryDetail workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy - HH:mm').format(workout.completedAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                ),
              ],
            ),
          ),

          // Exercise Details
          Expanded(
            child: ListView.builder(
              key: PageStorageKey('workout_detail_exercises_${workout.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...exercise.sets.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.value.setNumber}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value.weight.toInt()}kg × ${entry.value.reps} reps',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRPEColor(entry.value.rpe, colorScheme),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'RPE ${entry.value.rpe}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRPEColor(int rpe, ColorScheme colorScheme) {
    if (rpe <= 6) {
      return colorScheme.tertiary.withValues(alpha: 0.2);
    } else if (rpe <= 8) {
      return colorScheme.secondary.withValues(alpha: 0.2);
    } else {
      return colorScheme.error.withValues(alpha: 0.2);
    }
  }
}
