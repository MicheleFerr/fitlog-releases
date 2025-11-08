import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Grafico interattivo per tracciare il progresso del peso
/// con gesture support per zoom, pan e dettagli on-tap
class InteractiveWeightChart extends ConsumerStatefulWidget {
  
  const InteractiveWeightChart({
    super.key,
    required this.data,
    this.targetWeight,
    this.onDataPointTap,
  });
  final List<WeightData> data;
  final double? targetWeight;
  final Function(WeightData)? onDataPointTap;

  @override
  ConsumerState<InteractiveWeightChart> createState() => _InteractiveWeightChartState();
}

class _InteractiveWeightChartState extends ConsumerState<InteractiveWeightChart>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // Zoom and pan state
  double _minX = 0;
  double _maxX = 30;
  final double _touchedX = -1;
  int? _touchedIndex;
  
  // Period selection
  ChartPeriod _selectedPeriod = ChartPeriod.month;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
    _updateAxisRange();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _updateAxisRange() {
    final filteredData = _getFilteredData();
    if (filteredData.isEmpty) return;
    
    setState(() {
      switch (_selectedPeriod) {
        case ChartPeriod.week:
          _minX = 0;
          _maxX = 7;
          break;
        case ChartPeriod.month:
          _minX = 0;
          _maxX = 30;
          break;
        case ChartPeriod.threeMonths:
          _minX = 0;
          _maxX = 90;
          break;
        case ChartPeriod.year:
          _minX = 0;
          _maxX = 365;
          break;
        case ChartPeriod.all:
          _minX = 0;
          _maxX = filteredData.length.toDouble();
          break;
      }
    });
  }
  
  List<WeightData> _getFilteredData() {
    final now = DateTime.now();
    final cutoffDate = switch (_selectedPeriod) {
      ChartPeriod.week => now.subtract(const Duration(days: 7)),
      ChartPeriod.month => now.subtract(const Duration(days: 30)),
      ChartPeriod.threeMonths => now.subtract(const Duration(days: 90)),
      ChartPeriod.year => now.subtract(const Duration(days: 365)),
      ChartPeriod.all => DateTime(2000),
    };
    
    return widget.data
        .where((d) => d.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredData = _getFilteredData();
    
    if (filteredData.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return Column(
      children: [
        // Period selector
        _buildPeriodSelector(context),
        const SizedBox(height: 20),
        
        // Chart
        SizedBox(
          height: 300,
          child: GestureDetector(
            onScaleUpdate: (details) {
              // Pinch to zoom
              if (details.scale != 1.0) {
                setState(() {
                  final newRange = (_maxX - _minX) / details.scale;
                  final center = (_maxX + _minX) / 2;
                  _minX = (center - newRange / 2).clamp(0, filteredData.length.toDouble());
                  _maxX = (center + newRange / 2).clamp(0, filteredData.length.toDouble());
                });
              }
            },
            onHorizontalDragUpdate: (details) {
              // Pan gesture
              final dx = details.primaryDelta! / context.size!.width * (_maxX - _minX);
              setState(() {
                _minX = (_minX - dx).clamp(0, filteredData.length.toDouble());
                _maxX = (_maxX - dx).clamp(0, filteredData.length.toDouble());
              });
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  _buildChartData(filteredData, theme),
                  duration: const Duration(milliseconds: 250),
                );
              },
            ),
          ),
        ),
        
        // Stats summary
        if (_touchedIndex != null && _touchedIndex! < filteredData.length)
          _buildDataPointDetails(filteredData[_touchedIndex!], theme),
          
        // Legend
        _buildLegend(theme),
      ],
    );
  }
  
  Widget _buildPeriodSelector(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getPeriodLabel(period)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                    _updateAxisRange();
                  });
                  HapticFeedback.lightImpact();
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  LineChartData _buildChartData(List<WeightData> data, ThemeData theme) {
    final spots = <FlSpot>[];
    final minWeight = data.map((d) => d.weight).reduce(math.min);
    final maxWeight = data.map((d) => d.weight).reduce(math.max);
    
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].weight));
    }
    
    return LineChartData(
      minX: _minX,
      maxX: _maxX,
      minY: minWeight - 2,
      maxY: maxWeight + 2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 5,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            reservedSize: 30,
            interval: _getBottomInterval(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.length) return const SizedBox();
              
              final date = data[index].date;
              final format = _selectedPeriod == ChartPeriod.week 
                  ? DateFormat('E')
                  : DateFormat('d/M');
              
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  format.format(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        // Main weight line
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: theme.colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isTouched = index == _touchedIndex;
              return FlDotCirclePainter(
                radius: isTouched ? 6 : 4,
                color: theme.colorScheme.primary,
                strokeWidth: isTouched ? 3 : 2,
                strokeColor: theme.colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.3),
                theme.colorScheme.primary.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        
        // Target weight line
        if (widget.targetWeight != null)
          LineChartBarData(
            spots: [
              FlSpot(_minX, widget.targetWeight!),
              FlSpot(_maxX, widget.targetWeight!),
            ],
            isCurved: false,
            color: context.colors.success.withValues(alpha: 0.6),
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (event, response) {
          if (event is FlPanUpdateEvent || event is FlTapUpEvent) {
            setState(() {
              if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                _touchedIndex = response.lineBarSpots!.first.spotIndex;
                if (_touchedIndex! < data.length) {
                  HapticFeedback.lightImpact();
                  widget.onDataPointTap?.call(data[_touchedIndex!]);
                }
              } else {
                _touchedIndex = null;
              }
            });
          }
        },
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor is deprecated, use fitInsideHorizontally/Vertically instead
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipPadding: const EdgeInsets.all(8),
          // TODO: tooltipRoundedRadius deprecated in fl_chart - use custom painter if needed
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.spotIndex;
              if (index >= data.length) return null;
              
              final weightData = data[index];
              return LineTooltipItem(
                '${weightData.weight.toStringAsFixed(1)} kg\n${DateFormat('d MMM').format(weightData.date)}',
                TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
  
  Widget _buildDataPointDetails(WeightData data, ThemeData theme) {
    final previousData = _getPreviousDataPoint(data);
    final change = previousData != null ? data.weight - previousData.weight : 0;
    final changePercent = previousData != null 
        ? ((data.weight - previousData.weight) / previousData.weight * 100)
        : 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Data',
            value: DateFormat('d MMM yyyy').format(data.date),
            icon: AppIcons.calendar,
            theme: theme,
          ),
          _buildStatItem(
            label: 'Peso',
            value: '${data.weight.toStringAsFixed(1)} kg',
            icon: AppIcons.weight,
            theme: theme,
          ),
          _buildStatItem(
            label: 'Variazione',
            value: '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
            subtitle: '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
            icon: change >= 0 ? AppIcons.trendingUp : AppIcons.trendingDown,
            color: change >= 0 ? context.colors.error : context.colors.success,
            theme: theme,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required String label,
    required String value,
    String? subtitle,
    required IconData icon,
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
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color?.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
      ],
    );
  }
  
  Widget _buildLegend(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: theme.colorScheme.primary,
            label: 'Peso attuale',
            theme: theme,
          ),
          if (widget.targetWeight != null) ...[
            SizedBox(width: 24),
            _buildLegendItem(
              color: context.colors.success,
              label: 'Obiettivo',
              isDashed: true,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            border: isDashed ? Border.all(color: color, width: 1) : null,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.lineChart,
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
          const SizedBox(height: 8),
          Text(
            'Inizia a registrare il tuo peso',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
  
  WeightData? _getPreviousDataPoint(WeightData current) {
    final index = widget.data.indexOf(current);
    if (index > 0) {
      return widget.data[index - 1];
    }
    return null;
  }
  
  double _getBottomInterval() {
    final range = _maxX - _minX;
    if (range <= 7) return 1;
    if (range <= 30) return 5;
    if (range <= 90) return 15;
    return 30;
  }
  
  String _getPeriodLabel(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.week:
        return '1S';
      case ChartPeriod.month:
        return '1M';
      case ChartPeriod.threeMonths:
        return '3M';
      case ChartPeriod.year:
        return '1A';
      case ChartPeriod.all:
        return 'Tutto';
    }
  }
}

enum ChartPeriod {
  week,
  month,
  threeMonths,
  year,
  all,
}

class WeightData {
  
  const WeightData({
    required this.date,
    required this.weight,
    this.note,
    this.workoutId,
  });
  final DateTime date;
  final double weight;
  final String? note;
  final String? workoutId;
}
