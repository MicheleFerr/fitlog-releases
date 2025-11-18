/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// PrBadgeHeader - Personal Record highlights for Exercise Detail Screen
///
/// **Purpose**: Displays top 3 personal records in compact horizontal layout
///
/// **Layout**:
/// ```
/// ┌─────────────────────────────────────────────────────────┐
/// │  🏆 Max Weight    💪 Est. 1RM    📊 Volume Record     │
/// │  100.0 kg         110.5 kg       5000.0 kg            │
/// └─────────────────────────────────────────────────────────┘
/// ```
///
/// **Features**:
/// - 3 PR badges: Max Weight, Estimated 1RM, Total Volume
/// - Theme-aware colors (primary, secondary, tertiary)
/// - Semantic icons for accessibility
/// - Localized labels
/// - Responsive layout (adapts to screen width)
///
/// **Usage**:
/// ```dart
/// PrBadgeHeader(records: exerciseRecords)
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_records.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// PR Badge Header Widget
///
/// **Displays**: Max Weight, Estimated 1RM, Total Volume Record
/// **Height**: ~80px (compact)
class PrBadgeHeader extends StatelessWidget {
  const PrBadgeHeader({
    required this.records,
    super.key,
  });

  final ExerciseRecords records;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Max Weight Record
          Expanded(
            child: _PrBadge(
              icon: AppIcons.achievement,
              label: 'Max Weight', // TODO(Phase 4.1): Replace with context.l10n.maxWeight
              value: '${records.maxWeightRecord.toStringAsFixed(1)} kg',
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 12),

          // Estimated 1RM
          Expanded(
            child: _PrBadge(
              icon: AppIcons.workout,
              label: 'Est. 1RM', // TODO(Phase 4.1): Replace with context.l10n.estimated1RM
              value: '${records.estimated1RM.toStringAsFixed(1)} kg',
              color: context.colors.secondary,
            ),
          ),
          const SizedBox(width: 12),

          // Total Volume Record
          Expanded(
            child: _PrBadge(
              icon: AppIcons.trendUp,
              label: 'Volume', // TODO(Phase 4.1): Replace with context.l10n.volumeRecord
              value: '${records.totalVolumeRecord.toStringAsFixed(0)} kg',
              color: context.colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual PR Badge (icon + label + value)
class _PrBadge extends StatelessWidget {
  const _PrBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          SemanticIcon(
            icon: icon,
            semanticLabel: '$label: $value',
            size: AppIconSize.small,
            color: color,
          ),
          const SizedBox(height: 2),

          // Value (emphasized)
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Label (subtle)
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
