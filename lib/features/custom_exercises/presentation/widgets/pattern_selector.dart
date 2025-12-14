import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Movement patterns with Italian labels and icons
enum MovementPattern {
  push('Push', AppIcons.arrowUpward),
  pull('Pull', AppIcons.arrowDownward),
  hinge('Hinge', AppIcons.swapVert),
  squat('Squat', AppIcons.accessibilityNew),
  accessory('Accessory', AppIcons.fitnessCenter);

  const MovementPattern(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Widget for selecting movement pattern in custom exercise creation.
///
/// Features:
/// - Single-select pattern buttons (Push/Pull/Hinge/Squat/Accessory)
/// - Icon + label for each pattern
/// - Compact segmented button style
/// - Optional label and helper text
class PatternSelector extends StatelessWidget {
  const PatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternChanged,
    this.label,
    this.helperText,
  });

  /// Currently selected movement pattern
  final MovementPattern? selectedPattern;

  /// Callback when pattern selection changes
  final ValueChanged<MovementPattern> onPatternChanged;

  /// Optional label shown above selector
  final String? label;

  /// Optional helper text shown below selector
  final String? helperText;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
        ],

        SegmentedButton<MovementPattern>(
          segments: MovementPattern.values.map((pattern) {
            return ButtonSegment<MovementPattern>(
              value: pattern,
              label: Text(pattern.label),
              icon: Icon(pattern.icon),
            );
          }).toList(),
          selected: selectedPattern != null
              ? {selectedPattern!}
              : <MovementPattern>{},
          onSelectionChanged: (Set<MovementPattern> newSelection) {
            if (newSelection.isNotEmpty) {
              onPatternChanged(newSelection.first);
            }
          },
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),

        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              helperText!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
