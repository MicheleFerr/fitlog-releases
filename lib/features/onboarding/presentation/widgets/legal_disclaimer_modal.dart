import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal dialog that displays medical disclaimer and liability limitations.
///
/// MUST be shown during onboarding before user can access app features.
/// Cannot be dismissed by tapping outside (barrierDismissible: false).
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => LegalDisclaimerModal(
///     onAccept: () {
///       // Save consent timestamp
///       Navigator.pop(context);
///     },
///   ),
/// );
/// ```
class LegalDisclaimerModal extends StatelessWidget {
  const LegalDisclaimerModal({
    super.key,
    required this.onAccept,
    this.onDecline,
  });

  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.warningAmberRounded,
            semanticLabel: context.l10n.legalDisclaimerTitle,
            size: AppIconSize.xlarge,
            color: context.iconError,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.legalDisclaimerTitle,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.legalDisclaimerContent,
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            // Privacy Policy and ToS links
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Open Privacy Policy (Task 7)
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // TODO: Open Terms of Service (Task 7)
                  },
                  child: Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        if (onDecline != null)
          TextButton(
            onPressed: onDecline,
            child: Text(
              context.l10n.legalDisclaimerDecline,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        FilledButton(
          onPressed: onAccept,
          child: Text(context.l10n.legalDisclaimerAccept),
        ),
      ],
    );
  }
}
