/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/presentation/screens
/// 🎯 Feature: user_feedback
/// 🔧 Type: screen
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// ADMIN FEEDBACK DASHBOARD - Only visible to ferrara-michele@hotmail.it
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/presentation/providers/feedback_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Admin dashboard for managing user feedback
/// Only accessible to ferrara-michele@hotmail.it
class AdminFeedbackDashboardScreen extends ConsumerStatefulWidget {
  const AdminFeedbackDashboardScreen({super.key});

  /// Check if current user is admin
  static bool isAdmin() {
    final email = FirebaseAuth.instance.currentUser?.email;
    return email == 'ferrara-michele@hotmail.it';
  }

  /// Navigate to dashboard (with auth check)
  static void navigate(BuildContext context) {
    if (!isAdmin()) {
      SnackBarService.showError(context, 'Unauthorized access');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminFeedbackDashboardScreen(),
      ),
    );
  }

  @override
  ConsumerState<AdminFeedbackDashboardScreen> createState() =>
      _AdminFeedbackDashboardScreenState();
}

class _AdminFeedbackDashboardScreenState
    extends ConsumerState<AdminFeedbackDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FeedbackStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Map tab index to filter status
        switch (_tabController.index) {
          case 0:
            _filterStatus = null; // All
            break;
          case 1:
            _filterStatus = FeedbackStatus.newFeedback;
            break;
          case 2:
            _filterStatus = FeedbackStatus.reviewed;
            break;
          case 3:
            _filterStatus = FeedbackStatus.resolved;
            break;
          case 4:
            _filterStatus = FeedbackStatus.dismissed;
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auth check
    if (!AdminFeedbackDashboardScreen.isAdmin()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unauthorized')),
        body: Center(
          child: Text(
            'You do not have permission to access this page',
            style: context.textTheme.bodyLarge,
          ),
        ),
      );
    }

    final feedbackStream = ref.watch(allFeedbackProvider);
    final statisticsAsync = ref.watch(feedbackStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(AppIcons.admin, color: context.colors.primary),
            const SizedBox(width: 8),
            const Text('Feedback Dashboard'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: '🆕 New'),
            Tab(text: '👁️ Reviewed'),
            Tab(text: '✅ Resolved'),
            Tab(text: '❌ Dismissed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Statistics Card
          statisticsAsync.when(
            data: (stats) => _buildStatisticsCard(stats),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading statistics: $error'),
            ),
          ),

          const Divider(height: 1),

          // Feedback List
          Expanded(
            child: feedbackStream.when(
              data: (feedbackList) {
                // Filter by status if needed
                final filteredList = _filterStatus == null
                    ? feedbackList
                    : feedbackList
                        .where((f) => f.status == _filterStatus)
                        .toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.inbox,
                          size: 64,
                          color: context.colors.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback in this category',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final feedback = filteredList[index];
                    return _buildFeedbackCard(feedback);
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.error, size: 64, color: context.colors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading feedback',
                      style: context.textTheme.bodyLarge,
                    ),
                    Text(
                      error.toString(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(FeedbackStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats.totalFeedback.toString(),
                  AppIcons.feedback,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'New',
                  stats.newFeedback.toString(),
                  AppIcons.newReleases,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Avg Rating',
                  '${stats.averageRating.toStringAsFixed(1)}⭐',
                  AppIcons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: context.colors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(UserFeedback feedback) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User info + Status badge
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  backgroundColor: context.colors.primary,
                  child: Text(
                    feedback.userDisplayName?.substring(0, 1).toUpperCase() ??
                        feedback.userEmail?.substring(0, 1).toUpperCase() ??
                        '?',
                    style: TextStyle(color: context.colors.onPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userDisplayName ?? 'Anonymous',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        feedback.userEmail ?? 'No email',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(feedback.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${feedback.statusIcon} ${feedback.statusLabel}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(feedback.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category + Rating
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${feedback.categoryIcon} ${feedback.categoryLabel}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (feedback.rating != null)
                  Text(
                    feedback.ratingStars,
                    style: context.textTheme.bodyMedium,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feedback.message,
                style: context.textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 12),

            // Metadata
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildMetadataItem(
                  AppIcons.clock,
                  _formatDate(feedback.createdAt),
                ),
                if (feedback.appVersion != null)
                  _buildMetadataItem(
                    AppIcons.info,
                    feedback.appVersion!,
                  ),
                if (feedback.deviceInfo != null)
                  _buildMetadataItem(
                    AppIcons.phoneAndroid,
                    feedback.deviceInfo!,
                  ),
              ],
            ),

            // Admin notes (if any)
            if (feedback.adminNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.admin,
                          size: 16,
                          color: context.colors.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Admin Notes',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.adminNotes!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Actions (only if actionable)
            if (feedback.isActionable)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Mark as Reviewed
                  if (feedback.status == FeedbackStatus.newFeedback)
                    TextButton.icon(
                      onPressed: () => _markAsReviewed(feedback),
                      icon: const Icon(AppIcons.visibility),
                      label: const Text('Mark Reviewed'),
                    ),

                  const SizedBox(width: 8),

                  // Resolve with notes
                  ElevatedButton.icon(
                    onPressed: () => _resolveWithNotes(feedback),
                    icon: const Icon(AppIcons.complete),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Dismiss
                  TextButton.icon(
                    onPressed: () => _dismissFeedback(feedback),
                    icon: const Icon(AppIcons.cancel),
                    label: const Text('Dismiss'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
                ],
              ),

            // Delete button (always available)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _deleteFeedback(feedback),
                icon: Icon(AppIcons.delete, color: context.colors.error),
                tooltip: 'Delete',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.newFeedback:
        return context.colors.primary;
      case FeedbackStatus.reviewed:
        return context.colors.tertiary;
      case FeedbackStatus.resolved:
        return context.colors.secondary;
      case FeedbackStatus.dismissed:
        return context.colors.error;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // === ACTIONS ===

  Future<void> _markAsReviewed(UserFeedback feedback) async {
    final adminUserId = FirebaseAuth.instance.currentUser!.uid;
    final repository = ref.read(feedbackRepositoryProvider);

    try {
      await repository.updateFeedbackStatus(
        feedbackId: feedback.id,
        status: FeedbackStatus.reviewed,
        adminUserId: adminUserId,
      );

      if (mounted) {
        SnackBarService.showSuccess(context, 'Marked as reviewed');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Failed to update: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _resolveWithNotes(UserFeedback feedback) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add resolution notes (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What was done to resolve this...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final adminUserId = FirebaseAuth.instance.currentUser!.uid;
      final repository = ref.read(feedbackRepositoryProvider);

      try {
        await repository.updateFeedbackStatus(
          feedbackId: feedback.id,
          status: FeedbackStatus.resolved,
          adminUserId: adminUserId,
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
        );

        if (mounted) {
          SnackBarService.showSuccess(context, 'Feedback resolved');
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Failed to resolve: ${e.toString()}',
          );
        }
      }
    }

    notesController.dispose();
  }

  Future<void> _dismissFeedback(UserFeedback feedback) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add dismissal reason:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Why is this being dismissed...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final adminUserId = FirebaseAuth.instance.currentUser!.uid;
      final repository = ref.read(feedbackRepositoryProvider);

      try {
        await repository.updateFeedbackStatus(
          feedbackId: feedback.id,
          status: FeedbackStatus.dismissed,
          adminUserId: adminUserId,
          notes: reasonController.text.trim(),
        );

        if (mounted) {
          SnackBarService.showSuccess(context, 'Feedback dismissed');
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Failed to dismiss: ${e.toString()}',
          );
        }
      }
    }

    reasonController.dispose();
  }

  Future<void> _deleteFeedback(UserFeedback feedback) async {
    final confirmed = await ModalService.showConfirmDialog(
      context,
      title: 'Delete Feedback',
      message: 'Are you sure you want to permanently delete this feedback?',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      final repository = ref.read(feedbackRepositoryProvider);

      try {
        await repository.deleteFeedback(feedback.id);

        if (mounted) {
          SnackBarService.showSuccess(context, 'Feedback deleted');
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Failed to delete: ${e.toString()}',
          );
        }
      }
    }
  }
}
