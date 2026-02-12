/// Template Suggestion Card
///
/// Home screen card showing which workout template to do today.
/// Analyzes user's templates against current muscle recovery status
/// and recommends the optimal choice.
///
/// **States**:
/// - Loading: Shows shimmer placeholder
/// - No templates: Hidden (user needs templates first)
/// - Has suggestion: Shows best template with recommendation
/// - All muscles fatigued: Suggests rest day
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/template_stress_analysis.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/template_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Template Suggestion Card for home screen
///
/// Shows the best workout template recommendation based on muscle recovery.
class TemplateSuggestionCard extends ConsumerWidget {
  const TemplateSuggestionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(templateSuggestionProvider);

    return suggestionAsync.when(
      data: (analyses) {
        // If no templates or analyses, hide the card
        if (analyses == null || analyses.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get best template
        final best = analyses.first;

        // If best template is "avoid", show rest day suggestion instead
        if (best.recommendation == TemplateRecommendation.avoid) {
          // Check if there's an acceptable alternative
          final acceptable = analyses
              .skip(1)
              .where((a) => a.recommendation != TemplateRecommendation.avoid)
              .toList();

          if (acceptable.isEmpty) {
            // All templates should be avoided - suggest rest day
            return _RestDaySuggestionCard(bestAnalysis: best);
          }

          // Show the best acceptable alternative instead
          final alternative = acceptable.first;
          return _TemplateSuggestionContent(
            analysis: alternative,
            alternatives: acceptable.skip(1).take(2).toList(),
            onTap: () => _handleTemplateTap(context, alternative),
          );
        }

        // Filter alternatives to exclude "avoid" templates for better UX
        final filteredAlternatives = analyses
            .skip(1)
            .where((a) => a.recommendation != TemplateRecommendation.avoid)
            .take(2)
            .toList();

        return _TemplateSuggestionContent(
          analysis: best,
          alternatives: filteredAlternatives,
          onTap: () => _handleTemplateTap(context, best),
        );
      },
      loading: () => _buildLoadingState(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: const Center(child: LoadingIndicator()),
    );
  }

  void _handleTemplateTap(
    BuildContext context,
    TemplateStressAnalysis analysis,
  ) {
    HapticFeedback.mediumImpact();
    // Navigate to template detail
    context.push('/templates/detail', extra: analysis.templateId);
  }
}

/// Content widget showing the template recommendation
class _TemplateSuggestionContent extends StatelessWidget {
  const _TemplateSuggestionContent({
    required this.analysis,
    required this.alternatives,
    required this.onTap,
  });

  final TemplateStressAnalysis analysis;
  final List<TemplateStressAnalysis> alternatives;
  final VoidCallback onTap;

  Color _getRecommendationColor(
    TemplateRecommendation recommendation,
    BuildContext context,
  ) {
    return switch (recommendation) {
      TemplateRecommendation.optimal => context.successColor,
      TemplateRecommendation.acceptable => context.warningColor,
      TemplateRecommendation.suboptimal => context.colors.tertiary,
      TemplateRecommendation.avoid => context.errorColor,
    };
  }

  IconData _getRecommendationIcon(TemplateRecommendation recommendation) {
    return switch (recommendation) {
      TemplateRecommendation.optimal => AppIcons.checkCircle,
      TemplateRecommendation.acceptable => AppIcons.schedule,
      TemplateRecommendation.suboptimal => AppIcons.warning,
      TemplateRecommendation.avoid => AppIcons.cancel,
    };
  }

