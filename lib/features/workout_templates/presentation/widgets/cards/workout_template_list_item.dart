/// List item for workout templates in list view (My Templates tab)
///
/// Unified design matching WorkoutTemplateCard:
/// - Category strip with animated press feedback
/// - Press animation (0.98 scale) with haptic feedback
/// - Difficulty badge and exercise preview
/// - Last performed with status color
library;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_card_styles.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_stats.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';

class WorkoutTemplateListItem extends ConsumerStatefulWidget {
  const WorkoutTemplateListItem({
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
  final VoidCallback onTap;
  final VoidCallback onStartWorkout;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback? onMakePublic;

  /// Pre-calculated stats from parent (optimization: avoids N provider calls)
  final TemplateStats? preloadedStats;

  @override
  ConsumerState<WorkoutTemplateListItem> createState() =>
      _WorkoutTemplateListItemState();
}

class _WorkoutTemplateListItemState
    extends ConsumerState<WorkoutTemplateListItem> {
  bool _isPressed = false;

  /// Get color based on template category
  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return context.colors.error;
      case TemplateCategory.cardio:
        return context.colors.primary;
      case TemplateCategory.flexibility:
        return context.colors.success;
      case TemplateCategory.hybrid:
        return context.colors.tertiary;
    }
  }

  /// Get icon based on template category
  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.strength:
        return AppIcons.workout;
      case TemplateCategory.cardio:
        return AppIcons.directionsRun;
      case TemplateCategory.flexibility:
        return AppIcons.flexibility;
      case TemplateCategory.hybrid:
        return AppIcons.fitnessCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // OPTIMIZATION: Use preloaded stats if available
    final TemplateStats? stats;
    if (widget.preloadedStats != null) {
      stats = widget.preloadedStats;
    } else {
      final statsAsync = ref.watch(templateStatsProvider(widget.template.id));
      stats = statsAsync.value;
    }

    final category = widget.template.effectiveCategory;
    final difficulty = widget.template.effectiveDifficulty;
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = _getCategoryIcon(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? AppCardStyles.pressedScale : 1.0,
          duration: AppCardStyles.pressAnimationDuration,
          curve: Curves.easeOut,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main content
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius:
                      BorderRadius.circular(AppCardStyles.cornerRadius),
                  boxShadow: AppCardStyles.compactCardShadows(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md + 4, // Extra space for strip
                    right: AppSpacing.xs,
                    top: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors:
                                category.gradientColors(context.isDarkMode),
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

                      const SizedBox(width: AppSpacing.sm),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title row with difficulty badge
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.template.name,
                                    style:
                                        context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _DifficultyBadge(difficulty: difficulty),
                              ],
                            ),

                            const SizedBox(height: 2),

