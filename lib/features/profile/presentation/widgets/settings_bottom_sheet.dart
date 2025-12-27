/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Quick Settings Bottom Sheet
/// Type: Widget
///
/// Bottom sheet with quick settings access including theme toggle,
/// language selection, and navigation to full settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Shows the quick settings bottom sheet
void showSettingsBottomSheet(BuildContext context) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
    builder: (context) => const _SettingsBottomSheetContent(),
  );
}

/// Content of the settings bottom sheet
class _SettingsBottomSheetContent extends ConsumerWidget {
  const _SettingsBottomSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    AppIcons.settings,
                    size: AppIconSize.medium,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.settings,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme toggle
            _SettingsTile(
              icon: config.themeMode == ThemeMode.dark
                  ? AppIcons.darkMode
                  : AppIcons.lightMode,
              title: context.l10n.appearance,
              subtitle: _getThemeModeLabel(context, config.themeMode),
              onTap: () => _toggleTheme(context, ref, config.themeMode),
            ),

            // Language selection
            _SettingsTile(
              icon: AppIcons.language,
              title: context.l10n.language,
              subtitle: _getLanguageLabel(config.locale.languageCode),
              onTap: () => _showLanguageSelector(
                context,
                ref,
                config.locale.languageCode,
              ),
            ),

            const Divider(height: 32),

            // All settings button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    context.pushNamed(AppRoutes.settingsName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(AppIcons.settingsOutlined, size: AppIconSize.small),
                      const SizedBox(width: 8),
                      Text(context.l10n.allSettings),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getThemeModeLabel(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.l10n.themeLight;
      case ThemeMode.dark:
        return context.l10n.themeDark;
      case ThemeMode.system:
        return context.l10n.themeSystem;
    }
  }

  String _getLanguageLabel(String languageCode) {
    switch (languageCode) {
      case 'it':
        return 'Italiano';
      case 'en':
        return 'English';
      default:
        return 'System';
    }
  }

  void _toggleTheme(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    HapticFeedback.lightImpact();

    // Cycle through: System -> Light -> Dark -> System
    final ThemeMode nextMode;
    switch (currentMode) {
      case ThemeMode.system:
        nextMode = ThemeMode.light;
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
    }

    ref.read(appConfigProvider.notifier).setThemeMode(nextMode);
  }

  void _showLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => _LanguageSelectorSheet(
        currentLanguageCode: currentLanguageCode,
        onSelect: (languageCode) {
          ref.read(appConfigProvider.notifier).setLanguage(languageCode, '');
          Navigator.pop(context);
        },
      ),
    );
  }

}

/// Individual settings tile
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: AppIconSize.medium,
        color: context.colors.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        AppIcons.chevronRight,
        size: AppIconSize.small,
        color: context.colors.onSurfaceVariant,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}

/// Language selector sheet
class _LanguageSelectorSheet extends StatelessWidget {
  const _LanguageSelectorSheet({
    required this.currentLanguageCode,
    required this.onSelect,
  });

  final String currentLanguageCode;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            context.l10n.selectLanguage,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _LanguageOption(
            label: 'English',
            languageCode: 'en',
            isSelected: currentLanguageCode == 'en',
            onTap: () => onSelect('en'),
          ),
          _LanguageOption(
            label: 'Italiano',
            languageCode: 'it',
            isSelected: currentLanguageCode == 'it',
            onTap: () => onSelect('it'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Individual language option
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isSelected
          ? Icon(AppIcons.check, color: context.colors.primary)
          : const SizedBox(width: 24),
      title: Text(
        label,
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? context.colors.primary : null,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
