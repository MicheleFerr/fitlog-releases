/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Material: CustomPainter, Canvas
/// - analytics/presentation/providers: workoutAnalyticsProvider
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Real-time volume chart showing muscle group breakdown
class VolumeChartWidget extends ConsumerWidget {
  
  const VolumeChartWidget({
    super.key,
    this.isCompact = false,
  });
  final bool isCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final analytics = ref.watch(workoutAnalyticsProvider);
    final volumeByMuscleGroup = analytics.currentMetrics?.volumeByMuscleGroup ?? {};
    
    if (volumeByMuscleGroup.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalVolume = volumeByMuscleGroup.values.fold(0.0, (sum, v) => sum + v);
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.volumeByMuscleGroup,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${totalVolume.toStringAsFixed(0)} kg',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isCompact)
              _buildCompactChart(context, theme, colorScheme, volumeByMuscleGroup, totalVolume, l10n)
            else
              _buildDetailedChart(context, theme, colorScheme, volumeByMuscleGroup, totalVolume, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactChart(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<ExerciseCategory, double> volumeByMuscleGroup,
    double totalVolume,
    AppLocalizations l10n,
  ) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          // Pie chart
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: VolumePieChartPainter(
                volumeByMuscleGroup,
                totalVolume,
                colorScheme,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Legend (compact)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: volumeByMuscleGroup.entries
                  .where((entry) => entry.value > 0)
                  .take(3)
                  .map((entry) => _buildLegendItem(
                    context,
                    theme,
                    colorScheme,
                    entry.key,
                    entry.value,
                    totalVolume,
                    l10n,
                  ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedChart(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<ExerciseCategory, double> volumeByMuscleGroup,
    double totalVolume,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Pie chart
        SizedBox(
          height: 150,
          child: CustomPaint(
            painter: VolumePieChartPainter(
              volumeByMuscleGroup,
              totalVolume,
              colorScheme,
            ),
            size: Size.infinite,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Legend (detailed)
        ...volumeByMuscleGroup.entries
            .where((entry) => entry.value > 0)
            .map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: _buildLegendItem(
                context,
                theme,
                colorScheme,
                entry.key,
                entry.value,
                totalVolume,
                l10n,
              ),
            ))
            ,
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    ExerciseCategory category,
    double volume,
    double totalVolume,
    AppLocalizations l10n,
  ) {
    final percentage = totalVolume > 0 ? (volume / totalVolume) * 100 : 0;
    final color = _getMuscleGroupColor(category, colorScheme);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _getMuscleGroupName(category, l10n),
            style: theme.textTheme.bodySmall,
          ),
        ),
        Text(
          '${volume.toStringAsFixed(0)} kg',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getMuscleGroupColor(ExerciseCategory category, ColorScheme colorScheme) {
    switch (category) {
      case ExerciseCategory.chest:
        return colorScheme.primary;
      case ExerciseCategory.back:
        return colorScheme.secondary;
      case ExerciseCategory.shoulders:
        return colorScheme.tertiary;
      case ExerciseCategory.arms:
        return colorScheme.error;
      case ExerciseCategory.legs:
        return colorScheme.outline;
      case ExerciseCategory.abs:
        return colorScheme.surfaceContainerHighest;
      case ExerciseCategory.cardio:
        return colorScheme.inversePrimary;
      case ExerciseCategory.other:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getMuscleGroupName(ExerciseCategory category, AppLocalizations l10n) {
    switch (category) {
      case ExerciseCategory.chest:
        return l10n.chest;
      case ExerciseCategory.back:
        return l10n.back;
      case ExerciseCategory.shoulders:
        return l10n.shoulders;
      case ExerciseCategory.arms:
        return l10n.arms;
      case ExerciseCategory.legs:
        return l10n.legs;
      case ExerciseCategory.abs:
        return l10n.abs;
      case ExerciseCategory.cardio:
        return l10n.cardio;
      case ExerciseCategory.other:
        return l10n.other;
    }
  }
}

/// Custom painter for volume pie chart
class VolumePieChartPainter extends CustomPainter {

  VolumePieChartPainter(
    this.volumeByMuscleGroup,
    this.totalVolume,
    this.colorScheme,
  );
  final Map<ExerciseCategory, double> volumeByMuscleGroup;
  final double totalVolume;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (totalVolume == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2; // Start at top
    
    for (final entry in volumeByMuscleGroup.entries) {
      if (entry.value <= 0) continue;

      final sweepAngle = (entry.value / totalVolume) * 2 * math.pi;
      
      paint.color = _getMuscleGroupColor(entry.key);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw separator line
      final separatorPaint = Paint()
        ..color = colorScheme.surface
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final endX = center.dx + radius * math.cos(startAngle + sweepAngle);
      final endY = center.dy + radius * math.sin(startAngle + sweepAngle);

      canvas.drawLine(
        center,
        Offset(endX, endY),
        separatorPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = colorScheme.surface;
    
    canvas.drawCircle(center, radius * 0.3, centerPaint);
  }

  Color _getMuscleGroupColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return colorScheme.primary;
      case ExerciseCategory.back:
        return colorScheme.secondary;
      case ExerciseCategory.shoulders:
        return colorScheme.tertiary;
      case ExerciseCategory.arms:
        return colorScheme.error;
      case ExerciseCategory.legs:
        return colorScheme.outline;
      case ExerciseCategory.abs:
        return colorScheme.surfaceContainerHighest;
      case ExerciseCategory.cardio:
        return colorScheme.inversePrimary;
      case ExerciseCategory.other:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated volume progress bar
class VolumeProgressBar extends ConsumerWidget {

  const VolumeProgressBar({
    super.key,
    required this.category,
    required this.currentVolume,
    required this.targetVolume,
    this.showPercentage = true,
  });
  final ExerciseCategory category;
  final double currentVolume;
  final double targetVolume;
  final bool showPercentage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final progress = targetVolume > 0 ? (currentVolume / targetVolume).clamp(0.0, 1.0) : 0.0;
    final color = _getMuscleGroupColor(category, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getMuscleGroupName(category, l10n),
              style: theme.textTheme.bodySmall,
            ),
            if (showPercentage)
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            );
          },
        ),
        const SizedBox(height: 2),
        Text(
          '${currentVolume.toStringAsFixed(0)} / ${targetVolume.toStringAsFixed(0)} kg',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getMuscleGroupColor(ExerciseCategory category, ColorScheme colorScheme) {
    switch (category) {
      case ExerciseCategory.chest:
        return colorScheme.primary;
      case ExerciseCategory.back:
        return colorScheme.secondary;
      case ExerciseCategory.shoulders:
        return colorScheme.tertiary;
      case ExerciseCategory.arms:
        return colorScheme.error;
      case ExerciseCategory.legs:
        return colorScheme.outline;
      case ExerciseCategory.abs:
        return colorScheme.surfaceContainerHighest;
      case ExerciseCategory.cardio:
        return colorScheme.inversePrimary;
      case ExerciseCategory.other:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getMuscleGroupName(ExerciseCategory category, AppLocalizations l10n) {
    switch (category) {
      case ExerciseCategory.chest:
        return l10n.chest;
      case ExerciseCategory.back:
        return l10n.back;
      case ExerciseCategory.shoulders:
        return l10n.shoulders;
      case ExerciseCategory.arms:
        return l10n.arms;
      case ExerciseCategory.legs:
        return l10n.legs;
      case ExerciseCategory.abs:
        return l10n.abs;
      case ExerciseCategory.cardio:
        return l10n.cardio;
      case ExerciseCategory.other:
        return l10n.other;
    }
  }
}