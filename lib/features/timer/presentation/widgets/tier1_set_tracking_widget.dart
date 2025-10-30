import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import 'package:gymbro_flutter_new/features/timer/presentation/providers/tier1_set_timing_extension.dart';
import 'package:gymbro_flutter_new/features/timer/domain/entities/set_execution_timing.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// TIER-1 Set Tracking Widget with real-time visualization
/// Shows live metrics, form feedback, and velocity graphs during set execution
class Tier1SetTrackingWidget extends ConsumerWidget {
  
  const Tier1SetTrackingWidget({
    super.key,
    required this.exerciseId,
    required this.setNumber,
    this.showAdvancedMetrics = true,
  });
  final String exerciseId;
  final int setNumber;
  final bool showAdvancedMetrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTrackingSet = ref.watch(isTrackingSetProvider);
    final currentMetrics = ref.watch(currentSetMetricsProvider);
    final shouldStopSet = ref.watch(shouldStopSetProvider);
    final coachingTip = ref.watch(currentCoachingTipProvider);
    final fatigueIndex = ref.watch(setFatigueIndexProvider);
    final velocityDrop = ref.watch(setVelocityDropProvider);
    
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    if (!isTrackingSet || currentMetrics == null) {
      return _buildReadyState(context, theme, l10n);
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with set info and status
            _buildHeader(context, theme, l10n, currentMetrics),
            
            const SizedBox(height: 16),
            
            // Live metrics row
            _buildLiveMetricsRow(context, theme, l10n, currentMetrics),
            
            const SizedBox(height: 16),
            
            // Velocity graph
            if (showAdvancedMetrics) ...[
              _buildVelocityGraph(context, theme, l10n, currentMetrics),
              const SizedBox(height: 16),
            ],
            
            // Fatigue and form indicators
            _buildFatigueFormIndicators(context, theme, l10n, fatigueIndex, currentMetrics.currentFormScore),
            
            const SizedBox(height: 16),
            
            // Coaching feedback
            if (coachingTip != null) ...[
              _buildCoachingTip(context, theme, l10n, coachingTip, shouldStopSet),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            _buildActionButtons(context, theme, l10n, ref, shouldStopSet),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.timer,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setTrackingReady,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.set} $setNumber',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AppLocalizations l10n, LiveSetMetrics metrics) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPhaseColor(metrics.phase, theme),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPhaseText(metrics.phase, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.set} $setNumber',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${l10n.rep} ${metrics.currentRep} • ${_formatDuration(metrics.elapsedMs)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        // Live indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveMetricsRow(BuildContext context, ThemeData theme, AppLocalizations l10n, LiveSetMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            theme,
            l10n.velocity,
            '${metrics.currentVelocityMps.toStringAsFixed(2)} m/s',
            Icons.speed,
            _getVelocityColor(metrics.currentVelocityMps, theme),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            theme,
            l10n.average,
            '${metrics.averageVelocityMps.toStringAsFixed(2)} m/s',
            Icons.trending_up,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            theme,
            l10n.drop,
            '${metrics.velocityDropPercent.toStringAsFixed(1)}%',
            Icons.trending_down,
            _getDropColor(metrics.velocityDropPercent, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVelocityGraph(BuildContext context, ThemeData theme, AppLocalizations l10n, LiveSetMetrics metrics) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.velocityProfile,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateVelocitySpots(metrics),
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: math.max(1.5, metrics.currentVelocityMps * 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFatigueFormIndicators(BuildContext context, ThemeData theme, AppLocalizations l10n, 
      double fatigueIndex, double formScore) {
    return Row(
      children: [
        Expanded(
          child: _buildCircularIndicator(
            context,
            theme,
            l10n.fatigue,
            fatigueIndex,
            _getFatigueColor(fatigueIndex, theme),
            '%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCircularIndicator(
            context,
            theme,
            l10n.form,
            formScore,
            _getFormColor(formScore, theme),
            '%',
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIndicator(BuildContext context, ThemeData theme, String label, 
      double value, Color color, String suffix) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${value.toInt()}$suffix',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachingTip(BuildContext context, ThemeData theme, AppLocalizations l10n, 
      String coachingTip, bool shouldStopSet) {
    final severity = shouldStopSet ? _CoachingSeverity.warning : _CoachingSeverity.info;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity, theme).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getSeverityColor(severity, theme).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getSeverityIcon(severity),
            color: _getSeverityColor(severity, theme),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              coachingTip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getSeverityColor(severity, theme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, AppLocalizations l10n, 
      WidgetRef ref, bool shouldStopSet) {
    return Row(
      children: [
        if (shouldStopSet) ...[
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _completeSet(ref),
              icon: const Icon(Icons.stop),
              label: Text(l10n.stopSet),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _registerRep(ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.addRep),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _completeSet(ref),
              icon: const Icon(Icons.check),
              label: Text(l10n.completeSet),
            ),
          ),
        ],
      ],
    );
  }

  // Helper methods

  Color _getPhaseColor(SetPhase phase, ThemeData theme) {
    switch (phase) {
      case SetPhase.preparation:
        return theme.colorScheme.secondary;
      case SetPhase.execution:
        return theme.colorScheme.primary;
      case SetPhase.completion:
        return theme.colorScheme.tertiary;
      case SetPhase.rest:
        return theme.colorScheme.outline;
    }
  }

  String _getPhaseText(SetPhase phase, AppLocalizations l10n) {
    switch (phase) {
      case SetPhase.preparation:
        return l10n.preparing;
      case SetPhase.execution:
        return l10n.executing;
      case SetPhase.completion:
        return l10n.completed;
      case SetPhase.rest:
        return l10n.resting;
    }
  }

  Color _getVelocityColor(double velocity, ThemeData theme) {
    if (velocity > 1.0) return Colors.green;
    if (velocity > 0.5) return theme.colorScheme.primary;
    return Colors.orange;
  }

  Color _getDropColor(double drop, ThemeData theme) {
    if (drop > 25) return theme.colorScheme.error;
    if (drop > 15) return Colors.orange;
    return Colors.green;
  }

  Color _getFatigueColor(double fatigue, ThemeData theme) {
    if (fatigue > 80) return theme.colorScheme.error;
    if (fatigue > 60) return Colors.orange;
    return Colors.green;
  }

  Color _getFormColor(double form, ThemeData theme) {
    if (form > 80) return Colors.green;
    if (form > 60) return Colors.orange;
    return theme.colorScheme.error;
  }

  List<FlSpot> _generateVelocitySpots(LiveSetMetrics metrics) {
    // Mock velocity data for demo - in real app, would use actual velocity history
    final spots = <FlSpot>[];
    final baseVelocity = metrics.averageVelocityMps;
    
    for (int i = 0; i < 20; i++) {
      final x = i.toDouble();
      final noise = (math.sin(i * 0.5) * 0.1) + (math.Random().nextDouble() * 0.2 - 0.1);
      final y = math.max(0, baseVelocity + noise - (i * 0.02)); // Gradual decline with noise
      spots.add(FlSpot(x, y));
    }
    
    return spots;
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  Color _getSeverityColor(_CoachingSeverity severity, ThemeData theme) {
    switch (severity) {
      case _CoachingSeverity.info:
        return theme.colorScheme.primary;
      case _CoachingSeverity.warning:
        return theme.colorScheme.error;
    }
  }

  IconData _getSeverityIcon(_CoachingSeverity severity) {
    switch (severity) {
      case _CoachingSeverity.info:
        return Icons.info_outline;
      case _CoachingSeverity.warning:
        return Icons.warning_outlined;
    }
  }

  void _registerRep(WidgetRef ref) {
    final unifiedTimer = ref.read(unifiedTimerProvider.notifier);
    unifiedTimer.registerSetRep();
  }

  void _completeSet(WidgetRef ref) {
    final unifiedTimer = ref.read(unifiedTimerProvider.notifier);
    final trackingNotifier = ref.read(tier1SetTrackingProvider.notifier);
    
    unifiedTimer.completeSetTracking().then((completedSet) {
      if (completedSet != null) {
        trackingNotifier.completeSetTracking(completedSet);
      }
    });
  }
}

enum _CoachingSeverity { info, warning }