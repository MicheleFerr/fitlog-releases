/// AI Coach Disclaimer Dialog
///
/// GDPR/Legal compliance dialog shown before first AI Coach use.
/// Informs users that AI Coach is NOT a medical professional.
///
/// **Layer**: Presentation - Widget
/// **Feature**: AI Coach
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing disclaimer acceptance in SharedPreferences
const String _disclaimerAcceptedKey = 'ai_coach_disclaimer_accepted_v1';

/// AI Coach disclaimer dialog widget
///
/// Shows a legal disclaimer explaining AI Coach limitations.
/// Must be accepted before using AI Coach chat.
class AICoachDisclaimerDialog extends StatelessWidget {
  const AICoachDisclaimerDialog({super.key});

  /// Check if user has already accepted the disclaimer
  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerAcceptedKey) ?? false;
  }

  /// Mark disclaimer as accepted
  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerAcceptedKey, true);
  }

  /// Show dialog and return true if accepted, false if cancelled
  static Future<bool> show(BuildContext context) async {
    // Check if already accepted
    if (await hasAccepted()) {
      return true;
    }

    // Show dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AICoachDisclaimerDialog(),
    );

    // Save acceptance if confirmed
    if (result == true) {
      await markAccepted();
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppIcons.warning,
              color: context.colors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.aiCoachDisclaimerTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtitle
            Text(
              context.l10n.aiCoachDisclaimerSubtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Bullet points - what AI Coach is NOT
            _DisclaimerPoint(
              icon: AppIcons.close,
              text: context.l10n.aiCoachDisclaimerNotTrainer,
              iconColor: context.colors.error,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DisclaimerPoint(
              icon: AppIcons.close,
              text: context.l10n.aiCoachDisclaimerNotDoctor,
              iconColor: context.colors.error,
            ),
            const SizedBox(height: AppSpacing.xs),
            _DisclaimerPoint(
              icon: AppIcons.close,
              text: context.l10n.aiCoachDisclaimerNoDiagnosis,
              iconColor: context.colors.error,
            ),

            const SizedBox(height: AppSpacing.md),

            // Warning box
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.info,
                    size: 18,
                    color: context.colors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      context.l10n.aiCoachDisclaimerConsultPro,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // May contain errors note
            Text(
              context.l10n.aiCoachDisclaimerMayContainErrors,
              style: context.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.aiCoachDisclaimerUnderstand),
        ),
      ],
    );
  }
}

/// Single disclaimer bullet point
class _DisclaimerPoint extends StatelessWidget {
  const _DisclaimerPoint({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
