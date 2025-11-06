/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/widgets
/// 🎯 Feature: community
/// 🔧 Type: widget
///
/// Modal per visualizzare dettagli completi di un contributo community
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/admin_moderation_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/voting_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Modal per visualizzare dettagli completi di un contributo
class ContributionDetailModal extends ConsumerStatefulWidget {

  const ContributionDetailModal({
    super.key,
    required this.contribution,
  });
  final CommunityContribution contribution;

  @override
  ConsumerState<ContributionDetailModal> createState() => _ContributionDetailModalState();
}

class _ContributionDetailModalState extends ConsumerState<ContributionDetailModal> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmittingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAdminAsync = ref.watch(isAdminProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dettagli Contributo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(AppIcons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    // Contribution Card
                    VotingCard(
                      contribution: widget.contribution,
                      onUpvote: () => _handleVote(true),
                      onDownvote: () => _handleVote(false),
                      showActions: true,
                    ),

                    const SizedBox(height: 16),

                    // Admin Actions
                    if (isAdminAsync.asData?.value == true)
                      _buildAdminActions(theme),

                    // Comments Section
                    _buildCommentsSection(theme, l10n),

                    // Report Button
                    _buildReportButton(theme, l10n),
                  ],
                ),
              ),

              // Comment Input (Fixed at bottom)
              _buildCommentInput(theme, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminActions(ThemeData theme) {
    if (widget.contribution.status != ContributionStatus.pending) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.admin,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Azioni Admin',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleApprove(),
                  icon: const Icon(AppIcons.complete),
                  label: const Text('Approva'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _handleReject(),
                  icon: const Icon(AppIcons.cancel),
                  label: const Text('Rifiuta'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.commentOutlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Commenti (${widget.contribution.comments.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.contribution.comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      AppIcons.commentsDisabledOutlined,
                      size: 48,
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nessun commento ancora',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sii il primo a commentare!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...widget.contribution.comments.map((comment) => _buildCommentCard(comment, theme)),
        ],
      ),
    );
  }

  Widget _buildCommentCard(ContributionComment comment, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  comment.userName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Aggiungi un commento...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _isSubmittingComment ? null : _submitComment,
            icon: _isSubmittingComment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingIndicator(size: 20),
                  )
                : const Icon(AppIcons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () => _showReportDialog(),
        icon: const Icon(AppIcons.flagOutlined),
        label: const Text('Segnala contributo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3)),
        ),
      ),
    );
  }

  Future<void> _handleVote(bool isUpvote) async {
    try {
      await ref.read(contributionSubmissionProvider.notifier).voteOnContribution(
            widget.contribution.id,
            isUpvote,
          );

      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        isUpvote ? '👍 Voto positivo!' : '👎 Voto negativo',
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: $e',
      );
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmittingComment = true);

    try {
      // TODO: Implement comment submission
      // await ref.read(contributionSubmissionProvider.notifier).addComment(
      //       widget.contribution.id,
      //       content,
      //     );

      _commentController.clear();

      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        '💬 Commento aggiunto!',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  Future<void> _handleApprove() async {
    try {
      await ref.read(adminModerationProvider.notifier).approveContribution(
            widget.contribution.id,
          );

      if (!mounted) return;

      Navigator.pop(context);

      SnackBarService.showSuccess(
        context,
        '✅ Contributo approvato!',
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: $e',
      );
    }
  }

  Future<void> _handleReject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectDialog(),
    );

    if (reason == null || reason.trim().isEmpty) return;

    try {
      await ref.read(adminModerationProvider.notifier).rejectContribution(
            widget.contribution.id,
            reason,
          );

      if (!mounted) return;

      Navigator.pop(context);

      SnackBarService.showCustom(
        context,
        message: '🚫 Contributo rifiutato',
        backgroundColor: Colors.red,
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: $e',
      );
    }
  }

  Future<void> _showReportDialog() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _ReportDialog(),
    );

    if (reason == null || reason.trim().isEmpty) return;

    try {
      // TODO: Implement report submission
      // await ref.read(contributionSubmissionProvider.notifier).reportContribution(
      //       widget.contribution.id,
      //       reason,
      //     );

      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        '🚨 Segnalazione inviata',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: $e',
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} sett. fa';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}g fa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m fa';
    } else {
      return 'ora';
    }
  }
}

/// Dialog per rifiutare un contributo
class _RejectDialog extends StatefulWidget {
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Rifiuta Contributo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifica il motivo del rifiuto:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Es: Informazioni non accurate',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _controller.text);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Rifiuta'),
        ),
      ],
    );
  }
}

/// Dialog per segnalare un contributo
class _ReportDialog extends StatefulWidget {
  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _controller = TextEditingController();
  String? _selectedReason;

  final _reportReasons = [
    'Spam o pubblicità',
    'Contenuto offensivo',
    'Informazioni errate',
    'Duplicato',
    'Altro',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Segnala Contributo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motivo della segnalazione:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._reportReasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() => _selectedReason = value);
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              )),
          if (_selectedReason == 'Altro') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Specifica il motivo',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  final reason = _selectedReason == 'Altro'
                      ? _controller.text
                      : _selectedReason!;
                  Navigator.pop(context, reason);
                },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: const Text('Segnala'),
        ),
      ],
    );
  }
}
