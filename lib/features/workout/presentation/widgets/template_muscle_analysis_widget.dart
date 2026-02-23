/// Template Muscle Analysis Widget
///
/// Expandable section in the template editor showing muscle coverage,
/// push/pull and upper/lower ratios, and a body heatmap.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_muscle_analyzer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Expandable muscle balance analysis section for the template editor
class TemplateMuscleAnalysisSection extends ConsumerStatefulWidget {
  const TemplateMuscleAnalysisSection({
    required this.exercises,
    super.key,
  });

  final List<ExerciseTemplate> exercises;

  @override
  ConsumerState<TemplateMuscleAnalysisSection> createState() =>
      _TemplateMuscleAnalysisSectionState();
}

class _TemplateMuscleAnalysisSectionState
    extends ConsumerState<TemplateMuscleAnalysisSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (widget.exercises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          context.l10n.addExercisesForMuscleAnalysis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final muscleMapAsync = ref.watch(exerciseMuscleMapProvider);

    return muscleMapAsync.when(
      data: (muscleMap) => _buildAnalysis(context, muscleMap),
      loading: () => _buildAnalysis(context, null),
      error: (_, __) => _buildAnalysis(context, null),
    );
  }

  Widget _buildAnalysis(
    BuildContext context,
    Map<String, ExerciseMuscleData>? muscleMap,
  ) {
    final analysis = TemplateMuscleAnalyzer.analyze(
      widget.exercises,
      muscleMap: muscleMap,
    );

    if (analysis.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header - always visible
          _buildHeader(context, analysis),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(context, analysis),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TemplateMuscleAnalysis analysis) {
    final statusColor = analysis.hasWarnings
        ? context.colors.warning
        : context.colors.success;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
              size: AppIconSize.small,
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.muscleBalance,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
            if (analysis.hasWarnings) ...[
              const SizedBox(width: 6),
              Text(
                context.l10n.muscleWarning,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.warning,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Body Heatmap
        SizedBox(
          height: 250,
          child: ProfessionalBodyHeatmap(
            heatValues: MuscleHeatValues(analysis.musclePercentages),
          ),
        ),

        const SizedBox(height: 12),

        // Ratio bars
        _buildRatioBar(
          context,
          label: context.l10n.pushPullRatio,
          ratio: analysis.pushPullRatio,
          hasWarning: analysis.pushPullWarning,
        ),
        const SizedBox(height: 8),
        _buildRatioBar(
          context,
          label: context.l10n.upperLowerRatio,
          ratio: analysis.upperLowerRatio,
          hasWarning: analysis.upperLowerWarning,
        ),

        const SizedBox(height: 12),

        // Muscle chips
        _buildMuscleChips(context, analysis),

        const SizedBox(height: 10),

        _buildExerciseBreakdownAction(context, analysis),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRatioBar(
    BuildContext context, {
    required String label,
    required double ratio,
    required bool hasWarning,
  }) {
    // ratio of 1.0 = balanced (0.5 on the bar)
    // ratio of 2.0+ = fully left, ratio of 0.0 = fully right
    final clampedRatio = ratio.clamp(0.0, 3.0);
    final barFraction = (clampedRatio / (clampedRatio + 1.0)).clamp(0.0, 1.0);

    final barColor = hasWarning ? context.colors.warning : context.colors.primary;
    final ratioText = ratio > 0 ? '${ratio.toStringAsFixed(1)}:1' : '-';

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  // Background
                  Container(
                    color: context.colors.surfaceContainerHighest,
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: barFraction,
                    child: Container(color: barColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ratioText,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasWarning ? context.colors.warning : null,
                ),
              ),
              if (hasWarning) ...[
                const SizedBox(width: 2),
                Icon(
                  AppIcons.warning,
                  size: AppIconSize.tiny,
                  color: context.colors.warning,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleChips(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        // Covered muscles
        for (final muscle in analysis.coveredMuscles)
          _buildMuscleChip(
            context,
            muscle: muscle,
            percentage: analysis.musclePercentages[
                    MuscleAbbreviationMapper.normalizeToHeatmapKey(muscle)] ??
                0,
            isCovered: true,
          ),
        // Neglected muscles
        for (final muscle in analysis.neglectedMuscles)
          _buildMuscleChip(
            context,
            muscle: muscle,
            percentage: analysis.musclePercentages[
                    MuscleAbbreviationMapper.normalizeToHeatmapKey(muscle)] ??
                0,
            isCovered: false,
          ),
      ],
    );
  }

  Widget _buildMuscleChip(
    BuildContext context, {
    required String muscle,
    required double percentage,
    required bool isCovered,
  }) {
    final displayName = MuscleAbbreviationMapper.codeToDisplayName(muscle);
    final color = isCovered ? context.colors.success : context.colors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$displayName ${percentage.toStringAsFixed(0)}%',
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExerciseBreakdownAction(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    if (analysis.exerciseBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _showExerciseBreakdownBottomSheet(context, analysis),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              AppIcons.info,
              size: AppIconSize.small,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.exerciseBreakdown,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              context.l10n.viewDetails,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              AppIcons.chevronRight,
              size: AppIconSize.tiny,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExerciseBreakdownBottomSheet(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sheetContext.l10n.exerciseBreakdown,
                        style: sheetContext.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(sheetContext.l10n.close),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: analysis.exerciseBreakdown.length,
                    padding: const EdgeInsets.only(bottom: 12),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final breakdown = analysis.exerciseBreakdown[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sheetContext.colors.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sheetContext.colors.outline
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    breakdown.exerciseName,
                                    style: sheetContext.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  sheetContext.l10n.setsCount(breakdown.sets),
                                  style: sheetContext.textTheme.labelSmall
                                      ?.copyWith(
                                    color: sheetContext.colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${sheetContext.l10n.total} ${breakdown.totalPercentage.toStringAsFixed(1)}%',
                              style: sheetContext.textTheme.labelSmall?.copyWith(
                                color: sheetContext.colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final contribution
                                    in breakdown.contributions)
                                  _buildContributionChip(
                                    sheetContext,
                                    muscle: contribution.muscleId,
                                    percentage: contribution.percentage,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContributionChip(
    BuildContext context, {
    required String muscle,
    required double percentage,
  }) {
    final displayName = MuscleAbbreviationMapper.codeToDisplayName(muscle);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$displayName ${percentage.toStringAsFixed(1)}%',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
