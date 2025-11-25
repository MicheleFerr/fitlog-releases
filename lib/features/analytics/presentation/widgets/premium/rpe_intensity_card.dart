import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/rpe_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// RPE & Intensity Distribution Card
///
/// Based on Helms et al. (2018) and Zourdos et al. (2016):
/// - Optimal hypertrophy: 60-80% of sets at RPE 7-9
/// - Optimal strength: 50-70% of sets at RPE 8-10
/// - Recovery: RPE 5-6
/// - Maximal effort: RPE 10
class RPEIntensityCard extends StatelessWidget {

  const RPEIntensityCard({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final distribution = RPEAnalyzer.analyzeRPEDistribution(workouts);
    final perMuscleGroup = RPEAnalyzer.analyzeRPEPerMuscleGroup(workouts);
    final zone = RPEAnalyzer.getIntensityZone(distribution);

    if (distribution.totalSetsWithRPE == 0) {
      return _buildNoDataState(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppIcons.speed,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rpeAndIntensity,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.rpeIntensityDistribution,
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
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Total sets tracked
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.setsWithRPETracked,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '${distribution.totalSetsWithRPE}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // RPE Distribution Bar
          _buildRPEDistributionBar(context, distribution),
          const SizedBox(height: 20),

          // Intensity Zone Indicator
          _buildIntensityZoneIndicator(context, zone, distribution),
          const SizedBox(height: 20),

          // RPE per Muscle Group
          Text(
            l10n.averageRPEPerMuscleGroup,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...MuscleGroup.values.map((muscle) {
            final stats = perMuscleGroup[muscle];
            if (stats == null || stats.totalSets == 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMuscleRPERow(context, muscle, stats),
            );
          }),

          const SizedBox(height: 20),

          // Scientific Reference
          _buildScientificReference(context),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SemanticIcon(
  icon: AppIcons.speedOutlined,
  semanticLabel: 'Speed outlined',
  size: AppIconSize.medium,
  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5,
),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRPEDataAvailable,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noRPEDataDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRPEDistributionBar(
    BuildContext context,
    RPEDistributionData distribution,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final total = distribution.totalSetsWithRPE;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.rpeDistribution,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Stacked bar
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                if (distribution.recoverySets > 0)
                  _buildBarSegment(
                    context,
                    distribution.recoverySets / total,
                    context.successColor.withOpacity(0.6),
                  ),
                if (distribution.moderateSets > 0)
                  _buildBarSegment(
                    context,
                    distribution.moderateSets / total,
                    context.colors.tertiary.withOpacity(0.7),
                  ),
                if (distribution.hardSets > 0)
                  _buildBarSegment(
                    context,
                    distribution.hardSets / total,
                    context.warningColor.withOpacity(0.7),
                  ),
                if (distribution.veryHardSets > 0)
                  _buildBarSegment(
                    context,
                    distribution.veryHardSets / total,
                    context.warningColor,
                  ),
                if (distribution.maximalSets > 0)
                  _buildBarSegment(
                    context,
                    distribution.maximalSets / total,
                    context.errorColor,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(
              context,
              l10n.rpeRecovery,
              context.successColor.withOpacity(0.6),
              '${distribution.recoveryPercentage.toStringAsFixed(0)}%',
            ),
            _buildLegendItem(
              context,
              l10n.rpeModerate,
              context.colors.tertiary.withOpacity(0.7),
              '${distribution.moderatePercentage.toStringAsFixed(0)}%',
            ),
            _buildLegendItem(
              context,
              l10n.rpeHard,
              context.warningColor.withOpacity(0.7),
              '${distribution.hardPercentage.toStringAsFixed(0)}%',
            ),
            _buildLegendItem(
              context,
              l10n.rpeVeryHard,
              context.warningColor,
              '${distribution.veryHardPercentage.toStringAsFixed(0)}%',
            ),
            _buildLegendItem(
              context,
              l10n.rpeMaximal,
              context.errorColor,
              '${distribution.maximalPercentage.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarSegment(BuildContext context, double fraction, Color color) {
    return Expanded(
      flex: (fraction * 1000).toInt(),
      child: Container(
        color: color,
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    String percentage,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 4),
        Text(
          percentage,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityZoneIndicator(
    BuildContext context,
    IntensityZone zone,
    RPEDistributionData distribution,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String title;
    String description;
    String advice;
    IconData icon;
    Color color;

    switch (zone) {
      case IntensityZone.tooEasy:
        title = l10n.intensityZoneTooEasy;
        description = l10n.intensityZoneTooEasyDesc;
        advice = l10n.intensityZoneTooEasyAdvice;
        icon = AppIcons.trendingDown;
        color = context.colors.outline;
        break;
      case IntensityZone.optimalHypertrophy:
        title = l10n.intensityZoneOptimalHypertrophy;
        description = l10n.intensityZoneOptimalHypertrophyDesc;
        advice = l10n.intensityZoneOptimalHypertrophyAdvice;
        icon = AppIcons.trendingUp;
        color = context.successColor;
        break;
      case IntensityZone.optimalStrength:
        title = l10n.intensityZoneOptimalStrength;
        description = l10n.intensityZoneOptimalStrengthDesc;
        advice = l10n.intensityZoneOptimalStrengthAdvice;
        icon = AppIcons.fitnessCenter;
        color = context.infoColor;
        break;
      case IntensityZone.balanced:
        title = l10n.intensityZoneBalanced;
        description = l10n.intensityZoneBalancedDesc;
        advice = l10n.intensityZoneBalancedAdvice;
        icon = AppIcons.balance;
        color = context.warningColor;
        break;
      case IntensityZone.tooHard:
        title = l10n.intensityZoneTooHard;
        description = l10n.intensityZoneTooHardDesc;
        advice = l10n.intensityZoneTooHardAdvice;
        icon = AppIcons.warning;
        color = context.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.tip,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    advice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleRPERow(
    BuildContext context,
    MuscleGroup muscle,
    RPEStats stats,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Color getRPEColor(double rpe) {
      if (rpe <= 6) return context.successColor;
      if (rpe <= 7) return context.infoColor;
      if (rpe <= 8) return context.warningColor;
      if (rpe <= 9) return context.warningColor;
      return context.errorColor;
    }

    final avgColor = getRPEColor(stats.averageRPE);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMuscleGroupName(context, muscle),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${stats.totalSets} ${l10n.setsUnit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'RPE ${stats.averageRPE.toStringAsFixed(1)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: avgColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${l10n.rangeLabel} ${stats.minRPE}-${stats.maxRPE}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMuscleGroupName(BuildContext context, MuscleGroup muscle) {
    final l10n = AppLocalizations.of(context);
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chestMuscle.toUpperCase();
      case MuscleGroup.back:
        return l10n.backMuscle.toUpperCase();
      case MuscleGroup.shoulders:
        return l10n.shouldersMuscle.toUpperCase();
      case MuscleGroup.arms:
        return l10n.armsMuscle.toUpperCase();
      case MuscleGroup.legs:
        return l10n.legsMuscle.toUpperCase();
      case MuscleGroup.core:
        return l10n.coreMuscle.toUpperCase();
    }
  }

  Widget _buildScientificReference(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _launchURL('https://doi.org/10.1519/SSC.0000000000000373'),
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
        child: Row(
          children: [
            Icon(
              AppIcons.experiment,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scientificBasis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.helmsEtAl2018,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.openInNew,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.info, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(l10n.rpeInfoTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.rpeInfoDescription,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _buildRPEExplanationRow(l10n.rpeScale5_6, l10n.rpeScale5_6Desc, context.successColor),
              _buildRPEExplanationRow(l10n.rpeScale7, l10n.rpeScale7Desc, context.infoColor),
              _buildRPEExplanationRow(l10n.rpeScale8, l10n.rpeScale8Desc, context.warningColor),
              _buildRPEExplanationRow(l10n.rpeScale9, l10n.rpeScale9Desc, context.warningColor),
              _buildRPEExplanationRow(l10n.rpeScale10, l10n.rpeScale10Desc, context.errorColor),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.optimalDistribution,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.hypertrophyDistribution}\n'
                '${l10n.strengthDistribution}\n'
                '${l10n.recoveryDistribution}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.closeButton),
          ),
        ],
      ),
    );
  }

  Widget _buildRPEExplanationRow(String rpe, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$rpe: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(description),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
