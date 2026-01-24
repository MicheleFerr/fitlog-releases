/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/screens
/// 🎯 Feature: analytics
/// 🔧 Type: screen
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// VOLUME FULLSCREEN SCREEN - Interactive volume trend with zoom/pan
///
/// **Features**:
/// - Period selector: 1M, 3M, 6M, 1Y, All
/// - Zoom/pan with Syncfusion ZoomPanBehavior
/// - Rich tooltips with session preview (top exercises)
/// - Share chart as image
/// - Landscape orientation lock
///
/// **Navigation**:
/// - From: VolumeModal → "View Fullscreen" button
/// - Back: Close button or back gesture
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Period selection enum for filtering data
enum VolumePeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  all,
}

/// Data point for volume chart
class VolumeDataPoint {
  VolumeDataPoint({
    required this.date,
    required this.volume,
    required this.workouts,
    required this.exercises,
  });

  final DateTime date;
  final double volume;
  final int workouts;
  final List<String> exercises; // Top exercises for this day
}

/// Fullscreen volume trend chart
class VolumeFullscreenScreen extends StatefulWidget {
  const VolumeFullscreenScreen({
    required this.exerciseHistories,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;

  @override
  State<VolumeFullscreenScreen> createState() => _VolumeFullscreenScreenState();
}

class _VolumeFullscreenScreenState extends State<VolumeFullscreenScreen> {
  final GlobalKey _chartKey = GlobalKey();
  bool _isSharing = false;
  VolumePeriod _selectedPeriod = VolumePeriod.threeMonths;

  @override
  void initState() {
    super.initState();
    // Lock to landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Calculate period days from enum
  int _getPeriodDays(VolumePeriod period) {
    switch (period) {
      case VolumePeriod.oneMonth:
        return 30;
      case VolumePeriod.threeMonths:
        return 90;
      case VolumePeriod.sixMonths:
        return 180;
      case VolumePeriod.oneYear:
        return 365;
      case VolumePeriod.all:
        return 3650; // ~10 years
    }
  }

  /// Get period label for chip
  String _getPeriodLabel(VolumePeriod period) {
    switch (period) {
      case VolumePeriod.oneMonth:
        return '1M';
      case VolumePeriod.threeMonths:
        return '3M';
      case VolumePeriod.sixMonths:
        return '6M';
      case VolumePeriod.oneYear:
        return '1Y';
      case VolumePeriod.all:
        return 'All';
    }
  }

  /// Calculate volume data points grouped by day
  List<VolumeDataPoint> _calculateDataPoints() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final periodDays = _getPeriodDays(_selectedPeriod);
    final startDate = today.subtract(Duration(days: periodDays));

    // Group by date
    final dataByDate = <DateTime, ({double volume, Set<String> exercises})>{};

    for (final history in widget.exerciseHistories) {
      for (final session in history.sessions) {
        final dateOnly = DateTime(
          session.date.year,
          session.date.month,
          session.date.day,
        );

        if (dateOnly.isAfter(startDate) || dateOnly.isAtSameMomentAs(startDate)) {
          // Calculate session volume (AnalyticsSet has non-nullable weight/reps)
          double sessionVolume = 0;
          for (final set in session.sets) {
            sessionVolume += set.weight * set.reps;
          }

          final existing = dataByDate[dateOnly];
          if (existing != null) {
            dataByDate[dateOnly] = (
              volume: existing.volume + sessionVolume,
              exercises: {...existing.exercises, history.exerciseName},
            );
          } else {
            dataByDate[dateOnly] = (
              volume: sessionVolume,
              exercises: {history.exerciseName},
            );
          }
        }
      }
    }

    // Convert to list and sort
    final dataPoints = dataByDate.entries.map((entry) {
      return VolumeDataPoint(
        date: entry.key,
        volume: entry.value.volume,
        workouts: 1, // Each date = 1 workout day
        exercises: entry.value.exercises.take(3).toList(),
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return dataPoints;
  }

  /// Share chart as image
  Future<void> _shareChart() async {
    if (_isSharing) return;

    // Capture context-dependent values before async gap
    final screenSize = MediaQuery.of(context).size;

    setState(() => _isSharing = true);

    try {
      final boundary =
          _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find chart to capture');
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final bytes = byteData.buffer.asUint8List();
      final sharePositionOrigin = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height / 2),
        width: 10,
        height: 10,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: 'volume_trend.png',
              mimeType: 'image/png',
            ),
          ],
          subject: 'Volume Trend Chart',
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError(
        context,
        'Failed to share chart: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = _calculateDataPoints();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.volumeTrend,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: AppIconSize.medium,
                    height: AppIconSize.medium,
                    child: LoadingIndicator(),
                  )
                : SemanticIcon.button(
                    icon: AppIcons.share,
                    semanticLabel: context.l10n.share,
                  ),
            onPressed: _isSharing ? null : _shareChart,
          ),
        ],
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: RepaintBoundary(
        key: _chartKey,
        child: Column(
          children: [
            // Period selector
            _buildPeriodSelector(context),

            // Chart
            Expanded(
              child: _buildChart(context, dataPoints),
            ),

            // Summary bar
            _buildSummaryBar(context, dataPoints),
          ],
        ),
      ),
    );
  }

