import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Configuration for legal document URLs
///
/// Change these URLs when hosting on your domain
class LegalDocumentsConfig {
  LegalDocumentsConfig._();

  /// Base URL for legal documents (your domain)
  static const String baseUrl = 'https://fitlogpro.it/legal';

  /// Apple standard Terms of Use (EULA) URL.
  static const String appleStandardEula =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  /// Privacy Policy URLs.
  static const String privacyPolicyIt = '$baseUrl/privacy-it.html';
  static const String privacyPolicyEn = '$baseUrl/privacy-en.html';

  /// Terms of Service URLs.
  static const String termsOfServiceIt = '$baseUrl/terms-it.html';
  static const String termsOfServiceEn = '$baseUrl/terms-en.html';

  /// Local asset paths (fallback when offline)
  static const String privacyPolicyItLocal = 'assets/legal/privacy_policy.md';
  static const String privacyPolicyEnLocal = 'assets/legal/privacy_policy.md';
  static const String termsOfServiceItLocal =
      'assets/legal/terms_of_service.md';
  static const String termsOfServiceEnLocal =
      'assets/legal/terms_of_service.md';

  /// Coach Agreement URLs
  static const String coachAgreementIt = '$baseUrl/coach-agreement-it.html';
  static const String coachAgreementEn = '$baseUrl/coach-agreement-en.html';

  /// Coach Agreement local paths
  static const String coachAgreementItLocal =
      'docs/legal/COACH_AGREEMENT_IT.md';
  static const String coachAgreementEnLocal =
      'docs/legal/COACH_AGREEMENT_EN.md';
}

/// Screen to display legal documents (Privacy Policy, Terms of Service)
///
/// Loads the bundled document for guaranteed in-app availability and lets the
/// user open the hosted version when needed.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.webUrl,
    required this.localAssetPath,
  });

  final String title;
  final String webUrl;
  final String localAssetPath;

  /// Show Privacy Policy based on current locale
  static Future<void> showPrivacyPolicy(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    final isItalian = locale.languageCode == 'it';

    await _openHostedDocument(
      context,
      title: context.l10n.privacyPolicy,
      webUrl: isItalian
          ? LegalDocumentsConfig.privacyPolicyIt
          : LegalDocumentsConfig.privacyPolicyEn,
      localAssetPath: isItalian
          ? LegalDocumentsConfig.privacyPolicyItLocal
          : LegalDocumentsConfig.privacyPolicyEnLocal,
    );
  }

  /// Show Terms of Service based on current locale
  static Future<void> showTermsOfService(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    final isItalian = locale.languageCode == 'it';

    await _openHostedDocument(
      context,
      title: context.l10n.termsOfService,
      webUrl: isItalian
          ? LegalDocumentsConfig.termsOfServiceIt
          : LegalDocumentsConfig.termsOfServiceEn,
      localAssetPath: isItalian
          ? LegalDocumentsConfig.termsOfServiceItLocal
          : LegalDocumentsConfig.termsOfServiceEnLocal,
    );
  }

  /// Show the Apple standard Terms of Use (EULA).
  static Future<void> showAppleStandardEula(BuildContext context) async {
    await _openWebDocument(
      context,
      url: LegalDocumentsConfig.appleStandardEula,
    );
  }

  /// Show Coach Agreement based on current locale
  static void showCoachAgreement(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isItalian = locale.languageCode == 'it';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: context.l10n.coachAgreement,
          webUrl: isItalian
              ? LegalDocumentsConfig.coachAgreementIt
              : LegalDocumentsConfig.coachAgreementEn,
          localAssetPath: isItalian
              ? LegalDocumentsConfig.coachAgreementItLocal
              : LegalDocumentsConfig.coachAgreementEnLocal,
        ),
      ),
    );
  }

  static Future<void> _openHostedDocument(
    BuildContext context, {
    required String title,
    required String webUrl,
    required String localAssetPath,
  }) async {
    try {
      final launched = await launchUrl(
        Uri.parse(webUrl),
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      if (launched || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: title,
          webUrl: webUrl,
          localAssetPath: localAssetPath,
        ),
      ),
    );
  }

  static Future<void> _openWebDocument(
    BuildContext context, {
    required String url,
  }) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      if (launched || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open document link')),
      );
    }
  }

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  bool _isLoading = true;
  String? _localContent;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocalDocument();
  }

  Future<void> _openOnlineVersion() async {
    try {
      final uri = Uri.parse(widget.webUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      if (!launched) {
        _showOpenLinkError();
      }
    } catch (e) {
      _showOpenLinkError();
    }
  }

  void _showOpenLinkError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open document link')),
    );
  }

  Future<void> _loadLocalDocument() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _localContent = null;
      _errorMessage = null;
    });

    try {
      final content = await rootBundle.loadString(widget.localAssetPath);
      if (mounted) {
        setState(() {
          _localContent = _cleanMarkdown(content);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load document';
          _isLoading = false;
        });
      }
    }
  }

  /// Simple markdown cleaning for readability
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.openInNew),
            onPressed: _openOnlineVersion,
            tooltip: context.l10n.open,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.cloudOff, size: 48, color: context.colors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Accessibility: Retry button with semantic label
              Semantics(
                label: context.l10n.retry,
                button: true,
                child: FilledButton.icon(
                  onPressed: () {
                    _loadLocalDocument();
                  },
                  icon: const Icon(AppIcons.refresh),
                  label: Text(context.l10n.retry),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_localContent != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SelectableText(
          _localContent!,
          style: context.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
