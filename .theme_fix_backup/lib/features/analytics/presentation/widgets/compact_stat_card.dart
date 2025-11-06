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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: effectiveColor,
                      size: 20,
                    ),
                  ),
                  if (trend != null) trend!,
                ],
              ),
              const Spacer(),
              // Value
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              // Label with optional tooltip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (tooltipTitle != null && tooltipDescription != null) ...[
                    const SizedBox(width: 4),
                    InfoTooltip(
                      title: tooltipTitle!,
                      description: tooltipDescription!,
                      iconSize: 16,
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
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