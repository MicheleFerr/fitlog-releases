/// Template GDPR Dialogs
///
/// Dialogs for template reporting and social consent.
///
/// **Layer**: Presentation - Widgets
/// **Feature**: workout_templates
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

// =============================================================================
// Social Consent Dialog
// =============================================================================

/// Result of the social consent dialog.
enum SocialConsentResult {
  /// User agreed to publish with profile info visible.
  publishWithProfile,

  /// User chose to publish anonymously.
  publishAnonymous,

  /// User cancelled.
  cancelled,
}

/// Shows a dialog asking for social consent before publishing a template.
///
/// Returns [SocialConsentResult] indicating the user's choice.
Future<SocialConsentResult> showSocialConsentDialog({
  required BuildContext context,
}) async {
  final result = await showDialog<SocialConsentResult>(
    context: context,
    builder: (context) => const _SocialConsentDialog(),
  );
  return result ?? SocialConsentResult.cancelled;
}

class _SocialConsentDialog extends StatelessWidget {
  const _SocialConsentDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.visibility,
            semanticLabel: l10n.socialConsentTitle,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(l10n.socialConsentTitle)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.socialConsentMessage,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.socialConsentRevocable,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, SocialConsentResult.cancelled),
          child: Text(l10n.socialConsentCancel),
        ),
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(context, SocialConsentResult.publishAnonymous),
          child: Text(l10n.socialConsentAnonymous),
        ),
        FilledButton(
          onPressed: () async {
            // Grant consent and return
            await ConsentService().grantSocialConsent();
            if (context.mounted) {
              Navigator.pop(context, SocialConsentResult.publishWithProfile);
            }
          },
          child: Text(l10n.socialConsentAgree),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
