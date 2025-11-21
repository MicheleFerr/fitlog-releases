/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Warning banner showing patch conflicts to admin
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/patch_conflict_detector.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Warning banner displaying patch conflicts
class ConflictWarningBanner extends StatelessWidget {
  const ConflictWarningBanner({
    required this.analysis,
    this.onTapDetails,
    super.key,
  });

  final ConflictAnalysis analysis;
  final VoidCallback? onTapDetails;

  @override
  Widget build(BuildContext context) {
    if (!analysis.hasConflicts) {
      return const SizedBox.shrink();
    }

    final highestSeverity = _getHighestSeverity();
    final color = _getSeverityColor(context, highestSeverity);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                AppIcons.warning,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠️ ${analysis.conflictSummary}',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onTapDetails != null)
                IconButton(
                  onPressed: onTapDetails,
                  icon: Icon(AppIcons.info, size: 18, color: color),
                  tooltip: 'View details',
                ),
            ],
          ),

          // Conflict list
          const SizedBox(height: 8),
          ...analysis.conflicts.map((conflict) => _buildConflictItem(
                context,
                conflict,
                color,
              )),

          // Blocking warning
          if (analysis.hasBlockingConflicts) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.error,
                    size: 16,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Blocking conflicts detected - requires manual review',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConflictItem(
    BuildContext context,
    PatchConflict conflict,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getConflictIcon(conflict.type),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conflict.message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
                if (conflict.currentValue != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Current value: "${conflict.currentValue}"',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (conflict.recommendedAction != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 ${conflict.recommendedAction}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ConflictSeverity _getHighestSeverity() {
    if (analysis.conflicts.any((c) => c.severity == ConflictSeverity.high)) {
      return ConflictSeverity.high;
    }
    if (analysis.conflicts.any((c) => c.severity == ConflictSeverity.medium)) {
      return ConflictSeverity.medium;
    }
    return ConflictSeverity.low;
  }

  Color _getSeverityColor(BuildContext context, ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.low:
        return context.colors.warning;
      case ConflictSeverity.medium:
        return const Color(0xFFFF6B00); // Dark orange
      case ConflictSeverity.high:
        return context.colors.error;
    }
  }

  IconData _getConflictIcon(ConflictType type) {
    switch (type) {
      case ConflictType.staleValue:
        return AppIcons.refresh;
      case ConflictType.duplicateField:
        return AppIcons.copy;
      case ConflictType.versionMismatch:
        return AppIcons.update;
      case ConflictType.exerciseDeleted:
        return AppIcons.delete;
      case ConflictType.fieldRemoved:
        return AppIcons.cancel;
    }
  }
}
