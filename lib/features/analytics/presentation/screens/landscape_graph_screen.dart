/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/screens
/// 🎯 Feature: analytics
/// 🔧 Type: screen
///
/// LandscapeGraphScreen - Fullscreen landscape mode graph for exercise metrics
///
/// **Purpose**: Display multi-metric graph in landscape orientation with 0-100 normalization
///
/// **Features**:
/// - Locks device to landscape orientation on mount
/// - Multi-select metrics (1-4 metrics: Volume, Weight, 1RM, Weight×Reps)
/// - 0-100 normalization for all metrics
/// - Chart legend with color coding
/// - Smooth animations and transitions
/// - Restores portrait orientation on dispose
///
/// **Navigation**:
/// - From: ExerciseDetailScreen → Tap fullscreen icon or auto-rotate to landscape
/// - Back: Tap close button or rotate to portrait
///
/// **Usage**:
/// ```dart
/// // Via push
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => LandscapeGraphScreen(
///       exerciseName: 'Bench Press',
///       history: exerciseHistory,
///     ),
///   ),
/// );
/// ```
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/landscape_metrics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/metric_chip.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/chart_legend.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/landscape_chart_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Landscape fullscreen graph screen
///
/// **Orientation Lock**: Sets landscape on mount, restores portrait on dispose
class LandscapeGraphScreen extends ConsumerStatefulWidget {
  const LandscapeGraphScreen({
    required this.exerciseName,
    required this.history,
    super.key,
  });

  /// Exercise name for title
  final String exerciseName;

  /// Exercise history data (ExerciseHistory entity)
  final dynamic history; // Type: ExerciseHistory (avoid circular import)

  @override
  ConsumerState<LandscapeGraphScreen> createState() =>
      _LandscapeGraphScreenState();
}

class _LandscapeGraphScreenState extends ConsumerState<LandscapeGraphScreen> {
  /// GlobalKey for capturing widget as image for sharing
  final GlobalKey _chartKey = GlobalKey();

  /// Track if share operation is in progress
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape on screen mount
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore portrait orientation on screen dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  /// Capture chart as image and share
  ///
  /// **Steps**:
  /// 1. Find RenderRepaintBoundary from GlobalKey
  /// 2. Capture widget as image (PNG)
  /// 3. Convert to byte data
  /// 4. Share via native share sheet (share_plus)
  Future<void> _shareChart() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Find the render object
      final boundary =
          _chartKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find chart to capture');
      }

      // Capture as image (PNG, 2x pixel ratio for quality)
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final bytes = byteData.buffer.asUint8List();

      // Calculate share origin for iOS popover positioning
      // Use center of screen as origin for share sheet
      if (!mounted) return;
      final screenSize = MediaQuery.of(context).size;
      final sharePositionOrigin = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height / 2),
        width: 10,
        height: 10,
      );

      // Share via native share sheet
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: '${widget.exerciseName}_chart.png',
            mimeType: 'image/png',
          ),
        ],
        subject: '${widget.exerciseName} Progress Chart',
        text: 'Check out my ${widget.exerciseName} progress!',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      // Show error to user
      if (mounted) {
        SnackBarService.showError(
          context,
          'Failed to share chart: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: SemanticIcon.button(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
          ),
          onPressed: () => context.pop(),
          tooltip: context.l10n.close,
        ),
        actions: [
          // Share chart button
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
            tooltip: context.l10n.share,
          ),
        ],
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: RepaintBoundary(
        key: _chartKey,
        child: Column(
          children: [
            // Metric selection chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: context.colors.surfaceContainerHighest,
              child: const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MetricChip(metric: MetricType.volume),
                  MetricChip(metric: MetricType.weight),
                  MetricChip(metric: MetricType.oneRmEstimated),
                  MetricChip(metric: MetricType.weightTimesReps),
                ],
              ),
            ),

            // Multi-metric chart with 0-100 normalization
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  // Watch selected metrics from provider
                  final selectedMetrics = ref.watch(landscapeMetricsProvider);

                  return LandscapeChartWidget(
                    history: widget.history,
                    selectedMetrics: selectedMetrics,
                  );
                },
              ),
            ),

            // Chart legend (shows selected metrics with colors)
            const ChartLegend(),
          ],
        ),
      ),
    );
  }
}
