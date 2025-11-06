import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Types of legal documents available for viewing
enum DocumentType {
  privacyPolicy,
  termsOfService,
  medicalDisclaimer,
}

/// Extension to get document paths based on locale
extension DocumentTypeExtension on DocumentType {
  /// Returns the asset path for the document based on locale
  String getPath(String locale) {
    switch (this) {
      case DocumentType.privacyPolicy:
        return locale == 'it'
            ? 'docs/legal/PRIVACY_POLICY_IT.md'
            : 'docs/legal/PRIVACY_POLICY_EN.md';
      case DocumentType.termsOfService:
        return locale == 'it'
            ? 'docs/legal/TERMS_OF_SERVICE_IT.md'
            : 'docs/legal/TERMS_OF_SERVICE_EN.md';
      case DocumentType.medicalDisclaimer:
        // Medical disclaimer uses existing localization content
        return '';
    }
  }
}

/// Screen for viewing legal documents (Privacy Policy, ToS, Medical Disclaimer)
///
/// Loads markdown documents from assets and displays them in a scrollable view.
/// Supports localization (IT/EN) and shows appropriate loading/error states.
class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({
    super.key,
    required this.documentType,
  });

  final DocumentType documentType;

  String _getTitle(BuildContext context) {
    switch (documentType) {
      case DocumentType.privacyPolicy:
        return context.l10n.privacyPolicy;
      case DocumentType.termsOfService:
        return context.l10n.termsOfService;
      case DocumentType.medicalDisclaimer:
        return context.l10n.legalDisclaimerTitle;
    }
  }

  Future<String> _loadDocument(BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode;
    final path = documentType.getPath(locale);

    if (path.isEmpty) {
      // Medical disclaimer content from existing localizations
      return context.l10n.legalDisclaimerContent;
    }

    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      throw Exception('Failed to load document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context)),
      ),
      body: FutureBuilder<String>(
        future: _loadDocument(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.l10n.errorLoadingDocument,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              snapshot.data!,
              style: context.textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }
}
