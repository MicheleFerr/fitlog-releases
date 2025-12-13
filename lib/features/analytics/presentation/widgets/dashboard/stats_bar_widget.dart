import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// StatsBarWidget - Displays key KPIs in a horizontal bar
///
/// Shows:
/// - Total Volume (formatted as k/M)
/// - Streak Days
/// - PR Count
class StatsBarWidget extends StatelessWidget {
  const StatsBarWidget({
    super.key,
    required this.totalVolume,
    required this.streakDays,
    required this.prCount,
    required this.measurementUnit,
    this.onVolumeTap,
    this.onStreakTap,
    this.onPRTap,
  });

  final double totalVolume;
  final int streakDays;
  final int prCount;
  final String measurementUnit;
  final VoidCallback? onVolumeTap;
  final VoidCallback? onStreakTap;
  final VoidCallback? onPRTap;

  /// Formats volume to display as k (thousands) or M (millions)
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      final millions = volume / 1000000;
      return '${millions.toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      final thousands = volume / 1000;
      return '${thousands.toStringAsFixed(1)}k';
    } else {
      return volume.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: AppIcons.barChart,
                value: _formatVolume(totalVolume),
                label: context.l10n.totalVolumeLabel,
                onTap: onVolumeTap,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: context.colors.outlineVariant,
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.streak,
                value: streakDays.toString(),
                label: context.l10n.streakDays,
                onTap: onStreakTap,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: context.colors.outlineVariant,
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.achievement,
                value: prCount.toString(),
                label: context.l10n.personalRecords,
                onTap: onPRTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: context.colors.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return content;
  }
}
