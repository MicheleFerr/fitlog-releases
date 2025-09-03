import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Chart showing strength progression over time
class StrengthProgressionChart extends StatefulWidget {
  final List<ExerciseActivity> activities;
  final String? selectedExerciseId;
  final Function(String?)? onExerciseSelected;

  const StrengthProgressionChart({
    super.key,
    required this.activities,
    this.selectedExerciseId,
    this.onExerciseSelected,
  });

  @override
  State<StrengthProgressionChart> createState() => _StrengthProgressionChartState();
}

class _StrengthProgressionChartState extends State<StrengthProgressionChart> {
  String? _selectedExerciseId;
  bool _showEstimated1RM = true;
  bool _showActualWeight = true;
  bool _showTrendLine = true;

  @override
  void initState() {
    super.initState();
    _selectedExerciseId = widget.selectedExerciseId ?? _getTopExercises().firstOrNull;
  }

  List<String> _getTopExercises() {
    final exerciseCounts = <String, int>{};
    for (final activity in widget.activities) {
      exerciseCounts[activity.exerciseId] = (exerciseCounts[activity.exerciseId] ?? 0) + 1;
    }
    
    final sorted = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    
    final exerciseData = _prepareChartData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, localizations, colorScheme),
            const SizedBox(height: 8),
            _buildExerciseSelector(context, localizations),
            const SizedBox(height: 8),
            _buildToggleButtons(context, localizations),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: exerciseData.isEmpty
                  ? _buildEmptyState(context, localizations)
                  : _buildChart(context, exerciseData, colorScheme),
            ),
            const SizedBox(height: 16),
            _buildLegend(context, colorScheme),
            const SizedBox(height: 16),
            _buildStats(context, localizations, exerciseData),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.trending_up,
          color: colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          localizations.strengthProgression,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(context),
        ),
      ],
    );
  }

  Widget _buildExerciseSelector(BuildContext context, AppLocalizations localizations) {
    final exercises = _getExerciseOptions();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedExerciseId,
          isExpanded: true,
          hint: Text(localizations.selectExercise),
          items: exercises.map((exercise) {
            return DropdownMenuItem(
              value: exercise.id,
              child: Text(exercise.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedExerciseId = value;
            });
            widget.onExerciseSelected?.call(value);
          },
        ),
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context, AppLocalizations localizations) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: Text(localizations.estimated1RM),
          selected: _showEstimated1RM,
          onSelected: (value) {
            setState(() {
              _showEstimated1RM = value;
            });
          },
        ),
        FilterChip(
          label: Text(localizations.actualWeight),
          selected: _showActualWeight,
          onSelected: (value) {
            setState(() {
              _showActualWeight = value;
            });
          },
        ),
        FilterChip(
          label: Text(localizations.trendLine),
          selected: _showTrendLine,
          onSelected: (value) {
            setState(() {
              _showTrendLine = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, List<FlSpot> data, ColorScheme colorScheme) {
    final actualData = _showActualWeight ? _prepareActualWeightData() : [];
    final trendData = _showTrendLine ? _calculateTrendLine(data) : [];
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _getDateLabel(value.toInt()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: _calculateYInterval(data),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toStringAsFixed(0)}kg',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            left: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        lineBarsData: [
          if (_showEstimated1RM && data.isNotEmpty)
            LineChartBarData(
              spots: data,
              isCurved: true,
              curveSmoothness: 0.3,
              color: colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          if (_showActualWeight && actualData.isNotEmpty)
            LineChartBarData(
              spots: actualData.cast<FlSpot>(),
              isCurved: false,
              color: colorScheme.secondary,
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [5, 5],
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: colorScheme.secondary,
                    strokeWidth: 2,
                    strokeColor: colorScheme.surface,
                  );
                },
              ),
            ),
          if (_showTrendLine && trendData.isNotEmpty)
            LineChartBarData(
              spots: trendData,
              isCurved: false,
              color: colorScheme.tertiary,
              barWidth: 2,
              dashArray: [10, 5],
              dotData: const FlDotData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => colorScheme.inverseSurface,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                String label = '';
                if (barSpot.barIndex == 0) {
                  label = '1RM: ';
                } else if (barSpot.barIndex == 1) {
                  label = 'Weight: ';
                } else {
                  label = 'Trend: ';
                }
                
                return LineTooltipItem(
                  '$label${barSpot.y.toStringAsFixed(1)}kg\n${_getDateLabel(barSpot.x.toInt())}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_showEstimated1RM) ...[
          Container(
            width: 20,
            height: 3,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '1RM',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
        ],
        if (_showActualWeight) ...[
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.secondary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Actual',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
        ],
        if (_showTrendLine) ...[
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.tertiary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Trend',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildStats(BuildContext context, AppLocalizations localizations, List<FlSpot> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final improvement = data.last.y - data.first.y;
    final improvementPercent = (improvement / data.first.y) * 100;
    final currentMax = data.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            localizations.current1RM,
            '${data.last.y.toStringAsFixed(1)}kg',
            Icons.fitness_center,
          ),
          _buildStatItem(
            context,
            localizations.bestEver,
            '${currentMax.toStringAsFixed(1)}kg',
            Icons.emoji_events,
          ),
          _buildStatItem(
            context,
            localizations.improvement,
            '${improvementPercent > 0 ? '+' : ''}${improvementPercent.toStringAsFixed(1)}%',
            improvementPercent > 0 ? Icons.trending_up : Icons.trending_down,
            color: improvementPercent > 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Column(
      children: [
        Icon(icon, size: 20, color: effectiveColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noDataForExercise,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _prepareChartData() {
    if (_selectedExerciseId == null) return [];
    
    final exerciseActivities = widget.activities
        .where((a) => a.exerciseId == _selectedExerciseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final data = <FlSpot>[];
    
    for (var i = 0; i < exerciseActivities.length; i++) {
      final activity = exerciseActivities[i];
      double maxEstimated1RM = 0;
      
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        final reps = int.tryParse(set.reps) ?? 0;
        
        if (weight > 0 && reps > 0) {
          final estimated1RM = OneRMCalculator.calculateAverage(weight, reps);
          if (estimated1RM > maxEstimated1RM) {
            maxEstimated1RM = estimated1RM;
          }
        }
      }
      
      if (maxEstimated1RM > 0) {
        data.add(FlSpot(i.toDouble(), maxEstimated1RM));
      }
    }
    
    return data;
  }

  List<FlSpot> _prepareActualWeightData() {
    if (_selectedExerciseId == null) return [];
    
    final exerciseActivities = widget.activities
        .where((a) => a.exerciseId == _selectedExerciseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final data = <FlSpot>[];
    
    for (var i = 0; i < exerciseActivities.length; i++) {
      final activity = exerciseActivities[i];
      double maxWeight = 0;
      
      for (final set in activity.sets.where((s) => s.done && !s.isWarmup)) {
        final weight = double.tryParse(set.weight) ?? 0;
        if (weight > maxWeight) {
          maxWeight = weight;
        }
      }
      
      if (maxWeight > 0) {
        data.add(FlSpot(i.toDouble(), maxWeight));
      }
    }
    
    return data;
  }

  List<FlSpot> _calculateTrendLine(List<FlSpot> data) {
    if (data.length < 2) return [];
    
    // Simple linear regression
    final n = data.length;
    final sumX = data.fold(0.0, (sum, spot) => sum + spot.x);
    final sumY = data.fold(0.0, (sum, spot) => sum + spot.y);
    final sumXY = data.fold(0.0, (sum, spot) => sum + (spot.x * spot.y));
    final sumX2 = data.fold(0.0, (sum, spot) => sum + (spot.x * spot.x));
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    return [
      FlSpot(0, intercept),
      FlSpot(data.last.x, slope * data.last.x + intercept),
    ];
  }

  double _calculateYInterval(List<FlSpot> data) {
    if (data.isEmpty) return 10;
    final maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxY / 5).roundToDouble();
  }

  String _getDateLabel(int index) {
    if (_selectedExerciseId == null) return '';
    
    final exerciseActivities = widget.activities
        .where((a) => a.exerciseId == _selectedExerciseId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    if (index >= 0 && index < exerciseActivities.length) {
      final date = exerciseActivities[index].createdAt;
      return '${date.day}/${date.month}';
    }
    
    return '';
  }

  List<({String id, String name})> _getExerciseOptions() {
    final exerciseMap = <String, String>{};
    
    for (final activity in widget.activities) {
      exerciseMap[activity.exerciseId] = activity.exerciseName;
    }
    
    final topExercises = _getTopExercises();
    final options = <({String id, String name})>[];
    
    for (final id in topExercises) {
      if (exerciseMap.containsKey(id)) {
        options.add((id: id, name: exerciseMap[id]!));
      }
    }
    
    return options;
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.aboutStrengthProgression),
        content: Text(AppLocalizations.of(context)!.strengthProgressionInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}