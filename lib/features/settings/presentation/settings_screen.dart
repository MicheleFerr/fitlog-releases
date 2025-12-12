import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/config/feature_flags.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/database_manager_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/migration_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/registry/tutorial_registry.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final currentUser = ref.watch(firebaseUserProvider);
    final l10n = context.l10n;

    // Auto-load fitness profile when user is authenticated
    ref.watch(fitnessProfileAutoLoadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: context.colors.surfaceContainerHighest,
        leading: IconButton(
          icon: const SemanticIcon(
  icon: AppIcons.back,
  semanticLabel: 'Back',
),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DISABLED: Fitness Benchmark Hero Card
            // Reason: GDPR compliance - medical questionnaire data
            // Date: 2025-01-21
            // _buildFitnessBenchmarkCard(context, ref),
            // const SizedBox(height: 24),

            // User Info Section
            _buildUserInfoSection(context, ref, currentUser),
            const SizedBox(height: 24),

            // DISABLED: Fitness Profile Section
            // Reason: GDPR compliance - medical questionnaire data
            // Date: 2025-01-21
            // _buildFitnessProfileSection(context, ref),
            // const SizedBox(height: 24),

            // Appearance Settings
            _buildAppearanceSection(context, ref, config),
            const SizedBox(height: 24),

            // Workout Essentials (NEW)
            _buildWorkoutEssentialsSection(context, ref, config),
            const SizedBox(height: 24),

            // Data & Backup
            _buildDataBackupSection(context),
            const SizedBox(height: 24),

            // Health Sync (Apple Health / Health Connect)
            _buildHealthSyncSection(context),
            const SizedBox(height: 24),

            // Units & Language
            _buildUnitsLanguageSection(context, ref, config),
            const SizedBox(height: 24),

            // Tutorial & Help
            _buildTutorialHelpSection(context, ref),
            const SizedBox(height: 24),

            // Account Actions
            _buildAccountSection(context, ref),

            // DEBUG: Migration tool (ferrara-michele only)
            if (currentUser.value?.email?.toString().contains('ferrara-michele') == true)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: FilledButton.tonalIcon(
                    onPressed: () => showMigrationDialog(context, ref),
                    icon: const SemanticIcon(
                      icon: AppIcons.analytics,
                      semanticLabel: 'Analytics',
                    ),
                    label: Text(context.l10n.migrateWorkoutHistory),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                      foregroundColor: context.colors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, WidgetRef ref, AsyncValue<dynamic> currentUser) {
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
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
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
                                    style: context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        const SizedBox(height: 12),
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
                        // Admin Premium Toggle (admin only)
                        if (ref.watch(isAdminCachedProvider)) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildAdminPremiumToggle(context, ref),
                        ],
                      ],
                    )
                  : Text(context.l10n.settingsNotLoggedIn),
              loading: () => Text(context.l10n.settingsLoading),
              error: (_, __) => Text(context.l10n.settingsErrorLoadingUser),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPremiumToggle(BuildContext context, WidgetRef ref) {
    // FIX: Read from userProfileProvider (stream with data), not notifier (may be loading)
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final accountTier = profile?.accountTier ?? AccountTier.free;
    final isPremium = accountTier == AccountTier.premium || accountTier == AccountTier.pro;

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
          SwitchListTile(
            title: Text(context.l10n.adminPremiumStatus),
            subtitle: Text(
              isPremium
                  ? context.l10n.adminPremiumActive(accountTier.name)
                  : context.l10n.adminPremiumInactive,
            ),
            value: isPremium,
            activeTrackColor: context.colors.tertiary.withValues(alpha: 0.5),
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

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.theme,
                  semanticLabel: 'Theme settings',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.appearance,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Theme Mode Selection (with visual icon preview)
            ListTile(
              title: Text(context.l10n.theme),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: _getThemeModeIcon(config.themeMode),
                    semanticLabel: _getThemeModeText(context.l10n, config.themeMode),
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(_getThemeModeText(context.l10n, config.themeMode)),
                ],
              ),
              leading: SemanticIcon(
                icon: _getThemeModeIcon(config.themeMode),
                semanticLabel: _getThemeModeText(context.l10n, config.themeMode),
                size: AppIconSize.medium,
              ),
              trailing: const SemanticIcon(
  icon: AppIcons.chevronRight,
  semanticLabel: 'Chevron right',
),
              onTap: () => _showThemeDialog(context, ref, config.themeMode),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Theme Color (with color preview circle)
            ListTile(
              title: Text(context.l10n.settingsThemeColor),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppIconSize.small,
                    height: AppIconSize.small,
                    decoration: BoxDecoration(
                      color: _getPrimaryColor(context, config.primaryColor),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.settingsThemeColorDesc),
                ],
              ),
              leading: SemanticIcon(
                icon: AppIcons.colorLens,
                semanticLabel: 'Theme color',
                size: AppIconSize.medium,
                color: _getPrimaryColor(context, config.primaryColor),
              ),
              trailing: const SemanticIcon(
  icon: AppIcons.chevronRight,
  semanticLabel: 'Chevron right',
),
              onTap: () => _showColorDialog(context, ref, config.primaryColor),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Font Size (with live preview text)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SemanticIcon(
  icon: AppIcons.formatSize,
  semanticLabel: 'Format size',
),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.settingsTextSize,
                            style: context.textTheme.bodyLarge,
                          ),
                          Text(
                            context.l10n.settingsTextSizePreview(
                              _getFontSizeText(context, config.fontSize),
                            ),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.6),
                              fontSize: (context.textTheme.bodyMedium?.fontSize ?? 14) * config.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: config.fontSize,
                  min: 0.8,
                  max: 1.2,
                  divisions: 4,
                  onChanged: (value) {
                    ref.read(appConfigProvider.notifier).setFontSize(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutEssentialsSection(BuildContext context, WidgetRef ref, AppConfig config) {
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
                  icon: AppIcons.workout,
                  semanticLabel: 'Workout essentials',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsWorkoutEssentials,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Default Rest Time
            _buildSettingTile(
              context,
              title: context.l10n.settingsDefaultRestTime,
              subtitle: '${config.defaultRestTime}s',
              leading: const SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
),
              onTap: () => _showRestTimeDialog(context, ref, config.defaultRestTime),
            ),

            const Divider(),

            // Day Cutoff Hour (configurable workout "today" cutoff)
            _buildSettingTile(
              context,
              title: context.l10n.settingsDayCutoffHour,
              subtitle: context.l10n.settingsDayCutoffHourDesc(
                ref.watch(userProfileProvider).valueOrNull?.dayCutoffHour ?? 4,
              ),
              leading: const SemanticIcon(
  icon: AppIcons.schedule,
  semanticLabel: 'Schedule',
),
              onTap: () => _showDayCutoffDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBackupSection(BuildContext context) {
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
                  icon: AppIcons.storage,
                  semanticLabel: context.l10n.dataBackup,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.dataBackup,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Import Data from other apps
            _buildSettingTile(
              context,
              title: context.l10n.importData,
              subtitle: context.l10n.importFromOtherApp,
              leading: const SemanticIcon(
                icon: AppIcons.download,
                semanticLabel: 'Import',
              ),
              onTap: () => context.pushNamed('import-data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSyncSection(BuildContext context) {
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
                  icon: AppIcons.sync,
                  semanticLabel: 'Health Sync',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.healthSyncSettings,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Health Sync Settings Link
            _buildSettingTile(
              context,
              title: context.l10n.healthSyncSettings,
              subtitle: context.l10n.healthSyncSettingsDesc,
              leading: const SemanticIcon(
                icon: AppIcons.favorite,
                semanticLabel: 'Health',
              ),
              onTap: () => context.pushNamed('health-sync'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsLanguageSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.language,
                  semanticLabel: 'Units and language',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsUnitsLanguage,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Selection
            _buildSettingTile(
              context,
              title: context.l10n.settingsLanguage,
              subtitle: _getLanguageText(config.languageCode),
              leading: const SemanticIcon(
  icon: AppIcons.translate,
  semanticLabel: 'Translate',
),
              onTap: () => _showLanguageDialog(context, ref, config.languageCode),
            ),

            const Divider(),

            // Measurement Unit
            _buildSettingTile(
              context,
              title: context.l10n.weightUnits,
              subtitle: config.measurementUnit.toUpperCase(),
              leading: const SemanticIcon(
  icon: AppIcons.weight,
  semanticLabel: 'Weight',
),
              onTap: () => _showUnitsDialog(context, ref, config.measurementUnit),
            ),

            const Divider(),

            // Effort Scale (RPE/RIR)
            _buildSettingTile(
              context,
              title: context.l10n.effortScaleSetting,
              subtitle: ref.watch(effortScaleProvider) == 'rpe'
                  ? context.l10n.rpeMode
                  : context.l10n.rirMode,
              leading: const SemanticIcon(
  icon: AppIcons.trending,
  semanticLabel: 'Effort scale',
),
              onTap: () => _showEffortScaleDialog(context, ref, ref.read(effortScaleProvider)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTutorialHelpSection(BuildContext context, WidgetRef ref) {
    final tutorialsEnabled = ref.watch(tutorialsEnabledProvider);
    final seenCount = ref.watch(seenTutorialsCountProvider);
    final totalCount = TutorialRegistry.allTutorials.length;

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
            _buildSwitchTile(
              context,
              title: context.l10n.settingsContextualTutorials,
              subtitle: context.l10n.settingsContextualTutorialsDesc,
              value: tutorialsEnabled,
              onChanged: (value) {
                ref.read(tutorialStateProvider.notifier).setTutorialsEnabled(value);
                SnackBarService.showSuccess(
                  context,
                  value
                      ? context.l10n.settingsTutorialsEnabled
                      : context.l10n.settingsTutorialsDisabled,
                );
              },
            ),

            const Divider(),

            // Tutorials Progress Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.checkCircle,
                    semanticLabel: context.l10n.settingsTutorialsSeenCount(seenCount, totalCount),
                    size: AppIconSize.small,
                    color: context.colors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.settingsTutorialsSeenCount(seenCount, totalCount),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Reset Tutorials Button
            _buildSettingTile(
              context,
              title: context.l10n.settingsResetTutorials,
              subtitle: context.l10n.settingsResetTutorialsDesc,
              leading: SemanticIcon(
                icon: AppIcons.refresh,
                semanticLabel: context.l10n.settingsResetTutorials,
                size: AppIconSize.medium,
                color: context.colors.warning,
              ),
              onTap: () => _showResetTutorialsDialog(context, ref),
            ),

            const Divider(),

            // Help Center
            _buildSettingTile(
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
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
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
            _buildSettingTile(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: leading,
      trailing: trailing ?? const SemanticIcon(
  icon: AppIcons.chevronRight,
  semanticLabel: 'Chevron right',
),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Dialog Methods
  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeLight),
                subtitle: Text(l10n.themeLightDesc),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeDark),
                subtitle: Text(l10n.themeDarkDesc),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeSystem),
                subtitle: Text(l10n.themeSystemDesc),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsChooseLanguage),
        content: RadioGroup<String>(
          groupValue: currentLang,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setLanguage(value, value == 'en' ? 'US' : 'IT');
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(context.l10n.languageEnglish),
                subtitle: Text(context.l10n.settingsEnglishUS),
                value: 'en',
              ),
              RadioListTile<String>(
                title: Text(context.l10n.settingsItaliano),
                subtitle: Text(context.l10n.settingsItalianIT),
                value: 'it',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, WidgetRef ref, String currentUnit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.weightUnits),
        content: RadioGroup<String>(
          groupValue: currentUnit,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setMeasurementUnit(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(context.l10n.settingsKilogramsKg),
                subtitle: Text(context.l10n.settingsMetricSystem),
                value: 'kg',
              ),
              RadioListTile<String>(
                title: Text(context.l10n.settingsPoundsLbs),
                subtitle: Text(context.l10n.settingsImperialSystem),
                value: 'lbs',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEffortScaleDialog(BuildContext context, WidgetRef ref, String currentScale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.effortScaleSetting),
        content: RadioGroup<String>(
          groupValue: currentScale,
          onChanged: (value) {
            if (value != null) {
              ref.read(appConfigProvider.notifier).setEffortScale(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(context.l10n.rpeMode),
                subtitle: Text(context.l10n.rpeScaleDescription),
                value: 'rpe',
              ),
              RadioListTile<String>(
                title: Text(context.l10n.rirMode),
                subtitle: Text(context.l10n.rirScaleDescription),
                value: 'rir',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context, WidgetRef ref, String currentColor) {
    final colors = ['blue', 'red', 'green', 'purple', 'orange', 'teal'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsAccentColorDialog),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              ref.read(appConfigProvider.notifier).setPrimaryColor(color);
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPrimaryColor(context, color),
                shape: BoxShape.circle,
                border: currentColor == color
                    ? Border.all(color: context.colors.onSurface, width: 3)
                    : null,
              ),
              child: currentColor == color
                  ? SemanticIcon(
                      icon: AppIcons.check,
                      semanticLabel: 'Selected',
                      size: AppIconSize.medium,
                      color: context.colors.surface,
                    )
                  : null,
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showRestTimeDialog(BuildContext context, WidgetRef ref, int currentTime) {
    int selectedTime = currentTime;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.settingsDefaultRestTimeDialog),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${selectedTime}s'),
              Slider(
                value: selectedTime.toDouble(),
                min: 30,
                max: 300,
                divisions: 27,
                onChanged: (value) {
                  setState(() {
                    selectedTime = value.round();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                ref.read(appConfigProvider.notifier).setDefaultRestTime(selectedTime);
                Navigator.pop(context);
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayCutoffDialog(BuildContext context, WidgetRef ref) {
    final currentProfile = ref.read(userProfileProvider).valueOrNull;
    int selectedHour = currentProfile?.dayCutoffHour ?? 4;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.settingsDayCutoffHourDialog),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.settingsDayCutoffHourValue(selectedHour),
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Slider(
                value: selectedHour.toDouble(),
                min: 0,
                max: 23,
                divisions: 23,
                label: '$selectedHour:00',
                onChanged: (value) {
                  setState(() {
                    selectedHour = value.round();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.settingsDayCutoffHourHint,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                if (currentProfile != null) {
                  // Update preferences map with new cutoff hour
                  final updatedPreferences = Map<String, dynamic>.from(currentProfile.preferences);
                  updatedPreferences['dayCutoffHour'] = selectedHour;

                  // Update profile in Firestore
                  await ref.read(userProfileNotifierProvider.notifier).updateProfile({
                    'preferences': updatedPreferences,
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    SnackBarService.showSuccess(
                      context,
                      context.l10n.settingsDayCutoffHourUpdated(selectedHour),
                    );
                  }
                }
              },
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

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
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: context.colors.error),
            child: Text(context.l10n.signOutButton),
          ),
        ],
      ),
    );
  }

  void _showResetTutorialsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsResetTutorialsConfirmTitle),
        content: Text(context.l10n.settingsResetTutorialsConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tutorialStateProvider.notifier).resetAllTutorials();
              if (context.mounted) {
                SnackBarService.showSuccess(
                  context,
                  context.l10n.settingsTutorialsResetSuccess,
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.warning,
            ),
            child: Text(context.l10n.settingsResetTutorials),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  String _getThemeModeText(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppIcons.lightMode;
      case ThemeMode.dark:
        return AppIcons.darkMode;
      case ThemeMode.system:
        return AppIcons.autoMode;
    }
  }

  String _getFontSizeText(BuildContext context, double fontSize) {
    if (fontSize < 0.9) return context.l10n.settingsFontSizeSmall;
    if (fontSize > 1.1) return context.l10n.settingsFontSizeLarge;
    return context.l10n.settingsFontSizeNormal;
  }

  String _getLanguageText(String code) {
    switch (code) {
      case 'it':
        return 'Italiano';
      case 'en':
      default:
        return 'English';
    }
  }

  Color _getPrimaryColor(BuildContext context, String colorName) {
    switch (colorName) {
      case 'red':
        return context.colors.error;
      case 'green':
        return context.colors.success;
      case 'purple':
        return context.colors.tertiary;
      case 'orange':
        return context.colors.warning;
      case 'teal':
        return context.colors.secondary;
      case 'blue':
      default:
        return context.colors.primary;
    }
  }
}
