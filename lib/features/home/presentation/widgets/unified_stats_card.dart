import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class UnifiedStatsCard extends ConsumerStatefulWidget {

  const UnifiedStatsCard({super.key, this.onTapXP, this.onTapAchievements});
  final VoidCallback? onTapXP;
  final VoidCallback? onTapAchievements;

  @override
  ConsumerState<UnifiedStatsCard> createState() => _UnifiedStatsCardState();
}

class _UnifiedStatsCardState extends ConsumerState<UnifiedStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _levelController;
  late AnimationController _xpController;
  late AnimationController _pulseController;
  late Animation<double> _levelScale;
  late Animation<double> _xpProgress;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _levelController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _xpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _levelScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _levelController, curve: Curves.elasticOut),
    );

    _xpProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _xpController, curve: Curves.easeInOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _levelController.forward();
    _xpController.forward();
  }

  @override
  void dispose() {
    _levelController.dispose();
    _xpController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userStatsAsync = ref.watch(userContributionStatsProvider);
    final achievementXPAsync = ref.watch(achievementXPProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTapXP?.call();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header con titolo
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              AppIcons.autoAwesome,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🏆 Progressi & Achievement',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getMotivationalText(
                              streakAsync.asData?.value ?? 0,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // XP e Level Display
                Builder(
                  builder: (context) {
                    // Ottieni i dati o usa default
                    final communityStats = userStatsAsync.valueOrNull;
                    final achievementData = achievementXPAsync.valueOrNull;

                    if (communityStats == null || achievementData == null) {
                      // Mostra skeleton o default mentre carica
                      return _buildDefaultXPDisplay(context, theme);
                    }

                    // Calcola XP totali
                    final communityXP = communityStats.totalPoints;
                    final achievementXP = achievementData.totalXP;
                    final totalXP = communityXP + achievementXP;

                    // Calcola livello (ogni 500 XP)
                    final level = (totalXP / 500).floor() + 1;
                    final currentLevelXP = totalXP % 500;
                    final progress = currentLevelXP / 500;

                    return Column(
                      children: [
                        // Level Badge
                        ScaleTransition(
                          scale: _levelScale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getLevelColor(level),
                                  _getLevelColor(level).withValues(alpha: 0.3),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getLevelColor(
                                    level,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Level icon background
                                Icon(
                                  _getLevelIcon(level),
                                  size: 40,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                // Level number
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'LV',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$level',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // XP Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.bolt,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$totalXP XP',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Level Progress Bar
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Livello $level',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '$currentLevelXP / 500 XP',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Livello ${level + 1}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _xpProgress,
                              builder: (context, child) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress * _xpProgress.value,
                                    minHeight: 10,
                                    backgroundColor: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getLevelColor(level),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                icon: AppIcons.people,
                                label: 'Community',
                                value: '$communityXP XP',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                icon: AppIcons.achievement,
                                label: 'Achievement',
                                value: '$achievementXP XP',
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                icon: AppIcons.streak,
                                label: 'Streak',
                                value: '${streakAsync.asData?.value ?? 0}',
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Recent Achievements
                        if (achievementData.recentAchievements.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                AppIcons.star,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Achievement Recenti',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...achievementData.recentAchievements.take(3).map((
                            achievement,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildAchievementItem(
                                context,
                                achievement: achievement,
                              ),
                            );
                          }),
                          if (achievementData.recentAchievements.length > 3)
                            TextButton(
                              onPressed: widget.onTapAchievements,
                              child: Text(
                                'Vedi tutti (${achievementData.recentAchievements.length})',
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    BuildContext context, {
    required Achievement achievement,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: achievement.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '+${achievement.xpReward} XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultXPDisplay(BuildContext context, ThemeData theme) {
    // Mostra display XP con valori a 0
    return Column(
      children: [
        // Level Badge (livello 1)
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.green, Colors.green.withValues(alpha: 0.3)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                AppIcons.workout,
                size: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LV',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // XP Display (0 XP)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.bolt, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              '0 XP',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar vuota
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Livello 1', style: theme.textTheme.bodySmall),
                Text(
                  '0 / 500 XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('Livello 2', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Stats vuote
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: AppIcons.people,
                label: 'Community',
                value: '0 XP',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: AppIcons.achievement,
                label: 'Achievement',
                value: '0 XP',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                context,
                icon: AppIcons.streak,
                label: 'Streak',
                value: '0',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }


  String _getMotivationalText(int streak) {
    if (streak >= 30) return '🔥 Inarrestabile! 30+ giorni di streak!';
    if (streak >= 14) return '💪 Campione! 2 settimane consecutive!';
    if (streak >= 7) return '⭐ Ottimo! Una settimana completa!';
    if (streak >= 3) return '🚀 Bene! Mantieni il ritmo!';
    if (streak >= 1) return '✨ Iniziato! Continua così!';
    return '🎯 Inizia oggi il tuo percorso!';
  }

  Color _getLevelColor(int level) {
    if (level >= 20) return Colors.purple;
    if (level >= 15) return Colors.deepOrange;
    if (level >= 10) return Colors.orange;
    if (level >= 5) return Colors.blue;
    return Colors.green;
  }

  IconData _getLevelIcon(int level) {
    if (level >= 20) return AppIcons.diamond;
    if (level >= 15) return AppIcons.expert;
    if (level >= 10) return AppIcons.achievement;
    if (level >= 5) return AppIcons.star;
    return AppIcons.workout;
  }
}
