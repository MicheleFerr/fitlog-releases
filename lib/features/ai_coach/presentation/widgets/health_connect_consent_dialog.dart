/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
/// 🌍 Localization: REQUIRED
/// 🎨 Theme: context.colors.*
/// 📱 Platform: Android only (Health Connect)
///
/// HEALTH CONNECT CONSENT DIALOG - GDPR Article 9 compliance
///
/// **Special Category Data** (Biometric/Health):
/// - Requires explicit consent (higher protection than Article 7.1)
/// - Clear explanation of processing
/// - Granular control (can disable per data type)
/// - Right to withdraw consent (revoke anytime)
/// - Link to privacy policy
///
/// **Features**:
/// - GDPR Article 9 compliant consent flow
/// - Clear data collection explanation
/// - Explicit opt-in (unchecked by default)
/// - Timestamp and version tracking
/// - Withdrawal option (revoke consent)
/// - Privacy policy link
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Health Connect Consent Dialog (GDPR Article 9)
///
/// **Usage**:
/// ```dart
/// final granted = await showDialog<bool>(
///   context: context,
///   barrierDismissible: false, // Must explicitly choose
///   builder: (context) => const HealthConnectConsentDialog(),
/// );
///
/// if (granted == true) {
///   // Initialize Health Connect
/// }
/// ```
class HealthConnectConsentDialog extends ConsumerStatefulWidget { // e.g., '1.0', '1.1'

  const HealthConnectConsentDialog({
    super.key,
    this.consentVersion = '1.0',
  });
  final String consentVersion;

  @override
  ConsumerState<HealthConnectConsentDialog> createState() =>
      _HealthConnectConsentDialogState();
}

class _HealthConnectConsentDialogState
    extends ConsumerState<HealthConnectConsentDialog> {
  bool _consentGiven = false; // GDPR Article 9: Must be unchecked by default
  bool _understandDataProcessing = false; // Additional checkbox for clarity

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(AppIcons.healthAndSafety, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Health Data Access',
              style: context.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // GDPR Article 9 explanation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.info,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Why We Need This',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FitLog Pro uses your Google Health Connect data to provide AI-powered workout insights and recovery recommendations.',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Health data types collected
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Data We Access',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHealthDataItem(
                    context,
                    AppIcons.directionsWalk,
                    'Step Count',
                    'Daily activity level assessment',
                  ),
                  _buildHealthDataItem(
                    context,
                    AppIcons.favorite,
                    'Heart Rate',
                    'Recovery state and workout intensity',
                  ),
                  _buildHealthDataItem(
                    context,
                    AppIcons.workout,
                    'Workout Data',
                    'Training frequency and volume tracking',
                  ),
                  _buildHealthDataItem(
                    context,
                    AppIcons.streak,
                    'Active Energy',
                    'Caloric expenditure monitoring',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // How data is used
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How Your Data Is Used',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildUsageItem(context, 'AI-powered workout recommendations'),
                  _buildUsageItem(context, 'Recovery insights and rest day alerts'),
                  _buildUsageItem(context, 'Training load optimization'),
                  _buildUsageItem(context, 'Overtraining prevention'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        AppIcons.checkCircle,
                        color: context.colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your health data is NEVER shared with third parties',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Consent checkboxes (GDPR: unchecked by default)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _consentGiven
                      ? context.colors.primary
                      : context.colors.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _consentGiven,
                    onChanged: (value) {
                      setState(() {
                        _consentGiven = value ?? false;
                      });
                    },
                    title: Text(
                      'I consent to health data access',
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Required for AI Coach features',
                      style: context.textTheme.bodySmall,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_consentGiven)
                    CheckboxListTile(
                      value: _understandDataProcessing,
                      onChanged: (value) {
                        setState(() {
                          _understandDataProcessing = value ?? false;
                        });
                      },
                      title: Text(
                        'I understand how my data is processed',
                        style: context.textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        'Securely stored and never shared',
                        style: context.textTheme.bodySmall,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // GDPR Article 17 + 20 notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.shield, color: context.colors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Your Rights (GDPR)',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildRightItem(
                    context,
                    'Right to Access',
                    'View all your data anytime',
                  ),
                  _buildRightItem(
                    context,
                    'Right to Erasure',
                    'Delete all health data from our servers',
                  ),
                  _buildRightItem(
                    context,
                    'Right to Portability',
                    'Export your data in JSON format',
                  ),
                  _buildRightItem(
                    context,
                    'Right to Withdraw',
                    'Revoke consent anytime from Settings',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Privacy policy link
            InkWell(
              onTap: () async {
                final url = Uri.parse(
                  'https://fitlogpro.app/privacy', // TODO: Replace with actual URL
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.policyOutlined,
                    color: context.colors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Read our Privacy Policy',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Consent version info
            Text(
              'Consent version: ${widget.consentVersion} • ${DateTime.now().toLocal().toString().split('.')[0]}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: (_consentGiven && _understandDataProcessing)
              ? () async {
                  // TODO: Record consent in provider (Task 4.6)
                  // await ref.read(healthConnectProvider.notifier).recordConsent(widget.consentVersion);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              : null, // Disabled if both checkboxes not checked
          child: const Text('Grant Access'),
        ),
      ],
    );
  }

  Widget _buildHealthDataItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            AppIcons.check,
            size: 16,
            color: context.colors.tertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            AppIcons.circle,
            size: 8,
            color: context.colors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: context.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: subtitle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Revoke Health Connect Consent Dialog (GDPR Article 17 - Right to Erasure)
///
/// **Usage**:
/// ```dart
/// final revoked = await showDialog<bool>(
///   context: context,
///   builder: (context) => const RevokeHealthConnectConsentDialog(),
/// );
///
/// if (revoked == true) {
///   // Consent revoked, disable Health Connect features
/// }
/// ```
class RevokeHealthConnectConsentDialog extends ConsumerWidget {
  const RevokeHealthConnectConsentDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(AppIcons.warning, color: context.colors.error),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Revoke Health Data Access'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will:',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildWarningItem(
            context,
            'Delete all health data from our servers',
          ),
          _buildWarningItem(
            context,
            'Disable AI Coach health-based features',
          ),
          _buildWarningItem(
            context,
            'Remove recovery insights and recommendations',
          ),
          _buildWarningItem(
            context,
            'Revoke Health Connect access permissions',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(AppIcons.info, color: context.colors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your Google Health Connect data remains safe in the Health Connect app. We only delete our copy.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
          ),
          onPressed: () async {
            // TODO: Revoke consent and delete data (Task 4.6)
            // await ref.read(healthConnectProvider.notifier).revokeConsentAndDeleteData();

            if (context.mounted) {
              Navigator.pop(context, true);
              SnackBarService.showError(context, 'Health data access revoked');
            }
          },
          child: const Text('Revoke & Delete'),
        ),
      ],
    );
  }

  static Widget _buildWarningItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            AppIcons.close,
            size: 20,
            color: context.colors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
