import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Rep Continuum Distribution Card
///
/// Based on Schoenfeld et al. (2021):
/// "Loading Recommendations for Muscle Strength, Hypertrophy, and Local Endurance"
/// https://doi.org/10.1519/JSC.0000000000003932
///
/// Shows distribution of training across:
/// - Strength zone (1-5 reps)
/// - Hypertrophy zone (6-15 reps)
/// - Endurance zone (15+ reps)
class RepContinuumCard extends StatelessWidget {

  const RepContinuumCard({
    super.key,
    required this.workouts,
  });
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = VolumeAnalyzer.analyzeRepContinuum(workouts);

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
                      l10n.repContinuum,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.repContinuumSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.info),
                onPressed: () => _showScientificExplanation(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Total sets counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.totalSetsAnalyzed(data.totalSets),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Strength Zone
          _buildZoneRow(
            context,
            l10n.strengthZone,
            data.strengthPercentage,
            data.strengthSets,
            context.colors.error,
            l10n.strengthZoneDesc,
          ),
          const SizedBox(height: 12),

          // Hypertrophy Zone
          _buildZoneRow(
            context,
            l10n.hypertrophyZone,
            data.hypertrophyPercentage,
            data.hypertrophySets,
            theme.colorScheme.primary,
            l10n.hypertrophyZoneDesc,
          ),
          const SizedBox(height: 12),

          // Endurance Zone
          _buildZoneRow(
            context,
            l10n.enduranceZone,
            data.endurancePercentage,
            data.enduranceSets,
            context.colors.success,
            l10n.enduranceZoneDesc,
          ),
          const SizedBox(height: 20),

          // Visual stacked bar
          _buildStackedBar(context, data),
          const SizedBox(height: 16),

          // Recommendation
          _buildRecommendation(context, data),
          const SizedBox(height: 16),

          // Scientific citation
          _buildScientificCitation(context),
        ],
      ),
    );
  }

  Widget _buildZoneRow(
    BuildContext context,
    String label,
    double percentage,
    int sets,
    Color color,
    String description,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$sets sets',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStackedBar(BuildContext context, RepContinuumData data) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            if (data.strengthPercentage > 0)
              Expanded(
                flex: (data.strengthPercentage * 100).toInt(),
                child: Container(
                  color: context.colors.error,
                  alignment: Alignment.center,
                  child: data.strengthPercentage > 15
                      ? Text(
                          '${data.strengthPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              ),
            if (data.hypertrophyPercentage > 0)
              Expanded(
                flex: (data.hypertrophyPercentage * 100).toInt(),
                child: Container(
                  color: theme.colorScheme.primary,
                  alignment: Alignment.center,
                  child: data.hypertrophyPercentage > 15
                      ? Text(
                          '${data.hypertrophyPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              ),
            if (data.endurancePercentage > 0)
              Expanded(
                flex: (data.endurancePercentage * 100).toInt(),
                child: Container(
                  color: context.colors.success,
                  alignment: Alignment.center,
                  child: data.endurancePercentage > 15
                      ? Text(
                          '${data.endurancePercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, RepContinuumData data) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String recommendation;
    IconData icon;
    Color iconColor;

    if (data.hypertrophyPercentage >= 60) {
      recommendation = l10n.repContinuumRecommendationBalanced;
      icon = Icons.check_circle;
      iconColor = context.colors.success;
    } else if (data.strengthPercentage > 50) {
      recommendation = l10n.repContinuumRecommendationStrength;
      icon = Icons.fitness_center;
      iconColor = context.colors.error;
    } else if (data.endurancePercentage > 50) {
      recommendation = l10n.repContinuumRecommendationEndurance;
      icon = Icons.timer;
      iconColor = context.colors.success;
    } else {
      recommendation = l10n.repContinuumRecommendationMixed;
      icon = AppIcons.info;
      iconColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
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
            Icon(
              AppIcons.experiment,
              size: 20,
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
                    'Schoenfeld et al. (2021) - J Strength Cond Res',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.openInNew,
              size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
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
                      l10n.repContinuumScientificTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.repContinuumScientificSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Paper info
                    _buildPaperCard(
                      context,
                      'Schoenfeld et al. (2021)',
                      'Journal of Strength and Conditioning Research',
                      l10n.repContinuumPaperSummary,
                      'https://doi.org/10.1519/JSC.0000000000003932',
                    ),
                    const SizedBox(height: 20),

                    // Key findings
                    Text(
                      l10n.keyFindings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildFindingItem(
                      context,
                      l10n.repContinuumFinding1,
                      Icons.fitness_center,
                      context.colors.error,
                    ),
                    const SizedBox(height: 8),
                    _buildFindingItem(
                      context,
                      l10n.repContinuumFinding2,
                      AppIcons.trendUp,
                      theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    _buildFindingItem(
                      context,
                      l10n.repContinuumFinding3,
                      Icons.timer,
                      context.colors.success,
                    ),
                    const SizedBox(height: 20),

                    // Practical application
                    Text(
                      l10n.practicalApplication,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.repContinuumPracticalAdvice,
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
                Icon(
                  AppIcons.openInNew,
                  size: 20,
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

  Widget _buildFindingItem(
    BuildContext context,
    String text,
    IconData icon,
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
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _launchPaper() async {
    await _launchURL('https://doi.org/10.1519/JSC.0000000000003932');
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
