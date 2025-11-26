/// Community Hub Screen - Central place for community features
///
/// Design based on best practices from Strava, Nike Run Club:
/// - Simple AppBar with visible TabBar
/// - Activity Feed as main view
/// - Clear onboarding for new users
/// - Kudos/voting system for engagement
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/contribution_detail_modal.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/create_contribution_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/core/auth/admin_status_provider.dart';

class CommunityHubScreen extends ConsumerStatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  ConsumerState<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends ConsumerState<CommunityHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.community),
        elevation: 0,
        actions: [
          // Admin badge (if admin)
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'Admin',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onTertiary,
                  ),
                ),
                backgroundColor: context.colors.tertiary,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(AppIcons.trendUp, size: AppIconSize.small),
              text: context.l10n.popular,
            ),
            Tab(
              icon: const Icon(AppIcons.person, size: AppIconSize.small),
              text: context.l10n.myContributions,
            ),
            Tab(
              icon: const Icon(AppIcons.help, size: AppIconSize.small),
              text: context.l10n.guide,
            ),
          ],
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.onSurfaceVariant,
          indicatorColor: context.colors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FeedTab(),
          _MyContributionsTab(),
          _GuideTab(onNavigateToFeed: () => _tabController.animateTo(0)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateModal(context),
        icon: const Icon(AppIcons.add),
        label: Text(context.l10n.contribute),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateContributionModal(),
    );
  }
}

// ============================================================================
// FEED TAB - Activity feed with trending contributions
// ============================================================================

class _FeedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingContributionsProvider);

    return trending.when(
      data: (contributions) {
        if (contributions.isEmpty) {
          return _EmptyFeedState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingContributionsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ContributionFeedCard(contribution: contributions[index]),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => _ErrorState(
        error: error,
        onRetry: () => ref.invalidate(trendingContributionsProvider),
      ),
    );
  }
}

// ============================================================================
// MY CONTRIBUTIONS TAB
// ============================================================================

