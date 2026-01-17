/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/presentation/widgets
/// 🎯 Purpose: Help beginners understand fitness terminology
/// 🔧 Type: Reusable widget
///
/// Terminology Tooltip - Tap-to-show explanations for technical fitness terms
///
/// **Usage**:
/// ```dart
/// TerminologyTooltip(
///   term: context.l10n.personalRecord,
///   explanation: context.l10n.tooltipPRExplanation,
///   child: Text('PR'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Terminology types for pre-configured tooltips
enum TerminologyType {
  pr,
  rpe,
  volume,
  reps,
  avg,
}

/// A tap-to-show tooltip widget for fitness terminology
///
/// Wraps any widget and adds a tap handler that shows a bottom sheet
/// with an explanation of the term. Designed for beginners who may not
/// understand fitness jargon like "PR", "RPE", "Volume", etc.
class TerminologyTooltip extends StatelessWidget {
  const TerminologyTooltip({
    super.key,
    required this.term,
    required this.explanation,
    required this.child,
    this.showIndicator = true,
  });

  /// Factory constructor for pre-configured terminology types
  factory TerminologyTooltip.fromType({
    Key? key,
    required TerminologyType type,
    required BuildContext context,
    required Widget child,
    bool showIndicator = true,
  }) {
    final (term, explanation) = _getTerminologyData(type, context);
    return TerminologyTooltip(
      key: key,
      term: term,
      explanation: explanation,
      showIndicator: showIndicator,
      child: child,
    );
  }

  /// The technical term title (e.g., "Personal Record")
  final String term;

  /// The beginner-friendly explanation
  final String explanation;

  /// The widget to wrap (usually Text showing the term)
  final Widget child;

  /// Whether to show a small "?" indicator
  final bool showIndicator;

  static (String, String) _getTerminologyData(TerminologyType type, BuildContext context) {
    switch (type) {
      case TerminologyType.pr:
        return (context.l10n.tooltipPR, context.l10n.tooltipPRExplanation);
      case TerminologyType.rpe:
        return (context.l10n.tooltipRPE, context.l10n.tooltipRPEExplanation);
      case TerminologyType.volume:
        return (context.l10n.tooltipVolume, context.l10n.tooltipVolumeExplanation);
      case TerminologyType.reps:
        return (context.l10n.tooltipReps, context.l10n.tooltipRepsExplanation);
      case TerminologyType.avg:
        return (context.l10n.tooltipAvg, context.l10n.tooltipAvgExplanation);
    }
  }

  void _showExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TerminologyBottomSheet(
        term: term,
        explanation: explanation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showExplanation(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (showIndicator) ...[
            const SizedBox(width: 4),
            Icon(
              AppIcons.helpOutline,
              size: AppIconSize.tiny,
              color: context.colors.primary.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet content for terminology explanation
class _TerminologyBottomSheet extends StatelessWidget {
  const _TerminologyBottomSheet({
    required this.term,
    required this.explanation,
  });

  final String term;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppIcons.lightbulb,
                  color: context.colors.primary,
                  size: AppIconSize.medium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  term,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Explanation
          Text(
            explanation,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.ok),
            ),
          ),
        ],
      ),
    );
  }
}
