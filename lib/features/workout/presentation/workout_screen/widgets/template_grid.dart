import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart' as wt;
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/swipeable_template_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Template grid widget that displays templates in a vertical list
///
/// Shows templates as swipeable cards with iOS-style swipe actions.
/// Displays an empty state when no templates are available.
class TemplateGrid extends StatelessWidget {
  const TemplateGrid({
    super.key,
    required this.templates,
    required this.categoryTitle,
    required this.isCustomTab,
    required this.onTemplateTap,
    required this.onTemplateShare,
    required this.onTemplateDuplicate,
    required this.onTemplateEdit,
    required this.onTemplateDelete,
    required this.onCreateTemplate,
    this.onTemplateSchedule,
  });

  /// List of templates to display
  final List<wt.WorkoutTemplate> templates;

  /// Category title (for accessibility and context)
  final String categoryTitle;

  /// Whether this is the custom templates tab
  final bool isCustomTab;

  /// Callback when user taps on a template
  final void Function(wt.WorkoutTemplate template) onTemplateTap;

  /// Callback when user shares a template
  final void Function(wt.WorkoutTemplate template) onTemplateShare;

  /// Callback when user duplicates a template
  final void Function(wt.WorkoutTemplate template) onTemplateDuplicate;

  /// Callback when user edits a template
  final void Function(wt.WorkoutTemplate template) onTemplateEdit;

  /// Callback when user deletes a template
  final void Function(wt.WorkoutTemplate template) onTemplateDelete;

  /// Callback when user creates a new template (only shown in empty state for custom tab)
  final VoidCallback onCreateTemplate;

  /// Callback when user schedules a template (swipe right action)
  final void Function(wt.WorkoutTemplate template)? onTemplateSchedule;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: isCustomTab ? AppIcons.noteAdd : AppIcons.inventory2Outlined,
              semanticLabel: isCustomTab ? 'No custom templates' : 'No predefined workouts',
              size: AppIconSize.xxlarge,
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isCustomTab ? context.l10n.noCustomTemplates : context.l10n.noPredefinedWorkouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isCustomTab ? context.l10n.createFirstTemplate : context.l10n.predefinedWorkoutsComingSoon,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
            if (isCustomTab) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onCreateTemplate,
                icon: SemanticIcon(
                  icon: AppIcons.add,
                  semanticLabel: context.l10n.createNewTemplate,
                  size: AppIconSize.medium,
                ),
                label: Text(context.l10n.createNewTemplate),
              ),
            ],
          ],
        ),
      );
    }

    // Use vertical ListView with SwipeableTemplateCard (iOS-style swipe actions)
    return ListView.builder(
      itemCount: templates.length,
      itemExtent: 216, // 200px card + 16px margin (8px top + 8px bottom)
      itemBuilder: (context, index) {
        final template = templates[index];
        return SwipeableTemplateCard(
          key: ValueKey(template.id),
          template: template,
          onTap: () => onTemplateTap(template),
          onShare: () => onTemplateShare(template),
          onDuplicate: () => onTemplateDuplicate(template),
          onEdit: () => onTemplateEdit(template),
          onDelete: () => onTemplateDelete(template),
          onSchedule: onTemplateSchedule != null
              ? () => onTemplateSchedule!(template)
              : null,
        );
      },
    );
  }
}
