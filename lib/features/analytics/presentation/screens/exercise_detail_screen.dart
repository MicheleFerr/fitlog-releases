import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_progress_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/enhanced_empty_state.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
  });

  final String exerciseName;

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

enum ChartViewMode { combined, separated }

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  TimePeriod _selectedPeriod = TimePeriod.month;
  ChartViewMode _viewMode = ChartViewMode.combined;

  // Track which metrics are visible in combined chart
  final Map<String, bool> _visibleMetrics = {
    'weight': true,
    'volume': true,
    'reps': true,
    'rpe': true,
  };

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(exerciseMetricsProvider(widget.exerciseName));

    if (metrics == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.exerciseName),
        ),
        body: EnhancedEmptyState(
          type: EmptyStateType.error,
          icon: AppIcons.error,
          title: 'Exercise not found',
          description: 'No data available for ${widget.exerciseName}',
        ),
      );
    }

    final filteredSets = metrics.getSetsInPeriod(_selectedPeriod);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // View mode toggle
          _buildViewModeToggle(),
          const SizedBox(height: 20),

          // Stats summary
          _buildStatsSummary(metrics, filteredSets),
          const SizedBox(height: 20),

          // Charts based on view mode
          if (_viewMode == ChartViewMode.combined) ...[
            _buildCombinedChartCard(filteredSets),
          ] else ...[
            // Weight progression chart
            _buildChartCard(
              context.l10n.weightProgression,
              AppIcons.workout,
              Colors.blue,
              _buildWeightChart(filteredSets),
            ),
            const SizedBox(height: 16),

            // Volume progression chart
            _buildChartCard(
              context.l10n.volumeProgression,
              AppIcons.analytics,
              Colors.orange,
              _buildVolumeChart(filteredSets),
            ),
            const SizedBox(height: 16),

            // Reps progression chart
            _buildChartCard(
              context.l10n.repsProgression,
              AppIcons.repeat,
              Colors.green,
              _buildRepsChart(filteredSets),
            ),
            const SizedBox(height: 16),

            // RPE progression chart (if available)
            if (filteredSets.any((s) => s.rpe != null)) ...[
              _buildChartCard(
                context.l10n.effortProgression,
                AppIcons.speed,
                Colors.red,
                _buildRPEChart(filteredSets),
              ),
              const SizedBox(height: 16),
            ],
          ],

          // Session history
          _buildSessionHistory(filteredSets),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton(context.l10n.week, TimePeriod.week),
          _buildPeriodButton(context.l10n.month, TimePeriod.month),
          _buildPeriodButton('3M', TimePeriod.threeMonths),
          _buildPeriodButton(context.l10n.year, TimePeriod.year),
          _buildPeriodButton(context.l10n.all, TimePeriod.all),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected ? context.colors.onPrimary : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return SegmentedButton<ChartViewMode>(
      segments: [
        ButtonSegment<ChartViewMode>(
          value: ChartViewMode.combined,
          label: Text(context.l10n.combinedView),
          icon: const Icon(AppIcons.lineChart),
        ),
        ButtonSegment<ChartViewMode>(
          value: ChartViewMode.separated,
          label: Text(context.l10n.separatedView),
          icon: const Icon(AppIcons.stackedLineChart),
        ),
      ],
      selected: {_viewMode},
      onSelectionChanged: (Set<ChartViewMode> newSelection) {
        setState(() {
          _viewMode = newSelection.first;
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return context.colors.primary;
          }
          return context.colors.surfaceContainer;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return context.colors.onPrimary;
          }
          return context.colors.onSurfaceVariant;
        }),
      ),
    );
  }

  Widget _buildCombinedChartCard(List<ExerciseSetData> sets) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.insights, color: context.colors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  context.l10n.combinedChart,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tapToToggle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            _buildCombinedChart(sets),
            const SizedBox(height: 16),
            _buildInteractiveLegend(sets),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No data available')),
      );
    }

    // Normalize all metrics to 0-100 scale for comparison
    final weightData = _normalizeData(sets.map((s) => s.weight).toList());
    final volumeData = _normalizeData(sets.map((s) => s.volume).toList());
    final repsData = _normalizeData(sets.map((s) => s.reps.toDouble()).toList());
    final rpeData = sets.any((s) => s.rpe != null)
        ? _normalizeData(sets.map((s) => (s.rpe ?? 5).toDouble()).toList())
        : null;

    final lineBarsData = <LineChartBarData>[];

    // Weight line (blue)
    if (_visibleMetrics['weight']!) {
      lineBarsData.add(_createLineBarData(
        weightData,
        Colors.blue,
        'Weight',
      ));
    }

    // Volume line (orange)
    if (_visibleMetrics['volume']!) {
      lineBarsData.add(_createLineBarData(
        volumeData,
        Colors.orange,
        'Volume',
      ));
    }

    // Reps line (green)
    if (_visibleMetrics['reps']!) {
      lineBarsData.add(_createLineBarData(
        repsData,
        Colors.green,
        'Reps',
      ));
    }

    // RPE line (purple gradient)
    if (rpeData != null && _visibleMetrics['rpe']!) {
      lineBarsData.add(_createLineBarData(
        rpeData,
        Colors.purple,
        'RPE',
        useGradient: true,
      ));
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: context.textTheme.bodySmall,
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.2),
            ),
          ),
          lineBarsData: lineBarsData,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}%',
                    TextStyle(
                      color: spot.bar.color,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _createLineBarData(
    List<double> data,
    Color color,
    String label, {
    bool useGradient = false,
  }) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      preventCurveOverShooting: true,
      color: useGradient ? null : color,
      gradient: useGradient
          ? const LinearGradient(
              colors: [
                Colors.green,
                Colors.orange,
                Colors.red,
              ],
            )
          : null,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 1.5,
          strokeColor: context.colors.surface,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.1),
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.red.withValues(alpha: 0.1),
                ],
              )
            : null,
      ),
    );
  }

  List<double> _normalizeData(List<double> data) {
    if (data.isEmpty) return [];

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);

    if (max == min) return List.filled(data.length, 50.0);

    return data.map((value) {
      return ((value - min) / (max - min)) * 100;
    }).toList();
  }

  Widget _buildInteractiveLegend(List<ExerciseSetData> sets) {
    final hasRPE = sets.any((s) => s.rpe != null);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildLegendItem('weight', context.l10n.weight, Colors.blue, AppIcons.workout),
        _buildLegendItem('volume', context.l10n.volume, Colors.orange, AppIcons.analytics),
        _buildLegendItem('reps', context.l10n.reps, Colors.green, AppIcons.repeat),
        if (hasRPE) _buildLegendItem('rpe', context.l10n.effort, Colors.purple, AppIcons.speed),
      ],
    );
  }

  Widget _buildLegendItem(String key, String label, Color color, IconData icon) {
    final isVisible = _visibleMetrics[key] ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          _visibleMetrics[key] = !isVisible;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isVisible ? color.withValues(alpha: 0.15) : context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isVisible ? color : context.colors.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isVisible ? color : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: isVisible ? FontWeight.bold : FontWeight.normal,
                color: isVisible ? color : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(ExerciseProgressMetrics metrics, List<ExerciseSetData> sets) {
    final periodMaxWeight = sets.isNotEmpty
        ? sets.fold<double>(0, (max, set) => set.weight > max ? set.weight : max)
        : 0.0;

    final periodAvgWeight = sets.isNotEmpty
        ? sets.fold<double>(0, (sum, set) => sum + set.weight) / sets.length
        : 0.0;

    final periodAvgReps = sets.isNotEmpty
        ? sets.fold<double>(0, (sum, set) => sum + set.reps) / sets.length
        : 0.0;

    final setsWithRPE = sets.where((s) => s.rpe != null).toList();
    final periodAvgRPE = setsWithRPE.isNotEmpty
        ? setsWithRPE.fold<double>(0, (sum, set) => sum + (set.rpe ?? 0)) / setsWithRPE.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withValues(alpha: 0.1),
            context.colors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exerciseStats,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context.l10n.personalRecord,
                '${periodMaxWeight.toStringAsFixed(1)} kg',
                AppIcons.achievement,
                Colors.amber,
              ),
              _buildStatItem(
                context.l10n.averageWeight,
                '${periodAvgWeight.toStringAsFixed(1)} kg',
                AppIcons.workout,
                Colors.blue,
              ),
              _buildStatItem(
                context.l10n.avgReps,
                periodAvgReps.toStringAsFixed(0),
                AppIcons.repeat,
                Colors.green,
              ),
              if (periodAvgRPE > 0)
                _buildStatItem(
                  context.l10n.averageRPE,
                  periodAvgRPE.toStringAsFixed(1),
                  AppIcons.speed,
                  Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, IconData icon, Color color, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sets.length; i++) {
      spots.add(FlSpot(i.toDouble(), sets[i].weight));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sets.length; i++) {
      spots.add(FlSpot(i.toDouble(), sets[i].volume));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orange,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepsChart(List<ExerciseSetData> sets) {
    if (sets.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sets.length; i++) {
      spots.add(FlSpot(i.toDouble(), sets[i].reps.toDouble()));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.green,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRPEChart(List<ExerciseSetData> sets) {
    final setsWithRPE = sets.where((s) => s.rpe != null).toList();

    if (setsWithRPE.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No RPE data available')),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < setsWithRPE.length; i++) {
      spots.add(FlSpot(i.toDouble(), setsWithRPE[i].rpe!.toDouble()));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: context.colors.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: context.textTheme.bodySmall,
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.orange, Colors.red],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final rpe = spot.y;
                  final color = rpe >= 9
                      ? Colors.red
                      : rpe >= 7
                          ? Colors.orange
                          : Colors.green;
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 2,
                    strokeColor: context.colors.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.orange.withValues(alpha: 0.1),
                    Colors.red.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHistory(List<ExerciseSetData> sets) {
    if (sets.isEmpty) return const SizedBox.shrink();

    // Group by date
    final Map<String, List<ExerciseSetData>> sessionsByDate = {};
    for (final set in sets) {
      final dateKey = DateFormat('yyyy-MM-dd').format(set.date);
      sessionsByDate.putIfAbsent(dateKey, () => []).add(set);
    }

    // Sort by date descending
    final sortedDates = sessionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.sessionHistory,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedDates.take(5).map((dateKey) {
              final sessionSets = sessionsByDate[dateKey]!;
              final date = DateTime.parse(dateKey);

              return _buildSessionItem(date, sessionSets);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(DateTime date, List<ExerciseSetData> sets) {
    final maxWeight = sets.fold<double>(0, (max, set) => set.weight > max ? set.weight : max);
    final totalVolume = sets.fold<double>(0, (sum, set) => sum + set.volume);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppIcons.calendar,
                color: context.colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(date),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${sets.length} sets • ${maxWeight.toStringAsFixed(1)} kg max',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(totalVolume / 1000).toStringAsFixed(1)}k kg',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
