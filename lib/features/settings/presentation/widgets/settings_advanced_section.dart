import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/cn_switch_list_tile.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/ghost_mode_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/tutorial_state_notifier.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/settings_shared_helpers.dart';
import 'package:cupertino_native/cupertino_native.dart';

/// Advanced settings section (collapsed by default):
/// Ghost Mode, Day Cutoff, Effort Scale, Recalculate Stress Index, Reset Tutorials.
class SettingsAdvancedSection extends ConsumerWidget {
  const SettingsAdvancedSection({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ghostState = ref.watch(ghostModeProvider);
    final ghostEnabled = ghostState.isEnabled;
    final ghostConfig = ghostState.config;
    final dayCutoffHour =
        ref.watch(userProfileProvider).value?.dayCutoffHour ?? 4;

    return Card(
      child: Theme(
        // Remove ExpansionTile dividers
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: SemanticIcon(
            icon: AppIcons.tune,
            semanticLabel: 'Advanced settings',
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
          title: Text(
            context.l10n.settingsAdvancedTitle,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            context.l10n.settingsAdvancedDesc,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          initiallyExpanded: false,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Divider(),

                  // Ghost Mode Toggle
                  CNSwitchListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(context.l10n.ghostModeTitle)),
                        buildInfoTooltip(
                          context,
                          context.l10n.ghostModeTooltip,
                        ),
                      ],
                    ),
                    subtitle: Text(context.l10n.ghostModeDescription),
                    value: ghostEnabled,
                    onChanged: (value) async {
                      await ref
                          .read(ghostModeProvider.notifier)
                          .setEnabled(value);
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
                      icon: ghostEnabled
                          ? AppIcons.visibilityOff
                          : AppIcons.visibility,
                      semanticLabel: ghostEnabled ? 'Hidden' : 'Visible',
                      size: AppIconSize.medium,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Ghost Mode Customization (only when enabled)
                  if (ghostEnabled)
                    _buildGhostModeCustomization(context, ref, ghostConfig),

                  const Divider(),

                  // Day Cutoff Hour
                  buildSettingTile(
                    context,
                    title: context.l10n.settingsDayCutoffHour,
                    subtitle: context.l10n.settingsDayCutoffHourDesc(
                      dayCutoffHour,
                    ),
                    leading: const SemanticIcon(
                      icon: AppIcons.schedule,
                      semanticLabel: 'Schedule',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildInfoTooltip(
                          context,
                          context.l10n.dayCutoffTooltip,
                        ),
                        const SizedBox(width: 8),
                        const SemanticIcon(
                          icon: AppIcons.chevronRight,
                          semanticLabel: 'Edit',
                        ),
                      ],
                    ),
                    onTap: () => _showDayCutoffDialog(context, ref),
                  ),

                  const Divider(),

                  // Effort Scale (RPE vs RIR)
                  buildSettingTile(
                    context,
                    title: context.l10n.effortScale,
                    subtitle: config.effortScale == 'rpe'
                        ? context.l10n.rpeScale
                        : context.l10n.rirScale,
                    leading: const SemanticIcon(
                      icon: AppIcons.speed,
                      semanticLabel: 'Effort scale',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildInfoTooltip(
                          context,
                          context.l10n.effortScaleTooltip,
                        ),
                        const SizedBox(width: 8),
                        const SemanticIcon(
                          icon: AppIcons.chevronRight,
                          semanticLabel: 'Edit',
                        ),
                      ],
                    ),
                    onTap: () => _showEffortScaleDialog(
                      context,
                      ref,
                      config.effortScale,
                    ),
                  ),

                  const Divider(),

                  // Recalculate Stress Index
                  buildSettingTile(
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
                  buildSettingTile(
                    context,
                    title: context.l10n.resetTutorials,
                    subtitle: context.l10n.resetTutorialsDesc,
                    leading: const SemanticIcon(
                      icon: AppIcons.school,
                      semanticLabel: 'Reset tutorials',
                    ),
                    onTap: () => _showResetTutorialsDialog(context, ref),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Ghost Mode Customization ---

  Widget _buildGhostModeCustomization(
    BuildContext context,
    WidgetRef ref,
    dynamic config,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(context.l10n.ghostModeHideXP),
            value: config.hideXPProgress,
            onChanged: (value) {
              ref
                  .read(ghostModeProvider.notifier)
                  .updateConfigField('hideXPProgress', value: value ?? true);
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          CheckboxListTile(
            title: Text(context.l10n.ghostModeHideTier),
            value: config.hideTierBadge,
            onChanged: (value) {
              ref
                  .read(ghostModeProvider.notifier)
                  .updateConfigField('hideTierBadge', value: value ?? true);
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          CheckboxListTile(
            title: Text(context.l10n.ghostModeHideStreak),
            value: config.hideStreak,
            onChanged: (value) {
              ref
                  .read(ghostModeProvider.notifier)
                  .updateConfigField('hideStreak', value: value ?? false);
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
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
            dense: true,
          ),
          CheckboxListTile(
            title: Text(context.l10n.ghostModeHideAnimations),
            value: config.hideXPAnimations,
            onChanged: (value) {
              ref
                  .read(ghostModeProvider.notifier)
                  .updateConfigField('hideXPAnimations', value: value ?? true);
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

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
              CNSlider(
                value: selectedHour.toDouble(),
                min: 0,
                max: 23,
                step: 1.0,
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
}