  /// Period selector chips
  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colors.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: VolumePeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(_getPeriodLabel(period)),
              selected: isSelected,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => _selectedPeriod = period);
              },
              backgroundColor: context.colors.surfaceContainer,
              selectedColor: context.colors.primaryContainer,
              labelStyle: context.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? context.colors.onPrimaryContainer
                    : context.colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Main chart with zoom/pan
  Widget _buildChart(BuildContext context, List<VolumeDataPoint> dataPoints) {
    if (dataPoints.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noDataForChart,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    }

    final maxVolume = dataPoints.fold<double>(
      0,
      (max, d) => d.volume > max ? d.volume : max,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: DateTimeAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelStyle: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          dateFormat: _getDateFormat(dataPoints),
          majorTickLines: const MajorTickLines(size: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxVolume * 1.15,
          majorGridLines: MajorGridLines(
            color: context.colors.outline.withValues(alpha: 0.15),
            dashArray: const <double>[4, 4],
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          labelFormat: '{value}',
          numberFormat: NumberFormat.compact(),
          majorTickLines: const MajorTickLines(size: 0),
        ),
        // Enable zoom/pan
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          enableDoubleTapZooming: true,
          enableMouseWheelZooming: true,
          zoomMode: ZoomMode.x,
        ),
        // Enhanced trackball tooltip
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.colors.inverseSurface,
            borderRadius: 8,
          ),
          builder: (context, trackballDetails) {
            final dataPoint = trackballDetails.point as VolumeDataPoint?;
            if (dataPoint == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.inverseSurface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.shadow.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    DateFormat('EEEE, d MMMM').format(dataPoint.date),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colors.onInverseSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Volume value
                  Text(
                    '${_formatVolume(dataPoint.volume)} kg',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Exercises preview
                  if (dataPoint.exercises.isNotEmpty) ...[
                    Text(
                      context.l10n.exercises,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onInverseSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...dataPoint.exercises.map((ex) => Text(
                          '• $ex',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onInverseSurface,
                          ),
                        )),
                  ],
                ],
              ),
            );
          },
        ),
        series: <CartesianSeries<VolumeDataPoint, DateTime>>[
          // Area fill
          SplineAreaSeries<VolumeDataPoint, DateTime>(
            dataSource: dataPoints,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.volume,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.colors.warning.withValues(alpha: 0.4),
                context.colors.warning.withValues(alpha: 0.05),
              ],
            ),
            borderWidth: 0,
            animationDuration: 800,
          ),
          // Line
          SplineSeries<VolumeDataPoint, DateTime>(
            dataSource: dataPoints,
            xValueMapper: (data, _) => data.date,
            yValueMapper: (data, _) => data.volume,
            color: context.colors.warning,
            width: 3,
            markerSettings: MarkerSettings(
              isVisible: dataPoints.length <= 30,
              height: 8,
              width: 8,
              borderWidth: 2,
              borderColor: context.colors.warning,
              color: context.colors.surface,
            ),
            animationDuration: 800,
          ),
        ],
      ),
    );
  }

  /// Summary bar at bottom
  Widget _buildSummaryBar(
    BuildContext context,
    List<VolumeDataPoint> dataPoints,
  ) {
    final totalVolume = dataPoints.fold<double>(
      0,
      (sum, d) => sum + d.volume,
    );
    final avgVolume = dataPoints.isNotEmpty ? totalVolume / dataPoints.length : 0.0;
    final workoutDays = dataPoints.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: context.colors.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            label: context.l10n.totalVolume,
            value: '${_formatVolume(totalVolume)} kg',
          ),
          _buildSummaryItem(
            context,
            label: context.l10n.avgPerWorkout,
            value: '${_formatVolume(avgVolume)} kg',
          ),
          _buildSummaryItem(
            context,
            label: context.l10n.totalWorkouts,
            value: '$workoutDays',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatVolume(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }

  DateFormat _getDateFormat(List<VolumeDataPoint> dataPoints) {
    if (dataPoints.length <= 1) return DateFormat('d MMM');
    final range = dataPoints.last.date.difference(dataPoints.first.date);
    if (range.inDays > 180) return DateFormat('MMM');
    if (range.inDays > 30) return DateFormat('d MMM');
    return DateFormat('d');
  }
}
