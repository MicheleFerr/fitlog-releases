import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_template_cache_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Enhanced workout banner that shows active workout status
class EnhancedWorkoutBanner extends ConsumerWidget {

  const EnhancedWorkoutBanner({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Apple HIG standard padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    workout.isActive
                        ? Icons.fitness_center
                        : AppIcons.pauseCircle,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            workout.isActive
                                ? Icons.local_fire_department
                                : Icons.pause,
                            color: theme.colorScheme.onPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workout.isActive
                                ? l10n.workoutActive
                                : l10n.workoutPaused,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.name,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Apple HIG spacing
            Row(
              children: [
                Expanded(
                  child: _WorkoutStat(
                    icon: Icons.timer,
                    value: _formatDuration(workout.duration),
                    label: l10n.duration,
                  ),
                ),
                Expanded(
                  child: _WorkoutStat(
                    icon: Icons.fitness_center,
                    value: '${workout.completedSets}/${workout.totalSets}',
                    label: 'Sets',
                  ),
                ),
                Expanded(
                  child: _WorkoutStat(
                    icon: Icons.trending_up,
                    value: '${workout.completedExercises}/${workout.exercises.length}',
                    label: l10n.exercises,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Apple HIG spacing
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.goNamed('workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onPrimary,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      workout.isActive ? l10n.continueButton : l10n.resume,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showEndWorkoutDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.onPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.end,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEndWorkoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final workout = ref.read(currentWorkoutProvider);
    if (workout == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.fitness_center, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              l10n.endWorkout,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${workout.exercises.length} ${l10n.exercises.toLowerCase()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.howToEndWorkout, style: theme.textTheme.bodyLarge),
          ],
        ),
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          // Discard
          TextButton.icon(
            onPressed: () async {
              if (kDebugMode) {
                debugPrint('🗑️ [DISCARD BUTTON] Pressed - Starting discard workflow');
              }

              Navigator.pop(dialogContext);

              // 💾 CRITICAL FIX: Force save template modifications before discarding
              // This ensures any changes (notes, weights, reps) are preserved in the template
              if (kDebugMode) {
                debugPrint('💾 [DISCARD] Calling forceSave() before clearing workout...');
              }

              final cacheService = ref.read(workoutTemplateCacheServiceProvider);
              await cacheService.forceSave();

              if (kDebugMode) {
                debugPrint('✅ [DISCARD] forceSave() completed, now clearing workout');
              }

              ref.read(currentWorkoutProvider.notifier).clearWorkout();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(l10n.workoutDiscarded),
                    ],
                  ),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, size: 20),
            label: Text(l10n.discard),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
          // Save and end
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(currentWorkoutProvider.notifier).completeWorkout();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(l10n.workoutSavedSuccessfully),
                    ],
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                ref.read(currentWorkoutProvider.notifier).clearWorkout();
              });
            },
            icon: const Icon(Icons.save, size: 20),
            label: Text(l10n.saveAndEnd),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  String _formatDuration(Duration? duration) {
    if (duration == null) return '0m';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _WorkoutStat extends StatelessWidget {

  const _WorkoutStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min, // Apple HIG: compact layout
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6), // Apple HIG corner radius
          ),
          child: Icon(
            icon,
            size: 14, // Apple HIG icon sizing
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 6), // Apple HIG standard spacing
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 15, // Apple HIG body font size
            fontWeight: FontWeight.w600, // Apple preferred weight
            letterSpacing: -0.24, // Apple HIG letter spacing
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            fontSize: 11, // Apple HIG caption size
            fontWeight: FontWeight.w500,
            letterSpacing: 0.06,
          ),
        ),
      ],
    );
  }
}
