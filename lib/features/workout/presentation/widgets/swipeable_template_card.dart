import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/template_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// iOS-style swipeable wrapper for TemplateCard
///
/// Features:
/// - Swipe left to reveal 4 action buttons
/// - Actions: Share, Duplicate, Edit, Delete
/// - Actions stay open until explicitly closed
/// - Smooth reveal animation
/// - HapticFeedback on actions
/// - Uses flutter_slidable for proper swipe behavior
class SwipeableTemplateCard extends StatelessWidget {
  const SwipeableTemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onShare,
    required this.onDuplicate,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkoutTemplate template;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(template.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.75, // Show all 4 actions
        children: [
          // Share action
          CustomSlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              onShare();
            },
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.share,
                  semanticLabel: context.l10n.templateActionShare,
                  size: AppIconSize.medium,
                  color: context.colors.onPrimary,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.templateActionShare,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Duplicate action
          CustomSlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              onDuplicate();
            },
            backgroundColor: context.colors.tertiary,
            foregroundColor: context.colors.onTertiary,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.copy,
                  semanticLabel: context.l10n.templateActionDuplicate,
                  size: AppIconSize.medium,
                  color: context.colors.onTertiary,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.templateActionDuplicate,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Edit action
          CustomSlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              onEdit();
            },
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.onSecondary,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.edit,
                  semanticLabel: context.l10n.templateActionEdit,
                  size: AppIconSize.medium,
                  color: context.colors.onSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.templateActionEdit,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Delete action (red)
          CustomSlidableAction(
            onPressed: (context) {
              HapticFeedback.heavyImpact();
              onDelete();
            },
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SemanticIcon(
                  icon: AppIcons.delete,
                  semanticLabel: context.l10n.templateActionDelete,
                  size: AppIconSize.medium,
                  color: context.colors.onError,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.templateActionDelete,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onError,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      child: TemplateCard(
        template: template,
        onTap: onTap,
      ),
    );
  }
}
