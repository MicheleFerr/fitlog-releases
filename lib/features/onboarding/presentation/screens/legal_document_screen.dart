import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Simple screen to display legal documents (Privacy Policy, Terms of Service)
///
/// Loads markdown files from assets and displays them as plain text.
/// For TestFlight/early release - can be upgraded to flutter_markdown later.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;

  /// Show Privacy Policy based on current locale
  static void showPrivacyPolicy(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isItalian = locale.languageCode == 'it';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: context.l10n.privacyPolicy,
          assetPath: isItalian
              ? 'docs/legal/PRIVACY_POLICY_IT.md'
              : 'docs/legal/PRIVACY_POLICY_EN.md',
        ),
      ),
    );
  }

  /// Show Terms of Service based on current locale
  static void showTermsOfService(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isItalian = locale.languageCode == 'it';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: context.l10n.termsOfService,
          assetPath: isItalian
              ? 'docs/legal/TERMS_OF_SERVICE_IT.md'
              : 'docs/legal/TERMS_OF_SERVICE_EN.md',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading document: ${snapshot.error}',
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final content = snapshot.data ?? '';

          // Simple markdown-to-text conversion
          // Remove markdown headers (#), bold (**), etc.
          final cleanContent = _cleanMarkdown(content);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              cleanContent,
              style: context.textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Simple markdown cleaning for readability
  /// Keeps headers visible but removes markdown syntax
  String _cleanMarkdown(String markdown) {
    return markdown
        // Convert headers to uppercase with spacing
        .replaceAllMapped(
          RegExp(r'^#{1,6}\s+(.+)$', multiLine: true),
          (match) => '\n${match.group(1)?.toUpperCase()}\n',
        )
        // Remove bold/italic markers
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'\1')
        .replaceAll(RegExp(r'__(.+?)__'), r'\1')
        .replaceAll(RegExp(r'_(.+?)_'), r'\1')
        // Remove horizontal rules
        .replaceAll(RegExp(r'^-{3,}$', multiLine: true), '\n')
        // Clean up extra newlines
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
