import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/database_manager_screen.dart';

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
          icon: Icon(AppIcons.back),
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

            // Units & Language
            _buildUnitsLanguageSection(context, ref, config),
            const SizedBox(height: 24),

            // Account Actions
            _buildAccountSection(context, ref),
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
                Icon(
                  AppIcons.person,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
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
                                  ? Icon(AppIcons.person)
                                  : null,
                            ),
                            SizedBox(width: 12),
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
                        SizedBox(height: 12),
                        // Admin Dashboard Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.pushNamed('admin'),
                            icon: Icon(AppIcons.admin),
                            label: Text(context.l10n.adminDashboard),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.colors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
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
                            icon: Icon(AppIcons.storage),
                            label: Text(context.l10n.databaseManager),
                            style: FilledButton.styleFrom(
                              backgroundColor: context.colors.primary,
                            ),
                          ),
                        ),
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

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.theme,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  context.l10n.appearance,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Theme Mode Selection (with visual icon preview)
            ListTile(
              title: Text(context.l10n.theme),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getThemeModeIcon(config.themeMode), size: 20),
                  const SizedBox(width: 8),
                  Text(_getThemeModeText(context.l10n, config.themeMode)),
                ],
              ),
              leading: Icon(_getThemeModeIcon(config.themeMode)),
              trailing: const Icon(AppIcons.chevronRight),
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
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getPrimaryColor(config.primaryColor),
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
              leading: Icon(
                AppIcons.colorLens,
                color: _getPrimaryColor(config.primaryColor),
              ),
              trailing: const Icon(AppIcons.chevronRight),
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
                    Icon(AppIcons.formatSize),
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
                Icon(AppIcons.workout, color: context.colors.primary),
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
              leading: const Icon(AppIcons.timer),
              onTap: () => _showRestTimeDialog(context, ref, config.defaultRestTime),
            ),

            const Divider(),

            // APRE System Toggle
            _buildSwitchTile(
              context,
              title: context.l10n.settingsApreAutoAdjustment,
              subtitle: context.l10n.settingsApreAutoAdjustmentDesc,
              value: config.enableApre ?? false,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).updateWorkoutSettings(
                  enableApre: value,
                );
              },
            ),

            // APRE Protocol Config (only if enabled)
            if (config.enableApre == true) ...[
              const Divider(),
              _buildSettingTile(
                context,
                title: context.l10n.settingsApreProtocol,
                subtitle: context.l10n.settingsApreProtocolDesc(config.defaultApreProtocol ?? 3),
                leading: const Icon(AppIcons.settings),
                onTap: () => _showApreProtocolDialog(context, ref, config.defaultApreProtocol ?? 3),
              ),
            ],
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
                Icon(
                  AppIcons.language,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
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
              leading: const Icon(AppIcons.translate),
              onTap: () => _showLanguageDialog(context, ref, config.languageCode),
            ),

            const Divider(),

            // Measurement Unit
            _buildSettingTile(
              context,
              title: context.l10n.weightUnits,
              subtitle: config.measurementUnit.toUpperCase(),
              leading: const Icon(AppIcons.weight),
              onTap: () => _showUnitsDialog(context, ref, config.measurementUnit),
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
                Icon(
                  AppIcons.logout,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
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
              leading: const Icon(AppIcons.logout, color: Colors.red),
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
      trailing: trailing ?? const Icon(AppIcons.chevronRight),
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
                color: _getPrimaryColor(color),
                shape: BoxShape.circle,
                border: currentColor == color
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: currentColor == color
                  ? const Icon(AppIcons.check, color: Colors.white)
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

  void _showApreProtocolDialog(BuildContext context, WidgetRef ref, int currentProtocol) {
    final protocols = [3, 6, 10];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsApreProtocol),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: protocols.map((protocol) => RadioListTile<int>(
            title: Text(context.l10n.settingsApreProtocolDesc(protocol)),
            subtitle: Text(_getApreProtocolDescription(context, protocol)),
            value: protocol,
            groupValue: currentProtocol,
            onChanged: (value) {
              if (value != null) {
                ref.read(appConfigProvider.notifier).updateWorkoutSettings(
                  defaultApreProtocol: value,
                );
                Navigator.pop(context);
                SnackBarService.showSuccess(
                  context,
                  context.l10n.settingsApreProtocolUpdated(value),
                );
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  String _getApreProtocolDescription(BuildContext context, int protocol) {
    switch (protocol) {
      case 3:
        return '3 sets to failure (fastest)';
      case 6:
        return '6 sets progressive (balanced)';
      case 10:
        return '10 sets progressive (advanced)';
      default:
        return 'Protocol $protocol';
    }
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.signOutButton),
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

  Color _getPrimaryColor(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      case 'blue':
      default:
        return Colors.blue;
    }
  }
}
