/// Main workout template card for grid/list view in My Templates tab
///
/// Unified design matching TemplateCard from WorkoutScreen:
/// - Category strip with animated press feedback
/// - Double shadow system for depth
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

class WorkoutTemplateCard extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<WorkoutTemplateCard> createState() =>
      _WorkoutTemplateCardState();
}

class _WorkoutTemplateCardState extends ConsumerState<WorkoutTemplateCard> {
  bool _isPressed = false;

  /// Get color based on template category (matches TemplateCard in WorkoutScreen)
  Color _getCategoryColor(TemplateCategory category) {
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

    // OPTIMIZATION: Use preloaded stats if available
    final TemplateStats? stats;
    if (widget.preloadedStats != null) {
      stats = widget.preloadedStats;
    } else {
      final statsAsync = ref.watch(templateStatsProvider(widget.template.id));
      stats = statsAsync.value;
    }

    // Get category for colors/icon
    final category = widget.template.effectiveCategory;
    final difficulty = widget.template.effectiveDifficulty;
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = _getCategoryIcon(category);

    return GestureDetector(
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
            // Main card content
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppCardStyles.cornerRadius),
                boxShadow: AppCardStyles.cardShadows(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and menu
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
                              colors:
                                  category.gradientColors(context.isDarkMode),
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.sm),
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
                        // Difficulty badge
                        _DifficultyBadge(difficulty: difficulty),
                        const Spacer(),
                        _buildPopupMenu(context, l10n),
                      ],
                    ),
                  ),

                  // Name
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      widget.template.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Exercise preview
                  if (widget.template.exercises.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        _buildExercisePreview(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Fork attribution badge
                  if (widget.template.forkedFromTemplateId != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          SemanticIcon(
                            icon: AppIcons.copy,
                            semanticLabel: l10n.templateForkedFrom(
                              widget.template.originalAuthorName ?? '',
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

                  // Stats row with duration and last performed
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: _buildStatsRow(context, l10n, stats),
                  ),
                ],
              ),
            ),

            // Left accent strip (category color) - matches TemplateCard
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

            // Watermark category icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                categoryIcon,
                size: AppCardStyles.watermarkSize(CardSize.medium),
                color: categoryColor.withValues(
                  alpha: AppCardStyles.watermarkOpacity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build exercise preview text "Panca · Croci · Dips +3"
  String _buildExercisePreview() {
    final exercises = widget.template.exercises;
    final names = exercises.take(3).map((e) => e.exerciseName).join(' · ');
    final remaining =
        exercises.length > 3 ? ' +${exercises.length - 3}' : '';
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${widget.template.exercises.length}',
          style: context.textTheme.bodySmall?.copyWith(
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          hasRealDuration
              ? '~${stats.avgDuration!.inMinutes}m'
              : '${widget.template.estimatedDuration}m',
          style: context.textTheme.bodySmall?.copyWith(
            color: hasRealDuration
                ? context.colors.success
                : context.colors.onSurfaceVariant,
            fontStyle: hasRealDuration ? null : FontStyle.italic,
          ),
        ),

        // Last performed (if available)
        if (stats != null && stats.lastPerformed != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: AppSpacing.xxs,
            height: AppSpacing.xxs,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            AppIcons.history,
            size: AppIconSize.tiny,
            color: stats.statusColor(context) ??
                context.colors.onSurfaceVariant,
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

  /// Build popup menu for card actions
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

/// Difficulty badge with WCAG AA compliant semantic colors
/// Matches the design from TemplateCard
class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final DifficultyLevel difficulty;

  /// Get background color (light container)
  Color _getBackgroundColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.successContainer;
      case DifficultyLevel.intermediate:
        return context.colors.warningContainer;
      case DifficultyLevel.advanced:
        return context.colors.primaryContainer; // Blue - not intimidating
      case DifficultyLevel.expert:
        return context.colors.tertiaryContainer; // Purple for expert
    }
  }

  /// Get border color (saturated semantic)
  Color _getBorderColor(BuildContext context) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return context.colors.success;
      case DifficultyLevel.intermediate:
        return context.colors.warning;
      case DifficultyLevel.advanced:
        return context.colors.primary; // Blue - not intimidating
      case DifficultyLevel.expert:
        return context.colors.tertiary; // Purple for expert
    }
  }

  /// Get text color (on container)
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
