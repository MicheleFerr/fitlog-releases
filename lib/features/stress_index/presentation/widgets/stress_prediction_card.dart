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
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/prediction_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
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

    // BUGFIX: Capture all l10n strings BEFORE showing bottom sheet
    final l10n = context.l10n;
    final titleText = l10n.stressPredictionTitle;
    final currentText = l10n.stressPredictionCurrent;
    final tomorrowText = l10n.stressPredictionTomorrow;
    final ifWorkoutText = l10n.stressPredictionIfWorkout;
    final recoveryRateText = l10n.stressPredictionRecoveryRate;
    final calibrationHintText = l10n.stressPredictionCalibrationHint;
    final editProfileText = l10n.editProfile;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true, // Allow larger sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        // Use Consumer to access stress history for workout details
        return Consumer(
          builder: (consumerContext, ref, _) {
            final stressState = ref.watch(stressIndexNotifierProvider);
            final history = stressState.valueOrNull?.history ?? [];
            final latestResult = history.isNotEmpty ? history.first : null;

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.md,
                    bottom: MediaQuery.of(sheetContext).padding.bottom +
                        AppSpacing.lg,
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
                            color: sheetContext.colors.outline
                                .withValues(alpha: 0.3),
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
                                  titleText,
                                  style:
                                      sheetContext.textTheme.bodySmall?.copyWith(
                                    color: sheetContext.colors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  recLabel,
                                  style:
                                      sheetContext.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Workout breakdown (when high stress)
                      if (latestResult != null &&
                          insight.currentStress >= 50) ...[
                        _buildWorkoutBreakdown(sheetContext, latestResult, l10n),
                        const SizedBox(height: 20),
                      ],

                      // Scientific explanation (when high stress)
                      if (insight.currentStress >= 50) ...[
                        _buildScientificExplanation(sheetContext, l10n),
                        const SizedBox(height: 20),
                      ],

                      // Rationale
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: sheetContext.colors.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SemanticIcon(
                              icon: AppIcons.tip,
                              semanticLabel: 'Info',
                              color: sheetContext.colors.onSurfaceVariant,
                              size: AppIconSize.small,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                insight.rationale,
                                style:
                                    sheetContext.textTheme.bodyMedium?.copyWith(
                                  color: sheetContext.colors.onSurface
                                      .withValues(alpha: 0.85),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detailed metrics
                      _buildDetailedMetrics(
                        sheetContext,
                        currentLabel: currentText,
                        tomorrowLabel: tomorrowText,
                        ifWorkoutLabel: ifWorkoutText,
                        recoveryRateLabel: recoveryRateText,
                      ),
                      const SizedBox(height: 20),

                      // Calibration quality indicator
                      if (insight.calibrationQuality.name != 'excellent')
                        _buildCalibrationHint(
                          sheetContext,
                          hintText: calibrationHintText,
                          editProfileText: editProfileText,
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Build workout breakdown section showing why session was intense
  Widget _buildWorkoutBreakdown(
    BuildContext context,
    StressIndexResult result,
    dynamic l10n,
  ) {
    // Sort muscles by stress (highest first)
    final muscles = result.muscleBreakdown.values.toList()
      ..sort((a, b) => b.stressScore.compareTo(a.stressScore));

    // Take top 4 muscles
    final topMuscles = muscles.take(4).toList();

    // Calculate total volume
    final totalVolume =
        muscles.fold<double>(0, (sum, m) => sum + m.totalVolume);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.errorColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.fitnessCenter,
                semanticLabel: 'Workout',
                color: context.errorColor,
                size: AppIconSize.small,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.stressWorkoutBreakdownTitle,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  context,
                  label: context.l10n.sets,
                  value: result.totalSets.toString(),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
                _buildMiniStat(
                  context,
                  label: context.l10n.volumeKg,
                  value: '${(totalVolume / 1000).toStringAsFixed(1)}k',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
                _buildMiniStat(
                  context,
                  label: context.l10n.stressScore,
                  value: result.displayScore.toStringAsFixed(0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Muscle breakdown
          ...topMuscles.map((muscle) => _buildMuscleRow(context, muscle)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleRow(BuildContext context, MuscleStressData muscle) {
    final stressColor = _getMuscleStressColor(muscle.stressLevel, context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Muscle name
          Expanded(
            flex: 2,
            child: Text(
              muscle.displayName,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Sets
          Expanded(
            child: Text(
              '${muscle.setsCount} set',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          // Stress bar
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: muscle.stressScore / 100,
                      backgroundColor:
                          context.colors.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(stressColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  muscle.stressScore.toStringAsFixed(0),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: stressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMuscleStressColor(MuscleStressLevel level, BuildContext context) {
    return switch (level) {
      MuscleStressLevel.low => context.successColor,
      MuscleStressLevel.moderate => context.warningColor,
      MuscleStressLevel.high => context.colors.tertiary,
      MuscleStressLevel.veryHigh => context.errorColor,
    };
  }

  /// Build scientific explanation with research references
  Widget _buildScientificExplanation(BuildContext context, dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.science,
                semanticLabel: 'Science',
                color: context.colors.primary,
                size: AppIconSize.small,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.stressScientificBasisTitle,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Explanation text
          Text(
            context.l10n.stressScientificExplanation,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // References
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.stressReferencesTitle,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReference(
                  context,
                  '1. Banister et al. (1975)',
                  context.l10n.stressReferenceBanister,
                ),
                const SizedBox(height: 4),
                _buildReference(
                  context,
                  '2. Schoenfeld et al. (2017)',
                  context.l10n.stressReferenceSchoenfeld,
                ),
                const SizedBox(height: 4),
                _buildReference(
                  context,
                  '3. Morton et al. (2019)',
                  context.l10n.stressReferenceMorton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReference(BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SemanticIcon(
          icon: AppIcons.article,
          semanticLabel: title,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ' - $description'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics(
    BuildContext context, {
    required String currentLabel,
    required String tomorrowLabel,
    required String ifWorkoutLabel,
    required String recoveryRateLabel,
  }) {
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
            label: currentLabel,
            value: '${insight.displayStress}',
            icon: AppIcons.barChart,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            label: tomorrowLabel,
            value: '${insight.displayPredicted}',
            icon: AppIcons.schedule,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            label: ifWorkoutLabel,
            value: '${insight.predictedIfWorkout.round()}',
            icon: AppIcons.fitnessCenter,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            label: recoveryRateLabel,
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

  Widget _buildCalibrationHint(
    BuildContext context, {
    required String hintText,
    required String editProfileText,
  }) {
    return Material(
      color: context.colors.primaryContainer.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Navigate to Edit Profile screen to complete fitness questionnaire
          context.pushNamed(AppRoutes.editProfileName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                  hintText,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              // Arrow icon to indicate it's tappable
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: editProfileText,
                color: context.colors.primary,
                size: AppIconSize.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
