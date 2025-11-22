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
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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
        return DecoratedBox(
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
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
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
                        context.l10n.contributionDetails,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
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
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
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
                context.l10n.adminActions,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleApprove(),
                  icon: SemanticIcon(
  icon: AppIcons.complete,
  semanticLabel: 'Complete',
),
                  label: Text(context.l10n.approve),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.success,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _handleReject(),
                  icon: SemanticIcon(
  icon: AppIcons.cancel,
  semanticLabel: 'Cancel',
),
                  label: Text(context.l10n.reject),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.error.withValues(alpha: 0.2),
                    foregroundColor: context.colors.error,
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
              SemanticIcon(
  icon: AppIcons.commentOutlined,
  semanticLabel: 'Comment outlined',
  size: AppIconSize.small,
  color: theme.colorScheme.primary,
),
              const SizedBox(width: 8),
              Text(
                context.l10n.commentsCount(widget.contribution.comments.length),
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
                    SemanticIcon(
  icon: AppIcons.commentsDisabledOutlined,
  semanticLabel: 'Comments disabled outlined',
  size: AppIconSize.xxlarge,
  color: theme.colorScheme.outline.withValues(alpha: 0.5,
),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.noCommentsYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.beFirstToComment,
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
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
                  style: context.textTheme.labelSmall?.copyWith(
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
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: context.l10n.addCommentHint,
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
                : const SemanticIcon(
  icon: AppIcons.send,
  semanticLabel: 'Send',
),
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
        icon: const SemanticIcon(
  icon: AppIcons.flagOutlined,
  semanticLabel: 'Flag outlined',
),
        label: Text(context.l10n.reportContribution),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
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
        isUpvote ? context.l10n.upvoteSuccess : context.l10n.downvoteSuccess,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        context.l10n.errorWithMessage(e.toString()),
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
        context.l10n.commentAddedSuccess,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        context.l10n.errorWithMessage(e.toString()),
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
        context.l10n.contributionApprovedSuccess,
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        context.l10n.errorWithMessage(e.toString()),
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
        message: context.l10n.contributionRejectedSuccess,
        backgroundColor: context.colors.error,
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        context.l10n.errorWithMessage(e.toString()),
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
        context.l10n.reportSubmittedSuccess,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        context.l10n.errorWithMessage(e.toString()),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return context.l10n.weeksAgo((difference.inDays / 7).floor());
    } else if (difference.inDays > 0) {
      return context.l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return context.l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return context.l10n.minutesAgo(difference.inMinutes);
    } else {
      return context.l10n.justNow;
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
      title: Text(context.l10n.rejectContributionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.rejectReasonLabel,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: context.l10n.rejectReasonHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, _controller.text);
          },
          style: FilledButton.styleFrom(
            backgroundColor: context.colors.error,
          ),
          child: Text(context.l10n.reject),
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

  List<String> get _reportReasons => [
    context.l10n.reportReasonSpam,
    context.l10n.reportReasonOffensive,
    context.l10n.reportReasonWrongInfo,
    context.l10n.reportReasonDuplicate,
    context.l10n.reportReasonOther,
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
      title: Text(context.l10n.reportContributionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.reportReasonLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedReason = value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _reportReasons.map((reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )).toList(),
            ),
          ),
          if (_selectedReason == context.l10n.reportReasonOther) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: context.l10n.reportReasonOtherHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  final reason = _selectedReason == context.l10n.reportReasonOther
                      ? _controller.text
                      : _selectedReason!;
                  Navigator.pop(context, reason);
                },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: Text(context.l10n.reportAction),
        ),
      ],
    );
  }
}
