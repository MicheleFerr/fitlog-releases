import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/stress_index/data/mappers/muscle_abbreviation_mapper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Muscle abbreviations with full Italian names
///
/// **SINGLE SOURCE OF TRUTH**: Uses MuscleAbbreviationMapper.
/// This getter provides the same data but from a centralized source.
Map<String, String> get muscleAbbreviations =>
    MuscleAbbreviationMapper.getAllMusclesForSelector();

/// Widget for selecting focus muscles in custom exercise creation.
///
/// Features:
/// - Multi-select FilterChips with checkmarks
/// - Italian muscle abbreviations with full name tooltips
/// - Warning when exceeding recommended muscle count (default: 3)
/// - Compact chip layout with wrapping
class MuscleChipSelector extends StatelessWidget {
  const MuscleChipSelector({
    super.key,
    required this.selectedMuscles,
    required this.onSelectionChanged,
    this.label,
    this.maxRecommended = 3,
  });

  /// Currently selected muscle abbreviations (e.g., ['PETT', 'TRIC'])
  final List<String> selectedMuscles;

  /// Callback when muscle selection changes
  final ValueChanged<List<String>> onSelectionChanged;

  /// Optional label shown above chips
  final String? label;

  /// Maximum recommended muscles before showing warning (default: 3)
  final int maxRecommended;

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

        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: muscleAbbreviations.entries.map((entry) {
            final isSelected = selectedMuscles.contains(entry.key);

            return FilterChip(
              label: Text(entry.key),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<String>.from(selectedMuscles);
                if (selected) {
                  newSelection.add(entry.key);
                } else {
                  newSelection.remove(entry.key);
                }
                onSelectionChanged(newSelection);
              },
              showCheckmark: true,
              tooltip: entry.value,
              selectedColor: context.colors.primary.withValues(alpha: 0.2),
              checkmarkColor: context.colors.primary,
            );
          }).toList(),
        ),

        if (selectedMuscles.length > maxRecommended)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  AppIcons.infoOutline,
                  size: 16,
                  color: context.colors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Consigliati max $maxRecommended muscoli primari',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
