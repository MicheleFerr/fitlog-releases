/// Stress Prediction Card
///
/// Compact home screen card showing stress prediction and recovery recommendation.
/// Uses Banister FFM exponential decay model for predictions.
///
/// **Features**:
/// - Current stress level with color coding
/// - Predicted stress tomorrow (if resting)
/// - Recovery recommendation badge
/// - Tap to expand for details
///
/// **Scientific Basis**:
/// - Banister Fitness-Fatigue Model (τ₂ = 10 days base)
/// - Personal calibration from age, training age, HRV baseline
/// - Sleep/HRV daily modulation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/prediction_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/template_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Stress Prediction Card for home screen
///
/// Shows current stress, tomorrow's prediction, and recovery recommendation.
class StressPredictionCard extends ConsumerWidget {
  const StressPredictionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(stressInsightProvider);

    return insightAsync.when(
      data: (insight) {
        // Don't show if no stress data (first time user)
        if (insight.currentStress <= 0 && insight.predictedTomorrow <= 0) {
          return const SizedBox.shrink();
        }

        return _StressPredictionContent(insight: insight);
      },
      loading: () => _buildLoadingState(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: const Center(child: LoadingIndicator()),
    );
  }
}

/// Content widget showing stress prediction
class _StressPredictionContent extends StatelessWidget {
  const _StressPredictionContent({required this.insight});

  final StressInsight insight;

  Color _getRecommendationColor(
    RecoveryRecommendation recommendation,
    BuildContext context,
  ) {
    return switch (recommendation) {
      RecoveryRecommendation.readyHard => context.successColor,
      RecoveryRecommendation.moderate => context.warningColor,
      RecoveryRecommendation.lightOnly => context.colors.tertiary,
      RecoveryRecommendation.activeRecovery => context.errorColor,
      RecoveryRecommendation.restRequired => context.errorColor,
    };
  }

  IconData _getRecommendationIcon(RecoveryRecommendation recommendation) {
    return switch (recommendation) {
      RecoveryRecommendation.readyHard => AppIcons.checkCircle,
      RecoveryRecommendation.moderate => AppIcons.schedule,
      RecoveryRecommendation.lightOnly => AppIcons.warning,
      RecoveryRecommendation.activeRecovery => AppIcons.nightlight,
      RecoveryRecommendation.restRequired => AppIcons.block,
    };
  }

  String _getRecommendationLabel(
    RecoveryRecommendation recommendation,
    BuildContext context,
  ) {
    return switch (recommendation) {
      RecoveryRecommendation.readyHard =>
        context.l10n.stressRecommendationReadyHard,
      RecoveryRecommendation.moderate =>
        context.l10n.stressRecommendationModerate,
      RecoveryRecommendation.lightOnly =>
        context.l10n.stressRecommendationLightOnly,
      RecoveryRecommendation.activeRecovery =>
        context.l10n.stressRecommendationActiveRecovery,
      RecoveryRecommendation.restRequired =>
        context.l10n.stressRecommendationRestRequired,
    };
  }

  Color _getStressColor(double stress, BuildContext context) {
    if (stress < 30) {
      return context.successColor;
    } else if (stress < 50) {
      return context.warningColor;
    } else if (stress < 70) {
      return context.colors.tertiary;
    } else {
      return context.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final recColor = _getRecommendationColor(insight.recommendation, context);
    final recIcon = _getRecommendationIcon(insight.recommendation);
    final recLabel = _getRecommendationLabel(insight.recommendation, context);
    final stressColor = _getStressColor(insight.currentStress, context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: recColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: context.colors.surface.withValues(alpha: 0),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showDetailsSheet(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with title and recommendation badge
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: recColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SemanticIcon(
                          icon: recIcon,
                          semanticLabel: recLabel,
                          color: recColor,
                          size: AppIconSize.small,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.stressPredictionTitle,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              recLabel,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Expand hint
                      SemanticIcon(
                        icon: AppIcons.infoOutline,
                        semanticLabel: 'Details',
                        color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                        size: AppIconSize.small,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Current stress
                      _buildMetric(
                        context,
                        label: context.l10n.stressPredictionCurrent,
                        value: '${insight.displayStress}',
                        color: stressColor,
                      ),
                      // Divider
                      Container(
                        width: 1,
                        height: 40,
                        color: context.colors.outline.withValues(alpha: 0.2),
                      ),
                      // Tomorrow prediction
                      _buildMetric(
                        context,
                        label: context.l10n.stressPredictionTomorrow,
                        value: '${insight.displayPredicted}',
                        color: _getStressColor(
                          insight.predictedTomorrow,
                          context,
                        ),
                      ),
                      // Divider
                      Container(
                        width: 1,
                        height: 40,
                        color: context.colors.outline.withValues(alpha: 0.2),
                      ),
                      // Recovery rate
                      _buildMetric(
                        context,
                        label: context.l10n.stressPredictionRecoveryRate,
                        value:
                            '-${insight.recoveryRatePerHour.toStringAsFixed(1)}/h',
                        color: context.colors.primary,
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

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDetailsSheet(BuildContext context) {
    final recColor = _getRecommendationColor(insight.recommendation, context);
    final recIcon = _getRecommendationIcon(insight.recommendation);
    final recLabel = _getRecommendationLabel(insight.recommendation, context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(sheetContext).padding.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: recColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SemanticIcon(
                      icon: recIcon,
                      semanticLabel: recLabel,
                      color: recColor,
                      size: AppIconSize.medium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.stressPredictionTitle,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          recLabel,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Rationale
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticIcon(
                      icon: AppIcons.tip,
                      semanticLabel: 'Info',
                      color: context.colors.onSurfaceVariant,
                      size: AppIconSize.small,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight.rationale,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detailed metrics
              _buildDetailedMetrics(context),
              const SizedBox(height: 20),

              // Calibration quality indicator
              if (insight.calibrationQuality.name != 'excellent')
                _buildCalibrationHint(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailedMetrics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            label: context.l10n.stressPredictionCurrent,
            value: '${insight.displayStress}',
            icon: AppIcons.barChart,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            label: context.l10n.stressPredictionTomorrow,
            value: '${insight.displayPredicted}',
            icon: AppIcons.schedule,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            label: context.l10n.stressPredictionIfWorkout,
            value: '${insight.predictedIfWorkout.round()}',
            icon: AppIcons.fitnessCenter,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            label: context.l10n.stressPredictionRecoveryRate,
            value: '-${insight.recoveryRatePerHour.toStringAsFixed(1)}/h',
            icon: AppIcons.trending,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        SemanticIcon(
          icon: icon,
          semanticLabel: label,
          color: context.colors.onSurfaceVariant,
          size: AppIconSize.small,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.infoOutline,
            semanticLabel: 'Hint',
            color: context.colors.primary,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.stressPredictionCalibrationHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
