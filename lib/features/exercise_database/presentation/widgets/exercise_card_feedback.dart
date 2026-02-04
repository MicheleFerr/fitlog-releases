/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/widgets
/// 🎯 Feature: exercise_database
/// 🔧 Type: widget
///
/// Widget per segnalare problemi su esercizi (bug, suggerimenti, errori di testo)
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/presentation/providers/unified_feedback_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Widget button per segnalare problemi su esercizi
class ExerciseFeedbackButton extends ConsumerStatefulWidget {
  const ExerciseFeedbackButton({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.version,
  });

  /// ID dell'esercizio
  final String exerciseId;

  /// Nome dell'esercizio
  final String exerciseName;

  /// Versione dell'esercizio
  final String version;

  @override
  ConsumerState<ExerciseFeedbackButton> createState() =>
      _ExerciseFeedbackButtonState();

  /// Static method to show feedback via modern BottomSheetModal
  static Future<void> showFeedbackDialog(
    BuildContext context, {
    required String exerciseId,
    required String exerciseName,
    required String version,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ExerciseFeedbackBottomSheet(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        version: version,
      ),
    );
  }
}

class _ExerciseFeedbackButtonState
    extends ConsumerState<ExerciseFeedbackButton> {
  late TextEditingController _messageController;
  String _selectedType = 'SUGGESTION';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const SemanticIcon(
        icon: AppIcons.flagOutlined,
        semanticLabel: 'Flag outlined',
      ),
      tooltip: context.l10n.reportExerciseIssue,
      onPressed: _showFeedbackDialog,
    );
  }

  /// Mostra il dialog di feedback
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.reportExerciseIssue),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informazioni esercizio
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exerciseName,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'v${widget.version}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tipo di segnalazione
              Text(
                context.l10n.feedbackType,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'BUG',
                    child: Text(context.l10n.feedbackBug),
                  ),
                  DropdownMenuItem(
                    value: 'SUGGESTION',
                    child: Text(context.l10n.feedbackSuggestion),
                  ),
                  DropdownMenuItem(
                    value: 'TYPO',
                    child: Text(context.l10n.feedbackTypo),
                  ),
                  DropdownMenuItem(
                    value: 'OTHER',
                    child: Text(context.l10n.feedbackOther),
                  ),
                ].toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value ?? 'SUGGESTION';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Messaggio
              Text(
                context.l10n.describeProblem,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: context.l10n.describeProblem,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: Text(context.l10n.cancelFeedback),
          ),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submitFeedback,
            icon: _isSubmitting
                ? LoadingIndicator(size: 16, color: context.colors.onPrimary)
                : const SemanticIcon(
                    icon: AppIcons.send,
                    semanticLabel: 'Send',
                  ),
            label: Text(context.l10n.sendFeedback),
          ),
        ],
      ),
    );
  }

  /// Invia il feedback a Firestore
  Future<void> _submitFeedback() async {
    final message = _messageController.text.trim();

    // Validazione
    if (message.isEmpty) {
      SnackBarService.showError(context, context.l10n.feedbackRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.errorAuthenticationRequired,
          );
        }
        return;
      }

      // Create unified feedback with exercise metadata
      final feedback = UnifiedFeedback(
        id: '', // Auto-generated by repository
        userId: user.uid,
        type: UnifiedFeedbackType.exercise,
        status: UnifiedFeedbackStatus.open,
        severity: FeedbackSeverity.medium, // Default medium (was numeric 2)
        message: message,
        createdAt: DateTime.now(),
        metadata: {
          'exerciseId': widget.exerciseId,
          'exerciseName': widget.exerciseName,
          'version': widget.version,
          'feedbackType': _selectedType, // BUG, SUGGESTION, TYPO, OTHER
          'userEmail': user.email ?? '',
        },
        adminNotes: null,
        resolvedAt: null,
        updatedAt: null,
      );

      // Submit via unified repository (Riverpod)
      final repository = ref.read(unifiedFeedbackRepositoryProvider);
      debugPrint('📤 Submitting feedback: userId=${feedback.userId}, type=${feedback.type}, severity=${feedback.severity}');

      final result = await repository.submitFeedback(feedback);

      if (mounted) {
        result.fold(
          (failure) {
            debugPrint('❌ Feedback submission failed: ${failure.message}');
            SnackBarService.showError(context, context.l10n.feedbackSentError);
          },
          (feedbackId) {
            debugPrint('✅ Feedback submitted successfully with ID: $feedbackId');
            Navigator.of(context).pop();
            SnackBarService.showSuccess(
              context,
              context.l10n.feedbackSentSuccess,
            );

            // Reset form
            _messageController.clear();
            setState(() {
              _selectedType = 'SUGGESTION';
            });
          },
        );
      }
    } catch (e, stack) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.feedbackSentError);
      }
      debugPrint('❌ Error submitting feedback: $e\n$stack');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

