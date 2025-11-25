/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/presentation/widgets
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: widget
/// 🌍 Localization: REQUIRED
/// 🎨 Theme: context.colors.*
/// 📱 Platform: Universal
///
/// PRIVACY CONSENT DIALOG - GDPR Article 7.1 compliance
///
/// **Features**:
/// - Clear explanation of data collection
/// - Explicit opt-in (unchecked by default)
/// - Timestamp and version tracking
/// - Withdrawal option (revoke consent)
/// - Data retention period selection
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/notifications/presentation/providers/notification_settings_provider_v2.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Privacy Consent Dialog (GDPR Article 7.1)
///
/// **Usage**:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => const PrivacyConsentDialog(),
/// );
/// ```
class PrivacyConsentDialog extends ConsumerStatefulWidget { // e.g., '1.0', '1.1', '2.0'

  const PrivacyConsentDialog({
    super.key,
    this.consentVersion = '2.0',
  });
  final String consentVersion;

  @override
  ConsumerState<PrivacyConsentDialog> createState() =>
      _PrivacyConsentDialogState();
}

class _PrivacyConsentDialogState extends ConsumerState<PrivacyConsentDialog> {
  bool _consentGiven = false; // GDPR: Must be unchecked by default
  bool _analyticsEnabled = false;
  int _retentionDays = 90;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(AppIcons.privacyTipRounded, color: context.colors.primary),
          const SizedBox(width: 12),
          Text(
            'Privacy & Consent',
            style: context.textTheme.titleLarge,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // GDPR Article 7.1 explanation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data We Collect',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildDataItem('Notification delivery times'),
                  _buildDataItem('Notification types (workout/recovery/streak)'),
                  _buildDataItem('Read/unread status'),
                  _buildDataItem('User preferences (quiet hours, frequency caps)'),
                  const SizedBox(height: 12),
                  Text(
                    'Purpose',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Cross-device sync (access settings from any device)\n'
                    '• Analytics (improve notification relevance)\n'
                    '• History (view past notifications)',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Consent checkbox (GDPR: unchecked by default)
            CheckboxListTile(
              value: _consentGiven,
              onChanged: (value) {
                setState(() {
                  _consentGiven = value ?? false;
                });
              },
              title: Text(
                'I consent to data collection',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Required for cross-device sync and history',
                style: context.textTheme.bodySmall,
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // Analytics opt-in (separate from consent)
            if (_consentGiven) ...[
              CheckboxListTile(
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() {
                    _analyticsEnabled = value ?? false;
                  });
                },
                title: const Text('Enable analytics'),
                subtitle: Text(
                  'Help improve notification relevance',
                  style: context.textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              // Data retention period
              ListTile(
                title: const Text('Data retention period'),
                subtitle: Text('$_retentionDays days'),
                trailing: DropdownButton<int>(
                  value: _retentionDays,
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 days')),
                    DropdownMenuItem(value: 90, child: Text('90 days')),
                    DropdownMenuItem(value: 180, child: Text('180 days')),
                    DropdownMenuItem(value: 365, child: Text('1 year')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _retentionDays = value ?? 90;
                    });
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // GDPR Article 17 notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.info, color: context.colors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Right to Erasure: You can delete all data anytime from Settings > Advanced > Delete All Data',
                      style: context.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Consent version info
            Text(
              'Consent version: ${widget.consentVersion} • ${DateTime.now().toLocal()}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.5),
              ),
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
          onPressed: _consentGiven
              ? () async {
                  // Record consent (GDPR Article 7.1)
                  await ref
                      .read(notificationSettingsV2Provider.notifier)
                      .recordConsent(widget.consentVersion);

                  // Update analytics and retention settings
                  final settings =
                      ref.read(notificationSettingsV2Provider).value;
                  if (settings != null) {
                    final updated = settings.copyWith(
                      enableAnalytics: _analyticsEnabled,
                      dataRetentionDays: _retentionDays,
                    );
                    await ref
                        .read(notificationSettingsV2Provider.notifier)
                        .updateSettings(updated);
                  }

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              : null, // Disabled if consent not given
          child: const Text('Accept'),
        ),
      ],
    );
  }

  Widget _buildDataItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            AppIcons.checkCircle,
            size: 16,
            color: context.colors.primary,
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
}

/// Revoke Consent Dialog (GDPR Article 17 - Right to Erasure)
class RevokeConsentDialog extends ConsumerWidget {
  const RevokeConsentDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(AppIcons.warning, color: context.colors.error),
          const SizedBox(width: 12),
          const Text('Revoke Consent'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will:',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildWarningItem(context, 'Delete all notification data from cloud'),
          _buildWarningItem(context, 'Delete all local notification history'),
          _buildWarningItem(context, 'Cancel all scheduled notifications'),
          _buildWarningItem(
              context, 'Disable cross-device sync permanently'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '⚠️ This action CANNOT be undone!',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.error,
              ),
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
          ),
          onPressed: () async {
            await ref
                .read(notificationSettingsV2Provider.notifier)
                .revokeConsentAndDeleteData();

            if (context.mounted) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notification data deleted'),
                  backgroundColor: context.colors.error,
                ),
              );
            }
          },
          child: const Text('Revoke & Delete All'),
        ),
      ],
    );
  }

  Widget _buildWarningItem(BuildContext context, String text) {
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
