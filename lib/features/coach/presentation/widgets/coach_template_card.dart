/// Coach Template Card Widget
///
/// Displays a coach template in a card format showing:
/// - Template name and description
/// - Exercise count and estimated duration
/// - Assignment count (optional)
/// - Tags
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_template.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Card widget displaying a coach template
class CoachTemplateCard extends StatelessWidget {
  const CoachTemplateCard({
    required this.template,
    required this.onTap,
    this.onAssign,
    this.showAssignmentCount = false,
    super.key,
  });

  final CoachTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onAssign;
  final bool showAssignmentCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.template,
                      color: context.colors.onPrimaryContainer,
                      size: AppIconSize.medium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (template.description != null &&
                            template.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              template.description!,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Menu button
                  IconButton(
                    icon: const Icon(AppIcons.moreVert),
                    onPressed: () => _showMenu(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Stats row
              Row(
                children: [
                  // Exercise count
                  _StatChip(
                    icon: AppIcons.workout,
                    label: '${template.exercises.length}',
                    tooltip: context.l10n.exercises,
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Duration
                  _StatChip(
                    icon: AppIcons.timer,
                    label: '${template.estimatedDuration}m',
                    tooltip: context.l10n.duration,
                  ),

                  // Assignment count (if enabled)
                  if (showAssignmentCount && template.hasAssignments) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _StatChip(
                      icon: AppIcons.peopleOutline,
                      label: '${template.assignedCount}',
                      tooltip: context.l10n.assignedAthletes(
                        template.assignedCount,
                      ),
                      highlight: true,
                    ),
                  ],

                  const Spacer(),

                  // Assign button
                  if (onAssign != null)
                    TextButton.icon(
                      onPressed: onAssign,
                      icon: Icon(AppIcons.personAdd, size: AppIconSize.small),
                      label: Text(context.l10n.assignTemplate),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),

              // Tags (if any)
              if (template.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: template.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.edit),
              title: Text(context.l10n.edit),
              onTap: () {
                Navigator.pop(ctx);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.personAdd),
              title: Text(context.l10n.assignTemplate),
              onTap: () {
                Navigator.pop(ctx);
                onAssign?.call();
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.copy),
              title: Text(context.l10n.duplicate),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Duplicate template
              },
            ),
            ListTile(
              leading: Icon(AppIcons.delete, color: context.colors.error),
              title: Text(
                context.l10n.delete,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Show delete confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stat chip for displaying template stats
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: highlight
              ? context.colors.tertiaryContainer
              : context.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: highlight
                  ? context.colors.onTertiaryContainer
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: highlight
                    ? context.colors.onTertiaryContainer
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
