import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:gymbro_flutter_new/features/timer/domain/services/set_analytics_engine.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// TIER-1 Performance Heatmap Widget
/// Visualizes performance data as an interactive heatmap with drill-down capabilities
class PerformanceHeatmapWidget extends ConsumerStatefulWidget {
  
  const PerformanceHeatmapWidget({
    super.key,
    required this.exerciseId,
    required this.startDate,
    required this.endDate,
    this.metric = HeatmapMetric.executionTime,
    this.showWeekView = true,
  });
  final String exerciseId;
  final DateTime startDate;
  final DateTime endDate;
  final HeatmapMetric metric;
  final bool showWeekView;

  @override
  ConsumerState<PerformanceHeatmapWidget> createState() => _PerformanceHeatmapWidgetState();
}

class _PerformanceHeatmapWidgetState extends ConsumerState<PerformanceHeatmapWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  HeatmapMetric _selectedMetric = HeatmapMetric.executionTime;
  DateTime? _selectedDate;
  List<HeatmapCell> _heatmapData = [];
  
  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.metric;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadHeatmapData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadHeatmapData() async {
    try {
      final analyticsEngine = ref.read(setAnalyticsEngineProvider);
      final timings = await analyticsEngine.generatePerformanceReport(
        widget.exerciseId,
        widget.startDate,
        widget.endDate,
      );
      
      setState(() {
        _heatmapData = _generateHeatmapData(timings);
      });
      
      _animationController.forward();
      
    } catch (e) {
      // Handle error - show empty state or error message
      setState(() {
        _heatmapData = [];
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
            // Header with metric selector
            _buildHeader(context, theme, l10n),
            
            const SizedBox(height: 16),
            
            // Heatmap grid
            if (_heatmapData.isNotEmpty) ...[
              _buildHeatmapGrid(context, theme, l10n),
              const SizedBox(height: 16),
              
              // Legend
              _buildLegend(context, theme, l10n),
              
              const SizedBox(height: 16),
              
              // Selected date details
              if (_selectedDate != null) ...[
                _buildSelectedDateDetails(context, theme, l10n),
              ],
            ] else ...[
              _buildEmptyState(context, theme, l10n),
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
                l10n.performanceHeatmap,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getDateRangeText(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // Metric selector dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HeatmapMetric>(
              value: _selectedMetric,
              isDense: true,
              items: HeatmapMetric.values.map((metric) {
                return DropdownMenuItem<HeatmapMetric>(
                  value: metric,
                  child: Text(
                    _getMetricLabel(metric, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (metric) {
                if (metric != null) {
                  setState(() {
                    _selectedMetric = metric;
                    _selectedDate = null;
                  });
                  _loadHeatmapData();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapGrid(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Week day labels
            if (widget.showWeekView) _buildWeekDayLabels(theme, l10n),
            
            const SizedBox(height: 8),
            
            // Heatmap cells
            _buildHeatmapCells(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDayLabels(ThemeData theme, AppLocalizations l10n) {
    final weekdays = [
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun,
    ];
    
    return Row(
      children: [
        const SizedBox(width: 30), // Space for month labels
        ...weekdays.map((day) => Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildHeatmapCells(BuildContext context, ThemeData theme) {
    if (_heatmapData.isEmpty) return const SizedBox.shrink();
    
    // Group data by weeks
    final weeks = _groupByWeeks(_heatmapData);
    
    return Column(
      children: weeks.asMap().entries.map((weekEntry) {
        final weekIndex = weekEntry.key;
        final week = weekEntry.value;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              // Month label (only show for first week of month)
              SizedBox(
                width: 30,
                child: _shouldShowMonthLabel(week, weekIndex) 
                  ? Text(
                      _getMonthLabel(week.first.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : null,
              ),
              // Week cells
              ...List.generate(7, (dayIndex) {
                final cellData = week.length > dayIndex ? week[dayIndex] : null;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: _buildHeatmapCell(context, theme, cellData),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeatmapCell(BuildContext context, ThemeData theme, HeatmapCell? cellData) {
    final isSelected = cellData?.date == _selectedDate;
    final hasData = cellData != null && cellData.value > 0;
    
    return GestureDetector(
      onTap: cellData != null ? () => _onCellTapped(cellData) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _getCellColor(cellData, theme),
          borderRadius: BorderRadius.circular(4),
          border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
          boxShadow: isSelected
            ? [BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              )]
            : null,
        ),
        child: hasData
          ? Center(
              child: Text(
                _getCellDisplayValue(cellData),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getCellTextColor(cellData, theme),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            )
          : null,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Text(
          l10n.less,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final intensity = index / 4.0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getIntensityColor(intensity, theme),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          l10n.more,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          _getMetricLabel(_selectedMetric, l10n),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDateDetails(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final selectedCell = _heatmapData.firstWhere((cell) => cell.date == _selectedDate);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatSelectedDate(_selectedDate!, l10n),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  theme,
                  l10n.sets,
                  selectedCell.setCount.toString(),
                  Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  theme,
                  _getMetricLabel(_selectedMetric, l10n),
                  _formatMetricValue(selectedCell.value, _selectedMetric),
                  _getMetricIcon(_selectedMetric),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  theme,
                  l10n.quality,
                  '${(selectedCell.qualityScore * 100).toInt()}%',
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.grid_view,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPerformanceData,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startWorkoutToSeeData,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods

  String _getDateRangeText(AppLocalizations l10n) {
    final formatter = MaterialLocalizations.of(context);
    return '${formatter.formatShortDate(widget.startDate)} - ${formatter.formatShortDate(widget.endDate)}';
  }

  String _getMetricLabel(HeatmapMetric metric, AppLocalizations l10n) {
    switch (metric) {
      case HeatmapMetric.executionTime:
        return l10n.executionTime;
      case HeatmapMetric.formScore:
        return l10n.formScore;
      case HeatmapMetric.fatigueIndex:
        return l10n.fatigueIndex;
      case HeatmapMetric.velocity:
        return l10n.velocity;
      case HeatmapMetric.consistency:
        return l10n.consistency;
    }
  }

  IconData _getMetricIcon(HeatmapMetric metric) {
    switch (metric) {
      case HeatmapMetric.executionTime:
        return Icons.timer;
      case HeatmapMetric.formScore:
        return Icons.star;
      case HeatmapMetric.fatigueIndex:
        return Icons.battery_alert;
      case HeatmapMetric.velocity:
        return Icons.speed;
      case HeatmapMetric.consistency:
        return Icons.trending_up;
    }
  }

  List<HeatmapCell> _generateHeatmapData(PerformanceReport report) {
    // Mock data generation - in real app, would process actual timing data
    final cells = <HeatmapCell>[];
    final random = math.Random();
    
    var currentDate = widget.startDate;
    while (currentDate.isBefore(widget.endDate) || currentDate.isAtSameMomentAs(widget.endDate)) {
      final hasData = random.nextDouble() > 0.3; // 70% chance of having data
      
      if (hasData) {
        final setCount = random.nextInt(5) + 1;
        final baseValue = _generateBaseValue(_selectedMetric, random);
        final qualityScore = 0.6 + (random.nextDouble() * 0.4);
        
        cells.add(HeatmapCell(
          date: currentDate,
          value: baseValue,
          setCount: setCount,
          qualityScore: qualityScore,
        ));
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return cells;
  }

  double _generateBaseValue(HeatmapMetric metric, math.Random random) {
    switch (metric) {
      case HeatmapMetric.executionTime:
        return 20000 + (random.nextDouble() * 30000); // 20-50 seconds
      case HeatmapMetric.formScore:
        return 60 + (random.nextDouble() * 40); // 60-100%
      case HeatmapMetric.fatigueIndex:
        return random.nextDouble() * 100; // 0-100%
      case HeatmapMetric.velocity:
        return 0.3 + (random.nextDouble() * 0.8); // 0.3-1.1 m/s
      case HeatmapMetric.consistency:
        return 50 + (random.nextDouble() * 50); // 50-100%
    }
  }

  List<List<HeatmapCell>> _groupByWeeks(List<HeatmapCell> data) {
    final weeks = <List<HeatmapCell>>[];
    final currentWeek = <HeatmapCell>[];
    
    var currentDate = widget.startDate;
    final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
    
    currentDate = startOfWeek;
    while (currentDate.isBefore(widget.endDate) || currentDate.isAtSameMomentAs(widget.endDate)) {
      final cellData = data.where((cell) => 
        cell.date.year == currentDate.year &&
        cell.date.month == currentDate.month &&
        cell.date.day == currentDate.day).firstOrNull;
      
      if (cellData != null) {
        currentWeek.add(cellData);
      }
      
      if (currentDate.weekday == 7 || currentDate.isAtSameMomentAs(widget.endDate)) {
        if (currentWeek.isNotEmpty) {
          weeks.add(List.from(currentWeek));
        }
        currentWeek.clear();
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return weeks;
  }

  bool _shouldShowMonthLabel(List<HeatmapCell> week, int weekIndex) {
    if (week.isEmpty) return false;
    return weekIndex == 0 || week.first.date.day <= 7;
  }

  String _getMonthLabel(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  Color _getCellColor(HeatmapCell? cellData, ThemeData theme) {
    if (cellData == null || cellData.value == 0) {
      return theme.colorScheme.surfaceContainerHighest;
    }
    
    // Normalize value to 0-1 range based on metric
    final normalizedValue = _normalizeValue(cellData.value, _selectedMetric);
    return _getIntensityColor(normalizedValue, theme);
  }

  Color _getIntensityColor(double intensity, ThemeData theme) {
    final baseColor = theme.colorScheme.primary;
    return Color.lerp(
      theme.colorScheme.surfaceContainerHighest,
      baseColor,
      intensity,
    )!;
  }

  Color _getCellTextColor(HeatmapCell cellData, ThemeData theme) {
    final normalizedValue = _normalizeValue(cellData.value, _selectedMetric);
    return normalizedValue > 0.5 
      ? theme.colorScheme.onPrimary 
      : theme.colorScheme.onSurface;
  }

  String _getCellDisplayValue(HeatmapCell cellData) {
    return cellData.setCount.toString();
  }

  double _normalizeValue(double value, HeatmapMetric metric) {
    switch (metric) {
      case HeatmapMetric.executionTime:
        return math.min(1.0, (value - 15000) / 35000); // 15-50s range
      case HeatmapMetric.formScore:
      case HeatmapMetric.fatigueIndex:
      case HeatmapMetric.consistency:
        return value / 100.0;
      case HeatmapMetric.velocity:
        return math.min(1.0, value / 1.5); // 0-1.5 m/s range
    }
  }

  String _formatMetricValue(double value, HeatmapMetric metric) {
    switch (metric) {
      case HeatmapMetric.executionTime:
        return '${(value / 1000).toStringAsFixed(1)}s';
      case HeatmapMetric.formScore:
      case HeatmapMetric.fatigueIndex:
      case HeatmapMetric.consistency:
        return '${value.toInt()}%';
      case HeatmapMetric.velocity:
        return '${value.toStringAsFixed(2)} m/s';
    }
  }

  String _formatSelectedDate(DateTime date, AppLocalizations l10n) {
    final formatter = MaterialLocalizations.of(context);
    return formatter.formatFullDate(date);
  }

  void _onCellTapped(HeatmapCell cellData) {
    setState(() {
      _selectedDate = _selectedDate == cellData.date ? null : cellData.date;
    });
  }
}

/// Heatmap metrics that can be visualized
enum HeatmapMetric {
  executionTime,
  formScore,
  fatigueIndex,
  velocity,
  consistency,
}

/// Individual cell in the heatmap
class HeatmapCell { // 0-1 range
  
  const HeatmapCell({
    required this.date,
    required this.value,
    required this.setCount,
    required this.qualityScore,
  });
  final DateTime date;
  final double value;
  final int setCount;
  final double qualityScore;
}