/// Modern BottomSheetModal for exercise feedback
class _ExerciseFeedbackBottomSheet extends ConsumerStatefulWidget {
  const _ExerciseFeedbackBottomSheet({
    required this.exerciseId,
    required this.exerciseName,
    required this.version,
  });

  final String exerciseId;
  final String exerciseName;
  final String version;

  @override
  ConsumerState<_ExerciseFeedbackBottomSheet> createState() =>
      _ExerciseFeedbackBottomSheetState();
}

class _ExerciseFeedbackBottomSheetState
    extends ConsumerState<_ExerciseFeedbackBottomSheet> {
  late TextEditingController _messageController;
  String _selectedType = 'SUGGESTION';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final message = _messageController.text.trim();

    // Validazione
    if (message.isEmpty) {
      SnackBarService.showError(context, context.l10n.feedbackRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.errorAuthenticationRequired,
          );
        }
        return;
      }

      // Create unified feedback with exercise metadata
      final feedback = UnifiedFeedback(
        id: '', // Auto-generated by repository
        userId: user.uid,
        type: UnifiedFeedbackType.exercise,
        status: UnifiedFeedbackStatus.open,
        severity: FeedbackSeverity.medium,
        message: message,
        createdAt: DateTime.now(),
        metadata: {
          'exerciseId': widget.exerciseId,
          'exerciseName': widget.exerciseName,
          'version': widget.version,
          'feedbackType': _selectedType, // BUG, SUGGESTION, TYPO, OTHER
          'userEmail': user.email ?? '',
        },
        adminNotes: null,
        resolvedAt: null,
        updatedAt: null,
      );

      // Submit via unified repository (Riverpod)
      final repository = ref.read(unifiedFeedbackRepositoryProvider);
      debugPrint('📤 Submitting feedback: userId=${feedback.userId}, type=${feedback.type}, severity=${feedback.severity}');

      final result = await repository.submitFeedback(feedback);

      if (mounted) {
        result.fold(
          (failure) {
            debugPrint('❌ Feedback submission failed: ${failure.message}');
            SnackBarService.showError(context, context.l10n.feedbackSentError);
          },
          (feedbackId) {
            debugPrint('✅ Feedback submitted successfully with ID: $feedbackId');
            Navigator.of(context).pop();
            SnackBarService.showSuccess(
              context,
              context.l10n.feedbackSentSuccess,
            );
          },
        );
      }
    } catch (e, stack) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.feedbackSentError);
      }
      debugPrint('❌ Error submitting feedback: $e\n$stack');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: ColoredBox(
          color: context.colors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle + Title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Visual drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.l10n.reportProblem,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informazioni esercizio
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.colors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.exerciseName,
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v${widget.version}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tipo di segnalazione
                    Text(
                      context.l10n.feedbackType,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: context.colors.surfaceContainer,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'BUG',
                          child: Text(context.l10n.feedbackBug),
                        ),
                        DropdownMenuItem(
                          value: 'SUGGESTION',
                          child: Text(context.l10n.feedbackSuggestion),
                        ),
                        DropdownMenuItem(
                          value: 'TYPO',
                          child: Text(context.l10n.feedbackTypo),
                        ),
                        DropdownMenuItem(
                          value: 'OTHER',
                          child: Text(context.l10n.feedbackOther),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? 'SUGGESTION';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Messaggio
                    Text(
                      context.l10n.describeProblem,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      minLines: 3,
                      enabled: !_isSubmitting,
                      decoration: InputDecoration(
                        hintText: context.l10n.describeProblem,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        filled: true,
                        fillColor: context.colors.surfaceContainer,
                      ),
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Actions (bottom sticky)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: context.colors.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancelFeedback),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        icon: _isSubmitting
                            ? LoadingIndicator(
                                size: 16,
                                color: context.colors.onPrimary,
                              )
                            : const SemanticIcon(
                                icon: AppIcons.send,
                                semanticLabel: 'Send',
                              ),
                        label: Text(context.l10n.sendFeedback),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
