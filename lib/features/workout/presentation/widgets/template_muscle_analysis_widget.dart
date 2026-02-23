/// Template Muscle Analysis Widget
///
/// Section in the template editor that opens a bottom sheet with
/// muscle coverage, push/pull and upper/lower ratios, body heatmap,
/// and per-exercise contribution details.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/template_muscle_analyzer.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Muscle balance section for the template editor.
///
/// The section itself is a compact row; tapping it opens a bottom sheet
/// with full analysis and an internal dropdown for exercise details.
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
  @override
  Widget build(BuildContext context) {
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
      child: _buildHeader(context, analysis),
    );
  }

  Widget _buildHeader(BuildContext context, TemplateMuscleAnalysis analysis) {
    final statusColor = analysis.hasWarnings
        ? context.colors.warning
        : context.colors.success;

    return InkWell(
      onTap: () => _showMuscleBalanceBottomSheet(context, analysis),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              AppIcons.workout,
              size: AppIconSize.small,
              color: context.colors.onSurfaceVariant,
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
              Flexible(
                child: Text(
                  context.l10n.muscleWarning,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.warning,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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

  Future<void> _showMuscleBalanceBottomSheet(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    final statusColor = analysis.hasWarnings
        ? context.colors.warning
        : context.colors.success;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              sheetContext.l10n.muscleBalance,
                              style: sheetContext.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (analysis.hasWarnings) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  sheetContext.l10n.muscleWarning,
                                  style: sheetContext.textTheme.labelSmall
                                      ?.copyWith(
                                    color: sheetContext.colors.warning,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(sheetContext.l10n.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBottomSheetContent(sheetContext, analysis),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250,
          child: ProfessionalBodyHeatmap(
            heatValues: MuscleHeatValues(analysis.musclePercentages),
          ),
        ),
        const SizedBox(height: 12),
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
        _buildMuscleChips(context, analysis),
        const SizedBox(height: 12),
        _buildExerciseBreakdownDropdown(context, analysis),
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
                  Container(
                    color: context.colors.surfaceContainerHighest,
                  ),
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
        for (final muscle in analysis.coveredMuscles)
          _buildMuscleChip(
            context,
            muscle: muscle,
            percentage: analysis.musclePercentages[
                    MuscleAbbreviationMapper.normalizeToHeatmapKey(muscle)] ??
                0,
            isCovered: true,
          ),
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

  Widget _buildExerciseBreakdownDropdown(
    BuildContext context,
    TemplateMuscleAnalysis analysis,
  ) {
    if (analysis.exerciseBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: context.colors.outline.withValues(alpha: 0.0),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(
            context.l10n.exerciseBreakdown,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            context.l10n.viewDetails,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          children: [
            for (int i = 0; i < analysis.exerciseBreakdown.length; i++) ...[
              _buildBreakdownCard(context, analysis.exerciseBreakdown[i]),
              if (i != analysis.exerciseBreakdown.length - 1)
                const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context,
    ExerciseContributionBreakdown breakdown,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.15),
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
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                context.l10n.setsCount(breakdown.sets),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${context.l10n.total} ${breakdown.totalPercentage.toStringAsFixed(1)}%',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final contribution in breakdown.contributions)
                _buildContributionChip(
                  context,
                  muscle: contribution.muscleId,
                  percentage: contribution.percentage,
                ),
            ],
          ),
        ],
      ),
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
