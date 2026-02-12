import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/widgets/exercise_card_preview.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/cn_switch_list_tile.dart';

/// Settings section for Exercise Card customization
///
/// Provides controls for:
/// - GIF size (small/medium/large/hidden)
/// - Card density (compact/standard/extended)
/// - Toggle elements (insight, timer, plates, RPE)
/// - Footer elements (tips, TUT, notes)
/// - Footer expanded by default toggle
/// - Preset configurations
///
/// Includes live preview that updates in real-time.
class ExerciseCardSettingsSection extends ConsumerWidget {
  const ExerciseCardSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(exerciseCardSettingsProvider);
    final notifier = ref.read(exerciseCardSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                AppIcons.workout,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.exerciseCardSettings,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Live preview
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.preview,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const ExerciseCardPreview(),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // GIF Size
        _buildSegmentedControl<ExerciseGifSize>(
          context,
          title: context.l10n.gifSize,
          subtitle: context.l10n.gifSizeDescription,
          value: settings.gifSize,
          values: ExerciseGifSize.values,
          labels: {
            ExerciseGifSize.small: context.l10n.small,
            ExerciseGifSize.medium: context.l10n.medium,
            ExerciseGifSize.large: context.l10n.large,
            ExerciseGifSize.hidden: context.l10n.hidden,
          },
          onChanged: (value) => notifier.setGifSize(value),
        ),
        const SizedBox(height: 16),

        // Card Density
        _buildSegmentedControl<ExerciseCardDensity>(
          context,
          title: context.l10n.cardDensity,
          subtitle: context.l10n.cardDensityDescription,
          value: settings.density,
          values: ExerciseCardDensity.values,
          labels: {
            ExerciseCardDensity.compact: context.l10n.compact,
            ExerciseCardDensity.standard: context.l10n.standard,
            ExerciseCardDensity.extended: context.l10n.expanded,
          },
          onChanged: (value) => notifier.setDensity(value),
        ),
        const SizedBox(height: 16),

        // Toggle switches section
        _buildToggleSection(context, settings, notifier),
        const SizedBox(height: 16),

        // Footer elements section
        _buildFooterElementsSection(context, settings, notifier),
        const SizedBox(height: 16),

        // Presets section
        _buildPresetsSection(context, notifier),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSegmentedControl<T extends Enum>(
    BuildContext context, {
    required String title,
    required String subtitle,
    required T value,
    required List<T> values,
    required Map<T, String> labels,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              segments: values
                  .map((v) => ButtonSegment<T>(
                        value: v,
                        label: Text(
                          labels[v] ?? v.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ))
                  .toList(),
              selected: {value},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  onChanged(selected.first);
                }
              },
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection(
    BuildContext context,
    ExerciseCardSettings settings,
    ExerciseCardSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.showElements,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Insight toggle
        CNSwitchListTile(
          title: Text(context.l10n.showInsight),
          subtitle: Text(context.l10n.showInsightDescription),
          value: settings.showInsight,
          onChanged: (value) => notifier.setShowInsight(value),
          secondary: Icon(
            AppIcons.insights,
            color: settings.showInsight
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
        ),
        // Timer toggle
        CNSwitchListTile(
          title: Text(context.l10n.showTimer),
          subtitle: Text(context.l10n.showTimerDescription),
          value: settings.showTimer,
          onChanged: (value) => notifier.setShowTimer(value),
          secondary: Icon(
            AppIcons.timer,
            color: settings.showTimer
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
        ),
        // Plates toggle
        CNSwitchListTile(
          title: Text(context.l10n.showPlates),
          subtitle: Text(context.l10n.showPlatesDescription),
          value: settings.showPlates,
          onChanged: (value) => notifier.setShowPlates(value),
          secondary: Icon(
            AppIcons.calculateRounded,
            color: settings.showPlates
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
        ),
        // RPE toggle
        CNSwitchListTile(
          title: Text(context.l10n.showRpe),
          subtitle: Text(context.l10n.showRpeDescription),
          value: settings.showRpe,
          onChanged: (value) => notifier.setShowRpe(value),
          secondary: Icon(
            AppIcons.speed,
            color: settings.showRpe
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterElementsSection(
    BuildContext context,
    ExerciseCardSettings settings,
    ExerciseCardSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.footerElements,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.footerElementsDescription,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Element chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExerciseFooterElement.values.map((element) {
              final isSelected = settings.footerElements.contains(element);
              return FilterChip(
                label: Text(element.label),
                selected: isSelected,
                onSelected: (_) => notifier.toggleFooterElement(element),
                avatar: Icon(
                  _getElementIcon(element),
                  size: 18,
                  color: isSelected
                      ? context.colors.onPrimaryContainer
                      : context.colors.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Footer expanded by default
        CNSwitchListTile(
          title: Text(context.l10n.footerExpandedByDefault),
          subtitle: Text(context.l10n.footerExpandedByDefaultDescription),
          value: settings.footerExpanded,
          onChanged: (value) => notifier.setFooterExpanded(value),
          secondary: Icon(
            settings.footerExpanded ? AppIcons.expand : AppIcons.unfoldLess,
            color: settings.footerExpanded
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsSection(
    BuildContext context,
    ExerciseCardSettingsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.presets,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.presetsDescription,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PresetChip(
                label: context.l10n.presetBeginner,
                icon: AppIcons.school,
                color: context.colors.tertiary,
                onTap: () => notifier.applyPreset(ExerciseCardPresets.beginnerSettings),
              ),
              _PresetChip(
                label: context.l10n.presetPowerUser,
                icon: AppIcons.bolt,
                color: context.colors.primary,
                onTap: () => notifier.applyPreset(ExerciseCardPresets.powerUserSettings),
              ),
              _PresetChip(
                label: context.l10n.presetEfficient,
                icon: AppIcons.speed,
                color: context.colors.secondary,
                onTap: () => notifier.applyPreset(ExerciseCardPresets.efficientSettings),
              ),
              _PresetChip(
                label: context.l10n.presetMinimal,
                icon: AppIcons.visibility,
                color: context.colors.outline,
                onTap: () => notifier.applyPreset(ExerciseCardPresets.minimalSettings),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Reset to defaults
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => notifier.resetToDefaults(),
            icon: const Icon(AppIcons.refresh),
            label: Text(context.l10n.resetToDefaults),
          ),
        ),
      ],
    );
  }

  IconData _getElementIcon(ExerciseFooterElement element) {
    switch (element) {
      case ExerciseFooterElement.tips:
        return AppIcons.lightbulb;
      case ExerciseFooterElement.tut:
        return AppIcons.timer;
      case ExerciseFooterElement.notes:
        return AppIcons.notes;
    }
  }
}

/// Styled chip for preset selection
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: onTap,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}
