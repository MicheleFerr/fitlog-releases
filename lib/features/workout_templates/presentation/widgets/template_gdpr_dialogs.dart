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
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
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
  final result = await ModalService.showSheet<SocialConsentResult>(
    context,
    isScrollControlled: true,
    builder: (context) => const _SocialConsentSheet(),
  );
  return result ?? SocialConsentResult.cancelled;
}

class _SocialConsentSheet extends StatefulWidget {
  const _SocialConsentSheet();

  @override
  State<_SocialConsentSheet> createState() => _SocialConsentSheetState();
}

class _SocialConsentSheetState extends State<_SocialConsentSheet> {
  bool _isSavingConsent = false;

  Future<void> _publishWithProfile(BuildContext context) async {
    if (_isSavingConsent) return;

    setState(() => _isSavingConsent = true);

    try {
      final consentService = ConsentService();
      final hasConsent = await consentService.hasSocialConsent();
      if (!hasConsent) {
        await consentService.grantSocialConsent();
      }

      if (context.mounted) {
        Navigator.pop(context, SocialConsentResult.publishWithProfile);
      }
    } catch (_) {
      if (!context.mounted) return;
      SnackBarService.showError(context, context.l10n.errorGeneric);
      setState(() => _isSavingConsent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: SemanticIcon(
                    icon: AppIcons.visibility,
                    semanticLabel: l10n.socialConsentTitle,
                    size: AppIconSize.large,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.socialConsentTitle,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.socialConsentRevocable,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                l10n.socialConsentMessage,
                style: context.textTheme.bodyMedium,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSavingConsent
                        ? null
                        : () => _publishWithProfile(context),
                    icon: _isSavingConsent
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: LoadingIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.badge_outlined),
                    label: Text(l10n.socialConsentAgree),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSavingConsent
                        ? null
                        : () => Navigator.pop(
                            context,
                            SocialConsentResult.publishAnonymous,
                          ),
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: Text(l10n.socialConsentAnonymous),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: _isSavingConsent
                      ? null
                      : () => Navigator.pop(
                          context,
                          SocialConsentResult.cancelled,
                        ),
                  child: Text(l10n.socialConsentCancel),
                ),
              ],
            ),
          ),

          SizedBox(height: context.bottomPadding + AppSpacing.sm),
        ],
      ),
    );
  }
}
