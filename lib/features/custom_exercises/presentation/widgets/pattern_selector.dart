import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Movement patterns with Italian labels, icons, and descriptions
enum MovementPattern {
  push(
    'Push',
    AppIcons.arrowUpward,
    'Movimenti di spinta orizzontale o verticale (panca, shoulder press, pushup)',
  ),
  pull(
    'Pull',
    AppIcons.arrowDownward,
    'Movimenti di trazione orizzontale o verticale (trazioni, rematori, pulldown)',
  ),
  hinge(
    'Hinge',
    AppIcons.swapVert,
    'Movimenti a cerniera sui fianchi (stacco, hip thrust, good morning)',
  ),
  squat(
    'Squat',
    AppIcons.accessibilityNew,
    'Movimenti di accosciata (squat, leg press, affondi)',
  ),
  accessory(
    'Accessory',
    AppIcons.fitnessCenter,
    'Esercizi di isolamento o complementari (curl, alzate laterali, calf)',
  );

  const MovementPattern(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}

/// Widget for selecting movement pattern in custom exercise creation.
///
/// Features:
/// - Single-select pattern chips (Push/Pull/Hinge/Squat/Accessory)
/// - Icon + label for each pattern
/// - Info button with tooltip explaining each pattern
/// - Wrap layout for better space usage
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
    final colorScheme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              // Info button with tooltip
              _PatternInfoButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Wrap with filter chips
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: MovementPattern.values.map((pattern) {
            final isSelected = selectedPattern == pattern;
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    pattern.icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(pattern.label),
                ],
              ),
              onSelected: (_) => onPatternChanged(pattern),
              showCheckmark: false,
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
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
            );
          }).toList(),
        ),

        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, left: 4),
            child: Text(
              helperText!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}

/// Info button that shows a dialog explaining all movement patterns
class _PatternInfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return GestureDetector(
      onTap: () => _showPatternInfoDialog(context),
      child: Tooltip(
        message: context.l10n.info,
        child: Icon(
          AppIcons.info,
          size: 18,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  void _showPatternInfoDialog(BuildContext context) {
    final colorScheme = context.colors;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              AppIcons.help,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(context.l10n.movementPattern),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: MovementPattern.values.map((pattern) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        pattern.icon,
                        size: 20,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pattern.label,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pattern.description,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }
}
