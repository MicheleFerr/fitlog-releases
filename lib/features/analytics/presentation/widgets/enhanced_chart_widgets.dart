import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Enhanced Volume Chart with Material 3 styling
class EnhancedVolumeChart extends StatelessWidget {

  const EnhancedVolumeChart({
    super.key,
    required this.activities,
  });
  final List<ExerciseActivity> activities;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final volumeData = _prepareVolumeData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.barChart,
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  localizations.weeklyVolumeChart,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(AppIcons.moreVert, color: colorScheme.outline),
                  onSelected: (value) => _handleChartAction(value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          const Icon(AppIcons.download),
                          const SizedBox(width: 8),
                          Text(localizations.exportData),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          const Icon(AppIcons.infoOutlined),
                          const SizedBox(width: 8),
                          Text(localizations.viewDetails),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 280,
              child: volumeData.isEmpty
                  ? _buildEmptyChart(context, localizations.noVolumeData)
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
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
                                  meta: meta,
                                  child: Text(
                                    _getWeekLabel(value.toInt()),
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
                              reservedSize: 60,
                              interval: _calculateYInterval(volumeData),
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    '${(value / 1000).toStringAsFixed(0)}k',
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
                          LineChartBarData(
                            spots: volumeData,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: colorScheme.surface,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.2),
                                  colorScheme.primary.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => colorScheme.inverseSurface,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                return LineTooltipItem(
                                  '${barSpot.y.toStringAsFixed(0)}kg\n${_getWeekLabel(barSpot.x.toInt())}',
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
                    ),
            ),
            SizedBox(height: 16),
            _buildVolumeInsights(context, volumeData),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeInsights(BuildContext context, List<FlSpot> volumeData) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    if (volumeData.isEmpty) return const SizedBox.shrink();

    final currentVolume = volumeData.last.y;
    final previousVolume = volumeData.length > 1 ? volumeData[volumeData.length - 2].y : 0;
    final volumeChange = currentVolume - previousVolume;
    final isImproving = volumeChange > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isImproving ? AppIcons.trendUp : AppIcons.trendDown,
            color: isImproving ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              isImproving
                  ? localizations.volumeIncreased(volumeChange.toStringAsFixed(0))
                  : localizations.volumeDecreased(volumeChange.abs().toStringAsFixed(0)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _prepareVolumeData() {
    // Group activities by week and calculate total volume
    final weeklyVolume = <int, double>{};
    final now = DateTime.now();

    for (final activity in activities) {
      final weeksDiff = now.difference(activity.createdAt).inDays ~/ 7;
      if (weeksDiff > 12) continue; // Only show last 12 weeks

      final volume = activity.sets.fold<double>(0.0, (sum, set) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        return sum + (weight * reps);
      });

      weeklyVolume[12 - weeksDiff] = (weeklyVolume[12 - weeksDiff] ?? 0) + volume;
    }

    return weeklyVolume.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  String _getWeekLabel(int weekIndex) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: (12 - weekIndex) * 7));
    return '${targetDate.day}/${targetDate.month}';
  }

  double _calculateYInterval(List<FlSpot> data) {
    if (data.isEmpty) return 1000;
    final maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxY / 5).roundToDouble();
  }

  Widget _buildEmptyChart(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.barChart,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _handleChartAction(String action) {
    // Handle chart actions (export, details, etc.)
  }
}

/// Enhanced Frequency Chart showing workout frequency
class EnhancedFrequencyChart extends StatelessWidget {

