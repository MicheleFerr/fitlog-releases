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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/landscape_metrics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/metric_chip.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/chart_legend.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/landscape_chart_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

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

class _LandscapeGraphScreenState extends ConsumerState<LandscapeGraphScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape on screen mount
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Register orientation observer for auto-rotation back to portrait
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister orientation observer
    WidgetsBinding.instance.removeObserver(this);

    // Restore portrait orientation on screen dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // Auto-pop when device is rotated back to portrait
    if (!mounted) return;

    final orientation = MediaQuery.of(context).orientation;

    // If device rotated to portrait, pop back to exercise detail screen
    if (orientation == Orientation.portrait) {
      // Small delay to avoid conflict with orientation lock
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
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
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Metric selection chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: context.colors.surfaceContainerHighest,
            child: Wrap(
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
    );
  }
}
