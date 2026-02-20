/// All Templates Muscle Overview
///
/// Expandable section showing aggregated muscle coverage across all templates,
/// with a body heatmap, push/pull & upper/lower ratios, and per-template breakdown.
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

/// Aggregated muscle overview for the templates list screen
class AllTemplatesMuscleOverview extends ConsumerStatefulWidget {
  const AllTemplatesMuscleOverview({
    required this.templates,
    super.key,
  });

  final List<WorkoutTemplate> templates;

  @override
  ConsumerState<AllTemplatesMuscleOverview> createState() =>
      _AllTemplatesMuscleOverviewState();
}

class _AllTemplatesMuscleOverviewState
    extends ConsumerState<AllTemplatesMuscleOverview> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Skip if no templates or all templates have no exercises
    final templatesWithExercises =
        widget.templates.where((t) => t.exercises.isNotEmpty).toList();
    if (templatesWithExercises.isEmpty) return const SizedBox.shrink();

    final muscleMapAsync = ref.watch(exerciseMuscleMapProvider);

    return muscleMapAsync.when(
      data: (muscleMap) =>
          _buildContent(context, muscleMap, templatesWithExercises),
      loading: () =>
          _buildContent(context, null, templatesWithExercises),
      error: (_, __) =>
          _buildContent(context, null, templatesWithExercises),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, ExerciseMuscleData>? muscleMap,
    List<WorkoutTemplate> templatesWithExercises,
  ) {
    // Aggregate all exercises across all templates
    final allExercises = <ExerciseTemplate>[];
    for (final template in templatesWithExercises) {
      allExercises.addAll(template.exercises);
    }

    final aggregatedAnalysis = TemplateMuscleAnalyzer.analyze(
      allExercises,
      muscleMap: muscleMap,
    );

    if (aggregatedAnalysis.isEmpty) return const SizedBox.shrink();

    final statusColor = aggregatedAnalysis.hasWarnings
        ? context.colors.warning
        : context.colors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header - always visible
          GestureDetector(
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
                    context.l10n.muscleOverview,
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
                  const Spacer(),
                  Text(
                    context.l10n.totalSetsCount(aggregatedAnalysis.totalSets),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(
              context,
              aggregatedAnalysis,
              muscleMap,
              templatesWithExercises,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    TemplateMuscleAnalysis aggregatedAnalysis,
    Map<String, ExerciseMuscleData>? muscleMap,
    List<WorkoutTemplate> templatesWithExercises,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aggregated body heatmap
        SizedBox(
          height: 250,
          child: ProfessionalBodyHeatmap(
            heatValues: MuscleHeatValues(aggregatedAnalysis.musclePercentages),
          ),
        ),

        const SizedBox(height: 12),

        // Ratio bars
        _buildRatioBar(
          context,
          label: context.l10n.pushPullRatio,
          ratio: aggregatedAnalysis.pushPullRatio,
          hasWarning: aggregatedAnalysis.pushPullWarning,
        ),
        const SizedBox(height: 8),
        _buildRatioBar(
          context,
          label: context.l10n.upperLowerRatio,
          ratio: aggregatedAnalysis.upperLowerRatio,
          hasWarning: aggregatedAnalysis.upperLowerWarning,
        ),

        const SizedBox(height: 16),

        // Per-template section
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            context.l10n.perTemplate,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),

        // Per-template breakdown
        for (final template in templatesWithExercises)
          _buildTemplateRow(context, template, muscleMap),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTemplateRow(
    BuildContext context,
    WorkoutTemplate template,
    Map<String, ExerciseMuscleData>? muscleMap,
  ) {
    final analysis = TemplateMuscleAnalyzer.analyze(
      template.exercises,
      muscleMap: muscleMap,
    );

    if (analysis.isEmpty) return const SizedBox.shrink();

    // Get top 4 muscles sorted by percentage
    final topMuscles = analysis.coveredMuscles.take(4).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template name + total sets
          Row(
            children: [
              Icon(
                AppIcons.list,
                size: AppIconSize.tiny,
                color: context.colors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  template.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                context.l10n.setsCount(analysis.totalSets),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Top muscle chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final muscle in topMuscles)
                _buildMiniChip(
                  context,
                  muscle: muscle,
                  percentage: analysis.musclePercentages[
                          MuscleAbbreviationMapper.normalizeToHeatmapKey(
                              muscle)] ??
                      0,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(
    BuildContext context, {
    required String muscle,
    required double percentage,
  }) {
    final displayName = MuscleAbbreviationMapper.codeToDisplayName(muscle);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$displayName ${percentage.toStringAsFixed(0)}%',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
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
    final barColor =
        hasWarning ? context.colors.warning : context.colors.primary;
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
}
