import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/screens/legal_document_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Bottom sheet modal that displays medical disclaimer and liability limitations.
///
/// MUST be shown during onboarding before user can access app features.
/// Cannot be dismissed by swiping down (isDismissible: false).
///
/// Usage:
/// ```dart
/// LegalDisclaimerModal.show(
///   context: context,
///   onAccept: () {
///     // Save consent timestamp
///   },
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

  /// Shows the legal disclaimer as a bottom sheet modal
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onAccept,
    VoidCallback? onDecline,
  }) {
    return ModalService.showSheet<void>(context,
      isScrollControlled: true,
      isDismissible: false, // Cannot dismiss without accepting
      enableDrag: false, // Cannot swipe to close
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) =>
          LegalDisclaimerModal(onAccept: onAccept, onDecline: onDecline),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar (decorative only - can't drag to close)
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with warning icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SemanticIcon(
                  icon: AppIcons.warningAmberRounded,
                  semanticLabel: context.l10n.legalDisclaimerTitle,
                  size: AppIconSize.large,
                  color: context.iconError,
                ),
              ),
              const SizedBox(width: 12),
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

          const SizedBox(height: 16),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.legalDisclaimerContent,
                    style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  // Privacy Policy and ToS links
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          LegalDocumentScreen.showPrivacyPolicy(context);
                        },
                        icon: SemanticIcon(
                          icon: AppIcons.privacyTipRounded,
                          semanticLabel: context.l10n.privacyPolicy,
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        ),
                        label: Text(
                          context.l10n.privacyPolicy,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          LegalDocumentScreen.showTermsOfService(context);
                        },
                        icon: SemanticIcon(
                          icon: AppIcons.document,
                          semanticLabel: context.l10n.termsOfService,
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        ),
                        label: Text(
                          context.l10n.termsOfService,
                          style: context.textTheme.bodyMedium?.copyWith(
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
          ),

          const SizedBox(height: 16),

          // Action buttons
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onAccept();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(context.l10n.legalDisclaimerAccept),
          ),

          if (onDecline != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                onDecline!();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: context.colors.error,
              ),
              child: Text(context.l10n.legalDisclaimerDecline),
            ),
          ],

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
