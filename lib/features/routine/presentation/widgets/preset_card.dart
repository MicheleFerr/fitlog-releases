/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// PRESET CARD WIDGET - Reusable Card for Routine Presets
///
/// Features:
/// - Display preset name (localized)
/// - Show days per week
/// - Selection indicator (checkmark/circle)
/// - Visual distinction (selected/unselected states)
/// - Tap handler for selection
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Preset Card Widget - Display routine preset with selection state
class PresetCard extends StatelessWidget {
  const PresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  /// Routine preset to display
  final RoutinePreset preset;

  /// Whether this preset is currently selected
  final bool isSelected;

  /// Callback when card is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 1,
      color: isSelected
          ? context.colors.primaryContainer
          : context.colors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Selection indicator (checkmark or circle)
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.outline,
                size: 32,
              ),
              const SizedBox(height: 12),

              // Preset name (displayName from enum extension)
              Text(
                preset.displayName,
                style: context.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? context.colors.onPrimaryContainer
                      : context.colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Days per week
              Text(
                '${preset.defaultTrainingDays.length} ${context.l10n.daysPerWeek}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? context.colors.onPrimaryContainer
                      : context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
