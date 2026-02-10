import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Live preview widget showing how exercise cards will look
/// with current settings applied.
///
/// Updates in real-time as user changes settings.
/// Part of Exercise Card Settings redesign.
class ExerciseCardPreview extends ConsumerWidget {
  const ExerciseCardPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(exerciseCardSettingsProvider);

    return Container(
      padding: EdgeInsets.all(settings.density.horizontalPadding),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // GIF placeholder (conditional on size)
              if (settings.showGif)
                Container(
                  width: settings.gifSize.size,
                  height: settings.gifSize.size,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.workout,
                    size: settings.gifSize.size * 0.5,
                    color: context.colors.primary,
                  ),
                ),
              if (settings.showGif) const SizedBox(width: 12),
              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row with inline insight
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Bench Press',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Inline insight chip
                        if (settings.showInsight) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.insights,
                                  size: AppIconSize.tiny,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '80kg×8',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Timer badge
                        if (settings.showTimer)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppIcons.timer,
                                  size: AppIconSize.tiny,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '90s',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu icon
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  AppIcons.moreVert,
                  size: AppIconSize.medium,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: settings.density.sectionSpacing),

          // Sets preview
          _buildSetsPreview(context, settings),

          // Plates section (conditional)
          if (settings.showPlates) ...[
            SizedBox(height: settings.density.sectionSpacing),
            _buildPlatesPreview(context),
          ],

          // Footer section (conditional on footerElements)
          if (settings.hasFooter) ...[
            SizedBox(height: settings.density.sectionSpacing),
            _buildFooterPreview(context, settings),
          ],
        ],
      ),
    );
  }

  Widget _buildSetsPreview(BuildContext context, ExerciseCardSettings settings) {
    return Column(
      children: [
        // Set row 1
        _buildSetRow(
          context,
          settings,
          setNumber: 1,
          weight: '80',
          reps: '8',
          isCompleted: true,
        ),
        SizedBox(height: settings.density.sectionSpacing / 2),
        // Set row 2
        _buildSetRow(
          context,
          settings,
          setNumber: 2,
          weight: '80',
          reps: '8',
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildSetRow(
    BuildContext context,
    ExerciseCardSettings settings, {
    required int setNumber,
    required String weight,
    required String reps,
    required bool isCompleted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: settings.density.verticalPadding / 2,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.colors.primaryContainer.withValues(alpha: 0.2)
            : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted
                  ? context.colors.primary
                  : context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      AppIcons.check,
                      size: 14,
                      color: context.colors.onPrimary,
                    )
                  : Text(
                      '$setNumber',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Weight
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '${weight}kg',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Reps
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '$reps reps',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // RPE (conditional)
          if (settings.showRpe) ...[
            const SizedBox(width: 8),
            Container(
              width: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                isCompleted ? '8' : '-',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatesPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.calculateRounded,
            size: AppIconSize.small,
            color: context.colors.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Plates: 1×20kg + 1×10kg',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterPreview(BuildContext context, ExerciseCardSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(
          height: 1,
          thickness: 1,
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 8),
        // Chips row
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            // Tips chip
            if (settings.footerElements.contains(ExerciseFooterElement.tips))
              _buildFooterChip(
                context,
                icon: AppIcons.lightbulb,
                label: 'Tips',
              ),
            // TUT chip
            if (settings.footerElements.contains(ExerciseFooterElement.tut))
              _buildFooterChip(
                context,
                icon: AppIcons.timer,
                label: '3-1-2-0',
              ),
            // Notes chip
            if (settings.footerElements.contains(ExerciseFooterElement.notes))
              _buildFooterChip(
                context,
                icon: AppIcons.notes,
                label: 'Notes',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.tiny,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
