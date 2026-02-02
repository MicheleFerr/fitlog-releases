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

  /// Privacy Policy URLs
  static const String privacyPolicyIt = '$baseUrl/privacy-it.html';
  static const String privacyPolicyEn = '$baseUrl/privacy-en.html';

  /// Terms of Service URLs
  static const String termsOfServiceIt = '$baseUrl/terms-it.html';
  static const String termsOfServiceEn = '$baseUrl/terms-en.html';

  /// Local asset paths (fallback when offline)
  static const String privacyPolicyItLocal = 'docs/legal/PRIVACY_POLICY_IT.md';
  static const String privacyPolicyEnLocal = 'docs/legal/PRIVACY_POLICY_EN.md';
  static const String termsOfServiceItLocal =
      'docs/legal/TERMS_OF_SERVICE_IT.md';
  static const String termsOfServiceEnLocal =
      'docs/legal/TERMS_OF_SERVICE_EN.md';

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
/// Attempts to load from web URL first (in-app WebView),
/// falls back to local assets if offline.
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
  static void showPrivacyPolicy(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isItalian = locale.languageCode == 'it';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: context.l10n.privacyPolicy,
          webUrl: isItalian
              ? LegalDocumentsConfig.privacyPolicyIt
              : LegalDocumentsConfig.privacyPolicyEn,
          localAssetPath: isItalian
              ? LegalDocumentsConfig.privacyPolicyItLocal
              : LegalDocumentsConfig.privacyPolicyEnLocal,
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
          webUrl: isItalian
              ? LegalDocumentsConfig.termsOfServiceIt
              : LegalDocumentsConfig.termsOfServiceEn,
          localAssetPath: isItalian
              ? LegalDocumentsConfig.termsOfServiceItLocal
              : LegalDocumentsConfig.termsOfServiceEnLocal,
        ),
      ),
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

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  bool _isLoading = true;
  bool _showingLocalFallback = false;
  String? _localContent;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tryOpenWebView();
  }

  Future<void> _tryOpenWebView() async {
    try {
      final uri = Uri.parse(widget.webUrl);

      // Try to launch in-app WebView
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );

      if (launched && mounted) {
        // WebView opened successfully, pop this screen
        // The WebView handles everything
        Navigator.of(context).pop();
      } else {
        // Couldn't open WebView, fall back to local
        await _loadLocalFallback();
      }
    } catch (e) {
      // Network error or other issue, fall back to local
      await _loadLocalFallback();
    }
  }

  Future<void> _loadLocalFallback() async {
    if (!mounted) return;

    setState(() {
      _showingLocalFallback = true;
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
          if (_showingLocalFallback)
            IconButton(
              icon: const Icon(AppIcons.refresh),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _showingLocalFallback = false;
                  _localContent = null;
                  _errorMessage = null;
                });
                _tryOpenWebView();
              },
              tooltip: context.l10n.retry,
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
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _tryOpenWebView();
                },
                icon: const Icon(AppIcons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_localContent != null) {
      return Column(
        children: [
          // Offline banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.colors.tertiaryContainer,
            child: Row(
              children: [
                Icon(
                  AppIcons.cloudOff,
                  size: 16,
                  color: context.colors.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.offlineMode,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                _localContent!,
                style: context.textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