  String _getRecommendationLabel(
    TemplateRecommendation recommendation,
    BuildContext context,
  ) {
    return switch (recommendation) {
      TemplateRecommendation.optimal =>
        context.l10n.templateRecommendationOptimal,
      TemplateRecommendation.acceptable =>
        context.l10n.templateRecommendationAcceptable,
      TemplateRecommendation.suboptimal =>
        context.l10n.templateRecommendationSuboptimal,
      TemplateRecommendation.avoid => context.l10n.templateRecommendationAvoid,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRecommendationColor(analysis.recommendation, context);
    final icon = _getRecommendationIcon(analysis.recommendation);
    final label = _getRecommendationLabel(analysis.recommendation, context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: context.colors.surface.withValues(alpha: 0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: Icon + Title + Score badge
                  Row(
                    children: [
                      // Icon container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SemanticIcon(
                          icon: icon,
                          semanticLabel: label,
                          color: color,
                          size: AppIconSize.medium,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title and label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            Text(
                              context.l10n.templateSuggestionTitle,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Template name
                            Text(
                              analysis.templateName,
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.colors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Score badge with tooltip
                      Tooltip(
                        message: context.l10n.templateOptimalityScoreTooltip,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${analysis.optimalityScore.round()}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.colors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '%',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.surface.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Recommendation badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SemanticIcon(
                          icon: icon,
                          semanticLabel: label,
                          color: color,
                          size: AppIconSize.tiny,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rationale text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            analysis.rationale,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(
                                alpha: 0.85,
                              ),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Muscle recovery summary
                  _buildMuscleRecoverySummary(context),
                  const SizedBox(height: 16),

                  // Action row
                  Row(
                    children: [
                      // View all alternatives button
                      if (alternatives.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showAlternativesSheet(context, alternatives);
                          },
                          icon: SemanticIcon(
                            icon: AppIcons.list,
                            semanticLabel: 'Alternatives',
                            size: AppIconSize.small,
                            color: context.colors.primary,
                          ),
                          label: Text(
                            context.l10n.templateViewAlternatives,
                            style: TextStyle(color: context.colors.primary),
                          ),
                        ),
                      const Spacer(),
                      // Start workout button
                      FilledButton.icon(
                        onPressed: onTap,
                        icon: const SemanticIcon(
                          icon: AppIcons.play,
                          semanticLabel: 'Start',
                          size: AppIconSize.small,
                        ),
                        label: Text(context.l10n.startWorkout),
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
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

  Widget _buildMuscleRecoverySummary(BuildContext context) {
    // Hide section if no muscle data available
    if (analysis.muscleReadiness.isEmpty) {
      return const SizedBox.shrink();
    }

    final readyCount = analysis.musclesReadyCount;
    final cautionCount = analysis.musclesNeedCautionCount;
    final totalMuscles = analysis.muscleReadiness.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMuscleMetric(
          context,
          icon: AppIcons.checkCircle,
          value: '$readyCount',
          label: context.l10n.templateMusclesReady,
          color: context.successColor,
        ),
        _buildMuscleMetric(
          context,
          icon: AppIcons.warning,
          value: '$cautionCount',
          label: context.l10n.templateMusclesCaution,
          color: context.warningColor,
        ),
        _buildMuscleMetric(
          context,
          icon: AppIcons.fitnessCenter,
          value: '$totalMuscles',
          label: context.l10n.templateMusclesTotal,
          color: context.colors.tertiary,
        ),
      ],
    );
  }

  Widget _buildMuscleMetric(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SemanticIcon(
            icon: icon,
            semanticLabel: label,
            size: AppIconSize.small,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showAlternativesSheet(
    BuildContext context,
    List<TemplateStressAnalysis> alternatives,
  ) {
    ModalService.showSheet<void>(context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    context.l10n.templateAlternativesTitle,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                // Alternatives list
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: alternatives.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, index) {
                      final alt = alternatives[index];
                      return _AlternativeListTile(
                        analysis: alt,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          HapticFeedback.mediumImpact();
                          context.push(
                            '/templates/detail',
                            extra: alt.templateId,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// List tile for alternative template in bottom sheet
class _AlternativeListTile extends StatelessWidget {
  const _AlternativeListTile({required this.analysis, required this.onTap});

  final TemplateStressAnalysis analysis;
  final VoidCallback onTap;

  Color _getColor(BuildContext context) {
    return switch (analysis.recommendation) {
      TemplateRecommendation.optimal => context.successColor,
      TemplateRecommendation.acceptable => context.warningColor,
      TemplateRecommendation.suboptimal => context.colors.tertiary,
      TemplateRecommendation.avoid => context.errorColor,
    };
  }

  IconData _getIcon() {
    return switch (analysis.recommendation) {
      TemplateRecommendation.optimal => AppIcons.checkCircle,
      TemplateRecommendation.acceptable => AppIcons.schedule,
      TemplateRecommendation.suboptimal => AppIcons.warning,
      TemplateRecommendation.avoid => AppIcons.cancel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Material(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: SemanticIcon(
                  icon: _getIcon(),
                  semanticLabel: analysis.recommendation.name,
                  color: color,
                  size: AppIconSize.small,
                ),
              ),
              const SizedBox(width: 12),
              // Name and score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.templateName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analysis.optimalityScore.round()}% ${context.l10n.templateOptimalityLabel}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: 'Go',
                color: context.colors.onSurfaceVariant,
                size: AppIconSize.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rest day suggestion card shown when all templates should be avoided
///
/// Includes "Complete your split" option with scientific context
class _RestDaySuggestionCard extends StatelessWidget {
  const _RestDaySuggestionCard({required this.bestAnalysis});

  final TemplateStressAnalysis bestAnalysis;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.tertiary;

    // Calculate average recovery of PRIMARY muscles for this template
    final primaryMuscleRecovery = _calculatePrimaryMuscleRecovery();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Icon + Title
            _buildHeader(context, color),
            const SizedBox(height: 16),

            // Rest day message
            _buildRestMessage(context),
            const SizedBox(height: 12),

            // Fatigued muscles info
            _buildFatiguedMusclesSummary(context),
            const SizedBox(height: 20),

            // Divider
            Divider(color: context.colors.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 16),

            // Complete Split Section
            _buildCompleteSplitSection(context, primaryMuscleRecovery),
          ],
        ),
      ),
    );
  }

  double _calculatePrimaryMuscleRecovery() {
    if (bestAnalysis.primaryMuscles.isEmpty) return 0;

    double total = 0;
    for (final muscleId in bestAnalysis.primaryMuscles) {
      total += bestAnalysis.muscleReadiness[muscleId]?.recoveryPercent ?? 100;
    }
    return total / bestAnalysis.primaryMuscles.length;
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: SemanticIcon(
            icon: AppIcons.nightlight,
            semanticLabel: context.l10n.templateRestDaySuggestionTitle,
            color: color,
            size: AppIconSize.medium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.templateSuggestionTitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.templateRestDaySuggestionTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.templateRestDaySuggestionBody,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFatiguedMusclesSummary(BuildContext context) {
    final fatiguedMuscles = bestAnalysis.fatiguedMuscles;
    if (fatiguedMuscles.isEmpty) return const SizedBox.shrink();

    final muscleNames = fatiguedMuscles
        .take(3)
        .map((id) => bestAnalysis.muscleReadiness[id]?.displayName ?? id)
        .join(', ');

    final moreCount = fatiguedMuscles.length - 3;
    final displayText = moreCount > 0
        ? '$muscleNames +$moreCount'
        : muscleNames;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.errorColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.warning,
            semanticLabel: 'Warning',
            color: context.errorColor,
            size: AppIconSize.small,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayText,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteSplitSection(
    BuildContext context,
    double primaryRecovery,
  ) {
    // Get primary muscle names for this template
    final primaryMuscleNames = bestAnalysis.primaryMuscles
        .take(3)
        .map((id) => bestAnalysis.muscleReadiness[id]?.displayName ?? id)
        .join(', ');

    // Determine if primary muscles are actually OK (>60%)
    final primaryMusclesOk = primaryRecovery >= 60;
    final cardColor = primaryMusclesOk
        ? context.warningColor
        : context.errorColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            SemanticIcon(
              icon: AppIcons.fitnessCenter,
              semanticLabel: 'Workout',
              color: context.colors.onSurfaceVariant,
              size: AppIconSize.small,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.templateCompleteSplitTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Template card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template name + recovery badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bestAnalysis.templateName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${primaryRecovery.round()}%',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Target muscles
              Text(
                '${context.l10n.templateTargetMuscles}: $primaryMuscleNames',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Scientific context
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticIcon(
                      icon: AppIcons.science,
                      semanticLabel: 'Science',
                      color: context.colors.primary,
                      size: AppIconSize.tiny,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.templateSplitScienceExplanation(
                          primaryMuscleNames,
                          primaryRecovery.round(),
                        ),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.8,
                          ),
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push(
                      '/templates/detail',
                      extra: bestAnalysis.templateId,
                    );
                  },
                  icon: SemanticIcon(
                    icon: primaryMusclesOk ? AppIcons.play : AppIcons.warning,
                    semanticLabel: 'Start',
                    size: AppIconSize.small,
                    color: context.colors.surface,
                  ),
                  label: Text(
                    primaryMusclesOk
                        ? context.l10n.templateProceedWithCaution
                        : context.l10n.templateProceedAnyway,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: cardColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
