import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_start_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Fallback templates widget
///
/// Displays hardcoded fallback templates when no templates are available
/// from the backend. These are basic workout templates that users can
/// start immediately:
/// - Upper Body
/// - Lower Body
/// - HIIT Training
///
/// Each template is displayed as a QuickStartCard with appropriate
/// icons and colors.
class FallbackTemplates extends StatelessWidget {
  const FallbackTemplates({
    super.key,
    required this.onTemplateSelected,
  });

  /// Callback when a fallback template is selected
  /// The template name is passed as a string identifier
  final void Function(String templateName) onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuickStartCard(
          icon: AppIcons.workout,
          title: context.l10n.upperBody,
          subtitle: context.l10n.upperBodySubtitle,
          color: context.colors.secondary,
          onTap: () => onTemplateSelected('Upper Body'),
        ),
        const SizedBox(height: AppSpacing.sm),
        QuickStartCard(
          icon: AppIcons.cardio,
          title: context.l10n.lowerBody,
          subtitle: context.l10n.lowerBodySubtitle,
          color: context.colors.tertiary,
          onTap: () => onTemplateSelected('Lower Body'),
        ),
        const SizedBox(height: AppSpacing.sm),
        QuickStartCard(
          icon: AppIcons.timer,
          title: context.l10n.hiitTraining,
          subtitle: context.l10n.hiitTrainingSubtitle,
          color: context.colors.error,
          onTap: () => onTemplateSelected('HIIT'),
        ),
      ],
    );
  }
}
