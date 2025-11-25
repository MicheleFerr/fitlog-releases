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

  /// Static method to show feedback dialog programmatically
  static Future<void> showFeedbackDialog(
    BuildContext context, {
    required String exerciseId,
    required String exerciseName,
    required String version,
  }) async {
    final messageController = TextEditingController();
    String selectedType = 'SUGGESTION';
    bool isSubmitting = false;

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Segnala problema'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informazioni esercizio
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v$version',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tipo di segnalazione
                Text(
                  'Tipo di segnalazione',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'BUG', child: Text('🐛 Bug')),
                    DropdownMenuItem(value: 'SUGGESTION', child: Text('💡 Suggerimento')),
                    DropdownMenuItem(value: 'TYPO', child: Text('📝 Errore di testo')),
                    DropdownMenuItem(value: 'OTHER', child: Text('❓ Altro')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? 'SUGGESTION';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Messaggio
                Text(
                  'Descrivi il problema',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Descrivi il problema in dettaglio...',
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
              onPressed: isSubmitting ? null : () {
                Navigator.of(context).pop();
                messageController.dispose();
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : () async {
                final message = messageController.text.trim();

                if (message.isEmpty) {
                  SnackBarService.showError(context, context.l10n.feedbackRequired);
                  return;
                }

                setState(() { isSubmitting = true; });

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    SnackBarService.showError(context, context.l10n.errorAuthenticationRequired);
                    return;
                  }

                  // Get unified feedback repository from Riverpod container
                  final container = ProviderScope.containerOf(context);
                  final repository = container.read(unifiedFeedbackRepositoryProvider);

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
                      'exerciseId': exerciseId,
                      'exerciseName': exerciseName,
                      'version': version,
                      'feedbackType': selectedType, // BUG, SUGGESTION, TYPO, OTHER
                      'userEmail': user.email ?? '',
                    },
                    adminNotes: null,
                    resolvedAt: null,
                    updatedAt: null,
                  );

                  // Submit via unified repository
                  final result = await repository.submitFeedback(feedback);

                  if (context.mounted) {
                    result.fold(
                      (failure) {
                        SnackBarService.showError(context, context.l10n.error);
                      },
                      (feedbackId) {
                        Navigator.of(context).pop();
                        SnackBarService.showSuccess(context, context.l10n.feedbackSentSuccess);
                      },
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    SnackBarService.showError(context, context.l10n.feedbackSentError);
                  }
                  debugPrint('❌ Error submitting feedback: $e');
                } finally {
                  messageController.dispose();
                  if (context.mounted) {
                    setState(() { isSubmitting = false; });
                  }
                }
              },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SemanticIcon(
  icon: AppIcons.send,
  semanticLabel: 'Send',
),
              label: const Text('Invia'),
            ),
          ],
        ),
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
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.onPrimary,
                      ),
                    ),
                  )
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
      SnackBarService.showError(
        context,
        context.l10n.feedbackRequired,
      );
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
      final result = await repository.submitFeedback(feedback);

      if (mounted) {
        result.fold(
          (failure) {
            SnackBarService.showError(
              context,
              context.l10n.feedbackSentError,
            );
          },
          (feedbackId) {
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
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.feedbackSentError,
        );
      }
      debugPrint('❌ Error submitting feedback: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
