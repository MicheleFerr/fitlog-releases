import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_progress_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/mini_sparkline.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class ExerciseProgressScreen extends ConsumerStatefulWidget {
  const ExerciseProgressScreen({super.key});

  @override
  ConsumerState<ExerciseProgressScreen> createState() =>
      _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState
    extends ConsumerState<ExerciseProgressScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMetrics = ref.watch(exerciseProgressMetricsProvider);

    final filteredExercises =
        allMetrics.entries.where((entry) {
          if (_searchQuery.isEmpty) return true;
          return entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList()..sort(
          (a, b) => b.value.lastWorkoutDate.compareTo(a.value.lastWorkoutDate),
        );

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: context.colors.surface.withValues(alpha: 0),
        elevation: 0,
        leading: IconButton(
          icon: const SemanticIcon(icon: AppIcons.back, semanticLabel: 'Back'),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.homePath);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.exerciseProgress,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.l10n.atAGlanceSubtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: context.l10n.searchExercisesPlaceholder,
                prefixIcon: const SemanticIcon(
                  icon: AppIcons.search,
                  semanticLabel: 'Search',
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const SemanticIcon(
                          icon: AppIcons.clear,
                          semanticLabel: 'Clear',
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.colors.surfaceContainer,
              ),
            ),
          ),

          // Exercise list
          Expanded(child: _buildExerciseList(filteredExercises)),
        ],
      ),
    );
  }

  Widget _buildExerciseList(
    List<MapEntry<String, ExerciseProgressMetrics>> exercises,
  ) {
    if (exercises.isEmpty) {
      return EnhancedEmptyState(
        type: EmptyStateType.info,
        icon: AppIcons.workout,
        title: context.l10n.noExercisesFound,
        description: _searchQuery.isEmpty
            ? context.l10n.noExercisesFoundDesc
            : 'No exercises match "$_searchQuery"',
        primaryActionLabel: context.l10n.startWorkout,
        primaryActionIcon: AppIcons.add,
        onPrimaryAction: () => context.push(AppRoutes.workoutPath),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('exercise_progress_list'),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: context.tabBarInset,
      ),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final entry = exercises[index];
        return _ExerciseAtAGlanceCard(
          exerciseName: entry.key,
          metrics: entry.value,
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(
              AppRoutes.exerciseProgressDetailPath,
              extra: entry.key,
            );
          },
        );
      },
    );
  }
}

/// Exercise "At a Glance" Card
///
/// Redesigned card showing key exercise stats at first glance:
/// - Hero stats: PR Weight, Est. 1RM, Total Volume
/// - Mini sparkline of recent sessions
/// - One-liner insight ("Weight up 8% recently")
/// - Last workout inline ("Last: 3x8 @ 60kg · 3d ago")
/// - PR badge when exercise has a recent PR
class _ExerciseAtAGlanceCard extends StatelessWidget {
  const _ExerciseAtAGlanceCard({
    required this.exerciseName,
    required this.metrics,
    required this.onTap,
  });