  const EnhancedFrequencyChart({
    super.key,
    required this.activities,
  });
  final List<ExerciseActivity> activities;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final frequencyData = _prepareFrequencyData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  color: colorScheme.secondary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  localizations.workoutFrequency,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 280,
              child: frequencyData.isEmpty
                  ? _buildEmptyChart(context, localizations.noFrequencyData)
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxFrequency(frequencyData) + 1,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => colorScheme.inverseSurface,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.round()} ${localizations.workouts}\n${_getDayName(group.x.toInt(), localizations)}',
                                TextStyle(
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
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
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    _getDayAbbreviation(value.toInt(), localizations),
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
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    value.toInt().toString(),
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
                          show: false,
                        ),
                        gridData: const FlGridData(show: false),
                        barGroups: frequencyData.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.secondary,
                                    colorScheme.secondary.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 24,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
            SizedBox(height: 16),
            _buildFrequencyInsights(context, frequencyData),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyInsights(BuildContext context, List<int> frequencyData) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    final bestDay = frequencyData.indexOf(frequencyData.reduce((a, b) => a > b ? a : b));
    final totalWorkouts = frequencyData.fold(0, (a, b) => a + b);
    final averagePerDay = totalWorkouts / 7;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                AppIcons.achievement,
                color: colorScheme.secondary,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                localizations.bestWorkoutDay(_getDayName(bestDay, localizations)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                AppIcons.analytics,
                color: colorScheme.outline,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                localizations.averageWorkoutsPerDay(averagePerDay.toStringAsFixed(1)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<int> _prepareFrequencyData() {
    // Initialize frequency data for each day of the week (0 = Monday, 6 = Sunday)
    final frequency = List<int>.filled(7, 0);

    for (final activity in activities) {
      final dayOfWeek = (activity.createdAt.weekday - 1) % 7; // Convert to 0-6 range
      frequency[dayOfWeek]++;
    }

    return frequency;
  }

  double _getMaxFrequency(List<int> data) {
    return data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b).toDouble();
  }

  Widget _buildEmptyChart(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.calendar,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayIndex, AppLocalizations localizations) {
    switch (dayIndex) {
      case 0: return localizations.monday;
      case 1: return localizations.tuesday;
      case 2: return localizations.wednesday;
      case 3: return localizations.thursday;
      case 4: return localizations.friday;
      case 5: return localizations.saturday;
      case 6: return localizations.sunday;
      default: return '';
    }
  }

  String _getDayAbbreviation(int dayIndex, AppLocalizations localizations) {
    switch (dayIndex) {
      case 0: return localizations.mondayShort;
      case 1: return localizations.tuesdayShort;
      case 2: return localizations.wednesdayShort;
      case 3: return localizations.thursdayShort;
      case 4: return localizations.fridayShort;
      case 5: return localizations.saturdayShort;
      case 6: return localizations.sundayShort;
      default: return '';
    }
  }
}

/// Body Part Distribution Chart
class EnhancedBodyPartChart extends StatelessWidget {

  const EnhancedBodyPartChart({
    super.key,
    required this.activities,
  });
  final List<ExerciseActivity> activities;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final bodyPartData = _prepareBodyPartData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.donutLarge,
                  color: colorScheme.tertiary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  localizations.bodyPartDistribution,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: bodyPartData.isEmpty
                  ? _buildEmptyChart(context, localizations.noBodyPartData)
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              sections: bodyPartData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final section = entry.value;
                                return PieChartSectionData(
                                  color: _getBodyPartColor(section.category, colorScheme),
                                  value: section.percentage,
                                  title: '${section.percentage.toStringAsFixed(0)}%',
                                  radius: 50,
                                  titleStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                );
                              }).toList(),
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  // Handle touch interactions
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: bodyPartData.map((section) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _getBodyPartColor(section.category, colorScheme),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        section.category,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<BodyPartSection> _prepareBodyPartData() {
    final bodyPartCounts = <String, int>{};
    
    for (final activity in activities) {
      final category = _categorizeExercise(activity.exerciseName);
      bodyPartCounts[category] = (bodyPartCounts[category] ?? 0) + 1;
    }

    final total = bodyPartCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];

    return bodyPartCounts.entries
        .map((entry) => BodyPartSection(
              category: entry.key,
              count: entry.value,
              percentage: (entry.value / total) * 100,
            ))
        .where((section) => section.percentage > 2) // Only show categories > 2%
        .toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
  }

  String _categorizeExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();
    
    if (name.contains('chest') || name.contains('bench') || name.contains('pec')) {
      return 'Chest';
    } else if (name.contains('back') || name.contains('pull') || name.contains('row')) {
      return 'Back';
    } else if (name.contains('shoulder') || name.contains('press') || name.contains('deltoid')) {
      return 'Shoulders';
    } else if (name.contains('leg') || name.contains('squat') || name.contains('quad')) {
      return 'Legs';
    } else if (name.contains('arm') || name.contains('bicep') || name.contains('tricep')) {
      return 'Arms';
    } else {
      return 'Other';
    }
  }

  Color _getBodyPartColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'Chest':
        return colorScheme.primary;
      case 'Back':
        return colorScheme.secondary;
      case 'Shoulders':
        return colorScheme.tertiary;
      case 'Legs':
        return colorScheme.success;
      case 'Arms':
        return colorScheme.secondary;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Widget _buildEmptyChart(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.donutLarge,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Data classes
class BodyPartSection {

  BodyPartSection({
    required this.category,
    required this.count,
    required this.percentage,
  });
  final String category;
  final int count;
  final double percentage;
}
