import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Equipment types with icons for visual identification
enum EquipmentType {
  bilanciere('Bilanciere', AppIcons.fitnessCenter),
  manubri('Manubri', AppIcons.fitnessCenter),
  cavi('Cavi', AppIcons.swapVert),
  macchina('Macchina', AppIcons.settings),
  corpoLibero('Corpo Libero', AppIcons.accessibility),
  kettlebell('Kettlebell', AppIcons.fitnessCenter),
  elastici('Elastici', AppIcons.straighten),
  trapBar('Trap Bar', AppIcons.fitnessCenter),
  pallaMedica('Palla Medica', AppIcons.sports),
  corde('Corde', AppIcons.straighten),
  zavorre('Zavorre', AppIcons.scale),
  assistito('Assistito', AppIcons.support),
  vario('Vario', AppIcons.category);

  const EquipmentType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Widget for selecting equipment in custom exercise creation.
///
/// Features:
/// - Single-select equipment chips with icons
/// - Wrap layout for flexible arrangement
/// - Clear visual distinction for selected state
/// - Compact design optimized for mobile
class EquipmentSelector extends StatelessWidget {
  const EquipmentSelector({
    super.key,
    required this.selectedEquipment,
    required this.onEquipmentChanged,
    this.label,
  });

  /// Currently selected equipment (string label)
  final String selectedEquipment;

  /// Callback when equipment selection changes
  final ValueChanged<String> onEquipmentChanged;

  /// Optional label shown above selector
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Wrap with filter chips
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: EquipmentType.values.map((equipment) {
            final isSelected = selectedEquipment == equipment.label;
            return FilterChip(
              selected: isSelected,
              label: Text(equipment.label),
              avatar: isSelected
                  ? null
                  : Icon(
                      equipment.icon,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
              onSelected: (_) => onEquipmentChanged(equipment.label),
              showCheckmark: true,
              checkmarkColor: colorScheme.onSecondaryContainer,
              selectedColor: colorScheme.secondaryContainer,
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.secondary
                    : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              labelStyle: context.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.xxs,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}
