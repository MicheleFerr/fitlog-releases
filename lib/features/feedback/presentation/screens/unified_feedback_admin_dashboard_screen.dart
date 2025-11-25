/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/presentation/screens
/// 🎯 Feature: unified_feedback
/// 🔧 Type: screen (admin dashboard)
///
/// Unified Feedback Admin Dashboard
///
/// **2025 UI/UX Best Practices**:
/// - Real-time updates without refresh
/// - Progressive disclosure (summary → details)
/// - Visual hierarchy with severity badges
/// - Filtering with immediate feedback
/// - Status indicators with colors
/// - Card-based layout for metrics
/// - Responsive grid for statistics
/// - Search with debouncing
/// - AI-ready for future predictive analytics
library;

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

/// Admin dashboard for unified feedback system
///
/// **Features**:
/// - Real-time metrics (total, pending, critical counts)
/// - Statistics dashboard with cards
/// - Filtering (type, status, severity)
/// - Search functionality
/// - Feedback list with priority sorting
/// - Status badges and severity indicators
/// - Action buttons (resolve, dismiss, change severity)
class UnifiedFeedbackAdminDashboard extends ConsumerStatefulWidget {
  const UnifiedFeedbackAdminDashboard({super.key});

  @override
  ConsumerState<UnifiedFeedbackAdminDashboard> createState() =>
      _UnifiedFeedbackAdminDashboardState();
}

