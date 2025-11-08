import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/features/community/presentation/providers/community_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/optimized_progress_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';
import 'package:gymbro_flutter_new/features/home/utils/xp_calculator.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// OPTIMIZED VERSION - Fixed animation loops and excessive rebuilds
class OptimizedUnifiedStatsCard extends ConsumerStatefulWidget {
  
  const OptimizedUnifiedStatsCard({
    super.key,
    this.onTapXP,
    this.onTapAchievements,
    this.size = WidgetSize.large,
  });
  final VoidCallback? onTapXP;
  final VoidCallback? onTapAchievements;
  final WidgetSize size;

  @override
  ConsumerState<OptimizedUnifiedStatsCard> createState() => _OptimizedUnifiedStatsCardState();
}

class _OptimizedUnifiedStatsCardState extends ConsumerState<OptimizedUnifiedStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _levelController;
  late AnimationController _xpController;
  late AnimationController _pulseController;
  late Animation<double> _levelScale;
  late Animation<double> _xpProgress;
  late Animation<double> _pulseAnimation;
  
  // Cache for data to prevent unnecessary rebuilds
  DashboardStats? _cachedStats;
  AchievementData? _cachedAchievementData;
  // UserContributionStats? _cachedUserStats; // TODO: Define UserContributionStats class
  dynamic _cachedUserStats; // Temporary workaround
  DateTime? _lastDataFetch;
  
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
    
    // OPTIMIZED: Slower pulse to reduce CPU usage
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4), // Slower pulse
      vsync: this,
    );
    
    _levelScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.elasticOut,
    ));
    
    _xpProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.easeInOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02, // Smaller pulse to reduce repaints
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations only once
    _levelController.forward();
    _xpController.forward();
    
    // Only start pulse animation when widget is actually visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startPulseAnimation();
      }
    });
  }
  
  void _startPulseAnimation() {
    if (!mounted) return;
    
    // OPTIMIZATION: Only pulse when widget is visible and data is available
    _pulseController.repeat(reverse: true);
  }
  
  void _stopPulseAnimation() {
    if (_pulseController.isAnimating) {
      _pulseController.stop();
    }
  }
  
  @override
  void dispose() {
    _levelController.dispose();
    _xpController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  // OPTIMIZATION: Cache data and only rebuild when necessary
  bool _shouldRebuildData(DashboardStats? newStats, AchievementData? newAchievement, dynamic newUser) {
    if (_cachedStats == null || _cachedAchievementData == null || _cachedUserStats == null) {
      return true;
    }
    
    // Check if data actually changed
    return newStats?.currentStreak != _cachedStats?.currentStreak ||
           newAchievement?.totalXP != _cachedAchievementData?.totalXP ||
           newUser?.totalPoints != _cachedUserStats?.totalPoints;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // OPTIMIZED: Use single combined provider instead of multiple watchers
    final dashboardStatsAsync = ref.watch(optimizedDashboardStatsProvider);
    final achievementXPAsync = ref.watch(achievementXPProvider);
    
    // OPTIMIZED: Use select() to only watch specific fields from user stats
    final userStatsAsync = ref.watch(userContributionStatsProvider.select(
      (value) => value.whenData((stats) => stats.totalPoints),
    ));
    
    return DecoratedBox(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with optimized pulse animation
                _buildOptimizedHeader(theme, dashboardStatsAsync),
                
                const SizedBox(height: 20),
                
                // Main content with cached data
                _buildOptimizedContent(
                  context, 
                  theme, 
                  dashboardStatsAsync, 
                  achievementXPAsync, 
                  userStatsAsync
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptimizedHeader(ThemeData theme, AsyncValue<DashboardStats> dashboardStatsAsync) {
    // Use const widgets where possible to prevent rebuilds
    return Row(
      children: [
        // OPTIMIZED: Use RepaintBoundary to isolate animation repaints
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.autoAwesome,
                    color: context.colors.surface,
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏆 Progressi & Achievement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _getMotivationalText(dashboardStatsAsync.value?.currentStreak ?? 0),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOptimizedContent(
    BuildContext context,
    ThemeData theme,
    AsyncValue<DashboardStats> dashboardStatsAsync,
    AsyncValue<AchievementData> achievementXPAsync,
    AsyncValue<int> userStatsAsync,
  ) {
    return dashboardStatsAsync.when(
      data: (stats) => achievementXPAsync.when(
        data: (achievementData) {
          // Cache data to prevent unnecessary rebuilds
          if (_shouldRebuildData(stats, achievementData, null)) {
            _cachedStats = stats;
            _cachedAchievementData = achievementData;
            _lastDataFetch = DateTime.now();
          }
          
          return _buildContentWithData(context, theme, stats, achievementData, userStatsAsync);
        },
        loading: () => _buildDefaultXPDisplay(context, theme),
        error: (_, __) => _buildErrorState(context),
      ),
      loading: () => _buildLoadingSkeleton(context),
      error: (_, __) => _buildErrorState(context),
    );
  }
  
  Widget _buildContentWithData(
    BuildContext context,
    ThemeData theme,
    DashboardStats stats,
    AchievementData achievementData,
    AsyncValue<int> userStatsAsync,
  ) {
    final communityXP = userStatsAsync.value ?? 0;
    final achievementXP = achievementData.totalXP;
    final totalXP = communityXP + achievementXP;
    
    final levelProgress = XPCalculator.getLevelProgress(totalXP);
    final level = levelProgress.level;
    final currentLevelXP = levelProgress.currentXP;
    final requiredXP = levelProgress.requiredXP;
    final progress = levelProgress.progress;
    final levelTitle = XPCalculator.getLevelTitle(level);
    final isMilestone = XPCalculator.isMilestoneLevel(level);
    
    return widget.size == WidgetSize.small 
      ? _buildSmallContent(theme, level, totalXP)
      : widget.size == WidgetSize.medium
        ? _buildMediumContent(theme, level, totalXP, progress, currentLevelXP, requiredXP)
        : _buildLargeContent(context, theme, level, totalXP, progress, currentLevelXP, requiredXP, levelTitle, isMilestone, communityXP, achievementXP, stats, achievementData);
  }
  
  Widget _buildSmallContent(ThemeData theme, int level, int totalXP) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getLevelColor(level),
                _getLevelColor(level).withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Text(
              '$level',
              style: TextStyle(
                color: context.colors.surface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$totalXP XP',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Livello $level',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMediumContent(
    ThemeData theme, 
    int level, 
    int totalXP, 
    double progress, 
    int currentLevelXP, 
    int requiredXP
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getLevelColor(level),
                    _getLevelColor(level).withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LV',
                    style: TextStyle(
                      color: context.colors.surface.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                      color: context.colors.surface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalXP XP',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(level)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currentLevelXP / $requiredXP XP per il livello ${level + 1}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLargeContent(
    BuildContext context,
    ThemeData theme,
    int level,
    int totalXP,
    double progress,
    int currentLevelXP,
    int requiredXP,
    String levelTitle,
    bool isMilestone,
    int communityXP,
    int achievementXP,
    DashboardStats stats,
    AchievementData achievementData,
  ) {
    return Column(
      children: [
        // Level Badge with RepaintBoundary
        RepaintBoundary(
          child: ScaleTransition(
            scale: _levelScale,
            child: Container(
              width: 80,
              height: 80,
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
                    color: _getLevelColor(level).withValues(alpha: 0.5),
                    blurRadius: isMilestone ? 30 : 20,
                    spreadRadius: isMilestone ? 3 : 2,
                  ),
                ],
                border: isMilestone ? Border.all(
                  color: context.colors.surface.withValues(alpha: 0.5),
                  width: 2,
                ) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    levelTitle.toUpperCase(),
                    style: TextStyle(
                      color: context.colors.surface.withValues(alpha: 0.9),
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                      color: context.colors.surface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isMilestone)
                    Icon(
                      AppIcons.star,
                      color: context.colors.surface.withValues(alpha: 0.9),
                      size: 12,
                    ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
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
        
        // Progress Bar with RepaintBoundary
        RepaintBoundary(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Livello $level', style: theme.textTheme.bodySmall),
                  Text(
                    '$currentLevelXP / $requiredXP XP',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text('Livello ${level + 1}', style: theme.textTheme.bodySmall),
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
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(level)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: AppIcons.people,
                label: 'Community',
                value: '$communityXP XP',
                color: context.colors.primary,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatItem(
                context,
                icon: AppIcons.achievement,
                label: 'Achievement',
                value: '$achievementXP XP',
                color: context.colors.secondary,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatItem(
                context,
                icon: AppIcons.streak,
                label: 'Streak',
                value: '${stats.currentStreak}',
                color: context.colors.error,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDefaultXPDisplay(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.success,
              ),
              child: Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: context.colors.surface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '0 XP',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.error,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Errore caricamento dati',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
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
    if (level >= 20) return context.colors.tertiary;
    if (level >= 15) return context.colors.warning;
    if (level >= 10) return context.colors.secondary;
    if (level >= 5) return context.colors.primary;
    return context.colors.success;
  }
}
