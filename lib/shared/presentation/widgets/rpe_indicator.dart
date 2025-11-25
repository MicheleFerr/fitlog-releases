/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ No text to localize (RPE is universal)
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// Atomic widget for displaying RPE (Rate of Perceived Exertion) indicators
/// Extracted from exercise_list_item.dart for reusability and performance
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Atomic widget for displaying RPE (Rate of Perceived Exertion) indicator
///
/// RPE is a standardized scale (1-10) for measuring exercise intensity.
/// This widget provides consistent styling across the app.
///
/// Colors follow the standard RPE zones:
/// - 1-6: Green (easy/moderate)
/// - 7-8: Amber/Warning (challenging)
/// - 9-10: Red/Error (maximum effort)
class RpeIndicator extends StatelessWidget {
  const RpeIndicator({
    super.key,
    required this.rpe,
    this.showLabel = true,
    this.compact = false,
  });

  /// RPE value (1-10 scale)
  final int rpe;

  /// Whether to show "RPE" label prefix
  final bool showLabel;

  /// Use compact styling (smaller padding)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _getRpeColor(context, rpe);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
        : const EdgeInsets.symmetric(horizontal: 6, vertical: 2);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        showLabel ? 'RPE $rpe' : '$rpe',
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Get color based on RPE value following standard zones
  ///
  /// - 1-6: Success (green) - Easy to moderate
  /// - 7-8: Warning (amber) - Challenging
  /// - 9-10: Error (red) - Maximum effort
  static Color _getRpeColor(BuildContext context, int rpe) {
    if (rpe <= 6) return context.successColor;
    if (rpe <= 8) return context.warningColor;
    return context.errorColor;
  }

  /// Static utility to get RPE color without widget instance
  /// Useful when only the color is needed
  static Color getColor(BuildContext context, int rpe) {
    return _getRpeColor(context, rpe);
  }

  /// Get description text for RPE value
  /// Returns localization key for external translation
  static String getRpeDescription(int rpe) {
    if (rpe <= 4) return 'light';
    if (rpe <= 6) return 'moderate';
    if (rpe <= 7) return 'challenging';
    if (rpe <= 8) return 'hard';
    if (rpe <= 9) return 'veryHard';
    return 'maximal';
  }
}

/// Larger RPE indicator with description for modal/detail views
class RpeIndicatorExpanded extends StatelessWidget {
  const RpeIndicatorExpanded({
    super.key,
    required this.rpe,
  });

  final int rpe;

  @override
  Widget build(BuildContext context) {
    final color = RpeIndicator.getColor(context, rpe);
    final description = RpeIndicator.getRpeDescription(rpe);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // RPE number in circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rpe',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Description column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RPE',
                style: context.textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
              Text(
                description.toUpperCase(),
                style: context.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
