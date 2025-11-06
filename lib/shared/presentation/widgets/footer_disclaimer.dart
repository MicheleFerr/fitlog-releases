import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/legal_disclaimer_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Footer disclaimer shown at bottom of workout-related screens.
///
/// Provides constant reminder of liability limitations.
/// Tapping opens full disclaimer modal.
///
/// Usage:
/// ```dart
/// Column(
///   children: [
///     // Main content
///     Spacer(),
///     FooterDisclaimer(),
///   ],
/// );
/// ```
class FooterDisclaimer extends StatelessWidget {
  const FooterDisclaimer({super.key});

  void _showFullDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LegalDisclaimerModal(
        onAccept: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFullDisclaimer(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border(
            top: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.warning,
                  size: 14, // Smaller than tiny for ultra-compact footer
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.l10n.footerDisclaimerShort,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.footerDisclaimerTapHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary.withValues(alpha: 0.7),
                fontSize: 10,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
