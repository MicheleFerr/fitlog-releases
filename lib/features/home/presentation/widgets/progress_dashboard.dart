import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
// Use cached provider for better performance and correct workout counting
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';

/// Debug logger for widget
class _WidgetLogger {
  static const bool _enableDebugLogs = kDebugMode; // Solo in debug mode, non in production

  static void log(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('👨‍💻 WIDGET [$timestamp] ProgressDashboard: $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('❌ WIDGET_ERROR [$timestamp] ProgressDashboard: $message${error != null ? ' - $error' : ''}');
    }
  }
}

/// Cached Progress Dashboard widget for the homepage
///
/// Features:
/// - Shows correct workout count (not individual exercises)
/// - Uses local cache for instant loading after first calculation
/// - Auto-updates when workouts are completed
/// - Shows key progress metrics (streak, total workouts, weekly frequency)
/// - Uses proper localization for all text
/// - Uses theme colors for consistency
/// - Handles loading and error states
/// - Performance optimized with local caching
/// - Clean Architecture compliant
class ProgressDashboard extends ConsumerWidget {
  const ProgressDashboard({super.key});

  // Static constructor logging
  static void _logConstruction() {
    if (kDebugMode) {
      debugPrint('🚨 CRITICAL: ProgressDashboard constructor called at ${DateTime.now()}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logConstruction(); // Log construction attempt
    try {
      _WidgetLogger.log('🚀 Building ProgressDashboard widget');

      final l10n = AppLocalizations.of(context);
      final theme = Theme.of(context);
      _WidgetLogger.log('Context and theme obtained');

      // Watch the cached dashboard stats provider
      _WidgetLogger.log('Watching cachedProgressProvider...');
      final dashboardStatsAsync = ref.watch(cachedProgressProvider);
      _WidgetLogger.log('Provider state: ${dashboardStatsAsync.runtimeType}');

      // Continue with normal widget build
      return _buildWidget(context, ref, l10n, theme, dashboardStatsAsync);
    } catch (e, stack) {
      _WidgetLogger.error('💥 CRITICAL BUILD ERROR in ProgressDashboard', e);
      _WidgetLogger.error('Stack trace: $stack');
      // Return error widget
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('ProgressDashboard Error: $e', style: const TextStyle(color: Colors.red)),
      );
    }
  }

  Widget _buildWidget(BuildContext context, WidgetRef ref, AppLocalizations l10n, ThemeData theme, AsyncValue<DashboardStats> dashboardStatsAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, l10n, theme),
              const SizedBox(height: 20),
              
              // Content based on state
              dashboardStatsAsync.when(
                loading: () {
                  _WidgetLogger.log('🔄 Provider is in LOADING state');
                  return _buildLoadingState(context, theme);
                },
                error: (error, stackTrace) {
                  _WidgetLogger.error('💥 Provider is in ERROR state', error);
                  _WidgetLogger.error('Error details: $error');
                  _WidgetLogger.error('Stack trace: $stackTrace');
                  return _buildErrorState(context, l10n, theme, error);
                },
                data: (stats) {
                  _WidgetLogger.log('✅ Provider returned DATA successfully');
                  _WidgetLogger.log('Stats received - Workouts: ${stats.totalWorkouts}, Streak: ${stats.currentStreak}');
                  _WidgetLogger.log('Stats received - Frequency: ${stats.weeklyFrequency}, Volume: ${stats.totalVolume}');
                  return _buildContentState(context, l10n, theme, stats);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.goNamed('analytics');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
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
                child: Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yourProgress,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      l10n.quickStats,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Skeleton for stats grid
        Row(
          children: List.generate(3, (index) => 
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
                child: _buildStatSkeleton(theme),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Skeleton for progress summary
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatSkeleton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, ThemeData theme, Object error) {
    _WidgetLogger.error('Building error state widget');
    _WidgetLogger.error('Error object type: ${error.runtimeType}');
    _WidgetLogger.error('Error string: $error');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.errorLoadingData,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.pullToRefresh,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DashboardStats stats,
  ) {
    return Column(
      children: [
        // Main Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                l10n: l10n,
                theme: theme,
                icon: Icons.local_fire_department,
                label: l10n.streak,
                value: '${stats.currentStreak}',
                subtitle: stats.currentStreak == 1 ? l10n.day : l10n.days(stats.currentStreak),
                color: _getStreakColor(stats.currentStreak, theme),
                onTap: () => _showStreakInfo(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                l10n: l10n,
                theme: theme,
                icon: Icons.fitness_center,
                label: l10n.totalWorkouts,
                value: '${stats.totalWorkouts}',
                subtitle: l10n.workouts,
                color: theme.colorScheme.primary,
                onTap: () => _showWorkoutsInfo(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context: context,
                l10n: l10n,
                theme: theme,
                icon: Icons.schedule,
                label: l10n.weeklyFrequency,
                value: stats.weeklyFrequency.toStringAsFixed(1),
                subtitle: l10n.perWeek,
                color: theme.colorScheme.secondary,
                onTap: () => _showFrequencyInfo(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Progress Summary
        _buildProgressSummary(context, l10n, theme, stats),
      ],
    );
  }
  
  Widget _buildStatCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressSummary(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DashboardStats stats,
  ) {
    final isImproving = _isProgressImproving(stats);
    final summaryColor = isImproving ? 
      theme.colorScheme.primary : 
      theme.colorScheme.tertiary;
    final summaryIcon = isImproving ? 
      Icons.trending_up : 
      Icons.trending_flat;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: summaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: summaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            summaryIcon,
            color: summaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProgressSummaryTitle(l10n, stats),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  _getProgressSummaryDescription(l10n, stats),
                  style: theme.textTheme.bodySmall?.copyWith(
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
  
  Color _getStreakColor(int streak, ThemeData theme) {
    if (streak >= 7) return Colors.orange;
    if (streak >= 3) return theme.colorScheme.primary;
    if (streak >= 1) return Colors.green;
    return theme.colorScheme.outline;
  }
  
  bool _isProgressImproving(DashboardStats stats) {
    // Simple heuristic: if they have a streak > 0 and workout frequency > 2, they're improving
    return stats.currentStreak > 0 && stats.weeklyFrequency >= 2.0;
  }
  
  String _getProgressSummaryTitle(AppLocalizations l10n, DashboardStats stats) {
    if (stats.currentStreak >= 7) {
      return l10n.excellentProgress;
    } else if (stats.currentStreak >= 3) {
      return l10n.goodProgress;
    } else if (stats.totalWorkouts > 0) {
      return l10n.keepGoing;
    } else {
      return l10n.getStarted;
    }
  }
  
  String _getProgressSummaryDescription(AppLocalizations l10n, DashboardStats stats) {
    if (stats.currentStreak >= 7) {
      return l10n.streakMotivation;
    } else if (stats.currentStreak >= 3) {
      return l10n.consistencyMotivation;
    } else if (stats.totalWorkouts > 0) {
      return l10n.buildStreakMotivation;
    } else {
      return l10n.startFirstWorkout;
    }
  }
  
  void _showStreakInfo(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).streakInfo),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showWorkoutsInfo(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).totalWorkoutsInfo),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showFrequencyInfo(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).weeklyFrequencyInfo),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}