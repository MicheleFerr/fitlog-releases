import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class RecentWorkoutsCard extends StatelessWidget {

  const RecentWorkoutsCard({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final recentWorkouts = workouts.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.history,
                      color: context.colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.recentWorkouts,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full history
                    SnackBarService.showInfo(context, context.l10n.fullHistoryComingSoon);
                  },
                  child: Text(context.l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (recentWorkouts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    context.l10n.noRecentWorkouts,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.surfaceContainerHighest),
                  ),
                ),
              )
            else
              ...recentWorkouts.map((workout) {
                // Calculate total volume
                final totalVolume = workout.exercises.fold<double>(
                  0.0,
                  (sum, exercise) => sum + exercise.sets.fold<double>(
                    0.0,
                    (setSum, set) => setSum + (set.isCompleted ? (set.weight ?? 0) * (set.reps ?? 0) : 0),
                  ),
                );

                return _buildWorkoutItem(
                  context,
                  workout.name,
                  workout.createdAt,
                  workout.exercises.length,
                  totalVolume,
                  _convertWorkoutToActivities(workout),
                );
              }),
          ],
        ),
      ),
    );
  }

  // Helper to convert a Workout to a List<ExerciseActivity> for the details view
  List<ExerciseActivity> _convertWorkoutToActivities(Workout workout) {
    return workout.exercises.where((e) => e.sets.any((s) => s.isCompleted)).map((exercise) {
      return ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: '', // email is not available here, but might not be needed by the details view
        workoutName: workout.name,
        workoutDate: workout.endTime ?? workout.createdAt,
      );
    }).toList();
  }

  Widget _buildWorkoutItem(
    BuildContext context,
    String workoutName,
    DateTime date,
    int exerciseCount,
    double totalVolume,
    List<ExerciseActivity> activities,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showWorkoutDetails(context, activities),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Workout icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.workout,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Workout info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutName,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(date)} • ${context.l10n.exercisesWithCount(exerciseCount)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Volume
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${totalVolume.toStringAsFixed(0)} kg',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                Text(
                  context.l10n.volumeLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context, List<ExerciseActivity> syntheticActivities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.95);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: safeMax,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header with handle
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.colors.outline.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title and date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    syntheticActivities.first.schedaName,
                                    style: context.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(syntheticActivities.first.createdAt),
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: context.colors.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  AppIcons.close,
                                  color: context.colors.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Summary stats
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(context, '${syntheticActivities.length}', context.l10n.exercisesLabel),
                        _buildSummaryItem(
                          context,
                          '${syntheticActivities.fold<int>(0, (sum, a) => sum + a.sets.length)}',
                          context.l10n.totalSets
                        ),
                        _buildSummaryItem(
                          context,
                          '${_calculateWorkoutVolumeFromActivities(syntheticActivities).toStringAsFixed(0)} kg',
                          context.l10n.totalVolume
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Exercise list with expandable details
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: syntheticActivities.length,
                      itemBuilder: (context, index) {
                        final activity = syntheticActivities[index];
                        return _buildExerciseDetailCard(context, activity);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _calculateWorkoutVolumeFromActivities(List<ExerciseActivity> activities) {
    return activities.fold(0.0, (sum, activity) {
      return sum + activity.sets.fold(0.0, (setSum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return setSum + (weight * reps);
      });
    });
  }

  Widget _buildSummaryItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetailCard(BuildContext context, ExerciseActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Theme(
        data: context.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: activity.exerciseImage != null
                  ? Image.network(
                      activity.exerciseImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        AppIcons.workout,
                        color: context.colors.primary,
                      ),
                    )
                  : Icon(
                      AppIcons.workout,
                      color: context.colors.primary,
                    ),
            ),
          ),
          title: Text(
            activity.exerciseName,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                context.l10n.setsCount(activity.sets.length),
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.kgVolume(_calculateExerciseVolume(activity).toStringAsFixed(0)),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          children: [
            // Set details table
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            context.l10n.setHeader,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            context.l10n.weightKg,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            context.l10n.reps,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            context.l10n.effort,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            context.l10n.time,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Set rows
                  ...activity.sets.map((set) {
                    // RPE = 0 means warmup set
                    final isWarmupSet = set.isWarmup || (set.rpe != null && set.rpe == 0);

                    return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.colors.outline.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isWarmupSet
                                  ? context.colors.warning.withValues(alpha: 0.2)
                                  : set.done
                                      ? context.colors.primary.withValues(alpha: 0.2)
                                      : context.colors.outline.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                isWarmupSet ? 'W' : '${set.set}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isWarmupSet
                                      ? context.colors.warning
                                      : set.done
                                          ? context.colors.primary
                                          : context.colors.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set.weight,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set.actualReps ?? set.reps,
                            style: context.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildEffortIndicator(context, set.effort),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            set.setDurationMillis != null 
                                ? '${(set.setDurationMillis! / 1000).toStringAsFixed(0)}s'
                                : '-',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                  }),
                ],
              ),
            ),
            // Additional stats if available (exclude warmup sets with RPE=0)
            if (activity.sets.any((s) => s.rpe != null && s.rpe! > 0 || s.rir != null)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.tertiaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Exclude warmup sets (RPE=0) from average calculation
                    if (activity.sets.any((s) => s.rpe != null && s.rpe! > 0))
                      _buildAdditionalStat(
                        context,
                        context.l10n.averageRpe,
                        (activity.sets.where((s) => s.rpe != null && s.rpe! > 0).fold<int>(0, (sum, s) => sum + s.rpe!) / activity.sets.where((s) => s.rpe != null && s.rpe! > 0).length).toStringAsFixed(1),
                      ),
                    if (activity.sets.any((s) => s.rir != null))
                      _buildAdditionalStat(
                        context,
                        context.l10n.averageRir,
                        (activity.sets.where((s) => s.rir != null).fold<int>(0, (sum, s) => sum + s.rir!) / activity.sets.where((s) => s.rir != null).length).toStringAsFixed(1),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEffortIndicator(BuildContext context, int effort) {
    final colors = [
      HSLColor.fromColor(context.colors.success).withLightness(0.7).toColor(),
      HSLColor.fromColor(context.colors.success).withLightness(0.6).toColor(),
      const Color(0xFFFFB74D), // Orange 400
      const Color(0xFFFF9800), // Amber 400
      HSLColor.fromColor(context.colors.error).withLightness(0.6).toColor(),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          width: 6,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index < effort 
                ? colors[effort - 1]
                : context.colors.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildAdditionalStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.tertiary,
          ),
        ),
      ],
    );
  }

  double _calculateWorkoutVolume(List<ExerciseActivity> activities) {
    return activities.fold(0.0, (sum, activity) => sum + _calculateExerciseVolume(activity));
  }

  double _calculateExerciseVolume(ExerciseActivity activity) {
    return activity.sets.fold(0.0, (sum, set) {
      if (!set.done) return sum;
      final weight = double.tryParse(set.weight) ?? 0.0;
      final reps = int.tryParse(set.reps) ?? 0;
      return sum + (weight * reps);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
}
