import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/feedback_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Feedback Settings Screen
///
/// Allows user to configure haptic feedback preferences.
class FeedbackSettingsScreen extends ConsumerWidget {
  const FeedbackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(feedbackSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.feedbackSettings),
      ),
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.error,
                size: 64,
                color: context.colors.error,
              ),
              SizedBox(height: 16),
              Text(
                context.l10n.errorLoadingSettings,
                style: context.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, FeedbackSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Description Card
        Card(
          elevation: 0,
          color: context.colors.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                  Icon(
                    AppIcons.vibration,
                    color: context.colors.onPrimaryContainer,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.hapticDescription,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ),
        SizedBox(height: 24),

        // Enable/Disable Switch
        Card(
          elevation: 0,
          color: context.colors.surfaceContainerHighest,
          child: SwitchListTile(
            title: Text(context.l10n.enableHaptic),
            subtitle: Text(
              settings.hapticEnabled
                  ? 'Enabled'
                  : 'Disabled',
              style: context.textTheme.bodySmall?.copyWith(
                color: settings.hapticEnabled
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
            value: settings.hapticEnabled,
            onChanged: (value) async {
              await ref.read(feedbackSettingsProvider.notifier).toggleHaptic();

              // Provide immediate feedback
              if (value) {
                HapticFeedback.lightImpact();
                if (context.mounted) {
                  SnackBarService.showSuccess(
                    context,
                    context.l10n.feedbackSettingsSaved,
                  );
                }
              }
            },
            activeTrackColor: context.colors.primary,
          ),
        ),
        SizedBox(height: 16),

        // Intensity Selection
        Card(
          elevation: 0,
          color: context.colors.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.hapticIntensity,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                SegmentedButton<HapticIntensity>(
                  segments: [
                    ButtonSegment<HapticIntensity>(
                      value: HapticIntensity.light,
                      label: Text(context.l10n.intensityLight),
                      icon: Icon(AppIcons.circle, size: 12),
                    ),
                    ButtonSegment<HapticIntensity>(
                      value: HapticIntensity.medium,
                      label: Text(context.l10n.intensityMedium),
                      icon: Icon(AppIcons.circle, size: 16),
                    ),
                    ButtonSegment<HapticIntensity>(
                      value: HapticIntensity.heavy,
                      label: Text(context.l10n.intensityHeavy),
                      icon: const Icon(AppIcons.circle, size: 20),
                    ),
                  ],
                  selected: {settings.hapticIntensity},
                  onSelectionChanged: (Set<HapticIntensity> newSelection) async {
                    final intensity = newSelection.first;
                    await ref.read(feedbackSettingsProvider.notifier).updateHapticIntensity(intensity);

                    // Provide immediate feedback with selected intensity
                    if (settings.hapticEnabled) {
                      switch (intensity) {
                        case HapticIntensity.light:
                          HapticFeedback.lightImpact();
                          break;
                        case HapticIntensity.medium:
                          HapticFeedback.mediumImpact();
                          break;
                        case HapticIntensity.heavy:
                          HapticFeedback.heavyImpact();
                          break;
                      }
                    }

                    if (context.mounted) {
                      SnackBarService.showSuccess(
                        context,
                        context.l10n.feedbackSettingsSaved,
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return context.colors.primaryContainer;
                      }
                      return context.colors.surface;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
