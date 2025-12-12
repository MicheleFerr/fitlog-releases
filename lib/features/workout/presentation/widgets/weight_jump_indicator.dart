/// Weight Jump Indicator - Minimal warning badge for weight jumps
///
/// A subtle, non-intrusive indicator that shows when a significant
/// weight jump is detected between sets. Tapping opens an info modal.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Minimal weight jump warning indicator
///
/// Shows a small warning badge when weight jump is detected.
/// Tapping opens a bottom sheet with detailed information.
class WeightJumpIndicator extends StatelessWidget {
  const WeightJumpIndicator({
    super.key,
    required this.minWeight,
    required this.maxWeight,
    this.showLabel = false,
  });

  final double minWeight;
  final double maxWeight;

  /// Whether to show a short label next to the icon
  final bool showLabel;

  /// Check if there's a significant weight jump (>100% increase)
  static bool hasWeightJump({
    required double? minWeight,
    required double? maxWeight,
  }) {
    if (minWeight == null || maxWeight == null) return false;
    if (minWeight <= 0) return false;
    return maxWeight > minWeight * 2;
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.weightJumpDetected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWeightJumpInfo(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.error.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.warning,
                  size: AppIconSize.tiny,
                  color: context.colors.error,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.weightJump,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWeightJumpInfo(BuildContext context) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => WeightJumpInfoSheet(
        minWeight: minWeight,
        maxWeight: maxWeight,
      ),
    );
  }
}

/// Bottom sheet with weight jump explanation and safety tips
class WeightJumpInfoSheet extends StatelessWidget {
  const WeightJumpInfoSheet({
    super.key,
    required this.minWeight,
    required this.maxWeight,
  });

  final double minWeight;
  final double maxWeight;

  @override
  Widget build(BuildContext context) {
    final jumpPercentage = ((maxWeight - minWeight) / minWeight * 100).round();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.warning,
                      color: context.colors.error,
                      size: AppIconSize.large,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.weightJumpDetected,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$jumpPercentage%',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weight details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WeightColumn(
                      label: context.l10n.minimumWeight,
                      weight: minWeight,
                      context: context,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        AppIcons.forwardIos,
                        color: context.colors.onSurfaceVariant,
                        size: AppIconSize.small,
                      ),
                    ),
                    _WeightColumn(
                      label: context.l10n.maximumWeight,
                      weight: maxWeight,
                      context: context,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Safety tips
              Text(
                context.l10n.safetyTips,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _SafetyTipItem(
                icon: AppIcons.checkCircle,
                text: context.l10n.weightJumpTip1,
                context: context,
              ),
              const SizedBox(height: 8),
              _SafetyTipItem(
                icon: AppIcons.checkCircle,
                text: context.l10n.weightJumpTip2,
                context: context,
              ),
              const SizedBox(height: 8),
              _SafetyTipItem(
                icon: AppIcons.checkCircle,
                text: context.l10n.weightJumpTip3,
                context: context,
              ),
              const SizedBox(height: 8),
              _SafetyTipItem(
                icon: AppIcons.checkCircle,
                text: context.l10n.weightJumpTip4,
                context: context,
              ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.understood),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightColumn extends StatelessWidget {
  const _WeightColumn({
    required this.label,
    required this.weight,
    required this.context,
    this.isHighlighted = false,
  });

  final String label;
  final double weight;
  final BuildContext context;
  final bool isHighlighted;

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? context.colors.error
                : context.colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SafetyTipItem extends StatelessWidget {
  const _SafetyTipItem({
    required this.icon,
    required this.text,
    required this.context,
  });

  final IconData icon;
  final String text;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppIconSize.small,
          color: context.colors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
