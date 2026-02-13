import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen showing attribution, licensing, and legal information for AI Coach Documents
///
/// Required for CC-BY compliance and GDPR transparency
class DocumentsAttributionScreen extends ConsumerWidget {
  const DocumentsAttributionScreen({super.key});

  static const routePath = '/ai-coach/documents/attribution';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scientificSources),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + context.tabBarInset,
        ),
        children: [
          _buildSection(
            context,
            icon: Icons.science,
            title: 'Evidence-Based Training',
            content: 'FitLog AI Coach uses scientifically validated papers '
                'to provide evidence-based training advice. All recommendations '
                'are backed by peer-reviewed research from leading journals.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            icon: Icons.lock_open,
            title: 'Open Access Sources',
            content: 'All papers used are open access with Creative Commons '
                'licenses (CC-BY or CC-BY-NC-ND). Abstracts are provided '
                'under fair use for educational purposes.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            icon: Icons.link,
            title: 'Direct Links',
            content: 'Each paper includes a direct link to the original '
                'publisher (DOI link). You can access the full paper for free '
                'from the source.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            icon: Icons.format_quote,
            title: 'Proper Attribution',
            content: 'Every recommendation includes proper citation with '
                'authors, year, title, and license information as required '
                'by Creative Commons licenses.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            icon: Icons.privacy_tip,
            title: 'Your Privacy',
            content: 'Document synchronization is completely anonymous. '
                'No personal data is collected, tracked, or shared. '
                'All documents are cached locally on your device.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            icon: Icons.gavel,
            title: 'Legal Disclaimer',
            content: 'Information provided by AI Coach is for educational '
                'purposes only and should not replace professional medical '
                'or training advice. Always consult qualified professionals '
                'for personalized guidance.',
            isWarning: true,
          ),
          const SizedBox(height: 24),
          _buildLicenseInfo(context),
          const SizedBox(height: 24),
          _buildContactSection(context),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isWarning
                      ? context.colors.warning
                      : context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfo(BuildContext context) {
    return Card(
      color: context.colors.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.copyright,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Creative Commons Licenses',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLicenseRow(
              context,
              'CC-BY',
              'Attribution required. Free to use and share.',
            ),
            _buildLicenseRow(
              context,
              'CC-BY-NC-ND',
              'Non-commercial use only. No modifications.',
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _launchUrl('https://creativecommons.org/licenses/'),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Learn more about CC licenses'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseRow(BuildContext context, String license, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              license,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions or Concerns?',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If you have questions about our scientific sources, '
              'licensing, or data handling practices, please contact us.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _launchUrl('mailto:support@fitlogpro.it'),
              icon: const Icon(Icons.email, size: 16),
              label: const Text('support@fitlogpro.it'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
