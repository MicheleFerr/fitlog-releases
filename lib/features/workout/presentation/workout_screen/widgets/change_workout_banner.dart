import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Banner widget that prompts users to change their workout template.
///
/// Displayed in the preloaded workout view to allow users to browse
/// other templates if the suggested one doesn't fit their needs.
class ChangeWorkoutBanner extends StatelessWidget {
  const ChangeWorkoutBanner({required this.onBrowseTemplates, super.key});

  /// Callback when the user taps to browse templates
  final VoidCallback onBrowseTemplates;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              context.l10n.notWhatYouWanted,
              style: context.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: onBrowseTemplates,
            child: Text(context.l10n.browseTemplates),
          ),
        ],
      ),
    );
  }
}
