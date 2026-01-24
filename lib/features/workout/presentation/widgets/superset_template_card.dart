import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Compact superset template card for horizontal scroll
///
/// Designed for 140×160dp footprint per mockup specs
/// Features:
/// - Clean iOS-style card with shadow
/// - Difficulty badge (beginner/intermediate/advanced)
/// - Exercise names (max 2 lines, truncated)
/// - Quick stats (rounds, rest times)
/// - Persona indicator (optional)
/// - Scientific badge for evidence-based templates
class SupersetTemplateCard extends ConsumerStatefulWidget {
  const SupersetTemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onDuplicate,
    this.onEdit,
    this.onDelete,
    this.width = 140,
    this.height = 160,
  });

  final SupersetTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final double width;
  final double height;

  @override
  ConsumerState<SupersetTemplateCard> createState() =>
      _SupersetTemplateCardState();
}

class _SupersetTemplateCardState extends ConsumerState<SupersetTemplateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Fade-in animation on mount
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getDifficultyColor() {
    switch (widget.template.difficulty) {
      case TemplateDifficulty.beginner:
        return context.colors.success; // Green
      case TemplateDifficulty.intermediate:
      case TemplateDifficulty.intermediateAdvanced:
        return context.colors.primary; // Blue
      case TemplateDifficulty.advanced:
        return context.colors.error; // Red
    }
  }

  String _getDifficultyLabel() {
    switch (widget.template.difficulty) {
      case TemplateDifficulty.beginner:
        return context.l10n.beginner;
      case TemplateDifficulty.intermediate:
        return context.l10n.intermediate;
      case TemplateDifficulty.intermediateAdvanced:
        return context.l10n.advanced;
      case TemplateDifficulty.advanced:
        return context.l10n.advanced;
    }
  }

  /// Show options menu on long press
  void _showOptionsMenu() {
    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                context.l10n.templateOptions,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Divider(height: 1),

            // Duplicate option (always available)
            if (widget.onDuplicate != null)
              ListTile(
                leading: Icon(AppIcons.copy, color: context.colors.primary),
                title: Text(context.l10n.duplicateTemplate),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDuplicate!();
                },
              ),

            // Edit option (only for custom templates)
            if (widget.template.isCustom && widget.onEdit != null)
              ListTile(
                leading: Icon(AppIcons.edit, color: context.colors.primary),
                title: Text(context.l10n.editTemplate),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onEdit!();
                },
              ),

            // Delete option (only for custom templates)
            if (widget.template.isCustom && widget.onDelete != null)
              ListTile(
                leading: Icon(AppIcons.delete, color: context.colors.error),
                title: Text(
                  context.l10n.deleteTemplate,
                  style: TextStyle(color: context.colors.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onDelete!();
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hasScientificBasis = widget.template.scientificBasis.isNotEmpty;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        onLongPress: (widget.onDuplicate != null ||
                widget.onEdit != null ||
                widget.onDelete != null)
            ? _showOptionsMenu
            : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Difficulty badge + Scientific indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getDifficultyLabel(),
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getDifficultyColor(),
                          ),
                        ),
                      ),

                      // Scientific badge
                      if (hasScientificBasis)
                        Icon(
                          AppIcons.science,
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Template name
                  Text(
                    widget.template.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Exercise names
                  Expanded(
                    child: Text(
                      widget.template.exerciseNames.join(' + '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: context.colors.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      // Rounds
                      Icon(
                        AppIcons.repeat,
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.template.rounds}x',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Duration estimate
                      Icon(
                        AppIcons.timer,
                        size: AppIconSize.tiny,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.template.estimatedTimeMinutes}min',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
