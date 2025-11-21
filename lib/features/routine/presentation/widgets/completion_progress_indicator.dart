/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/widgets
/// 🎯 Feature: flexible_routine
/// 🔧 Type: widget
/// 🌍 Localization: Required (context.l10n)
/// 📱 Platform: Universal
///
/// COMPLETION PROGRESS INDICATOR WIDGET - Progress Visualization
///
/// Features:
/// - Display progress percentage (0-100%)
/// - Visual linear progress bar
/// - Descriptive text (e.g., "3 out of 6 days assigned")
/// - Theme-aware colors (primary for progress)
/// - Material 3 design system compliance
/// - Used in RoutineCreationStep2Screen to show template assignment progress
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Completion Progress Indicator - Show completion progress with bar and text
class CompletionProgressIndicator extends StatelessWidget {
  const CompletionProgressIndicator({
    super.key,
    required this.completedCount,
    required this.totalCount,
    this.label,
  });

  /// Number of completed items
  final int completedCount;

  /// Total number of items
  final int totalCount;

  /// Optional label (e.g., "days assigned", "exercises completed")
  /// If null, defaults to context.l10n.completed
  final String? label;

  /// Calculate progress percentage (0.0 - 1.0)
  double get progress {
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  /// Calculate progress percentage for display (0-100)
  int get progressPercentage => (progress * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colors.primary,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: "X out of Y {label}"
            Text(
              '$completedCount ${context.l10n.outOf} $totalCount ${label ?? context.l10n.completed}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            // Right: "X%"
            Text(
              '$progressPercentage%',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
