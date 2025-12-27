import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/consent_type.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// GDPR Consent Dialog
///
/// Presents users with granular consent options according to GDPR Art. 7
/// - Clear consent language (non-technical)
/// - Granular opt-in (not bundled)
/// - Easy to withdraw consent
/// - Links to privacy policy
class ConsentDialog extends StatefulWidget {
  const ConsentDialog({super.key});

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  final Map<ConsentType, bool> _consents = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConsents();
  }

  Future<void> _loadCurrentConsents() async {
    final granted = await PrivacyManager.getGrantedConsents();
    setState(() {
      for (final type in ConsentType.values) {
        _consents[type] = granted.contains(type);
      }
    });
  }

  Future<void> _saveConsents() async {
    setState(() => _isLoading = true);

    try {
      final granted = _consents.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet();

      await PrivacyManager.saveConsents(granted);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Privacy & Data Usage',
        style: context.textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We respect your privacy. Choose which data you want to share with us.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ...ConsentType.values.map((type) => _buildConsentTile(type)),
            const SizedBox(height: 16),
            _buildPrivacyPolicyLink(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveConsents,
          child: _isLoading
              ? LoadingIndicator(
                  size: 16,
                  color: context.colors.onPrimary,
                )
              : const Text('Save Preferences'),
        ),
      ],
    );
  }

  Widget _buildConsentTile(ConsentType type) {
    final isGranted = _consents[type] ?? type.isRequired;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (type.isRequired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Required',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isGranted,
                onChanged: type.isRequired
                    ? null
                    : (value) {
                        setState(() {
                          _consents[type] = value;
                        });
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyLink() {
    return InkWell(
      onTap: () {
        // TODO: Open privacy policy URL
        // Launch URL to privacy policy
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SemanticIcon(
  icon: AppIcons.policyOutlined,
  semanticLabel: 'Policy outlined',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
            const SizedBox(width: 8),
            Text(
              'Read our Privacy Policy',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the consent dialog
///
/// Returns true if user saved preferences, false if cancelled
Future<bool> showConsentDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Must make a choice
    builder: (context) => const ConsentDialog(),
  );

  return result ?? false;
}
