import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/cn_switch_list_tile.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/database_manager_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/audio_debug_test_screen.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/screens/tier_limits_test_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';

/// Displays user account info and admin controls in the settings screen.
class SettingsUserInfoSection extends ConsumerWidget {
  const SettingsUserInfoSection({
    super.key,
    required this.currentUser,
  });

  final AsyncValue<dynamic> currentUser;

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
                  icon: AppIcons.person,
                  semanticLabel: 'Account',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.account,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            currentUser.when(
              data: (user) => user != null
                  ? _buildUserDetails(context, ref, user)
                  : Text(context.l10n.settingsNotLoggedIn),
              loading: () => Text(context.l10n.settingsLoading),
              error: (_, __) => Text(context.l10n.settingsErrorLoadingUser),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: user.photoURL != null
                  ? CachedNetworkImageProvider(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const SemanticIcon(
                      icon: AppIcons.person,
                      semanticLabel: 'Profile',
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? context.l10n.gymbroUser,
                    style: context.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email ?? context.l10n.settingsNoEmail,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Admin Section (admin only - protected by isAdminCachedProvider)
        if (ref.watch(isAdminCachedProvider)) ...[
          const SizedBox(height: 12),
          _buildAdminSection(context, ref),
        ],
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Admin Dashboard Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.pushNamed('admin'),
            icon: const SemanticIcon(
              icon: AppIcons.admin,
              semanticLabel: 'Admin',
            ),
            label: Text(context.l10n.adminDashboard),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Database Manager Button (Direct Access)
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DatabaseManagerScreen(),
                ),
              );
            },
            icon: const SemanticIcon(
              icon: AppIcons.storage,
              semanticLabel: 'Storage',
            ),
            label: Text(context.l10n.databaseManager),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Audio Debug Tests
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AudioDebugTestScreen(),
                ),
              );
            },
            icon: const SemanticIcon(
              icon: AppIcons.bugReport,
              semanticLabel: 'Audio Debug',
            ),
            label: Text(context.l10n.audioDebugTests),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.warning,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tier Limits Test
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TierLimitsTestScreen(),
                ),
              );
            },
            icon: const SemanticIcon(
              icon: AppIcons.trophy,
              semanticLabel: 'Tier Limits Test',
            ),
            label: Text(context.l10n.tierLimitsTest),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // TEST: Reset Exercise Database
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final actions = ref.read(exerciseSyncActionsProvider);
              SnackBarService.showInfo(
                context,
                '🧪 Resetting exercise database...',
              );
              await actions.resetForTesting();
              if (context.mounted) {
                SnackBarService.showInfo(
                  context,
                  '🧪 Forcing re-sync...',
                );
              }
              await actions.forceSync();
              if (context.mounted) {
                SnackBarService.showSuccess(
                  context,
                  '✅ Reset & sync complete!',
                );
              }
            },
            icon: const SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: 'Reset',
            ),
            label: const Text('🧪 Reset Exercise DB'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.warning,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        _buildAdminPremiumToggle(context, ref),
      ],
    );
  }

  Widget _buildAdminPremiumToggle(BuildContext context, WidgetRef ref) {
    // FIX: Read from userProfileProvider (stream with data), not notifier (may be loading)
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;
    final accountTier = profile?.accountTier ?? AccountTier.free;
    final isPremium = accountTier != AccountTier.free;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.admin,
                semanticLabel: context.l10n.adminPremiumToggle,
                size: AppIconSize.small,
                color: context.colors.tertiary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.adminPremiumToggle,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CNSwitchListTile(
            title: Text(context.l10n.adminPremiumStatus),
            subtitle: Text(
              isPremium
                  ? context.l10n.adminPremiumActive(accountTier.name)
                  : context.l10n.adminPremiumInactive,
            ),
            value: isPremium,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) async {
              final newTier = value ? AccountTier.premium : AccountTier.free;
              await ref
                  .read(userProfileNotifierProvider.notifier)
                  .upgradeTier(newTier);

              if (context.mounted) {
                SnackBarService.showSuccess(
                  context,
                  value
                      ? context.l10n.adminPremiumEnabled
                      : context.l10n.adminPremiumDisabled,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
