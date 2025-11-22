/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Admin screen for reviewing user-submitted exercise patches
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_patch_review_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/widgets/patch_review_card.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/analytics/trackers/patch_event_tracker.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class ExercisePatchReviewScreen extends ConsumerWidget {
  const ExercisePatchReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final patchesAsync = ref.watch(exercisePatchReviewProvider);

    // Track screen view and pending patches count
    patchesAsync.whenData((patches) {
      final pendingCount = patches.where((p) => p.isPending).length;
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = PatchEventTracker(analytics);
      tracker.trackPatchReviewOpened(
        pendingCount: pendingCount,
        source: 'admin_panel',
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              AppIcons.rateReview,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.exercisePatchReview),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(exercisePatchReviewProvider),
            icon: const SemanticIcon(
  icon: AppIcons.refresh,
  semanticLabel: 'Refresh',
),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: patchesAsync.when(
        data: (patches) {
          debugPrint('🎬 Patch Review: ${patches.length} patches loaded');
          return _buildPatchesList(context, l10n, patches, ref);
        },
        loading: () {
          debugPrint('⏳ Patch Review: Loading...');
          return _buildLoadingState(context, l10n);
        },
        error: (error, _) {
          debugPrint('❌ Patch Review error: $error');
          return _buildErrorState(context, l10n, error.toString());
        },
      ),
    );
  }

  Widget _buildPatchesList(
    BuildContext context,
    AppLocalizations l10n,
    List<ExercisePatch> patches,
    WidgetRef ref,
  ) {
    if (patches.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    // Group patches by status
    final pendingPatches =
        patches.where((p) => p.isPending).toList();
    final reviewedPatches =
        patches.where((p) => !p.isPending).toList();

    debugPrint(
      '📋 Pending: ${pendingPatches.length}, Reviewed: ${reviewedPatches.length}',
    );

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(exercisePatchReviewProvider),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            _buildStatsCards(context, l10n, patches),

            const SizedBox(height: 24),

            // Pending patches (priority)
            if (pendingPatches.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n.pendingPatches,
                AppIcons.pending,
                context.colors.warning,
              ),
              const SizedBox(height: 12),
              ...pendingPatches.map(
                (patch) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PatchReviewCard(
                    patch: patch,
                    onApprove: () => _handleApprove(context, ref, patch),
                    onReject: () => _handleReject(context, ref, patch),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Reviewed patches (history)
            if (reviewedPatches.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                l10n.reviewedPatches,
                AppIcons.checkCircle,
                context.colors.success,
              ),
              const SizedBox(height: 12),
              ...reviewedPatches.map(
                (patch) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PatchReviewCard(
                    patch: patch,
                    readOnly: true,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    AppLocalizations l10n,
    List<ExercisePatch> patches,
  ) {
    final pending = patches.where((p) => p.isPending).length;
    final approved = patches.where((p) => p.isApproved).length;
    final rejected = patches.where((p) => p.isRejected).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.pending,
            pending.toString(),
            AppIcons.pending,
            context.colors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.approved,
            approved.toString(),
            AppIcons.checkCircle,
            context.colors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.rejected,
            rejected.toString(),
            AppIcons.cancel,
            context.colors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: context.colors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingPatches,
            style: context.textTheme.bodyLarge,
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
          SemanticIcon(
  icon: AppIcons.checkCircle,
  semanticLabel: 'Complete',
  size: AppIconSize.medium,
  color: context.colors.success.withValues(alpha: 0.5,
),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noPatchesToReview,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.allPatchesReviewed,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String error,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
  size: AppIconSize.medium,
  color: context.colors.error,
),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingPatches,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    ExercisePatch patch,
  ) async {
    final l10n = context.l10n;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.checkCircle, color: context.colors.success),
            const SizedBox(width: 8),
            const Text('Approve Patch'),
          ],
        ),
        content: Text(
          'Approve correction for ${patch.fieldName}?\n\n'
          'Old: ${patch.oldValue}\n'
          'New: ${patch.newValue}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Execute approval
      final approveAction = ref.read(approvePatchProvider);
      await approveAction(patch.id, null);

      // Haptic feedback for success
      // ignore: unawaited_futures
      // ignore: unawaited_futures
      HapticFeedback.mediumImpact();

      // Track analytics
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = PatchEventTracker(analytics);
      await tracker.trackPatchApproved(
        patchId: patch.id,
        exerciseId: patch.exerciseId,
        fieldName: patch.fieldName,
        source: 'patch_review_screen',
      );

      if (!context.mounted) return;

      SnackBarService.showSuccess(
        context,
        '${l10n.patchApproved} (${patch.fieldName})',
      );
    } catch (e) {
      if (!context.mounted) return;

      // Haptic feedback for error
      HapticFeedback.vibrate();
      // ignore: unawaited_futures

      SnackBarService.showError(
        context,
        'Error approving patch: $e',
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    ExercisePatch patch,
  ) async {
    final l10n = context.l10n;

    // Show reason dialog
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.cancel, color: context.colors.error),
            const SizedBox(width: 8),
            const Text('Reject Patch'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject correction for ${patch.fieldName}?',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Explain why this patch is rejected...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                SnackBarService.showError(
                  context,
                  'Rejection reason is required',
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true || reasonController.text.trim().isEmpty) return;

    try {
      // Execute rejection
      final rejectAction = ref.read(rejectPatchProvider);
      await rejectAction(
        patch.id,
        reasonController.text.trim(),
        null, // adminNote
      );

      // Haptic feedback for rejection
      HapticFeedback.lightImpact();
      // ignore: unawaited_futures

      // Track analytics
      final analytics = ref.read(analyticsServiceProvider);
      final tracker = PatchEventTracker(analytics);
      await tracker.trackPatchRejected(
        patchId: patch.id,
        exerciseId: patch.exerciseId,
        fieldName: patch.fieldName,
        adminNote: reasonController.text.trim(),
        source: 'patch_review_screen',
      );

      if (!context.mounted) return;

      SnackBarService.showSuccess(
        context,
        '${l10n.patchRejected} (${patch.fieldName})',
      );
    } catch (e) {
      if (!context.mounted) return;

      // Haptic feedback for error
      HapticFeedback.vibrate();
      // ignore: unawaited_futures

      SnackBarService.showError(
        context,
        'Error rejecting patch: $e',
      );
    } finally {
      reasonController.dispose();
    }
  }
}