class _MyContributionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myContributions = ref.watch(userContributionsProvider);

    return myContributions.when(
      data: (contributions) {
        if (contributions.isEmpty) {
          return _EmptyMyContributionsState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userContributionsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contributions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ContributionFeedCard(
                  contribution: contributions[index],
                  showStatus: true,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => _ErrorState(
        error: error,
        onRetry: () => ref.invalidate(userContributionsProvider),
      ),
    );
  }
}

// ============================================================================
// GUIDE TAB - How to use community
// ============================================================================

class _GuideTab extends StatelessWidget {
  const _GuideTab({required this.onNavigateToFeed});

  final VoidCallback onNavigateToFeed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  AppIcons.people,
                  size: 48,
                  color: context.colors.onPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.welcomeToCommunity,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.communityDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onPrimary.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // What you can do
          Text(
            context.l10n.whatYouCanDo,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _GuideItem(
            icon: AppIcons.tip,
            iconColor: context.colors.primary,
            title: context.l10n.shareTips,
            description: context.l10n.shareTipsDescription,
          ),
          _GuideItem(
            icon: AppIcons.warning,
            iconColor: context.warningColor,
            title: context.l10n.reportWarnings,
            description: context.l10n.reportWarningsDescription,
          ),
          _GuideItem(
            icon: AppIcons.editNote,
            iconColor: context.successColor,
            title: context.l10n.suggestCorrections,
            description: context.l10n.suggestCorrectionsDescription,
          ),

          const SizedBox(height: 24),

          // XP System
          Text(
            context.l10n.xpSystem,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _XPRow(action: context.l10n.submitContribution, xp: '+10 XP'),
                  _XPRow(action: context.l10n.contributionApproved, xp: '+50 XP'),
                  _XPRow(action: context.l10n.contributionFeatured, xp: '+100 XP'),
                  _XPRow(action: context.l10n.voteOnContribution, xp: '+1 XP'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNavigateToFeed,
              icon: const Icon(AppIcons.trendUp),
              label: Text(context.l10n.exploreCommunity),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ============================================================================
// CONTRIBUTION CARD - Main card for feed items
// ============================================================================

class _ContributionFeedCard extends ConsumerWidget {
  const _ContributionFeedCard({
    required this.contribution,
    this.showStatus = false,
  });

  final CommunityContribution contribution;
  final bool showStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select() to only rebuild when uid changes, not when other user data changes
    // High-impact: _ContributionFeedCard is rendered N times in community feed
    final currentUserId = ref.watch(
      currentUserProvider.select((async) => async.asData?.value?.uid),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type badge + Title
              Row(
                children: [
                  _TypeBadge(type: contribution.type),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contribution.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showStatus) _StatusBadge(status: contribution.status),
                ],
              ),
              const SizedBox(height: 8),

              // Exercise name
              Row(
                children: [
                  Icon(
                    AppIcons.workout,
                    size: AppIconSize.tiny,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    contribution.exerciseName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                contribution.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer: Author + Votes
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: context.colors.primaryContainer,
                    child: Text(
                      contribution.userName.isNotEmpty
                          ? contribution.userName[0].toUpperCase()
                          : '?',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    contribution.userName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),

                  // Vote buttons (like Strava Kudos)
                  _VoteButton(
                    icon: AppIcons.thumbUp,
                    count: contribution.upvotes,
                    isSelected: contribution.upvotedBy.contains(currentUserId),
                    onTap: () => _handleVote(ref, context, true),
                  ),
                  const SizedBox(width: 8),
                  _VoteButton(
                    icon: AppIcons.thumbDown,
                    count: contribution.downvotes,
                    isSelected: contribution.downvotedBy.contains(currentUserId),
                    isDownvote: true,
                    onTap: () => _handleVote(ref, context, false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContributionDetailModal(contribution: contribution),
    );
  }

  Future<void> _handleVote(WidgetRef ref, BuildContext context, bool isUpvote) async {
    HapticFeedback.lightImpact();
    try {
      await ref.read(contributionSubmissionProvider.notifier).voteOnContribution(
        contribution.id,
        isUpvote,
      );
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(context, e.toString());
      }
    }
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final ContributionType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (type) {
      ContributionType.tip => (AppIcons.tip, context.colors.primary, 'Tip'),
      ContributionType.warning => (AppIcons.warning, context.warningColor, 'Warning'),
      ContributionType.correction => (AppIcons.editNote, context.successColor, 'Fix'),
      ContributionType.technique => (AppIcons.workout, context.colors.tertiary, 'Technique'),
      ContributionType.variant => (AppIcons.altRoute, context.colors.secondary, 'Variant'),
      ContributionType.translation => (AppIcons.translate, context.colors.primary, 'Translation'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.tiny, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ContributionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ContributionStatus.pending => (context.warningColor, context.l10n.pending),
      ContributionStatus.approved => (context.successColor, context.l10n.approved),
      ContributionStatus.rejected => (context.errorColor, context.l10n.rejected),
      ContributionStatus.underReview => (context.colors.primary, context.l10n.underReview),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.icon,
    required this.count,
    required this.onTap,
    this.isSelected = false,
    this.isDownvote = false,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDownvote;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? (isDownvote ? context.errorColor : context.colors.primary)
        : context.colors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: AppIconSize.small, color: color),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: context.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: AppIconSize.medium, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _XPRow extends StatelessWidget {
  const _XPRow({required this.action, required this.xp});

  final String action;
  final String xp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action, style: context.textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              xp,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STATES
// ============================================================================

class _EmptyFeedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.people,
                size: 64,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.noContributionsYet,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.beFirstToContribute,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMyContributionsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.editNote,
                size: 64,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.noContributionsFromYou,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.startContributing,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isNetworkError = error.toString().contains('unavailable') ||
        error.toString().contains('network');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? AppIcons.wifiOff : AppIcons.errorOutline,
              size: 64,
              color: isNetworkError ? context.warningColor : context.errorColor,
            ),
            const SizedBox(height: 24),
            Text(
              isNetworkError ? context.l10n.offline : context.l10n.error,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isNetworkError
                  ? context.l10n.checkConnection
                  : context.l10n.somethingWentWrong,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(AppIcons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
