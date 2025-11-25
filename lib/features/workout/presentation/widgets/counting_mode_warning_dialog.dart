import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// 🎯 TIER-1: Warning dialog for counting mode changes with completed sets
///
/// Shows warning when user tries to change counting mode and has completed sets.
/// Returns user decision: cancelled, keep, or reset data.
enum CountingModeWarningAction {
  cancelled, // User cancelled the change
  keep,      // User wants to keep existing data
  reset,     // User wants to reset all data
}

class CountingModeWarningDialog {
  /// Show warning dialog and return user action
  static Future<CountingModeWarningAction> show(
    BuildContext context, {
    required int completedSetsCount,
    required String fromMode,
    required String toMode,
  }) async {
    HapticFeedback.mediumImpact();

    final result = await showDialog<CountingModeWarningAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CountingModeWarningDialogContent(
        completedSetsCount: completedSetsCount,
        fromMode: fromMode,
        toMode: toMode,
      ),
    );

    return result ?? CountingModeWarningAction.cancelled;
  }
}

class _CountingModeWarningDialogContent extends StatelessWidget {
  const _CountingModeWarningDialogContent({
    required this.completedSetsCount,
    required this.fromMode,
    required this.toMode,
  });

  final int completedSetsCount;
  final String fromMode;
  final String toMode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: context.colors.surface,
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.warningAmber,
            semanticLabel: context.l10n.warning,
            size: AppIconSize.large,
            color: context.iconWarning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.countingModeWarningTitle,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning message
          Text(
            context.l10n.countingModeWarningMessage(
              completedSetsCount,
              fromMode,
              toMode,
            ),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.warningContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: 'Info',
                  size: AppIconSize.small,
                  color: context.iconWarning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.countingModeWarningInfo,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop(CountingModeWarningAction.cancelled);
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colors.onSurface.withValues(alpha: 0.6),
          ),
          child: Text(context.l10n.cancel),
        ),

        // Keep data button
        TextButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop(CountingModeWarningAction.keep);
          },
          style: TextButton.styleFrom(
            foregroundColor: context.colors.primary,
          ),
          child: Text(context.l10n.keepData),
        ),

        // Reset button
        FilledButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.of(context).pop(CountingModeWarningAction.reset);
          },
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.warning,
            foregroundColor: context.colors.onWarning,
          ),
          child: Text(context.l10n.resetAll),
        ),
      ],
    );
  }
}
