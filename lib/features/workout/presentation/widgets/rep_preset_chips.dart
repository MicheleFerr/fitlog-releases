/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
///
/// Rep preset chips for quick set/rep configuration
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/preset_selection_tracker.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/providers/preset_service_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/models/workout_preset.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Rep preset chips widget for quick selection
///
/// Features:
/// - 6 predefined rep ranges (1-3, 4-6, 6-8, 8-12, 12-15, 15+)
/// - Color-coded by training goal
/// - Icon-based visual feedback
/// - Tooltips with descriptions
/// - Localized labels and descriptions
/// - Configuration-driven via JSON presets
/// - Analytics tracking for preset selections
class RepPresetChips extends ConsumerWidget {
  const RepPresetChips({
    super.key,
    required this.onPresetSelected,
    this.selectedReps,
    this.source = 'rep_preset_chips',
    this.exerciseId,
  });

  final Function(int reps) onPresetSelected;
  final int? selectedReps;

  /// Source screen/modal for analytics tracking
  final String source;

  /// Optional exercise ID for per-exercise tracking
  final String? exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetService = ref.watch(presetServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = PresetSelectionTracker(analytics);

    return FutureBuilder<List<RepRangePreset>>(
      future: presetService.getRepRangePresets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final presets = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.speed,
                  size: 18,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  context.l10n.quickRepPresets,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((preset) {
                final isSelected = selectedReps == preset.reps;

                // Resolve localized label and description
                final label = _getLocalizedText(context, preset.labelKey);
                final description = _getLocalizedText(context, preset.descriptionKey);

                return Tooltip(
                  message: description,
                  child: FilterChip(
                    avatar: Icon(
                      preset.icon,
                      size: 16,
                      color: isSelected ? context.colors.surface : preset.color,
                    ),
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: preset.color,
                    backgroundColor: preset.color.withValues(alpha: 0.1),
                    checkmarkColor: context.colors.surface,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? context.colors.surface : context.colors.onSurface,
                      fontSize: 13,
                    ),
                    onSelected: (_) async {
                      // Track preset selection
                      await tracker.trackRepPresetSelected(
                        presetId: preset.id,
                        reps: preset.reps,
                        source: source,
                        exerciseId: exerciseId,
                      );

                      // Notify callback
                      onPresetSelected(preset.reps);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  /// Get localized text by key
  ///
  /// Maps localization keys to AppLocalizations getters
  String _getLocalizedText(BuildContext context, String key) {
    final l10n = context.l10n;

    switch (key) {
      // Rep preset labels
      case 'repPresetStrengthLabel':
        return l10n.repPresetStrengthLabel;
      case 'repPresetPowerLabel':
        return l10n.repPresetPowerLabel;
      case 'repPresetStrengthHypertrophyLabel':
        return l10n.repPresetStrengthHypertrophyLabel;
      case 'repPresetHypertrophyLabel':
        return l10n.repPresetHypertrophyLabel;
      case 'repPresetEnduranceLabel':
        return l10n.repPresetEnduranceLabel;
      case 'repPresetHighEnduranceLabel':
        return l10n.repPresetHighEnduranceLabel;

      // Rep preset descriptions
      case 'repPresetStrengthDescription':
        return l10n.repPresetStrengthDescription;
      case 'repPresetPowerDescription':
        return l10n.repPresetPowerDescription;
      case 'repPresetStrengthHypertrophyDescription':
        return l10n.repPresetStrengthHypertrophyDescription;
      case 'repPresetHypertrophyDescription':
        return l10n.repPresetHypertrophyDescription;
      case 'repPresetEnduranceDescription':
        return l10n.repPresetEnduranceDescription;
      case 'repPresetHighEnduranceDescription':
        return l10n.repPresetHighEnduranceDescription;

      default:
        return key; // Fallback to key if not found
    }
  }
}

/// Set count preset chips for quick set configuration
///
/// Features:
/// - 6 predefined set counts (1-6 sets)
/// - Consistent styling with rep presets
/// - Localized labels
/// - Configuration-driven via JSON presets
/// - Analytics tracking for preset selections
class SetCountPresetChips extends ConsumerWidget {
  const SetCountPresetChips({
    super.key,
    required this.onPresetSelected,
    this.selectedSets,
    this.source = 'set_count_preset_chips',
    this.exerciseId,
  });

  final Function(int sets) onPresetSelected;
  final int? selectedSets;

  /// Source screen/modal for analytics tracking
  final String source;

  /// Optional exercise ID for per-exercise tracking
  final String? exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetService = ref.watch(presetServiceProvider);
    final analytics = ref.read(analyticsServiceProvider);
    final tracker = PresetSelectionTracker(analytics);

    return FutureBuilder<List<SetCountPreset>>(
      future: presetService.getSetCountPresets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final presets = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.repeat,
                  size: 18,
                  color: context.colors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  context.l10n.quickSetCount,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((preset) {
                final isSelected = selectedSets == preset.sets;

                return FilterChip(
                  avatar: CircleAvatar(
                    backgroundColor: isSelected
                        ? context.colors.surface
                        : context.colors.primary.withValues(alpha: 0.2),
                    radius: 10,
                    child: Text(
                      '${preset.sets}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.onSurface,
                      ),
                    ),
                  ),
                  label: Text('${preset.sets} ${context.l10n.sets}'),
                  selected: isSelected,
                  selectedColor: context.colors.primary,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  checkmarkColor: context.colors.surface,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? context.colors.surface : context.colors.onSurface,
                    fontSize: 13,
                  ),
                  onSelected: (_) async {
                    // Track preset selection
                    await tracker.trackSetCountPresetSelected(
                      sets: preset.sets,
                      source: source,
                      exerciseId: exerciseId,
                    );

                    // Notify callback
                    onPresetSelected(preset.sets);
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
