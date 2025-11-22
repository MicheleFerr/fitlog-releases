import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Card speciale per template nei Quick Start
class TemplateQuickStartCard extends StatelessWidget {
  const TemplateQuickStartCard({
    super.key,
    required this.template,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final wt.WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: template.isCustom ? () => _showContextMenu(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icona template
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: template.isCustom
                      ? context.colors.primary.withValues(alpha: 0.1)
                      : context.colors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  template.isCustom ? AppIcons.person : AppIcons.star,
                  color: template.isCustom
                      ? context.colors.primary
                      : context.colors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Info template
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Statistiche mini
                    Row(
                      children: [
                        SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.medium,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.exercises.length}',
                          style: context.textTheme.labelSmall?.copyWith(
                            // fontSize handled by labelSmall
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SemanticIcon(
  icon: AppIcons.schedule,
  semanticLabel: 'Schedule',
  size: AppIconSize.medium,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${template.estimatedDuration}min',
                          style: context.textTheme.labelSmall?.copyWith(
                            // fontSize handled by labelSmall
                            color: context.colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (template.usageCount > 0) ...[
                          const SizedBox(width: 12),
                          SemanticIcon(
  icon: AppIcons.trendUp,
  semanticLabel: 'Trend up',
  size: AppIconSize.medium,
  color: context.colors.onSurface.withValues(alpha: 0.5,
),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${template.usageCount}',
                            style: context.textTheme.labelSmall?.copyWith(
                              // fontSize handled by labelSmall
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Freccia
              Icon(
                AppIcons.forwardIos,
                color: context.colors.onSurface.withValues(alpha: 0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    // Haptic feedback per il long press
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),

            // Titolo
            Row(
              children: [
                Icon(
                  template.isCustom ? AppIcons.person : AppIcons.star,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Opzioni menu
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.play,
                  color: context.colors.primary,
                ),
              ),
              title: Text(context.l10n.startWorkoutAction),
              subtitle: Text(context.l10n.startWorkoutDescription),
              onTap: () {
                Navigator.of(context).pop();
                onTap();
              },
            ),

            if (onEdit != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.edit,
                    color: context.colors.secondary,
                  ),
                ),
                title: Text(context.l10n.modifyTemplate),
                subtitle: Text(context.l10n.addOrRemoveExercises),
                onTap: () {
                  Navigator.of(context).pop();
                  onEdit!();
                },
              ),

            if (onDelete != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.delete,
                    color: context.errorColor,
                  ),
                ),
                title: Text(context.l10n.deleteTemplate),
                subtitle: Text(context.l10n.removePermanentlyAction),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete!();
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
