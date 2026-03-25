import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Hero card per iniziare o riprendere un workout
///
/// Stati:
/// - Nessun workout attivo: mostra "Start Workout" con opzioni
/// - Workout in corso: mostra "Resume" con stats
class StartWorkoutCard extends ConsumerWidget {
  const StartWorkoutCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final isWorkoutActive =
        currentWorkout != null &&
        (currentWorkout.status == WorkoutStatus.inProgress ||
            currentWorkout.status == WorkoutStatus.paused);

    if (isWorkoutActive) {
      return _ActiveWorkoutCard(workout: currentWorkout);
    }

    return const _InactiveWorkoutCard();
  }
}

/// Card compatto per workout attivo - mostra Resume
class _ActiveWorkoutCard extends ConsumerWidget {
  const _ActiveWorkoutCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseCount = workout.exercises.length;
    final completedSets = workout.exercises.fold<int>(
      0,
      (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        child: Semantics(
          label: context.l10n.resumeWorkout,
          button: true,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.go(AppRoutes.workoutPath);
            },
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Workout name and stats
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name.isNotEmpty
                                  ? workout.name
                                  : context.l10n.workout,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$exerciseCount ${context.l10n.exercises} • ${context.l10n.setsCompleted(completedSets)}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Resume button
                      FilledButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.go(AppRoutes.workoutPath);
                        },
                        icon: SemanticIcon(
                          icon: AppIcons.play,
                          semanticLabel: context.l10n.resume,
                          size: AppIconSize.small,
                        ),
                        label: Text(context.l10n.resume),
                        style: FilledButton.styleFrom(
                          padding: AppSpacing.button,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.sm),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Secondary actions row
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: context.l10n.finish,
                          button: true,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _showFinishConfirmation(context, ref);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                            ),
                            child: Text(context.l10n.finish),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Semantics(
                          label: context.l10n.discard,
                          button: true,
                          child: OutlinedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _showDiscardConfirmation(context, ref);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.error,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                            ),
                            child: Text(context.l10n.discard),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFinishConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.completeWorkout),
        content: Text(context.l10n.saveWorkoutQuestion),
        actions: [
          Semantics(
            label: context.l10n.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
          ),
          Semantics(
            label: context.l10n.finish,
            button: true,
            child: FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref
                    .read(currentWorkoutProvider.notifier)
                    .completeWorkout(context);
              },
              child: Text(context.l10n.finish),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscardConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.discardWorkoutTitle),
        content: Text(context.l10n.discardWorkoutQuestion),
        actions: [
          Semantics(
            label: context.l10n.cancel,
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancel),
            ),
          ),
          Semantics(
            label: context.l10n.discard,
            button: true,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(currentWorkoutProvider.notifier).clearWorkout();
              },
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.error,
              ),
              child: Text(context.l10n.discard),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card per avviare rapidamente un workout quando non ce n'e uno attivo.
class _InactiveWorkoutCard extends StatelessWidget {
  const _InactiveWorkoutCard();

  String _freeWorkoutRoute() {
    return Uri(
      path: AppRoutes.workoutPath,
      queryParameters: {
        'freeWorkout': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          onTap: () {
            HapticFeedback.mediumImpact();
            context.go(_freeWorkoutRoute());
          },
          child: Padding(
            padding: AppSpacing.card,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.flashOn,
                    semanticLabel: context.l10n.startNow,
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.startNow,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.startImmediately,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.arrowForwardIos,
                  semanticLabel: context.l10n.startNow,
                  size: AppIconSize.tiny,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
