import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/database_manager_screen.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/screens/audio_debug_test_screen.dart';
import 'package:gymbro_flutter_new/features/debug/presentation/screens/tier_limits_test_screen.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/migration_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/data_export/presentation/widgets/data_export_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/ghost_mode_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/screens/legal_document_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';

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
          icon: const SemanticIcon(icon: AppIcons.back, semanticLabel: 'Back'),
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

            // Ghost Mode (Privacy & Focus)
            _buildGhostModeSection(context, ref),
            const SizedBox(height: 24),

            // Workout Essentials (NEW)
            _buildWorkoutEssentialsSection(context, ref, config),
            const SizedBox(height: 24),

            // Feedback & Display (Sounds, Vibrations, Screen)
            _buildFeedbackDisplaySection(context, ref, config),
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

            // Advanced Settings (power users)
            _buildAdvancedSettingsSection(context, ref, config),
            const SizedBox(height: 24),

            // Premium (Coming Soon)
            _buildPremiumSection(context),
            const SizedBox(height: 24),

            // Account Actions
            _buildAccountSection(context, ref),
            const SizedBox(height: 24),

            // About & Credits
            _buildAboutCreditsSection(context),

            // DEBUG: Migration tool (ferrara-michele only)
            if (currentUser.value?.email?.toString().contains(
                  'ferrara-michele',
                ) ==
                true)
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
                      backgroundColor: context.colors.primary.withValues(
                        alpha: 0.1,
                      ),
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

  Widget _buildUserInfoSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> currentUser,
  ) {
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
                                    style: context.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    user.email ?? context.l10n.settingsNoEmail,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: context.colors.onSurface
                                              .withValues(alpha: 0.7),
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
                                    builder: (_) =>
                                        const DatabaseManagerScreen(),
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
                          // 🔬 Audio Debug Tests
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AudioDebugTestScreen(),
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
                          // 🧪 Tier Limits Test
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TierLimitsTestScreen(),
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
                          // 🧪 TEST: Reset Exercise Database
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final actions = ref.read(
                                  exerciseSyncActionsProvider,
                                );
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
                              label: Text('🧪 Reset Exercise DB'),
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

  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
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
                    semanticLabel: _getThemeModeText(
                      context.l10n,
                      config.themeMode,
                    ),
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(_getThemeModeText(context.l10n, config.themeMode)),
                ],
              ),
              leading: SemanticIcon(
                icon: _getThemeModeIcon(config.themeMode),
                semanticLabel: _getThemeModeText(
                  context.l10n,
                  config.themeMode,
                ),
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
                              color: context.colors.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize:
                                  (context.textTheme.bodyMedium?.fontSize ??
                                      14) *
                                  config.fontSize,
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

  Widget _buildGhostModeSection(BuildContext context, WidgetRef ref) {
    final ghostState = ref.watch(ghostModeProvider);
    final isEnabled = ghostState.isEnabled;
    final config = ghostState.config;

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
                  icon: AppIcons.visibilityOff,
                  semanticLabel: context.l10n.ghostModeSection,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.ghostModeSection,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ghost Mode Toggle
            SwitchListTile(
              title: Text(context.l10n.ghostModeTitle),
              subtitle: Text(context.l10n.ghostModeDescription),
              value: isEnabled,
              onChanged: (value) async {
                await ref.read(ghostModeProvider.notifier).setEnabled(value);
                if (context.mounted) {
                  SnackBarService.showInfo(
                    context,
                    value
                        ? context.l10n.ghostModeEnabled
                        : context.l10n.ghostModeDisabled,
                  );
                }
              },
              secondary: SemanticIcon(
                icon: isEnabled ? AppIcons.visibilityOff : AppIcons.visibility,
                semanticLabel: isEnabled ? 'Hidden' : 'Visible',
                size: AppIconSize.medium,
              ),
              contentPadding: EdgeInsets.zero,
            ),

            // Customization options (only when enabled)
            if (isEnabled) ...[
              const Divider(),
              ExpansionTile(
                title: Text(context.l10n.ghostModeCustomize),
                tilePadding: EdgeInsets.zero,
                children: [
                  // Hide XP Progress
                  CheckboxListTile(
                    title: Text(context.l10n.ghostModeHideXP),
                    value: config.hideXPProgress,
                    onChanged: (value) {
                      ref
                          .read(ghostModeProvider.notifier)
                          .updateConfigField(
                            'hideXPProgress',
                            value: value ?? true,
                          );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Hide Tier Badge
                  CheckboxListTile(
                    title: Text(context.l10n.ghostModeHideTier),
                    value: config.hideTierBadge,
                    onChanged: (value) {
                      ref
                          .read(ghostModeProvider.notifier)
                          .updateConfigField(
                            'hideTierBadge',
                            value: value ?? true,
                          );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Hide Streak
                  CheckboxListTile(
                    title: Text(context.l10n.ghostModeHideStreak),
                    value: config.hideStreak,
                    onChanged: (value) {
                      ref
                          .read(ghostModeProvider.notifier)
                          .updateConfigField(
                            'hideStreak',
                            value: value ?? false,
                          );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Hide Community
                  CheckboxListTile(
                    title: Text(context.l10n.ghostModeHideCommunity),
                    value: config.hideCommunity,
                    onChanged: (value) {
                      ref
                          .read(ghostModeProvider.notifier)
                          .updateConfigField(
                            'hideCommunity',
                            value: value ?? true,
                          );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Hide Comparisons
                  CheckboxListTile(
                    title: Text(context.l10n.ghostModeHideComparisons),
                    value: config.hideStrengthComparisons,
                    onChanged: (value) {
                      ref
                          .read(ghostModeProvider.notifier)
                          .updateConfigField(
                            'hideStrengthComparisons',
                            value: value ?? true,
                          );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  // Hide Animations
                  CheckboxListTile(
                    title: Text(context.l10n.ghostModeHideAnimations),
                    value: config.hideXPAnimations,
                    onChanged: (value) {
                      ref
                          .read(ghostModeProvider.notifier)
                          .updateConfigField(
                            'hideXPAnimations',
                            value: value ?? true,
                          );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutEssentialsSection(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
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
              onTap: () =>
                  _showRestTimeDialog(context, ref, config.defaultRestTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackDisplaySection(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
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
                  icon: AppIcons.notifications,
                  semanticLabel: 'Feedback settings',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsFeedbackDisplay,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sound toggle
            _buildSwitchTile(
              context,
              title: context.l10n.settingsSounds,
              subtitle: context.l10n.settingsSoundsDesc,
              value: config.soundEnabled,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setSoundEnabled(value);
              },
              leading: SemanticIcon(
                icon: config.soundEnabled
                    ? AppIcons.volumeUp
                    : AppIcons.volumeOff,
                semanticLabel: 'Sound',
                size: AppIconSize.medium,
              ),
            ),

            const Divider(),

            // Timer sound selection
            _buildTimerSoundSelector(context, ref, config),

            const Divider(),

            // Vibration toggle
            _buildSwitchTile(
              context,
              title: context.l10n.settingsVibrations,
              subtitle: context.l10n.settingsVibrationsDesc,
              value: config.vibrationsEnabled,
              onChanged: (value) {
                ref
                    .read(appConfigProvider.notifier)
                    .setVibrationsEnabled(value);
              },
              leading: SemanticIcon(
                icon: AppIcons.vibration,
                semanticLabel: 'Vibration',
                size: AppIconSize.medium,
              ),
            ),

            const Divider(),

            // Keep screen awake toggle
            _buildSwitchTile(
              context,
              title: context.l10n.settingsKeepScreenAwake,
              subtitle: context.l10n.settingsKeepScreenAwakeDesc,
              value: config.keepScreenAwakeDuringWorkout,
              onChanged: (value) {
                ref
                    .read(appConfigProvider.notifier)
                    .setKeepScreenAwakeDuringWorkout(value);
              },
              leading: const SemanticIcon(
                icon: AppIcons.screenLockPortrait,
                semanticLabel: 'Screen lock',
                size: AppIconSize.medium,
              ),
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

            const Divider(),

            // Export Data (GDPR Art. 20)
            _buildSettingTile(
              context,
              title: context.l10n.exportData,
              subtitle: context.l10n.exportDataSubtitle,
              leading: const SemanticIcon(
                icon: AppIcons.upload,
                semanticLabel: 'Export',
              ),
              onTap: () => _showExportDataSheet(context),
            ),

            const Divider(),

            // Reset All Analytics (Cache + Stress Index)
            Consumer(
              builder: (context, ref, _) {
                final stressState = ref.watch(stressIndexNotifierProvider);
                final isLoading = stressState.isLoading;

                return _buildSettingTile(
                  context,
                  title: context.l10n.recalculateStressIndex,
                  subtitle: isLoading
                      ? context.l10n.recalculatingStressIndex
                      : context.l10n.recalculateStressIndexDesc,
                  leading: isLoading
                      ? const LoadingIndicator(size: 24)
                      : const SemanticIcon(
                          icon: AppIcons.refresh,
                          semanticLabel: 'Recalculate',
                        ),
                  onTap: isLoading
                      ? null
                      : () async {
                          // Step 1: Clear analytics cache (forces recalculation of all views)
                          final cacheService = ref.read(
                            analyticsCacheServiceProvider,
                          );
                          await cacheService.clear();

                          // Step 2: Recalculate stress index with new EMG ratios
                          // Use 365 days to recalculate all historical data
                          final result = await ref
                              .read(stressIndexNotifierProvider.notifier)
                              .clearAndRecalculate(days: 365);

                          if (context.mounted) {
                            SnackBarService.showSuccess(
                              context,
                              context.l10n.stressIndexRecalculatedSuccess(
                                result.$2,
                              ),
                            );
                          }
                        },
                );
              },
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

  Widget _buildUnitsLanguageSection(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
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
              onTap: () =>
                  _showLanguageDialog(context, ref, config.languageCode),
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
              onTap: () =>
                  _showUnitsDialog(context, ref, config.measurementUnit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialHelpSection(BuildContext context, WidgetRef ref) {
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
            _buildSwitchTile(
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

            const Divider(),

            // Delete Account (GDPR Art. 17 - Right to Erasure)
            _buildSettingTile(
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

  Widget _buildAdvancedSettingsSection(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
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
                  icon: AppIcons.tune,
                  semanticLabel: 'Advanced settings',
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.settingsAdvancedTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.settingsAdvancedDesc,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Day Cutoff Hour
            _buildSettingTile(
              context,
              title: context.l10n.settingsDayCutoffHour,
              subtitle: context.l10n.settingsDayCutoffHourDesc(
                ref.watch(userProfileProvider).value?.dayCutoffHour ?? 4,
              ),
              leading: const SemanticIcon(
                icon: AppIcons.schedule,
                semanticLabel: 'Schedule',
              ),
              onTap: () => _showDayCutoffDialog(context, ref),
            ),

            const Divider(),

            // Effort Scale (RPE vs RIR)
            _buildSettingTile(
              context,
              title: context.l10n.effortScale,
              subtitle: config.effortScale == 'rpe'
                  ? context.l10n.rpeScale
                  : context.l10n.rirScale,
              leading: const SemanticIcon(
                icon: AppIcons.speed,
                semanticLabel: 'Effort scale',
              ),
              onTap: () =>
                  _showEffortScaleDialog(context, ref, config.effortScale),
            ),

            const Divider(),

            // Recalculate Stress Index
            _buildSettingTile(
              context,
              title: context.l10n.recalculateStressIndex,
              subtitle: context.l10n.recalculateStressIndexDesc,
              leading: const SemanticIcon(
                icon: AppIcons.refresh,
                semanticLabel: 'Recalculate',
              ),
              onTap: () => _recalculateStressIndex(context, ref),
            ),

            const Divider(),

            // Reset Tutorials
            _buildSettingTile(
              context,
              title: context.l10n.resetTutorials,
              subtitle: context.l10n.resetTutorialsDesc,
              leading: const SemanticIcon(
                icon: AppIcons.school,
                semanticLabel: 'Reset tutorials',
              ),
              onTap: () => _showResetTutorialsDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCreditsSection(BuildContext context) {
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
                  icon: AppIcons.infoOutline,
                  semanticLabel: context.l10n.aboutCredits,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.aboutCredits,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Exercise Images Credit (ExerciseDB)
            _buildSettingTile(
              context,
              title: context.l10n.exerciseImagesCredit,
              subtitle: context.l10n.exerciseImagesCreditDesc,
              leading: const SemanticIcon(
                icon: AppIcons.workout,
                semanticLabel: 'Exercise images',
              ),
              onTap: () => _showExerciseDbAttributionDialog(context),
            ),

            const Divider(),

            // Privacy Policy
            _buildSettingTile(
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

            // Open Source Licenses
            _buildSettingTile(
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

  Widget _buildPremiumSection(BuildContext context) {
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
                  icon: AppIcons.star,
                  semanticLabel: context.l10n.gymbroPremium,
                  size: AppIconSize.medium,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.gymbroPremium,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.l10n.premiumComingSoonBadge,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Premium features tile
            _buildSettingTile(
              context,
              title: context.l10n.unlockPremium,
              subtitle: context.l10n.getUnlimitedAccess,
              leading: SemanticIcon(
                icon: AppIcons.unlock,
                semanticLabel: context.l10n.unlockPremium,
              ),
              onTap: () => context.pushNamed('premium'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.l10n.viewPlans,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      trailing:
          trailing ??
          const SemanticIcon(
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
    Widget? leading,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Timer sound selector with preview
  Widget _buildTimerSoundSelector(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
    // Map internal sound names to display names
    String getSoundDisplayName(String soundName) {
      switch (soundName) {
        case 'sound':
          return context.l10n.settingsTimerSoundClassic;
        case 'timer_complete':
          return context.l10n.settingsTimerSoundComplete;
        case 'LightWeight':
          return context.l10n.settingsTimerSoundLightWeight;
        case 'YehBuddie':
          return context.l10n.settingsTimerSoundYehBuddie;
        default:
          return soundName;
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const SemanticIcon(
        icon: AppIcons.volumeUp,
        semanticLabel: 'Timer sound',
        size: AppIconSize.medium,
      ),
      title: Text(context.l10n.settingsTimerSound),
      subtitle: Text(getSoundDisplayName(config.timerSound)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview button
          IconButton(
            icon: const SemanticIcon(
              icon: AppIcons.playCircleFilled,
              semanticLabel: 'Preview sound',
              size: AppIconSize.medium,
            ),
            onPressed: () => _previewTimerSound(config.timerSound),
            tooltip: context.l10n.settingsTimerSoundPreview,
          ),
          const SizedBox(width: 8),
          const SemanticIcon(
            icon: AppIcons.chevronRight,
            semanticLabel: 'Select sound',
          ),
        ],
      ),
      onTap: () => _showTimerSoundPicker(context, ref, config),
    );
  }

  // Show timer sound picker bottom sheet
  void _showTimerSoundPicker(
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
  ) {
    final availableSounds = [
      {'name': 'sound', 'displayName': context.l10n.settingsTimerSoundClassic},
      {
        'name': 'timer_complete',
        'displayName': context.l10n.settingsTimerSoundComplete,
      },
      {
        'name': 'LightWeight',
        'displayName': context.l10n.settingsTimerSoundLightWeight,
      },
      {
        'name': 'YehBuddie',
        'displayName': context.l10n.settingsTimerSoundYehBuddie,
      },
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const SemanticIcon(
                      icon: AppIcons.volumeUp,
                      semanticLabel: 'Timer sound',
                      size: AppIconSize.medium,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.settingsTimerSound,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Sound list
              ...availableSounds.map((sound) {
                final soundName = sound['name']!;
                final displayName = sound['displayName']!;
                final isSelected = config.timerSound == soundName;

                return ListTile(
                  leading: SemanticIcon(
                    icon: isSelected
                        ? AppIcons.checkCircle
                        : AppIcons.radioButtonUnchecked,
                    semanticLabel: isSelected ? 'Selected' : 'Not selected',
                    size: AppIconSize.medium,
                    color: isSelected ? context.colors.primary : null,
                  ),
                  title: Text(
                    displayName,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? context.colors.primary : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const SemanticIcon(
                      icon: AppIcons.playCircleFilled,
                      semanticLabel: 'Preview',
                      size: AppIconSize.medium,
                    ),
                    onPressed: () => _previewTimerSound(soundName),
                  ),
                  onTap: () {
                    ref
                        .read(appConfigProvider.notifier)
                        .setTimerSound(soundName);
                    Navigator.of(bottomSheetContext).pop();

                    // Show feedback
                    SnackBarService.showSuccess(
                      context,
                      '${context.l10n.settingsTimerSound}: $displayName',
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Preview timer sound using platform channel
  void _previewTimerSound(String soundName) {
    const platform = MethodChannel('com.gymbro.timer_sound_fix');

    try {
      // Use TimerSoundFix channel to play the sound
      platform.invokeMethod('playTimerSound', {'soundName': soundName});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to preview timer sound: $e');
      }
    }
  }

  // Stress Index Recalculation
  Future<void> _recalculateStressIndex(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Clear analytics cache (forces recalculation of all views)
    final cacheService = ref.read(analyticsCacheServiceProvider);
    await cacheService.clear();

    // Recalculate stress index with new EMG ratios
    // Use 365 days to recalculate all historical data
    final result = await ref
        .read(stressIndexNotifierProvider.notifier)
        .clearAndRecalculate(days: 365);

    if (context.mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.stressIndexRecalculatedSuccess(result.$2),
      );
    }
  }

  // Dialog Methods
  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
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

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsChooseLanguage),
        content: RadioGroup<String>(
          groupValue: currentLang,
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(appConfigProvider.notifier)
                  .setLanguage(value, value == 'en' ? 'US' : 'IT');
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

  void _showUnitsDialog(
    BuildContext context,
    WidgetRef ref,
    String currentUnit,
  ) {
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

  void _showEffortScaleDialog(
    BuildContext context,
    WidgetRef ref,
    String currentScale,
  ) {
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

  void _showRestTimeDialog(
    BuildContext context,
    WidgetRef ref,
    int currentTime,
  ) {
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
                ref
                    .read(appConfigProvider.notifier)
                    .setDefaultRestTime(selectedTime);
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
    final currentProfile = ref.read(userProfileProvider).value;
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
                  final updatedPreferences = Map<String, dynamic>.from(
                    currentProfile.preferences,
                  );
                  updatedPreferences['dayCutoffHour'] = selectedHour;

                  // Update profile in Firestore
                  await ref
                      .read(userProfileNotifierProvider.notifier)
                      .updateProfile({'preferences': updatedPreferences});

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
              await ref
                  .read(tutorialStateProvider.notifier)
                  .resetAllTutorials();
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

  void _showExportDataSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DataExportSheet(),
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
}
