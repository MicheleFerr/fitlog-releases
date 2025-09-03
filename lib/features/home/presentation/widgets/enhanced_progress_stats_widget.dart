import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../domain/models/home_widget_config.dart';
import '../../domain/models/level_system.dart';
import '../../providers/progress_widget_preferences_provider.dart';
import '../../providers/volume_settings_provider.dart';
import 'volume_display_widget.dart';
import 'level_info_modal.dart';
import 'weekly_distribution_modal.dart';
import 'volume_details_modal.dart';
import 'package:intl/intl.dart';

class EnhancedProgressStatsWidget extends ConsumerStatefulWidget {
  final WidgetSize size;
  
  const EnhancedProgressStatsWidget({
    super.key,
    required this.size,
  });

  @override
  ConsumerState<EnhancedProgressStatsWidget> createState() => _EnhancedProgressStatsWidgetState();
}

class _EnhancedProgressStatsWidgetState extends ConsumerState<EnhancedProgressStatsWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(progressWidgetPreferencesProvider);
    final layout = preferences.layout;
    
    return GestureDetector(
      onTap: () => _showLevelSystemInfo(context),
      onLongPressStart: (_) {
        _animationController.forward();
        HapticFeedback.mediumImpact();
      },
      onLongPressEnd: (_) {
        _animationController.reverse();
        _showOptionsMenu(context);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildLayoutView(context, layout),
          );
        },
      ),
    );
  }
  
  Widget _buildLayoutView(BuildContext context, ProgressWidgetLayout layout) {
    switch (layout) {
      case ProgressWidgetLayout.minimal:
        return _buildMinimalView(context);
      case ProgressWidgetLayout.compact:
        return _buildCompactView(context);
      case ProgressWidgetLayout.full:
        return _buildFullView(context);
    }
  }
  
  Widget _buildMinimalView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // TODO: Replace with actual user XP from provider
    final levelInfo = LevelSystem.getLevelInfo(2450); 
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Row(
          children: [
            // Level Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${levelInfo.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'LVL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // XP Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelInfo.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        l10n.xpPoints(levelInfo.totalXp),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: levelInfo.progressPercentage,
                          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final analyticsState = ref.watch(analyticsProvider);
    final frequencyStats = ref.read(analyticsProvider.notifier).getFrequencyStats();
    final preferences = ref.watch(progressWidgetPreferencesProvider);
    
    // TODO: Replace with actual user XP
    final levelInfo = LevelSystem.getLevelInfo(2450);
    
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with level badge
            Row(
              children: [
                _buildLevelBadge(context, levelInfo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.progressTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.last30Days,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () => _showOptionsMenu(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Metrics Grid
            if (analyticsState.isLoading)
              const CircularProgressIndicator()
            else
              _buildMetricsGrid(context, frequencyStats, preferences.visibleMetrics),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFullView(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final analyticsState = ref.watch(analyticsProvider);
    final frequencyStats = ref.read(analyticsProvider.notifier).getFrequencyStats();
    final volumeData = ref.watch(volumeChartDataProvider);
    final preferences = ref.watch(progressWidgetPreferencesProvider);
    
    // TODO: Replace with actual user XP
    final levelInfo = LevelSystem.getLevelInfo(2450);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.03),
              theme.colorScheme.secondary.withValues(alpha: 0.01),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _buildLevelBadge(context, levelInfo),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.completeAnalysis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.detailedStats,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            if (analyticsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (analyticsState.activities.isEmpty)
              _buildEmptyState(context)
            else ...[
              // Main stats
              if (preferences.visibleMetrics.contains('totalWorkouts') ||
                  preferences.visibleMetrics.contains('monthlyWorkouts') ||
                  preferences.visibleMetrics.contains('currentStreak'))
                _buildMainStats(context, analyticsState, frequencyStats),
              
              // Volume display with new design
              if (preferences.visibleMetrics.contains('weeklyVolume')) ...[
                const SizedBox(height: 20),
                _buildVolumeDisplay(context, volumeData),
              ],
              
              // Weekly distribution
              if (preferences.visibleMetrics.contains('weekdayDistribution')) ...[
                const SizedBox(height: 20),
                _buildWeekdayDistribution(
                  context, 
                  frequencyStats['dayDistribution'] as Map<int, int>? ?? {}
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelBadge(BuildContext context, LevelInfo levelInfo) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _showLevelBadgeInfo(context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${levelInfo.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'LVL',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
  
  Widget _buildMetricsGrid(BuildContext context, Map<String, dynamic> stats, Set<String> visibleMetrics) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final metrics = <Widget>[];
    
    if (visibleMetrics.contains('monthlyWorkouts')) {
      metrics.add(_buildMiniStat(
        context,
        label: l10n.workoutsLabel,
        value: '${stats['daysInLast30'] ?? 0}',
        icon: Icons.calendar_today,
      ));
    }
    
    if (visibleMetrics.contains('avgPerWeek')) {
      metrics.add(_buildMiniStat(
        context,
        label: l10n.avgPerWeek,
        value: '${stats['avgPerWeek'] ?? 0}',
        icon: Icons.schedule,
      ));
    }
    
    if (visibleMetrics.contains('currentStreak')) {
      metrics.add(_buildMiniStat(
        context,
        label: l10n.streakLabel,
        value: '${stats['currentStreak'] ?? 0}',
        icon: Icons.local_fire_department,
      ));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: metrics,
    );
  }
  
  Widget _buildMiniStat(BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMainStats(BuildContext context, dynamic analyticsState, Map<String, dynamic> frequencyStats) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(progressWidgetPreferencesProvider);
    final stats = <Widget>[];
    
    if (preferences.visibleMetrics.contains('totalWorkouts')) {
      stats.add(Expanded(
        child: _buildStatCard(
          context,
          icon: Icons.fitness_center,
          label: l10n.totalWorkouts,
          value: '${analyticsState.activities.length}',
          color: Colors.blue,
          subtitle: l10n.sinceRegistration,
        ),
      ));
    }
    
    if (preferences.visibleMetrics.contains('monthlyWorkouts')) {
      stats.add(Expanded(
        child: _buildStatCard(
          context,
          icon: Icons.calendar_today,
          label: l10n.thisMonth,
          value: '${frequencyStats['daysInLast30'] ?? 0}',
          color: Colors.orange,
          subtitle: l10n.activeDays,
        ),
      ));
    }
    
    if (preferences.visibleMetrics.contains('currentStreak')) {
      stats.add(Expanded(
        child: _buildStatCard(
          context,
          icon: Icons.local_fire_department,
          label: l10n.currentStreak,
          value: '${frequencyStats['currentStreak'] ?? 0}',
          color: Colors.red,
          subtitle: l10n.consecutiveDays,
        ),
      ));
    }
    
    if (stats.isEmpty) return const SizedBox.shrink();
    
    return Row(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          stats[i],
          if (i < stats.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
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
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVolumeDisplay(BuildContext context, Map<DateTime, double> volumeData) {
    // Ottieni le impostazioni del periodo
    final volumeSettings = ref.watch(volumeSettingsProvider);
    final dateRange = volumeSettings.getDateRange();
    
    // Calcola il volume totale per il periodo selezionato
    double totalVolume = 0;
    volumeData.forEach((date, volume) {
      if (date.isAfter(dateRange.start) && date.isBefore(dateRange.end)) {
        totalVolume += volume;
      }
    });
    
    // Usa il nuovo widget per visualizzare il volume
    return VolumeDisplayWidget(
      volumeInKg: totalVolume,
      showSettings: true,
      expandedView: widget.size == WidgetSize.large,
    );
  }
  
  Widget _buildVolumeChart(BuildContext context, Map<DateTime, double> volumeData) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalVolume,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildChart(context, volumeData),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart(BuildContext context, Map<DateTime, double> volumeData) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => 
      DateTime(now.year, now.month, now.day - (6 - i))
    );
    
    final spots = last7Days.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final date = entry.value;
      final dateKey = DateTime(date.year, date.month, date.day);
      final volume = volumeData[dateKey] ?? 0;
      return FlSpot(index, volume);
    }).toList();
    
    final maxVolume = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVolume > 0 ? maxVolume / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                  final date = last7Days[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('E', 'it').format(date).substring(0, 2),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: spot.y > 0 ? 4 : 2,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: spot.y > 0 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeekdayDistribution(BuildContext context, Map<int, int> distribution) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final maxCount = distribution.values.fold(0, (a, b) => a > b ? a : b);
    
    return InkWell(
      onTap: () => _showWeeklyDistributionInfo(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyDistribution,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayIndex = index + 1;
              final count = distribution[dayIndex == 7 ? 7 : dayIndex] ?? 0;
              final height = maxCount > 0 ? (count / maxCount) * 60 : 0;
              
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 60,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 24,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noWorkoutsRecorded,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.startFirstWorkout,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.dashboard_customize),
                title: Text(l10n.changeLayout),
                onTap: () {
                  Navigator.pop(context);
                  _showLayoutOptions(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: Text(l10n.selectMetrics),
                onTap: () {
                  Navigator.pop(context);
                  _showMetricsSelection(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l10n.resetDefaults),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(progressWidgetPreferencesProvider.notifier).resetToDefaults();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showLayoutOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLayout = ref.read(progressWidgetPreferencesProvider).layout;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              RadioListTile<ProgressWidgetLayout>(
                title: Text(l10n.fullView),
                subtitle: Text(AppLocalizations.of(context)!.completeStatistics),
                value: ProgressWidgetLayout.full,
                groupValue: currentLayout,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(progressWidgetPreferencesProvider.notifier).setLayout(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ProgressWidgetLayout>(
                title: Text(l10n.compactView),
                subtitle: Text(AppLocalizations.of(context)!.essentialStatistics),
                value: ProgressWidgetLayout.compact,
                groupValue: currentLayout,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(progressWidgetPreferencesProvider.notifier).setLayout(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<ProgressWidgetLayout>(
                title: Text(l10n.minimalView),
                subtitle: Text(AppLocalizations.of(context)!.levelAndXpOnly),
                value: ProgressWidgetLayout.minimal,
                groupValue: currentLayout,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(progressWidgetPreferencesProvider.notifier).setLayout(value);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showMetricsSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final metrics = {
      'totalWorkouts': l10n.totalWorkouts,
      'monthlyWorkouts': 'Allenamenti Mensili',
      'currentStreak': l10n.currentStreak,
      'weeklyVolume': l10n.weeklyVolume,
      'weekdayDistribution': l10n.weeklyDistribution,
      'avgPerWeek': l10n.avgPerWeek,
    };
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MetricsSelectionSheet(
        metrics: metrics,
        ref: ref,
      ),
    );
  }
  
  void _showLevelSystemInfo(BuildContext context) {
    // TODO: Replace with actual user XP
    final levelInfo = LevelSystem.getLevelInfo(2450);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LevelInfoModal(
        currentLevel: levelInfo.level,
        currentXp: levelInfo.currentXp,
        xpForNextLevel: levelInfo.xpForNextLevel,
      ),
    );
  }
  
  void _showWeeklyDistributionInfo(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);
    
    // Crea i dati per la distribuzione settimanale
    final weeklyData = <String, double>{
      'mon': 0,
      'tue': 0,
      'wed': 0,
      'thu': 0,
      'fri': 0,
      'sat': 0,
      'sun': 0,
    };
    
    // TODO: Popola con dati reali dalla analytics
    // Per ora usiamo dati di esempio
    weeklyData['mon'] = 12500;
    weeklyData['tue'] = 8000;
    weeklyData['wed'] = 15000;
    weeklyData['thu'] = 0;
    weeklyData['fri'] = 10000;
    weeklyData['sat'] = 18000;
    weeklyData['sun'] = 5000;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeeklyDistributionModal(
        weeklyData: weeklyData,
      ),
    );
  }
  
  void _showVolumeDetailsModal(BuildContext context) {
    // Ottieni i dati del volume dal provider
    final volumeData = ref.watch(volumeChartDataProvider);
    final volumeSettings = ref.watch(volumeSettingsProvider);
    final dateRange = volumeSettings.getDateRange();
    
    // Calcola il volume totale per il periodo selezionato
    double totalVolume = 0;
    volumeData.forEach((date, volume) {
      if (date.isAfter(dateRange.start) && date.isBefore(dateRange.end)) {
        totalVolume += volume;
      }
    });
    
    // Usa i dati reali del volume per il grafico
    // Se volumeData è vuoto, usa dati di esempio
    final dailyData = volumeData.isNotEmpty ? volumeData : <DateTime, double>{};
    
    // Se non ci sono dati, genera dati di esempio
    if (dailyData.isEmpty) {
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        // Simula dati con pattern realistico
        if (date.weekday == 1 || date.weekday == 3 || date.weekday == 5) {
          dailyData[date] = 10000 + (i * 100).toDouble();
        } else if (date.weekday == 7) {
          dailyData[date] = 5000; // Domenica più leggera
        } else if (date.weekday == 6) {
          dailyData[date] = 15000; // Sabato più pesante
        } else {
          dailyData[date] = 0; // Giorni di riposo
        }
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VolumeDetailsModal(
        currentVolume: totalVolume,
        dailyVolumeData: dailyData,
      ),
    );
  }
  
  void _showLevelBadgeInfo(BuildContext context) {
    _showLevelSystemInfo(context);
  }
  
  
  Widget _buildUpcomingPerks(BuildContext context, int currentLevel) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final upcomingPerks = <int, LevelPerk>{
      5: LevelPerk.customWorkoutTemplates,
      10: LevelPerk.advancedAnalytics,
      15: LevelPerk.socialFeatures,
      20: LevelPerk.personalRecords,
      25: LevelPerk.customExercises,
      30: LevelPerk.workoutPrograms,
      35: LevelPerk.nutritionTracking,
      40: LevelPerk.advancedTimers,
      45: LevelPerk.teamWorkouts,
      50: LevelPerk.coachingMode,
    };
    
    final filteredPerks = upcomingPerks.entries
        .where((entry) => entry.key > currentLevel)
        .take(3);
    
    return Column(
      children: filteredPerks.map((entry) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${entry.key}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    entry.value.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.levelRequired(entry.key),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// Widget stateful per la selezione delle metriche con aggiornamento in tempo reale
class _MetricsSelectionSheet extends ConsumerStatefulWidget {
  final Map<String, String> metrics;
  final WidgetRef ref;
  
  const _MetricsSelectionSheet({
    required this.metrics,
    required this.ref,
  });
  
  @override
  ConsumerState<_MetricsSelectionSheet> createState() => _MetricsSelectionSheetState();
}

class _MetricsSelectionSheetState extends ConsumerState<_MetricsSelectionSheet> {
  late Set<String> _selectedMetrics;
  
  @override
  void initState() {
    super.initState();
    // Inizializza con le metriche attualmente selezionate
    _selectedMetrics = Set.from(
      widget.ref.read(progressWidgetPreferencesProvider).visibleMetrics
    );
  }
  
  void _toggleMetric(String metricKey) {
    setState(() {
      if (_selectedMetrics.contains(metricKey)) {
        _selectedMetrics.remove(metricKey);
      } else {
        _selectedMetrics.add(metricKey);
      }
    });
    
    // Aggiorna immediatamente il provider
    widget.ref.read(progressWidgetPreferencesProvider.notifier)
        .setVisibleMetrics(_selectedMetrics);
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.selectMetrics,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.metrics.entries.map((entry) {
                    final isSelected = _selectedMetrics.contains(entry.key);
                    return CheckboxListTile(
                      title: Text(entry.value),
                      value: isSelected,
                      onChanged: (_) => _toggleMetric(entry.key),
                      activeColor: theme.colorScheme.primary,
                      checkColor: theme.colorScheme.onPrimary,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reset alle metriche di default
                        setState(() {
                          _selectedMetrics = {
                            'totalWorkouts',
                            'monthlyWorkouts', 
                            'currentStreak',
                            'weeklyVolume',
                          };
                        });
                        widget.ref.read(progressWidgetPreferencesProvider.notifier)
                            .setVisibleMetrics(_selectedMetrics);
                      },
                      child: Text(l10n.resetDefaults),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.done),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}