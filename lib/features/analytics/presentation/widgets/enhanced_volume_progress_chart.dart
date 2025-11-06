import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/volume_progress_chart_3d.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_efficiency_calculator.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/fatigue_rating_dialog.dart';

/// Enhanced Volume Progress Chart with interactive date selection and detailed views
class EnhancedVolumeProgressChart extends ConsumerStatefulWidget {
  
  const EnhancedVolumeProgressChart({
    super.key,
    required this.workouts,
    this.isPremium = false,
  });
  final List<Workout> workouts;
  final bool isPremium;

  @override
  ConsumerState<EnhancedVolumeProgressChart> createState() => _EnhancedVolumeProgressChartState();
}

class _EnhancedVolumeProgressChartState extends ConsumerState<EnhancedVolumeProgressChart>
    with TickerProviderStateMixin {
  
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  
  VolumeChartType _currentChartType = VolumeChartType.weekly;
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = _getCurrentWeekNumber();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  int? _touchedIndex;
  bool _showDetails = false;
  final Map<String, bool> _expandedWorkouts = {};
  
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
  }
  
  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }
  
  static int _getCurrentWeekNumber() {
    final now = DateTime.now();
    final firstJan = DateTime(now.year, 1, 1);
    final daysOffset = firstJan.weekday - 1;
    final firstMonday = firstJan.subtract(Duration(days: daysOffset));
    return ((now.difference(firstMonday).inDays) / 7).ceil();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Column(
      children: [
        // Chart Type Selector
        _buildChartTypeSelector(theme, localizations),
        const SizedBox(height: 16),
        
        // Date/Week/Month Selector based on chart type
        _buildDateSelector(theme, localizations),
        const SizedBox(height: 20),
        
        // Main Chart
        SizedBox(
          height: 350,
          child: AnimatedBuilder(
            animation: _entranceAnimation,
            builder: (context, child) {
              return _buildChart(theme, localizations);
            },
          ),
        ),
        
        // Details Section
        if (_showDetails) ...[
          const SizedBox(height: 20),
          _buildDetailsSection(theme, localizations),
        ],
        
        // Stats Summary
        const SizedBox(height: 20),
        _buildStatsSummary(theme, localizations),
        
        // Premium Features (if applicable)
        if (!widget.isPremium) ...[
          const SizedBox(height: 20),
          _buildPremiumTeaser(theme, localizations),
        ] else ...[
          const SizedBox(height: 20),
          _buildPremiumFeatures(theme, localizations),
        ],
      ],
    );
  }
  
  Widget _buildChartTypeSelector(ThemeData theme, AppLocalizations localizations) {
    return SegmentedButton<VolumeChartType>(
      segments: [
        ButtonSegment(
          value: VolumeChartType.daily,
          label: Text(localizations.day),
          icon: const Icon(AppIcons.calendarViewDay, size: 18),
        ),
        ButtonSegment(
          value: VolumeChartType.weekly,
          label: Text(localizations.week),
          icon: const Icon(AppIcons.calendarViewWeek, size: 18),
        ),
        ButtonSegment(
          value: VolumeChartType.monthly,
          label: Text(localizations.month),
          icon: const Icon(AppIcons.calendarViewMonth, size: 18),
        ),
      ],
      selected: {_currentChartType},
      onSelectionChanged: (Set<VolumeChartType> newSelection) {
        if (newSelection.isNotEmpty) {
          setState(() {
            _currentChartType = newSelection.first;
            _showDetails = false;
          });
          HapticFeedback.lightImpact();
        }
      },
    );
  }
  
  Widget _buildDateSelector(ThemeData theme, AppLocalizations localizations) {
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return _buildDaySelector(theme, localizations);
      case VolumeChartType.weekly:
        return _buildWeekSelector(theme, localizations);
      case VolumeChartType.monthly:
        return _buildMonthSelector(theme, localizations);
    }
  }
  
  Widget _buildDaySelector(ThemeData theme, AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(AppIcons.chevronLeft),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                });
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('EEEE, d MMMM yyyy', Localizations.localeOf(context).languageCode)
                      .format(_selectedDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(AppIcons.chevronRight),
              onPressed: _selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                  ? () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                      });
                      HapticFeedback.lightImpact();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeekSelector(ThemeData theme, AppLocalizations localizations) {
    final weekStart = _getWeekStart(_selectedWeek, _selectedYear);
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(AppIcons.chevronLeft),
                  onPressed: () {
                    setState(() {
                      _selectedWeek--;
                      if (_selectedWeek < 1) {
                        _selectedYear--;
                        _selectedWeek = _getWeeksInYear(_selectedYear);
                      }
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${localizations.week} $_selectedWeek / $_selectedYear',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('d MMM', Localizations.localeOf(context).languageCode).format(weekStart)} - '
                        '${DateFormat('d MMM', Localizations.localeOf(context).languageCode).format(weekEnd)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(AppIcons.chevronRight),
                  onPressed: _isCurrentWeek() ? null : () {
                    setState(() {
                      _selectedWeek++;
                      if (_selectedWeek > _getWeeksInYear(_selectedYear)) {
                        _selectedYear++;
                        _selectedWeek = 1;
                      }
                    });
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick selection buttons
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedWeek = _getCurrentWeekNumber();
                      _selectedYear = DateTime.now().year;
                    });
                  },
                  child: Text(localizations.thisWeek),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final lastWeek = _getCurrentWeekNumber() - 1;
                      if (lastWeek < 1) {
                        _selectedYear = DateTime.now().year - 1;
                        _selectedWeek = _getWeeksInYear(_selectedYear);
                      } else {
                        _selectedWeek = lastWeek;
                        _selectedYear = DateTime.now().year;
                      }
                    });
                  },
                  child: Text(localizations.lastWeek),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthSelector(ThemeData theme, AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(AppIcons.chevronLeft),
              onPressed: () {
                setState(() {
                  _selectedMonth--;
                  if (_selectedMonth < 1) {
                    _selectedMonth = 12;
                    _selectedYear--;
                  }
                });
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode)
                    .format(DateTime(_selectedYear, _selectedMonth)),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(AppIcons.chevronRight),
              onPressed: _isCurrentMonth() ? null : () {
                setState(() {
                  _selectedMonth++;
                  if (_selectedMonth > 12) {
                    _selectedMonth = 1;
                    _selectedYear++;
                  }
                });
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChart(ThemeData theme, AppLocalizations localizations) {
    final data = _getFilteredData();
    
    if (data.isEmpty) {
      return _buildEmptyState(theme, localizations);
    }
    
    final processedData = _processData(data);
    final maxVolume = processedData.isEmpty ? 0.0 : 
        processedData.map((d) => d.totalVolume).reduce(math.max);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BarChart(
        BarChartData(
          maxY: maxVolume * 1.2,
          barGroups: processedData.asMap().entries.map((entry) {
            final index = entry.key;
            final volumeData = entry.value;
            final isTouched = index == _touchedIndex;
            
            return BarChartGroupData(
              x: index,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: volumeData.totalVolume * _entranceAnimation.value,
                  width: _currentChartType == VolumeChartType.daily ? 32 : 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    colors: isTouched
                        ? [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withValues(alpha: 0.7),
                          ]
                        : [
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
                  if (index >= processedData.length) return const SizedBox();
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getChartLabel(processedData[index], localizations),
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
            horizontalInterval: maxVolume > 0 ? maxVolume / 4 : 1000,
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
                  _showDetails = index >= 0 && index < processedData.length;
                });
                
                if (index >= 0) {
                  HapticFeedback.lightImpact();
                }
              }
            },
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex >= processedData.length) return null;
                
                final volumeData = processedData[groupIndex];
                return BarTooltipItem(
                  _getTooltipText(volumeData, localizations),
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
  
  Widget _buildDetailsSection(ThemeData theme, AppLocalizations localizations) {
    if (_touchedIndex == null || _touchedIndex! < 0) {
      return const SizedBox();
    }
    
    final processedData = _processData(_getFilteredData());
    if (_touchedIndex! >= processedData.length) {
      return const SizedBox();
    }
    
    final selectedData = processedData[_touchedIndex!];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDetailTitle(selectedData, localizations),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close),
                  onPressed: () {
                    setState(() {
                      _showDetails = false;
                      _touchedIndex = null;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            // Show different details based on chart type
            if (_currentChartType == VolumeChartType.daily) ...[
              _buildDailyDetails(selectedData, theme, localizations),
            ] else if (_currentChartType == VolumeChartType.weekly) ...[
              _buildWeeklyDetails(selectedData, theme, localizations),
            ] else ...[
              _buildMonthlyDetails(selectedData, theme, localizations),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyDetails(ProcessedVolumeData data, ThemeData theme, AppLocalizations localizations) {
    final exerciseDetails = _getExerciseDetailsForDate(data.date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${localizations.exercises}: ${exerciseDetails.length}',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ...exerciseDetails.map((exercise) {
          // Get previous performance for comparison
          final exerciseName = exercise['name']?.toString() ?? '';
          final previousPerformance = exerciseName.isNotEmpty 
              ? _getPreviousPerformance(exerciseName, data.date)
              : null;
          final currentVolume = (exercise['volume'] as num?)?.toDouble() ?? 0.0;
          final volumeChange = previousPerformance != null 
              ? ((currentVolume - previousPerformance) / previousPerformance * 100)
              : 0.0;
          
          return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: volumeChange > 5 
                    ? context.colors.success.withValues(alpha: 0.3)
                    : volumeChange < -5 
                        ? context.colors.error.withValues(alpha: 0.3)
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise['name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (previousPerformance != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: volumeChange > 5 
                              ? context.colors.success.withValues(alpha: 0.2)
                              : volumeChange < -5 
                                  ? context.colors.error.withValues(alpha: 0.2)
                                  : context.colors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              volumeChange > 5 
                                  ? AppIcons.trendUp
                                  : volumeChange < -5 
                                      ? AppIcons.trendDown
                                      : AppIcons.remove,
                              size: 14,
                              color: volumeChange > 5 
                                  ? context.colors.success
                                  : volumeChange < -5 
                                      ? context.colors.error
                                      : context.colors.secondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              volumeChange > 5
                                  ? localizations.improvement
                                  : volumeChange < -5
                                      ? localizations.decline
                                      : localizations.stall,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: volumeChange > 5 
                                    ? context.colors.success
                                    : volumeChange < -5 
                                        ? context.colors.error
                                        : context.colors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${exercise['sets']} × ${exercise['avgReps']} @ ${exercise['avgWeight']}kg',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${currentVolume.toStringAsFixed(0)}kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (previousPerformance != null) ...[
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Previous: ${previousPerformance.toStringAsFixed(0)}kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${volumeChange > 0 ? '+' : ''}${volumeChange.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: volumeChange > 0 
                              ? context.colors.success
                              : volumeChange < 0 
                                  ? context.colors.error
                                  : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
        }),
      ],
    );
  }
  
  Widget _buildWeeklyDetails(ProcessedVolumeData data, ThemeData theme, AppLocalizations localizations) {
    final workoutDetails = _getWorkoutDetailsForWeek(data.date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with workout count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${localizations.workouts}: ${workoutDetails.length}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              AppIcons.workout,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  localizations.day,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  localizations.workout,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  localizations.volume,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Table content
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: workoutDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final workout = entry.value;
              final isLast = index == workoutDetails.length - 1;
              
              return _buildWorkoutExpandableRow(
                workout,
                theme,
                localizations,
                isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMonthlyDetails(ProcessedVolumeData data, ThemeData theme, AppLocalizations localizations) {
    final monthStats = _getMonthStats(data.date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow(localizations.totalWorkouts, '${monthStats['workouts']}', theme),
        _buildStatRow(localizations.totalExercises, '${monthStats['exercises']}', theme),
        _buildStatRow(localizations.totalSets, '${monthStats['sets']}', theme),
        _buildStatRow(localizations.avgVolumePerWorkout, 
            '${(monthStats['avgVolume'] as double).toStringAsFixed(0)}kg', theme),
        const SizedBox(height: 12),
        Text(
          localizations.topExercises,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...(monthStats['topExercises'] as List).map((exercise) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exercise['name'] as String,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '${exercise['count']}x',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsSummary(ThemeData theme, AppLocalizations localizations) {
    final data = _getFilteredData();
    if (data.isEmpty) return const SizedBox();
    
    final processedData = _processData(data);
    final totalVolume = processedData.fold(0.0, (sum, d) => sum + d.totalVolume);
    final avgVolume = totalVolume / processedData.length;
    final maxVolume = processedData.map((d) => d.totalVolume).reduce(math.max);
    final trend = _calculateTrend(processedData);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: AppIcons.workout,
            label: localizations.totalVolume,
            value: '${(totalVolume / 1000).toStringAsFixed(1)}k kg',
            theme: theme,
          ),
          _buildStatItem(
            icon: AppIcons.analytics,
            label: localizations.average,
            value: '${avgVolume.toStringAsFixed(0)} kg',
            theme: theme,
          ),
          _buildStatItem(
            icon: AppIcons.rocket,
            label: localizations.record,
            value: '${maxVolume.toStringAsFixed(0)} kg',
            theme: theme,
          ),
          _buildStatItem(
            icon: trend > 0 ? AppIcons.trendUp : AppIcons.trendDown,
            label: localizations.trend,
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
  
  Widget _buildPremiumTeaser(ThemeData theme, AppLocalizations localizations) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.star,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.unlockPremiumFeatures,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              localizations.premiumVolumeFeatures,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPremiumFeatures(ThemeData theme, AppLocalizations localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.autoAwesome,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.advancedInsights,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Performance Predictions
            _buildPremiumInsight(
              icon: AppIcons.ai,
              title: 'Performance Trends',
              value: _getAIPrediction(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Muscle Balance Score
            _buildPremiumInsight(
              icon: AppIcons.balance,
              title: localizations.muscleBalance,
              value: _getMuscleBalanceScore(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Recovery Recommendation
            _buildPremiumInsight(
              icon: AppIcons.bedtime,
              title: localizations.recoveryRecommendation,
              value: _getRecoveryRecommendation(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            // Training Intensity Score
            _buildPremiumInsight(
              icon: AppIcons.speed,
              title: localizations.trainingIntensity,
              value: _getIntensityScore(),
              theme: theme,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // MUSCLE EFFICIENCY SCORE - NASCOSTO TEMPORANEAMENTE
            // Necessita di personalizzazione per essere affidabile
            // TODO: Riattivare quando avremo:
            // 1. Profilo utente dettagliato (età, esperienza, recupero)
            // 2. Machine learning per pattern individuali
            // 3. Integrazione dati sonno/stress/nutrizione
            // 4. Almeno 30 giorni di dati per calibrazione
            /*
            // Muscle Efficiency Score Section
            Row(
              children: [
                Icon(
                  AppIcons.workout,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Muscle Efficiency Score',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track your muscle efficiency',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Efficiency = Volume / Recovery Time',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showFatigueRatingDialog(context),
                    icon: const Icon(AppIcons.ai),
                    label: const Text('Rate Today\'s Fatigue'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Show recent efficiency scores if available
                  _buildRecentEfficiencyScores(theme),
                ],
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
  
  Widget _buildPremiumInsight({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(ThemeData theme, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.barChart,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noDataForSelectedPeriod,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutExpandableRow(
    Map<String, dynamic> workout,
    ThemeData theme,
    AppLocalizations localizations,
    bool isLast,
  ) {
    final workoutKey = '${workout['date']}_${workout['name']}';
    final isExpanded = _expandedWorkouts[workoutKey] ?? false;
        
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedWorkouts[workoutKey] = !isExpanded;
            });
          },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: !isLast ? Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatDayName(workout['date'] as DateTime, localizations),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        workout['name'] as String,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${(workout['volume'] as double).toStringAsFixed(0)}kg',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        if (isExpanded) ...[
          _buildWorkoutExpandedContent(workout, theme, localizations),
        ],
      ],
    );
  }
  
  Widget _buildWorkoutExpandedContent(
    Map<String, dynamic> workout,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final workoutDate = workout['date'] as DateTime;
    final exerciseDetails = _getExerciseDetailsForDate(workoutDate);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.workout,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${localizations.exercises} (${exerciseDetails.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...exerciseDetails.map((exercise) {
            final exerciseName = exercise['name']?.toString() ?? '';
            final previousPerformance = exerciseName.isNotEmpty 
                ? _getPreviousPerformance(exerciseName, workoutDate)
                : null;
            final currentVolume = (exercise['volume'] as num?)?.toDouble() ?? 0.0;
            final volumeChange = previousPerformance != null 
                ? ((currentVolume - previousPerformance) / previousPerformance * 100)
                : 0.0;
                
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showExerciseDetailsDialog(
                  context,
                  exercise['name'] as String,
                  workoutDate,
                  exercise,
                  localizations,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: volumeChange > 5 
                          ? context.colors.success.withValues(alpha: 0.3)
                          : volumeChange < -5 
                              ? context.colors.error.withValues(alpha: 0.3)
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (previousPerformance != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: volumeChange > 5 
                                ? context.colors.success.withValues(alpha: 0.2)
                                : volumeChange < -5 
                                    ? context.colors.error.withValues(alpha: 0.2)
                                    : context.colors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                volumeChange > 5 
                                    ? AppIcons.trendUp
                                    : volumeChange < -5 
                                        ? AppIcons.trendDown
                                        : AppIcons.remove,
                                size: 14,
                                color: volumeChange > 5 
                                    ? context.colors.success
                                    : volumeChange < -5 
                                        ? context.colors.error
                                        : context.colors.secondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                volumeChange > 5
                                    ? localizations.improvement
                                    : volumeChange < -5
                                        ? localizations.decline
                                        : localizations.stall,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: volumeChange > 5 
                                      ? context.colors.success
                                      : volumeChange < -5 
                                          ? context.colors.error
                                          : context.colors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${exercise['sets']} ${localizations.sets} × ${exercise['avgReps']} ${localizations.reps} @ ${exercise['avgWeight']}kg',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${currentVolume.toStringAsFixed(0)}kg',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (previousPerformance != null) ...[
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${localizations.previous}: ${previousPerformance.toStringAsFixed(0)}kg',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${volumeChange > 0 ? '+' : ''}${volumeChange.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: volumeChange > 0 
                                ? context.colors.success
                                : volumeChange < 0 
                                    ? context.colors.error
                                    : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
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
  
  String _formatDayName(DateTime date, AppLocalizations localizations) {
    final day = date.day;
    final weekday = date.weekday;
    
    // Get day names in the current language
    final dayNames = Localizations.localeOf(context).languageCode == 'it'
        ? ['lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica']
        : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    final dayName = dayNames[weekday - 1];
    return '$dayName $day';
  }
  
  // Helper methods
  List<Workout> _getFilteredData() {
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return widget.workouts.where((workout) {
          return _isSameDay(workout.endTime ?? workout.createdAt, _selectedDate);
        }).toList();
        
      case VolumeChartType.weekly:
        final weekStart = _getWeekStart(_selectedWeek, _selectedYear);
        final weekEnd = weekStart.add(const Duration(days: 6));
        return widget.workouts.where((workout) {
          final workoutDate = workout.endTime ?? workout.createdAt;
          return workoutDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                 workoutDate.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
        
      case VolumeChartType.monthly:
        return widget.workouts.where((workout) {
          final workoutDate = workout.endTime ?? workout.createdAt;
          return workoutDate.year == _selectedYear &&
                 workoutDate.month == _selectedMonth;
        }).toList();
    }
  }
  
  List<ProcessedVolumeData> _processData(List<Workout> workouts) {
    final Map<DateTime, ProcessedVolumeData> grouped = {};
    
    for (final workout in workouts) {
      final key = _getGroupKey(workout.endTime ?? workout.createdAt);
      
      if (!grouped.containsKey(key)) {
        grouped[key] = ProcessedVolumeData(
          date: key,
          totalVolume: 0,
          workoutCount: 0,
          muscleGroupVolumes: {},
        );
      }
      
      final volume = workout.exercises.fold(0.0, (sum, e) => sum + e.totalVolume);
      
      grouped[key]!.totalVolume += volume;
      grouped[key]!.workoutCount++;
      
      for (final exercise in workout.exercises) {
        final muscle = _getMuscleGroup(exercise.name);
        grouped[key]!.muscleGroupVolumes[muscle] = 
            (grouped[key]!.muscleGroupVolumes[muscle] ?? 0) + exercise.totalVolume;
      }
    }
    
    final sorted = grouped.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return sorted;
  }
  
  DateTime _getGroupKey(DateTime date) {
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return DateTime(date.year, date.month, date.day, date.hour);
      case VolumeChartType.weekly:
        return DateTime(date.year, date.month, date.day);
      case VolumeChartType.monthly:
        return DateTime(date.year, date.month, date.day);
    }
  }
  
  String _getChartLabel(ProcessedVolumeData data, AppLocalizations localizations) {
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return DateFormat('HH:00').format(data.date);
      case VolumeChartType.weekly:
        return DateFormat('E', Localizations.localeOf(context).languageCode).format(data.date);
      case VolumeChartType.monthly:
        return DateFormat('d').format(data.date);
    }
  }
  
  String _getTooltipText(ProcessedVolumeData data, AppLocalizations localizations) {
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return '${data.totalVolume.toStringAsFixed(0)} kg\n${localizations.tapForDetails}';
      case VolumeChartType.weekly:
        return '${data.totalVolume.toStringAsFixed(0)} kg\n${data.workoutCount} ${localizations.workouts}';
      case VolumeChartType.monthly:
        return '${data.totalVolume.toStringAsFixed(0)} kg\n${data.workoutCount} ${localizations.workouts}';
    }
  }
  
  String _getDetailTitle(ProcessedVolumeData data, AppLocalizations localizations) {
    switch (_currentChartType) {
      case VolumeChartType.daily:
        return DateFormat('HH:00 - HH:59').format(data.date);
      case VolumeChartType.weekly:
        final dayName = _formatDayName(data.date, localizations);
        final monthName = DateFormat('MMMM', Localizations.localeOf(context).languageCode).format(data.date);
        return '$dayName $monthName';
      case VolumeChartType.monthly:
        return DateFormat('d MMMM yyyy', Localizations.localeOf(context).languageCode).format(data.date);
    }
  }
  
  List<Map<String, dynamic>> _getExerciseDetailsForDate(DateTime date) {
    final workoutsForDate = widget.workouts.where((w) => _isSameDay(w.endTime ?? w.createdAt, date)).toList();
    
    final exerciseMap = <String, Map<String, dynamic>>{};
    
    for (final workout in workoutsForDate) {
      for (final exercise in workout.exercises) {
        if (!exerciseMap.containsKey(exercise.name)) {
          exerciseMap[exercise.name] = {
            'name': exercise.name,
            'sets': 0,
            'totalReps': 0,
            'totalWeight': 0.0,
            'volume': 0.0,
          };
        }
        
        final data = exerciseMap[exercise.name]!;
        final completedSets = exercise.sets.where((s) => s.isCompleted).toList();

        data['sets'] = (data['sets'] as int) + completedSets.length;
        
        for (final set in completedSets) {
          data['totalReps'] = (data['totalReps'] as int) + (set.reps ?? 0);
          data['totalWeight'] = (data['totalWeight'] as double) + (set.weight ?? 0.0);
          data['volume'] = (data['volume'] as double) + set.volume;
        }
      }
    }
    
    return exerciseMap.values.map((data) {
      final sets = data['sets'] as int;
      return {
        'name': data['name'],
        'sets': sets,
        'avgReps': sets > 0 ? ((data['totalReps'] as int) / sets).round() : 0,
        'avgWeight': sets > 0 ? ((data['totalWeight'] as double) / sets).toStringAsFixed(1) : '0',
        'volume': data['volume'] as double,
      };
    }).toList();
  }
  
  List<Map<String, dynamic>> _getWorkoutDetailsForWeek(DateTime date) {
    final weekStart = _getWeekStart(_selectedWeek, _selectedYear);
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final workoutsForWeek = widget.workouts.where((workout) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      return workoutDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             workoutDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    final workoutMap = <String, Map<String, dynamic>>{};
    
    for (final workout in workoutsForWeek) {
      final dateKey = DateFormat('yyyy-MM-dd').format(workout.endTime ?? workout.createdAt);
      
      if (!workoutMap.containsKey(dateKey)) {
        workoutMap[dateKey] = {
          'date': workout.endTime ?? workout.createdAt,
          'name': workout.name,
          'volume': 0.0,
        };
      }
      
      final volume = workout.exercises.fold(0.0, (sum, e) => sum + e.totalVolume);
      
      workoutMap[dateKey]!['volume'] = (workoutMap[dateKey]!['volume'] as double) + volume;
    }
    
    final sorted = workoutMap.values.toList()
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    return sorted;
  }
  
  Map<String, dynamic> _getMonthStats(DateTime date) {
    final workoutsForMonth = widget.workouts.where((workout) {
      final workoutDate = workout.endTime ?? workout.createdAt;
      return workoutDate.year == _selectedYear &&
             workoutDate.month == _selectedMonth;
    }).toList();
    
    final workouts = workoutsForMonth.length;
    final exercises = workoutsForMonth.fold(0, (sum, w) => sum + w.exercises.length);
    final sets = workoutsForMonth.fold(0, (sum, w) => sum + w.exercises.fold(0, (exSum, e) => exSum + e.sets.where((s) => s.isCompleted).length));
    final totalVolume = workoutsForMonth.fold(0.0, (sum, w) => sum + w.exercises.fold(0.0, (exSum, e) => exSum + e.totalVolume));
    
    final exerciseCount = <String, int>{};
    for (final workout in workoutsForMonth) {
      for (final exercise in workout.exercises) {
        exerciseCount[exercise.name] = (exerciseCount[exercise.name] ?? 0) + 1;
      }
    }
    
    final topExercises = exerciseCount.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    return {
      'workouts': workouts,
      'exercises': exercises,
      'sets': sets,
      'avgVolume': workouts > 0 ? totalVolume / workouts : 0.0,
      'topExercises': topExercises.take(3).toList(),
    };
  }
  
  String _getMuscleGroup(String exerciseName) {
    final lowerName = exerciseName.toLowerCase();
    if (lowerName.contains('chest') || lowerName.contains('bench') || lowerName.contains('fly')) {
      return 'chest';
    } else if (lowerName.contains('back') || lowerName.contains('row') || lowerName.contains('pull')) {
      return 'back';
    } else if (lowerName.contains('shoulder') || lowerName.contains('delt') || lowerName.contains('press')) {
      return 'shoulders';
    } else if (lowerName.contains('bicep') || lowerName.contains('tricep') || lowerName.contains('curl')) {
      return 'arms';
    } else if (lowerName.contains('squat') || lowerName.contains('leg') || lowerName.contains('calf')) {
      return 'legs';
    } else if (lowerName.contains('ab') || lowerName.contains('core') || lowerName.contains('plank')) {
      return 'core';
    }
    return 'other';
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
  
  DateTime _getWeekStart(int weekNumber, int year) {
    final firstJan = DateTime(year, 1, 1);
    final daysOffset = firstJan.weekday - 1;
    final firstMonday = firstJan.subtract(Duration(days: daysOffset));
    return firstMonday.add(Duration(days: (weekNumber - 1) * 7));
  }
  
  int _getWeeksInYear(int year) {
    final lastDay = DateTime(year, 12, 31);
    final firstMonday = _getWeekStart(1, year);
    return ((lastDay.difference(firstMonday).inDays) / 7).ceil();
  }
  
  bool _isCurrentWeek() {
    return _selectedWeek == _getCurrentWeekNumber() && _selectedYear == DateTime.now().year;
  }
  
  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _selectedMonth == now.month && _selectedYear == now.year;
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  // Premium feature methods
  String _getAIPrediction() {
    final data = _processData(_getFilteredData());
    if (data.isEmpty) return 'No data';
    
    final trend = _calculateTrend(data);
    if (trend > 10) {
      return 'Excellent progress! +${trend.toStringAsFixed(1)}%';
    } else if (trend > 0) {
      return 'Good progress! +${trend.toStringAsFixed(1)}%';
    } else if (trend > -10) {
      return 'Stable performance ${trend.toStringAsFixed(1)}%';
    } else {
      return 'Time to increase intensity ${trend.toStringAsFixed(1)}%';
    }
  }
  
  String _getMuscleBalanceScore() {
    final activities = _getFilteredData();
    if (activities.isEmpty) return 'No data';

    final muscleVolumes = <String, double>{};
    for (final workout in activities) {
      for (final exercise in workout.exercises) {
        final muscle = _getMuscleGroup(exercise.name);
        final volume = exercise.sets.fold(0.0, (sum, set) {
          final weight = set.weight ?? 0.0;
          final reps = set.reps ?? 0;
          return sum + (weight * reps);
        });
        muscleVolumes[muscle] = (muscleVolumes[muscle] ?? 0) + volume;
      }
    }
    
    if (muscleVolumes.isEmpty) return 'No data';
    
    final avgVolume = muscleVolumes.values.reduce((a, b) => a + b) / muscleVolumes.length;
    final maxDeviation = muscleVolumes.values
        .map((v) => (v - avgVolume).abs())
        .reduce(math.max);
    
    final balanceScore = 100 - (maxDeviation / avgVolume * 100).clamp(0, 100);
    
    if (balanceScore > 80) {
      return 'Excellent ${balanceScore.toStringAsFixed(0)}%';
    } else if (balanceScore > 60) {
      return 'Good ${balanceScore.toStringAsFixed(0)}%';
    } else {
      return 'Needs work ${balanceScore.toStringAsFixed(0)}%';
    }
  }
  
  String _getRecoveryRecommendation() {
    final activities = _getFilteredData();
    if (activities.isEmpty) return 'Rest well';

    final recentVolume = activities.fold(0.0, (sum, workout) {
      return sum + workout.exercises.fold(0.0, (exerciseSum, exercise) {
        return exerciseSum + exercise.sets.fold(0.0, (setSum, set) {
          final weight = set.weight ?? 0.0;
          final reps = set.reps ?? 0;
          return setSum + (weight * reps);
        });
      });
    });
    
    if (recentVolume > 10000) {
      return 'Take 48-72h rest';
    } else if (recentVolume > 5000) {
      return 'Take 24-48h rest';
    } else {
      return 'Light activity OK';
    }
  }
  
  String _getIntensityScore() {
    final activities = _getFilteredData();
    if (activities.isEmpty) return 'No data';

    var totalEffort = 0.0;
    var totalExercises = 0;

    for (final workout in activities) {
      for (final exercise in workout.exercises) {
        if (exercise.sets.isNotEmpty) {
          final effortSum = exercise.sets.fold(0.0, (setSum, set) {
            return setSum + (set.rpe?.toDouble() ?? 5.0);
          });
          totalEffort += effortSum / exercise.sets.length;
          totalExercises++;
        }
      }
    }

    final avgEffort = totalExercises > 0 ? totalEffort / totalExercises : 0.0;
    
    if (avgEffort > 8) {
      return 'Very High ${avgEffort.toStringAsFixed(1)}/10';
    } else if (avgEffort > 6) {
      return 'High ${avgEffort.toStringAsFixed(1)}/10';
    } else if (avgEffort > 4) {
      return 'Moderate ${avgEffort.toStringAsFixed(1)}/10';
    } else {
      return 'Low ${avgEffort.toStringAsFixed(1)}/10';
    }
  }
  
  // Get previous performance for a specific exercise
  double? _getPreviousPerformance(String exerciseName, DateTime currentDate) {
    // Find workouts for this exercise before the current date
    final previousWorkouts = widget.workouts
        .where((workout) => 
            (workout.endTime ?? workout.createdAt).isBefore(currentDate) &&
            workout.exercises.any((e) => e.name == exerciseName))
        .toList()
      ..sort((a, b) => (b.endTime ?? b.createdAt).compareTo(a.endTime ?? a.createdAt)); // Most recent first
    
    if (previousWorkouts.isEmpty) return null;
    
    // Get the most recent previous performance
    final mostRecentWorkout = previousWorkouts.first;
    final exercise = mostRecentWorkout.exercises.firstWhere((e) => e.name == exerciseName);
    
    return exercise.totalVolume;
  }
  
  // Show fatigue rating dialog
  void _showFatigueRatingDialog(BuildContext context) {
    final today = DateTime.now();
    final todayActivities = widget.workouts.where((workout) {
      return workout.createdAt.year == today.year &&
             workout.createdAt.month == today.month &&
             workout.createdAt.day == today.day;
    }).toList();
    
    if (todayActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workouts today to rate'),
        ),
      );
      return;
    }
    
    final totalVolume = todayActivities.fold(0.0, (sum, workout) {
      return sum + workout.exercises.fold(0.0, (exerciseSum, exercise) {
        return exerciseSum + exercise.sets.fold(0.0, (setSum, set) {
          final weight = set.weight ?? 0.0;
          final reps = set.reps ?? 0;
          return setSum + (weight * reps);
        });
      });
    });

    final exercisesPerformed = <String>{};
    for (final workout in todayActivities) {
      for (final exercise in workout.exercises) {
        exercisesPerformed.add(exercise.name);
      }
    }
    final exercisesList = exercisesPerformed.toList();
    
    showDialog(
      context: context,
      builder: (context) => FatigueRatingDialog(
        totalVolume: totalVolume,
        exercisesPerformed: exercisesList,
        onRatingSubmitted: (fatigueLevel, notes) {
          // TODO: Save fatigue data to local storage
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fatigue level $fatigueLevel recorded'),
              backgroundColor: context.colors.success,
            ),
          );
        },
      ),
    );
  }
  
  // Build recent efficiency scores widget
  Widget _buildRecentEfficiencyScores(ThemeData theme) {
    // Convert workouts to activities for efficiency calculation
    final activities = <ExerciseActivity>[];
    for (final workout in widget.workouts) {
      for (final exercise in workout.exercises) {
        // Skip conversion for now - this method is unused
        // Would need proper ExerciseActivity.fromExercise implementation
      }
    }

    // Calculate real efficiency score
    final score = MuscleEfficiencyCalculator.calculate(
      recentActivities: activities,
      currentDate: DateTime.now(),
    );

    if (score.score == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No data available yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Score',
                style: theme.textTheme.titleSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: score.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: score.color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  score.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: score.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Score display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score.score / 100,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(score.color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.score}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: score.color,
                      ),
                    ),
                    Icon(
                      score.trend == EfficiencyTrend.improving
                          ? AppIcons.trendUp
                          : score.trend == EfficiencyTrend.declining
                              ? AppIcons.trendDown
                              : AppIcons.remove,
                      size: 20,
                      color: score.trend == EfficiencyTrend.improving
                          ? context.colors.success
                          : score.trend == EfficiencyTrend.declining
                              ? context.colors.error
                              : context.colors.surfaceContainerHighest,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Component breakdown
          Text(
            'Score Breakdown',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...score.components.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatComponentName(entry.key),
                  style: theme.textTheme.bodySmall,
                ),
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: entry.value / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getComponentColor(entry.value),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Text(
                  '${entry.value.round()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
          // Insights
          if (score.insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Insights',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...score.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.tip,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      insight,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  String _formatComponentName(String component) {
    switch (component) {
      case 'volume': return 'Volume Progress';
      case 'recovery': return 'Recovery';
      case 'intensity': return 'Intensity';
      case 'consistency': return 'Consistency';
      case 'overload': return 'Progressive Overload';
      default: return component;
    }
  }

  Color _getComponentColor(double value) {
    if (value >= 80) return context.colors.success;
    if (value >= 60) return context.colors.secondary;
    return context.colors.error;
  }
  
  Widget _buildScoreItem(String day, int? score, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          day,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: score != null 
                ? color.withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: score != null ? color : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              score != null ? '$score' : '?',
              style: theme.textTheme.titleSmall?.copyWith(
                color: score != null ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Get detailed set information for a specific exercise on a specific date
  List<Map<String, dynamic>> _getExerciseSetsForDate(String exerciseName, DateTime date) {
    // Find workouts for the given date
    final relevantWorkouts = widget.workouts.where((w) =>
      _isSameDay(w.createdAt, date)
    ).toList();

    final List<Map<String, dynamic>> allSets = [];

    for (final workout in relevantWorkouts) {
      // Find exercises matching the name
      final exercises = workout.exercises.where((e) => e.name == exerciseName);

      for (final exercise in exercises) {
        for (int i = 0; i < exercise.sets.length; i++) {
          final set = exercise.sets[i];
          final weight = set.weight ?? 0.0;
          final reps = set.reps ?? 0;
          final volume = weight * reps;

          allSets.add({
            'setNumber': i + 1,
            'weight': weight,
            'reps': reps,
            'effort': set.rpe ?? 5,
            'volume': volume,
            'workoutId': workout.id,
            'exerciseId': exercise.id,
          });
        }
      }
    }
    
    return allSets;
  }
  
  void _showExerciseDetailsDialog(
    BuildContext context, 
    String exerciseName, 
    DateTime date,
    Map<String, dynamic> exerciseData,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (context) => ExerciseDetailsDialog(
        exerciseName: exerciseName,
        date: date,
        exerciseData: exerciseData,
        sets: _getExerciseSetsForDate(exerciseName, date),
        localizations: localizations,
      ),
    );
  }
}

// Tier-1 Exercise Details Dialog Widget
class ExerciseDetailsDialog extends ConsumerStatefulWidget {

  const ExerciseDetailsDialog({
    super.key,
    required this.exerciseName,
    required this.date,
    required this.exerciseData,
    required this.sets,
    required this.localizations,
  });
  final String exerciseName;
  final DateTime date;
  final Map<String, dynamic> exerciseData;
  final List<Map<String, dynamic>> sets;
  final AppLocalizations localizations;
  
  @override
  ConsumerState<ExerciseDetailsDialog> createState() => _ExerciseDetailsDialogState();
}

class _ExerciseDetailsDialogState extends ConsumerState<ExerciseDetailsDialog> {
  bool _showComparison = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalVolume = (widget.exerciseData['volume'] as double?) ?? 0.0;
    final avgWeight = double.tryParse(widget.exerciseData['avgWeight']?.toString() ?? '0') ?? 0.0;
    final totalSets = widget.exerciseData['sets'] as int? ?? 0;
    final avgReps = widget.exerciseData['avgReps'] as int? ?? 0;
    
    // Get current user for exercise history
    final currentUserAsync = ref.watch(firebaseUserProvider);
    final userId = currentUserAsync.value?.uid ?? '';

    // TODO: Re-implement exercise stats providers when needed
    // These providers don't exist yet and need to be created
    // final exerciseStatsAsync = ref.watch(exerciseStatsProvider(widget.exerciseName));
    // final exerciseHistoryAsync = ref.watch(exerciseHistoryGroupedProvider(widget.exerciseName));
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: context.colors.onSurface.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Compact
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: context.colors.surface,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.exerciseName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(widget.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.colors.surface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: context.colors.surface,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Summary Stats - Compact List
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    icon: AppIcons.workout,
                    label: widget.localizations.totalVolume,
                    value: '${totalVolume.toStringAsFixed(0)}kg',
                    theme: theme,
                  ),
                  const Divider(height: 1),
                  _buildStatRow(
                    icon: AppIcons.repeat,
                    label: widget.localizations.sets,
                    value: totalSets.toString(),
                    theme: theme,
                  ),
                  const Divider(height: 1),
                  _buildStatRow(
                    icon: AppIcons.trendUp,
                    label: '${widget.localizations.average} ${widget.localizations.weight}',
                    value: '${avgWeight.toStringAsFixed(1)}kg',
                    theme: theme,
                  ),
                ],
              ),
            ),
            
            // Comparison Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showComparison = !_showComparison;
                  });
                },
                icon: Icon(
                  _showComparison ? AppIcons.keyboardArrowUp : Icons.history,
                  size: 20,
                ),
                label: Text(widget.localizations.compareWithHistory),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            // Comparison Section (Expandable with Animation)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showComparison ? 200 : 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.localizations.personalRecords,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // TODO: Re-enable when exerciseStatsAsync provider is implemented
                          Column(
                            children: [
                              Text(
                                'Stats temporarily unavailable',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sets List - Minimal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sets Header - Simplified
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.listAlt,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.localizations.sets} (${widget.sets.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Sets Data - Clean List
                  Expanded(
                    child: ListView.separated(
                      itemCount: widget.sets.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final set = widget.sets[index];
                        return _buildSetRow(set, index + 1, theme, widget.localizations);
                      },
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

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(
    Map<String, dynamic> set, 
    int displayNumber, 
    ThemeData theme, 
    AppLocalizations localizations,
  ) {
    final weight = set['weight'] as double;
    final reps = set['reps'] as int;
    final effort = set['effort'] as int;
    final volume = set['volume'] as double;
    
    // Effort color based on value
    Color effortColor;
    if (effort >= 9) {
      effortColor = context.colors.error;
    } else if (effort >= 7) {
      effortColor = context.colors.secondary;
    } else if (effort >= 5) {
      effortColor = context.colors.success;
    } else {
      effortColor = context.colors.primary;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Set Number - Minimal
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                displayNumber.toString(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Weight × Reps - Single Line
          Expanded(
            child: Text(
              '${weight.toStringAsFixed(1)}kg × $reps',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // RPE - Compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: effortColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$effort',
              style: theme.textTheme.labelSmall?.copyWith(
                color: effortColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Volume - Right aligned
          Text(
            '${volume.toStringAsFixed(0)}kg',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
