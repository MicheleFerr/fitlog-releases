import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/document_viewer_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Screen displaying links to all legal documents
///
/// Provides access to:
/// - Privacy Policy (GDPR compliant)
/// - Terms of Service
/// - Medical Disclaimer
///
/// Each document opens in a [DocumentViewerScreen] with full content.
class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  void _openDocument(BuildContext context, DocumentType documentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(documentType: documentType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.legalDocuments),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              AppIcons.privacyTipRounded,
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            title: Text(context.l10n.privacyPolicy),
            subtitle: Text(context.l10n.privacyPolicySubtitle),
            trailing: const Icon(
              AppIcons.chevronRight,
              size: AppIconSize.small,
            ),
            onTap: () => _openDocument(context, DocumentType.privacyPolicy),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              AppIcons.article,
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            title: Text(context.l10n.termsOfService),
            subtitle: Text(context.l10n.tosSubtitle),
            trailing: const Icon(
              AppIcons.chevronRight,
              size: AppIconSize.small,
            ),
            onTap: () => _openDocument(context, DocumentType.termsOfService),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              AppIcons.healthAndSafety,
              size: AppIconSize.medium,
              color: context.colors.error, // Medical warning in red
            ),
            title: Text(context.l10n.legalDisclaimerTitle),
            subtitle: Text(context.l10n.disclaimerSubtitle),
            trailing: Icon(
              AppIcons.chevronRight,
              size: AppIconSize.small,
            ),
            onTap: () =>
                _openDocument(context, DocumentType.medicalDisclaimer),
          ),
        ],
      ),
    );
  }
}
