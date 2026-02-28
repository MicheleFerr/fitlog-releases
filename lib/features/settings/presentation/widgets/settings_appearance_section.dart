import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_theme_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:cupertino_native/cupertino_native.dart';

/// Appearance settings section: theme mode, primary color, font size.
class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({
    super.key,
    required this.config,
  });

  final AppConfig config;

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
                    icon: _getThemeModeIcon(config.appThemeMode),
                    semanticLabel: _getThemeModeText(
                      context.l10n,
                      config.appThemeMode,
                    ),
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(_getThemeModeText(context.l10n, config.appThemeMode)),
                ],
              ),
              leading: SemanticIcon(
                icon: _getThemeModeIcon(config.appThemeMode),
                semanticLabel: _getThemeModeText(
                  context.l10n,
                  config.appThemeMode,
                ),
                size: AppIconSize.medium,
              ),
              trailing: const SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: 'Chevron right',
              ),
              onTap: () => _showThemeDialog(context, ref, config.appThemeMode),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(),

            // Primary Color Selection
            ListTile(
              title: Text(context.l10n.primaryColor),
              subtitle: Text(
                _getColorDisplayName(context, config.primaryColor),
              ),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getColorFromHex(config.primaryColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.outline, width: 1),
                ),
              ),
              trailing: const SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: 'Chevron right',
              ),
              onTap: () =>
                  _showColorPickerDialog(context, ref, config.primaryColor),
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
                CNSlider(
                  value: config.fontSize,
                  min: 0.8,
                  max: 1.1,
                  step: 0.01,
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

  // --- Theme Dialog ---

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    final l10n = AppLocalizations.of(context);
    ModalService.showSheet(
      context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                l10n.chooseTheme,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            RadioGroup<AppThemeMode>(
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appConfigProvider.notifier).setAppThemeMode(value);
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeLight),
                    subtitle: Text(l10n.themeLightDesc),
                    value: AppThemeMode.light,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeDark),
                    subtitle: Text(l10n.themeDarkDesc),
                    value: AppThemeMode.dark,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeUltraDark),
                    subtitle: Text(l10n.themeUltraDarkDesc),
                    value: AppThemeMode.ultraDark,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themePink),
                    subtitle: Text(l10n.themePinkDesc),
                    value: AppThemeMode.pink,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeDarkPink),
                    subtitle: Text(l10n.themeDarkPinkDesc),
                    value: AppThemeMode.darkPink,
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.themeSystem),
                    subtitle: Text(l10n.themeSystemDesc),
                    value: AppThemeMode.system,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Color Picker Dialog ---

  void _showColorPickerDialog(
    BuildContext context,
    WidgetRef ref,
    String currentColor,
  ) {
    final colors = AppTheme.themeColors.entries.toList();

    ModalService.showSheet(
      context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                context.l10n.choosePrimaryColor,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...colors.map((entry) {
              final colorName = entry.key;
              final color = entry.value;
              final colorHex = (color.toARGB32() & 0xFFFFFF)
                  .toRadixString(16)
                  .padLeft(6, '0');
              final isSelected =
                  currentColor.toLowerCase() == colorName ||
                  currentColor.toLowerCase() == colorHex;

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: context.colors.onSurface, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const SemanticIcon(
                          icon: AppIcons.check,
                          semanticLabel: 'Selected',
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
                title: Text(
                  _getColorDisplayName(context, colorName),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  ref
                      .read(appConfigProvider.notifier)
                      .setPrimaryColor(colorName);
                  Navigator.pop(context);
                  SnackBarService.showSuccess(
                    context,
                    '${context.l10n.primaryColor}: ${_getColorDisplayName(context, colorName)}',
                  );
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- Helper Methods ---

  String _getThemeModeText(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
      case AppThemeMode.ultraDark:
        return l10n.themeUltraDark;
      case AppThemeMode.pink:
        return l10n.themePink;
      case AppThemeMode.darkPink:
        return l10n.themeDarkPink;
      case AppThemeMode.system:
        return l10n.themeSystem;
    }
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return AppIcons.lightMode;
      case AppThemeMode.dark:
        return AppIcons.darkMode;
      case AppThemeMode.ultraDark:
        return AppIcons.darkMode;
      case AppThemeMode.pink:
        return AppIcons.lightMode;
      case AppThemeMode.darkPink:
        return AppIcons.darkMode;
      case AppThemeMode.system:
        return AppIcons.autoMode;
    }
  }

  String _getFontSizeText(BuildContext context, double fontSize) {
    if (fontSize < 0.87) return context.l10n.settingsFontSizeExtraSmall;
    if (fontSize < 0.94) return context.l10n.settingsFontSizeSmall;
    if (fontSize < 1.01) return context.l10n.settingsFontSizeNormal;
    if (fontSize < 1.07) return context.l10n.settingsFontSizeMediumLarge;
    return context.l10n.settingsFontSizeLarge;
  }

  Color _getColorFromHex(String hexColor) {
    // Check if it's a named color first
    final namedColor = AppTheme.themeColors[hexColor.toLowerCase()];
    if (namedColor != null) return namedColor;

    // Otherwise parse as hex
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.themeColors['blue']!;
    }
  }

  String _getColorDisplayName(BuildContext context, String colorKey) {
    final colorName = colorKey.toLowerCase();
    switch (colorName) {
      case 'blue':
      case '2196f3':
        return context.l10n.colorBlue;
      case 'red':
      case 'f44336':
        return context.l10n.colorRed;
      case 'green':
      case '4caf50':
        return context.l10n.colorGreen;
      case 'purple':
      case '9c27b0':
        return context.l10n.colorPurple;
      case 'orange':
      case 'ff9800':
        return context.l10n.colorOrange;
      case 'teal':
      case '009688':
        return context.l10n.colorTeal;
      case 'pink':
      case 'e91e63':
        return context.l10n.colorPink;
      default:
        return context.l10n.colorBlue;
    }
  }
}
