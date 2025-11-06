import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Grafico avanzato per tracciare la progressione del 1RM (One Rep Max)
/// con predictive trend lines e analisi del plateau
class OneRMProgressionChart extends StatefulWidget {
  
  const OneRMProgressionChart({
    super.key,
    required this.exerciseData,
    this.onDataPointTap,
    this.showPrediction = true,
    this.predictionDays = 30,
  });
  final Map<String, List<OneRMData>> exerciseData; // Exercise name -> data points
  final Function(String exercise, OneRMData data)? onDataPointTap;
  final bool showPrediction;
  final int predictionDays;

  @override
  State<OneRMProgressionChart> createState() => _OneRMProgressionChartState();
}

class _OneRMProgressionChartState extends State<OneRMProgressionChart>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _drawAnimation;
  late Animation<double> _pulseAnimation;
  
  String? _selectedExercise;
  OneRMData? _selectedDataPoint;
  bool _showAllExercises = false;
  ChartTimeRange _timeRange = ChartTimeRange.threeMonths;
  
  // Analysis results
  PlateauAnalysis? _plateauAnalysis;
  TrendPrediction? _trendPrediction;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _drawAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Select first exercise by default
    if (widget.exerciseData.isNotEmpty) {
      _selectedExercise = widget.exerciseData.keys.first;
      _analyzeData();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _analyzeData() {
    if (_selectedExercise == null) return;
    
    final data = widget.exerciseData[_selectedExercise!];
    if (data == null || data.isEmpty) return;
    
    setState(() {
      _plateauAnalysis = _detectPlateau(data);
      _trendPrediction = _predictTrend(data);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exercise selector
        _buildExerciseSelector(theme),
        const SizedBox(height: 16),
        
        // Time range selector
        _buildTimeRangeSelector(theme),
        const SizedBox(height: 20),
        
        // Main chart
        SizedBox(
          height: 300,
          child: AnimatedBuilder(
            animation: _drawAnimation,
            builder: (context, child) {
              return _buildChart(theme);
            },
          ),
        ),
        
        // Analysis cards
        if (_plateauAnalysis != null || _trendPrediction != null) ...[
          const SizedBox(height: 20),
          _buildAnalysisCards(theme),
        ],
        
        // Selected point details
        if (_selectedDataPoint != null) ...[
          const SizedBox(height: 16),
          _buildDataPointDetails(theme),
        ],
        
        // Legend
        const SizedBox(height: 16),
        _buildLegend(theme),
      ],
    );
  }
  
  Widget _buildExerciseSelector(ThemeData theme) {
    final exercises = widget.exerciseData.keys.toList();
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exercises.length + 1,
        itemBuilder: (context, index) {
          if (index == exercises.length) {
            // "Show all" chip
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Mostra tutti'),
                selected: _showAllExercises,
                onSelected: (selected) {
                  setState(() {
                    _showAllExercises = selected;
                    if (!selected && exercises.isNotEmpty) {
                      _selectedExercise = exercises.first;
                    }
                    _analyzeData();
                  });
                  HapticFeedback.lightImpact();
                },
                avatar: const Icon(AppIcons.visibility, size: 18),
              ),
            );
          }
          
          final exercise = exercises[index];
          final isSelected = exercise == _selectedExercise && !_showAllExercises;
          final data = widget.exerciseData[exercise]!;
          final latestRM = data.isNotEmpty ? data.last.weight : 0;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exercise,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${latestRM.toStringAsFixed(0)}kg',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedExercise = exercise;
                    _showAllExercises = false;
                    _analyzeData();
                  });
                  HapticFeedback.lightImpact();
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTimeRangeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periodo di visualizzazione',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...ChartTimeRange.values.map((range) {
            final isSelected = _timeRange == range;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _timeRange = range;
                  });
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getTimeRangeIcon(range),
                        size: 20,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTimeRangeLabelFull(range),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              _getTimeRangeDescription(range),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          AppIcons.complete,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildChart(ThemeData theme) {
    if (widget.exerciseData.isEmpty) {
      return _buildEmptyState(theme);
    }
    
    final lineBarsData = <LineChartBarData>[];
    final exercisesToShow = _showAllExercises 
        ? widget.exerciseData.keys.toList()
        : (_selectedExercise != null ? [_selectedExercise!] : []);
    
    if (exercisesToShow.isEmpty) {
      return _buildEmptyState(theme);
    }
    
    // Calculate bounds
    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;
    
    for (final exercise in exercisesToShow) {
      final data = _getFilteredData(widget.exerciseData[exercise]!);
      if (data.isEmpty) continue;
      
      for (final point in data) {
        final x = point.date.millisecondsSinceEpoch.toDouble();
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, point.weight);
        maxY = math.max(maxY, point.weight);
      }
    }
    
    // Add prediction range
    if (widget.showPrediction) {
      maxX = DateTime.now()
          .add(Duration(days: widget.predictionDays))
          .millisecondsSinceEpoch
          .toDouble();
    }
    
    // Build line bars
    int colorIndex = 0;
    final colors = [
      theme.colorScheme.primary,
      context.colors.secondary,
      context.colors.success,
      context.colors.tertiary,
      context.colors.primary,
      context.colors.error,
    ];
    
    for (final exercise in exercisesToShow) {
      final data = _getFilteredData(widget.exerciseData[exercise]!);
      if (data.isEmpty) continue;
      
      final color = colors[colorIndex % colors.length];
      final spots = data.map((point) {
        return FlSpot(
          point.date.millisecondsSinceEpoch.toDouble(),
          point.weight,
        );
      }).toList();
      
      // Actual data line
      lineBarsData.add(
        LineChartBarData(
          spots: spots.map((spot) => FlSpot(
            spot.x,
            spot.y * _drawAnimation.value,
          )).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isSelected = _selectedDataPoint != null &&
                  data[index].date == _selectedDataPoint!.date;
              
              return FlDotCirclePainter(
                radius: isSelected ? 6 : 4,
                color: color,
                strokeWidth: 2,
                strokeColor: theme.colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: !_showAllExercises,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
      
      // Prediction line
      if (widget.showPrediction && !_showAllExercises && _trendPrediction != null) {
        final predictionSpots = _generatePredictionLine(
          spots.last,
          _trendPrediction!,
        );
        
        lineBarsData.add(
          LineChartBarData(
            spots: predictionSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: color.withValues(alpha: 0.5),
            barWidth: 2,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        );
      }
      
      colorIndex++;
    }
    
    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY * 0.9,
        maxY: maxY * 1.1,
        lineBarsData: lineBarsData,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
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
              reservedSize: 30,
              interval: (maxX - minX) / 5,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('d/M').format(date),
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
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.lineBarSpots != null) {
              final spot = response!.lineBarSpots!.first;
              final exercise = exercisesToShow[spot.barIndex];
              final data = _getFilteredData(widget.exerciseData[exercise]!);
              
              if (spot.spotIndex < data.length) {
                setState(() {
                  _selectedDataPoint = data[spot.spotIndex];
                });
                HapticFeedback.lightImpact();
                widget.onDataPointTap?.call(exercise, data[spot.spotIndex]);
              }
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildAnalysisCards(ThemeData theme) {
    return Row(
      children: [
        if (_plateauAnalysis != null)
          Expanded(
            child: _buildPlateauCard(theme),
          ),
        if (_plateauAnalysis != null && _trendPrediction != null)
          const SizedBox(width: 12),
        if (_trendPrediction != null)
          Expanded(
            child: _buildPredictionCard(theme),
          ),
      ],
    );
  }
  
  Widget _buildPlateauCard(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _plateauAnalysis!.isInPlateau ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _plateauAnalysis!.isInPlateau
                  ? context.colors.secondary.withValues(alpha: 0.1)
                  : context.colors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _plateauAnalysis!.isInPlateau
                    ? context.colors.secondary.withValues(alpha: 0.3)
                    : context.colors.success.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _plateauAnalysis!.isInPlateau
                          ? AppIcons.warningAmber
                          : Icons.trending_up,
                      color: _plateauAnalysis!.isInPlateau
                          ? context.colors.secondary
                          : context.colors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _plateauAnalysis!.isInPlateau
                          ? 'Plateau Detected'
                          : 'Progressing Well',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _plateauAnalysis!.message,
                  style: theme.textTheme.bodySmall,
                ),
                if (_plateauAnalysis!.suggestion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💡 ${_plateauAnalysis!.suggestion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPredictionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                AppIcons.autoGraph,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Proiezione 30 giorni',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Obiettivo previsto: '),
                TextSpan(
                  text: '${_trendPrediction!.predictedValue.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Confidenza: ${(_trendPrediction!.confidence * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataPointDetails(ThemeData theme) {
    if (_selectedDataPoint == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: AppIcons.calendar,
            label: 'Data',
            value: DateFormat('d MMM yyyy').format(_selectedDataPoint!.date),
            theme: theme,
          ),
          _buildDetailItem(
            icon: AppIcons.workout,
            label: '1RM',
            value: '${_selectedDataPoint!.weight.toStringAsFixed(1)} kg',
            theme: theme,
          ),
          if (_selectedDataPoint!.actualReps != null)
            _buildDetailItem(
              icon: AppIcons.repeat,
              label: 'Reps',
              value: '${_selectedDataPoint!.actualReps}',
              theme: theme,
            ),
          if (_selectedDataPoint!.rpe != null)
            _buildDetailItem(
              icon: AppIcons.speed,
              label: 'RPE',
              value: '${_selectedDataPoint!.rpe}/10',
              theme: theme,
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
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
          label: '1RM Effettivo',
          theme: theme,
        ),
        if (widget.showPrediction)
          _buildLegendItem(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            label: 'Proiezione',
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
            border: isDashed
                ? Border(
                    top: BorderSide(
                      color: color,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                : null,
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
            AppIcons.analytics,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun dato 1RM disponibile',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  List<OneRMData> _getFilteredData(List<OneRMData> data) {
    final now = DateTime.now();
    final cutoff = switch (_timeRange) {
      ChartTimeRange.month => now.subtract(const Duration(days: 30)),
      ChartTimeRange.threeMonths => now.subtract(const Duration(days: 90)),
      ChartTimeRange.sixMonths => now.subtract(const Duration(days: 180)),
      ChartTimeRange.year => now.subtract(const Duration(days: 365)),
      ChartTimeRange.all => DateTime(2000),
    };
    
    return data.where((d) => d.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
  
  PlateauAnalysis _detectPlateau(List<OneRMData> data) {
    if (data.length < 3) {
      return const PlateauAnalysis(
        isInPlateau: false,
        message: 'Dati insufficienti per analisi',
      );
    }
    
    // Check last 3-5 data points for plateau
    final recentData = data.length > 5 
        ? data.sublist(data.length - 5)
        : data;
    
    final weights = recentData.map((d) => d.weight).toList();
    final avg = weights.reduce((a, b) => a + b) / weights.length;
    final variance = weights.map((w) => (w - avg).abs()).reduce((a, b) => a + b) / weights.length;
    
    // If variance is less than 2% of average, it's a plateau
    final isInPlateau = variance < (avg * 0.02);
    
    return PlateauAnalysis(
      isInPlateau: isInPlateau,
      message: isInPlateau
          ? 'Nessun progresso significativo nelle ultime ${recentData.length} sessioni'
          : 'Progressione costante rilevata',
      suggestion: isInPlateau
          ? 'Prova a variare rep range o aumentare il volume'
          : null,
    );
  }
  
  TrendPrediction _predictTrend(List<OneRMData> data) {
    if (data.length < 2) {
      return TrendPrediction(
        predictedValue: data.last.weight,
        confidence: 0.0,
      );
    }
    
    // Simple linear regression for prediction
    final n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = data[i].weight;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // Predict 30 days ahead
    final daysAhead = 30.0 / (data.last.date.difference(data.first.date).inDays / n);
    final predictedValue = intercept + slope * (n + daysAhead);
    
    // Calculate confidence based on R-squared
    double ssRes = 0, ssTot = 0;
    final yMean = sumY / n;
    
    for (int i = 0; i < n; i++) {
      final yPred = intercept + slope * i;
      ssRes += math.pow(data[i].weight - yPred, 2);
      ssTot += math.pow(data[i].weight - yMean, 2);
    }
    
    final rSquared = ssTot > 0 ? 1 - (ssRes / ssTot) : 0;
    
    return TrendPrediction(
      predictedValue: predictedValue.clamp(data.last.weight * 0.9, data.last.weight * 1.2),
      confidence: rSquared.clamp(0.0, 1.0).toDouble(),
    );
  }
  
  List<FlSpot> _generatePredictionLine(FlSpot lastPoint, TrendPrediction prediction) {
    final endDate = DateTime.now().add(Duration(days: widget.predictionDays));
    final endX = endDate.millisecondsSinceEpoch.toDouble();
    
    return [
      lastPoint,
      FlSpot(endX, prediction.predictedValue),
    ];
  }
  
  String _getTimeRangeLabel(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.month:
        return '1M';
      case ChartTimeRange.threeMonths:
        return '3M';
      case ChartTimeRange.sixMonths:
        return '6M';
      case ChartTimeRange.year:
        return '1A';
      case ChartTimeRange.all:
        return 'Tutto';
    }
  }
  
  String _getTimeRangeLabelFull(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.month:
        return 'Ultimo mese';
      case ChartTimeRange.threeMonths:
        return 'Ultimi 3 mesi';
      case ChartTimeRange.sixMonths:
        return 'Ultimi 6 mesi';
      case ChartTimeRange.year:
        return 'Ultimo anno';
      case ChartTimeRange.all:
        return 'Tutto lo storico';
    }
  }
  
  String _getTimeRangeDescription(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.month:
        return 'Ultimi 30 giorni di progressione';
      case ChartTimeRange.threeMonths:
        return 'Trimestre di allenamento';
      case ChartTimeRange.sixMonths:
        return 'Semestre completo';
      case ChartTimeRange.year:
        return 'Progressione annuale';
      case ChartTimeRange.all:
        return 'Tutti i dati disponibili';
    }
  }
  
  IconData _getTimeRangeIcon(ChartTimeRange range) {
    switch (range) {
      case ChartTimeRange.month:
        return AppIcons.calendar;
      case ChartTimeRange.threeMonths:
        return AppIcons.dateRange;
      case ChartTimeRange.sixMonths:
        return AppIcons.calendarViewMonth;
      case ChartTimeRange.year:
        return AppIcons.calendarMonth;
      case ChartTimeRange.all:
        return AppIcons.allInclusive;
    }
  }
}

enum ChartTimeRange {
  month,
  threeMonths,
  sixMonths,
  year,
  all,
}

class OneRMData {
  
  const OneRMData({
    required this.date,
    required this.weight,
    this.actualReps,
    this.rpe,
    this.notes,
  });
  final DateTime date;
  final double weight;
  final int? actualReps;
  final double? rpe; // Rate of Perceived Exertion (1-10)
  final String? notes;
}

class PlateauAnalysis {
  
  const PlateauAnalysis({
    required this.isInPlateau,
    required this.message,
    this.suggestion,
  });
  final bool isInPlateau;
  final String message;
  final String? suggestion;
}

class TrendPrediction {
  
  const TrendPrediction({
    required this.predictedValue,
    required this.confidence,
  });
  final double predictedValue;
  final double confidence;
}
