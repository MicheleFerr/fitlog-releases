/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/presentation/screens
/// 🎯 Feature: unified_feedback
/// 🔧 Type: screen (user-facing)
///
/// User Feedback History Screen
///
/// **Features**:
/// - View all user's submitted feedback
/// - Filter by feedback type
/// - Status indicators (pending, resolved, dismissed)
/// - Feedback detail view
/// - Real-time updates
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/presentation/providers/unified_feedback_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// User feedback history screen
///
/// **User Flow**:
/// 1. View all submitted feedback
/// 2. Filter by type (exercise, ai_insight, analytics, etc.)
/// 3. See status updates (pending → reviewing → resolved)
/// 4. Read admin responses
class UserFeedbackHistoryScreen extends ConsumerStatefulWidget {
  const UserFeedbackHistoryScreen({super.key});

  @override
  ConsumerState<UserFeedbackHistoryScreen> createState() =>
      _UserFeedbackHistoryScreenState();
}

class _UserFeedbackHistoryScreenState
    extends ConsumerState<UserFeedbackHistoryScreen> {
  // Filter state
  UnifiedFeedbackType? _selectedType;

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.myFeedback)),
        body: _buildNotAuthenticatedState(context),
      );
    }

    // Watch user feedback with real-time updates
    final feedbackAsync = _selectedType == null
        ? ref.watch(userFeedbackStreamProvider(userId))
        : ref.watch(userFeedbackByTypeProvider((userId: userId, type: _selectedType!)));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myFeedback),
        elevation: 0,
        actions: [
          // Feedback count badge
          feedbackAsync.when(
            data: (feedbackList) => feedbackList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Badge(
                        label: Text(feedbackList.length.toString()),
                        backgroundColor: context.colors.primary,
                        child: Icon(
                          AppIcons.comment,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            _buildFilterChips(context),
            const SizedBox(height: 24),

            // Feedback list
            _buildFeedbackList(context, feedbackAsync, userId),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // FILTER CHIPS
  // ============================================================================

  /// Build filter chips for feedback type
  Widget _buildFilterChips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Type',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All Types
            FilterChip(
              label: Text(context.l10n.allTypes),
              selected: _selectedType == null,
              onSelected: (_) {
                setState(() {
                  _selectedType = null;
                });
              },
            ),
            // Individual types
            ...UnifiedFeedbackType.values.map((type) {
              return FilterChip(
                label: Text('${type.icon} ${type.displayName}'),
                selected: _selectedType == type,
                onSelected: (_) {
                  setState(() {
                    _selectedType = _selectedType == type ? null : type;
                  });
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // FEEDBACK LIST
  // ============================================================================

  /// Build feedback list
  Widget _buildFeedbackList(
    BuildContext context,
    AsyncValue<List<UnifiedFeedback>> feedbackAsync,
    String userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Feedback',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        feedbackAsync.when(
          loading: () => const LoadingIndicator(message: 'Loading your feedback...'),
          error: (error, _) => _buildErrorCard(context, error.toString()),
          data: (feedbackList) {
            if (feedbackList.isEmpty) {
              return _buildEmptyState(context);
            }

            // Sort by createdAt (most recent first)
            final sortedFeedback = List<UnifiedFeedback>.from(feedbackList)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedFeedback.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final feedback = sortedFeedback[index];
                return _buildFeedbackCard(context, feedback);
              },
            );
          },
        ),
      ],
    );
  }

  /// Build individual feedback card
  Widget _buildFeedbackCard(BuildContext context, UnifiedFeedback feedback) {
    return Card(
      elevation: 0,
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: context.colors.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showFeedbackDetailDialog(context, feedback);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type Icon + Title + Status Badge
              Row(
                children: [
                  // Type Icon
                  Text(
                    feedback.type.icon,
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.typeDisplayTitle,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(feedback.createdAt),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  _buildStatusBadge(context, feedback.status),
                ],
              ),
              const SizedBox(height: 12),

              // Message Preview
              Text(
                feedback.shortSummary,
                style: context.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Admin Response Indicator
              if (feedback.hasAdminReview) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SemanticIcon(
  icon: AppIcons.admin,
  semanticLabel: 'Admin',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.adminResponded,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SemanticIcon(
  icon: AppIcons.chevronRight,
  semanticLabel: 'Chevron right',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(BuildContext context, UnifiedFeedbackStatus status) {
    final color = _getStatusColor(context, status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SemanticIcon(
  icon: AppIcons.feedbackOutlined,
  semanticLabel: 'Feedback outlined',
  size: AppIconSize.medium,
  color: context.colors.onSurfaceVariant,
),
            const SizedBox(height: 16),
            Text(
              context.l10n.noFeedbackSubmittedYet,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noFeedbackSubmittedDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error card
  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      color: context.colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(AppIcons.error, color: context.colors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading feedback: $error',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build not authenticated state
  Widget _buildNotAuthenticatedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
  icon: AppIcons.lock,
  semanticLabel: 'Lock',
  size: AppIconSize.medium,
  color: context.colors.error,
),
            const SizedBox(height: 16),
            Text(
              'Please sign in',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need to be signed in to view your feedback history',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // FEEDBACK DETAIL DIALOG
  // ============================================================================

  /// Show feedback detail dialog
  void _showFeedbackDetailDialog(BuildContext context, UnifiedFeedback feedback) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    feedback.type.icon,
                    style: context.textTheme.headlineLarge,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feedback.typeDisplayTitle,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status Badge
              _buildStatusBadge(context, feedback.status),
              const SizedBox(height: 16),

              // Divider
              Divider(color: context.colors.outlineVariant),
              const SizedBox(height: 16),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Your Message
                      Text(
                        context.l10n.yourMessage,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedback.message,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Submitted Date
                      Text(
                        context.l10n.submitted,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(feedback.createdAt),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),

                      // Admin Response (if available)
                      if (feedback.adminNotes != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SemanticIcon(
  icon: AppIcons.admin,
  semanticLabel: 'Admin',
  size: AppIconSize.small,
  color: context.colors.primary,
),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.adminResponse,
                                    style: context.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                feedback.adminNotes!,
                                style: context.textTheme.bodyMedium,
                              ),
                              if (feedback.resolvedAt != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Resolved ${_formatDate(feedback.resolvedAt!)}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Close Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get status color
  Color _getStatusColor(BuildContext context, UnifiedFeedbackStatus status) {
    switch (status) {
      case UnifiedFeedbackStatus.open:
        return context.colors.warning;
      case UnifiedFeedbackStatus.reviewing:
        return context.colors.tertiary;
      case UnifiedFeedbackStatus.resolved:
        return context.colors.success;
      case UnifiedFeedbackStatus.dismissed:
        return context.colors.error;
      case UnifiedFeedbackStatus.closed:
        return context.colors.onSurfaceVariant;
    }
  }

  /// Get status icon
  IconData _getStatusIcon(UnifiedFeedbackStatus status) {
    switch (status) {
      case UnifiedFeedbackStatus.open:
        return AppIcons.pending;
      case UnifiedFeedbackStatus.reviewing:
        return AppIcons.sync;
      case UnifiedFeedbackStatus.resolved:
        return AppIcons.checkCircle;
      case UnifiedFeedbackStatus.dismissed:
        return AppIcons.close;
      case UnifiedFeedbackStatus.closed:
        return AppIcons.archive;
    }
  }
}
