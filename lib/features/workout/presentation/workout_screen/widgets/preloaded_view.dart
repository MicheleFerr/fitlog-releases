import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen/widgets/change_workout_banner.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Preloaded workout view displayed when a workout is suggested/loaded
/// but not yet started.
///
/// Shows the workout name with a "suggested" badge, the list of exercises,
/// a banner to change the workout, and a start button.
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

          // Exercise list
          Expanded(
            child: ListView.builder(
              itemCount: workout.exercises.length,
              itemBuilder: (_, i) {
                final exercise = workout.exercises[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(exercise.name),
                  subtitle: Text(exercise.category.toString().split('.').last),
                );
              },
            ),
          ),

          // Start button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: onStartWorkout,
              icon: const SemanticIcon(
                icon: AppIcons.playArrowRounded,
                semanticLabel: 'Play arrow rounded',
              ),
              label: Text(context.l10n.startWorkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.successColor,
                foregroundColor: context.colors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl + AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
