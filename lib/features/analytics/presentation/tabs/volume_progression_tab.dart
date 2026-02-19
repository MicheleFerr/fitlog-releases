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
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/emg_movement_ratios.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/volume_analyzer.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/utils/muscle_group_mapper.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/stress_index/presentation/providers/stress_index_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Volume Progression Tab
///
/// Shows how training volume has changed over time,
/// helping users track progressive overload.
///
/// Uses EMG-based ratios for accurate muscle volume distribution
/// when exerciseMuscleMap is provided.
class VolumeProgressionTab extends StatefulWidget {
  const VolumeProgressionTab({
    super.key,
    required this.exerciseHistories,
    this.exerciseMuscleMap,
  });

  final List<ExerciseHistory> exerciseHistories;

  /// Optional map for EMG-based weighted distribution
  final Map<String, ExerciseMuscleData>? exerciseMuscleMap;

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
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + context.tabBarInset),
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

          // Exercises counted this week (only for radar view)
          if (_viewMode == _VolumeViewMode.radar) ...[
            const SizedBox(height: 16),
            _buildExercisesCountedCard(context, volumeData),
          ],
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
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.small,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card showing which exercises are counted this week per muscle group
  Widget _buildExercisesCountedCard(BuildContext context, _VolumeData data) {
    final colorScheme = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.fitnessCenter,
                size: AppIconSize.small,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.exercisesThisWeek,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // List exercises per muscle group
          ...MuscleGroup.values.map((muscle) {
            final exercises = data.exercisesPerMuscle[muscle] ?? {};
            if (exercises.isEmpty) return const SizedBox.shrink();

            final sets = data.muscleVolumes[muscle] ?? 0;
            final zone = VolumeAnalyzer.getVolumeZone(sets, muscle);
            final zoneColor = _getZoneColor(zone, colorScheme);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Muscle header with sets count
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: zoneColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getMuscleDisplayName(context, muscle),
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: zoneColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($sets ${l10n.sets})',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Exercise list with contribution
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercises.entries.map((entry) {
                        final exerciseName = entry.key;
                        final contribution = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.checkCircle,
                                size: 12,
                                color: colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  exerciseName,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '+${contribution.toStringAsFixed(1)}',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
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
            );
          }),
          // Empty state
          if (data.exercisesPerMuscle.values.every((e) => e.isEmpty))
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.noExercisesThisWeek,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                final chartSize =
                    size.shortestSide * 0.85; // Match radar padding
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Zone rings background
                    CustomPaint(
                      size: Size(chartSize, chartSize),
                      painter: _VolumeZoneRingsPainter(
                        numPoints: muscles.length,
                        errorColor: colorScheme.error,
                        tertiaryColor: colorScheme.tertiary,
                        primaryColor: colorScheme.primary,
                        successColor: colorScheme.success,
                      ),
                    ),
                    // Actual radar chart
                    RadarChart(
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
                          final zone = VolumeAnalyzer.getVolumeZone(
                            sets,
                            muscle,
                          );
                          final icon = _getZoneIcon(zone);
                          return RadarChartTitle(
                            text:
                                '$icon ${_getMuscleShortName(context, muscle)}\n$sets',
                          );
                        },
                        tickCount: 4,
                        ticksTextStyle: context.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
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
                            if (response != null &&
                                response.touchedSpot != null) {
                              setState(() {
                                _touchedRadarIndex = response
                                    .touchedSpot!
                                    .touchedRadarEntryIndex;
                              });
                              // Show tooltip
                              if (event is FlTapUpEvent) {
                                _showMuscleTooltip(
                                  context,
                                  data,
                                  _touchedRadarIndex,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    ),
                  ],
                );
              },
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
            _buildTooltipRow(
              l10n.currentZone,
              _getZoneName(context, zone),
              _getZoneColor(zone, colorScheme),
            ),
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
              style: context.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
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
        _buildLegendItem(context, l10n.effective, colorScheme.primary),
        _buildLegendItem(context, l10n.optimal, colorScheme.success),
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
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
                          context.textTheme.bodySmall!.copyWith(
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

  Widget _buildMuscleLegend(
    BuildContext context,
    Map<MuscleGroup, Color> colors,
  ) {
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
      MuscleGroup.shoulders: colorScheme.warning,
      MuscleGroup.arms: colorScheme.secondary,
      MuscleGroup.legs: colorScheme.success,
      MuscleGroup.core: colorScheme.inversePrimary,
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
        builder: (ctx) =>
            _LandscapeVolumeChart(data: data, viewMode: _viewMode),
      ),
    );
  }

  _VolumeData _calculateVolumeData() {
    final now = DateTime.now();
    final weeklyVolumes = <int, double>{};
    final muscleVolumes = <MuscleGroup, double>{};
    // Track weekly volumes per muscle for trend chart (now double for weighted)
    final weeklyMuscleVolumes = <MuscleGroup, List<double>>{};
    // Track exercises contributing to each muscle group this week
    final exercisesPerMuscle = <MuscleGroup, Map<String, double>>{};

    // Initialize weekly muscle volumes and exercises
    for (final muscle in MuscleGroup.values) {
      weeklyMuscleVolumes[muscle] = [0.0, 0.0, 0.0, 0.0];
      muscleVolumes[muscle] = 0.0;
      exercisesPerMuscle[muscle] = {};
    }

    for (final history in widget.exerciseHistories) {
      // Try to get muscle data for weighted distribution
      // Use case-insensitive lookup: try exact match, then lowercase
      final muscleData =
          widget.exerciseMuscleMap?[history.exerciseName] ??
          widget.exerciseMuscleMap?[history.exerciseName.toLowerCase()];

      for (final session in history.sessions) {
        // Days since session
        final daysDiff = now.difference(session.date).inDays;
        // Week calculation (0 = this week, 1 = last week, etc.)
        final weekDiff = daysDiff ~/ 7;

        // Scientific volume is calculated weekly (7 days)
        final isThisWeek = weekDiff == 0;

        if (weekDiff < 4) {
          weeklyVolumes[weekDiff] =
              (weeklyVolumes[weekDiff] ?? 0) + session.totalVolume;

          final setCount = session.sets.length.toDouble();
          final exerciseName = history.exerciseName;

          // Use weighted distribution if muscle data available
          if (muscleData != null && muscleData.hasData) {
            // Get movement pattern from patternMovimento (in fileCategory) or infer
            final movementPattern = muscleData.fileCategory.isNotEmpty
                ? EmgMovementRatios.fromPatternMovimento(
                    muscleData.fileCategory,
                    exerciseName: muscleData.exerciseName.isNotEmpty
                        ? muscleData.exerciseName
                        : history.exerciseName,
                  )
                : EmgMovementRatios.inferPattern(
                    fileCategory: '',
                    exerciseName: muscleData.exerciseName.isNotEmpty
                        ? muscleData.exerciseName
                        : history.exerciseName,
                    focusMuscle: muscleData.primary.isNotEmpty
                        ? muscleData.primary.first
                        : null,
                  );

            // Get EMG-based tiered ratios
            final (primaryRatio, highSynergistRatio, moderateSynergistRatio) =
                EmgMovementRatios.getTieredRatios(movementPattern);

            final weekIndex = 3 - weekDiff; // Convert to 0=oldest, 3=newest

            // Distribute to primary muscles
            if (muscleData.primary.isNotEmpty) {
              final primarySets = setCount * primaryRatio;
              final perPrimary = primarySets / muscleData.primary.length;
              for (final muscle in muscleData.primary) {
                final muscleGroup = _getMuscleGroupFromAbbreviation(muscle);
                if (muscleGroup != null) {
                  weeklyMuscleVolumes[muscleGroup]![weekIndex] += perPrimary;
                  // Add to radar chart for this week only (scientific 7-day volume)
                  if (isThisWeek) {
                    muscleVolumes[muscleGroup] =
                        (muscleVolumes[muscleGroup] ?? 0) + perPrimary;
                    // Track exercise contribution
                    exercisesPerMuscle[muscleGroup]![exerciseName] =
                        (exercisesPerMuscle[muscleGroup]![exerciseName] ?? 0) +
                        perPrimary;
                  }
                }
              }
            }

            // Distribute to secondary muscles with tiered approach
            if (muscleData.secondary.isNotEmpty) {
              // First synergist gets highSynergistRatio
              final firstSynergist = muscleData.secondary.first;
              final highSets = setCount * highSynergistRatio;
              final firstGroup = _getMuscleGroupFromAbbreviation(
                firstSynergist,
              );
              if (firstGroup != null) {
                weeklyMuscleVolumes[firstGroup]![weekIndex] += highSets;
                if (isThisWeek) {
                  muscleVolumes[firstGroup] =
                      (muscleVolumes[firstGroup] ?? 0) + highSets;
                  // Track exercise contribution
                  exercisesPerMuscle[firstGroup]![exerciseName] =
                      (exercisesPerMuscle[firstGroup]![exerciseName] ?? 0) +
                      highSets;
                }
              }

              // Remaining synergists split moderateSynergistRatio
              if (muscleData.secondary.length > 1) {
                final remaining = muscleData.secondary.sublist(1);
                final modSets = setCount * moderateSynergistRatio;
                final perMod = modSets / remaining.length;
                for (final muscle in remaining) {
                  final muscleGroup = _getMuscleGroupFromAbbreviation(muscle);
                  if (muscleGroup != null) {
                    weeklyMuscleVolumes[muscleGroup]![weekIndex] += perMod;
                    if (isThisWeek) {
                      muscleVolumes[muscleGroup] =
                          (muscleVolumes[muscleGroup] ?? 0) + perMod;
                      // Track exercise contribution
                      exercisesPerMuscle[muscleGroup]![exerciseName] =
                          (exercisesPerMuscle[muscleGroup]![exerciseName] ??
                              0) +
                          perMod;
                    }
                  }
                }
              }
            }
          } else {
            // Fallback to single muscle group - try multiple strategies
            // 1. First try history.muscleGroup (may be set on custom exercises)
            MuscleGroup? muscleGroup = _getMuscleGroupFromString(
              history.muscleGroup,
            );

            // 2. If not found, use pattern matching on exercise name (SSOT)
            if (muscleGroup == null) {
              final abbr =
                  MuscleAbbreviationMapper.categorizeExerciseToAbbreviation(
                    history.exerciseName,
                  );
              muscleGroup = _getMuscleGroupFromAbbreviation(abbr);
            }

            if (muscleGroup != null) {
              final weekIndex = 3 - weekDiff;
              weeklyMuscleVolumes[muscleGroup]![weekIndex] += setCount;
              if (isThisWeek) {
                muscleVolumes[muscleGroup] =
                    (muscleVolumes[muscleGroup] ?? 0) + setCount;
                // Track exercise contribution
                exercisesPerMuscle[muscleGroup]![exerciseName] =
                    (exercisesPerMuscle[muscleGroup]![exerciseName] ?? 0) +
                    setCount;
              }
            }
          }
        }
      }
    }

    final thisWeek = weeklyVolumes[0] ?? 0;
    final lastWeek = weeklyVolumes[1] ?? 0;
    final weeklyChange = lastWeek > 0
        ? ((thisWeek - lastWeek) / lastWeek * 100).round()
        : 0;

    // Convert double volumes to int for compatibility with existing UI
    final muscleVolumesInt = muscleVolumes.map(
      (key, value) => MapEntry(key, value.round()),
    );
    final weeklyMuscleVolumesInt = weeklyMuscleVolumes.map(
      (key, value) => MapEntry(key, value.map((v) => v.round()).toList()),
    );

    return _VolumeData(
      weeklyVolumes: List.generate(4, (i) => weeklyVolumes[3 - i] ?? 0),
      weeklyChange: weeklyChange,
      totalVolume: thisWeek,
      previousWeekVolume: lastWeek,
      muscleVolumes: muscleVolumesInt,
      weeklyMuscleVolumes: weeklyMuscleVolumesInt,
      exercisesPerMuscle: exercisesPerMuscle,
    );
  }

  /// Map muscle abbreviation (e.g., PETT, LAT) to MuscleGroup
  ///
  /// Uses centralized [MuscleGroupMapper] as SINGLE SOURCE OF TRUTH.
  MuscleGroup? _getMuscleGroupFromAbbreviation(String abbreviation) {
    return MuscleGroupMapper.fromMuscleAbbreviation(abbreviation);
  }

  /// Map English muscle name (e.g., 'chest', 'back') to MuscleGroup
  ///
  /// Uses centralized [MuscleGroupMapper] as SINGLE SOURCE OF TRUTH.
  MuscleGroup? _getMuscleGroupFromString(String muscle) {
    return MuscleGroupMapper.fromEnglishString(muscle);
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
        return colorScheme.success;
      case VolumeZone.excessive:
        return colorScheme.error;
    }
  }

  /// Get emoji icon for volume zone status
  String _getZoneIcon(VolumeZone zone) {
    switch (zone) {
      case VolumeZone.belowMaintenance:
        return '⚠️'; // Warning - below maintenance
      case VolumeZone.maintenance:
        return '📉'; // Down arrow - just maintaining
      case VolumeZone.effective:
        return '📈'; // Up arrow - effective
      case VolumeZone.optimal:
        return '✅'; // Check - optimal
      case VolumeZone.excessive:
        return '🔥'; // Fire - excessive/overtraining
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
        border: Border.all(color: changeColor.withValues(alpha: 0.3)),
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
          _buildLandmarkRow(
            context,
            'MV',
            l10n.maintenanceVolume,
            colorScheme.error,
          ),
          _buildLandmarkRow(
            context,
            'MEV',
            l10n.minimumEffectiveVolume,
            colorScheme.tertiary,
          ),
          _buildLandmarkRow(
            context,
            'MAV',
            l10n.maxAdaptiveVolume,
            colorScheme.primary,
          ),
          _buildLandmarkRow(
            context,
            'MRV',
            l10n.maxRecoverableVolume,
            colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildLandmarkRow(
    BuildContext context,
    String abbr,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
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
    required this.exercisesPerMuscle,
  });

  final List<double> weeklyVolumes;
  final int weeklyChange;
  final double totalVolume;
  final double previousWeekVolume;
  final Map<MuscleGroup, int> muscleVolumes;
  final Map<MuscleGroup, List<int>> weeklyMuscleVolumes;

  /// Exercises contributing to each muscle group this week with their set contribution
  final Map<MuscleGroup, Map<String, double>> exercisesPerMuscle;
}

/// Landscape full-screen volume chart
class _LandscapeVolumeChart extends StatefulWidget {
  const _LandscapeVolumeChart({required this.data, required this.viewMode});

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
      final boundary =
          _chartKey.currentContext?.findRenderObject()
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
        ShareParams(files: [XFile(file.path)], text: shareText),
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
        backgroundColor: colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
        actions: [
          // Share button
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingIndicator(),
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
        SizedBox(width: 150, child: _buildVerticalLegend(context)),
        // Chart in center
        Expanded(
          child: RadarChart(
            RadarChartData(
              dataSets: radarData,
              radarBackgroundColor: colorScheme.surface.withValues(alpha: 0),
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
        SizedBox(width: 150, child: _buildMuscleInfoList(context)),
      ],
    );
  }

  Widget _buildLandscapeTrendChart(BuildContext context) {
    final colorScheme = context.colors;
    final l10n = context.l10n;
    final muscleColors = _getMuscleColors(colorScheme);
    final lineBars = <LineChartBarData>[];

    for (final muscle in MuscleGroup.values) {
      final weeklyData =
          widget.data.weeklyMuscleVolumes[muscle] ?? [0, 0, 0, 0];
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
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
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
                        context.textTheme.bodySmall!.copyWith(
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
      (l10n.effective, colorScheme.primary),
      (l10n.optimal, colorScheme.success),
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
        ...zones.map(
          (zone) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: zone.$2,
                    borderRadius: BorderRadius.circular(8),
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
          ),
        ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sets',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: zoneColor,
                    fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(8),
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
        return colorScheme.success;
      case VolumeZone.excessive:
        return colorScheme.error;
    }
  }

  Map<MuscleGroup, Color> _getMuscleColors(ColorScheme colorScheme) {
    return {
      MuscleGroup.chest: colorScheme.primary,
      MuscleGroup.back: colorScheme.tertiary,
      MuscleGroup.shoulders: colorScheme.warning,
      MuscleGroup.arms: colorScheme.secondary,
      MuscleGroup.legs: colorScheme.success,
      MuscleGroup.core: colorScheme.inversePrimary,
    };
  }
}

/// Custom painter for volume zone rings on radar chart
///
/// Draws colored polygon rings representing volume zones:
/// - Red (0-30%): Below maintenance volume
/// - Purple (30-45%): Maintenance volume
/// - Blue (45-80%): Effective volume
/// - Green (80-100%): Optimal volume
/// - Red (100%+): Excessive volume
class _VolumeZoneRingsPainter extends CustomPainter {
  _VolumeZoneRingsPainter({
    required this.numPoints,
    required this.errorColor,
    required this.tertiaryColor,
    required this.primaryColor,
    required this.successColor,
  });

  final int numPoints;
  final Color errorColor;
  final Color tertiaryColor;
  final Color primaryColor;
  final Color successColor;

  // Zone thresholds based on average MV/MEV/MAV/MRV percentages
  static const double belowMaintenanceMax = 0.30;
  static const double maintenanceMax = 0.45;
  static const double effectiveMax = 0.80;
  static const double optimalMax = 1.0;
  // Excessive is everything above 100%

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide / 2 * 0.75; // Match radar chart radius

    // Draw zones from outside to inside
    final zones = [
      // Excessive zone (100%+) - thin ring at edge
      _ZoneData(
        innerPercent: optimalMax,
        outerPercent: 1.2, // Goes a bit beyond for overflow
        fillColor: errorColor.withValues(alpha: 0.12),
        borderColor: errorColor.withValues(alpha: 0.3),
      ),
      // Optimal zone (80-100%)
      _ZoneData(
        innerPercent: effectiveMax,
        outerPercent: optimalMax,
        fillColor: successColor.withValues(alpha: 0.12),
        borderColor: successColor.withValues(alpha: 0.35),
      ),
      // Effective zone (45-80%)
      _ZoneData(
        innerPercent: maintenanceMax,
        outerPercent: effectiveMax,
        fillColor: primaryColor.withValues(alpha: 0.10),
        borderColor: primaryColor.withValues(alpha: 0.25),
      ),
      // Maintenance zone (30-45%)
      _ZoneData(
        innerPercent: belowMaintenanceMax,
        outerPercent: maintenanceMax,
        fillColor: tertiaryColor.withValues(alpha: 0.10),
        borderColor: tertiaryColor.withValues(alpha: 0.25),
      ),
      // Below maintenance (0-30%)
      _ZoneData(
        innerPercent: 0,
        outerPercent: belowMaintenanceMax,
        fillColor: errorColor.withValues(alpha: 0.08),
        borderColor: errorColor.withValues(alpha: 0.2),
      ),
    ];

    for (final zone in zones) {
      _drawPolygonRing(
        canvas,
        center,
        maxRadius * zone.innerPercent,
        maxRadius * zone.outerPercent,
        zone.fillColor,
        zone.borderColor,
      );
    }
  }

  void _drawPolygonRing(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
    Color fillColor,
    Color borderColor,
  ) {
    final outerPath = _createPolygonPath(center, outerRadius);
    final innerPath = _createPolygonPath(center, innerRadius);

    // Create ring by subtracting inner from outer
    final ringPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(ringPath, fillPaint);

    // Border (only outer edge)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(outerPath, borderPaint);
  }

  Path _createPolygonPath(Offset center, double radius) {
    final path = Path();
    final angleStep = (2 * math.pi) / numPoints;
    // Start from top (-90 degrees)
    const startAngle = -math.pi / 2;

    for (var i = 0; i < numPoints; i++) {
      final angle = startAngle + (i * angleStep);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _VolumeZoneRingsPainter oldDelegate) {
    return numPoints != oldDelegate.numPoints ||
        errorColor != oldDelegate.errorColor ||
        tertiaryColor != oldDelegate.tertiaryColor ||
        primaryColor != oldDelegate.primaryColor ||
        successColor != oldDelegate.successColor;
  }
}

/// Data class for zone ring parameters
class _ZoneData {
  const _ZoneData({
    required this.innerPercent,
    required this.outerPercent,
    required this.fillColor,
    required this.borderColor,
  });

  final double innerPercent;
  final double outerPercent;
  final Color fillColor;
  final Color borderColor;
}
