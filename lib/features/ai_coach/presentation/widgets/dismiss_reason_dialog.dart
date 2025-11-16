/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Dismiss Reason Dialog - Captures why user dismissed insight
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feedback_data.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Dismiss Reason Dialog
///
/// Shows dialog with dismiss reason options when user marks insight
/// as not helpful.
///
/// Features:
/// - Radio button list of reasons
/// - Optional comment text field
/// - Material 3 design
/// - Cancel/Submit buttons
///
/// Returns: _DismissResult or null if cancelled
class DismissReasonDialog extends StatefulWidget {
  const DismissReasonDialog({super.key});

  @override
  State<DismissReasonDialog> createState() => _DismissReasonDialogState();
}

class _DismissReasonDialogState extends State<DismissReasonDialog> {
  DismissReason _selectedReason = DismissReason.notRelevant;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _DismissResult(
        reason: _selectedReason,
        comment: _commentController.text.isNotEmpty
            ? _commentController.text
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.feedbackWhyNotHelpful),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reason options
            _buildReasonRadio(
              DismissReason.alreadyKnow,
              context.l10n.dismissReasonAlreadyKnow,
            ),
            _buildReasonRadio(
              DismissReason.notRelevant,
              context.l10n.dismissReasonNotRelevant,
            ),
            _buildReasonRadio(
              DismissReason.incorrect,
              context.l10n.dismissReasonIncorrect,
            ),
            _buildReasonRadio(
              DismissReason.tooAdvanced,
              context.l10n.dismissReasonTooAdvanced,
            ),
            _buildReasonRadio(
              DismissReason.tooBasic,
              context.l10n.dismissReasonTooBasic,
            ),
            _buildReasonRadio(
              DismissReason.notInterested,
              context.l10n.dismissReasonNotInterested,
            ),
            _buildReasonRadio(
              DismissReason.other,
              context.l10n.dismissReasonOther,
            ),

            const SizedBox(height: 16),

            // Optional comment
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: context.l10n.feedbackCommentOptional,
                hintText: context.l10n.feedbackCommentHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.submit),
        ),
      ],
    );
  }

  Widget _buildReasonRadio(DismissReason reason, String label) {
    return RadioListTile<DismissReason>(
      value: reason,
      groupValue: _selectedReason,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedReason = value);
        }
      },
      title: Text(label),
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Dismiss result data class (internal)
class _DismissResult {
  const _DismissResult({
    required this.reason,
    this.comment,
  });

  final DismissReason reason;
  final String? comment;
}
