import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/info_tooltip.dart';

/// Compact stat card for displaying key metrics in a grid layout
class CompactStatCard extends StatelessWidget {

  const CompactStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
    this.subtitle,
    this.trend,
    this.tooltipTitle,
    this.tooltipDescription,
    this.isMinimal = false, // New: compact mode for less vertical space
  });
  final String value;
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trend;
  final String? tooltipTitle;
  final String? tooltipDescription;
  final bool isMinimal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    // Minimal mode uses less padding, smaller icons, smaller text
    final cardPadding = isMinimal ? const EdgeInsets.all(8) : const EdgeInsets.all(16);
    final iconPadding = isMinimal ? const EdgeInsets.all(4) : const EdgeInsets.all(8);
    final iconSize = isMinimal ? 16.0 : 20.0;
    final borderRadius = isMinimal ? 12.0 : 16.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: cardPadding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and trend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: iconPadding,
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isMinimal ? 6 : 8),
                    ),
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: iconSize,
                    ),
                  ),
                  if (trend != null && !isMinimal) trend!,
                ],
              ),
              if (!isMinimal) const Spacer() else const SizedBox(height: 6),
              // Value
              Text(
                value,
                style: (isMinimal
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineMedium)?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isMinimal ? 2 : 4),
              // Label with optional tooltip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: isMinimal ? 10 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tooltipTitle != null && tooltipDescription != null && !isMinimal) ...[
                    const SizedBox(width: 4),
                    InfoTooltip(
                      title: tooltipTitle!,
                      description: tooltipDescription!,
                      iconSize: 16,
                    ),
                  ],
                ],
              ),
              if (subtitle != null && !isMinimal) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: effectiveColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}