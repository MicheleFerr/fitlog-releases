/// Main workout template card for grid/list view in My Templates tab
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

class WorkoutTemplateCard extends ConsumerWidget {
  const WorkoutTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onStartWorkout,
    required this.onDuplicate,
    required this.onShare,
    required this.onDelete,
    this.onMakePublic,
    this.preloadedStats,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap; // Now goes to Edit
  final VoidCallback onStartWorkout; // Starts workout
  final VoidCallback onDuplicate; // Duplicates template
  final VoidCallback onShare; // Shares template
  final VoidCallback onDelete;
  final VoidCallback? onMakePublic; // Make template public

  /// Pre-calculated stats from parent (optimization: avoids N provider calls)
  final TemplateStats? preloadedStats;

  /// Get color based on template category (matches TemplateCard in WorkoutScreen)
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // OPTIMIZATION: Use preloaded stats if available
    final TemplateStats? stats;
    if (preloadedStats != null) {
      stats = preloadedStats;
    } else {
      final statsAsync = ref.watch(templateStatsProvider(template.id));
      stats = statsAsync.value;
    }

    // Get category for colors/icon
    final category = template.effectiveCategory;
    final categoryColor = _getCategoryColor(context, category);
    final categoryIcon = _getCategoryIcon(category);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main card content
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              // Border with category color accent
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      // Icon with category-based colors
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: category.gradientColors(context.isDarkMode),
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SemanticIcon(
                          icon: categoryIcon,
                          semanticLabel: l10n.workout,
                          size: AppIconSize.small,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: SemanticIcon(
                          icon: AppIcons.moreVert,
                          semanticLabel: l10n.more,
                          size: AppIconSize.small,
                        ),
                        onSelected: (value) {
                          if (value == 'start') onStartWorkout();
                          if (value == 'duplicate') onDuplicate();
                          if (value == 'share') onShare();
                          if (value == 'make_public') onMakePublic?.call();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          // Start Workout option (primary action in menu)
                          PopupMenuItem(
                            value: 'start',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.play,
                                  semanticLabel: l10n.startWorkout,
                                  size: AppIconSize.small,
                                  color: context.colors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.startWorkout,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          // Duplicate option
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.copy,
                                  semanticLabel: l10n.duplicate,
                                  size: AppIconSize.small,
                                  color: context.colors.onSurface,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.duplicate,
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          // Share option
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.share,
                                  semanticLabel: l10n.share,
                                  size: AppIconSize.small,
                                  color: context.colors.onSurface,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.share,
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          // Make Public option
                          PopupMenuItem(
                            value: 'make_public',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.public,
                                  semanticLabel: l10n.makePublic,
                                  size: AppIconSize.small,
                                  color: context.colors.onSurface,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.makePublic,
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          // Delete option
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.delete,
                                  semanticLabel: l10n.delete,
                                  size: AppIconSize.small,
                                  color: context.colors.error,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  l10n.delete,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.error,
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

                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    template.name,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Fork attribution badge
                if (template.forkedFromTemplateId != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      children: [
                        SemanticIcon(
                          icon: AppIcons.copy,
                          semanticLabel: l10n.templateForkedFrom(
                            template.originalAuthorName ?? '',
                          ),
                          size: AppIconSize.tiny,
                          color: context.colors.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            l10n.templateForkedFrom(
                              template.originalAuthorName ?? l10n.anonymous,
                            ),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.tertiary,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Stats
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      SemanticIcon(
                        icon: AppIcons.workout,
                        semanticLabel: l10n.exercises,
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${template.exercises.length}',
                        style: context.textTheme.bodySmall?.copyWith(
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
                      const SizedBox(width: AppSpacing.xs),
                      // Duration display: real average or estimated
                      if (stats != null &&
                          stats.totalCompletions > 0 &&
                          stats.avgDuration != null)
                        Text(
                          '${stats.avgDuration!.inMinutes}m',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.success, // Green for real data
                          ),
                        )
                      else
                        Text(
                          '~${template.estimatedDuration}m',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Watermark category icon (matches TemplateCard in WorkoutScreen)
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              categoryIcon,
              size: 80,
              color: categoryColor.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
