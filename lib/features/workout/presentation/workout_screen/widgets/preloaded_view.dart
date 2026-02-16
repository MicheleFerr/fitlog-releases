import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/change_workout_banner.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Preloaded workout view displayed when a workout is suggested/loaded
/// but not yet started.
///
/// Shows the workout name with a "suggested" badge, the list of exercises
/// in premium cards with series preview, a banner to change the workout,
/// and a prominent start button.
class PreloadedView extends ConsumerWidget {
  const PreloadedView({
    required this.workout,
    required this.sessionId,
    required this.onStartWorkout,
    required this.onBrowseTemplates,
    super.key,
  });

  /// The preloaded workout to display
  final Workout workout;

  /// Session ID for analytics correlation
  final String sessionId;

  /// Callback when the user starts the workout
  final VoidCallback onStartWorkout;

  /// Callback when the user wants to browse other templates
  final VoidCallback onBrowseTemplates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      left: false,
      right: false,
      bottom: false, // Allow content to scroll under bottom navigation bar
      child: Column(
        children: [
          // "Change Workout" banner
          ChangeWorkoutBanner(onBrowseTemplates: onBrowseTemplates),

          // Exercise list with premium cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                return _buildExerciseCard(context, exercise, index + 1);
              },
            ),
          ),

          // Start button - full width, prominent
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(
                top: BorderSide(
                  color: context.colors.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: FilledButton.icon(
              onPressed: onStartWorkout,
              icon: SemanticIcon(
                icon: AppIcons.playArrowRounded,
                size: AppIconSize.medium,
                semanticLabel: context.l10n.startWorkout,
              ),
              label: Text(
                context.l10n.startWorkout,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    dynamic exercise,
    int orderNumber,
  ) {
    // Build series preview (e.g., "4 × 10 reps" or "4 × 10 @ 80kg")
    String seriesPreview = '';
    if (exercise.sets != null && exercise.sets.isNotEmpty) {
      final numSets = exercise.sets.length;
      final firstSet = exercise.sets.first;

      if (firstSet.reps != null) {
        seriesPreview = '$numSets × ${firstSet.reps} ${context.l10n.reps}';

        // Add weight if available
        if (firstSet.weight != null && firstSet.weight! > 0) {
          seriesPreview += ' @ ${firstSet.weight}kg';
        }
      } else if (firstSet.seconds != null) {
        seriesPreview = '$numSets × ${firstSet.seconds}${context.l10n.seconds}';
      } else if (firstSet.distance != null) {
        seriesPreview =
            '$numSets × ${firstSet.distance}${context.l10n.meters}';
      }
    }

    // Estimated duration (basic: sets × (rest time + ~30s per set))
    int estimatedMinutes = 0;
    if (exercise.sets != null && exercise.restTime != null) {
      final totalSeconds =
          exercise.sets.length * (exercise.restTime! + 30); // ~30s per set
      estimatedMinutes = (totalSeconds / 60).ceil();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Order number badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Center(
                child: Text(
                  '$orderNumber',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name
                  Text(
                    exercise.name as String,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),

                  // Category/muscle group
                  Row(
                    children: [
                      SemanticIcon(
                        icon: _getCategoryIcon(exercise.category),
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                        semanticLabel: exercise.category.toString(),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        _getCategoryName(context, exercise.category),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // Series preview
                  if (seriesPreview.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      seriesPreview,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],

                  // Estimated duration
                  if (estimatedMinutes > 0) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.timer,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                          semanticLabel: context.l10n.duration,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '~$estimatedMinutes ${context.l10n.minutes}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(dynamic category) {
    // Convert enum to string and match
    final categoryStr = category.toString().split('.').last.toLowerCase();

    switch (categoryStr) {
      case 'chest':
        return AppIcons.fitnessCenterRounded;
      case 'back':
        return AppIcons.back;
      case 'shoulders':
        return AppIcons.sports; // shoulder icon not available, use sports
      case 'arms':
        return AppIcons.fitnessCenterRounded; // arm icon not available, use fitness
      case 'legs':
        return AppIcons.directionsWalk; // legPress not available, use walk
      case 'abs':
        return AppIcons.fitnessCenterRounded; // abs icon not available, use fitness
      case 'cardio':
        return AppIcons.cardio;
      default:
        return AppIcons.fitnessCenterRounded;
    }
  }

  String _getCategoryName(BuildContext context, dynamic category) {
    final categoryStr = category.toString().split('.').last;

    // Use l10n if available, otherwise capitalize
    switch (categoryStr.toLowerCase()) {
      case 'chest':
        return context.l10n.chest;
      case 'back':
        return context.l10n.back;
      case 'shoulders':
        return context.l10n.shoulders;
      case 'arms':
        return context.l10n.arms;
      case 'legs':
        return context.l10n.legs;
      case 'abs':
        return context.l10n.abs;
      case 'cardio':
        return context.l10n.cardio;
      default:
        return categoryStr;
    }
  }
}
