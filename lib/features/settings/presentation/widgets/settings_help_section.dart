import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/data/services/consent_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/privacy/consent_dialog.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/screens/legal_document_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_shared_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Help & Info settings section: tutorials, help center, feedback, privacy,
/// licenses, exercise images credit, made-with-love footer.
class SettingsHelpSection extends ConsumerWidget {
  const SettingsHelpSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialsEnabled = ref.watch(tutorialsEnabledProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.help,
                  semanticLabel: context.l10n.settingsTutorialHelp,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsTutorialHelp,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contextual Tutorials Toggle
            buildSwitchTile(
              context,
              title: context.l10n.settingsContextualTutorials,
              subtitle: context.l10n.settingsContextualTutorialsDesc,
              value: tutorialsEnabled,
              onChanged: (value) {
                ref
                    .read(tutorialStateProvider.notifier)
                    .setTutorialsEnabled(value);
                SnackBarService.showSuccess(
                  context,
                  value
                      ? context.l10n.settingsTutorialsEnabled
                      : context.l10n.settingsTutorialsDisabled,
                );
              },
            ),

            const Divider(),

            // Help Center (AI Coach)
            buildSettingTile(
              context,
              title: context.l10n.helpCenter,
              subtitle: context.l10n.helpCenterDescription,
              leading: SemanticIcon(
                icon: AppIcons.help,
                semanticLabel: context.l10n.helpCenter,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              onTap: () => context.pushNamed('ai-coach'),
            ),

            const Divider(),

            // Beta Feedback
            buildSettingTile(
              context,
              title: context.l10n.betaFeedback,
              subtitle: context.l10n.betaFeedbackDesc,
              leading: SemanticIcon(
                icon: AppIcons.bugReport,
                semanticLabel: context.l10n.betaFeedback,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              onTap: () => _launchBetaFeedbackEmail(context),
            ),

            const Divider(),

            // Privacy Policy
            buildSettingTile(
              context,
              title: context.l10n.privacyPolicy,
              subtitle: context.l10n.privacyPolicyDesc,
              leading: const SemanticIcon(
                icon: AppIcons.shield,
                semanticLabel: 'Privacy',
              ),
              onTap: () => LegalDocumentScreen.showPrivacyPolicy(context),
            ),

            const Divider(),

            buildSettingTile(
              context,
              title: context.l10n.privacyDataUsageTitle,
              subtitle: context.l10n.privacyDataUsageDescription,
              leading: const SemanticIcon(
                icon: AppIcons.privacyTipRounded,
                semanticLabel: 'App privacy preferences',
              ),
              onTap: () => showConsentDialog(context),
            ),

            const Divider(),

            FutureBuilder<PrivacyOptionsRequirementStatus>(
              future: ConsentService().getPrivacyOptionsRequirementStatus(),
              builder: (context, snapshot) {
                final requirement = snapshot.data;
                final isRequired =
                    requirement == PrivacyOptionsRequirementStatus.required;
                final subtitle = isRequired
                    ? context.l10n.privacyOptionsDesc
                    : context.l10n.privacyOptionsUnavailableDesc;

                return buildSettingTile(
                  context,
                  title: context.l10n.privacyOptions,
                  subtitle: subtitle,
                  leading: const SemanticIcon(
                    icon: AppIcons.shield,
                    semanticLabel: 'Privacy options',
                  ),
                  trailing: snapshot.connectionState == ConnectionState.waiting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: () => _openPrivacyOptions(context, requirement),
                );
              },
            ),

            const Divider(),

            // Open Source Licenses
            buildSettingTile(
              context,
              title: context.l10n.openSourceLicenses,
              subtitle: context.l10n.openSourceLicensesDesc,
              leading: const SemanticIcon(
                icon: AppIcons.code,
                semanticLabel: 'Licenses',
              ),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'FitLog Pro',
                applicationLegalese: context.l10n.madeWithLove,
              ),
            ),

            const Divider(),

            // Exercise Images Credit (ExerciseDB)
            buildSettingTile(
              context,
              title: context.l10n.exerciseImagesCredit,
              subtitle: context.l10n.exerciseImagesCreditDesc,
              leading: const SemanticIcon(
                icon: AppIcons.workout,
                semanticLabel: 'Exercise images',
              ),
              onTap: () => _showExerciseDbAttributionDialog(context),
            ),

            const SizedBox(height: 16),

            // Made with love footer
            Center(
              child: Text(
                context.l10n.madeWithLove,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialogs ---

  Future<void> _openPrivacyOptions(
    BuildContext context,
    PrivacyOptionsRequirementStatus? requirement,
  ) async {
    final consentService = ConsentService();

    try {
      final resolvedRequirement =
          requirement ??
          await consentService.getPrivacyOptionsRequirementStatus();

      if (resolvedRequirement != PrivacyOptionsRequirementStatus.required) {
        if (context.mounted) {
          SnackBarService.showInfo(
            context,
            context.l10n.privacyOptionsUnavailableDesc,
          );
        }
        return;
      }

      await consentService.showPrivacyOptionsForm();

      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.privacyOptionsUpdated,
        );
      }
    } catch (_) {
      if (context.mounted) {
        SnackBarService.showError(context, context.l10n.privacyOptionsError);
      }
    }
  }

  void _showExerciseDbAttributionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.workout,
              semanticLabel: 'ExerciseDB',
              size: AppIconSize.medium,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(context.l10n.exerciseImagesCredit),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.exerciseDbAttribution,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.link,
                    semanticLabel: 'Link',
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'exercisedb.io',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _launchBetaFeedbackEmail(BuildContext context) async {
    final platform = Theme.of(context).platform;
    final l10n = context.l10n;
    final packageInfo = await PackageInfo.fromPlatform();
    final version = '${packageInfo.version}+${packageInfo.buildNumber}';
    final device = platform.name;
    final os = platform == TargetPlatform.iOS ? 'iOS' : 'Android';

    final subject = Uri.encodeComponent(l10n.betaFeedbackSubject);
    final body = Uri.encodeComponent(
      l10n.betaFeedbackBody(version, device, os),
    );

    final uri = Uri.parse(
      'mailto:michele.cozzolino93@gmail.com?subject=$subject&body=$body',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      SnackBarService.showError(context, 'Could not open email client');
    }
  }
}
