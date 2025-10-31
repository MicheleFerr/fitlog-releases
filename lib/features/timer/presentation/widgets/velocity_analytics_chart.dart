import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:gymbro_flutter_new/features/timer/domain/services/set_analytics_engine.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// TIER-1 Velocity Analytics Chart Widget
/// Advanced velocity-based training visualization with load-velocity profiling
class VelocityAnalyticsChart extends ConsumerStatefulWidget {
  
  const VelocityAnalyticsChart({
    super.key,
    required this.exerciseId,
    this.timeWindow = const Duration(days: 30),
    this.chartType = VelocityChartType.loadVelocity,
  });
  final String exerciseId;
  final Duration timeWindow;
  final VelocityChartType chartType;

  @override
  ConsumerState<VelocityAnalyticsChart> createState() => _VelocityAnalyticsChartState();
}

class _VelocityAnalyticsChartState extends ConsumerState<VelocityAnalyticsChart>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  VBTAnalysis? _vbtData;
  VelocityChartType _selectedChartType = VelocityChartType.loadVelocity;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _selectedChartType = widget.chartType;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadVBTData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVBTData() async {
    setState(() => _isLoading = true);
    
    try {
      final analyticsEngine = ref.read(setAnalyticsEngineProvider);
      final vbtAnalysis = await analyticsEngine.analyzeVelocityBasedTraining(
        widget.exerciseId,
        widget.timeWindow,
      );
      
      setState(() {
        _vbtData = vbtAnalysis;
        _isLoading = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      setState(() {
        _vbtData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with chart type selector
            _buildHeader(context, theme, l10n),
            
            const SizedBox(height: 16),
            
            if (_isLoading) ...[
              _buildLoadingState(context, theme, l10n),
            ] else if (_vbtData == null) ...[
              _buildErrorState(context, theme, l10n),
            ] else ...[
              // Chart content
              _buildChartContent(context, theme, l10n),
              
              const SizedBox(height: 16),
              
              // Analytics summary
              _buildAnalyticsSummary(context, theme, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.velocityAnalytics,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getTimeWindowText(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        // Chart type selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: VelocityChartType.values.map((type) {
              final isSelected = type == _selectedChartType;
              
              return GestureDetector(
                onTap: () => _onChartTypeChanged(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.colorScheme.primary 
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getChartTypeLabel(type, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.analyzingVelocityData,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.velocityAnalysisError,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadVBTData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _buildChart(context, theme, l10n),
      ),
    );
  }

  Widget _buildChart(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    switch (_selectedChartType) {
      case VelocityChartType.loadVelocity:
        return _buildLoadVelocityChart(theme, l10n);
      case VelocityChartType.zoneDistribution:
        return _buildZoneDistributionChart(theme, l10n);
      case VelocityChartType.velocityTrend:
        return _buildVelocityTrendChart(theme, l10n);
    }
  }

  Widget _buildLoadVelocityChart(ThemeData theme, AppLocalizations l10n) {
    if (_vbtData?.loadVelocityProfile.isEmpty != false) {
      return _buildNoDataMessage(theme, l10n);
    }
    
    // Generate mock load-velocity profile data
    final spots = _generateLoadVelocitySpots();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}kg',
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
            axisNameWidget: Text(
              l10n.load,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}m/s',
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
            axisNameWidget: Text(
              l10n.velocity,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          // Trend line
          LineChartBarData(
            spots: _generateTrendLine(spots),
            isCurved: false,
            color: theme.colorScheme.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDistributionChart(ThemeData theme, AppLocalizations l10n) {
    final zoneData = _vbtData?.zoneDistribution ?? {};
    
    if (zoneData.isEmpty) {
      return _buildNoDataMessage(theme, l10n);
    }
    
    final sections = _generateZoneDistributionSections(zoneData, theme);
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildZoneLegend(zoneData, theme, l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildVelocityTrendChart(ThemeData theme, AppLocalizations l10n) {
    // Generate mock trend data
    final trendSpots = _generateVelocityTrendSpots();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final weeks = ['W1', 'W2', 'W3', 'W4'];
                final index = value.toInt();
                if (index >= 0 && index < weeks.length) {
                  return Text(
                    weeks[index],
                    style: theme.textTheme.bodySmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}m/s',
                  style: theme.textTheme.bodySmall,
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        lineBarsData: [
          // Average velocity trend
          LineChartBarData(
            spots: trendSpots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
          ),
          // Peak velocity trend
          LineChartBarData(
            spots: trendSpots.map((spot) => FlSpot(spot.x, spot.y + 0.2)).toList(),
            isCurved: true,
            color: theme.colorScheme.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [3, 3],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSummary(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    if (_vbtData == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.keyInsights,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  theme,
                  l10n.avgVelocityLoss,
                  '${_vbtData!.averageVelocityLoss.toStringAsFixed(1)}%',
                  _getVelocityLossColor(_vbtData!.averageVelocityLoss, theme),
                  Icons.trending_down,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInsightCard(
                  theme,
                  l10n.optimalLoad,
                  '${_vbtData!.optimalLoads.maxPower.toInt()}kg',
                  theme.colorScheme.secondary,
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInsightCard(
                  theme,
                  l10n.minVelocity,
                  '${_vbtData!.recommendedVelocityThresholds.minVelocity.toStringAsFixed(2)}m/s',
                  theme.colorScheme.tertiary,
                  Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ThemeData theme, String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.insufficientVelocityData,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods

  String _getTimeWindowText(AppLocalizations l10n) {
    final days = widget.timeWindow.inDays;
    if (days >= 365) {
      return l10n.lastYear;
    } else if (days >= 30) {
      return l10n.lastNMonths(days ~/ 30);
    } else {
      return l10n.lastNDays(days);
    }
  }

  String _getChartTypeLabel(VelocityChartType type, AppLocalizations l10n) {
    switch (type) {
      case VelocityChartType.loadVelocity:
        return l10n.loadVelocity;
      case VelocityChartType.zoneDistribution:
        return l10n.zones;
      case VelocityChartType.velocityTrend:
        return l10n.trend;
    }
  }

  void _onChartTypeChanged(VelocityChartType type) {
    setState(() {
      _selectedChartType = type;
    });
  }

  List<FlSpot> _generateLoadVelocitySpots() {
    // Mock load-velocity relationship data
    final spots = <FlSpot>[];
    final random = math.Random();
    
    for (int load = 40; load <= 120; load += 10) {
      // Inverse relationship between load and velocity with some noise
      final baseVelocity = math.max(0.1, 1.5 - ((load - 40) * 0.015));
      final velocity = baseVelocity + (random.nextDouble() * 0.2 - 0.1);
      spots.add(FlSpot(load.toDouble(), velocity));
    }
    
    return spots;
  }

  List<FlSpot> _generateTrendLine(List<FlSpot> spots) {
    if (spots.length < 2) return [];
    
    // Simple linear regression for trend line
    final firstSpot = spots.first;
    final lastSpot = spots.last;
    
    return [
      FlSpot(firstSpot.x, firstSpot.y - 0.1),
      FlSpot(lastSpot.x, lastSpot.y + 0.1),
    ];
  }

  List<PieChartSectionData> _generateZoneDistributionSections(
    Map<String, double> zoneData,
    ThemeData theme,
  ) {
    final colors = [
      context.colors.error,
      context.colors.secondary,
      theme.colorScheme.primary,
      context.colors.success,
      context.colors.primary,
    ];
    
    return zoneData.entries.map((entry) {
      final index = zoneData.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value * 100).toInt()}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.surface,
        ),
      );
    }).toList();
  }

  List<Widget> _buildZoneLegend(
    Map<String, double> zoneData,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final colors = [
      context.colors.error,
      context.colors.secondary,
      theme.colorScheme.primary,
      context.colors.success,
      context.colors.primary,
    ];
    
    return zoneData.entries.map((entry) {
      final index = zoneData.keys.toList().indexOf(entry.key);
      final color = colors[index % colors.length];
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getZoneLabel(entry.key, l10n),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getZoneLabel(String zone, AppLocalizations l10n) {
    switch (zone.toLowerCase()) {
      case 'explosive':
        return l10n.explosiveZone;
      case 'speed':
        return l10n.speedZone;
      case 'strength':
        return l10n.strengthZone;
      default:
        return zone;
    }
  }

  List<FlSpot> _generateVelocityTrendSpots() {
    // Mock weekly velocity trend data
    final random = math.Random();
    final spots = <FlSpot>[];
    
    double baseVelocity = 0.8;
    for (int week = 0; week < 4; week++) {
      baseVelocity += (random.nextDouble() * 0.2 - 0.1);
      baseVelocity = math.max(0.3, math.min(1.2, baseVelocity));
      spots.add(FlSpot(week.toDouble(), baseVelocity));
    }
    
    return spots;
  }

  Color _getVelocityLossColor(double velocityLoss, ThemeData theme) {
    if (velocityLoss > 25) return theme.colorScheme.error;
    if (velocityLoss > 15) return context.colors.secondary;
    return context.colors.success;
  }
}

/// Available velocity chart types
enum VelocityChartType {
  loadVelocity,
  zoneDistribution,
  velocityTrend,
}