import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Quick barbell option for inline selection
class QuickBarbellOption {
  const QuickBarbellOption({
    required this.label,
    required this.weight,
    required this.icon,
  });

  final String label;
  final double? weight; // null = no barbell
  final IconData icon;
}

/// Inline chip-based barbell selector for quick 1-tap selection
class BarbellQuickSelector extends StatelessWidget {
  const BarbellQuickSelector({
    super.key,
    required this.selectedWeight,
    required this.onWeightSelected,
    required this.onOtherTapped,
  });

  final double? selectedWeight;
  final ValueChanged<double?> onWeightSelected;
  final VoidCallback onOtherTapped;

  /// Default quick options for common barbells
  static const List<QuickBarbellOption> defaultOptions = [
    QuickBarbellOption(label: '20kg', weight: 20.0, icon: AppIcons.workout),
    QuickBarbellOption(label: '15kg', weight: 15.0, icon: AppIcons.workout),
    QuickBarbellOption(label: 'No', weight: null, icon: AppIcons.block),
    QuickBarbellOption(label: 'EZ 7.5', weight: 7.5, icon: AppIcons.waves),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Quick selection chips
          ...defaultOptions.map((option) {
            final isSelected = _isSelected(option.weight);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _BarbellChip(
                label: option.label,
                icon: option.icon,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onWeightSelected(option.weight);
                },
              ),
            );
          }),

          // "Altro" chip for full bottom sheet
          _BarbellChip(
            label: context.l10n.other,
            icon: AppIcons.settings,
            isSelected: _isCustomWeight(),
            isOther: true,
            onTap: () {
              HapticFeedback.selectionClick();
              onOtherTapped();
            },
          ),
        ],
      ),
    );
  }

  bool _isSelected(double? weight) {
    if (weight == null && selectedWeight == null) return true;
    return selectedWeight == weight;
  }

  bool _isCustomWeight() {
    if (selectedWeight == null) return false;

    // Check if selected weight matches any quick option
    for (final option in defaultOptions) {
      if (option.weight == selectedWeight) return false;
    }

    // It's a custom weight not in quick options
    return true;
  }
}

class _BarbellChip extends StatelessWidget {
  const _BarbellChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isOther = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isOther;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;

    final foregroundColor = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline.withValues(alpha: 0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: icon,
                semanticLabel: label,
                size: AppIconSize.tiny,
                color: foregroundColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              if (isOther && isSelected) ...[
                const SizedBox(width: 4),
                SemanticIcon(
                  icon: AppIcons.check,
                  semanticLabel: 'Selected',
                  size: AppIconSize.tiny,
                  color: foregroundColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
