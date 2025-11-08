import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/community/presentation/widgets/community_initializer.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class CommunityPulseCard extends ConsumerStatefulWidget {
  
  const CommunityPulseCard({
    super.key,
    this.onViewAll,
  });
  final VoidCallback? onViewAll;

  @override
  ConsumerState<CommunityPulseCard> createState() => _CommunityPulseCardState();
}

class _CommunityPulseCardState extends ConsumerState<CommunityPulseCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentIndex = 0;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // _pulseController.repeat(reverse: true); // Breathing effect disabled
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Buongiorno! Review esercizi mattutini';
    } else if (hour < 18) {
      return '☀️ Pomeriggio produttivo! Vota i contributi';
    } else {
      return '🌙 Sera! Controlla i recovery tips';
    }
  }
  
  String _getMotivationalText(UserContributionStats? stats) {
    if (stats == null) return 'Inizia a contribuire!';
    
    if (stats.currentStreak > 0) {
      return '🔥 ${stats.currentStreak} giorni di streak!';
    }
    
    if (stats.totalPoints > 0) {
      return '⭐ ${stats.totalPoints} punti totali';
    }
    
    return '🚀 Unisciti alla community!';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contributionsAsync = ref.watch(contributionsForReviewProvider);
    final userStatsAsync = ref.watch(userContributionStatsProvider);
    
    // Wrap con initializer per garantire che le collezioni esistano
    return CommunityInitializer.withInitialization(
      child: SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      _AnimatedIcon(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Hub',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              _getGreeting(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          AppIcons.expandMore,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  userStatsAsync.when(
                    data: (stats) => _buildStatsRow(stats, theme),
                    loading: () => _buildStatsRowSkeleton(theme),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  
                  // Expanded content
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 20),
                        contributionsAsync.when(
                          data: (contributions) {
                            if (contributions.isEmpty) {
                              return _buildEmptyState(theme);
                            }
                            return _buildContributionsList(
                              contributions,
                              theme,
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => Text('Errore: $error'),
                        ),
                      ],
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  
                  // Action buttons
                  if (!_isExpanded) ...[
                    const SizedBox(height: 16),
                    contributionsAsync.when(
                      data: (contributions) {
                        if (contributions.isEmpty) {
                          return _buildEmptyActionButton(theme);
                        }
                        return _buildQuickActions(
                          contributions.length,
                          theme,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
  
  Widget _buildStatsRow(UserContributionStats stats, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: AppIcons.streak,
          value: stats.currentStreak.toString(),
          label: 'Streak',
          color: context.colors.secondary,
        ),
        _StatItem(
          icon: AppIcons.star,
          value: stats.totalPoints.toString(),
          label: 'Punti',
          color: context.colors.warning,
        ),
        _StatItem(
          icon: AppIcons.complete,
          value: stats.approvedContributions.toString(),
          label: 'Approvati',
          color: context.colors.success,
        ),
        _StatItem(
          icon: AppIcons.achievement,
          value: '#${stats.weeklyRank > 0 ? stats.weeklyRank : '-'}',
          label: 'Rank',
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
  
  Widget _buildStatsRowSkeleton(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        4,
        (index) => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(int count, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _isExpanded = true;
              });
            },
            icon: const Icon(AppIcons.howToVote),
            label: Text('Review $count contributi'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: widget.onViewAll,
          icon: const Icon(AppIcons.forward),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyActionButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.onViewAll,
        icon: const Icon(AppIcons.explore),
        label: const Text('Esplora Community'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          side: BorderSide(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContributionsList(
    List<CommunityContribution> contributions,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Da revieware',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.95),
            itemCount: math.min(contributions.length, 5),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final contribution = contributions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _MiniContributionCard(
                  contribution: contribution,
                  onVote: (isUpvote) {
                    ref
                        .read(contributionSubmissionProvider.notifier)
                        .voteOnContribution(contribution.id, isUpvote);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            math.min(contributions.length, 5),
            (index) => Container(
              width: index == _currentIndex ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == _currentIndex
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.celebration,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            'Tutto reviewato!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ottimo lavoro, hai reviewato tutti i contributi',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
          child: Icon(
            AppIcons.people,
            color: context.colors.surface,
            size: 24,
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _MiniContributionCard extends StatelessWidget {
  
  const _MiniContributionCard({
    required this.contribution,
    required this.onVote,
  });
  final CommunityContribution contribution;
  final Function(bool) onVote;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getTypeIcon(context, contribution.type),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  contribution.exerciseName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contribution.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            contribution.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filled(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onVote(false);
                },
                icon: Icon(AppIcons.close),
                style: IconButton.styleFrom(
                  backgroundColor: context.colors.error.withValues(alpha: 0.1),
                  foregroundColor: context.colors.error,
                ),
              ),
              IconButton.filled(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onVote(true);
                },
                icon: Icon(AppIcons.check),
                style: IconButton.styleFrom(
                  backgroundColor: context.colors.success.withValues(alpha: 0.1),
                  foregroundColor: context.colors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _getTypeIcon(BuildContext context, ContributionType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ContributionType.tip:
        icon = AppIcons.lightbulb;
        color = context.colors.warning;
        break;
      case ContributionType.warning:
        icon = AppIcons.warning;
        color = context.colors.secondary;
        break;
      case ContributionType.correction:
        icon = AppIcons.edit;
        color = context.colors.primary;
        break;
      case ContributionType.technique:
        icon = AppIcons.fitnessCenter;
        color = context.colors.tertiary;
        break;
      default:
        icon = AppIcons.info;
        color = context.colors.surfaceContainerHighest;
    }
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }
}
