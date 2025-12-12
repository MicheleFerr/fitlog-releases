/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: settings
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Legal document viewer for Privacy Policy and Terms of Service
library;

import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class LegalDocumentScreen extends ConsumerStatefulWidget { // 'privacy' or 'terms'
  
  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });
  final String documentType;

  @override
  ConsumerState<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends ConsumerState<LegalDocumentScreen> {
  String _documentContent = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadDocument();
  }
  
  Future<void> _loadDocument() async {
    try {
      final String fileName = widget.documentType == 'privacy'
          ? 'assets/legal/privacy_policy.md'
          : 'assets/legal/terms_of_service.md';

      // Load from assets
      final String content = await rootBundle.loadString(fileName);

      // 🔧 MEMORY LEAK FIX: Check mounted before setState after async operation
      if (!mounted) return;

      setState(() {
        _documentContent = content;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to formatted content if asset loading fails
      // 🔧 MEMORY LEAK FIX: Check mounted before setState after async operation
      if (!mounted) return;

      setState(() {
        _documentContent = _getFormattedContent();
        _isLoading = false;
      });
    }
  }
  
  String _getFormattedContent() {
    if (widget.documentType == 'privacy') {
      return '''
# Privacy Policy

**Last Updated: January 21, 2025**

## Your Privacy Matters

GymBro TrackLog respects your privacy and is committed to protecting your personal data.

## What We Collect

### Information You Provide
• Email address and display name
• Workout data (exercises, sets, reps, weights)
• App preferences and settings
• Profile photo (optional)

### What We DON'T Collect
• Location data
• Health data from other apps
• Contacts or address book
• Camera roll photos
• Microphone recordings

## How We Use Your Data

• **Service Provision**: To provide workout tracking
• **Cloud Sync**: Sync across devices (Premium only)
• **Backup**: Automatic backups (Premium only)
• **Improvements**: Anonymous analytics

## Data Security

• End-to-end encryption
• Secure HTTPS connections
• Firebase Security Rules
• Regular security audits
• GDPR compliant

## Your Rights

• **Access**: Request your data
• **Correction**: Fix inaccurate data
• **Deletion**: Delete your account
• **Export**: Download your data
• **Restriction**: Limit data usage

## Third Parties

We use:
• Firebase (Google) for authentication
• App Store/Play Store for payments
• Crashlytics for error reporting

We NEVER share data with:
• Advertisers
• Data brokers
• Marketing companies

## Children's Privacy

GymBro is not for children under 13 (16 in EU).

## Contact Us

**Privacy Questions**: privacy@gymbro.app
**Developer**: Michele Cozzolino
**Response Time**: 24-48 hours

## Updates

We'll notify you of any material changes via in-app notification.

---
Version 1.0.0 | GDPR Compliant
''';
    } else {
      return '''
# Terms of Service

**Last Updated: January 21, 2025**

## Agreement to Terms

By using GymBro TrackLog, you agree to these Terms of Service.

## Use of Service

### Eligibility
• You must be at least 13 years old (16 in EU)
• You must provide accurate information
• One person per account

### Acceptable Use
✅ Personal fitness tracking
✅ Creating workout routines
✅ Tracking progress
✅ Sharing workouts (Premium)

### Prohibited Uses
❌ Illegal activities
❌ Hacking or reverse engineering
❌ Scraping user data
❌ Impersonation
❌ Malicious content

## Subscriptions

### Free Tier
• Basic workout tracking
• Local storage only
• Limited templates

### Premium Features
• Cloud sync
• Automatic backups
• Advanced analytics
• Community features
• Priority support

### Billing
• Processed by App Store/Play Store
• Auto-renews unless cancelled
• Cancel anytime

## Your Content

• You own your workout data
• We need permission to store/process it
• You're responsible for accuracy
• We may delete violating content

## Health Disclaimer

⚠️ **IMPORTANT**:
• GymBro is NOT medical advice
• Consult doctors before exercising
• We're not responsible for injuries
• Stop if you feel pain

## Liability Limits

• Service provided "AS IS"
• No warranty of any kind
• Maximum liability: €100 or fees paid
• No liability for injuries

## Privacy

Your privacy is protected by our Privacy Policy.

## Termination

### By You
• Delete account anytime
• Cancel subscription in Store
• Data deleted after 30 days

### By Us
• For Terms violations
• For illegal activities
• For non-payment

## Contact

**Legal Questions**: legal@gymbro.app
**Support**: support@gymbro.app
**Developer**: Michele Cozzolino

## Governing Law

These Terms are governed by EU and Italian law.

---
Version 1.0.0 | EU Compliant
''';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final String title = widget.documentType == 'privacy' 
        ? 'Privacy Policy'
        : 'Terms of Service';
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.arrowBackIosNew),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.share),
            onPressed: () => _shareDocument(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.05),
                        colorScheme.surface,
                      ],
                    ),
                  ),
                ),
                
                // Content
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surface.withValues(alpha: 0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildFormattedContent(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildFormattedContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lines = _documentContent.split('\n');
    final List<Widget> widgets = [];
    
    for (final line in lines) {
      if (line.startsWith('# ')) {
        // Main title
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Text(
              line.substring(2),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Section title
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 24),
            child: Text(
              line.substring(3),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // Subsection title
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 16),
            child: Text(
              line.substring(4),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        );
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold text
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.substring(2, line.length - 2),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ')) {
        // Bullet point
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: theme.textTheme.bodyLarge),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('✅ ') || line.startsWith('❌ ')) {
        // Checkmark or X items
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.substring(0, 2), style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('⚠️ ')) {
        // Warning
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.warning.withValues(alpha: 0.1),
              border: Border.all(color: context.colors.warning.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line.substring(3),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('---')) {
        // Divider
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
        );
      } else if (line.trim().isNotEmpty) {
        // Regular text
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              line,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  void _shareDocument() {
    // Implement sharing functionality
    // You can use share_plus package
    final String title = widget.documentType == 'privacy' 
        ? 'GymBro Privacy Policy'
        : 'GymBro Terms of Service';
    
    final String url = widget.documentType == 'privacy'
        ? 'https://gymbro.app/privacy'
        : 'https://gymbro.app/terms';
    
    // Share.share('$title\n$url');
  }
}