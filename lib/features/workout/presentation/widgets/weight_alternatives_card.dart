import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/plate_calculator_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Card that shows weight alternatives when exact target cannot be achieved
///
/// Displays:
/// - Warning that exact weight is not achievable
/// - List of nearby alternatives with plate breakdown
/// - Quick action to select an alternative
class WeightAlternativesCard extends StatelessWidget {
  const WeightAlternativesCard({
    super.key,
    required this.targetWeight,
    required this.alternatives,
    required this.onAlternativeSelected,
    this.onKeepTarget,
  });

  /// The original target weight that couldn't be achieved
  final double targetWeight;

  /// List of alternative plate calculations
  final List<PlateCalculation> alternatives;

  /// Callback when user selects an alternative weight
  final ValueChanged<double> onAlternativeSelected;

  /// Callback when user wants to keep the target (even if not exact)
  final VoidCallback? onKeepTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (alternatives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning header
          Row(
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
                  context.l10n.cannotReachExactWeight(targetWeight),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            context.l10n.alternativesAvailable,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          // Alternatives list
          ...alternatives.map((alt) => _AlternativeItem(
                calculation: alt,
                targetWeight: targetWeight,
                onSelect: () {
                  HapticFeedback.selectionClick();
                  onAlternativeSelected(alt.totalWeight);
                },
              )),

          const SizedBox(height: 12),

          // Keep target button
          if (onKeepTarget != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onKeepTarget!();
                },
                child: Text(context.l10n.keepTargetWeight(targetWeight)),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlternativeItem extends StatelessWidget {
  const _AlternativeItem({
    required this.calculation,
    required this.targetWeight,
    required this.onSelect,
  });

  final PlateCalculation calculation;
  final double targetWeight;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difference = calculation.totalWeight - targetWeight;
    final isLighter = difference < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Weight column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${calculation.totalWeight}kg',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      isLighter
                          ? '${difference.abs()}kg ${context.l10n.lighter}'
                          : '+${difference}kg ${context.l10n.heavier}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isLighter
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Plates description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.perSide,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        calculation.platesDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Select button
                FilledButton.tonal(
                  onPressed: onSelect,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(context.l10n.useThisWeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
