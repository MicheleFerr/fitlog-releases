import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_analyzer.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';

/// Scientific Muscle Balance Widget with clear bar chart visualization
///
/// Shows:
/// - Volume distribution by muscle group
/// - Push:Pull ratio (Boyle, 2016)
/// - Quad:Hamstring ratio (Croisier et al., 2008)
class ScientificMuscleBalanceWidget extends StatelessWidget {

  const ScientificMuscleBalanceWidget({
    super.key,
    required this.activities,
    this.showRatios = true,
  });
  final List<ExerciseActivity> activities;
  final bool showRatios;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final distribution = MuscleBalanceAnalyzer.analyzeDistribution(activities);
    final pushPull = MuscleBalanceAnalyzer.analyzePushPullBalance(activities);
    final quadHam = MuscleBalanceAnalyzer.analyzeQuadHamstringBalance(activities);

    if (distribution.totalVolume == 0) {
      return _buildEmptyState(context, l10n);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.muscleBalance,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.volumeDistribution,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => _showHelpDialog(context, l10n),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Volume Distribution Bar Chart
            _buildVolumeBarChart(
              context,
              distribution.percentageDistribution,
              colorScheme,
            ),

            if (showRatios) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Scientific Ratios
              Text(
                l10n.scientificRatios,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Push:Pull Ratio
              _buildRatioCard(
                context,
                icon: Icons.sync_alt,
                title: l10n.pushPullRatio,
                ratio: pushPull.ratio,
                targetRange: '0.8-1.2',
                feedback: _translateFeedback(context, MuscleBalanceAnalyzer.getPushPullFeedback(pushPull.ratio)),
                isBalanced: pushPull.isBalanced,
                details: '${l10n.pushSetsLabel(pushPull.pushSets)}, ${l10n.pullSetsLabel(pushPull.pullSets)}',
              ),

              const SizedBox(height: 12),

              // Quad:Ham Ratio
              _buildRatioCard(
                context,
                icon: Icons.directions_run,
                title: l10n.quadHamstringRatio,
                ratio: quadHam.ratio,
                targetRange: '0.6-1.0',
                feedback: _translateFeedback(context, MuscleBalanceAnalyzer.getQuadHamFeedback(quadHam.ratio)),
                isBalanced: quadHam.isBalanced,
                details: '${l10n.quadSetsLabel(quadHam.quadSets)}, ${l10n.hamstringSetsLabel(quadHam.hamstringSets)}',
                isHighRisk: quadHam.isHighRisk,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeBarChart(
    BuildContext context,
    Map<String, double> distribution,
    ColorScheme colorScheme,
  ) {
    final sortedGroups = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedGroups.map((entry) {
        final color = _getColorForMuscleGroup(entry.key, colorScheme);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Background bar
                        Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        // Filled bar
                        FractionallySizedBox(
                          widthFactor: entry.value / 100,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        // Percentage text
                        Container(
                          height: 28,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            '${entry.value.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: entry.value > 15
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatioCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double ratio,
    required String targetRange,
    required String feedback,
    required bool isBalanced,
    required String details,
    bool isHighRisk = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    if (isHighRisk) {
      statusColor = Colors.red;
    } else if (isBalanced) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).targetRange(targetRange),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${ratio.toStringAsFixed(2)}:1',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noMuscleGroupData,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForMuscleGroup(String group, ColorScheme colorScheme) {
    switch (group) {
      case 'Chest':
        return Colors.blue;
      case 'Back':
        return Colors.green;
      case 'Shoulders':
        return Colors.orange;
      case 'Legs':
        return Colors.purple;
      case 'Arms':
        return Colors.red;
      case 'Core':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.muscleBalanceScience),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.muscleBalanceExplanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildScientificReference(
                context,
                title: AppLocalizations.of(context).pushPullRatio,
                reference: 'Boyle (2016)',
                explanation: AppLocalizations.of(context).pushPullExplanation,
              ),
              const SizedBox(height: 12),
              _buildScientificReference(
                context,
                title: AppLocalizations.of(context).quadHamstringRatio,
                reference: 'Croisier et al. (2008)',
                explanation: AppLocalizations.of(context).quadHamExplanation,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificReference(
    BuildContext context, {
    required String title,
    required String reference,
    required String explanation,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '📚 $reference',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Translate feedback key to localized string
  String _translateFeedback(BuildContext context, String feedbackKey) {
    final l10n = AppLocalizations.of(context);

    switch (feedbackKey) {
      case 'feedbackTooMuchPull':
        return l10n.feedbackTooMuchPull;
      case 'feedbackTooMuchPush':
        return l10n.feedbackTooMuchPush;
      case 'feedbackSlightPushExcess':
        return l10n.feedbackSlightPushExcess;
      case 'feedbackOptimalPushPull':
        return l10n.feedbackOptimalPushPull;
      case 'feedbackGoodPullEmphasis':
        return l10n.feedbackGoodPullEmphasis;
      case 'feedbackHamstringSeverelyUndertrained':
        return l10n.feedbackHamstringSeverelyUndertrained;
      case 'feedbackHamstringUndertrained':
        return l10n.feedbackHamstringUndertrained;
      case 'feedbackOptimalQuadHam':
        return l10n.feedbackOptimalQuadHam;
      case 'feedbackHamstringOveremphasized':
        return l10n.feedbackHamstringOveremphasized;
      default:
        return feedbackKey; // Fallback to key if not found
    }
  }
}