                            // Exercise preview or description
                            if (widget.template.exercises.isNotEmpty)
                              Text(
                                _buildExercisePreview(),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Text(
                                widget.template.description.isNotEmpty
                                    ? widget.template.description
                                    : l10n.noDescription,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontStyle: widget
                                          .template.description.isEmpty
                                      ? FontStyle.italic
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                            // Fork attribution
                            if (widget.template.forkedFromTemplateId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SemanticIcon(
                                      icon: AppIcons.copy,
                                      semanticLabel: l10n.templateForkedFrom(
                                        widget.template.originalAuthorName ??
                                            '',
                                      ),
                                      size: AppIconSize.tiny,
                                      color: context.colors.tertiary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Flexible(
                                      child: Text(
                                        l10n.templateForkedFrom(
                                          widget.template.originalAuthorName ??
                                              l10n.anonymous,
                                        ),
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
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

                            const SizedBox(height: 4),

                            // Stats row
                            _buildStatsRow(context, l10n, stats),
                          ],
                        ),
                      ),

                      // Menu button
                      _buildPopupMenu(context, l10n),
                    ],
                  ),
                ),
              ),

              // Left accent strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: AppCardStyles.pressAnimationDuration,
                  curve: Curves.easeOut,
                  width: _isPressed
                      ? AppCardStyles.stripWidthPressed
                      : AppCardStyles.stripWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        categoryColor.withValues(alpha: 0.9),
                        categoryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppCardStyles.cornerRadius),
                      bottomLeft: Radius.circular(AppCardStyles.cornerRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(
                          alpha: AppCardStyles.stripGlowOpacity,
                        ),
                        blurRadius: AppCardStyles.stripGlowBlurRadius,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build exercise preview text "Panca · Croci · Dips +3"
  String _buildExercisePreview() {
    final exercises = widget.template.exercises;
    final names = exercises.take(3).map((e) => e.exerciseName).join(' · ');
    final remaining = exercises.length > 3 ? ' +${exercises.length - 3}' : '';
    return '$names$remaining';
  }

  /// Build stats row with exercise count, duration, and last performed
  Widget _buildStatsRow(
    BuildContext context,
    AppLocalizations l10n,
    TemplateStats? stats,
  ) {
    final hasRealDuration = stats != null &&
        stats.totalCompletions > 0 &&
        stats.avgDuration != null;

    return Row(
      children: [
        // Exercise count
        SemanticIcon(
          icon: AppIcons.workout,
          semanticLabel: l10n.exercises,
          size: AppIconSize.tiny,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          '${widget.template.exercises.length}',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Duration
        SemanticIcon(
          icon: AppIcons.timer,
          semanticLabel: l10n.duration,
          size: AppIconSize.tiny,
          color: hasRealDuration
              ? context.colors.success
              : context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Text(
          hasRealDuration
              ? '~${stats.avgDuration!.inMinutes}m'
              : '${widget.template.estimatedDuration}m',
          style: context.textTheme.labelSmall?.copyWith(
            color: hasRealDuration
                ? context.colors.success
                : context.colors.onSurfaceVariant,
          ),
        ),

        // Last performed (if available)
        if (stats != null && stats.lastPerformed != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            AppIcons.history,
            size: AppIconSize.tiny,
            color:
                stats.statusColor(context) ?? context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              stats.formattedLastPerformed(context),
              style: context.textTheme.labelSmall?.copyWith(
                color: stats.statusColor(context) ??
                    context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Build popup menu for actions
  Widget _buildPopupMenu(BuildContext context, AppLocalizations l10n) {
    return CNPopupMenuButton.icon(
      buttonIcon: const CNSymbol('ellipsis', size: 16),
      buttonStyle: CNButtonStyle.plain,
      size: 32,
      items: [
        CNPopupMenuItem(
          label: l10n.startWorkout,
          icon: const CNSymbol('play', size: 14),
        ),
        CNPopupMenuItem(
          label: l10n.duplicate,
          icon: const CNSymbol('doc.on.doc', size: 14),
        ),
        CNPopupMenuItem(
          label: l10n.share,
          icon: const CNSymbol('square.and.arrow.up', size: 14),
        ),
        CNPopupMenuItem(
          label: l10n.makePublic,
          icon: const CNSymbol('globe', size: 14),
        ),
        CNPopupMenuItem(
          label: l10n.delete,
          icon: const CNSymbol('trash', size: 14),
        ),
      ],
      onSelected: (index) {
        switch (index) {
          case 0: widget.onStartWorkout();
          case 1: widget.onDuplicate();
          case 2: widget.onShare();
          case 3: widget.onMakePublic?.call();
          case 4: widget.onDelete();
        }
      },
    );
  }
}

/// Difficulty badge (compact version for list items)
class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final DifficultyLevel difficulty;

  Color _getBackgroundColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.successContainer;
      case DifficultyLevel.intermediate:
        return context.colors.warningContainer;
      case DifficultyLevel.advanced:
        return context.colors.primaryContainer;
      case DifficultyLevel.expert:
        return context.colors.tertiaryContainer;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.success;
      case DifficultyLevel.intermediate:
        return context.colors.warning;
      case DifficultyLevel.advanced:
        return context.colors.primary;
      case DifficultyLevel.expert:
        return context.colors.tertiary;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.onSuccessContainer;
      case DifficultyLevel.intermediate:
        return context.colors.onWarningContainer;
      case DifficultyLevel.advanced:
        return context.colors.onPrimaryContainer;
      case DifficultyLevel.expert:
        return context.colors.onTertiaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(context), width: 1),
      ),
      child: Text(
        difficulty.localizedName(context),
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: _getTextColor(context),
          fontSize: 10,
        ),
      ),
    );
  }
}
