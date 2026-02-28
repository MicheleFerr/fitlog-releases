import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_shared_helpers.dart';

/// Account actions section: sign out and delete account (GDPR Art. 17).
class SettingsAccountSection extends ConsumerWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.logout,
                  semanticLabel: 'Account actions',
                  size: AppIconSize.medium,
                  color: context.colors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsAccountActions,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sign Out
            buildSettingTile(
              context,
              title: context.l10n.settingsSignOut,
              subtitle: context.l10n.settingsSignOutDesc,
              leading: SemanticIcon(
                icon: AppIcons.logout,
                semanticLabel: 'Sign out',
                size: AppIconSize.medium,
                color: context.colors.error,
              ),
              onTap: () => _showSignOutDialog(context, ref),
            ),

            const Divider(),

            // Delete Account (GDPR Art. 17 - Right to Erasure)
            buildSettingTile(
              context,
              title: context.l10n.deleteAccount,
              subtitle: context.l10n.deleteAccountDesc,
              leading: SemanticIcon(
                icon: AppIcons.delete,
                semanticLabel: 'Delete account',
                size: AppIconSize.medium,
                color: context.colors.error,
              ),
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dialogs ---

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.signOutButton),
        content: Text(context.l10n.settingsSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.signOutButton),
          ),
        ],
      ),
    );
  }

  /// Show delete account confirmation dialog (GDPR Art. 17)
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.warning,
              semanticLabel: 'Warning',
              size: AppIconSize.medium,
              color: context.colors.error,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(context.l10n.deleteAccountTitle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.deleteAccountWarning,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.deleteAccountDataList,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${context.l10n.deleteAccountDataWorkouts}\n'
                    '• ${context.l10n.deleteAccountDataTemplates}\n'
                    '• ${context.l10n.deleteAccountDataPhotos}\n'
                    '• ${context.l10n.deleteAccountDataMeasurements}\n'
                    '• ${context.l10n.deleteAccountDataSettings}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.deleteAccountExportHint,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performAccountDeletion(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  /// Perform the actual account deletion
  Future<void> _performAccountDeletion(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Show loading dialog (intentionally not awaited - we dismiss it later)
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const LoadingIndicator(size: 24),
              const SizedBox(width: 16),
              Expanded(child: Text(context.l10n.deleteAccountProgress)),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .deleteAccount();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Account deleted successfully
        SnackBarService.showSuccess(context, context.l10n.deleteAccountSuccess);
        context.go('/login');
      } else {
        // Re-authentication required
        _showReauthenticationDialog(context, ref);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      SnackBarService.showError(context, context.l10n.deleteAccountError);
    }
  }

  /// Show re-authentication dialog when required for account deletion
  void _showReauthenticationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteAccountReauthTitle),
        content: Text(context.l10n.deleteAccountReauthMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Sign out and redirect to login for re-authentication
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                SnackBarService.showInfo(
                  context,
                  context.l10n.deleteAccountReauthHint,
                );
                context.go('/login');
              }
            },
            child: Text(context.l10n.settingsSignOut),
          ),
        ],
      ),
    );
  }
}
