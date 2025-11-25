/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Schermata per la review dei contributi inviati dalla community
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/community_corrections_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/widgets/correction_review_card.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class CommunityCorrectionsScreen extends ConsumerWidget {
  const CommunityCorrectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final corrections = ref.watch(communityCorrectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.rate_review,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.communityContributions),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(communityCorrectionsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: corrections.when(
        data: (correctionsList) {
          debugPrint('🎬 Admin screen received ${correctionsList.length} contributions');
          return _buildCorrectionsList(context, l10n, correctionsList, ref);
        },
        loading: () {
          debugPrint('⏳ Admin screen in loading state');
          return _buildLoadingState(context, l10n);
        },
        error: (error, _) {
          debugPrint('❌ Admin screen error: $error');
          return _buildErrorState(context, l10n, error.toString());
        },
      ),
    );
  }

  Widget _buildCorrectionsList(
    BuildContext context,
    AppLocalizations l10n,
    List<CommunityContribution> corrections,
    WidgetRef ref,
  ) {
    debugPrint('🎯 Building corrections list with ${corrections.length} contributions');

    if (corrections.isEmpty) {
      debugPrint('📭 No contributions found, showing empty state');
      return _buildEmptyState(context, l10n);
    }

    // Raggruppa correzioni per status
    final pendingCorrections = corrections.where((c) => c.status == ContributionStatus.pending).toList();
    final reviewedCorrections = corrections.where((c) => c.status != ContributionStatus.pending).toList();

    debugPrint('📋 Pending: ${pendingCorrections.length}, Reviewed: ${reviewedCorrections.length}');
    for (var contrib in corrections) {
      debugPrint('📄 Contribution: ${contrib.id} - ${contrib.type.name} - ${contrib.status.name} - ${contrib.title}');
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(communityCorrectionsProvider),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiche rapide
            _buildStatsCards(context, l10n, corrections),

            const SizedBox(height: 24),

            // Correzioni in pending
            if (pendingCorrections.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n.pendingCorrections,
                Icons.pending,
                context.colors.warning,
                pendingCorrections.length,
              ),
              const SizedBox(height: 12),
              ...pendingCorrections.map((correction) =>
                CorrectionReviewCard(
                  correction: correction,
                  onAction: (action) => _handleCorrectionAction(context, ref, correction, action),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Correzioni già revisionate
            if (reviewedCorrections.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n.reviewedCorrections,
                Icons.check_circle,
                context.colors.success,
                reviewedCorrections.length,
              ),
              const SizedBox(height: 12),
              ...reviewedCorrections.map((correction) =>
                CorrectionReviewCard(
                  correction: correction,
                  onAction: null, // Non permettere azioni su correzioni già revisionate
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, AppLocalizations l10n, List<CommunityContribution> corrections) {
    final pending = corrections.where((c) => c.status == ContributionStatus.pending).length;
    final approved = corrections.where((c) => c.status == ContributionStatus.approved).length;
    final rejected = corrections.where((c) => c.status == ContributionStatus.rejected).length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: l10n.pending,
            value: pending.toString(),
            icon: Icons.pending,
            color: context.colors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: l10n.approved,
            value: approved.toString(),
            icon: Icons.check_circle,
            color: context.colors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: l10n.rejected,
            value: rejected.toString(),
            icon: Icons.cancel,
            color: context.colors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading corrections...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingCorrections,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noCorrections,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noCorrectionsDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleCorrectionAction(
    BuildContext context,
    WidgetRef ref,
    CommunityContribution correction,
    CorrectionAction action,
  ) {
    switch (action) {
      case CorrectionAction.approve:
        _showApprovalDialog(context, ref, correction);
        break;
      case CorrectionAction.reject:
        _showRejectionDialog(context, ref, correction);
        break;
      case CorrectionAction.view:
        _showCorrectionDetails(context, correction);
        break;
    }
  }

  void _showApprovalDialog(BuildContext context, WidgetRef ref, CommunityContribution correction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).approveCorrection),
        content: Text(
          '${AppLocalizations.of(context).confirmApproval}\n\n'
          '${AppLocalizations.of(context).exercise}: ${correction.exerciseName}\n'
          '${AppLocalizations.of(context).suggestedBy}: ${correction.userName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(communityCorrectionsProvider.notifier).approveCorrection(correction.id);
            },
            child: Text(AppLocalizations.of(context).approve),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, WidgetRef ref, CommunityContribution correction) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).rejectCorrection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppLocalizations.of(context).exercise}: ${correction.exerciseName}\n'
              '${AppLocalizations.of(context).suggestedBy}: ${correction.userName}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).rejectionReason,
                hintText: AppLocalizations.of(context).rejectionReasonHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(communityCorrectionsProvider.notifier).rejectCorrection(
                correction.id,
                reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(AppLocalizations.of(context).reject),
          ),
        ],
      ),
    );
  }

  void _showCorrectionDetails(BuildContext context, CommunityContribution correction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(correction.exerciseName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(AppLocalizations.of(context).suggestedBy, correction.userName),
              _DetailRow(AppLocalizations.of(context).correctionType, correction.type.name),
              _DetailRow(AppLocalizations.of(context).currentValue, correction.originalValue ?? 'N/A'),
              _DetailRow(AppLocalizations.of(context).proposedValue, correction.suggestedValue ?? 'N/A'),
              _DetailRow(AppLocalizations.of(context).description, correction.description),
              _DetailRow(AppLocalizations.of(context).submittedAt, _formatDate(correction.createdAt)),
              if (correction.status != ContributionStatus.pending)
                _DetailRow(AppLocalizations.of(context).status, correction.status.name),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {

  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

enum CorrectionAction {
  approve,
  reject,
  view,
}