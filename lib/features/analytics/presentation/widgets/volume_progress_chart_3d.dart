import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Grafico 3D interattivo per visualizzare il volume di allenamento
/// con effetti di profondità e animazioni touch-responsive
class VolumeProgressChart3D extends ConsumerStatefulWidget {
  
  const VolumeProgressChart3D({
    super.key,
    required this.data,
    this.chartType = VolumeChartType.weekly,
    this.onBarTap,
    this.showTrend = true,
  });
  final List<VolumeData> data;
  final VolumeChartType chartType;
  final Function(VolumeData)? onBarTap;
  final bool showTrend;

  @override
  ConsumerState<VolumeProgressChart3D> createState() => _VolumeProgressChart3DState();
}

class _VolumeProgressChart3DState extends ConsumerState<VolumeProgressChart3D>
    with TickerProviderStateMixin {
  
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  
  int? _touchedIndex;
  final bool _is3DMode = false; // Disabled by default
  VolumeChartType _currentChartType = VolumeChartType.weekly;
  
  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    
    _entranceController.forward();
    _currentChartType = widget.chartType;
  }
  
  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final processedData = _processDataByType();
    
    return Column(
      children: [
        // Controls
        _buildControls(theme),
        const SizedBox(height: 20),
        
        // Chart
        SizedBox(
          height: 350,
          child: AnimatedBuilder(
            animation: _entranceAnimation,
            builder: (context, child) {
              return _buildChart(processedData, theme);
            },
          ),
        ),
        
        // Stats summary
        _buildStatsSummary(processedData, theme),
        
        // Legend
        _buildLegend(theme),
      ],
    );
  }
  
  Widget _buildControls(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Chart type selector
        SegmentedButton<VolumeChartType>(
          segments: const [
            ButtonSegment(
              value: VolumeChartType.daily,
              label: Text('Giorno'),
              icon: Icon(AppIcons.calendarViewDay, size: 18),
            ),
            ButtonSegment(
              value: VolumeChartType.weekly,
              label: Text('Settimana'),
              icon: Icon(AppIcons.calendarViewWeek, size: 18),
            ),
            ButtonSegment(
              value: VolumeChartType.monthly,
              label: Text('Mese'),
              icon: Icon(AppIcons.calendarViewMonth, size: 18),
            ),
          ],
          selected: {_currentChartType},
          onSelectionChanged: (Set<VolumeChartType> newSelection) {
            if (newSelection.isNotEmpty) {
              setState(() {
                _currentChartType = newSelection.first;
              });
              HapticFeedback.lightImpact();
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildChart(List<ProcessedVolumeData> data, ThemeData theme) {
    if (data.isEmpty) {
      return _buildEmptyState(theme);
    }
    
    final maxVolume = data.map((d) => d.totalVolume).reduce(math.max);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BarChart(
        BarChartData(
          maxY: maxVolume * 1.2,
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final volumeData = entry.value;
            final isTouched = index == _touchedIndex;
            
            return BarChartGroupData(
              x: index,
              barsSpace: 4,
              barRods: [
                // Main volume bar
                BarChartRodData(
                  toY: volumeData.totalVolume * _entranceAnimation.value,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxVolume * 1.2,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                
                // Muscle group breakdown
                if (volumeData.muscleGroupVolumes.isNotEmpty) ...[
                  BarChartRodData(
                    toY: volumeData.totalVolume * _entranceAnimation.value,
                    width: 8,
                    rodStackItems: _buildMuscleGroupStack(
                      volumeData.muscleGroupVolumes,
                      volumeData.totalVolume,
                      theme,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ],
              ],
              showingTooltipIndicators: isTouched ? [0] : [],
            );
          }).toList(),
          
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= data.length) return const SizedBox();
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formatLabel(data[index].date, _currentChartType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVolume / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          
          barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response?.spot != null) {
                final index = response!.spot!.touchedBarGroupIndex;
                setState(() {
                  _touchedIndex = index;
                });
                
                if (index >= 0 && index < data.length) {
                  HapticFeedback.lightImpact();
                  // Convert ProcessedVolumeData back to VolumeData
                  // widget.onBarTap?.call(data[index]);
                }
              }
            },
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor is deprecated, use fitInsideHorizontally/Vertically instead
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex >= data.length) return null;
                
                final volumeData = data[groupIndex];
                return BarTooltipItem(
                  '${volumeData.totalVolume.toStringAsFixed(0)} kg\n'
                  '${volumeData.workoutCount} allenamenti',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        
        swapAnimationDuration: const Duration(milliseconds: 300),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
  
  List<BarChartRodStackItem> _buildMuscleGroupStack(
    Map<String, double> muscleVolumes,
    double totalVolume,
    ThemeData theme,
  ) {
    final items = <BarChartRodStackItem>[];
    double currentY = 0;
    
    final colors = [
      context.colors.primary,
      context.colors.error,
      context.colors.success,
      context.colors.secondary,
      context.colors.tertiary,
      Colors.teal,
    ];
    
    int colorIndex = 0;
    muscleVolumes.forEach((muscle, volume) {
      items.add(BarChartRodStackItem(
        currentY,
        currentY + volume,
        colors[colorIndex % colors.length].withValues(alpha: 0.7),
      ));
      currentY += volume;
      colorIndex++;
    });
    
    return items;
  }
  
  Widget _buildStatsSummary(List<ProcessedVolumeData> data, ThemeData theme) {
    if (data.isEmpty) return const SizedBox();
    
    final totalVolume = data.fold(0.0, (sum, d) => sum + d.totalVolume);
    final avgVolume = totalVolume / data.length;
    final maxVolume = data.map((d) => d.totalVolume).reduce(math.max);
    final trend = _calculateTrend(data);
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.fitness_center,
            label: 'Volume Totale',
            value: '${(totalVolume / 1000).toStringAsFixed(1)}k kg',
            theme: theme,
          ),
          _buildStatItem(
            icon: Icons.analytics,
            label: 'Media',
            value: '${avgVolume.toStringAsFixed(0)} kg',
            theme: theme,
          ),
          _buildStatItem(
            icon: Icons.rocket_launch,
            label: 'Record',
            value: '${maxVolume.toStringAsFixed(0)} kg',
            theme: theme,
          ),
          _buildStatItem(
            icon: trend > 0 ? Icons.trending_up : Icons.trending_down,
            label: 'Trend',
            value: '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
            color: trend > 0 ? context.colors.success : context.colors.error,
            theme: theme,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(
          color: theme.colorScheme.primary,
          label: 'Volume Totale',
          theme: theme,
        ),
        if (widget.showTrend)
          _buildLegendItem(
            color: context.colors.secondary,
            label: 'Trend Line',
            isDashed: true,
            theme: theme,
          ),
      ],
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            border: isDashed ? Border.all(color: color, width: 1) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun dato disponibile',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  List<ProcessedVolumeData> _processDataByType() {
    // Group data by chart type
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return _groupByDay();
      case VolumeChartType.weekly:
        return _groupByWeek();
      case VolumeChartType.monthly:
        return _groupByMonth();
    }
  }
  
  List<ProcessedVolumeData> _groupByDay() {
    final Map<DateTime, ProcessedVolumeData> grouped = {};
    
    for (final data in widget.data) {
      final key = DateTime(data.date.year, data.date.month, data.date.day);
      
      if (!grouped.containsKey(key)) {
        grouped[key] = ProcessedVolumeData(
          date: key,
          totalVolume: 0,
          workoutCount: 0,
          muscleGroupVolumes: {},
        );
      }
      
      grouped[key]!.totalVolume += data.volume;
      grouped[key]!.workoutCount++;
      
      if (data.muscleGroup != null) {
        grouped[key]!.muscleGroupVolumes[data.muscleGroup!] = 
            (grouped[key]!.muscleGroupVolumes[data.muscleGroup!] ?? 0) + data.volume;
      }
    }
    
    final sorted = grouped.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Return last 7 days
    return sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
  }
  
  List<ProcessedVolumeData> _groupByWeek() {
    // Implementation for weekly grouping
    return _groupByDay(); // Simplified for now
  }
  
  List<ProcessedVolumeData> _groupByMonth() {
    // Implementation for monthly grouping
    return _groupByDay(); // Simplified for now
  }
  
  String _formatLabel(DateTime date, VolumeChartType type) {
    switch (type) {
      case VolumeChartType.daily:
        return DateFormat('E').format(date);
      case VolumeChartType.weekly:
        return 'S${_getWeekOfMonth(date)}';
      case VolumeChartType.monthly:
        return DateFormat('MMM').format(date);
    }
  }
  
  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysDifference = date.difference(firstDayOfMonth).inDays;
    return (daysDifference / 7).floor() + 1;
  }
  
  double _calculateTrend(List<ProcessedVolumeData> data) {
    if (data.length < 2) return 0;
    
    final firstHalf = data.sublist(0, data.length ~/ 2);
    final secondHalf = data.sublist(data.length ~/ 2);
    
    final firstAvg = firstHalf.fold(0.0, (sum, d) => sum + d.totalVolume) / firstHalf.length;
    final secondAvg = secondHalf.fold(0.0, (sum, d) => sum + d.totalVolume) / secondHalf.length;
    
    if (firstAvg == 0) return 0;
    return ((secondAvg - firstAvg) / firstAvg) * 100;
  }
}

enum VolumeChartType {
  daily,
  weekly,
  monthly,
}

class VolumeData {
  
  const VolumeData({
    required this.date,
    required this.volume,
    this.muscleGroup,
    this.exerciseName,
    required this.sets,
    required this.reps,
  });
  final DateTime date;
  final double volume;
  final String? muscleGroup;
  final String? exerciseName;
  final int sets;
  final int reps;
}

class ProcessedVolumeData {
  
  ProcessedVolumeData({
    required this.date,
    required this.totalVolume,
    required this.workoutCount,
    required this.muscleGroupVolumes,
  });
  final DateTime date;
  double totalVolume;
  int workoutCount;
  Map<String, double> muscleGroupVolumes;
}