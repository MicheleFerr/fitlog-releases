/// Template GDPR Dialogs
///
/// Dialogs for template reporting and social consent.
///
/// **Layer**: Presentation - Widgets
/// **Feature**: workout_templates
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_report_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/template_report.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

// =============================================================================
// Template Report Dialog
// =============================================================================

/// Shows a dialog to report a community template.
///
/// Returns `true` if the report was submitted successfully.
Future<bool> showTemplateReportDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String templateId,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _TemplateReportDialog(
      templateId: templateId,
      ref: ref,
    ),
  );
  return result ?? false;
}

class _TemplateReportDialog extends StatefulWidget {
  const _TemplateReportDialog({
    required this.templateId,
    required this.ref,
  });

  final String templateId;
  final WidgetRef ref;

  @override
  State<_TemplateReportDialog> createState() => _TemplateReportDialogState();
}

class _TemplateReportDialogState extends State<_TemplateReportDialog> {
  TemplateReportReason? _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _reasonLabel(AppLocalizations l10n, TemplateReportReason reason) {
    return switch (reason) {
      TemplateReportReason.inappropriateContent =>
        l10n.templateReportReasonInappropriate,
      TemplateReportReason.misleading => l10n.templateReportReasonMisleading,
      TemplateReportReason.spam => l10n.templateReportReasonSpam,
      TemplateReportReason.copyright => l10n.templateReportReasonCopyright,
      TemplateReportReason.other => l10n.templateReportReasonOther,
    };
  }

  Future<void> _submit() async {
    if (_selectedReason == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = widget.ref.read(templateReportRepositoryProvider);
      await repo.reportTemplate(
        templateId: widget.templateId,
        reason: _selectedReason!,
        details: _detailsController.text.trim().isNotEmpty
            ? _detailsController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        SnackBarService.showSuccess(
          context,
          AppLocalizations.of(context).templateReportSuccess,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final message = e.toString().contains('already_reported')
            ? l10n.templateReportAlreadyReported
            : l10n.errorGeneric;
        SnackBarService.showError(context, message);
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.templateReportTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.templateReportReasonLabel,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...TemplateReportReason.values.map(
              (reason) => RadioListTile<TemplateReportReason>(
                title: Text(
                  _reasonLabel(l10n, reason),
                  style: context.textTheme.bodyMedium,
                ),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) => setState(() => _selectedReason = value),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(
                labelText: l10n.templateReportDetailsLabel,
                hintText: l10n.templateReportDetailsHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selectedReason != null && !_isSubmitting ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.templateReportSubmit),
        ),
      ],
    );
  }
}

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
