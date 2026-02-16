/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/analytics/presentation/widgets
/// Feature: analytics
/// Type: widget
///
/// Exercise Compact Card - Compact card for exercise suggestions in horizontal grid
///
/// Displays exercise GIF, name, type/equipment info, and add/already-added CTA.
/// Used inside MusclePriorityCard's horizontal ListView.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/exercise_image_carousel.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Compact exercise card (160x280) for horizontal grid display.
///
/// Shows exercise GIF with difficulty badge, name, type/equipment,
/// and a CTA button to add or indicate already-added state.
class ExerciseCompactCard extends StatelessWidget {
  const ExerciseCompactCard({
    required this.suggestion,
    required this.isInSelectedTemplate,
    required this.onAdd,
    super.key,
  });

  final ExerciseSuggestion suggestion;
  final bool isInSelectedTemplate;
  final VoidCallback onAdd;

  static const double cardWidth = 160.0;
  static const double cardHeight = 280.0;
  static const double imageHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isInSelectedTemplate
              ? colorScheme.secondaryContainer.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInSelectedTemplate
                ? context.colors.success.withValues(alpha: 0.3)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.exerciseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${suggestion.exerciseType} \u2022 ${suggestion.equipment}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _buildCTA(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final colorScheme = context.colors;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
      child: Stack(
        children: [
          if (suggestion.imageUrl != null && suggestion.imageUrl!.isNotEmpty)
            ExerciseImageCarousel(
              imageUrl: suggestion.imageUrl!,
              height: imageHeight,
              width: double.infinity,
              placeholder: _imagePlaceholder(context),
              errorWidget: _imagePlaceholder(context),
            )
          else
            _imagePlaceholder(context),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.scrim.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _difficultyLabel(context),
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.surface,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final colorScheme = context.colors;
    return Container(
      height: imageHeight,
      width: double.infinity,
      color: colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          AppIcons.workout,
          size: AppIconSize.large,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  String _difficultyLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (suggestion.difficulty) {
      ExerciseDifficulty.beginner => l10n.difficultyBeginner,
      ExerciseDifficulty.intermediate => l10n.difficultyIntermediate,
      ExerciseDifficulty.advanced => l10n.difficultyAdvanced,
    };
  }

  Widget _buildCTA(BuildContext context) {
    final l10n = context.l10n;

    if (isInSelectedTemplate) {
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: Icon(
            AppIcons.checkCircle,
            size: AppIconSize.small,
            color: context.colors.success,
          ),
          label: Text(
            l10n.alreadyAdded,
            style: TextStyle(fontSize: 12, color: context.colors.success),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.colors.success,
            side: BorderSide(color: context.colors.success),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(AppIcons.add, size: AppIconSize.small),
        label: Text(l10n.add, style: const TextStyle(fontSize: 12)),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}
