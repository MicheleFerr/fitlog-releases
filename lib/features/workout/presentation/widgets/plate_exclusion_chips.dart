import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/gym_equipment_profiles_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Widget for temporarily excluding plates from the calculation
///
/// Allows users to tap on plate chips to exclude them (e.g., when plates
/// are in use by others at the gym). Excluded plates are shown with
/// strikethrough and different styling.
class PlateExclusionChips extends ConsumerWidget {
  const PlateExclusionChips({
    super.key,
    required this.availablePlates,
    this.onExclusionChanged,
  });

  /// List of all available plate weights from the current profile
  final List<double> availablePlates;

  /// Callback when exclusion state changes
  final VoidCallback? onExclusionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final excludedPlates = ref.watch(excludedPlatesProvider);
    final hasExclusions = excludedPlates.isNotEmpty;

    if (availablePlates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Text(
              context.l10n.availablePlatesTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasExclusions) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${excludedPlates.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Plate chips
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: availablePlates.map((plate) {
            final isExcluded = excludedPlates.contains(plate);
            return _PlateChip(
              weight: plate,
              isExcluded: isExcluded,
              onTap: () => _toggleExclusion(ref, plate, isExcluded),
            );
          }).toList(),
        ),

        // Exclusion warning and reset button
        if (hasExclusions) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.warning,
                  semanticLabel: 'Warning',
                  size: AppIconSize.small,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.platesExcludedWarning(excludedPlates.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _resetExclusions(ref),
                  icon: const SemanticIcon(
                    icon: AppIcons.undo,
                    semanticLabel: 'Reset',
                    size: AppIconSize.tiny,
                  ),
                  label: Text(context.l10n.resetExclusions),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _toggleExclusion(WidgetRef ref, double plate, bool isCurrentlyExcluded) {
    HapticFeedback.selectionClick();
    final notifier = ref.read(excludedPlatesProvider.notifier);
    final currentExclusions = ref.read(excludedPlatesProvider);

    if (isCurrentlyExcluded) {
      notifier.state = {...currentExclusions}..remove(plate);
    } else {
      notifier.state = {...currentExclusions, plate};
    }

    onExclusionChanged?.call();
  }

  void _resetExclusions(WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(excludedPlatesProvider.notifier).state = {};
    onExclusionChanged?.call();
  }
}

/// Individual plate chip with available/excluded states
class _PlateChip extends StatelessWidget {
  const _PlateChip({
    required this.weight,
    required this.isExcluded,
    required this.onTap,
  });

  final double weight;
  final bool isExcluded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Color based on plate weight (for visual distinction)
    final plateColor = _getPlateColor(weight, theme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isExcluded
                ? theme.colorScheme.surfaceContainerHighest
                : plateColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExcluded
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : plateColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status icon
              SemanticIcon(
                icon: isExcluded ? AppIcons.block : AppIcons.check,
                semanticLabel: isExcluded ? 'Excluded' : 'Available',
                size: AppIconSize.tiny,
                color: isExcluded
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : plateColor,
              ),
              const SizedBox(width: 4),
              // Weight text
              Text(
                '${weight}kg',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isExcluded
                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  decoration: isExcluded ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a color based on plate weight for visual distinction
  Color _getPlateColor(double weight, ThemeData theme) {
    // Standard color coding for Olympic plates
    if (weight >= 25) return const Color(0xFFE53935); // Red
    if (weight >= 20) return const Color(0xFF1E88E5); // Blue
    if (weight >= 15) return const Color(0xFFFFB300); // Yellow
    if (weight >= 10) return const Color(0xFF43A047); // Green
    if (weight >= 5) return const Color(0xFFEF5350); // White/Light red
    if (weight >= 2.5) return const Color(0xFF757575); // Gray
    return const Color(0xFF424242); // Dark gray for small plates
  }
}
