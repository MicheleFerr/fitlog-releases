import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Volume Landmarks Dashboard
///
/// Based on Bernárdez-Vázquez et al. (2022):
/// "Resistance Training Variables for Optimization of Muscle Hypertrophy: An Umbrella Review"
/// https://doi.org/10.3390/healthcare10040674
///
/// Shows 4 volume zones per muscle group:
/// - MV (Maintenance Volume)
/// - MEV (Minimum Effective Volume)
/// - MAV (Maximum Adaptive Volume)
/// - MRV (Maximum Recoverable Volume)
class VolumeLandmarksCard extends StatelessWidget {

  const VolumeLandmarksCard({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final weeklySets = VolumeAnalyzer.calculateWeeklySets(workouts);
    final result = VolumeAnalyzer.calculateWeeklySetsWithExercises(workouts);
    final exercisesPerMuscle = result.categorized;
    final uncategorizedExercises = result.uncategorized;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.volumeLandmarks,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.volumeLandmarksSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
),
                onPressed: () => _showScientificExplanation(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Legend
          _buildLegend(context),
          const SizedBox(height: 20),

          // Muscle groups
          ...MuscleGroup.values.map((muscle) {
            final sets = weeklySets[muscle] ?? 0;
            final landmarks = VolumeAnalyzer.defaultLandmarks[muscle]!;
            final zone = VolumeAnalyzer.getVolumeZone(sets, muscle);
            final exercises = exercisesPerMuscle[muscle] ?? [];

            return Column(
              children: [
                _buildMuscleRow(context, muscle, sets, landmarks, zone, exercises),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Uncategorized exercises warning
          if (uncategorizedExercises.isNotEmpty) ...[
            _buildUncategorizedSection(context, uncategorizedExercises),
            const SizedBox(height: 20),
          ],

          // Scientific citation
          _buildScientificCitation(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(context, 'MV', l10n.maintenanceVolume, context.colors.surfaceContainerHighest),
        _buildLegendItem(context, 'MEV', l10n.minEffectiveVolume, context.colors.secondary),
        _buildLegendItem(context, 'MAV', l10n.maxAdaptiveVolume, context.colors.success),
        _buildLegendItem(context, 'MRV', l10n.maxRecoverableVolume, context.colors.error),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    String description,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleRow(
    BuildContext context,
    MuscleGroup muscle,
    int currentSets,
    VolumeLandmarks landmarks,
    VolumeZone zone,
    List<ExerciseContribution> exercises,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getMuscleDisplayName(muscle),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  '$currentSets',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getZoneColor(zone, theme.colorScheme),
                  ),
                ),
                Text(
                  ' ${l10n.setsPerWeek}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Volume bar
        Stack(
          children: [
            // Background bar
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Gradient zones
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  // MV zone (grey)
                  Expanded(
                    flex: landmarks.mv,
                    child: Container(
                      height: 24,
                      color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                  ),
                  // MEV to MAV zone (green gradient)
                  Expanded(
                    flex: landmarks.mav - landmarks.mv,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.secondary.withValues(alpha: 0.3),
                            context.colors.success.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // MAV to MRV zone (orange/red)
                  Expanded(
                    flex: landmarks.mrv - landmarks.mav,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.colors.success.withValues(alpha: 0.5),
                            context.colors.error.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Landmark markers
            _buildLandmarkMarker(context, landmarks.mv, landmarks.mrv, 'MV'),
            _buildLandmarkMarker(context, landmarks.mev, landmarks.mrv, 'MEV'),
            _buildLandmarkMarker(context, landmarks.mav, landmarks.mrv, 'MAV'),
            _buildLandmarkMarker(context, landmarks.mrv, landmarks.mrv, 'MRV'),

            // Current position indicator
            if (currentSets > 0)
              Positioned(
                left: _calculatePosition(currentSets, landmarks.mrv),
                top: -4,
                child: Column(
                  children: [
                    Container(
                      width: 3,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getZoneColor(zone, theme.colorScheme),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getZoneColor(zone, theme.colorScheme),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '●',
                        style: TextStyle(
                          color: context.colors.surface,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Zone indicator with dynamic explanations and exercises (expandable)
        _buildZoneIndicator(context, zone, currentSets, landmarks, muscle, exercises),
      ],
    );
  }

  Widget _buildLandmarkMarker(
    BuildContext context,
    int value,
    int maxValue,
    String label,
  ) {
    final theme = Theme.of(context);

    return Positioned(
      left: _calculatePosition(value, maxValue),
      bottom: 0,
      child: Container(
        transform: Matrix4.translationValues(-10, 0, 0),
        child: Column(
          children: [
            Container(
              width: 2,
              height: 8,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            Container(
              height: 24,
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePosition(int sets, int maxSets) {
    // Calculate position as percentage of total width
    // Add small padding to prevent overflow
    final percentage = (sets / (maxSets + 2)).clamp(0.0, 1.0);
    return percentage * 280; // Approximate card width minus padding
  }

  Widget _buildZoneIndicator(
    BuildContext context,
    VolumeZone zone,
    int currentSets,
    VolumeLandmarks landmarks,
    MuscleGroup muscle,
    List<ExerciseContribution> exercises,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String message;
    String explanation;
    String advice;
    IconData icon;
    Color color;

    switch (zone) {
      case VolumeZone.belowMaintenance:
        message = l10n.volumeZoneBelowMaintenance;
        explanation = l10n.volumeBelowMaintenanceExplanation(currentSets, landmarks.mv);
        advice = l10n.volumeBelowMaintenanceAdvice(landmarks.mv - currentSets);
        icon = AppIcons.trendingDown;
        color = context.colors.surfaceContainerHighest;
        break;
      case VolumeZone.maintenance:
        message = l10n.volumeZoneMaintenance;
        explanation = l10n.volumeMaintenanceExplanation(currentSets, landmarks.mv, landmarks.mev);
        advice = l10n.volumeMaintenanceAdvice(landmarks.mev - currentSets);
        icon = AppIcons.pauseCircleOutline;
        color = context.colors.surfaceContainerHighest;
        break;
      case VolumeZone.effective:
        message = l10n.volumeZoneEffective;
        explanation = l10n.volumeEffectiveExplanation(currentSets, landmarks.mev, landmarks.mav);
        advice = l10n.volumeEffectiveAdvice(landmarks.mav - currentSets);
        icon = AppIcons.trendingUp;
        color = context.colors.secondary;
        break;
      case VolumeZone.optimal:
        message = l10n.volumeZoneOptimal;
        explanation = l10n.volumeOptimalExplanation(currentSets, landmarks.mav, landmarks.mrv);
        advice = l10n.volumeOptimalAdvice;
        icon = AppIcons.checkCircle;
        color = context.colors.success;
        break;
      case VolumeZone.excessive:
        message = l10n.volumeZoneExcessive;
        explanation = l10n.volumeExcessiveExplanation(currentSets, landmarks.mrv);
        advice = l10n.volumeExcessiveAdvice(currentSets - landmarks.mrv);
        icon = AppIcons.warning;
        color = context.colors.error;
        break;
    }

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                message,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              SemanticIcon(
  icon: AppIcons.keyboardArrowDown,
  semanticLabel: 'Keyboard arrow down',
  size: AppIconSize.tiny,
  color: color,
),
            ],
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explanation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticIcon(
  icon: AppIcons.info,
  semanticLabel: 'Information',
  size: AppIconSize.tiny,
  color: color,
),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        explanation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Advice
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticIcon(
  icon: AppIcons.tip,
  semanticLabel: 'Tip',
  size: AppIconSize.tiny,
  color: color,
),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        advice,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Exercise breakdown
                if (exercises.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(color: color.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.tiny,
  color: color,
),
                      const SizedBox(width: 8),
                      Text(
                        l10n.exercisesThisWeek,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...exercises.map((exercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              exercise.exerciseName,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            '${exercise.sets} ${l10n.setsUnit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getZoneColor(VolumeZone zone, ColorScheme colorScheme) {
    switch (zone) {
      case VolumeZone.belowMaintenance:
      case VolumeZone.maintenance:
        return colorScheme.surfaceContainerHighest;
      case VolumeZone.effective:
        return colorScheme.secondary;
      case VolumeZone.optimal:
        return colorScheme.success;
      case VolumeZone.excessive:
        return colorScheme.error;
    }
  }

  String _getMuscleDisplayName(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return 'PETT';
      case MuscleGroup.back:
        return 'DORSO';
      case MuscleGroup.shoulders:
        return 'DELT';
      case MuscleGroup.arms:
        return 'BRACCI';
      case MuscleGroup.legs:
        return 'GAMBE';
      case MuscleGroup.core:
        return 'CORE';
    }
  }

  String _getMuscleGroupLocalizedName(BuildContext context, MuscleGroup muscle) {
    final l10n = AppLocalizations.of(context);
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chestMuscle;
      case MuscleGroup.back:
        return l10n.backMuscle;
      case MuscleGroup.shoulders:
        return l10n.shouldersMuscle;
      case MuscleGroup.arms:
        return l10n.armsMuscle;
      case MuscleGroup.legs:
        return l10n.legsMuscle;
      case MuscleGroup.core:
        return l10n.coreMuscle;
    }
  }

  Widget _buildUncategorizedSection(
    BuildContext context,
    List<ExerciseContribution> uncategorized,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.warningAmberRounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.uncategorizedExercises,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.uncategorizedExercisesDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          ...uncategorized.map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _showRemapDialog(context, exercise),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.workout,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.exerciseName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${exercise.sets} ${l10n.setsUnit} • ${exercise.category?.name ?? l10n.unknownCategory}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        AppIcons.edit,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScientificCitation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _launchPaper(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            SemanticIcon(
  icon: AppIcons.experiment,
  semanticLabel: 'Experiment',
  size: AppIconSize.small,
  color: theme.colorScheme.primary,
),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scientificBasis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bernárdez-Vázquez et al. (2022) - Healthcare',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SemanticIcon(
  icon: AppIcons.openInNew,
  semanticLabel: 'Open in new',
  size: AppIconSize.tiny,
  color: theme.colorScheme.primary.withValues(alpha: 0.7,
),
            ),
          ],
        ),
      ),
    );
  }

  void _showScientificExplanation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      l10n.volumeLandmarksScientificTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.volumeLandmarksScientificSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Paper info
                    _buildPaperCard(
                      context,
                      'Bernárdez-Vázquez et al. (2022)',
                      'Healthcare (MDPI)',
                      l10n.volumeLandmarksPaperSummary,
                      'https://doi.org/10.3390/healthcare10040674',
                    ),
                    const SizedBox(height: 20),

                    // Volume zones explanation
                    Text(
                      l10n.volumeZonesExplanation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildZoneExplanation(
                      context,
                      'MV',
                      l10n.mvExplanation,
                      context.colors.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 12),
                    _buildZoneExplanation(
                      context,
                      'MEV',
                      l10n.mevExplanation,
                      context.colors.secondary,
                    ),
                    const SizedBox(height: 12),
                    _buildZoneExplanation(
                      context,
                      'MAV',
                      l10n.mavExplanation,
                      context.colors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildZoneExplanation(
                      context,
                      'MRV',
                      l10n.mrvExplanation,
                      context.colors.error,
                    ),
                    const SizedBox(height: 20),

                    // Practical advice
                    Text(
                      l10n.practicalApplication,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.volumeLandmarksPracticalAdvice,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperCard(
    BuildContext context,
    String authors,
    String journal,
    String summary,
    String url,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.articleOutlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authors,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        journal,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SemanticIcon(
  icon: AppIcons.openInNew,
  semanticLabel: 'Open in new',
  size: AppIconSize.small,
  color: theme.colorScheme.primary,
),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneExplanation(
    BuildContext context,
    String label,
    String explanation,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            explanation,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _showRemapDialog(
    BuildContext context,
    ExerciseContribution exercise,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final muscleGroups = [
      (MuscleGroup.chest, l10n.chestMuscle, AppIcons.favorite),
      (MuscleGroup.back, l10n.backMuscle, AppIcons.grid4x4),
      (MuscleGroup.shoulders, l10n.shouldersMuscle, AppIcons.north),
      (MuscleGroup.arms, l10n.armsMuscle, AppIcons.sportsMartialArts),
      (MuscleGroup.legs, l10n.legsMuscle, AppIcons.directionsRun),
      (MuscleGroup.core, l10n.coreMuscle, AppIcons.favoriteBorder),
    ];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.edit, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.categorizeExercise,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.workout,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise.exerciseName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.selectCorrectMuscleGroup,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...muscleGroups.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, group.$1);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          group.$3,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          group.$2,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
        ],
      ),
    ).then((selectedGroup) {
      if (selectedGroup != null) {
        // Check if widget is still mounted before using context
        if (!context.mounted) return;

        // TODO: Save mapping to SharedPreferences/Hive
        // For now, show a snackbar
        final muscleGroupName = _getMuscleGroupLocalizedName(context, selectedGroup);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.remappingComingSoon(exercise.exerciseName, muscleGroupName),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Future<void> _launchPaper() async {
    await _launchURL('https://doi.org/10.3390/healthcare10040674');
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