  final String exerciseName;
  final ExerciseProgressMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasRecentPR = _hasRecentPR();
    final trendData = _calculateTrend();
    final estimated1RM = _calculateEstimated1RM();
    final lastSessionInfo = _getLastSessionInfo(context);
    final sparklineData = _getSparklineData();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: hasRecentPR ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: hasRecentPR
            ? BorderSide(
                color: context.colors.warning.withValues(alpha: 0.6),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Name + trend badge + sparkline
              _buildHeader(context, sparklineData),
              const SizedBox(height: 14),

              // Row 2: Hero stats (PR Weight, Est. 1RM, Volume)
              _buildHeroStats(context, estimated1RM),
              const SizedBox(height: 12),

              // Row 3: Insight one-liner
              _buildInsight(context, trendData),
              const SizedBox(height: 8),

              // Row 4: Last session inline
              _buildLastSession(context, lastSessionInfo),
            ],
          ),
        ),
      ),
    );
  }

  /// Header row: exercise name, PR badge, trend indicator, sparkline
  Widget _buildHeader(BuildContext context, List<double> sparklineData) {
    final hasRecentPR_ = _hasRecentPR();

    return Row(
      children: [
        // Exercise name + sessions count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      exerciseName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasRecentPR_) ...[
                    const SizedBox(width: 8),
                    _buildPRBadge(context),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${metrics.totalSessions} ${context.l10n.totalSessions.toLowerCase()} · ${_getRelativeTime(context, metrics.lastWorkoutDate)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Sparkline
        MiniSparkline(
          dataPoints: sparklineData,
          isPositiveTrend: metrics.weightTrend == TrendDirection.improving,
          width: 64,
          height: 28,
        ),
      ],
    );
  }

  /// PR badge (gold)
  Widget _buildPRBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.achievement,
            size: 12,
            color: context.colors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            context.l10n.recentPR,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Hero stats: 3 key numbers
  Widget _buildHeroStats(BuildContext context, double estimated1RM) {
    final totalVolumeFormatted = _formatVolume(metrics.totalVolume);

    return Row(
      children: [
        _HeroStat(
          label: context.l10n.prWeight,
          value: '${metrics.maxWeight.toStringAsFixed(1)}kg',
          color: context.colors.warning,
          icon: AppIcons.achievement,
        ),
        const SizedBox(width: 8),
        _HeroStat(
          label: context.l10n.est1RM,
          value: estimated1RM > 0
              ? '${estimated1RM.toStringAsFixed(1)}kg'
              : '—',
          color: context.colors.primary,
          icon: AppIcons.workout,
        ),
        const SizedBox(width: 8),
        _HeroStat(
          label: context.l10n.totalVol,
          value: totalVolumeFormatted,
          color: context.colors.success,
          icon: AppIcons.analytics,
        ),
      ],
    );
  }

  /// One-liner insight based on trend
  Widget _buildInsight(BuildContext context, _TrendInfo trendData) {
    final color = trendData.getColor(context);
    final text = trendData.getText(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(trendData.icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Last session inline
  Widget _buildLastSession(BuildContext context, String lastSessionText) {
    return Row(
      children: [
        Icon(
          AppIcons.clock,
          size: AppIconSize.tiny,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            lastSessionText,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Icon(
          AppIcons.chevronRight,
          size: AppIconSize.small,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  // -- Data calculation helpers --

  /// Check if exercise has a PR within the last 14 days
  bool _hasRecentPR() {
    if (metrics.allSets.isEmpty) return false;
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    final recentSets = metrics.allSets.where((s) => s.date.isAfter(cutoff));
    if (recentSets.isEmpty) return false;

    final recentMax = recentSets.fold<double>(
      0,
      (max, s) => s.weight > max ? s.weight : max,
    );
    return recentMax >= metrics.maxWeight && metrics.maxWeight > 0;
  }

  /// Calculate trend info for insight text
  _TrendInfo _calculateTrend() {
    if (metrics.allSets.length < 4) {
      return _TrendInfo.newExercise;
    }

    final sets = metrics.allSets;
    final midpoint = sets.length ~/ 2;
    final firstHalf = sets.sublist(0, midpoint);
    final secondHalf = sets.sublist(midpoint);

    final firstAvg =
        firstHalf.fold<double>(0, (sum, s) => sum + s.weight) /
        firstHalf.length;
    final secondAvg =
        secondHalf.fold<double>(0, (sum, s) => sum + s.weight) /
        secondHalf.length;

    if (firstAvg == 0) return _TrendInfo.newExercise;

    final percentChange = ((secondAvg - firstAvg) / firstAvg) * 100;
    final absChange = percentChange.abs();

    if (absChange <= 2.0) return _TrendInfo(type: _TrendType.stable);
    if (percentChange > 0) {
      return _TrendInfo(
        type: _TrendType.improving,
        percent: absChange,
      );
    }
    return _TrendInfo(type: _TrendType.declining, percent: absChange);
  }

  /// Calculate estimated 1RM from best set
  double _calculateEstimated1RM() {
    if (metrics.allSets.isEmpty) return 0;

    double best1RM = 0;
    for (final set in metrics.allSets) {
      if (set.weight <= 0 || set.reps <= 0) continue;
      final est = OneRMCalculator.calculateAverage(
        set.weight,
        set.reps,
      );
      if (est > best1RM) best1RM = est;
    }
    return best1RM;
  }

  /// Get last session summary text
  String _getLastSessionInfo(BuildContext context) {
    if (metrics.allSets.isEmpty) {
      return context.l10n.lastSessionSimple('—');
    }

    final lastDate = metrics.lastWorkoutDate;
    final timeAgo = _getRelativeTime(context, lastDate);

    // Get sets from the last session
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final lastSessionSets = metrics.allSets.where((s) {
      final sDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sDate == lastDateOnly;
    }).toList();

    if (lastSessionSets.isEmpty) {
      return context.l10n.lastSessionSimple(timeAgo);
    }

    // Calculate typical set: most common weight, avg reps
    final setCount = lastSessionSets.length;
    final maxWeight = lastSessionSets.fold<double>(
      0,
      (max, s) => s.weight > max ? s.weight : max,
    );
    final avgReps = (lastSessionSets.fold<double>(
          0,
          (sum, s) => sum + s.reps,
        ) /
        setCount)
        .round();

    return context.l10n.lastSession(
      setCount,
      avgReps,
      maxWeight.toStringAsFixed(1),
      timeAgo,
    );
  }

  /// Get sparkline data (max weight per session, last 8 sessions)
  List<double> _getSparklineData() {
    if (metrics.allSets.isEmpty) return [];

    // Group by date and get max weight per session
    final Map<String, double> sessionMaxWeights = {};
    for (final set in metrics.allSets) {
      final dateKey =
          '${set.date.year}-${set.date.month}-${set.date.day}';
      if (!sessionMaxWeights.containsKey(dateKey) ||
          set.weight > sessionMaxWeights[dateKey]!) {
        sessionMaxWeights[dateKey] = set.weight;
      }
    }

    // Sort by date and take last 8
    final sortedEntries = sessionMaxWeights.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final recentEntries = sortedEntries.length > 8
        ? sortedEntries.sublist(sortedEntries.length - 8)
        : sortedEntries;

    return recentEntries.map((e) => e.value).toList();
  }

  /// Format volume to human-readable (e.g., "12.5t" or "850kg")
  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toStringAsFixed(0)}kg';
  }

  /// Get relative time string
  static String _getRelativeTime(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return context.l10n.today;
    } else if (difference.inDays == 1) {
      return context.l10n.yesterday;
    } else if (difference.inDays < 7) {
      return context.l10n.daysAgoShort(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return context.l10n.weeksAgo(weeks);
    } else {
      final months = (difference.inDays / 30).round();
      return context.l10n.monthsAgo(months);
    }
  }
}

/// Individual hero stat widget
class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: AppIconSize.small, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend types for insight generation
enum _TrendType { improving, declining, stable, newExercise }

/// Trend info for building insight widget
class _TrendInfo {
  _TrendInfo({required this.type, this.percent = 0});

  final _TrendType type;
  final double percent;

  static final newExercise = _TrendInfo(type: _TrendType.newExercise);

  String getText(BuildContext context) {
    return switch (type) {
      _TrendType.improving => context.l10n.insightImproving(
          percent.toStringAsFixed(0),
        ),
      _TrendType.declining => context.l10n.insightDeclining(
          percent.toStringAsFixed(0),
        ),
      _TrendType.stable => context.l10n.insightStable,
      _TrendType.newExercise => context.l10n.insightNewExercise,
    };
  }

  IconData get icon => switch (type) {
        _TrendType.improving => AppIcons.trendingUp,
        _TrendType.declining => AppIcons.trendingDown,
        _TrendType.stable => AppIcons.remove,
        _TrendType.newExercise => AppIcons.lightbulb,
      };

  Color getColor(BuildContext context) => switch (type) {
        _TrendType.improving => context.colors.success,
        _TrendType.declining => context.colors.error,
        _TrendType.stable => context.colors.primary,
        _TrendType.newExercise => context.colors.onSurfaceVariant,
      };
}
