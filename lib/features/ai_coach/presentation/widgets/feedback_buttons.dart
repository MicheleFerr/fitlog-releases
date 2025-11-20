/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Feedback Buttons - User feedback UI for AI insights
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feedback_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/feedback_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/dismiss_reason_dialog.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Feedback Buttons Widget
///
/// Shows helpful/not helpful buttons for AI insights
///
/// Features:
/// - Helpful button (thumbs up)
/// - Not helpful button (thumbs down) → Opens dismiss reason dialog
/// - Compact layout
/// - Haptic feedback
/// - Loading state during submission
///
/// Usage:
/// ```dart
/// FeedbackButtons(
///   insightId: insight.id,
///   insightType: 'overtraining',
///   insightCategory: 'recovery',
///   onFeedbackSubmitted: () => print('Feedback submitted'),
/// )
/// ```
class FeedbackButtons extends ConsumerStatefulWidget {
  const FeedbackButtons({
    required this.insightId,
    required this.insightType,
    required this.insightCategory,
    this.onFeedbackSubmitted,
    this.viewDurationSeconds = 0,
    super.key,
  });

  final String insightId;
  final String insightType;
  final String insightCategory;
  final VoidCallback? onFeedbackSubmitted;
  final int viewDurationSeconds;

  @override
  ConsumerState<FeedbackButtons> createState() => _FeedbackButtonsState();
}

class _FeedbackButtonsState extends ConsumerState<FeedbackButtons> {
  bool _isSubmitting = false;

  Future<void> _handleHelpful() async {
    setState(() => _isSubmitting = true);

    try {
      await ref.read(feedbackProvider.notifier).markAsHelpful(
            insightId: widget.insightId,
            insightType: widget.insightType,
            insightCategory: widget.insightCategory,
            viewDurationSeconds: widget.viewDurationSeconds,
          );

      widget.onFeedbackSubmitted?.call();

      if (mounted) {
        // Show success message
        SnackBarService.showSuccess(
          context,
          context.l10n.feedbackThankYou,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleNotHelpful() async {
    // Show dismiss reason dialog
    final result = await showDialog<_DismissResult>(
      context: context,
      builder: (context) => const DismissReasonDialog(),
    );

    if (result == null) return; // User cancelled

    setState(() => _isSubmitting = true);

    try {
      await ref.read(feedbackProvider.notifier).markAsNotHelpful(
            insightId: widget.insightId,
            insightType: widget.insightType,
            insightCategory: widget.insightCategory,
            reason: result.reason,
            comment: result.comment,
            viewDurationSeconds: widget.viewDurationSeconds,
          );

      widget.onFeedbackSubmitted?.call();

      if (mounted) {
        // Show success message
        SnackBarService.showSuccess(
          context,
          context.l10n.feedbackThankYou,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Helpful button
        IconButton(
          onPressed: _isSubmitting ? null : _handleHelpful,
          tooltip: context.l10n.feedbackHelpful,
          icon: SemanticIcon(
            icon: AppIcons.thumbUp,
            semanticLabel: context.l10n.feedbackHelpful,
            size: AppIconSize.small,
            color: _isSubmitting
                ? context.colors.onSurfaceVariant.withValues(alpha: 0.5)
                : context.iconSuccess,
          ),
        ),

        const SizedBox(width: 4),

        // Not helpful button
        IconButton(
          onPressed: _isSubmitting ? null : _handleNotHelpful,
          tooltip: context.l10n.feedbackNotHelpful,
          icon: SemanticIcon(
            icon: AppIcons.thumbDown,
            semanticLabel: context.l10n.feedbackNotHelpful,
            size: AppIconSize.small,
            color: _isSubmitting
                ? context.colors.onSurfaceVariant.withValues(alpha: 0.5)
                : context.iconError,
          ),
        ),
      ],
    );
  }
}

/// Dismiss result data class
class _DismissResult {
  const _DismissResult({
    required this.reason,
    this.comment,
  });

  final DismissReason reason;
  final String? comment;
}
