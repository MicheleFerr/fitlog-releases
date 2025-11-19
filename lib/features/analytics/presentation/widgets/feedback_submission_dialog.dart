/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget (dialog)
///
/// FeedbackSubmissionDialog - Dialog for submitting correction feedback to admin
///
/// **Purpose**: Ask user if they want to report correction to admin for global fix
///
/// **UX Flow**:
/// 1. User saves correction locally → immediate UI effect
/// 2. This dialog appears asking "Report to admin?"
/// 3. User chooses:
///    - "Yes" → Submit to Firestore for admin review
///    - "No" → Keep local-only (no global fix)
/// 4. If yes → show success message + "You'll be notified when admin reviews"
///
/// **Features**:
/// - Clear explanation of what happens
/// - Two-button choice (Yes/No)
/// - Loading state during submission
/// - Success/error feedback
///
/// **Workflow After Submission**:
/// 1. Correction submitted → Firestore `muscle_group_feedback` collection
/// 2. Status = `pending`
/// 3. Admin reviews in Firestore console → changes status to `approved`/`rejected`
/// 4. Cloud Function triggers → sends FCM push notification
/// 5. User sees notification → opens app → correction applied globally (if approved)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/muscle_correction_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/mixins/safe_set_state_mixin.dart';

/// Dialog for submitting correction feedback to admin
///
/// **Usage**:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => FeedbackSubmissionDialog(
///     correction: correction,
///   ),
/// );
/// ```
class FeedbackSubmissionDialog extends ConsumerStatefulWidget {
  const FeedbackSubmissionDialog({
    required this.correction,
    super.key,
  });

  /// The correction to submit for admin review
  final MuscleCorrection correction;

  @override
  ConsumerState<FeedbackSubmissionDialog> createState() =>
      _FeedbackSubmissionDialogState();
}

class _FeedbackSubmissionDialogState
    extends ConsumerState<FeedbackSubmissionDialog>
    with SafeSetStateMixin {
  /// Loading state during submission
  bool _isSubmitting = false;

  /// Submit correction to admin (Firestore)
  Future<void> _submitToAdmin() async {
    safeSetState(() {
      _isSubmitting = true;
    });

    final result = await ref
        .read(muscleCorrectionRepositoryProvider)
        .submitFeedbackToAdmin(widget.correction);

    if (!mounted) return;

    safeSetState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) {
        // Show error
        SnackBarService.showError(
          context,
          failure.message,
        );
      },
      (_) {
        // Success
        HapticFeedback.mediumImpact();
        SnackBarService.showSuccess(
          context,
          context.l10n.feedbackSubmittedSuccess,
        );

        // Close dialog
        Navigator.of(context).pop(true); // Return true = submitted
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.send,
            semanticLabel: context.l10n.reportToAdmin,
            color: colors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.reportToAdmin,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explanation
          Text(
            context.l10n.reportToAdminExplanation,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Correction summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name
                Text(
                  widget.correction.exerciseName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Old → New
                Row(
                  children: [
                    // Old (incorrect)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SemanticIcon(
                              icon: AppIcons.close,
                              semanticLabel: 'Incorrect muscle group',
                              size: 14,
                              color: colors.error,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.correction.oldMuscleGroup,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Arrow
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SemanticIcon(
                        icon: AppIcons.chevronRight,
                        semanticLabel: 'Changes to',
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    // New (correct)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SemanticIcon(
                              icon: AppIcons.check,
                              semanticLabel: 'Correct muscle group',
                              size: 14,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.correction.newMuscleGroup,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: context.l10n.adminWillReviewNotification,
                  size: 20,
                  color: colors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.adminWillReviewNotification,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // No button
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false), // Return false = not submitted
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            context.l10n.noKeepLocal,
            style: textTheme.labelLarge,
          ),
        ),

        // Yes button
        FilledButton(
          onPressed: _isSubmitting ? null : _submitToAdmin,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: LoadingIndicator(
                    color: colors.onPrimary,
                    size: 18,
                  ),
                )
              : Text(
                  context.l10n.yesReportToAdmin,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
