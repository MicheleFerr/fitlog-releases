import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../../shared/presentation/providers/app_config_provider.dart';
import '../../../shared/domain/entities/app_config.dart';
import '../../../shared/domain/entities/timer_sound.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../timer/presentation/providers/timer_ui_state_provider.dart';
import 'widgets/timer_sound_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final currentUser = ref.watch(firebaseUserProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            // User Info Section
            _buildUserInfoSection(context, ref, currentUser),
            const SizedBox(height: 24),

            // Appearance Settings
            _buildAppearanceSection(context, ref, config),
            const SizedBox(height: 24),

            // Workout Settings
            _buildWorkoutSection(context, ref, config),
            const SizedBox(height: 24),

            // Units & Language
            _buildUnitsLanguageSection(context, ref, config),
            const SizedBox(height: 24),

            // iOS Features (if iOS)
            if (Theme.of(context).platform == TargetPlatform.iOS) ...[
              _buildIOSFeaturesSection(context, ref, config),
              const SizedBox(height: 24),
            ],

            // Audio & Feedback
            _buildAudioFeedbackSection(context, ref, config),
            const SizedBox(height: 24),

            // Advanced Settings
            _buildAdvancedSection(context, ref, config),
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
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.account,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName ?? 'GymBro User',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    user.email ?? 'No email',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Text('Not logged in'),
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Error loading user'),
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
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.appearance,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Theme Mode Selection
            _buildSettingTile(
              context,
              title: AppLocalizations.of(context)!.theme,
              subtitle: _getThemeModeText(AppLocalizations.of(context)!, config.themeMode),
              leading: Icon(_getThemeModeIcon(config.themeMode)),
              onTap: () => _showThemeDialog(context, ref, config.themeMode),
            ),

            const Divider(),

            // Font Size
            _buildFontSizeSection(context, ref, config),

            const Divider(),

            // Primary Color
            _buildSettingTile(
              context,
              title: 'Accent Color',
              subtitle: config.primaryColor.toUpperCase(),
              leading: Icon(
                Icons.color_lens,
                color: _getPrimaryColor(config.primaryColor),
              ),
              onTap: () => _showColorDialog(context, ref, config.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Workout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Auto Start Timer
            _buildSwitchTile(
              context,
              title: 'Auto-start Timer',
              subtitle: 'Start rest timer after completing set',
              value: config.autoStartTimer,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setAutoStartTimer(value);
              },
            ),

            const Divider(),

            // Default Rest Time
            _buildSettingTile(
              context,
              title: 'Default Rest Time',
              subtitle: '${config.defaultRestTime}s',
              leading: const Icon(Icons.timer),
              onTap: () => _showRestTimeDialog(context, ref, config.defaultRestTime),
            ),

            const Divider(),

            // Show Intensity Techniques
            _buildSwitchTile(
              context,
              title: 'Advanced Techniques',
              subtitle: 'Show drop sets, supersets, etc.',
              value: config.showIntensityTechniques,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setShowIntensityTechniques(value);
              },
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
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Units & Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Language Selection
            _buildSettingTile(
              context,
              title: 'Language',
              subtitle: _getLanguageText(config.languageCode),
              leading: const Icon(Icons.translate),
              onTap: () => _showLanguageDialog(context, ref, config.languageCode),
            ),

            const Divider(),

            // Measurement Unit
            _buildSettingTile(
              context,
              title: 'Weight Units',
              subtitle: config.measurementUnit.toUpperCase(),
              leading: const Icon(Icons.monitor_weight),
              onTap: () => _showUnitsDialog(context, ref, config.measurementUnit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSFeaturesSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_iphone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'iOS Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Activities
            _buildSwitchTile(
              context,
              title: 'Live Activities',
              subtitle: 'Show timer on lock screen & Dynamic Island',
              value: config.enableLiveActivities,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setEnableLiveActivities(value);
              },
            ),

            const Divider(),

            // HealthKit Sync
            _buildSwitchTile(
              context,
              title: 'Health App Sync',
              subtitle: 'Sync workouts to Apple Health',
              value: config.syncWithHealthKit,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setSyncWithHealthKit(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioFeedbackSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audio & Feedback',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sound Effects
            _buildSwitchTile(
              context,
              title: 'Sound Effects',
              subtitle: 'Play sounds for timer and completion',
              value: config.soundEnabled,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setSoundEnabled(value);
              },
            ),

            const Divider(),

            // Vibrations
            _buildSwitchTile(
              context,
              title: 'Vibrations',
              subtitle: 'Haptic feedback for interactions',
              value: config.vibrationsEnabled,
              onChanged: (value) {
                ref.read(appConfigProvider.notifier).setVibrationsEnabled(value);
              },
            ),

            const Divider(),

            // Timer Sound
            _buildSettingTile(
              context,
              title: AppLocalizations.of(context)!.timerSound,
              subtitle: TimerSound.fromFileName(config.timerSound).getLocalizedName(),
              leading: const Icon(Icons.notifications_active),
              onTap: () => _showTimerSoundDialog(context, ref, config.timerSound),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_applications,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Advanced',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Export Settings
            _buildSettingTile(
              context,
              title: 'Export Settings',
              subtitle: 'Save settings as JSON file',
              leading: const Icon(Icons.file_download),
              onTap: () => _exportSettings(context, ref),
            ),

            const Divider(),

            // Import Settings
            _buildSettingTile(
              context,
              title: 'Import Settings',
              subtitle: 'Load settings from JSON file',
              leading: const Icon(Icons.file_upload),
              onTap: () => _importSettings(context, ref),
            ),

            const Divider(),

            // Reset Timer Position
            _buildSettingTile(
              context,
              title: 'Reset Timer Position',
              subtitle: 'Reset draggable timer to default position',
              leading: const Icon(Icons.picture_in_picture_alt),
              onTap: () => _resetTimerPosition(context, ref),
            ),

            const Divider(),

            // Reset to Defaults
            _buildSettingTile(
              context,
              title: 'Reset to Defaults',
              subtitle: 'Restore all settings to default',
              leading: const Icon(Icons.restore, color: Colors.red),
              onTap: () => _showResetDialog(context, ref),
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
                  Icons.logout,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sign Out
            _buildSettingTile(
              context,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              leading: const Icon(Icons.logout, color: Colors.red),
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
      trailing: trailing ?? const Icon(Icons.chevron_right),
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

  Widget _buildFontSizeSection(BuildContext context, WidgetRef ref, AppConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_size),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    _getFontSizeText(config.fontSize),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }

  // Dialog Methods
  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeLight),
              subtitle: Text(l10n.themeLightDesc),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeDark),
              subtitle: Text(l10n.themeDarkDesc),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.themeSystem),
              subtitle: Text(l10n.themeSystemDesc),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('English (US)'),
              value: 'en',
              groupValue: currentLang,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setLanguage(value, 'US');
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Italiano'),
              subtitle: const Text('Italian (IT)'),
              value: 'it',
              groupValue: currentLang,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setLanguage(value, 'IT');
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, WidgetRef ref, String currentUnit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weight Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Kilograms (kg)'),
              subtitle: const Text('Metric system'),
              value: 'kg',
              groupValue: currentUnit,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setMeasurementUnit(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Pounds (lbs)'),
              subtitle: const Text('Imperial system'),
              value: 'lbs',
              groupValue: currentUnit,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setMeasurementUnit(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context, WidgetRef ref, String currentColor) {
    final colors = ['blue', 'red', 'green', 'purple', 'orange', 'teal'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accent Color'),
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
                  ? const Icon(Icons.check, color: Colors.white)
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
          title: const Text('Default Rest Time'),
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(appConfigProvider.notifier).setDefaultRestTime(selectedTime);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetTimerPosition(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Timer Position'),
        content: const Text('This will reset the draggable timer to its default position. Useful if the timer is stuck off-screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Reset timer position to default
              ref.read(timerUIStateProvider.notifier).updatePosition(const Offset(20, 100));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Timer position reset to default'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Reset Position'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to defaults? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(appConfigProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _exportSettings(BuildContext context, WidgetRef ref) {
    final config = ref.read(appConfigProvider.notifier).exportConfig();
    // In a real app, you'd save this to a file or share it
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _importSettings(BuildContext context, WidgetRef ref) {
    // In a real app, you'd pick a file and import it
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality coming soon')),
    );
  }

  void _showTimerSoundDialog(BuildContext context, WidgetRef ref, String currentSound) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.timerSound),
        content: SizedBox(
          width: double.maxFinite,
          child: TimerSoundSelector(
            selectedSound: TimerSound.fromFileName(currentSound),
            onSoundSelected: (sound) {
              ref.read(appConfigProvider.notifier).setTimerSound(sound.fileName);
              Navigator.pop(context);
            },
          ),
        ),
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
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.auto_mode;
    }
  }

  String _getFontSizeText(double fontSize) {
    if (fontSize < 0.9) return 'Small';
    if (fontSize > 1.1) return 'Large';
    return 'Normal';
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