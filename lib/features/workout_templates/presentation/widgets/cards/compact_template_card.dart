/// Compact template card for horizontal scroll in Discover tab
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';

class CompactTemplateCard extends StatelessWidget {
  const CompactTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onUse,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onUse;

  /// Get color based on template category
  Color _getCategoryColor(BuildContext context, TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return context.colors.error; // Red
      case TemplateCategory.cardio:
        return context.colors.primary; // Blue
      case TemplateCategory.flexibility:
        return context.colors.success; // Green
      case TemplateCategory.hybrid:
        return context.colors.tertiary; // Purple
    }
  }

  /// Get icon based on template category
  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return AppIcons.workout; // Dumbbell
      case TemplateCategory.cardio:
        return AppIcons.directionsRun; // Running
      case TemplateCategory.flexibility:
        return AppIcons.flexibility; // Yoga pose
      case TemplateCategory.hybrid:
        return AppIcons.fitnessCenter; // General fitness
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = template.effectiveCategory;
    final categoryColor = _getCategoryColor(context, category);
    final categoryIcon = _getCategoryIcon(category);

    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: categoryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Watermark icon
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(
                categoryIcon,
                size: 48,
                color: categoryColor.withValues(alpha: 0.1),
              ),
            ),
            // Main content
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category icon + Template name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  category.gradientColors(context.isDarkMode),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            categoryIcon,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            template.name,
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Stats row
                    Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.workout,
                          semanticLabel: l10n.exercises,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.exercises.length}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SemanticIcon(
                          icon: AppIcons.timer,
                          semanticLabel: l10n.duration,
                          size: AppIconSize.tiny,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        // Handle null/0 duration gracefully
                        Text(
                          '${template.estimatedDuration}\'',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Use button with category color
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: onUse,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: const Size(0, 32),
                          backgroundColor:
                              categoryColor.withValues(alpha: 0.15),
                          foregroundColor: categoryColor,
                        ),
                        child: Text(
                          l10n.use,
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
