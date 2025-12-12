/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// VOLUME PROGRESSION TAB
/// Shows weekly volume trends and progression over time.
///
/// Features:
/// - Radar chart with volume zones (MV/MEV/MAV/MRV)
/// - 4-week trend chart per muscle group
/// - Tab navigation between Radar and Trend views
/// - Interactive tooltips
/// - Landscape support for expanded view
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Volume Progression Tab
///
/// Shows how training volume has changed over time,
/// helping users track progressive overload.
class VolumeProgressionTab extends StatefulWidget {
  const VolumeProgressionTab({
    super.key,
    required this.exerciseHistories,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  State<VolumeProgressionTab> createState() => _VolumeProgressionTabState();
}

/// View mode for the volume charts
enum _VolumeViewMode { radar, trend }

class _VolumeProgressionTabState extends State<VolumeProgressionTab> {
  _VolumeViewMode _viewMode = _VolumeViewMode.radar;
  int _touchedRadarIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    // Calculate volume data
    final volumeData = _calculateVolumeData();

    if (volumeData.totalVolume == 0) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            l10n.volumeProgression,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.volumeProgressionDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Weekly change indicator
          _buildWeeklyChangeCard(context, volumeData),
          const SizedBox(height: 24),

          // Tab buttons for Radar/Trend
          _buildViewTabs(context),
          const SizedBox(height: 16),

          // Main chart (Radar or Trend)
          _buildMainChart(context, volumeData),
          const SizedBox(height: 16),

          // Landscape hint
          _buildLandscapeHint(context, volumeData),
          const SizedBox(height: 24),

          // Volume landmarks explanation
          _buildVolumeLandmarksInfo(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Tab buttons to switch between Radar and Trend views
  Widget _buildViewTabs(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              icon: AppIcons.pieChart,
              label: l10n.radarView,
              isSelected: _viewMode == _VolumeViewMode.radar,
              onTap: () => setState(() => _viewMode = _VolumeViewMode.radar),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              icon: AppIcons.trendUp,
              label: l10n.trendView,
              isSelected: _viewMode == _VolumeViewMode.trend,
              onTap: () => setState(() => _viewMode = _VolumeViewMode.trend),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.small,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main chart area with animated switcher
  Widget _buildMainChart(BuildContext context, _VolumeData data) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      child: _viewMode == _VolumeViewMode.radar
          ? _buildRadarChart(context, data)
          : _buildTrendChart(context, data),
    );
  }

  /// Radar chart with concentric zone circles
  Widget _buildRadarChart(BuildContext context, _VolumeData data) {
    final colorScheme = context.colors;

    // Prepare data for radar chart
    // Each axis = muscle group, value = percentage of MRV reached
    const muscles = MuscleGroup.values;
    final radarData = <RadarDataSet>[];

    // Current volume dataset
    final currentValues = <RadarEntry>[];
    for (final muscle in muscles) {
      final sets = data.muscleVolumes[muscle] ?? 0;
      final landmarks = VolumeAnalyzer.defaultLandmarks[muscle]!;
      // Normalize to 0-100 based on MRV
      final percentage = (sets / landmarks.mrv * 100).clamp(0.0, 120.0);
      currentValues.add(RadarEntry(value: percentage));
    }

    radarData.add(
      RadarDataSet(
        fillColor: colorScheme.primary.withValues(alpha: 0.3),
        borderColor: colorScheme.primary,
        borderWidth: 2,
        entryRadius: 4,
        dataEntries: currentValues,
      ),
    );

    return Container(
      key: const ValueKey('radar'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: RadarChart(
              RadarChartData(
                dataSets: radarData,
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
                getTitle: (index, angle) {
                  final muscle = muscles[index];
                  final sets = data.muscleVolumes[muscle] ?? 0;
                  return RadarChartTitle(
                    text: '${_getMuscleShortName(context, muscle)}\n$sets',
                  );
                },
                tickCount: 4,
                ticksTextStyle: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 8,
                ),
                tickBorderData: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
                gridBorderData: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
                radarTouchData: RadarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (response != null && response.touchedSpot != null) {
                      setState(() {
                        _touchedRadarIndex = response.touchedSpot!.touchedRadarEntryIndex;
                      });
                      // Show tooltip
                      if (event is FlTapUpEvent) {
                        _showMuscleTooltip(context, data, _touchedRadarIndex);
                      }
                    }
                  },
                ),
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            ),
          ),
          const SizedBox(height: 16),
          // Zone legend
          _buildZoneLegend(context),
        ],
      ),
    );
  }

  /// Show tooltip with muscle details
  void _showMuscleTooltip(BuildContext context, _VolumeData data, int index) {
    if (index < 0 || index >= MuscleGroup.values.length) return;

    final muscle = MuscleGroup.values[index];
    final sets = data.muscleVolumes[muscle] ?? 0;
    final landmarks = VolumeAnalyzer.defaultLandmarks[muscle]!;
    final zone = VolumeAnalyzer.getVolumeZone(sets, muscle);
    final colorScheme = context.colors;
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(AppIcons.fitnessCenter, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(_getMuscleDisplayName(context, muscle)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTooltipRow(l10n.weeklySets, '$sets', colorScheme.primary),
            _buildTooltipRow(l10n.currentZone, _getZoneName(context, zone), _getZoneColor(zone, colorScheme)),
            const Divider(),
            Text(l10n.volumeLandmarks, style: context.textTheme.labelMedium),
            const SizedBox(height: 8),
            _buildTooltipRow('MV', '${landmarks.mv}', colorScheme.error),
            _buildTooltipRow('MEV', '${landmarks.mev}', colorScheme.tertiary),
            _buildTooltipRow('MAV', '${landmarks.mav}', colorScheme.primary),
            _buildTooltipRow('MRV', '${landmarks.mrv}', colorScheme.error),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Zone legend for radar chart
  Widget _buildZoneLegend(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(context, l10n.belowMaintenance, colorScheme.error),
        _buildLegendItem(context, l10n.maintenance, colorScheme.tertiary),
        _buildLegendItem(context, l10n.effective, Colors.blue),
        _buildLegendItem(context, l10n.optimal, const Color(0xFF4CAF50)),
        _buildLegendItem(context, l10n.excessive, colorScheme.error),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Trend chart showing 4-week progression per muscle
  Widget _buildTrendChart(BuildContext context, _VolumeData data) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    // Build line data for each muscle
    final lineBars = <LineChartBarData>[];
    final muscleColors = _getMuscleColors(colorScheme);

    for (final muscle in MuscleGroup.values) {
      final weeklyData = data.weeklyMuscleVolumes[muscle] ?? [0, 0, 0, 0];
      final spots = <FlSpot>[];

      for (var i = 0; i < 4; i++) {
        spots.add(FlSpot(i.toDouble(), weeklyData[i].toDouble()));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: muscleColors[muscle],
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 5,
              color: muscleColors[muscle]!,
              strokeWidth: 2,
              strokeColor: colorScheme.surface,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return Container(
      key: const ValueKey('trend'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: LineChart(
              LineChartData(
                lineBarsData: lineBars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekLabels = [
                          '${l10n.week} 1',
                          '${l10n.week} 2',
                          '${l10n.week} 3',
                          '${l10n.week} 4',
                        ];
                        if (value.toInt() < weekLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weekLabels[value.toInt()],
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final muscle = MuscleGroup.values[spot.barIndex];
                        return LineTooltipItem(
                          '${_getMuscleShortName(context, muscle)}: ${spot.y.toInt()} ${l10n.sets}',
                          TextStyle(
                            color: muscleColors[muscle],
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            ),
          ),
          const SizedBox(height: 16),
          // Muscle color legend
          _buildMuscleLegend(context, muscleColors),
        ],
      ),
    );
  }

  Widget _buildMuscleLegend(BuildContext context, Map<MuscleGroup, Color> colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: colors.entries.map((entry) {
        return _buildLegendItem(
          context,
          _getMuscleShortName(context, entry.key),
          entry.value,
        );
      }).toList(),
    );
  }

  Map<MuscleGroup, Color> _getMuscleColors(ColorScheme colorScheme) {
    return {
      MuscleGroup.chest: colorScheme.primary,
      MuscleGroup.back: colorScheme.tertiary,
      MuscleGroup.shoulders: Colors.orange,
      MuscleGroup.arms: Colors.purple,
      MuscleGroup.legs: const Color(0xFF4CAF50),
      MuscleGroup.core: Colors.cyan,
    };
  }

  /// Landscape hint button
  Widget _buildLandscapeHint(BuildContext context, _VolumeData data) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () => _openLandscapeView(context, data),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.fullscreen,
              size: AppIconSize.small,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.tapForExpandedView,
              style: context.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open landscape full-screen view
  void _openLandscapeView(BuildContext context, _VolumeData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _LandscapeVolumeChart(
          data: data,
          viewMode: _viewMode,
        ),
      ),
    );
  }

  _VolumeData _calculateVolumeData() {
    final now = DateTime.now();
    final weeklyVolumes = <int, double>{};
    final muscleVolumes = <MuscleGroup, int>{};
    // Track weekly volumes per muscle for trend chart
    final weeklyMuscleVolumes = <MuscleGroup, List<int>>{};

    // Initialize weekly muscle volumes
    for (final muscle in MuscleGroup.values) {
      weeklyMuscleVolumes[muscle] = [0, 0, 0, 0];
    }

    for (final history in widget.exerciseHistories) {
      // Get muscle group from history
      final muscleGroup =
          _getMuscleGroupFromString(history.muscleGroup);

      for (final session in history.sessions) {
        // Week calculation (0 = this week, 1 = last week, etc.)
        final weekDiff = now.difference(session.date).inDays ~/ 7;
        if (weekDiff < 4) {
          weeklyVolumes[weekDiff] =
              (weeklyVolumes[weekDiff] ?? 0) + session.totalVolume;

          // Track sets per muscle per week for trend chart
          if (muscleGroup != null) {
            final weekIndex = 3 - weekDiff; // Convert to 0=oldest, 3=newest
            weeklyMuscleVolumes[muscleGroup]![weekIndex] += session.sets.length;
          }
        }

        // Count sets for muscle groups (last 7 days only)
        if (weekDiff == 0 && muscleGroup != null) {
          muscleVolumes[muscleGroup] =
              (muscleVolumes[muscleGroup] ?? 0) + session.sets.length;
        }
      }
    }

    final thisWeek = weeklyVolumes[0] ?? 0;
    final lastWeek = weeklyVolumes[1] ?? 0;
    final weeklyChange =
        lastWeek > 0 ? ((thisWeek - lastWeek) / lastWeek * 100).round() : 0;

    return _VolumeData(
      weeklyVolumes: List.generate(4, (i) => weeklyVolumes[3 - i] ?? 0),
      weeklyChange: weeklyChange,
      totalVolume: thisWeek,
      previousWeekVolume: lastWeek,
      muscleVolumes: muscleVolumes,
      weeklyMuscleVolumes: weeklyMuscleVolumes,
    );
  }

  MuscleGroup? _getMuscleGroupFromString(String muscle) {
    final lowerMuscle = muscle.toLowerCase();

    if (lowerMuscle.contains('chest') || lowerMuscle.contains('pec')) {
      return MuscleGroup.chest;
    } else if (lowerMuscle.contains('back') ||
        lowerMuscle.contains('lat') ||
        lowerMuscle.contains('trap')) {
      return MuscleGroup.back;
    } else if (lowerMuscle.contains('shoulder') ||
        lowerMuscle.contains('delt')) {
      return MuscleGroup.shoulders;
    } else if (lowerMuscle.contains('arm') ||
        lowerMuscle.contains('bicep') ||
        lowerMuscle.contains('tricep')) {
      return MuscleGroup.arms;
    } else if (lowerMuscle.contains('leg') ||
        lowerMuscle.contains('quad') ||
        lowerMuscle.contains('ham') ||
        lowerMuscle.contains('glute') ||
        lowerMuscle.contains('calf')) {
      return MuscleGroup.legs;
    } else if (lowerMuscle.contains('core') || lowerMuscle.contains('ab')) {
      return MuscleGroup.core;
    }
    return null;
  }

  String _getMuscleShortName(BuildContext context, MuscleGroup muscle) {
    final l10n = context.l10n;
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chestShort;
      case MuscleGroup.back:
        return l10n.backShort;
      case MuscleGroup.shoulders:
        return l10n.shouldersShort;
      case MuscleGroup.arms:
        return l10n.armsShort;
      case MuscleGroup.legs:
        return l10n.legsShort;
      case MuscleGroup.core:
        return l10n.coreShort;
    }
  }

  String _getMuscleDisplayName(BuildContext context, MuscleGroup muscle) {
    final l10n = context.l10n;
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chest;
      case MuscleGroup.back:
        return l10n.back;
      case MuscleGroup.shoulders:
        return l10n.shoulders;
      case MuscleGroup.arms:
        return l10n.arms;
      case MuscleGroup.legs:
        return l10n.legs;
      case MuscleGroup.core:
        return l10n.core;
    }
  }

  String _getZoneName(BuildContext context, VolumeZone zone) {
    final l10n = context.l10n;
    switch (zone) {
      case VolumeZone.belowMaintenance:
        return l10n.belowMaintenance;
      case VolumeZone.maintenance:
        return l10n.maintenance;
      case VolumeZone.effective:
        return l10n.effective;
      case VolumeZone.optimal:
        return l10n.optimal;
      case VolumeZone.excessive:
        return l10n.excessive;
    }
  }

  Color _getZoneColor(VolumeZone zone, ColorScheme colorScheme) {
    switch (zone) {
      case VolumeZone.belowMaintenance:
        return colorScheme.error;
      case VolumeZone.maintenance:
        return colorScheme.tertiary;
      case VolumeZone.effective:
        return colorScheme.primary;
      case VolumeZone.optimal:
        return const Color(0xFF4CAF50);
      case VolumeZone.excessive:
        return colorScheme.error;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.trendUp,
              size: AppIconSize.xxlarge,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDataYet,
              style: context.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completeWorkoutsToSeeStats,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChangeCard(BuildContext context, _VolumeData data) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    final isPositive = data.weeklyChange >= 0;
    final changeColor = isPositive ? colorScheme.primary : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            changeColor.withValues(alpha: 0.15),
            changeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: changeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? AppIcons.trendUp : AppIcons.trendDown,
              color: changeColor,
              size: AppIconSize.large,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weeklyVolumeChange,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${data.weeklyChange}%',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                  ),
                ),
                Text(
                  l10n.vsLastWeek,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Total volume this week with previous week comparison
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.thisWeek,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatVolume(data.totalVolume),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'kg',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Previous week comparison
              if (data.previousWeekVolume > 0)
                Text(
                  '${l10n.lastWeek}: ${_formatVolume(data.previousWeekVolume)} kg',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeLandmarksInfo(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.info,
                size: AppIconSize.small,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.volumeLandmarks,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLandmarkRow(context, 'MV', l10n.maintenanceVolume, colorScheme.error),
          _buildLandmarkRow(context, 'MEV', l10n.minimumEffectiveVolume, colorScheme.tertiary),
          _buildLandmarkRow(context, 'MAV', l10n.maxAdaptiveVolume, colorScheme.primary),
          _buildLandmarkRow(context, 'MRV', l10n.maxRecoverableVolume, colorScheme.error),
        ],
      ),
    );
  }

  Widget _buildLandmarkRow(
      BuildContext context, String abbr, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              abbr,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.toStringAsFixed(0);
  }
}

/// Internal data class for volume calculations
class _VolumeData {
  const _VolumeData({
    required this.weeklyVolumes,
    required this.weeklyChange,
    required this.totalVolume,
    required this.previousWeekVolume,
    required this.muscleVolumes,
    required this.weeklyMuscleVolumes,
  });

  final List<double> weeklyVolumes;
  final int weeklyChange;
  final double totalVolume;
  final double previousWeekVolume;
  final Map<MuscleGroup, int> muscleVolumes;
  final Map<MuscleGroup, List<int>> weeklyMuscleVolumes;
}

/// Landscape full-screen volume chart
class _LandscapeVolumeChart extends StatefulWidget {
  const _LandscapeVolumeChart({
    required this.data,
    required this.viewMode,
  });

  final _VolumeData data;
  final _VolumeViewMode viewMode;

  @override
  State<_LandscapeVolumeChart> createState() => _LandscapeVolumeChartState();
}

class _LandscapeVolumeChartState extends State<_LandscapeVolumeChart> {
  late _VolumeViewMode _currentMode;
  final GlobalKey _chartKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.viewMode;
    // Force landscape orientation and hide system UI for immersive view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  @override
  void dispose() {
    // Restore portrait and show system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Future<void> _shareChart() async {
    if (_isSharing) return;

    // Capture l10n text before async gap
    final shareText = context.l10n.volumeProgression;

    setState(() => _isSharing = true);

    try {
      final boundary = _chartKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/volume_chart.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: shareText,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing chart: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.volumeProgression),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Share button
          IconButton(
            icon: _isSharing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const Icon(AppIcons.share),
            onPressed: _isSharing ? null : _shareChart,
            tooltip: l10n.share,
          ),
          // Toggle view mode
          IconButton(
            icon: Icon(
              _currentMode == _VolumeViewMode.radar
                  ? AppIcons.trendUp
                  : AppIcons.pieChart,
            ),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == _VolumeViewMode.radar
                    ? _VolumeViewMode.trend
                    : _VolumeViewMode.radar;
              });
            },
            tooltip: _currentMode == _VolumeViewMode.radar
                ? l10n.trendView
                : l10n.radarView,
          ),
        ],
      ),
      body: SafeArea(
        child: RepaintBoundary(
          key: _chartKey,
          child: Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentMode == _VolumeViewMode.radar
                  ? _buildLandscapeRadarChart(context)
                  : _buildLandscapeTrendChart(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeRadarChart(BuildContext context) {
    final colorScheme = context.colors;
    const muscles = MuscleGroup.values;
    final radarData = <RadarDataSet>[];

    // Current volume dataset
    final currentValues = <RadarEntry>[];
    for (final muscle in muscles) {
      final sets = widget.data.muscleVolumes[muscle] ?? 0;
      final landmarks = VolumeAnalyzer.defaultLandmarks[muscle]!;
      final percentage = (sets / landmarks.mrv * 100).clamp(0.0, 120.0);
      currentValues.add(RadarEntry(value: percentage));
    }

    radarData.add(
      RadarDataSet(
        fillColor: colorScheme.primary.withValues(alpha: 0.3),
        borderColor: colorScheme.primary,
        borderWidth: 3,
        entryRadius: 6,
        dataEntries: currentValues,
      ),
    );

    return Row(
      key: const ValueKey('landscape_radar'),
      children: [
        // Legend on left
        SizedBox(
          width: 150,
          child: _buildVerticalLegend(context),
        ),
        // Chart in center
        Expanded(
          child: RadarChart(
            RadarChartData(
              dataSets: radarData,
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              titlePositionPercentageOffset: 0.15,
              titleTextStyle: context.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index, angle) {
                final muscle = muscles[index];
                final sets = widget.data.muscleVolumes[muscle] ?? 0;
                return RadarChartTitle(
                  text: '${_getMuscleShortName(context, muscle)}\n$sets',
                );
              },
              tickCount: 4,
              ticksTextStyle: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              tickBorderData: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              gridBorderData: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
        // Volume info on right
        SizedBox(
          width: 150,
          child: _buildMuscleInfoList(context),
        ),
      ],
    );
  }

  Widget _buildLandscapeTrendChart(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final muscleColors = _getMuscleColors(colorScheme);
    final lineBars = <LineChartBarData>[];

    for (final muscle in MuscleGroup.values) {
      final weeklyData = widget.data.weeklyMuscleVolumes[muscle] ?? [0, 0, 0, 0];
      final spots = <FlSpot>[];

      for (var i = 0; i < 4; i++) {
        spots.add(FlSpot(i.toDouble(), weeklyData[i].toDouble()));
      }

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: muscleColors[muscle],
          barWidth: 4,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 6,
              color: muscleColors[muscle]!,
              strokeWidth: 2,
              strokeColor: colorScheme.surface,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return Row(
      key: const ValueKey('landscape_trend'),
      children: [
        // Legend on left
        SizedBox(
          width: 120,
          child: _buildMuscleLegendVertical(context, muscleColors),
        ),
        // Chart expanded
        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: lineBars,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    l10n.sets,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      // Use short labels: S1, S2, S3, S4
                      final weekLabels = ['S1', 'S2', 'S3', 'S4'];
                      final idx = value.toInt();
                      if (idx >= 0 && idx < weekLabels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            weekLabels[idx],
                            style: context.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipMargin: 16,
                  tooltipPadding: const EdgeInsets.all(12),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final muscle = MuscleGroup.values[spot.barIndex];
                      return LineTooltipItem(
                        '${_getMuscleShortName(context, muscle)}: ${spot.y.toInt()} ${l10n.sets}',
                        TextStyle(
                          color: muscleColors[muscle],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLegend(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    final zones = [
      (l10n.belowMaintenance, colorScheme.error),
      (l10n.maintenance, colorScheme.tertiary),
      (l10n.effective, Colors.blue),
      (l10n.optimal, const Color(0xFF4CAF50)),
      (l10n.excessive, colorScheme.error),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.volumeLandmarks,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...zones.map((zone) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: zone.$2,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  zone.$1,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMuscleInfoList(BuildContext context) {
    final colorScheme = context.colors;

    return ListView(
      children: MuscleGroup.values.map((muscle) {
        final sets = widget.data.muscleVolumes[muscle] ?? 0;
        final zone = VolumeAnalyzer.getVolumeZone(sets, muscle);
        final zoneColor = _getZoneColor(zone, colorScheme);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getMuscleShortName(context, muscle),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: zoneColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$sets',
                  style: TextStyle(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMuscleLegendVertical(
    BuildContext context,
    Map<MuscleGroup, Color> colors,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colors.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getMuscleDisplayName(context, entry.key),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getMuscleShortName(BuildContext context, MuscleGroup muscle) {
    final l10n = context.l10n;
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chestShort;
      case MuscleGroup.back:
        return l10n.backShort;
      case MuscleGroup.shoulders:
        return l10n.shouldersShort;
      case MuscleGroup.arms:
        return l10n.armsShort;
      case MuscleGroup.legs:
        return l10n.legsShort;
      case MuscleGroup.core:
        return l10n.coreShort;
    }
  }

  String _getMuscleDisplayName(BuildContext context, MuscleGroup muscle) {
    final l10n = context.l10n;
    switch (muscle) {
      case MuscleGroup.chest:
        return l10n.chest;
      case MuscleGroup.back:
        return l10n.back;
      case MuscleGroup.shoulders:
        return l10n.shoulders;
      case MuscleGroup.arms:
        return l10n.arms;
      case MuscleGroup.legs:
        return l10n.legs;
      case MuscleGroup.core:
        return l10n.core;
    }
  }

  Color _getZoneColor(VolumeZone zone, ColorScheme colorScheme) {
    switch (zone) {
      case VolumeZone.belowMaintenance:
        return colorScheme.error;
      case VolumeZone.maintenance:
        return colorScheme.tertiary;
      case VolumeZone.effective:
        return colorScheme.primary;
      case VolumeZone.optimal:
        return const Color(0xFF4CAF50);
      case VolumeZone.excessive:
        return colorScheme.error;
    }
  }

  Map<MuscleGroup, Color> _getMuscleColors(ColorScheme colorScheme) {
    return {
      MuscleGroup.chest: colorScheme.primary,
      MuscleGroup.back: colorScheme.tertiary,
      MuscleGroup.shoulders: Colors.orange,
      MuscleGroup.arms: Colors.purple,
      MuscleGroup.legs: const Color(0xFF4CAF50),
      MuscleGroup.core: Colors.cyan,
    };
  }
}
