library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/professional_body_heatmap.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_border_radius.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Compact anatomical map for exercise target muscles.
///
/// Primary muscles are highlighted in red, secondary in yellow.
/// Tapping the preview opens a fullscreen version.
class ExerciseTargetMuscleMap extends StatelessWidget {
  const ExerciseTargetMuscleMap({
    super.key,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    this.previewWidth = 112,
    this.previewHeight = 88,
    this.showLegend = false,
    this.enableFullscreen = true,
  });

  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final double previewWidth;
  final double previewHeight;
  final bool showLegend;
  final bool enableFullscreen;

  static const Set<String> _supportedGroups = {
    'chest',
    'shoulders',
    'obliques',
    'abs',
    'abductors',
    'biceps',
    'calves',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'upper_back',
    'quadriceps',
    'trapezius',
    'triceps',
    'adductors',
    'lower_back',
    'neck',
  };

  @override
  Widget build(BuildContext context) {
    final primaryGroups = _toHeatmapGroups(primaryMuscles);
    final secondaryGroups = _toHeatmapGroups(secondaryMuscles)
      ..removeAll(primaryGroups);
    final heatValues = _buildHeatValues(
      primaryGroups: primaryGroups,
      secondaryGroups: secondaryGroups,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPreview(
          context,
          heatValues: heatValues,
          hasSecondary: secondaryGroups.isNotEmpty,
        ),
        if (showLegend) ...[
          const SizedBox(height: AppSpacing.xs),
          _TargetLegend(hasSecondary: secondaryGroups.isNotEmpty),
        ],
      ],
    );
  }

  Widget _buildPreview(
    BuildContext context, {
    required Map<String, double> heatValues,
    required bool hasSecondary,
  }) {
    final preview = Container(
      width: previewWidth,
      height: previewHeight,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppBorderRadius.smRadius,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: IgnorePointer(child: _buildHeatmap(context, heatValues)),
            ),
          ),
          if (enableFullscreen)
            Positioned(
              right: 4,
              bottom: 4,
              child: Icon(
                AppIcons.zoomOutMap,
                size: 14,
                color: context.colors.onSurface.withValues(alpha: 0.55),
              ),
            ),
        ],
      ),
    );

    if (!enableFullscreen) return preview;

    return Semantics(
      button: true,
      label: context.l10n.exerciseOptionsTapToEnlarge,
      child: InkWell(
        borderRadius: AppBorderRadius.smRadius,
        onTap: () => _showFullscreen(
          context,
          heatValues: heatValues,
          hasSecondary: hasSecondary,
        ),
        child: preview,
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, Map<String, double> values) {
    return ProfessionalBodyHeatmap(
      heatValues: MuscleHeatValues(values),
      enableSelection: false,
      showSelectionInfo: false,
      showLegend: false,
      lowHeatColor: context.colors.surfaceContainerHighest,
      mediumHeatColor: context.warningColor,
      highHeatColor: context.colors.primary,
    );
  }

  Set<String> _toHeatmapGroups(List<String> muscles) {
    final groups = <String>{};
    for (final rawMuscle in muscles) {
      final muscle = rawMuscle.trim();
      if (muscle.isEmpty) continue;

      final direct =
          MuscleAbbreviationMapper.toHeatmapGroupKey(muscle) ??
          MuscleAbbreviationMapper.toHeatmapGroupKey(muscle.toUpperCase());
      if (direct != null) {
        groups.add(direct);
        continue;
      }

      final normalized = MuscleAbbreviationMapper.normalizeToHeatmapKey(muscle);
      if (_supportedGroups.contains(normalized)) {
        groups.add(normalized);
      }
    }
    return groups;
  }

  Map<String, double> _buildHeatValues({
    required Set<String> primaryGroups,
    required Set<String> secondaryGroups,
  }) {
    final values = <String, double>{};

    // MuscleHeatValues currently expects percentages in [0..100].
    for (final group in secondaryGroups) {
      values[group] = 50;
    }
    for (final group in primaryGroups) {
      values[group] = 100;
    }

    return values;
  }

  void _showFullscreen(
    BuildContext context, {
    required Map<String, double> heatValues,
    required bool hasSecondary,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: context.colors.scrim.withValues(alpha: 0.72),
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 56, 14, 14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: dialogContext.colors.surface,
                        borderRadius: AppBorderRadius.lgRadius,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.sm,
                                AppSpacing.sm,
                                AppSpacing.sm,
                                0,
                              ),
                              child: IgnorePointer(
                                child: _buildHeatmap(dialogContext, heatValues),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.sm,
                              0,
                              AppSpacing.sm,
                              AppSpacing.sm,
                            ),
                            child: _TargetLegend(hasSecondary: hasSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: dialogContext.colors.surfaceContainerHigh
                          .withValues(alpha: 0.92),
                      foregroundColor: dialogContext.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TargetLegend extends StatelessWidget {
  const _TargetLegend({required this.hasSecondary});

  final bool hasSecondary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _LegendChip(
          color: context.colors.primary,
          label: context.l10n.primaryMuscle,
        ),
        if (hasSecondary)
          _LegendChip(
            color: context.warningColor,
            label: context.l10n.secondaryMuscles,
          ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppBorderRadius.circularRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
