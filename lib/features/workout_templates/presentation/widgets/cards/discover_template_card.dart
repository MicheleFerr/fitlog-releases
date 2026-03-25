/// Full-width template card for the Store vertical list
///
/// UX Research Base (Netflix Thumbnail Research):
/// - Larger thumbnails preferred over smaller ones with text
/// - 160px height for comfortable touch targets
/// - Left color strip for quick category identification
/// - Clear visual hierarchy: Name → Stats → CTA
///
/// Replaces horizontal scroll of small 180x120 cards with
/// vertical list of large, readable cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template_extensions.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/template_category.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/difficulty_level.dart';

/// Full-width template card for vertical list view
///
/// Features:
/// - 160px fixed height for consistent rhythm
/// - Left accent strip colored by category
/// - Category and difficulty badges
/// - Stats row with exercise count and duration
/// - Prominent CTA buttons
/// - Press animation with haptic feedback
class DiscoverTemplateCard extends StatefulWidget {
  const DiscoverTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onUse,
    this.primaryActionLabel,
    this.onReport,
  });

  /// Template to display
  final WorkoutTemplate template;

  /// Callback when card is tapped (preview)
  final VoidCallback onTap;

  /// Callback when "Save to Library" button is tapped
  final VoidCallback onUse;

  /// Optional override for the primary CTA label.
  final String? primaryActionLabel;

  /// Optional callback to report the template.
  final VoidCallback? onReport;

  @override
  State<DiscoverTemplateCard> createState() => _DiscoverTemplateCardState();
}

class _DiscoverTemplateCardState extends State<DiscoverTemplateCard> {
  bool _isPressed = false;

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
        return AppIcons.flexibility; // Stretch
      case TemplateCategory.hybrid:
        return AppIcons.fitnessCenter; // Gym
    }
  }

  /// Get localized category name
  String _getCategoryName(BuildContext context, TemplateCategory category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case TemplateCategory.strength:
        return l10n.strength;
      case TemplateCategory.cardio:
        return l10n.cardio;
      case TemplateCategory.flexibility:
        return l10n.flexibility;
      case TemplateCategory.hybrid:
        return l10n.templateCategoryHybrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = widget.template.effectiveCategory;
    final difficulty = widget.template.effectiveDifficulty;
    final color = _getCategoryColor(context, category);
    final categoryIcon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(context, category);
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: 160,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.colors.surface, color.withValues(alpha: 0.03)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(
                  alpha: isDark ? 0.2 : 0.08,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Watermark icon
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  categoryIcon,
                  size: 100,
                  color: color.withValues(alpha: 0.06),
                ),
              ),

              // Left accent strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isPressed ? 5 : 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.9),
                        color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, // Extra left padding for strip
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Left: Template info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row: Category badge + Difficulty badge
                          Row(
                            children: [
                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(categoryIcon, size: 12, color: color),
                                    const SizedBox(width: 4),
                                    Text(
                                      categoryName,
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: AppSpacing.sm),

                              // Difficulty badge
                              _DifficultyBadge(
                                difficulty: difficulty,
                                isDark: isDark,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Template name (larger, bolder)
                          Text(
                            widget.template.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (widget.template.authorName != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.byAuthor(widget.template.authorName!),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const Spacer(),

                          // Stats row
                          Row(
                            children: [
                              Icon(
                                AppIcons.workout,
                                size: AppIconSize.small,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.exercises.length}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                AppIcons.timer,
                                size: AppIconSize.small,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.estimatedDuration}\'',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                AppIcons.download,
                                size: AppIconSize.small,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.downloadCount}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Icon(
                                AppIcons.merge,
                                size: AppIconSize.small,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.template.forkCount}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: CTA buttons
                    const SizedBox(width: AppSpacing.md),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Save to Library button
                        FilledButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            widget.onUse();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          child: Text(
                            widget.primaryActionLabel ?? l10n.addToMyTemplates,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // Preview link
                        TextButton(
                          onPressed: widget.onTap,
                          child: Text(
                            l10n.preview,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (widget.onReport != null)
                          TextButton(
                            onPressed: widget.onReport,
                            child: Text(
                              l10n.templateReportAction,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Difficulty badge widget with semantic colors
class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty, required this.isDark});

  final DifficultyLevel difficulty;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = difficulty.badgeColor(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        difficulty.localizedName(context),
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
