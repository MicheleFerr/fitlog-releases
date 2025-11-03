import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/admin_moderation_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/voting_card.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/contribution_detail_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/create_contribution_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class CommunityHubScreen extends ConsumerStatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  ConsumerState<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends ConsumerState<CommunityHubScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabCount = 3; // Will be updated based on admin status

  @override
  void initState() {
    super.initState();
    // Initialize with default tab count, will update in build
    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTabController(int newTabCount) {
    if (newTabCount != _tabCount) {
      final oldIndex = _tabController.index;
      _tabController.dispose();
      _tabCount = newTabCount;
      _tabController = TabController(
        length: newTabCount,
        vsync: this,
        initialIndex: oldIndex.clamp(0, newTabCount - 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userStats = ref.watch(userContributionStatsProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    final isAdmin = isAdminAsync.asData?.value ?? false;

    // Update tab controller based on admin status
    final newTabCount = isAdmin ? 4 : 3;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateTabController(newTabCount);
      }
    });

    if (kDebugMode) {
      debugPrint('🔐 [CommunityHub] Building with admin status: $isAdmin (tabs: $newTabCount)');
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Simplified header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(
                '🌟 Community',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: userStats.when(
                      data: (stats) => _buildCompactUserStats(stats, theme),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                ),
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
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                isScrollable: isAdmin, // Make scrollable if admin tab present
                tabs: [
                  const Tab(icon: Icon(Icons.local_fire_department), text: 'Popolari'),
                  const Tab(icon: Icon(Icons.person), text: 'I Miei'),
                  if (isAdmin)
                    const Tab(
                      icon: Icon(Icons.admin_panel_settings),
                      text: 'Admin',
                    ),
                  const Tab(icon: Icon(Icons.info_outline), text: 'Info'),
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
                _buildMyContributionsTab(),
                if (isAdmin) _buildAdminTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateContributionModal(),
        icon: const Icon(Icons.add),
        label: const Text('Contribuisci'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCompactUserStats(UserContributionStats? stats, ThemeData theme) {
    if (stats == null) {
      return Text(
        '👋 Benvenuto!',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        Text(
          '⭐ ${stats.totalPoints} XP',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Livello ${stats.level}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
            // Se vuoto, mostra mock data o empty state
            if (contributions.isEmpty) {
              return _buildEmptyStateWithMockOption(
                icon: Icons.trending_up,
                title: 'Nessun Contributo',
                subtitle: 'La community è ancora vuota',
                showMockButton: true,
              );
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
                  final contribution = contributions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildContributionCard(contribution),
                  );
                },
              ),
            );
          },
          loading: () => _buildSkeletonLoader(),
          error: (error, stack) => _buildEnhancedErrorState(error),
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
              return _buildEmptyStateWithAction(
                icon: AppIcons.editNote,
                title: 'Nessun Contributo',
                subtitle: 'Non hai ancora contribuito alla community',
                actionText: 'Come Contribuire',
                onActionTap: () {
                  // Navigate to Info tab (index depends on admin status)
                  final isAdmin = ref.read(isAdminProvider).asData?.value ?? false;
                  final infoTabIndex = isAdmin ? 3 : 2;
                  _tabController.animateTo(infoTabIndex);
                },
              );
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
                  final contribution = contributions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMyContributionCard(contribution),
                  );
                },
              ),
            );
          },
          loading: () => _buildSkeletonLoader(),
          error: (error, __) => _buildEnhancedErrorState(error),
        );
      },
    );
  }

  Widget _buildAdminTab() {
    return Consumer(
      builder: (context, ref, child) {
        final pendingContributions = ref.watch(pendingContributionsProvider);
        final moderationStats = ref.watch(moderationStatsProvider);

        return Column(
          children: [
            // Stats header
            moderationStats.when(
              data: (stats) => Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      icon: AppIcons.pendingActions,
                      label: 'Pending',
                      value: stats.pendingCount.toString(),
                      color: context.warningColor,
                    ),
                    _buildStatChip(
                      icon: Icons.lightbulb,
                      label: 'Tips',
                      value: stats.tipCount.toString(),
                      color: context.infoColor,
                    ),
                    _buildStatChip(
                      icon: Icons.warning,
                      label: 'Warnings',
                      value: stats.warningCount.toString(),
                      color: context.errorColor,
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Pending contributions list
            Expanded(
              child: pendingContributions.when(
                data: (contributions) {
                  if (contributions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.completeOutline,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nessun Contributo Pending',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tutti i contributi sono stati revisionati!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(pendingContributionsProvider);
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: contributions.length,
                      itemBuilder: (context, index) {
                        final contribution = contributions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAdminContributionCard(contribution),
                        );
                      },
                    ),
                  );
                },
                loading: () => _buildSkeletonLoader(),
                error: (error, __) => _buildEnhancedErrorState(error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildAdminContributionCard(CommunityContribution contribution) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _handleCardTap(contribution),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getContributionIcon(contribution.type),
                    color: _getTypeColor(contribution.type),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contribution.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(contribution.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contribution.exerciseName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                contribution.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'By ${contribution.userName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _handleApprove(contribution.id),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approva'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.successColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _handleReject(contribution.id),
                    icon: const Icon(AppIcons.cancel, size: 18),
                    label: const Text('Rifiuta'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleApprove(String contributionId) async {
    try {
      await ref.read(adminModerationProvider.notifier).approveContribution(contributionId);

      if (!mounted) return;

      SnackBarService.showSuccess(
        context,
        '✅ Contributo approvato!',
        duration: const Duration(seconds: 2),
      );

      // Refresh pending contributions
      ref.invalidate(pendingContributionsProvider);
      ref.invalidate(trendingContributionsProvider);
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: ${e.toString()}',
      );
    }
  }

  Future<void> _handleReject(String contributionId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rifiuta Contributo'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Motivo (opzionale)',
            hintText: 'Es: Informazione non corretta',
          ),
          maxLines: 3,
          onChanged: (value) {
            // Store value in dialog state
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'No reason provided'),
            style: TextButton.styleFrom(foregroundColor: context.errorColor),
            child: const Text('Rifiuta'),
          ),
        ],
      ),
    );

    if (reason == null) return;

    try {
      await ref.read(adminModerationProvider.notifier).rejectContribution(
            contributionId,
            reason,
          );

      if (!mounted) return;

      SnackBarService.showWarning(
        context,
        '❌ Contributo rifiutato',
        duration: const Duration(seconds: 2),
      );

      // Refresh pending contributions
      ref.invalidate(pendingContributionsProvider);
    } catch (e) {
      if (!mounted) return;

      SnackBarService.showError(
        context,
        'Errore: ${e.toString()}',
      );
    }
  }

  Widget _buildInfoTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
        // Info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Come Funziona',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  '💡',
                  'Condividi Consigli',
                  'Aiuta altri atleti condividendo i tuoi tips e tecniche',
                ),
                _buildInfoItem(
                  '⚠️',
                  'Avvisa sui Rischi',
                  'Segnala problemi di sicurezza o errori comuni',
                ),
                _buildInfoItem(
                  '📝',
                  'Correggi Errori',
                  'Migliora le informazioni degli esercizi nel database',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // XP System card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Sistema Punti XP',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildXPItem('Invia contributo', '+10 XP'),
                _buildXPItem('Contributo approvato', '+50 XP'),
                _buildXPItem('Contributo in evidenza', '+100 XP'),
                _buildXPItem('Voto su contributo', '+1 XP'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Current Status
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.construction,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sistema in Beta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La community è ancora in fase di sviluppo. Potrebbero esserci problemi di connessione o dati mancanti.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String title, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPItem(String action, String xp) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(action, style: theme.textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              xp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionCard(CommunityContribution contribution) {
    // Get current user ID for vote tracking
    final userAsync = ref.watch(currentUserProvider);
    final currentUserId = userAsync.asData?.value?.uid;

    return VotingCard(
      contribution: contribution,
      currentUserId: currentUserId,
      onUpvote: () => _handleVote(contribution.id, true),
      onDownvote: () => _handleVote(contribution.id, false),
      onComment: () => _handleComment(contribution),
      onTap: () => _handleCardTap(contribution),
    );
  }

  // Vote handling
  Future<void> _handleVote(String contributionId, bool isUpvote) async {
    try {
      await ref.read(contributionSubmissionProvider.notifier).voteOnContribution(
            contributionId,
            isUpvote,
          );

      if (!mounted) return;

      // Success feedback
      SnackBarService.showSuccess(
        context,
        isUpvote ? '👍 Voto positivo!' : '👎 Voto negativo',
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      if (!mounted) return;

      // Error feedback
      SnackBarService.showError(
        context,
        'Errore: ${e.toString()}',
      );
    }
  }

  void _handleComment(CommunityContribution contribution) {
    // TODO: Open comment modal/bottom sheet
    SnackBarService.showInfo(
      context,
      '💬 Commenti coming soon!',
    );
  }

  void _handleCardTap(CommunityContribution contribution) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContributionDetailModal(
        contribution: contribution,
      ),
    );
  }

  void _showCreateContributionModal() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateContributionModal(),
    );
  }

  Widget _buildMyContributionCard(CommunityContribution contribution) {
    // Get current user ID
    final userAsync = ref.watch(currentUserProvider);
    final currentUserId = userAsync.asData?.value?.uid;

    // Use VotingCard anche per i propri contributi
    // L'utente può vedere i voti ma il sistema previene voto multiplo
    return VotingCard(
      contribution: contribution,
      currentUserId: currentUserId,
      onUpvote: () => _handleVote(contribution.id, true),
      onDownvote: () => _handleVote(contribution.id, false),
      onComment: () => _handleComment(contribution),
      onTap: () => _handleCardTap(contribution),
    );
  }

  Widget _buildStatusBadge(ContributionStatus status) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedErrorState(Object error) {
    final theme = Theme.of(context);
    final isNetworkError = error.toString().contains('unavailable') ||
        error.toString().contains('network') ||
        error.toString().contains('firestore.googleapis.com');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNetworkError
                    ? context.warningColor.withValues(alpha: 0.1)
                    : theme.colorScheme.error.withValues(alpha: 0.1),
              ),
              child: Icon(
                isNetworkError ? AppIcons.wifiOff : Icons.error_outline,
                size: 64,
                color: isNetworkError ? context.warningColor : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isNetworkError ? 'Sei Offline' : 'Errore',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isNetworkError
                  ? 'Controlla la tua connessione internet e riprova'
                  : 'Si è verificato un errore imprevisto',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Retry
                ref.invalidate(trendingContributionsProvider);
                ref.invalidate(userContributionsProvider);
                ref.invalidate(userContributionStatsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onActionTap,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onActionTap,
              icon: const Icon(Icons.help_outline),
              label: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithMockOption({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showMockButton = false,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (showMockButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Load mock data
                  SnackBarService.showInfo(
                    context,
                    'Modalità demo non ancora disponibile',
                  );
                },
                icon: const Icon(Icons.preview),
                label: const Text('Visualizza Demo'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getContributionIcon(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return Icons.lightbulb_outline;
      case ContributionType.warning:
        return AppIcons.warningAmberRounded;
      case ContributionType.correction:
        return AppIcons.editNote;
      case ContributionType.technique:
        return Icons.fitness_center;
      case ContributionType.variant:
        return Icons.alt_route;
      case ContributionType.translation:
        return AppIcons.translate;
    }
  }

  Color _getTypeColor(ContributionType type) {
    switch (type) {
      case ContributionType.tip:
        return context.infoColor;
      case ContributionType.warning:
        return context.warningColor;
      case ContributionType.correction:
        return context.colors.primary;
      case ContributionType.technique:
        return context.successColor;
      case ContributionType.variant:
        return Colors.teal;
      case ContributionType.translation:
        return Colors.indigo;
    }
  }

  Color _getStatusColor(ContributionStatus status) {
    switch (status) {
      case ContributionStatus.approved:
        return context.successColor;
      case ContributionStatus.rejected:
        return context.errorColor;
      case ContributionStatus.pending:
        return context.warningColor;
      case ContributionStatus.underReview:
        return context.colors.primary;
    }
  }

  String _getStatusText(ContributionStatus status) {
    switch (status) {
      case ContributionStatus.approved:
        return 'APPROVATO';
      case ContributionStatus.rejected:
        return 'RIFIUTATO';
      case ContributionStatus.pending:
        return 'IN ATTESA';
      case ContributionStatus.underReview:
        return 'IN REVISIONE';
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {

  _SliverTabBarDelegate(this.tabBar, {required this.theme});
  final TabBar tabBar;
  final ThemeData theme;

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
