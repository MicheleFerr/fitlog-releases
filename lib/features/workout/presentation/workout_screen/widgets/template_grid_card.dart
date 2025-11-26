import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Grid template card widget
///
/// Displays a template in a Material card with:
/// - Gradient header with icon
/// - Template name and details
/// - Exercise count, duration, and custom badge
///
/// Used in grid layouts to show individual templates.
class TemplateGridCard extends StatelessWidget {
  const TemplateGridCard({
    super.key,
    required this.template,
    required this.onTap,
  });

  /// The workout template to display
  final wt.WorkoutTemplate template;

  /// Callback when card is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Usa colori del tema invece di colori basati sul nome
    final baseColor = template.isCustom
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header with icon
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    baseColor,
                    baseColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SemanticIcon(
                  icon: AppIcons.workout,
                  semanticLabel: 'Workout template',
                  size: AppIconSize.xlarge,
                  color: context.colors.surface,
                ),
              ),
            ),

            // Template details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      template.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Stats
                    Column(
                      children: [
                        // Exercises count
                        Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.formatListBulleted,
                              semanticLabel: 'Format list bulleted',
                              size: AppIconSize.tiny,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              context.l10n.exercisesCount(template.exercises.length),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        // Duration
                        Row(
                          children: [
                            SemanticIcon(
                              icon: AppIcons.timer,
                              semanticLabel: 'Timer',
                              size: AppIconSize.tiny,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              '~${template.estimatedDuration} min',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        // Custom badge
                        if (template.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.sm),
                            ),
                            child: Text(
                              context.l10n.customBadge,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
