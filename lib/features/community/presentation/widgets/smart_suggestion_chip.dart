/// Smart Suggestion Chip - Minimal inline indicator
///
/// A simple, static chip that displays suggestions without
/// distracting animations. Tap opens info sheet.
/// Design matches WeightJumpIndicator for consistency.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/suggestion_info_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Minimal suggestion chip - no animations, just static display
/// Follows same pattern as WeightJumpIndicator
class SmartSuggestionChip extends StatelessWidget {
  const SmartSuggestionChip({
    super.key,
    required this.suggestion,
    required this.icon,
    this.onTap,
    this.onDismiss,
    this.fullSuggestion,
    this.showLabel = true,
    // Keep these for backwards compatibility but ignore them
    this.displayDuration = const Duration(seconds: 8),
    this.showBreathingAnimation = false,
    this.isMinimal = true,
  });

  final String suggestion;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final SmartSuggestion? fullSuggestion;

  /// Whether to show the text label next to the icon
  final bool showLabel;

  // Deprecated - kept for backwards compatibility
  final Duration displayDuration;
  final bool showBreathingAnimation;
  final bool isMinimal;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: suggestion,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: AppIconSize.tiny,
                  color: context.colors.primary,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      suggestion,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();

    // Show info sheet if full suggestion is available
    if (fullSuggestion != null) {
      showSuggestionInfoSheet(context, fullSuggestion!);
    }

    onTap?.call();
  }
}
