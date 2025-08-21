import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/voting_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'dart:math' as math;

class CommunityHubScreen extends ConsumerStatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  ConsumerState<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends ConsumerState<CommunityHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _headerAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    ); // Rimosso ..repeat() per fermare l'animazione continua
    
    _headerAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_headerAnimationController);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userStats = ref.watch(userContributionStatsProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium animated header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                'Community Hub',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Static gradient background (no animation)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.8),
                          theme.colorScheme.secondary.withOpacity(0.8),
                          theme.colorScheme.tertiary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  
                  // Glass overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  
                  // User stats centrati in basso
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: userStats.when(
                        data: (stats) => _buildUserStatsHeader(stats, theme),
                        loading: () => const SizedBox(height: 60),
                        error: (_, __) => const SizedBox(height: 60),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                tabs: const [
                  Tab(icon: Icon(Icons.local_fire_department), text: 'Trending'),
                  Tab(icon: Icon(Icons.how_to_vote), text: 'Vota'),
                  Tab(icon: Icon(Icons.person), text: 'I Miei'),
                  Tab(icon: Icon(Icons.leaderboard), text: 'Classifica'),
                ],
              ),
              theme: theme,
            ),
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrendingTab(),
                _buildVotingTab(),
                _buildMyContributionsTab(),
                _buildLeaderboardTab(),
              ],
            ),
          ),
        ],
      ),
      
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }
  
  Widget _buildUserStatsHeader(UserContributionStats stats, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        _buildStatItem(
          icon: Icons.star,
          value: stats.totalPoints.toString(),
          label: 'Punti',
          theme: theme,
        ),
        _buildStatItem(
          icon: Icons.workspace_premium,
          value: 'Livello ${stats.level}',
          label: _getLevelName(stats.level),
          theme: theme,
        ),
        _buildStatItem(
          icon: Icons.check_circle,
          value: '${(stats.approvalRate * 100).toInt()}%',
          label: 'Approvati',
          theme: theme,
        ),
        _buildStatItem(
          icon: Icons.local_fire_department,
          value: stats.currentStreak.toString(),
          label: 'Streak',
          theme: theme,
        ),
      ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
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
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrendingTab() {
    return Consumer(
      builder: (context, ref, child) {
        final trending = ref.watch(trendingContributionsProvider);
        
        return trending.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return _buildEmptyState(
                icon: Icons.trending_up,
                title: 'Nessun Trend',
                subtitle: 'Sii il primo a contribuire!',
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contributions.length,
              itemBuilder: (context, index) {
                final contribution = contributions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VotingCard(
                    contribution: contribution,
                    onUpvote: () {
                      ref.read(contributionSubmissionProvider.notifier)
                          .voteOnContribution(contribution.id, true);
                      HapticFeedback.lightImpact();
                    },
                    onDownvote: () {
                      ref.read(contributionSubmissionProvider.notifier)
                          .voteOnContribution(contribution.id, false);
                      HapticFeedback.lightImpact();
                    },
                    onComment: () {
                      // TODO: Show comment dialog
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildErrorState(),
        );
      },
    );
  }
  
  Widget _buildVotingTab() {
    return Consumer(
      builder: (context, ref, child) {
        final forReview = ref.watch(contributionsForReviewProvider);
        
        return forReview.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return _buildEmptyState(
                icon: Icons.how_to_vote,
                title: 'Nessuna Votazione',
                subtitle: 'Tutte le contribuzioni sono state votate!',
              );
            }
            
            return Stack(
              children: contributions.asMap().entries.map((entry) {
                final index = entry.key;
                final contribution = entry.value;
                
                return Positioned.fill(
                  child: Dismissible(
                    key: Key(contribution.id),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      final isUpvote = direction == DismissDirection.endToStart;
                      ref.read(contributionSubmissionProvider.notifier)
                          .voteOnContribution(contribution.id, isUpvote);
                      HapticFeedback.mediumImpact();
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      color: Colors.green.withOpacity(0.3),
                      child: const Icon(
                        Icons.thumb_up,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      color: Colors.red.withOpacity(0.3),
                      child: const Icon(
                        Icons.thumb_down,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    child: Transform.scale(
                      scale: 1 - (index * 0.05),
                      child: Transform.translate(
                        offset: Offset(0, index * 10.0),
                        child: VotingCard(
                          contribution: contribution,
                          onUpvote: () {
                            ref.read(contributionSubmissionProvider.notifier)
                                .voteOnContribution(contribution.id, true);
                            HapticFeedback.lightImpact();
                          },
                          onDownvote: () {
                            ref.read(contributionSubmissionProvider.notifier)
                                .voteOnContribution(contribution.id, false);
                            HapticFeedback.lightImpact();
                          },
                          onComment: () {
                            // TODO: Show comment dialog
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildErrorState(),
        );
      },
    );
  }
  
  Widget _buildMyContributionsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final myContributions = ref.watch(userContributionsProvider);
        
        return myContributions.when(
          data: (contributions) {
            if (contributions.isEmpty) {
              return _buildEmptyState(
                icon: Icons.edit_note,
                title: 'Nessuna Contribuzione',
                subtitle: 'Inizia a contribuire alla community!',
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contributions.length,
              itemBuilder: (context, index) {
                final contribution = contributions[index];
                return _buildMyContributionCard(contribution);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildErrorState(),
        );
      },
    );
  }
  
  Widget _buildMyContributionCard(CommunityContribution contribution) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(contribution.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    contribution.status.name.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contribution.upvotes.toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.thumb_down,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contribution.downvotes.toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              contribution.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contribution.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contribution.exerciseName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeaderboardTab() {
    // In production, this would fetch from a leaderboard endpoint
    return _buildEmptyState(
      icon: Icons.leaderboard,
      title: 'Classifica',
      subtitle: 'Presto disponibile!',
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return _buildEmptyState(
      icon: Icons.error_outline,
      title: 'Errore',
      subtitle: 'Riprova più tardi',
    );
  }
  
  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Open contribution dialog
        HapticFeedback.mediumImpact();
      },
      backgroundColor: theme.colorScheme.primary,
      icon: const Icon(Icons.add),
      label: const Text('Contribuisci'),
    );
  }
  
  Color _getStatusColor(ContributionStatus status) {
    switch (status) {
      case ContributionStatus.approved:
        return Colors.green;
      case ContributionStatus.rejected:
        return Colors.red;
      case ContributionStatus.pending:
        return Colors.orange;
      case ContributionStatus.underReview:
        return Colors.purple;
    }
  }
  
  String _getLevelName(String level) {
    final levelInt = int.tryParse(level) ?? 0;
    if (levelInt >= 50) return 'Leggenda';
    if (levelInt >= 40) return 'Maestro';
    if (levelInt >= 30) return 'Esperto';
    if (levelInt >= 20) return 'Veterano';
    if (levelInt >= 10) return 'Contribuente';
    if (levelInt >= 5) return 'Attivo';
    return 'Novizio';
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final ThemeData theme;
  
  _SliverTabBarDelegate(this.tabBar, {required this.theme});
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.colorScheme.surface,
      child: tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}