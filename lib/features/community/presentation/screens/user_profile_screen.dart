/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/community/presentation/screens
/// 🎯 Feature: community
/// 🔧 Type: screen
///
/// Schermata profilo utente community con stats e contributi
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/voting_card.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Schermata profilo utente community
class UserProfileScreen extends ConsumerStatefulWidget { // Null = current user

  const UserProfileScreen({
    super.key,
    this.userId,
  });
  final String? userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
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
    final theme = Theme.of(context);
    final statsAsync = ref.watch(userContributionStatsProvider);
    final contributionsAsync = ref.watch(userContributionsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con user info
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: statsAsync.when(
                data: (stats) => _buildUserHeader(stats, theme),
                loading: () => _buildLoadingHeader(theme),
                error: (e, _) => _buildErrorHeader(theme, e.toString()),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tutti'),
                  Tab(text: 'Approvati'),
                  Tab(text: 'In attesa'),
                ],
              ),
              theme: theme,
            ),
          ),

          // Content based on selected tab
          contributionsAsync.when(
            data: (contributions) => _buildContributionsList(contributions),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.error,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Errore nel caricare i contributi',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
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

  Widget _buildUserHeader(UserContributionStats stats, ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Avatar with level ring
              Stack(
                alignment: Alignment.center,
                children: [
                  // Level ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      stats.userId[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  // Level badge
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        stats.level,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // User name
              Text(
                stats.userId,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // XP Progress
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        AppIcons.stars,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${stats.totalPoints} XP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _calculateLevelProgress(stats.totalPoints),
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: AppIcons.article,
                    label: 'Contributi',
                    value: stats.totalContributions.toString(),
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: AppIcons.complete,
                    label: 'Approvati',
                    value: stats.approvedContributions.toString(),
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: AppIcons.streak,
                    label: 'Streak',
                    value: '${stats.currentStreak}d',
                    theme: theme,
                  ),
                  _buildStatItem(
                    icon: AppIcons.percent,
                    label: 'Approval',
                    value: '${(stats.approvalRate * 100).toStringAsFixed(0)}%',
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingHeader(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorHeader(ThemeData theme, String error) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.error,
            theme.colorScheme.error.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.error, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Errore nel caricare il profilo',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionsList(List<CommunityContribution> allContributions) {
    // Filter based on selected tab
    List<CommunityContribution> filteredContributions;
    switch (_tabController.index) {
      case 1: // Approvati
        filteredContributions = allContributions
            .where((c) => c.status == ContributionStatus.approved)
            .toList();
        break;
      case 2: // In attesa
        filteredContributions = allContributions
            .where((c) => c.status == ContributionStatus.pending)
            .toList();
        break;
      default: // Tutti
        filteredContributions = allContributions;
    }

    if (filteredContributions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.articleOutlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              ),
              SizedBox(height: 16),
              Text(
                'Nessun contributo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final contribution = filteredContributions[index];
            final userAsync = ref.watch(currentUserProvider);
            final currentUserId = userAsync.asData?.value?.uid;

            return VotingCard(
              contribution: contribution,
              currentUserId: currentUserId,
              onUpvote: () => _handleVote(contribution.id, true),
              onDownvote: () => _handleVote(contribution.id, false),
              onTap: () => _handleCardTap(contribution),
            );
          },
          childCount: filteredContributions.length,
        ),
      ),
    );
  }

  Future<void> _handleVote(String contributionId, bool isUpvote) async {
    try {
      await ref.read(contributionSubmissionProvider.notifier).voteOnContribution(
            contributionId,
            isUpvote,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isUpvote ? '👍 Voto positivo!' : '👎 Voto negativo'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Errore: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleCardTap(CommunityContribution contribution) {
    // TODO: Open contribution detail modal
    // Can reuse ContributionDetailModal from community_hub_screen
  }

  double _calculateLevelProgress(int totalPoints) {
    // Simple level progression: every 100 XP = 1 level
    final currentLevelPoints = totalPoints % 100;
    return currentLevelPoints / 100;
  }
}

/// Custom delegate for SliverPersistentHeader with TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {

  _SliverTabBarDelegate(this.tabBar, {required this.theme});
  final TabBar tabBar;
  final ThemeData theme;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