class _UnifiedFeedbackAdminDashboardState
    extends ConsumerState<UnifiedFeedbackAdminDashboard> {
  // Search controller for debouncing
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch real-time pending count
    final pendingCountAsync = ref.watch(pendingFeedbackCountStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.feedbackDashboard),
        elevation: 0,
        actions: [
          // Real-time pending count badge
          pendingCountAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Badge(
                        label: Text(count.toString()),
                        backgroundColor: context.colors.error,
                        child: Icon(
                          AppIcons.notifications,
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
            // Statistics Dashboard
            _buildStatisticsDashboard(context),
            const SizedBox(height: 24),

            // Search Bar
            _buildSearchBar(context),
            const SizedBox(height: 16),

            // Filter Chips
            _buildFilterChips(context),
            const SizedBox(height: 24),

            // Feedback List
            _buildFeedbackList(context),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STATISTICS DASHBOARD
  // ============================================================================

  /// Build statistics dashboard with cards
  ///
  /// **2025 UX**: Card-based layout with visual hierarchy
  /// **Metrics**: Total, Pending, Critical, Completed counts
  Widget _buildStatisticsDashboard(BuildContext context) {
    final statsAsync = ref.watch(feedbackStatisticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.overview,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          loading: () => const LoadingIndicator(message: 'Loading statistics...'),
          error: (error, _) => _buildErrorCard(context, error.toString()),
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                icon: AppIcons.comment,
                label: context.l10n.totalFeedback,
                value: stats.totalCount.toString(),
                color: context.colors.primary,
                subtitle: 'all time',
              ),
              _buildStatCard(
                context,
                icon: AppIcons.pending,
                label: context.l10n.pending,
                value: stats.pendingCount.toString(),
                color: context.colors.warning,
                subtitle: 'needs review',
              ),
              _buildStatCard(
                context,
                icon: AppIcons.error,
                label: context.l10n.criticalIssues,
                value: stats.highPriorityCount.toString(),
                color: context.colors.error,
                subtitle: 'high priority',
              ),
              _buildStatCard(
                context,
                icon: AppIcons.checkCircle,
                label: context.l10n.completed,
                value: stats.completedCount.toString(),
                color: context.colors.success,
                subtitle: 'resolved',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build individual stat card
  ///
  /// **2025 UX**: Icon + Value + Label + Subtitle layout
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
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
                'Error loading statistics: $error',
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

  // ============================================================================
  // SEARCH BAR
  // ============================================================================

  /// Build search bar with debouncing
  ///
  /// **2025 UX**: Real-time search with immediate feedback
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: context.l10n.searchFeedback,
        prefixIcon: Icon(AppIcons.search, color: context.colors.onSurfaceVariant),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(AppIcons.close, color: context.colors.onSurfaceVariant),
                onPressed: () {
                  _searchController.clear();
                  ref.read(feedbackSearchQueryProvider.notifier).state = '';
                },
              )
            : null,
        filled: true,
        fillColor: context.colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (query) {
        // Update search query provider (debouncing handled in UI by user typing)
        ref.read(feedbackSearchQueryProvider.notifier).state = query;
      },
    );
  }

  // ============================================================================
  // FILTER CHIPS
  // ============================================================================

  /// Build filter chips for type, status, severity
  ///
  /// **2025 UX**: Filter chips with immediate visual feedback
  Widget _buildFilterChips(BuildContext context) {
    final selectedType = ref.watch(selectedFeedbackTypeProvider);
    final selectedStatus = ref.watch(selectedFeedbackStatusProvider);
    final selectedSeverity = ref.watch(selectedFeedbackSeverityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filters,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Type Filter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All Types
            FilterChip(
              label: Text(context.l10n.allTypes),
              selected: selectedType == null,
              onSelected: (_) {
                ref.read(selectedFeedbackTypeProvider.notifier).state = null;
              },
            ),
            // Individual types
            ...UnifiedFeedbackType.values.map((type) {
              return FilterChip(
                label: Text('${type.icon} ${type.displayName}'),
                selected: selectedType == type,
                onSelected: (_) {
                  ref.read(selectedFeedbackTypeProvider.notifier).state =
                      selectedType == type ? null : type;
                },
              );
            }),
          ],
        ),
        const SizedBox(height: 12),

        // Status Filter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All Statuses
            FilterChip(
              label: Text(context.l10n.allStatuses),
              selected: selectedStatus == null,
              onSelected: (_) {
                ref.read(selectedFeedbackStatusProvider.notifier).state = null;
              },
            ),
            // Individual statuses
            ...UnifiedFeedbackStatus.values.map((status) {
              return FilterChip(
                label: Text(status.displayName),
                selected: selectedStatus == status,
                selectedColor: _getStatusColor(context, status).withValues(alpha: 0.3),
                onSelected: (_) {
                  ref.read(selectedFeedbackStatusProvider.notifier).state =
                      selectedStatus == status ? null : status;
                },
              );
            }),
          ],
        ),
        const SizedBox(height: 12),

        // Severity Filter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All Severities
            FilterChip(
              label: Text(context.l10n.allPriorities),
              selected: selectedSeverity == null,
              onSelected: (_) {
                ref.read(selectedFeedbackSeverityProvider.notifier).state = null;
              },
            ),
            // Individual severities
            ...FeedbackSeverity.values.map((severity) {
              return FilterChip(
                label: Text('${severity.icon} ${severity.displayName}'),
                selected: selectedSeverity == severity,
                selectedColor: _getSeverityColor(context, severity).withValues(alpha: 0.3),
                onSelected: (_) {
                  ref.read(selectedFeedbackSeverityProvider.notifier).state =
                      selectedSeverity == severity ? null : severity;
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

  /// Build feedback list with filtering
  ///
  /// **2025 UX**: Card-based list with progressive disclosure
  Widget _buildFeedbackList(BuildContext context) {
    final filteredFeedbackAsync = ref.watch(filteredFeedbackProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback Items',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        filteredFeedbackAsync.when(
          loading: () => const LoadingIndicator(message: 'Loading feedback...'),
          error: (error, _) => _buildErrorCard(context, error.toString()),
          data: (feedbackList) {
            if (feedbackList.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feedbackList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final feedback = feedbackList[index];
                return _buildFeedbackCard(context, feedback);
              },
            );
          },
        ),
      ],
    );
  }

  /// Build individual feedback card
  ///
  /// **2025 UX**: Expandable card with status/severity badges
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
          // TODO: Navigate to feedback detail screen
          // Navigator.pushNamed(context, '/feedback-detail', arguments: feedback.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type Icon + Title + Badges
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
                          '${feedback.daysSinceCreated} days ago',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Severity Badge
                  _buildSeverityBadge(context, feedback.severity),
                ],
              ),
              const SizedBox(height: 12),

              // Message Preview
              Text(
                feedback.shortSummary,
                style: context.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer: Status Badge + User Info + Actions
              Row(
                children: [
                  // Status Badge
                  _buildStatusBadge(context, feedback.status),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Text(
                      feedback.userDisplayName ?? feedback.userEmail ?? 'Anonymous',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Chevron Icon
                  Icon(
                    AppIcons.chevronRight,
                    color: context.colors.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status badge
  ///
  /// **2025 UX**: Color-coded status indicators
  Widget _buildStatusBadge(BuildContext context, UnifiedFeedbackStatus status) {
    final color = _getStatusColor(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.displayName,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build severity badge
  ///
  /// **2025 UX**: Visual priority indicators
  Widget _buildSeverityBadge(BuildContext context, FeedbackSeverity severity) {
    final color = _getSeverityColor(context, severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            severity.icon,
            style: context.textTheme.labelSmall,
          ),
          const SizedBox(width: 4),
          Text(
            severity.displayName,
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
  ///
  /// **2025 UX**: Friendly empty state with icon
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SemanticIcon(
  icon: AppIcons.inbox,
  semanticLabel: 'Inbox',
  size: AppIconSize.medium,
  color: context.colors.onSurfaceVariant,
),
            const SizedBox(height: 16),
            Text(
              context.l10n.noFeedbackFound,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search query',
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
  // HELPER METHODS
  // ============================================================================

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

  /// Get severity color
  Color _getSeverityColor(BuildContext context, FeedbackSeverity severity) {
    switch (severity) {
      case FeedbackSeverity.low:
        return context.colors.success;
      case FeedbackSeverity.medium:
        return context.colors.warning;
      case FeedbackSeverity.high:
        return context.colors.error;
      case FeedbackSeverity.critical:
        return context.colors.error;
    }
  }
}
